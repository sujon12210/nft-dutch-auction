// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DutchAuctionNFT is ERC721, Ownable, ReentrancyGuard {
    uint256 public constant MAX_SUPPLY = 1000;
    
    uint256 public immutable startPrice;
    uint256 public immutable floorPrice;
    uint256 public immutable startTime;
    uint256 public immutable duration;
    uint256 public immutable pricePriceDropPerSecond;

    uint256 public totalSupply;

    event NFTPurchased(address indexed buyer, uint256 indexed tokenId, uint256 pricePaid);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _startPrice,
        uint256 _floorPrice,
        uint256 _startTime,
        uint256 _duration
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        require(_startPrice > _floorPrice, "Start price must exceed floor price");
        require(_duration > 0, "Duration must be greater than zero");
        require(_startTime >= block.timestamp, "Start time cannot be in the past");

        startPrice = _startPrice;
        floorPrice = _floorPrice;
        startTime = _startTime;
        duration = _duration;
        
        pricePriceDropPerSecond = (_startPrice - _floorPrice) / _duration;
    }

    function getCurrentPrice() public view returns (uint256) {
        if (block.timestamp < startTime) {
            return startPrice;
        }
        
        uint256 elapsed = block.timestamp - startTime;
        if (elapsed >= duration) {
            return floorPrice;
        }
        
        return startPrice - (elapsed * pricePriceDropPerSecond);
    }

    function mintAuctionNFT(uint256 _quantity) external payable nonReentrant {
        require(block.timestamp >= startTime, "Auction has not started yet");
        require(totalSupply + _quantity <= MAX_SUPPLY, "Exceeds maximum token supply");
        
        uint256 price = getCurrentPrice();
        uint256 totalCost = price * _quantity;
        require(msg.value >= totalCost, "Insufficient payment provided");

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 tokenId = totalSupply;
            totalSupply++;
            _safeMint(msg.sender, tokenId);
            emit NFTPurchased(msg.sender, tokenId, price);
        }

        // Return surplus native asset balances to buyer immediately
        if (msg.value > totalCost) {
            uint256 refund = msg.value - totalCost;
            (bool success, ) = msg.sender.call{value: refund}("");
            require(success, "Refund transfer failed");
        }
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available to withdraw");
        
        (bool success, ) = owner().call{value: balance}("");
        require(success, "Withdrawal execution failed");
    }
}
