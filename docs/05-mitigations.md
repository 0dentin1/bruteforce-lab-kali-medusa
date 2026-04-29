# 05 — Medidas de Mitigação Contra Ataques de Força Bruta

## 1. Objetivo

Este documento relaciona as vulnerabilidades exploradas no laboratório com controles defensivos aplicáveis em ambientes reais, fornecendo exemplos práticos de implementação.

---

## 2. Principais Riscos Identificados no Laboratório

| Vulnerabilidade | Serviço Afetado | Severidade |
|---|---|---|
| Senhas fracas ou previsíveis | FTP, SMB, Web | Alta |
| Ausência de rate limiting | Web (DVWA) | Alta |
| Sem bloqueio após falhas | FTP, SMB, Web | Alta |
| Enumeração anônima | SMB | Média |
| Serviço legado exposto (FTP, SMBv1) | FTP, SMB | Alta |
| Credenciais trafegando em texto claro | FTP | Alta |
| Mensagens de erro reveladoras | Web | Média |
| Ausência de monitoramento | Todos | Alta |

---

## 3. Rate Limiting

Rate limiting limita a quantidade de tentativas de autenticação permitidas em um intervalo de tempo.

Exemplo de regra:

```
Máximo de 5 tentativas de login por minuto por IP.
Após o limite, bloquear o IP por 10 minutos.
```

Exemplo de implementação com fail2ban para SSH/FTP:

```ini
[sshd]
enabled  = true
maxretry = 5
findtime = 60
bantime  = 600
```

Para aplicações web, o rate limiting pode ser implementado em nível de proxy reverso (nginx, Caddy) ou na própria aplicação (middleware).

---

## 4. Account Lockout

Bloquear a conta após um número de tentativas falhas reduz a eficácia do brute force.

Recomendações:

- Bloquear após 5 a 10 tentativas falhas
- Usar bloqueio progressivo (tempo de bloqueio aumenta a cada tentativa)
- Alertar o usuário legítimo sobre tentativas suspeitas
- Diferenciar bloqueio temporário de permanente

---

## 5. MFA (Multi-Factor Authentication)

O MFA é o controle mais eficaz contra brute force, pois mesmo que a senha seja descoberta, o atacante ainda precisa do segundo fator.

Opções recomendadas:

- TOTP (Time-based One-Time Password) via apps como Google Authenticator
- Chave de hardware (YubiKey)
- Notificação push

---

## 6. Hardening de Serviços

### FTP

- Substituir FTP por SFTP (SSH File Transfer Protocol)
- Desabilitar login anônimo
- Usar chaves SSH em vez de senha
- Restringir acesso por IP via firewall

### SMB

- Desabilitar SMBv1:

```bash
# Linux (smb.conf)
min protocol = SMB2

# Windows PowerShell
Set-SmbServerConfiguration -EnableSMB1Protocol $false
```

- Desabilitar enumeração anônima:

```ini
# smb.conf
restrict anonymous = 2
```

- Restringir portas 139 e 445 apenas a hosts necessários

### Aplicações Web

- Implementar HTTPS obrigatório
- Usar mensagens de erro genéricas (não revelar se usuário ou senha está errado)
- Implementar CAPTCHA adaptativo
- Adicionar header de segurança `X-Frame-Options`, `Content-Security-Policy`

---

## 7. Monitoramento e Detecção

Exemplos de regras de alerta para SIEM:

**Regra 1 — Brute Force por IP:**
```
Mais de 10 falhas de autenticação do mesmo IP em 5 minutos.
```

**Regra 2 — Password Spraying:**
```
Uma mesma senha testada contra 5 ou mais usuários diferentes em 10 minutos.
```

**Regra 3 — Login após falhas repetidas:**
```
Login bem-sucedido após 5 ou mais falhas consecutivas na mesma conta.
```

**Regra 4 — Enumeração de usuários:**
```
Tentativas de login contra usuários inexistentes acima de 10 por minuto.
```

**Regra 5 — Acesso fora do horário:**
```
Autenticação bem-sucedida fora do horário comercial em conta não autorizada.
```

---

## 8. Hashing Seguro de Senhas

Senhas armazenadas devem usar algoritmos de hash modernos com salt:

| Algoritmo | Recomendado | Motivo |
|---|---|---|
| bcrypt | Sim | Fator de custo ajustável |
| argon2id | Sim | Resistente a GPU/ASIC |
| scrypt | Sim | Resistente a hardware |
| MD5 | Não | Quebrado, não usar |
| SHA1 | Não | Inseguro para senhas |
| SHA256 sem salt | Não | Vulnerável a rainbow tables |

---

## 9. Priorização Recomendada

| Prioridade | Controle | Impacto |
|---|---|---|
| 1 | Implementar MFA | Crítico |
| 2 | Bloquear senhas fracas e comuns | Alto |
| 3 | Aplicar rate limiting | Alto |
| 4 | Ativar logs e alertas | Alto |
| 5 | Restringir serviços expostos | Médio |
| 6 | Desabilitar protocolos legados (FTP, SMBv1) | Alto |
| 7 | Revisar permissões e contas | Médio |
| 8 | Segmentar rede | Médio |
| 9 | Monitoramento contínuo com SIEM | Alto |
