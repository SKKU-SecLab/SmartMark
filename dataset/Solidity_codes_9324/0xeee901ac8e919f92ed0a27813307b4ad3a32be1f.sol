
pragma solidity ^0.4.24;


interface IBridgeValidators {

    function isValidator(address _validator) public view returns(bool);

    function requiredSignatures() public view returns(uint256);

    function owner() public view returns(address);

}


library Message {


    function addressArrayContains(address[] array, address value) internal pure returns (bool) {

        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }

    function parseMessage(bytes message)
    internal
    pure
    returns(address recipient, uint256 amount, bytes32 txHash)
    {

        require(isMessageValid(message));
        assembly {
            recipient := and(mload(add(message, 20)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            amount := mload(add(message, 52))
            txHash := mload(add(message, 84))
        }
    }

    function isMessageValid(bytes _msg) internal pure returns(bool) {

        return _msg.length == 116;
    }

    function recoverAddressFromSignedMessage(bytes signature, bytes message) internal pure returns (address) {

        require(signature.length == 65);
        bytes32 r;
        bytes32 s;
        bytes1 v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := mload(add(signature, 0x60))
        }
        return ecrecover(hashMessage(message), uint8(v), r, s);
    }

    function hashMessage(bytes message) internal pure returns (bytes32) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        string memory msgLength = "116";
        return keccak256(prefix, msgLength, message);
    }

    function hasEnoughValidSignatures(
        bytes _message,
        uint8[] _vs,
        bytes32[] _rs,
        bytes32[] _ss,
        IBridgeValidators _validatorContract) internal view {

        require(isMessageValid(_message));
        uint256 requiredSignatures = _validatorContract.requiredSignatures();
        require(_vs.length >= requiredSignatures);
        bytes32 hash = hashMessage(_message);
        address[] memory encounteredAddresses = new address[](requiredSignatures);

        for (uint256 i = 0; i < requiredSignatures; i++) {
            address recoveredAddress = ecrecover(hash, _vs[i], _rs[i], _ss[i]);
            require(_validatorContract.isValidator(recoveredAddress));
            if (addressArrayContains(encounteredAddresses, recoveredAddress)) {
                revert();
            }
            encounteredAddresses[i] = recoveredAddress;
        }
    }
}


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract EternalStorage {


    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}


interface IOwnedUpgradeabilityProxy {

    function proxyOwner() public view returns (address);

}


contract OwnedUpgradeability {


    function upgradeabilityAdmin() public view returns (address) {

        return IOwnedUpgradeabilityProxy(this).proxyOwner();
    }

    modifier onlyIfOwnerOfProxy() {

        require(msg.sender == upgradeabilityAdmin());
        _;
    }
}


contract Ownable is EternalStorage {

    event OwnershipTransferred(address previousOwner, address newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner());
        _;
    }

    function owner() public view returns (address) {

        return addressStorage[keccak256("owner")];
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        setOwner(newOwner);
    }

    function setOwner(address newOwner) internal {

        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[keccak256("owner")] = newOwner;
    }
}


contract Validatable is EternalStorage {


    function validatorContract() public view returns(IBridgeValidators) {

        return IBridgeValidators(addressStorage[keccak256("validatorContract")]);
    }

    modifier onlyValidator() {

        require(validatorContract().isValidator(msg.sender));
        _;
    }
}


contract BasicBridge is EternalStorage, Validatable, Ownable {

    event GasPriceChanged(uint256 gasPrice);
    event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);

    function setGasPrice(uint256 _gasPrice) public onlyOwner {

        require(_gasPrice > 0);
        uintStorage[keccak256("gasPrice")] = _gasPrice;
        emit GasPriceChanged(_gasPrice);
    }

    function gasPrice() public view returns(uint256) {

        return uintStorage[keccak256("gasPrice")];
    }

    function setRequiredBlockConfirmations(uint256 _blockConfirmations) public onlyOwner {

        require(_blockConfirmations > 0);
        uintStorage[keccak256("requiredBlockConfirmations")] = _blockConfirmations;
        emit RequiredBlockConfirmationChanged(_blockConfirmations);
    }

    function requiredBlockConfirmations() public view returns(uint256) {

        return uintStorage[keccak256("requiredBlockConfirmations")];
    }
}


contract Sacrifice {

    constructor(address _recipient) public payable {
        selfdestruct(_recipient);
    }
}

contract HomeBridge is EternalStorage, BasicBridge, OwnedUpgradeability {

    using SafeMath for uint256;
    event GasConsumptionLimitsUpdated(uint256 gas);
    event Deposit (address recipient, uint256 value);
    event Withdraw (address recipient, uint256 value, bytes32 transactionHash);
    event DailyLimit(uint256 newLimit);
    event ForeignDailyLimit(uint256 newLimit);

    function initialize (
        address _validatorContract,
        uint256 _homeDailyLimit,
        uint256 _maxPerTx,
        uint256 _minPerTx,
        uint256 _homeGasPrice,
        uint256 _requiredBlockConfirmations
    ) public
    returns(bool)
    {
        require(!isInitialized());
        require(_validatorContract != address(0));
        require(_homeGasPrice > 0);
        require(_requiredBlockConfirmations > 0);
        require(_minPerTx > 0 && _maxPerTx > _minPerTx && _homeDailyLimit > _maxPerTx);
        addressStorage[keccak256("validatorContract")] = _validatorContract;
        uintStorage[keccak256("deployedAtBlock")] = block.number;
        uintStorage[keccak256("homeDailyLimit")] = _homeDailyLimit;
        uintStorage[keccak256("maxPerTx")] = _maxPerTx;
        uintStorage[keccak256("minPerTx")] = _minPerTx;
        uintStorage[keccak256("gasPrice")] = _homeGasPrice;
        uintStorage[keccak256("requiredBlockConfirmations")] = _requiredBlockConfirmations;
        setInitialize(true);
        return isInitialized();
    }

    function () public payable {
        require(msg.value > 0);
        require(msg.data.length == 0);
        require(withinLimit(msg.value));
        setTotalSpentPerDay(getCurrentDay(), totalSpentPerDay(getCurrentDay()).add(msg.value));
        emit Deposit(msg.sender, msg.value);
    }

    function upgradeFrom3To4() public {

        require(owner() == address(0));
        setOwner(validatorContract().owner());
    }

    function gasLimitWithdrawRelay() public view returns(uint256) {

        return uintStorage[keccak256("gasLimitWithdrawRelay")];
    }

    function deployedAtBlock() public view returns(uint256) {

        return uintStorage[keccak256("deployedAtBlock")];
    }

    function homeDailyLimit() public view returns(uint256) {

        return uintStorage[keccak256("homeDailyLimit")];
    }

    function foreignDailyLimit() public view returns(uint256) {

        return uintStorage[keccak256("foreignDailyLimit")];
    }

    function totalSpentPerDay(uint256 _day) public view returns(uint256) {

        return uintStorage[keccak256("totalSpentPerDay", _day)];
    }

    function totalExecutedPerDay(uint256 _day) public view returns(uint256) {

        return uintStorage[keccak256("totalExecutedPerDay", _day)];
    }

    function withdraws(bytes32 _withdraw) public view returns(bool) {

        return boolStorage[keccak256("withdraws", _withdraw)];
    }

    function setGasLimitWithdrawRelay(uint256 _gas) external onlyOwner {

        uintStorage[keccak256("gasLimitWithdrawRelay")] = _gas;
        emit GasConsumptionLimitsUpdated(_gas);
    }

    function withdraw(uint8[] vs, bytes32[] rs, bytes32[] ss, bytes message) external {

        Message.hasEnoughValidSignatures(message, vs, rs, ss, validatorContract());
        address recipient;
        uint256 amount;
        bytes32 txHash;
        (recipient, amount, txHash) = Message.parseMessage(message);
        require(withinForeignLimit(amount));
        setTotalExecutedPerDay(getCurrentDay(), totalExecutedPerDay(getCurrentDay()).add(amount));
        require(!withdraws(txHash));
        setWithdraws(txHash, true);

        if (!recipient.send(amount)) {
            (new Sacrifice).value(amount)(recipient);
        }

        emit Withdraw(recipient, amount, txHash);
    }

    function setHomeDailyLimit(uint256 _homeDailyLimit) external onlyOwner {

        uintStorage[keccak256("homeDailyLimit")] = _homeDailyLimit;
        emit DailyLimit(_homeDailyLimit);
    }

    function setMaxPerTx(uint256 _maxPerTx) external onlyOwner {

        require(_maxPerTx < homeDailyLimit());
        uintStorage[keccak256("maxPerTx")] = _maxPerTx;
    }

    function setForeignDailyLimit(uint256 _foreignDailyLimit) external onlyOwner {

        uintStorage[keccak256("foreignDailyLimit")] = _foreignDailyLimit;
        emit ForeignDailyLimit(_foreignDailyLimit);
    }

    function setForeignMaxPerTx(uint256 _maxPerTx) external onlyOwner {

        require(_maxPerTx < foreignDailyLimit());
        uintStorage[keccak256("foreignMaxPerTx")] = _maxPerTx;
    }

    function setMinPerTx(uint256 _minPerTx) external onlyOwner {

        require(_minPerTx < homeDailyLimit() && _minPerTx < maxPerTx());
        uintStorage[keccak256("minPerTx")] = _minPerTx;
    }

    function minPerTx() public view returns(uint256) {

        return uintStorage[keccak256("minPerTx")];
    }

    function getCurrentDay() public view returns(uint256) {

        return now / 1 days;
    }

    function maxPerTx() public view returns(uint256) {

        return uintStorage[keccak256("maxPerTx")];
    }

    function foreignMaxPerTx() public view returns(uint256) {

        return uintStorage[keccak256("foreignMaxPerTx")];
    }

    function withinLimit(uint256 _amount) public view returns(bool) {

        uint256 nextLimit = totalSpentPerDay(getCurrentDay()).add(_amount);
        return homeDailyLimit() >= nextLimit && _amount <= maxPerTx() && _amount >= minPerTx();
    }

    function withinForeignLimit(uint256 _amount) public view returns(bool) {

        uint256 nextLimit = totalExecutedPerDay(getCurrentDay()).add(_amount);
        return foreignDailyLimit() >= nextLimit && _amount <= foreignMaxPerTx();
    }

    function isInitialized() public view returns(bool) {

        return boolStorage[keccak256("isInitialized")];
    }

    function setTotalSpentPerDay(uint256 _day, uint256 _value) private {

        uintStorage[keccak256("totalSpentPerDay", _day)] = _value;
    }

    function setTotalExecutedPerDay(uint256 _day, uint256 _value) private {

        uintStorage[keccak256("totalExecutedPerDay", _day)] = _value;
    }

    function setWithdraws(bytes32 _withdraw, bool _status) private {

        boolStorage[keccak256("withdraws", _withdraw)] = _status;
    }

    function setInitialize(bool _status) private {

        boolStorage[keccak256("isInitialized")] = _status;
    }
}