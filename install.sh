#!/bin/bash

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

# Instalação inicial das dependências básicas, incluindo figlet
animate_dots "Preparando" 10 &
run_silently sudo apt-get update
run_silently sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common figlet
wait

# Agora que figlet está instalado, exibir o texto "MEMBER AREA" em formato grande
clear  # Limpa a tela antes de exibir o texto grande
figlet "MEMBER AREA"

# Continuar com a instalação do Docker e outras dependências
animate_dots "Instalando Docker" 15 &
run_silently curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
run_silently sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
run_silently sudo apt-get update
run_silently sudo apt-get install -y docker-ce docker-ce-cli containerd.io
run_silently sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
run_silently sudo chmod +x /usr/local/bin/docker-compose
wait

# Download do docker-compose.yml
animate_dots "Baixando" 5 &
run_silently curl -L https://raw.githubusercontent.com/Celipi/member_area/main/docker-compose.yml -o docker-compose.yml

# Criar a rede traefik_proxy (se não existir)
if ! docker network inspect traefik_proxy >/dev/null 2>&1; then
    run_silently sudo docker network create traefik_proxy
fi

# Criar o diretório letsencrypt (para os certificados SSL)
mkdir -p letsencrypt 2>/dev/null
wait

# Solicitar o domínio ao usuário
read -p "Digite o domínio que você deseja usar para o seu aplicativo (ex: meuaplicativo.com): " DOMINIO

# Substituir o domínio no docker-compose.yml
sed -i "s/seu_dominio.com/$DOMINIO/g" docker-compose.yml 2>/dev/null

# Solicitar o e-mail para o Let's Encrypt
read -p "Digite seu endereço de e-mail para o Let's Encrypt: " EMAIL

# Substituir o e-mail no docker-compose.yml
sed -i "s/--certificatesresolvers.letsencrypt.acme.email=seu_email@example.com/--certificatesresolvers.letsencrypt.acme.email=$EMAIL/g" docker-compose.yml 2>/dev/null

# Iniciar a aplicação com o Docker Compose
animate_dots "Iniciando" 15 &
run_silently sudo docker-compose up -d
wait

echo -e "\nInstalação concluída! Acesse seu aplicativo em https://$DOMINIO"