# Etapa de build
FROM composer:latest AS vendor

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-scripts --no-interaction

# Etapa final
FROM php:8.2-fpm-alpine

# Instalar dependências do sistema
RUN apk add --no-cache \
    bash \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    libzip-dev \
    zip \
    unzip \
    oniguruma-dev \
    icu-dev \
    php82-pdo_pgsql \
    postgresql-dev \
    php82-pgsql

# Extensões PHP
RUN docker-php-ext-install pdo pdo_pgsql mbstring zip exif pcntl intl

# Instalar Composer
COPY --from=vendor /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

COPY --from=vendor /app/vendor ./vendor

# Permissões
RUN chown -R www-data:www-data /var/www

USER www-data

CMD ["php-fpm"]
