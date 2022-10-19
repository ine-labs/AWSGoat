FROM php:8.0-apache

RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN apt-get update && apt-get upgrade -y
RUN apt-get install mariadb-client-10.5 -y
RUN apt-get install -y python3 sudo vim libcap2-bin fdisk net-tools netcat

COPY ./src /var/www/html
COPY ./script /usr/local/bin

RUN chmod +x /usr/local/bin/startup.sh

RUN chown -R www-data /var/www/html/documents
RUN echo "www-data ALL=NOPASSWD:/usr/bin/vim /var/www/html/documents" >> /etc/sudoers

RUN chmod 774 -R /var/www/html/documents

CMD ["/usr/local/bin/startup.sh"]
EXPOSE 80