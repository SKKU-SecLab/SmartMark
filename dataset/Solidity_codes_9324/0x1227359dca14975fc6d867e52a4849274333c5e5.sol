
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
pragma solidity >=0.7.0 <0.8.0;


abstract contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(
        address indexed previousOperator,
        address indexed newOperator
    );

    constructor() {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(
            _operator == _msgSender(),
            'operator: caller is not the operator'
        );
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(
            newOperator_ != address(0),
            'operator: zero address given for new operator'
        );
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}// MIT
pragma solidity >=0.7.0 <0.8.0;

interface IBurnProxy {

    function burnFrom(address from, uint256 amount) external;

}// MIT
pragma solidity >=0.7.0 <0.8.0;



interface IRedeemPool {

    event RedeemStart(address indexed starter, uint256 reward);
    event DepositBond(address indexed owner, uint256 amount);
    event RewardClaimed(address indexed owner, uint256 amount);
    event ReCharge(
        address indexed owner,
        address indexed token,
        uint256 indexed rid,
        uint256 amount
    );
    event ReChargeETH(
        address indexed owner,
        uint256 indexed rid,
        uint256 amount
    );
    event Withdrawal(
        address indexed from,
        address indexed to,
        uint256 indexed at
    );

    function rechargeCash(uint256 _rid, uint256 _amount) external;

}

contract RedeemPool is IRedeemPool, Operator {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Redeemseat {
        uint256 lastSnapshotIndex;
        uint256 deposit;
        uint256 rewardEarned;
    }

    struct RedeemSnapshot {
        uint256 start;
        uint256 end;
        uint256 rewardAll;
        uint256 deposit;
        uint256 maxDeposit;
        uint256 rewardPerBond;
    }

    RedeemSnapshot[] public history;
    mapping(address => Redeemseat) public seats;

    mapping(uint256 => uint256) public currentReward;
    mapping(uint256 => uint256) public lastReward;
    mapping(uint256 => uint256) public historyReward;

    address public bond;
    address public cash;
    address public swapRouter;
    address public burn;
    uint256 public cashToClaim = 0;
    uint256 public nextEpoch;
    uint256 public limitRatio = 1e19;
    uint256 public period = 86400;
    uint256 public epochDuration = 30 days;

    constructor(
        address _bond,
        address _cash,
        uint256 _nextEpoch,
        address _swapRouter
    ) {
        bond = _bond;
        cash = _cash;
        nextEpoch = _nextEpoch;
        swapRouter = _swapRouter;
        history.push(
            RedeemSnapshot({
                start: 0,
                end: block.timestamp,
                deposit: 0,
                maxDeposit: 0,
                rewardAll: 0,
                rewardPerBond: 0
            })
        );
    }

    function lastSnapshotIndex() public view returns (uint256) {

        return history.length.sub(1);
    }

    function canDeposit() public view returns (bool) {

        if (history[lastSnapshotIndex()].end >= block.timestamp) {
            return true;
        }
        if (block.timestamp < nextEpoch) {
            return false;
        }
        if (IERC20(cash).balanceOf(address(this)).sub(cashToClaim) > 0) {
            return true;
        }
        return false;
    }

    function setPeriod(uint256 _period) public onlyOperator {

        period = _period;
    }

    function setNextEpoch(uint256 _nextEpoch) public onlyOperator {

        nextEpoch = _nextEpoch;
    }

    function setEpochDuration(uint256 _epochDuration) public onlyOperator {

        epochDuration = _epochDuration;
    }

    function setLimitRatio(uint256 _limitRatio) public onlyOperator {

        limitRatio = _limitRatio;
        RedeemSnapshot memory snapShot = history[lastSnapshotIndex()];
        if (snapShot.end >= block.timestamp) {
            snapShot.maxDeposit = snapShot.rewardAll.mul(limitRatio).div(1e18);
        }
        history[lastSnapshotIndex()] = snapShot;
    }

    function setSwapRouter(address _swapRouter) public onlyOwner {

        swapRouter = _swapRouter;
    }

    function setBurn(address _burn) public onlyOwner {

        burn = _burn;
    }

    function startRedeem() public onlyOperator {

        _startRedeem();
    }

    function _startRedeem() internal {

        uint256 index = lastSnapshotIndex();
        require(
            block.timestamp > history[index].end,
            'last period have not end'
        );
        uint256 cashRemain = history[index].rewardAll.sub(
            history[index].rewardPerBond.mul(history[index].deposit).div(1e18)
        );

        cashToClaim = cashToClaim - cashRemain;

        uint256 rewardAll = IERC20(cash).balanceOf(address(this)).sub(
            cashToClaim
        );
        require(rewardAll > 0, 'require cash balance gt 0');

        cashToClaim = cashToClaim.add(rewardAll);
        history.push(
            RedeemSnapshot({
                start: block.timestamp,
                end: block.timestamp.add(period),
                deposit: 0,
                maxDeposit: rewardAll.mul(limitRatio).div(1e18),
                rewardAll: rewardAll,
                rewardPerBond: 0
            })
        );
        nextEpoch = nextEpoch.add(period).add(epochDuration);

        for (uint256 i = 0; i < 4; i++) {
            lastReward[i] = currentReward[i];
            currentReward[i] = 0;
        }
        _burnBond();
        emit RedeemStart(_msgSender(), rewardAll);
    }

    function _burnBond() internal {

        if (IERC20(bond).balanceOf(address(this)) <= 0) {
            return;
        }
        IERC20(bond).approve(burn, IERC20(bond).balanceOf(address(this)));
        IBurnProxy(burn).burnFrom(
            address(this),
            IERC20(bond).balanceOf(address(this))
        );
    }

    function burnBond() public onlyOperator {

        _burnBond();
    }

    function deposit(uint256 _amount) public updateReward(_msgSender()) {

        address director = _msgSender();
        uint256 index = lastSnapshotIndex();
        RedeemSnapshot memory snapShot = history[index];
        if (block.timestamp > nextEpoch && block.timestamp > snapShot.end) {
            _startRedeem();
            index = lastSnapshotIndex();
            snapShot = history[index];
        }
        require(
            block.timestamp >= snapShot.start &&
                block.timestamp <= snapShot.end,
            'not in redeem period'
        );
        require(
            snapShot.deposit.add(_amount) <= snapShot.maxDeposit,
            'deposit overflow'
        );
        snapShot.deposit = snapShot.deposit.add(_amount);
        snapShot.rewardPerBond = snapShot.rewardAll.mul(1e18).div(
            snapShot.deposit
        );
        if (snapShot.rewardPerBond > 1e18) {
            snapShot.rewardPerBond = 1e18;
        }
        history[index] = snapShot;

        IERC20(bond).safeTransferFrom(director, address(this), _amount);

        Redeemseat memory seat = seats[director];
        seat.lastSnapshotIndex = index;
        seat.deposit = seat.deposit.add(_amount);
        seats[director] = seat;
        emit DepositBond(director, _amount);
    }

    function claimReward() public {

        _claimRewad(_msgSender());
    }

    function claimRewadFor(address _director) public {

        _claimRewad(_director);
    }

    function _claimRewad(address _director) internal updateReward(_director) {

        Redeemseat memory seat = seats[_director];
        uint256 reward = seat.rewardEarned;
        if (reward == 0) {
            return;
        }

        cashToClaim = cashToClaim.sub(reward);
        IERC20(cash).safeTransfer(_director, reward);
        seat.rewardEarned = 0;
        seats[_director] = seat;

        emit RewardClaimed(_director, reward);
    }

    function rechargeCash(uint256 _rid, uint256 _amount) public override {

        recharge(_rid, cash, _amount);
    }

    function recharge(
        uint256 _rid,
        address _token,
        uint256 _amount
    ) public {

        IERC20(_token).safeTransferFrom(_msgSender(), address(this), _amount);
        if (_token == cash) {
            currentReward[_rid] = currentReward[_rid].add(_amount);
            historyReward[_rid] = historyReward[_rid].add(_amount);
        }

        emit ReCharge(_msgSender(), _token, _rid, _amount);
    }

    function rechargeETH(uint256 _rid) public payable {

        emit ReChargeETH(_msgSender(), _rid, msg.value);
    }

    function currentRewardDetail()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        if (block.timestamp > history[lastSnapshotIndex()].end) {
            return (
                IERC20(cash).balanceOf(address(this)).sub(cashToClaim),
                currentReward[0],
                currentReward[1],
                currentReward[2],
                currentReward[3]
            );
        }
        return (
            history[lastSnapshotIndex()].rewardAll,
            lastReward[0],
            lastReward[1],
            lastReward[2],
            lastReward[3]
        );
    }

    modifier updateReward(address _director) {

        uint256 rewardNew = rewardEarned(_director);
        Redeemseat memory seat = seats[_director];
        if (seat.rewardEarned == rewardNew) {
            _;
            return;
        }
        seat.rewardEarned = rewardNew;
        seat.deposit = 0;
        seats[_director] = seat;
        _;
    }

    function rewardEarned(address _director) public view returns (uint256) {

        Redeemseat memory seat = seats[_director];
        if (seat.deposit == 0) {
            return seat.rewardEarned;
        }
        uint256 lastIndex = lastSnapshotIndex();
        if (
            seat.lastSnapshotIndex == lastIndex &&
            history[lastIndex].end >= block.timestamp
        ) {
            return seat.rewardEarned;
        }
        return
            seat.rewardEarned.add(
                seat
                    .deposit
                    .mul(history[seat.lastSnapshotIndex].rewardPerBond)
                    .div(1e18)
            );
    }

    function historySnapShot() public view returns (uint256, uint256) {

        uint256 totalDeposit = 0;
        uint256 totalReward = 0;
        for (uint256 i = 0; i < history.length; i++) {
            totalDeposit = totalDeposit.add(history[i].deposit);
            totalReward = totalReward.add(history[i].rewardAll);
        }
        return (totalDeposit, totalReward);
    }

    function migrate(uint256 amount, address to) public onlyOwner {

        IERC20(cash).safeTransfer(to, amount);
        emit Withdrawal(_msgSender(), to, block.timestamp);
    }

    function swap(
        address token,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) public onlyOperator {

        if (amountIn > IERC20(token).balanceOf(address(this))) {
            amountIn = IERC20(token).balanceOf(address(this));
        }
        require(amountIn > 0, 'token insufficient');
        uint256 cashBefore = IERC20(cash).balanceOf(address(this));
        IERC20(token).approve(swapRouter, amountIn);
        IUniswapV2Router01(swapRouter).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 10 days
        );
        uint256 amount = IERC20(cash).balanceOf(address(this)).sub(cashBefore);

        uint256 rid = 0;
        currentReward[rid] = currentReward[rid].add(amount);
        historyReward[rid] = historyReward[rid].add(amount);
    }

    function swapETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) public onlyOperator {

        if (amountIn > address(this).balance) {
            amountIn = address(this).balance;
        }
        require(amountIn > 0, 'eth insufficient');
        uint256 cashBefore = IERC20(cash).balanceOf(address(this));
        IUniswapV2Router01(swapRouter).swapExactETHForTokens{value: amountIn}(
            amountOutMin,
            path,
            address(this),
            block.timestamp + 10 days
        );
        uint256 amount = IERC20(cash).balanceOf(address(this)).sub(cashBefore);

        uint256 rid = 0;
        currentReward[rid] = currentReward[rid].add(amount);
        historyReward[rid] = historyReward[rid].add(amount);
    }
}// MIT
pragma solidity >=0.7.0 <0.8.0;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


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


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


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

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


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