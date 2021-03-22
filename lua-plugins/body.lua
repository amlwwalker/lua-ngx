
-- get the body content based on the content-type

-- ngx.say("request is:",ngx.var.request_method)
-- ngx.say("the constant is:",ngx.HTTP_GET,type(ngx.HTTP_GET))

local args = nil

if ngx.var.request_method == "POST" then
  local contentType = ngx.var.content_type
  -- ngx.req.read_body() -- doing this now in nginx location block. Maybe better here
  args = ngx.req.get_post_args()
  if contentType == nil then
    ngx.status = 410
    ngx.say("no content type")
    ngx.exit(ngx.OK)
  elseif contentType == "application/x-www-form-urlencoded" then
    if args["OZ_DT"] == nil or args["OZ_TC"] == nil or args["OZ_SG"] == nil then
      ngx.status = 401
      ngx.say("required parameters are missing")
      ngx.exit(ngx.OK)
    end
    local OZ_DT = args["OZ_DT"]
    local OZ_TC = args["OZ_TC"]
    local OZ_SG = args["OZ_SG"]
    if OZ_DT ~= "OZZY_DATA_TOKEN" or OZ_TC ~= "OZZY_CUSTOMER_TOKEN" or OZ_SG ~= "OZZY_SESSION_GENERATED_TOKEN" then 
      ngx.status = 401
      ngx.say("required parameters are incorrect")
      ngx.exit(ngx.OK)
    end
    ngx.status = 200
    ngx.say("welcome to the matrix: " .. contentType)
    ngx.exit(ngx.OK)
  else
    ngx.status = 410
    ngx.say("contentType: " .. contentType)
    ngx.exit(ngx.OK)
  end
end

-- local contentType = ngx.var.content_type
-- ngx.log(ngx.STDERR, "contentType: " .. contentType)

-- if contentType == "application/x-www-form-urlencoded" then
--   ngx.log(ngx.STDERR, "contentType: " .. contentType)
--   ngx.say("content type is x-www-form-urlencoded")
--   ngx.exit(ngx.HTTP_OK)
-- end


-- ngx.exit(ngx.HTTP_OK)
