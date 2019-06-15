#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mkdir data/secret

function genRandom() {
    trfilter='A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~'
    head /dev/urandom | tr -dc "$trfilter" | head -c $1
}

genRandom 80 > "$DIR/data/secret/secret-script-signing-key"
genRandom 80 > "$DIR/data/secret/secret-jwt-signing-key"
gen_username=`genRandom 30`
gen_password=`genRandom 30`
gen_salt=`docker run gruelbox/orko:stable salt`
totp_whitelist=`docker run gruelbox/orko:stable otp --nocheck`
totp_login=`docker run gruelbox/orko:stable otp --nocheck`

echo -n "$gen_username" > "$DIR/data/secret/secret-jwt-username"
echo -n "$gen_salt" > "$DIR/data/secret/secret-jwt-salt"
echo -n "$totp_whitelist" > "$DIR/data/secret/secret-whitelist-totp"
echo -n "$totp_login" > "$DIR/data/secret/secret-jwt-totp"

echo -n `docker run gruelbox/orko:stable hash --salt "$gen_salt" "$gen_password"` > "$DIR/data/secret/secret-jwt-password"

echo "Credentials generated"
echo "############## CREDENTIALS - NOTE THIS DOWN NOW ###################"
echo "Whitelisting TOTP: $totp_whitelist"
echo "Username: $gen_username"
echo "Password: $gen_password"
echo "Login TOTP: $totp_login"
echo "###################################################################"