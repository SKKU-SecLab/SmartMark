
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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

pragma solidity >=0.4.24 <0.8.0;


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
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


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
pragma solidity 0.7.6;


interface IERC20Mintable is IERC20 {

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

}// MIT
pragma solidity 0.7.6;

interface IPriceOracle {

    function addToken(address token) external returns (bool success);

    function update(address token) external;

    function priceOf(address token, uint256 amount) external view returns (uint256 daiAmount);

}// MIT
pragma solidity 0.7.6;


contract Gateway is OwnableUpgradeable {

    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Mintable;
    using SafeMath for uint256;

    enum ReleaseMethod { MINT, UNLOCK }

    struct Token {
        address tokenAddress; // address on the chain that this contract is deployed to
        ReleaseMethod releaseMethod;
    }

    uint128 public minVariableFeeInUsd;
    uint128 public maxVariableFeeInUsd;
    uint128 public serviceFeePercent;
    uint128 public serviceFeePercentWhenNoPrice;
    uint256 public feeShareToTheTeam;
    address public orgWallet;
    address public teamWallet;
    IPriceOracle public priceOracle;
    Token[] public tokens;
    mapping(address => uint256) public addressToTokenId;
    mapping(address => uint256) public feeToWithdraw;
    mapping(uint256 => uint256) public networksFee;
    mapping(bytes32 => bool) public processedRequests;
    mapping(uint256 => mapping(uint256 => bool)) supportedChains;

    event TransferredToAnotherChain(
        uint256 indexed tokenId,
        uint256 indexed toChainId,
        address from,
        address to,
        uint256 amount,
        uint256 amountToTransfer,
        uint256 networkFee
    );
    event TransferredFromAnotherChain(
        bytes32 indexed requestKey,
        uint256 indexed tokenId,
        uint256 indexed fromChainId,
        address to,
        uint256 amount
    );
    event NetworkFeeUpdated(uint256 indexed chainId, uint256 newNetworkFee);
    event TokenAdded(uint256 indexed tokenId, address tokenAddress, ReleaseMethod releaseMethod, uint256[] supportedChains);
    event TokenSupportedChainsUpdated(uint256 indexed tokenId, uint256 chainId, bool active);
    event TokenUpdated(uint256 indexed tokenId, address tokenAddress, ReleaseMethod releaseMethod);

    function initialize(IPriceOracle _priceOracle, address _orgWallet, address _teamWallet) public initializer {

        __Ownable_init();
        require(_orgWallet != address(0), "Gateway: orgWallet cannot be set to 0 address");
        require(_teamWallet != address(0), "Gateway: teamWallet cannot be set to 0 address");

        minVariableFeeInUsd = 1e18; // $1
        maxVariableFeeInUsd = 100e18; // $100
        serviceFeePercentWhenNoPrice = 1e16; // 1%
        serviceFeePercent = 1e16; // 1%
        feeShareToTheTeam = 5e17; // 50%

        priceOracle = _priceOracle;
        orgWallet = _orgWallet;
        teamWallet = _teamWallet;
    }

    function addToken(address tokenAddress, ReleaseMethod releaseMethod, uint256[] calldata chains)
        external
        onlyOwner
    {

        require(tokenAddress != address(0), "Gateway: invalid tokenAddress");
        require(addressToTokenId[tokenAddress] == 0 && (tokens.length == 0 || tokens[0].tokenAddress != tokenAddress), "Gateway: address already added");

        uint256 tokenId = tokens.length;

        tokens.push(Token({
            tokenAddress: tokenAddress, 
            releaseMethod: releaseMethod
        }));
        addressToTokenId[tokenAddress] = tokenId;

        for (uint256 i = 0; i < chains.length; ++i) {
            supportedChains[tokenId][chains[i]] = true;
        }

        if (address(priceOracle) != address(0)) {
            priceOracle.addToken(tokenAddress);
        }

        emit TokenAdded(tokenId, tokenAddress, releaseMethod, chains);
    }

    function updateToken(uint256 tokenId, address tokenAddress, ReleaseMethod releaseMethod) public onlyOwner {

        require(tokens[tokenId].tokenAddress != address(0), "Gateway: invalid tokenId");
        address oldAddress = tokens[tokenId].tokenAddress;

        addressToTokenId[oldAddress] = 0;
        addressToTokenId[tokenAddress] = tokenId;
        tokens[tokenId].tokenAddress == tokenAddress;
        tokens[tokenId].releaseMethod == releaseMethod;

        emit TokenUpdated(tokenId, tokenAddress, releaseMethod);
    }

    function updateTokenSupportedChain(uint256 tokenId, uint256 chainId, bool active) public onlyOwner {

        require(networksFee[chainId] > 0,"Gateway: this chain hasn't networkFee set");
        supportedChains[tokenId][chainId] = active;
        emit TokenSupportedChainsUpdated(tokenId, chainId, active);
    }

    function transferFromAnotherChain(
        uint256 tokenId,
        uint256 fromChainId,
        bytes32 requestTxHash,
        uint256 logIndex,
        address to,
        uint256 amount
    ) external onlyOwner {

        require(tokens.length > tokenId, "Gateway: token doesn't exist");
        
        bytes32 requestKey = toRequestKey(fromChainId, requestTxHash, logIndex);
        require(!processedRequests[requestKey], "Gateway: request already processed");

        processedRequests[requestKey] = true;

        IERC20Mintable token = IERC20Mintable(tokens[tokenId].tokenAddress);
        if (tokens[tokenId].releaseMethod == ReleaseMethod.MINT) {
            token.mint(to, amount);
        } else {
            token.safeTransfer(to, amount);
        }

        emit TransferredFromAnotherChain(requestKey, tokenId, fromChainId, to, amount);
    }

    function toRequestKey(uint256 fromChainId, bytes32 requestTxHash, uint256 logIndex) public pure returns (bytes32 requestKey) {

        requestKey = keccak256(abi.encode(fromChainId, requestTxHash, logIndex));
    }

    function transferToAnotherChain(
        uint256 tokenId,
        uint256 toChainId,
        address to,
        uint256 amount
    ) external payable {

        require(amount > 0, "Gateway: amount should be > 0");
        require(msg.value == networksFee[toChainId], "Gateway: wrong network fee value");
        require(tokens.length > tokenId, "Gateway: token doesn't exist");
        require(supportedChains[tokenId][toChainId], "Gateway: chain isn't supported");

        IERC20Mintable token = IERC20Mintable(tokens[tokenId].tokenAddress);

        if (address(priceOracle) != address(0)) {
            priceOracle.update(address(token));
        }

        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 actualAmount = token.balanceOf(address(this)).sub(balanceBefore);

        uint256 fee = feeCalculation(address(token), actualAmount);

        if (tokens[tokenId].releaseMethod == ReleaseMethod.MINT) {
            token.burn(address(this), actualAmount.sub(fee));
        }

        feeToWithdraw[address(token)] = feeToWithdraw[address(token)].add(fee);

        emit TransferredToAnotherChain(tokenId, toChainId, msg.sender, to, actualAmount, actualAmount.sub(fee), networksFee[toChainId]);
    }

    function setFeeParameters(uint128 _minVariableFeeInUsd, uint128 _maxVariableFeeInUsd, uint128 _serviceFeePercentWhenNoPrice, uint128 _serviceFeePercent, uint256 _feeShareToTheTeam) public onlyOwner {

        require(_minVariableFeeInUsd < _maxVariableFeeInUsd, "Gateway: minVariableFeeInUsd should be < maxVariableFeeInUsd");
        require(_serviceFeePercentWhenNoPrice <= 1e18, "Gateway: Invalid serviceFeePercentWhenNoPrice");
        require(_serviceFeePercent <= 1e18, "Gateway: Invalid serviceFeePercent");
        require(_feeShareToTheTeam <= 1e18, "Gateway: Invalid feeShareToTheTeam");

        minVariableFeeInUsd = _minVariableFeeInUsd;
        maxVariableFeeInUsd = _maxVariableFeeInUsd;
        serviceFeePercentWhenNoPrice = _serviceFeePercentWhenNoPrice;
        serviceFeePercent = _serviceFeePercent;
        feeShareToTheTeam = _feeShareToTheTeam;
    }

    function getNetworkFee(uint256 toChainId) public view returns (uint256 networkFee) {

        networkFee = networksFee[toChainId];
    }

    function feeCalculation(address token, uint256 tokenAmount) public view returns(uint256) {

        uint256 usdAmount = address(priceOracle) != address(0) ? priceOracle.priceOf(token, tokenAmount) : 0;
        if (usdAmount == 0 || usdAmount <= minVariableFeeInUsd) {
            return tokenAmount.mul(serviceFeePercentWhenNoPrice).div(1e18);
        }
        
        uint256 feeInUsd = usdAmount.mul(serviceFeePercent).div(1e18);

        if (feeInUsd < minVariableFeeInUsd) {
            return tokenAmount.mul(minVariableFeeInUsd).div(usdAmount);
        } else if(feeInUsd > maxVariableFeeInUsd) {
            return tokenAmount.mul(maxVariableFeeInUsd).div(usdAmount);
        }

        return tokenAmount.mul(serviceFeePercent).div(1e18);
    }

    function updateNetworkFee(uint256 chainId, uint256 _networkFee) public onlyOwner {

        networksFee[chainId] = _networkFee;
        emit NetworkFeeUpdated(chainId, _networkFee);
    }

    function setPriceOracle(IPriceOracle _priceOracle) public onlyOwner {

        priceOracle = _priceOracle;
    }

    function withdrawAllFees() external {

        withdrawTokenFees(address(0));

        uint256 numberOfTokens = tokens.length;
        for (uint256 i = 0; i < numberOfTokens; ++i) {
            withdrawTokenFees(tokens[i].tokenAddress);
        }
    }

    function withdrawTokenFees(address token) public {

        uint256 total = getFeeToWithdraw(token);

        if (total == 0) {
            return;
        }

        if (token == address(0)) {
            Address.sendValue(payable(owner()), address(this).balance);
        } else  {
            delete feeToWithdraw[token];
            uint256 teamAmount = total.mul(feeShareToTheTeam).div(1e18);
            IERC20(token).safeTransfer(teamWallet, teamAmount);
            IERC20(token).safeTransfer(orgWallet, total.sub(teamAmount));
        }
    }

    function getFeeToWithdraw(address token) public view returns (uint256 amount) {

        if(token == address(0)) {
            amount = address(this).balance;
        } else {
            amount = feeToWithdraw[token];
        }
    }

    function updateWallets(address _orgWallet, address _teamWallet) public onlyOwner {

        require(_orgWallet != address(0), "Gateway: orgWallet cannot be set to 0 address");
        require(_teamWallet != address(0), "Gateway: teamWallet cannot be set to 0 address");
        orgWallet = _orgWallet;
        teamWallet = _teamWallet;
    }

    function getChainId() external pure returns (uint256 chainId) {

        assembly {
            chainId := chainid()
        }
    }
}