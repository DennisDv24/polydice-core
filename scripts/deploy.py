from brownie import GameController
from brownie import config, network, accounts
from scripts.utils import (
    get_account,
    LOCAL_BLOCKCHAIN_ENVS,
    get_contract_from_config,
    fund_with_link
)
from web3 import Web3
import pytest
import time

def deploy_game_controller(acc = None, funds = Web3.toWei(10, 'ether')):
    
    if not acc: acc = get_account()
    
    active_net = network.show_active()
    game_controller = GameController.deploy(
        get_contract_from_config('vrf_coordinator'),
        get_contract_from_config('link_token'),
        config['networks'][active_net]['fee'],
        config['networks'][active_net]['keyhash'],
        {'from': acc, 'value': funds}
    )
    
    return game_controller


def main():
    #test_random_number()
    deploy_testnet()



