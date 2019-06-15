# orko-docker-example

## What is Orko?
[Orko](https://github.com/gruelbox/orko) is a self hosted web application which provides a unified dashboard to control numerous cryptocurrency exchanges, allowing you to trade and manage your portfolio, even if it is spread across multiple exchanges, all from one screen. It works seamlessly on desktop and mobile, so you can have the same trading experience wherever you go.

## What's this?
This is a set of example configuration files demonstrating how to configure a (relatively) secure Orko instance with an SSL reverse proxy using Docker.

Please note that running a secure, publicly visible server requires care, attention and a lot of learning.  This is doubly true when (like Orko) your application has to have access tounencrypted exchange API keys.  If an attacker were to gain access to those keys, they would be able to access your trading accounts.

**This is not an exhaustive guide, and no-one associated with Orko can be held in any way responsible for what may happen when you try and set up your own server**.

However, if you know what you're doing, you may find this collection of tips useful. It is heavily based on [these fantastic instructions](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71).

### Prerequisites

- Your own domain and the understanding of how to configure it.
- A suitable Linux-based host with:
    - No unnecessary services (such as `httpd` or `sambdad`)
    - A suitable update strategy to ensure security patches are installed quickly
    - `sshd` secured and locked down. There are many guides out there. [Here's one](http://acmeextension.com/secur-ssh-server/).
    - Docker and docker-compose installed.

### Steps

TODO

