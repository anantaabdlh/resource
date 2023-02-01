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
echo "   Auto Installer mars-1 {cosmovisor} For MARS PROTOCOL v1.0.0   ";
echo -e "\e[0m"
sleep 1

# Variable
MARS_WALLET=wallet
MARS=marsd
BINARY=cosmovisor
MARS_ID=mars-1
MARS_FOLDER=.mars
MARS_VER=v1.0.0
MARS_REPO=https://github.com/mars-protocol/hub
MARS_GENESIS=https://snapshots.polkachu.com/genesis/mars/genesis.json
MARS_ADDRBOOK=https://snapshots.polkachu.com/addrbook/mars/addrbook.json
MARS_DENOM=umars
MARS_PORT=20

echo "export MARS_WALLET=${MARS_WALLET}" >> $HOME/.bash_profile
echo "export MARS=${MARS}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export MARS_ID=${MARS_ID}" >> $HOME/.bash_profile
echo "export MARS_FOLDER=${MARS_FOLDER}" >> $HOME/.bash_profile
echo "export MARS_VER=${MARS_VER}" >> $HOME/.bash_profile
echo "export MARS_REPO=${MARS_REPO}" >> $HOME/.bash_profile
echo "export MARS_GENESIS=${MARS_GENESIS}" >> $HOME/.bash_profile
echo "export MARS_ADDRBOOK=${MARS_ADDRBOOK}" >> $HOME/.bash_profile
echo "export MARS_DENOM=${MARS_DENOM}" >> $HOME/.bash_profile
echo "export MARS_PORT=${MARS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $MARS_NODENAME ]; then
	read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " MARS_NODENAME
	echo 'export MARS_NODENAME='$MARS_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$MARS_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$MARS_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$MARS_PORT\e[0m"
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

# Get mainnet version of mars
cd $HOME
rm -rf hub
git clone $MARS_REPO
cd hub
git checkout $MARS_VER
make install
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$MARS_FOLDER/$BINARY/genesis/bin
mv $HOME/go/bin/$MARS $HOME/$MARS_FOLDER/$BINARY/genesis/bin/

# Create application symlinks
ln -s $HOME/$MARS_FOLDER/$BINARY/genesis $HOME/$MARS_FOLDER/$BINARY/current
sudo ln -s $HOME/$MARS_FOLDER/$BINARY/current/bin/$MARS /usr/bin/$MARS

# Init generation
$MARS config chain-id $MARS_ID
$MARS config keyring-backend file
$MARS config node tcp://localhost:${MARS_PORT}657
$MARS init $MARS_NODENAME --chain-id $MARS_ID

# Set peers and seeds
PEERS=9cb92702727bc5f3d40154e625b9553a04f4d649@65.109.104.72:18556
SEEDS=ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:18556
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$MARS_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$MARS_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $MARS_GENESIS > $HOME/$MARS_FOLDER/config/genesis.json
curl -Ls $MARS_ADDRBOOK > $HOME/$MARS_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${MARS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${MARS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${MARS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${MARS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${MARS_PORT}660\"%" $HOME/$MARS_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${MARS_PORT}317\"%; s%^address = \":8080\"%address = \":${MARS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${MARS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${MARS_PORT}091\"%" $HOME/$MARS_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$MARS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$MARS_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$MARS_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$MARS_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$MARS_DENOM\"/" $HOME/$MARS_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$MARS_FOLDER/config/app.toml
$MARS tendermint unsafe-reset-all --home $HOME/$MARS_FOLDER --keep-addr-book
SNAP_NAME=$(curl -s https://snapshots.nodestake.top/mars/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
curl -o - -L https://snapshots.nodestake.top/mars/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/$MARS_FOLDER

# Create Service
sudo tee /etc/systemd/system/$MARS.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BINARY) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$MARS_FOLDER"
Environment="DAEMON_NAME=$MARS"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl start $MARS
sudo systemctl daemon-reload
sudo systemctl enable $MARS

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[31msystemctl status $MARS\e[0m"
echo -e "CHECK RUNNING LOGS  : \e[1m\e[31mjournalctl -fu $MARS -o cat\e[0m"
echo -e "CHECK LOCAL STATUS  : \e[1m\e[31mcurl -s localhost:${MARS_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
