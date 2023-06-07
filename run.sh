#!/bin/bash

MY_HOME="/home/dima"
SYSTEM_CONTRACTS_PATH=$(realpath ${MY_HOME}/work/eos-system-contracts)
echo "system contracts path: $SYSTEM_CONTRACTS_PATH"
EVM_CONTRACT_PATH=$(realpath ${MY_HOME}/work/eos-evm)
echo "evm project path: $EVM_CONTRACT_PATH"

NUMBER_OF_KEYS=2

ETH_PRIV_KEY="a3f1b69da92a0233ce29485d3049a4ace39e8d384bbc2557e3fc60940ce4e954"
ETH_PUB_KEY="0x2787b98fc4e731d0456b3941f0b3fe2e01439961"
ETH_STORAGE_CONTRACT="608060405234801561001057600080fd5b50610150806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c80632e64cec11461003b5780636057361d14610059575b600080fd5b610043610075565b60405161005091906100d9565b60405180910390f35b610073600480360381019061006e919061009d565b61007e565b005b60008054905090565b8060008190555050565b60008135905061009781610103565b92915050565b6000602082840312156100b3576100b26100fe565b5b60006100c184828501610088565b91505092915050565b6100d3816100f4565b82525050565b60006020820190506100ee60008301846100ca565b92915050565b6000819050919050565b600080fd5b61010c816100f4565b811461011757600080fd5b5056fea26469706673582212209a159a4f3847890f10bfb87871a61eba91c5dbf5ee3cf6398207e292eee22a1664736f6c63430008070033"
# "608060405234801561001057600080fd5b50610150806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c80632e64cec11461003b5780636057361d14610059575b600080fd5b610043610075565b60405161005091906100a1565b60405180910390f35b610073600480360381019061006e91906100ed565b61007e565b005b60008054905090565b8060008190555050565b6000819050919050565b61009b81610088565b82525050565b60006020820190506100b66000830184610092565b92915050565b600080fd5b6100ca81610088565b81146100d557600080fd5b50565b6000813590506100e7816100c1565b92915050565b600060208284031215610103576101026100bc565b5b6000610111848285016100d8565b9150509291505056fea2646970667358221220322c78243e61b783558509c9cc22cb8493dde6925aa5e89a08cdf6e22f279ef164736f6c63430008120033"
                      
#1bln
ISSUE_AMT=1000000000

function get_priv_key {
    cat $1 | sed -n -e 's/Private key: //p'
}

function get_pub_key {
    cat $1 | sed -n -e 's/Public key: //p'
}

function strip_hex {
    echo "$1" | sed -n -e 's/^0x//p'
}

function get_signed_eth_trx {
    OUTPUT=$(python3 sign_ethraw.py "$1" "$2" "$3" "$4" "$5" "$6")
    echo "$OUTPUT" | sed -n -e 's/Eth signed raw transaction is //p'
}

function cleanup {
    pkill nodeos
    rm -rf ./data-dir/blocks
    rm -rf ./data-dir/protocol_features
    rm -rf ./data-dir/snapshots
    rm -rf ./data-dir/state
    rm -rf ./data-dir/state-history
    rm -rf ./keys/*
    rm -rf ./chain-data
    rm -rf ./eth-genesis.json

    pkill keosd
    rm -rf ${MY_HOME}/eosio-wallet/evm-test-wallet*
}
cleanup

trap "cleanup" EXIT

mkdir -p ./keys

cleos wallet create -n evm-test-wallet -f ./keys/evm-test-wallet.pswd
WALLET_PASSWORD=$(cat ./keys/evm-test-wallet.pswd)
cleos wallet open -n evm-test-wallet
cleos wallet unlock -n evm-test-wallet --password $WALLET_PASSWORD

#eosio private key
cleos wallet import -n evm-test-wallet --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
cleos wallet import -n evm-test-wallet --private-key 5JURSKS1BrJ1TagNBw1uVSzTQL2m9eHGkjknWeZkjSt33Awtior

cleos create key -f ./keys/eosio.bpay.keys
cleos wallet import -n evm-test-wallet --private-key $(get_priv_key ./keys/eosio.bpay.keys)
cleos create key -f ./keys/eosio.msig.keys
cleos wallet import -n evm-test-wallet --private-key $(get_priv_key ./keys/eosio.msig.keys)
cleos create key -f ./keys/eosio.names.keys
cleos wallet import -n evm-test-wallet --private-key $(get_priv_key ./keys/eosio.names.keys)
cleos create key -f ./keys/eosio.ram.keys
cleos wallet import -n evm-test-wallet --private-key $(get_priv_key ./keys/eosio.ram.keys)
cleos create key -f ./keys/eosio.ramfee.keys
cleos wallet import -n evm-test-wallet --private-key $(get_priv_key ./keys/eosio.ramfee.keys)
cleos create key -f ./keys/eosio.saving.keys
cleos wallet import -n evm-test-wallet --private-key $(get_priv_key ./keys/eosio.saving.keys)
cleos create key -f ./keys/eosio.stake.keys
cleos wallet import -n evm-test-wallet --private-key $(get_priv_key ./keys/eosio.stake.keys)
cleos create key -f ./keys/eosio.token.keys
cleos wallet import -n evm-test-wallet --private-key $(get_priv_key ./keys/eosio.token.keys)
cleos create key -f ./keys/eosio.vpay.keys
cleos wallet import -n evm-test-wallet --private-key $(get_priv_key ./keys/eosio.vpay.keys)
cleos create key -f ./keys/eosio.rex.keys
cleos wallet import -n evm-test-wallet --private-key $(get_priv_key ./keys/eosio.rex.keys)

declare -a PRIV_KEYS=()
declare -a PUB_KEYS=()

for i in $(seq 1 $NUMBER_OF_KEYS)
do
   echo "creating keys number $i"
   cleos create key -f "./keys/key${i}.keys"
   PRIV_KEYS[$i]=$(get_priv_key ./keys/key${i}.keys)
   PUB_KEYS[$i]=$(get_pub_key ./keys/key${i}.keys)
   cleos wallet import -n evm-test-wallet --private-key ${PRIV_KEYS[$i]}
done

nodeos --data-dir=./data-dir  --config-dir=./data-dir --genesis-json=./data-dir/genesis.json --disable-replay-opts --contracts-console --delete-all-blocks > node.log 2>&1 &

sleep 0.5

cleos get info | jq

curl --data-binary '{"protocol_features_to_activate":["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}' http://127.0.0.1:8888/v1/producer/schedule_protocol_feature_activations
echo ""

sleep 0.5

cleos set code eosio "${SYSTEM_CONTRACTS_PATH}/build/contracts/eosio.boot/eosio.boot.wasm"
cleos set abi eosio  "${SYSTEM_CONTRACTS_PATH}/build/contracts/eosio.boot/eosio.boot.abi"

cleos push action eosio activate '["f0af56d2c5a48d60a4a5b5c903edfb7db3a736a94ed589d0b797df33ff9d3e1d"]' -p eosio 
cleos push action eosio activate '["e0fb64b1085cc5538970158d05a009c24e276fb94e1a0bf6a528b48fbc4ff526"]' -p eosio
cleos push action eosio activate '["d528b9f6e9693f45ed277af93474fd473ce7d831dae2180cca35d907bd10cb40"]' -p eosio
cleos push action eosio activate '["c3a6138c5061cf291310887c0b5c71fcaffeab90d5deb50d3b9e687cead45071"]' -p eosio 
cleos push action eosio activate '["bcd2a26394b36614fd4894241d3c451ab0f6fd110958c3423073621a70826e99"]' -p eosio
cleos push action eosio activate '["ad9e3d8f650687709fd68f4b90b41f7d825a365b02c23a636cef88ac2ac00c43"]' -p eosio
cleos push action eosio activate '["8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405"]' -p eosio 
cleos push action eosio activate '["6bcb40a24e49c26d0a60513b6aeb8551d264e4717f306b81a37a5afb3b47cedc"]' -p eosio
cleos push action eosio activate '["68dcaa34c0517d19666e6b33add67351d8c5f69e999ca1e37931bc410a297428"]' -p eosio
cleos push action eosio activate '["5443fcf88330c586bc0e5f3dee10e7f63c76c00249c87fe4fbf7f38c082006b4"]' -p eosio
cleos push action eosio activate '["4fca8bd82bbd181e714e283f83e1b45d95ca5af40fb89ad3977b653c448f78c2"]' -p eosio
cleos push action eosio activate '["ef43112c6543b88db2283a2e077278c315ae2c84719a8b25f25cc88565fbea99"]' -p eosio
cleos push action eosio activate '["4a90c00d55454dc5b059055ca213579c6ea856967712a56017487886a4d4cc0f"]' -p eosio 
cleos push action eosio activate '["35c2186cc36f7bb4aeaf4487b36e57039ccf45a9136aa856a5d569ecca55ef2b"]' -p eosio
cleos push action eosio activate '["299dcb6af692324b899b39f16d5a530a33062804e41f09dc97e9f156b4476707"]' -p eosio
cleos push action eosio activate '["2652f5f96006294109b3dd0bbde63693f55324af452b799ee137a81a905eed25"]' -p eosio
cleos push action eosio activate '["1a99a59d87e06e09ec5b028a9cbb7749b4a5ad8819004365d02dc4379a8b7241"]' -p eosio

sleep 0.5

echo "creating system accounts..."
cleos create account eosio eosio.msig $(get_pub_key ./keys/eosio.msig.keys)
cleos create account eosio eosio.token $(get_pub_key ./keys/eosio.token.keys)
cleos create account eosio eosio.rex $(get_pub_key ./keys/eosio.rex.keys)
cleos create account eosio eosio.ram $(get_pub_key ./keys/eosio.ram.keys)
cleos create account eosio eosio.ramfee $(get_pub_key ./keys/eosio.ramfee.keys)
cleos create account eosio eosio.stake $(get_pub_key ./keys/eosio.stake.keys)
cleos create account eosio eosio.names $(get_pub_key ./keys/eosio.names.keys)
cleos create account eosio eosio.saving $(get_pub_key ./keys/eosio.saving.keys)
cleos create account eosio eosio.vpay $(get_pub_key ./keys/eosio.vpay.keys)

echo "creating evm account..."
cleos create account eosio evmevmevmevm ${PUB_KEYS[1]} ${PUB_KEYS[1]}
cleos set account permission evmevmevmevm active --add-code
cleos create account eosio a123 ${PUB_KEYS[2]} ${PUB_KEYS[2]}

cleos set contract eosio        "${SYSTEM_CONTRACTS_PATH}/build/contracts/eosio.system/"
cleos set contract eosio.token  "${SYSTEM_CONTRACTS_PATH}/build/contracts/eosio.token/"
cleos set contract eosio.msig   "${SYSTEM_CONTRACTS_PATH}/build/contracts/eosio.msig/"

sleep 0.5
cleos push action eosio.token create "[ \"eosio\", \"$(($ISSUE_AMT * 2)).0000 EOS\" ]" -p eosio.token
cleos push action eosio.token issue "[ \"eosio\", \"${ISSUE_AMT}.0000 EOS\", \"memo\" ]" -p eosio
echo "initializing system contract..."
cleos push action eosio init '["0", "4,EOS"]' -p eosio
cleos push action eosio setpriv '["eosio.msig", 1]' -p eosio
# cleos push action eosio wasmcfg '["high"]' -p eosio

sleep 0.5

echo "setting evm contract..."
cleos set code evmevmevmevm ${EVM_CONTRACT_PATH}/contract/build/evm_runtime/evm_runtime.wasm
cleos set abi evmevmevmevm  ${EVM_CONTRACT_PATH}/contract/build/evm_runtime/evm_runtime.abi
cleos get code evmevmevmevm

echo "init evm contract"
cleos push action evmevmevmevm init '{"chainid": 15555, "fee_params": {"gas_price": 150000000, "miner_cut": 10000, "ingress_bridge_fee": "0.0100 EOS"}}' -p evmevmevmevm

echo "transfer to eosio name contract"
cleos transfer eosio evmevmevmevm "1.0000 EOS" "evmevmevmevm"

echo "transfer to ethereum address"
cleos transfer eosio evmevmevmevm "1000000.0000 EOS" "$ETH_PUB_KEY"
echo "ethereum account balance" 
cleos get table evmevmevmevm evmevmevmevm account | jq

cleos push action evmevmevmevm open '{"owner":"a123"}' -p a123

cat ./template.env | sed -e "s/PRIV_KEY/${PRIV_KEYS[2]}/g" > ./tx_wrapper/.env

cd ./tx_wrapper
yarn
node index.js > nodejs.log 2>&1 &

sleep 0.5

echo "check gas price"
curl http://127.0.0.1:18888 -X POST -H "Accept: application/json" -H "Content-Type: application/json" --data '{"method":"eth_gasPrice","params":[],"id":1,"jsonrpc":"2.0"}' | jq

cd ..
SIGNED_TRX=$(get_signed_eth_trx $ETH_PUB_KEY $ETH_PUB_KEY 1 '' 0 $ETH_PRIV_KEY)
echo "send raw eth transaction $SIGNED_TRX"
curl http://127.0.0.1:18888 -X POST -H "Accept: application/json" -H "Content-Type: application/json" --data "{\"method\":\"eth_sendRawTransaction\",\"params\":[\"0x${SIGNED_TRX}\"],\"id\":1,\"jsonrpc\":\"2.0\"}" | jq

echo "check ethereum account balance"
cleos get table evmevmevmevm evmevmevmevm account | jq

SIGNED_TRX=$(get_signed_eth_trx $ETH_PUB_KEY '' 0 $ETH_STORAGE_CONTRACT 1 $ETH_PRIV_KEY)
echo "send raw eth contract transaction $SIGNED_TRX"
curl http://127.0.0.1:18888 -X POST -H "Accept: application/json" -H "Content-Type: application/json" --data "{\"method\":\"eth_sendRawTransaction\",\"params\":[\"0x${SIGNED_TRX}\"],\"id\":1,\"jsonrpc\":\"2.0\"}" | jq

echo "ethereum account balance" 
cleos get table evmevmevmevm evmevmevmevm account | jq

SIGNED_TRX=$(get_signed_eth_trx $ETH_PUB_KEY '0x51a97d86ae7c83f050056f03ebbe451001046764' 0 6057361d000000000000000000000000000000000000000000000000000000000000007b 2 $ETH_PRIV_KEY)
echo "send call store method transaction $SIGNED_TRX"
curl http://127.0.0.1:18888 -X POST -H "Accept: application/json" -H "Content-Type: application/json" --data "{\"method\":\"eth_sendRawTransaction\",\"params\":[\"0x${SIGNED_TRX}\"],\"id\":1,\"jsonrpc\":\"2.0\"}" | jq

sleep 0.5

echo "check ethereum account balance"
cleos get table evmevmevmevm evmevmevmevm account | jq

echo "check eth view"
cleos get table evmevmevmevm evmevmevmevm account --index 2 -L 51a97d86ae7c83f050056f03ebbe451001046764 --key-type sha256 | jq

echo "read storage data"
cleos get table evmevmevmevm 1 storage | jq

echo "eth config:"
cleos get table evmevmevmevm evmevmevmevm config | jq

echo "block 10:"
cleos get block 10 | jq

BLOCK_TIME=$(cleos get table evmevmevmevm evmevmevmevm config | jq .rows[0].genesis_time)
BLOCK_SECONDS=$(python3 -c "from datetime import datetime; print(hex(int((datetime.strptime($BLOCK_TIME,\"%Y-%m-%dT%H:%M:%S\")-datetime(1970,1,1)).total_seconds())))" )
BLOCK_HASH=$(cleos get block 10 | jq .id | tr -d '"')

mkdir -p ./chain-data
# 0x56e4adc95b92b720 is hex of raw evmevmevmevm name
cat ./eth-genesis-template.json | sed -e "s/BLOCK_ID/${BLOCK_HASH}/g" | sed -e "s/NONCE_VAL/0x56e4adc95b92b720/g" | sed -e "s/TIMESTAMP_VAL/${BLOCK_SECONDS}/g" > ./eth-genesis.json

echo "eth genesis.json:"
cat ./eth-genesis.json | jq

eos-evm-node --chain-data ./chain-data --plugin block_conversion_plugin --plugin blockchain_plugin --nocolor 1 --verbosity=5 --genesis-json=./eth-genesis.json > eth-node.log 2>&1 &
sleep 1
eos-evm-rpc --api-spec=eth,net --http-port=0.0.0.0:8881 --eos-evm-node=127.0.0.1:8080 --chaindata=./chain-data > eth-rpc.log 2>&1 &
sleep 1

echo "check eth rpc"
curl --location --request POST 'localhost:8881/' --header 'Content-Type: application/json' --data-raw '{"method":"eth_blockNumber","id":0}' | jq

echo "get block by id"
curl --location --request POST 'localhost:8881/' --header 'Content-Type: application/json' --data-raw '{"method":"eth_getBlockByNumber","params":["0x1",true],"id":0}' | jq


echo "get balance"
curl --location --request POST 'localhost:8881/' --header 'Content-Type: application/json' --data-raw "{\"method\":\"eth_getBalance\",\"params\":[\"${ETH_PUB_KEY}\",\"latest\"],\"id\":0}" | jq

echo "check storage via evm-rpc"
curl --location --request POST 'localhost:8881/' --header 'Content-Type: application/json' --data-raw "{\"method\":\"eth_call\",\"params\":[{\"from\":\"$(strip_hex ${ETH_PUB_KEY})\",\"to\":\"51a97d86ae7c83f050056f03ebbe451001046764\",\"data\":\"0x2e64cec1\"},\"latest\"],\"id\":11}" | jq

# cd ./proxy
# docker build -t evm-proxy .
# docker image ls
# EVM_PROXY_ID=$(docker image ls | grep evm-proxy | awk '{print $3}')
# echo "evm-proxy image id = ${EVM_PROXY_ID}"

# NGNIX_ERR_LOG=$(pwd)/error.log
# > ${NGNIX_ERR_LOG}
# NGNIX_WRITE_LOG=$(pwd)/write-post-data.log
# > ${NGNIX_WRITE_LOG}
# NGNIX_ACCESS_LOG=$(pwd)/access.log
# > ${NGNIX_ACCESS_LOG}
# echo "running docker with ngnix server"
# docker run --add-host=host.docker.internal:host-gateway -p 80:80 --network="host"                         \
#             -v ./nginx.conf:/etc/nginx.conf                                                                 \
#             -v ${NGNIX_ERR_LOG}:/var/log/nginx/error.log                                                    \
#             -v ${NGNIX_WRITE_LOG}:/var/log/nginx/error/write-post-data.log                                  \
#             -v ${NGNIX_ACCESS_LOG}:/var/log/nginx/access.log ${EVM_PROXY_ID} > ../docker-ngnix.log 2>&1 &
# sleep 3
# EVM_CONTAINER_ID=$(docker container ls | grep ${EVM_PROXY_ID} | awk '{print $1}')
# echo "evm container container id = ${EVM_CONTAINER_ID}"

# echo "testing ngnix server"
# curl http://127.0.0.1:80 -X POST -H "Accept: application/json" -H "Content-Type: application/json" --data '{"method":"eth_gasPrice","params":[],"id":1,"jsonrpc":"2.0"}'

pkill nodeos
pkill node
pkill eos-evm-node
pkill eos-evm-rpc
# docker container stop $EVM_CONTAINER_ID
# docker container rm $EVM_CONTAINER_ID
# docker rmi -f $EVM_PROXY_ID