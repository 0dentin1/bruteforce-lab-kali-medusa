#!/bin/bash

# ==========================================================
# 05 — Checklist de Mitigação e Hardening
# Projeto: Brute Force Lab com Kali Linux e Medusa
# Este script não altera o sistema. Apenas exibe recomendações.
# ==========================================================

clear

echo "=================================================="
echo " 05 — Checklist de Mitigação"
echo "=================================================="
echo

echo "[+] Este script apresenta uma checklist defensiva baseada nos testes do laboratório."
echo "[+] Nenhuma alteração será feita no sistema."
echo

echo "=================================================="
echo "[1] Controles gerais contra brute force"
echo "=================================================="
echo "- Implementar MFA sempre que possível."
echo "- Aplicar rate limiting por IP e por usuário."
echo "- Aplicar bloqueio progressivo após falhas."
echo "- Bloquear senhas comuns e previsíveis."
echo "- Monitorar login bem-sucedido após múltiplas falhas."
echo "- Restringir exposição de serviços sensíveis."
echo

echo "=================================================="
echo "[2] Mitigação para FTP"
echo "=================================================="
echo "- Evitar FTP simples."
echo "- Preferir SFTP ou FTPS."
echo "- Desabilitar login anônimo."
echo "- Restringir acesso por firewall."
echo "- Remover contas padrão ou desnecessárias."
echo "- Monitorar falhas repetidas de autenticação."
echo "- Bloquear senhas fracas."
echo

echo "=================================================="
echo "[3] Mitigação para aplicações web"
echo "=================================================="
echo "- Implementar rate limiting no endpoint de login."
echo "- Aplicar bloqueio progressivo por usuário."
echo "- Usar MFA."
echo "- Utilizar CAPTCHA adaptativo quando houver comportamento suspeito."
echo "- Usar mensagens de erro genéricas."
echo "- Detectar credential stuffing."
echo "- Registrar IP, user-agent, horário e resultado da tentativa."
echo

echo "=================================================="
echo "[4] Mitigação para SMB"
echo "=================================================="
echo "- Desabilitar SMBv1."
echo "- Bloquear enumeração anônima."
echo "- Restringir portas 139 e 445."
echo "- Permitir SMB apenas entre hosts necessários."
echo "- Auditar compartilhamentos."
echo "- Revisar permissões periodicamente."
echo "- Aplicar princípio do menor privilégio."
echo

echo "=================================================="
echo "[5] Monitoramento e detecção"
echo "=================================================="
echo "- Alertar múltiplas falhas do mesmo IP."
echo "- Alertar múltiplas falhas contra o mesmo usuário."
echo "- Alertar uma senha testada contra vários usuários."
echo "- Alertar login bem-sucedido após várias falhas."
echo "- Monitorar autenticações fora do horário normal."
echo "- Monitorar acesso de contas inativas."
echo

echo "=================================================="
echo "[6] Exemplos de regras de alerta"
echo "=================================================="
echo "Regra 1:"
echo "Mais de 10 falhas de login do mesmo IP em 5 minutos."
echo
echo "Regra 2:"
echo "Uma mesma senha testada contra vários usuários em curto período."
echo
echo "Regra 3:"
echo "Login bem-sucedido após 5 ou mais falhas consecutivas."
echo
echo "Regra 4:"
echo "Tentativas de login contra usuários inexistentes."
echo

echo "=================================================="
echo "[7] Priorização recomendada"
echo "=================================================="
echo "1. Implementar MFA."
echo "2. Bloquear senhas comuns."
echo "3. Aplicar rate limiting."
echo "4. Ativar logs e alertas."
echo "5. Restringir serviços expostos."
echo "6. Desabilitar protocolos legados."
echo "7. Revisar permissões."
echo "8. Segmentar rede."
echo "9. Monitorar continuamente."
echo

echo "=================================================="
echo " Checklist finalizada"
echo "=================================================="
