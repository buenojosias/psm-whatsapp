# Multi-stage build para resolver problemas de dependências
FROM composer:2.7 as composer

WORKDIR /app

# Copiar apenas arquivos de dependências primeiro
COPY composer.json composer.lock* ./

# Configurar composer para resolver conflitos
RUN composer config --global repos.packagist composer https://packagist.org
RUN composer config --global allow-plugins.php-http/discovery true
RUN composer config --global allow-plugins.pestphp/pest-plugin true

# Instalar dependências com resolução de conflitos
RUN composer install \
    --no-scripts \
    --no-autoloader \
    --no-dev \
    --prefer-dist \
    --ignore-platform-reqs

# Stage final
FROM php:8.2-fpm-alpine

# Instalar dependências do sistema
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    zip \
    unzip \
    supervisor \
    nginx \
    nodejs \
    npm \
    netcat-openbsd \
    bash

# Instalar extensões PHP necessárias para Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        sockets

# Instalar Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Criar usuário para aplicação
RUN addgroup -g 1000 www && \
    adduser -u 1000 -G www -s /bin/sh -D www

# Configurar diretório de trabalho
WORKDIR /var/www

# Copiar vendor do stage anterior
COPY --from=composer --chown=www:www /app/vendor ./vendor

# Copiar arquivos da aplicação
COPY --chown=www:www . .

# Configurar permissões
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache \
    && chown -R www:www storage bootstrap/cache \
    && chmod -R 755 storage bootstrap/cache

# Finalizar autoloader
USER www
RUN composer dump-autoload --optimize --classmap-authoritative

# Voltar para root para configurações de sistema
USER root

# Configurar Nginx
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# Configurar Supervisor
COPY docker/supervisor/supervisord.conf /etc/supervisord.conf

# Script de inicialização
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Ajustar configuração do PHP-FPM
RUN echo "listen = 127.0.0.1:9000" >> /usr/local/etc/php-fpm.d/www.conf

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
