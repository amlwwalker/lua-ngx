resources
https://blog.cloud66.com/supercharging-nginx-with-lua/
https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/
https://www.gakhov.com/articles/implementing-api-based-fileserver-with-nginx-and-lua.html

commands

docker run --name nginx-lua -v "$(pwd)"/lua-plugins:/etc/lua-plugins:ro -v "$(pwd)"/site-config/nginx.conf:/etc/nginx/nginx.conf:ro -v "$(pwd)"/site-config/sites-enabled:/etc/nginx/conf.d:ro -v "$(pwd)"/site-content:/usr/share/nginx/html:ro -v "$(pwd)"/site-config/certs:/etc/ssl/certs -d -p 8080:80 fabiocicerchia/nginx-lua


the approach

a request is made to a backend which responds with  a frontend. Does it set a cookie on the response, so that next request a cookie can be read?

does js reload the page as Frank Walsh's example?

does the first page (homepage) get through and its the next request?