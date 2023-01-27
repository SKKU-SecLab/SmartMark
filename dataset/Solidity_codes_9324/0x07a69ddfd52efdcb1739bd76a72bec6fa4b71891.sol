

pragma solidity ^0.8.0;



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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}



contract FundRaising is Ownable {


    mapping(uint256 => uint256) public prices;
    
  
    
    address public usdt;
    address public mis;

    struct Round {
        uint256 price;
        uint start;
        uint duration;
        uint usdtMin;
        uint usdtMax;
        uint supply;
    }
    
    struct Record {
        uint256 lockedAmount;
        uint256 lockStartTs;
        bool useUnlockB;
    }
    mapping(address => uint256) public recordsLen;
    mapping(address => mapping(uint256 => Record)) public records;
    mapping(uint => mapping(address => bool)) public paid;
    Round[] public rounds;
    mapping(uint256 => uint256) public bought;

    
    constructor(address usdt_, address mis_) {
        usdt = usdt_;
        mis = mis_;

        uint256 usdtDecimals = IERC20Metadata(usdt).decimals();
        uint256 misDecimals = IERC20Metadata(mis).decimals();
        

        rounds.push(Round(
            150 * 10**(16 + usdtDecimals - misDecimals),
            1619161200, // start
            72 * 3600,
            20000 * 10**usdtDecimals,
            50000 * 10**usdtDecimals,
            270000 * 10**usdtDecimals // token supply in usdt
        ));
        rounds.push(Round(
            200 * 10**(16 + usdtDecimals - misDecimals),
            1619420400, // start
            72 * 3600,
            100 * 10**usdtDecimals,
            1000 * 10**usdtDecimals,
            216000 * 10**usdtDecimals // token supply in usdt
        ));
        rounds.push(Round(
            250 * 10**(16 + usdtDecimals - misDecimals),
            1619679600, // start
            72 * 3600,
            100 * 10**usdtDecimals,
            1000 * 10**usdtDecimals,
            180000 * 10**usdtDecimals // token supply in usdt
        ));
    }

    
    function cliff(uint256 n, uint256 t, uint256 a, uint256 r) internal pure returns(uint256) {

        uint256 total = a * r / 10**18;
        return n >= t ? total : 0;
    }
    
    function linear(uint256 n, uint256 t0, uint256 t1, uint256 s, uint256 a, uint256 r) internal pure returns(uint256) {

        uint256 total = a * r / 10**18;
        if (n < t0) {
            return 0;
        }
        else if (n >= t1) {
            return total;
        }
        else {
            uint256 perStep = total / ((t1 - t0) / s);
            uint passedSteps = (n - t0) / s;
            return perStep * passedSteps;
        }
    }

    function getUnlockA(uint totalLocked, uint lockStartTs) internal view returns(uint) {

        uint256 n = block.timestamp;
        uint256 t0 = lockStartTs + 1 * 30 * 86400;
        uint256 t1 = lockStartTs + 6 * 30 * 86400;
        uint256 r0 = 50 * 10**16;
        uint256 r1 = 50 * 10**16;
        uint256 s = 30 * 86400;
        return cliff(n, t0, totalLocked, r0) + linear(n, t0, t1, s, totalLocked, r1);
    }
    
    function getUnlockB(uint totalLocked, uint lockStartTs) internal view returns(uint) {

        uint256 n = block.timestamp;
        uint256 t0 = lockStartTs;
        uint256 t1 = lockStartTs + 10 * 30 * 86400;
        uint256 r = 100 * 10**16;
        uint256 s = 30 * 86400;
        return linear(n, t0, t1, s, totalLocked, r);
    }


    function deposit(address token, uint256 amount) public onlyOwner {

        safeTransferFrom(token, msg.sender, address(this), amount);
    }

    function withdraw(address token, uint256 amount) public onlyOwner {

        safeTransfer(token, msg.sender, amount);
    }

    function updateRound(
        uint256 index,
        uint256 price,
        uint256 start,
        uint256 duration,
        uint256 usdtMin,
        uint256 usdtMax,
        uint256 supply
    ) public onlyOwner {

        Round memory round = Round(price, start, duration, usdtMin, usdtMax, supply);
        if (index >= 0 && index < rounds.length) {
            rounds[index] = round;
        }
        else {
            rounds.push(round);
        }
    }
    

    function _useUnlockPlanB(uint256 usdtAmount) public view returns(bool) {

        return usdtAmount >= 20000 * 10**IERC20Metadata(usdt).decimals();
    }
    
    function buy(uint256 roundId, uint256 usdtAmount) public {

        
        require(roundId < rounds.length, "WRONG_ROUND_ID");
        require(!paid[roundId][msg.sender], "ALREADY_BOUGHT");
        Round storage round = rounds[roundId];
        require(usdtAmount >= round.usdtMin, "LESS_THAN_MIN");
        require(usdtAmount <= round.usdtMax, "MORE_THAN_MAX");
        require(bought[roundId] + usdtAmount <= round.supply, "EXCEED_SUPPLY");
        
        safeTransferFrom(usdt,msg.sender, address(this), usdtAmount);
        
        
        records[msg.sender][recordsLen[msg.sender]] = Record(
            10**18 * usdtAmount / round.price,
            round.start + round.duration,
            _useUnlockPlanB(usdtAmount)
        );
        recordsLen[msg.sender] += 1;
        
        paid[roundId][msg.sender] = true;
        bought[roundId] += usdtAmount;
    }
    
    mapping(address => uint256) public claimed;
    
    function available(address account) public view returns(uint256) {

        uint len = recordsLen[account];
        uint total = 0;
        for(uint256 i=0;i< len;i++) {
            Record storage record = records[account][i];
            if (record.useUnlockB) {
                total += getUnlockB(record.lockedAmount, record.lockStartTs);
            }
            else {
                total += getUnlockA(record.lockedAmount, record.lockStartTs);
            }
        }
        return total - claimed[account];
    }
    
    function claim() public {

        uint a = available(msg.sender);
        require(a > 0, "NOTHING_TO_CLAIM");
        safeTransfer(mis, msg.sender, a);
        claimed[msg.sender] += a;
    }

    function safeApprove(address token, address to, uint value) public {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) public {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) public {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) public {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}