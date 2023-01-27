
pragma solidity ^0.4.25;


contract Ownable {

  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    _owner = msg.sender;
  }

  function owner() public view returns(address) {

    return _owner;
  }

  modifier onlyOwner() {

    require(isOwner());
    _;
  }

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract PaymentSystem is Ownable {


    struct order {
        address payer;
        uint256 value;
        bool revert;
    }

    mapping(uint256 => order) public orders;

    function () public payable {
        revert();
    }

    event PaymentOrder(uint256 indexed id, address payer, uint256 value);

    function paymentOrder(uint256 _id) public payable returns(bool) {

        require(orders[_id].value==0, "id used");
        require(msg.value>0, "no money");

        orders[_id].payer=msg.sender;
        orders[_id].value=msg.value;
        orders[_id].revert=false;

        emit PaymentOrder(_id, msg.sender, msg.value);

        return true;
    }

    event RevertOrder(uint256 indexed id, address payer, uint256 value);

    function revertOrder(uint256 _id) public onlyOwner returns(bool)  {

        require(orders[_id].value>0, "order not used"); 
        require(orders[_id].revert==false, "order revert");

        orders[_id].revert=true;
        address(orders[_id].payer).transfer(orders[_id].value);
        
        emit RevertOrder(_id, orders[_id].payer, orders[_id].value);

        return true;
    }

    function outputMoney(address _from, uint256 _value) public onlyOwner returns(bool) {

        require(address(this).balance>=_value);

        address(_from).transfer(_value);

        return true;
    }

}