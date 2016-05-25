### Usage:
``` 
git clone https://gist.github.com/xenithorb/024cc04b3bac2b95d44d9d2f0f61cb88 poll_le_certs
cd poll_le_certs
sudo cp poll_le_certs.sh /usr/local/bin/
sudo cp poll_le_certs.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now poll_le_certs.service 
```