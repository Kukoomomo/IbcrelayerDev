``interchain-security-pd -> spd``

``interchain-security-cd -> scd``

### node0 init 
```bash
spd init node0 --chain-id=provider-chain --home spdtestnet/node0

sed -i '.bak' '100s/"voting_period": "172800s"/"voting_period": "30s"/' spdtestnet/node0/config/genesis.json

spd keys add node0 -i --keyring-backend test --keyring-dir spdtestnet/keys
# cosmos1atfclhdvkjmvfqljjnug87xguayu270kjw0h92
# smoke evoke define explain decorate decorate garbage flower tumble lonely knee direct monster liquid fortune gallery chef excuse decorate edge apple jar tree sentence

spd add-genesis-account $(spd keys show node0 --address --keyring-backend test --keyring-dir spdtestnet/keys) 1500000000stake --home spdtestnet/node0
spd gentx node0 100000000stake --chain-id=provider-chain --home spdtestnet/node0 --keyring-backend test --keyring-dir spdtestnet/keys
spd collect-gentxs --home spdtestnet/node0 
spd keys list --keyring-backend test --keyring-dir spdtestnet/keys

spd start --home spdtestnet/node0
```

### node1 init 
```bash
spd init node1 --chain-id=provider-chain --home spdtestnet/node1
cp spdtestnet/node0/config/genesis.json spdtestnet/node1/config/genesis.json 

# config.toml
sed -i '.bak' '15s/proxy_app = "tcp:\/\/127.0.0.1:26658"/proxy_app = "tcp:\/\/127.0.0.1:36658"/' spdtestnet/node1/config/config.toml
sed -i '.bak' '91s/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/127.0.0.1:36657"/' spdtestnet/node1/config/config.toml
sed -i '.bak' '167s/pprof_laddr = "localhost:6060"/pprof_laddr = "localhost:6061"/' spdtestnet/node1/config/config.toml
sed -i '.bak' '175s/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:36656"/' spdtestnet/node1/config/config.toml
sed -i '.bak' '392s/prometheus_listen_addr = ":26660"/prometheus_listen_addr = ":36660"/' spdtestnet/node1/config/config.toml

# check this persistent_peers address with
 spd status

sed -i '.bak' '188s/persistent_peers = ""/persistent_peers = "e6408a178fbe219f7550e55caf231289ba02f10e@192.168.1.5:26656"/' spdtestnet/node1/config/config.toml

# app.toml
sed -i '.bak' '114s/address = "tcp:\/\/0.0.0.0:1317"/address = "tcp:\/\/0.0.0.0:2317"/' spdtestnet/node1/config/app.toml
sed -i '.bak' '141s/address = ":8080"/address = ":8081"/' spdtestnet/node1/config/app.toml
sed -i '.bak' '165s/address = "0.0.0.0:9090"/address = "0.0.0.0:9190"/' spdtestnet/node1/config/app.toml
sed -i '.bak' '178s/address = "0.0.0.0:9091"/address = "0.0.0.0:9191"/' spdtestnet/node1/config/app.toml

# start
spd start --home spdtestnet/node1

# send token to cosmos1ks3qkmz2f2ns2sccp568c8zwxpj2r57ktldq0j
spd keys add node1 -i --keyring-backend test --keyring-dir spdtestnet/keys
# winner pear help armor eight believe miracle vehicle warrior veteran forest consider balcony almost sadness measure doll display tag sad mean cat amateur unknown

spd tx bank send cosmos1atfclhdvkjmvfqljjnug87xguayu270kjw0h92 cosmos1ks3qkmz2f2ns2sccp568c8zwxpj2r57ktldq0j 100000000stake --chain-id provider-chain  --keyring-backend test --keyring-dir spdtestnet/keys --from node0 -y -b block

# create validator 
spd tx staking create-validator \
 --amount=10000000stake \
 --pubkey=$(spd tendermint show-validator --home spdtestnet/node1) \
 --moniker="node1" \
 --chain-id=provider-chain \
 --commission-rate="0.10" \
 --commission-max-rate="0.20" \
 --commission-max-change-rate="0.01" \
 --min-self-delegation="1000000" \
 --gas="200000" \
 --from=node1 --keyring-backend test --keyring-dir spdtestnet/keys \
 -y \
 -b block

# query validator
spd q staking validators
# check voting power
spd q tendermint-validator-set

# withdraw test
spd tx distribution withdraw-all-rewards --chain-id provider-chain  --keyring-backend test --keyring-dir spdtestnet/keys --from node0 -y -b block
spd tx distribution withdraw-all-rewards --chain-id provider-chain  --keyring-backend test --keyring-dir spdtestnet/keys --from node1 -y -b block

spd q bank balances cosmos1atfclhdvkjmvfqljjnug87xguayu270kjw0h92
spd q bank balances cosmos1ks3qkmz2f2ns2sccp568c8zwxpj2r57ktldq0j

spd tx gov submit-proposal create-consumer-chain proposal.json --chain-id provider-chain --from node0 --keyring-backend test --keyring-dir spdtestnet/keys -y -b block 

spd tx gov vote 1 yes --chain-id provider-chain --from node0 --keyring-backend test --keyring-dir spdtestnet/keys -y -b block 

spd q gov proposals

```

### consumer chain
```bash
scd init node0 --chain-id=consumer-chain --home scdtestnet/node0
scd init node1 --chain-id=consumer-chain --home scdtestnet/node1

cp -r spdtestnet/node0/config/priv_validator_key.json  scdtestnet/node0/config/priv_validator_key.json
cp -r spdtestnet/node1/config/priv_validator_key.json  scdtestnet/node1/config/priv_validator_key.json

spd q provider consumer-genesis consumer-chain -o json

# list todo 
# overwrite genesis line 51 
# genesis bank module 
# genesis account module 

# node0
# config.toml
sed -i '.bak' '15s/proxy_app = "tcp:\/\/127.0.0.1:26658"/proxy_app = "tcp:\/\/127.0.0.1:56658"/' scdtestnet/node0/config/config.toml
sed -i '.bak' '91s/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/127.0.0.1:56657"/' scdtestnet/node0/config/config.toml
sed -i '.bak' '167s/pprof_laddr = "localhost:6060"/pprof_laddr = "localhost:6063"/' scdtestnet/node0/config/config.toml
sed -i '.bak' '175s/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:56656"/' scdtestnet/node0/config/config.toml
sed -i '.bak' '392s/prometheus_listen_addr = ":26660"/prometheus_listen_addr = ":56660"/' scdtestnet/node0/config/config.toml

# app.toml
sed -i '.bak' '114s/address = "tcp:\/\/0.0.0.0:1317"/address = "tcp:\/\/0.0.0.0:4317"/' scdtestnet/node0/config/app.toml
sed -i '.bak' '141s/address = ":8080"/address = ":8083"/' scdtestnet/node0/config/app.toml
sed -i '.bak' '165s/address = "0.0.0.0:9090"/address = "0.0.0.0:9390"/' scdtestnet/node0/config/app.toml
sed -i '.bak' '178s/address = "0.0.0.0:9091"/address = "0.0.0.0:9391"/' scdtestnet/node0/config/app.toml

scd start --home scdtestnet/node0

# node1 
# config.toml
sed -i '.bak' '15s/proxy_app = "tcp:\/\/127.0.0.1:26658"/proxy_app = "tcp:\/\/127.0.0.1:46658"/' scdtestnet/node1/config/config.toml
sed -i '.bak' '91s/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/127.0.0.1:46657"/' scdtestnet/node1/config/config.toml
sed -i '.bak' '167s/pprof_laddr = "localhost:6060"/pprof_laddr = "localhost:6062"/' scdtestnet/node1/config/config.toml
sed -i '.bak' '175s/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:46656"/' scdtestnet/node1/config/config.toml
sed -i '.bak' '392s/prometheus_listen_addr = ":26660"/prometheus_listen_addr = ":46660"/' scdtestnet/node1/config/config.toml

# check this persistent_peers address with  scd status --node http://localhost:56657
sed -i '.bak' '188s/persistent_peers = ""/persistent_peers = "861b54b61b1a4cf4067d413f12d2b84c45045d3a@192.168.1.5:56656"/' scdtestnet/node1/config/config.toml

# app.toml
sed -i '.bak' '114s/address = "tcp:\/\/0.0.0.0:1317"/address = "tcp:\/\/0.0.0.0:3317"/' scdtestnet/node1/config/app.toml
sed -i '.bak' '141s/address = ":8080"/address = ":8082"/' scdtestnet/node1/config/app.toml
sed -i '.bak' '165s/address = "0.0.0.0:9090"/address = "0.0.0.0:9290"/' scdtestnet/node1/config/app.toml
sed -i '.bak' '178s/address = "0.0.0.0:9091"/address = "0.0.0.0:9291"/' scdtestnet/node1/config/app.toml

scd start --home scdtestnet/node1/

scd keys add node0 -i --keyring-backend test --keyring-dir scdtestnet/keys
# cosmos1atfclhdvkjmvfqljjnug87xguayu270kjw0h92
# smoke evoke define explain decorate decorate garbage flower tumble lonely knee direct monster liquid fortune gallery chef excuse decorate edge apple jar tree sentence

# q balances
scd q bank balances cosmos1atfclhdvkjmvfqljjnug87xguayu270kjw0h92 --node http://localhost:56657
```

### change voting power
```bash
spd tx staking delegate cosmosvaloper1ks3qkmz2f2ns2sccp568c8zwxpj2r57kwte4rp 1000000stake \
 --from node0 --keyring-backend test --keyring-dir spdtestnet/keys \
 -y -b block \
 --chain-id provider-chain

# check voting power
spd q tendermint-validator-set
```
