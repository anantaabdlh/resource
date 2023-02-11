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
echo "Auto Installer osmosis-1 {cosmovisor} mainnet For OSMOSIS v14.0.0";
echo -e "\e[0m"
sleep 1

# Variable
OSMO_WALLET=wallet
OSMO=osmosisd
BINARY=cosmovisor
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
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
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
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$OSMO_FOLDER/$BINARY/genesis/bin
mv build/$OSMO $HOME/$OSMO_FOLDER/$BINARY/genesis/bin/
rm -rf build

# Create application symlinks
ln -s $HOME/$OSMO_FOLDER/$BINARY/genesis $HOME/$OSMO_FOLDER/$BINARY/current
sudo ln -s $HOME/$OSMO_FOLDER/$BINARY/current/bin/$OSMO /usr/bin/$OSMO

# Create service osmosis
sudo tee /etc/systemd/system/$OSMO.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BINARY) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$OSMO_FOLDER"
Environment="DAEMON_NAME=$OSMO"
Environment="UNSAFE_SKIP_BACKUP=true"

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
PEERS=b63e1e588e8feb7e4a4adf0f2542d755e606d3f1@5.9.105.113:26656,8f67a2fcdd7ade970b1983bf1697111d35dfdd6f@52.79.199.137:26656,00c328a33578466c711874ec5ee7ada75951f99a@35.82.201.64:26656,cfb6f2d686014135d4a6034aa6645abd0020cac6@52.79.88.57:26656,8d9967d5f865c68f6fe2630c0f725b0363554e77@134.255.252.173:26656,785bc83577e3980545bac051de8f57a9fd82695f@194.233.164.146:26656,778fdedf6effe996f039f22901a3360bc838b52e@161.97.187.189:36657,64d36f3a186a113c02db0cf7c588c7c85d946b5b@209.97.132.170:26656,4d9ac3510d9f5cfc975a28eb2a7b8da866f7bc47@37.187.38.191:26656,2115945f074ddb038de5d835e287fa03e32f0628@95.217.43.85:26656,bf2c480eff178d2647ba1adfeee8ced568fe752c@91.65.128.44:26656,2f9c16151400d8516b0f58c030b3595be20b804c@37.120.245.167:26656,bada684070727cb3dda430bcc79b329e93399665@173.212.240.91:26656,3fea02d121cb24503d5fbc53216a527257a9ab55@143.198.145.208:26656,7de029fa5e9c1f39557c0e3523c1ae0b07c58be0@78.141.219.223:26656,7024d1ca024d5e33e7dc1dcb5ed08349768220b9@134.122.42.20:26656,d326ad6dffa7763853982f334022944259b4e7f4@143.110.212.33:26656,e7916387e05acd53d1b8c0f842c13def365c7bb6@176.9.64.212:26666,55eea69c21b46000c1594d8b4a448563b075d9e3@34.107.19.235:26656,9faf468b90a3b2b85ffd88645a15b3715f68bb0b@195.201.122.100:26656,ffc82412c0261a94df122b9cc0ce1de81da5246b@15.222.240.16:26656,5b90a530464885fd28c31f698c81694d0b4a1982@35.183.238.70:26656,7b6689cb18d625bbc069aa99d9d5521293db442c@51.158.97.192:26656,fda06dcebe2acd17857a6c9e9a7b365da3771ceb@52.206.252.176:26656,8d9fd90a009e4b6e9572bf9a84b532a366790a1d@193.26.156.221:26656,44a760a66071dae257c5c044be604219bfc3510c@49.12.35.177:36656,ebc272824924ea1a27ea3183dd0b9ba713494f83@osmosis.mainnet.peer.autostake.net:26716
SEEDS=83adaa38d1c15450056050fd4c9763fcc7e02e2c@ec2-44-234-84-104.us-west-2.compute.amazonaws.com:26656,23142ab5d94ad7fa3433a889dcd3c6bb6d5f247d@95.217.193.163:26656,f82d1a360dc92d4e74fdc2c8e32f4239e59aebdf@95.217.121.243:26656,e437756a853061cc6f1639c2ac997d9f7e84be67@144.76.183.180:26656,f515a8599b40f0e84dfad935ba414674ab11a668@osmosis.blockpane.com:26656,7c66126b64cd66bafd9ccfc721f068df451d31a3@osmosis-seed.sunshinevalidation.io:9393,ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:12556,20e1000e88125698264454a884812746c2eb4807@seeds.lavenderfive.com:12556,ebc272824924ea1a27ea3183dd0b9ba713494f83@osmosis.mainnet.seed.autostake.net:26716,3cc024d1c760c9cd96e6413abaf3b36a8bdca58e@seeds.goldenratiostaking.net:1630,bd7064a50f5843e2c84c71c4dc18ac07424bdcc1@seeds.whispernode.com:12556,e1b058e5cfa2b836ddaa496b10911da62dcf182e@osmosis-seed-1.allnodes.me:26656,e726816f42831689eab9378d5d577f1d06d25716@osmosis-seed-2.allnodes.me:26656
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
[[ -f $HOME/$OSMO_FOLDER/data/upgrade-info.json ]] && cp $HOME/$OSMO_FOLDER/data/upgrade-info.json $HOME/$OSMO_FOLDER/cosmovisor/genesis/upgrade-info.json

# Start Service
sudo systemctl start $OSMO

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[31msystemctl status $OSMO\e[0m"
echo -e "CHECK RUNNING LOGS  : \e[1m\e[31mjournalctl -fu $OSMO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS  : \e[1m\e[31mcurl -s localhost:${OSMO_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
