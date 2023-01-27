
pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT


pragma solidity ^0.8.4;

abstract contract OwnableData {
    address public owner;
    address public pendingOwner;
}

abstract contract Ownable is OwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        require(_owner != address(0), "Ownable: zero address");
        owner = _owner;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(address newOwner, bool direct) public onlyOwner {
        if (direct) {
            require(newOwner != address(0), "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            pendingOwner = newOwner;
        }
    }

    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}// MIT
pragma solidity ^0.8.4;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

}// MIT
pragma solidity ^0.8.0;


library SafeERC20 {

    function safeSymbol(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x95d89b41));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeName(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x06fdde03));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeDecimals(IERC20 token) internal view returns (uint8) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x313ce567));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: Transfer failed");
    }

    function safeTransferFrom(IERC20 token, address from, uint256 amount) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x23b872dd, from, address(this), amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: TransferFrom failed");
    }
}// UNLICENSED

pragma solidity ^0.8.4;


contract TokenSale is Ownable {

    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    address public beneficiary;

    uint256 public minPerAccount;
    uint256 public maxPerAccount;

    uint256 public cap;

    uint256 public startTime;
    uint256 public duration;

    bool private _ended;

    mapping(address => uint256) public balances;
    EnumerableSet.AddressSet private _participants;

    struct ParticipantData {
        address _address;
        uint256 _balance;
    }

    mapping(address => uint256) private _deposited;

    uint256 public collected;

    mapping(uint256 => mapping(address => bool)) public whitelisted;
    uint256 public whitelistRound = 1;
    bool public whitelistedOnly = true;

    EnumerableSet.AddressSet private stableCoins;

    event WhitelistChanged(bool newEnabled);
    event WhitelistRoundChanged(uint256 round);
    event Purchased(address indexed purchaser, uint256 amount);

    constructor(
        address _owner,
        address _beneficiary,
        uint256 _minPerAccount,
        uint256 _maxPerAccount,
        uint256 _cap,
        uint256 _startTime,
        uint256 _duration,
        address[] memory _stableCoinsAddresses
    ) Ownable(_owner) {
        require(_beneficiary != address(0), "TokenSale: zero address");
        require(_cap > 0, "TokenSale: Cap is 0");
        require(_duration > 0, "TokenSale: Duration is 0");
        require(_startTime + _duration > block.timestamp, "TokenSale: Final time is before current time");

        beneficiary = _beneficiary;
        minPerAccount = _minPerAccount;
        maxPerAccount = _maxPerAccount;
        cap = _cap;
        startTime = _startTime;
        duration = _duration;

        for (uint256 i; i < _stableCoinsAddresses.length; i++) {
            stableCoins.add(_stableCoinsAddresses[i]);
        }
    }


    function endTime() external view returns (uint256) {

        return startTime + duration;
    }

    function balanceOf(address account) external view returns (uint256) {

        return balances[account];
    }

    function maxAllocationOf(address account) external view returns (uint256) {

        if (!whitelistedOnly || whitelisted[whitelistRound][account]) {
            return maxPerAccount;
        } else {
            return 0;
        }
    }

    function remainingAllocation(address account) external view returns (uint256) {

        if (!whitelistedOnly || whitelisted[whitelistRound][account]) {
            if (maxPerAccount > 0) {
                return maxPerAccount - balances[account];
            } else {
                return cap - collected;
            }
        } else {
            return 0;
        }
    }

    function isWhitelisted(address account) external view returns (bool) {

        if (whitelistedOnly) {
            return whitelisted[whitelistRound][account];
        } else {
            return true;
        }
    }

    function acceptableStableCoins() external view returns (address[] memory) {

        uint256 length = stableCoins.length();
        address[] memory addresses = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            addresses[i] = stableCoins.at(i);
        }

        return addresses;
    }

    function isLive() public view returns (bool) {

        return !_ended && block.timestamp > startTime && block.timestamp < startTime + duration;
    }

    function getParticipantsNumber() external view returns (uint256) {

        return _participants.length();
    }

    function getParticipantDataAt(uint256 index) external view returns (ParticipantData memory) {

        require(index < _participants.length(), "Incorrect index");

        address pAddress = _participants.at(index);
        ParticipantData memory data = ParticipantData(pAddress, balances[pAddress]);

        return data;
    }

    function getParticipantsDataInRange(uint256 from, uint256 to) external view returns (ParticipantData[] memory) {

        require(from <= to, "Incorrect range");
        require(to < _participants.length(), "Incorrect range");

        uint256 length = to - from + 1;
        ParticipantData[] memory data = new ParticipantData[](length);

        for (uint256 i; i < length; i++) {
            address pAddress = _participants.at(i + from);
            data[i] = ParticipantData(pAddress, balances[pAddress]);
        }

        return data;
    }


    function _isBalanceSufficient(uint256 _amount) private view returns (bool) {

        return _amount + collected <= cap;
    }


    modifier onlyBeneficiary() {

        require(msg.sender == beneficiary, "TokenSale: Caller is not the beneficiary");
        _;
    }

    modifier onlyWhitelisted() {

        require(!whitelistedOnly || whitelisted[whitelistRound][msg.sender], "TokenSale: Account is not whitelisted");
        _;
    }

    modifier isOngoing() {

        require(isLive(), "TokenSale: Sale is not active");
        _;
    }

    modifier isEnded() {

        require(_ended || block.timestamp > startTime + duration, "TokenSale: Not ended");
        _;
    }


    function buyWith(address stableCoinAddress, uint256 amount) external isOngoing onlyWhitelisted {

        require(stableCoins.contains(stableCoinAddress), "TokenSale: Stable coin not supported");
        require(amount > 0, "TokenSale: Amount is 0");
        require(_isBalanceSufficient(amount), "TokenSale: Insufficient remaining amount");
        require(amount + balances[msg.sender] >= minPerAccount, "TokenSale: Amount too low");
        require(maxPerAccount == 0 || balances[msg.sender] + amount <= maxPerAccount, "TokenSale: Amount too high");

        uint8 decimals = IERC20(stableCoinAddress).safeDecimals();
        uint256 stableCoinUnits = amount * (10**(decimals - 2));

        require(
            IERC20(stableCoinAddress).allowance(msg.sender, address(this)) >= stableCoinUnits,
            "TokenSale: Insufficient stable coin allowance"
        );
        IERC20(stableCoinAddress).safeTransferFrom(msg.sender, stableCoinUnits);

        balances[msg.sender] += amount;
        collected += amount;
        _deposited[stableCoinAddress] += stableCoinUnits;

        if (!_participants.contains(msg.sender)) {
            _participants.add(msg.sender);
        }

        emit Purchased(msg.sender, amount);
    }

    function endPresale() external onlyOwner {

        require(collected >= cap, "TokenSale: Limit not reached");
        _ended = true;
    }

    function withdrawFunds() external onlyBeneficiary isEnded {

        _ended = true;

        uint256 amount;

        for (uint256 i; i < stableCoins.length(); i++) {
            address stableCoin = address(stableCoins.at(i));
            amount = IERC20(stableCoin).balanceOf(address(this));
            if (amount > 0) {
                IERC20(stableCoin).safeTransfer(beneficiary, amount);
            }
        }
    }

    function recoverErc20(address token) external onlyOwner {

        uint256 amount = IERC20(token).balanceOf(address(this));
        amount -= _deposited[token];
        if (amount > 0) {
            IERC20(token).safeTransfer(owner, amount);
        }
    }

    function recoverEth() external onlyOwner isEnded {

        payable(owner).transfer(address(this).balance);
    }

    function setBeneficiary(address newBeneficiary) public onlyOwner {

        require(newBeneficiary != address(0), "TokenSale: zero address");
        beneficiary = newBeneficiary;
    }

    function setWhitelistedOnly(bool enabled) public onlyOwner {

        whitelistedOnly = enabled;
        emit WhitelistChanged(enabled);
    }

    function setWhitelistRound(uint256 round) public onlyOwner {

        whitelistRound = round;
        emit WhitelistRoundChanged(round);
    }

    function addWhitelistedAddresses(address[] calldata addresses) external onlyOwner {

        for (uint256 i; i < addresses.length; i++) {
            whitelisted[whitelistRound][addresses[i]] = true;
        }
    }
}