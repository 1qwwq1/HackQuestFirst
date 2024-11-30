// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;
contract RockPaperScissors {

    struct Auction {
        bytes32 blindedAuction;
        address auctionAddress;
        uint auctionTime;
    }

    enum Option {
        None,
        Rock,
        Paper,
        Scissors
    }
    
    address payable public host;
    uint private auctionCount = 0;
    uint private optionCount = 0;
    mapping(address => Auction) private auctions; 
    mapping(address => Option) private options; 
    address[] members;
    address public winnerAddress;

    constructor() payable { host = payable(msg.sender); }
        
    function auction(bytes32 blindedAuction) external{
        require(auctionCount<=2,"The number of auction is already full");
        auctions[msg.sender] = Auction({
            blindedAuction: blindedAuction,
            auctionAddress: msg.sender,
            auctionTime: block.timestamp
        });
        auctionCount++;    
    }  

    function revealAuction(
        uint choices,
        uint secret
    )
        payable external
    {
        require(Option(choices) != Option.None);
        Auction storage auctionToCheck;
        auctionToCheck = auctions[msg.sender];
        Option op = Option(choices);
        if(auctionToCheck.blindedAuction == keccak256(abi.encodePacked(op,secret))){
            options[msg.sender] = Option(choices);
            members.push(msg.sender);
            optionCount++;
        }
        if(optionCount == 2){
            checkWinner(members[0],members[1]);
        }
        
    }

    function tool(
        uint choices,
        uint secret
    )
        external
        pure returns (bytes32)
    {
        Option op = Option(choices);
        return keccak256(abi.encodePacked(op,secret));
    }

    function checkWinner(address firstMember,address secondMember) payable public  {
        if(options[firstMember] == options[secondMember]){
            winnerAddress = auctions[firstMember].auctionTime > auctions[secondMember].auctionTime? secondMember : firstMember;
        }else if(options[firstMember] == Option.Rock){
            if(options[secondMember] == Option.Paper){
                winnerAddress = secondMember;
            }else {
                winnerAddress = firstMember;
            }
        }else if(options[firstMember] == Option.Paper){
            if(options[secondMember] == Option.Scissors){
                winnerAddress = secondMember;
            }else {
                winnerAddress = firstMember;
            }
        }else if(options[firstMember] == Option.Scissors){
            if(options[secondMember] == Option.Rock){
                winnerAddress = secondMember;
            }else {
                winnerAddress = firstMember;
            }
        }
        payable(winnerAddress).transfer(address(this).balance);
    }
}



















    
