
pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;




library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

pragma solidity ^0.7.0;




library AdditionalMath {

    using SafeMath for uint256;

    function max16(uint16 a, uint16 b) internal pure returns (uint16) {

        return a >= b ? a : b;
    }

    function min16(uint16 a, uint16 b) internal pure returns (uint16) {

        return a < b ? a : b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a.add(b) - 1) / b;
    }

    function addSigned(uint256 a, int256 b) internal pure returns (uint256) {

        if (b >= 0) {
            return a.add(uint256(b));
        } else {
            return a.sub(uint256(-b));
        }
    }

    function subSigned(uint256 a, int256 b) internal pure returns (uint256) {

        if (b >= 0) {
            return a.sub(uint256(b));
        } else {
            return a.add(uint256(-b));
        }
    }

    function mul32(uint32 a, uint32 b) internal pure returns (uint32) {

        if (a == 0) {
            return 0;
        }
        uint32 c = a * b;
        assert(c / a == b);
        return c;
    }

    function add16(uint16 a, uint16 b) internal pure returns (uint16) {

        uint16 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub16(uint16 a, uint16 b) internal pure returns (uint16) {

        assert(b <= a);
        return a - b;
    }

    function addSigned16(uint16 a, int16 b) internal pure returns (uint16) {

        if (b >= 0) {
            return add16(a, uint16(b));
        } else {
            return sub16(a, uint16(-b));
        }
    }

    function subSigned16(uint16 a, int16 b) internal pure returns (uint16) {

        if (b >= 0) {
            return sub16(a, uint16(b));
        } else {
            return add16(a, uint16(-b));
        }
    }
}

pragma solidity ^0.7.0;


library SignatureVerifier {


    enum HashAlgorithm {KECCAK256, SHA256, RIPEMD160}

    bytes25 constant EIP191_VERSION_E_HEADER = "Ethereum Signed Message:\n";

    function recover(bytes32 _hash, bytes memory _signature)
        internal
        pure
        returns (address)
    {

        require(_signature.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28);
        return ecrecover(_hash, v, r, s);
    }

    function toAddress(bytes memory _publicKey) internal pure returns (address) {

        return address(uint160(uint256(keccak256(_publicKey))));
    }

    function hash(bytes memory _message, HashAlgorithm _algorithm)
        internal
        pure
        returns (bytes32 result)
    {

        if (_algorithm == HashAlgorithm.KECCAK256) {
            result = keccak256(_message);
        } else if (_algorithm == HashAlgorithm.SHA256) {
            result = sha256(_message);
        } else {
            result = ripemd160(_message);
        }
    }

    function verify(
        bytes memory _message,
        bytes memory _signature,
        bytes memory _publicKey,
        HashAlgorithm _algorithm
    )
        internal
        pure
        returns (bool)
    {

        require(_publicKey.length == 64);
        return toAddress(_publicKey) == recover(hash(_message, _algorithm), _signature);
    }

    function hashEIP191(
        bytes memory _message,
        byte _version
    )
        internal
        view
        returns (bytes32 result)
    {

        if(_version == byte(0x00)){  // Version 0: Data with intended validator
            address validator = address(this);
            return keccak256(abi.encodePacked(byte(0x19), byte(0x00), validator, _message));
        } else if (_version == byte(0x45)){  // Version E: personal_sign messages
            uint256 length = _message.length;
            require(length > 0, "Empty message not allowed for version E");

            uint256 digits = 0;
            while (length != 0) {
                digits++;
                length /= 10;
            }
            bytes memory lengthAsText = new bytes(digits);
            length = _message.length;
            uint256 index = digits - 1;
            while (length != 0) {
                lengthAsText[index--] = byte(uint8(48 + length % 10));
                length /= 10;
            }

            return keccak256(abi.encodePacked(byte(0x19), EIP191_VERSION_E_HEADER, lengthAsText, _message));
        } else {
            revert("Unsupported EIP191 version");
        }
    }

    function verifyEIP191(
        bytes memory _message,
        bytes memory _signature,
        bytes memory _publicKey,
        byte _version
    )
        internal
        view
        returns (bool)
    {

        require(_publicKey.length == 64);
        return toAddress(_publicKey) == recover(hashEIP191(_message, _version), _signature);
    }

}

pragma solidity ^0.7.0;


interface IERC900History {

    function totalStakedForAt(address addr, uint256 blockNumber) external view returns (uint256);

    function totalStakedAt(uint256 blockNumber) external view returns (uint256);

    function supportsHistory() external pure returns (bool);

}

pragma solidity ^0.7.0;




contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view override returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public override returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {


        require(value == 0 || _allowed[msg.sender][spender] == 0);

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {

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

pragma solidity ^0.7.0;




abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

pragma solidity ^0.7.0;




contract NuCypherToken is ERC20, ERC20Detailed('NuCypher', 'NU', 18) {


    constructor (uint256 _totalSupplyOfTokens) {
        _mint(msg.sender, _totalSupplyOfTokens);
    }

    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData)
        external returns (bool success)
    {

        approve(_spender, _value);
        TokenRecipient(_spender).receiveApproval(msg.sender, _value, address(this), _extraData);
        return true;
    }

}


interface TokenRecipient {


    function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes calldata _extraData) external;


}

pragma solidity ^0.7.0;


abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.7.0;




abstract contract Upgradeable is Ownable {

    event StateVerified(address indexed testTarget, address sender);
    event UpgradeFinished(address indexed target, address sender);

    address public target;

    address public previousTarget;

    uint8 public isUpgrade;

    uint256 stubSlot;

    uint8 constant UPGRADE_FALSE = 1;
    uint8 constant UPGRADE_TRUE = 2;

    modifier onlyWhileUpgrading()
    {
        require(isUpgrade == UPGRADE_TRUE);
        _;
    }

    function verifyState(address _testTarget) public virtual onlyWhileUpgrading {
        emit StateVerified(_testTarget, msg.sender);
    }

    function finishUpgrade(address _target) public virtual onlyWhileUpgrading {
        emit UpgradeFinished(_target, msg.sender);
    }

    function delegateGetData(
        address _target,
        bytes4 _selector,
        uint8 _numberOfArguments,
        bytes32 _argument1,
        bytes32 _argument2
    )
        internal returns (bytes32 memoryAddress)
    {
        assembly {
            memoryAddress := mload(0x40)
            mstore(memoryAddress, _selector)
            if gt(_numberOfArguments, 0) {
                mstore(add(memoryAddress, 0x04), _argument1)
            }
            if gt(_numberOfArguments, 1) {
                mstore(add(memoryAddress, 0x24), _argument2)
            }
            switch delegatecall(gas(), _target, memoryAddress, add(0x04, mul(0x20, _numberOfArguments)), 0, 0)
                case 0 {
                    revert(memoryAddress, 0)
                }
                default {
                    returndatacopy(memoryAddress, 0x0, returndatasize())
                }
        }
    }

    function delegateGet(address _target, bytes4 _selector)
        internal returns (uint256 result)
    {
        bytes32 memoryAddress = delegateGetData(_target, _selector, 0, 0, 0);
        assembly {
            result := mload(memoryAddress)
        }
    }

    function delegateGet(address _target, bytes4 _selector, bytes32 _argument)
        internal returns (uint256 result)
    {
        bytes32 memoryAddress = delegateGetData(_target, _selector, 1, _argument, 0);
        assembly {
            result := mload(memoryAddress)
        }
    }

    function delegateGet(
        address _target,
        bytes4 _selector,
        bytes32 _argument1,
        bytes32 _argument2
    )
        internal returns (uint256 result)
    {
        bytes32 memoryAddress = delegateGetData(_target, _selector, 2, _argument1, _argument2);
        assembly {
            result := mload(memoryAddress)
        }
    }
}

pragma solidity ^0.7.0;




abstract contract Issuer is Upgradeable {
    using SafeERC20 for NuCypherToken;
    using AdditionalMath for uint32;

    event Donated(address indexed sender, uint256 value);
    event Initialized(uint256 reservedReward);

    uint128 constant MAX_UINT128 = uint128(0) - 1;

    NuCypherToken public immutable token;
    uint128 public immutable totalSupply;

    uint256 public immutable mintingCoefficient;
    uint256 public immutable lockDurationCoefficient1;
    uint256 public immutable lockDurationCoefficient2;

    uint32 public immutable genesisSecondsPerPeriod;
    uint32 public immutable secondsPerPeriod;

    uint16 public immutable maximumRewardedPeriods;

    uint256 public immutable firstPhaseMaxIssuance;
    uint256 public immutable firstPhaseTotalSupply;

    uint128 public previousPeriodSupply;
    uint128 public currentPeriodSupply;
    uint16 public currentMintingPeriod;

    constructor(
        NuCypherToken _token,
        uint32 _genesisHoursPerPeriod,
        uint32 _hoursPerPeriod,
        uint256 _issuanceDecayCoefficient,
        uint256 _lockDurationCoefficient1,
        uint256 _lockDurationCoefficient2,
        uint16 _maximumRewardedPeriods,
        uint256 _firstPhaseTotalSupply,
        uint256 _firstPhaseMaxIssuance
    ) {
        uint256 localTotalSupply = _token.totalSupply();
        require(localTotalSupply > 0 &&
            _issuanceDecayCoefficient != 0 &&
            _hoursPerPeriod != 0 &&
            _genesisHoursPerPeriod != 0 &&
            _genesisHoursPerPeriod <= _hoursPerPeriod &&
            _lockDurationCoefficient1 != 0 &&
            _lockDurationCoefficient2 != 0 &&
            _maximumRewardedPeriods != 0);
        require(localTotalSupply <= uint256(MAX_UINT128), "Token contract has supply more than supported");

        uint256 maxLockDurationCoefficient = _maximumRewardedPeriods + _lockDurationCoefficient1;
        uint256 localMintingCoefficient = _issuanceDecayCoefficient * _lockDurationCoefficient2;
        require(maxLockDurationCoefficient > _maximumRewardedPeriods &&
            localMintingCoefficient / _issuanceDecayCoefficient ==  _lockDurationCoefficient2 &&
            localTotalSupply * localMintingCoefficient / localTotalSupply == localMintingCoefficient &&
            localTotalSupply * localTotalSupply * maxLockDurationCoefficient / localTotalSupply / localTotalSupply ==
                maxLockDurationCoefficient,
            "Specified parameters cause overflow");

        require(maxLockDurationCoefficient <= _lockDurationCoefficient2,
            "Resulting locking duration coefficient must be less than 1");
        require(_firstPhaseTotalSupply <= localTotalSupply, "Too many tokens for the first phase");
        require(_firstPhaseMaxIssuance <= _firstPhaseTotalSupply, "Reward for the first phase is too high");

        token = _token;
        secondsPerPeriod = _hoursPerPeriod.mul32(1 hours);
        genesisSecondsPerPeriod = _genesisHoursPerPeriod.mul32(1 hours);
        lockDurationCoefficient1 = _lockDurationCoefficient1;
        lockDurationCoefficient2 = _lockDurationCoefficient2;
        maximumRewardedPeriods = _maximumRewardedPeriods;
        firstPhaseTotalSupply = _firstPhaseTotalSupply;
        firstPhaseMaxIssuance = _firstPhaseMaxIssuance;
        totalSupply = uint128(localTotalSupply);
        mintingCoefficient = localMintingCoefficient;
    }

    modifier isInitialized()
    {
        require(currentMintingPeriod != 0);
        _;
    }

    function getCurrentPeriod() public view returns (uint16) {
        return uint16(block.timestamp / secondsPerPeriod);
    }

    function recalculatePeriod(uint16 _period) internal view returns (uint16) {
        return uint16(uint256(_period) * genesisSecondsPerPeriod / secondsPerPeriod);
    }

    function initialize(uint256 _reservedReward, address _sourceOfFunds) external onlyOwner {
        require(currentMintingPeriod == 0);
        require(firstPhaseMaxIssuance <= _reservedReward);
        currentMintingPeriod = getCurrentPeriod();
        currentPeriodSupply = totalSupply - uint128(_reservedReward);
        previousPeriodSupply = currentPeriodSupply;
        token.safeTransferFrom(_sourceOfFunds, address(this), _reservedReward);
        emit Initialized(_reservedReward);
    }

    function mint(
        uint16 _currentPeriod,
        uint256 _lockedValue,
        uint256 _totalLockedValue,
        uint16 _allLockedPeriods
    )
        internal returns (uint256 amount)
    {
        if (currentPeriodSupply == totalSupply) {
            return 0;
        }

        if (_currentPeriod > currentMintingPeriod) {
            previousPeriodSupply = currentPeriodSupply;
            currentMintingPeriod = _currentPeriod;
        }

        uint256 currentReward;
        uint256 coefficient;

        if (previousPeriodSupply + firstPhaseMaxIssuance <= firstPhaseTotalSupply) {
            currentReward = firstPhaseMaxIssuance;
            coefficient = lockDurationCoefficient2;
        } else {
            currentReward = totalSupply - previousPeriodSupply;
            coefficient = mintingCoefficient;
        }

        uint256 allLockedPeriods =
            AdditionalMath.min16(_allLockedPeriods, maximumRewardedPeriods) + lockDurationCoefficient1;
        amount = (uint256(currentReward) * _lockedValue * allLockedPeriods) /
            (_totalLockedValue * coefficient);

        uint256 maxReward = getReservedReward();
        if (amount == 0) {
            amount = 1;
        } else if (amount > maxReward) {
            amount = maxReward;
        }

        currentPeriodSupply += uint128(amount);
    }

    function unMint(uint256 _amount) internal {
        previousPeriodSupply -= uint128(_amount);
        currentPeriodSupply -= uint128(_amount);
    }

    function donate(uint256 _value) external isInitialized {
        token.safeTransferFrom(msg.sender, address(this), _value);
        unMint(_value);
        emit Donated(msg.sender, _value);
    }

    function getReservedReward() public view returns (uint256) {
        return totalSupply - currentPeriodSupply;
    }

    function verifyState(address _testTarget) public override virtual {
        super.verifyState(_testTarget);
        require(uint16(delegateGet(_testTarget, this.currentMintingPeriod.selector)) == currentMintingPeriod);
        require(uint128(delegateGet(_testTarget, this.previousPeriodSupply.selector)) == previousPeriodSupply);
        require(uint128(delegateGet(_testTarget, this.currentPeriodSupply.selector)) == currentPeriodSupply);
    }

    function finishUpgrade(address _target) public override virtual {
        super.finishUpgrade(_target);
        if (currentMintingPeriod > getCurrentPeriod()) {
            currentMintingPeriod = recalculatePeriod(currentMintingPeriod);
        }
    }

}

pragma solidity ^0.7.0;

library Bits {


    uint256 internal constant ONE = uint256(1);

    function toggleBit(uint256 self, uint8 index) internal pure returns (uint256) {

        return self ^ ONE << index;
    }

    function bit(uint256 self, uint8 index) internal pure returns (uint8) {

        return uint8(self >> index & 1);
    }

    function bitSet(uint256 self, uint8 index) internal pure returns (bool) {

        return self >> index & 1 == 1;
    }

}

pragma solidity ^0.7.0;


library Snapshot {


    function encodeSnapshot(uint32 _time, uint96 _value) internal pure returns(uint128) {

        return uint128(uint256(_time) << 96 | uint256(_value));
    }

    function decodeSnapshot(uint128 _snapshot) internal pure returns(uint32 time, uint96 value){

        time = uint32(bytes4(bytes16(_snapshot)));
        value = uint96(_snapshot);
    }

    function addSnapshot(uint128[] storage _self, uint256 _value) internal {

        addSnapshot(_self, block.number, _value);
    }

    function addSnapshot(uint128[] storage _self, uint256 _time, uint256 _value) internal {

        uint256 length = _self.length;
        if (length != 0) {
            (uint32 currentTime, ) = decodeSnapshot(_self[length - 1]);
            if (uint32(_time) == currentTime) {
                _self[length - 1] = encodeSnapshot(uint32(_time), uint96(_value));
                return;
            } else if (uint32(_time) < currentTime){
                revert();
            }
        }
        _self.push(encodeSnapshot(uint32(_time), uint96(_value)));
    }

    function lastSnapshot(uint128[] storage _self) internal view returns (uint32, uint96) {

        uint256 length = _self.length;
        if (length > 0) {
            return decodeSnapshot(_self[length - 1]);
        }

        return (0, 0);
    }

    function lastValue(uint128[] storage _self) internal view returns (uint96) {

        (, uint96 value) = lastSnapshot(_self);
        return value;
    }

    function getValueAt(uint128[] storage _self, uint256 _time256) internal view returns (uint96) {

        uint32 _time = uint32(_time256);
        uint256 length = _self.length;

        if (length == 0) {
            return 0;
        }

        uint256 lastIndex = length - 1;
        (uint32 snapshotTime, uint96 snapshotValue) = decodeSnapshot(_self[length - 1]);
        if (_time >= snapshotTime) {
            return snapshotValue;
        }

        (snapshotTime, snapshotValue) = decodeSnapshot(_self[0]);
        if (length == 1 || _time < snapshotTime) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = lastIndex - 1;
        uint32 midTime;
        uint96 midValue;

        while (high > low) {
            uint256 mid = (high + low + 1) / 2; // average, ceil round
            (midTime, midValue) = decodeSnapshot(_self[mid]);

            if (_time > midTime) {
                low = mid;
            } else if (_time < midTime) {
                high = mid - 1;
            } else {
                return midValue;
            }
        }

        (, snapshotValue) = decodeSnapshot(_self[low]);
        return snapshotValue;
    }
}

pragma solidity ^0.7.0;




interface PolicyManagerInterface {

    function secondsPerPeriod() external view returns (uint32);

    function register(address _node, uint16 _period) external;

    function migrate(address _node) external;

    function ping(
        address _node,
        uint16 _processedPeriod1,
        uint16 _processedPeriod2,
        uint16 _periodToSetDefault
    ) external;

}


interface AdjudicatorInterface {

    function rewardCoefficient() external view returns (uint32);

}


interface WorkLockInterface {

    function token() external view returns (NuCypherToken);

}

contract StakingEscrowStub is Upgradeable {

    using AdditionalMath for uint32;

    NuCypherToken public immutable token;
    uint32 public immutable genesisSecondsPerPeriod;
    uint32 public immutable secondsPerPeriod;
    uint16 public immutable minLockedPeriods;
    uint256 public immutable minAllowableLockedTokens;
    uint256 public immutable maxAllowableLockedTokens;

    constructor(
        NuCypherToken _token,
        uint32 _genesisHoursPerPeriod,
        uint32 _hoursPerPeriod,
        uint16 _minLockedPeriods,
        uint256 _minAllowableLockedTokens,
        uint256 _maxAllowableLockedTokens
    ) {
        require(_token.totalSupply() > 0 &&
            _hoursPerPeriod != 0 &&
            _genesisHoursPerPeriod != 0 &&
            _genesisHoursPerPeriod <= _hoursPerPeriod &&
            _minLockedPeriods > 1 &&
            _maxAllowableLockedTokens != 0);

        token = _token;
        secondsPerPeriod = _hoursPerPeriod.mul32(1 hours);
        genesisSecondsPerPeriod = _genesisHoursPerPeriod.mul32(1 hours);
        minLockedPeriods = _minLockedPeriods;
        minAllowableLockedTokens = _minAllowableLockedTokens;
        maxAllowableLockedTokens = _maxAllowableLockedTokens;
    }

    function verifyState(address _testTarget) public override virtual {

        super.verifyState(_testTarget);

        require(address(delegateGet(_testTarget, this.token.selector)) == address(token));
        require(uint32(delegateGet(_testTarget, this.secondsPerPeriod.selector)) == secondsPerPeriod);
        require(uint16(delegateGet(_testTarget, this.minLockedPeriods.selector)) == minLockedPeriods);
        require(delegateGet(_testTarget, this.minAllowableLockedTokens.selector) == minAllowableLockedTokens);
        require(delegateGet(_testTarget, this.maxAllowableLockedTokens.selector) == maxAllowableLockedTokens);
    }
}


contract StakingEscrow is Issuer, IERC900History {


    using AdditionalMath for uint256;
    using AdditionalMath for uint16;
    using Bits for uint256;
    using SafeMath for uint256;
    using Snapshot for uint128[];
    using SafeERC20 for NuCypherToken;

    event Deposited(address indexed staker, uint256 value, uint16 periods);

    event Locked(address indexed staker, uint256 value, uint16 firstPeriod, uint16 periods);

    event Divided(
        address indexed staker,
        uint256 oldValue,
        uint16 lastPeriod,
        uint256 newValue,
        uint16 periods
    );

    event Merged(address indexed staker, uint256 value1, uint256 value2, uint16 lastPeriod);

    event Prolonged(address indexed staker, uint256 value, uint16 lastPeriod, uint16 periods);

    event Withdrawn(address indexed staker, uint256 value);

    event CommitmentMade(address indexed staker, uint16 indexed period, uint256 value);

    event Minted(address indexed staker, uint16 indexed period, uint256 value);

    event Slashed(address indexed staker, uint256 penalty, address indexed investigator, uint256 reward);

    event ReStakeSet(address indexed staker, bool reStake);

    event WorkerBonded(address indexed staker, address indexed worker, uint16 indexed startPeriod);

    event WindDownSet(address indexed staker, bool windDown);

    event SnapshotSet(address indexed staker, bool snapshotsEnabled);

    event Migrated(address indexed staker, uint16 indexed period);

    event WorkMeasurementSet(address indexed staker, bool measureWork);

    struct SubStakeInfo {
        uint16 firstPeriod;
        uint16 lastPeriod;
        uint16 unlockingDuration;
        uint128 lockedValue;
    }

    struct Downtime {
        uint16 startPeriod;
        uint16 endPeriod;
    }

    struct StakerInfo {
        uint256 value;
        uint16 currentCommittedPeriod;
        uint16 nextCommittedPeriod;
        uint16 lastCommittedPeriod;
        uint16 stub1; // former slot for lockReStakeUntilPeriod
        uint256 completedWork;
        uint16 workerStartPeriod; // period when worker was bonded
        address worker;
        uint256 flags; // uint256 to acquire whole slot and minimize operations on it

        uint256 reservedSlot1;
        uint256 reservedSlot2;
        uint256 reservedSlot3;
        uint256 reservedSlot4;
        uint256 reservedSlot5;

        Downtime[] pastDowntime;
        SubStakeInfo[] subStakes;
        uint128[] history;

    }

    uint16 internal constant RESERVED_PERIOD = 0;
    uint16 internal constant MAX_CHECKED_VALUES = 5;
    uint16 public constant MAX_SUB_STAKES = 30;
    uint16 internal constant MAX_UINT16 = 65535;

    uint8 internal constant RE_STAKE_DISABLED_INDEX = 0;
    uint8 internal constant WIND_DOWN_INDEX = 1;
    uint8 internal constant MEASURE_WORK_INDEX = 2;
    uint8 internal constant SNAPSHOTS_DISABLED_INDEX = 3;
    uint8 internal constant MIGRATED_INDEX = 4;

    uint16 public immutable minLockedPeriods;
    uint16 public immutable minWorkerPeriods;
    uint256 public immutable minAllowableLockedTokens;
    uint256 public immutable maxAllowableLockedTokens;

    PolicyManagerInterface public immutable policyManager;
    AdjudicatorInterface public immutable adjudicator;
    WorkLockInterface public immutable workLock;

    mapping (address => StakerInfo) public stakerInfo;
    address[] public stakers;
    mapping (address => address) public stakerFromWorker;

    mapping (uint16 => uint256) stub4; // former slot for lockedPerPeriod
    uint128[] public balanceHistory;

    address stub1; // former slot for PolicyManager
    address stub2; // former slot for Adjudicator
    address stub3; // former slot for WorkLock

    mapping (uint16 => uint256) _lockedPerPeriod;
    function lockedPerPeriod(uint16 _period) public view returns (uint256) {

        return _period != RESERVED_PERIOD ? _lockedPerPeriod[_period] : 111;
    }

    constructor(
        NuCypherToken _token,
        PolicyManagerInterface _policyManager,
        AdjudicatorInterface _adjudicator,
        WorkLockInterface _workLock,
        uint32 _genesisHoursPerPeriod,
        uint32 _hoursPerPeriod,
        uint256 _issuanceDecayCoefficient,
        uint256 _lockDurationCoefficient1,
        uint256 _lockDurationCoefficient2,
        uint16 _maximumRewardedPeriods,
        uint256 _firstPhaseTotalSupply,
        uint256 _firstPhaseMaxIssuance,
        uint16 _minLockedPeriods,
        uint256 _minAllowableLockedTokens,
        uint256 _maxAllowableLockedTokens,
        uint16 _minWorkerPeriods
    )
        Issuer(
            _token,
            _genesisHoursPerPeriod,
            _hoursPerPeriod,
            _issuanceDecayCoefficient,
            _lockDurationCoefficient1,
            _lockDurationCoefficient2,
            _maximumRewardedPeriods,
            _firstPhaseTotalSupply,
            _firstPhaseMaxIssuance
        )
    {
        require(_minLockedPeriods > 1 && _maxAllowableLockedTokens != 0);
        minLockedPeriods = _minLockedPeriods;
        minAllowableLockedTokens = _minAllowableLockedTokens;
        maxAllowableLockedTokens = _maxAllowableLockedTokens;
        minWorkerPeriods = _minWorkerPeriods;

        require((_policyManager.secondsPerPeriod() == _hoursPerPeriod * (1 hours) ||
            _policyManager.secondsPerPeriod() == _genesisHoursPerPeriod * (1 hours)) &&
            _adjudicator.rewardCoefficient() != 0 &&
            (address(_workLock) == address(0) || _workLock.token() == _token));
        policyManager = _policyManager;
        adjudicator = _adjudicator;
        workLock = _workLock;
    }

    modifier onlyStaker()
    {

        StakerInfo storage info = stakerInfo[msg.sender];
        require((info.value > 0 || info.nextCommittedPeriod != 0) &&
            info.flags.bitSet(MIGRATED_INDEX));
        _;
    }

    function getAllTokens(address _staker) external view returns (uint256) {

        return stakerInfo[_staker].value;
    }

    function getFlags(address _staker)
        external view returns (
            bool windDown,
            bool reStake,
            bool measureWork,
            bool snapshots,
            bool migrated
        )
    {

        StakerInfo storage info = stakerInfo[_staker];
        windDown = info.flags.bitSet(WIND_DOWN_INDEX);
        reStake = !info.flags.bitSet(RE_STAKE_DISABLED_INDEX);
        measureWork = info.flags.bitSet(MEASURE_WORK_INDEX);
        snapshots = !info.flags.bitSet(SNAPSHOTS_DISABLED_INDEX);
        migrated = info.flags.bitSet(MIGRATED_INDEX);
    }

    function getStartPeriod(StakerInfo storage _info, uint16 _currentPeriod)
        internal view returns (uint16)
    {

        if (_info.flags.bitSet(WIND_DOWN_INDEX) && _info.nextCommittedPeriod > _currentPeriod) {
            return _currentPeriod + 1;
        }
        return _currentPeriod;
    }

    function getLastPeriodOfSubStake(SubStakeInfo storage _subStake, uint16 _startPeriod)
        internal view returns (uint16)
    {

        if (_subStake.lastPeriod != 0) {
            return _subStake.lastPeriod;
        }
        uint32 lastPeriod = uint32(_startPeriod) + _subStake.unlockingDuration;
        if (lastPeriod > uint32(MAX_UINT16)) {
            return MAX_UINT16;
        }
        return uint16(lastPeriod);
    }

    function getLastPeriodOfSubStake(address _staker, uint256 _index)
        public view returns (uint16)
    {

        StakerInfo storage info = stakerInfo[_staker];
        SubStakeInfo storage subStake = info.subStakes[_index];
        uint16 startPeriod = getStartPeriod(info, getCurrentPeriod());
        return getLastPeriodOfSubStake(subStake, startPeriod);
    }


    function getLockedTokens(StakerInfo storage _info, uint16 _currentPeriod, uint16 _period)
        internal view returns (uint256 lockedValue)
    {

        lockedValue = 0;
        uint16 startPeriod = getStartPeriod(_info, _currentPeriod);
        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake = _info.subStakes[i];
            if (subStake.firstPeriod <= _period &&
                getLastPeriodOfSubStake(subStake, startPeriod) >= _period) {
                lockedValue += subStake.lockedValue;
            }
        }
    }

    function getLockedTokens(address _staker, uint16 _offsetPeriods)
        external view returns (uint256 lockedValue)
    {

        StakerInfo storage info = stakerInfo[_staker];
        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod.add16(_offsetPeriods);
        return getLockedTokens(info, currentPeriod, nextPeriod);
    }

    function getLastCommittedPeriod(address _staker) public view returns (uint16) {

        StakerInfo storage info = stakerInfo[_staker];
        return info.nextCommittedPeriod != 0 ? info.nextCommittedPeriod : info.lastCommittedPeriod;
    }

    function getActiveStakers(uint16 _offsetPeriods, uint256 _startIndex, uint256 _maxStakers)
        external view returns (uint256 allLockedTokens, uint256[2][] memory activeStakers)
    {

        require(_offsetPeriods > 0);

        uint256 endIndex = stakers.length;
        require(_startIndex < endIndex);
        if (_maxStakers != 0 && _startIndex + _maxStakers < endIndex) {
            endIndex = _startIndex + _maxStakers;
        }
        activeStakers = new uint256[2][](endIndex - _startIndex);
        allLockedTokens = 0;

        uint256 resultIndex = 0;
        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod.add16(_offsetPeriods);

        for (uint256 i = _startIndex; i < endIndex; i++) {
            address staker = stakers[i];
            StakerInfo storage info = stakerInfo[staker];
            if (info.currentCommittedPeriod != currentPeriod &&
                info.nextCommittedPeriod != currentPeriod) {
                continue;
            }
            uint256 lockedTokens = getLockedTokens(info, currentPeriod, nextPeriod);
            if (lockedTokens != 0) {
                activeStakers[resultIndex][0] = uint256(staker);
                activeStakers[resultIndex++][1] = lockedTokens;
                allLockedTokens += lockedTokens;
            }
        }
        assembly {
            mstore(activeStakers, resultIndex)
        }
    }

    function getWorkerFromStaker(address _staker) external view returns (address) {

        return stakerInfo[_staker].worker;
    }

    function getCompletedWork(address _staker) external view returns (uint256) {

        return stakerInfo[_staker].completedWork;
    }

    function findIndexOfPastDowntime(address _staker, uint16 _period) external view returns (uint256 index) {

        StakerInfo storage info = stakerInfo[_staker];
        for (index = 0; index < info.pastDowntime.length; index++) {
            if (_period <= info.pastDowntime[index].endPeriod) {
                return index;
            }
        }
    }

    function setWorkMeasurement(address _staker, bool _measureWork) external returns (uint256) {

        require(msg.sender == address(workLock));
        StakerInfo storage info = stakerInfo[_staker];
        if (info.flags.bitSet(MEASURE_WORK_INDEX) == _measureWork) {
            return info.completedWork;
        }
        info.flags = info.flags.toggleBit(MEASURE_WORK_INDEX);
        emit WorkMeasurementSet(_staker, _measureWork);
        return info.completedWork;
    }

    function bondWorker(address _worker) external onlyStaker {

        StakerInfo storage info = stakerInfo[msg.sender];
        require(_worker != info.worker);
        uint16 currentPeriod = getCurrentPeriod();
        if (info.worker != address(0)) { // If this staker had a worker ...
            require(currentPeriod >= info.workerStartPeriod.add16(minWorkerPeriods));
            stakerFromWorker[info.worker] = address(0);
        }

        if (_worker != address(0)) {
            require(stakerFromWorker[_worker] == address(0));
            require(stakerInfo[_worker].subStakes.length == 0 || _worker == msg.sender);
            stakerFromWorker[_worker] = msg.sender;
        }

        info.worker = _worker;
        info.workerStartPeriod = currentPeriod;
        emit WorkerBonded(msg.sender, _worker, currentPeriod);
    }

    function setReStake(bool _reStake) external {

        StakerInfo storage info = stakerInfo[msg.sender];
        if (info.flags.bitSet(RE_STAKE_DISABLED_INDEX) == !_reStake) {
            return;
        }
        info.flags = info.flags.toggleBit(RE_STAKE_DISABLED_INDEX);
        emit ReStakeSet(msg.sender, _reStake);
    }

    function depositFromWorkLock(
        address _staker,
        uint256 _value,
        uint16 _unlockingDuration
    )
        external
    {

        require(msg.sender == address(workLock));
        StakerInfo storage info = stakerInfo[_staker];
        if (!info.flags.bitSet(WIND_DOWN_INDEX) && info.subStakes.length == 0) {
            info.flags = info.flags.toggleBit(WIND_DOWN_INDEX);
            emit WindDownSet(_staker, true);
        }
        _unlockingDuration = recalculatePeriod(_unlockingDuration);
        deposit(_staker, msg.sender, MAX_SUB_STAKES, _value, _unlockingDuration);
    }

    function setWindDown(bool _windDown) external {

        StakerInfo storage info = stakerInfo[msg.sender];
        if (info.flags.bitSet(WIND_DOWN_INDEX) == _windDown) {
            return;
        }
        info.flags = info.flags.toggleBit(WIND_DOWN_INDEX);
        emit WindDownSet(msg.sender, _windDown);

        uint16 nextPeriod = getCurrentPeriod() + 1;
        if (info.nextCommittedPeriod != nextPeriod) {
           return;
        }

        for (uint256 index = 0; index < info.subStakes.length; index++) {
            SubStakeInfo storage subStake = info.subStakes[index];
            if (!_windDown && subStake.lastPeriod == nextPeriod) {
                subStake.lastPeriod = 0;
                subStake.unlockingDuration = 1;
                continue;
            }
            if (subStake.lastPeriod != 0 || subStake.unlockingDuration == 0) {
                continue;
            }

            subStake.unlockingDuration = _windDown ? subStake.unlockingDuration - 1 : subStake.unlockingDuration + 1;
            if (subStake.unlockingDuration == 0) {
                subStake.lastPeriod = nextPeriod;
            }
        }
    }

    function setSnapshots(bool _enableSnapshots) external {

        StakerInfo storage info = stakerInfo[msg.sender];
        if (info.flags.bitSet(SNAPSHOTS_DISABLED_INDEX) == !_enableSnapshots) {
            return;
        }

        uint256 lastGlobalBalance = uint256(balanceHistory.lastValue());
        if(_enableSnapshots){
            info.history.addSnapshot(info.value);
            balanceHistory.addSnapshot(lastGlobalBalance + info.value);
        } else {
            info.history.addSnapshot(0);
            balanceHistory.addSnapshot(lastGlobalBalance - info.value);
        }
        info.flags = info.flags.toggleBit(SNAPSHOTS_DISABLED_INDEX);

        emit SnapshotSet(msg.sender, _enableSnapshots);
    }

    function addSnapshot(StakerInfo storage _info, int256 _addition) internal {

        if(!_info.flags.bitSet(SNAPSHOTS_DISABLED_INDEX)){
            _info.history.addSnapshot(_info.value);
            uint256 lastGlobalBalance = uint256(balanceHistory.lastValue());
            balanceHistory.addSnapshot(lastGlobalBalance.addSigned(_addition));
        }
    }

    function receiveApproval(
        address _from,
        uint256 _value,
        address _tokenContract,
        bytes calldata /* _extraData */
    )
        external
    {

        require(_tokenContract == address(token) && msg.sender == address(token));


        uint256 payloadSize;
        uint256 payload;
        assembly {
            payloadSize := calldataload(0x84)
            payload := calldataload(0xA4)
        }
        payload = payload >> 8*(32 - payloadSize);
        deposit(_from, _from, MAX_SUB_STAKES, _value, uint16(payload));
    }

    function deposit(address _staker, uint256 _value, uint16 _unlockingDuration) external {

        deposit(_staker, msg.sender, MAX_SUB_STAKES, _value, _unlockingDuration);
    }

    function depositAndIncrease(uint256 _index, uint256 _value) external onlyStaker {

        require(_index < MAX_SUB_STAKES);
        deposit(msg.sender, msg.sender, _index, _value, 0);
    }

    function deposit(address _staker, address _payer, uint256 _index, uint256 _value, uint16 _unlockingDuration) internal {

        require(_value != 0);
        StakerInfo storage info = stakerInfo[_staker];
        require(stakerFromWorker[_staker] == address(0) || stakerFromWorker[_staker] == info.worker);
        if (info.subStakes.length == 0 && info.lastCommittedPeriod == 0) {
            stakers.push(_staker);
            policyManager.register(_staker, getCurrentPeriod() - 1);
            info.flags = info.flags.toggleBit(MIGRATED_INDEX);
        }
        require(info.flags.bitSet(MIGRATED_INDEX));
        token.safeTransferFrom(_payer, address(this), _value);
        info.value += _value;
        lock(_staker, _index, _value, _unlockingDuration);

        addSnapshot(info, int256(_value));
        if (_index >= MAX_SUB_STAKES) {
            emit Deposited(_staker, _value, _unlockingDuration);
        } else {
            uint16 lastPeriod = getLastPeriodOfSubStake(_staker, _index);
            emit Deposited(_staker, _value, lastPeriod - getCurrentPeriod());
        }
    }

    function lockAndCreate(uint256 _value, uint16 _unlockingDuration) external onlyStaker {

        lock(msg.sender, MAX_SUB_STAKES, _value, _unlockingDuration);
    }

    function lockAndIncrease(uint256 _index, uint256 _value) external onlyStaker {

        require(_index < MAX_SUB_STAKES);
        lock(msg.sender, _index, _value, 0);
    }

    function lock(address _staker, uint256 _index, uint256 _value, uint16 _unlockingDuration) internal {

        if (_index < MAX_SUB_STAKES) {
            require(_value > 0);
        } else {
            require(_value >= minAllowableLockedTokens && _unlockingDuration >= minLockedPeriods);
        }

        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod + 1;
        StakerInfo storage info = stakerInfo[_staker];
        uint256 lockedTokens = getLockedTokens(info, currentPeriod, nextPeriod);
        uint256 requestedLockedTokens = _value.add(lockedTokens);
        require(requestedLockedTokens <= info.value && requestedLockedTokens <= maxAllowableLockedTokens);

        if (info.nextCommittedPeriod == nextPeriod) {
            _lockedPerPeriod[nextPeriod] += _value;
            emit CommitmentMade(_staker, nextPeriod, _value);
        }

        if (_index < MAX_SUB_STAKES) {
            lockAndIncrease(info, currentPeriod, nextPeriod, _staker, _index, _value);
        } else {
            lockAndCreate(info, nextPeriod, _staker, _value, _unlockingDuration);
        }
    }

    function lockAndCreate(
        StakerInfo storage _info,
        uint16 _nextPeriod,
        address _staker,
        uint256 _value,
        uint16 _unlockingDuration
    )
        internal
    {

        uint16 duration = _unlockingDuration;
        if (_info.nextCommittedPeriod == _nextPeriod && _info.flags.bitSet(WIND_DOWN_INDEX)) {
            duration -= 1;
        }
        saveSubStake(_info, _nextPeriod, 0, duration, _value);

        emit Locked(_staker, _value, _nextPeriod, _unlockingDuration);
    }

    function lockAndIncrease(
        StakerInfo storage _info,
        uint16 _currentPeriod,
        uint16 _nextPeriod,
        address _staker,
        uint256 _index,
        uint256 _value
    )
        internal
    {

        SubStakeInfo storage subStake = _info.subStakes[_index];
        (, uint16 lastPeriod) = checkLastPeriodOfSubStake(_info, subStake, _currentPeriod);

        if (_info.currentCommittedPeriod != 0 &&
            _info.currentCommittedPeriod <= _currentPeriod ||
            _info.nextCommittedPeriod != 0 &&
            _info.nextCommittedPeriod <= _currentPeriod)
        {
            saveSubStake(_info, subStake.firstPeriod, _currentPeriod, 0, subStake.lockedValue);
        }

        subStake.lockedValue += uint128(_value);
        subStake.firstPeriod = _nextPeriod;

        emit Locked(_staker, _value, _nextPeriod, lastPeriod - _currentPeriod);
    }

    function checkLastPeriodOfSubStake(
        StakerInfo storage _info,
        SubStakeInfo storage _subStake,
        uint16 _currentPeriod
    )
        internal view returns (uint16 startPeriod, uint16 lastPeriod)
    {

        startPeriod = getStartPeriod(_info, _currentPeriod);
        lastPeriod = getLastPeriodOfSubStake(_subStake, startPeriod);
        require(lastPeriod > _currentPeriod);
    }

    function saveSubStake(
        StakerInfo storage _info,
        uint16 _firstPeriod,
        uint16 _lastPeriod,
        uint16 _unlockingDuration,
        uint256 _lockedValue
    )
        internal
    {

        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake = _info.subStakes[i];
            if (subStake.lastPeriod != 0 &&
                (_info.currentCommittedPeriod == 0 ||
                subStake.lastPeriod < _info.currentCommittedPeriod) &&
                (_info.nextCommittedPeriod == 0 ||
                subStake.lastPeriod < _info.nextCommittedPeriod))
            {
                subStake.firstPeriod = _firstPeriod;
                subStake.lastPeriod = _lastPeriod;
                subStake.unlockingDuration = _unlockingDuration;
                subStake.lockedValue = uint128(_lockedValue);
                return;
            }
        }
        require(_info.subStakes.length < MAX_SUB_STAKES);
        _info.subStakes.push(SubStakeInfo(_firstPeriod, _lastPeriod, _unlockingDuration, uint128(_lockedValue)));
    }

    function divideStake(uint256 _index, uint256 _newValue, uint16 _additionalDuration) external onlyStaker {

        StakerInfo storage info = stakerInfo[msg.sender];
        require(_newValue >= minAllowableLockedTokens && _additionalDuration > 0);
        SubStakeInfo storage subStake = info.subStakes[_index];
        uint16 currentPeriod = getCurrentPeriod();
        (, uint16 lastPeriod) = checkLastPeriodOfSubStake(info, subStake, currentPeriod);

        uint256 oldValue = subStake.lockedValue;
        subStake.lockedValue = uint128(oldValue.sub(_newValue));
        require(subStake.lockedValue >= minAllowableLockedTokens);
        uint16 requestedPeriods = subStake.unlockingDuration.add16(_additionalDuration);
        saveSubStake(info, subStake.firstPeriod, 0, requestedPeriods, _newValue);
        emit Divided(msg.sender, oldValue, lastPeriod, _newValue, _additionalDuration);
        emit Locked(msg.sender, _newValue, subStake.firstPeriod, requestedPeriods);
    }

    function prolongStake(uint256 _index, uint16 _additionalDuration) external onlyStaker {

        StakerInfo storage info = stakerInfo[msg.sender];
        require(_additionalDuration > 0);
        SubStakeInfo storage subStake = info.subStakes[_index];
        uint16 currentPeriod = getCurrentPeriod();
        (uint16 startPeriod, uint16 lastPeriod) = checkLastPeriodOfSubStake(info, subStake, currentPeriod);

        subStake.unlockingDuration = subStake.unlockingDuration.add16(_additionalDuration);
        if (lastPeriod == startPeriod) {
            subStake.lastPeriod = 0;
        }
        require(uint32(lastPeriod - currentPeriod) + _additionalDuration >= minLockedPeriods);
        emit Locked(msg.sender, subStake.lockedValue, lastPeriod + 1, _additionalDuration);
        emit Prolonged(msg.sender, subStake.lockedValue, lastPeriod, _additionalDuration);
    }

    function mergeStake(uint256 _index1, uint256 _index2) external onlyStaker {

        require(_index1 != _index2); // must be different sub-stakes

        StakerInfo storage info = stakerInfo[msg.sender];
        SubStakeInfo storage subStake1 = info.subStakes[_index1];
        SubStakeInfo storage subStake2 = info.subStakes[_index2];
        uint16 currentPeriod = getCurrentPeriod();

        (, uint16 lastPeriod1) = checkLastPeriodOfSubStake(info, subStake1, currentPeriod);
        (, uint16 lastPeriod2) = checkLastPeriodOfSubStake(info, subStake2, currentPeriod);
        require(lastPeriod1 == lastPeriod2);
        emit Merged(msg.sender, subStake1.lockedValue, subStake2.lockedValue, lastPeriod1);

        if (subStake1.firstPeriod == subStake2.firstPeriod) {
            subStake1.lockedValue += subStake2.lockedValue;
            subStake2.lastPeriod = 1;
            subStake2.unlockingDuration = 0;
        } else if (subStake1.firstPeriod > subStake2.firstPeriod) {
            subStake1.lockedValue += subStake2.lockedValue;
            subStake2.lastPeriod = subStake1.firstPeriod - 1;
            subStake2.unlockingDuration = 0;
        } else {
            subStake2.lockedValue += subStake1.lockedValue;
            subStake1.lastPeriod = subStake2.firstPeriod - 1;
            subStake1.unlockingDuration = 0;
        }
    }

    function removeUnusedSubStake(uint16 _index) external onlyStaker {

        StakerInfo storage info = stakerInfo[msg.sender];

        uint256 lastIndex = info.subStakes.length - 1;
        SubStakeInfo storage subStake = info.subStakes[_index];
        require(subStake.lastPeriod != 0 &&
                (info.currentCommittedPeriod == 0 ||
                subStake.lastPeriod < info.currentCommittedPeriod) &&
                (info.nextCommittedPeriod == 0 ||
                subStake.lastPeriod < info.nextCommittedPeriod));

        if (_index != lastIndex) {
            SubStakeInfo storage lastSubStake = info.subStakes[lastIndex];
            subStake.firstPeriod = lastSubStake.firstPeriod;
            subStake.lastPeriod = lastSubStake.lastPeriod;
            subStake.unlockingDuration = lastSubStake.unlockingDuration;
            subStake.lockedValue = lastSubStake.lockedValue;
        }
        info.subStakes.pop();
    }

    function withdraw(uint256 _value) external onlyStaker {

        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod + 1;
        StakerInfo storage info = stakerInfo[msg.sender];
        uint256 lockedTokens = Math.max(getLockedTokens(info, currentPeriod, nextPeriod),
            getLockedTokens(info, currentPeriod, currentPeriod));
        require(_value <= info.value.sub(lockedTokens));
        info.value -= _value;

        addSnapshot(info, - int256(_value));
        token.safeTransfer(msg.sender, _value);
        emit Withdrawn(msg.sender, _value);

        if (info.value == 0 &&
            info.nextCommittedPeriod == 0 &&
            info.worker != address(0))
        {
            stakerFromWorker[info.worker] = address(0);
            info.worker = address(0);
            emit WorkerBonded(msg.sender, address(0), currentPeriod);
        }
    }

    function commitToNextPeriod() external isInitialized {

        address staker = stakerFromWorker[msg.sender];
        StakerInfo storage info = stakerInfo[staker];
        require(info.value > 0);
        require(msg.sender == tx.origin);

        migrate(staker);

        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod + 1;
        require(info.nextCommittedPeriod != nextPeriod);

        uint16 lastCommittedPeriod = getLastCommittedPeriod(staker);
        (uint16 processedPeriod1, uint16 processedPeriod2) = mint(staker);

        uint256 lockedTokens = getLockedTokens(info, currentPeriod, nextPeriod);
        require(lockedTokens > 0);
        _lockedPerPeriod[nextPeriod] += lockedTokens;

        info.currentCommittedPeriod = info.nextCommittedPeriod;
        info.nextCommittedPeriod = nextPeriod;

        decreaseSubStakesDuration(info, nextPeriod);

        if (lastCommittedPeriod < currentPeriod) {
            info.pastDowntime.push(Downtime(lastCommittedPeriod + 1, currentPeriod));
        }

        policyManager.ping(staker, processedPeriod1, processedPeriod2, nextPeriod);
        emit CommitmentMade(staker, nextPeriod, lockedTokens);
    }

    function migrate(address _staker) public {

        StakerInfo storage info = stakerInfo[_staker];
        require(info.subStakes.length != 0 || info.lastCommittedPeriod != 0);
        if (info.flags.bitSet(MIGRATED_INDEX)) {
            return;
        }

        info.currentCommittedPeriod = 0;
        info.nextCommittedPeriod = 0;
        info.lastCommittedPeriod = 1;
        info.workerStartPeriod = recalculatePeriod(info.workerStartPeriod);
        delete info.pastDowntime;

        uint16 currentPeriod = getCurrentPeriod();
        for (uint256 i = 0; i < info.subStakes.length; i++) {
            SubStakeInfo storage subStake = info.subStakes[i];
            subStake.firstPeriod = recalculatePeriod(subStake.firstPeriod);
            if (subStake.lastPeriod != 0) {
                subStake.lastPeriod = recalculatePeriod(subStake.lastPeriod);
                if (subStake.lastPeriod == 0) {
                    subStake.lastPeriod = 1;
                }
                subStake.unlockingDuration = 0;
            } else {
                uint16 oldCurrentPeriod = uint16(block.timestamp / genesisSecondsPerPeriod);
                uint16 lastPeriod = recalculatePeriod(oldCurrentPeriod + subStake.unlockingDuration);
                subStake.unlockingDuration = lastPeriod - currentPeriod;
                if (subStake.unlockingDuration == 0) {
                    subStake.lastPeriod = lastPeriod;
                }
            }
        }

        policyManager.migrate(_staker);
        info.flags = info.flags.toggleBit(MIGRATED_INDEX);
        emit Migrated(_staker, currentPeriod);
    }

    function decreaseSubStakesDuration(StakerInfo storage _info, uint16 _nextPeriod) internal {

        if (!_info.flags.bitSet(WIND_DOWN_INDEX)) {
            return;
        }
        for (uint256 index = 0; index < _info.subStakes.length; index++) {
            SubStakeInfo storage subStake = _info.subStakes[index];
            if (subStake.lastPeriod != 0 || subStake.unlockingDuration == 0) {
                continue;
            }
            subStake.unlockingDuration--;
            if (subStake.unlockingDuration == 0) {
                subStake.lastPeriod = _nextPeriod;
            }
        }
    }

    function mint() external onlyStaker {

        StakerInfo storage info = stakerInfo[msg.sender];
        uint16 previousPeriod = getCurrentPeriod() - 1;
        if (info.nextCommittedPeriod <= previousPeriod && info.nextCommittedPeriod != 0) {
            info.lastCommittedPeriod = info.nextCommittedPeriod;
        }
        (uint16 processedPeriod1, uint16 processedPeriod2) = mint(msg.sender);

        if (processedPeriod1 != 0 || processedPeriod2 != 0) {
            policyManager.ping(msg.sender, processedPeriod1, processedPeriod2, 0);
        }
    }

    function mint(address _staker) internal returns (uint16 processedPeriod1, uint16 processedPeriod2) {

        uint16 currentPeriod = getCurrentPeriod();
        uint16 previousPeriod = currentPeriod - 1;
        StakerInfo storage info = stakerInfo[_staker];

        if (info.nextCommittedPeriod == 0 ||
            info.currentCommittedPeriod == 0 &&
            info.nextCommittedPeriod > previousPeriod ||
            info.currentCommittedPeriod > previousPeriod) {
            return (0, 0);
        }

        uint16 startPeriod = getStartPeriod(info, currentPeriod);
        uint256 reward = 0;
        bool reStake = !info.flags.bitSet(RE_STAKE_DISABLED_INDEX);

        if (info.currentCommittedPeriod != 0) {
            reward = mint(info, info.currentCommittedPeriod, currentPeriod, startPeriod, reStake);
            processedPeriod1 = info.currentCommittedPeriod;
            info.currentCommittedPeriod = 0;
            if (reStake) {
                _lockedPerPeriod[info.nextCommittedPeriod] += reward;
            }
        }
        if (info.nextCommittedPeriod <= previousPeriod) {
            reward += mint(info, info.nextCommittedPeriod, currentPeriod, startPeriod, reStake);
            processedPeriod2 = info.nextCommittedPeriod;
            info.nextCommittedPeriod = 0;
        }

        info.value += reward;
        if (info.flags.bitSet(MEASURE_WORK_INDEX)) {
            info.completedWork += reward;
        }

        addSnapshot(info, int256(reward));
        emit Minted(_staker, previousPeriod, reward);
    }

    function mint(
        StakerInfo storage _info,
        uint16 _mintingPeriod,
        uint16 _currentPeriod,
        uint16 _startPeriod,
        bool _reStake
    )
        internal returns (uint256 reward)
    {

        reward = 0;
        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake =  _info.subStakes[i];
            uint16 lastPeriod = getLastPeriodOfSubStake(subStake, _startPeriod);
            if (subStake.firstPeriod <= _mintingPeriod && lastPeriod >= _mintingPeriod) {
                uint256 subStakeReward = mint(
                    _currentPeriod,
                    subStake.lockedValue,
                    _lockedPerPeriod[_mintingPeriod],
                    lastPeriod.sub16(_mintingPeriod));
                reward += subStakeReward;
                if (_reStake) {
                    subStake.lockedValue += uint128(subStakeReward);
                }
            }
        }
        return reward;
    }

    function slashStaker(
        address _staker,
        uint256 _penalty,
        address _investigator,
        uint256 _reward
    )
        public isInitialized
    {

        require(msg.sender == address(adjudicator));
        require(_penalty > 0);
        StakerInfo storage info = stakerInfo[_staker];
        require(info.flags.bitSet(MIGRATED_INDEX));
        if (info.value <= _penalty) {
            _penalty = info.value;
        }
        info.value -= _penalty;
        if (_reward > _penalty) {
            _reward = _penalty;
        }

        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod + 1;
        uint16 startPeriod = getStartPeriod(info, currentPeriod);

        (uint256 currentLock, uint256 nextLock, uint256 currentAndNextLock, uint256 shortestSubStakeIndex) =
            getLockedTokensAndShortestSubStake(info, currentPeriod, nextPeriod, startPeriod);

        uint256 lockedTokens = currentLock + currentAndNextLock;
        if (info.value < lockedTokens) {
           decreaseSubStakes(info, lockedTokens - info.value, currentPeriod, startPeriod, shortestSubStakeIndex);
        }
        if (nextLock > 0) {
            lockedTokens = nextLock + currentAndNextLock -
                (currentAndNextLock > info.value ? currentAndNextLock - info.value : 0);
            if (info.value < lockedTokens) {
               decreaseSubStakes(info, lockedTokens - info.value, nextPeriod, startPeriod, MAX_SUB_STAKES);
            }
        }

        emit Slashed(_staker, _penalty, _investigator, _reward);
        if (_penalty > _reward) {
            unMint(_penalty - _reward);
        }
        if (_reward > 0) {
            token.safeTransfer(_investigator, _reward);
        }

        addSnapshot(info, - int256(_penalty));

    }

    function getLockedTokensAndShortestSubStake(
        StakerInfo storage _info,
        uint16 _currentPeriod,
        uint16 _nextPeriod,
        uint16 _startPeriod
    )
        internal view returns (
            uint256 currentLock,
            uint256 nextLock,
            uint256 currentAndNextLock,
            uint256 shortestSubStakeIndex
        )
    {

        uint16 minDuration = MAX_UINT16;
        uint16 minLastPeriod = MAX_UINT16;
        shortestSubStakeIndex = MAX_SUB_STAKES;
        currentLock = 0;
        nextLock = 0;
        currentAndNextLock = 0;

        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake = _info.subStakes[i];
            uint16 lastPeriod = getLastPeriodOfSubStake(subStake, _startPeriod);
            if (lastPeriod < subStake.firstPeriod) {
                continue;
            }
            if (subStake.firstPeriod <= _currentPeriod &&
                lastPeriod >= _nextPeriod) {
                currentAndNextLock += subStake.lockedValue;
            } else if (subStake.firstPeriod <= _currentPeriod &&
                lastPeriod >= _currentPeriod) {
                currentLock += subStake.lockedValue;
            } else if (subStake.firstPeriod <= _nextPeriod &&
                lastPeriod >= _nextPeriod) {
                nextLock += subStake.lockedValue;
            }
            uint16 duration = lastPeriod - subStake.firstPeriod;
            if (subStake.firstPeriod <= _currentPeriod &&
                lastPeriod >= _currentPeriod &&
                (lastPeriod < minLastPeriod ||
                lastPeriod == minLastPeriod && duration < minDuration))
            {
                shortestSubStakeIndex = i;
                minDuration = duration;
                minLastPeriod = lastPeriod;
            }
        }
    }

    function decreaseSubStakes(
        StakerInfo storage _info,
        uint256 _penalty,
        uint16 _decreasePeriod,
        uint16 _startPeriod,
        uint256 _shortestSubStakeIndex
    )
        internal
    {

        SubStakeInfo storage shortestSubStake = _info.subStakes[0];
        uint16 minSubStakeLastPeriod = MAX_UINT16;
        uint16 minSubStakeDuration = MAX_UINT16;
        while(_penalty > 0) {
            if (_shortestSubStakeIndex < MAX_SUB_STAKES) {
                shortestSubStake = _info.subStakes[_shortestSubStakeIndex];
                minSubStakeLastPeriod = getLastPeriodOfSubStake(shortestSubStake, _startPeriod);
                minSubStakeDuration = minSubStakeLastPeriod - shortestSubStake.firstPeriod;
                _shortestSubStakeIndex = MAX_SUB_STAKES;
            } else {
                (shortestSubStake, minSubStakeDuration, minSubStakeLastPeriod) =
                    getShortestSubStake(_info, _decreasePeriod, _startPeriod);
            }
            if (minSubStakeDuration == MAX_UINT16) {
                break;
            }
            uint256 appliedPenalty = _penalty;
            if (_penalty < shortestSubStake.lockedValue) {
                shortestSubStake.lockedValue -= uint128(_penalty);
                saveOldSubStake(_info, shortestSubStake.firstPeriod, _penalty, _decreasePeriod);
                _penalty = 0;
            } else {
                shortestSubStake.lastPeriod = _decreasePeriod - 1;
                _penalty -= shortestSubStake.lockedValue;
                appliedPenalty = shortestSubStake.lockedValue;
            }
            if (_info.currentCommittedPeriod >= _decreasePeriod &&
                _info.currentCommittedPeriod <= minSubStakeLastPeriod)
            {
                _lockedPerPeriod[_info.currentCommittedPeriod] -= appliedPenalty;
            }
            if (_info.nextCommittedPeriod >= _decreasePeriod &&
                _info.nextCommittedPeriod <= minSubStakeLastPeriod)
            {
                _lockedPerPeriod[_info.nextCommittedPeriod] -= appliedPenalty;
            }
        }
    }

    function getShortestSubStake(
        StakerInfo storage _info,
        uint16 _currentPeriod,
        uint16 _startPeriod
    )
        internal view returns (
            SubStakeInfo storage shortestSubStake,
            uint16 minSubStakeDuration,
            uint16 minSubStakeLastPeriod
        )
    {

        shortestSubStake = shortestSubStake;
        minSubStakeDuration = MAX_UINT16;
        minSubStakeLastPeriod = MAX_UINT16;
        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake = _info.subStakes[i];
            uint16 lastPeriod = getLastPeriodOfSubStake(subStake, _startPeriod);
            if (lastPeriod < subStake.firstPeriod) {
                continue;
            }
            uint16 duration = lastPeriod - subStake.firstPeriod;
            if (subStake.firstPeriod <= _currentPeriod &&
                lastPeriod >= _currentPeriod &&
                (lastPeriod < minSubStakeLastPeriod ||
                lastPeriod == minSubStakeLastPeriod && duration < minSubStakeDuration))
            {
                shortestSubStake = subStake;
                minSubStakeDuration = duration;
                minSubStakeLastPeriod = lastPeriod;
            }
        }
    }

    function saveOldSubStake(
        StakerInfo storage _info,
        uint16 _firstPeriod,
        uint256 _lockedValue,
        uint16 _currentPeriod
    )
        internal
    {

        bool oldCurrentCommittedPeriod = _info.currentCommittedPeriod != 0 &&
            _info.currentCommittedPeriod < _currentPeriod;
        bool oldnextCommittedPeriod = _info.nextCommittedPeriod != 0 &&
            _info.nextCommittedPeriod < _currentPeriod;
        bool crosscurrentCommittedPeriod = oldCurrentCommittedPeriod && _info.currentCommittedPeriod >= _firstPeriod;
        bool crossnextCommittedPeriod = oldnextCommittedPeriod && _info.nextCommittedPeriod >= _firstPeriod;
        if (!crosscurrentCommittedPeriod && !crossnextCommittedPeriod) {
            return;
        }
        uint16 previousPeriod = _currentPeriod - 1;
        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake = _info.subStakes[i];
            if (subStake.lastPeriod == previousPeriod &&
                ((crosscurrentCommittedPeriod ==
                (oldCurrentCommittedPeriod && _info.currentCommittedPeriod >= subStake.firstPeriod)) &&
                (crossnextCommittedPeriod ==
                (oldnextCommittedPeriod && _info.nextCommittedPeriod >= subStake.firstPeriod))))
            {
                subStake.lockedValue += uint128(_lockedValue);
                return;
            }
        }
        saveSubStake(_info, _firstPeriod, previousPeriod, 0, _lockedValue);
    }

    function getStakersLength() external view returns (uint256) {

        return stakers.length;
    }

    function getSubStakesLength(address _staker) external view returns (uint256) {

        return stakerInfo[_staker].subStakes.length;
    }

    function getSubStakeInfo(address _staker, uint256 _index)
        external view virtual returns (
            uint16 firstPeriod,
            uint16 lastPeriod,
            uint16 unlockingDuration,
            uint128 lockedValue
        )
    {

        SubStakeInfo storage info = stakerInfo[_staker].subStakes[_index];
        firstPeriod = info.firstPeriod;
        lastPeriod = info.lastPeriod;
        unlockingDuration = info.unlockingDuration;
        lockedValue = info.lockedValue;
    }

    function getPastDowntimeLength(address _staker) external view returns (uint256) {

        return stakerInfo[_staker].pastDowntime.length;
    }

    function  getPastDowntime(address _staker, uint256 _index)
        external view returns (uint16 startPeriod, uint16 endPeriod)
    {
        Downtime storage downtime = stakerInfo[_staker].pastDowntime[_index];
        startPeriod = downtime.startPeriod;
        endPeriod = downtime.endPeriod;
    }


    function totalStakedForAt(address _owner, uint256 _blockNumber) public view override returns (uint256){

        return stakerInfo[_owner].history.getValueAt(_blockNumber);
    }

    function totalStakedAt(uint256 _blockNumber) public view override returns (uint256){

        return balanceHistory.getValueAt(_blockNumber);
    }

    function supportsHistory() external pure override returns (bool){

        return true;
    }

    function delegateGetStakerInfo(address _target, bytes32 _staker)
        internal returns (StakerInfo memory result)
    {

        bytes32 memoryAddress = delegateGetData(_target, this.stakerInfo.selector, 1, _staker, 0);
        assembly {
            result := memoryAddress
        }
    }

    function delegateGetSubStakeInfo(address _target, bytes32 _staker, uint256 _index)
        internal returns (SubStakeInfo memory result)
    {

        bytes32 memoryAddress = delegateGetData(
            _target, this.getSubStakeInfo.selector, 2, _staker, bytes32(_index));
        assembly {
            result := memoryAddress
        }
    }

    function delegateGetPastDowntime(address _target, bytes32 _staker, uint256 _index)
        internal returns (Downtime memory result)
    {

        bytes32 memoryAddress = delegateGetData(
            _target, this.getPastDowntime.selector, 2, _staker, bytes32(_index));
        assembly {
            result := memoryAddress
        }
    }

    function verifyState(address _testTarget) public override virtual {

        super.verifyState(_testTarget);
        require(delegateGet(_testTarget, this.lockedPerPeriod.selector,
            bytes32(bytes2(RESERVED_PERIOD))) == lockedPerPeriod(RESERVED_PERIOD));
        require(address(delegateGet(_testTarget, this.stakerFromWorker.selector, bytes32(0))) ==
            stakerFromWorker[address(0)]);

        require(delegateGet(_testTarget, this.getStakersLength.selector) == stakers.length);
        if (stakers.length == 0) {
            return;
        }
        address stakerAddress = stakers[0];
        require(address(uint160(delegateGet(_testTarget, this.stakers.selector, 0))) == stakerAddress);
        StakerInfo storage info = stakerInfo[stakerAddress];
        bytes32 staker = bytes32(uint256(stakerAddress));
        StakerInfo memory infoToCheck = delegateGetStakerInfo(_testTarget, staker);
        require(infoToCheck.value == info.value &&
            infoToCheck.currentCommittedPeriod == info.currentCommittedPeriod &&
            infoToCheck.nextCommittedPeriod == info.nextCommittedPeriod &&
            infoToCheck.flags == info.flags &&
            infoToCheck.lastCommittedPeriod == info.lastCommittedPeriod &&
            infoToCheck.completedWork == info.completedWork &&
            infoToCheck.worker == info.worker &&
            infoToCheck.workerStartPeriod == info.workerStartPeriod);

        require(delegateGet(_testTarget, this.getPastDowntimeLength.selector, staker) ==
            info.pastDowntime.length);
        for (uint256 i = 0; i < info.pastDowntime.length && i < MAX_CHECKED_VALUES; i++) {
            Downtime storage downtime = info.pastDowntime[i];
            Downtime memory downtimeToCheck = delegateGetPastDowntime(_testTarget, staker, i);
            require(downtimeToCheck.startPeriod == downtime.startPeriod &&
                downtimeToCheck.endPeriod == downtime.endPeriod);
        }

        require(delegateGet(_testTarget, this.getSubStakesLength.selector, staker) == info.subStakes.length);
        for (uint256 i = 0; i < info.subStakes.length && i < MAX_CHECKED_VALUES; i++) {
            SubStakeInfo storage subStakeInfo = info.subStakes[i];
            SubStakeInfo memory subStakeInfoToCheck = delegateGetSubStakeInfo(_testTarget, staker, i);
            require(subStakeInfoToCheck.firstPeriod == subStakeInfo.firstPeriod &&
                subStakeInfoToCheck.lastPeriod == subStakeInfo.lastPeriod &&
                subStakeInfoToCheck.unlockingDuration == subStakeInfo.unlockingDuration &&
                subStakeInfoToCheck.lockedValue == subStakeInfo.lockedValue);
        }

        require(delegateGet(_testTarget, this.totalStakedForAt.selector, staker, bytes32(block.number)) ==
            totalStakedForAt(stakerAddress, block.number));
        require(delegateGet(_testTarget, this.totalStakedAt.selector, bytes32(block.number)) ==
            totalStakedAt(block.number));

        if (info.worker != address(0)) {
            require(address(delegateGet(_testTarget, this.stakerFromWorker.selector, bytes32(uint256(info.worker)))) ==
                stakerFromWorker[info.worker]);
        }
    }

    function finishUpgrade(address _target) public override virtual {

        super.finishUpgrade(_target);
        _lockedPerPeriod[RESERVED_PERIOD] = 111;

        stakerFromWorker[address(0)] = address(this);
    }
}

pragma solidity ^0.7.0;




contract PolicyManager is Upgradeable {

    using SafeERC20 for NuCypherToken;
    using SafeMath for uint256;
    using AdditionalMath for uint256;
    using AdditionalMath for int256;
    using AdditionalMath for uint16;
    using Address for address payable;

    event PolicyCreated(
        bytes16 indexed policyId,
        address indexed sponsor,
        address indexed owner,
        uint256 feeRate,
        uint64 startTimestamp,
        uint64 endTimestamp,
        uint256 numberOfNodes
    );
    event ArrangementRevoked(
        bytes16 indexed policyId,
        address indexed sender,
        address indexed node,
        uint256 value
    );
    event RefundForArrangement(
        bytes16 indexed policyId,
        address indexed sender,
        address indexed node,
        uint256 value
    );
    event PolicyRevoked(bytes16 indexed policyId, address indexed sender, uint256 value);
    event RefundForPolicy(bytes16 indexed policyId, address indexed sender, uint256 value);
    event MinFeeRateSet(address indexed node, uint256 value);
    event FeeRateRangeSet(address indexed sender, uint256 min, uint256 defaultValue, uint256 max);
    event Withdrawn(address indexed node, address indexed recipient, uint256 value);

    struct ArrangementInfo {
        address node;
        uint256 indexOfDowntimePeriods;
        uint16 lastRefundedPeriod;
    }

    struct Policy {
        bool disabled;
        address payable sponsor;
        address owner;

        uint128 feeRate;
        uint64 startTimestamp;
        uint64 endTimestamp;

        uint256 reservedSlot1;
        uint256 reservedSlot2;
        uint256 reservedSlot3;
        uint256 reservedSlot4;
        uint256 reservedSlot5;

        ArrangementInfo[] arrangements;
    }

    struct NodeInfo {
        uint128 fee;
        uint16 previousFeePeriod;
        uint256 feeRate;
        uint256 minFeeRate;
        mapping (uint16 => int256) stub; // former slot for feeDelta
        mapping (uint16 => int256) feeDelta;
    }

    struct MemoryNodeInfo {
        uint128 fee;
        uint16 previousFeePeriod;
        uint256 feeRate;
        uint256 minFeeRate;
    }

    struct Range {
        uint128 min;
        uint128 defaultValue;
        uint128 max;
    }

    bytes16 internal constant RESERVED_POLICY_ID = bytes16(0);
    address internal constant RESERVED_NODE = address(0);
    uint256 internal constant MAX_BALANCE = uint256(uint128(0) - 1);
    int256 public constant DEFAULT_FEE_DELTA = int256((uint256(0) - 1) >> 1);

    StakingEscrow public immutable escrow;
    uint32 public immutable genesisSecondsPerPeriod;
    uint32 public immutable secondsPerPeriod;

    mapping (bytes16 => Policy) public policies;
    mapping (address => NodeInfo) public nodes;
    Range public feeRateRange;
    uint64 public resetTimestamp;

    constructor(StakingEscrow _escrowDispatcher, StakingEscrow _escrowImplementation) {
        escrow = _escrowDispatcher;
        uint32 localSecondsPerPeriod = _escrowImplementation.secondsPerPeriod();
        require(localSecondsPerPeriod > 0);
        secondsPerPeriod = localSecondsPerPeriod;
        uint32 localgenesisSecondsPerPeriod = _escrowImplementation.genesisSecondsPerPeriod();
        require(localgenesisSecondsPerPeriod > 0);
        genesisSecondsPerPeriod = localgenesisSecondsPerPeriod;
        if (_escrowDispatcher != _escrowImplementation) {
            require(_escrowDispatcher.secondsPerPeriod() == localSecondsPerPeriod ||
                _escrowDispatcher.secondsPerPeriod() == localgenesisSecondsPerPeriod);
        }
    }

    modifier onlyEscrowContract()
    {

        require(msg.sender == address(escrow));
        _;
    }

    function getCurrentPeriod() public view returns (uint16) {

        return uint16(block.timestamp / secondsPerPeriod);
    }

    function recalculatePeriod(uint16 _period) internal view returns (uint16) {

        return uint16(uint256(_period) * genesisSecondsPerPeriod / secondsPerPeriod);
    }

    function register(address _node, uint16 _period) external onlyEscrowContract {

        NodeInfo storage nodeInfo = nodes[_node];
        require(nodeInfo.previousFeePeriod == 0 && _period < getCurrentPeriod());
        nodeInfo.previousFeePeriod = _period;
    }

    function migrate(address _node) external onlyEscrowContract {

        NodeInfo storage nodeInfo = nodes[_node];
        require(nodeInfo.previousFeePeriod >= getCurrentPeriod());
        nodeInfo.previousFeePeriod = recalculatePeriod(nodeInfo.previousFeePeriod);
        nodeInfo.feeRate = 0;
    }

    function setFeeRateRange(uint128 _min, uint128 _default, uint128 _max) external onlyOwner {

        require(_min <= _default && _default <= _max);
        feeRateRange = Range(_min, _default, _max);
        emit FeeRateRangeSet(msg.sender, _min, _default, _max);
    }

    function setMinFeeRate(uint256 _minFeeRate) external {

        require(_minFeeRate >= feeRateRange.min &&
            _minFeeRate <= feeRateRange.max,
            "The staker's min fee rate must fall within the global fee range");
        NodeInfo storage nodeInfo = nodes[msg.sender];
        if (nodeInfo.minFeeRate == _minFeeRate) {
            return;
        }
        nodeInfo.minFeeRate = _minFeeRate;
        emit MinFeeRateSet(msg.sender, _minFeeRate);
    }

    function getMinFeeRate(NodeInfo storage _nodeInfo) internal view returns (uint256) {

        if (_nodeInfo.minFeeRate == 0 ||
            _nodeInfo.minFeeRate < feeRateRange.min ||
            _nodeInfo.minFeeRate > feeRateRange.max) {
            return feeRateRange.defaultValue;
        } else {
            return _nodeInfo.minFeeRate;
        }
    }

    function getMinFeeRate(address _node) public view returns (uint256) {

        NodeInfo storage nodeInfo = nodes[_node];
        return getMinFeeRate(nodeInfo);
    }

    function createPolicy(
        bytes16 _policyId,
        address _policyOwner,
        uint64 _endTimestamp,
        address[] calldata _nodes
    )
        external payable
    {

        Policy storage policy = policies[_policyId];
        require(
            _policyId != RESERVED_POLICY_ID &&
            policy.feeRate == 0 &&
            !policy.disabled &&
            _endTimestamp > block.timestamp &&
            msg.value > 0
        );
        require(address(this).balance <= MAX_BALANCE);
        uint16 currentPeriod = getCurrentPeriod();
        uint16 endPeriod = uint16(_endTimestamp / secondsPerPeriod) + 1;
        uint256 numberOfPeriods = endPeriod - currentPeriod;

        policy.sponsor = msg.sender;
        policy.startTimestamp = uint64(block.timestamp);
        policy.endTimestamp = _endTimestamp;
        policy.feeRate = uint128(msg.value.div(_nodes.length) / numberOfPeriods);
        require(policy.feeRate > 0 && policy.feeRate * numberOfPeriods * _nodes.length  == msg.value);
        if (_policyOwner != msg.sender && _policyOwner != address(0)) {
            policy.owner = _policyOwner;
        }

        for (uint256 i = 0; i < _nodes.length; i++) {
            address node = _nodes[i];
            require(node != RESERVED_NODE);
            NodeInfo storage nodeInfo = nodes[node];
            require(nodeInfo.previousFeePeriod != 0 &&
                nodeInfo.previousFeePeriod < currentPeriod &&
                policy.feeRate >= getMinFeeRate(nodeInfo));
            if (nodeInfo.feeDelta[currentPeriod] == DEFAULT_FEE_DELTA) {
                nodeInfo.feeDelta[currentPeriod] = int256(policy.feeRate);
            } else {
                nodeInfo.feeDelta[currentPeriod] += int256(policy.feeRate);
            }
            if (nodeInfo.feeDelta[endPeriod] == DEFAULT_FEE_DELTA) {
                nodeInfo.feeDelta[endPeriod] = -int256(policy.feeRate);
            } else {
                nodeInfo.feeDelta[endPeriod] -= int256(policy.feeRate);
            }
            if (nodeInfo.feeDelta[currentPeriod] == 0) {
                nodeInfo.feeDelta[currentPeriod] = DEFAULT_FEE_DELTA;
            }
            if (nodeInfo.feeDelta[endPeriod] == 0) {
                nodeInfo.feeDelta[endPeriod] = DEFAULT_FEE_DELTA;
            }
            policy.arrangements.push(ArrangementInfo(node, 0, 0));
        }

        emit PolicyCreated(
            _policyId,
            msg.sender,
            _policyOwner == address(0) ? msg.sender : _policyOwner,
            policy.feeRate,
            policy.startTimestamp,
            policy.endTimestamp,
            _nodes.length
        );
    }

    function getPolicyOwner(bytes16 _policyId) public view returns (address) {

        Policy storage policy = policies[_policyId];
        return policy.owner == address(0) ? policy.sponsor : policy.owner;
    }

    function ping(
        address _node,
        uint16 _processedPeriod1,
        uint16 _processedPeriod2,
        uint16 _periodToSetDefault
    )
        external onlyEscrowContract
    {

        NodeInfo storage node = nodes[_node];
        require(node.previousFeePeriod < getCurrentPeriod());
        if (_processedPeriod1 != 0) {
            updateFee(node, _processedPeriod1);
        }
        if (_processedPeriod2 != 0) {
            updateFee(node, _processedPeriod2);
        }
        if (_periodToSetDefault != 0 && node.feeDelta[_periodToSetDefault] == 0) {
            node.feeDelta[_periodToSetDefault] = DEFAULT_FEE_DELTA;
        }
    }

    function updateFee(NodeInfo storage _info, uint16 _period) internal {

        if (_info.previousFeePeriod == 0 || _period <= _info.previousFeePeriod) {
            return;
        }
        for (uint16 i = _info.previousFeePeriod + 1; i <= _period; i++) {
            int256 delta = _info.feeDelta[i];
            if (delta == DEFAULT_FEE_DELTA) {
                _info.feeDelta[i] = 0;
                continue;
            }

            _info.feeRate = _info.feeRate.addSigned(delta);
            _info.feeDelta[i] = 0;
        }
        _info.previousFeePeriod = _period;
        _info.fee += uint128(_info.feeRate);
    }

    function withdraw() external returns (uint256) {

        return withdraw(msg.sender);
    }

    function withdraw(address payable _recipient) public returns (uint256) {

        NodeInfo storage node = nodes[msg.sender];
        uint256 fee = node.fee;
        require(fee != 0);
        node.fee = 0;
        _recipient.sendValue(fee);
        emit Withdrawn(msg.sender, _recipient, fee);
        return fee;
    }

    function calculateRefundValue(Policy storage _policy, ArrangementInfo storage _arrangement)
        internal view returns (uint256 refundValue, uint256 indexOfDowntimePeriods, uint16 lastRefundedPeriod)
    {

        uint16 policyStartPeriod = uint16(_policy.startTimestamp / secondsPerPeriod);
        uint16 maxPeriod = AdditionalMath.min16(getCurrentPeriod(), uint16(_policy.endTimestamp / secondsPerPeriod));
        uint16 minPeriod = AdditionalMath.max16(policyStartPeriod, _arrangement.lastRefundedPeriod);
        uint16 downtimePeriods = 0;
        uint256 length = escrow.getPastDowntimeLength(_arrangement.node);
        uint256 initialIndexOfDowntimePeriods;
        if (_arrangement.lastRefundedPeriod == 0) {
            initialIndexOfDowntimePeriods = escrow.findIndexOfPastDowntime(_arrangement.node, policyStartPeriod);
        } else {
            initialIndexOfDowntimePeriods = _arrangement.indexOfDowntimePeriods;
        }

        for (indexOfDowntimePeriods = initialIndexOfDowntimePeriods;
             indexOfDowntimePeriods < length;
             indexOfDowntimePeriods++)
        {
            (uint16 startPeriod, uint16 endPeriod) =
                escrow.getPastDowntime(_arrangement.node, indexOfDowntimePeriods);
            if (startPeriod > maxPeriod) {
                break;
            } else if (endPeriod < minPeriod) {
                continue;
            }
            downtimePeriods += AdditionalMath.min16(maxPeriod, endPeriod)
                .sub16(AdditionalMath.max16(minPeriod, startPeriod)) + 1;
            if (maxPeriod <= endPeriod) {
                break;
            }
        }

        uint16 lastCommittedPeriod = escrow.getLastCommittedPeriod(_arrangement.node);
        if (indexOfDowntimePeriods == length && lastCommittedPeriod < maxPeriod) {
            downtimePeriods += maxPeriod - AdditionalMath.max16(minPeriod - 1, lastCommittedPeriod);
        }

        refundValue = _policy.feeRate * downtimePeriods;
        lastRefundedPeriod = maxPeriod + 1;
    }

    function refundInternal(bytes16 _policyId, address _node, bool _forceRevoke)
        internal returns (uint256 refundValue)
    {

        refundValue = 0;
        Policy storage policy = policies[_policyId];
        require(!policy.disabled && policy.startTimestamp >= resetTimestamp);
        uint16 endPeriod = uint16(policy.endTimestamp / secondsPerPeriod) + 1;
        uint256 numberOfActive = policy.arrangements.length;
        uint256 i = 0;
        for (; i < policy.arrangements.length; i++) {
            ArrangementInfo storage arrangement = policy.arrangements[i];
            address node = arrangement.node;
            if (node == RESERVED_NODE || _node != RESERVED_NODE && _node != node) {
                numberOfActive--;
                continue;
            }
            uint256 nodeRefundValue;
            (nodeRefundValue, arrangement.indexOfDowntimePeriods, arrangement.lastRefundedPeriod) =
                calculateRefundValue(policy, arrangement);
            if (_forceRevoke) {
                NodeInfo storage nodeInfo = nodes[node];

                uint16 lastRefundedPeriod = arrangement.lastRefundedPeriod;
                if (nodeInfo.feeDelta[lastRefundedPeriod] == DEFAULT_FEE_DELTA) {
                    nodeInfo.feeDelta[lastRefundedPeriod] = -int256(policy.feeRate);
                } else {
                    nodeInfo.feeDelta[lastRefundedPeriod] -= int256(policy.feeRate);
                }
                if (nodeInfo.feeDelta[endPeriod] == DEFAULT_FEE_DELTA) {
                    nodeInfo.feeDelta[endPeriod] = int256(policy.feeRate);
                } else {
                    nodeInfo.feeDelta[endPeriod] += int256(policy.feeRate);
                }

                if (nodeInfo.feeDelta[lastRefundedPeriod] == 0) {
                    nodeInfo.feeDelta[lastRefundedPeriod] = DEFAULT_FEE_DELTA;
                }
                if (nodeInfo.feeDelta[endPeriod] == 0) {
                    nodeInfo.feeDelta[endPeriod] = DEFAULT_FEE_DELTA;
                }
                nodeRefundValue += uint256(endPeriod - lastRefundedPeriod) * policy.feeRate;
            }
            if (_forceRevoke || arrangement.lastRefundedPeriod >= endPeriod) {
                arrangement.node = RESERVED_NODE;
                arrangement.indexOfDowntimePeriods = 0;
                arrangement.lastRefundedPeriod = 0;
                numberOfActive--;
                emit ArrangementRevoked(_policyId, msg.sender, node, nodeRefundValue);
            } else {
                emit RefundForArrangement(_policyId, msg.sender, node, nodeRefundValue);
            }

            refundValue += nodeRefundValue;
            if (_node != RESERVED_NODE) {
               break;
            }
        }
        address payable policySponsor = policy.sponsor;
        if (_node == RESERVED_NODE) {
            if (numberOfActive == 0) {
                policy.disabled = true;
                policy.sponsor = address(0);
                policy.owner = address(0);
                policy.feeRate = 0;
                policy.startTimestamp = 0;
                policy.endTimestamp = 0;
                emit PolicyRevoked(_policyId, msg.sender, refundValue);
            } else {
                emit RefundForPolicy(_policyId, msg.sender, refundValue);
            }
        } else {
            require(i < policy.arrangements.length);
        }
        if (refundValue > 0) {
            policySponsor.sendValue(refundValue);
        }
    }

    function calculateRefundValueInternal(bytes16 _policyId, address _node)
        internal view returns (uint256 refundValue)
    {

        refundValue = 0;
        Policy storage policy = policies[_policyId];
        require((policy.owner == msg.sender || policy.sponsor == msg.sender) && !policy.disabled);
        uint256 i = 0;
        for (; i < policy.arrangements.length; i++) {
            ArrangementInfo storage arrangement = policy.arrangements[i];
            if (arrangement.node == RESERVED_NODE || _node != RESERVED_NODE && _node != arrangement.node) {
                continue;
            }
            (uint256 nodeRefundValue,,) = calculateRefundValue(policy, arrangement);
            refundValue += nodeRefundValue;
            if (_node != RESERVED_NODE) {
               break;
            }
        }
        if (_node != RESERVED_NODE) {
            require(i < policy.arrangements.length);
        }
    }

    function revokePolicy(bytes16 _policyId) external returns (uint256 refundValue) {

        require(getPolicyOwner(_policyId) == msg.sender);
        return refundInternal(_policyId, RESERVED_NODE, true);
    }

    function revokeArrangement(bytes16 _policyId, address _node)
        external returns (uint256 refundValue)
    {

        require(_node != RESERVED_NODE);
        require(getPolicyOwner(_policyId) == msg.sender);
        return refundInternal(_policyId, _node, true);
    }

    function getRevocationHash(bytes16 _policyId, address _node) public view returns (bytes32) {

        return SignatureVerifier.hashEIP191(abi.encodePacked(_policyId, _node), byte(0x45));
    }

    function checkOwnerSignature(bytes16 _policyId, address _node, bytes memory _signature) internal view {

        bytes32 hash = getRevocationHash(_policyId, _node);
        address recovered = SignatureVerifier.recover(hash, _signature);
        require(getPolicyOwner(_policyId) == recovered);
    }

    function revoke(bytes16 _policyId, address _node, bytes calldata _signature)
        external returns (uint256 refundValue)
    {

        checkOwnerSignature(_policyId, _node, _signature);
        return refundInternal(_policyId, _node, true);
    }

    function refund(bytes16 _policyId) external {

        Policy storage policy = policies[_policyId];
        require(policy.owner == msg.sender || policy.sponsor == msg.sender);
        refundInternal(_policyId, RESERVED_NODE, false);
    }

    function refund(bytes16 _policyId, address _node)
        external returns (uint256 refundValue)
    {

        require(_node != RESERVED_NODE);
        Policy storage policy = policies[_policyId];
        require(policy.owner == msg.sender || policy.sponsor == msg.sender);
        return refundInternal(_policyId, _node, false);
    }

    function calculateRefundValue(bytes16 _policyId)
        external view returns (uint256 refundValue)
    {

        return calculateRefundValueInternal(_policyId, RESERVED_NODE);
    }

    function calculateRefundValue(bytes16 _policyId, address _node)
        external view returns (uint256 refundValue)
    {

        require(_node != RESERVED_NODE);
        return calculateRefundValueInternal(_policyId, _node);
    }

    function getArrangementsLength(bytes16 _policyId) external view returns (uint256) {

        return policies[_policyId].arrangements.length;
    }

    function getNodeFeeDelta(address _node, uint16 _period)
        public view virtual returns (int256)
    {

        if (_node == RESERVED_NODE && _period == 11) {
            return 55;
        }
        return nodes[_node].feeDelta[_period];
    }

    function getArrangementInfo(bytes16 _policyId, uint256 _index)
        external view returns (address node, uint256 indexOfDowntimePeriods, uint16 lastRefundedPeriod)
    {

        ArrangementInfo storage info = policies[_policyId].arrangements[_index];
        node = info.node;
        indexOfDowntimePeriods = info.indexOfDowntimePeriods;
        lastRefundedPeriod = info.lastRefundedPeriod;
    }


    function delegateGetPolicy(address _target, bytes16 _policyId)
        internal returns (Policy memory result)
    {

        bytes32 memoryAddress = delegateGetData(_target, this.policies.selector, 1, bytes32(_policyId), 0);
        assembly {
            result := memoryAddress
        }
    }

    function delegateGetArrangementInfo(address _target, bytes16 _policyId, uint256 _index)
        internal returns (ArrangementInfo memory result)
    {

        bytes32 memoryAddress = delegateGetData(
            _target, this.getArrangementInfo.selector, 2, bytes32(_policyId), bytes32(_index));
        assembly {
            result := memoryAddress
        }
    }

    function delegateGetNodeInfo(address _target, address _node)
        internal returns (MemoryNodeInfo memory result)
    {

        bytes32 memoryAddress = delegateGetData(_target, this.nodes.selector, 1, bytes32(uint256(_node)), 0);
        assembly {
            result := memoryAddress
        }
    }

    function delegateGetFeeRateRange(address _target) internal returns (Range memory result) {

        bytes32 memoryAddress = delegateGetData(_target, this.feeRateRange.selector, 0, 0, 0);
        assembly {
            result := memoryAddress
        }
    }

    function verifyState(address _testTarget) public override virtual {

        super.verifyState(_testTarget);
        require(uint64(delegateGet(_testTarget, this.resetTimestamp.selector)) == resetTimestamp);

        Range memory rangeToCheck = delegateGetFeeRateRange(_testTarget);
        require(feeRateRange.min == rangeToCheck.min &&
            feeRateRange.defaultValue == rangeToCheck.defaultValue &&
            feeRateRange.max == rangeToCheck.max);

        Policy storage policy = policies[RESERVED_POLICY_ID];
        Policy memory policyToCheck = delegateGetPolicy(_testTarget, RESERVED_POLICY_ID);
        require(policyToCheck.sponsor == policy.sponsor &&
            policyToCheck.owner == policy.owner &&
            policyToCheck.feeRate == policy.feeRate &&
            policyToCheck.startTimestamp == policy.startTimestamp &&
            policyToCheck.endTimestamp == policy.endTimestamp &&
            policyToCheck.disabled == policy.disabled);

        require(delegateGet(_testTarget, this.getArrangementsLength.selector, RESERVED_POLICY_ID) ==
            policy.arrangements.length);
        if (policy.arrangements.length > 0) {
            ArrangementInfo storage arrangement = policy.arrangements[0];
            ArrangementInfo memory arrangementToCheck = delegateGetArrangementInfo(
                _testTarget, RESERVED_POLICY_ID, 0);
            require(arrangementToCheck.node == arrangement.node &&
                arrangementToCheck.indexOfDowntimePeriods == arrangement.indexOfDowntimePeriods &&
                arrangementToCheck.lastRefundedPeriod == arrangement.lastRefundedPeriod);
        }

        NodeInfo storage nodeInfo = nodes[RESERVED_NODE];
        MemoryNodeInfo memory nodeInfoToCheck = delegateGetNodeInfo(_testTarget, RESERVED_NODE);
        require(nodeInfoToCheck.fee == nodeInfo.fee &&
            nodeInfoToCheck.feeRate == nodeInfo.feeRate &&
            nodeInfoToCheck.previousFeePeriod == nodeInfo.previousFeePeriod &&
            nodeInfoToCheck.minFeeRate == nodeInfo.minFeeRate);

        require(int256(delegateGet(_testTarget, this.getNodeFeeDelta.selector,
            bytes32(bytes20(RESERVED_NODE)), bytes32(uint256(11)))) == getNodeFeeDelta(RESERVED_NODE, 11));
    }

    function finishUpgrade(address _target) public override virtual {

        super.finishUpgrade(_target);

        if (resetTimestamp == 0) {
            resetTimestamp = uint64(block.timestamp);
        }

        Policy storage policy = policies[RESERVED_POLICY_ID];
        policy.sponsor = msg.sender;
        policy.owner = address(this);
        policy.startTimestamp = 1;
        policy.endTimestamp = 2;
        policy.feeRate = 3;
        policy.disabled = true;
        policy.arrangements.push(ArrangementInfo(RESERVED_NODE, 11, 22));
        NodeInfo storage nodeInfo = nodes[RESERVED_NODE];
        nodeInfo.fee = 100;
        nodeInfo.feeRate = 33;
        nodeInfo.previousFeePeriod = 44;
        nodeInfo.feeDelta[11] = 55;
        nodeInfo.minFeeRate = 777;
    }
}
