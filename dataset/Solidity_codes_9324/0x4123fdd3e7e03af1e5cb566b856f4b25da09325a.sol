
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

pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;

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
}//MIT


pragma solidity ^0.7.3;


abstract contract CC {
    function tokensMinted() public virtual view returns (uint256);
    function mint(
    uint256 _blockNumber,
    address _toAddress,
    uint256 _amount,
    bool asEgg,
    address payable _refundAddress,
    bytes calldata _data
    ) public virtual payable;
}

contract CCRescue is Ownable {


    using SafeMath for uint256;

    uint256 public constant FIRST_COCKATOO_PRICE_ETH = 1.25e15;
    uint256 public constant FIRST_EGG_PRICE_ETH = 1e15;
    uint256 public constant INCREMENTAL_PRICE_ETH = 1e14;

    CC private cryptocockatoos;
    
    uint256 public eggPrice;
    uint256 public cockatooPrice;
    bool public fixedPriceEnabled;
    bool public cockatooSaleEnabled;

    constructor (uint256 _eggPrice, uint256 _cockatooPrice, address contractAddress) {
        eggPrice = _eggPrice;
        cockatooPrice = _cockatooPrice;
        cryptocockatoos = CC(contractAddress);
        fixedPriceEnabled = true;
        cockatooSaleEnabled = false;
    }

    function setPrice(uint256 _eggPrice, uint256 _cockatooPrice) public onlyOwner {

        eggPrice = _eggPrice;
        cockatooPrice = _cockatooPrice;
    }

    function flipFixedPriceEnabled() public onlyOwner {

        fixedPriceEnabled = !(fixedPriceEnabled);
    }

    function flipCockatooSaleEnabled() public onlyOwner {

        cockatooSaleEnabled = !(cockatooSaleEnabled);
    }

    receive() external payable {
    }

    function withdraw() public onlyOwner {

        uint256 balance = address(this).balance;
        msg.sender.transfer(balance);
    }

    function getBalance() public view onlyOwner returns (uint256) {

        return address(this).balance;
    }

    function mintCockatoo(uint256 blocknumber, bool asEgg) public payable {


        require(fixedPriceEnabled, "CCRescue: Fixed price sale is disabled");

        uint256 _tokenNumber = cryptocockatoos.tokensMinted();
        uint256 balance = address(this).balance;
        uint256 actualPrice;
        
        if (asEgg) {
            actualPrice = FIRST_EGG_PRICE_ETH.add(INCREMENTAL_PRICE_ETH.mul(_tokenNumber));
            require(msg.value >= eggPrice, "CCRescue: Send more ether to mint an egg");
            require(balance >= actualPrice, "CCRescuse: Insufficient funds to mint an egg");
            msg.sender.transfer(msg.value.sub(eggPrice));
        }
        else {
            actualPrice = FIRST_COCKATOO_PRICE_ETH.add(INCREMENTAL_PRICE_ETH.mul(_tokenNumber));
            require(cockatooSaleEnabled, "CCRescue: Cockatoo sale is disabled");
            require(msg.value >= cockatooPrice, "CCRescue: Send more ether to mint a cockatoo");
            require(balance >= actualPrice, "CCRescue: Insufficient funds to mint a cockatoo");
            msg.sender.transfer(msg.value.sub(cockatooPrice));
        }
        
        address payable myAddress = payable(address(this));
        cryptocockatoos.mint{value:actualPrice}(blocknumber, msg.sender, 1, asEgg, myAddress, "");
    }
}