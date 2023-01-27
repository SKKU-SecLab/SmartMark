pragma solidity >=0.8.0;

abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );


    string public name;

    string public symbol;

    uint8 public immutable decimals;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;


    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }


    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= amount;
        }

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);
            require(
                recoveredAddress != address(0) && recoveredAddress == owner,
                "INVALID_PERMIT_SIGNATURE"
            );

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID
                ? INITIAL_DOMAIN_SEPARATOR
                : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256(bytes("1")),
                    block.chainid,
                    address(this)
                )
            );
    }


    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;


library SafeTransferLib {


    function safeTransferETH(address to, uint256 amount) internal {

        bool callStatus;

        assembly {
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(from, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "from" argument.
            mstore(
                add(freeMemoryPointer, 36),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(
            didLastOptionalReturnCallSucceed(callStatus),
            "TRANSFER_FROM_FAILED"
        );
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(
            didLastOptionalReturnCallSucceed(callStatus),
            "TRANSFER_FAILED"
        );
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }


    function didLastOptionalReturnCallSucceed(bool callStatus)
        private
        pure
        returns (bool success)
    {

        assembly {
            let returnDataSize := returndatasize()

            if iszero(callStatus) {
                returndatacopy(0, 0, returnDataSize)

                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                returndatacopy(0, 0, returnDataSize)

                success := iszero(iszero(mload(0)))
            }
            case 0 {
                success := 1
            }
            default {
                success := 0
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// AGPL-3.0

pragma solidity ^0.8.4;

interface IOwnershipTransferCallback {

    function onOwnershipTransfer(address oldOwner) external;

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// AGPL-3.0

pragma solidity ^0.8.4;


abstract contract OwnableWithTransferCallback {
    using Address for address;

    bytes4 constant TRANSFER_CALLBACK =
        type(IOwnershipTransferCallback).interfaceId;

    error Ownable_NotOwner();
    error Ownable_NewOwnerZeroAddress();

    address private _owner;

    event OwnershipTransferred(address indexed newOwner);

    function __Ownable_init(address initialOwner) internal {
        _owner = initialOwner;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        if (owner() != msg.sender) revert Ownable_NotOwner();
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) revert Ownable_NewOwnerZeroAddress();
        _transferOwnership(newOwner);

        if (newOwner.isContract()) {
            try
                IOwnershipTransferCallback(newOwner).onOwnershipTransfer(
                    msg.sender
                )
            {} catch (bytes memory) {}
        }
    }

    function _transferOwnership(address newOwner) internal virtual {
        _owner = newOwner;
        emit OwnershipTransferred(newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// AGPL-3.0
pragma solidity ^0.8.0;

contract CurveErrorCodes {

    enum Error {
        OK, // No error
        INVALID_NUMITEMS, // The numItem value is 0
        SPOT_PRICE_OVERFLOW // The updated spot price doesn't fit into 128 bits
    }
}// AGPL-3.0
pragma solidity ^0.8.0;


interface ICurve {

    function validateDelta(uint128 delta) external pure returns (bool valid);


    function validateSpotPrice(uint128 newSpotPrice)
        external
        view
        returns (bool valid);


    function getBuyInfo(
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier
    )
        external
        view
        returns (
            CurveErrorCodes.Error error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 inputValue,
            uint256 protocolFee
        );


    function getSellInfo(
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier
    )
        external
        view
        returns (
            CurveErrorCodes.Error error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 outputValue,
            uint256 protocolFee
        );

}// AGPL-3.0
pragma solidity ^0.8.0;


interface ILSSVMPairFactoryLike {

    enum PairVariant {
        ENUMERABLE_ETH,
        MISSING_ENUMERABLE_ETH,
        ENUMERABLE_ERC20,
        MISSING_ENUMERABLE_ERC20
    }

    function protocolFeeMultiplier() external view returns (uint256);


    function protocolFeeRecipient() external view returns (address payable);


    function callAllowed(address target) external view returns (bool);


    function routerStatus(LSSVMRouter router)
        external
        view
        returns (bool allowed, bool wasEverAllowed);


    function isPair(address potentialPair, PairVariant variant)
        external
        view
        returns (bool);

}// AGPL-3.0
pragma solidity ^0.8.0;


contract LSSVMRouter {

    using SafeTransferLib for address payable;
    using SafeTransferLib for ERC20;

    struct PairSwapAny {
        LSSVMPair pair;
        uint256 numItems;
    }

    struct PairSwapSpecific {
        LSSVMPair pair;
        uint256[] nftIds;
    }

    struct RobustPairSwapAny {
        PairSwapAny swapInfo;
        uint256 maxCost;
    }

    struct RobustPairSwapSpecific {
        PairSwapSpecific swapInfo;
        uint256 maxCost;
    }

    struct RobustPairSwapSpecificForToken {
        PairSwapSpecific swapInfo;
        uint256 minOutput;
    }

    struct NFTsForAnyNFTsTrade {
        PairSwapSpecific[] nftToTokenTrades;
        PairSwapAny[] tokenToNFTTrades;
    }

    struct NFTsForSpecificNFTsTrade {
        PairSwapSpecific[] nftToTokenTrades;
        PairSwapSpecific[] tokenToNFTTrades;
    }

    struct RobustPairNFTsFoTokenAndTokenforNFTsTrade {
        RobustPairSwapSpecific[] tokenToNFTTrades;
        RobustPairSwapSpecificForToken[] nftToTokenTrades;
        uint256 inputAmount;
        address payable tokenRecipient;
        address nftRecipient;
    }

    modifier checkDeadline(uint256 deadline) {

        _checkDeadline(deadline);
        _;
    }

    ILSSVMPairFactoryLike public immutable factory;

    constructor(ILSSVMPairFactoryLike _factory) {
        factory = _factory;
    }


    function swapETHForAnyNFTs(
        PairSwapAny[] calldata swapList,
        address payable ethRecipient,
        address nftRecipient,
        uint256 deadline
    )
        external
        payable
        checkDeadline(deadline)
        returns (uint256 remainingValue)
    {

        return
            _swapETHForAnyNFTs(swapList, msg.value, ethRecipient, nftRecipient);
    }

    function swapETHForSpecificNFTs(
        PairSwapSpecific[] calldata swapList,
        address payable ethRecipient,
        address nftRecipient,
        uint256 deadline
    )
        external
        payable
        checkDeadline(deadline)
        returns (uint256 remainingValue)
    {

        return
            _swapETHForSpecificNFTs(
                swapList,
                msg.value,
                ethRecipient,
                nftRecipient
            );
    }

    function swapNFTsForAnyNFTsThroughETH(
        NFTsForAnyNFTsTrade calldata trade,
        uint256 minOutput,
        address payable ethRecipient,
        address nftRecipient,
        uint256 deadline
    ) external payable checkDeadline(deadline) returns (uint256 outputAmount) {

        outputAmount = _swapNFTsForToken(
            trade.nftToTokenTrades,
            0,
            payable(address(this))
        );

        outputAmount += msg.value;

        outputAmount =
            _swapETHForAnyNFTs(
                trade.tokenToNFTTrades,
                outputAmount - minOutput,
                ethRecipient,
                nftRecipient
            ) +
            minOutput;
    }

    function swapNFTsForSpecificNFTsThroughETH(
        NFTsForSpecificNFTsTrade calldata trade,
        uint256 minOutput,
        address payable ethRecipient,
        address nftRecipient,
        uint256 deadline
    ) external payable checkDeadline(deadline) returns (uint256 outputAmount) {

        outputAmount = _swapNFTsForToken(
            trade.nftToTokenTrades,
            0,
            payable(address(this))
        );

        outputAmount += msg.value;

        outputAmount =
            _swapETHForSpecificNFTs(
                trade.tokenToNFTTrades,
                outputAmount - minOutput,
                ethRecipient,
                nftRecipient
            ) +
            minOutput;
    }


    function swapERC20ForAnyNFTs(
        PairSwapAny[] calldata swapList,
        uint256 inputAmount,
        address nftRecipient,
        uint256 deadline
    ) external checkDeadline(deadline) returns (uint256 remainingValue) {

        return _swapERC20ForAnyNFTs(swapList, inputAmount, nftRecipient);
    }

    function swapERC20ForSpecificNFTs(
        PairSwapSpecific[] calldata swapList,
        uint256 inputAmount,
        address nftRecipient,
        uint256 deadline
    ) external checkDeadline(deadline) returns (uint256 remainingValue) {

        return _swapERC20ForSpecificNFTs(swapList, inputAmount, nftRecipient);
    }

    function swapNFTsForToken(
        PairSwapSpecific[] calldata swapList,
        uint256 minOutput,
        address tokenRecipient,
        uint256 deadline
    ) external checkDeadline(deadline) returns (uint256 outputAmount) {

        return _swapNFTsForToken(swapList, minOutput, payable(tokenRecipient));
    }

    function swapNFTsForAnyNFTsThroughERC20(
        NFTsForAnyNFTsTrade calldata trade,
        uint256 inputAmount,
        uint256 minOutput,
        address nftRecipient,
        uint256 deadline
    ) external checkDeadline(deadline) returns (uint256 outputAmount) {

        outputAmount = _swapNFTsForToken(
            trade.nftToTokenTrades,
            0,
            payable(msg.sender)
        );

        outputAmount += inputAmount;

        outputAmount =
            _swapERC20ForAnyNFTs(
                trade.tokenToNFTTrades,
                outputAmount - minOutput,
                nftRecipient
            ) +
            minOutput;
    }

    function swapNFTsForSpecificNFTsThroughERC20(
        NFTsForSpecificNFTsTrade calldata trade,
        uint256 inputAmount,
        uint256 minOutput,
        address nftRecipient,
        uint256 deadline
    ) external checkDeadline(deadline) returns (uint256 outputAmount) {

        outputAmount = _swapNFTsForToken(
            trade.nftToTokenTrades,
            0,
            payable(msg.sender)
        );

        outputAmount += inputAmount;

        outputAmount =
            _swapERC20ForSpecificNFTs(
                trade.tokenToNFTTrades,
                outputAmount - minOutput,
                nftRecipient
            ) +
            minOutput;
    }


    function robustSwapETHForAnyNFTs(
        RobustPairSwapAny[] calldata swapList,
        address payable ethRecipient,
        address nftRecipient,
        uint256 deadline
    )
        external
        payable
        checkDeadline(deadline)
        returns (uint256 remainingValue)
    {

        remainingValue = msg.value;

        uint256 pairCost;
        CurveErrorCodes.Error error;
        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps; ) {
            (error, , , pairCost, ) = swapList[i].swapInfo.pair.getBuyNFTQuote(
                swapList[i].swapInfo.numItems
            );

            if (
                pairCost <= swapList[i].maxCost &&
                error == CurveErrorCodes.Error.OK
            ) {
                remainingValue -= swapList[i].swapInfo.pair.swapTokenForAnyNFTs{
                    value: pairCost
                }(
                    swapList[i].swapInfo.numItems,
                    pairCost,
                    nftRecipient,
                    true,
                    msg.sender
                );
            }

            unchecked {
                ++i;
            }
        }

        if (remainingValue > 0) {
            ethRecipient.safeTransferETH(remainingValue);
        }
    }

    function robustSwapETHForSpecificNFTs(
        RobustPairSwapSpecific[] calldata swapList,
        address payable ethRecipient,
        address nftRecipient,
        uint256 deadline
    )
        external
        payable
        checkDeadline(deadline)
        returns (uint256 remainingValue)
    {

        remainingValue = msg.value;
        uint256 pairCost;
        CurveErrorCodes.Error error;

        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps; ) {
            (error, , , pairCost, ) = swapList[i].swapInfo.pair.getBuyNFTQuote(
                swapList[i].swapInfo.nftIds.length
            );

            if (
                pairCost <= swapList[i].maxCost &&
                error == CurveErrorCodes.Error.OK
            ) {
                remainingValue -= swapList[i]
                    .swapInfo
                    .pair
                    .swapTokenForSpecificNFTs{value: pairCost}(
                    swapList[i].swapInfo.nftIds,
                    pairCost,
                    nftRecipient,
                    true,
                    msg.sender
                );
            }

            unchecked {
                ++i;
            }
        }

        if (remainingValue > 0) {
            ethRecipient.safeTransferETH(remainingValue);
        }
    }

    function robustSwapERC20ForAnyNFTs(
        RobustPairSwapAny[] calldata swapList,
        uint256 inputAmount,
        address nftRecipient,
        uint256 deadline
    ) external checkDeadline(deadline) returns (uint256 remainingValue) {

        remainingValue = inputAmount;
        uint256 pairCost;
        CurveErrorCodes.Error error;

        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps; ) {
            (error, , , pairCost, ) = swapList[i].swapInfo.pair.getBuyNFTQuote(
                swapList[i].swapInfo.numItems
            );

            if (
                pairCost <= swapList[i].maxCost &&
                error == CurveErrorCodes.Error.OK
            ) {
                remainingValue -= swapList[i].swapInfo.pair.swapTokenForAnyNFTs(
                        swapList[i].swapInfo.numItems,
                        pairCost,
                        nftRecipient,
                        true,
                        msg.sender
                    );
            }

            unchecked {
                ++i;
            }
        }
    }

    function robustSwapERC20ForSpecificNFTs(
        RobustPairSwapSpecific[] calldata swapList,
        uint256 inputAmount,
        address nftRecipient,
        uint256 deadline
    )
        external
        payable
        checkDeadline(deadline)
        returns (uint256 remainingValue)
    {

        remainingValue = inputAmount;
        uint256 pairCost;
        CurveErrorCodes.Error error;

        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps; ) {
            (error, , , pairCost, ) = swapList[i].swapInfo.pair.getBuyNFTQuote(
                swapList[i].swapInfo.nftIds.length
            );

            if (
                pairCost <= swapList[i].maxCost &&
                error == CurveErrorCodes.Error.OK
            ) {
                remainingValue -= swapList[i]
                    .swapInfo
                    .pair
                    .swapTokenForSpecificNFTs(
                        swapList[i].swapInfo.nftIds,
                        pairCost,
                        nftRecipient,
                        true,
                        msg.sender
                    );
            }

            unchecked {
                ++i;
            }
        }
    }

    function robustSwapNFTsForToken(
        RobustPairSwapSpecificForToken[] calldata swapList,
        address payable tokenRecipient,
        uint256 deadline
    ) external checkDeadline(deadline) returns (uint256 outputAmount) {

        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps; ) {
            uint256 pairOutput;

            {
                CurveErrorCodes.Error error;
                (error, , , pairOutput, ) = swapList[i]
                    .swapInfo
                    .pair
                    .getSellNFTQuote(swapList[i].swapInfo.nftIds.length);
                if (error != CurveErrorCodes.Error.OK) {
                    unchecked {
                        ++i;
                    }
                    continue;
                }
            }

            if (pairOutput >= swapList[i].minOutput) {
                outputAmount += swapList[i].swapInfo.pair.swapNFTsForToken(
                    swapList[i].swapInfo.nftIds,
                    0,
                    tokenRecipient,
                    true,
                    msg.sender
                );
            }

            unchecked {
                ++i;
            }
        }
    }

    function robustSwapETHForSpecificNFTsAndNFTsToToken(
        RobustPairNFTsFoTokenAndTokenforNFTsTrade calldata params
    ) external payable returns (uint256 remainingValue, uint256 outputAmount) {

        {
            remainingValue = msg.value;
            uint256 pairCost;
            CurveErrorCodes.Error error;

            uint256 numSwaps = params.tokenToNFTTrades.length;
            for (uint256 i; i < numSwaps; ) {
                (error, , , pairCost, ) = params
                    .tokenToNFTTrades[i]
                    .swapInfo
                    .pair
                    .getBuyNFTQuote(
                        params.tokenToNFTTrades[i].swapInfo.nftIds.length
                    );

                if (
                    pairCost <= params.tokenToNFTTrades[i].maxCost &&
                    error == CurveErrorCodes.Error.OK
                ) {
                    remainingValue -= params
                        .tokenToNFTTrades[i]
                        .swapInfo
                        .pair
                        .swapTokenForSpecificNFTs{value: pairCost}(
                        params.tokenToNFTTrades[i].swapInfo.nftIds,
                        pairCost,
                        params.nftRecipient,
                        true,
                        msg.sender
                    );
                }

                unchecked {
                    ++i;
                }
            }

            if (remainingValue > 0) {
                params.tokenRecipient.safeTransferETH(remainingValue);
            }
        }
        {
            uint256 numSwaps = params.nftToTokenTrades.length;
            for (uint256 i; i < numSwaps; ) {
                uint256 pairOutput;

                {
                    CurveErrorCodes.Error error;
                    (error, , , pairOutput, ) = params
                        .nftToTokenTrades[i]
                        .swapInfo
                        .pair
                        .getSellNFTQuote(
                            params.nftToTokenTrades[i].swapInfo.nftIds.length
                        );
                    if (error != CurveErrorCodes.Error.OK) {
                        unchecked {
                            ++i;
                        }
                        continue;
                    }
                }

                if (pairOutput >= params.nftToTokenTrades[i].minOutput) {
                    outputAmount += params
                        .nftToTokenTrades[i]
                        .swapInfo
                        .pair
                        .swapNFTsForToken(
                            params.nftToTokenTrades[i].swapInfo.nftIds,
                            0,
                            params.tokenRecipient,
                            true,
                            msg.sender
                        );
                }

                unchecked {
                    ++i;
                }
            }
        }
    }

    function robustSwapERC20ForSpecificNFTsAndNFTsToToken(
        RobustPairNFTsFoTokenAndTokenforNFTsTrade calldata params
    ) external payable returns (uint256 remainingValue, uint256 outputAmount) {

        {
            remainingValue = params.inputAmount;
            uint256 pairCost;
            CurveErrorCodes.Error error;

            uint256 numSwaps = params.tokenToNFTTrades.length;
            for (uint256 i; i < numSwaps; ) {
                (error, , , pairCost, ) = params
                    .tokenToNFTTrades[i]
                    .swapInfo
                    .pair
                    .getBuyNFTQuote(
                        params.tokenToNFTTrades[i].swapInfo.nftIds.length
                    );

                if (
                    pairCost <= params.tokenToNFTTrades[i].maxCost &&
                    error == CurveErrorCodes.Error.OK
                ) {
                    remainingValue -= params
                        .tokenToNFTTrades[i]
                        .swapInfo
                        .pair
                        .swapTokenForSpecificNFTs(
                            params.tokenToNFTTrades[i].swapInfo.nftIds,
                            pairCost,
                            params.nftRecipient,
                            true,
                            msg.sender
                        );
                }

                unchecked {
                    ++i;
                }
            }
        }
        {
            uint256 numSwaps = params.nftToTokenTrades.length;
            for (uint256 i; i < numSwaps; ) {
                uint256 pairOutput;

                {
                    CurveErrorCodes.Error error;
                    (error, , , pairOutput, ) = params
                        .nftToTokenTrades[i]
                        .swapInfo
                        .pair
                        .getSellNFTQuote(
                            params.nftToTokenTrades[i].swapInfo.nftIds.length
                        );
                    if (error != CurveErrorCodes.Error.OK) {
                        unchecked {
                            ++i;
                        }
                        continue;
                    }
                }

                if (pairOutput >= params.nftToTokenTrades[i].minOutput) {
                    outputAmount += params
                        .nftToTokenTrades[i]
                        .swapInfo
                        .pair
                        .swapNFTsForToken(
                            params.nftToTokenTrades[i].swapInfo.nftIds,
                            0,
                            params.tokenRecipient,
                            true,
                            msg.sender
                        );
                }

                unchecked {
                    ++i;
                }
            }
        }
    }

    receive() external payable {}


    function pairTransferERC20From(
        ERC20 token,
        address from,
        address to,
        uint256 amount,
        ILSSVMPairFactoryLike.PairVariant variant
    ) external {

        require(factory.isPair(msg.sender, variant), "Not pair");

        require(
            variant == ILSSVMPairFactoryLike.PairVariant.ENUMERABLE_ERC20 ||
                variant ==
                ILSSVMPairFactoryLike.PairVariant.MISSING_ENUMERABLE_ERC20,
            "Not ERC20 pair"
        );

        token.safeTransferFrom(from, to, amount);
    }

    function pairTransferNFTFrom(
        IERC721 nft,
        address from,
        address to,
        uint256 id,
        ILSSVMPairFactoryLike.PairVariant variant
    ) external {

        require(factory.isPair(msg.sender, variant), "Not pair");

        nft.safeTransferFrom(from, to, id);
    }


    function _checkDeadline(uint256 deadline) internal view {

        require(block.timestamp <= deadline, "Deadline passed");
    }

    function _swapETHForAnyNFTs(
        PairSwapAny[] calldata swapList,
        uint256 inputAmount,
        address payable ethRecipient,
        address nftRecipient
    ) internal returns (uint256 remainingValue) {

        remainingValue = inputAmount;

        uint256 pairCost;
        CurveErrorCodes.Error error;

        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps; ) {
            (error, , , pairCost, ) = swapList[i].pair.getBuyNFTQuote(
                swapList[i].numItems
            );

            require(error == CurveErrorCodes.Error.OK, "Bonding curve error");

            remainingValue -= swapList[i].pair.swapTokenForAnyNFTs{
                value: pairCost
            }(
                swapList[i].numItems,
                remainingValue,
                nftRecipient,
                true,
                msg.sender
            );

            unchecked {
                ++i;
            }
        }

        if (remainingValue > 0) {
            ethRecipient.safeTransferETH(remainingValue);
        }
    }

    function _swapETHForSpecificNFTs(
        PairSwapSpecific[] calldata swapList,
        uint256 inputAmount,
        address payable ethRecipient,
        address nftRecipient
    ) internal returns (uint256 remainingValue) {

        remainingValue = inputAmount;

        uint256 pairCost;
        CurveErrorCodes.Error error;

        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps; ) {
            (error, , , pairCost, ) = swapList[i].pair.getBuyNFTQuote(
                swapList[i].nftIds.length
            );

            require(error == CurveErrorCodes.Error.OK, "Bonding curve error");

            remainingValue -= swapList[i].pair.swapTokenForSpecificNFTs{
                value: pairCost
            }(
                swapList[i].nftIds,
                remainingValue,
                nftRecipient,
                true,
                msg.sender
            );

            unchecked {
                ++i;
            }
        }

        if (remainingValue > 0) {
            ethRecipient.safeTransferETH(remainingValue);
        }
    }

    function _swapERC20ForAnyNFTs(
        PairSwapAny[] calldata swapList,
        uint256 inputAmount,
        address nftRecipient
    ) internal returns (uint256 remainingValue) {

        remainingValue = inputAmount;

        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps; ) {
            remainingValue -= swapList[i].pair.swapTokenForAnyNFTs(
                swapList[i].numItems,
                remainingValue,
                nftRecipient,
                true,
                msg.sender
            );

            unchecked {
                ++i;
            }
        }
    }

    function _swapERC20ForSpecificNFTs(
        PairSwapSpecific[] calldata swapList,
        uint256 inputAmount,
        address nftRecipient
    ) internal returns (uint256 remainingValue) {

        remainingValue = inputAmount;

        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps; ) {
            remainingValue -= swapList[i].pair.swapTokenForSpecificNFTs(
                swapList[i].nftIds,
                remainingValue,
                nftRecipient,
                true,
                msg.sender
            );

            unchecked {
                ++i;
            }
        }
    }

    function _swapNFTsForToken(
        PairSwapSpecific[] calldata swapList,
        uint256 minOutput,
        address payable tokenRecipient
    ) internal returns (uint256 outputAmount) {

        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps; ) {
            outputAmount += swapList[i].pair.swapNFTsForToken(
                swapList[i].nftIds,
                0,
                tokenRecipient,
                true,
                msg.sender
            );

            unchecked {
                ++i;
            }
        }

        require(outputAmount >= minOutput, "outputAmount too low");
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// AGPL-3.0
pragma solidity ^0.8.0;


abstract contract LSSVMPair is
    OwnableWithTransferCallback,
    ReentrancyGuard,
    ERC1155Holder
{
    enum PoolType {
        TOKEN,
        NFT,
        TRADE
    }

    uint256 internal constant MAX_FEE = 0.90e18;

    uint128 public spotPrice;

    uint128 public delta;

    uint96 public fee;

    address payable public assetRecipient;

    event SwapNFTInPair();
    event SwapNFTOutPair();
    event SpotPriceUpdate(uint128 newSpotPrice);
    event TokenDeposit(uint256 amount);
    event TokenWithdrawal(uint256 amount);
    event NFTWithdrawal();
    event DeltaUpdate(uint128 newDelta);
    event FeeUpdate(uint96 newFee);
    event AssetRecipientChange(address a);

    error BondingCurveError(CurveErrorCodes.Error error);

    function initialize(
        address _owner,
        address payable _assetRecipient,
        uint128 _delta,
        uint96 _fee,
        uint128 _spotPrice
    ) external payable {
        require(owner() == address(0), "Initialized");
        __Ownable_init(_owner);
        __ReentrancyGuard_init();

        ICurve _bondingCurve = bondingCurve();
        PoolType _poolType = poolType();

        if ((_poolType == PoolType.TOKEN) || (_poolType == PoolType.NFT)) {
            require(_fee == 0, "Only Trade Pools can have nonzero fee");
            assetRecipient = _assetRecipient;
        } else if (_poolType == PoolType.TRADE) {
            require(_fee < MAX_FEE, "Trade fee must be less than 90%");
            require(
                _assetRecipient == address(0),
                "Trade pools can't set asset recipient"
            );
            fee = _fee;
        }
        require(_bondingCurve.validateDelta(_delta), "Invalid delta for curve");
        require(
            _bondingCurve.validateSpotPrice(_spotPrice),
            "Invalid new spot price for curve"
        );
        delta = _delta;
        spotPrice = _spotPrice;
    }


    function swapTokenForAnyNFTs(
        uint256 numNFTs,
        uint256 maxExpectedTokenInput,
        address nftRecipient,
        bool isRouter,
        address routerCaller
    ) external payable virtual nonReentrant returns (uint256 inputAmount) {
        ILSSVMPairFactoryLike _factory = factory();
        ICurve _bondingCurve = bondingCurve();
        IERC721 _nft = nft();

        {
            PoolType _poolType = poolType();
            require(
                _poolType == PoolType.NFT || _poolType == PoolType.TRADE,
                "Wrong Pool type"
            );
            require(
                (numNFTs > 0) && (numNFTs <= _nft.balanceOf(address(this))),
                "Ask for > 0 and <= balanceOf NFTs"
            );
        }

        uint256 protocolFee;
        (protocolFee, inputAmount) = _calculateBuyInfoAndUpdatePoolParams(
            numNFTs,
            maxExpectedTokenInput,
            _bondingCurve,
            _factory
        );

        _pullTokenInputAndPayProtocolFee(
            inputAmount,
            isRouter,
            routerCaller,
            _factory,
            protocolFee
        );

        _sendAnyNFTsToRecipient(_nft, nftRecipient, numNFTs);

        _refundTokenToSender(inputAmount);

        emit SwapNFTOutPair();
    }

    function swapTokenForSpecificNFTs(
        uint256[] calldata nftIds,
        uint256 maxExpectedTokenInput,
        address nftRecipient,
        bool isRouter,
        address routerCaller
    ) external payable virtual nonReentrant returns (uint256 inputAmount) {
        ILSSVMPairFactoryLike _factory = factory();
        ICurve _bondingCurve = bondingCurve();

        {
            PoolType _poolType = poolType();
            require(
                _poolType == PoolType.NFT || _poolType == PoolType.TRADE,
                "Wrong Pool type"
            );
            require((nftIds.length > 0), "Must ask for > 0 NFTs");
        }

        uint256 protocolFee;
        (protocolFee, inputAmount) = _calculateBuyInfoAndUpdatePoolParams(
            nftIds.length,
            maxExpectedTokenInput,
            _bondingCurve,
            _factory
        );

        _pullTokenInputAndPayProtocolFee(
            inputAmount,
            isRouter,
            routerCaller,
            _factory,
            protocolFee
        );

        _sendSpecificNFTsToRecipient(nft(), nftRecipient, nftIds);

        _refundTokenToSender(inputAmount);

        emit SwapNFTOutPair();
    }

    function swapNFTsForToken(
        uint256[] calldata nftIds,
        uint256 minExpectedTokenOutput,
        address payable tokenRecipient,
        bool isRouter,
        address routerCaller
    ) external virtual nonReentrant returns (uint256 outputAmount) {
        ILSSVMPairFactoryLike _factory = factory();
        ICurve _bondingCurve = bondingCurve();

        {
            PoolType _poolType = poolType();
            require(
                _poolType == PoolType.TOKEN || _poolType == PoolType.TRADE,
                "Wrong Pool type"
            );
            require(nftIds.length > 0, "Must ask for > 0 NFTs");
        }

        uint256 protocolFee;
        (protocolFee, outputAmount) = _calculateSellInfoAndUpdatePoolParams(
            nftIds.length,
            minExpectedTokenOutput,
            _bondingCurve,
            _factory
        );

        _sendTokenOutput(tokenRecipient, outputAmount);

        _payProtocolFeeFromPair(_factory, protocolFee);

        _takeNFTsFromSender(nft(), nftIds, _factory, isRouter, routerCaller);

        emit SwapNFTInPair();
    }


    function getBuyNFTQuote(uint256 numNFTs)
        external
        view
        returns (
            CurveErrorCodes.Error error,
            uint256 newSpotPrice,
            uint256 newDelta,
            uint256 inputAmount,
            uint256 protocolFee
        )
    {
        (
            error,
            newSpotPrice,
            newDelta,
            inputAmount,
            protocolFee
        ) = bondingCurve().getBuyInfo(
            spotPrice,
            delta,
            numNFTs,
            fee,
            factory().protocolFeeMultiplier()
        );
    }

    function getSellNFTQuote(uint256 numNFTs)
        external
        view
        returns (
            CurveErrorCodes.Error error,
            uint256 newSpotPrice,
            uint256 newDelta,
            uint256 outputAmount,
            uint256 protocolFee
        )
    {
        (
            error,
            newSpotPrice,
            newDelta,
            outputAmount,
            protocolFee
        ) = bondingCurve().getSellInfo(
            spotPrice,
            delta,
            numNFTs,
            fee,
            factory().protocolFeeMultiplier()
        );
    }

    function getAllHeldIds() external view virtual returns (uint256[] memory);

    function pairVariant()
        public
        pure
        virtual
        returns (ILSSVMPairFactoryLike.PairVariant);

    function factory() public pure returns (ILSSVMPairFactoryLike _factory) {
        uint256 paramsLength = _immutableParamsLength();
        assembly {
            _factory := shr(
                0x60,
                calldataload(sub(calldatasize(), paramsLength))
            )
        }
    }

    function bondingCurve() public pure returns (ICurve _bondingCurve) {
        uint256 paramsLength = _immutableParamsLength();
        assembly {
            _bondingCurve := shr(
                0x60,
                calldataload(add(sub(calldatasize(), paramsLength), 20))
            )
        }
    }

    function nft() public pure returns (IERC721 _nft) {
        uint256 paramsLength = _immutableParamsLength();
        assembly {
            _nft := shr(
                0x60,
                calldataload(add(sub(calldatasize(), paramsLength), 40))
            )
        }
    }

    function poolType() public pure returns (PoolType _poolType) {
        uint256 paramsLength = _immutableParamsLength();
        assembly {
            _poolType := shr(
                0xf8,
                calldataload(add(sub(calldatasize(), paramsLength), 60))
            )
        }
    }

    function getAssetRecipient()
        public
        view
        returns (address payable _assetRecipient)
    {
        if (poolType() == PoolType.TRADE) {
            return payable(address(this));
        }

        _assetRecipient = assetRecipient;
        if (_assetRecipient == address(0)) {
            _assetRecipient = payable(address(this));
        }
    }


    function _calculateBuyInfoAndUpdatePoolParams(
        uint256 numNFTs,
        uint256 maxExpectedTokenInput,
        ICurve _bondingCurve,
        ILSSVMPairFactoryLike _factory
    ) internal returns (uint256 protocolFee, uint256 inputAmount) {
        CurveErrorCodes.Error error;
        uint128 currentSpotPrice = spotPrice;
        uint128 newSpotPrice;
        uint128 currentDelta = delta;
        uint128 newDelta;
        (
            error,
            newSpotPrice,
            newDelta,
            inputAmount,
            protocolFee
        ) = _bondingCurve.getBuyInfo(
            currentSpotPrice,
            currentDelta,
            numNFTs,
            fee,
            _factory.protocolFeeMultiplier()
        );

        if (error != CurveErrorCodes.Error.OK) {
            revert BondingCurveError(error);
        }

        require(inputAmount <= maxExpectedTokenInput, "In too many tokens");

        if (currentSpotPrice != newSpotPrice || currentDelta != newDelta) {
            spotPrice = newSpotPrice;
            delta = newDelta;
        }
        if (currentSpotPrice != newSpotPrice) {
            emit SpotPriceUpdate(newSpotPrice);
        }
        if (currentDelta != newDelta) {
            emit DeltaUpdate(newDelta);
        }
    }

    function _calculateSellInfoAndUpdatePoolParams(
        uint256 numNFTs,
        uint256 minExpectedTokenOutput,
        ICurve _bondingCurve,
        ILSSVMPairFactoryLike _factory
    ) internal returns (uint256 protocolFee, uint256 outputAmount) {
        CurveErrorCodes.Error error;
        uint128 currentSpotPrice = spotPrice;
        uint128 newSpotPrice;
        uint128 currentDelta = delta;
        uint128 newDelta;
        (
            error,
            newSpotPrice,
            newDelta,
            outputAmount,
            protocolFee
        ) = _bondingCurve.getSellInfo(
            currentSpotPrice,
            currentDelta,
            numNFTs,
            fee,
            _factory.protocolFeeMultiplier()
        );

        if (error != CurveErrorCodes.Error.OK) {
            revert BondingCurveError(error);
        }

        require(
            outputAmount >= minExpectedTokenOutput,
            "Out too little tokens"
        );

        if (currentSpotPrice != newSpotPrice || currentDelta != newDelta) {
            spotPrice = newSpotPrice;
            delta = newDelta;
        }
        if (currentSpotPrice != newSpotPrice) {
            emit SpotPriceUpdate(newSpotPrice);
        }
        if (currentDelta != newDelta) {
            emit DeltaUpdate(newDelta);
        }
    }

    function _pullTokenInputAndPayProtocolFee(
        uint256 inputAmount,
        bool isRouter,
        address routerCaller,
        ILSSVMPairFactoryLike _factory,
        uint256 protocolFee
    ) internal virtual;

    function _refundTokenToSender(uint256 inputAmount) internal virtual;

    function _payProtocolFeeFromPair(
        ILSSVMPairFactoryLike _factory,
        uint256 protocolFee
    ) internal virtual;

    function _sendTokenOutput(
        address payable tokenRecipient,
        uint256 outputAmount
    ) internal virtual;

    function _sendAnyNFTsToRecipient(
        IERC721 _nft,
        address nftRecipient,
        uint256 numNFTs
    ) internal virtual;

    function _sendSpecificNFTsToRecipient(
        IERC721 _nft,
        address nftRecipient,
        uint256[] calldata nftIds
    ) internal virtual;

    function _takeNFTsFromSender(
        IERC721 _nft,
        uint256[] calldata nftIds,
        ILSSVMPairFactoryLike _factory,
        bool isRouter,
        address routerCaller
    ) internal virtual {
        {
            address _assetRecipient = getAssetRecipient();
            uint256 numNFTs = nftIds.length;

            if (isRouter) {
                LSSVMRouter router = LSSVMRouter(payable(msg.sender));
                (bool routerAllowed, ) = _factory.routerStatus(router);
                require(routerAllowed, "Not router");

                if (numNFTs > 1) {
                    uint256 beforeBalance = _nft.balanceOf(_assetRecipient);
                    for (uint256 i = 0; i < numNFTs; ) {
                        router.pairTransferNFTFrom(
                            _nft,
                            routerCaller,
                            _assetRecipient,
                            nftIds[i],
                            pairVariant()
                        );

                        unchecked {
                            ++i;
                        }
                    }
                    require(
                        (_nft.balanceOf(_assetRecipient) - beforeBalance) ==
                            numNFTs,
                        "NFTs not transferred"
                    );
                } else {
                    router.pairTransferNFTFrom(
                        _nft,
                        routerCaller,
                        _assetRecipient,
                        nftIds[0],
                        pairVariant()
                    );
                    require(
                        _nft.ownerOf(nftIds[0]) == _assetRecipient,
                        "NFT not transferred"
                    );
                }
            } else {
                for (uint256 i; i < numNFTs; ) {
                    _nft.safeTransferFrom(
                        msg.sender,
                        _assetRecipient,
                        nftIds[i]
                    );

                    unchecked {
                        ++i;
                    }
                }
            }
        }
    }

    function _immutableParamsLength() internal pure virtual returns (uint256);


    function withdrawERC721(IERC721 a, uint256[] calldata nftIds)
        external
        virtual;

    function withdrawERC20(ERC20 a, uint256 amount) external virtual;

    function withdrawERC1155(
        IERC1155 a,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external onlyOwner {
        a.safeBatchTransferFrom(address(this), msg.sender, ids, amounts, "");
    }

    function changeSpotPrice(uint128 newSpotPrice) external onlyOwner {
        ICurve _bondingCurve = bondingCurve();
        require(
            _bondingCurve.validateSpotPrice(newSpotPrice),
            "Invalid new spot price for curve"
        );
        if (spotPrice != newSpotPrice) {
            spotPrice = newSpotPrice;
            emit SpotPriceUpdate(newSpotPrice);
        }
    }

    function changeDelta(uint128 newDelta) external onlyOwner {
        ICurve _bondingCurve = bondingCurve();
        require(
            _bondingCurve.validateDelta(newDelta),
            "Invalid delta for curve"
        );
        if (delta != newDelta) {
            delta = newDelta;
            emit DeltaUpdate(newDelta);
        }
    }

    function changeFee(uint96 newFee) external onlyOwner {
        PoolType _poolType = poolType();
        require(_poolType == PoolType.TRADE, "Only for Trade pools");
        require(newFee < MAX_FEE, "Trade fee must be less than 90%");
        if (fee != newFee) {
            fee = newFee;
            emit FeeUpdate(newFee);
        }
    }

    function changeAssetRecipient(address payable newRecipient)
        external
        onlyOwner
    {
        PoolType _poolType = poolType();
        require(_poolType != PoolType.TRADE, "Not for Trade pools");
        if (assetRecipient != newRecipient) {
            assetRecipient = newRecipient;
            emit AssetRecipientChange(newRecipient);
        }
    }

    function call(address payable target, bytes calldata data)
        external
        onlyOwner
    {
        ILSSVMPairFactoryLike _factory = factory();
        require(_factory.callAllowed(target), "Target must be whitelisted");
        (bool result, ) = target.call{value: 0}(data);
        require(result, "Call failed");
    }

    function multicall(bytes[] calldata calls, bool revertOnFail)
        external
        onlyOwner
    {
        for (uint256 i; i < calls.length; ) {
            (bool success, bytes memory result) = address(this).delegatecall(
                calls[i]
            );
            if (!success && revertOnFail) {
                revert(_getRevertMsg(result));
            }

            unchecked {
                ++i;
            }
        }

        require(
            owner() == msg.sender,
            "Ownership cannot be changed in multicall"
        );
    }

    function _getRevertMsg(bytes memory _returnData)
        internal
        pure
        returns (string memory)
    {
        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }
}// AGPL-3.0
pragma solidity ^0.8.0;


abstract contract LSSVMPairERC20 is LSSVMPair {
    using SafeTransferLib for ERC20;

    uint256 internal constant IMMUTABLE_PARAMS_LENGTH = 81;

    function token() public pure returns (ERC20 _token) {
        uint256 paramsLength = _immutableParamsLength();
        assembly {
            _token := shr(
                0x60,
                calldataload(add(sub(calldatasize(), paramsLength), 61))
            )
        }
    }

    function _pullTokenInputAndPayProtocolFee(
        uint256 inputAmount,
        bool isRouter,
        address routerCaller,
        ILSSVMPairFactoryLike _factory,
        uint256 protocolFee
    ) internal override {
        require(msg.value == 0, "ERC20 pair");

        ERC20 _token = token();
        address _assetRecipient = getAssetRecipient();

        if (isRouter) {
            LSSVMRouter router = LSSVMRouter(payable(msg.sender));

            {
                (bool routerAllowed, ) = _factory.routerStatus(router);
                require(routerAllowed, "Not router");
            }

            uint256 beforeBalance = _token.balanceOf(_assetRecipient);
            router.pairTransferERC20From(
                _token,
                routerCaller,
                _assetRecipient,
                inputAmount - protocolFee,
                pairVariant()
            );

            require(
                _token.balanceOf(_assetRecipient) - beforeBalance ==
                    inputAmount - protocolFee,
                "ERC20 not transferred in"
            );

            router.pairTransferERC20From(
                _token,
                routerCaller,
                address(_factory),
                protocolFee,
                pairVariant()
            );

        } else {
            _token.safeTransferFrom(
                msg.sender,
                _assetRecipient,
                inputAmount - protocolFee
            );

            if (protocolFee > 0) {
                _token.safeTransferFrom(
                    msg.sender,
                    address(_factory),
                    protocolFee
                );
            }
        }
    }

    function _refundTokenToSender(uint256 inputAmount) internal override {
    }

    function _payProtocolFeeFromPair(
        ILSSVMPairFactoryLike _factory,
        uint256 protocolFee
    ) internal override {
        if (protocolFee > 0) {
            ERC20 _token = token();

            uint256 pairTokenBalance = _token.balanceOf(address(this));
            if (protocolFee > pairTokenBalance) {
                protocolFee = pairTokenBalance;
            }
            if (protocolFee > 0) {
                _token.safeTransfer(address(_factory), protocolFee);
            }
        }
    }

    function _sendTokenOutput(
        address payable tokenRecipient,
        uint256 outputAmount
    ) internal override {
        if (outputAmount > 0) {
            token().safeTransfer(tokenRecipient, outputAmount);
        }
    }

    function _immutableParamsLength() internal pure override returns (uint256) {
        return IMMUTABLE_PARAMS_LENGTH;
    }

    function withdrawERC20(ERC20 a, uint256 amount)
        external
        override
        onlyOwner
    {
        a.safeTransfer(msg.sender, amount);

        if (a == token()) {
            emit TokenWithdrawal(amount);
        }
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// AGPL-3.0
pragma solidity ^0.8.0;


abstract contract LSSVMPairMissingEnumerable is LSSVMPair {
    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.UintSet private idSet;

    function _sendAnyNFTsToRecipient(
        IERC721 _nft,
        address nftRecipient,
        uint256 numNFTs
    ) internal override {
        uint256 lastIndex = idSet.length() - 1;
        for (uint256 i; i < numNFTs; ) {
            uint256 nftId = idSet.at(lastIndex);
            _nft.safeTransferFrom(address(this), nftRecipient, nftId);
            idSet.remove(nftId);

            unchecked {
                --lastIndex;
                ++i;
            }
        }
    }

    function _sendSpecificNFTsToRecipient(
        IERC721 _nft,
        address nftRecipient,
        uint256[] calldata nftIds
    ) internal override {
        uint256 numNFTs = nftIds.length;
        for (uint256 i; i < numNFTs; ) {
            _nft.safeTransferFrom(address(this), nftRecipient, nftIds[i]);
            idSet.remove(nftIds[i]);

            unchecked {
                ++i;
            }
        }
    }

    function getAllHeldIds() external view override returns (uint256[] memory) {
        uint256 numNFTs = idSet.length();
        uint256[] memory ids = new uint256[](numNFTs);
        for (uint256 i; i < numNFTs; ) {
            ids[i] = idSet.at(i);

            unchecked {
                ++i;
            }
        }
        return ids;
    }

    function onERC721Received(
        address,
        address,
        uint256 id,
        bytes memory
    ) public virtual returns (bytes4) {
        IERC721 _nft = nft();
        if (msg.sender == address(_nft)) {
            idSet.add(id);
        }
        return this.onERC721Received.selector;
    }

    function withdrawERC721(IERC721 a, uint256[] calldata nftIds)
        external
        override
        onlyOwner
    {
        IERC721 _nft = nft();
        uint256 numNFTs = nftIds.length;

        if (a != _nft) {
            for (uint256 i; i < numNFTs; ) {
                a.safeTransferFrom(address(this), msg.sender, nftIds[i]);

                unchecked {
                    ++i;
                }
            }
        }
        else {
            for (uint256 i; i < numNFTs; ) {
                _nft.safeTransferFrom(address(this), msg.sender, nftIds[i]);
                idSet.remove(nftIds[i]);

                unchecked {
                    ++i;
                }
            }

            emit NFTWithdrawal();
        }
    }
}// AGPL-3.0
pragma solidity ^0.8.0;


contract LSSVMPairMissingEnumerableERC20 is
    LSSVMPairMissingEnumerable,
    LSSVMPairERC20
{

    function pairVariant()
        public
        pure
        override
        returns (ILSSVMPairFactoryLike.PairVariant)
    {

        return ILSSVMPairFactoryLike.PairVariant.MISSING_ENUMERABLE_ERC20;
    }
}