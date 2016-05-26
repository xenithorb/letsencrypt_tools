#### Usage:

Just copy this to `/etc/nginx/conf.d/` and then:

```
mkdir -p /var/www/certbot/
restorecon -Rv /var/www/certbot # optional 
certbot certonly --webroot -w /var/www/certbot -d domain [ -d more_domains ] -m email@example.com --agree-tos --text 
```

This will setup the renewal configurations up properly in `/etc/letsencrypt/renewal` so that later on you can just cron:

```
certbot renewal -n
```