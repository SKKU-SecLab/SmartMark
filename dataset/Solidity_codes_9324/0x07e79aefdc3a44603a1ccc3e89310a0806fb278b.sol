
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

interface ICurveDeposit {

    function add_liquidity(uint[4] calldata uamounts, uint min_mint_amount) external;

    function remove_liquidity_imbalance(uint[4] calldata uamounts, uint max_burn_amount) external;

    function remove_liquidity_one_coin(uint _token_amount, int128 i, uint min_uamount, bool donate_dust) external;

    function calc_withdraw_one_coin(uint _token_amount, int128 i) external view returns(uint);

}

interface ICurve {

    function add_liquidity(uint[4] calldata uamounts, uint min_mint_amount) external;

    function remove_liquidity_imbalance(uint[4] calldata uamounts, uint max_burn_amount) external;

    function remove_liquidity(uint amount, uint[4] calldata min_amounts) external;

    function calc_token_amount(uint[4] calldata inAmounts, bool deposit) external view returns(uint);

    function balances(int128 i) external view returns(uint);

    function get_virtual_price() external view returns(uint);


    function mock_add_to_balance(uint[4] calldata amounts) external;

}

interface IUtil {

    function get_D(uint[4] calldata uamounts) external pure returns(uint);

}

interface ICore {

    function mint(uint dusdAmount, address account) external returns(uint usd);

    function redeem(uint dusdAmount, address account) external returns(uint usd);

    function rewardDistributionCheckpoint(bool shouldDistribute) external returns(uint periodIncome);


    function lastPeriodIncome() external view returns(uint _totalAssets, uint _periodIncome, uint _adminFee);

    function currentSystemState() external view returns (uint _totalAssets, uint _deficit, uint _deficitPercent);

    function dusdToUsd(uint _dusd, bool fee) external view returns(uint usd);

}

interface IPeak {

    function updateFeed(uint[] calldata feed) external returns(uint portfolio);

    function portfolioValueWithFeed(uint[] calldata feed) external view returns(uint);

    function portfolioValue() external view returns(uint);

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

interface IGauge {

    function deposit(uint) external;

    function balanceOf(address) external view returns (uint);

    function claimable_tokens(address) external view returns (uint);

    function claimable_reward(address) external view returns (uint);

    function withdraw(uint, bool) external;

    function claim_rewards() external;

}

interface IMintr {

    function mint(address) external;

}

contract CurveSusdPeak is OwnableProxy, Initializable, IPeak {

    using SafeERC20 for IERC20;
    using SafeMath for uint;
    using Math for uint;

    uint constant MAX = uint(-1);
    uint constant N_COINS = 4;
    string constant ERR_SLIPPAGE = "They see you slippin";

    uint[N_COINS] ZEROES = [uint(0),uint(0),uint(0),uint(0)];
    address[N_COINS] underlyingCoins;
    uint[N_COINS] feed;

    ICurveDeposit curveDeposit; // deposit contract
    ICurve curve; // swap contract
    IERC20 curveToken; // LP token contract
    IUtil util;
    IGauge gauge;
    IMintr mintr;
    ICore core;

    function initialize(
        ICurveDeposit _curveDeposit,
        ICurve _curve,
        IERC20 _curveToken,
        ICore _core,
        IUtil _util,
        IGauge _gauge,
        IMintr _mintr,
        address[N_COINS] memory _underlyingCoins
    )   public
        notInitialized
    {

        curveDeposit = _curveDeposit;
        curve = _curve;
        curveToken = _curveToken;
        core = _core;
        util = _util;
        gauge = _gauge;
        mintr = _mintr;
        underlyingCoins = _underlyingCoins;
        replenishApprovals(MAX);
    }

    function mint(uint[N_COINS] calldata inAmounts, uint minDusdAmount)
        external
        returns (uint dusdAmount)
    {

        address[N_COINS] memory coins = underlyingCoins;
        for (uint i = 0; i < N_COINS; i++) {
            if (inAmounts[i] > 0) {
                IERC20(coins[i]).safeTransferFrom(msg.sender, address(this), inAmounts[i]);
            }
        }
        dusdAmount = _mint(inAmounts, minDusdAmount);
        if (dusdAmount >= 1e22) { // whale
            stake();
        }
    }

    function _mint(uint[N_COINS] memory inAmounts, uint minDusdAmount)
        internal
        returns (uint dusdAmount)
    {

        uint _old = portfolioValue();
        curve.add_liquidity(inAmounts, 0);
        uint _new = portfolioValue();
        dusdAmount = core.mint(_new.sub(_old), msg.sender);
        require(dusdAmount >= minDusdAmount, ERR_SLIPPAGE);
    }

    function mintWithScrv(uint inAmount, uint minDusdAmount)
        external
        returns (uint dusdAmount)
    {

        curveToken.safeTransferFrom(msg.sender, address(this), inAmount);
        dusdAmount = core.mint(sCrvToUsd(inAmount), msg.sender);
        require(dusdAmount >= minDusdAmount, ERR_SLIPPAGE);
        if (dusdAmount >= 1e22) { // whale
            stake();
        }
    }

    function redeem(uint dusdAmount, uint[N_COINS] calldata minAmounts)
        external
    {

        uint sCrv = _secureFunding(core.redeem(dusdAmount, msg.sender));
        curve.remove_liquidity(sCrv, ZEROES);
        address[N_COINS] memory coins = underlyingCoins;
        IERC20 coin;
        uint toTransfer;
        for (uint i = 0; i < N_COINS; i++) {
            coin = IERC20(coins[i]);
            toTransfer = coin.balanceOf(address(this));
            require(toTransfer >= minAmounts[i], ERR_SLIPPAGE);
            coin.safeTransfer(msg.sender, toTransfer);
        }
    }

    function redeemInSingleCoin(uint dusdAmount, uint i, uint minOut)
        external
    {

        uint sCrv = _secureFunding(core.redeem(dusdAmount, msg.sender));
        curveDeposit.remove_liquidity_one_coin(sCrv, int128(i), minOut, false);
        IERC20 coin = IERC20(underlyingCoins[i]);
        uint toTransfer = coin.balanceOf(address(this));
        require(toTransfer >= minOut, ERR_SLIPPAGE);
        coin.safeTransfer(msg.sender, toTransfer);
    }

    function redeemInScrv(uint dusdAmount, uint minOut)
        external
    {

        uint sCrv = _secureFunding(core.redeem(dusdAmount, msg.sender));
        require(sCrv >= minOut, ERR_SLIPPAGE);
        _withdraw(sCrv);
        curveToken.safeTransfer(msg.sender, sCrv);
    }

    function stake() public {

        _stake(curveToken.balanceOf(address(this)));
    }

    function updateFeed(uint[] calldata _feed)
        external
        returns(uint /* portfolio */)
    {

        require(msg.sender == address(core), "ERR_NOT_AUTH");
        require(_feed.length == N_COINS, "ERR_INVALID_UPDATE");
        feed = _processFeed(_feed);
        return portfolioValue();
    }

    function harvest(bool shouldClaim, uint minDusdAmount) external onlyOwner returns(uint) {

        if (shouldClaim) {
            claimRewards();
        }
        address uni = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address[] memory path = new address[](3);
        path[1] = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // weth

        address __crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
        IERC20 crv = IERC20(__crv);
        uint _crv = crv.balanceOf(address(this));
        uint _usdt;
        if (_crv > 0) {
            crv.safeApprove(uni, 0);
            crv.safeApprove(uni, _crv);
            path[0] = __crv;
            address __usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
            path[2] = __usdt;
            Uni(uni).swapExactTokensForTokens(_crv, uint(0), path, address(this), now.add(1800));
            _usdt = IERC20(__usdt).balanceOf(address(this));
        }

        address __snx = address(0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F);
        IERC20 snx = IERC20(__snx);
        uint _snx = snx.balanceOf(address(this));
        uint _usdc;
        if (_snx > 0) {
            snx.safeApprove(uni, 0);
            snx.safeApprove(uni, _snx);
            path[0] = __snx;
            address __usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
            path[2] = __usdc;
            Uni(uni).swapExactTokensForTokens(_snx, uint(0), path, address(this), now.add(1800));
            _usdc = IERC20(__usdc).balanceOf(address(this));
        }
        return _mint([0,_usdc,_usdt,0], minDusdAmount);
    }

    function getRewards(address[] calldata tokens, address destination) external onlyOwner {

        claimRewards();
        for (uint i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            require(
                address(token) != address(curveToken),
                "Admin can't withdraw curve lp tokens"
            );
            token.safeTransfer(destination, token.balanceOf(address(this)));
        }
    }

    function claimRewards() public {

        mintr.mint(address(gauge));
        gauge.claim_rewards();
    }

    function replenishApprovals(uint value) public {

        curveToken.safeIncreaseAllowance(address(curveDeposit), value);
        curveToken.safeIncreaseAllowance(address(gauge), value);
        for (uint i = 0; i < N_COINS; i++) {
            IERC20(underlyingCoins[i]).safeIncreaseAllowance(address(curve), value);
        }
    }


    function calcMint(uint[N_COINS] memory inAmounts)
        public view
        returns (uint dusdAmount)
    {

        return sCrvToUsd(curve.calc_token_amount(inAmounts, true /* deposit */));
    }

    function calcMintWithScrv(uint inAmount)
        public view
        returns (uint dusdAmount)
    {

        return sCrvToUsd(inAmount);
    }

    function calcRedeem(uint dusdAmount)
        public view
        returns(uint[N_COINS] memory amounts)
    {

        uint usd = core.dusdToUsd(dusdAmount, true);
        uint exchangeRate = sCrvToUsd(1e18);
        uint sCrv = usd.mul(1e18).div(exchangeRate);
        uint totalSupply = curveToken.totalSupply();
        for(uint i = 0; i < N_COINS; i++) {
            amounts[i] = curve.balances(int128(i)).mul(sCrv).div(totalSupply);
        }
    }

    function calcRedeemWithScrv(uint dusdAmount)
        public view
        returns(uint amount)
    {

        uint usd = core.dusdToUsd(dusdAmount, true);
        uint exchangeRate = sCrvToUsd(1e18);
        amount = usd.mul(1e18).div(exchangeRate);
    }

    function calcRedeemInSingleCoin(uint dusdAmount, uint i)
        public view
        returns(uint amount)
    {

        uint sCrv = usdToScrv(core.dusdToUsd(dusdAmount, true));
        amount = curveDeposit.calc_withdraw_one_coin(sCrv, int128(i));
    }

    function usdToScrv(uint usd) public view returns(uint sCrv) {

        uint exchangeRate = sCrvToUsd(1e18);
        if (exchangeRate > 0) {
            return usd.mul(1e18).div(exchangeRate);
        }
    }

    function portfolioValue() public view returns(uint) {

        return sCrvToUsd(sCrvBalance());
    }

    function sCrvToUsd(uint sCrvBal) public view returns(uint) {

        return _sCrvToUsd(sCrvBal, feed);
    }

    function portfolioValueWithFeed(uint[] calldata _feed) external view returns(uint) {

        return _sCrvToUsd(sCrvBalance(), _processFeed(_feed));
    }

    function sCrvBalance() public view returns(uint) {

        return curveToken.balanceOf(address(this))
            .add(gauge.balanceOf(address(this)));
    }

    function vars() public view returns(
        address _curveDeposit,
        address _curve,
        address _curveToken,
        address _util,
        address _gauge,
        address _mintr,
        address _core,
        address[N_COINS] memory _underlyingCoins,
        uint[N_COINS] memory _feed
    ) {

        return(
            address(curveDeposit),
            address(curve),
            address(curveToken),
            address(util),
            address(gauge),
            address(mintr),
            address(core),
            underlyingCoins,
            feed
        );
    }


    function _sCrvToUsd(uint sCrvBal, uint[N_COINS] memory _feed)
        internal view
        returns(uint)
    {

        uint sCrvTotalSupply = curveToken.totalSupply();
        if (sCrvTotalSupply == 0 || sCrvBal == 0) {
            return 0;
        }
        uint[N_COINS] memory balances;
        for (uint i = 0; i < N_COINS; i++) {
            balances[i] = curve.balances(int128(i)).mul(_feed[i]);
            if (i == 0 || i == 3) {
                balances[i] = balances[i].div(1e18);
            } else {
                balances[i] = balances[i].div(1e6);
            }
        }
        return util.get_D(balances).mul(sCrvBal).div(sCrvTotalSupply);
    }

    function _secureFunding(uint usd) internal returns(uint sCrv) {

        uint here = curveToken.balanceOf(address(this));
        uint there = gauge.balanceOf(address(this));
        sCrv = usdToScrv(usd).min(here.add(there)); // in an extreme scenario there might not be enough sCrv to redeem
        if (sCrv > here) {
            _withdraw(sCrv.sub(here));
        } else if (sCrv < here) {
            _stake(here.sub(sCrv));
        }
    }

    function _processFeed(uint[] memory _feed)
        internal
        pure
        returns(uint[N_COINS] memory _processedFeed)
    {

        for (uint i = 0; i < N_COINS; i++) {
            _processedFeed[i] = _feed[i].min(1e18);
        }
    }

    function _stake(uint amount) internal {

        if (amount > 0) {
            gauge.deposit(amount);
        }
    }

    function _withdraw(uint sCrv) internal {

        uint bal = curveToken.balanceOf(address(this));
        if (sCrv > bal) {
            gauge.withdraw(sCrv.sub(bal), false);
        }
    }
}

interface Uni {

    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external;

}