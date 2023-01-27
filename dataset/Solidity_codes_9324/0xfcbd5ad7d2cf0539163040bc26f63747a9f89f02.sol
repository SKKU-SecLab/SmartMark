



pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




pragma solidity 0.6.6;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function symbol() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}




pragma solidity 0.6.6;

interface IProtocolFactory {

  event ProtocolInitiation(address protocolAddress);

  function getAllProtocolAddresses() external view returns (address[] memory);

  function getRedeemFees() external view returns (uint16 _numerator, uint16 _denominator);

  function redeemFeeNumerator() external view returns (uint16);

  function redeemFeeDenominator() external view returns (uint16);

  function protocolImplementation() external view returns (address);

  function coverImplementation() external view returns (address);

  function coverERC20Implementation() external view returns (address);

  function treasury() external view returns (address);

  function governance() external view returns (address);

  function claimManager() external view returns (address);

  function protocols(bytes32 _protocolName) external view returns (address);


  function getProtocolsLength() external view returns (uint256);

  function getProtocolNameAndAddress(uint256 _index) external view returns (bytes32, address);

  function getProtocolAddress(bytes32 _name) external view returns (address);

  function getCoverAddress(bytes32 _protocolName, uint48 _timestamp, address _collateral, uint256 _claimNonce) external view returns (address);

  function getCovTokenAddress(bytes32 _protocolName, uint48 _timestamp, address _collateral, uint256 _claimNonce, bool _isClaimCovToken) external view returns (address);


  function updateProtocolImplementation(address _newImplementation) external returns (bool);

  function updateCoverImplementation(address _newImplementation) external returns (bool);

  function updateCoverERC20Implementation(address _newImplementation) external returns (bool);

  function assignClaimManager(address _address) external returns (bool);

  function addProtocol(
    bytes32 _name,
    bool _active,
    address _collateral,
    uint48[] calldata _timestamps,
    bytes32[] calldata _timestampNames
  ) external returns (address);


  function updateClaimManager(address _address) external returns (bool);

  function updateFees(uint16 _redeemFeeNumerator, uint16 _redeemFeeDenominator) external returns (bool);

  function updateGovernance(address _address) external returns (bool);

  function updateTreasury(address _address) external returns (bool);

}




pragma solidity 0.6.6;

interface IProtocol {

  event ClaimAccepted(uint256 newClaimNonce);

  function getProtocolDetails()
    external view returns (
      bytes32 _name,
      bool _active,
      uint256 _claimNonce,
      uint256 _claimRedeemDelay,
      uint256 _noclaimRedeemDelay,
      address[] memory _collaterals,
      uint48[] memory _expirationTimestamps,
      address[] memory _allCovers,
      address[] memory _allActiveCovers
    );

  function active() external view returns (bool);

  function name() external view returns (bytes32);

  function claimNonce() external view returns (uint256);

  function claimRedeemDelay() external view returns (uint256);

  function noclaimRedeemDelay() external view returns (uint256);

  function activeCovers(uint256 _index) external view returns (address);

  function claimDetails(uint256 _claimNonce) external view returns (uint16 _payoutNumerator, uint16 _payoutDenominator, uint48 _incidentTimestamp, uint48 _timestamp);

  function collateralStatusMap(address _collateral) external view returns (uint8 _status);

  function expirationTimestampMap(uint48 _expirationTimestamp) external view returns (bytes32 _name, uint8 _status);

  function coverMap(address _collateral, uint48 _expirationTimestamp) external view returns (address);


  function collaterals(uint256 _index) external view returns (address);

  function collateralsLength() external view returns (uint256);

  function expirationTimestamps(uint256 _index) external view returns (uint48);

  function expirationTimestampsLength() external view returns (uint256);

  function activeCoversLength() external view returns (uint256);

  function claimsLength() external view returns (uint256);

  function addCover(address _collateral, uint48 _timestamp, uint256 _amount)
    external returns (bool);


  function enactClaim(uint16 _payoutNumerator, uint16 _payoutDenominator, uint48 _incidentTimestamp, uint256 _protocolNonce) external returns (bool);


  function setActive(bool _active) external returns (bool);

  function updateExpirationTimestamp(uint48 _expirationTimestamp, bytes32 _expirationTimestampName, uint8 _status) external returns (bool);

  function updateCollateral(address _collateral, uint8 _status) external returns (bool);


  function updateClaimRedeemDelay(uint256 _claimRedeemDelay) external returns (bool);

  function updateNoclaimRedeemDelay(uint256 _noclaimRedeemDelay) external returns (bool);

}




pragma solidity 0.6.6;

interface IBalancerPool {

    function swapExactAmountIn(address, uint, address, uint, uint) external returns (uint, uint);

    function swapExactAmountOut(address, uint, address, uint, uint) external returns (uint, uint);

}



pragma solidity 0.6.6;

contract Arbys is Ownable {

    IProtocolFactory public factory;
    IERC20 public daiToken;
    uint48 public expirationTime;

    constructor (
      IProtocolFactory _factory,
      IERC20 daiToken_
    )
      public Ownable()
    {
      factory = _factory;
      daiToken = daiToken_;
    }

    function arbitrageSell(IProtocol _protocol, IBalancerPool _claimPool, IBalancerPool _noclaimPool, uint48 _expiration, uint _daiAmount) external {

      daiToken.transferFrom(msg.sender, address(this), _daiAmount);
      if (daiToken.allowance(address(this), address(_protocol)) < _daiAmount) {
        daiToken.approve(address(_protocol), _daiAmount);
      }
      _protocol.addCover(address(daiToken), _expiration, _daiAmount);

      address noclaimTokenAddr = factory.getCovTokenAddress(_protocol.name(), _expiration, address(daiToken), _protocol.claimNonce(), false);
      address claimTokenAddr = factory.getCovTokenAddress(_protocol.name(), _expiration, address(daiToken), _protocol.claimNonce(), true);

      _swapTokenForDai(_noclaimPool, IERC20(noclaimTokenAddr), _daiAmount);
      _swapTokenForDai(_claimPool, IERC20(claimTokenAddr), _daiAmount);

      uint256 bal = daiToken.balanceOf(address(this));
      require(bal > _daiAmount, "No arbys");
      require(daiToken.transfer(msg.sender, bal), "ERR_TRANSFER_FAILED");
    }

    function _swapTokenForDai(IBalancerPool _bPool, IERC20 token, uint _sellAmount) private {

        if (token.allowance(address(this), address(_bPool)) < _sellAmount) {
          token.approve(address(_bPool), _sellAmount);
        }
        IBalancerPool(_bPool).swapExactAmountIn(
            address(token),
            _sellAmount,
            address(daiToken),
            0, // minAmountOut, set to 0 -> sell no matter how low the price of CLAIM tokens are
            2**256 - 1 // maxPrice, set to max -> accept any swap prices
        );
    }

    function destroy() external onlyOwner {

        selfdestruct(msg.sender);
    }

    receive() external payable {}
}