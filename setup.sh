#!/bin/bash
if [ -z "$EXTERNAL_IP" ]; then
    EXTERNAL_IP=$(curl -s https://api.ipify.org)
fi
read -a input -p "Enter external ip [$EXTERNAL_IP]: "
EXTERNAL_IP=${input:-$EXTERNAL_IP}
echo "Your ip is $EXTERNAL_IP"
PORT="443"
read -a input -p "Enter server port [$PORT]: "
PORT=${input:-$PORT}

SCRIPT_DIR="$(cd $(dirname $0) && pwd)"
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

until docker run -v /root/ovpn-data:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_genconfig -u "tcp://$EXTERNAL_IP:$PORT"
do
  echo "Try again"
done
until docker run -v /root/ovpn-data:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn ovpn_initpki
do
  echo "Try again"
done

docker run --name openvpn --restart always -v /root/ovpn-data:/etc/openvpn -d -p 443:1194 --cap-add=NET_ADMIN kylemanna/openvpn