
pragma solidity ^0.4.24;

contract Owned {

    address public owner;

    constructor() 
    public {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) 
        onlyOwner 
    public {

        owner = newOwner;
    }
}

library RealitioSafeMath256 {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract SplitterWallet is Owned {


    uint256 constant MAX_RECIPIENTS = 100;

    using RealitioSafeMath256 for uint256;

    mapping(address => uint256) public balanceOf;
    
    uint256 public balanceTotal; 

    address[] public recipients;

    event LogWithdraw(
        address indexed user,
        uint256 amount
    );

    function _firstRecipientIndex(address addr) 
        internal
    view returns (uint256) 
    {

        uint256 i;
        for(i=0; i<recipients.length; i++) {
            if (recipients[i] == addr) {
                return i;
            }
        }
        revert("Recipient not found");
    }

    function addRecipient(address addr) 
        onlyOwner
    external {

        require(recipients.length < MAX_RECIPIENTS, "Too many recipients");
        recipients.push(addr);
    }

    function removeRecipient(address old_addr) 
        onlyOwner
    external {


        uint256 idx = _firstRecipientIndex(old_addr);
        assert(recipients[idx] == old_addr);

        uint256 last_idx = recipients.length - 1;
        if (idx != last_idx) {
            recipients[idx] = recipients[last_idx];
        }

        recipients.length--;
    }

    function replaceSelf(address new_addr) 
    external {

        uint256 idx = _firstRecipientIndex(msg.sender);
        assert(recipients[idx] == msg.sender);
        recipients[idx] = new_addr;
    }

    function allocate()
    external {


        uint256 unallocated = address(this).balance.sub(balanceTotal);
        require(unallocated > 0, "No funds to allocate");

        uint256 num_recipients = recipients.length;

        uint256 each = unallocated / num_recipients;
        require(each > 0, "No money left to be allocated after rounding down");

        uint256 i;
        for (i=0; i<num_recipients; i++) {
            address recip = recipients[i];
            balanceOf[recip] = balanceOf[recip].add(each);
            balanceTotal = balanceTotal.add(each);
        }

        assert(address(this).balance >= balanceTotal);

    }

    function withdraw() 
    external {


        uint256 bal = balanceOf[msg.sender];
        require(bal > 0, "Balance must be positive");

        balanceTotal = balanceTotal.sub(bal);
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(bal);

        emit LogWithdraw(msg.sender, bal);

        assert(address(this).balance >= balanceTotal);

    }

    function()
    external payable {
    }

}