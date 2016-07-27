# Only intended to be use by original author
set -x
git pull
sudo cp -f poll_le_certs.sh /usr/local/bin/
sudo cp -f poll_le_certs.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable poll_le_certs.service
sudo systemctl restart poll_le_certs.service
