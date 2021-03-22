access_by_lua_block {
    local cjson = require("cjson")
 
    -- check if user with access_token can we authenticated
    function authenticate_user(access_token)
        local params = {
            method = ngx.HTTP_GET,
            args = {
                access_token = access_token
            }
        }

        local res = ngx.location.capture("/_auth/access/check", params)
        if not res or res.status ~= 200 then
            return nil
        end

        return cjson.decode(res.body)
    end

    -- if user has no access_token, return 403 Forbidden
    local access_token = ngx.var.arg_access_token
    if not access_token then
       return_http_forbidden("Forbidden", "Forbidden")
    end

    -- authenticate user
    local credentials = authenticate_user(access_token)

    -- if user can't be resolved, return 403 Forbidden
    if not credentials or not credentials.data.user.id then
        return_http_forbidden("Forbidden", "Forbidden")
    end
}