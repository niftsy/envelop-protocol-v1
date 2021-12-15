import pytest
import logging
from brownie import Wei, reverts, chain
from makeTestData import makeNFTForTest721, makeFromERC721ToERC721


LOGGER = logging.getLogger(__name__)
ORIGINAL_NFT_IDs = [10000,11111,22222]
zero_address = '0x0000000000000000000000000000000000000000'

def test_unwrap(accounts, erc721mock, wrapper, dai, weth, wnft721, niftsy20):
	#make test data
	makeNFTForTest721(accounts, erc721mock, ORIGINAL_NFT_IDs)

	#make wrap NFT 721
	wTokenId = makeFromERC721ToERC721(accounts, erc721mock, wrapper, dai, weth, wnft721, niftsy20, ORIGINAL_NFT_IDs[0], accounts[3])
	
	assert wnft721.ownerOf(wTokenId) == accounts[3]

	contract_eth_balance = wrapper.balance()
	before_dai_balance = wrapper.getERC20CollateralBalance(wnft721.address, wTokenId, dai.address)
	before_weth_balance = wrapper.getERC20CollateralBalance(wnft721.address, wTokenId, weth.address)
	before_eth_balance = wrapper.getERC20CollateralBalance(wnft721.address, wTokenId, zero_address)
	before_acc_balance = accounts[2].balance()



	wrapper.unWrap(3, wnft721.address, wTokenId, {"from": accounts[3]})
	
	#checks
	assert wrapper.balance() == 0
	assert accounts[2].balance() == before_acc_balance + contract_eth_balance
	assert dai.balanceOf(wrapper) == 0
	assert weth.balanceOf(wrapper) == 0
	assert dai.balanceOf(accounts[2]) == before_dai_balance
	assert weth.balanceOf(accounts[2]) == before_weth_balance

	assert erc721mock.ownerOf(ORIGINAL_NFT_IDs[0]) == accounts[2]
	assert wnft721.totalSupply() == 0