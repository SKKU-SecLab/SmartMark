pragma solidity >=0.7.0;

interface IControllable {

    event ControllerAdded(address indexed contractAddress, address indexed controllerAddress);
    event ControllerRemoved(address indexed contractAddress, address indexed controllerAddress);

    function addController(address controller) external;


    function isController(address controller) external view returns (bool);


    function relinquishControl() external;

}// MIT

pragma solidity >=0.7.0;


abstract contract Controllable is IControllable {
    mapping(address => bool) _controllers;

    modifier onlyController() {
        require(
            _controllers[msg.sender] == true || address(this) == msg.sender,
            "Controllable: caller is not a controller"
        );
        _;
    }

    function _addController(address _controller) internal {
        _controllers[_controller] = true;
    }

    function addController(address _controller) external override onlyController {
        _controllers[_controller] = true;
    }

    function isController(address _address) external view override returns (bool allowed) {
        allowed = _controllers[_address];
    }

    function relinquishControl() external view override onlyController {
        _controllers[msg.sender];
    }
}// MIT

pragma solidity >=0.7.0;
library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.4.24;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}// MIT

pragma solidity >=0.7.0;

interface INFTGemMultiToken {

    function mint(
        address account,
        uint256 tokenHash,
        uint256 amount
    ) external;


    function burn(
        address account,
        uint256 tokenHash,
        uint256 amount
    ) external;


    function allHeldTokens(address holder, uint256 _idx) external view returns (uint256);


    function allHeldTokensLength(address holder) external view returns (uint256);


    function allTokenHolders(uint256 _token, uint256 _idx) external view returns (address);


    function allTokenHoldersLength(uint256 _token) external view returns (uint256);


    function totalBalances(uint256 _id) external view returns (uint256);


    function allProxyRegistries(uint256 _idx) external view returns (address);


    function allProxyRegistriesLength() external view returns (uint256);


    function addProxyRegistry(address registry) external;


    function removeProxyRegistryAt(uint256 index) external;


    function getRegistryManager() external view returns (address);


    function setRegistryManager(address newManager) external;


    function lock(uint256 token, uint256 timeframe) external;


    function unlockTime(address account, uint256 token) external view returns (uint256);

}// MIT
pragma solidity >=0.7.0;

interface INFTGemFeeManager {


    event DefaultFeeDivisorChanged(address indexed operator, uint256 oldValue, uint256 value);
    event FeeDivisorChanged(address indexed operator, address indexed token, uint256 oldValue, uint256 value);
    event ETHReceived(address indexed manager, address sender, uint256 value);
    event LiquidityChanged(address indexed manager, uint256 oldValue, uint256 value);

    function liquidity(address token) external view returns (uint256);


    function defaultLiquidity() external view returns (uint256);


    function setDefaultLiquidity(uint256 _liquidityMult) external returns (uint256);


    function feeDivisor(address token) external view returns (uint256);


    function defaultFeeDivisor() external view returns (uint256);


    function setFeeDivisor(address token, uint256 _feeDivisor) external returns (uint256);


    function setDefaultFeeDivisor(uint256 _feeDivisor) external returns (uint256);


    function ethBalanceOf() external view returns (uint256);


    function balanceOF(address token) external view returns (uint256);


    function transferEth(address payable recipient, uint256 amount) external;


    function transferToken(
        address token,
        address recipient,
        uint256 amount
    ) external;


}// MIT

pragma solidity >=0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.7.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity >=0.7.0;

interface INFTGemPool {


    event NFTGemClaimCreated(address account, address pool, uint256 claimHash, uint256 length, uint256 quantity, uint256 amountPaid);

    event NFTGemERC20ClaimCreated(
        address account,
        address pool,
        uint256 claimHash,
        uint256 length,
        address token,
        uint256 quantity,
        uint256 conversionRate
    );

    event NFTGemClaimRedeemed(
        address account,
        address pool,
        uint256 claimHash,
        uint256 amountPaid,
        uint256 feeAssessed
    );

    event NFTGemERC20ClaimRedeemed(
        address account,
        address pool,
        uint256 claimHash,
        address token,
        uint256 ethPrice,
        uint256 tokenAmount,
        uint256 feeAssessed
    );

    event NFTGemCreated(address account, address pool, uint256 claimHash, uint256 gemHash, uint256 quantity);

    function setMultiToken(address token) external;


    function setGovernor(address addr) external;


    function setFeeTracker(address addr) external;


    function setSwapHelper(address addr) external;


    function mintGenesisGems(address creator, address funder) external;


    function createClaim(uint256 timeframe) external payable;


    function createClaims(uint256 timeframe, uint256 count) external payable;


    function createERC20Claim(address erc20token, uint256 tokenAmount) external;


    function createERC20Claims(address erc20token, uint256 tokenAmount, uint256 count) external;


    function collectClaim(uint256 claimHash) external;


    function initialize(
        string memory,
        string memory,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        address
    ) external;

}// MIT

pragma solidity >=0.7.0;

interface INFTGemGovernor {

    event GovernanceTokenIssued(address indexed receiver, uint256 amount);
    event FeeUpdated(address indexed proposal, address indexed token, uint256 newFee);
    event AllowList(address indexed proposal, address indexed token, bool isBanned);
    event ProjectFunded(address indexed proposal, address indexed receiver, uint256 received);
    event StakingPoolCreated(
        address indexed proposal,
        address indexed pool,
        string symbol,
        string name,
        uint256 ethPrice,
        uint256 minTime,
        uint256 maxTime,
        uint256 diffStep,
        uint256 maxClaims,
        address alllowedToken
    );

    function initialize(
        address _multitoken,
        address _factory,
        address _feeTracker,
        address _proposalFactory,
        address _swapHelper
    ) external;


    function createProposalVoteTokens(uint256 proposalHash) external;


    function destroyProposalVoteTokens(uint256 proposalHash) external;


    function executeProposal(address propAddress) external;


    function issueInitialGovernanceTokens(address receiver) external returns (uint256);


    function maybeIssueGovernanceToken(address receiver) external returns (uint256);


    function issueFuelToken(address receiver, uint256 amount) external returns (uint256);


    function createPool(
        string memory symbol,
        string memory name,
        uint256 ethPrice,
        uint256 minTime,
        uint256 maxTime,
        uint256 diffstep,
        uint256 maxClaims,
        address allowedToken
    ) external returns (address);


    function createSystemPool(
        string memory symbol,
        string memory name,
        uint256 ethPrice,
        uint256 minTime,
        uint256 maxTime,
        uint256 diffstep,
        uint256 maxClaims,
        address allowedToken
    ) external returns (address);


    function createNewPoolProposal(
        address,
        string memory,
        string memory,
        string memory,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        address
    ) external returns (address);


    function createChangeFeeProposal(
        address,
        string memory,
        address,
        address,
        uint256
    ) external returns (address);


    function createFundProjectProposal(
        address,
        string memory,
        address,
        string memory,
        uint256
    ) external returns (address);


    function createUpdateAllowlistProposal(
        address,
        string memory,
        address,
        address,
        bool
    ) external returns (address);

}// MIT
pragma solidity >=0.7.0;

interface ISwapQueryHelper {


    function coinQuote(address token, uint256 tokenAmount)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function factory() external pure returns (address);


    function COIN() external pure returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);


    function hasPool(address token) external view returns (bool);


    function getReserves(
        address pair
    ) external view returns (uint256, uint256);


    function pairFor(
        address tokenA,
        address tokenB
    ) external pure returns (address);


    function getPathForCoinToToken(address token) external pure returns (address[] memory);


}// MIT

pragma solidity >=0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT
pragma solidity >=0.7.0;

interface INFTGemPoolData {


    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function ethPrice() external view returns (uint256);

    function minTime() external view returns (uint256);

    function maxTime() external view returns (uint256);

    function difficultyStep() external view returns (uint256);

    function maxClaims() external view returns (uint256);


    function claimedCount() external view returns (uint256);

    function claimAmount(uint256 claimId) external view returns (uint256);

    function claimQuantity(uint256 claimId) external view returns (uint256);

    function mintedCount() external view returns (uint256);

    function totalStakedEth() external view returns (uint256);

    function tokenId(uint256 tokenHash) external view returns (uint256);

    function tokenType(uint256 tokenHash) external view returns (uint8);

    function allTokenHashesLength() external view returns (uint256);

    function allTokenHashes(uint256 ndx) external view returns (uint256);

    function nextClaimHash() external view returns (uint256);

    function nextGemHash() external view returns (uint256);

    function nextGemId() external view returns (uint256);

    function nextClaimId() external view returns (uint256);


    function claimUnlockTime(uint256 claimId) external view returns (uint256);

    function claimTokenAmount(uint256 claimId) external view returns (uint256);

    function stakedToken(uint256 claimId) external view returns (address);


    function allowedTokensLength() external view returns (uint256);

    function allowedTokens(uint256 idx) external view returns (address);

    function isTokenAllowed(address token) external view returns (bool);

    function addAllowedToken(address token) external;

    function removeAllowedToken(address token) external;

}// MIT
pragma solidity >=0.7.0;



contract NFTGemPoolData is INFTGemPoolData, Initializable {

    using SafeMath for uint256;

    string internal _symbol;
    string internal _name;

    uint256 internal _ethPrice;
    uint256 internal _minTime;
    uint256 internal _maxTime;
    uint256 internal _diffstep;
    uint256 internal _maxClaims;

    mapping(uint256 => uint8) internal _tokenTypes;
    mapping(uint256 => uint256) internal _tokenIds;
    uint256[] internal _tokenHashes;

    uint256 internal _nextGemId;
    uint256 internal _nextClaimId;
    uint256 internal _totalStakedEth;

    mapping(uint256 => uint256) internal claimLockTimestamps;
    mapping(uint256 => address) internal claimLockToken;
    mapping(uint256 => uint256) internal claimAmountPaid;
    mapping(uint256 => uint256) internal claimQuant;
    mapping(uint256 => uint256) internal claimTokenAmountPaid;

    address[] internal _allowedTokens;
    mapping(address => bool) internal _isAllowedMap;

    constructor() {}

    function symbol() external view override returns (string memory) {

        return _symbol;
    }

    function name() external view override returns (string memory) {

        return _name;
    }

    function ethPrice() external view override returns (uint256) {

        return _ethPrice;
    }

    function minTime() external view override returns (uint256) {

        return _minTime;
    }

    function maxTime() external view override returns (uint256) {

        return _maxTime;
    }

    function difficultyStep() external view override returns (uint256) {

        return _diffstep;
    }

    function maxClaims() external view override returns (uint256) {

        return _maxClaims;
    }

    function claimedCount() external view override returns (uint256) {

        return _nextClaimId;
    }

    function mintedCount() external view override returns (uint256) {

        return _nextGemId;
    }

    function totalStakedEth() external view override returns (uint256) {

        return _totalStakedEth;
    }

    function tokenType(uint256 tokenHash) external view override returns (uint8) {

        return _tokenTypes[tokenHash];
    }

    function tokenId(uint256 tokenHash) external view override returns (uint256) {

        return _tokenIds[tokenHash];
    }

    function allTokenHashesLength() external view override returns (uint256) {

        return _tokenHashes.length;
    }

    function allTokenHashes(uint256 ndx) external view override returns (uint256) {

        return _tokenHashes[ndx];
    }

    function nextClaimHash() external view override returns (uint256) {

        return _nextClaimHash();
    }

    function nextGemHash() external view override returns (uint256) {

        return _nextGemHash();
    }

    function nextClaimId() external view override returns (uint256) {

        return _nextClaimId;
    }

    function nextGemId() external view override returns (uint256) {

        return _nextGemId;
    }

    function allowedTokensLength() external view override returns (uint256) {

        return _allowedTokens.length;
    }

    function allowedTokens(uint256 idx) external view override returns (address) {

        return _allowedTokens[idx];
    }

    function isTokenAllowed(address token) external view override returns (bool) {

        return _isAllowedMap[token];
    }

    function addAllowedToken(address token) external override {

        if(!_isAllowedMap[token]) {
            _allowedTokens.push(token);
            _isAllowedMap[token] = true;
        }
    }

    function removeAllowedToken(address token) external override {

        if(_isAllowedMap[token]) {
            for(uint256 i = 0; i < _allowedTokens.length; i++) {
                if(_allowedTokens[i] == token) {
                   _allowedTokens[i] = _allowedTokens[_allowedTokens.length - 1];
                    delete _allowedTokens[_allowedTokens.length - 1];
                    _isAllowedMap[token] = false;
                    return;
                }
            }
        }
    }

    function claimAmount(uint256 claimHash) external view override returns (uint256) {

        return claimAmountPaid[claimHash];
    }

    function claimQuantity(uint256 claimHash) external view override returns (uint256) {

        return claimQuant[claimHash];
    }

    function claimUnlockTime(uint256 claimHash) external view override returns (uint256) {

        return claimLockTimestamps[claimHash];
    }

    function claimTokenAmount(uint256 claimHash) external view override returns (uint256) {

        return claimTokenAmountPaid[claimHash];
    }

    function stakedToken(uint256 claimHash) external view override returns (address) {

        return claimLockToken[claimHash];
    }

    function _addToken(uint256 tokenHash, uint8 tt) internal {

        require(tt == 1 || tt == 2, "INVALID_TOKENTYPE");
        _tokenHashes.push(tokenHash);
        _tokenTypes[tokenHash] = tt;
        _tokenIds[tokenHash] = tt == 1 ? __nextClaimId() : __nextGemId();
        if(tt == 2) {
            _increaseDifficulty();
        }
    }

    function __nextClaimId() private returns (uint256) {

        uint256 ncId = _nextClaimId;
        _nextClaimId = _nextClaimId.add(1);
        return ncId;
    }

    function __nextGemId() private returns (uint256) {

        uint256 ncId = _nextGemId;
        _nextGemId = _nextGemId.add(1);
        return ncId;
    }

    function _increaseDifficulty() private {

        uint256 diffIncrease = _ethPrice.div(_diffstep);
        _ethPrice = _ethPrice.add(diffIncrease);
    }

    function _nextGemHash() internal view returns (uint256) {

        return uint256(keccak256(abi.encodePacked("gem", address(this), _nextGemId)));
    }

    function _nextClaimHash() internal view returns (uint256) {

        return
            (_maxClaims != 0 && _nextClaimId <= _maxClaims) || _maxClaims == 0
                ? uint256(keccak256(abi.encodePacked("claim", address(this), _nextClaimId)))
                : 0;
    }

}// MIT

pragma solidity >=0.7.0;



contract NFTGemPool is Initializable, NFTGemPoolData, INFTGemPool {

    using SafeMath for uint256;

    address private _multitoken;
    address private _governor;
    address private _feeTracker;
    address private _swapHelper;

    function initialize (
        string memory __symbol,
        string memory __name,
        uint256 __ethPrice,
        uint256 __minTime,
        uint256 __maxTime,
        uint256 __diffstep,
        uint256 __maxClaims,
        address __allowedToken
    ) external override initializer {
        _symbol = __symbol;
        _name = __name;
        _ethPrice = __ethPrice;
        _minTime = __minTime;
        _maxTime = __maxTime;
        _diffstep = __diffstep;
        _maxClaims = __maxClaims;

        if(__allowedToken != address(0)) {
            _allowedTokens.push(__allowedToken);
            _isAllowedMap[__allowedToken] = true;
        }
    }

    function setGovernor(address addr) external override {

        require(_governor == address(0), "IMMUTABLE");
        _governor = addr;
    }

    function setFeeTracker(address addr) external override {

        require(_feeTracker == address(0), "IMMUTABLE");
        _feeTracker = addr;
    }

    function setMultiToken(address token) external override {

        require(_multitoken == address(0), "IMMUTABLE");
        _multitoken = token;
    }

    function setSwapHelper(address helper) external override {

        require(_swapHelper == address(0), "IMMUTABLE");
        _swapHelper = helper;
    }

    function mintGenesisGems(address creator, address funder) external override {

        require(_multitoken != address(0), "NO_MULTITOKEN");
        require(creator != address(0) && funder != address(0), "ZERO_DESTINATION");
        require(_nextGemId == 0, "ALREADY_MINTED");

        uint256 gemHash = _nextGemHash();
        INFTGemMultiToken(_multitoken).mint(creator, gemHash, 1);
        _addToken(gemHash, 2);

        gemHash = _nextGemHash();
        INFTGemMultiToken(_multitoken).mint(creator, gemHash, 1);
        _addToken(gemHash, 2);
    }

    function createClaim(uint256 timeframe) external payable override {

        _createClaim(timeframe);
    }

    function createClaims(uint256 timeframe, uint256 count) external payable override {

        _createClaims(timeframe, count);
    }

    function createERC20Claim(address erc20token, uint256 tokenAmount) external override {

        _createERC20Claim(erc20token, tokenAmount);
    }

    function createERC20Claims(address erc20token, uint256 tokenAmount, uint256 count) external override {

        _createERC20Claims(erc20token, tokenAmount, count);
    }


    receive() external payable {
        uint256 incomingEth = msg.value;

        uint256 minClaimCost = _ethPrice.div(_maxTime).mul(_minTime);
        require(incomingEth >= minClaimCost, "INSUFFICIENT_ETH");

        uint256 actualClaimTime = _minTime;

        if (incomingEth <= _ethPrice)  {
            actualClaimTime = _ethPrice.div(incomingEth).mul(_minTime);
        }

        _createClaim(actualClaimTime);
    }

    function _createClaim(uint256 timeframe) internal {

        require(timeframe >= _minTime, "TIMEFRAME_TOO_SHORT");

        require((_maxTime != 0 && timeframe <= _maxTime) || _maxTime == 0, "TIMEFRAME_TOO_LONG");

        uint256 cost = _ethPrice.mul(_minTime).div(timeframe);
        require(msg.value > cost, "INSUFFICIENT_ETH");

        uint256 claimHash = _nextClaimHash();
        require(claimHash != 0, "NO_MORE_CLAIMABLE");

        INFTGemMultiToken(_multitoken).mint(msg.sender, claimHash, 1);
        _addToken(claimHash, 1);

        uint256 _claimUnlockTime = block.timestamp.add(timeframe);
        claimLockTimestamps[claimHash] = _claimUnlockTime;
        claimAmountPaid[claimHash] = cost;
        claimQuant[claimHash] = 1;

        _totalStakedEth = _totalStakedEth.add(cost);

        INFTGemGovernor(_governor).maybeIssueGovernanceToken(msg.sender);
        INFTGemGovernor(_governor).issueFuelToken(msg.sender, cost);

        emit NFTGemClaimCreated(msg.sender, address(this), claimHash, timeframe, 1, cost);

        if (msg.value > cost) {
            (bool success, ) = payable(msg.sender).call{value: msg.value.sub(cost)}("");
            require(success, "REFUND_FAILED");
        }
    }

    function _createClaims(uint256 timeframe, uint256 count) internal {

        require(timeframe >= _minTime, "TIMEFRAME_TOO_SHORT");
        require(msg.value != 0, "ZERO_BALANCE");
        require(count != 0, "ZERO_QUANTITY");
        require((_maxTime != 0 && timeframe <= _maxTime) || _maxTime == 0, "TIMEFRAME_TOO_LONG");

        uint256 adjustedBalance = msg.value.div(count);

        uint256 cost = _ethPrice.mul(_minTime).div(timeframe);
        require(adjustedBalance >= cost, "INSUFFICIENT_ETH");

        uint256 claimHash = _nextClaimHash();
        require(claimHash != 0, "NO_MORE_CLAIMABLE");

        INFTGemMultiToken(_multitoken).mint(msg.sender, claimHash, 1);
        _addToken(claimHash, 1);

        uint256 _claimUnlockTime = block.timestamp.add(timeframe);
        claimLockTimestamps[claimHash] = _claimUnlockTime;
        claimAmountPaid[claimHash] = cost.mul(count);
        claimQuant[claimHash] = count;

        INFTGemGovernor(_governor).maybeIssueGovernanceToken(msg.sender);
        INFTGemGovernor(_governor).issueFuelToken(msg.sender, cost);

        emit NFTGemClaimCreated(msg.sender, address(this), claimHash, timeframe, count, cost);

        _totalStakedEth = _totalStakedEth.add(cost.mul(count));

        if (msg.value > cost.mul(count)) {
            (bool success, ) = payable(msg.sender).call{value: msg.value.sub(cost.mul(count))}("");
            require(success, "REFUND_FAILED");
        }
    }

    function _createERC20Claim(address erc20token, uint256 tokenAmount) internal {

        require(erc20token != address(0), "INVALID_ERC20_TOKEN");

        require((_allowedTokens.length > 0 && _isAllowedMap[erc20token]) || _allowedTokens.length == 0, "TOKEN_DISALLOWED");

        require(ISwapQueryHelper(_swapHelper).hasPool(erc20token) == true, "NO_UNISWAP_POOL");

        require(tokenAmount >= 0, "NO_PAYMENT_INCLUDED");

        (uint256 ethereum, uint256 tokenReserve, uint256 ethReserve) = ISwapQueryHelper(_swapHelper).coinQuote(erc20token, tokenAmount);

        uint256 liquidity = INFTGemFeeManager(_feeTracker).liquidity(erc20token);

        require(ethReserve >= ethereum.mul(liquidity), "INSUFFICIENT_ETH_LIQUIDITY");

        require(tokenReserve >= tokenAmount.mul(liquidity), "INSUFFICIENT_TOKEN_LIQUIDITY");

        require(ethereum <= _ethPrice, "OVERPAYMENT");

        uint256 maturityTime = _ethPrice.mul(_minTime).div(ethereum);

        require(maturityTime >= _minTime, "INSUFFICIENT_TIME");

        uint256 claimHash = _nextClaimHash();
        require(claimHash != 0, "NO_MORE_CLAIMABLE");

        IERC20(erc20token).transferFrom(msg.sender, address(this), tokenAmount);

        INFTGemMultiToken(_multitoken).mint(msg.sender, claimHash, 1);
        _addToken(claimHash, 1);

        uint256 _claimUnlockTime = block.timestamp.add(maturityTime);
        claimLockTimestamps[claimHash] = _claimUnlockTime;
        claimAmountPaid[claimHash] = ethereum;
        claimLockToken[claimHash] = erc20token;
        claimTokenAmountPaid[claimHash] = tokenAmount;
        claimQuant[claimHash] = 1;

        _totalStakedEth = _totalStakedEth.add(ethereum);

        INFTGemGovernor(_governor).maybeIssueGovernanceToken(msg.sender);
        INFTGemGovernor(_governor).issueFuelToken(msg.sender, ethereum);

        emit NFTGemERC20ClaimCreated(msg.sender, address(this), claimHash, maturityTime, erc20token, 1, ethereum);
    }

    function _createERC20Claims(address erc20token, uint256 tokenAmount, uint256 count) internal {

        require(erc20token != address(0), "INVALID_ERC20_TOKEN");

        require((_allowedTokens.length > 0 && _isAllowedMap[erc20token]) || _allowedTokens.length == 0, "TOKEN_DISALLOWED");

        require(count != 0, "ZERO_QUANTITY");

        require(ISwapQueryHelper(_swapHelper).hasPool(erc20token) == true, "NO_UNISWAP_POOL");

        require(tokenAmount >= 0, "NO_PAYMENT_INCLUDED");

        (uint256 ethereum, uint256 tokenReserve, uint256 ethReserve) = ISwapQueryHelper(_swapHelper).coinQuote(
            erc20token,
            tokenAmount.div(count)
        );

        require(ethReserve >= ethereum.mul(100).mul(count), "INSUFFICIENT_ETH_LIQUIDITY");

        require(tokenReserve >= tokenAmount.mul(100).mul(count), "INSUFFICIENT_TOKEN_LIQUIDITY");

        require(ethereum <= _ethPrice, "OVERPAYMENT");

        uint256 maturityTime = _ethPrice.mul(_minTime).div(ethereum);

        require(maturityTime >= _minTime, "INSUFFICIENT_TIME");

        uint256 claimHash = _nextClaimHash();
        require(claimHash != 0, "NO_MORE_CLAIMABLE");

        INFTGemMultiToken(_multitoken).mint(msg.sender, claimHash, 1);
        _addToken(claimHash, 1);

        uint256 _claimUnlockTime = block.timestamp.add(maturityTime);
        claimLockTimestamps[claimHash] = _claimUnlockTime;
        claimAmountPaid[claimHash] = ethereum;
        claimLockToken[claimHash] = erc20token;
        claimTokenAmountPaid[claimHash] = tokenAmount;
        claimQuant[claimHash] = count;

        _totalStakedEth = _totalStakedEth.add(ethereum);

        INFTGemGovernor(_governor).maybeIssueGovernanceToken(msg.sender);
        INFTGemGovernor(_governor).issueFuelToken(msg.sender, ethereum);

        emit NFTGemERC20ClaimCreated(msg.sender, address(this), claimHash, maturityTime, erc20token, count, ethereum);

        IERC20(erc20token).transferFrom(msg.sender, address(this), tokenAmount);
    }

    function collectClaim(uint256 claimHash) external override {

        require(IERC1155(_multitoken).balanceOf(msg.sender, claimHash) == 1, "NOT_CLAIM_OWNER");
        uint256 unlockTime = claimLockTimestamps[claimHash];
        uint256 unlockPaid = claimAmountPaid[claimHash];
        require(unlockTime != 0 && unlockPaid > 0, "INVALID_CLAIM");

        address tokenUsed = claimLockToken[claimHash];
        uint256 unlockTokenPaid = claimTokenAmountPaid[claimHash];

        bool isMature = unlockTime < block.timestamp;

        INFTGemMultiToken(_multitoken).burn(msg.sender, claimHash, 1);

        if (tokenUsed != address(0)) {
            uint256 feePortion = 0;
            if (isMature == true) {
                uint256 poolDiv = INFTGemFeeManager(_feeTracker).feeDivisor(address(this));
                uint256 divisor = INFTGemFeeManager(_feeTracker).feeDivisor(tokenUsed);
                uint256 feeNum = poolDiv != divisor ? divisor : poolDiv;
                feePortion = unlockTokenPaid.div(feeNum);
            }
            IERC20(tokenUsed).transferFrom(address(this), _feeTracker, feePortion);
            IERC20(tokenUsed).transferFrom(address(this), msg.sender, unlockTokenPaid.sub(feePortion));

            emit NFTGemERC20ClaimRedeemed(
                msg.sender,
                address(this),
                claimHash,
                tokenUsed,
                unlockPaid,
                unlockTokenPaid,
                feePortion
            );
        } else {
            uint256 feePortion = 0;
            if (isMature == true) {
                uint256 divisor = INFTGemFeeManager(_feeTracker).feeDivisor(address(0));
                feePortion = unlockPaid.div(divisor);
            }
            payable(_feeTracker).transfer(feePortion);
            payable(msg.sender).transfer(unlockPaid.sub(feePortion));

            emit NFTGemClaimRedeemed(msg.sender, address(this), claimHash, unlockPaid, feePortion);
        }

        _totalStakedEth = _totalStakedEth.sub(unlockPaid);

        if (!isMature) {
            return;
        }

        uint256 nextHash = this.nextGemHash();

        INFTGemMultiToken(_multitoken).mint(msg.sender, nextHash, claimQuant[claimHash]);
        _addToken(nextHash, 2);

        INFTGemGovernor(_governor).maybeIssueGovernanceToken(msg.sender);
        INFTGemGovernor(_governor).issueFuelToken(msg.sender, unlockPaid);

        emit NFTGemCreated(msg.sender, address(this), claimHash, nextHash, claimQuant[claimHash]);
    }

}// MIT

pragma solidity >=0.6.0;

library Create2 {

    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address) {

        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {

        return computeAddress(salt, bytecodeHash, address(this));
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {

        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(uint160(uint256(_data)));
    }
}// MIT

pragma solidity >=0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity >=0.7.0;


contract ERC20Constructorless is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}// MIT
pragma solidity >=0.7.0;

interface IERC20WrappedGem {
    function wrap(uint256 quantity) external;

    function unwrap(uint256 quantity) external;

    event Wrap(address indexed account, uint256 quantity);
    event Unwrap(address indexed account, uint256 quantity);

    function initialize(
        string memory tokenSymbol,
        string memory tokenName,
        address poolAddress,
        address tokenAddress,
        uint8 decimals
    ) external;
}// MIT

pragma solidity >=0.7.0;


interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}// MIT

pragma solidity >=0.7.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity >=0.7.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
                ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}// MIT

pragma solidity >=0.7.0;


contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}// MIT

pragma solidity >=0.7.0;



contract ERC20WrappedGem is ERC20Constructorless, ERC1155Holder, IERC20WrappedGem, Initializable {
    using SafeMath for uint256;

    address private token;
    address private pool;
    uint256 private rate;

    uint256[] private ids;
    uint256[] private amounts;

    function initialize(
        string memory name,
        string memory symbol,
        address gemPool,
        address gemToken,
        uint8 decimals
    ) external override initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        token = gemToken;
        pool = gemPool;
    }

    function _transferERC1155(
        address from,
        address to,
        uint256 quantity
    ) internal {
        uint256 tq = quantity;
        delete ids;
        delete amounts;

        uint256 i = INFTGemMultiToken(token).allHeldTokensLength(from);
        require(i > 0, "INSUFFICIENT_GEMS");

        for (; i >= 0 && tq > 0; i = i.sub(1)) {
            uint256 tokenHash = INFTGemMultiToken(token).allHeldTokens(from, i);
            if (INFTGemPoolData(pool).tokenType(tokenHash) == 2) {
                uint256 oq = IERC1155(token).balanceOf(from, tokenHash);
                uint256 toTransfer = oq > tq ? tq : oq;
                ids.push(tokenHash);
                amounts.push(toTransfer);
                tq = tq.sub(toTransfer);
            }
            if (i == 0) break;
        }

        require(tq == 0, "INSUFFICIENT_GEMS");

        IERC1155(token).safeBatchTransferFrom(from, to, ids, amounts, "");
    }

    function wrap(uint256 quantity) external override {
        require(quantity != 0, "ZERO_QUANTITY");

        _transferERC1155(msg.sender, address(this), quantity);
        _mint(msg.sender, quantity.mul(10**decimals()));
        emit Wrap(msg.sender, quantity);
    }

    function unwrap(uint256 quantity) external override {
        require(quantity != 0, "ZERO_QUANTITY");
        require(balanceOf(msg.sender).mul(10**decimals()) >= quantity, "INSUFFICIENT_QUANTITY");

        _transferERC1155(address(this), msg.sender, quantity);
        _burn(msg.sender, quantity.mul(10**decimals()));
        emit Unwrap(msg.sender, quantity);
    }
}// MIT

pragma solidity >=0.7.0;

interface IERC20GemTokenFactory {
    event ERC20GemTokenCreated(
        address tokenAddress,
        address poolAddress,
        string tokenSymbol,
        string poolSymbol
    );

    function getItem(uint256 _symbolHash) external view returns (address);

    function allItems(uint256 idx) external view returns (address);

    function allItemsLength() external view returns (uint256);

    function createItem(
        string memory tokenSymbol,
        string memory tokenName,
        address poolAddress,
        address tokenAddress,
        uint8 decimals
    ) external returns (address payable);
}// MIT
pragma solidity >=0.7.0;


contract ERC20GemTokenFactory is Controllable, IERC20GemTokenFactory {
    address private operator;

    mapping(uint256 => address) private _getItem;
    address[] private _allItems;

    constructor() {
        _addController(msg.sender);
    }

    function getItem(uint256 _symbolHash) external view override returns (address gemPool) {
        gemPool = _getItem[_symbolHash];
    }

    function allItems(uint256 idx) external view override returns (address gemPool) {
        gemPool = _allItems[idx];
    }

    function allItemsLength() external view override returns (uint256) {
        return _allItems.length;
    }

    function createItem(
        string memory tokenSymbol,
        string memory tokenName,
        address poolAddress,
        address tokenAddress,
        uint8 decimals
    ) external override onlyController returns (address payable gemToken) {
        bytes32 salt = keccak256(abi.encodePacked(tokenSymbol));
        require(_getItem[uint256(salt)] == address(0), "GEMTOKEN_EXISTS"); // single check is sufficient
        require(poolAddress != address(0), "INVALID_POOL");

        bytes memory bytecode = type(ERC20WrappedGem).creationCode;

        gemToken = payable(Create2.deploy(0, salt, bytecode));

        IERC20WrappedGem(gemToken).initialize(tokenSymbol, tokenName, poolAddress, tokenAddress, decimals);

        _getItem[uint256(salt)] = gemToken;
        _allItems.push(gemToken);

        emit ERC20GemTokenCreated(gemToken, poolAddress, tokenSymbol, ERC20(gemToken).symbol());
    }
}