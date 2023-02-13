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
echo "    Auto Installer atreides-1 For Alliance (terra) v0.0.1-goa    ";
echo -e "\e[0m"
sleep 1

# Variable
ATREIDES_WALLET=wallet
ATREIDES=atreidesd
ATREIDES_ID=atreides-1
ATREIDES_FOLDER=.atreides
ATREIDES_VER=v0.0.1-goa
ATREIDES_REPO=https://github.com/terra-money/alliance
ATREIDES_DENOM=uatr
ATREIDES_PORT=04

echo "export ATREIDES_WALLET=${ATREIDES_WALLET}" >> $HOME/.bash_profile
echo "export ATREIDES=${ATREIDES}" >> $HOME/.bash_profile
echo "export ATREIDES_ID=${ATREIDES_ID}" >> $HOME/.bash_profile
echo "export ATREIDES_FOLDER=${ATREIDES_FOLDER}" >> $HOME/.bash_profile
echo "export ATREIDES_VER=${ATREIDES_VER}" >> $HOME/.bash_profile
echo "export ATREIDES_REPO=${ATREIDES_REPO}" >> $HOME/.bash_profile
echo "export ATREIDES_DENOM=${ATREIDES_DENOM}" >> $HOME/.bash_profile
echo "export ATREIDES_PORT=${ATREIDES_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $ATREIDES_NODENAME ]; then
        read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " ATREIDES_NODENAME
        echo 'export ATREIDES_NODENAME='$ATREIDES_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$ATREIDES_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$ATREIDES_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$ATREIDES_PORT\e[0m"
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
git clone $ATREIDES_REPO
cd alliance
git checkout $ATREIDES_VER
make build-alliance ACC_PREFIX=atreides
sudo mv build/$ATREIDES /usr/bin/

# Init generation
$ATREIDES config chain-id $ATREIDES_ID
$ATREIDES config keyring-backend file
$ATREIDES config node tcp://localhost:${ATREIDES_PORT}657
$ATREIDES init $ATREIDES_NODENAME --chain-id $ATREIDES_ID

# Set peers and seeds
PEERS="58c31664ab2888515ead08fac36f92d36ee843c9@146.190.83.6:04656"
SEEDS="d634d42f4f84caa0db7c718353090fd7973e702e@goa-seeds.lavenderfive.com:13656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$ATREIDES_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$ATREIDES_FOLDER/config/config.toml

# Create file genesis.json
touch $HOME/$ATREIDES_FOLDER/config/genesis.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ATREIDES_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ATREIDES_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ATREIDES_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ATREIDES_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ATREIDES_PORT}660\"%" $HOME/$ATREIDES_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ATREIDES_PORT}317\"%; s%^address = \":8080\"%address = \":${ATREIDES_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ATREIDES_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ATREIDES_PORT}091\"%" $HOME/$ATREIDES_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$ATREIDES_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$ATREIDES_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$ATREIDES_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$ATREIDES_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$ATREIDES_DENOM\"/" $HOME/$ATREIDES_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"1000\"/" $HOME/$ATREIDES_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"2\"/" $HOME/$ATREIDES_FOLDER/config/app.toml

# Enable state sync
$ATREIDES tendermint unsafe-reset-all --home $HOME/$ATREIDES_FOLDER

SNAP_RPC="https://rpc-goa-atreides.sxlzptprjkt.xyz:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo ""
echo -e "\e[1m\e[31m[!]\e[0m HEIGHT : \e[1m\e[31m$LATEST_HEIGHT\e[0m BLOCK : \e[1m\e[31m$BLOCK_HEIGHT\e[0m HASH : \e[1m\e[31m$TRUST_HASH\e[0m"
echo ""

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$ATREIDES_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$ATREIDES.service > /dev/null <<EOF
[Unit]
Description=$ATREIDES
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $ATREIDES) start --home $HOME/$ATREIDES_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $ATREIDES
sudo systemctl start $ATREIDES

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $ATREIDES -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${ATREIDES_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
