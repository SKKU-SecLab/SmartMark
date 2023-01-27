
pragma solidity 0.4.24;

interface ExchangeHandler {


    function getAvailableAmount(
        address[8] orderAddresses,
        uint256[6] orderValues,
        uint256 exchangeFee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256);


    function performBuy(
        address[8] orderAddresses,
        uint256[6] orderValues,
        uint256 exchangeFee,
        uint256 amountToFill,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable returns (uint256);


    function performSell(
        address[8] orderAddresses,
        uint256[6] orderValues,
        uint256 exchangeFee,
        uint256 amountToFill,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256);

}


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract Token is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface Kyber {

    function trade(Token src, uint srcAmount, Token dest, address destAddress, uint maxDestAmount, uint minConversionRate, address walletId) public payable returns (uint);

}


contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  function Ownable() public {

    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

interface ENSResolver {

    function resolve(bytes32 node) public view returns (address);

}

contract KyberHandler is ExchangeHandler, Ownable {

    address public totlePrimary;
    ENSResolver public ensResolver;
    Token constant public ETH_TOKEN_ADDRESS = Token(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    bytes32 constant public kyberHash = 0xff4ab868fec98e1be4e10e14add037a8056132cf492bec627457a78c21f7531f;

    modifier onlyTotle() {

        require(msg.sender == totlePrimary, "KyberHandler - Only TotlePrimary allowed to call this function");
        _;
    }

    constructor(
        address _totlePrimary,
        address _ensResolver
    ) public {
        require(_totlePrimary != address(0x0));
        require(_ensResolver != address(0x0));
        totlePrimary = _totlePrimary;
        ensResolver = ENSResolver(_ensResolver);
    }

    function getAvailableAmount(
        address[8] orderAddresses,
        uint256[6] orderValues,
        uint256 exchangeFee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {

        return orderValues[0];
    }

    function performBuy(
        address[8] orderAddresses, // 0: tokenToGet (dest), 1: destAddress (primary), 2: walletId
        uint256[6] orderValues, // 0: srcAmount (amountToGive), 1: dstAmount (amountToGet), 2: maxDestAmount, 3: minConversionRate
        uint256 exchangeFee, // ignore
        uint256 amountToFill, // ignore
        uint8 v, // ignore
        bytes32 r, // ignore
        bytes32 s // ignore
    ) external payable onlyTotle returns (uint256) {

        require(msg.value == orderValues[0], "KyberHandler - msg.value != ordVal[0] for buy");

        uint256 tokenAmountObtained = trade(
            ETH_TOKEN_ADDRESS, // ERC20 src
            orderValues[0],    // uint srcAmount
            Token(orderAddresses[0]), // ERC20 dest
            orderAddresses[1], // address destAddress (where tokens are sent to after trade)
            orderValues[2],    // uint maxDestAmount
            orderValues[3],    // uint minConversionRate
            orderAddresses[2]  // address walletId
        );

        if(this.balance > 0) {
            msg.sender.transfer(this.balance);
        }

        return tokenAmountObtained;
    }

    function performSell(
        address[8] orderAddresses, // 0: tokenToGive (src), 1: destAddress (primary), 2: walletId
        uint256[6] orderValues, // 0: srcAmount (amountToGive), 1: dstAmount (amountToGet), 2: maxDestAmount, 3: minConversionRate
        uint256 exchangeFee, // ignore
        uint256 amountToFill, // ignore
        uint8 v, // ignore
        bytes32 r, // ignore
        bytes32 s // ignore
    ) external onlyTotle returns (uint256) {


        require(
            Token(orderAddresses[0]).approve(resolveExchangeAddress(), orderValues[0]),
            "KyberHandler - unable to approve token for sell"
        );

        uint256 etherAmountObtained = trade(
            Token(orderAddresses[0]), // ERC20 src
            orderValues[0],    // uint srcAmount
            ETH_TOKEN_ADDRESS, // ERC20 dest
            orderAddresses[1], // address destAddress (where tokens are sent to after trade)
            orderValues[2],    // uint maxDestAmount
            orderValues[3],    // uint minConversionRate
            orderAddresses[2]  // address walletId
        );

        return etherAmountObtained;
    }

    function trade(
        Token src,
        uint srcAmount,
        Token dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    ) internal returns (uint256) {

        uint256 valToSend = 0;
        if(src == ETH_TOKEN_ADDRESS) {
            valToSend = srcAmount;
        }

        Kyber exchange = Kyber(resolveExchangeAddress());

        return exchange.trade.value(valToSend)(
            src,
            srcAmount,
            dest,
            destAddress,
            maxDestAmount,
            minConversionRate,
            walletId
        );
    }

    function resolveExchangeAddress() internal view returns (address) {

        return ensResolver.resolve(kyberHash);
    }

    function withdrawToken(address _token, uint _amount) external onlyOwner returns (bool) {

        return Token(_token).transfer(owner, _amount);
    }

    function withdrawETH(uint _amount) external onlyOwner returns (bool) {

        owner.transfer(_amount);
    }

    function setTotle(address _totlePrimary) external onlyOwner {

        require(_totlePrimary != address(0x0), "Invalid address for totlePrimary");
        totlePrimary = _totlePrimary;
    }

    function() public payable {
        uint256 size;
        address sender = msg.sender;
        assembly {
            size := extcodesize(sender)
        }
        require(size > 0, "KyberHandler - can only send ether from another contract");
    }
}