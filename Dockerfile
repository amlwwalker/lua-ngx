FROM fabiocicerchia/nginx-lua

VOLUME ["/etc/nginx/conf.d", "/etc/nginx/conf.d/sites-enabled", "/etc/nginx/conf.d/certs", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
CMD ["nginx"]

# Expose ports.
EXPOSE 80
EXPOSE 443