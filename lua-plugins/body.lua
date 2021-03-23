  local http = require("resty.http")
  local json = require "cjson"

local function fetch_via_https(server,path, body)
    local httpc = http.new()
    ok,err = httpc:connect(server,443)
    if err ~= nil then
       ngx.log(ngx.ERR,"Connection Failed " .. err)
       return False
    end

    -- ngx.log(ngx.ERR,"Connection error " .. err)
    -- Trigger the SSL handshake
    session, err = httpc:ssl_handshake(False, server, false)
    local res, err = httpc:request {
        path = path,
        method = 'POST',
        body = body,
        headers = {
        --     ["Authorization"] = "Bearer LRdsr7icoGPa_krmgBRPu0lMK1xMPNoAYby82W_z",
            ["Content-Type"] = "application/json",
            ["Content-Length"] = string.len(tostring(body))
        }
    }

    if not res then
        ngx.log(ngx.ERR,"Request Failed")
        httpc:close()
        return False
    end

    -- Return the connection to the keepalive pool
    httpc:set_keepalive()

    -- Check the status, dispatcher will serve us a 302
    if res.status == 200 then
        body, err = res:read_body()
        return body
    end

    return False
end

local function vesperRequest(OZ_DT,OZ_TC,OZ_S,headers)
  print(headers)
  local VESPER_URL = "httpdump.io"
  local httpc = http.new()
    local request_body = { 
    client_ds = {
      client_error = false,
      et = 10,
      event_success = true,
      fi = "login",
      ip = "127.0.0.1",
      mo = 2,
      pd = "acc",
      pw_match = true,  
      ref = "https://localhost:8080",
      server_error = false,
      url = "https://localhost:8080/whiteopstest.jsp",
      user_geo = "US",
      validation_error = false,
    },
    datatoken = "dfsdfsdf",
    payload = "wrwerweZ_SG",
    session = "w3e4w32wrwe"
  }
  ngx.log(ngx.ERR,"json request body " .. tostring(json.encode(request_body)))
  fetch_via_https(VESPER_URL, "/evntb", json.encode(request_body))
  -- local resp, err = httpc:request_uri("https://httpdump.io/evntb", {
  --     method = "POST",
  --     -- body = json.encode(request_body),
  --     ssl_verify = false,
  --     headers = {
  --               -- ["Authorization"] = "Bearer LRdsr7icoGPa_krmgBRPu0lMK1xMPNoAYby82W_z",
  --               ["Content-Type"] = "application/json",
  --               ["Content-Length"] = string.len(tostring(request_body))
  --     }
  -- })
   
  -- if not resp then
  --     ngx.say("request error :", err)
  --     return
  -- end
   
  -- --Get the status code
  -- ngx.status = resp.status
   
  -- --Get the response header
  -- for k, v in pairs(resp.headers) do
  --     if k ~= "Transfer-Encoding" and k ~= "Connection" then
  --         ngx.header[k] = v
  --     end
  -- end
  -- --Response volume
  -- ngx.say(resp.body)

  -- local http_request = require "http.request"

  -- request_body = json.encode(request_body)
  -- local response_body = {}
  -- local body, code, headers, status = https.request {
  --   url = VESPER_URL,
  --   method = 'POST',
  --   headers = {
  --     ["Authorization"] = "Bearer LRdsr7icoGPa_krmgBRPu0lMK1xMPNoAYby82W_z",
  --     ["Content-Type"] = "application/json",
  --     ["Content-Length"] = string.len(request_body)
  --   },
  --   source = ltn12.source.string(request_body),
  --   sink = ltn12.sink.table(response_body)
  -- }
  -- ngx.say(response_body)
  --careful of request timeout, or how long to wait for response
end 

local function processWhiteOpsTokens(OZ_DT,OZ_TC,OZ_SG, headers)
    vesperRequest()
    if OZ_DT ~= "OZZY_DATA_TOKEN" or OZ_TC ~= "OZZY_CUSTOMER_TOKEN" or OZ_SG ~= "OZZY_SESSION_GENERATED_TOKEN" then 
      ngx.status = 401
      ngx.say("required parameters are incorrect")
      ngx.exit(ngx.OK)
    end
end
local function handleUrlForm(args) 
  if args["OZ_DT"] == nil or args["OZ_TC"] == nil or args["OZ_SG"] == nil then
      ngx.status = 401
      ngx.say("required parameters are missing")
      ngx.exit(ngx.OK)
  end
end

local function continue() -- this should do anything before allowing the request through, like logging
  ngx.status = 200
  ngx.say("welcome to the matrix")
  ngx.exit(ngx.OK)
end

local function abort()
    ngx.status = 410
    ngx.say("no content type")
    ngx.exit(ngx.OK)
end


-- handle processing a body
if ngx.var.request_method == "POST" then
  local args = nil
  args = ngx.req.get_post_args() --retrieve the post args from the body. Note this can be done in nginx.conf however doing it here minimises the changes for a client
    local headers, err = ngx.req.get_headers(0)
  local contentType = ngx.var.content_type
  if contentType == nil then
    abort()
  elseif contentType == "application/x-www-form-urlencoded" then
    handleUrlForm(args) --check required fields exist
    -- if we get to here, they must, so lets read them out
    local OZ_DT = args["OZ_DT"]
    local OZ_TC = args["OZ_TC"]
    local OZ_SG = args["OZ_SG"]
    processWhiteOpsTokens(OZ_DT, OZ_TC, OZ_SG, headers) --vesper decides to block or allow
    continue()
  elseif contentType == "application/json" then
    continue() --handle json before continue
  end
end


