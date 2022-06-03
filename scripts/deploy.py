
from unittest.mock import Mock
from brownie import accounts, config, network, ProvenFactory, NFTProject, MockNFT
from brownie.network import web3
from scripts.helpers import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS

from eip712.messages import EIP712Message, EIP712Type

import time

class TestSubType(EIP712Type):
    inner: "uint256"

class TestMessage(EIP712Message):
    _name_: "string" = "Brownie Test Message"
    outer: "uint256"
    sub: TestSubType

def deploy_proven_factory():

    # First setup the mock NFT
    nft_project_owner = get_account(id="nftProject")
    mock_nft = MockNFT.deploy("mock", "MOCK", {"from":nft_project_owner}, publish_source=config["networks"][network.show_active()].get("verify"))
    print(f"MockNFT deployed... by {nft_project_owner} at {mock_nft}")

    print(MockNFT.at(mock_nft).balanceOf(nft_project_owner))

    # Second setup the NFT holder
    #holder = get_account(index=1)
    holder = get_account(id="provenUser")
    mint_tx = mock_nft.purchase({"from":holder})
    mint_tx.wait(1)
    token_id = mint_tx.events["MockNFTMinted"]["tokenId"]
    print(f"holder: {holder} minted an NFT token_id: {token_id}")

    print(MockNFT.at(mock_nft).balanceOf(nft_project_owner))


    # Third setup the factory contract
    TheProven_owner = get_account(id="TheProven")
    proven_factory = ProvenFactory.deploy({"from":TheProven_owner}, publish_source=config["networks"][network.show_active()].get("verify"))
    print(f"ProvenFactory deployed... by {TheProven_owner}")

    # CREATE A PROJECT
    print("Add an NFT project to the mix")
    new_project_tx = proven_factory.createProject(mock_nft, {"from":nft_project_owner},)
    new_project_tx.wait(1)
    project_address = new_project_tx.events["OnProjectCreated"]["contact_address"]

    print(f"Project created: {project_address}")

    #msg = TestMessage(outer=1, sub=TestSubType(inner=2))
    #signed = holder.sign_message(msg)
    #print(f"holder: {holder}")

    #reg_tx = NFTProject.at(project_address).registerNFT(1, signed.messageHash.hex(), {"from":holder},)
    vault = "0x5d79D25da74eD5A871254944C96815597ffd50DB"
    reg_tx = NFTProject.at(project_address).registerNFT(1, vault, {"from":holder},)
    reg_tx.wait(1)

    registered_token = reg_tx.events["Register"]["token_id"]

    print(f"Token {registered_token} has been registered with Proven.")

    #
    # Transfer to vault
    #
    trans_tx = mock_nft.transferFrom(holder, vault, registered_token, {"from": holder})
    trans_tx.wait(1)

    print("Token transferred to vault")

    test_token = registered_token
    isHolder = NFTProject.at(project_address).validateHolderOfToken(test_token, {"from":holder})

    print(f"The holder is valid holder of token: {test_token} -- {isHolder}")

    # isRegistered
    print("CHECK REGISTRATION")
    isRegistered = NFTProject.at(project_address).isRegistered(holder, test_token)
    print(f"is registered: {isRegistered}")

    isRegistered = NFTProject.at(project_address).isRegistered(holder, 4)
    print(f"Wrong Token ID: {isRegistered}")

    isRegistered = NFTProject.at(project_address).isRegistered(nft_project_owner, 1)
    print(f"Wrong wallet: {isRegistered}")

    # External verification
    verifyer = get_account()
    isVerified = NFTProject.at(project_address).external_verify(holder, test_token)
    print(f"is verified from EXTERNAL: {isVerified}")


def main():
    deploy_proven_factory()