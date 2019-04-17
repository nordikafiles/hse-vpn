curl 'https://api.ipify.org' > external_ip.txt
echo "Your ip is $(<external_ip.txt)"
SCRIPT_DIR="$(cd $(dirname $0) && pwd)"
echo "Script dir: $SCRIPT_DIR"
echo "Installing docker..."
apt-get update
apt-get install -y docker-ce
ln -s "$SCRIPT_DIR/restart.sh" ./restart_openvpn
ln -s "$SCRIPT_DIR/start.sh" ./start_openvpn
ln -s "$SCRIPT_DIR/stop.sh" ./stop_openvpn
ln -s "$SCRIPT_DIR/create_openvpn_user.sh" ./create_openvpn_user

docker run -v /root/ovpn-data:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_genconfig -u "tcp://$(<external_ip.txt):443"
docker run -v /root/ovpn-data:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn ovpn_initpki

docker run --name openvpn --restart always -v /root/ovpn-data:/etc/openvpn -d -p 443:1194 --cap-add=NET_ADMIN kylemanna/openvpn