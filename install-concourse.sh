# Install Postgresql
sudo amazon-linux-extras install postgresql10 vim epel -y
sudo yum install -y postgresql-server
sudo /usr/bin/postgresql-setup --initdb
sudo systemctl enable postgresql
sudo service postgresql start
sudo su postgres -c "createuser ec2-user"
sudo su postgres -c "createdb --owner=ec2-user atc"

# Install Concourse
wget https://github.com/concourse/concourse/releases/download/v6.0.0/concourse-6.0.0-linux-amd64.tgz -O concourse.tgz
sudo tar -C /usr/local -xzf concourse.tgz
rm concourse.tgz

# Generate keys
/usr/local/concourse/bin/concourse generate-key -t rsa -f /home/ec2-user/session_signing_key
/usr/local/concourse/bin/concourse generate-key -t ssh -f /home/ec2-user/tsa_host_key
/usr/local/concourse/bin/concourse generate-key -t ssh -f /home/ec2-user/worker_key
cp /home/ec2-user/worker_key.pub /home/ec2-user/authorized_worker_keys

# Create web service unit
sudo cat <<EOF > concourse-web.service 
[Unit]
Description=Concourse Web Agent
After=postgresql.service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=ec2-user
ExecStart=/usr/local/concourse/bin/concourse web --add-local-user jamie:norbit --main-team-local-user jamie --session-signing-key /home/ec2-user/session_signing_key --tsa-host-key /home/ec2-user/tsa_host_key --tsa-authorized-keys /home/ec2-user/authorized_worker_keys --postgres-user ec2-user --postgres-socket /var/run/postgresql --external-url=http://ci.jamiekelly.com:8080

[Install]
WantedBy=multi-user.target
EOF

# Create worker service unit
sudo cat <<EOF > concourse-worker.service 
[Unit]
Description=Concourse Worker Agent
After=cooncourse-web.service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=ec2-user
ExecStart=sudo -E /usr/local/concourse/bin/concourse worker --work-dir /opt/concourse/worker --tsa-host 127.0.0.1:2222 --tsa-public-key /home/ec2-user/tsa_host_key.pub --tsa-worker-private-key /home/ec2-user/worker_key

[Install]
WantedBy=multi-user.target
EOF

sudo mv concourse-web.service /etc/systemd/system/concourse-web.service
sudo mv concourse-worker.service /etc/systemd/system/concourse-worker.service

sudo systemctl enable concourse-web
sudo systemctl enable concourse-worker
