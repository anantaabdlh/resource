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
echo "   Auto Installer eightball-1 {cosmovisor} For 8ball v0.34.24    ";
echo -e "\e[0m"
sleep 1

# Variable
EBL_WALLET=wallet
EBL=8ball
BINARY=cosmovisor
EBL_ID=eightball-1
EBL_FOLDER=.8ball
EBL_VER=v0.34.24
EBL_REPO=https://github.com/sxlmnwb/8ball
EBL_GENESIS=https://snap.nodexcapital.com/8ball/genesis.json
EBL_ADDRBOOK=https://snap.nodexcapital.com/8ball/addrbook.json
EBL_DENOM=uebl
EBL_PORT=23

echo "export EBL_WALLET=${EBL_WALLET}" >> $HOME/.bash_profile
echo "export EBL=${EBL}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export EBL_ID=${EBL_ID}" >> $HOME/.bash_profile
echo "export EBL_FOLDER=${EBL_FOLDER}" >> $HOME/.bash_profile
echo "export EBL_VER=${EBL_VER}" >> $HOME/.bash_profile
echo "export EBL_REPO=${EBL_REPO}" >> $HOME/.bash_profile
echo "export EBL_GENESIS=${EBL_GENESIS}" >> $HOME/.bash_profile
echo "export EBL_ADDRBOOK=${EBL_ADDRBOOK}" >> $HOME/.bash_profile
echo "export EBL_DENOM=${EBL_DENOM}" >> $HOME/.bash_profile
echo "export EBL_PORT=${EBL_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $EBL_NODENAME ]; then
        read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " EBL_NODENAME
        echo 'export EBL_NODENAME='$EBL_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$EBL_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$EBL_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$EBL_PORT\e[0m"
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

# Get mainnet version of 8ball
cd $HOME
rm -rf $EBL
git clone $EBL_REPO
cd $EBL
git checkout $EBL_VER
go build -o $EBL ./cmd/eightballd
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$EBL_FOLDER/$BINARY/genesis/bin
mv $EBL $HOME/$EBL_FOLDER/$BINARY/genesis/bin/

# Create application symlinks
ln -s $HOME/$EBL_FOLDER/$BINARY/genesis $HOME/$EBL_FOLDER/$BINARY/current
sudo ln -s $HOME/$EBL_FOLDER/$BINARY/current/bin/$EBL /usr/bin/$EBL

# Init generation
$EBL config chain-id $EBL_ID
$EBL config keyring-backend file
$EBL config node tcp://localhost:${EBL_PORT}657
$EBL init $EBL_NODENAME --chain-id $EBL_ID

# Set peers and seeds
PEERS="fca96d0a1d7357afb226a49c4c7d9126118c37e9@one.8ball.info:26656,aa918e17c8066cd3b031f490f0019c1a95afe7e3@two.8ball.info:26656,98b49fea92b266ed8cfb0154028c79f81d16a825@three.8ball.info:26656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$EBL_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$EBL_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $EBL_GENESIS > $HOME/$EBL_FOLDER/config/genesis.json
curl -Ls $EBL_ADDRBOOK > $HOME/$EBL_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${EBL_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${EBL_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${EBL_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${EBL_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${EBL_PORT}660\"%" $HOME/$EBL_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${EBL_PORT}317\"%; s%^address = \":8080\"%address = \":${EBL_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${EBL_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${EBL_PORT}091\"%" $HOME/$EBL_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$EBL_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$EBL_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$EBL_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$EBL_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025$EBL_DENOM\"/" $HOME/$EBL_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$EBL_FOLDER/config/app.toml
$EBL tendermint unsafe-reset-all --home $HOME/$EBL_FOLDER --keep-addr-book
curl -L https://snap.nodexcapital.com/8ball/8ball-latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/$EBL_FOLDER

# Create Service
sudo tee /etc/systemd/system/$EBL.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BINARY) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$EBL_FOLDER"
Environment="DAEMON_NAME=$EBL"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl start $EBL
sudo systemctl daemon-reload
sudo systemctl enable $EBL

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[31msystemctl status $EBL\e[0m"
echo -e "CHECK RUNNING LOGS  : \e[1m\e[31mjournalctl -fu $EBL -o cat\e[0m"
echo -e "CHECK LOCAL STATUS  : \e[1m\e[31mcurl -s localhost:${EBL_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
