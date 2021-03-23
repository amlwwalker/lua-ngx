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
