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
echo "Auto Installer planq_7070-2 {cosmovisor} For PLANQ NETWORK v1.0.3";
echo -e "\e[0m"
sleep 1

# Variable
PLANQ_WALLET=wallet
PLANQ=planqd
BINARY=cosmovisor
PLANQ_ID=planq_7070-2
PLANQ_FOLDER=.planqd
PLANQ_VER=v1.0.3
PLANQ_REPO=https://github.com/planq-network/planq
PLANQ_GENESIS=https://snapshot.sxlzptprjkt.xyz/planq/genesis.json
PLANQ_ADDRBOOK=https://snapshot.sxlzptprjkt.xyz/planq/addrbook.json
PLANQ_DENOM=aplanq
PLANQ_PORT=18

echo "export PLANQ_WALLET=${PLANQ_WALLET}" >> $HOME/.bash_profile
echo "export PLANQ=${PLANQ}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export PLANQ_ID=${PLANQ_ID}" >> $HOME/.bash_profile
echo "export PLANQ_FOLDER=${PLANQ_FOLDER}" >> $HOME/.bash_profile
echo "export PLANQ_VER=${PLANQ_VER}" >> $HOME/.bash_profile
echo "export PLANQ_REPO=${PLANQ_REPO}" >> $HOME/.bash_profile
echo "export PLANQ_GENESIS=${PLANQ_GENESIS}" >> $HOME/.bash_profile
echo "export PLANQ_ADDRBOOK=${PLANQ_ADDRBOOK}" >> $HOME/.bash_profile
echo "export PLANQ_DENOM=${PLANQ_DENOM}" >> $HOME/.bash_profile
echo "export PLANQ_PORT=${PLANQ_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $PLANQ_NODENAME ]; then
	read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " PLANQ_NODENAME
	echo 'export PLANQ_NODENAME='$PLANQ_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$PLANQ_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$PLANQ_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$PLANQ_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get mainnet version of planq
cd $HOME
rm -rf planq
git clone $PLANQ_REPO
cd planq
git checkout $PLANQ_VER
make install
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$PLANQ_FOLDER/$BINARY/genesis/bin
mv $HOME/go/bin/$PLANQ $HOME/$PLANQ_FOLDER/$BINARY/genesis/bin/

# Create application symlinks
ln -s $HOME/$PLANQ_FOLDER/$BINARY/genesis $HOME/$PLANQ_FOLDER/$BINARY/current
sudo ln -s $HOME/$PLANQ_FOLDER/$BINARY/current/bin/$PLANQ /usr/bin/$PLANQ

# Init generation
$PLANQ config chain-id $PLANQ_ID
$PLANQ config keyring-backend file
$PLANQ config node tcp://localhost:${PLANQ_PORT}657
$PLANQ init $PLANQ_NODENAME --chain-id $PLANQ_ID

# Set peers and seeds
PEERS="b611a4058ac5caf8b56c1012c695afc75aea4217@peers-planq.sxlzptprjkt.xyz:18656"
SEEDS="5966b4ef17da12ee63ef30e50512ad41d541195c@seeds-planq.sxlzptprjkt.xyz:18656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$PLANQ_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$PLANQ_FOLDER/config/config.tom

# Download genesis and addrbook
curl -Ls $PLANQ_GENESIS > $HOME/$PLANQ_FOLDER/config/genesis.json
curl -Ls $PLANQ_ADDRBOOK > $HOME/$PLANQ_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PLANQ_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PLANQ_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PLANQ_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PLANQ_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PLANQ_PORT}660\"%" $HOME/$PLANQ_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PLANQ_PORT}317\"%; s%^address = \":8080\"%address = \":${PLANQ_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PLANQ_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PLANQ_PORT}091\"%" $HOME/$PLANQ_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$PLANQ_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$PLANQ_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$PLANQ_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$PLANQ_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025$PLANQ_DENOM\"/" $HOME/$PLANQ_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$PLANQ_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$PLANQ_FOLDER/config/app.toml
$PLANQ tendermint unsafe-reset-all --home $HOME/$PLANQ_FOLDER --keep-addr-book
SNAP_NAME=$(curl -s https://snapshots.nodestake.top/planq/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
curl -o - -L https://snapshots.nodestake.top/planq/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/$PLANQ_FOLDER

# Create Service
sudo tee /etc/systemd/system/$PLANQ.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BINARY) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$PLANQ_FOLDER"
Environment="DAEMON_NAME=$PLANQ"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $PLANQ
sudo systemctl start $PLANQ

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[31msystemctl status $PLANQ\e[0m"
echo -e "CHECK RUNNING LOGS  : \e[1m\e[31mjournalctl -fu $PLANQ -o cat\e[0m"
echo -e "CHECK LOCAL STATUS  : \e[1m\e[31mcurl -s localhost:${PLANQ_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
