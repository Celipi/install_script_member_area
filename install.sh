#!/bin/bash

# Função para exibir animações
animate() {
  local message=$1
  while true; do
    for i in . .. ...; do
      echo -ne "\r$message $i"
      sleep 0.5
    done
  done
}

# Animação de "Preparando"
animate "Preparando" &
ANIMATE_PID=$!

# Instalar dependências
sudo apt-get update -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    figlet

# Finalizar a animação de "Preparando"
kill $ANIMATE_PID
echo -ne "\rPreparando concluído!        \n"

# Exibir o texto "MEMBER AREA" em formato grande
figlet "MEMBER AREA"

# Adicionar chave GPG oficial do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adicionar repositório do Docker
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar o Docker Engine
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Instalar o Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Animação de "Baixando"
animate "Baixando" &
ANIMATE_PID=$!

# Baixar o docker-compose.yml
curl -L https://raw.githubusercontent.com/Celipi/member_area/main/docker-compose.yml -o docker-compose.yml

# Finalizar a animação de "Baixando"
kill $ANIMATE_PID
echo -ne "\rBaixando concluído!         \n"

# Criar a rede traefik_proxy (se não existir)
if ! docker network inspect traefik_proxy >/dev/null 2>&1; then
    sudo docker network create traefik_proxy
fi

# Criar o diretório letsencrypt (para os certificados SSL)
mkdir -p letsencrypt

# Solicitar o domínio ao usuário
read -p "Digite o domínio que você deseja usar para o seu aplicativo (ex: meuaplicativo.com): " DOMINIO

# Substituir o domínio no docker-compose.yml
sed -i "s/seu_dominio.com/$DOMINIO/g" docker-compose.yml

# Solicitar o e-mail para o Let's Encrypt
read -p "Digite seu endereço de e-mail para o Let's Encrypt: " EMAIL

# Substituir o e-mail no docker-compose.yml
sed -i "s/--certificatesresolvers.letsencrypt.acme.email=seu_email@example.com/--certificatesresolvers.letsencrypt.acme.email=$EMAIL/g" docker-compose.yml

# Animação de "Iniciando"
animate "Iniciando" &
ANIMATE_PID=$!

# Iniciar a aplicação com o Docker Compose
sudo docker-compose up -d

# Finalizar a animação de "Iniciando"
kill $ANIMATE_PID
echo -ne "\rIniciando concluído!        \n"

echo "Instalação concluída! Acesse seu aplicativo em https://$DOMINIO"
