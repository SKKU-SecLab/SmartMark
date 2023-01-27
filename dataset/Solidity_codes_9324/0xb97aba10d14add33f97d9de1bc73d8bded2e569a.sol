

pragma solidity 0.6.12;


interface VerifierRollupInterface {

    function verifyProof(
        uint256[2] calldata proofA,
        uint256[2][2] calldata proofB,
        uint256[2] calldata proofC,
        uint256[1] calldata input
    ) external view returns (bool);

}


interface VerifierWithdrawInterface {

    function verifyProof(
        uint256[2] calldata proofA,
        uint256[2][2] calldata proofB,
        uint256[2] calldata proofC,
        uint256[1] calldata input
    ) external view returns (bool);

}

interface ILitexAuctionProtocol {

    function getSlotDeadline() external view returns (uint8);


    function setSlotDeadline(uint8 newDeadline) external;


    function getOpenAuctionSlots() external view returns (uint16);


    function setOpenAuctionSlots(uint16 newOpenAuctionSlots) external;


    function getClosedAuctionSlots() external view returns (uint16);


    function setClosedAuctionSlots(uint16 newClosedAuctionSlots) external;


    function getOutbidding() external view returns (uint16);


    function setOutbidding(uint16 newOutbidding) external;


    function getAllocationRatio() external view returns (uint16[3] memory);


    function setAllocationRatio(uint16[3] memory newAllocationRatio) external;


    function getDonationAddress() external view returns (address);


    function setDonationAddress(address newDonationAddress) external;


    function getBootCoordinator() external view returns (address);


    function setBootCoordinator(
        address newBootCoordinator,
        string memory newBootCoordinatorURL
    ) external;


    function changeDefaultSlotSetBid(uint128 slotSet, uint128 newInitialMinBid)
        external;


    function setCoordinator(address forger, string memory coordinatorURL)
        external;


    function processBid(
        uint128 amount,
        uint128 slot,
        uint128 bidAmount,
        bytes calldata permit
    ) external;


    function processMultiBid(
        uint128 amount,
        uint128 startingSlot,
        uint128 endingSlot,
        bool[6] memory slotSets,
        uint128 maxBid,
        uint128 minBid,
        bytes calldata permit
    ) external;


    function forge(address forger) external;


    function canForge(address forger, uint256 blockNumber)
        external
        view
        returns (bool);

}



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
}

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

contract PoseidonUnit2 {

    function poseidon(uint256[2] memory) public pure returns (uint256) {}

}

contract PoseidonUnit3 {
    function poseidon(uint256[3] memory) public pure returns (uint256) {}
}

contract PoseidonUnit4 {
    function poseidon(uint256[4] memory) public pure returns (uint256) {}
}

contract LitexHelpers is Initializable {
    PoseidonUnit2 _insPoseidonUnit2;
    PoseidonUnit3 _insPoseidonUnit3;
    PoseidonUnit4 _insPoseidonUnit4;

    uint256 private constant _WORD_SIZE = 32;

    bytes32 public constant EIP712DOMAIN_HASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
    bytes32 public constant NAME_HASH =
        0xbe287413178bfeddef8d9753ad4be825ae998706a6dabff23978b59dccaea0ad;
    bytes32 public constant VERSION_HASH =
        0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;
    bytes32 public constant AUTHORISE_TYPEHASH =
        0xafd642c6a37a2e6887dc4ad5142f84197828a904e53d3204ecb1100329231eaa;
    bytes32 public constant LITEX_NETWORK_HASH =
        0xbe287413178bfeddef8d9753ad4be825ae998706a6dabff23978b59dccaea0ad;
    bytes32 public constant ACCOUNT_CREATION_HASH =
        0xff946cf82975b1a2b6e6d28c9a76a4b8d7a1fd0592b785cb92771933310f9ee7;

    function _initializeHelpers(
        address _poseidon2Elements,
        address _poseidon3Elements,
        address _poseidon4Elements
    ) internal initializer {
        _insPoseidonUnit2 = PoseidonUnit2(_poseidon2Elements);
        _insPoseidonUnit3 = PoseidonUnit3(_poseidon3Elements);
        _insPoseidonUnit4 = PoseidonUnit4(_poseidon4Elements);
    }

    function _hash2Elements(uint256[2] memory inputs)
        internal
        view
        returns (uint256)
    {
        return _insPoseidonUnit2.poseidon(inputs);
    }

    function _hash3Elements(uint256[3] memory inputs)
        internal
        view
        returns (uint256)
    {
        return _insPoseidonUnit3.poseidon(inputs);
    }

    function _hash4Elements(uint256[4] memory inputs)
        internal
        view
        returns (uint256)
    {
        return _insPoseidonUnit4.poseidon(inputs);
    }

    function _hashNode(uint256 left, uint256 right)
        internal
        view
        returns (uint256)
    {
        uint256[2] memory inputs;
        inputs[0] = left;
        inputs[1] = right;
        return _hash2Elements(inputs);
    }

    function _hashFinalNode(uint256 key, uint256 value)
        internal
        view
        returns (uint256)
    {
        uint256[3] memory inputs;
        inputs[0] = key;
        inputs[1] = value;
        inputs[2] = 1;
        return _hash3Elements(inputs);
    }

    function _smtVerifier(
        uint256 root,
        uint256[] memory siblings,
        uint256 key,
        uint256 value
    ) internal view returns (bool) {
        uint256 nextHash = _hashFinalNode(key, value);
        uint256 siblingTmp;
        for (int256 i = int256(siblings.length) - 1; i >= 0; i--) {
            siblingTmp = siblings[uint256(i)];
            bool leftRight = (uint8(key >> i) & 0x01) == 1;
            nextHash = leftRight
                ? _hashNode(siblingTmp, nextHash)
                : _hashNode(nextHash, siblingTmp);
        }

        return root == nextHash;
    }

    function _buildTreeState(
        uint32 token,
        uint48 nonce,
        uint256 balance,
        uint256 ay,
        address ethAddress
    ) internal pure returns (uint256[4] memory) {
        uint256[4] memory stateArray;

        stateArray[0] = token;
        stateArray[0] |= nonce << 32;
        stateArray[0] |= (ay >> 255) << (32 + 40);
        stateArray[1] = balance;
        stateArray[2] = (ay << 1) >> 1; // last bit set to 0
        stateArray[3] = uint256(ethAddress);
        return stateArray;
    }

    function _float2Fix(uint40 float) internal pure returns (uint256) {
        uint256 m = float & 0x7FFFFFFFF;
        uint256 e = float >> 35;

        uint256 exp = 10**e;

        uint256 fix = m * exp;

        return fix;
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32 domainSeparator) {
        return
            keccak256(
                abi.encode(
                    EIP712DOMAIN_HASH,
                    NAME_HASH,
                    VERSION_HASH,
                    getChainId(),
                    address(this)
                )
            );
    }

    function getChainId() public pure returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }

    function _checkSig(
        bytes32 babyjub,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) internal view returns (address) {
        require(
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "LitexHelpers::_checkSig: INVALID_S_VALUE"
        );

        bytes32 encodeData =
            keccak256(
                abi.encode(
                    AUTHORISE_TYPEHASH,
                    LITEX_NETWORK_HASH,
                    ACCOUNT_CREATION_HASH,
                    babyjub
                )
            );

        bytes32 messageDigest =
            keccak256(
                abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), encodeData)
            );

        address ethAddress = ecrecover(messageDigest, v, r, s);

        require(
            ethAddress != address(0),
            "LitexHelpers::_checkSig: INVALID_SIGNATURE"
        );

        return ethAddress;
    }

    function _getCallData(uint256 posParam)
        internal
        pure
        returns (uint256 ptr, uint256 len)
    {
        assembly {
            let pos := add(4, mul(posParam, 32))
            ptr := add(calldataload(pos), 4)
            len := calldataload(ptr)
            ptr := add(ptr, 32)
        }
    }

    function _fillZeros(uint256 ptr, uint256 len) internal pure {
        assembly {
            let ptrTo := ptr
            ptr := add(ptr, len)
            for {

            } lt(ptrTo, ptr) {
                ptrTo := add(ptrTo, 32)
            } {
                mstore(ptrTo, 0)
            }
        }
    }

    function _concatStorage(bytes storage _preBytes, bytes memory _postBytes)
        internal
    {
        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(
                and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)),
                2
            )
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
                case 2 {
                    sstore(
                        _preBytes_slot,
                        add(
                            fslot,
                            add(
                                mul(
                                    div(
                                        mload(add(_postBytes, 0x20)),
                                        exp(0x100, sub(32, mlength))
                                    ),
                                    exp(0x100, sub(32, newlength))
                                ),
                                mul(mlength, 2)
                            )
                        )
                    )
                }
                case 1 {
                    mstore(0x0, _preBytes_slot)
                    let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                    sstore(_preBytes_slot, add(mul(newlength, 2), 1))


                    let submod := sub(32, slength)
                    let mc := add(_postBytes, submod)
                    let end := add(_postBytes, mlength)
                    let mask := sub(exp(0x100, submod), 1)

                    sstore(
                        sc,
                        add(
                            and(
                                fslot,
                                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                            ),
                            and(mload(mc), mask)
                        )
                    )

                    for {
                        mc := add(mc, 0x20)
                        sc := add(sc, 1)
                    } lt(mc, end) {
                        sc := add(sc, 1)
                        mc := add(mc, 0x20)
                    } {
                        sstore(sc, mload(mc))
                    }

                    mask := exp(0x100, sub(mc, end))

                    sstore(sc, mul(div(mload(mc), mask), mask))
                }
                default {
                    mstore(0x0, _preBytes_slot)
                    let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                    sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                    let slengthmod := mod(slength, 32)
                    let mlengthmod := mod(mlength, 32)
                    let submod := sub(32, slengthmod)
                    let mc := add(_postBytes, submod)
                    let end := add(_postBytes, mlength)
                    let mask := sub(exp(0x100, submod), 1)

                    sstore(sc, add(sload(sc), and(mload(mc), mask)))

                    for {
                        sc := add(sc, 1)
                        mc := add(mc, 0x20)
                    } lt(mc, end) {
                        sc := add(sc, 1)
                        mc := add(mc, 0x20)
                    } {
                        sstore(sc, mload(mc))
                    }

                    mask := exp(0x100, sub(mc, end))

                    sstore(sc, mul(div(mload(mc), mask), mask))
                }
        }
    }
}


interface IWithdrawalDelayer {
    function getLitexGovernanceAddress() external view returns (address);

    function transferGovernance(address newGovernance) external;

    function claimGovernance() external;

    function getEmergencyCouncil() external view returns (address);

    function transferEmergencyCouncil(address payable newEmergencyCouncil)
        external;

    function claimEmergencyCouncil() external;

    function isEmergencyMode() external view returns (bool);

    function getWithdrawalDelay() external view returns (uint64);

    function getEmergencyModeStartingTime() external view returns (uint64);

    function enableEmergencyMode() external;

    function changeWithdrawalDelay(uint64 _newWithdrawalDelay) external;

    function depositInfo(address payable _owner, address _token)
        external
        view
        returns (uint192, uint64);

    function deposit(
        address _owner,
        address _token,
        uint192 _amount
    ) external payable;

    function withdrawal(address payable _owner, address _token) external;

    function escapeHatchWithdrawal(
        address _to,
        address _token,
        uint256 _amount
    ) external;
}

contract InstantWithdrawManager is LitexHelpers {
    using SafeMath for uint256;


    uint256 private constant _MAX_BUCKETS = 5;

    uint256 public nBuckets;
    mapping (int256 => uint256) public buckets;

    address public litexGovernanceAddress;

    uint64 public withdrawalDelay;

    bytes4 private constant _ERC20_DECIMALS = 0x313ce567;

    uint256 private constant _MAX_WITHDRAWAL_DELAY = 2 weeks;

    IWithdrawalDelayer public withdrawDelayerContract;

    mapping(address => uint64) public tokenExchange;

    uint256 private constant _EXCHANGE_MULTIPLIER = 1e10;

    event UpdateBucketWithdraw(
        uint8 indexed numBucket,
        uint256 indexed blockStamp,
        uint256 withdrawals
    );

    event UpdateWithdrawalDelay(uint64 newWithdrawalDelay);
    event UpdateBucketsParameters(uint256[] arrayBuckets);
    event UpdateTokenExchange(address[] addressArray, uint64[] valueArray);
    event SafeMode();

    function _initializeWithdraw(
        address _litexGovernanceAddress,
        uint64 _withdrawalDelay,
        address _withdrawDelayerContract
    ) internal initializer {
        litexGovernanceAddress = _litexGovernanceAddress;
        withdrawalDelay = _withdrawalDelay;
        withdrawDelayerContract = IWithdrawalDelayer(_withdrawDelayerContract);
    }

    modifier onlyGovernance {
        require(
            msg.sender == litexGovernanceAddress,
            "InstantWithdrawManager::onlyGovernance: ONLY_GOVERNANCE_ADDRESS"
        );
        _;
    }

    function _processInstantWithdrawal(address tokenAddress, uint192 amount)
        internal
        returns (bool)
    {
        uint256 amountUSD = _token2USD(tokenAddress, amount);

        if (amountUSD == 0) {
            return true;
        }

        int256 bucketIdx = _findBucketIdx(amountUSD);
        if (bucketIdx == -1) return true;

        (uint256 ceilUSD, uint256 blockStamp, uint256 withdrawals, uint256 rateBlocks, uint256 rateWithdrawals, uint256 maxWithdrawals) = unpackBucket(buckets[bucketIdx]);

        uint256 differenceBlocks = block.number.sub(blockStamp);
        uint256 periods = differenceBlocks.div(rateBlocks);

        withdrawals = withdrawals.add(periods.mul(rateWithdrawals));
        if (withdrawals >= maxWithdrawals) {
            withdrawals = maxWithdrawals;
            blockStamp = block.number;
        } else {
            blockStamp = blockStamp.add(periods.mul(rateBlocks));
        }

        if (withdrawals == 0) return false;

        withdrawals = withdrawals.sub(1);

        buckets[bucketIdx] = packBucket(ceilUSD, blockStamp, withdrawals, rateBlocks, rateWithdrawals, maxWithdrawals);

        emit UpdateBucketWithdraw(uint8(bucketIdx), blockStamp, withdrawals);
        return true;
    }

    function updateBucketsParameters(
        uint256[] memory newBuckets
    ) external onlyGovernance {
        uint256 n = newBuckets.length;
        require(
            n <= _MAX_BUCKETS,
            "InstantWithdrawManager::updateBucketsParameters: MAX_NUM_BUCKETS"
        );

        nBuckets = n;
        for (uint256 i = 0; i < n; i++) {
            (uint256 ceilUSD, , uint256 withdrawals, uint256 rateBlocks, uint256 rateWithdrawals, uint256 maxWithdrawals) = unpackBucket(newBuckets[i]);
            require(
                withdrawals <= maxWithdrawals,
                "InstantWithdrawManager::updateBucketsParameters: WITHDRAWALS_MUST_BE_LESS_THAN_MAXWITHDRAWALS"
            );
            require(
                rateBlocks > 0,
                "InstantWithdrawManager::updateBucketsParameters: RATE_BLOCKS_MUST_BE_MORE_THAN_0"
            );
            buckets[int256(i)] = packBucket(
                ceilUSD,
                block.number,
                withdrawals,
                rateBlocks,
                rateWithdrawals,
                maxWithdrawals
            );
        }
        emit UpdateBucketsParameters(newBuckets);
    }

    function updateTokenExchange(
        address[] memory addressArray,
        uint64[] memory valueArray
    ) external onlyGovernance {
        require(
            addressArray.length == valueArray.length,
            "InstantWithdrawManager::updateTokenExchange: INVALID_ARRAY_LENGTH"
        );
        for (uint256 i = 0; i < addressArray.length; i++) {
            tokenExchange[addressArray[i]] = valueArray[i];
        }
        emit UpdateTokenExchange(addressArray, valueArray);
    }

    function updateWithdrawalDelay(uint64 newWithdrawalDelay)
        external
        onlyGovernance
    {
        require(
            newWithdrawalDelay <= _MAX_WITHDRAWAL_DELAY,
            "InstantWithdrawManager::updateWithdrawalDelay: EXCEED_MAX_WITHDRAWAL_DELAY"
        );
        withdrawalDelay = newWithdrawalDelay;
        emit UpdateWithdrawalDelay(newWithdrawalDelay);
    }

    function safeMode() external onlyGovernance {
        nBuckets = 1;
        buckets[0] = packBucket(
            0xFFFFFFFF_FFFFFFFF_FFFFFFFF,
            0,
            0,
            1,
            0,
            0
        );
        withdrawDelayerContract.changeWithdrawalDelay(withdrawalDelay);
        emit SafeMode();
    }

    function instantWithdrawalViewer(address tokenAddress, uint192 amount)
        public
        view
        returns (bool)
    {
        uint256 amountUSD = _token2USD(tokenAddress, amount);
        if (amountUSD == 0) return true;

        int256 bucketIdx = _findBucketIdx(amountUSD);
        if (bucketIdx == -1) return true;


        (, uint256 blockStamp, uint256 withdrawals, uint256 rateBlocks, uint256 rateWithdrawals, uint256 maxWithdrawals) = unpackBucket(buckets[bucketIdx]);

        uint256 differenceBlocks = block.number.sub(blockStamp);
        uint256 periods = differenceBlocks.div(rateBlocks);

        withdrawals = withdrawals.add(periods.mul(rateWithdrawals));
        if (withdrawals>maxWithdrawals) withdrawals = maxWithdrawals;

        if (withdrawals == 0) return false;

        return true;
    }

    function _token2USD(address tokenAddress, uint192 amount)
        internal
        view
        returns (uint256)
    {
        if (tokenExchange[tokenAddress] == 0) return 0;

        uint256 baseUnitTokenUSD = (uint256(amount) *
            uint256(tokenExchange[tokenAddress])) / _EXCHANGE_MULTIPLIER;

        uint8 decimals;
        if (tokenAddress == address(0)) {
            decimals = 18;
        } else {
            (bool success, bytes memory data) = tokenAddress.staticcall(
                abi.encodeWithSelector(_ERC20_DECIMALS)
            );
            if (success) {
                decimals = abi.decode(data, (uint8));
            }
        }
        require(
            decimals < 77,
            "InstantWithdrawManager::_token2USD: TOKEN_DECIMALS_OVERFLOW"
        );
        return baseUnitTokenUSD / (10**uint256(decimals));
    }

    function _findBucketIdx(uint256 amountUSD) internal view returns (int256) {
        for (int256 i = 0; i < int256(nBuckets); i++) {
            uint256 ceilUSD = buckets[i] & 0xFFFFFFFF_FFFFFFFF_FFFFFFFF;
            if ((amountUSD <= ceilUSD) ||
                (ceilUSD == 0xFFFFFFFF_FFFFFFFF_FFFFFFFF))
            {
                return i;
            }
        }
        return -1;
    }

    function unpackBucket(uint256 bucket) public pure returns(
        uint256 ceilUSD,
        uint256 blockStamp,
        uint256 withdrawals,
        uint256 rateBlocks,
        uint256 rateWithdrawals,
        uint256 maxWithdrawals
    ) {
        ceilUSD = bucket & 0xFFFFFFFF_FFFFFFFF_FFFFFFFF;
        blockStamp = (bucket >> 96) & 0xFFFFFFFF;
        withdrawals = (bucket >> 128) & 0xFFFFFFFF;
        rateBlocks = (bucket >> 160) & 0xFFFFFFFF;
        rateWithdrawals = (bucket >> 192) & 0xFFFFFFFF;
        maxWithdrawals = (bucket >> 224) & 0xFFFFFFFF;
    }

    function packBucket(
        uint256 ceilUSD,
        uint256 blockStamp,
        uint256 withdrawals,
        uint256 rateBlocks,
        uint256 rateWithdrawals,
        uint256 maxWithdrawals
    ) public pure returns(uint256 ret) {
        ret = ceilUSD |
              (blockStamp << 96) |
              (withdrawals << 128) |
              (rateBlocks << 160) |
              (rateWithdrawals << 192) |
              (maxWithdrawals << 224);
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
}



contract LitexRollup is InstantWithdrawManager {
    struct VerifierRollup {
        VerifierRollupInterface verifierInterface;
        uint256 maxTx; // maximum rollup transactions in a batch: L2-tx + L1-tx transactions
        uint256 nLevels; // number of levels of the circuit
    }


    bytes4 constant _TRANSFER_SIGNATURE = 0xa9059cbb;

    bytes4 constant _TRANSFER_FROM_SIGNATURE = 0x23b872dd;

    bytes4 constant _APPROVE_SIGNATURE = 0x095ea7b3;


    bytes4 constant _PERMIT_SIGNATURE = 0xd505accf;

    uint48 constant _RESERVED_IDX = 255;

    uint48 constant _EXIT_IDX = 1;

    uint256 constant _LIMIT_LOAD_AMOUNT = (1 << 128);

    uint256 constant _LIMIT_L2TRANSFER_AMOUNT = (1 << 192);

    uint256 constant _LIMIT_TOKENS = (1 << 32);

    uint256 constant _L1_COORDINATOR_TOTALBYTES = 101;

    uint256 constant _L1_USER_TOTALBYTES = 78;


    uint256 constant _MAX_L1_USER_TX = 128;

    uint256 constant _MAX_L1_TX = 256;

    uint256 constant _RFIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;


    uint256 constant _INPUT_SHA_CONSTANT_BYTES = 20082;

    uint8 public constant ABSOLUTE_MAX_L1L2BATCHTIMEOUT = 240;

    address constant _ETH_ADDRESS_INTERNAL_ONLY = address(
        0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF
    );

    VerifierRollup[] public rollupVerifiers;

    VerifierWithdrawInterface public withdrawVerifier;

    uint48 public lastIdx;

    uint32 public lastForgedBatch;

    mapping(uint32 => uint256) public stateRootMap;

    mapping(uint32 => uint256) public exitRootsMap;

    mapping(uint32 => bytes32) public l1L2TxsDataHashMap;

    mapping(uint32 => mapping(uint48 => bool)) public exitNullifierMap;

    address[] public tokenList;

    mapping(address => uint256) public tokenMap;

    uint256 public feeAddToken;

    ILitexAuctionProtocol public litexAuctionContract;

    mapping(uint32 => bytes) public mapL1TxQueue;

    uint64 public lastL1L2Batch;

    uint32 public nextL1ToForgeQueue;

    uint32 public nextL1FillingQueue;

    uint8 public forgeL1L2BatchTimeout;

    address public tokenLXT;

    event L1UserTxEvent(
        uint32 indexed queueIndex,
        uint8 indexed position, // Position inside the queue where the TX resides
        bytes l1UserTx
    );

    event AddToken(address indexed tokenAddress, uint32 tokenID);

    event ForgeBatch(uint32 indexed batchNum, uint16 l1UserTxsLen);

    event UpdateForgeL1L2BatchTimeout(uint8 newForgeL1L2BatchTimeout);

    event UpdateFeeAddToken(uint256 newFeeAddToken);

    event WithdrawEvent(
        uint48 indexed idx,
        uint32 indexed numExitRoot,
        bool indexed instantWithdraw
    );

    event InitializeLitexEvent(
        uint8 forgeL1L2BatchTimeout,
        uint256 feeAddToken,
        uint64 withdrawalDelay
    );

    event litexV2();

    function updateVerifiers() external {
        require(
            msg.sender == address(0xb6D3f1056c015962fA66A4020E50522B58292D1E),
            "Litex::updateVerifiers ONLY_DEPLOYER"
        );
        require(
            rollupVerifiers[0].maxTx == 344, // Old verifier 344 tx
            "Litex::updateVerifiers VERIFIERS_ALREADY_UPDATED"
        );
        rollupVerifiers[0] = VerifierRollup({
            verifierInterface: VerifierRollupInterface(
                address(0x3DAa0B2a994b1BC60dB9e312aD0a8d87a1Bb16D2) // New verifier 400 tx
            ),
            maxTx: 400,
            nLevels: 32
        });

        rollupVerifiers[1] = VerifierRollup({
            verifierInterface: VerifierRollupInterface(
                address(0x1DC4b451DFcD0e848881eDE8c7A99978F00b1342) // New verifier 2048 tx
            ),
            maxTx: 2048,
            nLevels: 32
        });

        withdrawVerifier = VerifierWithdrawInterface(
            0x4464A1E499cf5443541da6728871af1D5C4920ca
        );
        emit litexV2();
    }

    function initializeLitex(
        address[] memory _verifiers,
        uint256[] memory _verifiersParams,
        address _withdrawVerifier,
        address _litexAuctionContract,
        address _tokenLXT,
        uint8 _forgeL1L2BatchTimeout,
        uint256 _feeAddToken,
        address _poseidon2Elements,
        address _poseidon3Elements,
        address _poseidon4Elements,
        address _litexGovernanceAddress,
        uint64 _withdrawalDelay,
        address _withdrawDelayerContract
    ) external initializer {
        require(
            _litexAuctionContract != address(0) &&
                _withdrawDelayerContract != address(0),
            "Litex::initializeLitex ADDRESS_0_NOT_VALID"
        );

        _initializeVerifiers(_verifiers, _verifiersParams);
        withdrawVerifier = VerifierWithdrawInterface(_withdrawVerifier);
        litexAuctionContract = ILitexAuctionProtocol(_litexAuctionContract);
        tokenLXT = _tokenLXT;
        forgeL1L2BatchTimeout = _forgeL1L2BatchTimeout;
        feeAddToken = _feeAddToken;

        lastIdx = _RESERVED_IDX;
        nextL1FillingQueue = 1;
        tokenList.push(address(0)); // Token 0 is ETH

        _initializeHelpers(
            _poseidon2Elements,
            _poseidon3Elements,
            _poseidon4Elements
        );
        _initializeWithdraw(
            _litexGovernanceAddress,
            _withdrawalDelay,
            _withdrawDelayerContract
        );
        emit InitializeLitexEvent(
            _forgeL1L2BatchTimeout,
            _feeAddToken,
            _withdrawalDelay
        );
    }


    function forgeBatch(
        uint48 newLastIdx,
        uint256 newStRoot,
        uint256 newExitRoot,
        bytes calldata encodedL1CoordinatorTx,
        bytes calldata l1L2TxsData,
        bytes calldata feeIdxCoordinator,
        uint8 verifierIdx,
        bool l1Batch,
        uint256[2] calldata proofA,
        uint256[2][2] calldata proofB,
        uint256[2] calldata proofC
    ) external virtual {
        require(
            msg.sender == tx.origin,
            "Litex::forgeBatch: INTENAL_TX_NOT_ALLOWED"
        );

        require(
            litexAuctionContract.canForge(msg.sender, block.number) == true,
            "Litex::forgeBatch: AUCTION_DENIED"
        );

        if (!l1Batch) {
            require(
                block.number < (lastL1L2Batch + forgeL1L2BatchTimeout), // No overflow since forgeL1L2BatchTimeout is an uint8
                "Litex::forgeBatch: L1L2BATCH_REQUIRED"
            );
        }

        uint256 input = _constructCircuitInput(
            newLastIdx,
            newStRoot,
            newExitRoot,
            l1Batch,
            verifierIdx
        );

        require(
            rollupVerifiers[verifierIdx].verifierInterface.verifyProof(
                proofA,
                proofB,
                proofC,
                [input]
            ),
            "Litex::forgeBatch: INVALID_PROOF"
        );

        lastForgedBatch++;
        lastIdx = newLastIdx;
        stateRootMap[lastForgedBatch] = newStRoot;
        exitRootsMap[lastForgedBatch] = newExitRoot;
        l1L2TxsDataHashMap[lastForgedBatch] = sha256(l1L2TxsData);

        uint16 l1UserTxsLen;
        if (l1Batch) {
            lastL1L2Batch = uint64(block.number);
            l1UserTxsLen = _clearQueue();
        }

        litexAuctionContract.forge(msg.sender);

        emit ForgeBatch(lastForgedBatch, l1UserTxsLen);
    }



    function addL1Transaction(
        uint256 babyPubKey,
        uint48 fromIdx,
        uint40 loadAmountF,
        uint40 amountF,
        uint32 tokenID,
        uint48 toIdx,
        bytes calldata permit
    ) external payable {
        require(
            tokenID < tokenList.length,
            "Litex::addL1Transaction: TOKEN_NOT_REGISTERED"
        );

        uint256 loadAmount = _float2Fix(loadAmountF);
        require(
            loadAmount < _LIMIT_LOAD_AMOUNT,
            "Litex::addL1Transaction: LOADAMOUNT_EXCEED_LIMIT"
        );

        if (loadAmount > 0) {
            if (tokenID == 0) {
                require(
                    loadAmount == msg.value,
                    "Litex::addL1Transaction: LOADAMOUNT_ETH_DOES_NOT_MATCH"
                );
            } else {
                require(
                    msg.value == 0,
                    "Litex::addL1Transaction: MSG_VALUE_NOT_EQUAL_0"
                );
                if (permit.length != 0) {
                    _permit(tokenList[tokenID], loadAmount, permit);
                }
                uint256 prevBalance = IERC20(tokenList[tokenID]).balanceOf(
                    address(this)
                );
                _safeTransferFrom(
                    tokenList[tokenID],
                    msg.sender,
                    address(this),
                    loadAmount
                );
                uint256 postBalance = IERC20(tokenList[tokenID]).balanceOf(
                    address(this)
                );
                require(
                    postBalance - prevBalance == loadAmount,
                    "Litex::addL1Transaction: LOADAMOUNT_ERC20_DOES_NOT_MATCH"
                );
            }
        }

        _addL1Transaction(
            msg.sender,
            babyPubKey,
            fromIdx,
            loadAmountF,
            amountF,
            tokenID,
            toIdx
        );
    }

    function _addL1Transaction(
        address ethAddress,
        uint256 babyPubKey,
        uint48 fromIdx,
        uint40 loadAmountF,
        uint40 amountF,
        uint32 tokenID,
        uint48 toIdx
    ) internal {
        uint256 amount = _float2Fix(amountF);
        require(
            amount < _LIMIT_L2TRANSFER_AMOUNT,
            "Litex::_addL1Transaction: AMOUNT_EXCEED_LIMIT"
        );

        if (toIdx == 0) {
            require(
                (amount == 0),
                "Litex::_addL1Transaction: AMOUNT_MUST_BE_0_IF_NOT_TRANSFER"
            );
        } else {
            if ((toIdx == _EXIT_IDX)) {
                require(
                    (loadAmountF == 0),
                    "Litex::_addL1Transaction: LOADAMOUNT_MUST_BE_0_IF_EXIT"
                );
            } else {
                require(
                    ((toIdx > _RESERVED_IDX) && (toIdx <= lastIdx)),
                    "Litex::_addL1Transaction: INVALID_TOIDX"
                );
            }
        }
        if (fromIdx == 0) {
            require(
                babyPubKey != 0,
                "Litex::_addL1Transaction: INVALID_CREATE_ACCOUNT_WITH_NO_BABYJUB"
            );
        } else {
            require(
                (fromIdx > _RESERVED_IDX) && (fromIdx <= lastIdx),
                "Litex::_addL1Transaction: INVALID_FROMIDX"
            );
            require(
                babyPubKey == 0,
                "Litex::_addL1Transaction: BABYJUB_MUST_BE_0_IF_NOT_CREATE_ACCOUNT"
            );
        }

        _l1QueueAddTx(
            ethAddress,
            babyPubKey,
            fromIdx,
            loadAmountF,
            amountF,
            tokenID,
            toIdx
        );
    }


    function withdrawMerkleProof(
        uint32 tokenID,
        uint192 amount,
        uint256 babyPubKey,
        uint32 numExitRoot,
        uint256[] memory siblings,
        uint48 idx,
        bool instantWithdraw
    ) external {
        if (instantWithdraw) {
            require(
                _processInstantWithdrawal(tokenList[tokenID], amount),
                "Litex::withdrawMerkleProof: INSTANT_WITHDRAW_WASTED_FOR_THIS_USD_RANGE"
            );
        }

        uint256[4] memory arrayState = _buildTreeState(
            tokenID,
            0,
            amount,
            babyPubKey,
            msg.sender
        );
        uint256 stateHash = _hash4Elements(arrayState);
        uint256 exitRoot = exitRootsMap[numExitRoot];
        require(
            exitNullifierMap[numExitRoot][idx] == false,
            "Litex::withdrawMerkleProof: WITHDRAW_ALREADY_DONE"
        );
        require(
            _smtVerifier(exitRoot, siblings, idx, stateHash) == true,
            "Litex::withdrawMerkleProof: SMT_PROOF_INVALID"
        );

        exitNullifierMap[numExitRoot][idx] = true;

        _withdrawFunds(amount, tokenID, instantWithdraw);

        emit WithdrawEvent(idx, numExitRoot, instantWithdraw);
    }

    function withdrawCircuit(
        uint256[2] calldata proofA,
        uint256[2][2] calldata proofB,
        uint256[2] calldata proofC,
        uint32 tokenID,
        uint192 amount,
        uint32 numExitRoot,
        uint48 idx,
        bool instantWithdraw
    ) external {
        if (instantWithdraw) {
            require(
                _processInstantWithdrawal(tokenList[tokenID], amount),
                "Litex::withdrawCircuit: INSTANT_WITHDRAW_WASTED_FOR_THIS_USD_RANGE"
            );
        }
        require(
            exitNullifierMap[numExitRoot][idx] == false,
            "Litex::withdrawCircuit: WITHDRAW_ALREADY_DONE"
        );

        uint256 exitRoot = exitRootsMap[numExitRoot];

        uint256 input = uint256(
            sha256(abi.encodePacked(exitRoot, msg.sender, tokenID, amount, idx))
        ) % _RFIELD;
        require(
            withdrawVerifier.verifyProof(proofA, proofB, proofC, [input]) ==
                true,
            "Litex::withdrawCircuit: INVALID_ZK_PROOF"
        );

        exitNullifierMap[numExitRoot][idx] = true;

        _withdrawFunds(amount, tokenID, instantWithdraw);

        emit WithdrawEvent(idx, numExitRoot, instantWithdraw);
    }

    function updateForgeL1L2BatchTimeout(uint8 newForgeL1L2BatchTimeout)
        external
        onlyGovernance
    {
        require(
            newForgeL1L2BatchTimeout <= ABSOLUTE_MAX_L1L2BATCHTIMEOUT,
            "Litex::updateForgeL1L2BatchTimeout: MAX_FORGETIMEOUT_EXCEED"
        );
        forgeL1L2BatchTimeout = newForgeL1L2BatchTimeout;
        emit UpdateForgeL1L2BatchTimeout(newForgeL1L2BatchTimeout);
    }

    function updateFeeAddToken(uint256 newFeeAddToken) external onlyGovernance {
        feeAddToken = newFeeAddToken;
        emit UpdateFeeAddToken(newFeeAddToken);
    }


    function registerTokensCount() public view returns (uint256) {
        return tokenList.length;
    }

    function rollupVerifiersLength() public view returns (uint256) {
        return rollupVerifiers.length;
    }


    function addToken(address tokenAddress, bytes calldata permit) public {
        require(
            IERC20(tokenAddress).totalSupply() > 0,
            "Litex::addToken: TOTAL_SUPPLY_ZERO"
        );
        uint256 currentTokens = tokenList.length;
        require(
            currentTokens < _LIMIT_TOKENS,
            "Litex::addToken: TOKEN_LIST_FULL"
        );
        require(
            tokenAddress != address(0),
            "Litex::addToken: ADDRESS_0_INVALID"
        );
        require(tokenMap[tokenAddress] == 0, "Litex::addToken: ALREADY_ADDED");

        if (msg.sender != litexGovernanceAddress) {
            if (permit.length != 0) {
                _permit(tokenLXT, feeAddToken, permit);
            }
            _safeTransferFrom(
                tokenLXT,
                msg.sender,
                litexGovernanceAddress,
                feeAddToken
            );
        }

        tokenList.push(tokenAddress);
        tokenMap[tokenAddress] = currentTokens;

        emit AddToken(tokenAddress, uint32(currentTokens));
    }

    function _initializeVerifiers(
        address[] memory _verifiers,
        uint256[] memory _verifiersParams
    ) internal {
        for (uint256 i = 0; i < _verifiers.length; i++) {
            rollupVerifiers.push(
                VerifierRollup({
                    verifierInterface: VerifierRollupInterface(_verifiers[i]),
                    maxTx: (_verifiersParams[i] << 8) >> 8,
                    nLevels: _verifiersParams[i] >> (256 - 8)
                })
            );
        }
    }

    function _l1QueueAddTx(
        address ethAddress,
        uint256 babyPubKey,
        uint48 fromIdx,
        uint40 loadAmountF,
        uint40 amountF,
        uint32 tokenID,
        uint48 toIdx
    ) internal {
        bytes memory l1Tx = abi.encodePacked(
            ethAddress,
            babyPubKey,
            fromIdx,
            loadAmountF,
            amountF,
            tokenID,
            toIdx
        );

        uint256 currentPosition = mapL1TxQueue[nextL1FillingQueue].length /
            _L1_USER_TOTALBYTES;

        _concatStorage(mapL1TxQueue[nextL1FillingQueue], l1Tx);

        emit L1UserTxEvent(nextL1FillingQueue, uint8(currentPosition), l1Tx);
        if (currentPosition + 1 >= _MAX_L1_USER_TX) {
            nextL1FillingQueue++;
        }
    }

    function _buildL1Data(uint256 ptr, bool l1Batch) internal view {
        uint256 dPtr;
        uint256 dLen;

        (dPtr, dLen) = _getCallData(3);
        uint256 l1CoordinatorLength = dLen / _L1_COORDINATOR_TOTALBYTES;

        uint256 l1UserLength;
        bytes memory l1UserTxQueue;
        if (l1Batch) {
            l1UserTxQueue = mapL1TxQueue[nextL1ToForgeQueue];
            l1UserLength = l1UserTxQueue.length / _L1_USER_TOTALBYTES;
        } else {
            l1UserLength = 0;
        }

        require(
            l1UserLength + l1CoordinatorLength <= _MAX_L1_TX,
            "Litex::_buildL1Data: L1_TX_OVERFLOW"
        );

        if (l1UserLength > 0) {
            assembly {
                let ptrFrom := add(l1UserTxQueue, 0x20)
                let ptrTo := ptr
                ptr := add(ptr, mul(l1UserLength, _L1_USER_TOTALBYTES))
                for {

                } lt(ptrTo, ptr) {
                    ptrTo := add(ptrTo, 32)
                    ptrFrom := add(ptrFrom, 32)
                } {
                    mstore(ptrTo, mload(ptrFrom))
                }
            }
        }

        for (uint256 i = 0; i < l1CoordinatorLength; i++) {
            uint8 v; // L1-Coordinator-Tx bytes[0]
            bytes32 s; // L1-Coordinator-Tx bytes[1:32]
            bytes32 r; // L1-Coordinator-Tx bytes[33:64]
            bytes32 babyPubKey; // L1-Coordinator-Tx bytes[65:96]
            uint256 tokenID; // L1-Coordinator-Tx bytes[97:100]

            assembly {
                v := byte(0, calldataload(dPtr))
                dPtr := add(dPtr, 1)

                s := calldataload(dPtr)
                dPtr := add(dPtr, 32)

                r := calldataload(dPtr)
                dPtr := add(dPtr, 32)

                babyPubKey := calldataload(dPtr)
                dPtr := add(dPtr, 32)

                tokenID := shr(224, calldataload(dPtr)) // 256-32 = 224
                dPtr := add(dPtr, 4)
            }

            require(
                tokenID < tokenList.length,
                "Litex::_buildL1Data: TOKEN_NOT_REGISTERED"
            );

            address ethAddress = _ETH_ADDRESS_INTERNAL_ONLY;

            if (v != 0) {
                ethAddress = _checkSig(babyPubKey, r, s, v);
            }

            assembly {
                mstore(ptr, shl(96, ethAddress)) // 256 - 160 = 96, write ethAddress: bytes[0:19]
                ptr := add(ptr, 20)

                mstore(ptr, babyPubKey) // write babyPubKey: bytes[20:51]
                ptr := add(ptr, 32)

                mstore(ptr, 0) // write zeros
                ptr := add(ptr, 16)

                mstore(ptr, shl(224, tokenID)) // 256 - 32 = 224 write tokenID: bytes[62:65]
                ptr := add(ptr, 4)

                mstore(ptr, 0) // write [6 Bytes] toIdx
                ptr := add(ptr, 6)
            }
        }

        _fillZeros(
            ptr,
            (_MAX_L1_TX - l1UserLength - l1CoordinatorLength) *
                _L1_USER_TOTALBYTES
        );
    }

    function _constructCircuitInput(
        uint48 newLastIdx,
        uint256 newStRoot,
        uint256 newExitRoot,
        bool l1Batch,
        uint8 verifierIdx
    ) internal view returns (uint256) {
        uint256 oldStRoot = stateRootMap[lastForgedBatch];
        uint256 oldLastIdx = lastIdx;
        uint256 dPtr; // Pointer to the calldata parameter data
        uint256 dLen; // Length of the calldata parameter

        uint256 l1L2TxsDataLength = ((rollupVerifiers[verifierIdx].nLevels /
            8) *
            2 +
            5 +
            1) * rollupVerifiers[verifierIdx].maxTx;

        uint256 feeIdxCoordinatorLength = (rollupVerifiers[verifierIdx]
            .nLevels / 8) * 64;

        bytes memory inputBytes;

        uint256 ptr; // Position for writing the bufftr

        assembly {
            let inputBytesLength := add(
                add(_INPUT_SHA_CONSTANT_BYTES, l1L2TxsDataLength),
                feeIdxCoordinatorLength
            )

            inputBytes := mload(0x40)
            mstore(0x40, add(add(inputBytes, 0x40), inputBytesLength))

            mstore(inputBytes, inputBytesLength)

            ptr := add(inputBytes, 32)

            mstore(ptr, shl(208, oldLastIdx)) // 256-48 = 208
            ptr := add(ptr, 6)

            mstore(ptr, shl(208, newLastIdx)) // 256-48 = 208
            ptr := add(ptr, 6)

            mstore(ptr, oldStRoot)
            ptr := add(ptr, 32)

            mstore(ptr, newStRoot)
            ptr := add(ptr, 32)

            mstore(ptr, newExitRoot)
            ptr := add(ptr, 32)
        }

        _buildL1Data(ptr, l1Batch);
        ptr += _MAX_L1_TX * _L1_USER_TOTALBYTES;

        (dPtr, dLen) = _getCallData(4);
        require(
            dLen <= l1L2TxsDataLength,
            "Litex::_constructCircuitInput: L2_TX_OVERFLOW"
        );
        assembly {
            calldatacopy(ptr, dPtr, dLen)
        }
        ptr += dLen;

        _fillZeros(ptr, l1L2TxsDataLength - dLen);
        ptr += l1L2TxsDataLength - dLen;

        (dPtr, dLen) = _getCallData(5);
        require(
            dLen <= feeIdxCoordinatorLength,
            "Litex::_constructCircuitInput: INVALID_FEEIDXCOORDINATOR_LENGTH"
        );
        assembly {
            calldatacopy(ptr, dPtr, dLen)
        }
        ptr += dLen;
        _fillZeros(ptr, feeIdxCoordinatorLength - dLen);
        ptr += feeIdxCoordinatorLength - dLen;

        assembly {
            mstore(ptr, shl(240, chainid())) // 256 - 16 = 240
        }
        ptr += 2;

        uint256 batchNum = lastForgedBatch + 1;

        assembly {
            mstore(ptr, shl(224, batchNum)) // 256 - 32 = 224
        }

        return uint256(sha256(inputBytes)) % _RFIELD;
    }

    function _clearQueue() internal returns (uint16) {
        uint16 l1UserTxsLen = uint16(
            mapL1TxQueue[nextL1ToForgeQueue].length / _L1_USER_TOTALBYTES
        );
        delete mapL1TxQueue[nextL1ToForgeQueue];
        nextL1ToForgeQueue++;
        if (nextL1ToForgeQueue == nextL1FillingQueue) {
            nextL1FillingQueue++;
        }
        return l1UserTxsLen;
    }

    function _withdrawFunds(
        uint192 amount,
        uint32 tokenID,
        bool instantWithdraw
    ) internal {
        if (instantWithdraw) {
            _safeTransfer(tokenList[tokenID], msg.sender, amount);
        } else {
            if (tokenID == 0) {
                withdrawDelayerContract.deposit{value: amount}(
                    msg.sender,
                    address(0),
                    amount
                );
            } else {
                address tokenAddress = tokenList[tokenID];

                _safeApprove(
                    tokenAddress,
                    address(withdrawDelayerContract),
                    amount
                );

                withdrawDelayerContract.deposit(
                    msg.sender,
                    tokenAddress,
                    amount
                );
            }
        }
    }


    function _safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(_APPROVE_SIGNATURE, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Litex::_safeApprove: ERC20_APPROVE_FAILED"
        );
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        if (token == address(0)) {
            (bool success, ) = msg.sender.call{value: value}(new bytes(0));
            require(success, "Litex::_safeTransfer: ETH_TRANSFER_FAILED");
        } else {
            (bool success, bytes memory data) = token.call(
                abi.encodeWithSelector(_TRANSFER_SIGNATURE, to, value)
            );
            require(
                success && (data.length == 0 || abi.decode(data, (bool))),
                "Litex::_safeTransfer: ERC20_TRANSFER_FAILED"
            );
        }
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(_TRANSFER_FROM_SIGNATURE, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Litex::_safeTransferFrom: ERC20_TRANSFERFROM_FAILED"
        );
    }


    function _permit(
        address token,
        uint256 _amount,
        bytes calldata _permitData
    ) internal {
        bytes4 sig = abi.decode(_permitData, (bytes4));
        require(
            sig == _PERMIT_SIGNATURE,
            "LitexAuctionProtocol::_permit: NOT_VALID_CALL"
        );
        (
            address owner,
            address spender,
            uint256 value,
            uint256 deadline,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = abi.decode(
            _permitData[4:],
            (address, address, uint256, uint256, uint8, bytes32, bytes32)
        );
        require(
            owner == msg.sender,
            "Litex::_permit: PERMIT_OWNER_MUST_BE_THE_SENDER"
        );
        require(
            spender == address(this),
            "Litex::_permit: SPENDER_MUST_BE_THIS"
        );
        require(
            value == _amount,
            "Litex::_permit: PERMIT_AMOUNT_DOES_NOT_MATCH"
        );

        address(token).call(
            abi.encodeWithSelector(
                _PERMIT_SIGNATURE,
                owner,
                spender,
                value,
                deadline,
                v,
                r,
                s
            )
        );
    }
}