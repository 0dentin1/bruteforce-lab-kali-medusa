#!/bin/bash

# ==========================================================
# 01 — Setup e Descoberta do Ambiente
# Projeto: Brute Force Lab com Kali Linux e Medusa
# Uso autorizado apenas em laboratório local/controlado.
# ==========================================================

clear

echo "=================================================="
echo " 01 — Setup e Descoberta do Ambiente"
echo "=================================================="
echo

echo "[+] Este script auxilia na identificação da rede e descoberta do alvo."
echo "[!] Use apenas em ambiente próprio, isolado e autorizado."
echo

echo "=================================================="
echo "[1] Interfaces de rede disponíveis"
echo "=================================================="
ip a
echo

echo "=================================================="
echo "[2] Tabela de rotas"
echo "=================================================="
ip route
echo

echo "=================================================="
echo "[3] Verificação de ferramentas"
echo "=================================================="

if command -v netdiscover >/dev/null 2>&1; then
    echo "[+] netdiscover encontrado."
else
    echo "[-] netdiscover não encontrado."
    echo "    Instale com: sudo apt install netdiscover -y"
fi

if command -v nmap >/dev/null 2>&1; then
    echo "[+] nmap encontrado."
else
    echo "[-] nmap não encontrado."
    echo "    Instale com: sudo apt install nmap -y"
fi

echo

read -p "Informe a faixa da rede Host-Only. Exemplo: 192.168.56.0/24: " NETWORK_RANGE

if [ -z "$NETWORK_RANGE" ]; then
    echo "[-] Nenhuma faixa de rede informada. Encerrando."
    exit 1
fi

echo
echo "=================================================="
echo "[4] Descoberta de hosts com netdiscover"
echo "=================================================="
echo "[+] Faixa informada: $NETWORK_RANGE"
echo "[!] Pressione CTRL+C quando identificar o IP da máquina alvo."
echo

sudo netdiscover -r "$NETWORK_RANGE"

echo
read -p "Informe o IP do alvo identificado. Exemplo: 192.168.56.101: " TARGET

if [ -z "$TARGET" ]; then
    echo "[-] Nenhum IP informado. Encerrando."
    exit 1
fi

echo
echo "=================================================="
echo "[5] Teste de conectividade"
echo "=================================================="
ping -c 4 "$TARGET"

echo
echo "=================================================="
echo "[6] Enumeração inicial com Nmap"
echo "=================================================="
nmap -sV "$TARGET"

echo
echo "=================================================="
echo " Descoberta finalizada"
echo "=================================================="
echo "[+] IP do alvo analisado: $TARGET"
echo "[+] Use esse IP nos próximos scripts."
echo
