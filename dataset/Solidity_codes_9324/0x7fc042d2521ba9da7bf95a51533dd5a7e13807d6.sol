



pragma solidity ^0.6.0;


contract Ownable {

  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "OW01");
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0), "OW02");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


pragma solidity ^0.6.0;


interface IERC20 {


  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint256);

  function totalSupply() external view returns (uint256);

  function balanceOf(address _owner) external view returns (uint256);


  function transfer(address _to, uint256 _value) external returns (bool);


  function allowance(address _owner, address _spender)
    external view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    external returns (bool);


  function approve(address _spender, uint256 _value) external returns (bool);


  function increaseApproval(address _spender, uint256 _addedValue)
    external returns (bool);


  function decreaseApproval(address _spender, uint256 _subtractedValue)
    external returns (bool);

}


pragma solidity ^0.6.0;



abstract contract ISimpleVaultERC20 {
  function transfer(IERC20 _token, address _to, uint256 _value)
    public virtual returns (bool);
}


pragma solidity ^0.6.0;




contract TimeLockedSimpleVaultERC20 is ISimpleVaultERC20, Ownable {


  uint64 public lockUntil;

  modifier whenUnlocked() {

    require(lockUntil < currentTime(), "TLV01");
    _;
  }

  constructor(address _beneficiary, uint64 _lockUntil) public {
    require(_beneficiary != address(0), "TLV02");
    require(_lockUntil > currentTime(), "TLV03");
    lockUntil = _lockUntil;
    transferOwnership(_beneficiary);
  }

  function transfer(IERC20 _token, address _to, uint256 _value)
    public override onlyOwner whenUnlocked returns (bool)
  {

    return _token.transfer(_to, _value);
  }

  function currentTime() internal view returns (uint256) {

    return now;
  }
}