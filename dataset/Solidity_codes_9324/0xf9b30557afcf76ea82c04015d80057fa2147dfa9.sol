
pragma solidity ^0.6.5;


interface IERC20TokenV06 {


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function transfer(address to, uint256 value)
        external
        returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external
        returns (bool);


    function approve(address spender, uint256 value)
        external
        returns (bool);


    function totalSupply()
        external
        view
        returns (uint256);


    function balanceOf(address owner)
        external
        view
        returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function decimals()
        external
        view
        returns (uint8);

}// Apache-2.0

pragma solidity ^0.6.5;



interface IEtherTokenV06 is
    IERC20TokenV06
{

    function deposit() external payable;


    function withdraw(uint256 amount) external;

}// Apache-2.0

pragma solidity ^0.6.5;


library LibRichErrorsV06 {


    bytes4 internal constant STANDARD_ERROR_SELECTOR = 0x08c379a0;

    function StandardError(string memory message)
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
}// Apache-2.0

pragma solidity ^0.6.5;


library LibOwnableRichErrors {



    function OnlyOwnerError(
        address sender,
        address owner
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("OnlyOwnerError(address,address)")),
            sender,
            owner
        );
    }

    function TransferOwnerToZeroError()
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("TransferOwnerToZeroError()"))
        );
    }

    function MigrateCallFailedError(address target, bytes memory resultData)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("MigrateCallFailedError(address,bytes)")),
            target,
            resultData
        );
    }
}// Apache-2.0

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;



library LibMigrate {


    bytes4 internal constant MIGRATE_SUCCESS = 0x2c64c5ef;

    using LibRichErrorsV06 for bytes;

    function delegatecallMigrateFunction(
        address target,
        bytes memory data
    )
        internal
    {

        (bool success, bytes memory resultData) = target.delegatecall(data);
        if (!success ||
            resultData.length != 32 ||
            abi.decode(resultData, (bytes4)) != MIGRATE_SUCCESS)
        {
            LibOwnableRichErrors.MigrateCallFailedError(target, resultData).rrevert();
        }
    }
}// Apache-2.0

pragma solidity ^0.6.5;


interface IOwnableV06 {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function transferOwnership(address newOwner) external;


    function owner() external view returns (address ownerAddress);

}// Apache-2.0

pragma solidity ^0.6.5;



interface IAuthorizableV06 is
    IOwnableV06
{

    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    function addAuthorizedAddress(address target)
        external;


    function removeAuthorizedAddress(address target)
        external;


    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external;


    function getAuthorizedAddresses()
        external
        view
        returns (address[] memory authorizedAddresses);


    function authorized(address addr) external view returns (bool isAuthorized);


    function authorities(uint256 idx) external view returns (address addr);


}// Apache-2.0

pragma solidity ^0.6.5;



interface IAllowanceTarget is
    IAuthorizableV06
{

    function executeCall(
        address payable target,
        bytes calldata callData
    )
        external
        returns (bytes memory resultData);

}// Apache-2.0

pragma solidity ^0.6.5;


library LibCommonRichErrors {



    function OnlyCallableBySelfError(address sender)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("OnlyCallableBySelfError(address)")),
            sender
        );
    }

    function IllegalReentrancyError(bytes4 selector, uint256 reentrancyFlags)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("IllegalReentrancyError(bytes4,uint256)")),
            selector,
            reentrancyFlags
        );
    }
}// Apache-2.0

pragma solidity ^0.6.5;



interface IOwnableFeature is
    IOwnableV06
{

    event Migrated(address caller, address migrator, address newOwner);

    function migrate(address target, bytes calldata data, address newOwner) external;

}// Apache-2.0

pragma solidity ^0.6.5;


interface ISimpleFunctionRegistryFeature {


    event ProxyFunctionUpdated(bytes4 indexed selector, address oldImpl, address newImpl);

    function rollback(bytes4 selector, address targetImpl) external;


    function extend(bytes4 selector, address impl) external;


    function getRollbackLength(bytes4 selector)
        external
        view
        returns (uint256 rollbackLength);


    function getRollbackEntryAtIndex(bytes4 selector, uint256 idx)
        external
        view
        returns (address impl);

}// Apache-2.0

pragma solidity ^0.6.5;



abstract contract FixinCommon {

    using LibRichErrorsV06 for bytes;

    address internal immutable _implementation;

    modifier onlySelf() virtual {
        if (msg.sender != address(this)) {
            LibCommonRichErrors.OnlyCallableBySelfError(msg.sender).rrevert();
        }
        _;
    }

    modifier onlyOwner() virtual {
        {
            address owner = IOwnableFeature(address(this)).owner();
            if (msg.sender != owner) {
                LibOwnableRichErrors.OnlyOwnerError(
                    msg.sender,
                    owner
                ).rrevert();
            }
        }
        _;
    }

    constructor() internal {
        _implementation = address(this);
    }

    function _registerFeatureFunction(bytes4 selector)
        internal
    {
        ISimpleFunctionRegistryFeature(address(this)).extend(selector, _implementation);
    }

    function _encodeVersion(uint32 major, uint32 minor, uint32 revision)
        internal
        pure
        returns (uint256 encodedVersion)
    {
        return (uint256(major) << 64) | (uint256(minor) << 32) | uint256(revision);
    }
}// Apache-2.0

pragma solidity ^0.6.5;


interface IFeature {



    function FEATURE_NAME() external view returns (string memory name);


    function FEATURE_VERSION() external view returns (uint256 version);

}// Apache-2.0

pragma solidity ^0.6.5;



interface IUniswapFeature {


    function sellToUniswap(
        IERC20TokenV06[] calldata tokens,
        uint256 sellAmount,
        uint256 minBuyAmount,
        bool isSushi
    )
        external
        payable
        returns (uint256 buyAmount);

}// Apache-2.0

pragma solidity ^0.6.5;



contract UniswapFeature is
    IFeature,
    IUniswapFeature,
    FixinCommon
{

    string public constant override FEATURE_NAME = "UniswapFeature";
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 1, 1);
    bytes32 public immutable GREEDY_TOKENS_BLOOM_FILTER;
    IEtherTokenV06 private immutable WETH;
    IAllowanceTarget private immutable ALLOWANCE_TARGET;

    uint256 constant private FF_UNISWAP_FACTORY = 0xFF5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f0000000000000000000000;
    uint256 constant private FF_SUSHISWAP_FACTORY = 0xFFC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac0000000000000000000000;
    uint256 constant private UNISWAP_PAIR_INIT_CODE_HASH = 0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f;
    uint256 constant private SUSHISWAP_PAIR_INIT_CODE_HASH = 0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303;
    uint256 constant private ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    uint256 constant private ETH_TOKEN_ADDRESS_32 = 0x000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;
    uint256 constant private MAX_SWAP_AMOUNT = 2**112;

    uint256 constant private ALLOWANCE_TARGET_EXECUTE_CALL_SELECTOR_32 = 0xbca8c7b500000000000000000000000000000000000000000000000000000000;
    uint256 constant private UNISWAP_PAIR_RESERVES_CALL_SELECTOR_32 = 0x0902f1ac00000000000000000000000000000000000000000000000000000000;
    uint256 constant private UNISWAP_PAIR_SWAP_CALL_SELECTOR_32 = 0x022c0d9f00000000000000000000000000000000000000000000000000000000;
    uint256 constant private TRANSFER_FROM_CALL_SELECTOR_32 = 0x23b872dd00000000000000000000000000000000000000000000000000000000;
    uint256 constant private ALLOWANCE_CALL_SELECTOR_32 = 0xdd62ed3e00000000000000000000000000000000000000000000000000000000;
    uint256 constant private WETH_WITHDRAW_CALL_SELECTOR_32 = 0x2e1a7d4d00000000000000000000000000000000000000000000000000000000;
    uint256 constant private WETH_DEPOSIT_CALL_SELECTOR_32 = 0xd0e30db000000000000000000000000000000000000000000000000000000000;
    uint256 constant private ERC20_TRANSFER_CALL_SELECTOR_32 = 0xa9059cbb00000000000000000000000000000000000000000000000000000000;

    constructor(
        IEtherTokenV06 weth,
        IAllowanceTarget allowanceTarget,
        bytes32 greedyTokensBloomFilter
    ) public {
        WETH = weth;
        ALLOWANCE_TARGET = allowanceTarget;
        GREEDY_TOKENS_BLOOM_FILTER = greedyTokensBloomFilter;
    }

    function migrate()
        external
        returns (bytes4 success)
    {

        _registerFeatureFunction(this.sellToUniswap.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    function sellToUniswap(
        IERC20TokenV06[] calldata tokens,
        uint256 sellAmount,
        uint256 minBuyAmount,
        bool isSushi
    )
        external
        payable
        override
        returns (uint256 buyAmount)
    {

        require(tokens.length > 1, "UniswapFeature/InvalidTokensLength");
        {
            IEtherTokenV06 weth = WETH;
            IAllowanceTarget allowanceTarget = ALLOWANCE_TARGET;
            bytes32 greedyTokensBloomFilter = GREEDY_TOKENS_BLOOM_FILTER;

            assembly {
                mstore(0xA00, add(calldataload(0x04), 0x24))
                mstore(0xA20, isSushi)
                mstore(0xA40, weth)
                mstore(0xA60, allowanceTarget)
                mstore(0xA80, greedyTokensBloomFilter)
            }
        }

        assembly {
            let numPairs := sub(calldataload(add(calldataload(0x04), 0x4)), 1)
            buyAmount := sellAmount
            let buyToken
            let nextPair := 0

            for {let i := 0} lt(i, numPairs) {i := add(i, 1)} {
                let sellToken := loadTokenAddress(i)
                buyToken := loadTokenAddress(add(i, 1))
                let pairOrder := lt(normalizeToken(sellToken), normalizeToken(buyToken))

                let pair := nextPair
                if iszero(pair) {
                    pair := computePairAddress(sellToken, buyToken)
                    nextPair := 0
                }

                if iszero(i) {
                    switch eq(sellToken, ETH_TOKEN_ADDRESS_32)
                        case 0 { // Not selling ETH. Selling an ERC20 instead.
                            if gt(callvalue(), 0) {
                                revert(0, 0)
                            }
                            moveTakerTokensTo(sellToken, pair, sellAmount)
                        }
                        default {
                            if iszero(eq(callvalue(), sellAmount)) {
                                revert(0, 0)
                            }
                            sellToken := mload(0xA40)// Re-assign to WETH
                            mstore(0xB00, WETH_DEPOSIT_CALL_SELECTOR_32)
                            if iszero(call(gas(), sellToken, sellAmount, 0xB00, 0x4, 0x00, 0x0)) {
                                bubbleRevert()
                            }
                            mstore(0xB00, ERC20_TRANSFER_CALL_SELECTOR_32)
                            mstore(0xB04, pair)
                            mstore(0xB24, sellAmount)
                            if iszero(call(gas(), sellToken, 0, 0xB00, 0x44, 0x00, 0x0)) {
                                bubbleRevert()
                            }
                        }
                }

                mstore(0xB00, UNISWAP_PAIR_RESERVES_CALL_SELECTOR_32)
                if iszero(staticcall(gas(), pair, 0xB00, 0x4, 0xC00, 0x40)) {
                    bubbleRevert()
                }
                if lt(returndatasize(), 0x40) {
                    revert(0,0)
                }

                let pairSellAmount := buyAmount
                {
                    let sellReserve
                    let buyReserve
                    switch iszero(pairOrder)
                        case 0 {
                            sellReserve := mload(0xC00)
                            buyReserve := mload(0xC20)
                        }
                        default {
                            sellReserve := mload(0xC20)
                            buyReserve := mload(0xC00)
                        }
                    if gt(pairSellAmount, MAX_SWAP_AMOUNT) {
                        revert(0, 0)
                    }
                    let sellAmountWithFee := mul(pairSellAmount, 997)
                    buyAmount := div(
                        mul(sellAmountWithFee, buyReserve),
                        add(sellAmountWithFee, mul(sellReserve, 1000))
                    )
                }

                let receiver
                switch eq(add(i, 1), numPairs)
                    case 0 {
                        nextPair := computePairAddress(
                            buyToken,
                            loadTokenAddress(add(i, 2))
                        )
                        receiver := nextPair
                    }
                    default {
                        switch eq(buyToken, ETH_TOKEN_ADDRESS_32)
                            case 0 {
                                receiver := caller()
                            }
                            default {
                                receiver := address()
                            }
                    }

                mstore(0xB00, UNISWAP_PAIR_SWAP_CALL_SELECTOR_32)
                switch pairOrder
                    case 0 {
                        mstore(0xB04, buyAmount)
                        mstore(0xB24, 0)
                    }
                    default {
                        mstore(0xB04, 0)
                        mstore(0xB24, buyAmount)
                    }
                mstore(0xB44, receiver)
                mstore(0xB64, 0x80)
                mstore(0xB84, 0)
                if iszero(call(gas(), pair, 0, 0xB00, 0xA4, 0, 0)) {
                    bubbleRevert()
                }
            } // End for-loop.

            if eq(buyToken, ETH_TOKEN_ADDRESS_32) {
                mstore(0xB00, WETH_WITHDRAW_CALL_SELECTOR_32)
                mstore(0xB04, buyAmount)
                if iszero(call(gas(), mload(0xA40), 0, 0xB00, 0x24, 0x00, 0x0)) {
                    bubbleRevert()
                }
                if iszero(call(gas(), caller(), buyAmount, 0xB00, 0x0, 0x00, 0x0)) {
                    bubbleRevert()
                }
            }


            function loadTokenAddress(idx) -> addr {
                addr := and(ADDRESS_MASK, calldataload(add(mload(0xA00), mul(idx, 0x20))))
            }

            function normalizeToken(token) -> normalized {
                normalized := token
                if eq(token, ETH_TOKEN_ADDRESS_32) {
                    normalized := mload(0xA40)
                }
            }

            function computePairAddress(tokenA, tokenB) -> pair {
                tokenA := normalizeToken(tokenA)
                tokenB := normalizeToken(tokenB)

                switch lt(tokenA, tokenB)
                    case 0 {
                        mstore(0xB14, tokenA)
                        mstore(0xB00, tokenB)
                    }
                    default {
                        mstore(0xB14, tokenB)
                        mstore(0xB00, tokenA)
                    }
                let salt := keccak256(0xB0C, 0x28)
                switch mload(0xA20) // isSushi
                    case 0 {
                        mstore(0xB00, FF_UNISWAP_FACTORY)
                        mstore(0xB15, salt)
                        mstore(0xB35, UNISWAP_PAIR_INIT_CODE_HASH)
                    }
                    default {
                        mstore(0xB00, FF_SUSHISWAP_FACTORY)
                        mstore(0xB15, salt)
                        mstore(0xB35, SUSHISWAP_PAIR_INIT_CODE_HASH)
                    }
                pair := and(ADDRESS_MASK, keccak256(0xB00, 0x55))
            }

            function bubbleRevert() {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }

            function moveTakerTokensTo(token, to, amount) {

                if isTokenPossiblyGreedy(token) {
                    mstore(0xB00, ALLOWANCE_CALL_SELECTOR_32)
                    mstore(0xB04, caller())
                    mstore(0xB24, address())
                    let success := staticcall(gas(), token, 0xB00, 0x44, 0xC00, 0x20)
                    if iszero(success) {
                        bubbleRevert()
                    }
                    if lt(returndatasize(), 0x20) {
                        revert(0, 0)
                    }
                    if lt(mload(0xC00), amount) {
                        moveTakerTokensToWithLegacyAllowanceTarget(token, to, amount)
                        leave
                    }
                }

                mstore(0xB00, TRANSFER_FROM_CALL_SELECTOR_32)
                mstore(0xB04, caller())
                mstore(0xB24, to)
                mstore(0xB44, amount)

                let success := call(
                    gas(),
                    token,
                    0,
                    0xB00,
                    0x64,
                    0xC00,
                    0x20
                )

                let rdsize := returndatasize()

                success := and(
                    success,                         // call itself succeeded
                    or(
                        iszero(rdsize),              // no return data, or
                        and(
                            iszero(lt(rdsize, 32)),  // at least 32 bytes
                            eq(mload(0xC00), 1)      // starts with uint256(1)
                        )
                    )
                )

                if iszero(success) {
                    moveTakerTokensToWithLegacyAllowanceTarget(token, to, amount)
                }
            }

            function moveTakerTokensToWithLegacyAllowanceTarget(token, to, amount) {
                mstore(0xB00, ALLOWANCE_TARGET_EXECUTE_CALL_SELECTOR_32)
                mstore(0xB04, token)
                mstore(0xB24, 0x40)
                mstore(0xB44, 0x64)
                mstore(0xB64, TRANSFER_FROM_CALL_SELECTOR_32)
                mstore(0xB68, caller())
                mstore(0xB88, to)
                mstore(0xBA8, amount)
                if iszero(call(gas(), mload(0xA60), 0, 0xB00, 0xC8, 0x00, 0x0)) {
                    bubbleRevert()
                }
            }

            function isTokenPossiblyGreedy(token) -> isPossiblyGreedy {
                mstore(0, token)
                let h := or(shl(mod(keccak256(0, 32), 256), 1), shl(mod(token, 256), 1))
                isPossiblyGreedy := eq(and(h, mload(0xA80)), h)
            }
        }

        require(buyAmount >= minBuyAmount, "UniswapFeature/UnderBought");
    }
}