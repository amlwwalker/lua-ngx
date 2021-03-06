local http = require("resty.http")
local json = require ("cjson") -- currently used to convert table to json
local function fetch_via_https(server,path, body)
    local httpc = http.new()
    ok,err = httpc:connect(server,443)
    if err ~= nil then
       ngx.log(ngx.ERR,"Connection Failed " .. err)
       return 400, "", err
    end
    session, err = httpc:ssl_handshake(False, server, false)
    local res, err = httpc:request {
        path = path,
        method = 'POST',
        body = body,
        headers = {
            ["Authorization"] = "Bearer LRdsr7icoGPa_krmgBRPu0lMK1xMPNoAYby82W_z",
            ["Content-Type"] = "application/json",
            ["Content-Length"] = string.len(tostring(body))
        }
    }

    if not res then
        ngx.log(ngx.ERR,"Request Failed")
        httpc:close()
        return 400, "", err
    end

    -- Return the connection to the keepalive pool
    httpc:set_keepalive()
    body, err = res:read_body()
    return res.status, body, err
end

local function handleUrlForm(args) 
  if args["OZ_DT"] == nil or args["OZ_TC"] == nil or args["OZ_SG"] == nil then
      ngx.status = 401
      ngx.say("required parameters are missing")
      ngx.exit(ngx.OK)
  end
end


local function abort(message)
    ngx.status = 410
    ngx.say(message)
    ngx.exit(ngx.OK)
end


local function continue(status, body, err) -- this should do anything before allowing the request through, like logging
  if err ~= nil then
    ngx.log(ngx.ERR, "json request body err " .. err)
    abort("json request body err " .. err)
  elseif status ~= 203 then
    ngx.log(ngx.ERR, "incorrect status code")
    abort("incorrect status code")
  else
    local jsonRaw = json.decode( body )
    local jsonparse = json.decode( jsonRaw )
    ngx.log(ngx.ERR,"jsonparse " .. body .. " " .. jsonparse["action"])
    if jsonparse["action"] ~= "allow" then
      abort(jsonparse["action"] ~= "allow")
    end
  end
  ngx.status = 200
  ngx.say("welcome to the matrix")
  ngx.exit(ngx.OK)
end

local function vesperRequest(OZ_DT,OZ_TC,OZ_SG,headers)
  for k, v in pairs(headers) do
      ngx.log(ngx.ERR,"header " .. k .. " " .. v)
  end
  local httpc = http.new()
  local mockResponse = {
    action = "allow",
    bot = false
  }
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
      ua = headers["user_agent"],
      ref = "https://localhost:8080",
      server_error = false,
      url = "https://localhost:8080/whiteopstest.jsp",
      user_geo = "US",
      validation_error = false,
    },
    datatoken = OZ_DT,
    payload = OZ_TC,
    session = OZ_SG,
    __response = json.encode(mockResponse),
    __status = "203"
  }
  status, body, err = fetch_via_https("httpdump.io", "/evntb", json.encode(request_body))
  if err ~= nil then
    ngx.log(ngx.ERR, "json request body err " .. err)
  else
    ngx.log(ngx.ERR,"json request body status " .. status .. " body " .. body)
  end
  return status, body, err
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
    status, body, err = vesperRequest(OZ_DT,OZ_TC,OZ_SG, headers)
    continue(status, body, err)
  elseif contentType == "application/json" then
    continue() --handle json before continue
  end
end


