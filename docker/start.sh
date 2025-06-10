#!/bin/sh

# Aguardar banco de dados estar disponível
echo "Aguardando banco de dados..."
while ! nc -z db 3306; do
  sleep 1
done

echo "Banco de dados disponível!"

# Executar migrações
php artisan migrate --force

# Limpar e otimizar cache
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Criar link simbólico para storage
php artisan storage:link

# Iniciar supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf
