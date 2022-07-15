# install interchain-security

rm -rf ~/.interchain-security*
rm -rf $GOPATH/bin/interchain-security-*

echo "install interchain-security"
git clone https://github.com/bitdao-io/interchain-security.git
cd interchain-security 
make install
cd ..
rm -rf interchain-security 

echo "install rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "install ibc relayer "
cargo install ibc-relayer-cli --bin hermes --locked
