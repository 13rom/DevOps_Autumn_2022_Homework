FROM httpd:2.4-alpine
MAINTAINER mailtome@ua.fm
COPY ./public-html/ /usr/local/apache2/htdocs/
EXPOSE 80
RUN echo "ServerName localhost" >> /usr/local/apache2/conf/httpd.conf

