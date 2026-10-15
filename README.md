# Firewall com iptables em Docker

Trabalho parcial de Segurança da Informação
Aluna: Iasmyn Severo

A ideia é simular a rede de uma loja virtual fictícia, a MurkTech. Existem duas redes separadas: a dos funcionários (cliente) e a dos servidores (DMZ). Um container firewall fica no meio, e tudo que passa de uma rede para a outra depende dele. Por padrão ele bloqueia tudo e só libera o que é necessário.

O relatório completo, com as regras e a justificativa de cada uma, está em `RelatorioFirewallSI.pdf`.

## Como rodar

Utilizando Docker e Docker Compose, com internet na primeira vez (o cliente baixa curl, nmap e netcat ao iniciar).

    git clone https://github.com/myhticile/firewallsi.git
    cd firewallsi
    docker compose up -d --build

Espere uns 30 segundos e veja se o cliente está pronto:

    docker logs --tail 5 seginf-cliente

Quando aparecer "Cliente pronto.", já dá para testar.

## Como testar

O que deve funcionar:

    docker exec seginf-cliente curl -s http://dmz-web
    docker exec seginf-cliente ping -c 2 dmz-web

O que deve ser bloqueado:

    docker exec seginf-cliente nc -zv -w 3 dmz-db 5432
    docker exec seginf-cliente nmap -Pn -p 5432 dmz-db

O site responde, o ping funciona e o banco dá timeout (a porta aparece como filtered no nmap). Para confirmar que foi o firewall quem bloqueou, olhe a coluna pkts:

    docker exec seginf-firewall iptables -L FORWARD -n -v

Os demais testes estão na seção 4 do relatório.

## Para encerrar

    docker compose down

Se quiser apagar também os dados do banco, use `docker compose down -v`.

## Observações

- A senha do banco é só de laboratório.
- O Nginx escuta apenas na porta 80. A 443 está liberada no firewall, mas não tem HTTPS configurado.
- Web e banco ficam na mesma rede (DMZ), então a conversa entre eles não passa pelo firewall.