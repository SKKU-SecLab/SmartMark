
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT
pragma solidity ^0.8.9;

interface IZDAORegistry {

  struct ZDAORecord {
    uint256 id;
    string ensSpace;
    address gnosisSafe;
    uint256[] associatedzNAs;
    bool destroyed;
  }


  function numberOfzDAOs() external view returns (uint256);


  function getzDAOById(uint256 daoId) external view returns (ZDAORecord memory);


  function getzDAOByEns(string calldata ensSpace) external view returns (ZDAORecord memory);


  function listzDAOs(uint256 startIndex, uint256 endIndex)
    external
    view
    returns (ZDAORecord[] memory);


  function doeszDAOExistForzNA(uint256 zNA) external view returns (bool);


  function getzDaoByZNA(uint256 zNA) external view returns (ZDAORecord memory);


  event DAOCreated(uint256 indexed daoId, string ensSpace, address gnosisSafe);
  event DAOModified(uint256 indexed daoId, string endSpace, address gnosisSafe);
  event DAODestroyed(uint256 indexed daoId);
  event LinkAdded(uint256 indexed daoId, uint256 indexed zNA);
  event LinkRemoved(uint256 indexed daoId, uint256 indexed zNA);
}// MIT
pragma solidity ^0.8.9;


interface IZNSHub {

  function ownerOf(uint256 domainId) external view returns (address);

}// MIT
pragma solidity ^0.8.9;


contract ZDAORegistry is IZDAORegistry, OwnableUpgradeable {

  IZNSHub public znsHub;

  mapping(uint256 => uint256) private ensTozDAO;
  mapping(uint256 => uint256) private zNATozDAOId;

  mapping(uint256 => ZDAORecord) public zDAORecords;

  uint256 private numZDAOs;

  modifier onlyZNAOwner(uint256 zNA) {

    require(znsHub.ownerOf(zNA) == msg.sender, "Not zNA owner");
    _;
  }

  modifier onlyValidZDAO(uint256 daoId) {

    require(daoId > 0 && daoId < numZDAOs && !zDAORecords[daoId].destroyed, "Invalid zDAO");
    _;
  }

  function initialize(address _znsHub) external initializer {

    __Ownable_init();

    znsHub = IZNSHub(_znsHub);
    zDAORecords[0] = ZDAORecord({
      id: 0,
      ensSpace: "",
      gnosisSafe: address(0),
      associatedzNAs: new uint256[](0),
      destroyed: false
    });

    numZDAOs = 1;
  }

  function addNewDAO(string calldata ensSpace, address gnosisSafe) external onlyOwner {

    uint256 ensId = _ensId(ensSpace);
    require(ensTozDAO[ensId] == 0, "ENS already has zDAO");

    zDAORecords[numZDAOs] = ZDAORecord({
      id: numZDAOs,
      ensSpace: ensSpace,
      gnosisSafe: gnosisSafe,
      associatedzNAs: new uint256[](0),
      destroyed: false
    });

    ensTozDAO[ensId] = numZDAOs;

    emit DAOCreated(numZDAOs, ensSpace, gnosisSafe);

    numZDAOs += 1;
  }

  function addZNAAssociation(uint256 daoId, uint256 zNA)
    external
    onlyValidZDAO(daoId)
    onlyZNAOwner(zNA)
  {

    _associatezNA(daoId, zNA);
  }

  function removeZNAAssociation(uint256 daoId, uint256 zNA)
    external
    onlyValidZDAO(daoId)
    onlyZNAOwner(zNA)
  {

    uint256 currentDAOAssociation = zNATozDAOId[zNA];
    require(currentDAOAssociation == daoId, "zNA not associated");

    _disassociatezNA(daoId, zNA);
  }


  function adminSetZNSHub(address _znsHub) external onlyOwner {

    znsHub = IZNSHub(_znsHub);
  }

  function adminRemoveDAO(uint256 daoId) external onlyValidZDAO(daoId) onlyOwner {

    zDAORecords[daoId].destroyed = true;
    ensTozDAO[_ensId(zDAORecords[daoId].ensSpace)] = 0;

    emit DAODestroyed(daoId);
  }

  function adminAssociateZNA(uint256 daoId, uint256 zNA) external onlyOwner onlyValidZDAO(daoId) {

    _associatezNA(daoId, zNA);
  }

  function adminDisassociateZNA(uint256 daoId, uint256 zNA)
    external
    onlyOwner
    onlyValidZDAO(daoId)
  {

    uint256 currentDAOAssociation = zNATozDAOId[zNA];
    require(currentDAOAssociation == daoId, "zNA not associated");

    _disassociatezNA(daoId, zNA);
  }

  function adminModifyZDAO(
    uint256 daoId,
    string calldata ensSpace,
    address gnosisSafe
  ) external onlyOwner onlyValidZDAO(daoId) {

    ZDAORecord storage zDAO = zDAORecords[daoId];

    uint256 newEnsId = _ensId(ensSpace);
    uint256 existingEnsId = _ensId(zDAO.ensSpace);

    if (newEnsId != existingEnsId) {
      ensTozDAO[existingEnsId] = 0;
      ensTozDAO[newEnsId] = daoId;
    }

    zDAO.ensSpace = ensSpace;
    zDAO.gnosisSafe = gnosisSafe;

    emit DAOModified(daoId, ensSpace, gnosisSafe);
  }


  function numberOfzDAOs() external view returns (uint256) {

    return numZDAOs - 1;
  }

  function getzDAOById(uint256 daoId) external view returns (ZDAORecord memory) {

    return zDAORecords[daoId];
  }

  function listzDAOs(uint256 startIndex, uint256 endIndex)
    external
    view
    returns (ZDAORecord[] memory)
  {

    uint256 numDaos = numZDAOs;
    require(startIndex != 0, "start index = 0, use 1");
    require(startIndex <= endIndex, "start index > end");
    require(startIndex < numDaos, "start index > length");
    require(endIndex < numDaos, "end index > length");

    if (numDaos == 1) {
      return new ZDAORecord[](0);
    }

    uint256 numRecords = endIndex - startIndex + 1;
    ZDAORecord[] memory records = new ZDAORecord[](numRecords);

    for (uint256 i = 0; i < numRecords; ++i) {
      records[i] = zDAORecords[startIndex + i];
    }

    return records;
  }

  function getzDaoByZNA(uint256 zNA) external view returns (ZDAORecord memory) {

    uint256 daoId = zNATozDAOId[zNA];
    require(
      daoId != 0 && daoId < numZDAOs && !zDAORecords[daoId].destroyed,
      "No zDAO associated with zNA"
    );
    return zDAORecords[daoId];
  }

  function getzDAOByEns(string calldata ensSpace) external view returns (ZDAORecord memory) {

    uint256 ensHash = _ensId(ensSpace);
    uint256 daoId = ensTozDAO[ensHash];
    require(daoId != 0, "No zDAO at ens space");
    require(!zDAORecords[daoId].destroyed, "zDAO destroyed");

    return zDAORecords[daoId];
  }

  function doeszDAOExistForzNA(uint256 zNA) external view returns (bool) {

    return zNATozDAOId[zNA] != 0;
  }


  function _associatezNA(uint256 daoId, uint256 zNA) internal {

    uint256 currentDAOAssociation = zNATozDAOId[zNA];
    require(currentDAOAssociation != daoId, "zNA already linked to DAO");

    if (currentDAOAssociation != 0) {
      _disassociatezNA(currentDAOAssociation, zNA);
    }

    zNATozDAOId[zNA] = daoId;
    zDAORecords[daoId].associatedzNAs.push(zNA);

    emit LinkAdded(daoId, zNA);
  }

  function _disassociatezNA(uint256 daoId, uint256 zNA) internal {

    ZDAORecord storage dao = zDAORecords[daoId];
    uint256 length = zDAORecords[daoId].associatedzNAs.length;

    for (uint256 i = 0; i < length; i++) {
      if (dao.associatedzNAs[i] == zNA) {
        dao.associatedzNAs[i] = dao.associatedzNAs[length - 1];
        dao.associatedzNAs.pop();
        zNATozDAOId[zNA] = 0;

        emit LinkRemoved(daoId, zNA);
        break;
      }
    }
  }

  function _ensId(string memory ensSpace) private pure returns (uint256) {

    uint256 ensHash = uint256(keccak256(abi.encodePacked(ensSpace)));
    return ensHash;
  }
}