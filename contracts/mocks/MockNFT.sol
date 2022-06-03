// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MockNFT is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    using Address for address;
    using Strings for uint256;

    uint256 public maxPurchaseQuantity;
    uint256 public MAX_TOKENS;
    uint256 public price;

    uint256 private _publicMinted = 0;
    uint256 public constant priceInWei = 0.0 ether;

    event MockNFTMinted (address purchaser, uint256 tokenId);

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        maxPurchaseQuantity = 20;
        MAX_TOKENS = 1000;
    }

    function purchase() external payable {
        require(priceInWei == msg.value, 'amount too low');

        if (totalSupply() < MAX_TOKENS) {
            _tokenIdCounter.increment();
            _publicMinted = _tokenIdCounter.current();
            _safeMint(msg.sender, _publicMinted);
        }

        emit MockNFTMinted(msg.sender, _publicMinted);
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) return new uint256[](0);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}   
