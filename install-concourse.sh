# Get the concourse tarball
wget https://github.com/concourse/concourse/releases/download/v6.0.0/concourse-6.0.0-linux-amd64.tgz -O concourse.tgz

# Untar
tar -C /usr/local -xzf concourse.tgz

# Remove tarball
rm concourse.tgz

concourse
