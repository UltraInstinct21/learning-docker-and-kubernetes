FROM nginx:latest

RUN apt-get update
RUN apt-get install -y vim


# /home/sarthi/Projects/Learning/docker-kubernetes/docker/index.html

COPY index.html /usr/share/nginx/html/index.html
RUN chown nginx:nginx /usr/share/nginx/html/index.html