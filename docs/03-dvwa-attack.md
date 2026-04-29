# 03 — Ataque de Força Bruta em Formulário Web com DVWA

## 1. Objetivo

Este documento descreve a simulação de um ataque de força bruta contra o formulário de login do DVWA, demonstrando como aplicações web sem proteção adequada são vulneráveis a ataques automatizados de autenticação.

> O teste foi realizado apenas em laboratório local e autorizado.

---

## 2. Escopo do Teste

| Item | Descrição |
|---|---|
| Aplicação | DVWA (Damn Vulnerable Web Application) |
| Tipo de teste | Brute force em formulário web |
| Máquina atacante | Kali Linux |
| Máquina alvo | Metasploitable 2 (DVWA hospedado) |
| Ferramentas | curl, Burp Suite |
| Rede | Host-Only / ambiente controlado |

---

## 3. Sobre o DVWA

O DVWA é uma aplicação propositalmente vulnerável, criada para estudo de segurança web. Permite configurar diferentes níveis de segurança para observar como controles defensivos afetam ataques.

Módulo utilizado neste teste:

```
http://192.168.56.101/dvwa/vulnerabilities/brute/
```

Nível de segurança configurado: **Low**

---

## 4. Análise da Requisição com Burp Suite

Antes de automatizar o ataque, a requisição de login foi interceptada via Burp Suite para identificar os parâmetros corretos.

Requisição capturada:

```
GET /dvwa/vulnerabilities/brute/?username=admin&password=test&Login=Login HTTP/1.1
Host: 192.168.56.101
Cookie: PHPSESSID=<session_id>; security=low
```

Parâmetros identificados:

| Parâmetro | Valor |
|---|---|
| `username` | Usuário a testar |
| `password` | Senha a testar |
| `Login` | Valor fixo: `Login` |
| `user_token` | Token CSRF (extraído dinamicamente) |

---

## 5. Nota sobre Proteção CSRF

O DVWA em versões mais recentes inclui um `user_token` mesmo no nível `low`. Este token muda a cada requisição e deve ser extraído dinamicamente antes de cada tentativa.

O script `03-dvwa-bruteforce.sh` realiza essa extração automaticamente:

1. Faz login no DVWA para obter uma sessão válida
2. A cada tentativa, extrai o `user_token` atual da página
3. Inclui o token na próxima requisição

Sem essa extração, as tentativas falham silenciosamente, mesmo com a senha correta.

---

## 6. Execução do Ataque

```bash
bash scripts/03-dvwa-bruteforce.sh
```

O script solicita interativamente:
- IP/host do DVWA
- Usuário a testar
- Caminho da wordlist

---

## 7. Resultado

Credencial válida identificada:

```
[+] CREDENCIAL ENCONTRADA!
    Usuário: admin
    Senha:   password
```

---

## 8. Vulnerabilidades Identificadas

- Ausência total de rate limiting no formulário de login
- Nenhum CAPTCHA ou mecanismo anti-bot
- Sem bloqueio de conta após tentativas repetidas
- Mensagem de erro diferente para usuário inválido vs senha errada (enumeração de usuários)

---

## 9. Mitigação

- Implementar rate limiting no endpoint de login (máx. 5 tentativas por minuto por IP)
- Adicionar bloqueio progressivo por usuário
- Implementar MFA
- Usar mensagens de erro genéricas que não distinguem usuário de senha
- Monitorar e alertar sobre tentativas múltiplas de autenticação
- CAPTCHA adaptativo ao detectar comportamento automatizado
