resources
https://blog.cloud66.com/supercharging-nginx-with-lua/
https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/

commands

docker run --name nginx-lua -v "$(pwd)"/lua-plugins:/etc/lua-plugins:ro -v "$(pwd)"/site-config/nginx.conf:/etc/nginx/nginx.conf:ro -v "$(pwd)"/site-config/sites-enabled:/etc/nginx/conf.d:ro -v "$(pwd)"/site-content:/usr/share/nginx/html:ro -v "$(pwd)"/site-config/certs:/etc/ssl/certs -d -p 8080:80 fabiocicerchia/nginx-lua
