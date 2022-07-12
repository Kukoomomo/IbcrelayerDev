### send tokens 
```bash
spd tx bank send node0 cosmos18vp7k4mdacjqm8vglrv7krj70uhcwk7hx9x4k2 1000000stake \
 --chain-id provider-chain \
 --keyring-backend test --keyring-dir spdtestnet/keys \
 -y -b block \
 --from node0 \
--node http://localhost:26657 

scd tx bank send node0 cosmos1y0eqyw2czryedw00jpxpc6pcfnkcfktgpc5g67 100000stake \
 --chain-id consumer-chain \
 --from node0 \
 --keyring-backend test --keyring-dir scdtestnet/keys \
 -y -b block \
 --node http://localhost:56657

spd q bank balances cosmos18vp7k4mdacjqm8vglrv7krj70uhcwk7hx9x4k2 
scd q bank balances cosmos1y0eqyw2czryedw00jpxpc6pcfnkcfktgpc5g67 --node http://localhost:56657
```

### create channel & start 
```bash
spd keys add spdIBC -i --output json --keyring-backend test --keyring-dir ibcRelayer/spdtestnet/keys > ibcRelayer/spdIBC.json
# flip celery sibling capital sheriff draw valve learn employ quantum neglect have vendor faculty drama extend venture bullet brown speak goddess wet suggest grid
# cosmos18vp7k4mdacjqm8vglrv7krj70uhcwk7hx9x4k2
scd keys add scdIBC -i --output json --keyring-backend test --keyring-dir ibcRelayer/scdtestnet/keys > ibcRelayer/scdIBC.json
# vacant banner beauty glimpse film purity please enrich depth trip pride notable desert fatigue main cave game zero income confirm coin clever raccoon organ
# cosmos1y0eqyw2czryedw00jpxpc6pcfnkcfktgpc5g67

scd keys add node0 -i --output json --keyring-backend test --keyring-dir ibcRelayer/scdtestnet/keys > ibcRelayer/node0.json
# smoke evoke define explain decorate decorate garbage flower tumble lonely knee direct monster liquid fortune gallery chef excuse decorate edge apple jar tree sentence
# cosmos1atfclhdvkjmvfqljjnug87xguayu270kjw0h92

spd keys list --keyring-backend test --keyring-dir ibcRelayer/spdtestnet/keys
scd keys list --keyring-backend test --keyring-dir ibcRelayer/scdtestnet/keys

cp ./ibcRelayer/config.toml ~/.hermes/

rm -rf ~/.hermes/keys/provider-chain
rm -rf ~/.hermes/keys/consumer-chain

hermes keys add provider-chain -n spdIBC  -p "m/44'/118'/0'/0/0" -f ./ibcRelayer/spdIBC.json 
hermes keys add consumer-chain -n scdIBC  -p "m/44'/118'/0'/0/0" -f ./ibcRelayer/scdIBC.json
hermes keys add consumer-chain -n node0  -p "m/44'/118'/0'/0/0" -f ./ibcRelayer/node0.json

hermes keys list provider-chain 
hermes keys list consumer-chain

# create connection for client 07-tendermint-0 
hermes create connection --client-a 07-tendermint-0 --client-b 07-tendermint-0 provider-chain 

# create ccv channel
hermes create channel --connection-a connection-0 --port-a provider  --port-b consumer -o ordered -v 1 consumer-chain

# create transfer channel
hermes create channel provider-chain consumer-chain --port-a transfer --port-b transfer -o unordered

hermes start 
```
