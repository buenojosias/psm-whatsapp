#!/bin/bash
set -e

echo "🚀 Iniciando aplicação Laravel WhatsApp..."

# Aguardar banco de dados
echo "⏳ Aguardando banco de dados..."
timeout=60
while ! nc -z db 3306; do
    timeout=$((timeout - 1))
    if [ $timeout -eq 0 ]; then
        echo "❌ Timeout aguardando banco de dados"
        exit 1
    fi
    sleep 1
done

echo "✅ Banco de dados disponível!"

# Aguardar Redis
echo "⏳ Aguardando Redis..."
timeout=30
while ! nc -z redis 6379; do
    timeout=$((timeout - 1))
    if [ $timeout -eq 0 ]; then
        echo "❌ Timeout aguardando Redis"
        exit 1
    fi
    sleep 1
done

echo "✅ Redis disponível!"

# Aguardar mais um pouco para garantir estabilidade
sleep 5

# Verificar se APP_KEY existe
if [ -z "$APP_KEY" ]; then
    echo "❌ APP_KEY não configurada!"
    exit 1
fi

# Executar migrações
echo "🔄 Executando migrações..."
php artisan migrate --force || {
    echo "⚠️ Falha na primeira tentativa de migração, tentando novamente..."
    sleep 10
    php artisan migrate --force
}

# Executar seeders (se existirem)
if [ -f "database/seeders/DatabaseSeeder.php" ]; then
    echo "🌱 Executando seeders..."
    php artisan db:seed --force || echo "⚠️ Seeders falharam ou não existem"
fi

# Limpar e otimizar cache
echo "🧹 Otimizando cache..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

php artisan config:cache
php artisan route:cache
php artisan view:cache

# Criar link simbólico para storage
echo "🔗 Configurando storage..."
php artisan storage:link || echo "⚠️ Storage link já existe"

# Configurar permissões finais
echo "🔐 Configurando permissões..."
chown -R www:www /var/www/storage /var/www/bootstrap/cache
chmod -R 755 /var/www/storage /var/www/bootstrap/cache

echo "✅ Aplicação Laravel WhatsApp pronta!"
echo "🌐 Servidor rodando na porta 80"

# Iniciar supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf
