
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}pragma solidity 0.8.2;


interface INeuronPool is IERC20 {
    function token() external view returns (address);

    function claimInsurance() external; // NOTE: Only yDelegatedVault implements this

    function getRatio() external view returns (uint256);

    function depositAll() external;

    function deposit(uint256) external;

    function withdrawAll() external;

    function withdraw(uint256) external;

    function earn() external;

    function decimals() external view returns (uint8);
}// MIT
pragma solidity 0.8.2;

interface IStakingRewards {
    function balanceOf(address account) external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function exit() external;

    function getReward() external;

    function getRewardForDuration() external view returns (uint256);

    function lastTimeRewardApplicable() external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function notifyRewardAmount(uint256 reward) external;

    function periodFinish() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function rewardPerTokenStored() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function rewards(address) external view returns (uint256);

    function rewardsDistribution() external view returns (address);

    function rewardsDuration() external view returns (uint256);

    function rewardsToken() external view returns (address);

    function stake(uint256 amount) external;

    function stakeWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function stakingToken() external view returns (address);

    function totalSupply() external view returns (uint256);

    function userRewardPerTokenPaid(address) external view returns (uint256);

    function withdraw(uint256 amount) external;
}

interface IStakingRewardsFactory {
    function deploy(address stakingToken, uint256 rewardAmount) external;

    function isOwner() external view returns (bool);

    function notifyRewardAmount(address stakingToken) external;

    function notifyRewardAmounts() external;

    function owner() external view returns (address);

    function renounceOwnership() external;

    function rewardsToken() external view returns (address);

    function stakingRewardsGenesis() external view returns (uint256);

    function stakingRewardsInfoByStakingToken(address)
        external
        view
        returns (address stakingRewards, uint256 rewardAmount);

    function stakingTokens(uint256) external view returns (address);

    function transferOwnership(address newOwner) external;
}pragma solidity 0.8.2;

interface IUniswapRouterV2 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}pragma solidity 0.8.2;

interface IController {
    function nPools(address) external view returns (address);

    function rewards() external view returns (address);

    function devfund() external view returns (address);

    function treasury() external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function withdraw(address, uint256) external;

    function earn(address, uint256) external;
}pragma solidity 0.8.2;




abstract contract StrategyBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 public performanceTreasuryFee = 3000;
    uint256 public constant performanceTreasuryMax = 10000;

    uint256 public withdrawalTreasuryFee = 0;
    uint256 public constant withdrawalTreasuryMax = 100000;

    uint256 public withdrawalDevFundFee = 0;
    uint256 public constant withdrawalDevFundMax = 100000;

    address public immutable neuronTokenAddress;
    address public immutable want;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public governance;
    address public controller;
    address public strategist;
    address public timelock;

    address public constant univ2Router2 =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant sushiRouter =
        0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    mapping(address => bool) public harvesters;

    constructor(
        address _want,
        address _governance,
        address _strategist,
        address _controller,
        address _neuronTokenAddress,
        address _timelock
    ) {
        require(_want != address(0));
        require(_governance != address(0));
        require(_strategist != address(0));
        require(_controller != address(0));
        require(_neuronTokenAddress != address(0));
        require(_timelock != address(0));

        want = _want;
        governance = _governance;
        strategist = _strategist;
        controller = _controller;
        neuronTokenAddress = _neuronTokenAddress;
        timelock = _timelock;
    }


    modifier onlyBenevolent() {
        require(
            harvesters[msg.sender] ||
                msg.sender == governance ||
                msg.sender == strategist
        );
        _;
    }


    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfPool() public view virtual returns (uint256);

    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    function getName() external pure virtual returns (string memory);


    function whitelistHarvester(address _harvester) external {
        require(
            msg.sender == governance || msg.sender == strategist,
            "not authorized"
        );
        harvesters[_harvester] = true;
    }

    function revokeHarvester(address _harvester) external {
        require(
            msg.sender == governance || msg.sender == strategist,
            "not authorized"
        );
        harvesters[_harvester] = false;
    }

    function setWithdrawalDevFundFee(uint256 _withdrawalDevFundFee) external {
        require(msg.sender == timelock, "!timelock");
        withdrawalDevFundFee = _withdrawalDevFundFee;
    }

    function setWithdrawalTreasuryFee(uint256 _withdrawalTreasuryFee) external {
        require(msg.sender == timelock, "!timelock");
        withdrawalTreasuryFee = _withdrawalTreasuryFee;
    }

    function setPerformanceTreasuryFee(uint256 _performanceTreasuryFee)
        external
    {
        require(msg.sender == timelock, "!timelock");
        performanceTreasuryFee = _performanceTreasuryFee;
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setTimelock(address _timelock) external {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    function setController(address _controller) external {
        require(msg.sender == timelock, "!timelock");
        controller = _controller;
    }

    function deposit() public virtual;

    function withdraw(IERC20 _asset) external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        uint256 _feeDev = _amount.mul(withdrawalDevFundFee).div(
            withdrawalDevFundMax
        );
        IERC20(want).safeTransfer(IController(controller).devfund(), _feeDev);

        uint256 _feeTreasury = _amount.mul(withdrawalTreasuryFee).div(
            withdrawalTreasuryMax
        );
        IERC20(want).safeTransfer(
            IController(controller).treasury(),
            _feeTreasury
        );

        address _nPool = IController(controller).nPools(address(want));
        require(_nPool != address(0), "!nPool"); // additional protection so we don't burn the funds

        IERC20(want).safeTransfer(
            _nPool,
            _amount.sub(_feeDev).sub(_feeTreasury)
        );
    }

    function withdrawForSwap(uint256 _amount)
        external
        returns (uint256 balance)
    {
        require(msg.sender == controller, "!controller");
        _withdrawSome(_amount);

        balance = IERC20(want).balanceOf(address(this));

        address _nPool = IController(controller).nPools(address(want));
        require(_nPool != address(0), "!nPool");
        IERC20(want).safeTransfer(_nPool, balance);
    }

    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();

        balance = IERC20(want).balanceOf(address(this));

        address _nPool = IController(controller).nPools(address(want));
        require(_nPool != address(0), "!nPool"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_nPool, balance);
    }

    function _withdrawAll() internal {
        _withdrawSome(balanceOfPool());
    }

    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);

    function harvest() public virtual;


    function execute(address _target, bytes memory _data)
        public
        payable
        returns (bytes memory response)
    {
        require(msg.sender == timelock, "!timelock");
        require(_target != address(0), "!target");

        assembly {
            let succeeded := delegatecall(
                sub(gas(), 5000),
                _target,
                add(_data, 0x20),
                mload(_data),
                0,
                0
            )
            let size := returndatasize()

            response := mload(0x40)
            mstore(
                0x40,
                add(response, and(add(add(size, 0x20), 0x1f), not(0x1f)))
            )
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                revert(add(response, 0x20), size)
            }
        }
    }

    function _swapUniswap(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        require(_to != address(0));

        address[] memory path;

        if (_from == weth || _to == weth) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = weth;
            path[2] = _to;
        }

        IUniswapRouterV2(univ2Router2).swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            block.timestamp.add(60)
        );
    }

    function _swapUniswapWithPath(address[] memory path, uint256 _amount)
        internal
    {
        require(path[1] != address(0));

        IUniswapRouterV2(univ2Router2).swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            block.timestamp.add(60)
        );
    }

    function _swapSushiswap(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        require(_to != address(0));

        address[] memory path;

        if (_from == weth || _to == weth) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = weth;
            path[2] = _to;
        }

        IUniswapRouterV2(sushiRouter).swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            block.timestamp.add(60)
        );
    }

    function _swapWithUniLikeRouter(
        address routerAddress,
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        require(_to != address(0));
        require(
            routerAddress != address(0),
            "_swapWithUniLikeRouter routerAddress cant be zero"
        );

        address[] memory path;

        if (_from == weth || _to == weth) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = weth;
            path[2] = _to;
        }

        try
            IUniswapRouterV2(routerAddress).swapExactTokensForTokens(
                _amount,
                0,
                path,
                address(this),
                block.timestamp.add(60)
            )
        {
            return true;
        } catch {
            return false;
        }
    }

    function _swapSushiswapWithPath(address[] memory path, uint256 _amount)
        internal
    {
        require(path[1] != address(0));

        IUniswapRouterV2(sushiRouter).swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            block.timestamp.add(60)
        );
    }

    function _swapToNeurAndDistributePerformanceFees(
        address swapToken,
        address swapRouterAddress
    ) internal {
        uint256 swapTokenBalance = IERC20(swapToken).balanceOf(address(this));

        if (swapTokenBalance > 0 && performanceTreasuryFee > 0) {
            uint256 performanceTreasuryFeeAmount = swapTokenBalance
                .mul(performanceTreasuryFee)
                .div(performanceTreasuryMax);
            uint256 totalFeeAmout = performanceTreasuryFeeAmount;

            _swapAmountToNeurAndDistributePerformanceFees(
                swapToken,
                totalFeeAmout,
                swapRouterAddress
            );
        }
    }

    function _swapAmountToNeurAndDistributePerformanceFees(
        address swapToken,
        uint256 amount,
        address swapRouterAddress
    ) internal {
        uint256 swapTokenBalance = IERC20(swapToken).balanceOf(address(this));

        require(
            swapTokenBalance >= amount,
            "Amount is bigger than token balance"
        );

        IERC20(swapToken).safeApprove(swapRouterAddress, 0);
        IERC20(weth).safeApprove(swapRouterAddress, 0);
        IERC20(swapToken).safeApprove(swapRouterAddress, amount);
        IERC20(weth).safeApprove(swapRouterAddress, type(uint256).max);
        bool isSuccesfullSwap = _swapWithUniLikeRouter(
            swapRouterAddress,
            swapToken,
            neuronTokenAddress,
            amount
        );

        if (isSuccesfullSwap) {
            uint256 neuronTokenBalance = IERC20(neuronTokenAddress).balanceOf(
                address(this)
            );

            if (neuronTokenBalance > 0) {
                IERC20(neuronTokenAddress).safeTransfer(
                    IController(controller).treasury(),
                    neuronTokenBalance
                );
            }
        } else {
            IERC20(swapToken).safeApprove(IController(controller).treasury(), 0);
            IERC20(swapToken).safeApprove(IController(controller).treasury(), amount);
            IERC20(swapToken).safeTransfer(
                IController(controller).treasury(),
                amount
            );
        }
    }
}// MIT
pragma solidity 0.8.2;

interface ISushiMasterchefV2 {
    function MASTER_PID() external view returns (uint256);

    function MASTER_CHEF() external view returns (address);

    function rewarder(uint256 pid) external view returns (address);

    function add(
        uint256 _allocPoint,
        address _lpToken,
        address _rewarder
    ) external;

    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external;

    function pendingSushi(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function sushiPerBlock() external view returns (uint256);

    function poolInfo(uint256)
        external
        view
        returns (
            uint256 lastRewardBlock,
            uint256 accsushiPerShare,
            uint256 allocPoint
        );

    function poolLength() external view returns (uint256);

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        address _rewarder,
        bool overwrite
    ) external;

    function harvestFromMasterChef() external;

    function harvest(uint256 pid, address to) external;

    function totalAllocPoint() external view returns (uint256);

    function updatePool(uint256 _pid) external;

    function userInfo(uint256, address)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);

    function withdraw(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external;

    function withdrawAndHarvest(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external;
}// MIT
pragma solidity 0.8.2;

interface ISushiRewarder {
    function pendingToken(uint256 pid, address user)
        external
        view
        returns (uint256);
}// MIT
pragma solidity 0.8.2;


abstract contract StrategySushiEthFarmDoubleRewardBase is StrategyBase {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public constant sushi = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
    address public immutable rewardToken;

    address public constant sushiMasterChef =
        0xEF0881eC094552b2e128Cf945EF17a6752B4Ec5d;

    uint256 public poolId;

    uint256 public keepRewardToken = 500;
    uint256 public keepRewardTokenMax = 10000;

    constructor(
        uint256 _poolId,
        address _lp,
        address _rewardToken,
        address _governance,
        address _strategist,
        address _controller,
        address _neuronTokenAddress,
        address _timelock
    )
        StrategyBase(
            _lp,
            _governance,
            _strategist,
            _controller,
            _neuronTokenAddress,
            _timelock
        )
    {
        poolId = _poolId;
        rewardToken = _rewardToken;
    }

    function setKeepRewardToken(uint256 _keepRewardToken) external {
        require(msg.sender == governance, "!governance");
        keepRewardToken = _keepRewardToken;
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 amount, ) = ISushiMasterchefV2(sushiMasterChef).userInfo(
            poolId,
            address(this)
        );
        return amount;
    }

    function getHarvestableSushi() public view returns (uint256) {
        return
            ISushiMasterchefV2(sushiMasterChef).pendingSushi(
                poolId,
                address(this)
            );
    }

    function getHarvestableRewardToken() public view returns (uint256) {
        address rewarder = ISushiMasterchefV2(sushiMasterChef).rewarder(poolId);
        return ISushiRewarder(rewarder).pendingToken(poolId, address(this));
    }


    function deposit() public override {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            IERC20(want).safeApprove(sushiMasterChef, 0);
            IERC20(want).safeApprove(sushiMasterChef, _want);
            ISushiMasterchefV2(sushiMasterChef).deposit(
                poolId,
                _want,
                address(this)
            );
        }
    }

    function _withdrawSome(uint256 _amount)
        internal
        override
        returns (uint256)
    {
        ISushiMasterchefV2(sushiMasterChef).withdraw(
            poolId,
            _amount,
            address(this)
        );
        return _amount;
    }


    function harvest() public override onlyBenevolent {

        ISushiMasterchefV2(sushiMasterChef).harvest(poolId, address(this));

        uint256 _rewardToken = IERC20(rewardToken).balanceOf(address(this));
        uint256 _sushi = IERC20(sushi).balanceOf(address(this));

        if (_rewardToken > 0) {
            _swapToNeurAndDistributePerformanceFees(rewardToken, sushiRouter);
            uint256 _keepRewardToken = _rewardToken.mul(keepRewardToken).div(
                keepRewardTokenMax
            );
            if (_keepRewardToken > 0) {
                IERC20(rewardToken).safeTransfer(
                    IController(controller).treasury(),
                    _keepRewardToken
                );
            }
            _rewardToken = IERC20(rewardToken).balanceOf(address(this));
        }

        if (_sushi > 0) {
            _swapToNeurAndDistributePerformanceFees(sushi, sushiRouter);
            _sushi = IERC20(sushi).balanceOf(address(this));
        }

        if (_rewardToken > 0) {
            uint256 _amount = _rewardToken.div(2);
            IERC20(rewardToken).safeApprove(sushiRouter, 0);
            IERC20(rewardToken).safeApprove(sushiRouter, _amount);
            _swapSushiswap(rewardToken, weth, _amount);
        }

        if (_sushi > 0) {
            uint256 _amount = _sushi.div(2);
            IERC20(sushi).safeApprove(sushiRouter, 0);
            IERC20(sushi).safeApprove(sushiRouter, _sushi);

            _swapSushiswap(sushi, weth, _amount);
            _swapSushiswap(sushi, rewardToken, _amount);
        }

        uint256 _weth = IERC20(weth).balanceOf(address(this));

        _rewardToken = IERC20(rewardToken).balanceOf(address(this));

        if (_weth > 0 && _rewardToken > 0) {
            IERC20(weth).safeApprove(sushiRouter, 0);
            IERC20(weth).safeApprove(sushiRouter, _weth);

            IERC20(rewardToken).safeApprove(sushiRouter, 0);
            IERC20(rewardToken).safeApprove(sushiRouter, _rewardToken);

            IUniswapRouterV2(sushiRouter).addLiquidity(
                weth,
                rewardToken,
                _weth,
                _rewardToken,
                0,
                0,
                address(this),
                block.timestamp + 60
            );

            IERC20(weth).transfer(
                IController(controller).treasury(),
                IERC20(weth).balanceOf(address(this))
            );
            IERC20(rewardToken).safeTransfer(
                IController(controller).treasury(),
                IERC20(rewardToken).balanceOf(address(this))
            );
        }

        deposit();
    }
}// MIT
pragma solidity 0.8.2;


contract StrategySushiDoubleEthCvxLp is StrategySushiEthFarmDoubleRewardBase {
    uint256 public constant sushi_cvx_poolId = 1;

    address public constant sushi_eth_cvx_lp =
        0x05767d9EF41dC40689678fFca0608878fb3dE906;
    address public constant cvx = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;

    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _neuronTokenAddress,
        address _timelock
    )
        StrategySushiEthFarmDoubleRewardBase(
            sushi_cvx_poolId,
            sushi_eth_cvx_lp,
            cvx,
            _governance,
            _strategist,
            _controller,
            _neuronTokenAddress,
            _timelock
        )
    {}


    function getName() external pure override returns (string memory) {
        return "StrategySushiDoubleEthCvxLp";
    }
}