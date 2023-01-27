
pragma solidity ^0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


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

    require(msg.sender == owner);
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

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}contract PermittedStabelsInterface {
  mapping (address => bool) public permittedAddresses;
}
contract PermittedPoolsInterface {

  mapping (address => bool) public permittedAddresses;
}
contract PermittedExchangesInterface {

  mapping (address => bool) public permittedAddresses;
}
contract SmartFundUSDFactoryInterface {

  function createSmartFund(
    address _owner,
    string  _name,
    uint256 _successFee,
    uint256 _platformFee,
    address _platfromAddress,
    address _exchangePortalAddress,
    address _permittedExchanges,
    address _permittedPools,
    address _permittedStabels,
    address _poolPortalAddress,
    address _stableCoinAddress,
    address _cEther
    )
  public
  returns(address);

}
contract SmartFundETHFactoryInterface {

  function createSmartFund(
    address _owner,
    string  _name,
    uint256 _successFee,
    uint256 _platformFee,
    address _platfromAddress,
    address _exchangePortalAddress,
    address _permittedExchanges,
    address _permittedPools,
    address _poolPortalAddress,
    address _cEther
    )
  public
  returns(address);

}













contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}
contract SmartFundRegistry is Ownable {

  address[] public smartFunds;

  address public COTDAOWallet;

  PermittedExchangesInterface public permittedExchanges;
  PermittedPoolsInterface public permittedPools;
  PermittedStabelsInterface public permittedStabels;

  address public poolPortalAddress;
  address public exchangePortalAddress;

  uint256 public platformFee;

  uint256 public maximumSuccessFee = 3000;

  address public stableCoinAddress;

  address public cEther;

  SmartFundETHFactoryInterface public smartFundETHFactory;
  SmartFundUSDFactoryInterface public smartFundUSDFactory;

  event SmartFundAdded(address indexed smartFundAddress, address indexed owner);

  constructor(
    address _COTDAOWallet,
    uint256 _platformFee,
    address _permittedExchangesAddress,
    address _exchangePortalAddress,
    address _permittedPoolAddress,
    address _poolPortalAddress,
    address _permittedStabels,
    address _stableCoinAddress,
    address _smartFundETHFactory,
    address _smartFundUSDFactory,
    address _cEther
  ) public {
    COTDAOWallet = _COTDAOWallet;
    platformFee = _platformFee;
    exchangePortalAddress = _exchangePortalAddress;
    permittedExchanges = PermittedExchangesInterface(_permittedExchangesAddress);
    permittedPools = PermittedPoolsInterface(_permittedPoolAddress);
    permittedStabels = PermittedStabelsInterface(_permittedStabels);
    poolPortalAddress = _poolPortalAddress;
    stableCoinAddress = _stableCoinAddress;
    smartFundETHFactory = SmartFundETHFactoryInterface(_smartFundETHFactory);
    smartFundUSDFactory = SmartFundUSDFactoryInterface(_smartFundUSDFactory);
    cEther = _cEther;
  }

  function createSmartFund(
    string _name,
    uint256 _successFee,
    bool _isStableBasedFund
  ) public {

    require(_successFee <= maximumSuccessFee);

    address owner = msg.sender;
    address smartFund;

    if(_isStableBasedFund){
      smartFund = smartFundUSDFactory.createSmartFund(
        owner,
        _name,
        _successFee,
        platformFee,
        COTDAOWallet,
        exchangePortalAddress,
        address(permittedExchanges),
        address(permittedPools),
        address(permittedStabels),
        poolPortalAddress,
        stableCoinAddress,
        cEther
      );
    }else{
      smartFund = smartFundETHFactory.createSmartFund(
        owner,
        _name,
        _successFee,
        platformFee,
        COTDAOWallet,
        exchangePortalAddress,
        address(permittedExchanges),
        address(permittedPools),
        poolPortalAddress,
        cEther
      );
    }

    smartFunds.push(smartFund);
    emit SmartFundAdded(smartFund, owner);
  }

  function totalSmartFunds() public view returns (uint256) {

    return smartFunds.length;
  }

  function getAllSmartFundAddresses() public view returns(address[]) {

    address[] memory addresses = new address[](smartFunds.length);

    for (uint i; i < smartFunds.length; i++) {
      addresses[i] = address(smartFunds[i]);
    }

    return addresses;
  }

  function setExchangePortalAddress(address _newExchangePortalAddress) public onlyOwner {

    require(permittedExchanges.permittedAddresses(_newExchangePortalAddress));
    exchangePortalAddress = _newExchangePortalAddress;
  }

  function setPoolPortalAddress (address _poolPortalAddress) external onlyOwner {
    require(permittedPools.permittedAddresses(_poolPortalAddress));

    poolPortalAddress = _poolPortalAddress;
  }

  function setMaximumSuccessFee(uint256 _maximumSuccessFee) external onlyOwner {

    maximumSuccessFee = _maximumSuccessFee;
  }

  function setPlatformFee(uint256 _platformFee) external onlyOwner {

    platformFee = _platformFee;
  }


  function changeStableCoinAddress(address _stableCoinAddress) external onlyOwner {

    require(permittedStabels.permittedAddresses(_stableCoinAddress));
    stableCoinAddress = _stableCoinAddress;
  }

  function withdrawTokens(address _tokenAddress) external onlyOwner {

    ERC20 token = ERC20(_tokenAddress);

    token.transfer(owner, token.balanceOf(this));
  }

  function withdrawEther() external onlyOwner {

    owner.transfer(address(this).balance);
  }

  function() public payable {}

}