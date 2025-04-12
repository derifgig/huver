FROM openresty/openresty:alpine

RUN apk update && apk add --no-cache bash vim

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
#
COPY html /html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
