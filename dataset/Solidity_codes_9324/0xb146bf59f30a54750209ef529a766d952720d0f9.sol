
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
}//MIT
pragma solidity 0.6.12;

interface IBPool {


    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function getBalance(address token) external view returns (uint);

}//MIT
pragma solidity 0.6.12;

interface ILPool {


    function balanceOf(address owner) external view returns (uint);

}//MIT
pragma solidity 0.6.12;

interface ICToken {


    function borrowBalanceStored(address account) external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function exchangeRateStored() external view returns (uint);

}// GPL-3.0
pragma solidity 0.6.12;

interface ISetToken {


    function balanceOf(address owner) external view returns (uint);


    function getTotalComponentRealUnits(address _component) external view returns(uint);

}//MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


interface IMasterChef {

    using SafeERC20 for IERC20;

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. SUSHI to distribute per block.
        uint256 lastRewardBlock; // Last block number that SUSHI distribution occurs.
        uint256 accSushiPerShare; // Accumulated SUSHI per share, times 1e12. See below.
    }

    function userInfo(uint256, address)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);


    function poolInfo(uint256 pid) external view returns (PoolInfo memory);


    function totalAllocPoint() external view returns (uint256);


    function deposit(uint256 _pid, uint256 _amount) external;

}// GPL-3.0

pragma solidity >=0.5.0;


interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;

}//MIT
pragma solidity 0.6.12;


contract CreamVotingPower {

    using SafeMath for uint256;
    using Address for address payable;
    using SafeERC20 for IERC20;

    struct VotingPower {
        uint256 wallet;
        uint256 crCream;
        uint256 sushiswap;
        uint256 masterChef;
        uint256 uniswap;
        uint256 balancer;
        uint256 pool;
        uint256 lending;
    }

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    address public constant defiPulseIndex = 0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b;
    address public constant cream = 0x2ba592F78dB6436527729929AAf6c908497cB200;
    address public constant crCream =
        0x892B14321a4FCba80669aE30Bd0cd99a7ECF6aC0;
    address[] public lPool = [
        address(0x780F75ad0B02afeb6039672E6a6CEDe7447a8b45),
        address(0xBdc3372161dfd0361161e06083eE5D52a9cE7595),
        address(0xD5586C1804D2e1795f3FBbAfB1FBB9099ee20A6c),
        address(0xE618C25f580684770f2578FAca31fb7aCB2F5945)
    ];
    address public constant sushiswap =
        0xf169CeA51EB51774cF107c88309717ddA20be167;
    address public constant masterchef =
        0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd;
    address public constant uniswap =
        0xddF9b7a31b32EBAF5c064C80900046C9e5b7C65F;
    address public constant balancer =
        0x280267901C175565C64ACBD9A3c8F60705A72639;

    uint256 public MINIMUM_VOTING_POWER = 1e18;

    function balanceOf(address _holder) public view returns (uint256) {

        require(_holder != address(0), "VotingPower.getVotingPower: Zero Address");
        uint256 votingPower =
            _creamBalance(_holder)
                .add(_addThreeUnites(_lendingSupply(_holder), _sushiswapBalance(_holder), _uniswapBalance(_holder)))
                .add(_addThreeUnites(_balancerBalance(_holder), _stakedInLPool(_holder), _defiPulseBalance(_holder)))
                .sub(_borrowedBalance(_holder));

        return votingPower >= MINIMUM_VOTING_POWER ? votingPower : 0;
    }

    function _creamBalance(address _holder) internal view returns (uint256) {

        require(
            _holder != address(0),
            "VotingPower.creamBalance: Zero Address"
        );

        return IERC20(cream).balanceOf(_holder);
    }

    function _lendingSupply(address _holder) internal view returns (uint256) {

        require(
            _holder != address(0),
            "VotingPower.lendingSupply: Zero Address"
        );

        uint256 totalLending = ICToken(crCream).balanceOf(_holder).mul(ICToken(crCream).exchangeRateStored()).div(1e18);
        uint256 borrowed = ICToken(crCream).borrowBalanceStored(_holder);

        if (borrowed > totalLending) {
            return 0;
        }

        return totalLending.sub(borrowed);
    }

    function _uniswapBalance(address _holder) internal view returns (uint256) {

        uint256 staked = IUniswapV2Pair(uniswap).balanceOf(_holder);
        uint256 lpTotalSupply = IUniswapV2Pair(uniswap).totalSupply();
        (uint112 _reserve0,,) = IUniswapV2Pair(uniswap).getReserves();

        staked = uint256(_reserve0).mul(staked).div(lpTotalSupply);

        return staked;
    }

    function _sushiswapBalance(address _holder) internal view returns (uint256) {

        (uint256 staked, ) = IMasterChef(masterchef).userInfo(22, _holder);
        uint256 lpInWallet = IUniswapV2Pair(sushiswap).balanceOf(_holder);
        uint256 lpTotalSupply = IUniswapV2Pair(sushiswap).totalSupply();
        (uint112 _reserve0,,) = IUniswapV2Pair(sushiswap).getReserves();
        uint256 creamPerLPToken = uint256(_reserve0).div(lpTotalSupply);

        return staked.add(lpInWallet).mul(creamPerLPToken);
    }

    function _balancerBalance(address _holder) internal view returns (uint256) {

        uint256 staked = IBPool(balancer).balanceOf(_holder);
        uint256 crInBalancer = IBPool(balancer).getBalance(cream);
        uint256 lpTotalSupply = IBPool(balancer).totalSupply();

        return crInBalancer.mul(staked).div(lpTotalSupply);
    }

    function _stakedInLPool(address _holder) internal view returns (uint256) {

        require(
            _holder != address(0),
            "VotingPower.lendingSupply: Zero Address"
        );

        uint256 totalStaked = 0;

        for (uint256 i = 0; i < 4; i++) {
            totalStaked = totalStaked.add(ILPool(lPool[i]).balanceOf(_holder));
        }

        return totalStaked;
    }

    function _borrowedBalance(address _holder) internal view returns (uint256) {

        require(
            _holder != address(0),
            "VotingPower.lendingSupply: Zero Address"
        );

        return ICToken(crCream).borrowBalanceStored(_holder);
    }

    function _defiPulseBalance(address _holder) internal view returns (uint256) {

        require(
            _holder != address(0),
            "VotingPower.lendingSupply: Zero Address"
        );

        return ISetToken(defiPulseIndex).balanceOf(_holder).mul(ISetToken(defiPulseIndex).getTotalComponentRealUnits(cream)).div(1e18);
    }

    function _addThreeUnites(uint256 a, uint256 b, uint256 c) private pure returns (uint256) {

        return a.add(b).add(c);
    }
}