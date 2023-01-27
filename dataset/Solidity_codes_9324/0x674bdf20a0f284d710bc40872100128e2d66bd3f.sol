
pragma solidity ^0.7.0;


contract Ownable
{

    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor()
    {
        owner = msg.sender;
    }

    modifier onlyOwner()
    {

        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    function transferOwnership(
        address newOwner
        )
        public
        virtual
        onlyOwner
    {

        require(newOwner != address(0), "ZERO_ADDRESS");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership()
        public
        onlyOwner
    {

        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}




library MathUint
{

    using MathUint for uint;

    function mul(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {

        c = a * b;
        require(a == 0 || c / a == b, "MUL_OVERFLOW");
    }

    function sub(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint)
    {

        require(b <= a, "SUB_UNDERFLOW");
        return a - b;
    }

    function add(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {

        c = a + b;
        require(c >= a, "ADD_OVERFLOW");
    }

    function add64(
        uint64 a,
        uint64 b
        )
        internal
        pure
        returns (uint64 c)
    {

        c = a + b;
        require(c >= a, "ADD_OVERFLOW");
    }
}




abstract contract ERC20
{
    function totalSupply()
        public
        virtual
        view
        returns (uint);

    function balanceOf(
        address who
        )
        public
        virtual
        view
        returns (uint);

    function allowance(
        address owner,
        address spender
        )
        public
        virtual
        view
        returns (uint);

    function transfer(
        address to,
        uint value
        )
        public
        virtual
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint    value
        )
        public
        virtual
        returns (bool);

    function approve(
        address spender,
        uint    value
        )
        public
        virtual
        returns (bool);
}







library AddressUtil
{

    using AddressUtil for *;

    function isContract(
        address addr
        )
        internal
        view
        returns (bool)
    {

        bytes32 codehash;
        assembly { codehash := extcodehash(addr) }
        return (codehash != 0x0 &&
                codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
    }

    function toPayable(
        address addr
        )
        internal
        pure
        returns (address payable)
    {

        return payable(addr);
    }

    function sendETH(
        address to,
        uint    amount,
        uint    gasLimit
        )
        internal
        returns (bool success)
    {

        if (amount == 0) {
            return true;
        }
        address payable recipient = to.toPayable();
        (success, ) = recipient.call{value: amount, gas: gasLimit}("");
    }

    function sendETHAndVerify(
        address to,
        uint    amount,
        uint    gasLimit
        )
        internal
        returns (bool success)
    {

        success = to.sendETH(amount, gasLimit);
        require(success, "TRANSFER_FAILURE");
    }

    function fastCall(
        address to,
        uint    gasLimit,
        uint    value,
        bytes   memory data
        )
        internal
        returns (bool success, bytes memory returnData)
    {

        if (to != address(0)) {
            assembly {
                success := call(gasLimit, to, value, add(data, 32), mload(data), 0, 0)
                let size := returndatasize()
                returnData := mload(0x40)
                mstore(returnData, size)
                returndatacopy(add(returnData, 32), 0, size)
                mstore(0x40, add(returnData, add(32, size)))
            }
        }
    }

    function fastCallAndVerify(
        address to,
        uint    gasLimit,
        uint    value,
        bytes   memory data
        )
        internal
        returns (bytes memory returnData)
    {

        bool success;
        (success, returnData) = fastCall(to, gasLimit, value, data);
        if (!success) {
            assembly {
                revert(add(returnData, 32), mload(returnData))
            }
        }
    }
}







contract Claimable is Ownable
{

    address public pendingOwner;

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner, "UNAUTHORIZED");
        _;
    }

    function transferOwnership(
        address newOwner
        )
        public
        override
        onlyOwner
    {

        require(newOwner != address(0) && newOwner != owner, "INVALID_ADDRESS");
        pendingOwner = newOwner;
    }

    function claimOwnership()
        public
        onlyPendingOwner
    {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}






library ERC20SafeTransfer
{

    function safeTransferAndVerify(
        address token,
        address to,
        uint    value
        )
        internal
    {

        safeTransferWithGasLimitAndVerify(
            token,
            to,
            value,
            gasleft()
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint    value
        )
        internal
        returns (bool)
    {

        return safeTransferWithGasLimit(
            token,
            to,
            value,
            gasleft()
        );
    }

    function safeTransferWithGasLimitAndVerify(
        address token,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
    {

        require(
            safeTransferWithGasLimit(token, to, value, gasLimit),
            "TRANSFER_FAILURE"
        );
    }

    function safeTransferWithGasLimit(
        address token,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
        returns (bool)
    {


        bytes memory callData = abi.encodeWithSelector(
            bytes4(0xa9059cbb),
            to,
            value
        );
        (bool success, ) = token.call{gas: gasLimit}(callData);
        return checkReturnValue(success);
    }

    function safeTransferFromAndVerify(
        address token,
        address from,
        address to,
        uint    value
        )
        internal
    {

        safeTransferFromWithGasLimitAndVerify(
            token,
            from,
            to,
            value,
            gasleft()
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint    value
        )
        internal
        returns (bool)
    {

        return safeTransferFromWithGasLimit(
            token,
            from,
            to,
            value,
            gasleft()
        );
    }

    function safeTransferFromWithGasLimitAndVerify(
        address token,
        address from,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
    {

        bool result = safeTransferFromWithGasLimit(
            token,
            from,
            to,
            value,
            gasLimit
        );
        require(result, "TRANSFER_FAILURE");
    }

    function safeTransferFromWithGasLimit(
        address token,
        address from,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
        returns (bool)
    {


        bytes memory callData = abi.encodeWithSelector(
            bytes4(0x23b872dd),
            from,
            to,
            value
        );
        (bool success, ) = token.call{gas: gasLimit}(callData);
        return checkReturnValue(success);
    }

    function checkReturnValue(
        bool success
        )
        internal
        pure
        returns (bool)
    {

        if (success) {
            assembly {
                switch returndatasize()
                case 0 {
                    success := 1
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
                default {
                    success := 0
                }
            }
        }
        return success;
    }
}






library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value < 2**96, "SafeCast: value doesn\'t fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint40(uint256 value) internal pure returns (uint40) {

        require(value < 2**40, "SafeCast: value doesn\'t fit in 40 bits");
        return uint40(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}




interface IDepositContract
{

    function isTokenSupported(address token)
        external
        view
        returns (bool);


    function deposit(
        address from,
        address token,
        uint96  amount,
        bytes   calldata extraData
        )
        external
        payable
        returns (uint96 amountReceived);


    function withdraw(
        address from,
        address to,
        address token,
        uint    amount,
        bytes   calldata extraData
        )
        external
        payable;


    function transfer(
        address from,
        address to,
        address token,
        uint    amount
        )
        external
        payable;


    function isETH(address addr)
        external
        view
        returns (bool);

}


contract DefaultDepositContract is IDepositContract, Claimable
{

    using AddressUtil       for address;
    using ERC20SafeTransfer for address;
    using MathUint          for uint;
    using SafeCast          for uint;

    address public exchange;

    mapping (address => bool) needCheckBalance;

    modifier onlyExchange()
    {

        require(msg.sender == exchange, "UNAUTHORIZED");
        _;
    }

    modifier ifNotZero(uint amount)
    {

        if (amount == 0) return;
        else  _;
    }

    event CheckBalance(
        address indexed token,
        bool            checkBalance
    );

    function initialize(
        address _exchange
        )
        external
    {

        require(
            exchange == address(0) && _exchange != address(0),
            "INVALID_EXCHANGE"
        );
        owner = msg.sender;
        exchange = _exchange;
    }

    function setCheckBalance(
        address token,
        bool    checkBalance
        )
        external
        onlyOwner
    {

        require(needCheckBalance[token] != checkBalance, "INVALID_VALUE");

        needCheckBalance[token] = checkBalance;
        emit CheckBalance(token, checkBalance);
    }

    function isTokenSupported(address /*token*/)
        external
        override
        pure
        returns (bool)
    {

        return true;
    }

    function deposit(
        address from,
        address token,
        uint96  amount,
        bytes   calldata /*extraData*/
        )
        external
        override
        payable
        onlyExchange
        ifNotZero(amount)
        returns (uint96 amountReceived)
    {

        uint ethToReturn = 0;

        if (isETHInternal(token)) {
            require(msg.value >= amount, "INVALID_ETH_DEPOSIT");
            amountReceived = amount;
            ethToReturn = msg.value - amount;
        } else {
            bool checkBalance = needCheckBalance[token];
            uint balanceBefore = checkBalance ? ERC20(token).balanceOf(address(this)) : 0;

            token.safeTransferFromAndVerify(from, address(this), uint(amount));

            uint balanceAfter = checkBalance ? ERC20(token).balanceOf(address(this)) : amount;
            uint diff = balanceAfter.sub(balanceBefore);
            amountReceived = diff.toUint96();

            ethToReturn = msg.value;
        }

        if (ethToReturn > 0) {
            from.sendETHAndVerify(ethToReturn, gasleft());
        }
    }

    function withdraw(
        address /*from*/,
        address to,
        address token,
        uint    amount,
        bytes   calldata /*extraData*/
        )
        external
        override
        payable
        onlyExchange
        ifNotZero(amount)
    {

        if (isETHInternal(token)) {
            to.sendETHAndVerify(amount, gasleft());
        } else {
            if (!token.safeTransfer(to, amount)){
                uint amountPaid = ERC20(token).balanceOf(address(this));
                require(amountPaid < amount, "UNEXPECTED");
                token.safeTransferAndVerify(to, amountPaid);
            }
        }
    }

    function transfer(
        address from,
        address to,
        address token,
        uint    amount
        )
        external
        override
        payable
        onlyExchange
        ifNotZero(amount)
    {

        token.safeTransferFromAndVerify(from, to, amount);
    }

    function isETH(address addr)
        external
        override
        pure
        returns (bool)
    {

        return isETHInternal(addr);
    }


    function isETHInternal(address addr)
        internal
        pure
        returns (bool)
    {

        return addr == address(0);
    }
}