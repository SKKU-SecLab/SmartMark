
pragma solidity 0.5.17;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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
}

interface IOracle {

    function getPriceFeed() external view returns(uint[] memory);

}

interface IStakeLPToken {

    function notify(uint _deficit) external;

    function totalSupply() external view returns(uint);

}

interface IPeak {

    function updateFeed(uint[] calldata feed) external returns(uint portfolio);

    function portfolioValueWithFeed(uint[] calldata feed) external view returns(uint);

    function portfolioValue() external view returns(uint);

}

interface IDUSD {

    function mint(address account, uint amount) external;

    function burn(address account, uint amount) external;

    function totalSupply() external view returns(uint);

    function burnForSelf(uint amount) external;

}

interface ICore {

    function mint(uint dusdAmount, address account) external returns(uint usd);

    function redeem(uint dusdAmount, address account) external returns(uint usd);

    function rewardDistributionCheckpoint(bool shouldDistribute) external returns(uint periodIncome);


    function lastPeriodIncome() external view returns(uint _totalAssets, uint _periodIncome, uint _adminFee);

    function currentSystemState() external view returns (uint _totalAssets, uint _deficit, uint _deficitPercent);

    function dusdToUsd(uint _dusd, bool fee) external view returns(uint usd);

}

contract Initializable {

    bool initialized = false;

    modifier notInitialized() {

        require(!initialized, "already initialized");
        initialized = true;
        _;
    }

    uint256[20] private _gap;

    function getStore(uint a) internal view returns(uint) {

        require(a < 20, "Not allowed");
        return _gap[a];
    }

    function setStore(uint a, uint val) internal {

        require(a < 20, "Not allowed");
        _gap[a] = val;
    }
}

contract OwnableProxy {

    bytes32 constant OWNER_SLOT = keccak256("proxy.owner");

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _transferOwnership(msg.sender);
    }

    function owner() public view returns(address _owner) {

        bytes32 position = OWNER_SLOT;
        assembly {
            _owner := sload(position)
        }
    }

    modifier onlyOwner() {

        require(isOwner(), "NOT_OWNER");
        _;
    }

    function isOwner() public view returns (bool) {

        return owner() == msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "OwnableProxy: new owner is the zero address");
        emit OwnershipTransferred(owner(), newOwner);
        bytes32 position = OWNER_SLOT;
        assembly {
            sstore(position, newOwner)
        }
    }
}

contract Core is OwnableProxy, Initializable, ICore {

    using SafeERC20 for IERC20;
    using SafeMath for uint;
    using Math for uint;

    uint constant FEE_PRECISION = 10000;

    IDUSD public dusd;
    IStakeLPToken public stakeLPToken;
    IOracle public oracle;
    address[] public systemCoins;
    uint[] public feed;

    uint public totalAssets;
    uint public unclaimedRewards;
    bool public inDeficit;
    uint public redeemFactor;
    uint public colBuffer;

    enum PeakState { Extinct, Active, Dormant }
    struct Peak {
        uint[] systemCoinIds; // system indices of the coins accepted by the peak
        uint amount;
        uint ceiling;
        PeakState state;
    }
    mapping(address => Peak) public peaks;
    address[] public peaksAddresses;


    event Mint(address indexed account, uint amount);
    event Redeem(address indexed account, uint amount);
    event FeedUpdated(uint[] feed);
    event TokenWhiteListed(address indexed token);
    event PeakWhitelisted(address indexed peak);
    event UpdateDeficitState(bool inDeficit);

    modifier checkAndNotifyDeficit() {

        _;
        uint supply = dusd.totalSupply();
        if (supply > totalAssets) {
            if (!inDeficit) {
                emit UpdateDeficitState(true);
                inDeficit = true;
            }
            stakeLPToken.notify(supply.sub(totalAssets));
        } else if (inDeficit) {
            inDeficit = false;
            emit UpdateDeficitState(false);
            stakeLPToken.notify(0);
        }
    }

    modifier onlyStakeLPToken() {

        require(
            msg.sender == address(stakeLPToken),
            "Only stakeLPToken"
        );
        _;
    }

    function initialize(
        IDUSD _dusd,
        IStakeLPToken _stakeLPToken,
        IOracle _oracle,
        uint _redeemFactor,
        uint _colBuffer
    )   public
        notInitialized
    {

        require(
            address(_dusd) != address(0) &&
            address(_stakeLPToken) != address(0) &&
            address(_oracle) != address(0),
            "0 address during initialization"
        );
        dusd = _dusd;
        stakeLPToken = _stakeLPToken;
        oracle = _oracle;
        require(
            _redeemFactor <= FEE_PRECISION && _colBuffer <= FEE_PRECISION,
            "Incorrect upper bound for fee"
        );
        redeemFactor = _redeemFactor;
        colBuffer = _colBuffer;
    }

    function mint(uint usdDelta, address account)
        external
        checkAndNotifyDeficit
        returns(uint dusdAmount)
    {

        Peak memory peak = peaks[msg.sender];
        dusdAmount = usdDelta;
        uint tvl = peak.amount.add(dusdAmount);
        require(
            usdDelta > 0
            && peak.state == PeakState.Active
            && tvl <= peak.ceiling,
            "ERR_MINT"
        );
        peaks[msg.sender].amount = tvl;
        dusd.mint(account, dusdAmount);
        totalAssets = totalAssets.add(usdDelta);
        emit Mint(account, dusdAmount);
    }

    function redeem(uint dusdAmount, address account)
        external
        checkAndNotifyDeficit
        returns(uint usd)
    {

        Peak memory peak = peaks[msg.sender];
        require(
            dusdAmount > 0 && peak.state != PeakState.Extinct,
            "ERR_REDEEM"
        );
        peaks[msg.sender].amount = peak.amount.sub(peak.amount.min(dusdAmount));
        usd = dusdToUsd(dusdAmount, true);
        dusd.burn(account, dusdAmount);
        totalAssets = totalAssets.sub(usd);
        emit Redeem(account, dusdAmount);
    }

    function syncSystem()
        public
        checkAndNotifyDeficit
    {

        _updateFeed(false);
    }

    function rewardDistributionCheckpoint(bool shouldDistribute)
        external
        onlyStakeLPToken
        checkAndNotifyDeficit
        returns(uint periodIncome)
    {

        _updateFeed(false); // totalAssets was updated
        uint _colBuffer;
        (periodIncome, _colBuffer) = _lastPeriodIncome(totalAssets);
        if (periodIncome == 0) {
            return 0;
        }
        if (shouldDistribute) {
            dusd.mint(address(stakeLPToken), periodIncome);
        } else {
            unclaimedRewards = unclaimedRewards.add(periodIncome);
        }
        if (_colBuffer > 0) {
            unclaimedRewards = unclaimedRewards.add(_colBuffer);
        }
    }

    function dusdToUsd(uint _dusd, bool fee)
        public
        view
        returns(uint usd)
    {

        if (!inDeficit) {
            usd = _dusd;
        } else {
            uint supply = dusd.totalSupply();
            uint perceivedSupply = supply.sub(stakeLPToken.totalSupply());
            if (perceivedSupply <= totalAssets) {
                usd = _dusd;
            } else {
                usd = _dusd.mul(totalAssets).div(perceivedSupply);
            }
        }
        if (fee) {
            usd = usd.mul(redeemFactor).div(FEE_PRECISION);
        }
        return usd;
    }

    function currentSystemState()
        public view
        returns (uint _totalAssets, uint _deficit, uint _deficitPercent)
    {

        _totalAssets = totalSystemAssets();
        uint supply = dusd.totalSupply();
        if (supply > _totalAssets) {
            _deficit = supply.sub(_totalAssets);
            _deficitPercent = _deficit.mul(1e7).div(supply); // 5 decimal precision
        }
    }

    function lastPeriodIncome()
        public view
        returns(uint _totalAssets, uint _periodIncome, uint _colBuffer)
    {

        _totalAssets = totalSystemAssets();
        (_periodIncome, _colBuffer) = _lastPeriodIncome(_totalAssets);
    }

    function totalSystemAssets()
        public view
        returns (uint _totalAssets)
    {

        uint[] memory _feed = oracle.getPriceFeed();
        for (uint i = 0; i < peaksAddresses.length; i++) {
            Peak memory peak = peaks[peaksAddresses[i]];
            if (peak.state == PeakState.Extinct) {
                continue;
            }
            _totalAssets = _totalAssets.add(
                IPeak(peaksAddresses[i]).portfolioValueWithFeed(_feed)
            );
        }
    }


    function whitelistTokens(address[] calldata tokens)
        external
        onlyOwner
    {

        for (uint i = 0; i < tokens.length; i++) {
            _whitelistToken(tokens[i]);
        }
    }

    function whitelistPeak(
        address peak,
        uint[] calldata _systemCoins,
        uint ceiling,
        bool shouldUpdateFeed
    )   external
        onlyOwner
    {

        uint numSystemCoins = systemCoins.length;
        for (uint i = 0; i < _systemCoins.length; i++) {
            require(_systemCoins[i] < numSystemCoins, "Invalid system coin index");
        }
        require(
            peaks[peak].state == PeakState.Extinct,
            "Peak already exists"
        );
        peaksAddresses.push(peak);
        peaks[peak] = Peak(_systemCoins, 0, ceiling, PeakState.Active);
        if (shouldUpdateFeed) {
            _updateFeed(true);
        }
        emit PeakWhitelisted(peak);
    }

    function setPeakStatus(address peak, uint ceiling, PeakState state)
        external
        onlyOwner
    {

        require(
            peaks[peak].state != PeakState.Extinct,
            "Peak is extinct"
        );
        peaks[peak].ceiling = ceiling;
        peaks[peak].state = state;
    }

    function setFee(uint _redeemFactor, uint _colBuffer)
        external
        onlyOwner
    {

        require(
            _redeemFactor <= FEE_PRECISION && _colBuffer <= FEE_PRECISION,
            "Incorrect upper bound for fee"
        );
        redeemFactor = _redeemFactor;
        colBuffer = _colBuffer;
    }


    function _updateFeed(bool forceUpdate) internal {

        uint[] memory _feed = oracle.getPriceFeed();
        require(_feed.length == systemCoins.length, "Invalid system state");
        bool changed = false;
        for (uint i = 0; i < _feed.length; i++) {
            if (feed[i] != _feed[i]) {
                feed[i] = _feed[i];
                changed = true;
            }
        }
        if (changed) {
            emit FeedUpdated(_feed);
        }
        Peak memory peak;
        uint _totalAssets;
        for (uint i = 0; i < peaksAddresses.length; i++) {
            peak = peaks[peaksAddresses[i]];
            if (peak.state == PeakState.Extinct) {
                continue;
            }
            if (!changed && !forceUpdate) {
                _totalAssets = _totalAssets.add(IPeak(peaksAddresses[i]).portfolioValue());
                continue;
            }
            uint[] memory prices = new uint[](peak.systemCoinIds.length);
            for (uint j = 0; j < prices.length; j++) {
                prices[j] = _feed[peak.systemCoinIds[j]];
            }
            _totalAssets = _totalAssets.add(IPeak(peaksAddresses[i]).updateFeed(prices));
        }
        totalAssets = _totalAssets;
    }

    function _lastPeriodIncome(uint _totalAssets)
        internal view
        returns(uint _periodIncome, uint _colBuffer)
    {

        uint supply = dusd.totalSupply().add(unclaimedRewards);
        if (_totalAssets > supply) {
            _periodIncome = _totalAssets.sub(supply);
            if (colBuffer > 0) {
                _colBuffer = _periodIncome.mul(colBuffer).div(FEE_PRECISION);
                _periodIncome = _periodIncome.sub(_colBuffer);
            }
        }
    }

    function _whitelistToken(address token)
        internal
    {

        for (uint i = 0; i < systemCoins.length; i++) {
            require(systemCoins[i] != token, "Adding a duplicate token");
        }
        systemCoins.push(token);
        feed.push(0);
        emit TokenWhiteListed(token);
    }
}