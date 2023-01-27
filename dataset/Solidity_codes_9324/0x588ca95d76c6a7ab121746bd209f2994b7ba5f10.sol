



pragma solidity ^0.6.0;

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
}


pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}


pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.6.0;

interface ENSRegistryOwnerI {

    function owner(bytes32 node) external view returns (address);

}

interface ENSReverseRegistrarI {

    function setName(string calldata name) external returns (bytes32 node);

}


pragma solidity ^0.6.0;


abstract contract OracleRequest {

    uint256 public EUR_WEI; //number of wei per EUR

    uint256 public lastUpdate; //timestamp of when the last update occurred

    function ETH_EUR() public view virtual returns (uint256); //number of EUR per ETH (rounded down!)

    function ETH_EURCENT() public view virtual returns (uint256); //number of EUR cent per ETH (rounded down!)

}


pragma solidity ^0.6.0;

interface CS2PropertiesI {


    enum AssetType {
        Honeybadger,
        Llama,
        Panda,
        Doge
    }

    enum Colors {
        Black,
        Green,
        Blue,
        Yellow,
        Red
    }

    function getType(uint256 tokenId) external view returns (AssetType);

    function getColor(uint256 tokenId) external view returns (Colors);


}


pragma solidity ^0.6.0;


abstract contract IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) public view virtual returns (uint256);

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view virtual returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external virtual;

    function isApprovedForAll(address account, address operator) external view virtual returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external virtual;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external virtual;
}


pragma solidity ^0.6.0;


abstract contract CS2PresaleRedeemI is IERC1155 {
    enum AssetType {
        Honeybadger,
        Llama,
        Panda,
        Doge
    }

    function redeemBatch(address owner, AssetType[] calldata _type, uint256[] calldata _count) external virtual;
}


pragma solidity ^0.6.2;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}


pragma solidity ^0.6.0;


abstract contract ERC721ExistsI is IERC721 {

    function exists(uint256 tokenId) public view virtual returns (bool);

}


pragma solidity ^0.6.0;



abstract contract CS2OCSBaseI is ERC721ExistsI, IERC721Enumerable {

    function createWithProof(bytes32 tokenData, bytes32[] memory merkleProof) public virtual returns (uint256);

}


pragma solidity ^0.6.0;









contract CS2OnChainShop {

    using SafeMath for uint256;

    CS2OCSBaseI internal CS2;
    CS2PresaleRedeemI internal CS2Presale;
    OracleRequest internal oracle;

    address payable public beneficiary;
    address public shippingControl;
    address public tokenAssignmentControl;

    uint256 public basePriceEurCent;
    uint256 public priceTargetTimestamp;
    uint256[4] public lastSaleTimestamp; // Every AssetType has their own sale/price tracking.
    uint256[4] public lastSalePriceEurCent;
    uint256[4] public lastSlotPriceEurCent;
    uint256 public slotSeconds = 600;
    uint256 public increaseFactorMicro; // 2500 for 0.25% (0.0025 * 1M)

    struct SoldInfo {
        address recipient;
        uint256 blocknumber;
        uint256 tokenId;
        bool presale;
        CS2PropertiesI.AssetType aType;
    }

    SoldInfo[] public soldSequence;
    uint256 public lastAssignedSequence;
    uint256 public lastRetrievedSequence;

    address[8] public tokenPools; // Pools for every AssetType as well as "normal" OCS and presale.
    uint256[8] public startIds;
    uint256[8] public tokenPoolSize;
    uint256[8] public unassignedInPool;
    uint256[2500][8] public tokenIdPools; // Max 2500 IDs per pool.

    bool internal _isOpen = true;

    enum ShippingStatus{
        Initial,
        Sold,
        ShippingSubmitted,
        ShippingConfirmed
    }

    mapping(uint256 => ShippingStatus) public deliveryStatus;

    event BasePriceChanged(uint256 previousBasePriceEurCent, uint256 newBasePriceEurCent);
    event PriceTargetTimeChanged(uint256 previousPriceTargetTimestamp, uint256 newPriceTargetTimestamp);
    event IncreaseFactorChanged(uint256 previousIncreaseFactorMicro, uint256 newIncreaseFactorMicro);
    event OracleChanged(address indexed previousOracle, address indexed newOracle);
    event BeneficiaryTransferred(address indexed previousBeneficiary, address indexed newBeneficiary);
    event TokenAssignmentControlTransferred(address indexed previousTokenAssignmentControl, address indexed newTokenAssignmentControl);
    event ShippingControlTransferred(address indexed previousShippingControl, address indexed newShippingControl);
    event ShopOpened();
    event ShopClosed();
    event AssetSold(address indexed buyer, address recipient, bool indexed presale, CS2PropertiesI.AssetType indexed aType, uint256 sequenceNumber, uint256 priceWei);
    event AssetAssigned(address indexed recipient, uint256 indexed tokenId, uint256 sequenceNumber);
    event AssignedAssetRetrieved(uint256 indexed tokenId, address indexed recipient);
    event ShippingSubmitted(address indexed owner, uint256[] tokenIds, string deliveryInfo);
    event ShippingFailed(address indexed owner, uint256 indexed tokenId, string reason);
    event ShippingConfirmed(address indexed owner, uint256 indexed tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    constructor(OracleRequest _oracle,
        address _CS2Address,
        address _CS2PresaleAddress,
        uint256 _basePriceEurCent,
        uint256 _priceTargetTimestamp,
        uint256 _increaseFactorMicro,
        address payable _beneficiary,
        address _shippingControl,
        address _tokenAssignmentControl,
        uint256 _tokenPoolSize,
        address[] memory _tokenPools,
        uint256[] memory _startIds)
    public
    {
        oracle = _oracle;
        require(address(oracle) != address(0x0), "You need to provide an actual Oracle contract.");
        CS2 = CS2OCSBaseI(_CS2Address);
        require(address(CS2) != address(0x0), "You need to provide an actual Cryptostamp 2 contract.");
        CS2Presale = CS2PresaleRedeemI(_CS2PresaleAddress);
        require(address(CS2Presale) != address(0x0), "You need to provide an actual Cryptostamp 2 Presale contract.");
        beneficiary = _beneficiary;
        require(address(beneficiary) != address(0x0), "You need to provide an actual beneficiary address.");
        shippingControl = _shippingControl;
        require(address(shippingControl) != address(0x0), "You need to provide an actual shippingControl address.");
        tokenAssignmentControl = _tokenAssignmentControl;
        require(address(tokenAssignmentControl) != address(0x0), "You need to provide an actual tokenAssignmentControl address.");
        basePriceEurCent = _basePriceEurCent;
        require(basePriceEurCent > 0, "You need to provide a non-zero base price.");
        priceTargetTimestamp = _priceTargetTimestamp;
        require(priceTargetTimestamp > now, "You need to provide a price target time in the future.");
        increaseFactorMicro = _increaseFactorMicro;
        uint256 poolnum = tokenPools.length;
        require(_tokenPools.length == poolnum, "Need correct amount of token pool addresses.");
        require(_startIds.length == poolnum, "Need correct amount of token pool start IDs.");
        for (uint256 i = 0; i < poolnum; i++) {
            tokenPools[i] = _tokenPools[i];
            startIds[i] = _startIds[i];
            tokenPoolSize[i] = _tokenPoolSize;
        }
    }

    modifier onlyBeneficiary() {

        require(msg.sender == beneficiary, "Only the current benefinicary can call this function.");
        _;
    }

    modifier onlyShippingControl() {

        require(msg.sender == shippingControl, "shippingControl key required for this function.");
        _;
    }

    modifier onlyTokenAssignmentControl() {

        require(msg.sender == tokenAssignmentControl, "tokenAssignmentControl key required for this function.");
        _;
    }

    modifier requireOpen() {

        require(isOpen() == true, "This call only works when the shop is open.");
        _;
    }


    function setBasePrice(uint256 _newBasePriceEurCent)
    public
    onlyBeneficiary
    {

        require(_newBasePriceEurCent > 0, "You need to provide a non-zero price.");
        emit BasePriceChanged(basePriceEurCent, _newBasePriceEurCent);
        basePriceEurCent = _newBasePriceEurCent;
    }

    function setPriceTargetTime(uint256 _newPriceTargetTimestamp)
    public
    onlyBeneficiary
    {

        require(_newPriceTargetTimestamp > now, "You need to provide a price target time in the future.");
        emit PriceTargetTimeChanged(priceTargetTimestamp, _newPriceTargetTimestamp);
        priceTargetTimestamp = _newPriceTargetTimestamp;
    }

    function setIncreaseFactor(uint256 _newIncreaseFactorMicro)
    public
    onlyBeneficiary
    {

        emit IncreaseFactorChanged(increaseFactorMicro, _newIncreaseFactorMicro);
        increaseFactorMicro = _newIncreaseFactorMicro;
    }

    function setOracle(OracleRequest _newOracle)
    public
    onlyBeneficiary
    {

        require(address(_newOracle) != address(0x0), "You need to provide an actual Oracle contract.");
        emit OracleChanged(address(oracle), address(_newOracle));
        oracle = _newOracle;
    }

    function transferBeneficiary(address payable _newBeneficiary)
    public
    onlyBeneficiary
    {

        require(_newBeneficiary != address(0), "beneficiary cannot be the zero address.");
        emit BeneficiaryTransferred(beneficiary, _newBeneficiary);
        beneficiary = _newBeneficiary;
    }

    function transferTokenAssignmentControl(address _newTokenAssignmentControl)
    public
    onlyTokenAssignmentControl
    {

        require(_newTokenAssignmentControl != address(0), "tokenAssignmentControl cannot be the zero address.");
        emit TokenAssignmentControlTransferred(tokenAssignmentControl, _newTokenAssignmentControl);
        tokenAssignmentControl = _newTokenAssignmentControl;
    }

    function transferShippingControl(address _newShippingControl)
    public
    onlyShippingControl
    {

        require(_newShippingControl != address(0), "shippingControl cannot be the zero address.");
        emit ShippingControlTransferred(shippingControl, _newShippingControl);
        shippingControl = _newShippingControl;
    }

    function openShop()
    public
    onlyBeneficiary
    {

        _isOpen = true;
        emit ShopOpened();
    }

    function closeShop()
    public
    onlyBeneficiary
    {

        _isOpen = false;
        emit ShopClosed();
    }


    function isOpen()
    public view
    returns (bool)
    {

        return _isOpen;
    }

    function priceEurCent(CS2PropertiesI.AssetType _type)
    public view
    returns (uint256)
    {

        return priceEurCentDynamic(true, _type);
    }

    function priceEurCentDynamic(bool freezeSaleSlot, CS2PropertiesI.AssetType _type)
    public view
    returns (uint256)
    {

        uint256 nowSlot = getTimeSlot(now);
        uint256 typeNum = uint256(_type);
        if (lastSaleTimestamp[typeNum] == 0 || nowSlot == 0) {
            return basePriceEurCent;
        }
        uint256 lastSaleSlot = getTimeSlot(lastSaleTimestamp[typeNum]);
        if (freezeSaleSlot) {
            if (nowSlot == lastSaleSlot) {
                return lastSlotPriceEurCent[typeNum];
            }
        }
        uint256 priceIncrease = lastSalePriceEurCent[typeNum] * increaseFactorMicro / 1_000_000;
        uint256 priceDecrease = (lastSalePriceEurCent[typeNum] + priceIncrease - basePriceEurCent) * (lastSaleSlot - nowSlot) / lastSaleSlot;
        return lastSalePriceEurCent[typeNum] + priceIncrease - priceDecrease;
    }

    function getTimeSlot(uint256 _timestamp)
    public view
    returns (uint256)
    {

        if (_timestamp >= priceTargetTimestamp) {
            return 0;
        }
        return (priceTargetTimestamp - _timestamp) / slotSeconds + 1;
    }

    function priceWei(CS2PropertiesI.AssetType _type)
    public view
    returns (uint256)
    {

        return priceEurCent(_type).mul(oracle.EUR_WEI()).div(100);
    }

    function getPoolIndex(bool _isPresale, CS2PropertiesI.AssetType _type)
    public pure
    returns (uint256)
    {

        return (_isPresale ? 4 : 0) + uint256(_type);
    }

    function availableForSale(bool _presale, CS2PropertiesI.AssetType _type)
    public view
    returns (uint256)
    {

        uint256 poolIndex = getPoolIndex(_presale, _type);
        return tokenPoolSize[poolIndex].sub(unassignedInPool[poolIndex]);
    }

    function isSoldOut(bool _presale, CS2PropertiesI.AssetType _type)
    public view
    returns (bool)
    {

        return availableForSale(_presale, _type) == 0;
    }

    function buy(CS2PropertiesI.AssetType _type, uint256 _amount, address payable _recipient, bytes32[] memory tokenData, bytes32[] memory merkleProofsAggregated)
    public payable
    requireOpen
    {

        if (tokenData.length > 0) {
            mintAssetsWithAggregatedProofs(tokenData, merkleProofsAggregated);
        }
        bool isPresale = false;
        require(_amount <= availableForSale(isPresale, _type), "Not enough assets available to buy that amount.");
        uint256 curPriceWei = priceWei(_type);
        uint256 payAmount = _amount.mul(curPriceWei);
        require(msg.value >= payAmount, "You need to send enough currency to buy the specified amount.");
        uint256 typeNum = uint256(_type);
        if (lastSaleTimestamp[typeNum] == 0 || getTimeSlot(now) != getTimeSlot(lastSaleTimestamp[typeNum])) {
            lastSlotPriceEurCent[typeNum] = priceEurCent(_type);
        }
        (bool sendSuccess, /*bytes memory data*/) = beneficiary.call{value: payAmount}("");
        if (!sendSuccess) { revert("Error in sending payment!"); }
        for (uint256 i = 0; i < _amount; i++) {
            soldSequence.push(SoldInfo(_recipient, block.number, 0, isPresale, _type));
            emit AssetSold(msg.sender, _recipient, isPresale, _type, soldSequence.length, curPriceWei);
            lastSalePriceEurCent[typeNum] = priceEurCentDynamic(false, _type);
            lastSaleTimestamp[typeNum] = now;
        }
        uint256 poolIndex = getPoolIndex(isPresale, _type);
        unassignedInPool[poolIndex] = unassignedInPool[poolIndex].add(_amount);
        assignPurchasedAssets(_amount + 1);
        retrieveAssignedAssets(_amount + 1);
        if (msg.value > payAmount) {
            (bool returnSuccess, /*bytes memory data*/) = msg.sender.call{value: msg.value.sub(payAmount)}("");
            if (!returnSuccess) { revert("Error in returning change!"); }
        }
    }

    function redeemVoucher(CS2PropertiesI.AssetType _type, uint256 _amount, address payable _recipient, bytes32[] memory tokenData, bytes32[] memory merkleProofsAggregated)
    public
    requireOpen
    {

        if (tokenData.length > 0) {
            mintAssetsWithAggregatedProofs(tokenData, merkleProofsAggregated);
        }
        bool isPresale = true;
        require(_amount <= availableForSale(isPresale, _type), "Not enough assets available to buy that amount.");
        uint256 typeNum = uint256(_type);
        require(CS2Presale.balanceOf(msg.sender, typeNum) >= _amount, "You need to own enough presale vouchers to redeem the specified amount.");
        CS2PresaleRedeemI.AssetType[] memory redeemTypes = new CS2PresaleRedeemI.AssetType[](1);
        uint256[] memory redeemAmounts = new uint256[](1);
        redeemTypes[0] = CS2PresaleRedeemI.AssetType(typeNum);
        redeemAmounts[0] = _amount;
        CS2Presale.redeemBatch(msg.sender, redeemTypes, redeemAmounts);
        for (uint256 i = 0; i < _amount; i++) {
            soldSequence.push(SoldInfo(_recipient, block.number, 0, isPresale, _type));
            emit AssetSold(msg.sender, _recipient, isPresale, _type, soldSequence.length, 0);
        }
        uint256 poolIndex = getPoolIndex(isPresale, _type);
        unassignedInPool[poolIndex] = unassignedInPool[poolIndex].add(_amount);
        assignPurchasedAssets(_amount + 1);
        retrieveAssignedAssets(_amount + 1);
    }

    function getUnassignedAssetCount()
    public view
    returns (uint256)
    {

        return soldSequence.length - lastAssignedSequence;
    }

    function getUnretrievedAssetCount()
    public view
    returns (uint256)
    {

        return soldSequence.length - lastRetrievedSequence;
    }

    function getSoldCount()
    public view
    returns (uint256)
    {

        return soldSequence.length;
    }

    function getSoldTokenId(uint256 _sequenceNumber, bytes32 _currentBlockHash)
    public view
    returns (uint256)
    {

        if (_sequenceNumber <= lastAssignedSequence) {
            uint256 seqIdx = _sequenceNumber.sub(1);
            return soldSequence[seqIdx].tokenId;
        }
        uint256 poolIndex;
        uint256 slotIndex;
        if (_sequenceNumber == lastAssignedSequence.add(1)) {
            (poolIndex, slotIndex) = _getNextUnassignedPoolSlot(_currentBlockHash);
        }
        else {
            (poolIndex, slotIndex) = _getUnassignedPoolSlotDeep(_sequenceNumber, _currentBlockHash);
        }
        return _getTokenIdForPoolSlot(poolIndex, slotIndex);
    }

    function _getTokenIdForPoolSlot(uint256 _poolIndex, uint256 _slotIndex)
    internal view
    returns (uint256)
    {

        uint256 tokenId = tokenIdPools[_poolIndex][_slotIndex];
        if (tokenId == 0) {
            tokenId = startIds[_poolIndex].add(_slotIndex);
        }
        return tokenId;
    }

    function _getSemiRandomSlotIndex(uint256 seqIdx, uint256 poolSize, bytes32 _currentBlockHash)
    internal view
    returns (uint256)
    {

        bytes32 bhash;
        if (soldSequence[seqIdx].blocknumber == block.number) {
          require(_currentBlockHash != bytes32(""), "For assets sold in the current block, provide a valid block hash.");
          bhash = _currentBlockHash;
        }
        else if (block.number < 256 || soldSequence[seqIdx].blocknumber >= block.number.sub(256)) {
          bhash = blockhash(soldSequence[seqIdx].blocknumber);
        }
        else {
          bhash = keccak256("");
        }
        return uint256(keccak256(abi.encodePacked(seqIdx, bhash))) % poolSize;
    }

    function _getNextUnassignedPoolSlot(bytes32 _currentBlockHash)
    internal view
    returns (uint256, uint256)
    {

        uint256 seqIdx = lastAssignedSequence; // last + 1 is next seqNo, seqIdx is seqNo - 1
        uint256 poolIndex = getPoolIndex(soldSequence[seqIdx].presale, soldSequence[seqIdx].aType);
        uint256 slotIndex = _getSemiRandomSlotIndex(seqIdx, tokenPoolSize[poolIndex], _currentBlockHash);
        return (poolIndex, slotIndex);
    }

    function _getUnassignedPoolSlotDeep(uint256 _sequenceNumber, bytes32 _currentBlockHash)
    internal view
    returns (uint256, uint256)
    {

        require(_sequenceNumber > lastAssignedSequence, "The asset was assigned already.");
        require(_sequenceNumber <= soldSequence.length, "Exceeds maximum sequence number.");
        uint256 depth = _sequenceNumber.sub(lastAssignedSequence);
        uint256[] memory poolIndex = new uint256[](depth);
        uint256[] memory slotIndex = new uint256[](depth);
        uint256[] memory slotRedirect = new uint256[](depth);
        uint256[] memory poolSizeReduction = new uint256[](tokenPoolSize.length);
        for (uint256 i = 0; i < depth; i++) {
            uint256 seqIdx = lastAssignedSequence.add(i); // last + 1 is next seqNo, seqIdx is seqNo - 1, then we add i
            poolIndex[i] = getPoolIndex(soldSequence[seqIdx].presale, soldSequence[seqIdx].aType);
            uint256 calcPoolSize = tokenPoolSize[poolIndex[i]].sub(poolSizeReduction[poolIndex[i]]);
            slotIndex[i] = _getSemiRandomSlotIndex(seqIdx, calcPoolSize, _currentBlockHash);
            for (uint256 fitloop = 0; fitloop < i; fitloop++) {
                for (uint256 j = 0; j < i; j++) {
                    if (poolIndex[i] == poolIndex[j] && slotIndex[i] == slotIndex[j]) {
                        slotIndex[i] = slotRedirect[j];
                    }
                }
            }
            slotRedirect[i] = calcPoolSize.sub(1);
            poolSizeReduction[poolIndex[i]] = poolSizeReduction[poolIndex[i]].add(1);
        }
        return (poolIndex[depth.sub(1)], slotIndex[depth.sub(1)]);
    }

    function assignPurchasedAssets(uint256 _maxCount)
    public
    {

        for (uint256 i = 0; i < _maxCount; i++) {
            if (lastAssignedSequence < soldSequence.length) {
                _assignNextPurchasedAsset(false);
            }
        }
    }

    function assignNextPurchasedAssset()
    public
    {

        _assignNextPurchasedAsset(true);
    }

    function _assignNextPurchasedAsset(bool revertForSameBlock)
    internal
    {

        uint256 nextSequenceNumber = lastAssignedSequence.add(1);
        uint256 seqIdx = nextSequenceNumber.sub(1);
        if (soldSequence[seqIdx].blocknumber < block.number) {
            (uint256 poolIndex, uint256 slotIndex) = _getNextUnassignedPoolSlot(bytes32(""));
            uint256 tokenId = _getTokenIdForPoolSlot(poolIndex, slotIndex);
            soldSequence[seqIdx].tokenId = tokenId;
            emit AssetAssigned(soldSequence[seqIdx].recipient, tokenId, nextSequenceNumber);
            if (lastRetrievedSequence == lastAssignedSequence && CS2.exists(tokenId)) {
                _retrieveAssignedAsset(seqIdx);
            }
            uint256 lastSlotIndex = tokenPoolSize[poolIndex].sub(1);
            if (slotIndex != lastSlotIndex) {
                uint256 lastValue = tokenIdPools[poolIndex][lastSlotIndex];
                if (lastValue == 0) {
                    lastValue = startIds[poolIndex] + lastSlotIndex;
                }
                tokenIdPools[poolIndex][slotIndex] = lastValue;
            }
            tokenPoolSize[poolIndex] = tokenPoolSize[poolIndex].sub(1);
            unassignedInPool[poolIndex] = unassignedInPool[poolIndex].sub(1);
            deliveryStatus[tokenId] = ShippingStatus.Sold;
            lastAssignedSequence = nextSequenceNumber;
        }
        else {
            if (revertForSameBlock) {
                revert("Cannot assign assets in the same block.");
            }
        }
    }

    function mintAssetsWithAggregatedProofs(bytes32[] memory tokenData, bytes32[] memory merkleProofsAggregated)
    public
    {

        uint256 count = tokenData.length;
        require(count > 0, "Need actual data and proofs");
        require(merkleProofsAggregated.length % count == 0, "Count of data and proofs need to match");
        uint256 singleProofLength = merkleProofsAggregated.length / count;
        for (uint256 i = 0; i < count; i++) {
            uint256 tokenId = uint256(tokenData[i] >> 168); // shift by 20 bytes for address and 1 byte for properties
            if (!CS2.exists(tokenId)) {
                bytes32[] memory merkleProof = new bytes32[](singleProofLength);
                for (uint256 j = 0; j < singleProofLength; j++) {
                    merkleProof[j] = merkleProofsAggregated[singleProofLength.mul(i).add(j)];
                }
                CS2.createWithProof(tokenData[i], merkleProof);
            }
        }
    }

    function retrieveAssignedAssets(uint256 _maxCount)
    public
    {

        for (uint256 i = 0; i < _maxCount; i++) {
            if (lastRetrievedSequence < lastAssignedSequence) {
                uint256 seqIdx = lastRetrievedSequence; // last + 1 is next seqNo, seqIdx is seqNo - 1
                if (CS2.exists(soldSequence[seqIdx].tokenId)) {
                    _retrieveAssignedAsset(seqIdx);
                }
            }
        }
    }

    function _retrieveAssignedAsset(uint256 seqIdx)
    internal
    {

        uint256 poolIndex = getPoolIndex(soldSequence[seqIdx].presale, soldSequence[seqIdx].aType);
        require(CS2.ownerOf(soldSequence[seqIdx].tokenId) == tokenPools[poolIndex], "Already transferred out of the pool");
        CS2.safeTransferFrom(tokenPools[poolIndex], soldSequence[seqIdx].recipient, soldSequence[seqIdx].tokenId);
        emit AssignedAssetRetrieved(soldSequence[seqIdx].tokenId, soldSequence[seqIdx].recipient);
        lastRetrievedSequence = seqIdx.add(1); // current SeqNo is SeqIdx + 1
    }


    function shipToMe(string memory _deliveryInfo, uint256[] memory _tokenIds)
    public
    requireOpen
    {

        uint256 count = _tokenIds.length;
        for (uint256 i = 0; i < count; i++) {
            require(CS2.ownerOf(_tokenIds[i]) == msg.sender, "You can only request shipping for your own tokens.");
            require(deliveryStatus[_tokenIds[i]] == ShippingStatus.Sold, "Shipping was already requested for one of these tokens or it was not sold by this shop.");
            deliveryStatus[_tokenIds[i]] = ShippingStatus.ShippingSubmitted;
        }
        emit ShippingSubmitted(msg.sender, _tokenIds, _deliveryInfo);
    }

    function confirmShipping(uint256[] memory _tokenIds)
    public
    onlyShippingControl
    {

        uint256 count = _tokenIds.length;
        for (uint256 i = 0; i < count; i++) {
            deliveryStatus[_tokenIds[i]] = ShippingStatus.ShippingConfirmed;
            emit ShippingConfirmed(CS2.ownerOf(_tokenIds[i]), _tokenIds[i]);
        }
    }

    function rejectShipping(uint256[] memory _tokenIds, string memory _reason)
    public
    onlyShippingControl
    {

        uint256 count = _tokenIds.length;
        for (uint256 i = 0; i < count; i++) {
            deliveryStatus[_tokenIds[i]] = ShippingStatus.Sold;
            emit ShippingFailed(CS2.ownerOf(_tokenIds[i]), _tokenIds[i], _reason);
        }
    }


    function registerReverseENS(address _reverseRegistrarAddress, string calldata _name)
    external
    onlyTokenAssignmentControl
    {

        require(_reverseRegistrarAddress != address(0), "need a valid reverse registrar");
        ENSReverseRegistrarI(_reverseRegistrarAddress).setName(_name);
    }


    function rescueToken(IERC20 _foreignToken, address _to)
    external
    onlyTokenAssignmentControl
    {

        _foreignToken.transfer(_to, _foreignToken.balanceOf(address(this)));
    }

    function approveNFTrescue(IERC721 _foreignNFT, address _to)
    external
    onlyTokenAssignmentControl
    {

        _foreignNFT.setApprovalForAll(_to, true);
    }

}