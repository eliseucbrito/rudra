#!/usr/bin/env bash

# Impede a execução do script como root diretamente
if [[ $EUID -eq 0 ]]; then
   echo "Este script não deve ser executado como root. Use um usuário normal."
   exit 1
fi

# A forma mais confiável de obter o usuário e seu home no contexto do script.
# $USER é o usuário logado que executa o script.
# $HOME é o diretório home desse usuário.
CURRENT_USER="$USER"
USER_HOME="$HOME"
RUDRA_DIR="$USER_HOME/rudra"
HARDWARE_CONFIG_DIR="$RUDRA_DIR/hosts/default"
HARDWARE_CONFIG_FILE="$HARDWARE_CONFIG_DIR/hardware-configuration.nix"
SYSTEM_HARDWARE_CONFIG="/etc/nixos/hardware-configuration.nix"

echo "Configurando para o usuário: $CURRENT_USER"
echo "Diretório do projeto: $RUDRA_DIR"

# Garante que o diretório de destino exista
# Não precisa de sudo, pois está dentro do diretório home do usuário
mkdir -p "$HARDWARE_CONFIG_DIR" || { echo "Falha ao criar o diretório $HARDWARE_CONFIG_DIR"; exit 1; }

# Lógica principal para o hardware-configuration.nix
if [ -f "$HARDWARE_CONFIG_FILE" ]; then
    echo "O arquivo 'hardware-configuration.nix' já existe. Nenhuma ação necessária."
else
    echo "O arquivo 'hardware-configuration.nix' não foi encontrado."
    if [ -f "$SYSTEM_HARDWARE_CONFIG" ]; then
        echo "Copiando a configuração de hardware existente de $SYSTEM_HARDWARE_CONFIG..."
        # Usamos sudo aqui para ler o arquivo do sistema
        sudo cp "$SYSTEM_HARDWARE_CONFIG" "$HARDWARE_CONFIG_FILE" || { echo "Falha ao copiar a configuração de hardware."; exit 1; }
    else
        echo "Nenhuma configuração de hardware existente encontrada. Gerando uma nova..."
        # Usamos sudo aqui para gerar a configuração
        sudo nixos-generate-config --show-hardware-config > "$HARDWARE_CONFIG_FILE" || { echo "Falha ao gerar a nova configuração de hardware."; exit 1; }
        echo "Nova configuração de hardware gerada com sucesso."
    fi
    
    # Ajusta as permissões para o usuário que executou o script, já que o arquivo foi criado via sudo
    echo "Ajustando permissões do arquivo de configuração..."
    sudo chown "$CURRENT_USER:$CURRENT_USER" "$HARDWARE_CONFIG_FILE"
fi

# Navega para o diretório do flake
cd "$RUDRA_DIR" || { echo "Falha ao entrar no diretório $RUDRA_DIR"; exit 1; }

# Rebuild da configuração do NixOS
echo "Iniciando o rebuild da configuração do NixOS..."
# sudo é necessário para o rebuild
sudo nixos-rebuild switch --flake .#default || { echo "Falha ao fazer o rebuild da configuração do NixOS."; exit 1; }

echo "Script concluído com sucesso."