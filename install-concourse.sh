# Install Postgresql
sudo amazon-linux-extras install postgresql10 vim epel -y
sudo yum install -y postgresql-server
sudo /usr/bin/postgresql-setup --initdb
sudo su postgres -c "createuser ec2-user"
sudo su postgres -c "createdb --owner=ec2-user atc"
sudo service postgresql enable
sudo service postgresql start

# Install Concourse
wget https://github.com/concourse/concourse/releases/download/v6.0.0/concourse-6.0.0-linux-amd64.tgz -O concourse.tgz
sudo tar -C /usr/local -xzf concourse.tgz
rm concourse.tgz

# Generate keys
/usr/local/concourse/bin/concourse generate-key -t rsa -f /home/ec2-user/session_signing_key
/usr/local/concourse/bin/concourse generate-key -t ssh -f /home/ec2-user/tsa_host_key
/usr/local/concourse/bin/concourse generate-key -t ssh -f /home/ec2-user/worker_key
cp /home/ec2-user/worker_key /home/ec2-user/authorized_worker_keys

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
ExecStart=/usr/local/concourse/bin/concourse web

[Install]
WantedBy=multi-user.target
EOF

sudo mv concourse-web.service /etc/systemd/system/concourse-web.service
