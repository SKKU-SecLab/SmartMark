


pragma solidity ^0.6.0;

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




pragma solidity ^0.6.0;

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




pragma solidity ^0.6.2;

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
}




pragma solidity ^0.6.0;




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
}




pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity 0.6.12;


contract Pausable is Context {

    event Paused(address account);
    event Shutdown(address account);
    event Unpaused(address account);
    event Open(address account);

    bool public paused;
    bool public stopEverything;

    modifier whenNotPaused() {

        require(!paused, "Pausable: paused");
        _;
    }
    modifier whenPaused() {

        require(paused, "Pausable: not paused");
        _;
    }

    modifier whenNotShutdown() {

        require(!stopEverything, "Pausable: shutdown");
        _;
    }

    modifier whenShutdown() {

        require(stopEverything, "Pausable: not shutdown");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused whenNotShutdown {

        paused = false;
        emit Unpaused(_msgSender());
    }

    function _shutdown() internal virtual whenNotShutdown {

        stopEverything = true;
        paused = true;
        emit Shutdown(_msgSender());
    }

    function _open() internal virtual whenShutdown {

        stopEverything = false;
        emit Open(_msgSender());
    }
}




pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
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

}




pragma solidity ^0.6.0;

contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity 0.6.12;

interface IController {
    function aaveProvider() external view returns (address);

    function pools() external view returns (address);

    function aaveReferralCode() external view returns (uint16);

    function founderFee() external view returns (uint256);

    function founderVault() external view returns (address);

    function withdrawFee(address) external view returns (uint256);

    function feeCollector(address pool) external view returns (address);

    function interestFee(address) external view returns (uint256);

    function poolStrategy(address pool) external view returns (address);

    function rebalanceFriction(address) external view returns (uint256);

    function treasuryPool() external view returns (address);

    function uniswapRouter() external view returns (address);
}




pragma solidity 0.6.12;




contract PoolRewards is ERC20, ReentrancyGuard {
    IERC20 public rewardsToken;
    IController public immutable controller;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public constant REWARD_DURATION = 7 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    event RewardAdded(uint256 reward);

    constructor(
        string memory name,
        string memory symbol,
        address _controller
    ) public ERC20(name, symbol) {
        controller = IController(_controller);
    }

    event RewardPaid(address indexed user, uint256 reward);
    modifier updateReward(address _account) {
        _updateReward(_account);
        _;
    }

    function notifyRewardAmount(uint256 reward) external updateReward(address(0)) {
        require(_msgSender() == address(controller), "Not authorized");
        require(address(rewardsToken) != address(0), "Rewards token not set");
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(REWARD_DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(REWARD_DURATION);
        }

        uint256 balance = rewardsToken.balanceOf(address(this));
        require(rewardRate <= balance.div(REWARD_DURATION), "Reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(REWARD_DURATION);
        emit RewardAdded(reward);
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(REWARD_DURATION);
    }

    function getReward() public nonReentrant updateReward(_msgSender()) {
        _getReward();
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(
                    totalSupply()
                )
            );
    }

    function _getReward() internal {
        uint256 reward = rewards[_msgSender()];
        if (reward != 0) {
            rewards[_msgSender()] = 0;
            rewardsToken.transfer(_msgSender(), reward);
            emit RewardPaid(_msgSender(), reward);
        }
    }

    function _setRewardsToken(address _rewardsToken) internal {
        require(address(rewardsToken) == address(0), "Rewards token already set");
        rewardsToken = IERC20(_rewardsToken);
    }

    function _updateReward(address _account) private {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
    }
}




pragma solidity 0.6.12;


interface IVPool is IERC20 {
    function approveToken() external;

    function getPricePerShare() external view returns (uint256);

    function totalValue() external view returns (uint256);

    function sweepErc20(address) external;

    function deposit() external payable;

    function deposit(uint256) external;

    function multiTransfer(uint256[] memory) external returns (bool);

    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;

    function rebalance() external;

    function resetApproval() external;

    function token() external view returns (address);

    function withdraw(uint256) external;

    function withdrawETH(uint256) external;

    function withdrawByStrategy(uint256) external;
}




pragma solidity ^0.6.6;

interface IAddressList {
    event AddressUpdated(address indexed a, address indexed sender);
    event AddressRemoved(address indexed a, address indexed sender);

    function add(address a) external returns (bool);
    function addValue(address a, uint256 v) external returns (bool);
    function remove(address a) external returns (bool);

    function get(address a) external view returns (uint256);
    function at(uint256 index) external view returns (address, uint256);
    function length() external view returns (uint256);
}




pragma solidity ^0.6.6;


interface IAddressListExt is IAddressList {
    function grantRole(bytes32, address) external;
}




pragma solidity ^0.6.6;

interface IAddressListFactory {
    event ListCreated(address indexed _sender, address indexed _newList);

    function ours(address a) external view returns (bool);
    function listCount() external view returns (uint);
    function listAt(uint idx) external view returns (address);
    function createList() external returns (address listaddr);
}




pragma solidity 0.6.12;







abstract contract PoolShareToken is PoolRewards, Pausable {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    IAddressListExt public immutable feeWhiteList;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 public constant PERMIT_TYPEHASH = keccak256(
        "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );

    bytes32 public immutable domainSeparator;

    uint256 internal constant MAX_UINT_VALUE = uint256(-1);
    mapping(address => uint256) public nonces;
    event Deposit(address indexed owner, uint256 shares, uint256 amount);
    event Withdraw(address indexed owner, uint256 shares, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        address _token,
        address _controller
    ) public PoolRewards(_name, _symbol, _controller) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        token = IERC20(_token);
        IAddressListFactory factory = IAddressListFactory(
            0x8252B79D85A8F75Ae7e439f71F078AB15a1d2929
        );
        IAddressListExt _feeWhiteList = IAddressListExt(factory.createList());
        _feeWhiteList.grantRole(keccak256("LIST_ADMIN"), _controller);
        feeWhiteList = _feeWhiteList;
        domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(_name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function setRewardsToken(address _rewardsToken) external {
        require(_msgSender() == address(controller), "Not authorized");
        require(_rewardsToken != address(token), "Reward and collateral same");
        _setRewardsToken(_rewardsToken);
    }

    function deposit(uint256 amount)
        external
        virtual
        nonReentrant
        whenNotPaused
        updateReward(_msgSender())
    {
        _deposit(amount);
    }

    function depositWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant whenNotPaused updateReward(_msgSender()) {
        IVPool(address(token)).permit(_msgSender(), address(this), amount, deadline, v, r, s);
        _deposit(amount);
    }

    function withdraw(uint256 shares)
        external
        virtual
        nonReentrant
        whenNotShutdown
        updateReward(_msgSender())
    {
        _getReward();
        _withdraw(shares);
    }

    function withdrawByStrategy(uint256 shares)
        external
        virtual
        nonReentrant
        whenNotShutdown
        updateReward(_msgSender())
    {
        require(feeWhiteList.get(_msgSender()) != 0, "Not a white listed address");
        _getReward();
        _withdrawByStrategy(shares);
    }

    function multiTransfer(uint256[] memory bits) external returns (bool) {
        for (uint256 i = 0; i < bits.length; i++) {
            address a = address(bits[i] >> 96);
            uint256 amount = bits[i] & ((1 << 96) - 1);
            require(transfer(a, amount), "Transfer failed");
        }
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "Expired");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline)
                )
            )
        );
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0) && signatory == owner, "Invalid signature");
        _approve(owner, spender, amount);
    }

    function getPricePerShare() external view returns (uint256) {
        if (totalSupply() == 0) {
            return convertFrom18(1e18);
        }
        return totalValue().mul(1e18).div(totalSupply());
    }

    function convertTo18(uint256 amount) public virtual pure returns (uint256) {
        return amount;
    }

    function convertFrom18(uint256 amount) public virtual pure returns (uint256) {
        return amount;
    }

    function feeCollector() public virtual view returns (address) {
        return controller.feeCollector(address(this));
    }

    function tokensHere() public virtual view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function totalValue() public virtual view returns (uint256) {
        return tokensHere();
    }

    function withdrawFee() public virtual view returns (uint256) {
        return controller.withdrawFee(address(this));
    }

    function _beforeBurning(uint256 share) internal virtual {}

    function _afterBurning(uint256 amount) internal virtual {}

    function _beforeMinting(uint256 amount) internal virtual {}

    function _afterMinting(uint256 amount) internal virtual {}

    function _calculateShares(uint256 amount) internal view returns (uint256) {
        require(amount != 0, "amount is 0");

        uint256 _totalSupply = totalSupply();
        uint256 _totalValue = convertTo18(totalValue());
        uint256 shares = (_totalSupply == 0 || _totalValue == 0)
            ? amount
            : amount.mul(_totalSupply).div(_totalValue);
        return shares;
    }

    function _deposit(uint256 amount) internal whenNotPaused {
        uint256 shares = _calculateShares(convertTo18(amount));
        _beforeMinting(amount);
        _mint(_msgSender(), shares);
        _afterMinting(amount);
        emit Deposit(_msgSender(), shares, amount);
    }

    function _handleFee(uint256 shares) internal returns (uint256 _sharesAfterFee) {
        if (withdrawFee() != 0) {
            uint256 _fee = shares.mul(withdrawFee()).div(1e18);
            _sharesAfterFee = shares.sub(_fee);
            _transfer(_msgSender(), feeCollector(), _fee);
        } else {
            _sharesAfterFee = shares;
        }
    }

    function _withdraw(uint256 shares) internal whenNotShutdown {
        require(shares != 0, "share is 0");
        _beforeBurning(shares);
        uint256 sharesAfterFee = _handleFee(shares);
        uint256 amount = convertFrom18(
            sharesAfterFee.mul(convertTo18(totalValue())).div(totalSupply())
        );

        _burn(_msgSender(), sharesAfterFee);
        _afterBurning(amount);
        emit Withdraw(_msgSender(), shares, amount);
    }

    function _withdrawByStrategy(uint256 shares) internal {
        require(shares != 0, "Withdraw must be greater than 0");
        _beforeBurning(shares);
        uint256 amount = convertFrom18(shares.mul(convertTo18(totalValue())).div(totalSupply()));
        _burn(_msgSender(), shares);
        _afterBurning(amount);
        emit Withdraw(_msgSender(), shares, amount);
    }
}




pragma solidity 0.6.12;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}




pragma solidity 0.6.12;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}




pragma solidity 0.6.12;

interface IStrategy {
    function rebalance() external;

    function deposit(uint256 amount) external;

    function beforeWithdraw() external;

    function withdraw(uint256 amount) external;

    function withdrawAll() external;

    function isEmpty() external view returns (bool);

    function isReservedToken(address _token) external view returns (bool);

    function token() external view returns (address);

    function totalLocked() external view returns (uint256);

    function pause() external;

    function unpause() external;

    function shutdown() external;

    function open() external;
}




pragma solidity 0.6.12;




abstract contract VTokenBase is PoolShareToken {
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(
        string memory name,
        string memory symbol,
        address _token,
        address _controller
    ) public PoolShareToken(name, symbol, _token, _controller) {
        require(_controller != address(0), "Controller address is zero");
    }

    modifier onlyController() {
        require(address(controller) == _msgSender(), "Caller is not the controller");
        _;
    }

    function pause() external onlyController {
        IStrategy strategy = IStrategy(controller.poolStrategy(address(this)));
        strategy.pause();
        _pause();
    }

    function unpause() external onlyController {
        IStrategy strategy = IStrategy(controller.poolStrategy(address(this)));
        strategy.unpause();
        _unpause();
    }

    function shutdown() external onlyController {
        IStrategy strategy = IStrategy(controller.poolStrategy(address(this)));
        strategy.shutdown();
        _shutdown();
    }

    function open() external onlyController {
        IStrategy strategy = IStrategy(controller.poolStrategy(address(this)));
        strategy.open();
        _open();
    }

    function approveToken() external virtual onlyController {
        address strategy = controller.poolStrategy(address(this));
        token.approve(strategy, MAX_UINT_VALUE);
        IERC20(IStrategy(strategy).token()).approve(strategy, MAX_UINT_VALUE);
    }

    function resetApproval() external virtual onlyController {
        address strategy = controller.poolStrategy(address(this));
        token.approve(strategy, 0);
        IERC20(IStrategy(strategy).token()).approve(strategy, 0);
    }

    function rebalance() external virtual {
        require(!stopEverything || (_msgSender() == address(controller)), "Contract has shutdown");
        IStrategy strategy = IStrategy(controller.poolStrategy(address(this)));
        strategy.rebalance();
    }

    function sweepErc20(address _erc20) external virtual {
        _sweepErc20(_erc20);
    }

    function tokenLocked() public virtual view returns (uint256) {
        IStrategy strategy = IStrategy(controller.poolStrategy(address(this)));
        return strategy.totalLocked();
    }

    function totalValue() public override view returns (uint256) {
        return tokenLocked().add(tokensHere());
    }

    function _afterBurning(uint256 _amount) internal override {
        uint256 balanceHere = tokensHere();
        if (balanceHere < _amount) {
            _withdrawCollateral(_amount.sub(balanceHere));
            balanceHere = tokensHere();
            _amount = balanceHere < _amount ? balanceHere : _amount;
        }
        token.transfer(_msgSender(), _amount);
    }

    function _beforeBurning(
        uint256 /* shares */
    ) internal override {
        IStrategy strategy = IStrategy(controller.poolStrategy(address(this)));
        strategy.beforeWithdraw();
    }

    function _beforeMinting(uint256 amount) internal override {
        token.transferFrom(_msgSender(), address(this), amount);
    }

    function _depositCollateral(uint256 amount) internal virtual {
        IStrategy strategy = IStrategy(controller.poolStrategy(address(this)));
        strategy.deposit(amount);
    }

    function _withdrawCollateral(uint256 amount) internal virtual {
        IStrategy strategy = IStrategy(controller.poolStrategy(address(this)));
        strategy.withdraw(amount);
    }

    function _sweepErc20(address _from) internal {
        IStrategy strategy = IStrategy(controller.poolStrategy(address(this)));
        require(
            _from != address(token) &&
                _from != address(this) &&
                !strategy.isReservedToken(_from) &&
                _from != address(rewardsToken),
            "Not allowed to sweep"
        );
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
        uint256 amt = IERC20(_from).balanceOf(address(this));
        IERC20(_from).safeApprove(address(uniswapRouter), amt);
        address[] memory path;
        if (address(token) == WETH) {
            path = new address[](2);
            path[0] = _from;
            path[1] = address(token);
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = WETH;
            path[2] = address(token);
        }
        uniswapRouter.swapExactTokensForTokens(amt, 1, path, address(this), now + 30);
    }
}


interface TokenLike {
    function approve(address, uint256) external;

    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;

    function deposit() external payable;

    function withdraw(uint256) external;
}


pragma solidity 0.6.12;



contract VETH is VTokenBase {
    TokenLike public immutable weth;
    bool internal shouldDeposit = true;

    constructor(address _controller)
        public
        VTokenBase("vETH Pool", "vETH", 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, _controller)
    {
        weth = TokenLike(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }

    receive() external payable {
        if (shouldDeposit) {
            deposit();
        }
    }

    function withdrawETH(uint256 shares)
        external
        whenNotShutdown
        nonReentrant
        updateReward(_msgSender())
    {
        require(shares != 0, "Withdraw must be greater than 0");
        _getReward();
        _beforeBurning(shares);
        uint256 sharesAfterFee = _handleFee(shares);
        uint256 amount = sharesAfterFee.mul(totalValue()).div(totalSupply());
        _burn(_msgSender(), sharesAfterFee);

        uint256 balanceHere = tokensHere();
        if (balanceHere < amount) {
            _withdrawCollateral(amount.sub(balanceHere));
            balanceHere = tokensHere();
            amount = balanceHere < amount ? balanceHere : amount;
        }
        shouldDeposit = false;
        weth.withdraw(amount);
        shouldDeposit = true;
        _msgSender().transfer(amount);

        emit Withdraw(_msgSender(), shares, amount);
    }

    function deposit() public payable whenNotPaused nonReentrant updateReward(_msgSender()) {
        uint256 shares = _calculateShares(msg.value);
        weth.deposit{value: msg.value}();
        _mint(_msgSender(), shares);
    }
}