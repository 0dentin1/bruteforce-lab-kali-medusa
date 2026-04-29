# 01 — Configuração do Ambiente de Laboratório

## 1. Objetivo

Este documento descreve a configuração do ambiente utilizado para simular ataques de força bruta em serviços vulneráveis, utilizando Kali Linux como máquina atacante e Metasploitable 2/DVWA como alvos.

O objetivo é criar um laboratório isolado, seguro e controlado para praticar segurança ofensiva e defensiva sem impactar redes reais.

---

## 2. Escopo

Este laboratório contempla:

- Configuração de máquinas virtuais no VirtualBox
- Criação de rede isolada (Host-Only)
- Descoberta de hosts na rede
- Validação de conectividade
- Enumeração inicial de serviços
- Preparação para testes com FTP, DVWA e SMB

---

## 3. Ambiente Utilizado

| Componente | Função |
|---|---|
| Kali Linux | Máquina atacante |
| Metasploitable 2 | Máquina vulnerável |
| DVWA | Aplicação web vulnerável (hospedada no Metasploitable 2) |
| VirtualBox | Plataforma de virtualização |
| Rede Host-Only | Rede isolada entre as VMs |
| Nmap | Enumeração de serviços |
| Netdiscover | Descoberta de hosts na rede |

---

## 4. Justificativa da Rede Host-Only

A rede Host-Only foi utilizada porque permite a comunicação entre as VMs sem expor o laboratório à internet ou à rede local.

Essa configuração:

- Mantém o tráfego dentro do ambiente virtual
- Reduz o risco de interação acidental com dispositivos reais
- Permite controle total sobre os IPs utilizados
- Simula uma rede interna para testes de segurança
- Garante que os ataques simulados não saiam do laboratório

---

## 5. Configuração das Máquinas Virtuais

### 5.1 Kali Linux (atacante)

Ferramentas utilizadas:

- Medusa
- Nmap
- Netdiscover
- enum4linux-ng
- smbclient
- curl
- Burp Suite

### 5.2 Metasploitable 2 (alvo)

Máquina propositalmente vulnerável com serviços inseguros:

- FTP (porta 21) — vsftpd 2.3.4
- SMB (portas 139/445) — Samba 3.0.20
- HTTP (porta 80) — DVWA, Mutillidae
- SSH (porta 22)
- Usuários com credenciais fracas ou padrão

### 5.3 DVWA

Aplicação web vulnerável hospedada no Metasploitable 2. Permite configurar níveis de segurança para observar como controles defensivos afetam ataques automatizados.

---

## 6. Configuração de Rede no VirtualBox

1. Abrir o VirtualBox
2. Selecionar a VM → Configurações → Rede
3. Adaptador 1: selecionar **Host-Only Adapter**
4. Repetir para ambas as VMs

Verificar que as duas VMs estão no mesmo segmento:

```bash
# No Kali Linux
ip a

# Identificar o IP do Metasploitable 2
sudo netdiscover -r 192.168.56.0/24
```

---

## 7. Verificação de Conectividade

```bash
ping -c 4 192.168.56.101
```

---

## 8. Enumeração Inicial de Serviços

```bash
nmap -sV -p 21,22,80,139,445 192.168.56.101
```

Resultado esperado:

```
21/tcp  open  ftp         vsftpd 2.3.4
22/tcp  open  ssh         OpenSSH 4.7p1
80/tcp  open  http        Apache httpd 2.2.8
139/tcp open  netbios-ssn Samba smbd 3.X
445/tcp open  netbios-ssn Samba smbd 3.0.20
```

---

## 9. Próximos Passos

Com o ambiente configurado e os serviços identificados, os próximos documentos detalham os ataques executados contra cada serviço:

- [02 — Ataque FTP com Medusa](02-ftp-attack.md)
- [03 — Brute Force Web com DVWA](03-dvwa-attack.md)
- [04 — SMB e Password Spraying](04-smb-attack.md)
