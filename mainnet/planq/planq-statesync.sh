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
echo "   Auto Installer planq_7070-2 mainnet For PLANQ NETWORK v1.0.3  ";
echo -e "\e[0m"
sleep 1

# Variable
PLANQ_WALLET=wallet
PLANQ=planqd
PLANQ_ID=planq_7070-2
PLANQ_FOLDER=.planqd
PLANQ_VER=v1.0.3
PLANQ_REPO=https://github.com/planq-network/planq
PLANQ_DENOM=aplanq
PLANQ_PORT=18

echo "export PLANQ_WALLET=${PLANQ_WALLET}" >> $HOME/.bash_profile
echo "export PLANQ=${PLANQ}" >> $HOME/.bash_profile
echo "export PLANQ_ID=${PLANQ_ID}" >> $HOME/.bash_profile
echo "export PLANQ_FOLDER=${PLANQ_FOLDER}" >> $HOME/.bash_profile
echo "export PLANQ_VER=${PLANQ_VER}" >> $HOME/.bash_profile
echo "export PLANQ_REPO=${PLANQ_REPO}" >> $HOME/.bash_profile
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
sudo mv $HOME/go/bin/$PLANQ /usr/bin/

# Init generation
$PLANQ config chain-id $PLANQ_ID
$PLANQ config keyring-backend file
$PLANQ config node tcp://localhost:${PLANQ_PORT}657
$PLANQ init $PLANQ_NODENAME --chain-id $PLANQ_ID

# Set peers and seeds
PEERS="b611a4058ac5caf8b56c1012c695afc75aea4217@peers-planq.sxlzptprjkt.xyz:18656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$PLANQ_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$PLANQ_FOLDER/config/config.toml

# Create file genesis.json
touch $HOME/$PLANQ_FOLDER/config/genesis.json

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
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$PLANQ_DENOM\"/" $HOME/$PLANQ_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$PLANQ_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$PLANQ_FOLDER/config/app.toml

# Enable state sync
$PLANQ tendermint unsafe-reset-all --home $HOME/$PLANQ_FOLDER

SNAP_RPC="https://rpc-planq.sxlzptprjkt.xyz:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo ""
echo -e "\e[1m\e[31m[!]\e[0m HEIGHT : \e[1m\e[31m$LATEST_HEIGHT\e[0m BLOCK : \e[1m\e[31m$BLOCK_HEIGHT\e[0m HASH : \e[1m\e[31m$TRUST_HASH\e[0m"
echo ""

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$PLANQ_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$PLANQ.service > /dev/null <<EOF
[Unit]
Description=$PLANQ
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $PLANQ) start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $PLANQ
sudo systemctl start $PLANQ

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $PLANQ -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${PLANQ_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
