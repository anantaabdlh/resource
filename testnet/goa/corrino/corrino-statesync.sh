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
echo "     Auto Installer corrino-1 For Alliance (terra) v0.1.0-goa    ";
echo -e "\e[0m"
sleep 1

# Variable
CORRINO_WALLET=wallet
CORRINO=corrinod
CORRINO_ID=corrino-1
CORRINO_FOLDER=.corrino
CORRINO_VER=v0.1.0-goa
CORRINO_REPO=https://github.com/terra-money/alliance
CORRINO_DENOM=ucor
CORRINO_PORT=03

echo "export CORRINO_WALLET=${CORRINO_WALLET}" >> $HOME/.bash_profile
echo "export CORRINO=${CORRINO}" >> $HOME/.bash_profile
echo "export CORRINO_ID=${CORRINO_ID}" >> $HOME/.bash_profile
echo "export CORRINO_FOLDER=${CORRINO_FOLDER}" >> $HOME/.bash_profile
echo "export CORRINO_VER=${CORRINO_VER}" >> $HOME/.bash_profile
echo "export CORRINO_REPO=${CORRINO_REPO}" >> $HOME/.bash_profile
echo "export CORRINO_DENOM=${CORRINO_DENOM}" >> $HOME/.bash_profile
echo "export CORRINO_PORT=${CORRINO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $CORRINO_NODENAME ]; then
        read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " CORRINO_NODENAME
        echo 'export CORRINO_NODENAME='$CORRINO_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$CORRINO_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$CORRINO_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$CORRINO_PORT\e[0m"
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
git clone $CORRINO_REPO
cd alliance
git checkout $CORRINO_VER
make build-alliance ACC_PREFIX=corrino
sudo mv build/$CORRINO /usr/bin/

# Init generation
$CORRINO config chain-id $CORRINO_ID
$CORRINO config keyring-backend file
$CORRINO config node tcp://localhost:${CORRINO_PORT}657
$CORRINO init $CORRINO_NODENAME --chain-id $CORRINO_ID

# Set peers and seeds
PEERS="abd7c8d502f7f27ed2bf11d0ca34c7e9e1186e79@146.190.83.6:03656"
SEEDS="2a78b8849872d641d61d97b95f7349540e9d8df0@goa-seeds.lavenderfive.com:12656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$CORRINO_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$CORRINO_FOLDER/config/config.toml

# Create file genesis.json
touch $HOME/$CORRINO_FOLDER/config/genesis.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CORRINO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CORRINO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CORRINO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CORRINO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CORRINO_PORT}660\"%" $HOME/$CORRINO_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CORRINO_PORT}317\"%; s%^address = \":8080\"%address = \":${CORRINO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CORRINO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CORRINO_PORT}091\"%" $HOME/$CORRINO_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$CORRINO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$CORRINO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$CORRINO_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$CORRINO_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$CORRINO_DENOM\"/" $HOME/$CORRINO_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"1000\"/" $HOME/$CORRINO_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"2\"/" $HOME/$CORRINO_FOLDER/config/app.toml

# Enable state sync
$CORRINO tendermint unsafe-reset-all --home $HOME/$CORRINO_FOLDER

SNAP_RPC="https://rpc-goa-corrino.sxlzptprjkt.xyz:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo ""
echo -e "\e[1m\e[31m[!]\e[0m HEIGHT : \e[1m\e[31m$LATEST_HEIGHT\e[0m BLOCK : \e[1m\e[31m$BLOCK_HEIGHT\e[0m HASH : \e[1m\e[31m$TRUST_HASH\e[0m"
echo ""

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$CORRINO_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$CORRINO.service > /dev/null <<EOF
[Unit]
Description=$CORRINO
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $CORRINO) start --home $HOME/$CORRINO_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $CORRINO
sudo systemctl start $CORRINO

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $CORRINO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${CORRINO_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
