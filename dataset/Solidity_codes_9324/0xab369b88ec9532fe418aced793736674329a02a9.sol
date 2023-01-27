

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}


library Roles {

  struct Role {
    mapping (address => bool) bearer;
  }

  function add(Role storage _role, address _addr)
    internal
  {

    _role.bearer[_addr] = true;
  }

  function remove(Role storage _role, address _addr)
    internal
  {

    _role.bearer[_addr] = false;
  }

  function check(Role storage _role, address _addr)
    internal
    view
  {

    require(has(_role, _addr));
  }

  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {

    return _role.bearer[_addr];
  }
}


contract RBAC {

  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  function checkRole(address _operator, string memory _role)
    public
    view
  {

    roles[_role].check(_operator);
  }

  function hasRole(address _operator, string memory _role)
    public
    view
    returns (bool)
  {

    return roles[_role].has(_operator);
  }

  function addRole(address _operator, string memory _role)
    internal
  {

    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  function removeRole(address _operator, string memory _role)
    internal
  {

    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  modifier onlyRole(string memory _role)
  {

    checkRole(msg.sender, _role);
    _;
  }



}




contract Whitelist is Ownable, RBAC {

  string public constant ROLE_WHITELISTED = "whitelist";


  modifier onlyIfWhitelisted(address _operator) {

    checkRole(_operator, ROLE_WHITELISTED);
    _;
  }


  function addAddressToWhitelist(address _operator)
    public
    onlyOwner
  {

    addRole(_operator, ROLE_WHITELISTED);
  }

  function whitelist(address _operator)
    public
    view
    returns (bool)
  {

    return hasRole(_operator, ROLE_WHITELISTED);
  }

  function addAddressesToWhitelist(address[] memory _operators)
    public
    onlyOwner
  {

    for (uint256 i = 0; i < _operators.length; i++) {
      addAddressToWhitelist(_operators[i]);
    }
  }

  function removeAddressFromWhitelist(address _operator)
    public
    onlyOwner
  {

    removeRole(_operator, ROLE_WHITELISTED);
  }

  function removeAddressesFromWhitelist(address[] memory _operators)
    public
    onlyOwner
  {

    for (uint256 i = 0; i < _operators.length; i++) {
      removeAddressFromWhitelist(_operators[i]);
    }
  }

}


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface ICAAsset {


  function ownerOf(uint256 _tokenId) external view returns (address _owner);

  function exists(uint256 _tokenId) external view returns (bool _exists);

  
  function transferFrom(address _from, address _to, uint256 _tokenId) external;

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

  function safeTransferFrom(address _from , address _to, uint256 _tokenId, bytes memory _data) external;


  function editionOfTokenId(uint256 _tokenId) external view returns (uint256 tokenId);


  function artistCommission(uint256 _tokenId) external view returns (address _artistAccount, uint256 _artistCommission);


  function editionOptionalCommission(uint256 _tokenId) external view returns (uint256 _rate, address _recipient);


  function mint(address _to, uint256 _editionNumber) external returns (uint256);


  function approve(address _to, uint256 _tokenId) external;




  function createActiveEdition(
    uint256 _editionNumber,
    bytes32 _editionData,
    uint256 _editionType,
    uint256 _startDate,
    uint256 _endDate,
    address _artistAccount,
    uint256 _artistCommission,
    uint256 _priceInWei,
    string memory _tokenUri,
    uint256 _totalAvailable
  ) external returns (bool);


  function artistsEditions(address _artistsAccount) external returns (uint256[] memory _editionNumbers);


  function totalAvailableEdition(uint256 _editionNumber) external returns (uint256);


  function highestEditionNumber() external returns (uint256);


  function updateOptionalCommission(uint256 _editionNumber, uint256 _rate, address _recipient) external;


  function updateStartDate(uint256 _editionNumber, uint256 _startDate) external;


  function updateEndDate(uint256 _editionNumber, uint256 _endDate) external;


  function updateEditionType(uint256 _editionNumber, uint256 _editionType) external;

}



interface ICA24Auction {

  function createReserveAuction(
    uint256 tokenId,
    address seller,
    uint256 reservePrice
  ) external;

}


interface ISelfServiceAccessControls {


  function isEnabledForAccount(address account) external view returns (bool);


}


interface ISelfServiceFrequencyControls {


  function canCreateNewEdition(address artist) external view returns (bool);


  function recordSuccessfulMint(address artist, uint256 totalAvailable, uint256 priceInWei) external returns (bool);

}




contract EditionCurationMinter is Whitelist, Pausable {


  ICAAsset public caAsset;
  ICA24Auction public auction;
  ISelfServiceAccessControls public accessControls;
  ISelfServiceFrequencyControls public frequencyControls;

  uint256 public maxEditionSize = 100;

  uint256 public minPricePerEdition = 0; // 0.01 ether;

  constructor(
    ICAAsset _caAsset,
    ICA24Auction _auction,
    ISelfServiceAccessControls _accessControls,
    ISelfServiceFrequencyControls _frequencyControls
  ) {
    super.addAddressToWhitelist(msg.sender);

    caAsset = _caAsset;
    auction = _auction;
    accessControls = _accessControls;
    frequencyControls = _frequencyControls;
  }

  function createEditionFor24Auction(
    address _optionalSplitAddress,
    uint256 _optionalSplitRate,
    uint256 _totalAvailable,
    uint256 _priceInWei,
    uint256 _startDate,
    uint256 _endDate,
    uint256 _artistCommission,
    uint256 _editionType,
    string memory _tokenUri
  )
  public
  whenNotPaused
  returns (uint256 _editionNumber, uint _tokenId)
  {

    address artists = msg.sender;

    require(frequencyControls.canCreateNewEdition(artists), "Sender currently frozen out of creation");
    require((_artistCommission + _optionalSplitRate) <= 100, "Total commission exceeds 100");

    _editionNumber = _createEdition(
      artists,
      [_totalAvailable, _priceInWei, _startDate, _endDate, _artistCommission, _editionType],
      _tokenUri
    );

    if (_optionalSplitRate > 0 && _optionalSplitAddress != address(0)) {
      caAsset.updateOptionalCommission(_editionNumber, _optionalSplitRate, _optionalSplitAddress);
    }

    frequencyControls.recordSuccessfulMint(artists, _totalAvailable, _priceInWei);


    _tokenId = caAsset.mint(address(this), _editionNumber);

    caAsset.approve(address(auction), _tokenId);

    auction.createReserveAuction(_tokenId, artists, _priceInWei);

  }

  function _createEdition(
    address _artist,
    uint256[6] memory _params,
    string memory _tokenUri
  )
  internal
  returns (uint256 _editionNumber) {


    uint256 _totalAvailable = _params[0];
    uint256 _priceInWei = _params[1];

    address owner = owner();

    require(msg.sender == owner || (_totalAvailable > 0 && _totalAvailable <= maxEditionSize), "Invalid edition size");

    require(msg.sender == owner || _priceInWei >= minPricePerEdition, "Invalid price");

    require(msg.sender == owner || accessControls.isEnabledForAccount(_artist), "Not allowed to create edition");

    uint256 editionNumber = getNextAvailableEditionNumber();

    require(
      caAsset.createActiveEdition(
        editionNumber,
        0x0, // _editionData - no edition data
        _params[5], //_editionType,
        _params[2], // _startDate,
        _params[3], //_endDate,
        _artist,
        _params[4], // _artistCommission - defaults to artistCommission if optional commission split missing
        _priceInWei,
        _tokenUri,
        _totalAvailable
      ),
      "Failed to create new edition"
    );


    return editionNumber;
  }

  function getNextAvailableEditionNumber() internal returns (uint256 editionNumber) {


    uint256 highestEditionNumber = caAsset.highestEditionNumber();
    uint256 totalAvailableEdition = caAsset.totalAvailableEdition(highestEditionNumber);

    uint256 nextAvailableEditionNumber = highestEditionNumber + totalAvailableEdition + 1;

    return ((nextAvailableEditionNumber + maxEditionSize - 1) / maxEditionSize) * maxEditionSize;
  }

  function setCAAsset(ICAAsset _caAsset) onlyIfWhitelisted(msg.sender) public {

    caAsset = _caAsset;
  }

  function setAuction(ICA24Auction _auction) onlyIfWhitelisted(msg.sender) public {

    auction = _auction;
  }

  function setMaxEditionSize(uint256 _maxEditionSize) onlyIfWhitelisted(msg.sender) public {

    maxEditionSize = _maxEditionSize;
  }

  function setMinPricePerEdition(uint256 _minPricePerEdition) onlyIfWhitelisted(msg.sender) public {

    minPricePerEdition = _minPricePerEdition;
  }

  function isFrozen(address account) public view returns (bool) {

    return frequencyControls.canCreateNewEdition(account);
  }

  function isEnabledForAccount(address account) public view returns (bool) {

    return accessControls.isEnabledForAccount(account);
  }

  function canCreateAnotherEdition(address account) public view returns (bool) {

    if (!accessControls.isEnabledForAccount(account)) {
      return false;
    }
    return frequencyControls.canCreateNewEdition(account);
  }

  function withdrawStuckEther(address _withdrawalAccount) onlyIfWhitelisted(msg.sender) public {

    require(_withdrawalAccount != address(0), "Invalid address provided");
    payable(_withdrawalAccount).transfer(address(this).balance);
  }
}