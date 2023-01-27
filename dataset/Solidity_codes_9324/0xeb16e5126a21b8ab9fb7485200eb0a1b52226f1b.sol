

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



pragma solidity 0.5.7;




contract TimeLockUpgradeV2 is
    Ownable
{

    using SafeMath for uint256;


    uint256 public timeLockPeriod;

    mapping(bytes32 => uint256) public timeLockedUpgrades;


    event UpgradeRegistered(
        bytes32 indexed _upgradeHash,
        uint256 _timestamp,
        bytes _upgradeData
    );

    event RemoveRegisteredUpgrade(
        bytes32 indexed _upgradeHash
    );


    modifier timeLockUpgrade() {

        require(
            isOwner(),
            "TimeLockUpgradeV2: The caller must be the owner"
        );

        if (timeLockPeriod > 0) {
            bytes32 upgradeHash = keccak256(
                abi.encodePacked(
                    msg.data
                )
            );

            uint256 registrationTime = timeLockedUpgrades[upgradeHash];

            if (registrationTime == 0) {
                timeLockedUpgrades[upgradeHash] = block.timestamp;

                emit UpgradeRegistered(
                    upgradeHash,
                    block.timestamp,
                    msg.data
                );

                return;
            }

            require(
                block.timestamp >= registrationTime.add(timeLockPeriod),
                "TimeLockUpgradeV2: Time lock period must have elapsed."
            );

            timeLockedUpgrades[upgradeHash] = 0;

        }

        _;
    }


    function removeRegisteredUpgrade(
        bytes32 _upgradeHash
    )
        external
        onlyOwner
    {

        require(
            timeLockedUpgrades[_upgradeHash] != 0,
            "TimeLockUpgradeV2.removeRegisteredUpgrade: Upgrade hash must be registered"
        );

        timeLockedUpgrades[_upgradeHash] = 0;

        emit RemoveRegisteredUpgrade(
            _upgradeHash
        );
    }

    function setTimeLockPeriod(
        uint256 _timeLockPeriod
    )
        external
        onlyOwner
    {

        require(
            _timeLockPeriod > timeLockPeriod,
            "TimeLockUpgradeV2: New period must be greater than existing"
        );

        timeLockPeriod = _timeLockPeriod;
    }
}



pragma solidity 0.5.7;


library AddressArrayUtils {


    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {

        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function contains(address[] memory A, address a) internal pure returns (bool) {

        bool isIn;
        (, isIn) = indexOf(A, a);
        return isIn;
    }

    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 aLength = A.length;
        uint256 bLength = B.length;
        address[] memory newAddresses = new address[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newAddresses[aLength + j] = B[j];
        }
        return newAddresses;
    }

    function append(address[] memory A, address a) internal pure returns (address[] memory) {

        address[] memory newAddresses = new address[](A.length + 1);
        for (uint256 i = 0; i < A.length; i++) {
            newAddresses[i] = A[i];
        }
        newAddresses[A.length] = a;
        return newAddresses;
    }

    function intersect(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 newLength = 0;
        for (uint256 i = 0; i < length; i++) {
            if (contains(B, A[i])) {
                includeMap[i] = true;
                newLength++;
            }
        }
        address[] memory newAddresses = new address[](newLength);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

    function union(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        address[] memory leftDifference = difference(A, B);
        address[] memory rightDifference = difference(B, A);
        address[] memory intersection = intersect(A, B);
        return extend(leftDifference, extend(intersection, rightDifference));
    }

    function difference(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 count = 0;
        for (uint256 i = 0; i < length; i++) {
            address e = A[i];
            if (!contains(B, e)) {
                includeMap[i] = true;
                count++;
            }
        }
        address[] memory newAddresses = new address[](count);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {

        uint256 length = A.length;
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {

        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert();
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

    function hasDuplicate(address[] memory A) internal pure returns (bool) {

        if (A.length == 0) {
            return false;
        }
        for (uint256 i = 0; i < A.length - 1; i++) {
            for (uint256 j = i + 1; j < A.length; j++) {
                if (A[i] == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    function isEqual(address[] memory A, address[] memory B) internal pure returns (bool) {

        if (A.length != B.length) {
            return false;
        }
        for (uint256 i = 0; i < A.length; i++) {
            if (A[i] != B[i]) {
                return false;
            }
        }
        return true;
    }
}



pragma solidity 0.5.7;





contract OracleWhiteList is
    Ownable,
    TimeLockUpgradeV2
{

    using AddressArrayUtils for address[];


    address[] public addresses;
    mapping(address => address) public oracleWhiteList;


    event TokenOraclePairAdded(
        address _tokenAddress,
        address _oracleAddress
    );

    event TokenOraclePairRemoved(
        address _tokenAddress,
        address _oracleAddress
    );


    constructor(
        address[] memory _initialTokenAddresses,
        address[] memory _initialOracleAddresses
    )
        public
    {
        require(
            _initialTokenAddresses.length == _initialOracleAddresses.length,
            "OracleWhiteList.constructor: Token and Oracle array lengths must match."
        );

        for (uint256 i = 0; i < _initialTokenAddresses.length; i++) {
            address tokenAddressToAdd = _initialTokenAddresses[i];

            addresses.push(tokenAddressToAdd);
            oracleWhiteList[tokenAddressToAdd] = _initialOracleAddresses[i];
        }
    }


    function addTokenOraclePair(
        address _tokenAddress,
        address _oracleAddress
    )
        external
        onlyOwner
        timeLockUpgrade
    {

        require(
            oracleWhiteList[_tokenAddress] == address(0),
            "OracleWhiteList.addTokenOraclePair: Token and Oracle pair already exists."
        );

        addresses.push(_tokenAddress);
        oracleWhiteList[_tokenAddress] = _oracleAddress;

        emit TokenOraclePairAdded(_tokenAddress, _oracleAddress);
    }

    function removeTokenOraclePair(
        address _tokenAddress
    )
        external
        onlyOwner
    {

        address oracleAddress = oracleWhiteList[_tokenAddress];

        require(
            oracleAddress != address(0),
            "OracleWhiteList.removeTokenOraclePair: Token Address is not current whitelisted."
        );

        addresses = addresses.remove(_tokenAddress);
        oracleWhiteList[_tokenAddress] = address(0);

        emit TokenOraclePairRemoved(_tokenAddress, oracleAddress);
    }

    function editTokenOraclePair(
        address _tokenAddress,
        address _oracleAddress
    )
        external
        onlyOwner
        timeLockUpgrade
    {

        require(
            oracleWhiteList[_tokenAddress] != address(0),
            "OracleWhiteList.editTokenOraclePair: Token and Oracle pair must exist."
        );

        oracleWhiteList[_tokenAddress] = _oracleAddress;

        emit TokenOraclePairAdded(
            _tokenAddress,
            _oracleAddress
        );
    }

    function validAddresses()
        external
        view
        returns (address[] memory)
    {

        return addresses;
    }

    function getOracleAddressesByToken(
        address[] calldata _tokenAddresses
    )
        external
        view
        returns (address[] memory)
    {

        uint256 arrayLength = _tokenAddresses.length;

        require(
            arrayLength > 0,
            "OracleWhiteList.getOracleAddressesByToken: Array length must be greater than 0."
        );

        address[] memory oracleAddresses = new address[](arrayLength);

        for (uint256 i = 0; i < arrayLength; i++) {
            oracleAddresses[i] = getOracleAddressByToken(
                _tokenAddresses[i]
            );
        }

        return oracleAddresses;
    }

    function getOracleAddressByToken(
        address _tokenAddress
    )
        public
        view
        returns (address)
    {

        require(
            oracleWhiteList[_tokenAddress] != address(0),
            "OracleWhiteList.getOracleAddressFromToken: No Oracle for that address."
        );

        return oracleWhiteList[_tokenAddress];
    }

    function areValidAddresses(
        address[] calldata _tokenAddresses
    )
        external
        view
        returns (bool)
    {

        uint256 arrayLength = _tokenAddresses.length;

        require(
            arrayLength > 0,
            "OracleWhiteList.areValidAddresses: Array length must be greater than 0."
        );

        for (uint256 i = 0; i < arrayLength; i++) {
            if (oracleWhiteList[_tokenAddresses[i]] == address(0)) {
                return false;
            }
        }

        return true;
    }


}