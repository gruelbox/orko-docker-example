#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

domains=($1)
rsa_key_size=4096
data_path="$DIR/data/certbot"
email="$2" # Adding a valid address is strongly recommended
staging=$3 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Starting temporary nginx ..."
set +e
docker stop nginx-temp-setup
set -e
docker run -d --rm \
  --name nginx-temp-setup \
  -v "$DIR/data/nginx-setup:/etc/nginx/conf.d" \
  -v "$data_path/www:/var/www/certbot" \
  -p 80:80 \
  nginx:stable-alpine

echo "### Waiting to ensure we've updated the IP and the webserver is ready ..."
sleep 30s
  
echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker run --rm \
  --name certbot-temp-setup \
  -v "$data_path/conf:/etc/letsencrypt" \
  -v "$data_path/www:/var/www/certbot" \
  certbot/certbot \
  certonly --webroot -w /var/www/certbot \
    --non-interactive \
    $staging_arg \
    $email_arg \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal \
    $domain_args

echo "### Shutting down temporary nginx ..."
docker stop nginx-temp-setup
