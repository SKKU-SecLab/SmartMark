
pragma solidity 0.5.2;


interface KongERC20Interface {


  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function mint(uint256 mintedAmount, address recipient) external;

  function getMintingLimit() external returns(uint256);


}

interface EllipticCurveInterface {


    function validateSignature(bytes32 message, uint[2] calldata rs, uint[2] calldata Q) external view returns (bool);


}


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


contract RegisterDirectMint {

  using SafeMath for uint256;

  address public _owner;

  address public _kongERC20Address;

  uint256 public _totalMintable;

  mapping (address => bool) public _minters;

  mapping (address => uint256) public _mintingCaps;

  struct Device {
    uint256 kongAmount;
    uint256 mintableTime;
    bool mintable;
  }

  mapping(bytes32 => Device) internal _devices;

  event Registration(
    bytes32 hardwareHash,
    bytes32 primaryPublicKeyHash,
    bytes32 secondaryPublicKeyHash,
    bytes32 tertiaryPublicKeyHash,
    bytes32 hardwareManufacturer,
    bytes32 hardwareModel,
    bytes32 hardwareSerial,
    bytes32 hardwareConfig,
    uint256 kongAmount,
    uint256 mintableTime,
    bool mintable
  );

  event MinterAddition (
    address minter,
    uint256 mintingCap
  );

  event MinterRemoval (
    address minter
  );

  constructor(address owner, address kongAddress) public {

    _owner = owner;

    _kongERC20Address = kongAddress;

    _mintingCaps[_owner] = (2 ** 25 + 2 ** 24 + 2 ** 23 + 2 ** 22) * 10 ** 18;

  }

  modifier onlyOwner() {

    require(_owner == msg.sender, 'Can only be called by owner.');
    _;
  }

  modifier onlyOwnerOrMinter() {

    require(_owner == msg.sender || _minters[msg.sender] == true, 'Can only be called by owner or minter.');
    _;
  }

  function delegateMintingRights(
    address newMinter,
    uint256 mintingCap
  )
    public
    onlyOwner
  {

    _mintingCaps[_owner] = _mintingCaps[_owner].sub(mintingCap);
    _mintingCaps[newMinter] = _mintingCaps[newMinter].add(mintingCap);

    _minters[newMinter] = true;

    emit MinterAddition(newMinter, _mintingCaps[newMinter]);
  }

  function removeMintingRights(
    address minter
  )
    public
    onlyOwner
  {

    require(_owner != minter, 'Cannot remove owner from minters.');

    _mintingCaps[_owner] = _mintingCaps[_owner].add(_mintingCaps[minter]);
    _mintingCaps[minter] = 0;

    _minters[minter] = false;

    emit MinterRemoval(minter);
  }

  function registerDevice(
    bytes32 hardwareHash,
    bytes32 primaryPublicKeyHash,
    bytes32 secondaryPublicKeyHash,
    bytes32 tertiaryPublicKeyHash,
    bytes32 hardwareManufacturer,
    bytes32 hardwareModel,
    bytes32 hardwareSerial,
    bytes32 hardwareConfig,
    uint256 kongAmount,
    uint256 mintableTime,
    bool mintable
  )
    public
    onlyOwnerOrMinter
  {

    require(_devices[hardwareHash].kongAmount == 0, 'Already registered.');

    if (mintable) {

      uint256 _maxMinted = KongERC20Interface(_kongERC20Address).getMintingLimit();
      require(_totalMintable.add(kongAmount) <= _maxMinted, 'Exceeds cumulative limit.');

      _totalMintable += kongAmount;

      _mintingCaps[msg.sender] = _mintingCaps[msg.sender].sub(kongAmount);
    }

    _devices[hardwareHash] = Device(
      kongAmount,
      mintableTime,
      mintable
    );

    emit Registration(
      hardwareHash,
      primaryPublicKeyHash,
      secondaryPublicKeyHash,
      tertiaryPublicKeyHash,
      hardwareManufacturer,
      hardwareModel,
      hardwareSerial,
      hardwareConfig,
      kongAmount,
      mintableTime,
      mintable
    );
  }

  function mintKong(
    bytes32 hardwareHash,
    address recipient
  )
    external
    onlyOwnerOrMinter
  {

    Device memory d = _devices[hardwareHash];

    require(d.mintable, 'Not mintable / already minted.');
    require(block.timestamp >= d.mintableTime, 'Cannot mint yet.');

    _devices[hardwareHash].mintable = false;

    KongERC20Interface(_kongERC20Address).mint(d.kongAmount, recipient);
  }

  function getRegistrationDetails(
    bytes32 hardwareHash
  )
    external
    view
    returns (uint256, uint256, bool)
  {

    Device memory d = _devices[hardwareHash];

    return (
      d.kongAmount,
      d.mintableTime,
      d.mintable
    );
  }

  function verifyMintableHardwareHash(
    bytes32 primaryPublicKeyHash,
    bytes32 secondaryPublicKeyHash,
    bytes32 tertiaryPublicKeyHash,
    bytes32 hardwareSerial
  )
    external
    view
    returns (bytes32)
  {

    bytes32 hashedKey = sha256(abi.encodePacked(primaryPublicKeyHash, secondaryPublicKeyHash, tertiaryPublicKeyHash, hardwareSerial));

    Device memory d = _devices[hashedKey];

    require(d.mintable == true, 'Not mintable.');
    require(d.kongAmount > 0, 'No KONG amount to be minted.');

    return hashedKey;
  }

  function getKongAmount(
    bytes32 hardwareHash
  )
    external
    view
    returns (uint)
  {

    Device memory d = _devices[hardwareHash];

    return d.kongAmount;
  }

}