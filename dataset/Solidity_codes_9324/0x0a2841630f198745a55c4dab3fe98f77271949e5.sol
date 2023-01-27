pragma solidity ^0.8.4;

contract Clone {

    function _getArgAddress(uint256 argOffset)
        internal
        pure
        returns (address arg)
    {

        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0x60, calldataload(add(offset, argOffset)))
        }
    }

    function _getArgUint256(uint256 argOffset)
        internal
        pure
        returns (uint256 arg)
    {

        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }

    function _getArgUint256Array(uint256 argOffset, uint64 arrLen)
        internal
        pure
        returns (uint256[] memory arr)
    {

        uint256 offset = _getImmutableArgsOffset();
        uint256 el;
        arr = new uint256[](arrLen);
        for (uint64 i = 0; i < arrLen; i++) {
            assembly {
                el := calldataload(add(add(offset, argOffset), mul(i, 32)))
            }
            arr[i] = el;
        }
        return arr;
    }

    function _getArgUint64(uint256 argOffset)
        internal
        pure
        returns (uint64 arg)
    {

        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xc0, calldataload(add(offset, argOffset)))
        }
    }

    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {

        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xf8, calldataload(add(offset, argOffset)))
        }
    }

    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {

        assembly {
            offset := sub(
                calldatasize(),
                add(shr(240, calldataload(sub(calldatasize(), 2))), 2)
            )
        }
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
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

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

    event Debug(bool one, bool two, uint256 retsize);


    function safeTransferETH(address to, uint256 amount) internal {

        bool success;

        assembly {
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}// MIT
pragma solidity 0.8.13;

library FullMath {

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        unchecked {
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            require(denominator > prod1);


            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            uint256 twos = (type(uint256).max - denominator + 1) & denominator;
            assembly {
                denominator := div(denominator, twos)
            }

            assembly {
                prod0 := div(prod0, twos)
            }
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            uint256 inv = (3 * denominator) ^ 2;
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            result = prod0 * inv;
            return result;
        }
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        result = mulDiv(a, b, denominator);
        unchecked {
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}// GPL-3.0-or-later
pragma solidity 0.8.13;


contract VestingModule is Clone {


    error InvalidVestingStreamId(uint256 id);


    using SafeTransferLib for address;
    using SafeTransferLib for ERC20;


    event CreateVestingStream(
        uint256 indexed id,
        address indexed token,
        uint256 amount
    );

    event ReleaseFromVestingStream(uint256 indexed id, uint256 amount);

    event ReceiveETH(uint256 amount);


    struct VestingStream {
        address token;
        uint256 vestingStart;
        uint256 total;
        uint256 released;
    }


    function beneficiary() public pure returns (address) {

        return _getArgAddress(0);
    }

    function vestingPeriod() public pure returns (uint256) {

        return _getArgUint256(20);
    }

    uint256 public numVestingStreams;

    mapping(uint256 => VestingStream) internal vestingStreams;
    mapping(address => uint256) public vesting;
    mapping(address => uint256) public released;


    constructor() {}




    function createVestingStreams(address[] calldata tokens)
        external
        payable
        returns (uint256[] memory ids)
    {

        uint256 numTokens = tokens.length;
        ids = new uint256[](numTokens);
        uint256 vestingStreamId = numVestingStreams;

        unchecked {
            for (uint256 i = 0; i < numTokens; ++i) {
                address token = tokens[i];
                uint256 pendingAmount = (
                    token != address(0)
                        ? ERC20(token).balanceOf(address(this))
                        : address(this).balance
                ) - (vesting[token] - released[token]);
                vesting[token] += pendingAmount;
                vestingStreams[vestingStreamId] = VestingStream({
                    token: token,
                    vestingStart: block.timestamp, // solhint-disable-line not-rely-on-time
                    total: pendingAmount,
                    released: 0
                });
                emit CreateVestingStream(vestingStreamId, token, pendingAmount);
                ids[i] = vestingStreamId;
                ++vestingStreamId;
            }
            numVestingStreams = vestingStreamId;
        }
    }

    function releaseFromVesting(uint256[] calldata ids)
        external
        payable
        returns (uint256[] memory releasedFunds)
    {

        uint256 numIds = ids.length;
        releasedFunds = new uint256[](numIds);

        unchecked {
            for (uint256 i = 0; i < numIds; ++i) {
                uint256 id = ids[i];
                if (id >= numVestingStreams) revert InvalidVestingStreamId(id);
                VestingStream memory vs = vestingStreams[id];
                uint256 transferAmount = _vestedAndUnreleased(vs);
                address token = vs.token;
                vestingStreams[id].released += transferAmount;
                released[token] += transferAmount;
                if (token != address(0)) {
                    ERC20(token).safeTransfer(beneficiary(), transferAmount);
                } else {
                    beneficiary().safeTransferETH(transferAmount);
                }

                emit ReleaseFromVestingStream(id, transferAmount);
                releasedFunds[i] = transferAmount;
            }
        }
    }


    function vestingStream(uint256 id)
        external
        view
        returns (VestingStream memory vs)
    {

        vs = vestingStreams[id];
    }

    function vested(uint256 id) external view returns (uint256) {

        VestingStream memory vs = vestingStreams[id];
        return _vested(vs);
    }

    function vestedAndUnreleased(uint256 id) external view returns (uint256) {

        VestingStream memory vs = vestingStreams[id];
        return _vestedAndUnreleased(vs);
    }


    function _vested(VestingStream memory vs) internal view returns (uint256) {

        uint256 elapsedTime;
        unchecked {
            elapsedTime = block.timestamp - vs.vestingStart;
        }
        return
            elapsedTime >= vestingPeriod()
                ? vs.total
                : FullMath.mulDiv(vs.total, elapsedTime, vestingPeriod());
    }

    function _vestedAndUnreleased(VestingStream memory vs)
        internal
        view
        returns (uint256)
    {

        unchecked {
            return _vested(vs) - vs.released;
        }
    }
}// BSD

pragma solidity ^0.8.4;

library ClonesWithImmutableArgs {

    error CreateFail();

    function cloneCreationCode(address implementation, bytes memory data)
        internal
        pure
        returns (uint256 ptr, uint256 creationSize)
    {

        unchecked {
            uint256 extraLength = data.length + 2; // +2 bytes for telling how much data there is appended to the call
            creationSize = 0x71 + extraLength;
            uint256 runSize = creationSize - 10;
            uint256 dataPtr;
            assembly {
                ptr := mload(0x40)


                mstore(
                    ptr,
                    0x6100000000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x01), shl(240, runSize)) // size of the contract running bytecode (16 bits)




                mstore(
                    add(ptr, 0x03),
                    0x3d81600a3d39f336602f57343d527f0000000000000000000000000000000000
                )
                mstore(
                    add(ptr, 0x12),
                    0x9e4ac34f21c619cefc926c8bd93b54bf5a39c7ab2127a895af1cc0691d7e3dff
                )
                mstore(
                    add(ptr, 0x32),
                    0x60203da13d3df35b3d3d3d3d363d3d3761000000000000000000000000000000
                )
                mstore(add(ptr, 0x43), shl(240, extraLength))

                mstore(
                    add(ptr, 0x45),
                    0x6067363936610000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x4b), shl(240, extraLength))

                mstore(
                    add(ptr, 0x4d),
                    0x013d730000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x50), shl(0x60, implementation))

                mstore(
                    add(ptr, 0x64),
                    0x5af43d3d93803e606557fd5bf300000000000000000000000000000000000000
                )
            }


            extraLength -= 2;
            uint256 counter = extraLength;
            uint256 copyPtr = ptr + 0x71;
            assembly {
                dataPtr := add(data, 32)
            }
            for (; counter >= 32; counter -= 32) {
                assembly {
                    mstore(copyPtr, mload(dataPtr))
                }

                copyPtr += 32;
                dataPtr += 32;
            }
            uint256 mask = ~(256**(32 - counter) - 1);
            assembly {
                mstore(copyPtr, and(mload(dataPtr), mask))
            }
            copyPtr += counter;
            assembly {
                mstore(copyPtr, shl(240, extraLength))
            }
        }
    }

    function clone(address implementation, bytes memory data)
        internal
        returns (address payable instance)
    {

        (uint256 creationPtr, uint256 creationSize) = cloneCreationCode(
            implementation,
            data
        );

        assembly {
            instance := create(0, creationPtr, creationSize)
        }

        if (instance == address(0)) {
            revert CreateFail();
        }
    }

    function cloneDeterministic(
        address implementation,
        bytes32 salt,
        bytes memory data
    ) internal returns (address payable instance) {

        (uint256 creationPtr, uint256 creationSize) = cloneCreationCode(
            implementation,
            data
        );

        assembly {
            instance := create2(0, creationPtr, creationSize, salt)
        }

        if (instance == address(0)) {
            revert CreateFail();
        }
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        bytes memory data
    ) internal view returns (address predicted, bool exists) {

        (uint256 creationPtr, uint256 creationSize) = cloneCreationCode(
            implementation,
            data
        );

        bytes32 creationHash;
        assembly {
            creationHash := keccak256(creationPtr, creationSize)
        }

        predicted = computeAddress(salt, creationHash, address(this));
        exists = predicted.code.length > 0;
    }

    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {

        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(uint160(uint256(_data)));
    }
}// GPL-3.0-or-later
pragma solidity 0.8.13;


contract VestingModuleFactory {


    error InvalidBeneficiary();
    error InvalidVestingPeriod();


    using ClonesWithImmutableArgs for address;


    event CreateVestingModule(
        address indexed vestingModule,
        address indexed beneficiary,
        uint256 vestingPeriod
    );


    VestingModule public implementation;


    constructor() {
        implementation = new VestingModule();
    }



    function createVestingModule(address beneficiary, uint256 vestingPeriod)
        external
        returns (VestingModule vm)
    {

        if (beneficiary == address(0)) revert InvalidBeneficiary();
        if (vestingPeriod == 0) revert InvalidVestingPeriod();

        bytes memory data = abi.encodePacked(beneficiary, vestingPeriod);
        vm = VestingModule(
            address(implementation).cloneDeterministic(
                bytes32(bytes20(beneficiary)),
                data
            )
        );
        emit CreateVestingModule(address(vm), beneficiary, vestingPeriod);
    }


    function predictVestingModuleAddress(
        address beneficiary,
        uint256 vestingPeriod
    ) external view returns (address predictedAddress, bool exists) {

        if (beneficiary == address(0) || vestingPeriod == 0)
            return (address(0), false);

        bytes memory data = abi.encodePacked(beneficiary, vestingPeriod);
        (predictedAddress, exists) = address(implementation)
            .predictDeterministicAddress(bytes32(bytes20(beneficiary)), data);
    }
}