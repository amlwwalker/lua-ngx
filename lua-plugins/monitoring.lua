local remote_addr = ngx.var.remote_addr
ngx.log(ngx.STDERR, "monitoring: " .. remote_addr)