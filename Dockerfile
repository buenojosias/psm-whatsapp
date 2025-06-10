# Dockerfile
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
    nginx

# Instalar extensões PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Criar usuário para aplicação
RUN addgroup -g 1000 www && \
    adduser -u 1000 -G www -s /bin/sh -D www

# Configurar diretório de trabalho
WORKDIR /var/www

# Copiar arquivos do projeto
COPY --chown=www:www . /var/www

# Instalar dependências do Composer
USER www
RUN composer install --optimize-autoloader --no-dev

# Voltar para root para configurações finais
USER root

# Configurar Nginx
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# Configurar Supervisor
COPY docker/supervisor/supervisord.conf /etc/supervisord.conf

# Configurar permissões
RUN chown -R www:www /var/www \
    && chmod -R 755 /var/www/storage \
    && chmod -R 755 /var/www/bootstrap/cache

# Script de inicialização
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
