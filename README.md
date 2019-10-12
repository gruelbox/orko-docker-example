# orko-docker-example

## What is Orko?

[Orko](https://github.com/gruelbox/orko) is a self hosted web application which provides a unified dashboard to control numerous cryptocurrency exchanges, allowing you to trade and manage your portfolio, even if it is spread across multiple exchanges, all from one screen. It works seamlessly on desktop and mobile, so you can have the same trading experience wherever you go.

## What's this?

This is a set of example configuration files demonstrating how to configure a (relatively) secure Orko instance with an SSL reverse proxy (using a certificate from [LetsEncrypt](https://letsencrypt.org/)) using Docker.

Please note that running a secure, publicly visible server requires care, attention and a lot of learning. This is doubly true when (like Orko) your application has to have access to unencrypted exchange API keys. If an attacker were to gain access to those keys, they would be able to access your trading accounts.

**This is not an exhaustive guide, and no-one associated with Orko can be held in any way responsible for what may happen when you try and set up your own server. Assume this guide contains errors and triple-check everything. Only you can be responsible for your own security.**.

However, if you know what you're doing, you may find this collection of tips useful. It is heavily derived from [these fantastic instructions](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71) which come highly recommended, and the [code on which they are based](https://github.com/wmnnd/nginx-certbot).

### Prerequisites

- Your own domain and the understanding of how to configure it to point to your server. Alternative, an account with https://www.noip.com/ and a domain configured there (we'll set it up so that the domain is automatically updated).
- A suitable Linux-based host with:
  - No unnecessary services (such as `httpd` or `sambdad`)
  - A suitable update strategy to ensure security patches are installed quickly
  - `sshd` secured and locked down. There are many guides out there. [Here's one](http://acmeextension.com/secur-ssh-server/).
  - Docker and docker-compose installed.

### Steps

- SSH into your server.
- `su` to get a root prompt.
- `mkdir /opt/orko`
- `cd /opt/orko`
- `git clone https://github.com/gruelbox/orko-docker-example.git`
- Modify `data/nginx/app.conf`, replacing the two instances of `yourserverhere.example.com` with your domain.
- _If you're using no-ip dynamic DNS_, modify `data/noip/noip.conf`, replacing `yourserverhere.example.com` with your domain and `YOURUSERNAME` and `YOURPASSWORD` with your no-ip account details.
- `chmod +x no-ip-refresh.sh`
- `chmod +x init-letsencrypt.sh`
- If using no-ip, refresh the IP address using `./no-ip-refresh.sh`.
- Now test setting up your SSL certificate: `./init-letsencrypt.sh your.domain.com your@email.com 1`
- If that worked OK, you can do it for real: `./init-letsencrypt.sh your.domain.com your@email.com 0`
- `chmod +x generate-secrets.sh`
- Generate a clean set of unused credentials: `./generate-secrets.sh`
- Note down the credentials printed at the end. Some of these will not be shown again.
- Now add your secrets, replacing XXX with the relevant values and skipping any features you don't use:

```
echo -n "XXX" > "data/secret/secret-telegram-botToken"
echo -n "XXX" > "data/secret/secret-telegram-chatId"
echo -n "XXX" > "data/secret/secret-exchanges-gdax-apiKey"
echo -n "XXX" > "data/secret/secret-exchanges-gdax-secretKey"
echo -n "XXX" > "data/secret/secret-exchanges-gdax-passphrase"
echo -n "XXX" > "data/secret/secret-exchanges-binance-apiKey"
echo -n "XXX" > "data/secret/secret-exchanges-binance-secretKey"
echo -n "XXX" > "data/secret/secret-exchanges-kucoin-apiKey"
echo -n "XXX" > "data/secret/secret-exchanges-kucoin-secretKey"
echo -n "XXX" > "data/secret/secret-exchanges-kucoin-passphrase"
echo -n "XXX" > "data/secret/secret-exchanges-bitfinex-apiKey"
echo -n "XXX" > "data/secret/secret-exchanges-bitfinex-secretKey"
echo -n "XXX" > "data/secret/secret-exchanges-bitmex-apiKey"
echo -n "XXX" > "data/secret/secret-exchanges-bitmex-secretKey"
echo -n "XXX" > "data/secret/secret-exchanges-kraken-apiKey"
echo -n "XXX" > "data/secret/secret-exchanges-kraken-secretKey"
echo -n "XXX" > "data/secret/secret-exchanges-bittrex-apiKey"
echo -n "XXX" > "data/secret/secret-exchanges-bittrex-secretKey"
```

- Lock down that directory:

```
chmod -R 600 data/secret
chmod 700 data/secret
```

- Start your server: `docker-compose up -d`, or `docker-compose up -d -f docker-compose.yml -f noip.yml` if using no-ip.

### Logging and monitoring (optional, but not really)

[Datadog](https://www.datadoghq.com/) and [Papertrail](https://papertrailapp.com/) have free services which work well when combined with this setup, to give you logs and real-time monitoring.

To use them, set up accounts, then in `docker-compose.extras.yml`, replace `YOUR-DATADOG-API-KEY` and `YOUR-LOGSPOUT-ENDPOINT` with the credentials from Datadog and Papertrail respectively.

To start, use:

`docker-compose -f docker-compose.yml -f noip.yml -f logspout.yml -f datadog.yml up -d`
