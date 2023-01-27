
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


interface ICrewGenerator {


  function setSeed(bytes32 _seed) external;


  function getFeatures(uint _crewId, uint _mod) external view returns (uint);

}// UNLICENSED
pragma solidity 0.7.6;



contract CrewFeatures is Ownable {


  mapping (uint => ICrewGenerator) private _generators;

  mapping (uint => uint) private _crewCollection;

  mapping (uint => uint) private _crewModifiers;

  mapping (address => bool) private _managers;

  event CollectionCreated(uint indexed id);
  event CollectionSeeded(uint indexed id);

  modifier onlyManagers {

    require(isManager(_msgSender()), "CrewFeatures: Only managers can call this function");
    _;
  }

  function setGenerator(uint _collId, ICrewGenerator _generator) external onlyOwner {

    _generators[_collId] = _generator;
    emit CollectionCreated(_collId);
  }

  function setGeneratorSeed(uint _collId, bytes32 _seed) external onlyManagers {

    require(address(_generators[_collId]) != address(0), "CrewFeatures: collection must be defined");
    ICrewGenerator generator = _generators[_collId];
    generator.setSeed(_seed);
    emit CollectionSeeded(_collId);
  }

  function setToken(uint _crewId, uint _collId, uint _mod) external onlyManagers {

    require(address(_generators[_collId]) != address(0), "CrewFeatures: collection must be defined");
    _crewCollection[_crewId] = _collId;

    if (_mod > 0) {
      _crewModifiers[_crewId] = _mod;
    }
  }

  function getFeatures(uint _crewId) public view returns (uint) {

    uint generatorId = _crewCollection[_crewId];
    ICrewGenerator generator = _generators[generatorId];
    uint features = generator.getFeatures(_crewId, _crewModifiers[_crewId]);
    features |= generatorId << 0;
    return features;
  }

  function addManager(address _manager) external onlyOwner {

    _managers[_manager] = true;
  }

  function removeManager(address _manager) external onlyOwner {

    _managers[_manager] = false;
  }

  function isManager(address _manager) public view returns (bool) {

    return _managers[_manager];
  }
}