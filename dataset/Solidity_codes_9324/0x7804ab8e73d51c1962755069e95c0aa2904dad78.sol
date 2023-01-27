pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}pragma solidity ^0.5.0;


contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }
}pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity 0.5.17;


library UnlockingSchedule {

    using SafeMath for uint256;

    function getUnlockedAmount(
        uint256 _now,
        uint256 grantedAmount,
        uint256 duration,
        uint256 start,
        uint256 cliff
    ) internal pure returns (uint256) {

        bool cliffNotReached = _now < cliff;
        if (cliffNotReached) { return 0; }

        uint256 timeElapsed = _now.sub(start);

        bool unlockingPeriodFinished = timeElapsed >= duration;
        if (unlockingPeriodFinished) { return grantedAmount; }

        return grantedAmount.mul(timeElapsed).div(duration);
    }
}pragma solidity 0.5.17;





library BytesLib {

    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes memory) {

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

            mstore(0x40, and(
                add(add(end, iszero(add(length, mload(_preBytes)))), 31),
                not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
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

    function slice(bytes memory _bytes, uint _start, uint _length) internal  pure returns (bytes memory res) {

        uint _end = _start + _length;
        require(_end > _start && _bytes.length >= _end, "Slice out of bounds");

        assembly {
            res := mload(0x40)
            mstore(0x40, add(add(res, 64), _length))
            mstore(res, _length)

            let diff := sub(res, add(_bytes, _start))

            for {
                let src := add(add(_bytes, 32), _start)
                let end := add(src, _length)
            } lt(src, end) {
                src := add(src, 32)
            } {
                mstore(add(src, diff), mload(src))
            }
        }
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        uint _totalLen = _start + 20;
        require(_totalLen > _start && _bytes.length >= _totalLen, "Address conversion out of bounds.");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1), "Uint8 conversion out of bounds.");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        uint _totalLen = _start + 32;
        require(_totalLen > _start && _bytes.length >= _totalLen, "Uint conversion out of bounds.");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;

        assembly {
            let length := mload(_preBytes)

            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {

        bool success = true;

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1

                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function toBytes32(bytes memory _source) pure internal returns (bytes32 result) {
        if (_source.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(_source, 32))
        }
    }

    function keccak256Slice(bytes memory _bytes, uint _start, uint _length) pure internal returns (bytes32 result) {
        uint _end = _start + _length;
        require(_end > _start && _bytes.length >= _end, "Slice out of bounds");

        assembly {
            result := keccak256(add(add(_bytes, 32), _start), _length)
        }
    }
}pragma solidity 0.5.17;


library AddressArrayUtils {


    function contains(address[] memory self, address _address)
        internal
        pure
        returns (bool)
    {

        for (uint i = 0; i < self.length; i++) {
            if (_address == self[i]) {
                return true;
            }
        }
        return false;
    }

    function removeAddress(address[] storage self, address _addressToRemove)
        internal
        returns (address[] storage)
    {

        for (uint i = 0; i < self.length; i++) {
            if (_addressToRemove == self[i]) {
                for (uint j = i; j < self.length-1; j++) {
                    self[j] = self[j+1];
                }
                self.length--;
                i--;
            }
        }
        return self;
    }
}pragma solidity 0.5.17;

library OperatorParams {

    uint256 constant TIMESTAMP_WIDTH = 64;
    uint256 constant AMOUNT_WIDTH = 128;

    uint256 constant TIMESTAMP_MAX = (2**TIMESTAMP_WIDTH) - 1;
    uint256 constant AMOUNT_MAX = (2**AMOUNT_WIDTH) - 1;

    uint256 constant CREATION_SHIFT = TIMESTAMP_WIDTH;
    uint256 constant AMOUNT_SHIFT = 2 * TIMESTAMP_WIDTH;

    function pack(
        uint256 amount,
        uint256 createdAt,
        uint256 undelegatedAt
    ) internal pure returns (uint256) {

        require(
            amount <= AMOUNT_MAX,
            "amount uint128 overflow"
        );
        require(
            (createdAt | undelegatedAt) <= TIMESTAMP_MAX,
            "timestamp uint64 overflow"
        );
        uint256 a = amount << AMOUNT_SHIFT;
        uint256 c = createdAt << CREATION_SHIFT;
        uint256 u = undelegatedAt;
        return (a | c | u);
    }

    function unpack(uint256 packedParams) internal pure returns (
        uint256 amount,
        uint256 createdAt,
        uint256 undelegatedAt
    ) {

        amount = getAmount(packedParams);
        createdAt = getCreationTimestamp(packedParams);
        undelegatedAt = getUndelegationTimestamp(packedParams);
    }

    function getAmount(uint256 packedParams)
        internal pure returns (uint256) {

        return (packedParams >> AMOUNT_SHIFT) & AMOUNT_MAX;
    }

    function setAmount(
        uint256 packedParams,
        uint256 amount
    ) internal pure returns (uint256) {

        return pack(
            amount,
            getCreationTimestamp(packedParams),
            getUndelegationTimestamp(packedParams)
        );
    }

    function getCreationTimestamp(uint256 packedParams)
        internal pure returns (uint256) {

        return (packedParams >> CREATION_SHIFT) & TIMESTAMP_MAX;
    }

    function setCreationTimestamp(
        uint256 packedParams,
        uint256 creationTimestamp
    ) internal pure returns (uint256) {

        return pack(
            getAmount(packedParams),
            creationTimestamp,
            getUndelegationTimestamp(packedParams)
        );
    }

    function getUndelegationTimestamp(uint256 packedParams)
        internal pure returns (uint256) {

        return packedParams & TIMESTAMP_MAX;
    }

    function setUndelegationTimestamp(
        uint256 packedParams,
        uint256 undelegationTimestamp
    ) internal pure returns (uint256) {

        return pack(
            getAmount(packedParams),
            getCreationTimestamp(packedParams),
            undelegationTimestamp
        );
    }
}pragma solidity 0.5.17;



contract StakeDelegatable {

    using SafeMath for uint256;
    using SafeERC20 for ERC20Burnable;
    using BytesLib for bytes;
    using AddressArrayUtils for address[];
    using OperatorParams for uint256;

    ERC20Burnable public token;

    uint256 public initializationPeriod;
    uint256 public undelegationPeriod;

    mapping(address => address[]) public ownerOperators;

    mapping(address => Operator) public operators;

    struct Operator {
        uint256 packedParams;
        address owner;
        address payable beneficiary;
        address authorizer;
    }

    modifier onlyOperatorAuthorizer(address _operator) {

        require(
            operators[_operator].authorizer == msg.sender,
            "Not operator authorizer"
        );
        _;
    }

    function operatorsOf(address _address) public view returns (address[] memory) {

        return ownerOperators[_address];
    }

    function balanceOf(address _address) public view returns (uint256 balance) {

        return operators[_address].packedParams.getAmount();
    }

    function ownerOf(address _operator) public view returns (address) {

        return operators[_operator].owner;
    }

    function beneficiaryOf(address _operator) public view returns (address payable) {

        return operators[_operator].beneficiary;
    }

    function authorizerOf(address _operator) public view returns (address) {

        return operators[_operator].authorizer;
    }
}pragma solidity 0.5.17;


library UintArrayUtils {


    function removeValue(uint256[] storage self, uint256 _value)
        internal
        returns(uint256[] storage)
    {

        for (uint i = 0; i < self.length; i++) {
            if (_value == self[i]) {
                for (uint j = i; j < self.length-1; j++) {
                    self[j] = self[j+1];
                }
                self.length--;
                i--;
            }
        }
        return self;
    }
}pragma solidity 0.5.17;


library PercentUtils {

    using SafeMath for uint256;

    function percent(uint256 a, uint256 b) internal pure returns (uint256) {

        return a.mul(b).div(100);
    }

    function asPercentOf(uint256 a, uint256 b) internal pure returns (uint256) {

        return a.mul(100).div(b);
    }
}pragma solidity 0.5.17;

library LockUtils {

    struct Lock {
        address creator;
        uint96 expiresAt;
    }

    struct LockSet {
        Lock[] locks;
        mapping(address => uint256) positions;
    }

    function contains(LockSet storage self, address creator)
        internal view returns (bool) {

        return (self.positions[creator] != 0);
    }

    function getLockTime(LockSet storage self, address creator)
        internal view returns (uint96) {

        uint256 positionPlusOne = self.positions[creator];
        if (positionPlusOne == 0) { return 0; }
        return self.locks[positionPlusOne - 1].expiresAt;
    }

    function setLock(
        LockSet storage self,
        address _creator,
        uint96 _expiresAt
    ) internal {

        uint256 positionPlusOne = self.positions[_creator];
        Lock memory lock = Lock(_creator, _expiresAt);
        if (positionPlusOne == 0) {
            self.locks.push(lock);
            self.positions[_creator] = self.locks.length;
        } else {
            self.locks[positionPlusOne - 1].expiresAt = _expiresAt;
        }
    }

    function releaseLock(
        LockSet storage self,
        address _creator
    ) internal {

        uint256 positionPlusOne = self.positions[_creator];
        if (positionPlusOne != 0) {
            uint256 lockCount = self.locks.length;
            if (positionPlusOne != lockCount) {
                Lock memory lastLock = self.locks[lockCount - 1];
                self.locks[positionPlusOne - 1] = lastLock;
                self.positions[lastLock.creator] = positionPlusOne;
            }
            self.locks.length--;
            self.positions[_creator] = 0;
        }
    }

    function enumerate(LockSet storage self)
        internal view returns (Lock[] memory) {

        return self.locks;
    }
}pragma solidity 0.5.17;


contract KeepRegistry {

    enum ContractStatus {New, Approved, Disabled}

    address public governance;

    address public registryKeeper;

    mapping(address => address) public panicButtons;

    address public defaultPanicButton;

    mapping(address => address) public operatorContractUpgraders;

    mapping(address => address) public serviceContractUpgraders;

    mapping(address => ContractStatus) public operatorContracts;

    event OperatorContractApproved(address operatorContract);
    event OperatorContractDisabled(address operatorContract);

    event GovernanceUpdated(address governance);
    event RegistryKeeperUpdated(address registryKeeper);
    event DefaultPanicButtonUpdated(address defaultPanicButton);
    event OperatorContractPanicButtonDisabled(address operatorContract);
    event OperatorContractPanicButtonUpdated(
        address operatorContract,
        address panicButton
    );
    event OperatorContractUpgraderUpdated(
        address serviceContract,
        address upgrader
    );
    event ServiceContractUpgraderUpdated(
        address operatorContract,
        address keeper
    );

    modifier onlyGovernance() {

        require(governance == msg.sender, "Not authorized");
        _;
    }

    modifier onlyRegistryKeeper() {

        require(registryKeeper == msg.sender, "Not authorized");
        _;
    }

    modifier onlyPanicButton(address _operatorContract) {

        address panicButton = panicButtons[_operatorContract];
        require(panicButton != address(0), "Panic button disabled");
        require(panicButton == msg.sender, "Not authorized");
        _;
    }

    modifier onlyForNewContract(address _operatorContract) {

        require(
            isNewOperatorContract(_operatorContract),
            "Not a new operator contract"
        );
        _;
    }

    modifier onlyForApprovedContract(address _operatorContract) {

        require(
            isApprovedOperatorContract(_operatorContract),
            "Not an approved operator contract"
        );
        _;
    }

    constructor() public {
        governance = msg.sender;
        registryKeeper = msg.sender;
        defaultPanicButton = msg.sender;
    }

    function setGovernance(address _governance) public onlyGovernance {

        governance = _governance;
        emit GovernanceUpdated(governance);
    }

    function setRegistryKeeper(address _registryKeeper) public onlyGovernance {

        registryKeeper = _registryKeeper;
        emit RegistryKeeperUpdated(registryKeeper);
    }

    function setDefaultPanicButton(address _panicButton) public onlyGovernance {

        defaultPanicButton = _panicButton;
        emit DefaultPanicButtonUpdated(defaultPanicButton);
    }

    function setOperatorContractPanicButton(
        address _operatorContract,
        address _panicButton
    ) public onlyForApprovedContract(_operatorContract) onlyGovernance {

        require(
            panicButtons[_operatorContract] != address(0),
            "Disabled panic button cannot be updated"
        );
        require(
            _panicButton != address(0),
            "Panic button must be non-zero address"
        );

        panicButtons[_operatorContract] = _panicButton;

        emit OperatorContractPanicButtonUpdated(
            _operatorContract,
            _panicButton
        );
    }

    function disableOperatorContractPanicButton(address _operatorContract)
        public
        onlyForApprovedContract(_operatorContract)
        onlyGovernance
    {

        require(
            panicButtons[_operatorContract] != address(0),
            "Panic button already disabled"
        );

        panicButtons[_operatorContract] = address(0);

        emit OperatorContractPanicButtonDisabled(_operatorContract);
    }

    function setOperatorContractUpgrader(
        address _serviceContract,
        address _operatorContractUpgrader
    ) public onlyGovernance {

        operatorContractUpgraders[_serviceContract] = _operatorContractUpgrader;
        emit OperatorContractUpgraderUpdated(
            _serviceContract,
            _operatorContractUpgrader
        );
    }

    function setServiceContractUpgrader(
        address _operatorContract,
        address _serviceContractUpgrader
    ) public onlyGovernance {

        serviceContractUpgraders[_operatorContract] = _serviceContractUpgrader;
        emit ServiceContractUpgraderUpdated(
            _operatorContract,
            _serviceContractUpgrader
        );
    }

    function approveOperatorContract(address operatorContract)
        public
        onlyForNewContract(operatorContract)
        onlyRegistryKeeper
    {

        operatorContracts[operatorContract] = ContractStatus.Approved;
        panicButtons[operatorContract] = defaultPanicButton;
        emit OperatorContractApproved(operatorContract);
    }

    function disableOperatorContract(address operatorContract)
        public
        onlyForApprovedContract(operatorContract)
        onlyPanicButton(operatorContract)
    {

        operatorContracts[operatorContract] = ContractStatus.Disabled;
        emit OperatorContractDisabled(operatorContract);
    }

    function isNewOperatorContract(address operatorContract)
        public
        view
        returns (bool)
    {

        return operatorContracts[operatorContract] == ContractStatus.New;
    }

    function isApprovedOperatorContract(address operatorContract)
        public
        view
        returns (bool)
    {

        return operatorContracts[operatorContract] == ContractStatus.Approved;
    }

    function operatorContractUpgraderFor(address _serviceContract)
        public
        view
        returns (address)
    {

        return operatorContractUpgraders[_serviceContract];
    }

    function serviceContractUpgraderFor(address _operatorContract)
        public
        view
        returns (address)
    {

        return serviceContractUpgraders[_operatorContract];
    }
}pragma solidity 0.5.17;


interface AuthorityDelegator {

    function __isRecognized(address delegatedAuthorityRecipient) external returns (bool);

}

contract TokenStaking is StakeDelegatable {

    using UintArrayUtils for uint256[];
    using PercentUtils for uint256;
    using LockUtils for LockUtils.LockSet;
    using SafeERC20 for ERC20Burnable;

    uint256 public minimumStakeScheduleStart;
    uint256 public constant minimumStakeSchedule = 86400 * 365 * 2; // 2 years in seconds (seconds per day * days in a year * years)
    uint256 public constant minimumStakeSteps = 10;
    uint256 public constant minimumStakeBase = 10000 * 1e18;

    event Staked(address indexed from, uint256 value);
    event Undelegated(address indexed operator, uint256 undelegatedAt);
    event RecoveredStake(address operator, uint256 recoveredAt);
    event TokensSlashed(address indexed operator, uint256 amount);
    event TokensSeized(address indexed operator, uint256 amount);
    event StakeLocked(address indexed operator, address lockCreator, uint256 until);
    event LockReleased(address indexed operator, address lockCreator);
    event ExpiredLockReleased(address indexed operator, address lockCreator);

    KeepRegistry public registry;

    mapping(address => mapping (address => bool)) internal authorizations;

    mapping(address => LockUtils.LockSet) internal operatorLocks;
    uint256 public constant maximumLockDuration = 86400 * 200; // 200 days in seconds

    mapping(address => address) internal delegatedAuthority;

    modifier onlyApprovedOperatorContract(address operatorContract) {

        require(
            registry.isApprovedOperatorContract(getAuthoritySource(operatorContract)),
            "Operator contract is not approved"
        );
        _;
    }

    constructor(
        address _tokenAddress,
        address _registry,
        uint256 _initializationPeriod,
        uint256 _undelegationPeriod
    ) public {
        require(_tokenAddress != address(0x0), "Token address can't be zero.");
        token = ERC20Burnable(_tokenAddress);
        registry = KeepRegistry(_registry);
        initializationPeriod = _initializationPeriod;
        undelegationPeriod = _undelegationPeriod;
        minimumStakeScheduleStart = block.timestamp;
    }

    function minimumStake() public view returns (uint256) {

        if (block.timestamp < minimumStakeScheduleStart.add(minimumStakeSchedule)) {
            uint256 currentStep = minimumStakeSteps.mul(
                block.timestamp.sub(minimumStakeScheduleStart)
            ).div(minimumStakeSchedule);
            return minimumStakeBase.mul(minimumStakeSteps.sub(currentStep));
        }
        return minimumStakeBase;
    }

    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public {

        require(ERC20Burnable(_token) == token, "Token contract must be the same one linked to this contract.");
        require(_value >= minimumStake(), "Tokens amount must be greater than the minimum stake");
        require(_extraData.length == 60, "Stake delegation data must be provided.");

        address payable beneficiary = address(uint160(_extraData.toAddress(0)));
        address operator = _extraData.toAddress(20);
        require(operators[operator].owner == address(0), "Operator address is already in use.");
        address authorizer = _extraData.toAddress(40);

        token.safeTransferFrom(_from, address(this), _value);

        operators[operator] = Operator(
            OperatorParams.pack(_value, block.timestamp, 0),
            _from,
            beneficiary,
            authorizer
        );
        ownerOperators[_from].push(operator);

        emit Staked(operator, _value);
    }

    function cancelStake(address _operator) public {

        address owner = operators[_operator].owner;
        require(
            msg.sender == _operator ||
            msg.sender == owner, "Only operator or the owner of the stake can cancel the delegation."
        );
        uint256 operatorParams = operators[_operator].packedParams;

        require(
            !_isInitialized(operatorParams),
            "Initialization period is over"
        );

        uint256 amount = operatorParams.getAmount();
        operators[_operator].packedParams = operatorParams.setAmount(0);

        token.safeTransfer(owner, amount);
    }

    function undelegate(address _operator) public {

        undelegateAt(_operator, block.timestamp);
    }

    function undelegateAt(
        address _operator,
        uint256 _undelegationTimestamp
    ) public {

        address owner = operators[_operator].owner;
        bool sentByOwner = msg.sender == owner;
        require(
            msg.sender == _operator ||
            sentByOwner, "Only operator or the owner of the stake can undelegate."
        );
        require(
            _undelegationTimestamp >= block.timestamp,
            "May not set undelegation timestamp in the past"
        );
        uint256 oldParams = operators[_operator].packedParams;
        uint256 existingCreationTimestamp = oldParams.getCreationTimestamp();
        uint256 existingUndelegationTimestamp = oldParams.getUndelegationTimestamp();
        require(
            _undelegationTimestamp > existingCreationTimestamp.add(initializationPeriod),
            "Cannot undelegate in initialization period, use cancelStake instead"
        );
        require(
            existingUndelegationTimestamp == 0 ||
            existingUndelegationTimestamp > _undelegationTimestamp ||
            sentByOwner,
            "Only the owner may postpone previously set undelegation"
        );
        uint256 newParams = oldParams.setUndelegationTimestamp(_undelegationTimestamp);
        operators[_operator].packedParams = newParams;
        emit Undelegated(_operator, _undelegationTimestamp);
    }

    function recoverStake(address _operator) public {

        uint256 operatorParams = operators[_operator].packedParams;
        require(
            operatorParams.getUndelegationTimestamp() != 0,
            "Can not recover without first undelegating"
        );
        require(
            _isUndelegatingFinished(operatorParams),
            "Can not recover stake before undelegation period is over."
        );

        require(
            !isStakeLocked(_operator),
            "Can not recover locked stake"
        );

        address owner = operators[_operator].owner;
        uint256 amount = operatorParams.getAmount();

        operators[_operator].packedParams = operatorParams.setAmount(0);

        token.safeTransfer(owner, amount);
        emit RecoveredStake(_operator, block.timestamp);
    }

    function getDelegationInfo(address _operator)
    public view returns (uint256 amount, uint256 createdAt, uint256 undelegatedAt) {

        return operators[_operator].packedParams.unpack();
    }

    function lockStake(
        address operator,
        uint256 duration
    ) public onlyApprovedOperatorContract(msg.sender) {

        require(
            isAuthorizedForOperator(operator, msg.sender),
            "Not authorized"
        );
        require(duration <= maximumLockDuration, "Lock duration too long");

        uint256 operatorParams = operators[operator].packedParams;

        require(
            _isInitialized(operatorParams),
            "Operator stake must be active"
        );
        require(
            !_isUndelegating(operatorParams),
            "Operator undelegating"
        );

        operatorLocks[operator].setLock(
            msg.sender,
            uint96(block.timestamp.add(duration))
        );
        emit StakeLocked(operator, msg.sender, block.timestamp.add(duration));
    }

    function unlockStake(
        address operator
    ) public {

        require(
            isAuthorizedForOperator(operator, msg.sender),
            "Not authorized"
        );
        operatorLocks[operator].releaseLock(msg.sender);
        emit LockReleased(operator, msg.sender);
    }

    function releaseExpiredLock(
        address operator,
        address operatorContract
    ) public {

        LockUtils.LockSet storage locks = operatorLocks[operator];
        require(
            locks.contains(operatorContract),
            "No matching lock present"
        );
        bool expired = block.timestamp >= locks.getLockTime(operatorContract);
        bool disabled = !registry.isApprovedOperatorContract(operatorContract);
        require(
            expired || disabled,
            "Lock still active and valid"
        );
        locks.releaseLock(operatorContract);
        emit ExpiredLockReleased(operator, operatorContract);
    }

    function isStakeLocked(
        address operator
    ) public view returns (bool) {

        LockUtils.Lock[] storage _locks = operatorLocks[operator].locks;
        LockUtils.Lock memory lock;
        for (uint i = 0; i < _locks.length; i++) {
            lock = _locks[i];
            if (block.timestamp < lock.expiresAt) {
                if (registry.isApprovedOperatorContract(lock.creator)) {
                    return true;
                }
            }
        }
        return false;
    }

    function getLocks(address operator)
        public
        view
        returns (address[] memory creators, uint256[] memory expirations) {

        uint256 lockCount = operatorLocks[operator].locks.length;
        creators = new address[](lockCount);
        expirations = new uint256[](lockCount);
        LockUtils.Lock memory lock;
        for (uint i = 0; i < lockCount; i++) {
            lock = operatorLocks[operator].locks[i];
            creators[i] = lock.creator;
            expirations[i] = lock.expiresAt;
        }
    }

    function slash(uint256 amountToSlash, address[] memory misbehavedOperators)
        public
        onlyApprovedOperatorContract(msg.sender) {


        uint256 totalAmountToBurn = 0;
        address authoritySource = getAuthoritySource(msg.sender);
        for (uint i = 0; i < misbehavedOperators.length; i++) {
            address operator = misbehavedOperators[i];
            require(authorizations[authoritySource][operator], "Not authorized");

            uint256 operatorParams = operators[operator].packedParams;
            require(
                _isInitialized(operatorParams),
                "Operator stake must be active"
            );

            require(
                !_isStakeReleased(operator, operatorParams, msg.sender),
                "Stake is released"
            );

            uint256 currentAmount = operatorParams.getAmount();

            if (currentAmount < amountToSlash) {
                totalAmountToBurn = totalAmountToBurn.add(currentAmount);

                uint256 newAmount = 0;
                operators[operator].packedParams = operatorParams.setAmount(newAmount);
                emit TokensSlashed(operator, currentAmount);
            } else {
                totalAmountToBurn = totalAmountToBurn.add(amountToSlash);

                uint256 newAmount = currentAmount.sub(amountToSlash);
                operators[operator].packedParams = operatorParams.setAmount(newAmount);
                emit TokensSlashed(operator, amountToSlash);
            }
        }

        token.burn(totalAmountToBurn);
    }

    function seize(
        uint256 amountToSeize,
        uint256 rewardMultiplier,
        address tattletale,
        address[] memory misbehavedOperators
    ) public onlyApprovedOperatorContract(msg.sender) {

        uint256 totalAmountToBurn = 0;
        address authoritySource = getAuthoritySource(msg.sender);
        for (uint i = 0; i < misbehavedOperators.length; i++) {
            address operator = misbehavedOperators[i];
            require(authorizations[authoritySource][operator], "Not authorized");

            uint256 operatorParams = operators[operator].packedParams;
            require(
                _isInitialized(operatorParams),
                "Operator stake must be active"
            );

            require(
                !_isStakeReleased(operator, operatorParams, msg.sender),
                "Stake is released"
            );

            uint256 currentAmount = operatorParams.getAmount();

            if (currentAmount < amountToSeize) {
                totalAmountToBurn = totalAmountToBurn.add(currentAmount);

                uint256 newAmount = 0;
                operators[operator].packedParams = operatorParams.setAmount(newAmount);
                emit TokensSeized(operator, currentAmount);
            } else {
                totalAmountToBurn = totalAmountToBurn.add(amountToSeize);

                uint256 newAmount = currentAmount.sub(amountToSeize);
                operators[operator].packedParams = operatorParams.setAmount(newAmount);
                emit TokensSeized(operator, amountToSeize);
            }
        }

        uint256 tattletaleReward = (totalAmountToBurn.percent(5)).percent(rewardMultiplier);

        token.safeTransfer(tattletale, tattletaleReward);
        token.burn(totalAmountToBurn.sub(tattletaleReward));
    }

    function authorizeOperatorContract(address _operator, address _operatorContract)
        public
        onlyOperatorAuthorizer(_operator)
        onlyApprovedOperatorContract(_operatorContract) {

        require(
            getAuthoritySource(_operatorContract) == _operatorContract,
            "Contract uses delegated authority"
        );
        authorizations[_operatorContract][_operator] = true;
    }

    function isAuthorizedForOperator(address _operator, address _operatorContract) public view returns (bool) {

        return authorizations[getAuthoritySource(_operatorContract)][_operator];
    }

    function eligibleStake(
        address _operator,
        address _operatorContract
    ) public view returns (uint256 balance) {

        bool isAuthorized = isAuthorizedForOperator(_operator, _operatorContract);

        uint256 operatorParams = operators[_operator].packedParams;

        bool isActive = _isInitialized(operatorParams);
        bool isUndelegating = _isUndelegating(operatorParams);

        if (isAuthorized && isActive && !isUndelegating) {
            balance = operatorParams.getAmount();
        }
    }

    function activeStake(
        address _operator,
        address _operatorContract
    ) public view returns (uint256 balance) {

        bool isAuthorized = isAuthorizedForOperator(_operator, _operatorContract);

        uint256 operatorParams = operators[_operator].packedParams;

        bool isActive = _isInitialized(operatorParams);

        bool stakeReleased = _isStakeReleased(
            _operator,
            operatorParams,
            _operatorContract
        );

        if (isAuthorized && isActive && !stakeReleased) {
            balance = operatorParams.getAmount();
        }
    }

    function hasMinimumStake(
        address staker,
        address operatorContract
    ) public view returns(bool) {

        return activeStake(staker, operatorContract) >= minimumStake();
    }

    function claimDelegatedAuthority(
        address delegatedAuthoritySource
    ) public onlyApprovedOperatorContract(delegatedAuthoritySource) {

        require(
            AuthorityDelegator(delegatedAuthoritySource).__isRecognized(msg.sender),
            "Unrecognized claimant"
        );
        delegatedAuthority[msg.sender] = delegatedAuthoritySource;
    }

    function getAuthoritySource(
        address operatorContract
    ) public view returns (address) {

        address delegatedAuthoritySource = delegatedAuthority[operatorContract];
        if (delegatedAuthoritySource == address(0)) {
            return operatorContract;
        }
        return getAuthoritySource(delegatedAuthoritySource);
    }

    function _isInitialized(uint256 _operatorParams)
        internal view returns (bool) {

        uint256 createdAt = _operatorParams.getCreationTimestamp();
        return block.timestamp > createdAt.add(initializationPeriod);
    }

    function _isUndelegating(uint256 _operatorParams)
        internal view returns (bool) {

        uint256 undelegatedAt = _operatorParams.getUndelegationTimestamp();
        return (undelegatedAt != 0) && (block.timestamp > undelegatedAt);
    }

    function _isUndelegatingFinished(uint256 _operatorParams)
        internal view returns (bool) {

        uint256 undelegatedAt = _operatorParams.getUndelegationTimestamp();
        uint256 finishedAt = undelegatedAt.add(undelegationPeriod);
        return (undelegatedAt != 0) && (block.timestamp > finishedAt);
    }

    function _isStakeReleased(
        address _operator,
        uint256 _operatorParams,
        address _operatorContract
    ) internal view returns (bool) {

        if (!_isUndelegatingFinished(_operatorParams)) {
            return false;
        }
        LockUtils.LockSet storage locks = operatorLocks[_operator];
        return block.timestamp >= locks.getLockTime(_operatorContract);
    }
}pragma solidity 0.5.17;



interface tokenSender {

    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData) external;

}

contract TokenGrantStake {

    using SafeMath for uint256;
    using BytesLib for bytes;

    ERC20Burnable token;
    TokenStaking tokenStaking;

    address tokenGrant; // Address of the master grant contract.

    uint256 grantId; // ID of the grant for this stake.
    uint256 amount; // Amount of staked tokens.
    address operator; // Operator of the stake.

    constructor(
        address _tokenAddress,
        uint256 _grantId,
        address _tokenStaking
    ) public {
        require(
            _tokenAddress != address(0x0),
            "Token address can't be zero."
        );
        require(
            _tokenStaking != address(0x0),
            "Staking contract address can't be zero."
        );

        token = ERC20Burnable(_tokenAddress);
        tokenGrant = msg.sender;
        grantId = _grantId;
        tokenStaking = TokenStaking(_tokenStaking);
    }

    function stake(
        uint256 _amount,
        bytes memory _extraData
    ) public onlyGrant {

        amount = _amount;
        operator = _extraData.toAddress(20);
        tokenSender(address(token)).approveAndCall(
            address(tokenStaking),
            _amount,
            _extraData
        );
    }

    function getGrantId() public view onlyGrant returns (uint256) {

        return grantId;
    }

    function getAmount() public view onlyGrant returns (uint256) {

        return amount;
    }

    function getStakingContract() public view onlyGrant returns (address) {

        return address(tokenStaking);
    }

    function getDetails() public view onlyGrant returns (
        uint256 _grantId,
        uint256 _amount,
        address _tokenStaking
    ) {

        return (
            grantId,
            amount,
            address(tokenStaking)
        );
    }

    function cancelStake() public onlyGrant returns (uint256) {

        tokenStaking.cancelStake(operator);
        return returnTokens();
    }

    function undelegate() public onlyGrant {

        tokenStaking.undelegate(operator);
    }

    function recoverStake() public onlyGrant returns (uint256) {

        tokenStaking.recoverStake(operator);
        return returnTokens();
    }

    function returnTokens() internal returns (uint256) {

        uint256 returnedAmount = token.balanceOf(address(this));
        amount -= returnedAmount;
        token.transfer(tokenGrant, returnedAmount);
        return returnedAmount;
    }

    modifier onlyGrant {

        require(
            msg.sender == tokenGrant,
            "For token grant contract only"
        );
        _;
    }
}pragma solidity 0.5.17;

contract GrantStakingPolicy {

    function getStakeableAmount(
        uint256 _now,
        uint256 grantedAmount,
        uint256 duration,
        uint256 start,
        uint256 cliff,
        uint256 withdrawn) public view returns (uint256);

}pragma solidity 0.5.17;



contract TokenGrant {

    using SafeMath for uint256;
    using UnlockingSchedule for uint256;
    using SafeERC20 for ERC20Burnable;
    using BytesLib for bytes;
    using AddressArrayUtils for address[];

    event TokenGrantCreated(uint256 id);
    event TokenGrantWithdrawn(uint256 indexed grantId, uint256 amount);
    event TokenGrantStaked(uint256 indexed grantId, uint256 amount, address operator);
    event TokenGrantRevoked(uint256 id);

    event StakingContractAuthorized(address indexed grantManager, address stakingContract);

    struct Grant {
        address grantManager; // Token grant manager.
        address grantee; // Address to which granted tokens are going to be withdrawn.
        uint256 revokedAt; // Timestamp at which grant was revoked by the grant manager.
        uint256 revokedAmount; // The number of tokens revoked from the grantee.
        uint256 revokedWithdrawn; // The number of tokens returned to the grant creator.
        bool revocable; // Whether grant manager can revoke the grant.
        uint256 amount; // Amount of tokens to be granted.
        uint256 duration; // Duration in seconds of the period in which the granted tokens will unlock.
        uint256 start; // Timestamp at which the linear unlocking schedule will start.
        uint256 cliff; // Timestamp before which no tokens will be unlocked.
        uint256 withdrawn; // Amount that was withdrawn to the grantee.
        uint256 staked; // Amount that was staked by the grantee.
        GrantStakingPolicy stakingPolicy;
    }

    uint256 public numGrants;

    ERC20Burnable public token;

    mapping(address => mapping (address => bool)) internal stakingContracts;

    mapping(uint256 => Grant) public grants;

    mapping(address => TokenGrantStake) public grantStakes;

    mapping(address => uint256[]) public grantIndices;

    mapping(address => uint256) public balances;

    mapping(address => address[]) public granteesToOperators;

    constructor(address _tokenAddress) public {
        require(_tokenAddress != address(0x0), "Token address can't be zero.");
        token = ERC20Burnable(_tokenAddress);
    }

    function authorizeStakingContract(address _stakingContract) public {

        require(
            _stakingContract != address(0x0),
            "Staking contract address can't be zero"
        );
        stakingContracts[msg.sender][_stakingContract] = true;
        emit StakingContractAuthorized(msg.sender, _stakingContract);
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }

    function stakeBalanceOf(address _address) public view returns (uint256 balance) {

        for (uint i = 0; i < grantIndices[_address].length; i++) {
            uint256 id = grantIndices[_address][i];
            balance += grants[id].staked;
        }
        return balance;
    }

    function getGrant(uint256 _id) public view returns (
        uint256 amount,
        uint256 withdrawn,
        uint256 staked,
        uint256 revokedAmount,
        uint256 revokedAt,
        address grantee
    ) {

        return (
            grants[_id].amount,
            grants[_id].withdrawn,
            grants[_id].staked,
            grants[_id].revokedAmount,
            grants[_id].revokedAt,
            grants[_id].grantee
        );
    }

    function getGrantUnlockingSchedule(
        uint256 _id
    ) public view returns (
        address grantManager,
        uint256 duration,
        uint256 start,
        uint256 cliff,
        address policy
    ) {

        return (
            grants[_id].grantManager,
            grants[_id].duration,
            grants[_id].start,
            grants[_id].cliff,
            address(grants[_id].stakingPolicy)
        );
    }

    function getGrants(address _granteeOrGrantManager) public view returns (uint256[] memory) {

        return grantIndices[_granteeOrGrantManager];
    }

    function getGranteeOperators(address grantee) public view returns (address[] memory) {

        return granteesToOperators[grantee];
    }

    function getGrantStakeDetails(address operator) public view returns (uint256 grantId, uint256 amount, address stakingContract) {

        return grantStakes[operator].getDetails();
    }


    function receiveApproval(address _from, uint256 _amount, address _token, bytes memory _extraData) public {

        require(ERC20Burnable(_token) == token, "Token contract must be the same one linked to this contract.");
        require(_amount <= token.balanceOf(_from), "Sender must have enough amount.");
        (address _grantManager,
         address _grantee,
         uint256 _duration,
         uint256 _start,
         uint256 _cliffDuration,
         bool _revocable,
         address _stakingPolicy) = abi.decode(
             _extraData,
             (address, address, uint256, uint256, uint256, bool, address)
        );

        require(_grantee != address(0), "Grantee address can't be zero.");
        require(
            _cliffDuration <= _duration,
            "Unlocking cliff duration must be less or equal total unlocking duration."
        );

        require(_stakingPolicy != address(0), "Staking policy can't be zero.");

        uint256 id = numGrants++;
        grants[id] = Grant(
            _grantManager,
            _grantee,
            0, 0, 0,
            _revocable,
            _amount,
            _duration,
            _start,
            _start.add(_cliffDuration),
            0, 0,
            GrantStakingPolicy(_stakingPolicy)
        );

        grantIndices[_from].push(id);

        grantIndices[_grantee].push(id);

        token.safeTransferFrom(_from, address(this), _amount);

        balances[_grantee] = balances[_grantee].add(_amount);
        emit TokenGrantCreated(id);
    }

    function withdraw(uint256 _id) public {

        uint256 amount = withdrawable(_id);
        require(amount > 0, "Grant available to withdraw amount should be greater than zero.");

        grants[_id].withdrawn = grants[_id].withdrawn.add(amount);

        balances[grants[_id].grantee] = balances[grants[_id].grantee].sub(amount);

        token.safeTransfer(grants[_id].grantee, amount);

        emit TokenGrantWithdrawn(_id, amount);
    }

    function unlockedAmount(uint256 _id) public view returns (uint256) {

        Grant storage grant = grants[_id];
        return (grant.revokedAt != 0)
            ? grant.amount.sub(grant.revokedAmount)
            : now.getUnlockedAmount(
                grant.amount,
                grant.duration,
                grant.start,
                grant.cliff
            );
    }

    function withdrawable(uint256 _id) public view returns (uint256) {

        uint256 unlocked = unlockedAmount(_id);
        uint256 withdrawn = grants[_id].withdrawn;
        uint256 staked = grants[_id].staked;

        if (withdrawn.add(staked) >= unlocked) {
            return 0;
        } else {
            return unlocked.sub(withdrawn).sub(staked);
        }
    }

    function revoke(uint256 _id) public {

        require(grants[_id].grantManager == msg.sender, "Only grant manager can revoke.");
        require(grants[_id].revocable, "Grant must be revocable in the first place.");
        require(grants[_id].revokedAt == 0, "Grant must not be already revoked.");

        uint256 unlockedAmount = unlockedAmount(_id);
        uint256 revokedAmount = grants[_id].amount.sub(unlockedAmount);
        grants[_id].revokedAt = now;
        grants[_id].revokedAmount = revokedAmount;

        balances[grants[_id].grantee] = balances[grants[_id].grantee].sub(revokedAmount);
        emit TokenGrantRevoked(_id);
    }

    function withdrawRevoked(uint256 _id) public {

        Grant storage grant = grants[_id];
        require(
            grant.grantManager == msg.sender,
            "Only grant manager can withdraw revoked tokens."
        );
        uint256 revoked = grant.revokedAmount;
        uint256 revokedWithdrawn = grant.revokedWithdrawn;
        require(revokedWithdrawn < revoked, "All revoked tokens withdrawn.");

        uint256 revokedRemaining = revoked.sub(revokedWithdrawn);

        uint256 totalAmount = grant.amount;
        uint256 staked = grant.staked;
        uint256 granteeWithdrawn = grant.withdrawn;
        uint256 remainingPresentInGrant =
            totalAmount.sub(staked).sub(revokedWithdrawn).sub(granteeWithdrawn);

        require(remainingPresentInGrant > 0, "No revoked tokens withdrawable.");

        uint256 amountToWithdraw = remainingPresentInGrant < revokedRemaining
            ? remainingPresentInGrant
            : revokedRemaining;
        token.safeTransfer(msg.sender, amountToWithdraw);
        grant.revokedWithdrawn += amountToWithdraw;
    }

    function stake(uint256 _id, address _stakingContract, uint256 _amount, bytes memory _extraData) public {

        require(grants[_id].grantee == msg.sender, "Only grantee of the grant can stake it.");
        require(grants[_id].revokedAt == 0, "Revoked grant can not be staked");
        require(
            stakingContracts[grants[_id].grantManager][_stakingContract],
            "Provided staking contract is not authorized."
        );

        require(_extraData.length == 60, "Stake delegation data must be provided.");
        address operator = _extraData.toAddress(20);

        require(_amount <= availableToStake(_id), "Must have available granted amount to stake.");

        TokenGrantStake grantStake = new TokenGrantStake(
            address(token),
            _id,
            _stakingContract
        );
        grantStakes[operator] = grantStake;
        granteesToOperators[grants[_id].grantee].push(operator);
        grants[_id].staked += _amount;

        token.transfer(address(grantStake), _amount);

        grantStake.stake(_amount, _extraData);
        emit TokenGrantStaked(_id, _amount, operator);
    }

    function availableToStake(uint256 _grantId) public view returns (uint256) {

        Grant storage grant = grants[_grantId];
        if (grant.revokedAt != 0) { return 0; }
        uint256 amount = grant.amount;
        uint256 withdrawn = grant.withdrawn;
        uint256 remaining = amount.sub(withdrawn);
        uint256 stakeable = grant.stakingPolicy.getStakeableAmount(
            now,
            amount,
            grant.duration,
            grant.start,
            grant.cliff,
            withdrawn
        );
        if (stakeable > remaining) {
            stakeable = remaining;
        }

        return stakeable.sub(grant.staked);
    }

    function cancelStake(address _operator) public {

        TokenGrantStake grantStake = grantStakes[_operator];
        uint256 grantId = grantStake.getGrantId();
        require(
            msg.sender == _operator || msg.sender == grants[grantId].grantee,
            "Only operator or grantee can cancel the delegation."
        );

        uint256 returned = grantStake.cancelStake();
        grants[grantId].staked = grants[grantId].staked.sub(returned);
    }

    function undelegate(address _operator) public {

        TokenGrantStake grantStake = grantStakes[_operator];
        uint256 grantId = grantStake.getGrantId();
        require(
            msg.sender == _operator || msg.sender == grants[grantId].grantee,
            "Only operator or grantee can undelegate."
        );

        grantStake.undelegate();
    }

    function cancelRevokedStake(address _operator) public {

        TokenGrantStake grantStake = grantStakes[_operator];
        uint256 grantId = grantStake.getGrantId();
        require(
            grants[grantId].revokedAt != 0,
            "Grant must be revoked"
        );
        require(
            msg.sender == grants[grantId].grantManager,
            "Only grant manager can force cancellation of revoked grant stake."
        );

        uint256 returned = grantStake.cancelStake();
        grants[grantId].staked = grants[grantId].staked.sub(returned);
    }

    function undelegateRevoked(address _operator) public {

        TokenGrantStake grantStake = grantStakes[_operator];
        uint256 grantId = grantStake.getGrantId();
        require(
            grants[grantId].revokedAt != 0,
            "Grant must be revoked"
        );
        require(
            msg.sender == grants[grantId].grantManager,
            "Only grant manager can force undelegation of revoked grant stake"
        );

        grantStake.undelegate();
    }

    function recoverStake(address _operator) public {

        TokenGrantStake grantStake = grantStakes[_operator];
        uint256 returned = grantStake.recoverStake();
        uint256 grantId = grantStake.getGrantId();
        grants[grantId].staked = grants[grantId].staked.sub(returned);

        delete grantStakes[_operator];
    }
}