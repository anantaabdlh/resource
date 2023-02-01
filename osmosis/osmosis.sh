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
echo "       Auto Installer osmosis-1 mainnet For OSMOSIS v14.0.0      ";
echo -e "\e[0m"
sleep 1

# Variable
OSMO_WALLET=wallet
OSMO=osmosisd
OSMO_ID=osmosis-1
OSMO_FOLDER=.osmosisd
OSMO_VER=v14.0.0
OSMO_REPO=https://github.com/osmosis-labs/osmosis
OSMO_GENESIS=https://snapshots.kjnodes.com/osmosis/genesis.json
OSMO_ADDRBOOK=https://snapshots.kjnodes.com/osmosis/addrbook.json
OSMO_DENOM=uosmo
OSMO_PORT=19

echo "export OSMO_WALLET=${OSMO_WALLET}" >> $HOME/.bash_profile
echo "export OSMO=${OSMO}" >> $HOME/.bash_profile
echo "export OSMO_ID=${OSMO_ID}" >> $HOME/.bash_profile
echo "export OSMO_FOLDER=${OSMO_FOLDER}" >> $HOME/.bash_profile
echo "export OSMO_VER=${OSMO_VER}" >> $HOME/.bash_profile
echo "export OSMO_REPO=${OSMO_REPO}" >> $HOME/.bash_profile
echo "export OSMO_GENESIS=${OSMO_GENESIS}" >> $HOME/.bash_profile
echo "export OSMO_ADDRBOOK=${OSMO_ADDRBOOK}" >> $HOME/.bash_profile
echo "export OSMO_DENOM=${OSMO_DENOM}" >> $HOME/.bash_profile
echo "export OSMO_PORT=${OSMO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $OSMO_NODENAME ]; then
	read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " OSMO_NODENAME
	echo 'export OSMO_NODENAME='$OSMO_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$OSMO_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$OSMO_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$OSMO_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential lz4 gcc git jq chrony -y

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

# Get mainnet version of osmosis
cd $HOME
rm -rf osmosis
git clone $OSMO_REPO
cd osmosis
git checkout $OSMO_VER
make build
mv build/$OSMO /usr/bin/

# Create Service
sudo tee /etc/systemd/system/$OSMO.service > /dev/null <<EOF
[Unit]
Description=$OSMO
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $OSMO) start --home $HOME/$OSMO_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register service
sudo systemctl daemon-reload
sudo systemctl enable $OSMO

# Init generation
$OSMO config chain-id $OSMO_ID
$OSMO config keyring-backend file
$OSMO config node tcp://localhost:${OSMO_PORT}657
$OSMO init $OSMO_NODENAME --chain-id $OSMO_ID

# Set peers and seeds
PEERS=$(curl -sS https://rpc.osmosis.zone/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')
SEEDS=400f3d9e30b69e78a7fb891f60d76fa3c73f0ecc@osmosis.rpc.kjnodes.com:29659,21d7539792ee2e0d650b199bf742c56ae0cf499e@162.55.132.230:2000,295b417f995073d09ff4c6c141bd138a7f7b5922@65.21.141.212:2000,ec4d3571bf709ab78df61716e47b5ac03d077a1a@65.108.43.26:2000,4cb8e1e089bdf44741b32638591944dc15b7cce3@65.108.73.18:2000,f515a8599b40f0e84dfad935ba414674ab11a668@osmosis.blockpane.com:26656,6bcdbcfd5d2c6ba58460f10dbcfde58278212833@osmosis.artifact-staking.io:26656
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$OSMO_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$OSMO_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $OSMO_GENESIS > $HOME/$OSMO_FOLDER/config/genesis.json
curl -Ls $OSMO_ADDRBOOK > $HOME/$OSMO_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OSMO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${OSMO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${OSMO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${OSMO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${OSMO_PORT}660\"%" $HOME/$OSMO_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${OSMO_PORT}317\"%; s%^address = \":8080\"%address = \":${OSMO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${OSMO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${OSMO_PORT}091\"%" $HOME/$OSMO_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$OSMO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$OSMO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$OSMO_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$OSMO_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$OSMO_DENOM\"/" $HOME/$OSMO_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$OSMO_FOLDER/config/app.toml
$OSMO tendermint unsafe-reset-all --home $HOME/$OSMO_FOLDER --keep-addr-book
curl -L https://snapshots.kjnodes.com/osmosis/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/$OSMO_FOLDER

# Start Service
sudo systemctl start $OSMO

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS  : \e[1m\e[31mjournalctl -fu $OSMO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS  : \e[1m\e[31mcurl -s localhost:${OSMO_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
