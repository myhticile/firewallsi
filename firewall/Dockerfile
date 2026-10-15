# começa de um linux bem leve
FROM alpine:3.20

# instala o iptables (o firewall) e as ferramentas de rede
RUN apk add --no-cache iptables iproute2

# copia o arquivo com as regras pra dentro do container
COPY entrypoint.sh /entrypoint.sh

# tira os enters do windows e deixa o arquivo executável
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

# quando o container ligar, roda esse arquivo
ENTRYPOINT ["/entrypoint.sh"]