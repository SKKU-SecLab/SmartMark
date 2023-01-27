
pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.7.1;

interface ILendingLogic {

    function lend(address _underlying, uint256 _amount) external view returns(address[] memory targets, bytes[] memory data);

    
    function unlend(address _wrapped, uint256 _amount) external view returns(address[] memory targets, bytes[] memory data);

}// MIT
pragma solidity ^0.7.1;

interface IAToken {

    function redeem(uint256 _amount) external;

}// MIT
pragma solidity ^0.7.1;

interface IAaveLendingPool {

    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external;

}// MIT
pragma solidity ^0.7.1;


contract LendingLogicAave is ILendingLogic {


    IAaveLendingPool public lendingPool;
    uint16 public referralCode;

    constructor(address _lendingPool, uint16 _referralCode) {
        lendingPool = IAaveLendingPool(_lendingPool);
        referralCode = _referralCode;
    }

    function lend(address _underlying, uint256 _amount) external view override returns(address[] memory targets, bytes[] memory data) {

        IERC20 underlying = IERC20(_underlying);

        targets = new address[](3);
        data = new bytes[](3);

        targets[0] = _underlying;
        data[0] = abi.encodeWithSelector(underlying.approve.selector, address(lendingPool), 0);

        targets[1] = _underlying;
        data[1] = abi.encodeWithSelector(underlying.approve.selector, address(lendingPool), _amount);

        targets[2] = address(lendingPool);
        data[2] =  abi.encodeWithSelector(lendingPool.deposit.selector, _underlying, _amount, referralCode);

        return(targets, data);
    }
    function unlend(address _wrapped, uint256 _amount) external view override returns(address[] memory targets, bytes[] memory data) {

        targets = new address[](1);
        data = new bytes[](1);

        targets[0] = _wrapped;
        data[0] = abi.encodeWithSelector(IAToken.redeem.selector, _amount);
        
        return(targets, data);
    }

}// MIT

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT
pragma solidity ^0.7.1;



contract LendingRegistry is Ownable {


    mapping(address => bytes32) public wrappedToProtocol;
    mapping(address => address) public wrappedToUnderlying;

    mapping(address => mapping(bytes32 => address)) public underlyingToProtocolWrapped;

    mapping(bytes32 => address) public protocolToLogic;

    event WrappedToProtocolSet(address indexed wrapped, bytes32 indexed protocol);
    event WrappedToUnderlyingSet(address indexed wrapped, address indexed underlying);
    event ProtocolToLogicSet(bytes32 indexed protocol, address indexed logic);
    event UnderlyingToProtocolWrappedSet(address indexed underlying, bytes32 indexed protocol, address indexed wrapped);

    function setWrappedToProtocol(address _wrapped, bytes32 _protocol) onlyOwner external {

        wrappedToProtocol[_wrapped] = _protocol;
        emit WrappedToProtocolSet(_wrapped, _protocol);
    }

    function setWrappedToUnderlying(address _wrapped, address _underlying) onlyOwner external {

        wrappedToUnderlying[_wrapped] = _underlying;
        emit WrappedToUnderlyingSet(_wrapped, _underlying);
    }

    function setProtocolToLogic(bytes32 _protocol, address _logic) onlyOwner external {

        protocolToLogic[_protocol] = _logic;
        emit ProtocolToLogicSet(_protocol, _logic);
    }

    function setUnderlyingToProtocolWrapped(address _underlying, bytes32 _protocol, address _wrapped) onlyOwner external {

        underlyingToProtocolWrapped[_underlying][_protocol] = _wrapped;
        emit UnderlyingToProtocolWrappedSet(_underlying, _protocol, _wrapped);
    } 

    function getLendTXData(address _underlying, uint256 _amount, bytes32 _protocol) external view returns(address[] memory targets, bytes[] memory data) {

        ILendingLogic lendingLogic = ILendingLogic(protocolToLogic[_protocol]);
        require(address(lendingLogic) != address(0), "NO_LENDING_LOGIC_SET");

        return lendingLogic.lend(_underlying, _amount);
    }

    function getUnlendTXData(address _wrapped, uint256 _amount) external view returns(address[] memory targets, bytes[] memory data) {

        ILendingLogic lendingLogic = ILendingLogic(protocolToLogic[wrappedToProtocol[_wrapped]]);
        require(address(lendingLogic) != address(0), "NO_LENDING_LOGIC_SET");

        return lendingLogic.unlend(_wrapped, _amount);
    }
}// MIT
pragma solidity ^0.7.1;

interface ICToken {

    function mint(uint _mintAmount) external returns (uint256);

    function redeem(uint _redeemTokens) external returns (uint256);

}// MIT
pragma solidity ^0.7.1;


contract LendingLogicCompound is ILendingLogic {


    LendingRegistry public lendingRegistry;
    bytes32 public constant PROTOCOL = keccak256(abi.encodePacked("Compound"));

    constructor(address _lendingRegistry) {
        lendingRegistry = LendingRegistry(_lendingRegistry);
    }

    function lend(address _underlying, uint256 _amount) external view override returns(address[] memory targets, bytes[] memory data) {

        IERC20 underlying = IERC20(_underlying);

        targets = new address[](3);
        data = new bytes[](3);


        address cToken = lendingRegistry.underlyingToProtocolWrapped(_underlying, PROTOCOL);

        targets[0] = _underlying;
        data[0] = abi.encodeWithSelector(underlying.approve.selector, cToken, 0);

        targets[1] = _underlying;
        data[1] = abi.encodeWithSelector(underlying.approve.selector, cToken, _amount);

        targets[2] = cToken;

        data[2] =  abi.encodeWithSelector(ICToken.mint.selector, _amount);

        return(targets, data);
    }
    function unlend(address _wrapped, uint256 _amount) external view override returns(address[] memory targets, bytes[] memory data) {

        targets = new address[](1);
        data = new bytes[](1);

        targets[0] = _wrapped;
        data[0] = abi.encodeWithSelector(ICToken.redeem.selector, _amount);
        
        return(targets, data);
    }

}// MIT

pragma solidity ^0.7.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT
pragma solidity ^0.7.1;

interface IERC173 {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address owner_);


    function transferOwnership(address _newOwner) external;

}// MIT
pragma solidity ^0.7.1;

interface IBasketFacet {


    event TokenAdded(address indexed _token);
    event TokenRemoved(address indexed _token);
    event EntryFeeSet(uint256 fee);
    event ExitFeeSet(uint256 fee);
    event AnnualizedFeeSet(uint256 fee);
    event FeeBeneficiarySet(address indexed beneficiary);
    event EntryFeeBeneficiaryShareSet(uint256 share);
    event ExitFeeBeneficiaryShareSet(uint256 share);

    event PoolJoined(address indexed who, uint256 amount);
    event PoolExited(address indexed who, uint256 amount);
    event FeeCharged(uint256 amount);
    event LockSet(uint256 lockBlock);
    event CapSet(uint256 cap);

    function setEntryFee(uint256 _fee) external;


    function getEntryFee() external view returns(uint256);


    function setExitFee(uint256 _fee) external;


    function getExitFee() external view returns(uint256);


    function setAnnualizedFee(uint256 _fee) external;


    function getAnnualizedFee() external view returns(uint256);


    function setFeeBeneficiary(address _beneficiary) external;


    function getFeeBeneficiary() external view returns(address);


    function setEntryFeeBeneficiaryShare(uint256 _share) external;


    function getEntryFeeBeneficiaryShare() external view returns(uint256);


    function setExitFeeBeneficiaryShare(uint256 _share) external;


    function getExitFeeBeneficiaryShare() external view returns(uint256);


    function calcOutStandingAnnualizedFee() external view returns(uint256);


    function chargeOutstandingAnnualizedFee() external;


    function joinPool(uint256 _amount) external;


    function exitPool(uint256 _amount) external;


    function getLock() external view returns (bool);


    function getLockBlock() external view returns (uint256);


    function setLock(uint256 _lock) external;


    function getCap() external view returns (uint256);


    function setCap(uint256 _maxCap) external;


    function balance(address _token) external view returns (uint256);


    function getTokens() external view returns (address[] memory);


    function addToken(address _token) external;


    function removeToken(address _token) external;


    function getTokenInPool(address _token) external view returns (bool);


    function calcTokensForAmount(uint256 _amount)
        external
        view
        returns (address[] memory tokens, uint256[] memory amounts);


    function calcTokensForAmountExit(uint256 _amount)
        external
        view
        returns (address[] memory tokens, uint256[] memory amounts);

}// MIT
pragma solidity ^0.7.1;

interface IERC20Facet {

    
    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function mint(address _receiver, uint256 _amount) external;


    function burn(address _from, uint256 _amount) external;


    function initialize(
        uint256 _initialSupply,
        string memory _name,
        string memory _symbol
    ) external;

}// MIT
pragma solidity ^0.7.1;

interface ICallFacet {


    event CallerAdded(address indexed caller);
    event CallerRemoved(address indexed caller);
    event Call(address indexed target, bytes data, uint256 value);

    function call(
        address[] memory _targets,
        bytes[] memory _calldata,
        uint256[] memory _values
    ) external;


    function callNoValue(
        address[] memory _targets,
        bytes[] memory _calldata
    ) external;


    function singleCall(
        address _target,
        bytes calldata _calldata,
        uint256 _value
    ) external;


    function addCaller(address _caller) external;


    function removeCaller(address _caller) external;


    function canCall(address _caller) external view returns (bool);


    function getCallers() external view returns (address[] memory);

}// MIT
pragma solidity ^0.7.1;


interface IExperiPie is IERC20, IBasketFacet, IERC20Facet, IERC173, ICallFacet {

}// MIT
pragma solidity ^0.7.1;


contract LendingManager is Ownable {

    using Math for uint256;

    LendingRegistry public lendingRegistry;
    IExperiPie public basket;

    event Lend(address indexed underlying, uint256 amount, bytes32 indexed protocol);
    event UnLend(address indexed wrapped, uint256 amount);
    constructor(address _lendingRegistry, address _basket) public {
        lendingRegistry = LendingRegistry(_lendingRegistry);
        basket = IExperiPie(_basket);
    }

    function lend(address _underlying, uint256 _amount, bytes32 _protocol) public onlyOwner {

        uint256 amount = _amount.min(IERC20(_underlying).balanceOf(address(basket)));

        (
            address[] memory _targets,
            bytes[] memory _data
        ) = lendingRegistry.getLendTXData(_underlying, amount, _protocol);

        basket.callNoValue(_targets, _data);

        removeToken(_underlying);

        addToken(lendingRegistry.underlyingToProtocolWrapped(_underlying, _protocol));

        emit Lend(_underlying, _amount, _protocol);
    }

    function unlend(address _wrapped, uint256 _amount) public onlyOwner {

        uint256 amount = _amount.min(IERC20(_wrapped).balanceOf(address(basket)));

        (
            address[] memory _targets,
            bytes[] memory _data
        ) = lendingRegistry.getUnlendTXData(_wrapped, amount);
        basket.callNoValue(_targets, _data);

        addToken(lendingRegistry.wrappedToUnderlying(_wrapped));

        removeToken(_wrapped);

        emit UnLend(_wrapped, _amount);
    }

    function bounce(address _wrapped, uint256 _amount, bytes32 _toProtocol) external {

       unlend(_wrapped, _amount);
       lend(lendingRegistry.wrappedToUnderlying(_wrapped), uint256(-1), _toProtocol);
    }

    function removeToken(address _token) internal {

        uint256 balance = basket.balance(_token);
        bool inPool = basket.getTokenInPool(_token);
        if(balance != 0 || !inPool) {
            return;
        }

        basket.singleCall(address(basket), abi.encodeWithSelector(basket.removeToken.selector, _token), 0);
    }

    function addToken(address _token) internal {

        uint256 balance = basket.balance(_token);
        bool inPool = basket.getTokenInPool(_token);
        if(balance == 0 || inPool) {
            return;
        }

        basket.singleCall(address(basket), abi.encodeWithSelector(basket.addToken.selector, _token), 0);
    }
 
}// MIT
pragma solidity ^0.7.1;

interface ISynthetix {

    function exchange(bytes32 sourceCurrencyKey, uint256 sourceAmount, bytes32 destinationCurrencyKey) external;

}// MIT
pragma solidity ^0.7.1;


interface IPriceReferenceFeed {

    function getRoundData(uint80 _roundId) external view returns (
        uint80 roundId, 
        int256 answer, 
        uint256 startedAt, 
        uint256 updatedAt, 
        uint80 answeredInRound
    );

    function latestRoundData() external view returns (
        uint80 roundId, 
        int256 answer, 
        uint256 startedAt, 
        uint256 updatedAt, 
        uint80 answeredInRound
    );

}// MIT
pragma solidity ^0.7.1;


contract RSISynthetixManager {


    address public immutable assetShort;
    address public immutable assetLong;
    bytes32 public immutable assetShortKey;
    bytes32 public immutable assetLongKey;

    IPriceReferenceFeed public immutable priceFeed;
    IExperiPie public immutable basket;
    ISynthetix public immutable synthetix;

    struct RoundData {
        uint80 roundId;
        int256 answer;
        uint256 startedAt; 
        uint256 updatedAt; 
        uint80 answeredInRound;
    }

    event Rebalanced(address indexed basket, address indexed fromToken, address indexed toToken);

    constructor(
        address _assetShort,
        address _assetLong,
        bytes32 _assetShortKey,
        bytes32 _assetLongKey,
        address _priceFeed,
        address _basket,
        address _synthetix
    ) {
        assetShort = _assetShort;
        assetLong = _assetLong;
        assetShortKey = _assetShortKey;
        assetLongKey = _assetLongKey;
        priceFeed = IPriceReferenceFeed(_priceFeed);
        basket = IExperiPie(_basket);
        synthetix = ISynthetix(_synthetix);
    }


    function rebalance() external {

        RoundData memory roundData = readLatestRound();
        require(roundData.updatedAt > 0, "Round not complete");

        if(roundData.answer <= 30 * 10**18) {
            long();
            return;
        } else if(roundData.answer >= 70 * 10**18) {
            short();
            return;
        }
    }

    function long() internal {

        IERC20 currentToken = IERC20(getCurrentToken());
        require(address(currentToken) == assetShort, "Can only long when short");

        uint256 currentTokenBalance = currentToken.balanceOf(address(basket));

        address[] memory targets = new address[](4);
        bytes[] memory data = new bytes[](4);
        uint256[] memory values = new uint256[](4);

        targets[0] = address(basket);
        data[0] = setLockData(block.number + 30);

        targets[1] = address(synthetix);
        data[1] = abi.encodeWithSelector(synthetix.exchange.selector, assetShortKey, currentTokenBalance, assetLongKey);


        targets[2] = address(basket);
        data[2] = abi.encodeWithSelector(basket.removeToken.selector, assetShort);

        targets[3] = address(basket);
        data[3] = abi.encodeWithSelector(basket.addToken.selector, assetLong);

        basket.call(targets, data, values);

        require(currentToken.balanceOf(address(basket)) == 0, "Current token balance should be zero");
        require(IERC20(assetLong).balanceOf(address(basket)) >= 10**6, "Amount too small");

        emit Rebalanced(address(basket), assetShort, assetLong);
    }

    function short() internal {

        IERC20 currentToken = IERC20(getCurrentToken());
        require(address(currentToken) == assetLong, "Can only short when long");

        uint256 currentTokenBalance = currentToken.balanceOf(address(basket));

        address[] memory targets = new address[](4);
        bytes[] memory data = new bytes[](4);
        uint256[] memory values = new uint256[](4);

        targets[0] = address(basket);
        data[0] = setLockData(block.number + 30);

        targets[1] = address(synthetix);
        data[1] = abi.encodeWithSelector(synthetix.exchange.selector, assetLongKey, currentTokenBalance, assetShortKey);

        targets[2] = address(basket);
        data[2] = abi.encodeWithSelector(basket.removeToken.selector, assetLong);

        targets[3] = address(basket);
        data[3] = abi.encodeWithSelector(basket.addToken.selector, assetShort);

        basket.call(targets, data, values);

        require(currentToken.balanceOf(address(basket)) == 0, "Current token balance should be zero");
        

        emit Rebalanced(address(basket), assetShort, assetLong);
    }

    function getCurrentToken() public view returns(address) {

        address[] memory tokens = basket.getTokens();
        require(tokens.length == 1, "RSI Pie can only have 1 asset at the time");
        return tokens[0];
    }


    function setLockData(uint256 _block) internal returns(bytes memory data) {

        bytes memory data = abi.encodeWithSelector(basket.setLock.selector, _block);
        return data;
    }
    function readRound(uint256 _round) public view returns(RoundData memory data) {

        (
            uint80 roundId, 
            int256 answer, 
            uint256 startedAt, 
            uint256 updatedAt, 
            uint80 answeredInRound
        ) = priceFeed.getRoundData(uint80(_round));

        return RoundData({
            roundId: roundId,
            answer: answer,
            startedAt: startedAt,
            updatedAt: updatedAt,
            answeredInRound: answeredInRound
        });
    }

    function readLatestRound() public view returns(RoundData memory data) {

        (
            uint80 roundId, 
            int256 answer, 
            uint256 startedAt, 
            uint256 updatedAt, 
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        return RoundData({
            roundId: roundId,
            answer: answer,
            startedAt: startedAt,
            updatedAt: updatedAt,
            answeredInRound: answeredInRound
        });
    }

}// MIT

pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.7.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity ^0.7.1;

library LibERC20Storage {

  bytes32 constant ERC_20_STORAGE_POSITION = keccak256(
    "PCToken.storage.location"
  );

  struct ERC20Storage {
    string name;
    string symbol;
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
  }

  function erc20Storage() internal pure returns (ERC20Storage storage es) {

    bytes32 position = ERC_20_STORAGE_POSITION;
    assembly {
      es.slot := position
    }
  }
}// MIT
pragma solidity ^0.7.1;


library LibERC20 {

  using SafeMath for uint256;

  event Transfer(address indexed from, address indexed to, uint256 amount);

  function mint(address _to, uint256 _amount) internal {

    LibERC20Storage.ERC20Storage storage es = LibERC20Storage.erc20Storage();

    es.balances[_to] = es.balances[_to].add(_amount);
    es.totalSupply = es.totalSupply.add(_amount);
    emit Transfer(address(0), _to, _amount);
  }

  function burn(address _from, uint256 _amount) internal {

    LibERC20Storage.ERC20Storage storage es = LibERC20Storage.erc20Storage();

    es.balances[_from] = es.balances[_from].sub(_amount);
    es.totalSupply = es.totalSupply.sub(_amount);
    emit Transfer(_from, address(0), _amount);
  }
}// MIT
pragma solidity ^0.7.1;

library LibReentryProtectionStorage {

  bytes32 constant REENTRY_STORAGE_POSITION = keccak256(
    "diamond.standard.reentry.storage"
  );

  struct RPStorage {
    uint256 lockCounter;
  }

  function rpStorage() internal pure returns (RPStorage storage bs) {

    bytes32 position = REENTRY_STORAGE_POSITION;
    assembly {
      bs.slot := position
    }
  }
}// MIT
pragma solidity ^0.7.1;


contract ReentryProtection {

  modifier noReentry {

    LibReentryProtectionStorage.RPStorage storage s = LibReentryProtectionStorage.rpStorage();
    s.lockCounter++;
    uint256 lockValue = s.lockCounter;
    _;
    require(
      lockValue == s.lockCounter,
      "ReentryProtectionFacet.noReentry: reentry detected"
    );
  }
}// MIT
pragma solidity ^0.7.1;

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT
pragma solidity ^0.7.1;


contract MockToken is ERC20 {
    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {}

    function mint(uint256 _amount, address _issuer) external {
        _mint(_issuer, _amount);
    }

    function burn(uint256 _amount, address _from) external {
        _burn(_from, _amount);
    }

}// MIT
pragma solidity ^0.7.0;


contract ERC20FactoryContract {
    event TokenCreated(address tokenAddress);

    function deployNewToken(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        address _issuer
    ) public returns (address) {
        MockToken t = new MockToken(_name, _symbol);
        t.mint(_totalSupply, _issuer);
        emit TokenCreated(address(t));
    }
}// MIT
pragma solidity ^0.7.1;


contract ManualPriceReferenceFeed is Ownable, IPriceReferenceFeed {
    uint256 public latestResult;
    uint256 public lastUpdate;

    function update(uint256 _value) external onlyOwner {
        latestResult = _value;
        lastUpdate = block.timestamp;
    }

    function getRoundData(uint80 _roundId) external override view returns (
        uint80 roundId, 
        int256 answer, 
        uint256 startedAt, 
        uint256 updatedAt, 
        uint80 answeredInRound
    ) {
        require(false, "NOT_SUPPORTED");
    }
    function latestRoundData() external override view returns (
        uint80 roundId, 
        int256 answer, 
        uint256 startedAt, 
        uint256 updatedAt, 
        uint80 answeredInRound
    ) {
        updatedAt = lastUpdate;
        answer = int256(latestResult);
    }
}// MIT
pragma solidity ^0.7.1;


contract MockAaveLendingPool is IAaveLendingPool {
    IERC20 public token;
    MockToken public aToken;

    bool public revertDeposit;

    constructor(address _token, address _aToken) public {
        token = IERC20(_token);
        aToken = MockToken(_aToken);
    }

    function deposit(address _reserve, uint256 _amount, uint16 _refferalCode) external override {
        require(!revertDeposit, "Deposited revert");
        require(token.transferFrom(msg.sender, address(aToken), _amount), "Transfer failed");
        aToken.mint(_amount, msg.sender);
    } 

    function setRevertDeposit(bool _doRevert) external {
        revertDeposit = _doRevert;
    }
}// MIT
pragma solidity ^0.7.1;


contract MockAToken is MockToken {
    IERC20 public token;

    bool public revertRedeem;

    constructor(address _token) MockToken("MockAToken", "MATKN") public {
        token = IERC20(_token);
    }

    function redeem(uint256 _amount) external {
        require(!revertRedeem, "Reverted");

        if(_amount == uint256(-1)) {
            _amount = balanceOf(msg.sender);
        }

        _burn(msg.sender, _amount);
        require(token.transfer(msg.sender, _amount), "Transfer failed");
    }

    function setRevertRedeem(bool _doRevert) external {
        revertRedeem = _doRevert;
    }
}// MIT
pragma solidity ^0.7.1;



contract MockCToken is MockToken {
    using SafeMath for uint256;
    uint256 public exchangeRate = 1 ether / 5;
    MockToken public underlying;

    uint256 public errorCode;
    constructor(address _underlying) MockToken("cTOKEN", "cToken") public {
        underlying = MockToken(_underlying);
    }

    function mint(uint256 _amount) external returns(uint256) {
        require(underlying.transferFrom(msg.sender, address(this), _amount), "MockCToken.mint: transferFrom failed");

        uint256 mintAmount = _amount.mul(10**18).div(exchangeRate);
        _mint(msg.sender, mintAmount);

        return errorCode;
    }

    function exchangeRateStored() external view returns(uint256) {
        return exchangeRate;
    }

    function redeem(uint256 _amount) external returns(uint256) {
        _burn(msg.sender, _amount);

        uint256 underlyingAmount = _amount.mul(exchangeRate).div(10**18);
        underlying.mint(underlyingAmount, msg.sender);

        return errorCode;
    }

    function redeemUnderlying(uint256 _amount) external returns(uint256) {
        uint256 internalAmount = _amount.mul(10**18).div(exchangeRate);
        _burn(msg.sender, internalAmount);

        underlying.mint(_amount, msg.sender);

        return errorCode;
    }

    function balanceOfUnderlying(address _owner) external returns(uint256) {
        return balanceOf(_owner).mul(exchangeRate).div(10**18);
    }

    function setErrorCode(uint256 _value) public {
        errorCode = _value;
    }
}// MIT
pragma solidity ^0.7.1;


contract MockLendingLogic is ILendingLogic {
    function lend(address _underlying, uint256 _amount) external view override returns(address[] memory targets, bytes[] memory data) {
        targets = new address[](1);
        data = new bytes[](1);

        targets[0] = _underlying;
        data[0] = bytes(abi.encode(_amount));
    }
    function unlend(address _wrapped, uint256 _amount) external view override returns(address[] memory targets, bytes[] memory data) {
        targets = new address[](1);
        data = new bytes[](1);

        targets[0] = _wrapped;
        data[0] = bytes(abi.encode(_amount));
    }
}// MIT
pragma solidity ^0.7.1;


contract MockSynthetix is ISynthetix {
    using SafeMath for uint256;

    mapping(bytes32=>MockToken) public keyToToken;
    mapping(bytes32=>uint256) public tokenPrice;

    uint256 public subtractSourceAmount;
    uint256 public subtractOutputAmount;

    function setSubtractSourceAmount(uint256 _amount) external {
        subtractSourceAmount = _amount;
    }

    function setSubtractOutputAmount(uint256 _amount) external {
        subtractOutputAmount = _amount;
    }

    function exchange(bytes32 _sourceCurrencyKey, uint256 _sourceAmount, bytes32 _destinationCurrencyKey) external override {
        uint256 sourcePrice = tokenPrice[_sourceCurrencyKey];
        uint256 destinationPrice = tokenPrice[_destinationCurrencyKey];
        uint256 outputAmount = _sourceAmount.mul(sourcePrice).div(destinationPrice);

        getOrSetToken(_sourceCurrencyKey).burn(_sourceAmount.sub(subtractSourceAmount), msg.sender);
        getOrSetToken(_destinationCurrencyKey).mint(outputAmount.sub(subtractOutputAmount), msg.sender);
    }

    function getOrSetToken(bytes32 _currencyKey) public returns(MockToken) {
        if(address(keyToToken[_currencyKey]) == address(0)) {
            keyToToken[_currencyKey] = new MockToken(string(abi.encode(_currencyKey)), string(abi.encode(_currencyKey)));
            tokenPrice[_currencyKey] = 1 ether;
        }

        return keyToToken[_currencyKey];
    }

    function setPrice(bytes32 _currencyKey, uint256 _price) external {
        tokenPrice[_currencyKey] = _price;
    }

    function getToken(bytes32 _currencyKey) external view returns(address) {
        return address(keyToToken[_currencyKey]);
    }
}