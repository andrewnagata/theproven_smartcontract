// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTProject {

    struct Holder {
        address vault;
        uint256[] token_ids;
    }

    address private factory;
    address public project_address;

    mapping(address => Holder) public holders;

    event Register(uint256 token_id, address wallet, address project);

    constructor (address _factory, address _project_address) {

        factory = _factory;
        project_address = _project_address;
    }

    function registerNFT(uint256 token_id, address vault) public {

        require(IERC721(project_address).ownerOf(token_id) == msg.sender, "Not the owner of the NFT");

        Holder storage holder = holders[msg.sender];

        if(holder.vault == address(0)) {
            holders[msg.sender] = Holder(vault, new uint256[](0));   
        }

        holders[msg.sender].token_ids.push(token_id);
       
        emit Register(token_id, msg.sender, project_address);
    }

    function validateHolderOfToken(uint256 tokenId) public view returns (bool) {
        address vault = holders[msg.sender].vault;

        if(IERC721(project_address).ownerOf(tokenId) != vault) {
            return false;
        }
        for(uint i=0; i < holders[msg.sender].token_ids.length; ++i) {
            if(holders[msg.sender].token_ids[i] == tokenId) {
                return true;
            }
        }
        
        return false;
    }

    function external_verify(address wallet, uint256 tokenId) public view returns (bool) {
         address vault = holders[wallet].vault;

        if(IERC721(project_address).ownerOf(tokenId) != vault) {
            return false;
        }
        for(uint i=0; i < holders[wallet].token_ids.length; ++i) {
            if(holders[wallet].token_ids[i] == tokenId) {
                return true;
            }
        }

        return false;
    }

    function isRegistered(address wallet, uint256 token_id) public view returns (bool) {
        if(holders[wallet].vault == address(0)) {
            return false;
        }

        for (uint i=0; i < holders[wallet].token_ids.length; ++i)
        {
            if(holders[wallet].token_ids[i] == token_id) {
                return true;
            }
        }

        return false;
    }
}