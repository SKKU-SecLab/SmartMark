pragma solidity ^0.8.0;

interface IQuantumKeyRing {

    function make(address to, uint256 id, uint256 amount) external;

}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract Auth {
    event OwnerUpdated(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnerUpdated(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function setOwner(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

interface Authority {

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);

}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ReentrancyGuard {
    uint256 private reentrancyStatus = 1;

    modifier nonReentrant() {
        require(reentrancyStatus == 1, "REENTRANCY");

        reentrancyStatus = 2;

        _;

        reentrancyStatus = 1;
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);


    string public name;

    string public symbol;

    uint8 public immutable decimals;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

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


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
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
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

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
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
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

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }


    function didLastOptionalReturnCallSucceed(bool callStatus) private pure returns (bool success) {

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

library BitMaps {

    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {

        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool value
    ) internal {

        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    function set(BitMap storage bitmap, uint256 index) internal {

        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    function unset(BitMap storage bitmap, uint256 index) internal {

        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// MIT
pragma solidity ^0.8.11;


                                                  

contract QuantumKeyMaker is Auth, ReentrancyGuard {

    using BitMaps for BitMaps.BitMap;


    event Ordered(uint256 indexed id, address indexed to, uint256 amount);



    IQuantumKeyRing private _keyRing;
    mapping (uint256 => mapping (bytes32 => BitMaps.BitMap)) private _hasClaimed;
    mapping (uint256 => mapping (bytes32 => bool)) private _validRoots;
    mapping (uint256 => uint256) public available;


    constructor(address keyRing, address owner, address authority) Auth(owner, Authority(authority)) {
        _keyRing = IQuantumKeyRing(keyRing);
    }


    function preorder(address to, uint256 id, uint256 amount) public requiresAuth {

        _keyRing.make(to, id, amount);
    }

    function setKeyMold(
        uint256 id,
        uint256 availability,
        bytes32[] calldata roots
    ) requiresAuth public {

        for(uint256 i = 0; i < roots.length; i++) {
            _validRoots[id][roots[i]] = true;
        }
        available[id] = availability;
    }
    
    function changeRoots(
        uint256 id,
        bytes32[] calldata roots,
        bool validate
    ) requiresAuth public {

        for(uint256 i = 0; i < roots.length; i++) {
            _validRoots[id][roots[i]] = validate;
        }
    }

    function changeSingleRoot(
        uint256 id,
        bytes32 root,
        bool validate
    ) requiresAuth public {

        _validRoots[id][root] = validate;
    }

    function setAvailability(uint256 id, uint256 amount) requiresAuth public {

        available[id] = amount;
    }

    function withdraw(address recipient) requiresAuth public {

        SafeTransferLib.safeTransferETH(recipient, address(this).balance);
    }



    function order(
        uint256 id,
        uint256 amount,
        uint256 index,
        uint256 price,
        uint256 start,
        bool limited,
        bytes32 root,
        bytes32[] calldata proof
    ) nonReentrant public payable {

        require(available[id] != 0, "MINTED_OUT");
        require(block.timestamp >= start, "TOO_EARLY");
        require((amount == 1 && limited) || !limited, "OVER_LIMIT");
        require(msg.value == price * amount, "WRONG_PRICE");
        if (limited) {
            uint256 idx = proof.length != 0 ? index : a2u(msg.sender);
            require(!_hasClaimed[id][root].get(idx), "ALREADY_CLAIMED");
            _hasClaimed[id][root].set(idx);
        }
        require(_validRoots[id][root], "INVALID_ROOT");
        address user = proof.length != 0 ? msg.sender : address(0);
        bytes32 node = keccak256(abi.encodePacked(user, id, b2u(limited), index, price, start));
        require(MerkleProof.verify(proof, root, node), "INVALID_PROOF");
        available[id] -= amount;
        _keyRing.make(msg.sender, id, amount);
        emit Ordered(id, msg.sender, amount);
    }


    function hasClaimed(uint256 id, bytes32 root, uint256 index, address user) public view returns (bool) {

        return _hasClaimed[id][root].get(index) || _hasClaimed[id][root].get(a2u(user));
    }

    function b2u(bool x) pure internal returns (uint r) {

        assembly { r := x }
    }

    function a2u(address addy) pure internal returns (uint r) {

        assembly {r := addy}
    }
}