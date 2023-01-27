
pragma solidity 0.4.24;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract Owned {


    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    address public owner;

    function Owned() public {owner = msg.sender;}


    function changeOwner(address _newOwner) public onlyOwner {

        owner = _newOwner;
    }
}

contract Callable is Owned {


    mapping(address => bool) public callers;

    modifier onlyCaller {

        require(callers[msg.sender]);
        _;
    }

    function updateCaller(address _caller, bool allowed) public onlyOwner {

        callers[_caller] = allowed;
    }
}

contract EternalStorage is Callable {


    mapping(bytes32 => uint) uIntStorage;
    mapping(bytes32 => string) stringStorage;
    mapping(bytes32 => address) addressStorage;
    mapping(bytes32 => bytes) bytesStorage;
    mapping(bytes32 => bool) boolStorage;
    mapping(bytes32 => int) intStorage;

    function getUint(bytes32 _key) external view returns (uint) {

        return uIntStorage[_key];
    }

    function getString(bytes32 _key) external view returns (string) {

        return stringStorage[_key];
    }

    function getAddress(bytes32 _key) external view returns (address) {

        return addressStorage[_key];
    }

    function getBytes(bytes32 _key) external view returns (bytes) {

        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) external view returns (bool) {

        return boolStorage[_key];
    }

    function getInt(bytes32 _key) external view returns (int) {

        return intStorage[_key];
    }

    function setUint(bytes32 _key, uint _value) onlyCaller external {

        uIntStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value) onlyCaller external {

        stringStorage[_key] = _value;
    }

    function setAddress(bytes32 _key, address _value) onlyCaller external {

        addressStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value) onlyCaller external {

        bytesStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) onlyCaller external {

        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value) onlyCaller external {

        intStorage[_key] = _value;
    }

    function deleteUint(bytes32 _key) onlyCaller external {

        delete uIntStorage[_key];
    }

    function deleteString(bytes32 _key) onlyCaller external {

        delete stringStorage[_key];
    }

    function deleteAddress(bytes32 _key) onlyCaller external {

        delete addressStorage[_key];
    }

    function deleteBytes(bytes32 _key) onlyCaller external {

        delete bytesStorage[_key];
    }

    function deleteBool(bytes32 _key) onlyCaller external {

        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key) onlyCaller external {

        delete intStorage[_key];
    }
}

contract FundRepository is Callable {


    using SafeMath for uint256;

    EternalStorage public db;

    mapping(bytes32 => mapping(string => Funding)) funds;

    struct Funding {
        address[] funders; //funders that funded tokens
        address[] tokens; //tokens that were funded
        mapping(address => TokenFunding) tokenFunding;
    }

    struct TokenFunding {
        mapping(address => uint256) balance;
        uint256 totalTokenBalance;
    }

    constructor(address _eternalStorage) public {
        db = EternalStorage(_eternalStorage);
    }

    function updateFunders(address _from, bytes32 _platform, string _platformId) public onlyCaller {

        bool existing = db.getBool(keccak256(abi.encodePacked("funds.userHasFunded", _platform, _platformId, _from)));
        if (!existing) {
            uint funderCount = getFunderCount(_platform, _platformId);
            db.setAddress(keccak256(abi.encodePacked("funds.funders.address", _platform, _platformId, funderCount)), _from);
            db.setUint(keccak256(abi.encodePacked("funds.funderCount", _platform, _platformId)), funderCount.add(1));
        }
    }

    function updateBalances(address _from, bytes32 _platform, string _platformId, address _token, uint256 _value) public onlyCaller {

        if (db.getBool(keccak256(abi.encodePacked("funds.token.address", _platform, _platformId, _token))) == false) {
            db.setBool(keccak256(abi.encodePacked("funds.token.address", _platform, _platformId, _token)), true);
            uint tokenCount = getFundedTokenCount(_platform, _platformId);
            db.setAddress(keccak256(abi.encodePacked("funds.token.address", _platform, _platformId, tokenCount)), _token);
            db.setUint(keccak256(abi.encodePacked("funds.tokenCount", _platform, _platformId)), tokenCount.add(1));
        }

        db.setUint(keccak256(abi.encodePacked("funds.tokenBalance", _platform, _platformId, _token)), balance(_platform, _platformId, _token).add(_value));

        db.setUint(keccak256(abi.encodePacked("funds.amountFundedByUser", _platform, _platformId, _from, _token)), amountFunded(_platform, _platformId, _from, _token).add(_value));

        db.setBool(keccak256(abi.encodePacked("funds.userHasFunded", _platform, _platformId, _from)), true);
    }

    function claimToken(bytes32 platform, string platformId, address _token) public onlyCaller returns (uint256) {

        require(!issueResolved(platform, platformId), "Can't claim token, issue is already resolved.");
        uint256 totalTokenBalance = balance(platform, platformId, _token);
        db.deleteUint(keccak256(abi.encodePacked("funds.tokenBalance", platform, platformId, _token)));
        return totalTokenBalance;
    }

    function refundToken(bytes32 _platform, string _platformId, address _owner, address _token) public onlyCaller returns (uint256) {

        require(!issueResolved(_platform, _platformId), "Can't refund token, issue is already resolved.");

        uint256 userTokenBalance = amountFunded(_platform, _platformId, _owner, _token);
        db.deleteUint(keccak256(abi.encodePacked("funds.amountFundedByUser", _platform, _platformId, _owner, _token)));


        uint256 oldBalance = balance(_platform, _platformId, _token);
        uint256 newBalance = oldBalance.sub(userTokenBalance);

        require(newBalance <= oldBalance);

        db.setUint(keccak256(abi.encodePacked("funds.tokenBalance", _platform, _platformId, _token)), newBalance);

        return userTokenBalance;
    }

    function finishResolveFund(bytes32 platform, string platformId) public onlyCaller returns (bool) {

        db.setBool(keccak256(abi.encodePacked("funds.issueResolved", platform, platformId)), true);
        db.deleteUint(keccak256(abi.encodePacked("funds.funderCount", platform, platformId)));
        return true;
    }

    function getFundInfo(bytes32 _platform, string _platformId, address _funder, address _token) public view returns (uint256, uint256, uint256) {

        return (
        getFunderCount(_platform, _platformId),
        balance(_platform, _platformId, _token),
        amountFunded(_platform, _platformId, _funder, _token)
        );
    }

    function issueResolved(bytes32 _platform, string _platformId) public view returns (bool) {

        return db.getBool(keccak256(abi.encodePacked("funds.issueResolved", _platform, _platformId)));
    }

    function getFundedTokenCount(bytes32 _platform, string _platformId) public view returns (uint256) {

        return db.getUint(keccak256(abi.encodePacked("funds.tokenCount", _platform, _platformId)));
    }

    function getFundedTokensByIndex(bytes32 _platform, string _platformId, uint _index) public view returns (address) {

        return db.getAddress(keccak256(abi.encodePacked("funds.token.address", _platform, _platformId, _index)));
    }

    function getFunderCount(bytes32 _platform, string _platformId) public view returns (uint) {

        return db.getUint(keccak256(abi.encodePacked("funds.funderCount", _platform, _platformId)));
    }

    function getFunderByIndex(bytes32 _platform, string _platformId, uint index) external view returns (address) {

        return db.getAddress(keccak256(abi.encodePacked("funds.funders.address", _platform, _platformId, index)));
    }

    function amountFunded(bytes32 _platform, string _platformId, address _funder, address _token) public view returns (uint256) {

        return db.getUint(keccak256(abi.encodePacked("funds.amountFundedByUser", _platform, _platformId, _funder, _token)));
    }

    function balance(bytes32 _platform, string _platformId, address _token) view public returns (uint256) {

        return db.getUint(keccak256(abi.encodePacked("funds.tokenBalance", _platform, _platformId, _token)));
    }
}