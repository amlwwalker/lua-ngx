local PLAIN_COOKIE = ""

function findCookie (cookieName)
  ngxCookieName = "cookie_" .. cookieName
  ngx.log(ngx.STDERR, "cookieName: " .. ngxCookieName)
    if ngx.var[ngxCookieName] ~= nil and ngx.var[ngxCookieName] ~= "" then --not nil and not blank
     storage = ngx.var[ngxCookieName]
     ngx.log(ngx.STDERR, "PLAIN_COOKIE: " .. storage)
    else
      ngx.log(ngx.STDERR, "PLAIN_COOKIE is blank")
      ngx.header["Content-type"] = "text/html"
      ngx.say('<html><head><script language="javascript">var gate=true;</script></head><body>There is something terribly wrong with your request</body></html>');
      ngx.exit(0)
    end
    return storage
end

PLAIN_COOKIE = findCookie("PLAIN_COOKIE")


