
pragma solidity ^0.4.24;



library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
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

  function getFractionalAmount(uint256 _amount, uint256 _percentage)
  internal
  pure
  returns (uint256) {

    return div(mul(_amount, _percentage), 100);
  }

}


interface ERC20 {

  function decimals() external view returns (uint8);


  function totalSupply() external view returns (uint256);


  function balanceOf(address _who) external view returns (uint256);


  function allowance(address _owner, address _spender) external view returns (uint256);


  function transfer(address _to, uint256 _value) external returns (bool);


  function approve(address _spender, uint256 _value) external returns (bool);


  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface MinterInterface {

  function cloneToken(string _uri, address _erc20Address) external returns (address asset);


  function mintAssetTokens(address _assetAddress, address _receiver, uint256 _amount) external returns (bool);


  function changeTokenController(address _assetAddress, address _newController) external returns (bool);

}


interface CrowdsaleReserveInterface {

  function issueETH(address _receiver, uint256 _amount) external returns (bool);

  function receiveETH(address _payer) external payable returns (bool);

  function refundETHAsset(address _asset, uint256 _amount) external returns (bool);

  function issueERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);

  function requestERC20(address _payer, uint256 _amount, address _tokenAddress) external returns (bool);

  function approveERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);

  function refundERC20Asset(address _asset, uint256 _amount, address _tokenAddress) external returns (bool);

}


interface Events {

  function transaction(string _message, address _from, address _to, uint _amount, address _token)  external;

  function asset(string _message, string _uri, address _assetAddress, address _manager);

}
interface DB {

  function addressStorage(bytes32 _key) external view returns (address);

  function uintStorage(bytes32 _key) external view returns (uint);

  function setUint(bytes32 _key, uint _value) external;

  function deleteUint(bytes32 _key) external;

  function setBool(bytes32 _key, bool _value) external;

  function boolStorage(bytes32 _key) external view returns (bool);

}

contract CrowdsaleETH {

    using SafeMath for uint256;

    DB private database;
    Events private events;
    MinterInterface private minter;
    CrowdsaleReserveInterface private reserve;

    constructor(address _database, address _events)
    public {
      database = DB(_database);
      events = Events(_events);
      minter = MinterInterface(database.addressStorage(keccak256(abi.encodePacked("contract", "Minter"))));
      reserve = CrowdsaleReserveInterface(database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleReserve"))));
    }


    function buyAssetOrderETH(address _assetAddress)
    external
    payable
    requiresEther
    validAsset(_assetAddress)
    beforeDeadline(_assetAddress)
    notFinalized(_assetAddress)
    returns (bool) {

      uint fundingRemaining = database.uintStorage(keccak256(abi.encodePacked("crowdsale.remaining", _assetAddress)));
      uint amount; //The number of tokens that will be minted
      if (msg.value < fundingRemaining) {
        amount = msg.value.mul(100).div(uint(100).add(database.uintStorage(keccak256(abi.encodePacked("platform.fee")))));
        database.setUint(keccak256(abi.encodePacked("crowdsale.remaining", _assetAddress)), fundingRemaining.sub(msg.value));
        require(minter.mintAssetTokens(_assetAddress, msg.sender, amount), "Investor minting failed");
        reserve.receiveETH.value(msg.value)(msg.sender);
      } else {
        amount = fundingRemaining.mul(100).div(uint(100).add(database.uintStorage(keccak256(abi.encodePacked("platform.fee")))));
        database.setBool(keccak256(abi.encodePacked("crowdsale.finalized", _assetAddress)), true);
        database.deleteUint(keccak256(abi.encodePacked("crowdsale.remaining", _assetAddress)));
        require(minter.mintAssetTokens(_assetAddress, msg.sender, amount), "Investor minting failed");
        reserve.receiveETH.value(fundingRemaining)(msg.sender);
        msg.sender.transfer(msg.value.sub(fundingRemaining));
        events.asset('Crowdsale finalized', '', _assetAddress, msg.sender);
      }
      events.transaction('Asset purchased', address(this), msg.sender, amount, _assetAddress);

      return true;
    }

    function payoutETH(address _assetAddress)
    external
    whenNotPaused
    finalized(_assetAddress)
    notPaid(_assetAddress)
    returns (bool) {

      database.setBool(keccak256(abi.encodePacked("crowdsale.paid", _assetAddress)), true);
      address platformAssetsWallet = database.addressStorage(keccak256(abi.encodePacked("platform.wallet.assets")));
      require(platformAssetsWallet != address(0), "Platform assets wallet not set");
      require(minter.mintAssetTokens(_assetAddress, database.addressStorage(keccak256(abi.encodePacked("contract", "AssetManagerFunds"))), database.uintStorage(keccak256(abi.encodePacked("asset.managerTokens", _assetAddress)))), "Manager minting failed");
      require(minter.mintAssetTokens(_assetAddress, platformAssetsWallet, database.uintStorage(keccak256(abi.encodePacked("asset.platformTokens", _assetAddress)))), "Platform minting failed");
      address receiver = database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress)));
      address platformFundsWallet = database.addressStorage(keccak256(abi.encodePacked("platform.wallet.funds")));
      require(receiver != address(0) && platformFundsWallet != address(0), "Receiver or platform wallet not set");
      uint amount = database.uintStorage(keccak256(abi.encodePacked("crowdsale.goal", _assetAddress)));
      uint platformFee = amount.getFractionalAmount(database.uintStorage(keccak256(abi.encodePacked("platform.fee"))));
      require(reserve.issueETH(platformFundsWallet, platformFee), 'Platform funds not paid');
      require(reserve.issueETH(receiver, amount), 'Operator funds not paid');
      database.deleteUint(keccak256(abi.encodePacked("crowdsale.start", _assetAddress)));
      address manager = database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress)));
      database.setUint(keccak256(abi.encodePacked("manager.assets", manager)), database.uintStorage(keccak256(abi.encodePacked("manager.assets", manager))).add(1));
      events.transaction('Asset payout', _assetAddress, receiver, amount, address(0));
      return true;
    }

    function cancel(address _assetAddress)
    external
    whenNotPaused
    validAsset(_assetAddress)
    beforeDeadline(_assetAddress)
    notFinalized(_assetAddress)
    returns (bool){

      require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress))));
      database.setUint(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress)), 1);
      refund(_assetAddress);
    }

    function refund(address _assetAddress)
    public
    whenNotPaused
    validAsset(_assetAddress)
    afterDeadline(_assetAddress)
    notFinalized(_assetAddress)
    returns (bool) {

      require(database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))) != 0);
      database.deleteUint(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress)));
      ERC20 assetToken = ERC20(_assetAddress);
      uint refundValue = assetToken.totalSupply().mul(uint(100).add(database.uintStorage(keccak256(abi.encodePacked("platform.fee"))))).div(100); //total supply plus platform fees
      reserve.refundETHAsset(_assetAddress, refundValue);
      return true;
    }

    function recoverTokens(address _erc20Token)
    onlyOwner
    external {

      ERC20 thisToken = ERC20(_erc20Token);
      uint contractBalance = thisToken.balanceOf(address(this));
      thisToken.transfer(msg.sender, contractBalance);
    }

    function destroy()
    onlyOwner
    external {

      events.transaction('CrowdsaleETH destroyed', address(this), msg.sender, address(this).balance, address(0));
      selfdestruct(msg.sender);
    }



    modifier requiresEther() {

      require(msg.value > 0);
      _;
    }

    modifier onlyOwner {

      require(database.boolStorage(keccak256(abi.encodePacked("owner", msg.sender))), "Not owner");
      _;
    }

    modifier whenNotPaused {

      require(!database.boolStorage(keccak256(abi.encodePacked("paused", address(this)))), "Contract paused");
      _;
    }

    modifier validAsset(address _assetAddress) {

      require(database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress))) != address(0), "Invalid asset");
      _;
    }

    modifier beforeDeadline(address _assetAddress) {

      require(now < database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))), "Before deadline");
      _;
    }

    modifier betweenDeadlines(address _assetAddress) {

      require(now <= database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))), "Past deadline");
      require(now >= database.uintStorage(keccak256(abi.encodePacked("crowdsale.start", _assetAddress))), "Before start time");
      _;
    }

    modifier afterDeadline(address _assetAddress) {

      require(now > database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))), "Before deadline");
      _;
    }

    modifier finalized(address _assetAddress) {

      require( database.boolStorage(keccak256(abi.encodePacked("crowdsale.finalized", _assetAddress))), "Crowdsale not finalized");
      _;
    }

    modifier notFinalized(address _assetAddress) {

      require( !database.boolStorage(keccak256(abi.encodePacked("crowdsale.finalized", _assetAddress))), "Crowdsale finalized");
      _;
    }

    modifier notPaid(address _assetAddress) {

      require( !database.boolStorage(keccak256(abi.encodePacked("crowdsale.paid", _assetAddress))), "Crowdsale had paid out");
      _;
    }

  }