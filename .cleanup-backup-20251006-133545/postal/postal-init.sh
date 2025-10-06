#!/bin/bash
# Generate postal.yml from environment variables

cat > /config/postal.yml << EOF
main_db:
  host: postal-mariadb
  username: root
  password: "${POSTAL_DB_ROOT_PASSWORD}"
  database: postal

message_db:
  host: postal-mariadb
  username: root
  password: "${POSTAL_DB_ROOT_PASSWORD}"

rabbitmq:
  host: postal-rabbitmq
  username: postal
  password: "${POSTAL_RABBITMQ_PASSWORD}"
  vhost: /postal
EOF

# Start the original command
exec "$@"
