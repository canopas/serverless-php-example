# Build PHP in the Lambda container 
FROM amazonlinux:2 as builder

# Install packages those are require for compiling PHP binary
RUN yum clean all && yum update -y && yum install zip python2-pip autoconf bison gcc gcc-c++ glibc-devel libicu-devel libcurl-devel libxml2-devel gzip tar make php-devel gcc libzip-devel libpng-devel -y

# Install openSSL
RUN curl -sL http://www.openssl.org/source/openssl-1.0.1k.tar.gz | tar -xvz && cd openssl-1.0.1k && ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl \ && make && make install && cd ~

# Compile PHP binary with all extensions those are require by php web applications. You can add more if you require..
RUN mkdir -p ~/php-bin && curl -sL https://github.com/php/php-src/archive/php-7.3.1.tar.gz | tar -xvz && cd php-src-php-7.3.1 && ./buildconf --force \
    && ./configure --prefix=/opt/php-bin/ --with-openssl=/usr/local/ssl --with-libzip --with-curl --without-pear --enable-mbstring --with-gd --with-zip --enable-gd-native-ttf --with-mhash --with-mysql --with-mysqli --with-pdo-mysql --enable-intl \
    && make install


FROM php:7.3.1

# Install required packages
RUN apt-get update && apt-get install -y jq zip python3-pip

# Install aws-cli for uploading lambda function through command line.
RUN pip3 install --upgrade awscli

# Install composer to install guzzlehttp/guzzle.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy php-cgi from amazonlinux:2 image.
COPY --from=0 /opt/php-bin/bin/php-cgi /

# Copy all files required by lambda function and runtime.
COPY /php /

# Change working directory.
WORKDIR "/"

# Install guzzlehttp/guzzle using composer, We are using guzzlehttp/guzzle for http requests.
RUN composer require guzzlehttp/guzzle && chmod +x bootstrap

# Create zip files for deploying to Lambda function
RUN zip -r runtime.zip extra-libraries bootstrap runtime.php vendor php-cgi && zip -r src.zip src

# Run deploy.sh that contains commands to deploy lambda function.
RUN chmod +x deploy.sh && ./deploy.sh
