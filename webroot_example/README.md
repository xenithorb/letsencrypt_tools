#### Usage:

Just copy this to `/etc/nginx/conf.d/` and then:

```
mkdir -p /var/www/certbot/
nginx -s reload
restorecon -Rv /var/www/certbot # optional 
certbot certonly --webroot -w /var/www/certbot -d domain [ -d more_domains ] -m email@example.com --agree-tos --text 
```

This will setup the renewal configurations up properly in `/etc/letsencrypt/renewal` so that later on you can just cron:

```
certbot renewal -n
```

By default the below config is meant to pass HTTP traffic to *http://yourdomanin.com/.well-known/acme-challenge/** to `certbot` and all other traffic will be sent off to HTTPS. This is because for all of my personal services I am using this for, I force HTTPS, you don't have to do this and can just integrate the `location{}` block into your configuration. **What's important it making sure that the *.well-known* configuration is present on the default server or present for all `server_name` virtual hosts that will be using Let's Encrypt certbot.**
