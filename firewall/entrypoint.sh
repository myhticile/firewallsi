#!/bin/sh
# roda os comandos usando o shell do linux

# se algum comando der erro, o script para
set -eu

# regra principal: bloqueia tudo que tenta entrar no firewall
iptables -P INPUT DROP

# bloqueia tudo que passa de uma rede pra outra
iptables -P FORWARD DROP

# o que sai do próprio firewall pode passar
iptables -P OUTPUT ACCEPT

# apaga as regras antigas pra começar do zero
iptables -F
iptables -t nat -F

# deixa o firewall conversar com ele mesmo
iptables -A INPUT -i lo -j ACCEPT

# aceita só as respostas de conversas que o firewall já começou
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# deixa passar as respostas de conexões que já foram liberadas
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# libera o cliente pro site (portas 80 e 443)
iptables -A FORWARD -s 172.20.0.10 -d 172.21.0.10 -p tcp -m multiport --dports 80,443 -j ACCEPT

# libera o ping do cliente pro site, só pra testar a conexão
iptables -A FORWARD -s 172.20.0.10 -d 172.21.0.10 -p icmp --icmp-type echo-request -j ACCEPT

# anota no log quando o cliente tenta o banco
iptables -A FORWARD -s 172.20.0.10 -d 172.21.0.20 -p tcp --dport 5432 -m limit --limit 5/min -j LOG --log-prefix "FW-DROP cliente->banco: "

# e bloqueia o cliente de chegar no banco
iptables -A FORWARD -s 172.20.0.10 -d 172.21.0.20 -p tcp --dport 5432 -j DROP

# o site e o banco não sabem voltar pra rede do cliente,
# então o firewall troca o endereço de origem pelo dele e a resposta volta por ele
iptables -t nat -A POSTROUTING -s 172.20.0.0/24 -d 172.21.0.0/24 -j MASQUERADE

echo "Regras do firewall carregadas."

# mostra as regras e quantos pacotes passaram em cada uma
iptables -L -n -v

# deixa o container ligado
exec sleep infinity