local remote_addr = ngx.var.remote_addr
local uri = ngx.var.uri

if string.match(remote_addr, "172.17.0.1") then -- change the IP here to your IP that the log below prints out

	ngx.log(ngx.STDERR, "ALLOWING: " .. remote_addr)
  -- we are ok here!
else
	ngx.log(ngx.STDERR, "BLOCKING: " .. remote_addr)
  ngx.exit(ngx.HTTP_FORBIDDEN)
end