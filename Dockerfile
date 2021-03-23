FROM fabiocicerchia/nginx-lua

VOLUME ["/etc/nginx/conf.d", "/etc/nginx/conf.d/sites-enabled", "/etc/nginx/conf.d/certs", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
CMD ["nginx"]

# Expose ports.
EXPOSE 80
EXPOSE 443


for ubuntu version

apt-get update
apt-get install -y build-essential
apt-get install -y unzip
apt-get install -y m4
luarocks install httpclient
luarocks install luasocket
luarocks install luasec
luarocks install lunajson obselete


https://github.com/ledgetech/lua-resty-http
https://stackoverflow.com/questions/48319678/install-resty-http-with-already-installed-openresty
curl https://raw.githubusercontent.com/ledgetech/lua-resty-http/master/lib/resty/http.lua -o http.lua