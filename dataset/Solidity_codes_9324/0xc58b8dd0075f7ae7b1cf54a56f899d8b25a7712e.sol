
pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// BUSL-1.1
pragma solidity >=0.7.6 <0.9.0;


interface IPoolShare {

    enum ShareKind {
        Principal,
        Yield
    }

    function kind() external view returns (ShareKind);


    function pool() external view returns (ITempusPool);


    function getPricePerFullShare() external returns (uint256);


    function getPricePerFullShareStored() external view returns (uint256);

}// MIT
pragma solidity >=0.7.6 <0.9.0;

interface IOwnable {

    event OwnershipProposed(address indexed currentOwner, address indexed proposedOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;


    function acceptOwnership() external;

}// MIT
pragma solidity >=0.7.6 <0.9.0;
pragma abicoder v2;

interface IVersioned {

    struct Version {
        uint16 major;
        uint16 minor;
        uint16 patch;
    }

    function version() external view returns (Version memory);

}// BUSL-1.1
pragma solidity >=0.7.6 <0.9.0;


interface ITempusFees is IOwnable {

    struct FeesConfig {
        uint256 depositPercent;
        uint256 earlyRedeemPercent;
        uint256 matureRedeemPercent;
    }

    function getFeesConfig() external view returns (FeesConfig memory);


    function setFeesConfig(FeesConfig calldata newFeesConfig) external;


    function maxDepositFee() external view returns (uint256);


    function maxEarlyRedeemFee() external view returns (uint256);


    function maxMatureRedeemFee() external view returns (uint256);


    function totalFees() external view returns (uint256);


    function transferFees(address recipient) external;

}

interface ITempusPool is ITempusFees, IVersioned {

    function protocolName() external view returns (bytes32);


    function yieldBearingToken() external view returns (address);


    function backingToken() external view returns (address);


    function backingTokenONE() external view returns (uint256);


    function principalShare() external view returns (IPoolShare);


    function yieldShare() external view returns (IPoolShare);


    function controller() external view returns (address);


    function startTime() external view returns (uint256);


    function maturityTime() external view returns (uint256);


    function exceptionalHaltTime() external view returns (uint256);


    function maximumNegativeYieldDuration() external view returns (uint256);


    function matured() external view returns (bool);


    function finalize() external;


    function onDepositYieldBearing(uint256 yieldTokenAmount, address recipient)
        external
        returns (
            uint256 mintedShares,
            uint256 depositedBT,
            uint256 fee,
            uint256 rate
        );


    function onDepositBacking(uint256 backingTokenAmount, address recipient)
        external
        payable
        returns (
            uint256 mintedShares,
            uint256 depositedYBT,
            uint256 fee,
            uint256 rate
        );


    function redeem(
        address from,
        uint256 principalAmount,
        uint256 yieldAmount,
        address recipient
    )
        external
        returns (
            uint256 redeemableYieldTokens,
            uint256 fee,
            uint256 rate
        );


    function redeemToBacking(
        address from,
        uint256 principalAmount,
        uint256 yieldAmount,
        address recipient
    )
        external
        payable
        returns (
            uint256 redeemableYieldTokens,
            uint256 redeemableBackingTokens,
            uint256 fee,
            uint256 rate
        );


    function estimatedMintedShares(uint256 amount, bool isBackingToken) external view returns (uint256);


    function estimatedRedeem(
        uint256 principals,
        uint256 yields,
        bool toBackingToken
    ) external view returns (uint256);


    function currentInterestRate() external view returns (uint256);


    function initialInterestRate() external view returns (uint256);


    function maturityInterestRate() external view returns (uint256);


    function pricePerYieldShare() external returns (uint256);


    function pricePerPrincipalShare() external returns (uint256);


    function pricePerYieldShareStored() external view returns (uint256);


    function pricePerPrincipalShareStored() external view returns (uint256);


    function numAssetsPerYieldToken(uint yieldTokens, uint interestRate) external view returns (uint);


    function numYieldTokensPerAsset(uint backingTokens, uint interestRate) external view returns (uint);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT
pragma solidity 0.8.10;


contract ERC20OwnerMintableToken is ERC20 {
    address public immutable manager;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        manager = msg.sender;
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == manager, "mint: only manager can mint");
        _mint(account, amount);
    }

    function burn(uint256 amount) external {
        require(msg.sender == manager, "burn: only manager can burn");
        _burn(manager, amount);
    }

    function burnFrom(address account, uint256 amount) external {
        require(msg.sender == manager, "burn: only manager can burn");
        _burn(account, amount);
    }
}// BUSL-1.1
pragma solidity 0.8.10;


abstract contract PoolShare is IPoolShare, ERC20OwnerMintableToken {
    ShareKind public immutable override kind;

    ITempusPool public immutable override pool;

    uint8 internal immutable tokenDecimals;

    constructor(
        ShareKind _kind,
        ITempusPool _pool,
        string memory name,
        string memory symbol,
        uint8 _decimals
    ) ERC20OwnerMintableToken(name, symbol) {
        kind = _kind;
        pool = _pool;
        tokenDecimals = _decimals;
    }

    function decimals() public view virtual override returns (uint8) {
        return tokenDecimals;
    }
}// BUSL-1.1
pragma solidity 0.8.10;


contract PrincipalShare is PoolShare {
    constructor(
        ITempusPool _pool,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) PoolShare(ShareKind.Principal, _pool, name, symbol, decimals) {}


    function getPricePerFullShare() external override returns (uint256) {
        return pool.pricePerPrincipalShare();
    }

    function getPricePerFullShareStored() external view override returns (uint256) {
        return pool.pricePerPrincipalShareStored();
    }
}// BUSL-1.1
pragma solidity 0.8.10;


contract YieldShare is PoolShare {
    constructor(
        ITempusPool _pool,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) PoolShare(ShareKind.Yield, _pool, name, symbol, decimals) {}


    function getPricePerFullShare() external override returns (uint256) {
        return pool.pricePerYieldShare();
    }

    function getPricePerFullShareStored() external view override returns (uint256) {
        return pool.pricePerYieldShareStored();
    }
}// MIT
pragma solidity 0.8.10;

library Fixed256xVar {
    function mulfV(
        uint256 a,
        uint256 b,
        uint256 one
    ) internal pure returns (uint256) {
        return (a * b) / one;
    }

    function divfV(
        uint256 a,
        uint256 b,
        uint256 one
    ) internal pure returns (uint256) {
        return (a * one) / b;
    }
}// MIT
pragma solidity 0.8.10;


abstract contract Ownable is IOwnable {
    address private _owner;
    address private _proposedOwner;

    constructor() {
        _setOwner(msg.sender);
    }

    function owner() public view virtual override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _proposedOwner = newOwner;
        emit OwnershipProposed(_owner, _proposedOwner);
    }

    function acceptOwnership() public virtual override {
        require(msg.sender == _proposedOwner, "Ownable: Only proposed owner can accept ownership");
        _setOwner(_proposedOwner);
        _proposedOwner = address(0);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity 0.8.10;


library UntrustedERC20 {
    using SafeERC20 for IERC20;

    function untrustedTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal returns (uint256) {
        uint256 startBalance = token.balanceOf(to);
        token.safeTransfer(to, value);
        return token.balanceOf(to) - startBalance;
    }

    function untrustedTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal returns (uint256) {
        uint256 startBalance = token.balanceOf(to);
        token.safeTransferFrom(from, to, value);
        return token.balanceOf(to) - startBalance;
    }
}// MIT
pragma solidity >=0.7.6 <0.9.0;


abstract contract Versioned is IVersioned {
    uint16 private immutable _major;
    uint16 private immutable _minor;
    uint16 private immutable _patch;

    constructor(
        uint16 major,
        uint16 minor,
        uint16 patch
    ) {
        _major = major;
        _minor = minor;
        _patch = patch;
    }

    function version() external view returns (Version memory) {
        return Version(_major, _minor, _patch);
    }
}// BUSL-1.1
pragma solidity 0.8.10;



struct TokenData {
    string name;
    string symbol;
}

abstract contract TempusPool is ITempusPool, ReentrancyGuard, Ownable, Versioned {
    using SafeERC20 for IERC20;
    using UntrustedERC20 for IERC20;
    using Fixed256xVar for uint256;

    uint256 public constant override maximumNegativeYieldDuration = 7 days;

    address public immutable override yieldBearingToken;
    address public immutable override backingToken;

    uint256 public immutable override startTime;
    uint256 public immutable override maturityTime;
    uint256 public override exceptionalHaltTime = type(uint256).max;

    uint256 public immutable override initialInterestRate;
    uint256 public override maturityInterestRate;

    uint256 public immutable exchangeRateONE;
    uint256 public immutable yieldBearingONE;
    uint256 public immutable override backingTokenONE;

    IPoolShare public immutable override principalShare;
    IPoolShare public immutable override yieldShare;

    address public immutable override controller;

    uint256 private immutable initialEstimatedYield;

    FeesConfig private feesConfig;
    uint256 public immutable override maxDepositFee;
    uint256 public immutable override maxEarlyRedeemFee;
    uint256 public immutable override maxMatureRedeemFee;
    uint256 public override totalFees;

    uint256 private negativeYieldStartTime;

    constructor(
        address _yieldBearingToken,
        address _backingToken,
        address ctrl,
        uint256 maturity,
        uint256 initInterestRate,
        uint256 exchangeRateOne,
        uint256 estimatedFinalYield,
        TokenData memory principalsData,
        TokenData memory yieldsData,
        FeesConfig memory maxFeeSetup
    ) Versioned(1, 0, 0) {
        require(maturity > block.timestamp, "maturityTime is after startTime");
        require(ctrl != address(0), "controller can not be zero");
        require(initInterestRate > 0, "initInterestRate can not be zero");
        require(estimatedFinalYield > 0, "estimatedFinalYield can not be zero");
        require(_yieldBearingToken != address(0), "YBT can not be zero");

        yieldBearingToken = _yieldBearingToken;
        backingToken = _backingToken;
        controller = ctrl;
        startTime = block.timestamp;
        maturityTime = maturity;
        initialInterestRate = initInterestRate;
        exchangeRateONE = exchangeRateOne;
        yieldBearingONE = 10**ERC20(_yieldBearingToken).decimals();
        initialEstimatedYield = estimatedFinalYield;

        maxDepositFee = maxFeeSetup.depositPercent;
        maxEarlyRedeemFee = maxFeeSetup.earlyRedeemPercent;
        maxMatureRedeemFee = maxFeeSetup.matureRedeemPercent;

        uint8 backingDecimals = _backingToken != address(0) ? IERC20Metadata(_backingToken).decimals() : 18;
        backingTokenONE = 10**backingDecimals;
        principalShare = new PrincipalShare(this, principalsData.name, principalsData.symbol, backingDecimals);
        yieldShare = new YieldShare(this, yieldsData.name, yieldsData.symbol, backingDecimals);
    }

    modifier onlyController() {
        require(msg.sender == controller, "Only callable by TempusController");
        _;
    }

    function depositToUnderlying(uint256 backingAmount) internal virtual returns (uint256 mintedYieldTokenAmount);

    function withdrawFromUnderlyingProtocol(uint256 amount, address recipient)
        internal
        virtual
        returns (uint256 backingTokenAmount);

    function matured() public view override returns (bool) {
        return (block.timestamp >= maturityTime) || (block.timestamp >= exceptionalHaltTime);
    }

    function getFeesConfig() external view override returns (FeesConfig memory) {
        return feesConfig;
    }

    function setFeesConfig(FeesConfig calldata newFeesConfig) external override onlyOwner {
        require(newFeesConfig.depositPercent <= maxDepositFee, "Deposit fee percent > max");
        require(newFeesConfig.earlyRedeemPercent <= maxEarlyRedeemFee, "Early redeem fee percent > max");
        require(newFeesConfig.matureRedeemPercent <= maxMatureRedeemFee, "Mature redeem fee percent > max");
        feesConfig = newFeesConfig;
    }

    function transferFees(address recipient) external override nonReentrant onlyOwner {
        uint256 amount = totalFees;
        totalFees = 0;

        IERC20 token = IERC20(yieldBearingToken);
        token.safeTransfer(recipient, amount);
    }

    function onDepositBacking(uint256 backingTokenAmount, address recipient)
        external
        payable
        override
        onlyController
        returns (
            uint256 mintedShares,
            uint256 depositedYBT,
            uint256 fee,
            uint256 rate
        )
    {
        assert(backingTokenAmount > 0);

        depositedYBT = depositToUnderlying(backingTokenAmount);
        assert(depositedYBT > 0);

        (mintedShares, , fee, rate) = mintShares(depositedYBT, recipient);
    }

    function onDepositYieldBearing(uint256 yieldTokenAmount, address recipient)
        external
        override
        onlyController
        returns (
            uint256 mintedShares,
            uint256 depositedBT,
            uint256 fee,
            uint256 rate
        )
    {
        assert(yieldTokenAmount > 0);

        (mintedShares, depositedBT, fee, rate) = mintShares(yieldTokenAmount, recipient);
    }

    function mintShares(uint256 yieldTokenAmount, address recipient)
        private
        returns (
            uint256 mintedShares,
            uint256 depositedBT,
            uint256 fee,
            uint256 rate
        )
    {
        rate = updateInterestRate();
        (bool hasMatured, bool hasNegativeYield) = validateInterestRate(rate);

        require(!hasMatured, "Maturity reached.");
        require(!hasNegativeYield, "Negative yield!");

        uint256 tokenAmount = yieldTokenAmount;
        uint256 depositFees = feesConfig.depositPercent;
        if (depositFees != 0) {
            fee = tokenAmount.mulfV(depositFees, yieldBearingONE);
            tokenAmount -= fee;
            totalFees += fee;
        }

        depositedBT = numAssetsPerYieldToken(tokenAmount, rate);
        mintedShares = numSharesToMint(depositedBT, rate);

        PrincipalShare(address(principalShare)).mint(recipient, mintedShares);
        YieldShare(address(yieldShare)).mint(recipient, mintedShares);
    }

    function redeemToBacking(
        address from,
        uint256 principalAmount,
        uint256 yieldAmount,
        address recipient
    )
        external
        payable
        override
        onlyController
        returns (
            uint256 redeemedYieldTokens,
            uint256 redeemedBackingTokens,
            uint256 fee,
            uint256 rate
        )
    {
        (redeemedYieldTokens, fee, rate) = burnShares(from, principalAmount, yieldAmount);

        redeemedBackingTokens = withdrawFromUnderlyingProtocol(redeemedYieldTokens, recipient);
    }

    function redeem(
        address from,
        uint256 principalAmount,
        uint256 yieldAmount,
        address recipient
    )
        external
        override
        onlyController
        returns (
            uint256 redeemedYieldTokens,
            uint256 fee,
            uint256 rate
        )
    {
        (redeemedYieldTokens, fee, rate) = burnShares(from, principalAmount, yieldAmount);

        redeemedYieldTokens = IERC20(yieldBearingToken).untrustedTransfer(recipient, redeemedYieldTokens);
    }

    function finalize() public override {
        if (matured() && maturityInterestRate == 0) {
            maturityInterestRate = updateInterestRate();
        }
    }

    function burnShares(
        address from,
        uint256 principalAmount,
        uint256 yieldAmount
    )
        private
        returns (
            uint256 redeemedYieldTokens,
            uint256 fee,
            uint256 interestRate
        )
    {
        require(IERC20(address(principalShare)).balanceOf(from) >= principalAmount, "Insufficient principals.");
        require(IERC20(address(yieldShare)).balanceOf(from) >= yieldAmount, "Insufficient yields.");

        uint256 currentRate = updateInterestRate();
        (bool hasMatured, ) = validateInterestRate(currentRate);

        if (hasMatured) {
            finalize();
        } else {
            require(principalAmount == yieldAmount, "Inequal redemption not allowed before maturity.");
        }
        PrincipalShare(address(principalShare)).burnFrom(from, principalAmount);
        YieldShare(address(yieldShare)).burnFrom(from, yieldAmount);

        (redeemedYieldTokens, , fee, interestRate) = getRedemptionAmounts(principalAmount, yieldAmount, currentRate);
        totalFees += fee;
    }

    function getRedemptionAmounts(
        uint256 principalAmount,
        uint256 yieldAmount,
        uint256 currentRate
    )
        private
        view
        returns (
            uint256 redeemableYieldTokens,
            uint256 redeemableBackingTokens,
            uint256 redeemFeeAmount,
            uint256 interestRate
        )
    {
        interestRate = effectiveRate(currentRate);

        if (interestRate < initialInterestRate) {
            redeemableBackingTokens = (principalAmount * interestRate) / initialInterestRate;
        } else {
            uint256 rateDiff = interestRate - initialInterestRate;
            uint256 yieldPercent = rateDiff.divfV(initialInterestRate, exchangeRateONE);
            uint256 redeemAmountFromYieldShares = yieldAmount.mulfV(yieldPercent, exchangeRateONE);

            redeemableBackingTokens = principalAmount + redeemAmountFromYieldShares;

            if (matured() && currentRate > interestRate) {
                uint256 additionalYieldRate = currentRate - interestRate;
                uint256 feeBackingAmount = yieldAmount.mulfV(
                    additionalYieldRate.mulfV(initialInterestRate, exchangeRateONE),
                    exchangeRateONE
                );
                redeemFeeAmount = numYieldTokensPerAsset(feeBackingAmount, currentRate);
            }
        }

        redeemableYieldTokens = numYieldTokensPerAsset(redeemableBackingTokens, currentRate);

        uint256 redeemFeePercent = matured() ? feesConfig.matureRedeemPercent : feesConfig.earlyRedeemPercent;
        if (redeemFeePercent != 0) {
            uint256 regularRedeemFee = redeemableYieldTokens.mulfV(redeemFeePercent, yieldBearingONE);
            redeemableYieldTokens -= regularRedeemFee;
            redeemFeeAmount += regularRedeemFee;

            redeemableBackingTokens = numAssetsPerYieldToken(redeemableYieldTokens, currentRate);
        }
    }

    function effectiveRate(uint256 currentRate) private view returns (uint256) {
        if (matured() && maturityInterestRate != 0) {
            return (currentRate < maturityInterestRate) ? currentRate : maturityInterestRate;
        } else {
            return currentRate;
        }
    }

    function currentYield(uint256 interestRate) private view returns (uint256) {
        return effectiveRate(interestRate).divfV(initialInterestRate, exchangeRateONE);
    }

    function currentYield() private returns (uint256) {
        return currentYield(updateInterestRate());
    }

    function currentYieldStored() private view returns (uint256) {
        return currentYield(currentInterestRate());
    }

    function estimatedYieldStored() private view returns (uint256) {
        return estimatedYield(currentYieldStored());
    }

    function estimatedYield(uint256 yieldCurrent) private view returns (uint256) {
        if (matured()) {
            return yieldCurrent;
        }
        uint256 currentTime = block.timestamp;
        uint256 timeToMaturity;
        uint256 poolDuration;
        unchecked {
            timeToMaturity = (maturityTime > currentTime) ? (maturityTime - currentTime) : 0;
            poolDuration = maturityTime - startTime;
        }
        uint256 timeLeft = timeToMaturity.divfV(poolDuration, exchangeRateONE);

        return yieldCurrent + timeLeft.mulfV(initialEstimatedYield, exchangeRateONE);
    }

    function pricePerYieldShare(uint256 currYield, uint256 estYield) private view returns (uint256) {
        uint one = exchangeRateONE;
        if (estYield < one) {
            return uint256(0);
        }
        uint256 yieldPrice = (estYield - one).mulfV(currYield, one).divfV(estYield, one);
        return interestRateToSharePrice(yieldPrice);
    }

    function pricePerPrincipalShare(uint256 currYield, uint256 estYield) private view returns (uint256) {
        if (estYield < exchangeRateONE) {
            return interestRateToSharePrice(currYield);
        }
        uint256 principalPrice = currYield.divfV(estYield, exchangeRateONE);
        return interestRateToSharePrice(principalPrice);
    }

    function pricePerYieldShare() external override returns (uint256) {
        uint256 yield = currentYield();
        return pricePerYieldShare(yield, estimatedYield(yield));
    }

    function pricePerYieldShareStored() external view override returns (uint256) {
        uint256 yield = currentYieldStored();
        return pricePerYieldShare(yield, estimatedYield(yield));
    }

    function pricePerPrincipalShare() external override returns (uint256) {
        uint256 yield = currentYield();
        return pricePerPrincipalShare(yield, estimatedYield(yield));
    }

    function pricePerPrincipalShareStored() external view override returns (uint256) {
        uint256 yield = currentYieldStored();
        return pricePerPrincipalShare(yield, estimatedYield(yield));
    }

    function numSharesToMint(uint256 depositedBT, uint256 currentRate) private view returns (uint256) {
        return (depositedBT * initialInterestRate) / currentRate;
    }

    function estimatedMintedShares(uint256 amount, bool isBackingToken) external view override returns (uint256) {
        uint256 currentRate = currentInterestRate();
        uint256 depositedBT = isBackingToken ? amount : numAssetsPerYieldToken(amount, currentRate);
        return numSharesToMint(depositedBT, currentRate);
    }

    function estimatedRedeem(
        uint256 principals,
        uint256 yields,
        bool toBackingToken
    ) external view override returns (uint256) {
        uint256 currentRate = currentInterestRate();
        (uint256 yieldTokens, uint256 backingTokens, , ) = getRedemptionAmounts(principals, yields, currentRate);
        return toBackingToken ? backingTokens : yieldTokens;
    }

    function validateInterestRate(uint256 rate) private returns (bool hasMatured, bool hasNegativeYield) {
        if (matured()) {
            return (true, rate < initialInterestRate);
        }

        if (rate >= initialInterestRate) {
            negativeYieldStartTime = 0;
            return (false, false);
        }

        if (negativeYieldStartTime == 0) {
            negativeYieldStartTime = block.timestamp;
            return (false, true);
        }

        if ((negativeYieldStartTime + maximumNegativeYieldDuration) <= block.timestamp) {
            exceptionalHaltTime = block.timestamp;
            assert(matured());
            return (true, true);
        }

        return (false, true);
    }

    function updateInterestRate() internal virtual returns (uint256);

    function currentInterestRate() public view virtual override returns (uint256);

    function numYieldTokensPerAsset(uint backingTokens, uint interestRate) public view virtual override returns (uint);

    function numAssetsPerYieldToken(uint yieldTokens, uint interestRate) public view virtual override returns (uint);

    function interestRateToSharePrice(uint interestRate) internal view virtual returns (uint);
}// GPL-3.0
pragma solidity 0.8.10;

interface IRariFundPriceConsumer {
    function getCurrencyPricesInUsd() external view returns (uint256[] memory);
}// GPL-3.0
pragma solidity 0.8.10;


interface IRariFundManager {
    function deposit(string calldata currencyCode, uint256 amount) external;

    function withdraw(string calldata currencyCode, uint256 amount) external returns (uint256);

    function getFundBalance() external returns (uint256);

    function rariFundPriceConsumer() external view returns (IRariFundPriceConsumer);

    function rariFundToken() external view returns (address);

    function getAcceptedCurrencies() external view returns (string[] memory);

    function getWithdrawalFeeRate() external view returns (uint256);
}// BUSL-1.1
pragma solidity 0.8.10;



contract RariTempusPool is TempusPool {
    using SafeERC20 for IERC20;
    using UntrustedERC20 for IERC20;
    using Fixed256xVar for uint256;

    bytes32 public constant override protocolName = "Rari";
    IRariFundManager private immutable rariFundManager;

    uint256 private immutable exchangeRateToBackingPrecision;
    uint256 private immutable backingTokenRariPoolIndex;
    uint256 private lastCalculatedInterestRate;

    constructor(
        IRariFundManager fundManager,
        address backingToken,
        address controller,
        uint256 maturity,
        uint256 estYield,
        TokenData memory principalsData,
        TokenData memory yieldsData,
        FeesConfig memory maxFeeSetup
    )
        TempusPool(
            fundManager.rariFundToken(),
            backingToken,
            controller,
            maturity,
            calculateInterestRate(
                fundManager,
                fundManager.rariFundToken(),
                getTokenRariPoolIndex(fundManager, backingToken)
            ),
            1e18,
            estYield,
            principalsData,
            yieldsData,
            maxFeeSetup
        )
    {
        require(
            IERC20Metadata(yieldBearingToken).decimals() == 18,
            "only 18 decimal Rari Yield Bearing Tokens are supported"
        );

        uint256 backingTokenIndex = getTokenRariPoolIndex(fundManager, backingToken);

        uint8 underlyingDecimals = IERC20Metadata(backingToken).decimals();
        require(underlyingDecimals <= 18, "underlying decimals must be <= 18");

        exchangeRateToBackingPrecision = 10**(18 - underlyingDecimals);
        backingTokenRariPoolIndex = backingTokenIndex;
        rariFundManager = fundManager;

        updateInterestRate();
    }

    function depositToUnderlying(uint256 amount) internal override returns (uint256) {
        assert(msg.value == 0);

        IERC20(backingToken).safeIncreaseAllowance(address(rariFundManager), amount);

        uint256 preDepositBalance = IERC20(yieldBearingToken).balanceOf(address(this));
        rariFundManager.deposit(IERC20Metadata(backingToken).symbol(), amount);
        uint256 postDepositBalance = IERC20(yieldBearingToken).balanceOf(address(this));

        return (postDepositBalance - preDepositBalance);
    }

    function withdrawFromUnderlyingProtocol(uint256 yieldBearingTokensAmount, address recipient)
        internal
        override
        returns (uint256 backingTokenAmount)
    {
        uint256 rftTotalSupply = IERC20(yieldBearingToken).totalSupply();
        uint256 withdrawalAmountUsd = (yieldBearingTokensAmount * rariFundManager.getFundBalance()) / rftTotalSupply;

        uint256 backingTokenToUsdRate = rariFundManager.rariFundPriceConsumer().getCurrencyPricesInUsd()[
            backingTokenRariPoolIndex
        ];

        uint256 withdrawalAmountInBackingToken = withdrawalAmountUsd.mulfV(backingTokenONE, backingTokenToUsdRate);
        if (withdrawalAmountInBackingToken.mulfV(backingTokenToUsdRate, backingTokenONE) > withdrawalAmountUsd) {
            withdrawalAmountInBackingToken -= 1;
        }

        uint256 preDepositBalance = IERC20(backingToken).balanceOf(address(this));
        rariFundManager.withdraw(IERC20Metadata(backingToken).symbol(), withdrawalAmountInBackingToken);
        uint256 amountWithdrawn = IERC20(backingToken).balanceOf(address(this)) - preDepositBalance;

        return IERC20(backingToken).untrustedTransfer(recipient, amountWithdrawn);
    }

    function updateInterestRate() internal override returns (uint256) {
        lastCalculatedInterestRate = calculateInterestRate(
            rariFundManager,
            yieldBearingToken,
            backingTokenRariPoolIndex
        );

        require(lastCalculatedInterestRate > 0, "Calculated rate is too small");

        return lastCalculatedInterestRate;
    }

    function currentInterestRate() public view override returns (uint256) {
        return lastCalculatedInterestRate;
    }

    function numAssetsPerYieldToken(uint yieldTokens, uint rate) public view override returns (uint) {
        return yieldTokens.mulfV(rate, exchangeRateONE) / exchangeRateToBackingPrecision;
    }

    function numYieldTokensPerAsset(uint backingTokens, uint rate) public view override returns (uint) {
        return backingTokens.divfV(rate, exchangeRateONE) * exchangeRateToBackingPrecision;
    }

    function interestRateToSharePrice(uint interestRate) internal view override returns (uint) {
        return interestRate / exchangeRateToBackingPrecision;
    }

    function calculateInterestRate(
        IRariFundManager fundManager,
        address ybToken,
        uint256 currencyIndex
    ) private returns (uint256) {
        uint256 backingTokenToUsdRate = fundManager.rariFundPriceConsumer().getCurrencyPricesInUsd()[currencyIndex];
        uint256 rftTotalSupply = IERC20(ybToken).totalSupply();
        uint256 fundBalanceUsd = rftTotalSupply > 0 ? fundManager.getFundBalance() : 0; // Only set if used

        uint256 preFeeRate;
        if (rftTotalSupply > 0 && fundBalanceUsd > 0) {
            preFeeRate = backingTokenToUsdRate.mulfV(fundBalanceUsd, rftTotalSupply);
        } else {
            preFeeRate = backingTokenToUsdRate;
        }

        uint256 postFeeRate = preFeeRate.mulfV(1e18 - fundManager.getWithdrawalFeeRate(), 1e18);

        return postFeeRate;
    }

    function getTokenRariPoolIndex(IRariFundManager fundManager, address bToken) private view returns (uint256) {
        string[] memory acceptedSymbols = fundManager.getAcceptedCurrencies();
        string memory backingTokenSymbol = IERC20Metadata(bToken).symbol();

        for (uint256 i = 0; i < acceptedSymbols.length; i++) {
            if (keccak256(bytes(backingTokenSymbol)) == keccak256(bytes(acceptedSymbols[i]))) {
                return i;
            }
        }

        revert("backing token is not accepted by the rari pool");
    }
}