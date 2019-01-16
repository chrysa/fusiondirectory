FROM debian:stretch

ENV LDAP_DOMAIN=ducal.me \
    LDAP_PASSWORD=changeme \
    FUSIONDIRECTORY_PASSWORD=changeme2 \
    SMTP_HOST=smtp \
    SMTP_PORT=25 \
    SMTP_TLSCERTCHECK=off

EXPOSE 80

RUN export DEBIAN_FRONTEND=noninteractive && \
    export LC_ALL=en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y software-properties-common gnupg  apt-transport-https && \
    gpg --keyserver keys.gnupg.net --recv-keys E184859262B4981F && \
    gpg -a --export E184859262B4981F | apt-key add - && \
    add-apt-repository 'deb http://repos.fusiondirectory.org/fusiondirectory-releases/fusiondirectory-1.0.9/debian-jessie/ jessie main' && \
    # add-apt-repository 'deb http://repos.fusiondirectory.org/fusiondirectory-extra/debian-jessie jessie main' && \
    apt-get update -q && \
    apt-get install -qy \
        fusiondirectory \
        argonaut-server \
        fusiondirectory \
        fusiondirectory-plugin-argonaut \
        fusiondirectory-plugin-autofs \
        fusiondirectory-plugin-certificates \
        fusiondirectory-plugin-gpg \
        fusiondirectory-plugin-ldapdump \
        fusiondirectory-plugin-ldapmanager \
        fusiondirectory-plugin-mail \
        fusiondirectory-plugin-postfix \
        fusiondirectory-plugin-ssh \
        fusiondirectory-plugin-sudo \
        fusiondirectory-plugin-systems \
        fusiondirectory-plugin-weblink \
        fusiondirectory-plugin-webservice \
        fusiondirectory-smarty3-acl-render \
        fusiondirectory-webservice-shell \
        php-mdb2 \
        php-mbstring \
        php-fpm && \
    # apt-get autoremove -qy software-properties-common gnupg apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

RUN export TARGET=/etc/php/7.0/fpm/php.ini \
 && sed -i -e "s:^;\(opcache.enable\) *=.*$:\1=1:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.enable_cli\) *=.*$:\1=0:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.memory_consumption\) *=.*$:\1=1024:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.max_accelerated_files\) *=.*$:\1=65407:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.validate_timestamps\) *=.*$:\1=0:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.revalidate_path\) *=.*$:\1=1:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.error_log\) *=.*$:\1=/dev/null:" ${TARGET} \
 && sed -i -e "s:^;\(opcache.log_verbosity_level\) *=.*$:\1=1:" ${TARGET} \
 && unset TARGET

RUN export TARGET=/etc/php/7.0/fpm/pool.d/www.conf \
 && sed -i -e "s:^\(listen *= *\).*$:\1/run/php7.0-fpm.sock:" ${TARGET} \
 && sed -i -e "s:^\(user *= *\).*$:\1nginx:" ${TARGET} \
 && unset TARGET

COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY fusiondirectory.conf /fusiondirectory.conf
COPY msmtp.conf /msmtp.conf
COPY start.sh /start.sh

ENTRYPOINT ["/start.sh"]
