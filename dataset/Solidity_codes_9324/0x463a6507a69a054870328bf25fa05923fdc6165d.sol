
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



contract ZXOwnable {

    address public owner;

    function Ownable() {

        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {

        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract ZXToken {


    function totalSupply() constant returns (uint supply) {}


    function balanceOf(address _owner) constant returns (uint balance) {}


    function transfer(address _to, uint _value) returns (bool success) {}


    function transferFrom(address _from, address _to, uint _value) returns (bool success) {}


    function approve(address _spender, uint _value) returns (bool success) {}


    function allowance(address _owner, address _spender) constant returns (uint remaining) {}


    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract ZeroExTokenTransferProxy is ZXOwnable {


    modifier onlyAuthorized {

        require(authorized[msg.sender]);
        _;
    }

    modifier targetAuthorized(address target) {

        require(authorized[target]);
        _;
    }

    modifier targetNotAuthorized(address target) {

        require(!authorized[target]);
        _;
    }

    mapping (address => bool) public authorized;
    address[] public authorities;

    event LogAuthorizedAddressAdded(address indexed target, address indexed caller);
    event LogAuthorizedAddressRemoved(address indexed target, address indexed caller);


    function addAuthorizedAddress(address target)
        public
        onlyOwner
        targetNotAuthorized(target)
    {

        authorized[target] = true;
        authorities.push(target);
        LogAuthorizedAddressAdded(target, msg.sender);
    }

    function removeAuthorizedAddress(address target)
        public
        onlyOwner
        targetAuthorized(target)
    {

        delete authorized[target];
        for (uint i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                authorities[i] = authorities[authorities.length - 1];
                authorities.length -= 1;
                break;
            }
        }
        LogAuthorizedAddressRemoved(target, msg.sender);
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint value)
        public
        onlyAuthorized
        returns (bool)
    {

        return ZXToken(token).transferFrom(from, to, value);
    }


    function getAuthorizedAddresses()
        public
        constant
        returns (address[])
    {

        return authorities;
    }
}

contract ZXSafeMath {

    function safeMul(uint a, uint b) internal constant returns (uint256) {

        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal constant returns (uint256) {

        uint c = a / b;
        return c;
    }

    function safeSub(uint a, uint b) internal constant returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal constant returns (uint256) {

        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {

        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {

        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {

        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {

        return a < b ? a : b;
    }
}

contract ZeroExExchange is ZXSafeMath {


    enum Errors {
        ORDER_EXPIRED,                    // Order has already expired
        ORDER_FULLY_FILLED_OR_CANCELLED,  // Order has already been fully filled or cancelled
        ROUNDING_ERROR_TOO_LARGE,         // Rounding error too large
        INSUFFICIENT_BALANCE_OR_ALLOWANCE // Insufficient balance or allowance for token transfer
    }

    string constant public VERSION = "1.0.0";
    uint16 constant public EXTERNAL_QUERY_GAS_LIMIT = 4999;    // Changes to state require at least 5000 gas

    address public ZRX_TOKEN_CONTRACT;
    address public TOKEN_TRANSFER_PROXY_CONTRACT;

    mapping (bytes32 => uint) public filled;
    mapping (bytes32 => uint) public cancelled;

    event LogFill(
        address indexed maker,
        address taker,
        address indexed feeRecipient,
        address makerToken,
        address takerToken,
        uint filledMakerTokenAmount,
        uint filledTakerTokenAmount,
        uint paidMakerFee,
        uint paidTakerFee,
        bytes32 indexed tokens, // keccak256(makerToken, takerToken), allows subscribing to a token pair
        bytes32 orderHash
    );

    event LogCancel(
        address indexed maker,
        address indexed feeRecipient,
        address makerToken,
        address takerToken,
        uint cancelledMakerTokenAmount,
        uint cancelledTakerTokenAmount,
        bytes32 indexed tokens,
        bytes32 orderHash
    );

    event LogError(uint8 indexed errorId, bytes32 indexed orderHash);

    struct Order {
        address maker;
        address taker;
        address makerToken;
        address takerToken;
        address feeRecipient;
        uint makerTokenAmount;
        uint takerTokenAmount;
        uint makerFee;
        uint takerFee;
        uint expirationTimestampInSec;
        bytes32 orderHash;
    }

    function ZeroExExchange(address _zrxToken, address _tokenTransferProxy) {

        ZRX_TOKEN_CONTRACT = _zrxToken;
        TOKEN_TRANSFER_PROXY_CONTRACT = _tokenTransferProxy;
    }


    function fillOrder(
          address[5] orderAddresses,
          uint[6] orderValues,
          uint fillTakerTokenAmount,
          bool shouldThrowOnInsufficientBalanceOrAllowance,
          uint8 v,
          bytes32 r,
          bytes32 s)
          public
          returns (uint filledTakerTokenAmount)
    {

        Order memory order = Order({
            maker: orderAddresses[0],
            taker: orderAddresses[1],
            makerToken: orderAddresses[2],
            takerToken: orderAddresses[3],
            feeRecipient: orderAddresses[4],
            makerTokenAmount: orderValues[0],
            takerTokenAmount: orderValues[1],
            makerFee: orderValues[2],
            takerFee: orderValues[3],
            expirationTimestampInSec: orderValues[4],
            orderHash: getOrderHash(orderAddresses, orderValues)
        });

        require(order.taker == address(0) || order.taker == msg.sender);
        require(order.makerTokenAmount > 0 && order.takerTokenAmount > 0 && fillTakerTokenAmount > 0);
        require(isValidSignature(
            order.maker,
            order.orderHash,
            v,
            r,
            s
        ));

        if (block.timestamp >= order.expirationTimestampInSec) {
            LogError(uint8(Errors.ORDER_EXPIRED), order.orderHash);
            return 0;
        }

        uint remainingTakerTokenAmount = safeSub(order.takerTokenAmount, getUnavailableTakerTokenAmount(order.orderHash));
        filledTakerTokenAmount = min256(fillTakerTokenAmount, remainingTakerTokenAmount);
        if (filledTakerTokenAmount == 0) {
            LogError(uint8(Errors.ORDER_FULLY_FILLED_OR_CANCELLED), order.orderHash);
            return 0;
        }

        if (isRoundingError(filledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount)) {
            LogError(uint8(Errors.ROUNDING_ERROR_TOO_LARGE), order.orderHash);
            return 0;
        }

        if (!shouldThrowOnInsufficientBalanceOrAllowance && !isTransferable(order, filledTakerTokenAmount)) {
            LogError(uint8(Errors.INSUFFICIENT_BALANCE_OR_ALLOWANCE), order.orderHash);
            return 0;
        }

        uint filledMakerTokenAmount = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount);
        uint paidMakerFee;
        uint paidTakerFee;
        filled[order.orderHash] = safeAdd(filled[order.orderHash], filledTakerTokenAmount);
        require(transferViaTokenTransferProxy(
            order.makerToken,
            order.maker,
            msg.sender,
            filledMakerTokenAmount
        ));
        require(transferViaTokenTransferProxy(
            order.takerToken,
            msg.sender,
            order.maker,
            filledTakerTokenAmount
        ));
        if (order.feeRecipient != address(0)) {
            if (order.makerFee > 0) {
                paidMakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerFee);
                require(transferViaTokenTransferProxy(
                    ZRX_TOKEN_CONTRACT,
                    order.maker,
                    order.feeRecipient,
                    paidMakerFee
                ));
            }
            if (order.takerFee > 0) {
                paidTakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.takerFee);
                require(transferViaTokenTransferProxy(
                    ZRX_TOKEN_CONTRACT,
                    msg.sender,
                    order.feeRecipient,
                    paidTakerFee
                ));
            }
        }

        LogFill(
            order.maker,
            msg.sender,
            order.feeRecipient,
            order.makerToken,
            order.takerToken,
            filledMakerTokenAmount,
            filledTakerTokenAmount,
            paidMakerFee,
            paidTakerFee,
            keccak256(order.makerToken, order.takerToken),
            order.orderHash
        );
        return filledTakerTokenAmount;
    }

    function cancelOrder(
        address[5] orderAddresses,
        uint[6] orderValues,
        uint cancelTakerTokenAmount)
        public
        returns (uint)
    {

        Order memory order = Order({
            maker: orderAddresses[0],
            taker: orderAddresses[1],
            makerToken: orderAddresses[2],
            takerToken: orderAddresses[3],
            feeRecipient: orderAddresses[4],
            makerTokenAmount: orderValues[0],
            takerTokenAmount: orderValues[1],
            makerFee: orderValues[2],
            takerFee: orderValues[3],
            expirationTimestampInSec: orderValues[4],
            orderHash: getOrderHash(orderAddresses, orderValues)
        });

        require(order.maker == msg.sender);
        require(order.makerTokenAmount > 0 && order.takerTokenAmount > 0 && cancelTakerTokenAmount > 0);

        if (block.timestamp >= order.expirationTimestampInSec) {
            LogError(uint8(Errors.ORDER_EXPIRED), order.orderHash);
            return 0;
        }

        uint remainingTakerTokenAmount = safeSub(order.takerTokenAmount, getUnavailableTakerTokenAmount(order.orderHash));
        uint cancelledTakerTokenAmount = min256(cancelTakerTokenAmount, remainingTakerTokenAmount);
        if (cancelledTakerTokenAmount == 0) {
            LogError(uint8(Errors.ORDER_FULLY_FILLED_OR_CANCELLED), order.orderHash);
            return 0;
        }

        cancelled[order.orderHash] = safeAdd(cancelled[order.orderHash], cancelledTakerTokenAmount);

        LogCancel(
            order.maker,
            order.feeRecipient,
            order.makerToken,
            order.takerToken,
            getPartialAmount(cancelledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount),
            cancelledTakerTokenAmount,
            keccak256(order.makerToken, order.takerToken),
            order.orderHash
        );
        return cancelledTakerTokenAmount;
    }


    function fillOrKillOrder(
        address[5] orderAddresses,
        uint[6] orderValues,
        uint fillTakerTokenAmount,
        uint8 v,
        bytes32 r,
        bytes32 s)
        public
    {

        require(fillOrder(
            orderAddresses,
            orderValues,
            fillTakerTokenAmount,
            false,
            v,
            r,
            s
        ) == fillTakerTokenAmount);
    }

    function batchFillOrders(
        address[5][] orderAddresses,
        uint[6][] orderValues,
        uint[] fillTakerTokenAmounts,
        bool shouldThrowOnInsufficientBalanceOrAllowance,
        uint8[] v,
        bytes32[] r,
        bytes32[] s)
        public
    {

        for (uint i = 0; i < orderAddresses.length; i++) {
            fillOrder(
                orderAddresses[i],
                orderValues[i],
                fillTakerTokenAmounts[i],
                shouldThrowOnInsufficientBalanceOrAllowance,
                v[i],
                r[i],
                s[i]
            );
        }
    }

    function batchFillOrKillOrders(
        address[5][] orderAddresses,
        uint[6][] orderValues,
        uint[] fillTakerTokenAmounts,
        uint8[] v,
        bytes32[] r,
        bytes32[] s)
        public
    {

        for (uint i = 0; i < orderAddresses.length; i++) {
            fillOrKillOrder(
                orderAddresses[i],
                orderValues[i],
                fillTakerTokenAmounts[i],
                v[i],
                r[i],
                s[i]
            );
        }
    }

    function fillOrdersUpTo(
        address[5][] orderAddresses,
        uint[6][] orderValues,
        uint fillTakerTokenAmount,
        bool shouldThrowOnInsufficientBalanceOrAllowance,
        uint8[] v,
        bytes32[] r,
        bytes32[] s)
        public
        returns (uint)
    {

        uint filledTakerTokenAmount = 0;
        for (uint i = 0; i < orderAddresses.length; i++) {
            require(orderAddresses[i][3] == orderAddresses[0][3]); // takerToken must be the same for each order
            filledTakerTokenAmount = safeAdd(filledTakerTokenAmount, fillOrder(
                orderAddresses[i],
                orderValues[i],
                safeSub(fillTakerTokenAmount, filledTakerTokenAmount),
                shouldThrowOnInsufficientBalanceOrAllowance,
                v[i],
                r[i],
                s[i]
            ));
            if (filledTakerTokenAmount == fillTakerTokenAmount) break;
        }
        return filledTakerTokenAmount;
    }

    function batchCancelOrders(
        address[5][] orderAddresses,
        uint[6][] orderValues,
        uint[] cancelTakerTokenAmounts)
        public
    {

        for (uint i = 0; i < orderAddresses.length; i++) {
            cancelOrder(
                orderAddresses[i],
                orderValues[i],
                cancelTakerTokenAmounts[i]
            );
        }
    }


    function getOrderHash(address[5] orderAddresses, uint[6] orderValues)
        public
        constant
        returns (bytes32)
    {

        return keccak256(
            address(this),
            orderAddresses[0], // maker
            orderAddresses[1], // taker
            orderAddresses[2], // makerToken
            orderAddresses[3], // takerToken
            orderAddresses[4], // feeRecipient
            orderValues[0],    // makerTokenAmount
            orderValues[1],    // takerTokenAmount
            orderValues[2],    // makerFee
            orderValues[3],    // takerFee
            orderValues[4],    // expirationTimestampInSec
            orderValues[5]     // salt
        );
    }

    function isValidSignature(
        address signer,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s)
        public
        constant
        returns (bool)
    {

        return signer == ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", hash),
            v,
            r,
            s
        );
    }

    function isRoundingError(uint numerator, uint denominator, uint target)
        public
        constant
        returns (bool)
    {

        uint remainder = mulmod(target, numerator, denominator);
        if (remainder == 0) return false; // No rounding error.

        uint errPercentageTimes1000000 = safeDiv(
            safeMul(remainder, 1000000),
            safeMul(numerator, target)
        );
        return errPercentageTimes1000000 > 1000;
    }

    function getPartialAmount(uint numerator, uint denominator, uint target)
        public
        constant
        returns (uint)
    {

        return safeDiv(safeMul(numerator, target), denominator);
    }

    function getUnavailableTakerTokenAmount(bytes32 orderHash)
        public
        constant
        returns (uint)
    {

        return safeAdd(filled[orderHash], cancelled[orderHash]);
    }



    function transferViaTokenTransferProxy(
        address token,
        address from,
        address to,
        uint value)
        internal
        returns (bool)
    {

        return ZeroExTokenTransferProxy(TOKEN_TRANSFER_PROXY_CONTRACT).transferFrom(token, from, to, value);
    }

    function isTransferable(Order order, uint fillTakerTokenAmount)
        internal
        constant  // The called token contracts may attempt to change state, but will not be able to due to gas limits on getBalance and getAllowance.
        returns (bool)
    {

        address taker = msg.sender;
        uint fillMakerTokenAmount = getPartialAmount(fillTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount);

        if (order.feeRecipient != address(0)) {
            bool isMakerTokenZRX = order.makerToken == ZRX_TOKEN_CONTRACT;
            bool isTakerTokenZRX = order.takerToken == ZRX_TOKEN_CONTRACT;
            uint paidMakerFee = getPartialAmount(fillTakerTokenAmount, order.takerTokenAmount, order.makerFee);
            uint paidTakerFee = getPartialAmount(fillTakerTokenAmount, order.takerTokenAmount, order.takerFee);
            uint requiredMakerZRX = isMakerTokenZRX ? safeAdd(fillMakerTokenAmount, paidMakerFee) : paidMakerFee;
            uint requiredTakerZRX = isTakerTokenZRX ? safeAdd(fillTakerTokenAmount, paidTakerFee) : paidTakerFee;

            if (   getBalance(ZRX_TOKEN_CONTRACT, order.maker) < requiredMakerZRX
                || getAllowance(ZRX_TOKEN_CONTRACT, order.maker) < requiredMakerZRX
                || getBalance(ZRX_TOKEN_CONTRACT, taker) < requiredTakerZRX
                || getAllowance(ZRX_TOKEN_CONTRACT, taker) < requiredTakerZRX
            ) return false;

            if (!isMakerTokenZRX && (   getBalance(order.makerToken, order.maker) < fillMakerTokenAmount // Don't double check makerToken if ZRX
                                     || getAllowance(order.makerToken, order.maker) < fillMakerTokenAmount)
            ) return false;
            if (!isTakerTokenZRX && (   getBalance(order.takerToken, taker) < fillTakerTokenAmount // Don't double check takerToken if ZRX
                                     || getAllowance(order.takerToken, taker) < fillTakerTokenAmount)
            ) return false;
        } else if (   getBalance(order.makerToken, order.maker) < fillMakerTokenAmount
                   || getAllowance(order.makerToken, order.maker) < fillMakerTokenAmount
                   || getBalance(order.takerToken, taker) < fillTakerTokenAmount
                   || getAllowance(order.takerToken, taker) < fillTakerTokenAmount
        ) return false;

        return true;
    }

    function getBalance(address token, address owner)
        internal
        constant  // The called token contract may attempt to change state, but will not be able to due to an added gas limit.
        returns (uint)
    {

        return Token(token).balanceOf.gas(EXTERNAL_QUERY_GAS_LIMIT)(owner); // Limit gas to prevent reentrancy
    }

    function getAllowance(address token, address owner)
        internal
        constant  // The called token contract may attempt to change state, but will not be able to due to an added gas limit.
        returns (uint)
    {

        return Token(token).allowance.gas(EXTERNAL_QUERY_GAS_LIMIT)(owner, TOKEN_TRANSFER_PROXY_CONTRACT); // Limit gas to prevent reentrancy
    }
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


interface DepositToken {

    function deposit() external payable;

    function withdraw(uint amount) external payable;

    function balanceOf(address who) external returns(uint256);

}

contract ZeroExHandler is ExchangeHandler {

    address wethAddress;
    address public exchangeAddress;
    uint constant MAX_UINT = 2**256 - 1;
    mapping(address => bool) public tokenAllowanceSet;

    event Order(
        address[8] addrs,
        uint256[6] values,
        uint256 value,
        address exc
    );

    constructor(address _exchangeAddr, address _wethAddr) public {
        exchangeAddress = _exchangeAddr;
        wethAddress = _wethAddr;
    }

    function() public payable { }

    function getAvailableAmount(
        address[8] orderAddresses,
        uint256[6] orderValues,
        uint256 exchangeFee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {

        if (!orderUsable(orderAddresses, orderValues)) {
            return 0;
        }
        address[5] memory newAddresses = convertAddressFormat(orderAddresses);
        bytes32 orderHash = ZeroExExchange(exchangeAddress).getOrderHash(newAddresses, orderValues);
        return SafeMath.sub(orderValues[1], ZeroExExchange(exchangeAddress).getUnavailableTakerTokenAmount(orderHash));
    }

    function performBuy(
        address[8] orderAddresses,
        uint256[6] orderValues,
        uint256 exchangeFee,
        uint256 amountToFill,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable returns (uint256) {

        require(orderUsable(orderAddresses, orderValues), "0xHandler - buy order validation failed");
        require(orderAddresses[3] == wethAddress, "0xHandler - ordAddr[3] != wethAddress for buy");
        require(amountToFill == msg.value, "0xHandler - amountToFill != msg.value for buy");
        DepositToken(wethAddress).deposit.value(amountToFill)();
        address[5] memory newAddresses = convertAddressFormat(orderAddresses);
        bytes32 orderHash = ZeroExExchange(exchangeAddress).getOrderHash(newAddresses, orderValues);
        setAllowance(wethAddress);
        ZeroExExchange(exchangeAddress).fillOrder(newAddresses, orderValues, amountToFill, true, v, r, s);
        uint receivedAmount = getPartialAmount(amountToFill, orderValues[1], orderValues[0]);
        require(
            Token(newAddresses[2]).transfer(msg.sender, receivedAmount),
            "0xHandler - failed to transfer bought tokens"
        );
        return receivedAmount;
    }

    function performSell(
        address[8] orderAddresses,
        uint256[6] orderValues,
        uint256 exchangeFee,
        uint256 amountToFill,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {

        require(orderUsable(orderAddresses, orderValues), "0xHandler - sell order validation failed");
        require(orderAddresses[2] == wethAddress, "0xHandler - ordAddr[3] != wethAddress for sell");
        address[5] memory newAddresses = convertAddressFormat(orderAddresses);
        setAllowance(orderAddresses[3]);
        ZeroExExchange(exchangeAddress).fillOrder(newAddresses, orderValues, amountToFill, false, v, r, s);
        uint receivedAmount = getPartialAmount(amountToFill, orderValues[1], orderValues[0]);
        DepositToken(wethAddress).withdraw(receivedAmount);
        msg.sender.transfer(receivedAmount);
        return receivedAmount;
    }

    function setAllowance(address token) internal {

        if(!tokenAllowanceSet[token]) {
            require(
                Token(token).approve(ZeroExExchange(exchangeAddress).TOKEN_TRANSFER_PROXY_CONTRACT(), MAX_UINT),
                "0xHandler - token approval failed"
            );
            tokenAllowanceSet[token] = true;
        }
    }

    function orderUsable(
        address[8] orderAddresses,
        uint256[6] orderValues
    ) internal returns (bool) {

        return (
            (orderAddresses[1] == address(0) ||    // Order's taker is anybody
            orderAddresses[1] == address(this)) && // Or the order's taker is this handler
            orderValues[3] == 0 &&                 // takerFees are 0
            orderValues[4] > block.timestamp       // Order is not expired
        );
    }

    function getPartialAmount(uint numerator, uint denominator, uint target)
        public
        constant
        returns (uint)
    {

        return SafeMath.div(SafeMath.mul(numerator, target), denominator);
    }

    function convertAddressFormat(address[8] oldFormat) internal pure returns (address[5] newFormat) {

        for(uint256 i = 0; i < newFormat.length; i++) {
            newFormat[i] = oldFormat[i];
        }
    }
}