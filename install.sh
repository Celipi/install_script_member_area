#!/bin/bash

# Instalar dependências
yes | sudo apt-get update > /dev/null 2>&1
yes | sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    figlet > /dev/null 2>&1

# Exibir o texto "MEMBER AREA" em formato grande
figlet "MEMBRIUMWL"

# Função para exibir animações
animate() {
  local message=$1
  printf "$message"
  while true; do
    for i in . .. ...; do
      printf " %s \r" "$i"
      sleep 0.5
    done
  done
}

# Animação de "preparando"
animate "Preparando" &

# Finalizar a animação de "preparando"
sleep 1
kill %1


# Adicionar chave GPG oficial do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null 2>&1

# Adicionar repositório do Docker
yes | sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" > /dev/null 2>&1

# Instalar o Docker Engine
yes | sudo apt-get update > /dev/null 2>&1
yes | sudo apt-get install -y docker-ce docker-ce-cli containerd.io > /dev/null 2>&1

# Instalar o Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null 2>&1
sudo chmod +x /usr/local/bin/docker-compose > /dev/null 2>&1

# Animação de "baixando"
animate "Baixando" &

# Baixar o docker-compose.yml
curl -L https://raw.githubusercontent.com/Celipi/member_area/main/docker-compose.yml -o docker-compose.yml > /dev/null 2>&1

# Finalizar a animação de "baixando"
sleep 1
kill %1

# Criar a rede traefik_proxy (se não existir)
if ! docker network inspect traefik_proxy >/dev/null 2>&1; then
    sudo docker network create traefik_proxy > /dev/null 2>&1
fi

# Criar o diretório letsencrypt (para os certificados SSL)
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

# Animação de "iniciando"
animate "Iniciando" &

# Iniciar a aplicação com o Docker Compose
sudo docker-compose up -d > /dev/null 2>&1

# Finalizar a animação de "iniciando"
sleep 1
kill %1

echo "Instalação concluída! Acesse seu aplicativo em https://$DOMINIO"