# install interchain-security

rm -rf ~/.interchain-security*
rm -rf $GOPATH/bin/interchain-security-*

git clone https://github.com/bitdao-io/interchain-security.git
cd interchain-security 
make install
cd ..
rm -rf interchain-security 