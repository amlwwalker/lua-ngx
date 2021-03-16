--First three blocks take the cookie chunks and concatenate them back into three local variables that
--map to the expected OZ values we use in our Vesper API call
local OZ_DT = ""
local OZ_TC = ""
local OZ_SG = ""

local i=1
while true do
   local cookieName = "cookie_OZDT" .. tostring(i)
   if ngx.var[cookieName] == nil then
	   break
   end
   OZ_DT = OZ_DT .. ngx.var[cookieName]
   i=i+1
end

i=1
while true do
   local cookieName = "cookie_OZTC" .. tostring(i)
   if ngx.var[cookieName] == nil then
           break
   end
   OZ_TC = OZ_TC .. ngx.var[cookieName]
   i=i+1
end

i=1
while true do
   local cookieName = "cookie_OZSG" .. tostring(i)
   if ngx.var[cookieName] == nil then
           break
   end
   OZ_SG = OZ_SG .. ngx.var[cookieName]
   i=i+1
end

--Here we have the three values (still URL encoded so they were safe in cookies)
--I generate an object using the lua module luasec - you can install this on your box
--using the luarocks program (i.e. luarocks install luasec
local headers, err = ngx.req.get_headers(0)
local https = require("ssl.https")
--Here just for sample sake I construct the POST body I'm going to send to the Vesper API
--Some of the values I present here are hard-coded, and a few would bear no relevance to a request we
--were processing ahead of app code (e.g. event_success would be unknown to us since we are ahead of the
--HTTP request being processed by the application logic
local postBody = "{ \"client_ds\":"
postBody = postBody ..  "{";
postBody = postBody .. "\"client_error\": false,"
postBody = postBody .. "\"et\": \"10\","
postBody = postBody .. "\"event_success\": true,"
postBody = postBody .. "\"fi\": \"login\","
postBody = postBody .. "\"ip\": \"127.0.0.1\","
postBody = postBody .. "\"mo\": \"2\","
postBody = postBody .. "\"pd\": \"acc\","
postBody = postBody .. "\"pw_match\": true,"
postBody = postBody .. "\"ref\": \"https://localhost:8080\","
postBody = postBody .. "\"server_error\": false,"
postBody = postBody .. "\"timestamp\":" .. tostring(os.time()) .. ","
postBody = postBody .. "\"ua\": \"" .. headers.user_agent .. "\","
postBody = postBody .. "\"url\": \"https://localhost:8080/whiteopstest.jsp\","
postBody = postBody .. "\"user_geo\": \"US\","
postBody = postBody .. "\"validation_error\": false },"
postBody = postBody .. "\"datatoken\": \"" .. string.gsub(string.gsub(ngx.unescape_uri(OZ_DT),"\\","\\\\"),"\"","\\\"") .. "\","
postBody = postBody .. "\"payload\": \"" .. string.gsub(string.gsub(ngx.unescape_uri(OZ_SG),"\\","\\\\"),"\"","\\\"") .. "\","
postBody = postBody .. "\"session\": \"" .. string.gsub(string.gsub(ngx.unescape_uri(OZ_TC),"\\","\\\\"),"\"","\\\"") .. "\""
postBody = postBody .. "}"

--note above that we are appending the three OZ values only after unescaping them then adjusting the values so they
--don't break JSON RFC 8259 formatting rules (e.g. the use of double quotes that aren't unescaped. the use of \ that isn't escaped
--ideally our signal values wouldn't include these characters or our signal JS would automatically escape these values before
--giving them to someone to append to a REST JSON body

ngx.req.clear_header("Cookie")
--NEED TO WRITE CODE TO CARRY NON WHITEOPS COOKIES FORWARD
--for the time being I'm just wiping the ngx cookies. LUA doesn't have a way to wipe a specific
--cookie that I could easily find. However, we can read cookies, we can clear a header, and
--we can set a header, so the easiest way to do this would be to take the "Cookie String" split it
--everytime we see a semi-colon, then create an empty string, sweep the array sub-strings for any
--that contain OZDT[0-9]= with a regex string, and anytime we get true from that regex, NOT append
--it to the new cookie string, then subsequently call set_header to set the stripped Cookie header
--which will move toward the downstream application

--Here we place the Vesper API request, before this was used it would need to be in a try/catch and timeout/dns res failure would need
--to be accounted for in both request/response processing and in how app protection would react
local respbody = {}
local body, code, headers, status = https.request {
        method = "POST",
        url = "https://vesper.p.botx.us/decision",
        source = ltn12.source.string(postBody),
        headers = {
	    ["Authorization"] = "Bearer LRdsr7icoGPa_krmgBRPu0lMK1xMPNoAYby82W_z",
	    ["Content-Type"] = "application/json",
	    ["Content-Length"] = tostring(#postBody)
        },
	sink = ltn12.sink.table(respbody)
    }
respbody = table.concat(respbody)
--Initially when I was looking at LUA I was struggling to see if this approach to placing a request was async or sync and if I
--might end up ahead of myself executing code beneath this before a decision was retrieved, then I found this clever site
--http://slowwly.robertomurray.co.uk - using it you can simulate a delay of any length before an HTTP 302 redirects you.
--for example http://slowwly.robertomurray.co.uk/delay/3000/url/https://www.example.com will wait 3 seconds before replying
--with the example.com page. From this I could tell that the execution of this code is SYNC, so I can just leave it as is for
--the sake of this example

--Now I load a JSON parsing function - I know... why use it here and not above. Well because it was easier to parse json this
--way then it would be manually, for it would be just as easy to just sweep the return string for the word "block" and then not
--have to add lunajson module using luarocks.
local lunajson = require 'lunajson'
local respJSON = lunajson.decode(respbody)
--here we basically say hey if the JSON said to block then don't progress down to proxy-pass whatever is behind nginx, instead server
--the waiting room page content and exit the Request/Response lifecycle. Important to note that the sub-filters still apply so the
--page body here doesn't have the script tag in it, because the sub-filter appends it after I say to do this. Sub-filter execution
--comes AFTER you use exit to finish constructing the page you want to send back.
if respJSON["action"] == "block" then
    ngx.header["Content-type"] = "text/html"
    ngx.say('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><script language="javascript">var gate=true;</script></head><body>Checking your browser... Please Wait.</body></html>');
    ngx.exit(0)
end

-- This is just test code from when I was looking at how Vesper was replying.
-- ngx.var.VesperTestPassed = postBody .. "<br/>" .. respbody
-- ngx.var.VesperResponse = respbody
