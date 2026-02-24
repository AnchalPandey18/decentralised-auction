//SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;
contract auction{
    address public seller;
    address public highestBidder;
    uint public startblock;
    uint public endBlock;
    uint public highestbid;
    uint public minIncrement;
    uint public startingPrice;
    bool public isEnded;
    // store refundable bids
    mapping(address=>uint) public bids;

    constructor(uint durationBlock, uint _minIncrement,uint _startingPrice){
        seller = msg.sender;
        startblock = block.number;
        endBlock = (startblock + durationBlock);
        minIncrement = _minIncrement;
        startingPrice = _startingPrice;
        highestbid = _startingPrice;
    }
    function bid() external payable{
        require(block.number <= endBlock,"Auction has ended");
        require(!isEnded,"Auction already ended");
        require(msg.value >=highestbid + minIncrement, "bit is too low");

        // save old highest bid for withdraw
        if(highestBidder != address(0)){
            bids[highestBidder] += highestbid;
        }
        highestbid = msg.value;
        highestBidder = msg.sender;
    }
    // withdraw the outbid
    function withdraw() external{
        require(msg.sender != highestBidder,"highest bidder cannot withdraw");
        uint amount = bids[msg.sender];
        require(amount > 0,"No refund available for this bidder");
        bids[msg.sender] = 0;
        (bool sent,) = payable(msg.sender).call{value:amount}("");
        require(sent, "Faled to send Ether");
    }
    // function to end the auction

    function endAuction() external{
        require(block.number >= endBlock, "Auction not yet ended");
        require(!isEnded,"Auction already ended");
        isEnded = true;
       (bool sent,) = payable(seller).call{value:highestbid}("");
       require(sent, "Failed to pay seller");

    }
}