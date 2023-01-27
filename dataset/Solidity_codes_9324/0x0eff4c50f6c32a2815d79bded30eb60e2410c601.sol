



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




pragma solidity ^0.4.24;


contract Halt is Owned {


    bool public halted = false;

    modifier notHalted() {

        require(!halted, "Smart contract is halted");
        _;
    }

    modifier isHalted() {

        require(halted, "Smart contract is not halted");
        _;
    }

    function setHalt(bool halt)
        public
        onlyOwner
    {

        halted = halt;
    }
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



contract QuotaStorage is BasicStorage {

    
    using SafeMath for uint;

    struct Quota {
        uint debt_receivable;
        uint debt_payable;
        uint _debt;
        uint asset_receivable;
        uint asset_payable;
        uint _asset;
        bool _active;
    }

    uint public constant DENOMINATOR = 10000;

    mapping(uint => mapping(bytes32 => Quota)) quotaMap;

    mapping(bytes32 => mapping(uint => uint)) storemanTokensMap;

    mapping(bytes32 => uint) storemanTokenCountMap;

    mapping(address => bool) public htlcGroupMap;

    address public depositOracleAddress;

    address public priceOracleAddress;

    uint public depositRate;

    string public depositTokenSymbol;

    address public tokenManagerAddress;

    address public debtOracleAddress;

    uint public fastCrossMinValue;

    modifier onlyHtlc() {

        require(htlcGroupMap[msg.sender], "Not in HTLC group");
        _;
    }
}


pragma solidity 0.4.26;

interface IOracle {

  function getDeposit(bytes32 smgID) external view returns (uint);

  function getValue(bytes32 key) external view returns (uint);

  function getValues(bytes32[] keys) external view returns (uint[] values);

  function getStoremanGroupConfig(
    bytes32 id
  ) external view returns(bytes32 groupId, uint8 status, uint deposit, uint chain1, uint chain2, uint curve1, uint curve2, bytes gpk1, bytes gpk2, uint startTime, uint endTime);

}




pragma solidity 0.4.26;





interface _ITokenManager {

    function getAncestorSymbol(uint id) external view returns (string symbol, uint8 decimals);

}

interface _IStoremanGroup {

    function getDeposit(bytes32 id) external view returns(uint deposit);

}

interface IDebtOracle {

    function isDebtClean(bytes32 storemanGroupId) external view returns (bool);

}


contract QuotaDelegate is QuotaStorage, Halt {


    modifier checkMinValue(uint tokenId, uint value) {

        if (fastCrossMinValue > 0) {
            string memory symbol;
            uint decimals;
            (symbol, decimals) = getTokenAncestorInfo(tokenId);
            uint price = getPrice(symbol);
            require(price > 0, "Price is zero");
            uint count = fastCrossMinValue.mul(10**decimals).div(price);
            require(value >= count, "value too small");
        }
        _;
    }
    
    function config(
        address _priceOracleAddr,
        address _htlcAddr,
        address _fastHtlcAddr,
        address _depositOracleAddr,
        address _tokenManagerAddress,
        uint _depositRate,
        string _depositTokenSymbol
    ) external onlyOwner {

        priceOracleAddress = _priceOracleAddr;
        htlcGroupMap[_htlcAddr] = true;
        htlcGroupMap[_fastHtlcAddr] = true;
        depositOracleAddress = _depositOracleAddr;
        depositRate = _depositRate;
        depositTokenSymbol = _depositTokenSymbol;
        tokenManagerAddress = _tokenManagerAddress;
    }

    function setDebtOracle(address oracle) external onlyOwner {

        debtOracleAddress = oracle;
    }

    function setFastCrossMinValue(uint value) external onlyOwner {

        fastCrossMinValue = value;
    }

    function userMintLock(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        
        uint mintQuota = getUserMintQuota(tokenId, storemanGroupId);
        require(
            mintQuota >= value,
            "Quota is not enough"
        );

        if (!quota._active) {
            quota._active = true;
            storemanTokensMap[storemanGroupId][storemanTokenCountMap[storemanGroupId]] = tokenId;
            storemanTokenCountMap[storemanGroupId] = storemanTokenCountMap[storemanGroupId]
                .add(1);
        }

        quota.asset_receivable = quota.asset_receivable.add(value);
    }

    function smgMintLock(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        
        if (!quota._active) {
            quota._active = true;
            storemanTokensMap[storemanGroupId][storemanTokenCountMap[storemanGroupId]] = tokenId;
            storemanTokenCountMap[storemanGroupId] = storemanTokenCountMap[storemanGroupId]
                .add(1);
        }

        quota.debt_receivable = quota.debt_receivable.add(value);
    }

    function userMintRevoke(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        quota.asset_receivable = quota.asset_receivable.sub(value);
    }

    function smgMintRevoke(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        quota.debt_receivable = quota.debt_receivable.sub(value);
    }

    function userMintRedeem(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        quota.debt_receivable = quota.debt_receivable.sub(value);
        quota._debt = quota._debt.add(value);
    }

    function smgMintRedeem(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        quota.asset_receivable = quota.asset_receivable.sub(value);
        quota._asset = quota._asset.add(value);
    }

    function userFastMint(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc checkMinValue(tokenId, value) {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        
        uint mintQuota = getUserMintQuota(tokenId, storemanGroupId);
        require(
            mintQuota >= value,
            "Quota is not enough"
        );

        if (!quota._active) {
            quota._active = true;
            storemanTokensMap[storemanGroupId][storemanTokenCountMap[storemanGroupId]] = tokenId;
            storemanTokenCountMap[storemanGroupId] = storemanTokenCountMap[storemanGroupId]
                .add(1);
        }
        quota._asset = quota._asset.add(value);
    }

    function smgFastMint(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        
        if (!quota._active) {
            quota._active = true;
            storemanTokensMap[storemanGroupId][storemanTokenCountMap[storemanGroupId]] = tokenId;
            storemanTokenCountMap[storemanGroupId] = storemanTokenCountMap[storemanGroupId]
                .add(1);
        }
        quota._debt = quota._debt.add(value);
    }

    function userFastBurn(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc checkMinValue(tokenId, value) {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        require(quota._debt.sub(quota.debt_payable) >= value, "Value is invalid");
        quota._debt = quota._debt.sub(value);
    }

    function smgFastBurn(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        quota._asset = quota._asset.sub(value);
    }

    function userBurnLock(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        require(quota._debt.sub(quota.debt_payable) >= value, "Value is invalid");
        quota.debt_payable = quota.debt_payable.add(value);
    }

    function smgBurnLock(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        quota.asset_payable = quota.asset_payable.add(value);
    }

    function userBurnRevoke(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        quota.debt_payable = quota.debt_payable.sub(value);
    }

    function smgBurnRevoke(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        quota.asset_payable = quota.asset_payable.sub(value);
    }

    function userBurnRedeem(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        quota._asset = quota._asset.sub(value);
        quota.asset_payable = quota.asset_payable.sub(value);
    }

    function smgBurnRedeem(
        uint tokenId,
        bytes32 storemanGroupId,
        uint value
    ) external onlyHtlc {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        quota._debt = quota._debt.sub(value);
        quota.debt_payable = quota.debt_payable.sub(value);
    }

    function debtLock(
        bytes32 srcStoremanGroupId,
        bytes32 dstStoremanGroupId
    ) external onlyHtlc {

        uint tokenCount = storemanTokenCountMap[srcStoremanGroupId];
        for (uint i = 0; i < tokenCount; i++) {
            uint id = storemanTokensMap[srcStoremanGroupId][i];
            Quota storage src = quotaMap[id][srcStoremanGroupId];

            require( src.debt_receivable == uint(0) && src.debt_payable == uint(0),
                "There are debt_receivable or debt_payable in src storeman"
            );

            if (src._debt == 0) {
                continue;
            }

            Quota storage dst = quotaMap[id][dstStoremanGroupId];
            if (!dst._active) {
                dst._active = true;
                storemanTokensMap[dstStoremanGroupId][storemanTokenCountMap[dstStoremanGroupId]] = id;
                storemanTokenCountMap[dstStoremanGroupId] = storemanTokenCountMap[dstStoremanGroupId]
                    .add(1);
            }

            dst.debt_receivable = dst.debt_receivable.add(src._debt);
            src.debt_payable = src.debt_payable.add(src._debt);
        }
    }

    function debtRedeem(
        bytes32 srcStoremanGroupId,
        bytes32 dstStoremanGroupId
    ) external onlyHtlc {

        uint tokenCount = storemanTokenCountMap[srcStoremanGroupId];
        for (uint i = 0; i < tokenCount; i++) {
            uint id = storemanTokensMap[srcStoremanGroupId][i];
            Quota storage src = quotaMap[id][srcStoremanGroupId];
            if (src._debt == 0) {
                continue;
            }
            Quota storage dst = quotaMap[id][dstStoremanGroupId];
            dst.debt_receivable = dst.debt_receivable.sub(src.debt_payable);
            dst._debt = dst._debt.add(src._debt);

            src.debt_payable = 0;
            src._debt = 0;
        }
    }

    function debtRevoke(
        bytes32 srcStoremanGroupId,
        bytes32 dstStoremanGroupId
    ) external onlyHtlc {

        uint tokenCount = storemanTokenCountMap[srcStoremanGroupId];
        for (uint i = 0; i < tokenCount; i++) {
            uint id = storemanTokensMap[srcStoremanGroupId][i];
            Quota storage src = quotaMap[id][srcStoremanGroupId];
            if (src._debt == 0) {
                continue;
            }
            Quota storage dst = quotaMap[id][dstStoremanGroupId];
            
            dst.debt_receivable = dst.debt_receivable.sub(src.debt_payable);
            src.debt_payable = 0;
        }
    }

    function assetLock(
        bytes32 srcStoremanGroupId,
        bytes32 dstStoremanGroupId
    ) external onlyHtlc {

        uint tokenCount = storemanTokenCountMap[srcStoremanGroupId];
        for (uint i = 0; i < tokenCount; i++) {
            uint id = storemanTokensMap[srcStoremanGroupId][i];
            Quota storage src = quotaMap[id][srcStoremanGroupId];

            require( src.asset_receivable == uint(0) && src.asset_payable == uint(0),
                "There are asset_receivable or asset_payable in src storeman"
            );

            if (src._asset == 0) {
                continue;
            }

            Quota storage dst = quotaMap[id][dstStoremanGroupId];
            if (!dst._active) {
                dst._active = true;
                storemanTokensMap[dstStoremanGroupId][storemanTokenCountMap[dstStoremanGroupId]] = id;
                storemanTokenCountMap[dstStoremanGroupId] = storemanTokenCountMap[dstStoremanGroupId]
                    .add(1);
            }

            dst.asset_receivable = dst.asset_receivable.add(src._asset);
            src.asset_payable = src.asset_payable.add(src._asset);
        }
    }

    function assetRedeem(
        bytes32 srcStoremanGroupId,
        bytes32 dstStoremanGroupId
    ) external onlyHtlc {

        uint tokenCount = storemanTokenCountMap[srcStoremanGroupId];
        for (uint i = 0; i < tokenCount; i++) {
            uint id = storemanTokensMap[srcStoremanGroupId][i];
            Quota storage src = quotaMap[id][srcStoremanGroupId];
            if (src._asset == 0) {
                continue;
            }
            Quota storage dst = quotaMap[id][dstStoremanGroupId];
            dst.asset_receivable = dst.asset_receivable.sub(src.asset_payable);
            dst._asset = dst._asset.add(src._asset);

            src.asset_payable = 0;
            src._asset = 0;
        }
    }

    function assetRevoke(
        bytes32 srcStoremanGroupId,
        bytes32 dstStoremanGroupId
    ) external onlyHtlc {

        uint tokenCount = storemanTokenCountMap[srcStoremanGroupId];
        for (uint i = 0; i < tokenCount; i++) {
            uint id = storemanTokensMap[srcStoremanGroupId][i];
            Quota storage src = quotaMap[id][srcStoremanGroupId];
            if (src._asset == 0) {
                continue;
            }
            Quota storage dst = quotaMap[id][dstStoremanGroupId];
            
            dst.asset_receivable = dst.asset_receivable.sub(src.asset_payable);
            src.asset_payable = 0;
        }
    }

    function getUserMintQuota(uint tokenId, bytes32 storemanGroupId)
        public
        view
        returns (uint)
    {

        string memory symbol;
        uint decimals;
        uint tokenPrice;

        (symbol, decimals) = getTokenAncestorInfo(tokenId);
        tokenPrice = getPrice(symbol);
        if (tokenPrice == 0) {
            return 0;
        }

        uint fiatQuota = getUserFiatMintQuota(storemanGroupId, symbol);

        return fiatQuota.div(tokenPrice).mul(10**decimals).div(1 ether);
    }

    function getSmgMintQuota(uint tokenId, bytes32 storemanGroupId)
        public
        view
        returns (uint)
    {

        string memory symbol;
        uint decimals;
        uint tokenPrice;

        (symbol, decimals) = getTokenAncestorInfo(tokenId);
        tokenPrice = getPrice(symbol);
        if (tokenPrice == 0) {
            return 0;
        }

        uint fiatQuota = getSmgFiatMintQuota(storemanGroupId, symbol);

        return fiatQuota.div(tokenPrice).mul(10**decimals).div(1 ether);
    }

    function getUserBurnQuota(uint tokenId, bytes32 storemanGroupId)
        public
        view
        returns (uint burnQuota)
    {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        burnQuota = quota._debt.sub(quota.debt_payable);
    }

    function getSmgBurnQuota(uint tokenId, bytes32 storemanGroupId)
        public
        view
        returns (uint burnQuota)
    {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        burnQuota = quota._asset.sub(quota.asset_payable);
    }

    function getAsset(uint tokenId, bytes32 storemanGroupId)
        public
        view
        returns (uint asset, uint asset_receivable, uint asset_payable)
    {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        return (quota._asset, quota.asset_receivable, quota.asset_payable);
    }

    function getDebt(uint tokenId, bytes32 storemanGroupId)
        public
        view
        returns (uint debt, uint debt_receivable, uint debt_payable)
    {

        Quota storage quota = quotaMap[tokenId][storemanGroupId];
        return (quota._debt, quota.debt_receivable, quota.debt_payable);
    }

    function isDebtClean(bytes32 storemanGroupId) external view returns (bool) {

        uint tokenCount = storemanTokenCountMap[storemanGroupId];
        if (tokenCount == 0) {
            if (debtOracleAddress == address(0)) {
                return true;
            } else {
                IDebtOracle debtOracle = IDebtOracle(debtOracleAddress);
                return debtOracle.isDebtClean(storemanGroupId);
            }
        }

        for (uint i = 0; i < tokenCount; i++) {
            uint id = storemanTokensMap[storemanGroupId][i];
            Quota storage src = quotaMap[id][storemanGroupId];
            if (src._debt > 0 || src.debt_payable > 0 || src.debt_receivable > 0) {
                return false;
            }

            if (src._asset > 0 || src.asset_payable > 0 || src.asset_receivable > 0) {
                return false;
            }
        }
        return true;
    }

    function getFastMinCount(uint tokenId) public view returns (uint, string, uint, uint, uint) {

        if (fastCrossMinValue == 0) {
            return (0, "", 0, 0, 0);
        }
        string memory symbol;
        uint decimals;
        (symbol, decimals) = getTokenAncestorInfo(tokenId);
        uint price = getPrice(symbol);
        uint count = fastCrossMinValue.mul(10**decimals).div(price);
        return (fastCrossMinValue, symbol, decimals, price, count);
    }




    function getFiatDeposit(bytes32 storemanGroupId) private view returns (uint) {

        uint deposit = getDepositAmount(storemanGroupId);
        return deposit.mul(getPrice(depositTokenSymbol));
    }

    function getUserFiatMintQuota(bytes32 storemanGroupId, string rawSymbol) private view returns (uint) {

        string memory symbol;
        uint decimals;

        uint totalTokenUsedValue = 0;
        for (uint i = 0; i < storemanTokenCountMap[storemanGroupId]; i++) {
            uint id = storemanTokensMap[storemanGroupId][i];
            (symbol, decimals) = getTokenAncestorInfo(id);
            Quota storage q = quotaMap[id][storemanGroupId];
            uint tokenValue = q.asset_receivable.add(q._asset).mul(getPrice(symbol)).mul(1 ether).div(10**decimals); /// change Decimals to 18 digits
            totalTokenUsedValue = totalTokenUsedValue.add(tokenValue);
        }
        
        return getLastDeposit(storemanGroupId, rawSymbol, totalTokenUsedValue);
    }

    function getLastDeposit(bytes32 storemanGroupId, string rawSymbol, uint totalTokenUsedValue) private view returns (uint depositValue) {

        if (keccak256(rawSymbol) == bytes32(0x28ba6d5ac5913a399cc20b18c5316ad1459ae671dd23558d05943d54c61d0997)) {
            depositValue = getFiatDeposit(storemanGroupId);
        } else {
            depositValue = getFiatDeposit(storemanGroupId).mul(DENOMINATOR).div(depositRate); // 15000 = 150%
        }

        if (depositValue <= totalTokenUsedValue) {
            depositValue = 0;
        } else {
            depositValue = depositValue.sub(totalTokenUsedValue); /// decimals: 18
        }
    }

    function getSmgFiatMintQuota(bytes32 storemanGroupId, string rawSymbol) private view returns (uint) {

        string memory symbol;
        uint decimals;

        uint totalTokenUsedValue = 0;
        for (uint i = 0; i < storemanTokenCountMap[storemanGroupId]; i++) {
            uint id = storemanTokensMap[storemanGroupId][i];
            (symbol, decimals) = getTokenAncestorInfo(id);
            Quota storage q = quotaMap[id][storemanGroupId];
            uint tokenValue = q.debt_receivable.add(q._debt).mul(getPrice(symbol)).mul(1 ether).div(10**decimals); /// change Decimals to 18 digits
            totalTokenUsedValue = totalTokenUsedValue.add(tokenValue);
        }

        uint depositValue = 0;
        if (keccak256(rawSymbol) == keccak256("WAN")) {
            depositValue = getFiatDeposit(storemanGroupId);
        } else {
            depositValue = getFiatDeposit(storemanGroupId).mul(DENOMINATOR).div(depositRate); // 15000 = 150%
        }

        if (depositValue <= totalTokenUsedValue) {
            return 0;
        }

        return depositValue.sub(totalTokenUsedValue); /// decimals: 18
    }

    function getDepositAmount(bytes32 storemanGroupId)
        private
        view
        returns (uint)
    {

        _IStoremanGroup smgAdmin = _IStoremanGroup(depositOracleAddress);
        return smgAdmin.getDeposit(storemanGroupId);
    }

    function getTokenAncestorInfo(uint tokenId)
        private
        view
        returns (string ancestorSymbol, uint decimals)
    {

        _ITokenManager tokenManager = _ITokenManager(tokenManagerAddress);
        (ancestorSymbol,decimals) = tokenManager.getAncestorSymbol(tokenId);
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {

        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function getPrice(string symbol) private view returns (uint price) {

        IOracle oracle = IOracle(priceOracleAddress);
        price = oracle.getValue(stringToBytes32(symbol));
    }
}