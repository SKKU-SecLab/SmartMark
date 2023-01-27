

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.9;

interface ITransferProvider {

  event TransferApproved(address indexed from, address indexed to, uint256 value);
  event TransferDeclined(address indexed from, address indexed to, uint256 value);

  function approveTransfer(address _from, address _to, uint256 _value, address _spender) external returns(bool);


  function considerTransfer(address _from, address _to, uint256 _value) external returns(bool);

}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;
contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.9;




contract vnxSimpleTransferProvider is Ownable, ITransferProvider {

  using SafeMath for uint256;
  
  address private _admin;

  event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

  constructor(address _adminUser) public
  {
    _admin = _adminUser;
  }
  function approveTransfer(address _from, address _to, uint256 _value, address _spender) external returns(bool)
  {

    if (_spender ==_admin) {
      emit TransferApproved(_from, _to, _value);
      return true;
    } else {
      emit TransferDeclined(_from, _to, _value);
      return false;
    }
  }

  function considerTransfer(address _from, address _to, uint256 _value) external returns(bool)
  {

    require(_to!=address(0), 'To address should not be zero');
    require(_value > 0, 'Value should be non-zero');
  
    return true;
  }

    function transferAdmin(address newAdmin) external onlyOwner {

        _transferAdmin(newAdmin);
    }

    function _transferAdmin(address newAdmin) internal {

        require(newAdmin != address(0), "Admin: new admin is the zero address");
        require(newAdmin != _admin, "Admin: new admin is the same");

        emit AdminChanged(_admin, newAdmin);
        _admin = newAdmin;
    }
}