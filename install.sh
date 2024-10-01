#!/bin/bash

# 1. Instalar dependências
echo "Instalando dependências..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# 2. Adicionar chave GPG oficial do Docker
echo "Adicionando chave GPG do Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# 3. Adicionar repositório do Docker
echo "Adicionando repositório do Docker..."
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# 4. Instalar o Docker Engine
echo "Instalando o Docker Engine..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# 5. Instalar o Docker Compose
echo "Instalando o Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Baixar o docker-compose.yml
echo "Baixando o docker-compose.yml..."
curl -L https://raw.githubusercontent.com/Celipi/member_area/main/docker-compose.yml -o docker-compose.yml

# Criar a rede traefik_proxy (se não existir)
echo "Verificando se a rede traefik_proxy existe..."
if ! docker network inspect traefik_proxy >/dev/null 2>&1; then
    echo "Criando a rede traefik_proxy..."
    sudo docker network create traefik_proxy
else
    echo "A rede traefik_proxy já existe."
fi

# Criar o diretório letsencrypt (para os certificados SSL)
echo "Criando diretório para certificados..."
mkdir -p letsencrypt

# Solicitar o domínio ao usuário
echo "Digite o domínio que você deseja usar para o seu aplicativo (ex: meuaplicativo.com):"
read DOMINIO

# Substituir o domínio no docker-compose.yml
sed -i "s/seu_dominio.com/$DOMINIO/g" docker-compose.yml

# Solicitar o e-mail para o Let's Encrypt
echo "Digite seu endereço de e-mail para o Let's Encrypt:"
read EMAIL

# Substituir o e-mail no docker-compose.yml
sed -i "s/--certificatesresolvers.letsencrypt.acme.email=seu_email@example.com/--certificatesresolvers.letsencrypt.acme.email=$EMAIL/g" docker-compose.yml

# Iniciar a aplicação com o Docker Compose
echo "Iniciando a aplicação..."
sudo docker-compose up -d

echo "Instalação concluída! Acesse seu aplicativo em https://$DOMINIO"