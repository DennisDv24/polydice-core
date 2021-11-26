from brownie import GameController, PolydiceGame
from brownie import config, network, accounts
from scripts.utils import (
    get_account,
    LOCAL_BLOCKCHAIN_ENVS,
    MAINNET_FORKS,
    get_contract_from_config
)
from scripts.deploy import deploy_game_controller
from web3 import Web3
import pytest



def test_deploy_GameController_with_PolydiceGame():

    if not in_local_network(network.show_active()):
        skip_unit_test()

    game_master_acc = get_account()
    
    game_controller = deploy_game_controller(game_master_acc, Web3.toWei(10, 'ether'))
    assert game_controller

def test_bank_fundings():

    if not in_local_network(network.show_active()):
        skip_unit_test()

    game_master_acc = get_account()
    
    initial_main_acc_funds = game_master_acc.balance()
    fund_sent_to_game_controller = Web3.toWei(10, 'ether')
    
    game_controller = deploy_game_controller(game_master_acc, fund_sent_to_game_controller)

    assert (
        game_master_acc.balance() == (
            initial_main_acc_funds - fund_sent_to_game_controller
        ) 
    )
    assert game_controller.bankFunds() == fund_sent_to_game_controller




def in_local_network(active_net):
    return (
        active_net in LOCAL_BLOCKCHAIN_ENVS or
        active_net in MAINNET_FORKS
    )

def skip_unit_test():
    print('Youre deploying to a real network, skipping unit test')
    pytest.skip()
