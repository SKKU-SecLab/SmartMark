
pragma solidity ^0.5.0;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event ForceTransfer(address indexed from, address indexed to, uint256 value, bytes32 details);
}

contract AtomicSwap is Ownable {

    using SafeMath for uint256;

    enum Direction { Buy, Sell }
    enum SwapState {
        INVALID,
        OPEN,
        CLOSED,
        EXPIRED
    }

    struct Swap {
        uint256 price;
        uint256 amount;
        uint256 remainingAmount;
        Direction direction;
        address openTrader;
        SwapState swapState;
    }
    mapping (uint256 => Swap) private swaps;
    uint256 public minimumSellPrice = 0;
    uint256 public minimumBuyPrice = 0;
    uint256 public minimumTradePrice = 0;
    uint256 public minimumAmount = 100 ether;
    uint256 priceMultiplicator = 1000000; // 6 decimals price

    uint256 swapId = 0;
    IERC20 awgContract;
    IERC20 awxContract;
    event Open(uint256 swapId);
    event Trade(uint256 swapId, address taker, uint256 amount);
    event Close(uint256 swapId);

    constructor(address _awgContract, address _awxContract) public {
        awgContract = IERC20(_awgContract);
        awxContract = IERC20(_awxContract);
    }

    function setMinimumPrices(uint256 _buyPrice, uint256 _sellPrice, uint256 _tradePrice) onlyOwner public {

        minimumBuyPrice = _buyPrice;
        minimumSellPrice = _sellPrice;
        minimumTradePrice = _tradePrice;
    }
    function setMinimumAmount(uint256 _amount) onlyOwner public {

        minimumAmount = _amount;
    }

    function forceCloseSwap(uint256 _swapId) onlyOwner public {

        Swap memory swap = swaps[_swapId];
        swap.swapState = SwapState.CLOSED;
        swaps[_swapId] = swap;
        if (swap.direction == Direction.Buy) {
            require(awgContract.transfer(swap.openTrader,(swap.remainingAmount).mul(swap.price).div(priceMultiplicator)), "Cannot transfer AWG");
        } else {
            require(awxContract.transfer(swap.openTrader,swap.remainingAmount), "Cannot transfer AWX");
        }
        emit Close(_swapId);
    }

    function openSwap(uint256 _price, uint256 _amount, Direction _direction) public {

        require(_amount > minimumAmount, "Amount is too low");
        if (_direction == Direction.Buy) {
            require((_price > minimumBuyPrice || isOwner()), "Price is too low");
            require(_amount.mul(_price).div(priceMultiplicator) <= awgContract.allowance(msg.sender, address(this)), "Cannot transfer AWG");
            require(awgContract.transferFrom(msg.sender, address(this), _amount.mul(_price).div(priceMultiplicator)));
        } else {
            require((_price > minimumSellPrice || isOwner()), "Price is too low");
            require(_amount <= awxContract.allowance(msg.sender, address(this)), "Cannot transfer AWX");
            require(awxContract.transferFrom(msg.sender, address(this), _amount));
        }
        Swap memory swap = Swap({
            price: _price,
            amount: _amount,
            direction: _direction,
            remainingAmount: _amount,
            openTrader: msg.sender,
            swapState: SwapState.OPEN
            });

        swaps[swapId] = swap;
        emit Open(swapId);
        swapId++;
    }

    function closeSwap(uint256 _swapId) public {

        Swap memory swap = swaps[_swapId];
        require(swap.swapState == SwapState.OPEN);
        require(swap.openTrader == msg.sender);

        if (swap.direction == Direction.Buy) {
            require(awgContract.transfer(msg.sender,(swap.remainingAmount).mul(swap.price).div(priceMultiplicator)), "Cannot transfer AWG");
        } else {
            require(awxContract.transfer(msg.sender,swap.remainingAmount), "Cannot transfer AWX");
        }

        swap.swapState = SwapState.CLOSED;
        swaps[_swapId] = swap;
        emit Close(_swapId);
    }

    function tradeSwap(uint256 _swapId, uint256 _amount) public {

        require(_amount > minimumAmount, "Amount is too low");
        Swap memory swap = swaps[_swapId];
        require(_amount <= swap.remainingAmount);
        require((swap.price > minimumTradePrice || isOwner()), "The swap price is too low.");
        require(swap.swapState == SwapState.OPEN);
        if (swap.direction == Direction.Buy) {
            require(_amount <= awxContract.allowance(msg.sender, address(this)));
            require(awxContract.transferFrom(msg.sender, swap.openTrader, _amount));
            require(awgContract.transfer(msg.sender, _amount.mul(swap.price).div(priceMultiplicator)));
        } else {
            require(_amount.mul(swap.price).div(priceMultiplicator) <= awgContract.allowance(msg.sender, address(this)));
            require(awgContract.transferFrom(msg.sender, swap.openTrader, _amount.mul(swap.price).div(priceMultiplicator)));
            require(awxContract.transfer(msg.sender, _amount));
        }
        swap.remainingAmount -= _amount;
        if (swap.remainingAmount == 0) {
            swap.swapState = SwapState.CLOSED;
            emit Close(_swapId);
        }
        swaps[_swapId] = swap;
        emit Trade(_swapId, msg.sender, _amount);
    }

    function getSwap(uint256 _swapId) public view returns (uint256 price, uint256 amount, uint256 remainingAmount, Direction direction, address openTrader, SwapState swapState) {

        Swap memory swap = swaps[_swapId];
        return (swap.price, swap.amount, swap.remainingAmount, swap.direction, swap.openTrader, swap.swapState);
    }
}