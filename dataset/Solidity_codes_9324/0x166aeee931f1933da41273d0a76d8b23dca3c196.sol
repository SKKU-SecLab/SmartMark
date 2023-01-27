
pragma solidity 0.8.7;

contract MouseTrap {

    
    mapping(address => uint256) public registeredBlock;
    uint256 private lastBlockCheeseWasStolen;
    address payable public immutable dev;
    
    constructor() {
        require(msg.sender == tx.origin, 'dev must be EOA');
        dev = payable(msg.sender);
    }
    
    receive() external payable {}
    
    function register() external payable {

        if (msg.value < 1 ether) return;
        
        if (msg.sender != tx.origin) {
            _lose();
            return;
        }
        
        if (registeredBlock[msg.sender] != 0) {
            _lose();
            return;
        }
        
        registeredBlock[msg.sender] = block.number;
    }
    
    function stealTheCheese(uint256 _targetBlock) external {

        if (registeredBlock[msg.sender] == 0) return;
        
        if (block.number == registeredBlock[msg.sender]) {
            _lose();
            return;
        }
        
        if (tx.gasprice - block.basefee < 20 gwei) {
            _lose();
            return;
        }
        
        if (_targetBlock != block.number) {
            _lose();
            return;
        }
        
        if (lastBlockCheeseWasStolen == block.number) {
            _lose();
            return;
        }
        
        lastBlockCheeseWasStolen = block.number;

        sendValue(payable(msg.sender), 1.02 ether);
    }
    
    function _lose() private {

        registeredBlock[msg.sender] = 0;
        sendValue(dev, 1 ether);
    }

	function sendValue(address payable recipient, uint256 amount) private {

		require(address(this).balance >= amount, "Address: insufficient balance");
		(bool success, ) = recipient.call{ value: amount }("");
		require(success, "Address: unable to send value, recipient may have reverted");
	}

}