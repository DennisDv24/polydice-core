from brownie import PolydiceGameV2
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

def test_random_number():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVS:
        pytest.skip()
    
    main_acc = get_account()
    link_token = get_contract_from_config('link_token')

    polydice_game_contract = PolydiceGameV2.deploy(
        get_contract_from_config('vrf_coordinator').address,
        get_contract_from_config('link_token').address,
        config['networks'][network.show_active()]['fee'],
        config['networks'][network.show_active()]['keyhash'],
        {'from': main_acc},
        publish_source=config['networks'][network.show_active()].get('verify', False)
    )
    print('PolydiceGameV2 main contract deployed')
    print('-------------------------------------')
    
    bal_before_sending = Web3.fromWei(link_token.balanceOf(main_acc), 'ether')

    fund_tx = fund_with_link(polydice_game_contract)

    print("LINK AMOUNT SENT TO CONTRACT:")
    print(bal_before_sending - Web3.fromWei(link_token.balanceOf(main_acc), 'ether'))
    print("LINK AMOUNT INTO THE CONTRACT:")
    print(Web3.fromWei(link_token.balanceOf(polydice_game_contract), 'ether'))

    tx = polydice_game_contract.doDiceRollAndFulfillBets({'from': main_acc})
    print("WAITING FOR CHAINLINK RESPONSE...")
    tx.wait(1)
    print('CONTRACT VARS: KEYHASH: ')
    print(polydice_game_contract.keyhash())
    print('CONTRACT VARS: FEE: ')
    print(polydice_game_contract.fee())

    time.sleep(60)
    print("CHAINLINK RANDOM NUMBER:")
    print(polydice_game_contract.lastRandom())

    print('CONTRACT VARS: KEYHASH: ')
    print(polydice_game_contract.keyhash())
    print('CONTRACT VARS: FEE: ')
    print(polydice_game_contract.fee())

def deploy_testnet():
    main_acc = get_account()
    link_token = get_contract_from_config('link_token')
    polydice_game_contract = PolydiceGameV2.deploy(
        get_contract_from_config('vrf_coordinator').address,
        link_token,
        config['networks'][network.show_active()]['fee'],
        config['networks'][network.show_active()]['keyhash'],
        {'from': main_acc},
        publish_source=config['networks'][network.show_active()].get('verify', False)
    )
    link_token.transfer(
        polydice_game_contract, 
        Web3.toWei(0.001, 'ether'),
        {'from': main_acc}
    )
    tx = polydice_game_contract.doDiceRollAndFulfillBets({'from': main_acc})

    tx.wait(1)
    time.sleep(60)
    print('FINAL RANDOM NUMBER:')
    print(polydice_game_contract.lastRandom())


def main():
    #test_random_number()
    #deploy_testnet()



