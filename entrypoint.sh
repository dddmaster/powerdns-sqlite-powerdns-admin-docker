#!/usr/bin/env sh

if [[ -z "${API_KEY}" ]]; then
  API_KEY=$($RANDOM | md5sum | head -c 20; echo;)
fi

if [[ -z "${LOG_LEVEL}" ]]; then
  LOG_LEVEL=0
fi

# Import DB Schema Structure
if [[ ! -f /pdns/pdns_db.sqlite ]]; then
	echo "<< Creating database schema.. >>"
	sqlite3 /pdns/pdns_db.sqlite < /schema.sql
	chmod 777 -R /pdns/
  cd /app
  flask db upgrade
	sqlite3 /data/powerdns-admin.db "INSERT INTO setting (name,value) VALUES('pdns_api_url','http://127.0.0.1:8081');"
	sqlite3 /data/powerdns-admin.db "INSERT INTO setting (name,value) VALUES('pdns_api_key','$API_KEY');"
	sqlite3 /data/powerdns-admin.db "INSERT INTO setting (name,value) VALUES('pdns_version','4.1.1');"
	echo "<< Done >>"
else
	echo "<< Database Ready! >>"
fi

# RUN Service
pdns_server \
	--loglevel=$LOG_LEVEL \
	--webserver-allow-from="127.0.0.1" \
	--api-key=$API_KEY &



cd /app
gunicorn -t 120 --workers 4 --bind 0.0.0.0:80 "powerdnsadmin:create_app()" &

dnsdist
