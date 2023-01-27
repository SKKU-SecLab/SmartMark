
pragma solidity >=0.6.0;

interface IERC1155Preset {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;


    function supportsInterface(bytes4 interfaceId) external view returns (bool);


    function mint(address to, uint256 id, uint256 amount, bytes memory data) external;


    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;


    function getOwnerIdByIndex(address owner, uint256 index) external view returns (uint256);


    function getOwnerIdIndex(address owner, uint256 id) external view returns (uint256);

}// MIT

pragma solidity >=0.6.0;

interface INodePackV3 {

  function doesPackExist(address entity, uint packId) external view returns (bool);


  function hasPackExpired(address entity, uint packId) external view returns (bool);


  function claim(uint packId, uint timestamp, address toStrongPool) external payable returns (uint);



  function getPackId(address _entity, uint _packType) external pure returns (bytes memory);


  function getEntityPackTotalNodeCount(address _entity, uint _packType) external view returns (uint);


  function getEntityPackActiveNodeCount(address _entity, uint _packType) external view returns (uint);


  function migrateNodes(address _entity, uint _nodeType, uint _nodeCount, uint _lastPaidAt, uint _rewardsDue, uint _totalClaimed) external returns (bool);



  function updatePackState(address _entity, uint _packType) external;

}// MIT

pragma solidity >=0.6.0;

library SafeMath {

  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    uint256 c = a + b;
    if (c < a) return (false, 0);
    return (true, c);
  }

  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    if (b > a) return (false, 0);
    return (true, a - b);
  }

  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    if (a == 0) return (true, 0);
    uint256 c = a * b;
    if (c / a != b) return (false, 0);
    return (true, c);
  }

  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    if (b == 0) return (false, 0);
    return (true, a / b);
  }

  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    if (b == 0) return (false, 0);
    return (true, a % b);
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath: modulo by zero");
    return a % b;
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

    require(b <= a, errorMessage);
    return a - b;
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    return a / b;
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    return a % b;
  }
}// MIT

pragma solidity >=0.6.0 <=0.8.9;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <=0.8.9;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity >=0.6.0 <=0.8.9;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity >=0.6.0 <=0.8.9;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}// MIT

pragma solidity >=0.6.0;

interface IAdminControl {

  function hasRole(uint8 _role, address _account) external view returns (bool);


  function SUPER_ADMIN() external view returns (uint8);


  function ADMIN() external view returns (uint8);


  function SERVICE_ADMIN() external view returns (uint8);

}// MIT

pragma solidity >=0.6.0;


abstract contract AdminAccess {

  IAdminControl public adminControl;

  modifier onlyRole(uint8 _role) {
    require(address(adminControl) == address(0) || adminControl.hasRole(_role, msg.sender), "no access");
    _;
  }

  function addAdminControlContract(IAdminControl _contract) external onlyRole(0) {
    adminControl = _contract;
  }

}//Unlicensed
pragma solidity 0.8.9;


contract StrongNFTPackBonusV2 is AdminAccess {


  event Staked(address indexed entity, uint tokenId, uint packType, uint timestamp);
  event Unstaked(address indexed entity, uint tokenId, uint packType, uint timestamp);
  event SetPackTypeNFTBonus(uint packType, string bonusName, uint value);

  IERC1155Preset public CERC1155;
  INodePackV3 public nodePack;

  bool public initDone;

  mapping(bytes4 => bool) private _supportedInterfaces;

  string[] public nftBonusNames;
  mapping(string => uint) public nftBonusLowerBound;
  mapping(string => uint) public nftBonusUpperBound;
  mapping(string => uint) public nftBonusEffectiveAt;
  mapping(string => uint) public nftBonusNodesLimit;
  mapping(uint => mapping(string => uint)) public packTypeNFTBonus;

  mapping(uint => address) public nftIdStakedToEntity;
  mapping(uint => uint) public nftIdStakedToPackType;

  mapping(address => uint[]) public entityStakedNftIds;

  mapping(bytes => uint[]) public entityPackStakedNftIds;
  mapping(bytes => uint) public entityPackStakedAt;
  mapping(bytes => uint) public entityPackBonusSaved;

  function init(address _nftContract) external onlyRole(adminControl.SUPER_ADMIN()) {

    require(initDone == false, "init done");

    _registerInterface(0x01ffc9a7);
    _registerInterface(
      ERC1155Receiver(address(0)).onERC1155Received.selector ^
      ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
    );

    CERC1155 = IERC1155Preset(_nftContract);
    initDone = true;
  }


  function isNftStaked(uint _nftId) public view returns (bool) {

    return nftIdStakedToPackType[_nftId] != 0;
  }

  function getStakedNftIds(address _entity) public view returns (uint[] memory) {

    return entityStakedNftIds[_entity];
  }

  function getPackStakedNftIds(address _entity, uint _packType) public view returns (uint[] memory) {

    bytes memory id = nodePack.getPackId(_entity, _packType);
    return entityPackStakedNftIds[id];
  }

  function getNftBonusNames() public view returns (string[] memory) {

    return nftBonusNames;
  }

  function getNftBonusNodesLimit(uint _nftId) public view returns (uint) {

    return nftBonusNodesLimit[getNftBonusName(_nftId)];
  }

  function getNftBonusName(uint _nftId) public view returns (string memory) {

    for (uint i = 0; i < nftBonusNames.length; i++) {
      if (_nftId >= nftBonusLowerBound[nftBonusNames[i]] && _nftId <= nftBonusUpperBound[nftBonusNames[i]]) {
        return nftBonusNames[i];
      }
    }

    return "";
  }

  function getNftBonusValue(uint _packType, string memory _bonusName) public view returns (uint) {

    return packTypeNFTBonus[_packType][_bonusName] > 0
    ? packTypeNFTBonus[_packType][_bonusName]
    : packTypeNFTBonus[0][_bonusName];
  }

  function getBonus(address _entity, uint _packType, uint _from, uint _to) public view returns (uint) {

    uint[] memory nftIds = getPackStakedNftIds(_entity, _packType);
    if (nftIds.length == 0) return 0;

    bytes memory id = nodePack.getPackId(_entity, _packType);
    if (entityPackStakedAt[id] == 0) return 0;

    uint bonus = entityPackBonusSaved[id];
    string memory bonusName = "";
    uint startFrom = 0;
    uint nftNodeLimitCount = 0;
    uint boostedNodesCount = 0;
    uint entityPackTotalNodeCount = nodePack.getEntityPackActiveNodeCount(_entity, _packType);

    for (uint i = 0; i < nftIds.length; i++) {
      if (boostedNodesCount >= entityPackTotalNodeCount) break;
      bonusName = getNftBonusName(nftIds[i]);
      if (keccak256(abi.encode(bonusName)) == keccak256(abi.encode(""))) return 0;
      if (nftBonusEffectiveAt[bonusName] == 0) continue;
      if (CERC1155.balanceOf(address(this), nftIds[i]) == 0) continue;

      nftNodeLimitCount = getNftBonusNodesLimit(nftIds[i]);
      if (boostedNodesCount + nftNodeLimitCount > entityPackTotalNodeCount) {
        nftNodeLimitCount = entityPackTotalNodeCount - boostedNodesCount;
      }

      boostedNodesCount += nftNodeLimitCount;
      startFrom = entityPackStakedAt[id] > _from ? entityPackStakedAt[id] : _from;
      if (startFrom < nftBonusEffectiveAt[bonusName]) {
        startFrom = nftBonusEffectiveAt[bonusName];
      }

      if (startFrom >= _to) continue;

      bonus += (_to - startFrom) * getNftBonusValue(_packType, bonusName) * nftNodeLimitCount;
    }

    return bonus;
  }


  function stakeNFT(uint _nftId, uint _packType) public payable {

    string memory bonusName = getNftBonusName(_nftId);
    require(keccak256(abi.encode(bonusName)) != keccak256(abi.encode("")), "not eligible");
    require(CERC1155.balanceOf(msg.sender, _nftId) != 0, "not enough");
    require(nftIdStakedToEntity[_nftId] == address(0), "already staked");
    require(nodePack.doesPackExist(msg.sender, _packType), "pack doesnt exist");

    bytes memory id = nodePack.getPackId(msg.sender, _packType);

    entityPackBonusSaved[id] = getBonus(msg.sender, _packType, entityPackStakedAt[id], block.timestamp);

    nftIdStakedToPackType[_nftId] = _packType;
    nftIdStakedToEntity[_nftId] = msg.sender;
    entityPackStakedAt[id] = block.timestamp;
    entityStakedNftIds[msg.sender].push(_nftId);
    entityPackStakedNftIds[id].push(_nftId);

    CERC1155.safeTransferFrom(msg.sender, address(this), _nftId, 1, bytes(""));

    emit Staked(msg.sender, _nftId, _packType, block.timestamp);
  }

  function unStakeNFT(uint _nftId, uint _packType, uint _timestamp) public {

    require(nftIdStakedToEntity[_nftId] != address(0), "not staked");
    require(nftIdStakedToEntity[_nftId] == msg.sender, "not staker");
    require(nftIdStakedToPackType[_nftId] == _packType, "wrong pack");

    nodePack.updatePackState(msg.sender, _packType);

    bytes memory id = nodePack.getPackId(msg.sender, _packType);

    nftIdStakedToPackType[_nftId] = 0;
    nftIdStakedToEntity[_nftId] = address(0);

    for (uint i = 0; i < entityStakedNftIds[msg.sender].length; i++) {
      if (entityStakedNftIds[msg.sender][i] == _nftId) {
        _deleteIndex(entityStakedNftIds[msg.sender], i);
        break;
      }
    }

    for (uint i = 0; i < entityPackStakedNftIds[id].length; i++) {
      if (entityPackStakedNftIds[id][i] == _nftId) {
        _deleteIndex(entityPackStakedNftIds[id], i);
        break;
      }
    }

    CERC1155.safeTransferFrom(address(this), msg.sender, _nftId, 1, bytes(""));

    emit Unstaked(msg.sender, _nftId, _packType, _timestamp);
  }


  function updateBonus(string memory _name, uint _lowerBound, uint _upperBound, uint _effectiveAt, uint _nodesLimit) public onlyRole(adminControl.SERVICE_ADMIN()) {

    bool alreadyExists = false;
    for (uint i = 0; i < nftBonusNames.length; i++) {
      if (keccak256(abi.encode(nftBonusNames[i])) == keccak256(abi.encode(_name))) {
        alreadyExists = true;
      }
    }

    if (!alreadyExists) {
      nftBonusNames.push(_name);
    }

    nftBonusLowerBound[_name] = _lowerBound;
    nftBonusUpperBound[_name] = _upperBound;
    nftBonusEffectiveAt[_name] = _effectiveAt != 0 ? _effectiveAt : block.timestamp;
    nftBonusNodesLimit[_name] = _nodesLimit;
  }

  function setPackTypeNFTBonus(uint _packType, string memory _bonusName, uint _value) external onlyRole(adminControl.SERVICE_ADMIN()) {

    packTypeNFTBonus[_packType][_bonusName] = _value;
    emit SetPackTypeNFTBonus(_packType, _bonusName, _value);
  }

  function updateNftContract(address _nftContract) external onlyRole(adminControl.SUPER_ADMIN()) {

    CERC1155 = IERC1155Preset(_nftContract);
  }

  function updateNodePackContract(address _contract) external onlyRole(adminControl.SUPER_ADMIN()) {

    nodePack = INodePackV3(_contract);
  }

  function updateEntityPackStakedAt(address _entity, uint _packType, uint _timestamp) public onlyRole(adminControl.SERVICE_ADMIN()) {

    bytes memory id = nodePack.getPackId(_entity, _packType);
    entityPackStakedAt[id] = _timestamp;
  }

  function setEntityPackBonusSaved(address _entity, uint _packType) external {

    require(msg.sender == address(nodePack), "not allowed");

    bytes memory id = nodePack.getPackId(_entity, _packType);
    entityPackBonusSaved[id] = getBonus(_entity, _packType, entityPackStakedAt[id], block.timestamp);
    entityPackStakedAt[id] = block.timestamp;
  }

  function resetEntityPackBonusSaved(bytes memory _packId) external {

    require(msg.sender == address(nodePack), "not allowed");

    entityPackBonusSaved[_packId] = 0;
  }


  function onERC1155Received(address, address, uint, uint, bytes memory) public virtual returns (bytes4) {

    return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(address, address, uint[] memory, uint[] memory, bytes memory) public virtual returns (bytes4) {

    return this.onERC1155BatchReceived.selector;
  }

  function supportsInterface(bytes4 interfaceId) public view returns (bool) {

    return _supportedInterfaces[interfaceId];
  }

  function _registerInterface(bytes4 interfaceId) internal virtual {

    require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
    _supportedInterfaces[interfaceId] = true;
  }

  function _deleteIndex(uint[] storage array, uint index) internal {

    uint lastIndex = array.length - 1;
    uint lastEntry = array[lastIndex];
    if (index == lastIndex) {
      array.pop();
    } else {
      array[index] = lastEntry;
      array.pop();
    }
  }
}