#Dir for extensions config /usr/local/etc/php/conf.d/

FROM deluxo/php7.0-fpm:v1
USER root

RUN apt-get update
RUN apt-get install -y php7.0-dev php-pear php7.0-common

RUN apt-get install -y curl libcurl4-openssl-dev

RUN apt-get install -y php-curl
RUN apt-get install -y libxml2-dev
RUN apt-get install -y php7.0-mbstring
RUN apt-get install -y php7.0-mysql
RUN apt-get update && apt-get install -y libmagickwand-6.q16-dev --no-install-recommends \
 && ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin \
 && pecl install imagick \
 && echo "extension=imagick.so" > /etc/php/7.0/mods-available/ext-imagick.ini \
 && ln -s /etc/php/7.0/mods-available/ext-imagick.ini /etc/php/7.0/cli/conf.d/20-imagic.ini

RUN pecl install redis
RUN touch /etc/php/7.0/mods-available/docker-php-redis.ini
RUN echo extension=redis.so >> /etc/php/7.0/mods-available/docker-php-redis.ini
RUN ln -s /etc/php/7.0/mods-available/docker-php-redis.ini /etc/php/7.0/cli/conf.d/20-redis.ini

#RUN pecl install xdebug-2.4.1
#RUN docker-php-ext-enable xdebug
#RUN touch /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.remote_autostart=0 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.remote_mode=req >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.remote_handler=dbgp >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.remote_connect_back=1 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.remote_port=9123 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.remote_host=192.168.1.22 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.idekey=PHPSTORM >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.remote_enable=1 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.profiler_append=0 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.profiler_enable=0 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.profiler_enable_trigger=1 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.profiler_output_dir=/var/debug >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.profiler_output_name=cachegrind.out.%s.%u >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.var_display_max_data=-1 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.var_display_max_children=-1 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN echo xdebug.var_display_max_depth=-1 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apt-get install -y geoip-bin geoip-database libgeoip-dev php-geoip

RUN apt-get install -y wget
RUN wget https://phar.phpunit.de/phpunit.phar
RUN chmod +x phpunit.phar
RUN mv phpunit.phar /usr/local/bin/phpunit

RUN apt-get install -y libboost-all-dev gperf libevent-dev uuid-dev libevent-dev libcloog-ppl-dev

RUN mkdir gearmand
RUN cd /gearmand && wget https://launchpad.net/gearmand/1.2/1.1.12/+download/gearmand-1.1.12.tar.gz
RUN cd /gearmand && tar -zxvf gearmand-1.1.12.tar.gz
RUN cd /gearmand/gearmand-1.1.12 && ./configure
RUN cd /gearmand/gearmand-1.1.12 && make
RUN cd /gearmand/gearmand-1.1.12 && make install

RUN mkdir gearman
RUN cd /gearman && wget https://github.com/wcgallego/pecl-gearman/archive/master.tar.gz \
&& tar -zxvf master.tar.gz
RUN cd /gearman/pecl-gearman-master && phpize
RUN cd /gearman/pecl-gearman-master && ./configure
RUN cd /gearman/pecl-gearman-master && make
RUN cd /gearman/pecl-gearman-master && make install

RUN touch /etc/php/7.0/mods-available/gearman.ini
RUN echo extension=gearman.so >> /etc/php/7.0/mods-available/gearman.ini
RUN ln -s /etc/php/7.0/mods-available/gearman.ini /etc/php/7.0/cli/conf.d/20-gearman.ini

RUN mkdir -p /usr/local/etc/php-fpm.d/
RUN mkdir -p /usr/local/var/log/
ADD php-fpm /usr/local/sbin/
ADD docker.conf /usr/local/etc/php-fpm.d/
ADD php-fpm.conf /usr/local/etc/
ADD www.conf /usr/local/etc/php-fpm.d/
ADD www.conf.default /usr/local/etc/php-fpm.d/
ADD zz-docker.conf /usr/local/etc/php-fpm.d/

#RUN apt-get install -y php-fpm

ADD php.ini /usr/local/etc/php/
RUN  mkdir -p  /usr/local/lib/php/extensions/no-debug-non-zts-20151012/
RUN cp -r /usr/lib/php/20151012/* /usr/local/lib/php/extensions/no-debug-non-zts-20151012/

WORKDIR /var/www

CMD ["php-fpm"]
