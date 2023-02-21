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
echo "    Auto Installer harkonnen-1 For Alliance (terra) v0.1.0-goa   ";
echo -e "\e[0m"
sleep 1

# Variable
HARKONNEN_WALLET=wallet
HARKONNEN=harkonnend
HARKONNEN_ID=harkonnen-1
HARKONNEN_FOLDER=.harkonnen
HARKONNEN_VER=v0.1.0-goa
HARKONNEN_REPO=https://github.com/terra-money/alliance
HARKONNEN_DENOM=uhar
HARKONNEN_PORT=02

echo "export HARKONNEN_WALLET=${HARKONNEN_WALLET}" >> $HOME/.bash_profile
echo "export HARKONNEN=${HARKONNEN}" >> $HOME/.bash_profile
echo "export HARKONNEN_ID=${HARKONNEN_ID}" >> $HOME/.bash_profile
echo "export HARKONNEN_FOLDER=${HARKONNEN_FOLDER}" >> $HOME/.bash_profile
echo "export HARKONNEN_VER=${HARKONNEN_VER}" >> $HOME/.bash_profile
echo "export HARKONNEN_REPO=${HARKONNEN_REPO}" >> $HOME/.bash_profile
echo "export HARKONNEN_DENOM=${HARKONNEN_DENOM}" >> $HOME/.bash_profile
echo "export HARKONNEN_PORT=${HARKONNEN_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $HARKONNEN_NODENAME ]; then
        read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " HARKONNEN_NODENAME
        echo 'export HARKONNEN_NODENAME='$HARKONNEN_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$HARKONNEN_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$HARKONNEN_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$HARKONNEN_PORT\e[0m"
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

# Get testnet version of alliance (terra)
cd $HOME
rm -rf alliance
git clone $HARKONNEN_REPO
cd alliance
git checkout $HARKONNEN_VER
make build-alliance ACC_PREFIX=harkonnen
sudo mv build/$HARKONNEN /usr/bin/

# Init generation
$HARKONNEN config chain-id $HARKONNEN_ID
$HARKONNEN config keyring-backend file
$HARKONNEN config node tcp://localhost:${HARKONNEN_PORT}657
$HARKONNEN init $HARKONNEN_NODENAME --chain-id $HARKONNEN_ID

# Set peers and seeds
PEERS="3a3d0eaa086d8a62b7c00d1177977244bc7d3ebb@146.190.81.135:02656"
SEEDS="1772a7a48530cc8adc447fdb7b720c064411667b@goa-seeds.lavenderfive.com:11656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$HARKONNEN_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$HARKONNEN_FOLDER/config/config.toml

# Create file genesis.json
touch $HOME/$HARKONNEN_FOLDER/config/genesis.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${HARKONNEN_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${HARKONNEN_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${HARKONNEN_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${HARKONNEN_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${HARKONNEN_PORT}660\"%" $HOME/$HARKONNEN_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${HARKONNEN_PORT}317\"%; s%^address = \":8080\"%address = \":${HARKONNEN_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${HARKONNEN_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${HARKONNEN_PORT}091\"%" $HOME/$HARKONNEN_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$HARKONNEN_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$HARKONNEN_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$HARKONNEN_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$HARKONNEN_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$HARKONNEN_DENOM\"/" $HOME/$HARKONNEN_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"1000\"/" $HOME/$HARKONNEN_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"2\"/" $HOME/$HARKONNEN_FOLDER/config/app.toml

# Enable state sync
$HARKONNEN tendermint unsafe-reset-all --home $HOME/$HARKONNEN_FOLDER

SNAP_RPC="https://rpc-goa-harkonnen.sxlzptprjkt.xyz:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo ""
echo -e "\e[1m\e[31m[!]\e[0m HEIGHT : \e[1m\e[31m$LATEST_HEIGHT\e[0m BLOCK : \e[1m\e[31m$BLOCK_HEIGHT\e[0m HASH : \e[1m\e[31m$TRUST_HASH\e[0m"
echo ""

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$HARKONNEN_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$HARKONNEN.service > /dev/null <<EOF
[Unit]
Description=$HARKONNEN
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $HARKONNEN) start --home $HOME/$HARKONNEN_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $HARKONNEN
sudo systemctl start $HARKONNEN

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $HARKONNEN -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${HARKONNEN_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
