### Usage:
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