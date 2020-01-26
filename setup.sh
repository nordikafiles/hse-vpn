#!/bin/bash
if [ -z "$EXTERNAL_IP" ]; then
    curl 'https://api.ipify.org' > external_ip.txt
else
    echo $EXTERNAL_IP > external_ip.txt
fi
echo "Your ip is $(<external_ip.txt)"
SCRIPT_DIR="$(cd $(dirname $0) && pwd)"
echo "Script dir: $SCRIPT_DIR"
echo "Installing docker..."
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
ln -s "$SCRIPT_DIR/restart.sh" /usr/bin/restart_openvpn
ln -s "$SCRIPT_DIR/start.sh" /usr/bin/start_openvpn
ln -s "$SCRIPT_DIR/stop.sh" /usr/bin/stop_openvpn
ln -s "$SCRIPT_DIR/create_openvpn_user.sh" /usr/bin/create_openvpn_user

docker run -v /root/ovpn-data:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_genconfig -u "tcp://$(<external_ip.txt):443"
docker run -v /root/ovpn-data:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn ovpn_initpki

docker run --name openvpn --restart always -v /root/ovpn-data:/etc/openvpn -d -p 443:1194 --cap-add=NET_ADMIN kylemanna/openvpn