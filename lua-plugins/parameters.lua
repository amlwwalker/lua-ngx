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

ngx.log(ngx.STDERR, "cookie_OZDT: " .. OZ_DT)