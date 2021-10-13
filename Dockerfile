#Lambda base image Amazon linux 2
FROM public.ecr.aws/lambda/provided:al2 as builder

# Set desired PHP Version
ARG php_version="7.4"

# Install environment assets
RUN yum clean all && \
    yum install -y amazon-linux-extras \
                   libcurl-devel

# Install PHP
RUN amazon-linux-extras enable php${php_version}
RUN yum install -y php-cli

# Download Composer
RUN curl -sS https://getcomposer.org/installer | /usr/bin/php -- --install-dir=/opt/ --filename=composer

# Install Guzzle, prepare vendor files
RUN mkdir /lambda-php-vendor && \
    cd /lambda-php-vendor && \
    /usr/bin/php /opt/composer require guzzlehttp/guzzle

# Prepare runtime files
COPY runtime/bootstrap /lambda-php-runtime/
RUN chmod 0755 /lambda-php-runtime/bootstrap

###### Create runtime image ######
FROM public.ecr.aws/lambda/provided:al2 as runtime

# Set desired PHP Version
ARG php_version="7.4"

# Layer 1: PHP Binaries
# Install environment assets
RUN yum clean all && \
    yum install -y amazon-linux-extras

# Install PHP
RUN amazon-linux-extras enable php${php_version}
RUN yum install -y php-cli

# Layer 2: Runtime Interface Client
COPY --from=builder /lambda-php-runtime /var/runtime

# Layer 3: Vendor
COPY --from=builder /lambda-php-vendor/vendor /opt/vendor
COPY lambda/ /var/task/

CMD [ "app.handler" ]
