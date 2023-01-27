pragma solidity 0.7.6;


interface IAsteroidFeatures {


  function getAsteroidSeed(uint _asteroidId) external pure returns (bytes32);


  function getRadius(uint _asteroidId) external pure returns (uint);


  function getSpectralType(uint _asteroidId) external pure returns (uint);


  function getSpectralTypeBySeed(bytes32 _seed) external pure returns (uint);


  function getOrbitalElements(uint _asteroidId) external pure returns (uint[6] memory orbitalElements);


  function getOrbitalElementsBySeed(bytes32 _seed) external pure returns (uint[6] memory orbitalElements);

}// UNLICENSED
pragma solidity 0.7.6;


interface IAsteroidScans {


  function scanOrderCount() external returns (uint);


  function recordScanOrder(uint _asteroidId) external;


  function getScanOrder(uint _asteroidId) external view returns(uint);


  function setInitialBonuses(uint[] calldata _asteroidIds, uint[] calldata _bonuses) external;


  function finalizeScan(uint _asteroidId) external;


  function retrieveScan(uint _asteroidId) external view returns (uint);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


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

}// UNLICENSED
pragma solidity 0.7.6;



interface IAsteroidToken is IERC721 {


  function mint(address _to, uint _tokenId) external;


  function burn(address _owner, uint _tokenId) external;


  function ownerOf(uint tokenId) external override view returns (address);

}// UNLICENSED
pragma solidity 0.7.6;


interface ICrewFeatures {


  function setGeneratorSeed(uint _collId, bytes32 _seed) external;


  function setToken(uint _crewId, uint _collId, uint _mod) external;

}// UNLICENSED
pragma solidity 0.7.6;



interface ICrewToken is IERC721 {


  function mint(address _to) external returns (uint);


  function ownerOf(uint256 tokenId) external override view returns (address);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// UNLICENSED
pragma solidity 0.7.6;



contract ArvadCrewSale is Ownable {

  IAsteroidToken asteroids;
  IAsteroidFeatures astFeatures;
  IAsteroidScans scans;
  ICrewToken crew;
  ICrewFeatures crewFeatures;

  mapping (uint => bool) private _asteroidsUsed;

  uint public saleStartTime; // in seconds since epoch
  uint public baseAsteroidPrice;
  uint public baseLotPrice;
  uint public startScanCount; // count of total purchases when the sale starts
  uint public endScanCount; // count of total purchases after which to stop the sale

  event SaleCreated(uint indexed start, uint asteroidPrice, uint lotPrice, uint startCount, uint endCount);
  event SaleCancelled(uint indexed start);
  event AsteroidUsed(uint indexed asteroidId, uint indexed crewId);

  constructor(
    IAsteroidToken _asteroids,
    IAsteroidFeatures _astFeatures,
    IAsteroidScans _scans,
    ICrewToken _crew,
    ICrewFeatures _crewFeatures
  ) {
    asteroids = _asteroids;
    astFeatures = _astFeatures;
    scans = _scans;
    crew = _crew;
    crewFeatures = _crewFeatures;
  }

  function createSale(
    uint _startTime,
    uint _perAsteroid,
    uint _perLot,
    uint _startScanCount,
    uint _endScanCount
  ) external onlyOwner {

    saleStartTime = _startTime;
    baseAsteroidPrice = _perAsteroid;
    baseLotPrice = _perLot;
    startScanCount = _startScanCount;
    endScanCount = _endScanCount;
    emit SaleCreated(saleStartTime, baseAsteroidPrice, baseLotPrice, startScanCount, endScanCount);
  }

  function cancelSale() external onlyOwner {

    require(saleStartTime > 0, "ArvadCrewSale: no sale defined");
    _cancelSale();
  }

  function getAsteroidPrice(uint _tokenId) public view returns (uint) {

    require(baseAsteroidPrice > 0 && baseLotPrice > 0, "ArvadCrewSale: base prices must be set");
    uint radius = astFeatures.getRadius(_tokenId);
    uint lots = (radius * radius) / 250000;
    return baseAsteroidPrice + (baseLotPrice * lots);
  }

  function buyAsteroid(uint _asteroidId) external payable {

    require(block.timestamp >= saleStartTime, "ArvadCrewSale: no active sale");
    require(msg.value == getAsteroidPrice(_asteroidId), "ArvadCrewSale: incorrect amount of Ether sent");
    uint scanCount = scans.scanOrderCount();
    require(scanCount < endScanCount, "ArvadCrewSale: sale has completed");

    asteroids.mint(_msgSender(), _asteroidId);
    scans.recordScanOrder(_asteroidId);

    if (scanCount == (endScanCount - 1)) {
      _cancelSale();
      unlockCitizens();
    }
  }

  function mintCrewWithAsteroid(uint _asteroidId) external {

    require(asteroids.ownerOf(_asteroidId) == _msgSender(), "ArvadCrewSale: caller must own the asteroid");
    require(!_asteroidsUsed[_asteroidId], "ArvadCrewSale: asteroid has already been used to mint crew");
    uint scanOrder = scans.getScanOrder(_asteroidId);
    require(scanOrder > 0 && scanOrder <= endScanCount, "ArvadCrewSale: crew not mintable with this asteroid");
    uint scanCount = scans.scanOrderCount();
    require(scanOrder <= startScanCount || scanCount >= endScanCount, "ArvadCrewSale: Scanning citizens not unlocked");

    uint crewId = crew.mint(_msgSender());

    if (scanOrder <= startScanCount) {
      crewFeatures.setToken(crewId, 1, (250000 - _asteroidId) * (250000 - _asteroidId) / 25000000);
    } else {
      crewFeatures.setToken(crewId, 2, (250000 - _asteroidId) * (250000 - _asteroidId) / 25000000);
    }

    _asteroidsUsed[_asteroidId] = true;
    emit AsteroidUsed(_asteroidId, crewId);
  }

  function withdraw() external onlyOwner {

    uint balance = address(this).balance;
    _msgSender().transfer(balance);
  }

  function unlockCitizens() internal {

    require(scans.scanOrderCount() >= endScanCount, "ArvadCrewSale: all asteroids must be sold first");
    bytes32 seed = blockhash(block.number - 1);
    crewFeatures.setGeneratorSeed(2, seed);
  }

  function emergencyUnlockCitizens() external onlyOwner {

    bytes32 seed = blockhash(block.number - 1);
    crewFeatures.setGeneratorSeed(2, seed);
  }

  function _cancelSale() private {

    emit SaleCancelled(saleStartTime);
    saleStartTime = 0;
    baseAsteroidPrice = 0;
    baseLotPrice = 0;
  }
}