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
echo "         Auto Installer LumenX For LumenX Network v1.4.0         ";
echo -e "\e[0m"
sleep 1

# Variable
LUMEN_WALLET=wallet
LUMEN=lumenxd
LUMEN_ID=LumenX
LUMEN_FOLDER=.lumenx
LUMEN_VER=v1.4.0
LUMEN_REPO=https://github.com/cryptonetD/lumenx.git
LUMEN_GENESIS=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/mainnet/lumenx/genesis.json
LUMEN_ADDRBOOK=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/mainnet/lumenx/addrbook.json
LUMEN_DENOM=ulumen
LUMEN_PORT=26

echo "export LUMEN_WALLET=${LUMEN_WALLET}" >> $HOME/.bash_profile
echo "export LUMEN=${LUMEN}" >> $HOME/.bash_profile
echo "export LUMEN_ID=${LUMEN_ID}" >> $HOME/.bash_profile
echo "export LUMEN_FOLDER=${LUMEN_FOLDER}" >> $HOME/.bash_profile
echo "export LUMEN_VER=${LUMEN_VER}" >> $HOME/.bash_profile
echo "export LUMEN_REPO=${LUMEN_REPO}" >> $HOME/.bash_profile
echo "export LUMEN_GENESIS=${LUMEN_GENESIS}" >> $HOME/.bash_profile
echo "export LUMEN_ADDRBOOK=${LUMEN_ADDRBOOK}" >> $HOME/.bash_profile
echo "export LUMEN_DENOM=${LUMEN_DENOM}" >> $HOME/.bash_profile
echo "export LUMEN_PORT=${LUMEN_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $LUMEN_NODENAME ]; then
	read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " LUMEN_NODENAME
	echo 'export LUMEN_NODENAME='$LUMEN_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$LUMEN_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$LUMEN_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$LUMEN_PORT\e[0m"
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

# Get mainnet version of lumenx
cd $HOME
rm -rf lumenx
git clone $LUMEN_REPO
cd lumenx
git checkout $LUMEN_VER
make install
sudo mv $HOME/go/bin/$LUMEN /usr/bin/

# Init generation
$LUMEN config chain-id $LUMEN_ID
$LUMEN config keyring-backend file
$LUMEN config node tcp://localhost:${LUMEN_PORT}657
$LUMEN init $LUMEN_NODENAME --chain-id $LUMEN_ID

# Set peers and seeds
PEERS="a81c30cb077e33192c68253aa563b3cb6c27f066@peers-lumenx.sxlzptprjkt.xyz:26656"
SEEDS="ff14d88ffa802336e37632f4deac3eac638a4e95@seeds-lumenx.sxlzptprjkt.xyz:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$LUMEN_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$LUMEN_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $LUMEN_GENESIS > $HOME/$LUMEN_FOLDER/config/genesis.json
curl -Ls $LUMEN_ADDRBOOK > $HOME/$LUMEN_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${LUMEN_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${LUMEN_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${LUMEN_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${LUMEN_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${LUMEN_PORT}660\"%" $HOME/$LUMEN_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${LUMEN_PORT}317\"%; s%^address = \":8080\"%address = \":${LUMEN_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${LUMEN_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${LUMEN_PORT}091\"%" $HOME/$LUMEN_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$LUMEN_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$LUMEN_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$LUMEN_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$LUMEN_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$LUMEN_DENOM\"/" $HOME/$LUMEN_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$LUMEN_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$LUMEN_FOLDER/config/app.toml
$LUMEN tendermint unsafe-reset-all --home $HOME/$LUMEN_FOLDER
curl -L https://snap.nodexcapital.com/lumenx/lumenx-latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/$LUMEN_FOLDER

# Create Service
sudo tee /etc/systemd/system/$LUMEN.service > /dev/null <<EOF
[Unit]
Description=$LUMEN
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $LUMEN) start --home $HOME/$LUMEN_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $LUMEN
sudo systemctl start $LUMEN

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $LUMEN -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${LUMEN_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
