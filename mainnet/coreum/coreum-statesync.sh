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
echo "   Auto Installer coreum-mainnet-1 For COREUM FOUNDATION v1.0.0  ";
echo -e "\e[0m"
sleep 1

# Variable
CORE_WALLET=wallet
CORE=cored
CORE_ID=coreum-testnet-1
CORE_FOLDER=.core
CORE_VER=v1.0.0
CORE_BINARY=https://github.com/CoreumFoundation/coreum/releases/download
CORE_BIN=cored-linux-arm64
CORE_DENOM=ucore
CORE_PORT=29

echo "export CORE_WALLET=${CORE_WALLET}" >> $HOME/.bash_profile
echo "export CORE=${CORE}" >> $HOME/.bash_profile
echo "export CORE_ID=${CORE_ID}" >> $HOME/.bash_profile
echo "export CORE_FOLDER=${CORE_FOLDER}" >> $HOME/.bash_profile
echo "export CORE_VER=${CORE_VER}" >> $HOME/.bash_profile
echo "export CORE_BINARY=${CORE_BINARY}" >> $HOME/.bash_profile
echo "export CORE_BIN=${CORE_BIN}" >> $HOME/.bash_profile
echo "export CORE_DENOM=${CORE_DENOM}" >> $HOME/.bash_profile
echo "export CORE_PORT=${CORE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $CORE_NODENAME ]; then
        read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " CORE_NODENAME
        echo 'export CORE_NODENAME='$CORE_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$CORE_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$CORE_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$CORE_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install curl build-essential jq chrony lz4 -y

# Get testnet version of coreum
cd $HOME
curl -Ls $CORE_BINARY/$CORE_VER/$CORE_BIN > $CORE
chmod +x $CORE
sudo mv $CORE /usr/bin/

# Create Service
sudo tee /etc/systemd/system/$CORE.service > /dev/null <<EOF
[Unit]
Description=$CORE
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $CORE) start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register Service
sudo systemctl daemon-reload
sudo systemctl enable $CORE

# Init generation
$CORE config chain-id $CORE_ID
$CORE config keyring-backend file
$CORE config node tcp://localhost:${CORE_PORT}657
$CORE init $CORE_NODENAME --chain-id $CORE_ID

# Set peers and seeds
PEERS=5ecc41d09b74f3c4729cbfbe29dfa38a5ab0f371@peers-coreum.sxlzptprjkt.xyz:29656
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$CORE_FOLDER/$CORE_ID/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$CORE_FOLDER/$CORE_ID/config/config.toml

# Create file genesis.json
touch $HOME/$CORE_FOLDER/$CORE_ID/config/genesis.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CORE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CORE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CORE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CORE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CORE_PORT}660\"%" $HOME/$CORE_FOLDER/$CORE_ID/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CORE_PORT}317\"%; s%^address = \":8080\"%address = \":${CORE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CORE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CORE_PORT}091\"%" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$CORE_DENOM\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml

# Enable state sync
$CORE tendermint unsafe-reset-all --home $HOME/$CORE_FOLDER/$CORE_ID

SNAP_RPC="https://rpc-coreum.sxlzptprjkt.xyz:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo ""
echo -e "\e[1m\e[31m[!]\e[0m HEIGHT : \e[1m\e[31m$LATEST_HEIGHT\e[0m BLOCK : \e[1m\e[31m$BLOCK_HEIGHT\e[0m HASH : \e[1m\e[31m$TRUST_HASH\e[0m"
echo ""

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$CORE_FOLDER/$CORE_ID/config/config.toml

#Start Service
sudo systemctl start $CORE

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $CORE -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${CORE_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
