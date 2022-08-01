#!/usr/bin/env sh

# Import DB Schema Structure
if [[ ! -f /pdns/pdns_db.sqlite ]]; then
	echo "<< Creating database schema.. >>"
	sqlite3 /pdns/pdns_db.sqlite < /schema.sql
	chmod 777 -R /pdns/
	echo "<< Done >>"
else
	echo "<< Database Ready! >>"
fi

SQLALCHEMY_DATABASE_URI=sqlite:////pdns/pdns_db.sqlite


# RUN Service
pdns_server \
	--loglevel=10 \
	--webserver-allow-from="127.0.0.1" \
	--api-key=$API_KEY &

cd /app
flask db upgrade
gunicorn -t 120 --workers 4 --bind 0.0.0.0:80 --log-level info "powerdnsadmin:create_app()"