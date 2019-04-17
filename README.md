# Simple OpenVPN Server Script
### Installation
Run the following commands as root:
```bash
git clone https://github.com/nordikafiles/hse-vpn
./hse-vpn/setup.sh
```
### Usage
Start, stop and restart server:
```bash
restart_openvpn
start_openvpn
stop_openvpn
```
Create OpenVPN client:
```bash
create_openvpn_user username
```
This script creates a file named username.ovpn