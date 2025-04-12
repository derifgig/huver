FROM nginx:latest

# Установим Lua и необходимые библиотеки
RUN apt-get update && apt-get install -y \
    lua5.1 \
    libnginx-mod-http-lua \
    lua-cjson \
    lua-filesystem \
    && rm -rf /var/lib/apt/lists/*

# Копируем наш Lua скрипт и конфиг NGINX
COPY huver_lua.lua /usr/share/nginx/html/huver_lua.lua
COPY style.css /usr/share/nginx/html/style.css
COPY nginx.conf /etc/nginx/nginx.conf

# Монтируем папку с файлами
VOLUME /usr/share/nginx/html/files

# Открываем порт 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

