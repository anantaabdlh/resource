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
echo "        Auto Installer galileo-3 {cosmovisor} v1.1.0-beta1       ";
echo -e "\e[0m"
sleep 1

# Variable
ANDR_WALLET=wallet
ANDR=andromedad
BINARY=cosmovisor
ANDR_ID=galileo-3
ANDR_FOLDER=.andromedad
ANDR_VER=galileo-3-v1.1.0-beta1
ANDR_REPO=https://github.com/andromedaprotocol/andromedad
ANDR_GENESIS=https://snapshots.kjnodes.com/andromeda-testnet/genesis.json
ANDR_ADDRBOOK=https://snapshots.kjnodes.com/andromeda-testnet/addrbook.json
ANDR_DENOM=aplanq
ANDR_PORT=18

echo "export ANDR_WALLET=${ANDR_WALLET}" >> $HOME/.bash_profile
echo "export ANDR=${ANDR}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export ANDR_ID=${ANDR_ID}" >> $HOME/.bash_profile
echo "export ANDR_FOLDER=${ANDR_FOLDER}" >> $HOME/.bash_profile
echo "export ANDR_VER=${ANDR_VER}" >> $HOME/.bash_profile
echo "export ANDR_REPO=${ANDR_REPO}" >> $HOME/.bash_profile
echo "export ANDR_GENESIS=${ANDR_GENESIS}" >> $HOME/.bash_profile
echo "export ANDR_ADDRBOOK=${ANDR_ADDRBOOK}" >> $HOME/.bash_profile
echo "export ANDR_DENOM=${ANDR_DENOM}" >> $HOME/.bash_profile
echo "export ANDR_PORT=${ANDR_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $ANDR_NODENAME ]; then
	read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " ANDR_NODENAME
	echo 'export ANDR_NODENAME='$ANDR_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$ANDR_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$ANDR_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$ANDR_PORT\e[0m"
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

# Get testnet version of andromeda
cd $HOME
rm -rf $ANDR
git clone $ANDR_REPO
cd $ANDR
git checkout $ANDR_VER
make build
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$ANDR_FOLDER/$BINARY/genesis/bin
mv build/$ANDR $HOME/$ANDR_FOLDER/$BINARY/genesis/bin/

# Create application symlinks
ln -s $HOME/$ANDR_FOLDER/$BINARY/genesis $HOME/$ANDR_FOLDER/$BINARY/current
sudo ln -s $HOME/$ANDR_FOLDER/$BINARY/current/bin/$ANDR /usr/bin/$ANDR

# Init generation
$ANDR config chain-id $ANDR_ID
$ANDR config keyring-backend file
$ANDR config node tcp://localhost:${ANDR_PORT}657
$ANDR init $ANDR_NODENAME --chain-id $ANDR_ID

# Set peers and seeds
PEERS="8870aca1936673bb2068ed07fcadc6c46d3ec3a1@146.190.83.6:22656"
SEEDS="3f472746f46493309650e5a033076689996c8881@andromeda-testnet.rpc.kjnodes.com:47659"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$ANDR_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$ANDR_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $ANDR_GENESIS > $HOME/$ANDR_FOLDER/config/genesis.json
curl -Ls $ANDR_ADDRBOOK > $HOME/$ANDR_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ANDR_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ANDR_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ANDR_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ANDR_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ANDR_PORT}660\"%" $HOME/$ANDR_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ANDR_PORT}317\"%; s%^address = \":8080\"%address = \":${ANDR_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ANDR_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ANDR_PORT}091\"%" $HOME/$ANDR_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$ANDR_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$ANDR_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$ANDR_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$ANDR_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$ANDR_DENOM\"/" $HOME/$ANDR_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$ANDR_FOLDER/config/app.toml
$ANDR tendermint unsafe-reset-all --home $HOME/$ANDR_FOLDER --keep-addr-book
curl -L https://snapshots.kjnodes.com/andromeda-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/$ANDR_FOLDER

# Create Service
sudo tee /etc/systemd/system/$ANDR.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BINARY) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$ANDR_FOLDER"
Environment="DAEMON_NAME=$ANDR"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $ANDR
sudo systemctl start $ANDR

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[31msystemctl status $ANDR\e[0m"
echo -e "CHECK RUNNING LOGS  : \e[1m\e[31mjournalctl -fu $ANDR -o cat\e[0m"
echo -e "CHECK LOCAL STATUS  : \e[1m\e[31mcurl -s localhost:${ANDR_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
