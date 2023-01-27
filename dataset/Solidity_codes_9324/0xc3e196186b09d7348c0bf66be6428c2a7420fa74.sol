interface IMintable {

    function mint(address to, uint amount) external;

}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

pragma solidity ^0.6.0;



abstract contract IRewardDistributionRecipient is Ownable {
    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward) virtual external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyOwner
    {
        rewardDistribution = _rewardDistribution;
    }
}pragma solidity >=0.5.0;

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

}// MIT

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
}// MIT

pragma solidity ^0.6.0;






contract MiningV2 is Ownable {

    using SafeMath for uint256;

    IUniswapV2Pair public pair;
    IMintable public token;
    IRewardDistributionRecipient public pool;

    uint public constant DEV_REWARD = 10e18;
    uint public constant MINING_REWARD = 100e18;
    uint public constant BLOCK_TIME = 1 days;
    address public dev;
    uint public lastBlocktime;
    uint public preR0;
    uint public preR1;
    bool public started;

    constructor(address _pair, address _token, address _pool, address _dev) public {
        require(_pair != address(0), "invalid pair");
        require(_token != address(0), "invalid token");
        require(_pool != address(0), "invalid pool");
        require(_dev != address(0), "invalid dev");
        pair = IUniswapV2Pair(_pair);
        token = IMintable(_token);
        pool = IRewardDistributionRecipient(_pool);
        dev = _dev;
    }

    modifier isStarted() {

        require(started, "not started");
        _;
    }

    modifier isInBlockWindow() {

        require(inBlockWindow(), "not in block window");
        _;
    }

    function mine() isInBlockWindow public {

        require(priceUp(), "CAN NOT MINE");
        uint amount = MINING_REWARD;
        token.mint(address(pool), amount);
        token.mint(address(dev), DEV_REWARD);
        pool.notifyRewardAmount(amount);
        (uint curR0, uint curR1, ) = pair.getReserves();
        if(curR0 > preR0.mul(2)){
            curR0 = preR0.mul(2);
        }
        if(curR1 > preR1.mul(2)){
            curR1 = preR1.mul(2);
        }
        preR0 = curR0;
        preR1 = curR1;
        lastBlocktime = block.timestamp;
    }

    function priceUp() public view isStarted returns (bool) {

        (uint curR0, uint curR1, ) = pair.getReserves();
        if(pair.token0() == address(token)){
            return curR0.mul(preR1) < curR1.mul(preR0);
        }else{
            return curR0.mul(preR1) > curR1.mul(preR0);
        }
    }


    function inBlockWindow() public view returns (bool){

        return block.timestamp > lastBlocktime.add(BLOCK_TIME);
    }

    function start() public onlyOwner {

        require(!started, "already started");
        (uint curR0, uint curR1, ) = pair.getReserves();
        require(curR0 > 0, "CAN NOT START");
        require(curR1 > 0, "CAN NOT START");
        preR0 = curR0;
        preR1 = curR1;
        lastBlocktime = block.timestamp;
        started = true;
    }

    function setDev(address _dev) public onlyOwner {

        require(_dev != address(0), "invalid dev");
        dev = _dev;
    }
}