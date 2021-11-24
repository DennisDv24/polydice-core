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

def test_random_number():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVS:
        pytest.skip()
    
    main_acc = get_account()
    link_token = get_contract_from_config('link_token')
    
    # TODO generalize main contract deployment
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
    
    contract_link_amount_before = Web3.fromWei(
        link_token.balanceOf(polydice_game_contract), 'ether'
    )
    acc_bal_before_sending = Web3.fromWei(link_token.balanceOf(main_acc), 'ether')

    fund_tx = fund_with_link(polydice_game_contract)

    acc_bal_after_sending =  Web3.fromWei(link_token.balanceOf(main_acc), 'ether')
    link_fee = Web3.fromWei(config['networks'][network.show_active()]['fee'], 'ether')
    
    # NOTE tests could fail because of decimal operations

    assert acc_bal_before_sending == acc_bal_after_sending + link_fee

    contract_link_amout_after = Web3.fromWei(
        link_token.balanceOf(polydice_game_contract), 'ether'
    )
    assert contract_link_amout_after == contract_link_amount_before + link_fee

    

    

