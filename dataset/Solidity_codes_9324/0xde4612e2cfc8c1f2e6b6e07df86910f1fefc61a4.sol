

pragma solidity ^0.5.2;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.2;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity ^0.5.2;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}


pragma solidity ^0.5.0;

library RLPReader {

    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START  = 0xb8;
    uint8 constant LIST_SHORT_START   = 0xc0;
    uint8 constant LIST_LONG_START    = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint len;
        uint memPtr;
    }

    struct Iterator {
        RLPItem item;   // Item that's being iterated over.
        uint nextPtr;   // Position of the next item in the list.
    }

    function next(Iterator memory self) internal pure returns (RLPItem memory) {

        require(hasNext(self));

        uint ptr = self.nextPtr;
        uint itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    function hasNext(Iterator memory self) internal pure returns (bool) {

        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {

        uint memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {

        require(isList(self));

        uint ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    function rlpLen(RLPItem memory item) internal pure returns (uint) {

        return item.len;
    }

    function payloadLen(RLPItem memory item) internal pure returns (uint) {

        return item.len - _payloadOffset(item.memPtr);
    }

    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {

        require(isList(item));

        uint items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint dataLen;
        for (uint i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr); 
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    function isList(RLPItem memory item) internal pure returns (bool) {

        if (item.len == 0) return false;

        uint8 byte0;
        uint memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START)
            return false;
        return true;
    }


    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {

        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;
        
        uint ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    function toBoolean(RLPItem memory item) internal pure returns (bool) {

        require(item.len == 1);
        uint result;
        uint memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        return result == 0 ? false : true;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {

        require(item.len == 21);

        return address(toUint(item));
    }

    function toUint(RLPItem memory item) internal pure returns (uint) {

        require(item.len > 0 && item.len <= 33);

        uint offset = _payloadOffset(item.memPtr);
        uint len = item.len - offset;

        uint result;
        uint memPtr = item.memPtr + offset;
        assembly {
            result := mload(memPtr)

            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    function toUintStrict(RLPItem memory item) internal pure returns (uint) {

        require(item.len == 33);

        uint result;
        uint memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {

        require(item.len > 0);

        uint offset = _payloadOffset(item.memPtr);
        uint len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }


    function numItems(RLPItem memory item) private pure returns (uint) {

        if (item.len == 0) return 0;

        uint count = 0;
        uint currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
           currPtr = currPtr + _itemLength(currPtr); // skip over an item
           count++;
        }

        return count;
    }

    function _itemLength(uint memPtr) private pure returns (uint) {

        uint itemLen;
        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START)
            itemLen = 1;
        
        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;

        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte
                
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } 

        else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    function _payloadOffset(uint memPtr) private pure returns (uint) {

        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) 
            return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START))
            return 1;
        else if (byte0 < LIST_SHORT_START)  // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        else
            return byte0 - (LIST_LONG_START - 1) + 1;
    }

    function copy(uint src, uint dest, uint len) private pure {

        if (len == 0) return;

        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        uint mask = 256 ** (WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}


pragma solidity ^0.5.2;


library BytesLib {

    function concat(bytes memory _preBytes, bytes memory _postBytes)
        internal
        pure
        returns (bytes memory)
    {

        bytes memory tempBytes;
        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(
                0x40,
                and(
                    add(add(end, iszero(add(length, mload(_preBytes)))), 31),
                    not(31) // Round down to the nearest 32 bytes.
                )
            )
        }
        return tempBytes;
    }

    function slice(bytes memory _bytes, uint256 _start, uint256 _length)
        internal
        pure
        returns (bytes memory)
    {

        require(_bytes.length >= (_start + _length));
        bytes memory tempBytes;
        assembly {
            switch iszero(_length)
                case 0 {
                    tempBytes := mload(0x40)

                    let lengthmod := and(_length, 31)

                    let mc := add(
                        add(tempBytes, lengthmod),
                        mul(0x20, iszero(lengthmod))
                    )
                    let end := add(mc, _length)

                    for {
                        let cc := add(
                            add(
                                add(_bytes, lengthmod),
                                mul(0x20, iszero(lengthmod))
                            ),
                            _start
                        )
                    } lt(mc, end) {
                        mc := add(mc, 0x20)
                        cc := add(cc, 0x20)
                    } {
                        mstore(mc, mload(cc))
                    }

                    mstore(tempBytes, _length)

                    mstore(0x40, and(add(mc, 31), not(31)))
                }
                default {
                    tempBytes := mload(0x40)
                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    function leftPad(bytes memory _bytes) internal pure returns (bytes memory) {

        bytes memory newBytes = new bytes(SafeMath.sub(32, _bytes.length));
        return concat(newBytes, _bytes);
    }

    function toBytes32(bytes memory b) internal pure returns (bytes32) {

        require(b.length >= 32, "Bytes array should atleast be 32 bytes");
        bytes32 out;
        for (uint256 i = 0; i < 32; i++) {
            out |= bytes32(b[i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function toBytes4(bytes memory b) internal pure returns (bytes4 result) {

        assembly {
            result := mload(add(b, 32))
        }
    }

    function fromBytes32(bytes32 x) internal pure returns (bytes memory) {

        bytes memory b = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            b[i] = bytes1(uint8(uint256(x) / (2**(8 * (31 - i)))));
        }
        return b;
    }

    function fromUint(uint256 _num) internal pure returns (bytes memory _ret) {

        _ret = new bytes(32);
        assembly {
            mstore(add(_ret, 32), _num)
        }
    }

    function toUint(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint256)
    {

        require(_bytes.length >= (_start + 32));
        uint256 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }

    function toAddress(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (address)
    {

        require(_bytes.length >= (_start + 20));
        address tempAddress;
        assembly {
            tempAddress := div(
                mload(add(add(_bytes, 0x20), _start)),
                0x1000000000000000000000000
            )
        }

        return tempAddress;
    }
}


pragma solidity ^0.5.2;


library ECVerify {

    function ecrecovery(bytes32 hash, uint[3] memory sig)
        internal
        pure
        returns (address)
    {

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(sig)
            s := mload(add(sig, 32))
            v := byte(31, mload(add(sig, 64)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0x0);
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return address(0x0);
        }

        address result = ecrecover(hash, v, r, s);

        require(result != address(0x0));

        return result;
    }

    function ecrecovery(bytes32 hash, bytes memory sig)
        internal
        pure
        returns (address)
    {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65) {
            return address(0x0);
        }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := and(mload(add(sig, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return address(0x0);
        }

        address result = ecrecover(hash, v, r, s);

        require(result != address(0x0));

        return result;
    }

    function ecrecovery(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (address)
    {

        address result = ecrecover(hash, v, r, s);

        require(result != address(0x0), "signature verification failed");

        return result;
    }

    function ecverify(bytes32 hash, bytes memory sig, address signer)
        internal
        pure
        returns (bool)
    {

        return signer == ecrecovery(hash, sig);
    }
}


pragma solidity ^0.5.2;

library Merkle {

    function checkMembership(
        bytes32 leaf,
        uint256 index,
        bytes32 rootHash,
        bytes memory proof
    ) internal pure returns (bool) {

        require(proof.length % 32 == 0, "Invalid proof length");
        uint256 proofHeight = proof.length / 32;
        require(index < 2 ** proofHeight, "Leaf index is too big");

        bytes32 proofElement;
        bytes32 computedHash = leaf;
        for (uint256 i = 32; i <= proof.length; i += 32) {
            assembly {
                proofElement := mload(add(proof, i))
            }

            if (index % 2 == 0) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }

            index = index / 2;
        }
        return computedHash == rootHash;
    }
}


pragma solidity ^0.5.2;

interface IGovernance {

    function update(address target, bytes calldata data) external;

}


pragma solidity ^0.5.2;


contract Governable {

    IGovernance public governance;

    constructor(address _governance) public {
        governance = IGovernance(_governance);
    }

    modifier onlyGovernance() {

        _assertGovernance();
        _;
    }

    function _assertGovernance() private view {

        require(
            msg.sender == address(governance),
            "Only governance contract is authorized"
        );
    }
}


pragma solidity ^0.5.2;

contract Lockable {

    bool public locked;

    modifier onlyWhenUnlocked() {

        _assertUnlocked();
        _;
    }

    function _assertUnlocked() private view {

        require(!locked, "locked");
    }

    function lock() public {

        locked = true;
    }

    function unlock() public {

        locked = false;
    }
}


pragma solidity ^0.5.2;



contract GovernanceLockable is Lockable, Governable {

    constructor(address governance) public Governable(governance) {}

    function lock() public onlyGovernance {

        super.lock();
    }

    function unlock() public onlyGovernance {

        super.unlock();
    }
}


pragma solidity ^0.5.2;

contract DelegateProxyForwarder {

    function delegatedFwd(address _dst, bytes memory _calldata) internal {

        assembly {
            let result := delegatecall(
                sub(gas, 10000),
                _dst,
                add(_calldata, 0x20),
                mload(_calldata),
                0,
                0
            )
            let size := returndatasize

            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }
    
    function isContract(address _target) internal view returns (bool) {

        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly {
            size := extcodesize(_target)
        }
        return size > 0;
    }
}


pragma solidity ^0.5.2;

contract IWithdrawManager {

    function createExitQueue(address token) external;


    function verifyInclusion(
        bytes calldata data,
        uint8 offset,
        bool verifyTxInclusion
    ) external view returns (uint256 age);


    function addExitToQueue(
        address exitor,
        address childToken,
        address rootToken,
        uint256 exitAmountOrTokenId,
        bytes32 txHash,
        bool isRegularExit,
        uint256 priority
    ) external;


    function addInput(
        uint256 exitId,
        uint256 age,
        address utxoOwner,
        address token
    ) external;


    function challengeExit(
        uint256 exitId,
        uint256 inputId,
        bytes calldata challengeData,
        address adjudicatorPredicate
    ) external;

}


pragma solidity ^0.5.2;




contract Registry is Governable {

    bytes32 private constant WETH_TOKEN = keccak256("wethToken");
    bytes32 private constant DEPOSIT_MANAGER = keccak256("depositManager");
    bytes32 private constant STAKE_MANAGER = keccak256("stakeManager");
    bytes32 private constant VALIDATOR_SHARE = keccak256("validatorShare");
    bytes32 private constant WITHDRAW_MANAGER = keccak256("withdrawManager");
    bytes32 private constant CHILD_CHAIN = keccak256("childChain");
    bytes32 private constant STATE_SENDER = keccak256("stateSender");
    bytes32 private constant SLASHING_MANAGER = keccak256("slashingManager");

    address public erc20Predicate;
    address public erc721Predicate;

    mapping(bytes32 => address) public contractMap;
    mapping(address => address) public rootToChildToken;
    mapping(address => address) public childToRootToken;
    mapping(address => bool) public proofValidatorContracts;
    mapping(address => bool) public isERC721;

    enum Type {Invalid, ERC20, ERC721, Custom}
    struct Predicate {
        Type _type;
    }
    mapping(address => Predicate) public predicates;

    event TokenMapped(address indexed rootToken, address indexed childToken);
    event ProofValidatorAdded(address indexed validator, address indexed from);
    event ProofValidatorRemoved(address indexed validator, address indexed from);
    event PredicateAdded(address indexed predicate, address indexed from);
    event PredicateRemoved(address indexed predicate, address indexed from);
    event ContractMapUpdated(bytes32 indexed key, address indexed previousContract, address indexed newContract);

    constructor(address _governance) public Governable(_governance) {}

    function updateContractMap(bytes32 _key, address _address) external onlyGovernance {

        emit ContractMapUpdated(_key, contractMap[_key], _address);
        contractMap[_key] = _address;
    }

    function mapToken(
        address _rootToken,
        address _childToken,
        bool _isERC721
    ) external onlyGovernance {

        require(_rootToken != address(0x0) && _childToken != address(0x0), "INVALID_TOKEN_ADDRESS");
        rootToChildToken[_rootToken] = _childToken;
        childToRootToken[_childToken] = _rootToken;
        isERC721[_rootToken] = _isERC721;
        IWithdrawManager(contractMap[WITHDRAW_MANAGER]).createExitQueue(_rootToken);
        emit TokenMapped(_rootToken, _childToken);
    }

    function addErc20Predicate(address predicate) public onlyGovernance {

        require(predicate != address(0x0), "Can not add null address as predicate");
        erc20Predicate = predicate;
        addPredicate(predicate, Type.ERC20);
    }

    function addErc721Predicate(address predicate) public onlyGovernance {

        erc721Predicate = predicate;
        addPredicate(predicate, Type.ERC721);
    }

    function addPredicate(address predicate, Type _type) public onlyGovernance {

        require(predicates[predicate]._type == Type.Invalid, "Predicate already added");
        predicates[predicate]._type = _type;
        emit PredicateAdded(predicate, msg.sender);
    }

    function removePredicate(address predicate) public onlyGovernance {

        require(predicates[predicate]._type != Type.Invalid, "Predicate does not exist");
        delete predicates[predicate];
        emit PredicateRemoved(predicate, msg.sender);
    }

    function getValidatorShareAddress() public view returns (address) {

        return contractMap[VALIDATOR_SHARE];
    }

    function getWethTokenAddress() public view returns (address) {

        return contractMap[WETH_TOKEN];
    }

    function getDepositManagerAddress() public view returns (address) {

        return contractMap[DEPOSIT_MANAGER];
    }

    function getStakeManagerAddress() public view returns (address) {

        return contractMap[STAKE_MANAGER];
    }

    function getSlashingManagerAddress() public view returns (address) {

        return contractMap[SLASHING_MANAGER];
    }

    function getWithdrawManagerAddress() public view returns (address) {

        return contractMap[WITHDRAW_MANAGER];
    }

    function getChildChainAndStateSender() public view returns (address, address) {

        return (contractMap[CHILD_CHAIN], contractMap[STATE_SENDER]);
    }

    function isTokenMapped(address _token) public view returns (bool) {

        return rootToChildToken[_token] != address(0x0);
    }

    function isTokenMappedAndIsErc721(address _token) public view returns (bool) {

        require(isTokenMapped(_token), "TOKEN_NOT_MAPPED");
        return isERC721[_token];
    }

    function isTokenMappedAndGetPredicate(address _token) public view returns (address) {

        if (isTokenMappedAndIsErc721(_token)) {
            return erc721Predicate;
        }
        return erc20Predicate;
    }

    function isChildTokenErc721(address childToken) public view returns (bool) {

        address rootToken = childToRootToken[childToken];
        require(rootToken != address(0x0), "Child token is not mapped");
        return isERC721[rootToken];
    }
}


pragma solidity 0.5.17;

contract IStakeManager {

    function startAuction(
        uint256 validatorId,
        uint256 amount,
        bool acceptDelegation,
        bytes calldata signerPubkey
    ) external;


    function confirmAuctionBid(uint256 validatorId, uint256 heimdallFee) external;


    function transferFunds(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external returns (bool);


    function delegationDeposit(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external returns (bool);


    function unstake(uint256 validatorId) external;


    function totalStakedFor(address addr) external view returns (uint256);


    function stakeFor(
        address user,
        uint256 amount,
        uint256 heimdallFee,
        bool acceptDelegation,
        bytes memory signerPubkey
    ) public;


    function checkSignatures(
        uint256 blockInterval,
        bytes32 voteHash,
        bytes32 stateRoot,
        address proposer,
        uint[3][] calldata sigs
    ) external returns (uint256);


    function updateValidatorState(uint256 validatorId, int256 amount) public;


    function ownerOf(uint256 tokenId) public view returns (address);


    function slash(bytes calldata slashingInfoList) external returns (uint256);


    function validatorStake(uint256 validatorId) public view returns (uint256);


    function epoch() public view returns (uint256);


    function getRegistry() public view returns (address);


    function withdrawalDelay() public view returns (uint256);


    function delegatedAmount(uint256 validatorId) public view returns(uint256);


    function decreaseValidatorDelegatedAmount(uint256 validatorId, uint256 amount) public;


    function withdrawDelegatorsReward(uint256 validatorId) public returns(uint256);


    function delegatorsReward(uint256 validatorId) public view returns(uint256);


    function dethroneAndStake(
        address auctionUser,
        uint256 heimdallFee,
        uint256 validatorId,
        uint256 auctionAmount,
        bool acceptDelegation,
        bytes calldata signerPubkey
    ) external;

}


pragma solidity 0.5.17;

contract IValidatorShare {

    function withdrawRewards() public;


    function unstakeClaimTokens() public;


    function getLiquidRewards(address user) public view returns (uint256);

    
    function owner() public view returns (address);


    function restake() public returns(uint256, uint256);


    function unlock() external;


    function lock() external;


    function drain(
        address token,
        address payable destination,
        uint256 amount
    ) external;


    function slash(uint256 valPow, uint256 delegatedAmount, uint256 totalAmountToSlash) external returns (uint256);


    function updateDelegation(bool delegation) external;


    function migrateOut(address user, uint256 amount) external;


    function migrateIn(address user, uint256 amount) external;

}


pragma solidity ^0.5.2;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}


pragma solidity ^0.5.2;


contract ERC20NonTradable is ERC20 {

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {

        revert("disabled");
    }
}


pragma solidity ^0.5.2;

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

        require(isOwner());
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

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.2;





contract IStakeManagerLocal {

    enum Status {Inactive, Active, Locked, Unstaked}

    struct Validator {
        uint256 amount;
        uint256 reward;
        uint256 activationEpoch;
        uint256 deactivationEpoch;
        uint256 jailTime;
        address signer;
        address contractAddress;
        Status status;
    }

    mapping(uint256 => Validator) public validators;
    bytes32 public accountStateRoot;
    uint256 public activeAmount; // delegation amount from validator contract
    uint256 public validatorRewards;

    function currentValidatorSetTotalStake() public view returns (uint256);


    function signerToValidator(address validatorAddress)
        public
        view
        returns (uint256);


    function isValidator(uint256 validatorId) public view returns (bool);

}

contract StakingInfo is Ownable {

    using SafeMath for uint256;
    mapping(uint256 => uint256) public validatorNonce;

    event Staked(
        address indexed signer,
        uint256 indexed validatorId,
        uint256 nonce,
        uint256 indexed activationEpoch,
        uint256 amount,
        uint256 total,
        bytes signerPubkey
    );

    event Unstaked(
        address indexed user,
        uint256 indexed validatorId,
        uint256 amount,
        uint256 total
    );

    event UnstakeInit(
        address indexed user,
        uint256 indexed validatorId,
        uint256 nonce,
        uint256 deactivationEpoch,
        uint256 indexed amount
    );

    event SignerChange(
        uint256 indexed validatorId,
        uint256 nonce,
        address indexed oldSigner,
        address indexed newSigner,
        bytes signerPubkey
    );
    event Restaked(uint256 indexed validatorId, uint256 amount, uint256 total);
    event Jailed(
        uint256 indexed validatorId,
        uint256 indexed exitEpoch,
        address indexed signer
    );
    event UnJailed(uint256 indexed validatorId, address indexed signer);
    event Slashed(uint256 indexed nonce, uint256 indexed amount);
    event ThresholdChange(uint256 newThreshold, uint256 oldThreshold);
    event DynastyValueChange(uint256 newDynasty, uint256 oldDynasty);
    event ProposerBonusChange(
        uint256 newProposerBonus,
        uint256 oldProposerBonus
    );

    event RewardUpdate(uint256 newReward, uint256 oldReward);

    event StakeUpdate(
        uint256 indexed validatorId,
        uint256 indexed nonce,
        uint256 indexed newAmount
    );
    event ClaimRewards(
        uint256 indexed validatorId,
        uint256 indexed amount,
        uint256 indexed totalAmount
    );
    event StartAuction(
        uint256 indexed validatorId,
        uint256 indexed amount,
        uint256 indexed auctionAmount
    );
    event ConfirmAuction(
        uint256 indexed newValidatorId,
        uint256 indexed oldValidatorId,
        uint256 indexed amount
    );
    event TopUpFee(address indexed user, uint256 indexed fee);
    event ClaimFee(address indexed user, uint256 indexed fee);
    event ShareMinted(
        uint256 indexed validatorId,
        address indexed user,
        uint256 indexed amount,
        uint256 tokens
    );
    event ShareBurned(
        uint256 indexed validatorId,
        address indexed user,
        uint256 indexed amount,
        uint256 tokens
    );
    event DelegatorClaimedRewards(
        uint256 indexed validatorId,
        address indexed user,
        uint256 indexed rewards
    );
    event DelegatorRestaked(
        uint256 indexed validatorId,
        address indexed user,
        uint256 indexed totalStaked
    );
    event DelegatorUnstaked(
        uint256 indexed validatorId,
        address indexed user,
        uint256 amount
    );
    event UpdateCommissionRate(
        uint256 indexed validatorId,
        uint256 indexed newCommissionRate,
        uint256 indexed oldCommissionRate
    );

    Registry public registry;

    modifier onlyValidatorContract(uint256 validatorId) {

        address _contract;
        (, , , , , , _contract, ) = IStakeManagerLocal(
            registry.getStakeManagerAddress()
        )
            .validators(validatorId);
        require(_contract == msg.sender,
        "Invalid sender, not validator");
        _;
    }

    modifier StakeManagerOrValidatorContract(uint256 validatorId) {

        address _contract;
        address _stakeManager = registry.getStakeManagerAddress();
        (, , , , , , _contract, ) = IStakeManagerLocal(_stakeManager).validators(
            validatorId
        );
        require(_contract == msg.sender || _stakeManager == msg.sender,
        "Invalid sender, not stake manager or validator contract");
        _;
    }

    modifier onlyStakeManager() {

        require(registry.getStakeManagerAddress() == msg.sender,
        "Invalid sender, not stake manager");
        _;
    }
    modifier onlySlashingManager() {

        require(registry.getSlashingManagerAddress() == msg.sender,
        "Invalid sender, not slashing manager");
        _;
    }

    constructor(address _registry) public {
        registry = Registry(_registry);
    }

    function updateNonce(
        uint256[] calldata validatorIds,
        uint256[] calldata nonces
    ) external onlyOwner {

        require(validatorIds.length == nonces.length, "args length mismatch");

        for (uint256 i = 0; i < validatorIds.length; ++i) {
            validatorNonce[validatorIds[i]] = nonces[i];
        }
    } 

    function logStaked(
        address signer,
        bytes memory signerPubkey,
        uint256 validatorId,
        uint256 activationEpoch,
        uint256 amount,
        uint256 total
    ) public onlyStakeManager {

        validatorNonce[validatorId] = validatorNonce[validatorId].add(1);
        emit Staked(
            signer,
            validatorId,
            validatorNonce[validatorId],
            activationEpoch,
            amount,
            total,
            signerPubkey
        );
    }

    function logUnstaked(
        address user,
        uint256 validatorId,
        uint256 amount,
        uint256 total
    ) public onlyStakeManager {

        emit Unstaked(user, validatorId, amount, total);
    }

    function logUnstakeInit(
        address user,
        uint256 validatorId,
        uint256 deactivationEpoch,
        uint256 amount
    ) public onlyStakeManager {

        validatorNonce[validatorId] = validatorNonce[validatorId].add(1);
        emit UnstakeInit(
            user,
            validatorId,
            validatorNonce[validatorId],
            deactivationEpoch,
            amount
        );
    }

    function logSignerChange(
        uint256 validatorId,
        address oldSigner,
        address newSigner,
        bytes memory signerPubkey
    ) public onlyStakeManager {

        validatorNonce[validatorId] = validatorNonce[validatorId].add(1);
        emit SignerChange(
            validatorId,
            validatorNonce[validatorId],
            oldSigner,
            newSigner,
            signerPubkey
        );
    }

    function logRestaked(uint256 validatorId, uint256 amount, uint256 total)
        public
        onlyStakeManager
    {

        emit Restaked(validatorId, amount, total);
    }

    function logJailed(uint256 validatorId, uint256 exitEpoch, address signer)
        public
        onlyStakeManager
    {

        emit Jailed(validatorId, exitEpoch, signer);
    }

    function logUnjailed(uint256 validatorId, address signer)
        public
        onlyStakeManager
    {

        emit UnJailed(validatorId, signer);
    }

    function logSlashed(uint256 nonce, uint256 amount)
        public
        onlySlashingManager
    {

        emit Slashed(nonce, amount);
    }

    function logThresholdChange(uint256 newThreshold, uint256 oldThreshold)
        public
        onlyStakeManager
    {

        emit ThresholdChange(newThreshold, oldThreshold);
    }

    function logDynastyValueChange(uint256 newDynasty, uint256 oldDynasty)
        public
        onlyStakeManager
    {

        emit DynastyValueChange(newDynasty, oldDynasty);
    }

    function logProposerBonusChange(
        uint256 newProposerBonus,
        uint256 oldProposerBonus
    ) public onlyStakeManager {

        emit ProposerBonusChange(newProposerBonus, oldProposerBonus);
    }

    function logRewardUpdate(uint256 newReward, uint256 oldReward)
        public
        onlyStakeManager
    {

        emit RewardUpdate(newReward, oldReward);
    }

    function logStakeUpdate(uint256 validatorId)
        public
        StakeManagerOrValidatorContract(validatorId)
    {

        validatorNonce[validatorId] = validatorNonce[validatorId].add(1);
        emit StakeUpdate(
            validatorId,
            validatorNonce[validatorId],
            totalValidatorStake(validatorId)
        );
    }

    function logClaimRewards(
        uint256 validatorId,
        uint256 amount,
        uint256 totalAmount
    ) public onlyStakeManager {

        emit ClaimRewards(validatorId, amount, totalAmount);
    }

    function logStartAuction(
        uint256 validatorId,
        uint256 amount,
        uint256 auctionAmount
    ) public onlyStakeManager {

        emit StartAuction(validatorId, amount, auctionAmount);
    }

    function logConfirmAuction(
        uint256 newValidatorId,
        uint256 oldValidatorId,
        uint256 amount
    ) public onlyStakeManager {

        emit ConfirmAuction(newValidatorId, oldValidatorId, amount);
    }

    function logTopUpFee(address user, uint256 fee) public onlyStakeManager {

        emit TopUpFee(user, fee);
    }

    function logClaimFee(address user, uint256 fee) public onlyStakeManager {

        emit ClaimFee(user, fee);
    }

    function getStakerDetails(uint256 validatorId)
        public
        view
        returns (
            uint256 amount,
            uint256 reward,
            uint256 activationEpoch,
            uint256 deactivationEpoch,
            address signer,
            uint256 _status
        )
    {

        IStakeManagerLocal stakeManager = IStakeManagerLocal(
            registry.getStakeManagerAddress()
        );
        address _contract;
        IStakeManagerLocal.Status status;
        (
            amount,
            reward,
            activationEpoch,
            deactivationEpoch,
            ,
            signer,
            _contract,
            status
        ) = stakeManager.validators(validatorId);
        _status = uint256(status);
        if (_contract != address(0x0)) {
            reward += IStakeManagerLocal(_contract).validatorRewards();
        }
    }

    function totalValidatorStake(uint256 validatorId)
        public
        view
        returns (uint256 validatorStake)
    {

        address contractAddress;
        (validatorStake, , , , , , contractAddress, ) = IStakeManagerLocal(
            registry.getStakeManagerAddress()
        )
            .validators(validatorId);
        if (contractAddress != address(0x0)) {
            validatorStake += IStakeManagerLocal(contractAddress).activeAmount();
        }
    }

    function getAccountStateRoot()
        public
        view
        returns (bytes32 accountStateRoot)
    {

        accountStateRoot = IStakeManagerLocal(registry.getStakeManagerAddress())
            .accountStateRoot();
    }

    function getValidatorContractAddress(uint256 validatorId)
        public
        view
        returns (address ValidatorContract)
    {

        (, , , , , , ValidatorContract, ) = IStakeManagerLocal(
            registry.getStakeManagerAddress()
        )
            .validators(validatorId);
    }

    function logShareMinted(
        uint256 validatorId,
        address user,
        uint256 amount,
        uint256 tokens
    ) public onlyValidatorContract(validatorId) {

        emit ShareMinted(validatorId, user, amount, tokens);
    }

    function logShareBurned(
        uint256 validatorId,
        address user,
        uint256 amount,
        uint256 tokens
    ) public onlyValidatorContract(validatorId) {

        emit ShareBurned(validatorId, user, amount, tokens);
    }

    function logDelegatorClaimRewards(
        uint256 validatorId,
        address user,
        uint256 rewards
    ) public onlyValidatorContract(validatorId) {

        emit DelegatorClaimedRewards(validatorId, user, rewards);
    }

    function logDelegatorRestaked(
        uint256 validatorId,
        address user,
        uint256 totalStaked
    ) public onlyValidatorContract(validatorId) {

        emit DelegatorRestaked(validatorId, user, totalStaked);
    }

    function logDelegatorUnstaked(uint256 validatorId, address user, uint256 amount)
        public
        onlyValidatorContract(validatorId)
    {

        emit DelegatorUnstaked(validatorId, user, amount);
    }

    function logUpdateCommissionRate(
        uint256 validatorId,
        uint256 newCommissionRate,
        uint256 oldCommissionRate
    ) public onlyValidatorContract(validatorId) {

        emit UpdateCommissionRate(
            validatorId,
            newCommissionRate,
            oldCommissionRate
        );
    }
}


pragma solidity ^0.5.2;

contract Initializable {

    bool inited = false;

    modifier initializer() {

        require(!inited, "already inited");
        inited = true;
        
        _;
    }
}


pragma solidity ^0.5.2;



contract IStakeManagerEventsHub {

    struct Validator {
        uint256 amount;
        uint256 reward;
        uint256 activationEpoch;
        uint256 deactivationEpoch;
        uint256 jailTime;
        address signer;
        address contractAddress;
    }

    mapping(uint256 => Validator) public validators;
}

contract EventsHub is Initializable {

    Registry public registry;

    modifier onlyValidatorContract(uint256 validatorId) {

        address _contract;
        (, , , , , , _contract) = IStakeManagerEventsHub(registry.getStakeManagerAddress()).validators(validatorId);
        require(_contract == msg.sender, "not validator");
        _;
    }

    modifier onlyStakeManager() {

        require(registry.getStakeManagerAddress() == msg.sender,
        "Invalid sender, not stake manager");
        _;
    }

    function initialize(Registry _registry) external initializer {

        registry = _registry;
    }

    event ShareBurnedWithId(
        uint256 indexed validatorId,
        address indexed user,
        uint256 indexed amount,
        uint256 tokens,
        uint256 nonce
    );

    function logShareBurnedWithId(
        uint256 validatorId,
        address user,
        uint256 amount,
        uint256 tokens,
        uint256 nonce
    ) public onlyValidatorContract(validatorId) {

        emit ShareBurnedWithId(validatorId, user, amount, tokens, nonce);
    }

    event DelegatorUnstakeWithId(
        uint256 indexed validatorId,
        address indexed user,
        uint256 amount,
        uint256 nonce
    );

    function logDelegatorUnstakedWithId(
        uint256 validatorId,
        address user,
        uint256 amount,
        uint256 nonce
    ) public onlyValidatorContract(validatorId) {

        emit DelegatorUnstakeWithId(validatorId, user, amount, nonce);
    }

    event RewardParams(
        uint256 rewardDecreasePerCheckpoint,
        uint256 maxRewardedCheckpoints,
        uint256 checkpointRewardDelta
    );

    function logRewardParams(
        uint256 rewardDecreasePerCheckpoint,
        uint256 maxRewardedCheckpoints,
        uint256 checkpointRewardDelta
    ) public onlyStakeManager {

        emit RewardParams(rewardDecreasePerCheckpoint, maxRewardedCheckpoints, checkpointRewardDelta);
    }

    event UpdateCommissionRate(
        uint256 indexed validatorId,
        uint256 indexed newCommissionRate,
        uint256 indexed oldCommissionRate
    );

    function logUpdateCommissionRate(
        uint256 validatorId,
        uint256 newCommissionRate,
        uint256 oldCommissionRate
    ) public onlyStakeManager {

        emit UpdateCommissionRate(
            validatorId,
            newCommissionRate,
            oldCommissionRate
        );
    }

    event SharesTransfer(
        uint256 indexed validatorId,
        address indexed from,
        address indexed to,
        uint256 value
    );

    function logSharesTransfer(
        uint256 validatorId,
        address from,
        address to,
        uint256 value
    ) public onlyValidatorContract(validatorId) {

        emit SharesTransfer(validatorId, from, to, value);
    }
}


pragma solidity ^0.5.2;



contract OwnableLockable is Lockable, Ownable {

    function lock() public onlyOwner {

        super.lock();
    }

    function unlock() public onlyOwner {

        super.unlock();
    }
}


pragma solidity 0.5.17;










contract ValidatorShare is IValidatorShare, ERC20NonTradable, OwnableLockable, Initializable {

    struct DelegatorUnbond {
        uint256 shares;
        uint256 withdrawEpoch;
    }

    uint256 constant EXCHANGE_RATE_PRECISION = 100;
    uint256 constant EXCHANGE_RATE_HIGH_PRECISION = 10**29;
    uint256 constant MAX_COMMISION_RATE = 100;
    uint256 constant REWARD_PRECISION = 10**25;

    StakingInfo public stakingLogger;
    IStakeManager public stakeManager;
    uint256 public validatorId;
    uint256 public validatorRewards_deprecated;
    uint256 public commissionRate_deprecated;
    uint256 public lastCommissionUpdate_deprecated;
    uint256 public minAmount;

    uint256 public totalStake_deprecated;
    uint256 public rewardPerShare;
    uint256 public activeAmount;

    bool public delegation;

    uint256 public withdrawPool;
    uint256 public withdrawShares;

    mapping(address => uint256) amountStaked_deprecated; // deprecated, keep for foundation delegators
    mapping(address => DelegatorUnbond) public unbonds;
    mapping(address => uint256) public initalRewardPerShare;

    mapping(address => uint256) public unbondNonces;
    mapping(address => mapping(uint256 => DelegatorUnbond)) public unbonds_new;

    EventsHub public eventsHub;

    function initialize(
        uint256 _validatorId,
        address _stakingLogger,
        address _stakeManager
    ) external initializer {

        validatorId = _validatorId;
        stakingLogger = StakingInfo(_stakingLogger);
        stakeManager = IStakeManager(_stakeManager);
        _transferOwnership(_stakeManager);
        _getOrCacheEventsHub();

        minAmount = 10**18;
        delegation = true;
    }


    function exchangeRate() public view returns (uint256) {

        uint256 totalShares = totalSupply();
        uint256 precision = _getRatePrecision();
        return totalShares == 0 ? precision : stakeManager.delegatedAmount(validatorId).mul(precision).div(totalShares);
    }

    function getTotalStake(address user) public view returns (uint256, uint256) {

        uint256 shares = balanceOf(user);
        uint256 rate = exchangeRate();
        if (shares == 0) {
            return (0, rate);
        }

        return (rate.mul(shares).div(_getRatePrecision()), rate);
    }

    function withdrawExchangeRate() public view returns (uint256) {

        uint256 precision = _getRatePrecision();
        if (validatorId < 8) {
            return precision;
        }

        uint256 _withdrawShares = withdrawShares;
        return _withdrawShares == 0 ? precision : withdrawPool.mul(precision).div(_withdrawShares);
    }

    function getLiquidRewards(address user) public view returns (uint256) {

        return _calculateReward(user, getRewardPerShare());
    }

    function getRewardPerShare() public view returns (uint256) {

        return _calculateRewardPerShareWithRewards(stakeManager.delegatorsReward(validatorId));
    }


    function buyVoucher(uint256 _amount, uint256 _minSharesToMint) public returns(uint256 amountToDeposit) {

        _withdrawAndTransferReward(msg.sender);
        
        amountToDeposit = _buyShares(_amount, _minSharesToMint, msg.sender);
        require(stakeManager.delegationDeposit(validatorId, amountToDeposit, msg.sender), "deposit failed");
        
        return amountToDeposit;
    }

    function restake() public returns(uint256, uint256) {

        address user = msg.sender;
        uint256 liquidReward = _withdrawReward(user);
        uint256 amountRestaked;

        require(liquidReward >= minAmount, "Too small rewards to restake");

        if (liquidReward != 0) {
            amountRestaked = _buyShares(liquidReward, 0, user);

            if (liquidReward > amountRestaked) {
                require(
                    stakeManager.transferFunds(validatorId, liquidReward - amountRestaked, user),
                    "Insufficent rewards"
                );
                stakingLogger.logDelegatorClaimRewards(validatorId, user, liquidReward - amountRestaked);
            }

            (uint256 totalStaked, ) = getTotalStake(user);
            stakingLogger.logDelegatorRestaked(validatorId, user, totalStaked);
        }
        
        return (amountRestaked, liquidReward);
    }

    function sellVoucher(uint256 claimAmount, uint256 maximumSharesToBurn) public {

        (uint256 shares, uint256 _withdrawPoolShare) = _sellVoucher(claimAmount, maximumSharesToBurn);

        DelegatorUnbond memory unbond = unbonds[msg.sender];
        unbond.shares = unbond.shares.add(_withdrawPoolShare);
        unbond.withdrawEpoch = stakeManager.epoch();
        unbonds[msg.sender] = unbond;

        StakingInfo logger = stakingLogger;
        logger.logShareBurned(validatorId, msg.sender, claimAmount, shares);
        logger.logStakeUpdate(validatorId);
    }

    function withdrawRewards() public {

        uint256 rewards = _withdrawAndTransferReward(msg.sender);
        require(rewards >= minAmount, "Too small rewards amount");
    }

    function migrateOut(address user, uint256 amount) external onlyOwner {

        _withdrawAndTransferReward(user);
        (uint256 totalStaked, uint256 rate) = getTotalStake(user);
        require(totalStaked >= amount, "Migrating too much");

        uint256 precision = _getRatePrecision();
        uint256 shares = amount.mul(precision).div(rate);
        _burn(user, shares);

        stakeManager.updateValidatorState(validatorId, -int256(amount));
        activeAmount = activeAmount.sub(amount);

        stakingLogger.logShareBurned(validatorId, user, amount, shares);
        stakingLogger.logStakeUpdate(validatorId);
        stakingLogger.logDelegatorUnstaked(validatorId, user, amount);
    }

    function migrateIn(address user, uint256 amount) external onlyOwner {

        _withdrawAndTransferReward(user);
        _buyShares(amount, 0, user);
    }

    function unstakeClaimTokens() public {

        DelegatorUnbond memory unbond = unbonds[msg.sender];
        uint256 amount = _unstakeClaimTokens(unbond);
        delete unbonds[msg.sender];
        stakingLogger.logDelegatorUnstaked(validatorId, msg.sender, amount);
    }

    function slash(
        uint256 validatorStake,
        uint256 delegatedAmount,
        uint256 totalAmountToSlash
    ) external onlyOwner returns (uint256) {

        uint256 _withdrawPool = withdrawPool;
        uint256 delegationAmount = delegatedAmount.add(_withdrawPool);
        if (delegationAmount == 0) {
            return 0;
        }
        uint256 _amountToSlash = delegationAmount.mul(totalAmountToSlash).div(validatorStake.add(delegationAmount));
        uint256 _amountToSlashWithdrawalPool = _withdrawPool.mul(_amountToSlash).div(delegationAmount);

        uint256 stakeSlashed = _amountToSlash.sub(_amountToSlashWithdrawalPool);
        stakeManager.decreaseValidatorDelegatedAmount(validatorId, stakeSlashed);
        activeAmount = activeAmount.sub(stakeSlashed);

        withdrawPool = withdrawPool.sub(_amountToSlashWithdrawalPool);
        return _amountToSlash;
    }

    function updateDelegation(bool _delegation) external onlyOwner {

        delegation = _delegation;
    }

    function drain(
        address token,
        address payable destination,
        uint256 amount
    ) external onlyOwner {

        if (token == address(0x0)) {
            destination.transfer(amount);
        } else {
            require(ERC20(token).transfer(destination, amount), "Drain failed");
        }
    }


    function sellVoucher_new(uint256 claimAmount, uint256 maximumSharesToBurn) public {

        (uint256 shares, uint256 _withdrawPoolShare) = _sellVoucher(claimAmount, maximumSharesToBurn);

        uint256 unbondNonce = unbondNonces[msg.sender].add(1);

        DelegatorUnbond memory unbond = DelegatorUnbond({
            shares: _withdrawPoolShare,
            withdrawEpoch: stakeManager.epoch()
        });
        unbonds_new[msg.sender][unbondNonce] = unbond;
        unbondNonces[msg.sender] = unbondNonce;

        _getOrCacheEventsHub().logShareBurnedWithId(validatorId, msg.sender, claimAmount, shares, unbondNonce);
        stakingLogger.logStakeUpdate(validatorId);
    }

    function unstakeClaimTokens_new(uint256 unbondNonce) public {

        DelegatorUnbond memory unbond = unbonds_new[msg.sender][unbondNonce];
        uint256 amount = _unstakeClaimTokens(unbond);
        delete unbonds_new[msg.sender][unbondNonce];
        _getOrCacheEventsHub().logDelegatorUnstakedWithId(validatorId, msg.sender, amount, unbondNonce);
    }


    function _getOrCacheEventsHub() private returns(EventsHub) {

        EventsHub _eventsHub = eventsHub;
        if (_eventsHub == EventsHub(0x0)) {
            _eventsHub = EventsHub(Registry(stakeManager.getRegistry()).contractMap(keccak256("eventsHub")));
            eventsHub = _eventsHub;
        }
        return _eventsHub;
    }

    function _sellVoucher(uint256 claimAmount, uint256 maximumSharesToBurn) private returns(uint256, uint256) {

        (uint256 totalStaked, uint256 rate) = getTotalStake(msg.sender);
        require(totalStaked != 0 && totalStaked >= claimAmount, "Too much requested");

        uint256 precision = _getRatePrecision();
        uint256 shares = claimAmount.mul(precision).div(rate);
        require(shares <= maximumSharesToBurn, "too much slippage");

        _withdrawAndTransferReward(msg.sender);

        _burn(msg.sender, shares);
        stakeManager.updateValidatorState(validatorId, -int256(claimAmount));
        activeAmount = activeAmount.sub(claimAmount);

        uint256 _withdrawPoolShare = claimAmount.mul(precision).div(withdrawExchangeRate());
        withdrawPool = withdrawPool.add(claimAmount);
        withdrawShares = withdrawShares.add(_withdrawPoolShare);

        return (shares, _withdrawPoolShare);
    }

    function _unstakeClaimTokens(DelegatorUnbond memory unbond) private returns(uint256) {

        uint256 shares = unbond.shares;
        require(
            unbond.withdrawEpoch.add(stakeManager.withdrawalDelay()) <= stakeManager.epoch() && shares > 0,
            "Incomplete withdrawal period"
        );

        uint256 _amount = withdrawExchangeRate().mul(shares).div(_getRatePrecision());
        withdrawShares = withdrawShares.sub(shares);
        withdrawPool = withdrawPool.sub(_amount);

        require(stakeManager.transferFunds(validatorId, _amount, msg.sender), "Insufficent rewards");

        return _amount;
    }

    function _getRatePrecision() private view returns (uint256) {

        if (validatorId < 8) {
            return EXCHANGE_RATE_PRECISION;
        }

        return EXCHANGE_RATE_HIGH_PRECISION;
    }

    function _calculateRewardPerShareWithRewards(uint256 accumulatedReward) private view returns (uint256) {

        uint256 _rewardPerShare = rewardPerShare;
        if (accumulatedReward != 0) {
            uint256 totalShares = totalSupply();
            
            if (totalShares != 0) {
                _rewardPerShare = _rewardPerShare.add(accumulatedReward.mul(REWARD_PRECISION).div(totalShares));
            }
        }

        return _rewardPerShare;
    }

    function _calculateReward(address user, uint256 _rewardPerShare) private view returns (uint256) {

        uint256 shares = balanceOf(user);
        if (shares == 0) {
            return 0;
        }

        uint256 _initialRewardPerShare = initalRewardPerShare[user];

        if (_initialRewardPerShare == _rewardPerShare) {
            return 0;
        }

        return _rewardPerShare.sub(_initialRewardPerShare).mul(shares).div(REWARD_PRECISION);
    }

    function _withdrawReward(address user) private returns (uint256) {

        uint256 _rewardPerShare = _calculateRewardPerShareWithRewards(
            stakeManager.withdrawDelegatorsReward(validatorId)
        );
        uint256 liquidRewards = _calculateReward(user, _rewardPerShare);
        
        rewardPerShare = _rewardPerShare;
        initalRewardPerShare[user] = _rewardPerShare;
        return liquidRewards;
    }

    function _withdrawAndTransferReward(address user) private returns (uint256) {

        uint256 liquidRewards = _withdrawReward(user);
        if (liquidRewards != 0) {
            require(stakeManager.transferFunds(validatorId, liquidRewards, user), "Insufficent rewards");
            stakingLogger.logDelegatorClaimRewards(validatorId, user, liquidRewards);
        }
        return liquidRewards;
    }

    function _buyShares(
        uint256 _amount,
        uint256 _minSharesToMint,
        address user
    ) private onlyWhenUnlocked returns (uint256) {

        require(delegation, "Delegation is disabled");

        uint256 rate = exchangeRate();
        uint256 precision = _getRatePrecision();
        uint256 shares = _amount.mul(precision).div(rate);
        require(shares >= _minSharesToMint, "Too much slippage");
        require(unbonds[user].shares == 0, "Ongoing exit");

        _mint(user, shares);

        _amount = rate.mul(shares).div(precision);

        stakeManager.updateValidatorState(validatorId, int256(_amount));
        activeAmount = activeAmount.add(_amount);

        StakingInfo logger = stakingLogger;
        logger.logShareMinted(validatorId, user, _amount, shares);
        logger.logStakeUpdate(validatorId);

        return _amount;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {

        _withdrawAndTransferReward(to);
        _withdrawAndTransferReward(from);
        super._transfer(from, to, value);
        _getOrCacheEventsHub().logSharesTransfer(validatorId, from, to, value);
    }
}


pragma solidity ^0.5.2;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.5.2;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);


    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function transferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}


pragma solidity ^0.5.2;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity ^0.5.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


pragma solidity ^0.5.2;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}


pragma solidity ^0.5.2;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}


pragma solidity ^0.5.2;







contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0));
        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0));
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}


pragma solidity ^0.5.2;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}


pragma solidity ^0.5.2;




contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner));
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply());
        return _allTokens[index];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;

    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}


pragma solidity ^0.5.2;


contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}


pragma solidity ^0.5.2;




contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId));
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId));
        _tokenURIs[tokenId] = uri;
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}


pragma solidity ^0.5.2;




contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
    }
}


pragma solidity ^0.5.2;




contract StakingNFT is ERC721Full, Ownable {

    constructor(string memory name, string memory symbol)
        public
        ERC721Full(name, symbol)
    {
    }

    function mint(address to, uint256 tokenId) public onlyOwner {

        require(
            balanceOf(to) == 0,
            "Validators MUST NOT own multiple stake position"
        );
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public onlyOwner {

        _burn(tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(
            balanceOf(to) == 0,
            "Validators MUST NOT own multiple stake position"
        );
        super._transferFrom(from, to, tokenId);
    }
}



pragma solidity ^0.5.2;


interface ERCProxy {

    function proxyType() external pure returns (uint256 proxyTypeId);

    function implementation() external view returns (address codeAddr);

}


pragma solidity ^0.5.2;



contract DelegateProxy is ERCProxy, DelegateProxyForwarder {

    function proxyType() external pure returns (uint256 proxyTypeId) {

        proxyTypeId = 2;
    }

    function implementation() external view returns (address);

}


pragma solidity ^0.5.2;


contract UpgradableProxy is DelegateProxy {

    event ProxyUpdated(address indexed _new, address indexed _old);
    event OwnerUpdate(address _new, address _old);

    bytes32 constant IMPLEMENTATION_SLOT = keccak256("matic.network.proxy.implementation");
    bytes32 constant OWNER_SLOT = keccak256("matic.network.proxy.owner");

    constructor(address _proxyTo) public {
        setOwner(msg.sender);
        setImplementation(_proxyTo);
    }

    function() external payable {
        delegatedFwd(loadImplementation(), msg.data);
    }

    modifier onlyProxyOwner() {

        require(loadOwner() == msg.sender, "NOT_OWNER");
        _;
    }

    function owner() external view returns(address) {

        return loadOwner();
    }

    function loadOwner() internal view returns(address) {

        address _owner;
        bytes32 position = OWNER_SLOT;
        assembly {
            _owner := sload(position)
        }
        return _owner;
    }

    function implementation() external view returns (address) {

        return loadImplementation();
    }

    function loadImplementation() internal view returns(address) {

        address _impl;
        bytes32 position = IMPLEMENTATION_SLOT;
        assembly {
            _impl := sload(position)
        }
        return _impl;
    }

    function transferOwnership(address newOwner) public onlyProxyOwner {

        require(newOwner != address(0), "ZERO_ADDRESS");
        emit OwnerUpdate(newOwner, loadOwner());
        setOwner(newOwner);
    }

    function setOwner(address newOwner) private {

        bytes32 position = OWNER_SLOT;
        assembly {
            sstore(position, newOwner)
        }
    }

    function updateImplementation(address _newProxyTo) public onlyProxyOwner {

        require(_newProxyTo != address(0x0), "INVALID_PROXY_ADDRESS");
        require(isContract(_newProxyTo), "DESTINATION_ADDRESS_IS_NOT_A_CONTRACT");

        emit ProxyUpdated(_newProxyTo, loadImplementation());
        
        setImplementation(_newProxyTo);
    }

    function updateAndCall(address _newProxyTo, bytes memory data) payable public onlyProxyOwner {

        updateImplementation(_newProxyTo);

        (bool success, bytes memory returnData) = address(this).call.value(msg.value)(data);
        require(success, string(returnData));
    }

    function setImplementation(address _newProxyTo) private {

        bytes32 position = IMPLEMENTATION_SLOT;
        assembly {
            sstore(position, _newProxyTo)
        }
    }
}


pragma solidity ^0.5.2;



contract ValidatorShareProxy is UpgradableProxy {

    constructor(address _registry) public UpgradableProxy(_registry) {}

    function loadImplementation() internal view returns (address) {

        return Registry(super.loadImplementation()).getValidatorShareAddress();
    }
}


pragma solidity ^0.5.2;



contract ValidatorShareFactory {

    function create(uint256 validatorId, address loggerAddress, address registry) public returns (address) {

        ValidatorShareProxy proxy = new ValidatorShareProxy(registry);

        proxy.transferOwnership(msg.sender);

        address proxyAddr = address(proxy);
        (bool success, bytes memory data) = proxyAddr.call.gas(gasleft())(
            abi.encodeWithSelector(
                ValidatorShare(proxyAddr).initialize.selector, 
                validatorId, 
                loggerAddress, 
                msg.sender
            )
        );
        require(success, string(data));

        return proxyAddr;
    }
}


pragma solidity ^0.5.2;


contract RootChainable is Ownable {

    address public rootChain;

    event RootChainChanged(
        address indexed previousRootChain,
        address indexed newRootChain
    );

    modifier onlyRootChain() {

        require(msg.sender == rootChain);
        _;
    }

    function changeRootChain(address newRootChain) public onlyOwner {

        require(newRootChain != address(0));
        emit RootChainChanged(rootChain, newRootChain);
        rootChain = newRootChain;
    }
}


pragma solidity 0.5.17;








contract StakeManagerStorage is GovernanceLockable, RootChainable {

    enum Status {Inactive, Active, Locked, Unstaked}

    struct Auction {
        uint256 amount;
        uint256 startEpoch;
        address user;
        bool acceptDelegation;
        bytes signerPubkey;
    }

    struct State {
        uint256 amount;
        uint256 stakerCount;
    }

    struct StateChange {
        int256 amount;
        int256 stakerCount;
    }

    struct Validator {
        uint256 amount;
        uint256 reward;
        uint256 activationEpoch;
        uint256 deactivationEpoch;
        uint256 jailTime;
        address signer;
        address contractAddress;
        Status status;
        uint256 commissionRate;
        uint256 lastCommissionUpdate;
        uint256 delegatorsReward;
        uint256 delegatedAmount;
        uint256 initialRewardPerStake;
    }

    uint256 constant MAX_COMMISION_RATE = 100;
    uint256 constant MAX_PROPOSER_BONUS = 100;
    uint256 constant REWARD_PRECISION = 10**25;
    uint256 internal constant INCORRECT_VALIDATOR_ID = 2**256 - 1;
    uint256 internal constant INITIALIZED_AMOUNT = 1;

    IERC20 public token;
    address public registry;
    StakingInfo public logger;
    StakingNFT public NFTContract;
    ValidatorShareFactory public validatorShareFactory;
    uint256 public WITHDRAWAL_DELAY; // unit: epoch
    uint256 public currentEpoch;

    uint256 public dynasty; // unit: epoch 50 days
    uint256 public CHECKPOINT_REWARD; // update via governance
    uint256 public minDeposit; // in ERC20 token
    uint256 public minHeimdallFee; // in ERC20 token
    uint256 public checkPointBlockInterval;
    uint256 public signerUpdateLimit;

    uint256 public validatorThreshold; //128
    uint256 public totalStaked;
    uint256 public NFTCounter;
    uint256 public totalRewards;
    uint256 public totalRewardsLiquidated;
    uint256 public auctionPeriod; // 1 week in epochs
    uint256 public proposerBonus; // 10 % of total rewards
    bytes32 public accountStateRoot;
    uint256 public replacementCoolDown;
    bool public delegationEnabled;

    mapping(uint256 => Validator) public validators;
    mapping(address => uint256) public signerToValidator;
    State public validatorState;
    mapping(uint256 => StateChange) public validatorStateChanges;

    mapping(address => uint256) public userFeeExit;
    mapping(uint256 => Auction) public validatorAuction;
    mapping(uint256 => uint256) public latestSignerUpdateEpoch;

    uint256 public totalHeimdallFee;
}


pragma solidity 0.5.17;

contract StakeManagerStorageExtension {

    address public eventsHub;
    uint256 public rewardPerStake;
    address public extensionCode;
    address[] public signers;

    uint256 constant CHK_REWARD_PRECISION = 100;
    uint256 public prevBlockInterval;
    uint256 public rewardDecreasePerCheckpoint;
    uint256 public maxRewardedCheckpoints;
    uint256 public checkpointRewardDelta;
}


pragma solidity 0.5.17;












contract StakeManagerExtension is StakeManagerStorage, Initializable, StakeManagerStorageExtension {

    using SafeMath for uint256;

    constructor() public GovernanceLockable(address(0x0)) {}

    function startAuction(
        uint256 validatorId,
        uint256 amount,
        bool _acceptDelegation,
        bytes calldata _signerPubkey
    ) external {

        uint256 currentValidatorAmount = validators[validatorId].amount;

        require(
            validators[validatorId].deactivationEpoch == 0 && currentValidatorAmount != 0,
            "Invalid validator for an auction"
        );
        uint256 senderValidatorId = signerToValidator[msg.sender];
        require(
            NFTContract.balanceOf(msg.sender) == 0 && // existing validators can't bid
                senderValidatorId != INCORRECT_VALIDATOR_ID,
            "Already used address"
        );

        uint256 _currentEpoch = currentEpoch;
        uint256 _replacementCoolDown = replacementCoolDown;
        require(_replacementCoolDown == 0 || _replacementCoolDown <= _currentEpoch, "Cooldown period");

        require(
            (_currentEpoch.sub(validators[validatorId].activationEpoch) % dynasty.add(auctionPeriod)) < auctionPeriod,
            "Invalid auction period"
        );

        uint256 perceivedStake = currentValidatorAmount;
        perceivedStake = perceivedStake.add(validators[validatorId].delegatedAmount);

        Auction storage auction = validatorAuction[validatorId];
        uint256 currentAuctionAmount = auction.amount;

        perceivedStake = Math.max(perceivedStake, currentAuctionAmount);

        require(perceivedStake < amount, "Must bid higher");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        if (currentAuctionAmount != 0) {
            require(token.transfer(auction.user, currentAuctionAmount), "Bid return failed");
        }

        auction.amount = amount;
        auction.user = msg.sender;
        auction.acceptDelegation = _acceptDelegation;
        auction.signerPubkey = _signerPubkey;

        logger.logStartAuction(validatorId, currentValidatorAmount, amount);
    }

    function confirmAuctionBid(
        uint256 validatorId,
        uint256 heimdallFee, /** for new validator */
        IStakeManager stakeManager
    ) external {

        Auction storage auction = validatorAuction[validatorId];
        address auctionUser = auction.user;

        require(
            msg.sender == auctionUser || NFTContract.tokenOfOwnerByIndex(msg.sender, 0) == validatorId,
            "Only bidder can confirm"
        );

        uint256 _currentEpoch = currentEpoch;
        require(
            _currentEpoch.sub(auction.startEpoch) % auctionPeriod.add(dynasty) >= auctionPeriod,
            "Not allowed before auctionPeriod"
        );
        require(auction.user != address(0x0), "Invalid auction");

        uint256 validatorAmount = validators[validatorId].amount;
        uint256 perceivedStake = validatorAmount;
        uint256 auctionAmount = auction.amount;

        perceivedStake = perceivedStake.add(validators[validatorId].delegatedAmount);

        if (perceivedStake >= auctionAmount && validators[validatorId].deactivationEpoch == 0) {
            require(token.transfer(auctionUser, auctionAmount), "Bid return failed");
            auction.startEpoch = _currentEpoch;
            logger.logConfirmAuction(validatorId, validatorId, validatorAmount);
        } else {
            stakeManager.dethroneAndStake(
                auctionUser, 
                heimdallFee,
                validatorId,
                auctionAmount,
                auction.acceptDelegation,
                auction.signerPubkey
            );
        }
        uint256 startEpoch = auction.startEpoch;
        delete validatorAuction[validatorId];
        validatorAuction[validatorId].startEpoch = startEpoch;
    }

    function migrateValidatorsData(uint256 validatorIdFrom, uint256 validatorIdTo) external {       

        for (uint256 i = validatorIdFrom; i < validatorIdTo; ++i) {
            ValidatorShare contractAddress = ValidatorShare(validators[i].contractAddress);
            if (contractAddress != ValidatorShare(0)) {
                validators[i].reward = contractAddress.validatorRewards_deprecated().add(INITIALIZED_AMOUNT);
                validators[i].delegatedAmount = contractAddress.activeAmount();
                validators[i].commissionRate = contractAddress.commissionRate_deprecated();
            } else {
                validators[i].reward = validators[i].reward.add(INITIALIZED_AMOUNT);
            }

            validators[i].delegatorsReward = INITIALIZED_AMOUNT;
        }
    }

    function updateCheckpointRewardParams(
        uint256 _rewardDecreasePerCheckpoint,
        uint256 _maxRewardedCheckpoints,
        uint256 _checkpointRewardDelta
    ) external {

        require(_maxRewardedCheckpoints.mul(_rewardDecreasePerCheckpoint) <= CHK_REWARD_PRECISION);
        require(_checkpointRewardDelta <= CHK_REWARD_PRECISION);

        rewardDecreasePerCheckpoint = _rewardDecreasePerCheckpoint;
        maxRewardedCheckpoints = _maxRewardedCheckpoints;
        checkpointRewardDelta = _checkpointRewardDelta;

        _getOrCacheEventsHub().logRewardParams(_rewardDecreasePerCheckpoint, _maxRewardedCheckpoints, _checkpointRewardDelta);
    }

    function updateCommissionRate(uint256 validatorId, uint256 newCommissionRate) external {

        uint256 _epoch = currentEpoch;
        uint256 _lastCommissionUpdate = validators[validatorId].lastCommissionUpdate;

        require( // withdrawalDelay == dynasty
            (_lastCommissionUpdate.add(WITHDRAWAL_DELAY) <= _epoch) || _lastCommissionUpdate == 0, // For initial setting of commission rate
            "Cooldown"
        );

        require(newCommissionRate <= MAX_COMMISION_RATE, "Incorrect value");
        _getOrCacheEventsHub().logUpdateCommissionRate(validatorId, newCommissionRate, validators[validatorId].commissionRate);
        validators[validatorId].commissionRate = newCommissionRate;
        validators[validatorId].lastCommissionUpdate = _epoch;
    }

    function _getOrCacheEventsHub() private returns(EventsHub) {

        EventsHub _eventsHub = EventsHub(eventsHub);
        if (_eventsHub == EventsHub(0x0)) {
            _eventsHub = EventsHub(Registry(registry).contractMap(keccak256("eventsHub")));
            eventsHub = address(_eventsHub);
        }
        return _eventsHub;
    }
}


pragma solidity 0.5.17;






















contract StakeManager is
    StakeManagerStorage,
    Initializable,
    IStakeManager,
    DelegateProxyForwarder,
    StakeManagerStorageExtension
{

    using SafeMath for uint256;
    using Merkle for bytes32;
    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;

    struct UnsignedValidatorsContext {
        uint256 unsignedValidatorIndex;
        uint256 validatorIndex;
        uint256[] unsignedValidators;
        address[] validators;
        uint256 totalValidators;
    }

    struct UnstakedValidatorsContext {
        uint256 deactivationEpoch;
        uint256[] deactivatedValidators;
        uint256 validatorIndex;
    }

    modifier onlyStaker(uint256 validatorId) {

        _assertStaker(validatorId);
        _;
    }

    function _assertStaker(uint256 validatorId) private view {

        require(NFTContract.ownerOf(validatorId) == msg.sender);
    }

    modifier onlyDelegation(uint256 validatorId) {

        _assertDelegation(validatorId);
        _;
    }

    function _assertDelegation(uint256 validatorId) private view {

        require(validators[validatorId].contractAddress == msg.sender, "Invalid contract address");
    }

    constructor() public GovernanceLockable(address(0x0)) initializer {}

    function initialize(
        address _registry,
        address _rootchain,
        address _token,
        address _NFTContract,
        address _stakingLogger,
        address _validatorShareFactory,
        address _governance,
        address _owner,
        address _extensionCode
    ) external initializer {

        require(isContract(_extensionCode), "auction impl incorrect");
        extensionCode = _extensionCode;
        governance = IGovernance(_governance);
        registry = _registry;
        rootChain = _rootchain;
        token = IERC20(_token);
        NFTContract = StakingNFT(_NFTContract);
        logger = StakingInfo(_stakingLogger);
        validatorShareFactory = ValidatorShareFactory(_validatorShareFactory);
        _transferOwnership(_owner);

        WITHDRAWAL_DELAY = (2**13); // unit: epoch
        currentEpoch = 1;
        dynasty = 886; // unit: epoch 50 days
        CHECKPOINT_REWARD = 20188 * (10**18); // update via governance
        minDeposit = (10**18); // in ERC20 token
        minHeimdallFee = (10**18); // in ERC20 token
        checkPointBlockInterval = 1024;
        signerUpdateLimit = 100;

        validatorThreshold = 7; //128
        NFTCounter = 1;
        auctionPeriod = (2**13) / 4; // 1 week in epochs
        proposerBonus = 10; // 10 % of total rewards
        delegationEnabled = true;
    }

    function isOwner() public view returns (bool) {

        address _owner;
        bytes32 position = keccak256("matic.network.proxy.owner");
        assembly {
            _owner := sload(position)
        }
        return msg.sender == _owner;
    }


    function getRegistry() public view returns (address) {

        return registry;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        return NFTContract.ownerOf(tokenId);
    }

    function epoch() public view returns (uint256) {

        return currentEpoch;
    }

    function withdrawalDelay() public view returns (uint256) {

        return WITHDRAWAL_DELAY;
    }

    function validatorStake(uint256 validatorId) public view returns (uint256) {

        return validators[validatorId].amount;
    }

    function getValidatorId(address user) public view returns (uint256) {

        return NFTContract.tokenOfOwnerByIndex(user, 0);
    }

    function delegatedAmount(uint256 validatorId) public view returns (uint256) {

        return validators[validatorId].delegatedAmount;
    }

    function delegatorsReward(uint256 validatorId) public view returns (uint256) {

        (, uint256 _delegatorsReward) = _evaluateValidatorAndDelegationReward(validatorId);
        return validators[validatorId].delegatorsReward.add(_delegatorsReward).sub(INITIALIZED_AMOUNT);
    }

    function validatorReward(uint256 validatorId) public view returns (uint256) {

        uint256 _validatorReward;
        if (validators[validatorId].deactivationEpoch == 0) {
            (_validatorReward, ) = _evaluateValidatorAndDelegationReward(validatorId);
        }
        return validators[validatorId].reward.add(_validatorReward).sub(INITIALIZED_AMOUNT);
    }

    function currentValidatorSetSize() public view returns (uint256) {

        return validatorState.stakerCount;
    }

    function currentValidatorSetTotalStake() public view returns (uint256) {

        return validatorState.amount;
    }

    function getValidatorContract(uint256 validatorId) public view returns (address) {

        return validators[validatorId].contractAddress;
    }

    function isValidator(uint256 validatorId) public view returns (bool) {

        return
            _isValidator(
                validators[validatorId].status,
                validators[validatorId].amount,
                validators[validatorId].deactivationEpoch,
                currentEpoch
            );
    }


    function setDelegationEnabled(bool enabled) public onlyGovernance {

        delegationEnabled = enabled;
    }

    function forceUnstake(uint256 validatorId) external onlyGovernance {

        _unstake(validatorId, currentEpoch);
    }

    function setCurrentEpoch(uint256 _currentEpoch) external onlyGovernance {

        currentEpoch = _currentEpoch;
    }

    function setStakingToken(address _token) public onlyGovernance {

        require(_token != address(0x0));
        token = IERC20(_token);
    }

    function updateValidatorThreshold(uint256 newThreshold) public onlyGovernance {

        require(newThreshold != 0);
        logger.logThresholdChange(newThreshold, validatorThreshold);
        validatorThreshold = newThreshold;
    }

    function updateCheckPointBlockInterval(uint256 _blocks) public onlyGovernance {

        require(_blocks != 0);
        checkPointBlockInterval = _blocks;
    }

    function updateCheckpointReward(uint256 newReward) public onlyGovernance {

        require(newReward != 0);
        logger.logRewardUpdate(newReward, CHECKPOINT_REWARD);
        CHECKPOINT_REWARD = newReward;
    }

    function updateCheckpointRewardParams(
        uint256 _rewardDecreasePerCheckpoint,
        uint256 _maxRewardedCheckpoints,
        uint256 _checkpointRewardDelta
    ) public onlyGovernance {

        delegatedFwd(
            extensionCode,
            abi.encodeWithSelector(
                StakeManagerExtension(extensionCode).updateCheckpointRewardParams.selector,
                _rewardDecreasePerCheckpoint,
                _maxRewardedCheckpoints,
                _checkpointRewardDelta
            )
        );
    }


    function migrateValidatorsData(uint256 validatorIdFrom, uint256 validatorIdTo) public onlyOwner {

        delegatedFwd(
            extensionCode,
            abi.encodeWithSelector(
                StakeManagerExtension(extensionCode).migrateValidatorsData.selector,
                validatorIdFrom,
                validatorIdTo
            )
        );
    }

    function insertSigners(address[] memory _signers) public onlyOwner {

        signers = _signers;
    }

    function updateValidatorContractAddress(uint256 validatorId, address newContractAddress) public onlyGovernance {

        require(IValidatorShare(newContractAddress).owner() == address(this));
        validators[validatorId].contractAddress = newContractAddress;
    }

    function updateDynastyValue(uint256 newDynasty) public onlyGovernance {

        require(newDynasty > 0);
        logger.logDynastyValueChange(newDynasty, dynasty);
        dynasty = newDynasty;
        WITHDRAWAL_DELAY = newDynasty;
        auctionPeriod = newDynasty.div(4);
        replacementCoolDown = currentEpoch.add(auctionPeriod);
    }

    function stopAuctions(uint256 forNCheckpoints) public onlyGovernance {

        replacementCoolDown = currentEpoch.add(forNCheckpoints);
    }

    function updateProposerBonus(uint256 newProposerBonus) public onlyGovernance {

        logger.logProposerBonusChange(newProposerBonus, proposerBonus);
        require(newProposerBonus <= MAX_PROPOSER_BONUS, "too big");
        proposerBonus = newProposerBonus;
    }

    function updateSignerUpdateLimit(uint256 _limit) public onlyGovernance {

        signerUpdateLimit = _limit;
    }

    function updateMinAmounts(uint256 _minDeposit, uint256 _minHeimdallFee) public onlyGovernance {

        minDeposit = _minDeposit;
        minHeimdallFee = _minHeimdallFee;
    }

    function drainValidatorShares(
        uint256 validatorId,
        address tokenAddr,
        address payable destination,
        uint256 amount
    ) external onlyGovernance {

        address contractAddr = validators[validatorId].contractAddress;
        require(contractAddr != address(0x0));
        IValidatorShare(contractAddr).drain(tokenAddr, destination, amount);
    }

    function drain(address destination, uint256 amount) external onlyGovernance {

        _transferToken(destination, amount);
    }

    function reinitialize(
        address _NFTContract,
        address _stakingLogger,
        address _validatorShareFactory,
        address _extensionCode
    ) external onlyGovernance {

        require(isContract(_extensionCode));
        eventsHub = address(0x0);
        extensionCode = _extensionCode;
        NFTContract = StakingNFT(_NFTContract);
        logger = StakingInfo(_stakingLogger);
        validatorShareFactory = ValidatorShareFactory(_validatorShareFactory);
    }


    function topUpForFee(address user, uint256 heimdallFee) public onlyWhenUnlocked {

        _transferAndTopUp(user, msg.sender, heimdallFee, 0);
    }

    function claimFee(
        uint256 accumFeeAmount,
        uint256 index,
        bytes memory proof
    ) public {

        require(
            keccak256(abi.encode(msg.sender, accumFeeAmount)).checkMembership(index, accountStateRoot, proof),
            "Wrong acc proof"
        );
        uint256 withdrawAmount = accumFeeAmount.sub(userFeeExit[msg.sender]);
        _claimFee(msg.sender, withdrawAmount);
        userFeeExit[msg.sender] = accumFeeAmount;
        _transferToken(msg.sender, withdrawAmount);
    }

    function totalStakedFor(address user) external view returns (uint256) {

        if (user == address(0x0) || NFTContract.balanceOf(user) == 0) {
            return 0;
        }
        return validators[NFTContract.tokenOfOwnerByIndex(user, 0)].amount;
    }

    function startAuction(
        uint256 validatorId,
        uint256 amount,
        bool _acceptDelegation,
        bytes calldata _signerPubkey
    ) external onlyWhenUnlocked {

        delegatedFwd(
            extensionCode,
            abi.encodeWithSelector(
                StakeManagerExtension(extensionCode).startAuction.selector,
                validatorId,
                amount,
                _acceptDelegation,
                _signerPubkey
            )
        );
    }

    function confirmAuctionBid(
        uint256 validatorId,
        uint256 heimdallFee /** for new validator */
    ) external onlyWhenUnlocked {

        delegatedFwd(
            extensionCode,
            abi.encodeWithSelector(
                StakeManagerExtension(extensionCode).confirmAuctionBid.selector,
                validatorId,
                heimdallFee,
                address(this)
            )
        );
    }

    function dethroneAndStake(
        address auctionUser,
        uint256 heimdallFee,
        uint256 validatorId,
        uint256 auctionAmount,
        bool acceptDelegation,
        bytes calldata signerPubkey
    ) external {

        require(msg.sender == address(this), "not allowed");
        _transferAndTopUp(auctionUser, auctionUser, heimdallFee, 0);
        _unstake(validatorId, currentEpoch);

        uint256 newValidatorId = _stakeFor(auctionUser, auctionAmount, acceptDelegation, signerPubkey);
        logger.logConfirmAuction(newValidatorId, validatorId, auctionAmount);
    }

    function unstake(uint256 validatorId) external onlyStaker(validatorId) {

        require(validatorAuction[validatorId].amount == 0);

        Status status = validators[validatorId].status;
        require(
            validators[validatorId].activationEpoch > 0 &&
                validators[validatorId].deactivationEpoch == 0 &&
                (status == Status.Active || status == Status.Locked)
        );

        uint256 exitEpoch = currentEpoch.add(1); // notice period
        _unstake(validatorId, exitEpoch);
    }

    function transferFunds(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external returns (bool) {

        require(
            validators[validatorId].contractAddress == msg.sender ||
                Registry(registry).getSlashingManagerAddress() == msg.sender,
            "not allowed"
        );
        return token.transfer(delegator, amount);
    }

    function delegationDeposit(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external onlyDelegation(validatorId) returns (bool) {

        return token.transferFrom(delegator, address(this), amount);
    }

    function stakeFor(
        address user,
        uint256 amount,
        uint256 heimdallFee,
        bool acceptDelegation,
        bytes memory signerPubkey
    ) public onlyWhenUnlocked {

        require(currentValidatorSetSize() < validatorThreshold, "no more slots");
        require(amount >= minDeposit, "not enough deposit");
        _transferAndTopUp(user, msg.sender, heimdallFee, amount);
        _stakeFor(user, amount, acceptDelegation, signerPubkey);
    }

    function unstakeClaim(uint256 validatorId) public onlyStaker(validatorId) {

        uint256 deactivationEpoch = validators[validatorId].deactivationEpoch;
        require(
            deactivationEpoch > 0 &&
                deactivationEpoch.add(WITHDRAWAL_DELAY) <= currentEpoch &&
                validators[validatorId].status != Status.Unstaked
        );

        uint256 amount = validators[validatorId].amount;
        uint256 newTotalStaked = totalStaked.sub(amount);
        totalStaked = newTotalStaked;

        _liquidateRewards(validatorId, msg.sender);

        NFTContract.burn(validatorId);

        validators[validatorId].amount = 0;
        validators[validatorId].jailTime = 0;
        validators[validatorId].signer = address(0);

        signerToValidator[validators[validatorId].signer] = INCORRECT_VALIDATOR_ID;
        validators[validatorId].status = Status.Unstaked;

        _transferToken(msg.sender, amount);
        logger.logUnstaked(msg.sender, validatorId, amount, newTotalStaked);
    }

    function restake(
        uint256 validatorId,
        uint256 amount,
        bool stakeRewards
    ) public onlyWhenUnlocked onlyStaker(validatorId) {

        require(validators[validatorId].deactivationEpoch == 0, "No restaking");

        if (amount > 0) {
            _transferTokenFrom(msg.sender, address(this), amount);
        }

        _updateRewards(validatorId);

        if (stakeRewards) {
            amount = amount.add(validators[validatorId].reward).sub(INITIALIZED_AMOUNT);
            validators[validatorId].reward = INITIALIZED_AMOUNT;
        }

        uint256 newTotalStaked = totalStaked.add(amount);
        totalStaked = newTotalStaked;
        validators[validatorId].amount = validators[validatorId].amount.add(amount);

        updateTimeline(int256(amount), 0, 0);

        logger.logStakeUpdate(validatorId);
        logger.logRestaked(validatorId, validators[validatorId].amount, newTotalStaked);
    }

    function withdrawRewards(uint256 validatorId) public onlyStaker(validatorId) {

        _updateRewards(validatorId);
        _liquidateRewards(validatorId, msg.sender);
    }

    function migrateDelegation(
        uint256 fromValidatorId,
        uint256 toValidatorId,
        uint256 amount
    ) public {

        require(toValidatorId > 7, "Invalid migration");
        IValidatorShare(validators[fromValidatorId].contractAddress).migrateOut(msg.sender, amount);
        IValidatorShare(validators[toValidatorId].contractAddress).migrateIn(msg.sender, amount);
    }

    function updateValidatorState(uint256 validatorId, int256 amount) public onlyDelegation(validatorId) {

        if (amount > 0) {
            require(delegationEnabled, "Delegation is disabled");
        }

        uint256 deactivationEpoch = validators[validatorId].deactivationEpoch;

        if (deactivationEpoch == 0) { // modify timeline only if validator didn't unstake
            updateTimeline(amount, 0, 0);
        } else if (deactivationEpoch > currentEpoch) { // validator just unstaked, need to wait till next checkpoint
            revert("unstaking");
        }
        

        if (amount >= 0) {
            increaseValidatorDelegatedAmount(validatorId, uint256(amount));
        } else {
            decreaseValidatorDelegatedAmount(validatorId, uint256(amount * -1));
        }
    }

    function increaseValidatorDelegatedAmount(uint256 validatorId, uint256 amount) private {

        validators[validatorId].delegatedAmount = validators[validatorId].delegatedAmount.add(amount);
    }

    function decreaseValidatorDelegatedAmount(uint256 validatorId, uint256 amount) public onlyDelegation(validatorId) {

        validators[validatorId].delegatedAmount = validators[validatorId].delegatedAmount.sub(amount);
    }

    function updateSigner(uint256 validatorId, bytes memory signerPubkey) public onlyStaker(validatorId) {

        address signer = _getAndAssertSigner(signerPubkey);
        uint256 _currentEpoch = currentEpoch;
        require(_currentEpoch >= latestSignerUpdateEpoch[validatorId].add(signerUpdateLimit), "Not allowed");

        address currentSigner = validators[validatorId].signer;
        logger.logSignerChange(validatorId, currentSigner, signer, signerPubkey);

        signerToValidator[currentSigner] = INCORRECT_VALIDATOR_ID;
        signerToValidator[signer] = validatorId;
        validators[validatorId].signer = signer;
        _updateSigner(currentSigner, signer);

        latestSignerUpdateEpoch[validatorId] = _currentEpoch;
    }

    function checkSignatures(
        uint256 blockInterval,
        bytes32 voteHash,
        bytes32 stateRoot,
        address proposer,
        uint256[3][] calldata sigs
    ) external onlyRootChain returns (uint256) {

        uint256 _currentEpoch = currentEpoch;
        uint256 signedStakePower;
        address lastAdd;
        uint256 totalStakers = validatorState.stakerCount;

        UnsignedValidatorsContext memory unsignedCtx;
        unsignedCtx.unsignedValidators = new uint256[](signers.length + totalStakers);
        unsignedCtx.validators = signers;
        unsignedCtx.validatorIndex = 0;
        unsignedCtx.totalValidators = signers.length;

        UnstakedValidatorsContext memory unstakeCtx;
        unstakeCtx.deactivatedValidators = new uint256[](signers.length + totalStakers);

        for (uint256 i = 0; i < sigs.length; ++i) {
            address signer = ECVerify.ecrecovery(voteHash, sigs[i]);

            if (signer == lastAdd) {
                continue;
            }

            if (signer < lastAdd) {
                break;
            }

            uint256 validatorId = signerToValidator[signer];
            uint256 amount = validators[validatorId].amount;
            Status status = validators[validatorId].status;
            unstakeCtx.deactivationEpoch = validators[validatorId].deactivationEpoch;

            if (_isValidator(status, amount, unstakeCtx.deactivationEpoch, _currentEpoch)) {
                lastAdd = signer;

                signedStakePower = signedStakePower.add(validators[validatorId].delegatedAmount).add(amount);

                if (unstakeCtx.deactivationEpoch != 0) {
                    unstakeCtx.deactivatedValidators[unstakeCtx.validatorIndex] = validatorId;
                    unstakeCtx.validatorIndex++;
                } else {
                    unsignedCtx = _fillUnsignedValidators(unsignedCtx, signer);
                }
            } else if (status == Status.Locked) {
                unsignedCtx.unsignedValidators[unsignedCtx.unsignedValidatorIndex] = validatorId;
                unsignedCtx.unsignedValidatorIndex++;
                unsignedCtx.validatorIndex++;
            }
        }

        unsignedCtx = _fillUnsignedValidators(unsignedCtx, address(0));

        return
            _increaseRewardAndAssertConsensus(
                blockInterval,
                proposer,
                signedStakePower,
                stateRoot,
                unsignedCtx.unsignedValidators,
                unsignedCtx.unsignedValidatorIndex,
                unstakeCtx.deactivatedValidators,
                unstakeCtx.validatorIndex
            );
    }

    function updateCommissionRate(uint256 validatorId, uint256 newCommissionRate) external onlyStaker(validatorId) {

        _updateRewards(validatorId);

        delegatedFwd(
            extensionCode,
            abi.encodeWithSelector(
                StakeManagerExtension(extensionCode).updateCommissionRate.selector,
                validatorId,
                newCommissionRate
            )
        );
    }

    function withdrawDelegatorsReward(uint256 validatorId) public onlyDelegation(validatorId) returns (uint256) {

        _updateRewards(validatorId);

        uint256 totalReward = validators[validatorId].delegatorsReward.sub(INITIALIZED_AMOUNT);
        validators[validatorId].delegatorsReward = INITIALIZED_AMOUNT;
        return totalReward;
    }

    function slash(bytes calldata _slashingInfoList) external returns (uint256) {

        require(Registry(registry).getSlashingManagerAddress() == msg.sender, "Not slash manager");

        RLPReader.RLPItem[] memory slashingInfoList = _slashingInfoList.toRlpItem().toList();
        int256 valJailed;
        uint256 jailedAmount;
        uint256 totalAmount;
        uint256 i;

        for (; i < slashingInfoList.length; i++) {
            RLPReader.RLPItem[] memory slashData = slashingInfoList[i].toList();

            uint256 validatorId = slashData[0].toUint();
            _updateRewards(validatorId);

            uint256 _amount = slashData[1].toUint();
            totalAmount = totalAmount.add(_amount);

            address delegationContract = validators[validatorId].contractAddress;
            if (delegationContract != address(0x0)) {
                uint256 delSlashedAmount =
                    IValidatorShare(delegationContract).slash(
                        validators[validatorId].amount,
                        validators[validatorId].delegatedAmount,
                        _amount
                    );
                _amount = _amount.sub(delSlashedAmount);
            }

            uint256 validatorStakeSlashed = validators[validatorId].amount.sub(_amount);
            validators[validatorId].amount = validatorStakeSlashed;

            if (validatorStakeSlashed == 0) {
                _unstake(validatorId, currentEpoch);
            } else if (slashData[2].toBoolean()) {
                jailedAmount = jailedAmount.add(_jail(validatorId, 1));
                valJailed++;
            }
        }

        updateTimeline(-int256(totalAmount.add(jailedAmount)), -valJailed, 0);

        return totalAmount;
    }

    function unjail(uint256 validatorId) public onlyStaker(validatorId) {

        require(validators[validatorId].status == Status.Locked, "Not jailed");
        require(validators[validatorId].deactivationEpoch == 0, "Already unstaking");

        uint256 _currentEpoch = currentEpoch;
        require(validators[validatorId].jailTime <= _currentEpoch, "Incomplete jail period");

        uint256 amount = validators[validatorId].amount;
        require(amount >= minDeposit);

        address delegationContract = validators[validatorId].contractAddress;
        if (delegationContract != address(0x0)) {
            IValidatorShare(delegationContract).unlock();
        }

        updateTimeline(int256(amount.add(validators[validatorId].delegatedAmount)), 1, 0);

        validators[validatorId].status = Status.Active;

        address signer = validators[validatorId].signer;
        logger.logUnjailed(validatorId, signer);
    }

    function updateTimeline(
        int256 amount,
        int256 stakerCount,
        uint256 targetEpoch
    ) internal {

        if (targetEpoch == 0) {
            if (amount > 0) {
                validatorState.amount = validatorState.amount.add(uint256(amount));
            } else if (amount < 0) {
                validatorState.amount = validatorState.amount.sub(uint256(amount * -1));
            }

            if (stakerCount > 0) {
                validatorState.stakerCount = validatorState.stakerCount.add(uint256(stakerCount));
            } else if (stakerCount < 0) {
                validatorState.stakerCount = validatorState.stakerCount.sub(uint256(stakerCount * -1));
            }
        } else {
            validatorStateChanges[targetEpoch].amount += amount;
            validatorStateChanges[targetEpoch].stakerCount += stakerCount;
        }
    }

    function updateValidatorDelegation(bool delegation) external {

        uint256 validatorId = signerToValidator[msg.sender];
        require(
            _isValidator(
                validators[validatorId].status,
                validators[validatorId].amount,
                validators[validatorId].deactivationEpoch,
                currentEpoch
            ),
            "not validator"
        );

        address contractAddr = validators[validatorId].contractAddress;
        require(contractAddr != address(0x0), "Delegation is disabled");

        IValidatorShare(contractAddr).updateDelegation(delegation);
    }


    function _getAndAssertSigner(bytes memory pub) private view returns (address) {

        require(pub.length == 64, "not pub");
        address signer = address(uint160(uint256(keccak256(pub))));
        require(signer != address(0) && signerToValidator[signer] == 0, "Invalid signer");
        return signer;
    }

    function _isValidator(
        Status status,
        uint256 amount,
        uint256 deactivationEpoch,
        uint256 _currentEpoch
    ) private pure returns (bool) {

        return (amount > 0 && (deactivationEpoch == 0 || deactivationEpoch > _currentEpoch) && status == Status.Active);
    }

    function _fillUnsignedValidators(UnsignedValidatorsContext memory context, address signer)
        private
        view
        returns(UnsignedValidatorsContext memory)
    {

        while (context.validatorIndex < context.totalValidators && context.validators[context.validatorIndex] != signer) {
            context.unsignedValidators[context.unsignedValidatorIndex] = signerToValidator[context.validators[context.validatorIndex]];
            context.unsignedValidatorIndex++;
            context.validatorIndex++;
        }

        context.validatorIndex++;
        return context;
    }

    function _calculateCheckpointReward(
        uint256 blockInterval,
        uint256 signedStakePower,
        uint256 currentTotalStake
    ) internal returns (uint256) {



        uint256 targetBlockInterval = checkPointBlockInterval;
        uint256 ckpReward = CHECKPOINT_REWARD;
        uint256 fullIntervals = Math.min(blockInterval / targetBlockInterval, maxRewardedCheckpoints);

        if (fullIntervals > 0 && fullIntervals != prevBlockInterval) {
            if (prevBlockInterval != 0) {
                uint256 delta = (ckpReward * checkpointRewardDelta / CHK_REWARD_PRECISION);
                
                if (prevBlockInterval > fullIntervals) {
                    ckpReward += delta;
                } else {
                    ckpReward -= delta;
                }
            }
            
            prevBlockInterval = fullIntervals;
        }

        uint256 reward;

        if (blockInterval > targetBlockInterval) {
            uint256 _rewardDecreasePerCheckpoint = rewardDecreasePerCheckpoint;

            reward = ckpReward.mul(fullIntervals).sub(ckpReward.mul(((fullIntervals - 1) * fullIntervals / 2).mul(_rewardDecreasePerCheckpoint)).div(CHK_REWARD_PRECISION));
            blockInterval = blockInterval.sub(fullIntervals.mul(targetBlockInterval));
            ckpReward = ckpReward.sub(ckpReward.mul(fullIntervals).mul(_rewardDecreasePerCheckpoint).div(CHK_REWARD_PRECISION));
        }

        reward = reward.add(blockInterval.mul(ckpReward).div(targetBlockInterval));
        reward = reward.mul(signedStakePower).div(currentTotalStake);
        return reward;
    }

    function _increaseRewardAndAssertConsensus(
        uint256 blockInterval,
        address proposer,
        uint256 signedStakePower,
        bytes32 stateRoot,
        uint256[] memory unsignedValidators,
        uint256 totalUnsignedValidators,
        uint256[] memory deactivatedValidators,
        uint256 totalDeactivatedValidators
    ) private returns (uint256) {

        uint256 currentTotalStake = validatorState.amount;
        require(signedStakePower >= currentTotalStake.mul(2).div(3).add(1), "2/3+1 non-majority!");

        uint256 reward = _calculateCheckpointReward(blockInterval, signedStakePower, currentTotalStake);

        uint256 _proposerBonus = reward.mul(proposerBonus).div(MAX_PROPOSER_BONUS);
        uint256 proposerId = signerToValidator[proposer];

        Validator storage _proposer = validators[proposerId];
        _proposer.reward = _proposer.reward.add(_proposerBonus);

        accountStateRoot = stateRoot;

        uint256 newRewardPerStake =
            rewardPerStake.add(reward.sub(_proposerBonus).mul(REWARD_PRECISION).div(signedStakePower));

        _updateValidatorsRewards(unsignedValidators, totalUnsignedValidators, newRewardPerStake);

        rewardPerStake = newRewardPerStake;

        _updateValidatorsRewards(deactivatedValidators, totalDeactivatedValidators, newRewardPerStake);

        _finalizeCommit();
        return reward;
    }

    function _updateValidatorsRewards(
        uint256[] memory unsignedValidators,
        uint256 totalUnsignedValidators,
        uint256 newRewardPerStake
    ) private {

        uint256 currentRewardPerStake = rewardPerStake;
        for (uint256 i = 0; i < totalUnsignedValidators; ++i) {
            _updateRewardsAndCommit(unsignedValidators[i], currentRewardPerStake, newRewardPerStake);
        }
    }

    function _updateRewardsAndCommit(
        uint256 validatorId,
        uint256 currentRewardPerStake,
        uint256 newRewardPerStake
    ) private {

        uint256 initialRewardPerStake = validators[validatorId].initialRewardPerStake;

        if (initialRewardPerStake < currentRewardPerStake) {
            uint256 validatorsStake = validators[validatorId].amount;
            uint256 delegatedAmount = validators[validatorId].delegatedAmount;
            if (delegatedAmount > 0) {
                uint256 combinedStakePower = validatorsStake.add(delegatedAmount);
                _increaseValidatorRewardWithDelegation(
                    validatorId,
                    validatorsStake,
                    delegatedAmount,
                    _getEligibleValidatorReward(
                        validatorId,
                        combinedStakePower,
                        currentRewardPerStake,
                        initialRewardPerStake
                    )
                );
            } else {
                _increaseValidatorReward(
                    validatorId,
                    _getEligibleValidatorReward(
                        validatorId,
                        validatorsStake,
                        currentRewardPerStake,
                        initialRewardPerStake
                    )
                );
            }
        }

        if (newRewardPerStake > initialRewardPerStake) {
            validators[validatorId].initialRewardPerStake = newRewardPerStake;
        }
    }

    function _updateRewards(uint256 validatorId) private {

        _updateRewardsAndCommit(validatorId, rewardPerStake, rewardPerStake);
    }

    function _getEligibleValidatorReward(
        uint256 validatorId,
        uint256 validatorStakePower,
        uint256 currentRewardPerStake,
        uint256 initialRewardPerStake
    ) private pure returns (uint256) {

        uint256 eligibleReward = currentRewardPerStake - initialRewardPerStake;
        return eligibleReward.mul(validatorStakePower).div(REWARD_PRECISION);
    }

    function _increaseValidatorReward(uint256 validatorId, uint256 reward) private {

        if (reward > 0) {
            validators[validatorId].reward = validators[validatorId].reward.add(reward);
        }
    }

    function _increaseValidatorRewardWithDelegation(
        uint256 validatorId,
        uint256 validatorsStake,
        uint256 delegatedAmount,
        uint256 reward
    ) private {

        uint256 combinedStakePower = delegatedAmount.add(validatorsStake);
        (uint256 validatorReward, uint256 delegatorsReward) =
            _getValidatorAndDelegationReward(validatorId, validatorsStake, reward, combinedStakePower);

        if (delegatorsReward > 0) {
            validators[validatorId].delegatorsReward = validators[validatorId].delegatorsReward.add(delegatorsReward);
        }

        if (validatorReward > 0) {
            validators[validatorId].reward = validators[validatorId].reward.add(validatorReward);
        }
    }

    function _getValidatorAndDelegationReward(
        uint256 validatorId,
        uint256 validatorsStake,
        uint256 reward,
        uint256 combinedStakePower
    ) internal view returns (uint256, uint256) {

        if (combinedStakePower == 0) {
            return (0, 0);
        }

        uint256 validatorReward = validatorsStake.mul(reward).div(combinedStakePower);

        uint256 commissionRate = validators[validatorId].commissionRate;
        if (commissionRate > 0) {
            validatorReward = validatorReward.add(
                reward.sub(validatorReward).mul(commissionRate).div(MAX_COMMISION_RATE)
            );
        }

        uint256 delegatorsReward = reward.sub(validatorReward);
        return (validatorReward, delegatorsReward);
    }

    function _evaluateValidatorAndDelegationReward(uint256 validatorId)
        private
        view
        returns (uint256 validatorReward, uint256 delegatorsReward)
    {

        uint256 validatorsStake = validators[validatorId].amount;
        uint256 combinedStakePower = validatorsStake.add(validators[validatorId].delegatedAmount);
        uint256 eligibleReward = rewardPerStake - validators[validatorId].initialRewardPerStake;
        return
            _getValidatorAndDelegationReward(
                validatorId,
                validatorsStake,
                eligibleReward.mul(combinedStakePower).div(REWARD_PRECISION),
                combinedStakePower
            );
    }

    function _jail(uint256 validatorId, uint256 jailCheckpoints) internal returns (uint256) {

        address delegationContract = validators[validatorId].contractAddress;
        if (delegationContract != address(0x0)) {
            IValidatorShare(delegationContract).lock();
        }

        uint256 _currentEpoch = currentEpoch;
        validators[validatorId].jailTime = _currentEpoch.add(jailCheckpoints);
        validators[validatorId].status = Status.Locked;
        logger.logJailed(validatorId, _currentEpoch, validators[validatorId].signer);
        return validators[validatorId].amount.add(validators[validatorId].delegatedAmount);
    }

    function _stakeFor(
        address user,
        uint256 amount,
        bool acceptDelegation,
        bytes memory signerPubkey
    ) internal returns (uint256) {

        address signer = _getAndAssertSigner(signerPubkey);
        uint256 _currentEpoch = currentEpoch;
        uint256 validatorId = NFTCounter;
        StakingInfo _logger = logger;

        uint256 newTotalStaked = totalStaked.add(amount);
        totalStaked = newTotalStaked;

        validators[validatorId] = Validator({
            reward: INITIALIZED_AMOUNT,
            amount: amount,
            activationEpoch: _currentEpoch,
            deactivationEpoch: 0,
            jailTime: 0,
            signer: signer,
            contractAddress: acceptDelegation
                ? validatorShareFactory.create(validatorId, address(_logger), registry)
                : address(0x0),
            status: Status.Active,
            commissionRate: 0,
            lastCommissionUpdate: 0,
            delegatorsReward: INITIALIZED_AMOUNT,
            delegatedAmount: 0,
            initialRewardPerStake: rewardPerStake
        });

        latestSignerUpdateEpoch[validatorId] = _currentEpoch;
        NFTContract.mint(user, validatorId);

        signerToValidator[signer] = validatorId;
        updateTimeline(int256(amount), 1, 0);
        validatorAuction[validatorId].startEpoch = _currentEpoch;
        _logger.logStaked(signer, signerPubkey, validatorId, _currentEpoch, amount, newTotalStaked);
        NFTCounter = validatorId.add(1);

        _insertSigner(signer);

        return validatorId;
    }

    function _unstake(uint256 validatorId, uint256 exitEpoch) internal {

        _updateRewards(validatorId);

        uint256 amount = validators[validatorId].amount;
        address validator = ownerOf(validatorId);

        validators[validatorId].deactivationEpoch = exitEpoch;

        int256 delegationAmount = int256(validators[validatorId].delegatedAmount);

        address delegationContract = validators[validatorId].contractAddress;
        if (delegationContract != address(0)) {
            IValidatorShare(delegationContract).lock();
        }

        _removeSigner(validators[validatorId].signer);
        _liquidateRewards(validatorId, validator);

        uint256 targetEpoch = exitEpoch <= currentEpoch ? 0 : exitEpoch;
        updateTimeline(-(int256(amount) + delegationAmount), -1, targetEpoch);

        logger.logUnstakeInit(validator, validatorId, exitEpoch, amount);
    }

    function _finalizeCommit() internal {

        uint256 _currentEpoch = currentEpoch;
        uint256 nextEpoch = _currentEpoch.add(1);

        StateChange memory changes = validatorStateChanges[nextEpoch];
        updateTimeline(changes.amount, changes.stakerCount, 0);

        delete validatorStateChanges[_currentEpoch];

        currentEpoch = nextEpoch;
    }

    function _liquidateRewards(uint256 validatorId, address validatorUser) private {

        uint256 reward = validators[validatorId].reward.sub(INITIALIZED_AMOUNT);
        totalRewardsLiquidated = totalRewardsLiquidated.add(reward);
        validators[validatorId].reward = INITIALIZED_AMOUNT;
        validators[validatorId].initialRewardPerStake = rewardPerStake;
        _transferToken(validatorUser, reward);
        logger.logClaimRewards(validatorId, reward, totalRewardsLiquidated);
    }

    function _transferToken(address destination, uint256 amount) private {

        require(token.transfer(destination, amount), "transfer failed");
    }

    function _transferTokenFrom(
        address from,
        address destination,
        uint256 amount
    ) private {

        require(token.transferFrom(from, destination, amount), "transfer from failed");
    }

    function _transferAndTopUp(
        address user,
        address from,
        uint256 fee,
        uint256 additionalAmount
    ) private {

        require(fee >= minHeimdallFee, "fee too small");
        _transferTokenFrom(from, address(this), fee.add(additionalAmount));
        totalHeimdallFee = totalHeimdallFee.add(fee);
        logger.logTopUpFee(user, fee);
    }

    function _claimFee(address user, uint256 amount) private {

        totalHeimdallFee = totalHeimdallFee.sub(amount);
        logger.logClaimFee(user, amount);
    }

    function _insertSigner(address newSigner) internal {

        signers.push(newSigner);

        uint lastIndex = signers.length - 1;
        uint i = lastIndex;
        for (; i > 0; --i) {
            address signer = signers[i - 1];
            if (signer < newSigner) {
                break;
            }
            signers[i] = signer;
        }

        if (i != lastIndex) {
            signers[i] = newSigner;
        }
    }

    function _updateSigner(address prevSigner, address newSigner) internal {

        _removeSigner(prevSigner);
        _insertSigner(newSigner);
    }

    function _removeSigner(address signerToDelete) internal {

        uint256 totalSigners = signers.length;
        address swapSigner = signers[totalSigners - 1];
        delete signers[totalSigners - 1];

        for (uint256 i = totalSigners - 1; i > 0; --i) {
            if (swapSigner == signerToDelete) {
                break;
            }

            (swapSigner, signers[i - 1]) = (signers[i - 1], swapSigner);
        }

        signers.length = totalSigners - 1;
    }
}