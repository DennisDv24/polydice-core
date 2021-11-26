from brownie import accounts, network, config, Contract
from brownie import MockV3Aggregator, VRFCoordinatorMock, LinkToken, interface
from web3 import Web3

LOCAL_BLOCKCHAIN_ENVS = [
        'development',
        'ganache-local'
        ]

MAINNET_FORKS = ['kovan-fork', 'kovan-fork-dev', 'polygon-test-fork']

def get_account(index=None, id=None):
    if index:
        return accounts[index];
    if id:
        return accounts.load(id)
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVS
        or network.show_active() in MAINNET_FORKS
    ):
        return accounts[0]
    return accounts.add(config['wallets']['from_key'])


DECIMALS = 8
STARTING_PRICE = 200_000_000_000

def deploy_mocks():
    print(f'The active network is {network.show_active()}')
    print('Deploying Mocks...')
    
    account = get_account()

    MockV3Aggregator.deploy(
        DECIMALS,
        STARTING_PRICE,
        {'from': account}
    )
    link_token = LinkToken.deploy({'from': account})
    VRFCoordinatorMock.deploy(link_token.address, {'from': account})

    print('Mocks deployed!')

contract_to_mock = {
    'eth_usd_pricefeed': MockV3Aggregator,
    'vrf_coordinator': VRFCoordinatorMock,
    'link_token': LinkToken
}

def get_contract_from_config(contract_name):
    contract_type = contract_to_mock[contract_name]

    contract_address = config['networks'][network.show_active()][contract_name]
    contract = Contract.from_abi(
        contract_type._name, contract_address, contract_type.abi
    )

    return contract               

def fund_with_link(contract_address,
                   account=None,
                   link_token=None,
                   amount=None):
    if not account: account = get_account()
    if not link_token: link_token = get_contract_from_config('link_token')
    if not amount: amount = config['networks'][network.show_active()]['fee']
    print('\n-------')
    print('LINK TOKEN CONTRACT: ', link_token)
    print('ACCOUNG THAT WILL SEND 0.0001 LINK TO IT: ', account)
    print('LINK INTO THAT ACCOUNT: ', Web3.fromWei(link_token.balanceOf(account), 'ether'))
    print('-------\n')
    tx = link_token.transfer(contract_address, amount, {'from': account})

    #link_token_contract = interface.LinkTokenInterface(link_token.address)
    #tx = link_token_contract.transfer(contract_address, amount, {'from': account})
    tx.wait(1)
    print('\nFunded contract with LINK')
    print('-------------------------\n')
    return tx
    




