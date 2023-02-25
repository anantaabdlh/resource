#
# // Copyright (C) 2022 Salman Wahib (sxlmnwb)
#

echo -e "\033[0;31m"
echo "  ██████ ▒██   ██▒ ██▓     ███▄ ▄███▓ ███▄    █  █     █░▓█████▄ ";
echo "▒██    ▒ ▒▒ █ █ ▒░▓██▒    ▓██▒▀█▀ ██▒ ██ ▀█   █ ▓█░ █ ░█▒██▒ ▄██░";
echo "░ ▓██▄   ░░  █   ░▒██░    ▓██    ▓██░▓██  ▀█ ██▒▒█░ █ ░█ ▒██░█▀  ";
echo "  ▒   ██▒ ░ █ █ ▒ ▒██░    ▒██    ▒██ ▓██▒  ▐▌██▒░█░ █ ░█ ░▓█  ▀█▓";
echo "▒██████▒▒▒██▒ ▒██▒░██████▒▒██▒   ░██▒▒██░   ▓██░░░██▒██▓ ░▒▓███▀▒";
echo "▒ ▒▓▒ ▒ ░▒▒ ░ ░▓ ░░ ▒░▓  ░░ ▒░   ░  ░░ ▒░   ▒ ▒ ░ ▓░▒ ▒  ▒░▒   ░ ";
echo "░ ░▒  ░ ░░░   ░▒ ░░ ░ ▒  ░░  ░      ░░ ░░   ░ ▒░  ▒ ░ ░   ░    ░ ";
echo "░  ░  ░   ░    ░    ░ ░   ░      ░      ░   ░ ░   ░   ░ ░        ";
echo "      ░   ░    ░      ░  ░       ░            ░     ░          ░ ";
echo "             Auto Installer arkh For arkhadian v2.0.0            ";
echo -e "\e[0m"
sleep 1

# Variable
ARKH_WALLET=wallet
ARKH=arkhd
ARKH_ID=arkh
ARKH_FOLDER=.arkh
ARKH_VER=v2.0.0
ARKH_REPO=https://github.com/vincadian/arkh-blockchain
ARKH_GENESIS=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/mainnet/arkh/genesis.json
ARKH_ADDRBOOK=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/mainnet/arkh/addrbook.json
ARKH_DENOM=arkh
ARKH_PORT=25

echo "export ARKH_WALLET=${ARKH_WALLET}" >> $HOME/.bash_profile
echo "export ARKH=${ARKH}" >> $HOME/.bash_profile
echo "export ARKH_ID=${ARKH_ID}" >> $HOME/.bash_profile
echo "export ARKH_FOLDER=${ARKH_FOLDER}" >> $HOME/.bash_profile
echo "export ARKH_VER=${ARKH_VER}" >> $HOME/.bash_profile
echo "export ARKH_REPO=${ARKH_REPO}" >> $HOME/.bash_profile
echo "export ARKH_GENESIS=${ARKH_GENESIS}" >> $HOME/.bash_profile
echo "export ARKH_ADDRBOOK=${ARKH_ADDRBOOK}" >> $HOME/.bash_profile
echo "export ARKH_DENOM=${ARKH_DENOM}" >> $HOME/.bash_profile
echo "export ARKH_PORT=${ARKH_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $ARKH_NODENAME ]; then
	read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " ARKH_NODENAME
	echo 'export ARKH_NODENAME='$ARKH_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$ARKH_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$ARKH_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$ARKH_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.19.5"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get mainnet version of arkh
cd $HOME
rm -rf arkh-blockchain
git clone $ARKH_REPO
cd arkh-blockchain
git checkout $ARKH_VER
go build -o $ARKH ./cmd/arkhd
sudo mv $ARKH /usr/bin/

# Init generation
$ARKH config chain-id $ARKH_ID
$ARKH config keyring-backend file
$ARKH config node tcp://localhost:${ARKH_PORT}657
$ARKH init $ARKH_NODENAME --chain-id $ARKH_ID

# Set peers and seeds
PEERS=$(curl -sS https://rpc-arkh.sxlzptprjkt.xyz/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')
SEEDS="808f01d4a7507bf7478027a08d95c575e1b5fa3c@asc-dataseed.arkhadian.com:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$ARKH_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$ARKH_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $ARKH_GENESIS > $HOME/$ARKH_FOLDER/config/genesis.json
curl -Ls $ARKH_ADDRBOOK > $HOME/$ARKH_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ARKH_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ARKH_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ARKH_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ARKH_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ARKH_PORT}660\"%" $HOME/$ARKH_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ARKH_PORT}317\"%; s%^address = \":8080\"%address = \":${ARKH_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ARKH_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ARKH_PORT}091\"%" $HOME/$ARKH_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$ARKH_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$ARKH_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$ARKH_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$ARKH_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025$ARKH_DENOM\"/" $HOME/$ARKH_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$ARKH_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$ARKH_FOLDER/config/app.toml
$ARKH unsafe-reset-all --home $HOME/$ARKH_FOLDER
curl -L https://snap.nodeist.net/arkh/arkh.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/$ARKH_FOLDER --strip-components 2

# Create Service
sudo tee /etc/systemd/system/$ARKH.service > /dev/null <<EOF
[Unit]
Description=$ARKH
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $ARKH) start --home $HOME/$ARKH_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $ARKH
sudo systemctl start $ARKH

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $ARKH -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${ARKH_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
