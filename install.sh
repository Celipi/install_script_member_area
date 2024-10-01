#!/bin/bash

# Instalar dependências
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    figlet

# Adicionar chave GPG oficial do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Adicionar repositório do Docker
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Instalar o Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Instalar o Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Exibir o texto "MEMBER AREA" em formato grande
figlet "MEMBER AREA"

# Animação de "preparando"
echo -n "Preparando"
while true; do
  for i in . .. ...; do
    echo -n "$i"
    sleep 0.5
    echo -ne "\r"
  done
done &

# Baixar o docker-compose.yml
curl -L https://raw.githubusercontent.com/Celipi/member_area/main/docker-compose.yml -o docker-compose.yml

# Finalizar a animação de "preparando"
kill %1

# Animação de "baixando"
echo -n "Baixando"
while true; do
  for i in . .. ...; do
    echo -n "$i"
    sleep 0.5
    echo -ne "\r"
  done
done &

# Criar a rede traefik_proxy (se não existir)
if ! docker network inspect traefik_proxy >/dev/null 2>&1; then
    sudo docker network create traefik_proxy
fi

# Criar o diretório letsencrypt (para os certificados SSL)
mkdir -p letsencrypt

# Finalizar a animação de "baixando"
kill %1

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

# Animação de "iniciando"
echo -n "Iniciando"
while true; do
  for i in . .. ...; do
    echo -n "$i"
    sleep 0.5
    echo -ne "\r"
  done
done &

# Iniciar a aplicação com o Docker Compose
sudo docker-compose up -d

# Finalizar a animação de "iniciando"
kill %1

echo "Instalação concluída! Acesse seu aplicativo em https://$DOMINIO"