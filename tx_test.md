## env
```bash
# need export first
PD_HOME=~/.interchain-security-p
PD_CHAIN_ID=provider-chain
CD_HOME=~/.interchain-security-c
CD_CHAIN_ID=consumer-chain

```

## tx command 
```bash
interchain-security-pd tx ibc-transfer transfer transfer channel-1 cosmos1y0eqyw2czryedw00jpxpc6pcfnkcfktgpc5g67 1stake \
 --from node0  --keyring-backend test --keyring-dir $PD_HOME/keys \
 --chain-id $PD_CHAIN_ID -b block -y 

interchain-security-cd q bank balances cosmos1y0eqyw2czryedw00jpxpc6pcfnkcfktgpc5g67 --node http://localhost:56657

interchain-security-cd tx ibc-transfer transfer transfer channel-1 cosmos1y0eqyw2czryedw00jpxpc6pcfnkcfktgpc5g67 1stake \
 --from scdnode0  --keyring-backend test --keyring-dir $CD_HOME/keys \
 --chain-id $CD_CHAIN_ID -b block -y \
 --node http://localhost:56657

interchain-security-pd q bank balances cosmos1y0eqyw2czryedw00jpxpc6pcfnkcfktgpc5g67

interchain-security-cd tx bank send scdnode0 cosmos1y0eqyw2czryedw00jpxpc6pcfnkcfktgpc5g67 100stake \
    --from scdnode0  --keyring-backend test --keyring-dir $CD_HOME/keys \
    --chain-id $CD_CHAIN_ID -b block -y \
    --node http://localhost:56657

interchain-security-pd tx slashing unjail \
 --from node1 --keyring-backend test --keyring-dir $PD_HOME/keys \
  --chain-id $PD_CHAIN_ID -b block -y 
```