#!/bin/bash

PD_HOME=~/.interchain-security-p
CD_HOME=~/.interchain-security-c

rm -rf $PD_HOME
rm -rf $CD_HOME

rm -rf logs
if test $(pgrep -f 'interchain-security-pd start' | wc -l) -eq 0
then
    echo "no found"
else
    kill $(pgrep -f 'interchain-security-pd start')
    sleep 1
    if test $(pgrep -f 'interchain-security-pd start' | wc -l) -eq 0
    then 
        echo "success"
    else 
        echo "failed"
    fi
fi

if test $(pgrep -f 'interchain-security-cd start' | wc -l) -eq 0
then
    echo "no found"
else
    kill $(pgrep -f 'interchain-security-cd start')
    sleep 1
    if test $(pgrep -f 'interchain-security-cd start' | wc -l) -eq 0
    then 
        echo "success"
    else 
        echo "failed"
    fi
fi

if test $(pgrep -f 'hermes start' | wc -l) -eq 0
then
    echo "no found"
else
    kill $(pgrep -f 'hermes start')
    sleep 1
    if test $(pgrep -f 'hermes start' | wc -l) -eq 0
    then 
        echo "success"
    else 
        echo "failed"
    fi
fi

rm -rf ~/.hermes/keys/provider-chain
rm -rf ~/.hermes/keys/consumer-chain