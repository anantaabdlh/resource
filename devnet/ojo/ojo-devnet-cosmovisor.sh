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
echo "  Auto Installer ojo-devnet {cosmovisor} For OJO NETWORK v0.1.2  ";
echo -e "\e[0m"
sleep 1

# Variable
OJO_WALLET=wallet
OJO=ojod
BINARY=cosmovisor
OJO_ID=ojo-devnet
OJO_FOLDER=.ojo
OJO_VER=v0.1.2
OJO_REPO=https://github.com/ojo-network/ojo
OJO_GENESIS=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/devnet/ojo/genesis.json
OJO_ADDRBOOK=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/devnet/ojo/addrbook.json
OJO_DENOM=uojo
OJO_PORT=28

echo "export OJO_WALLET=${OJO_WALLET}" >> $HOME/.bash_profile
echo "export OJO=${OJO}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export OJO_ID=${OJO_ID}" >> $HOME/.bash_profile
echo "export OJO_FOLDER=${OJO_FOLDER}" >> $HOME/.bash_profile
echo "export OJO_VER=${OJO_VER}" >> $HOME/.bash_profile
echo "export OJO_REPO=${OJO_REPO}" >> $HOME/.bash_profile
echo "export OJO_GENESIS=${OJO_GENESIS}" >> $HOME/.bash_profile
echo "export OJO_ADDRBOOK=${OJO_ADDRBOOK}" >> $HOME/.bash_profile
echo "export OJO_DENOM=${OJO_DENOM}" >> $HOME/.bash_profile
echo "export OJO_PORT=${OJO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $OJO_NODENAME ]; then
	read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " OJO_NODENAME
	echo 'export OJO_NODENAME='$OJO_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$OJO_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$OJO_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$OJO_PORT\e[0m"
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

# Get devnet version of ojo
cd $HOME
rm -rf ojo
git clone $OJO_REPO
cd ojo
git checkout $OJO_VER
make install
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$OJO_FOLDER/$BINARY/genesis/bin
mv $HOME/go/bin/$OJO $HOME/$OJO_FOLDER/$BINARY/genesis/bin/

# Create application symlinks
ln -s $HOME/$OJO_FOLDER/$BINARY/genesis $HOME/$OJO_FOLDER/$BINARY/current
sudo ln -s $HOME/$OJO_FOLDER/$BINARY/current/bin/$OJO /usr/bin/$OJO

# Init generation
$OJO config chain-id $OJO_ID
$OJO config keyring-backend test
$OJO config node tcp://localhost:${OJO_PORT}657
$OJO init $OJO_NODENAME --chain-id $OJO_ID

# Set peers and seeds
PEERS="0ccc4bd8386fbec1421e3c19c24124eeb00b3293@peers-ojo-devnet.sxlzptprjkt.xyz:28656"
SEEDS="5a36595613f189a3c1096729897fb02be0a8c15e@seeds-ojo-devnet.sxlzptprjkt.xyz:28656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$OJO_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$OJO_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $OJO_GENESIS > $HOME/$OJO_FOLDER/config/genesis.json
curl -Ls $OJO_ADDRBOOK > $HOME/$OJO_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OJO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${OJO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${OJO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${OJO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${OJO_PORT}660\"%" $HOME/$OJO_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${OJO_PORT}317\"%; s%^address = \":8080\"%address = \":${OJO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${OJO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${OJO_PORT}091\"%" $HOME/$OJO_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$OJO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$OJO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$OJO_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$OJO_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$OJO_DENOM\"/" $HOME/$OJO_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$OJO_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$OJO_FOLDER/config/app.toml
$OJO tendermint unsafe-reset-all --home $HOME/$OJO_FOLDER --keep-addr-book
curl -L https://snapshots.kjnodes.com/ojo-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/$OJO_FOLDER

# Create Service
sudo tee /etc/systemd/system/$OJO.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BINARY) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$OJO_FOLDER"
Environment="DAEMON_NAME=$OJO"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $OJO
sudo systemctl start $OJO

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[31msystemctl status $OJO\e[0m"
echo -e "CHECK RUNNING LOGS  : \e[1m\e[31mjournalctl -fu $OJO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS  : \e[1m\e[31mcurl -s localhost:${OJO_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
