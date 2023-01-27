



pragma solidity ^0.4.24;

contract Owned {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner, "Not owner");
        _;
    }

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    address public newOwner;

    function transferOwner(address _newOwner) public onlyOwner {

        require(_newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function changeOwner(address _newOwner) public onlyOwner {

        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }

    function renounceOwnership() public onlyOwner {

        owner = address(0);
    }
}


pragma solidity 0.4.26;


contract Admin is Owned {

    mapping(address => bool) public mapAdmin;

    event AddAdmin(address admin);
    event RemoveAdmin(address admin);

    modifier onlyAdmin() {

        require(mapAdmin[msg.sender], "not admin");
        _;
    }

    function addAdmin(
        address admin
    )
        external
        onlyOwner
    {

        mapAdmin[admin] = true;

        emit AddAdmin(admin);
    }

    function removeAdmin(
        address admin
    )
        external
        onlyOwner
    {

        delete mapAdmin[admin];

        emit RemoveAdmin(admin);
    }
}


pragma solidity ^0.4.24;

library BasicStorageLib {


    struct UintData {
        mapping(bytes => mapping(bytes => uint))           _storage;
    }

    struct BoolData {
        mapping(bytes => mapping(bytes => bool))           _storage;
    }

    struct AddressData {
        mapping(bytes => mapping(bytes => address))        _storage;
    }

    struct BytesData {
        mapping(bytes => mapping(bytes => bytes))          _storage;
    }

    struct StringData {
        mapping(bytes => mapping(bytes => string))         _storage;
    }


    function setStorage(UintData storage self, bytes memory key, bytes memory innerKey, uint value) internal {

        self._storage[key][innerKey] = value;
    }

    function getStorage(UintData storage self, bytes memory key, bytes memory innerKey) internal view returns (uint) {

        return self._storage[key][innerKey];
    }

    function delStorage(UintData storage self, bytes memory key, bytes memory innerKey) internal {

        delete self._storage[key][innerKey];
    }


    function setStorage(BoolData storage self, bytes memory key, bytes memory innerKey, bool value) internal {

        self._storage[key][innerKey] = value;
    }

    function getStorage(BoolData storage self, bytes memory key, bytes memory innerKey) internal view returns (bool) {

        return self._storage[key][innerKey];
    }

    function delStorage(BoolData storage self, bytes memory key, bytes memory innerKey) internal {

        delete self._storage[key][innerKey];
    }


    function setStorage(AddressData storage self, bytes memory key, bytes memory innerKey, address value) internal {

        self._storage[key][innerKey] = value;
    }

    function getStorage(AddressData storage self, bytes memory key, bytes memory innerKey) internal view returns (address) {

        return self._storage[key][innerKey];
    }

    function delStorage(AddressData storage self, bytes memory key, bytes memory innerKey) internal {

        delete self._storage[key][innerKey];
    }


    function setStorage(BytesData storage self, bytes memory key, bytes memory innerKey, bytes memory value) internal {

        self._storage[key][innerKey] = value;
    }

    function getStorage(BytesData storage self, bytes memory key, bytes memory innerKey) internal view returns (bytes memory) {

        return self._storage[key][innerKey];
    }

    function delStorage(BytesData storage self, bytes memory key, bytes memory innerKey) internal {

        delete self._storage[key][innerKey];
    }


    function setStorage(StringData storage self, bytes memory key, bytes memory innerKey, string memory value) internal {

        self._storage[key][innerKey] = value;
    }

    function getStorage(StringData storage self, bytes memory key, bytes memory innerKey) internal view returns (string memory) {

        return self._storage[key][innerKey];
    }

    function delStorage(StringData storage self, bytes memory key, bytes memory innerKey) internal {

        delete self._storage[key][innerKey];
    }

}


pragma solidity ^0.4.24;


contract BasicStorage {


    using BasicStorageLib for BasicStorageLib.UintData;
    using BasicStorageLib for BasicStorageLib.BoolData;
    using BasicStorageLib for BasicStorageLib.AddressData;
    using BasicStorageLib for BasicStorageLib.BytesData;
    using BasicStorageLib for BasicStorageLib.StringData;

    BasicStorageLib.UintData    internal uintData;
    BasicStorageLib.BoolData    internal boolData;
    BasicStorageLib.AddressData internal addressData;
    BasicStorageLib.BytesData   internal bytesData;
    BasicStorageLib.StringData  internal stringData;
}




pragma solidity 0.4.26;


contract TokenManagerStorage is BasicStorage {


    struct AncestorInfo {
      bytes   account;
      string  name;
      string  symbol;
      uint8   decimals;
      uint    chainID;
    }

    struct TokenPairInfo {
      AncestorInfo aInfo;               /// TODO:
      uint      fromChainID;            /// index in coinType.txt; e.g. eth=60, etc=61, wan=5718350
      bytes     fromAccount;            /// from address
      uint      toChainID;              ///
      bytes     toAccount;              /// to token address
    }
    
    struct TokenPairInfoFull {
      uint      id;
      AncestorInfo aInfo;
      uint      fromChainID;
      bytes     fromAccount;
      uint      toChainID;
      bytes     toAccount;
    }



    uint public totalTokenPairs = 0;

    mapping(uint => TokenPairInfo) public mapTokenPairInfo;
    mapping(uint => uint) public mapTokenPairIndex;
}


pragma solidity 0.4.26;

contract WRC20Protocol {



    string public name;
    string public symbol;
    uint8 public decimals;
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

    uint public totalSupply;

    function balanceOf(address _owner) public view returns (uint balance);


    function transfer(address _to, uint _value) public returns (bool success);


    function transferFrom(address _from, address _to, uint _value) public returns (bool success);


    function approve(address _spender, uint _value) public returns (bool success);


    function allowance(address _owner, address _spender) public view returns (uint remaining);


    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


pragma solidity ^0.4.24;

library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath mul overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath div 0"); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath sub b > a");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath add overflow");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath mod 0");
        return a % b;
    }
}





pragma solidity 0.4.26;



contract StandardToken is WRC20Protocol {

    using SafeMath for uint;

    modifier onlyPayloadSize(uint size) {

        require(msg.data.length >= size + 4, "Payload size is incorrect");
        _;
    }

    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) returns (bool success) {

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {

        return balances[_owner];
    }

    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) returns (bool success) {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0), "Not permitted");

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining) {

      return allowed[_owner][_spender];
    }
}




pragma solidity 0.4.26;



contract MappingToken is StandardToken, Owned {

    using SafeMath for uint;
    modifier onlyMeaningfulValue(uint value) {

        require(value > 0, "Value is null");
        _;
    }


    constructor(string tokenName, string tokenSymbol, uint8 tokenDecimal)
        public
    {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimal;
    }


    function mint(address account, uint value)
        external
        onlyOwner
        onlyMeaningfulValue(value)
    {

        balances[account] = balances[account].add(value);
        totalSupply = totalSupply.add(value);

        emit Transfer(address(0), account, value);
    }

    function burn(address account, uint value)
        external
        onlyOwner
        onlyMeaningfulValue(value)
    {

        balances[account] = balances[account].sub(value);
        totalSupply = totalSupply.sub(value);

        emit Transfer(account, address(0), value);
    }

    function update(string _name, string _symbol)
        external
        onlyOwner
    {

        name = _name;
        symbol = _symbol;
    }
}




pragma solidity 0.4.26;


interface IMappingToken {

    function changeOwner(address _newOwner) external;

    function acceptOwnership() external;

    function transferOwner(address) external;

    function name() external view returns (string);

    function symbol() external view returns (string);

    function decimals() external view returns (uint8);

    function mint(address, uint) external;

    function burn(address, uint) external;

    function update(string, string) external;

}




pragma solidity 0.4.26;
pragma experimental ABIEncoderV2;






contract TokenManagerDelegate is TokenManagerStorage, Admin {

    using SafeMath for uint;

     event AddToken(address tokenAddress, string name, string symbol, uint8 decimals);
     event AddTokenPair(uint indexed id, uint fromChainID, bytes fromAccount, uint toChainID, bytes toAccount);
     event UpdateTokenPair(uint indexed id, AncestorInfo aInfo, uint fromChainID, bytes fromAccount, uint toChainID, bytes toAccount);
     event RemoveTokenPair(uint indexed id);
     event UpdateToken(address tokenAddress, string name, string symbol);


    modifier onlyNotExistID(uint id) {

        require(mapTokenPairInfo[id].fromChainID == 0, "token exist");
        _;
    }

    modifier onlyExistID(uint id) {

        require(mapTokenPairInfo[id].fromChainID > 0, "token not exist");
        _;
    }

    
    function bytesToAddress(bytes b) internal pure returns (address addr) {

        assembly {
            addr := mload(add(b,20))
        }
    }

    function mintToken(
        address tokenAddress,
        address to,
        uint    value
    )
        external
        onlyAdmin
    {

        IMappingToken(tokenAddress).mint(to, value);
    }

    function burnToken(
        address tokenAddress,
        address from,
        uint    value
    )
        external
        onlyAdmin
    {

        IMappingToken(tokenAddress).burn(from, value);
    }

    function addToken(
        string name,
        string symbol,
        uint8 decimals
    )
        external
        onlyOwner
    {

        address tokenAddress = new MappingToken(name, symbol, decimals);
        
        emit AddToken(tokenAddress, name, symbol, decimals);
    }

    function addTokenPair(
        uint    id,

        AncestorInfo aInfo,

        uint    fromChainID,
        bytes   fromAccount,
        uint    toChainID,
        bytes   toAccount
    )
        public
        onlyOwner
        onlyNotExistID(id)
    {

        mapTokenPairInfo[id].fromChainID = fromChainID;
        mapTokenPairInfo[id].fromAccount = fromAccount;
        mapTokenPairInfo[id].toChainID = toChainID;
        mapTokenPairInfo[id].toAccount = toAccount;

        mapTokenPairInfo[id].aInfo.account = aInfo.account;
        mapTokenPairInfo[id].aInfo.name = aInfo.name;
        mapTokenPairInfo[id].aInfo.symbol = aInfo.symbol;
        mapTokenPairInfo[id].aInfo.decimals = aInfo.decimals;
        mapTokenPairInfo[id].aInfo.chainID = aInfo.chainID;

        mapTokenPairIndex[totalTokenPairs] = id;
        totalTokenPairs = totalTokenPairs.add(1);

        emit AddTokenPair(id, fromChainID, fromAccount, toChainID, toAccount);
    }

    function updateTokenPair(
        uint    id,

        AncestorInfo aInfo,

        uint    fromChainID,
        bytes   fromAccount,
        uint    toChainID,
        bytes   toAccount
    )
        public
        onlyOwner
        onlyExistID(id)
    {

        mapTokenPairInfo[id].aInfo.account = aInfo.account;
        mapTokenPairInfo[id].aInfo.name = aInfo.name;
        mapTokenPairInfo[id].aInfo.symbol = aInfo.symbol;
        mapTokenPairInfo[id].aInfo.decimals = aInfo.decimals;
        mapTokenPairInfo[id].aInfo.chainID = aInfo.chainID;

        mapTokenPairInfo[id].fromChainID = fromChainID;
        mapTokenPairInfo[id].fromAccount = fromAccount;
        mapTokenPairInfo[id].toChainID = toChainID;
        mapTokenPairInfo[id].toAccount = toAccount;

        emit UpdateTokenPair(id, aInfo, fromChainID, fromAccount, toChainID, toAccount);
    }

    function removeTokenPair(
        uint id
    )
        external
        onlyOwner
        onlyExistID(id)
    {

        for(uint i=0; i<totalTokenPairs; i++) {
            if (id == mapTokenPairIndex[i]) {
                if (i != totalTokenPairs - 1) {
                    mapTokenPairIndex[i] = mapTokenPairIndex[totalTokenPairs - 1];
                }
 
                delete mapTokenPairIndex[totalTokenPairs - 1];
                totalTokenPairs--;
                delete mapTokenPairInfo[id];
                emit RemoveTokenPair(id);
                return;
            }
        }
    }

    function updateToken(address tokenAddress, string name, string symbol)
        external
        onlyOwner
    {

        IMappingToken(tokenAddress).update(name, symbol);

        emit UpdateToken(tokenAddress, name, symbol);
    }

    function changeTokenOwner(address tokenAddress, address _newOwner) external onlyOwner {

        IMappingToken(tokenAddress).changeOwner(_newOwner);
    }

    function acceptTokenOwnership(address tokenAddress) external {

        IMappingToken(tokenAddress).acceptOwnership();
    }

    function transferTokenOwner(address tokenAddress, address _newOwner) external onlyOwner {

        IMappingToken(tokenAddress).transferOwner(_newOwner);
    }

    function getTokenPairInfo(
        uint id
    )
        external
        view
        returns (uint fromChainID, bytes fromAccount, uint toChainID, bytes toAccount)
    {

        fromChainID = mapTokenPairInfo[id].fromChainID;
        fromAccount = mapTokenPairInfo[id].fromAccount;
        toChainID = mapTokenPairInfo[id].toChainID;
        toAccount = mapTokenPairInfo[id].toAccount;
    }

    function getTokenPairInfoSlim(
        uint id
    )
        external
        view
        returns (uint fromChainID, bytes fromAccount, uint toChainID)
    {

        fromChainID = mapTokenPairInfo[id].fromChainID;
        fromAccount = mapTokenPairInfo[id].fromAccount;
        toChainID = mapTokenPairInfo[id].toChainID;
    }

    function getTokenInfo(uint id) external view returns (address addr, string name, string symbol, uint8 decimals) {

        if (mapTokenPairInfo[id].fromChainID == 0) {
            name = '';
            symbol = '';
            decimals = 0;
            addr = address(0);
        } else {
            address instance = bytesToAddress(mapTokenPairInfo[id].toAccount);
            name = IMappingToken(instance).name();
            symbol = IMappingToken(instance).symbol();
            decimals = IMappingToken(instance).decimals();
            addr = instance;
        }
    }

    function getAncestorInfo(uint id) external view returns (bytes account, string name, string symbol, uint8 decimals, uint chainId) {

        account = mapTokenPairInfo[id].aInfo.account;
        name = mapTokenPairInfo[id].aInfo.name;
        symbol = mapTokenPairInfo[id].aInfo.symbol;
        decimals = mapTokenPairInfo[id].aInfo.decimals;
        chainId = mapTokenPairInfo[id].aInfo.chainID;
    }

    function getAncestorSymbol(uint id) external view returns (string symbol, uint8 decimals) {

        symbol = mapTokenPairInfo[id].aInfo.symbol;
        decimals = mapTokenPairInfo[id].aInfo.decimals;
    }

    function getAncestorChainID(uint id) external view returns (uint chainID) {

        chainID = mapTokenPairInfo[id].aInfo.chainID;
    }




    function getTokenPairs()
        external
        view
        returns (uint[] id, uint[] fromChainID, bytes[] fromAccount, uint[] toChainID, bytes[] toAccount,
          string[] ancestorSymbol, uint8[] ancestorDecimals, bytes[] ancestorAccount, string[] ancestorName, uint[] ancestorChainID)
    {

        uint cnt = totalTokenPairs;
        uint theId = 0;
        uint i = 0;

        id = new uint[](cnt);
        fromChainID = new uint[](cnt);
        fromAccount = new bytes[](cnt);
        toChainID = new uint[](cnt);
        toAccount = new bytes[](cnt);

        ancestorSymbol = new string[](cnt);
        ancestorDecimals = new uint8[](cnt);

        ancestorAccount = new bytes[](cnt);
        ancestorName = new string[](cnt);
        ancestorChainID = new uint[](cnt);

        i = 0;
        theId = 0;
        uint j = 0;
        for (; j < totalTokenPairs; j++) {
            theId = mapTokenPairIndex[j];
            id[i] = theId;
            fromChainID[i] = mapTokenPairInfo[theId].fromChainID;
            fromAccount[i] = mapTokenPairInfo[theId].fromAccount;
            toChainID[i] = mapTokenPairInfo[theId].toChainID;
            toAccount[i] = mapTokenPairInfo[theId].toAccount;

            ancestorSymbol[i] = mapTokenPairInfo[theId].aInfo.symbol;
            ancestorDecimals[i] = mapTokenPairInfo[theId].aInfo.decimals;

            ancestorAccount[i] = mapTokenPairInfo[theId].aInfo.account;
            ancestorName[i] = mapTokenPairInfo[theId].aInfo.name;
            ancestorChainID[i] = mapTokenPairInfo[theId].aInfo.chainID;
            i ++;
        }
    }

    function getTokenPairsByChainID(uint chainID1, uint chainID2)
        external
        view
        returns (uint[] id, uint[] fromChainID, bytes[] fromAccount, uint[] toChainID, bytes[] toAccount,
          string[] ancestorSymbol, uint8[] ancestorDecimals, bytes[] ancestorAccount, string[] ancestorName, uint[] ancestorChainID)
    {

        uint cnt = 0;
        uint i = 0;
        uint theId = 0;
        uint[] memory id_valid = new uint[](totalTokenPairs);
        for (; i < totalTokenPairs; i++ ) {
            theId = mapTokenPairIndex[i];
            if ((mapTokenPairInfo[theId].fromChainID == chainID1) && (mapTokenPairInfo[theId].toChainID == chainID2) ||
            (mapTokenPairInfo[theId].toChainID == chainID1) && (mapTokenPairInfo[theId].fromChainID == chainID2)) {
                id_valid[cnt] = theId;
                cnt ++;
            }
        }

        id = new uint[](cnt);
        fromChainID = new uint[](cnt);
        fromAccount = new bytes[](cnt);
        toChainID = new uint[](cnt);
        toAccount = new bytes[](cnt);

        ancestorSymbol = new string[](cnt);
        ancestorDecimals = new uint8[](cnt);

        ancestorAccount = new bytes[](cnt);
        ancestorName = new string[](cnt);
        ancestorChainID = new uint[](cnt);

        for (i = 0; i < cnt; i++) {
            theId = id_valid[i];

            id[i] = theId;
            fromChainID[i] = mapTokenPairInfo[theId].fromChainID;
            fromAccount[i] = mapTokenPairInfo[theId].fromAccount;
            toChainID[i] = mapTokenPairInfo[theId].toChainID;
            toAccount[i] = mapTokenPairInfo[theId].toAccount;

            ancestorSymbol[i] = mapTokenPairInfo[theId].aInfo.symbol;
            ancestorDecimals[i] = mapTokenPairInfo[theId].aInfo.decimals;
            
            ancestorAccount[i] = mapTokenPairInfo[theId].aInfo.account;
            ancestorName[i] = mapTokenPairInfo[theId].aInfo.name;
            ancestorChainID[i] = mapTokenPairInfo[theId].aInfo.chainID;
        }
    }
}