
-- get the body content based on the content-type

-- ngx.say("request is:",ngx.var.request_method)
-- ngx.say("the constant is:",ngx.HTTP_GET,type(ngx.HTTP_GET))
local function vesperRequest(OZ_DT,OZ_TC,OZ_S,headers)
  local VESPER_URL = "https://vesper.p.botx.us/decision"

  local https = require("ssl.https")
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
      timestamp = tostring(os.time()),
      ua = headers.user_agent,
      url = "https://localhost:8080/whiteopstest.jsp",
      user_geo = "US",
      validation_error = false,
    },
    datatoken = OZ_DT,
    payload = OZ_SG,
    session = OZ_TC
  }
  request_body = json.encode(request_body)
  local response_body = {}
  local body, code, headers, status = https.request {
    url = VESPER_URL,
    method = 'POST',
    headers = {
      ["Authorization"] = "Bearer LRdsr7icoGPa_krmgBRPu0lMK1xMPNoAYby82W_z",
      ["Content-Type"] = "application/json",
      ["Content-Length"] = string.len(request_body)
    },
    source = ltn12.source.string(request_body),
    sink = ltn12.sink.table(response_body)
  }
  ngx.say(response_body)
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


