### Intent:

The primary intent with this was for backend servers that I wanted to have the same certs as the frontend proxy. 
My idea was to simply export `/etc/letsencrypt` over NFSv4, and then consume those files on both the proxy and backends. (all in this case NGINX). The resultant problem is that, while the front-end proxy can action based on the renewal event, there's no immediate way to action on that event for the backend servers unless I leave SSH keys around or some other event server going. All of which requires access or some kind of key (ssh key, say). Since I'm already exporting the files over NFS, why not just poll the files every once in a while to see if the mtime changed?

Assumptions:

1. The files you want to poll are exported from some other server and mounted on the computer running this script as an NFS filesystem. (a part of the script checks for this)

2. Certbot (letsencrypt) will renew the certs if they expire in **< 30 days**. Thus, polling on a long frequency (5 minutes in this case) is even excessive at that rate. You could probably increase it to several days with no ill effects. Less than 5 minute resolution is probably not warranted here.

3. The above assumption is dependent on the fact that you have the "cert getter" actuall run `certbot renew` or some other similar command to actually renew the certs in a reasonable interval. There's no need to wait for exactly 30 days, for example.

Utility:

1. TODO: Write and line SERVICES with CERTFILES - mostly like with associative arrays, and deduplicate the services so we only restart them once... As of right now it's written to fork and poll multiple certs, but will restart the same set of services. It may be the case that all certs are being used for the same services, but it also may not be the case, perhaps only NGINX is using the second cert, for example. 

#### Usage:
``` 
git clone https://gist.github.com/xenithorb/024cc04b3bac2b95d44d9d2f0f61cb88 poll_le_certs
cd poll_le_certs
sudo cp poll_le_certs.sh /usr/local/bin/
sudo cp poll_le_certs.service /etc/systemd/system/
``` 

Change some stuff here, (i.e. `vi /usr/local/bin/poll_le_certs.sh`) like the services named under `SERVICES=` and the certfile paths under the `CERTFILES=()` array, or the `POLL_INTERVAL` if you want a certain resolution. Then continue with the following commands to enable it as a service.

```
sudo systemctl daemon-reload
sudo systemctl enable --now poll_le_certs.service 
```