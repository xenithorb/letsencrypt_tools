# Only intended to be use by original author
git pull
sudo cp -f poll_le_certs.sh /usr/local/bin/
sudo cp -f poll_le_certs.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable poll_le_certs.service
sudo systemctl start poll_le_certs.service
