bash ./clean.sh

PD_HOME=~/.interchain-security-p
PD_CHAIN_ID=provider-chain
CD_HOME=~/.interchain-security-c
CD_CHAIN_ID=consumer-chain

NODE0_MEM='flip celery sibling capital sheriff draw valve learn employ quantum neglect have vendor faculty drama extend venture bullet brown speak goddess wet suggest grid'
NODE1_MEM='vacant banner beauty glimpse film purity please enrich depth trip pride notable desert fatigue main cave game zero income confirm coin clever raccoon organ'
NODE0_ADDR=cosmos18vp7k4mdacjqm8vglrv7krj70uhcwk7hx9x4k2
NODE1_ADDR=cosmos1y0eqyw2czryedw00jpxpc6pcfnkcfktgpc5g67
NODE1_VAL_ADDR=cosmosvaloper1y0eqyw2czryedw00jpxpc6pcfnkcfktgyvqakd

SPD_IBC_MEM='smoke evoke define explain decorate decorate garbage flower tumble lonely knee direct monster liquid fortune gallery chef excuse decorate edge apple jar tree sentence'
SPD_IBC_ADDR=cosmos1atfclhdvkjmvfqljjnug87xguayu270kjw0h92
# cache logs
rm -rf logs
mkdir logs

# clear first
rm -rf $PD_HOME
# wait clean
sleep 3

interchain-security-pd init node0 --chain-id=$PD_CHAIN_ID --home $PD_HOME/node0
sed -i '.bak' '100s/"voting_period": "172800s"/"voting_period": "30s"/' $PD_HOME/node0/config/genesis.json
echo $NODE0_MEM | interchain-security-pd keys add node0 --recover --keyring-backend test --keyring-dir $PD_HOME/keys 

interchain-security-pd add-genesis-account $(interchain-security-pd keys show node0 --address --keyring-backend test --keyring-dir $PD_HOME/keys) 1500000000stake --home $PD_HOME/node0
interchain-security-pd gentx node0 100000000stake --chain-id=$PD_CHAIN_ID --home $PD_HOME/node0 --keyring-backend test --keyring-dir $PD_HOME/keys
interchain-security-pd collect-gentxs --home $PD_HOME/node0 
interchain-security-pd keys list --keyring-backend test --keyring-dir $PD_HOME/keys

nohup interchain-security-pd start --home $PD_HOME/node0  > ./logs/pdnode0.log 2>&1 & 
echo "start scp node0 success!"

interchain-security-pd init node1 --chain-id=$PD_CHAIN_ID --home $PD_HOME/node1
cp $PD_HOME/node0/config/genesis.json $PD_HOME/node1/config/genesis.json 

# config.toml
sed -i '.bak' '15s/proxy_app = "tcp:\/\/127.0.0.1:26658"/proxy_app = "tcp:\/\/127.0.0.1:36658"/' $PD_HOME/node1/config/config.toml
sed -i '.bak' '91s/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/127.0.0.1:36657"/' $PD_HOME/node1/config/config.toml
sed -i '.bak' '167s/pprof_laddr = "localhost:6060"/pprof_laddr = "localhost:6061"/' $PD_HOME/node1/config/config.toml
sed -i '.bak' '175s/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:36656"/' $PD_HOME/node1/config/config.toml
sed -i '.bak' '392s/prometheus_listen_addr = ":26660"/prometheus_listen_addr = ":36660"/' $PD_HOME/node1/config/config.toml

sleep 10
# check this persistent_peers address with
PEER=$(interchain-security-pd status --node http://localhost:26657 | jq '.NodeInfo.id'| sed 's/\"//g')@localhost:26656
sed -i '.bak' '188s/persistent_peers = ""/persistent_peers = "'$PEER'"/' $PD_HOME/node1/config/config.toml

# app.toml
sed -i '.bak' '114s/address = "tcp:\/\/0.0.0.0:1317"/address = "tcp:\/\/0.0.0.0:2317"/' $PD_HOME/node1/config/app.toml
sed -i '.bak' '141s/address = ":8080"/address = ":8081"/' $PD_HOME/node1/config/app.toml
sed -i '.bak' '165s/address = "0.0.0.0:9090"/address = "0.0.0.0:9190"/' $PD_HOME/node1/config/app.toml
sed -i '.bak' '178s/address = "0.0.0.0:9091"/address = "0.0.0.0:9191"/' $PD_HOME/node1/config/app.toml

nohup interchain-security-pd start --home $PD_HOME/node1  > ./logs/pdnode1.log 2>&1 & 
echo "start scp node1 success!"

# wait node0 start
sleep 10
interchain-security-pd tx bank send node0 $NODE1_ADDR 100000000stake --chain-id=$PD_CHAIN_ID --keyring-backend=test --keyring-dir=$PD_HOME/keys --from node0 -y -b block
echo $NODE1_MEM | interchain-security-pd keys add node1 --recover --keyring-backend test --keyring-dir $PD_HOME/keys 

interchain-security-pd tx staking create-validator \
 --amount=10000000stake \
 --pubkey=$(interchain-security-pd tendermint show-validator --home $PD_HOME/node1) \
 --moniker="node1" \
 --chain-id=$PD_CHAIN_ID \
 --commission-rate="0.10" \
 --commission-max-rate="0.20" \
 --commission-max-change-rate="0.01" \
 --min-self-delegation="1000000" \
 --gas="200000" \
 --from=node1 --keyring-backend test --keyring-dir $PD_HOME/keys \
 -y \
 -b block

interchain-security-pd q tendermint-validator-set

interchain-security-pd tx gov submit-proposal create-consumer-chain proposal.json --chain-id $PD_CHAIN_ID --from node0 --keyring-backend test --keyring-dir $PD_HOME/keys -y -b block 

interchain-security-pd tx gov vote 1 yes --chain-id $PD_CHAIN_ID --from node0 --keyring-backend test --keyring-dir $PD_HOME/keys -y -b block 

# wait proposal voting time 30s
sleep 30
interchain-security-pd q gov proposals

interchain-security-cd init node0 --chain-id=$CD_CHAIN_ID --home $CD_HOME/node0
interchain-security-cd init node1 --chain-id=$CD_CHAIN_ID --home $CD_HOME/node1

cp -r $PD_HOME/node0/config/priv_validator_key.json  $CD_HOME/node0/config/priv_validator_key.json
cp -r $PD_HOME/node1/config/priv_validator_key.json  $CD_HOME/node1/config/priv_validator_key.json

cat $CD_HOME/node0/config/genesis.json | jq --argjson ccv $(interchain-security-pd q provider consumer-genesis consumer-chain -o json) '.app_state.ccvconsumer|=$ccv' > $CD_HOME/node0/config/genesis.json

BANK=$(cat $PD_HOME/node0/config/genesis.json | jq '.app_state.bank.balances')
ACCOUNT=$(cat $PD_HOME/node0/config/genesis.json | jq '.app_state.auth.accounts')

CD_GENESIS=$(cat $CD_HOME/node0/config/genesis.json | jq --argjson bank "$BANK" '.app_state.bank.balances|=$bank') 
CD_GENESIS=$(echo $CD_GENESIS | jq --argjson account "$ACCOUNT" '.app_state.auth.accounts|=$account' )

echo $CD_GENESIS > $CD_HOME/node0/config/genesis.json 
cp $CD_HOME/node0/config/genesis.json $CD_HOME/node1/config/genesis.json

# node0
# config.toml
sed -i '.bak' '15s/proxy_app = "tcp:\/\/127.0.0.1:26658"/proxy_app = "tcp:\/\/127.0.0.1:46658"/' $CD_HOME/node0/config/config.toml
sed -i '.bak' '91s/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/127.0.0.1:46657"/' $CD_HOME/node0/config/config.toml
sed -i '.bak' '167s/pprof_laddr = "localhost:6060"/pprof_laddr = "localhost:6062"/' $CD_HOME/node0/config/config.toml
sed -i '.bak' '175s/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:46656"/' $CD_HOME/node0/config/config.toml
sed -i '.bak' '392s/prometheus_listen_addr = ":26660"/prometheus_listen_addr = ":46660"/' $CD_HOME/node0/config/config.toml

# app.toml
sed -i '.bak' '114s/address = "tcp:\/\/0.0.0.0:1317"/address = "tcp:\/\/0.0.0.0:3317"/' $CD_HOME/node0/config/app.toml
sed -i '.bak' '141s/address = ":8080"/address = ":8082"/' $CD_HOME/node0/config/app.toml
sed -i '.bak' '165s/address = "0.0.0.0:9090"/address = "0.0.0.0:9290"/' $CD_HOME/node0/config/app.toml
sed -i '.bak' '178s/address = "0.0.0.0:9091"/address = "0.0.0.0:9291"/' $CD_HOME/node0/config/app.toml

nohup interchain-security-cd start --home $CD_HOME/node0  > ./logs/cdnode0.log 2>&1 & 
echo "start scd node0 success!"

# node1
# config.toml
sed -i '.bak' '15s/proxy_app = "tcp:\/\/127.0.0.1:26658"/proxy_app = "tcp:\/\/127.0.0.1:56658"/' $CD_HOME/node1/config/config.toml
sed -i '.bak' '91s/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/127.0.0.1:56657"/' $CD_HOME/node1/config/config.toml
sed -i '.bak' '167s/pprof_laddr = "localhost:6060"/pprof_laddr = "localhost:6063"/' $CD_HOME/node1/config/config.toml
sed -i '.bak' '175s/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:56656"/' $CD_HOME/node1/config/config.toml
sed -i '.bak' '392s/prometheus_listen_addr = ":26660"/prometheus_listen_addr = ":56660"/' $CD_HOME/node1/config/config.toml

# check this persistent_peers address with
# need wait node0 start
sleep 10

PEER_ADDR=$(cat $PD_HOME/node0/config/genesis.json | jq '.app_state.genutil.gen_txs[] | .body.memo' | sed 's/\"//g')
PEER_ID=$(interchain-security-cd status --node http://localhost:46657 | jq '.NodeInfo.id'| sed 's/\"//g')@localhost:46656

sed -i '.bak' '188s/persistent_peers = ""/persistent_peers = "'$PEER_ID'"/' $CD_HOME/node1/config/config.toml

# app.toml
sed -i '.bak' '114s/address = "tcp:\/\/0.0.0.0:1317"/address = "tcp:\/\/0.0.0.0:4317"/' $CD_HOME/node1/config/app.toml
sed -i '.bak' '141s/address = ":8080"/address = ":8083"/' $CD_HOME/node1/config/app.toml
sed -i '.bak' '165s/address = "0.0.0.0:9090"/address = "0.0.0.0:9390"/' $CD_HOME/node1/config/app.toml
sed -i '.bak' '178s/address = "0.0.0.0:9091"/address = "0.0.0.0:9391"/' $CD_HOME/node1/config/app.toml

nohup interchain-security-cd start --home $CD_HOME/node1  > ./logs/cdnode1.log 2>&1 & 
echo "start scd node1 success!"

echo "IBC relayer !!!"
mkdir ~/.hermes
cp ./ibcRelayer/config.toml ~/.hermes/     

interchain-security-pd tx bank send node0 $SPD_IBC_ADDR 1000000stake --chain-id=$PD_CHAIN_ID --keyring-backend=test --keyring-dir=$PD_HOME/keys --from node0 -y -b block

echo $SPD_IBC_MEM | interchain-security-pd keys add spdIBC --recover --keyring-backend test --keyring-dir $PD_HOME/keys
echo $NODE0_MEM | interchain-security-cd keys add scdnode0 --recover --keyring-backend test --keyring-dir $CD_HOME/keys

interchain-security-pd keys list --keyring-backend test --keyring-dir $PD_HOME/keys
interchain-security-cd keys list --keyring-backend test --keyring-dir $CD_HOME/keys

hermes keys add $PD_CHAIN_ID -n spdIBC  -p "m/44'/118'/0'/0/0" -f ./ibcRelayer/spdIBC.json 
hermes keys add $CD_CHAIN_ID -n scdnode0  -p "m/44'/118'/0'/0/0" -f ./ibcRelayer/scdnode0.json

hermes keys list $PD_CHAIN_ID
hermes keys list $CD_CHAIN_ID

echo "create connection for client 07-tendermint-0"
sleep 5
hermes create connection --client-a 07-tendermint-0 --client-b 07-tendermint-0 $PD_CHAIN_ID

echo "create ccv channel"
sleep 5
hermes create channel --connection-a connection-0 --port-a consumer --port-b provider -o ordered -v 1 $CD_CHAIN_ID

echo "start ibcrelayer"
nohup hermes start  > ./logs/ibcRelayer.log 2>&1 & 

interchain-security-pd tx staking delegate $NODE1_VAL_ADDR 1000000stake \
 --from node0 --keyring-backend test --keyring-dir $PD_HOME/keys \
 -y -b block \
 --chain-id $PD_CHAIN_ID

interchain-security-pd q ibc channel channels 
interchain-security-cd q ibc channel channels --node http://localhost:56657

echo "deploy success"

# interchain-security-cd tx bank send scdnode0 cosmos1y0eqyw2czryedw00jpxpc6pcfnkcfktgpc5g67 100stake \
#     --from scdnode0  --keyring-backend test --keyring-dir $CD_HOME/keys \
#     --chain-id $CD_CHAIN_ID -b block -y \
#     --node http://localhost:56657

# interchain-security-pd tx slashing unjail \
#  --from node1 --keyring-backend test --keyring-dir $PD_HOME/keys \
#   --chain-id $PD_CHAIN_ID -b block -y 