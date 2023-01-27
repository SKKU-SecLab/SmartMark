


pragma solidity ^0.5.9;
pragma experimental ABIEncoderV2;


library LibRichErrors {


    bytes4 internal constant STANDARD_ERROR_SELECTOR =
        0x08c379a0;

    function StandardError(
        string memory message
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }

    function rrevert(bytes memory errorData)
        internal
        pure
    {

        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}


pragma solidity ^0.5.9;


library LibSafeMathRichErrors {


    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR =
        0xe946c1bb;

    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR =
        0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96
    }

    function Uint256BinOpError(
        BinOpErrorCodes errorCode,
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UINT256_BINOP_ERROR_SELECTOR,
            errorCode,
            a,
            b
        );
    }

    function Uint256DowncastError(
        DowncastErrorCodes errorCode,
        uint256 a
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UINT256_DOWNCAST_ERROR_SELECTOR,
            errorCode,
            a
        );
    }
}


pragma solidity ^0.5.9;


library LibSafeMath {


    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (b == 0) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (b > a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 c = a + b;
        if (c < a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
    }
}




pragma solidity 0.5.16;


contract LibMath  {

    using LibSafeMath for uint256;

    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorFloor(
                numerator,
                denominator,
                target
            ),
            "ROUNDING_ERROR"
        );

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorCeil(
                numerator,
                denominator,
                target
            ),
            "ROUNDING_ERROR"
        );

        partialAmount = numerator.safeMul(target).safeAdd(denominator.safeSub(1)).safeDiv(denominator);
        return partialAmount;
    }

    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = numerator.safeMul(target).safeAdd(denominator.safeSub(1)).safeDiv(denominator);
        return partialAmount;
    }

    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        if (target == 0 || numerator == 0) {
            return false;
        }

        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }

    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        if (target == 0 || numerator == 0) {
            return false;
        }
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = denominator.safeSub(remainder) % denominator;
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }
}




pragma solidity 0.5.16;


contract LibFillResults {

    using LibSafeMath for uint256;

    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    struct MatchedFillResults {
        FillResults left;                    // Amounts filled and fees paid of left order.
        FillResults right;                   // Amounts filled and fees paid of right order.
        uint256 leftMakerAssetSpreadAmount;  // Spread between price of left and right order, denominated in the left order's makerAsset, paid to taker.
    }

    function addFillResults(FillResults memory totalFillResults, FillResults memory singleFillResults)
        internal
        pure
    {

        totalFillResults.makerAssetFilledAmount = totalFillResults.makerAssetFilledAmount.safeAdd(singleFillResults.makerAssetFilledAmount);
        totalFillResults.takerAssetFilledAmount = totalFillResults.takerAssetFilledAmount.safeAdd(singleFillResults.takerAssetFilledAmount);
        totalFillResults.makerFeePaid = totalFillResults.makerFeePaid.safeAdd(singleFillResults.makerFeePaid);
        totalFillResults.takerFeePaid = totalFillResults.takerFeePaid.safeAdd(singleFillResults.takerFeePaid);
    }
}




pragma solidity 0.5.16;


contract LibEIP712 {


    string constant internal EIP191_HEADER = "\x19\x01";

    string constant internal EIP712_DOMAIN_NAME = "0x Protocol";

    string constant internal EIP712_DOMAIN_VERSION = "2";

    bytes32 constant internal EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "address verifyingContract",
        ")"
    ));

    bytes32 public EIP712_DOMAIN_HASH;

    constructor ()
        public
    {
        EIP712_DOMAIN_HASH = keccak256(abi.encodePacked(
            EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
            keccak256(bytes(EIP712_DOMAIN_NAME)),
            keccak256(bytes(EIP712_DOMAIN_VERSION)),
            uint256(address(this))
        ));
    }

    function hashEIP712Message(bytes32 hashStruct)
        internal
        view
        returns (bytes32 result)
    {

        bytes32 eip712DomainHash = EIP712_DOMAIN_HASH;


        assembly {
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)  // EIP191 header
            mstore(add(memPtr, 2), eip712DomainHash)                                            // EIP712 domain hash
            mstore(add(memPtr, 34), hashStruct)                                                 // Hash of struct

            result := keccak256(memPtr, 66)
        }
        return result;
    }
}




pragma solidity 0.5.16;


contract LibOrder is
    LibEIP712
{

    bytes32 constant internal EIP712_ORDER_SCHEMA_HASH = keccak256(abi.encodePacked(
        "Order(",
        "address makerAddress,",
        "address takerAddress,",
        "address feeRecipientAddress,",
        "address senderAddress,",
        "uint256 makerAssetAmount,",
        "uint256 takerAssetAmount,",
        "uint256 makerFee,",
        "uint256 takerFee,",
        "uint256 expirationTimeSeconds,",
        "uint256 salt,",
        "bytes makerAssetData,",
        "bytes takerAssetData",
        ")"
    ));

    enum OrderStatus {
        INVALID,                     // Default value
        INVALID_MAKER_ASSET_AMOUNT,  // Order does not have a valid maker asset amount
        INVALID_TAKER_ASSET_AMOUNT,  // Order does not have a valid taker asset amount
        FILLABLE,                    // Order is fillable
        EXPIRED,                     // Order has already expired
        FULLY_FILLED,                // Order is fully filled
        CANCELLED                    // Order has been cancelled
    }

    struct Order {
        address payable makerAddress;           // Address that created the order.      
        address payable takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.          
        address payable feeRecipientAddress;    // Address that will recieve fees when order is filled.      
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.        
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.        
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.          
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.     
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
    }

    struct OrderInfo {
        uint8 orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 hash of the order (see LibOrder.getOrderHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }

    function getOrderHash(Order memory order)
        internal
        view
        returns (bytes32 orderHash)
    {

        orderHash = hashEIP712Message(hashOrder(order));
        return orderHash;
    }

    function hashOrder(Order memory order)
        internal
        pure
        returns (bytes32 result)
    {

        bytes32 schemaHash = EIP712_ORDER_SCHEMA_HASH;
        bytes32 makerAssetDataHash = keccak256(order.makerAssetData);
        bytes32 takerAssetDataHash = keccak256(order.takerAssetData);


        assembly {
            let pos1 := sub(order, 32)
            let pos2 := add(order, 320)
            let pos3 := add(order, 352)

            let temp1 := mload(pos1)
            let temp2 := mload(pos2)
            let temp3 := mload(pos3)
            
            mstore(pos1, schemaHash)
            mstore(pos2, makerAssetDataHash)
            mstore(pos3, takerAssetDataHash)
            result := keccak256(pos1, 416)
            
            mstore(pos1, temp1)
            mstore(pos2, temp2)
            mstore(pos3, temp3)
        }
        return result;
    }
}




pragma solidity 0.5.16;


contract IExchangeCore {


    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        external;


    function fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);


    function cancelOrder(LibOrder.Order memory order)
        public;


    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo);


    function updateOrder(
        bytes32 newOrderHash,
        uint256 newOfferAmount,
        LibOrder.Order memory orderToBeCanceled
    )
        public
        payable;

}




pragma solidity 0.5.16;


contract MExchangeCore is
    IExchangeCore
{

    event Fill(
        address indexed makerAddress,         // Address that created the order.      
        address indexed feeRecipientAddress,  // Address that received fees.
        address takerAddress,                 // Address that filled the order.
        address senderAddress,                // Address that called the Exchange contract (msg.sender).
        uint256 makerAssetFilledAmount,       // Amount of makerAsset sold by maker and bought by taker. 
        uint256 takerAssetFilledAmount,       // Amount of takerAsset sold by taker and bought by maker.
        uint256 makerFeePaid,                 // Amount of ZRX paid to feeRecipient by maker.
        uint256 takerFeePaid,                 // Amount of ZRX paid to feeRecipient by taker.
        bytes32 indexed orderHash,            // EIP712 hash of order (see LibOrder.getOrderHash).
        bytes makerAssetData,                 // Encoded data specific to makerAsset. 
        bytes takerAssetData                  // Encoded data specific to takerAsset.
    );

    event Cancel(
        address indexed makerAddress,         // Address that created the order.      
        address indexed feeRecipientAddress,  // Address that would have recieved fees if order was filled.   
        address senderAddress,                // Address that called the Exchange contract (msg.sender).
        bytes32 indexed orderHash,            // EIP712 hash of order (see LibOrder.getOrderHash).
        bytes makerAssetData,                 // Encoded data specific to makerAsset. 
        bytes takerAssetData                  // Encoded data specific to takerAsset.
    );

    event CancelUpTo(
        address indexed makerAddress,         // Orders cancelled must have been created by this address.
        address indexed senderAddress,        // Orders cancelled must have a `senderAddress` equal to this address.
        uint256 orderEpoch                    // Orders with specified makerAddress and senderAddress with a salt less than this value are considered cancelled.
    );

    event Transfer(
        address indexed toAddress,
        uint256 indexed amount
    );

    function fillOrderInternal(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        internal
        returns (LibFillResults.FillResults memory fillResults);


    function cancelOrderInternal(LibOrder.Order memory order)
        internal
        returns (LibOrder.OrderInfo memory);


    function updateFilledState(
        LibOrder.Order memory order,
        address takerAddress,
        bytes32 orderHash,
        uint256 orderTakerAssetFilledAmount,
        LibFillResults.FillResults memory fillResults
    )
        internal;


    function updateCancelledState(
        LibOrder.Order memory order,
        bytes32 orderHash
    )
        internal;

    
    function assertFillableOrder(
        LibOrder.Order memory order,
        LibOrder.OrderInfo memory orderInfo,
        address takerAddress,
        bytes memory signature
    )
        internal
        view;

    
    function assertValidFill(
        LibOrder.Order memory order,
        LibOrder.OrderInfo memory orderInfo,
        uint256 takerAssetFillAmount,
        uint256 takerAssetFilledAmount,
        uint256 makerAssetFilledAmount
    )
        internal
        view;


    function assertValidCancel(
        LibOrder.Order memory order,
        LibOrder.OrderInfo memory orderInfo
    )
        internal
        view;


    function calculateFillResults(
        LibOrder.Order memory order,
        uint256 takerAssetFilledAmount
    )
        internal
        pure
        returns (LibFillResults.FillResults memory fillResults);


}



pragma solidity 0.5.16;


contract ISignatureValidator {


    function preSign(
        bytes32 hash,
        address signerAddress,
        bytes calldata signature
    )
        external;

    
    function setSignatureValidatorApproval(
        address validatorAddress,
        bool approval
    )
        external;


    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);

}



pragma solidity 0.5.16;


contract MSignatureValidator is
    ISignatureValidator
{

    event SignatureValidatorApproval(
        address indexed signerAddress,     // Address that approves or disapproves a contract to verify signatures.
        address indexed validatorAddress,  // Address of signature validator contract.
        bool approved                      // Approval or disapproval of validator contract.
    );

    enum SignatureType {
        Illegal,         // 0x00, default value
        Invalid,         // 0x01
        EIP712,          // 0x02
        EthSign,         // 0x03
        Wallet,          // 0x04
        Validator,       // 0x05
        PreSigned,       // 0x06
        NSignatureTypes  // 0x07, number of signature types. Always leave at end.
    }

    function isValidWalletSignature(
        bytes32 hash,
        address walletAddress,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid);


    function isValidValidatorSignature(
        address validatorAddress,
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid);

}


pragma solidity 0.5.16;


contract ITransactions {


    function executeTransaction(
        uint256 salt,
        address payable signerAddress,
        bytes calldata data,
        bytes calldata signature
    )
        external;

}


pragma solidity 0.5.16;


contract MTransactions is
    ITransactions
{

    bytes32 constant internal EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH = keccak256(abi.encodePacked(
        "ZeroExTransaction(",
        "uint256 salt,",
        "address signerAddress,",
        "bytes data",
        ")"
    ));

    function hashZeroExTransaction(
        uint256 salt,
        address signerAddress,
        bytes memory data
    )
        internal
        pure
        returns (bytes32 result);


    function getCurrentContextAddress()
        internal
        view
        returns (address payable);

}



pragma solidity 0.5.16;


contract IAssetProxyDispatcher {


    function registerAssetProxy(address assetProxy)
        external;


    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address);

}



pragma solidity 0.5.16;


contract MAssetProxyDispatcher is
    IAssetProxyDispatcher
{

    event AssetProxyRegistered(
        bytes4 id,              // Id of new registered AssetProxy.
        address assetProxy      // Address of new registered AssetProxy.
    );

    function dispatchTransferFrom(
        bytes memory assetData,
        address from,
        address payable to,
        uint256 amount
    )
        internal;

}



pragma solidity ^0.5.9;


library LibReentrancyGuardRichErrors {


    bytes internal constant ILLEGAL_REENTRANCY_ERROR_SELECTOR_BYTES =
        hex"0c3b823f";

    function IllegalReentrancyError()
        internal
        pure
        returns (bytes memory)
    {

        return ILLEGAL_REENTRANCY_ERROR_SELECTOR_BYTES;
    }
}



pragma solidity ^0.5.9;


contract ReentrancyGuard {


    bool private _locked = false;

    modifier nonReentrant() {

        _lockMutexOrThrowIfAlreadyLocked();
        _;
        _unlockMutex();
    }

    function _lockMutexOrThrowIfAlreadyLocked()
        internal
    {

        if (_locked) {
            LibRichErrors.rrevert(
                LibReentrancyGuardRichErrors.IllegalReentrancyError()
            );
        }
        _locked = true;
    }

    function _unlockMutex()
        internal
    {

        _locked = false;
    }
}



pragma solidity 0.5.16;


contract Operational
{

    address public owner;

    address[] public withdrawOperators; // It is mainly responsible for the withdraw of deposit on cancelling.
    mapping (address => bool) public isWithdrawOperator;

    address[] public depositOperators; // It is mainly responsible for the deposit / transfer on dutch auction buying.
    mapping (address => bool) public isDepositOperator;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event WithdrawOperatorAdded(
        address indexed target,
        address indexed caller
    );

    event WithdrawOperatorRemoved(
        address indexed target,
        address indexed caller
    );

    event DepositOperatorAdded(
        address indexed target,
        address indexed caller
    );

    event DepositOperatorRemoved(
        address indexed target,
        address indexed caller
    );

    constructor ()
        public
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(
            msg.sender == owner,
            "ONLY_CONTRACT_OWNER"
        );
        _;
    }

    modifier onlyDepositOperator() {

        require(
            isDepositOperator[msg.sender],
            "SENDER_IS_NOT_DEPOSIT_OPERATOR"
        );
        _;
    }

    modifier withdrawable(address toAddress) {

        require(
            isWithdrawOperator[msg.sender] || toAddress == msg.sender,
            "SENDER_IS_NOT_WITHDRAWABLE"
        );
        _;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
    {

        require(
            newOwner != address(0),
            "INVALID_OWNER"
        );
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function addWithdrawOperator(address target)
        external
        onlyOwner
    {

        require(
            !isWithdrawOperator[target],
            "TARGET_IS_ALREADY_WITHDRAW_OPERATOR"
        );

        isWithdrawOperator[target] = true;
        withdrawOperators.push(target);
        emit WithdrawOperatorAdded(target, msg.sender);
    }

    function removeWithdrawOperator(address target)
        external
        onlyOwner
    {

        require(
            isWithdrawOperator[target],
            "TARGET_IS_NOT_WITHDRAW_OPERATOR"
        );

        delete isWithdrawOperator[target];
        for (uint256 i = 0; i < withdrawOperators.length; i++) {
            if (withdrawOperators[i] == target) {
                withdrawOperators[i] = withdrawOperators[withdrawOperators.length - 1];
                withdrawOperators.length -= 1;
                break;
            }
        }
        emit WithdrawOperatorRemoved(target, msg.sender);
    }

    function addDepositOperator(address target)
        external
        onlyOwner
    {

        require(
            !isDepositOperator[target],
            "TARGET_IS_ALREADY_DEPOSIT_OPERATOR"
        );

        isDepositOperator[target] = true;
        depositOperators.push(target);
        emit DepositOperatorAdded(target, msg.sender);
    }

    function removeDepositOperator(address target)
        external
        onlyOwner
    {

        require(
            isDepositOperator[target],
            "TARGET_IS_NOT_DEPOSIT_OPERATOR"
        );

        delete isDepositOperator[target];
        for (uint256 i = 0; i < depositOperators.length; i++) {
            if (depositOperators[i] == target) {
                depositOperators[i] = depositOperators[depositOperators.length - 1];
                depositOperators.length -= 1;
                break;
            }
        }
        emit DepositOperatorRemoved(target, msg.sender);
    }
}



pragma solidity 0.5.16;


contract DepositManager is
    Operational,
    ReentrancyGuard
{

    using LibSafeMath for uint256;

    mapping (address => uint256) public depositAmount;
    mapping (bytes32 => mapping (address => uint256)) public orderToDepositAmount;

    event Deposit(
        bytes32 indexed orderHash,
        address indexed senderAddress,
        uint256 amount
    );

    event DepositChanged(
        bytes32 indexed newOrderHash,
        uint256 newAmount,
        bytes32 indexed oldOrderHash,
        uint256 oldAmount,
        address indexed senderAddress
    );

    event Withdraw(
        bytes32 indexed orderHash,
        address indexed toAddress,
        uint256 amount
    );

    function deposit(bytes32 orderHash)
        public
        payable
        nonReentrant
    {

        depositInternal(orderHash, msg.sender, msg.value);
    }

    function withdraw(bytes32 orderHash, address payable toAddress)
        public
        nonReentrant
        withdrawable(toAddress)
    {

        withdrawInternal(orderHash, toAddress);
    }

    function depositByOperator(bytes32 orderHash, address toAddress)
        public
        payable
        nonReentrant
        onlyDepositOperator
    {

        depositInternal(orderHash, toAddress, msg.value);
    }

    function depositInternal(bytes32 orderHash, address sender, uint256 amount)
        internal
    {

        depositAmount[sender] = depositAmount[sender].safeAdd(amount);
        orderToDepositAmount[orderHash][sender] = orderToDepositAmount[orderHash][sender].safeAdd(amount);
        emit Deposit(orderHash, sender, amount);
    }

    function withdrawInternal(bytes32 orderHash, address payable toAddress)
        internal
    {

        if (orderToDepositAmount[orderHash][toAddress] > 0) {
            uint256 amount = orderToDepositAmount[orderHash][toAddress];
            depositAmount[toAddress] = depositAmount[toAddress].safeSub(amount);
            delete orderToDepositAmount[orderHash][toAddress];
            toAddress.transfer(amount);
            emit Withdraw(orderHash, toAddress, amount);
        }
    }

    function changeDeposit(
        bytes32 newOrderHash,
        uint256 newOfferAmount,
        bytes32 oldOrderHash,
        uint256 oldOfferAmount,
        address payable sender
    )
        internal
    {

        if (msg.value > 0) {
            depositAmount[sender] = depositAmount[sender].safeAdd(msg.value);
            orderToDepositAmount[newOrderHash][sender] = orderToDepositAmount[newOrderHash][sender].safeAdd(msg.value);
        }
        uint256 oldOrderToDepositAmount = orderToDepositAmount[oldOrderHash][sender];
        moveDeposit(oldOrderHash, newOrderHash, sender);
        if (oldOrderToDepositAmount > newOfferAmount) {
            uint256 refundAmount = orderToDepositAmount[newOrderHash][sender].safeSub(newOfferAmount);
            orderToDepositAmount[newOrderHash][sender] = orderToDepositAmount[newOrderHash][sender].safeSub(refundAmount);
            depositAmount[sender] = depositAmount[sender].safeSub(refundAmount);
            sender.transfer(refundAmount);
        }
        emit DepositChanged(newOrderHash, newOfferAmount, oldOrderHash, oldOfferAmount, sender);
    }

    function moveDeposit(
        bytes32 fromOrderHash,
        bytes32 toOrderHash,
        address sender
    )
        internal
    {

        uint256 amount = orderToDepositAmount[fromOrderHash][sender];
        delete orderToDepositAmount[fromOrderHash][sender];
        orderToDepositAmount[toOrderHash][sender] = orderToDepositAmount[toOrderHash][sender].safeAdd(amount);
    }

    function deductOrderToDepositAmount(
        bytes32 orderHash,
        address target,
        uint256 amount
    )
        internal
    {

        orderToDepositAmount[orderHash][target] = orderToDepositAmount[orderHash][target].safeSub(amount);
    }
}



pragma solidity 0.5.16;


contract LibConstants {

    bytes constant public ETH_ASSET_DATA = "\xf4\x72\x61\xb0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";
    bytes32 constant public KECCAK256_ETH_ASSET_DATA = keccak256(ETH_ASSET_DATA);
    uint256 constant public TRANSFER_GAS_LIMIT = 300000; // Gas limit for ETH sending
}



pragma solidity 0.5.16;


contract MixinExchangeCore is
    DepositManager,
    LibConstants,
    LibMath,
    LibOrder,
    LibFillResults,
    MAssetProxyDispatcher,
    MExchangeCore,
    MSignatureValidator,
    MTransactions
{

    mapping (bytes32 => uint256) public filled;

    mapping (bytes32 => bool) public cancelled;

    mapping (address => mapping (address => uint256)) public orderEpoch;

    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        external
        nonReentrant
    {

        address makerAddress = getCurrentContextAddress();
        address senderAddress = makerAddress == msg.sender ? address(0) : msg.sender;

        uint256 newOrderEpoch = targetOrderEpoch + 1;
        uint256 oldOrderEpoch = orderEpoch[makerAddress][senderAddress];

        require(
            newOrderEpoch > oldOrderEpoch,
            "INVALID_NEW_ORDER_EPOCH"
        );

        orderEpoch[makerAddress][senderAddress] = newOrderEpoch;
        emit CancelUpTo(
            makerAddress,
            senderAddress,
            newOrderEpoch
        );
    }

    function fillOrder(
        Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        payable
        nonReentrant
        returns (FillResults memory fillResults)
    {

        fillResults = fillOrderInternal(
            order,
            takerAssetFillAmount,
            signature
        );
        return fillResults;
    }

    function cancelOrder(Order memory order)
        public
        nonReentrant
    {

        OrderInfo memory orderInfo = cancelOrderInternal(order);
        withdrawInternal(orderInfo.orderHash, msg.sender);
    }

    function getOrderInfo(Order memory order)
        public
        view
        returns (OrderInfo memory orderInfo)
    {

        orderInfo.orderHash = getOrderHash(order);

        orderInfo.orderTakerAssetFilledAmount = filled[orderInfo.orderHash];

        if (order.makerAssetAmount == 0) {
            orderInfo.orderStatus = uint8(OrderStatus.INVALID_MAKER_ASSET_AMOUNT);
            return orderInfo;
        }

        if (order.takerAssetAmount == 0) {
            orderInfo.orderStatus = uint8(OrderStatus.INVALID_TAKER_ASSET_AMOUNT);
            return orderInfo;
        }

        if (orderInfo.orderTakerAssetFilledAmount >= order.takerAssetAmount) {
            orderInfo.orderStatus = uint8(OrderStatus.FULLY_FILLED);
            return orderInfo;
        }

        if (block.timestamp >= order.expirationTimeSeconds) {
            orderInfo.orderStatus = uint8(OrderStatus.EXPIRED);
            return orderInfo;
        }

        if (cancelled[orderInfo.orderHash]) {
            orderInfo.orderStatus = uint8(OrderStatus.CANCELLED);
            return orderInfo;
        }
        if (orderEpoch[order.makerAddress][order.senderAddress] > order.salt) {
            orderInfo.orderStatus = uint8(OrderStatus.CANCELLED);
            return orderInfo;
        }

        orderInfo.orderStatus = uint8(OrderStatus.FILLABLE);
        return orderInfo;
    }

    function updateOrder(
        bytes32 newOrderHash,
        uint256 newOfferAmount,
        Order memory orderToBeCanceled
    )
        public
        payable
        nonReentrant
    {

        OrderInfo memory orderInfo = cancelOrderInternal(orderToBeCanceled);
        uint256 oldOfferAmount = orderToBeCanceled.makerAssetAmount.safeAdd(orderToBeCanceled.makerFee);
        changeDeposit(newOrderHash, newOfferAmount, orderInfo.orderHash, oldOfferAmount, msg.sender);
    }

    function fillOrderInternal(
        Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        internal
        returns (FillResults memory fillResults)
    {

        OrderInfo memory orderInfo = getOrderInfo(order);

        address payable takerAddress = getCurrentContextAddress();

        if (msg.value > 0) {
            depositInternal(orderInfo.orderHash, takerAddress, msg.value);
        }

        assertFillableOrder(
            order,
            orderInfo,
            takerAddress,
            signature
        );

        uint256 remainingTakerAssetAmount = order.takerAssetAmount.safeSub(orderInfo.orderTakerAssetFilledAmount);
        uint256 takerAssetFilledAmount = LibSafeMath.min256(takerAssetFillAmount, remainingTakerAssetAmount);

        fillResults = calculateFillResults(order, takerAssetFilledAmount);

        assertValidFill(
            order,
            orderInfo,
            takerAssetFillAmount,
            takerAssetFilledAmount,
            fillResults.makerAssetFilledAmount
        );

        updateFilledState(
            order,
            takerAddress,
            orderInfo.orderHash,
            orderInfo.orderTakerAssetFilledAmount,
            fillResults
        );

        settleOrder(
            order,
            takerAddress,
            fillResults
        );

        if (keccak256(order.makerAssetData) == KECCAK256_ETH_ASSET_DATA) {
            deductOrderToDepositAmount(
                orderInfo.orderHash,
                order.makerAddress,
                fillResults.makerAssetFilledAmount.safeAdd(fillResults.makerFeePaid)
            );
        }
        if (keccak256(order.takerAssetData) == KECCAK256_ETH_ASSET_DATA) {
            deductOrderToDepositAmount(
                orderInfo.orderHash,
                takerAddress,
                fillResults.takerAssetFilledAmount.safeAdd(fillResults.takerFeePaid)
            );
        }

        return fillResults;
    }

    function cancelOrderInternal(Order memory order)
        internal
        returns (OrderInfo memory)
    {

        OrderInfo memory orderInfo = getOrderInfo(order);

        assertValidCancel(order, orderInfo);

        updateCancelledState(order, orderInfo.orderHash);

        return orderInfo;
    }

    function updateFilledState(
        Order memory order,
        address takerAddress,
        bytes32 orderHash,
        uint256 orderTakerAssetFilledAmount,
        FillResults memory fillResults
    )
        internal
    {

        filled[orderHash] = orderTakerAssetFilledAmount.safeAdd(fillResults.takerAssetFilledAmount);

        emit Fill(
            order.makerAddress,
            order.feeRecipientAddress,
            takerAddress,
            msg.sender,
            fillResults.makerAssetFilledAmount,
            fillResults.takerAssetFilledAmount,
            fillResults.makerFeePaid,
            fillResults.takerFeePaid,
            orderHash,
            order.makerAssetData,
            order.takerAssetData
        );
    }

    function updateCancelledState(
        Order memory order,
        bytes32 orderHash
    )
        internal
    {

        cancelled[orderHash] = true;

        emit Cancel(
            order.makerAddress,
            order.feeRecipientAddress,
            msg.sender,
            orderHash,
            order.makerAssetData,
            order.takerAssetData
        );
    }

    function assertFillableOrder(
        Order memory order,
        OrderInfo memory orderInfo,
        address takerAddress,
        bytes memory signature
    )
        internal
        view
    {

        require(
            orderInfo.orderStatus == uint8(OrderStatus.FILLABLE),
            "ORDER_UNFILLABLE"
        );

        if (order.senderAddress != address(0)) {
            require(
                order.senderAddress == msg.sender,
                "INVALID_SENDER"
            );
        }

        if (order.takerAddress != address(0)) {
            require(
                order.takerAddress == takerAddress,
                "INVALID_TAKER"
            );
        }

        if (orderInfo.orderTakerAssetFilledAmount == 0) {
            require(
                isValidSignature(
                    orderInfo.orderHash,
                    order.makerAddress,
                    signature
                ),
                "INVALID_ORDER_SIGNATURE"
            );
        }
    }

    function assertValidFill(
        Order memory order,
        OrderInfo memory orderInfo,
        uint256 takerAssetFillAmount,  // TODO: use FillResults
        uint256 takerAssetFilledAmount,
        uint256 makerAssetFilledAmount
    )
        internal
        view
    {

        require(
            takerAssetFillAmount != 0,
            "INVALID_TAKER_AMOUNT"
        );

        require(
            takerAssetFilledAmount <= takerAssetFillAmount,
            "TAKER_OVERPAY"
        );

        require(
            orderInfo.orderTakerAssetFilledAmount.safeAdd(takerAssetFilledAmount) <= order.takerAssetAmount,
            "ORDER_OVERFILL"
        );

        require(
            makerAssetFilledAmount.safeMul(order.takerAssetAmount) <=
            order.makerAssetAmount.safeMul(takerAssetFilledAmount),
            "INVALID_FILL_PRICE"
        );
    }

    function assertValidCancel(
        Order memory order,
        OrderInfo memory orderInfo
    )
        internal
        view
    {

        require(
            orderInfo.orderStatus == uint8(OrderStatus.FILLABLE),
            "ORDER_UNFILLABLE"
        );

        if (order.senderAddress != address(0)) {
            require(
                order.senderAddress == msg.sender,
                "INVALID_SENDER"
            );
        }

        address makerAddress = getCurrentContextAddress();
        require(
            order.makerAddress == makerAddress,
            "INVALID_MAKER"
        );
    }

    function calculateFillResults(
        Order memory order,
        uint256 takerAssetFilledAmount
    )
        internal
        pure
        returns (FillResults memory fillResults)
    {

        fillResults.takerAssetFilledAmount = takerAssetFilledAmount;
        fillResults.makerAssetFilledAmount = safeGetPartialAmountFloor(
            takerAssetFilledAmount,
            order.takerAssetAmount,
            order.makerAssetAmount
        );
        fillResults.makerFeePaid = safeGetPartialAmountFloor(
            fillResults.makerAssetFilledAmount,
            order.makerAssetAmount,
            order.makerFee
        );
        fillResults.takerFeePaid = safeGetPartialAmountFloor(
            takerAssetFilledAmount,
            order.takerAssetAmount,
            order.takerFee
        );

        return fillResults;
    }

    function settleOrder(
        LibOrder.Order memory order,
        address payable takerAddress,
        LibFillResults.FillResults memory fillResults
    )
        private
    {

        bytes memory ethAssetData = ETH_ASSET_DATA;
        dispatchTransferFrom(
            order.makerAssetData,
            order.makerAddress,
            takerAddress,
            fillResults.makerAssetFilledAmount
        );
        dispatchTransferFrom(
            order.takerAssetData,
            takerAddress,
            order.makerAddress,
            fillResults.takerAssetFilledAmount
        );
        dispatchTransferFrom(
            ethAssetData,
            order.makerAddress,
            order.feeRecipientAddress,
            fillResults.makerFeePaid
        );
        dispatchTransferFrom(
            ethAssetData,
            takerAddress,
            order.feeRecipientAddress,
            fillResults.takerFeePaid
        );
    }
}



pragma solidity ^0.5.9;


library LibBytesRichErrors {


    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}



pragma solidity ^0.5.9;


library LibBytes {


    using LibBytes for bytes;

    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {

        if (length < 32) {
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            if (source == dest) {
                return;
            }

            if (source > dest) {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let last := mload(sEnd)

                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let first := mload(source)

                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    mstore(dest, first)
                }
            }
        }
    }

    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        if (b.length == 0) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                b.length,
                0
            ));
        }

        result = b[b.length - 1];

        assembly {
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        index += 20;

        assembly {
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        index += 20;

        assembly {

            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            mstore(add(b, index), xor(input, neighbors))
        }
    }

    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        index += 32;

        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        index += 32;

        assembly {
            mstore(add(b, index), input)
        }
    }

    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                b.length,
                index + 4
            ));
        }

        index += 32;

        assembly {
            result := mload(add(b, index))
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    function writeLength(bytes memory b, uint256 length)
        internal
        pure
    {
        assembly {
            mstore(b, length)
        }
    }
}



pragma solidity 0.5.16;


contract IWallet {


    function isValidSignature(
        bytes32 hash,
        bytes calldata signature
    )
        external
        view
        returns (bytes4);

}



pragma solidity 0.5.16;


contract IValidator {


    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes calldata signature
    )
        external
        view
        returns (bytes4);

}



pragma solidity 0.5.16;


contract MixinSignatureValidator is
    ReentrancyGuard,
    MSignatureValidator,
    MTransactions
{

    using LibBytes for bytes;

    mapping (bytes32 => mapping (address => bool)) public preSigned;

    mapping (address => mapping (address => bool)) public allowedValidators;

    function preSign(
        bytes32 hash,
        address signerAddress,
        bytes calldata signature
    )
        external
    {

        if (signerAddress != msg.sender) {
            require(
                isValidSignature(
                    hash,
                    signerAddress,
                    signature
                ),
                "INVALID_SIGNATURE"
            );
        }
        preSigned[hash][signerAddress] = true;
    }

    function setSignatureValidatorApproval(
        address validatorAddress,
        bool approval
    )
        external
        nonReentrant
    {

        address signerAddress = getCurrentContextAddress();
        allowedValidators[signerAddress][validatorAddress] = approval;
        emit SignatureValidatorApproval(
            signerAddress,
            validatorAddress,
            approval
        );
    }

    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid)
    {

        require(
            signature.length > 0,
            "LENGTH_GREATER_THAN_0_REQUIRED"
        );

        uint8 signatureTypeRaw = uint8(signature.popLastByte());

        require(
            signatureTypeRaw < uint8(SignatureType.NSignatureTypes),
            "SIGNATURE_UNSUPPORTED"
        );

        SignatureType signatureType = SignatureType(signatureTypeRaw);

        uint8 v;
        bytes32 r;
        bytes32 s;
        address recovered;

        if (signatureType == SignatureType.Illegal) {
            revert("SIGNATURE_ILLEGAL");

        } else if (signatureType == SignatureType.Invalid) {
            require(
                signature.length == 0,
                "LENGTH_0_REQUIRED"
            );
            isValid = false;
            return isValid;

        } else if (signatureType == SignatureType.EIP712) {
            require(
                signature.length == 65,
                "LENGTH_65_REQUIRED"
            );
            v = uint8(signature[0]);
            r = signature.readBytes32(1);
            s = signature.readBytes32(33);
            recovered = ecrecover(
                hash,
                v,
                r,
                s
            );
            isValid = signerAddress == recovered;
            return isValid;

        } else if (signatureType == SignatureType.EthSign) {
            require(
                signature.length == 65,
                "LENGTH_65_REQUIRED"
            );
            v = uint8(signature[0]);
            r = signature.readBytes32(1);
            s = signature.readBytes32(33);
            recovered = ecrecover(
                keccak256(abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    hash
                )),
                v,
                r,
                s
            );
            isValid = signerAddress == recovered;
            return isValid;

        } else if (signatureType == SignatureType.Wallet) {
            isValid = isValidWalletSignature(
                hash,
                signerAddress,
                signature
            );
            return isValid;

        } else if (signatureType == SignatureType.Validator) {
            uint256 signatureLength = signature.length;
            address validatorAddress = signature.readAddress(signatureLength - 20);

            if (!allowedValidators[signerAddress][validatorAddress]) {
                return false;
            }
            isValid = isValidValidatorSignature(
                validatorAddress,
                hash,
                signerAddress,
                signature
            );
            return isValid;

        } else if (signatureType == SignatureType.PreSigned) {
            isValid = preSigned[hash][signerAddress];
            return isValid;
        }

        revert("SIGNATURE_UNSUPPORTED");
    }

    function isValidWalletSignature(
        bytes32 hash,
        address walletAddress,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid)
    {

        bytes memory callData = abi.encodeWithSelector(
            IWallet(walletAddress).isValidSignature.selector,
            hash,
            signature
        );
        bytes32 magicValue = bytes32(bytes4(keccak256("isValidWalletSignature(bytes32,address,bytes)")));
        bytes32 magicValueEIP1271 = bytes32(bytes4(keccak256("isValidSignature(bytes,bytes)")));
        bytes32 magicValueEIP1271Old = bytes32(bytes4(keccak256("isValidSignature(bytes32,bytes)")));
        assembly {
            if iszero(extcodesize(walletAddress)) {
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000c57414c4c45545f4552524f5200000000000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }

            let cdStart := add(callData, 32)
            let success := staticcall(
                gas,              // forward all gas
                walletAddress,    // address of Wallet contract
                cdStart,          // pointer to start of input
                mload(callData),  // length of input
                cdStart,          // write output over input
                32                // output size is 32 bytes
            )

            if iszero(eq(returndatasize(), 32)) {
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000c57414c4c45545f4552524f5200000000000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }

            switch success
            case 0 {
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000c57414c4c45545f4552524f5200000000000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }
            case 1 {
                isValid := or(
                    eq(
                        and(mload(cdStart), 0xffffffff00000000000000000000000000000000000000000000000000000000),
                        and(magicValue, 0xffffffff00000000000000000000000000000000000000000000000000000000)
                    ),
                    or(
                        eq(
                            and(mload(cdStart), 0xffffffff00000000000000000000000000000000000000000000000000000000),
                            and(magicValueEIP1271, 0xffffffff00000000000000000000000000000000000000000000000000000000)
                        ),
                        eq(
                            and(mload(cdStart), 0xffffffff00000000000000000000000000000000000000000000000000000000),
                            and(magicValueEIP1271Old, 0xffffffff00000000000000000000000000000000000000000000000000000000)
                        )
                    )
                )
            }
        }
        return isValid;
    }

    function isValidValidatorSignature(
        address validatorAddress,
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid)
    {

        bytes memory callData = abi.encodeWithSelector(
            IValidator(signerAddress).isValidSignature.selector,
            hash,
            signerAddress,
            signature
        );
        bytes32 magicValue = bytes32(bytes4(keccak256("isValidValidatorSignature(address,bytes32,address,bytes)")));
        assembly {
            if iszero(extcodesize(validatorAddress)) {
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000f56414c494441544f525f4552524f5200000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }

            let cdStart := add(callData, 32)
            let success := staticcall(
                gas,               // forward all gas
                validatorAddress,  // address of Validator contract
                cdStart,           // pointer to start of input
                mload(callData),   // length of input
                cdStart,           // write output over input
                32                 // output size is 32 bytes
            )

            if iszero(eq(returndatasize(), 32)) {
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000f56414c494441544f525f4552524f5200000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }

            switch success
            case 0 {
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000f56414c494441544f525f4552524f5200000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }
            case 1 {
                isValid := eq(
                    and(mload(cdStart), 0xffffffff00000000000000000000000000000000000000000000000000000000),
                    and(magicValue, 0xffffffff00000000000000000000000000000000000000000000000000000000)
                )
            }
        }
        return isValid;
    }
}



pragma solidity 0.5.16;


contract MixinWrapperFunctions is
    ReentrancyGuard,
    LibMath,
    MExchangeCore
{

    function batchCancelOrders(LibOrder.Order[] memory orders)
        public
        nonReentrant
    {

        uint256 ordersLength = orders.length;
        for (uint256 i = 0; i != ordersLength; i++) {
            cancelOrderInternal(orders[i]);
        }
    }

    function getOrdersInfo(LibOrder.Order[] memory orders)
        public
        view
        returns (LibOrder.OrderInfo[] memory)
    {

        uint256 ordersLength = orders.length;
        LibOrder.OrderInfo[] memory ordersInfo = new LibOrder.OrderInfo[](ordersLength);
        for (uint256 i = 0; i != ordersLength; i++) {
            ordersInfo[i] = getOrderInfo(orders[i]);
        }
        return ordersInfo;
    }

}



pragma solidity 0.5.16;


contract IAssetProxy {

    function transferFrom(
        bytes calldata assetData,
        address from,
        address to,
        uint256 amount
    )
        external;

    
    function getProxyId()
        external
        pure
        returns (bytes4);

}



pragma solidity 0.5.16;


contract MixinAssetProxyDispatcher is
    DepositManager,
    LibConstants,
    MAssetProxyDispatcher
{

    mapping (bytes4 => address) public assetProxies;

    function registerAssetProxy(address assetProxy)
        external
        onlyOwner
    {

        bytes4 assetProxyId = IAssetProxy(assetProxy).getProxyId();
        address currentAssetProxy = assetProxies[assetProxyId];
        require(
            currentAssetProxy == address(0),
            "ASSET_PROXY_ALREADY_EXISTS"
        );

        assetProxies[assetProxyId] = assetProxy;
        emit AssetProxyRegistered(
            assetProxyId,
            assetProxy
        );
    }

    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address)
    {

        return assetProxies[assetProxyId];
    }

    function dispatchTransferFrom(
        bytes memory assetData,
        address from,
        address payable to,
        uint256 amount
    )
        internal
    {

        if (amount > 0 && from != to) {
            require(
                assetData.length > 3,
                "LENGTH_GREATER_THAN_3_REQUIRED"
            );

            if (keccak256(assetData) == KECCAK256_ETH_ASSET_DATA) {
                require(
                    depositAmount[from] >= amount,
                    "DEPOSIT_AMOUNT_IS_INSUFFICIENT"
                );
                uint256 afterBalance = depositAmount[from].safeSub(amount);
                depositAmount[from] = afterBalance;
                if (to != address(this)) {
                    (bool success, bytes memory _data) = to.call.gas(TRANSFER_GAS_LIMIT).value(amount)("");
                    require(success, "ETH_SENDING_FAILED");
                }
                return;
            }

            bytes4 assetProxyId;
            assembly {
                assetProxyId := and(mload(
                    add(assetData, 32)),
                    0xFFFFFFFF00000000000000000000000000000000000000000000000000000000
                )
            }
            address assetProxy = assetProxies[assetProxyId];

            require(
                assetProxy != address(0),
                "ASSET_PROXY_DOES_NOT_EXIST"
            );
            

            assembly {
                let cdStart := mload(64)
                let dataAreaLength := and(add(mload(assetData), 63), 0xFFFFFFFFFFFE0)
                let cdEnd := add(cdStart, add(132, dataAreaLength))

                
                mstore(cdStart, 0xa85e59e400000000000000000000000000000000000000000000000000000000)
                
                mstore(add(cdStart, 4), 128)
                mstore(add(cdStart, 36), and(from, 0xffffffffffffffffffffffffffffffffffffffff))
                mstore(add(cdStart, 68), and(to, 0xffffffffffffffffffffffffffffffffffffffff))
                mstore(add(cdStart, 100), amount)
                
                let dataArea := add(cdStart, 132)
                for {} lt(dataArea, cdEnd) {} {
                    mstore(dataArea, mload(assetData))
                    dataArea := add(dataArea, 32)
                    assetData := add(assetData, 32)
                }

                let success := call(
                    gas,                    // forward all gas
                    assetProxy,             // call address of asset proxy
                    0,                      // don't send any ETH
                    cdStart,                // pointer to start of input
                    sub(cdEnd, cdStart),    // length of input  
                    cdStart,                // write output over input
                    512                     // reserve 512 bytes for output
                )
                if iszero(success) {
                    revert(cdStart, returndatasize())
                }
            }
        }
    }
}


pragma solidity 0.5.16;


contract MixinTransactions is
    LibEIP712,
    MSignatureValidator,
    MTransactions
{

    mapping (bytes32 => bool) public transactions;

    address payable public currentContextAddress;

    function executeTransaction(
        uint256 salt,
        address payable signerAddress,
        bytes calldata data,
        bytes calldata signature
    )
        external
    {

        require(
            currentContextAddress == address(0),
            "REENTRANCY_ILLEGAL"
        );

        bytes32 transactionHash = hashEIP712Message(hashZeroExTransaction(
            salt,
            signerAddress,
            data
        ));

        require(
            !transactions[transactionHash],
            "INVALID_TX_HASH"
        );

        if (signerAddress != msg.sender) {
            require(
                isValidSignature(
                    transactionHash,
                    signerAddress,
                    signature
                ),
                "INVALID_TX_SIGNATURE"
            );

            currentContextAddress = signerAddress;
        }

        transactions[transactionHash] = true;
        (bool success,) = address(this).delegatecall(data);
        require(
            success,
            "FAILED_EXECUTION"
        );

        if (signerAddress != msg.sender) {
            currentContextAddress = address(0);
        }
    }

    function hashZeroExTransaction(
        uint256 salt,
        address signerAddress,
        bytes memory data
    )
        internal
        pure
        returns (bytes32 result)
    {

        bytes32 schemaHash = EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH;
        bytes32 dataHash = keccak256(data);


        assembly {
            let memPtr := mload(64)

            mstore(memPtr, schemaHash)                                                               // hash of schema
            mstore(add(memPtr, 32), salt)                                                            // salt
            mstore(add(memPtr, 64), and(signerAddress, 0xffffffffffffffffffffffffffffffffffffffff))  // signerAddress
            mstore(add(memPtr, 96), dataHash)                                                        // hash of data

            result := keccak256(memPtr, 128)
        }
        return result;
    }

    function getCurrentContextAddress()
        internal
        view
        returns (address payable)
    {

        address payable currentContextAddress_ = currentContextAddress;
        address payable contextAddress = currentContextAddress_ == address(0) ? msg.sender : currentContextAddress_;
        return contextAddress;
    }
}


pragma solidity 0.5.16;


contract IMatchOrders {


    function matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);

}



pragma solidity 0.5.16;


contract MMatchOrders is
    IMatchOrders
{

    function assertValidMatch(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder
    )
        internal
        pure;


    function calculateMatchedFillResults(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        uint256 leftOrderTakerAssetFilledAmount,
        uint256 rightOrderTakerAssetFilledAmount
    )
        internal
        pure
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);


}



pragma solidity 0.5.16;


contract MixinMatchOrders is
    DepositManager,
    LibConstants,
    LibMath,
    MAssetProxyDispatcher,
    MExchangeCore,
    MMatchOrders,
    MTransactions
{

    function matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        nonReentrant
        returns (LibFillResults.MatchedFillResults memory matchedFillResults)
    {

        rightOrder.makerAssetData = leftOrder.takerAssetData;
        rightOrder.takerAssetData = leftOrder.makerAssetData;

        LibOrder.OrderInfo memory leftOrderInfo = getOrderInfo(leftOrder);
        LibOrder.OrderInfo memory rightOrderInfo = getOrderInfo(rightOrder);

        address payable takerAddress = getCurrentContextAddress();
        
        assertFillableOrder(
            leftOrder,
            leftOrderInfo,
            takerAddress,
            leftSignature
        );
        assertFillableOrder(
            rightOrder,
            rightOrderInfo,
            takerAddress,
            rightSignature
        );
        assertValidMatch(leftOrder, rightOrder);

        matchedFillResults = calculateMatchedFillResults(
            leftOrder,
            rightOrder,
            leftOrderInfo.orderTakerAssetFilledAmount,
            rightOrderInfo.orderTakerAssetFilledAmount
        );

        assertValidFill(
            leftOrder,
            leftOrderInfo,
            matchedFillResults.left.takerAssetFilledAmount,
            matchedFillResults.left.takerAssetFilledAmount,
            matchedFillResults.left.makerAssetFilledAmount
        );
        assertValidFill(
            rightOrder,
            rightOrderInfo,
            matchedFillResults.right.takerAssetFilledAmount,
            matchedFillResults.right.takerAssetFilledAmount,
            matchedFillResults.right.makerAssetFilledAmount
        );
        
        updateFilledState(
            leftOrder,
            takerAddress,
            leftOrderInfo.orderHash,
            leftOrderInfo.orderTakerAssetFilledAmount,
            matchedFillResults.left
        );
        updateFilledState(
            rightOrder,
            takerAddress,
            rightOrderInfo.orderHash,
            rightOrderInfo.orderTakerAssetFilledAmount,
            matchedFillResults.right
        );

        settleMatchedOrders(
            leftOrder,
            rightOrder,
            takerAddress,
            matchedFillResults
        );

        if (keccak256(leftOrder.makerAssetData) == KECCAK256_ETH_ASSET_DATA) {
            deductOrderToDepositAmount(
                leftOrderInfo.orderHash,
                leftOrder.makerAddress,
                matchedFillResults.right.takerAssetFilledAmount.safeAdd(matchedFillResults.leftMakerAssetSpreadAmount).safeAdd(matchedFillResults.left.makerFeePaid)
            );
        }
        if (keccak256(rightOrder.makerAssetData) == KECCAK256_ETH_ASSET_DATA) {
            deductOrderToDepositAmount(
                rightOrderInfo.orderHash,
                rightOrder.makerAddress,
                matchedFillResults.left.takerAssetFilledAmount.safeAdd(matchedFillResults.right.makerFeePaid)
            );
        }
        if (keccak256(leftOrder.takerAssetData) == KECCAK256_ETH_ASSET_DATA) {
            deductOrderToDepositAmount(
                leftOrderInfo.orderHash,
                takerAddress,
                matchedFillResults.left.takerFeePaid
            );
        }
        if (keccak256(rightOrder.takerAssetData) == KECCAK256_ETH_ASSET_DATA) {
            deductOrderToDepositAmount(
                rightOrderInfo.orderHash,
                takerAddress,
                matchedFillResults.right.takerFeePaid
            );
        }

        return matchedFillResults;
    }

    function assertValidMatch(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder
    )
        internal
        pure
    {

        require(
            leftOrder.makerAssetAmount.safeMul(rightOrder.makerAssetAmount) >=
            leftOrder.takerAssetAmount.safeMul(rightOrder.takerAssetAmount),
            "NEGATIVE_SPREAD_REQUIRED"
        );
    }

    function calculateMatchedFillResults(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        uint256 leftOrderTakerAssetFilledAmount,
        uint256 rightOrderTakerAssetFilledAmount
    )
        internal
        pure
        returns (LibFillResults.MatchedFillResults memory matchedFillResults)
    {

        uint256 leftTakerAssetAmountRemaining = leftOrder.takerAssetAmount.safeSub(leftOrderTakerAssetFilledAmount);
        uint256 leftMakerAssetAmountRemaining = safeGetPartialAmountFloor(
            leftOrder.makerAssetAmount,
            leftOrder.takerAssetAmount,
            leftTakerAssetAmountRemaining
        );
        uint256 rightTakerAssetAmountRemaining = rightOrder.takerAssetAmount.safeSub(rightOrderTakerAssetFilledAmount);
        uint256 rightMakerAssetAmountRemaining = safeGetPartialAmountFloor(
            rightOrder.makerAssetAmount,
            rightOrder.takerAssetAmount,
            rightTakerAssetAmountRemaining
        );

        if (leftTakerAssetAmountRemaining >= rightMakerAssetAmountRemaining) {
            matchedFillResults.right.makerAssetFilledAmount = rightMakerAssetAmountRemaining;
            matchedFillResults.right.takerAssetFilledAmount = rightTakerAssetAmountRemaining;
            matchedFillResults.left.takerAssetFilledAmount = matchedFillResults.right.makerAssetFilledAmount;
            matchedFillResults.left.makerAssetFilledAmount = safeGetPartialAmountFloor(
                leftOrder.makerAssetAmount,
                leftOrder.takerAssetAmount,
                matchedFillResults.left.takerAssetFilledAmount
            );
        } else {
            matchedFillResults.left.makerAssetFilledAmount = leftMakerAssetAmountRemaining;
            matchedFillResults.left.takerAssetFilledAmount = leftTakerAssetAmountRemaining;
            matchedFillResults.right.makerAssetFilledAmount = matchedFillResults.left.takerAssetFilledAmount;
            matchedFillResults.right.takerAssetFilledAmount = safeGetPartialAmountCeil(
                rightOrder.takerAssetAmount,
                rightOrder.makerAssetAmount,
                matchedFillResults.right.makerAssetFilledAmount
            );
        }

        matchedFillResults.leftMakerAssetSpreadAmount = matchedFillResults.left.makerAssetFilledAmount.safeSub(
            matchedFillResults.right.takerAssetFilledAmount
        );

        matchedFillResults.left.makerFeePaid = safeGetPartialAmountFloor(
            matchedFillResults.left.makerAssetFilledAmount,
            leftOrder.makerAssetAmount,
            leftOrder.makerFee
        );
        matchedFillResults.left.takerFeePaid = safeGetPartialAmountFloor(
            matchedFillResults.left.takerAssetFilledAmount,
            leftOrder.takerAssetAmount,
            leftOrder.takerFee
        );

        matchedFillResults.right.makerFeePaid = safeGetPartialAmountFloor(
            matchedFillResults.right.makerAssetFilledAmount,
            rightOrder.makerAssetAmount,
            rightOrder.makerFee
        );
        matchedFillResults.right.takerFeePaid = safeGetPartialAmountFloor(
            matchedFillResults.right.takerAssetFilledAmount,
            rightOrder.takerAssetAmount,
            rightOrder.takerFee
        );

        return matchedFillResults;
    }

    function settleMatchedOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        address payable takerAddress,
        LibFillResults.MatchedFillResults memory matchedFillResults
    )
        private
    {

        bytes memory ethAssetData = ETH_ASSET_DATA;

        dispatchTransferFrom(
            leftOrder.makerAssetData,
            leftOrder.makerAddress,
            rightOrder.makerAddress,
            matchedFillResults.right.takerAssetFilledAmount
        );
        dispatchTransferFrom(
            rightOrder.makerAssetData,
            rightOrder.makerAddress,
            leftOrder.makerAddress,
            matchedFillResults.left.takerAssetFilledAmount
        );
        dispatchTransferFrom(
            leftOrder.makerAssetData,
            leftOrder.makerAddress,
            takerAddress,
            matchedFillResults.leftMakerAssetSpreadAmount
        );

        dispatchTransferFrom(
            ethAssetData,
            leftOrder.makerAddress,
            leftOrder.feeRecipientAddress,
            matchedFillResults.left.makerFeePaid
        );
        dispatchTransferFrom(
            ethAssetData,
            rightOrder.makerAddress,
            rightOrder.feeRecipientAddress,
            matchedFillResults.right.makerFeePaid
        );

        if (leftOrder.feeRecipientAddress == rightOrder.feeRecipientAddress) {
            dispatchTransferFrom(
                ethAssetData,
                takerAddress,
                leftOrder.feeRecipientAddress,
                matchedFillResults.left.takerFeePaid.safeAdd(
                    matchedFillResults.right.takerFeePaid
                )
            );
        } else {
            dispatchTransferFrom(
                ethAssetData,
                takerAddress,
                leftOrder.feeRecipientAddress,
                matchedFillResults.left.takerFeePaid
            );
            dispatchTransferFrom(
                ethAssetData,
                takerAddress,
                rightOrder.feeRecipientAddress,
                matchedFillResults.right.takerFeePaid
            );
        }
    }
}



pragma solidity 0.5.16;


contract Exchange is
    MixinExchangeCore,
    MixinMatchOrders,
    MixinSignatureValidator,
    MixinTransactions,
    MixinWrapperFunctions,
    MixinAssetProxyDispatcher
{

    string constant public VERSION = "2.1.0-alpha-miime";

    constructor ()
        public
        MixinExchangeCore()
        MixinMatchOrders()
        MixinSignatureValidator()
        MixinTransactions()
        MixinAssetProxyDispatcher()
        MixinWrapperFunctions()
    {}
}