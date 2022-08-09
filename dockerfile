FROM ngoduykhanh/powerdns-admin
USER root
RUN apk --update --no-cache add pdns pdns-backend-sqlite3 curl dnsdist
ADD https://raw.githubusercontent.com/dddmaster/powerdns-sqlite-powerdns-admin-docker/main/entrypoint.sh /
ADD https://raw.githubusercontent.com/dddmaster/powerdns-sqlite-powerdns-admin-docker/main/dnsdist.conf /
ADD https://raw.githubusercontent.com/Arrrray/pdns-alpine/master/schema.sql /
ADD https://raw.githubusercontent.com/Arrrray/pdns-alpine/master/pdns.conf /etc/pdns
RUN # sed -E "s/(local-port=)(.*)/\154/" pdns.conf
RUN mkdir /pdns && mkdir -p /var/empty/var/run/ && chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]