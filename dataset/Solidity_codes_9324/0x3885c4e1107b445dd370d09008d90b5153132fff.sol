



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}


pragma solidity 0.6.12;

interface IPoolRestrictions {

  function getMaxTotalSupply(address _pool) external view returns (uint256);


  function isVotingSignatureAllowed(address _votingAddress, bytes4 _signature) external view returns (bool);


  function isVotingSenderAllowed(address _votingAddress, address _sender) external view returns (bool);


  function isWithoutFee(address _addr) external view returns (bool);

}


pragma solidity 0.6.12;



contract PoolRestrictions is IPoolRestrictions, Ownable {

  event SetTotalRestrictions(address indexed token, uint256 maxTotalSupply);
  event SetSignatureAllowed(bytes4 indexed signature, bool allowed);
  event SetSignatureAllowedForAddress(
    address indexed voting,
    bytes4 indexed signature,
    bool allowed,
    bool overrideAllowed
  );
  event SetVotingSenderAllowed(address indexed voting, address indexed sender, bool allowed);
  event SetWithoutFee(address indexed addr, bool withoutFee);

  struct TotalRestrictions {
    uint256 maxTotalSupply;
  }
  mapping(address => TotalRestrictions) public totalRestrictions;

  mapping(bytes4 => bool) public signaturesAllowed;

  struct VotingSignature {
    bool allowed;
    bool overrideAllowed;
  }
  mapping(address => mapping(bytes4 => VotingSignature)) public votingSignatures;
  mapping(address => mapping(address => bool)) public votingSenderAllowed;

  mapping(address => bool) public withoutFeeAddresses;

  constructor() public Ownable() {}

  function setTotalRestrictions(address[] calldata _poolsList, uint256[] calldata _maxTotalSupplyList)
    external
    onlyOwner
  {

    _setTotalRestrictions(_poolsList, _maxTotalSupplyList);
  }

  function setVotingSignatures(bytes4[] calldata _signatures, bool[] calldata _allowed) external onlyOwner {

    _setVotingSignatures(_signatures, _allowed);
  }

  function setVotingSignaturesForAddress(
    address _votingAddress,
    bool _override,
    bytes4[] calldata _signatures,
    bool[] calldata _allowed
  ) external onlyOwner {

    _setVotingSignaturesForAddress(_votingAddress, _override, _signatures, _allowed);
  }

  function setVotingAllowedForSenders(
    address _votingAddress,
    address[] calldata _senders,
    bool[] calldata _allowed
  ) external onlyOwner {

    uint256 len = _senders.length;
    _validateArrayLength(len);
    require(len == _allowed.length, "Arrays lengths are not equals");
    for (uint256 i = 0; i < len; i++) {
      votingSenderAllowed[_votingAddress][_senders[i]] = _allowed[i];
      emit SetVotingSenderAllowed(_votingAddress, _senders[i], _allowed[i]);
    }
  }

  function setWithoutFee(address[] calldata _addresses, bool _withoutFee) external onlyOwner {

    uint256 len = _addresses.length;
    _validateArrayLength(len);
    for (uint256 i = 0; i < len; i++) {
      withoutFeeAddresses[_addresses[i]] = _withoutFee;
      emit SetWithoutFee(_addresses[i], _withoutFee);
    }
  }

  function getMaxTotalSupply(address _poolAddress) external view override returns (uint256) {

    return totalRestrictions[_poolAddress].maxTotalSupply;
  }

  function isVotingSignatureAllowed(address _votingAddress, bytes4 _signature) external view override returns (bool) {

    if (votingSignatures[_votingAddress][_signature].overrideAllowed) {
      return votingSignatures[_votingAddress][_signature].allowed;
    } else {
      return signaturesAllowed[_signature];
    }
  }

  function isVotingSenderAllowed(address _votingAddress, address _sender) external view override returns (bool) {

    return votingSenderAllowed[_votingAddress][_sender];
  }

  function isWithoutFee(address _address) external view override returns (bool) {

    return withoutFeeAddresses[_address];
  }


  function _setTotalRestrictions(address[] memory _poolsList, uint256[] memory _maxTotalSupplyList) internal {

    uint256 len = _poolsList.length;
    _validateArrayLength(len);
    require(len == _maxTotalSupplyList.length, "Arrays lengths are not equals");

    for (uint256 i = 0; i < len; i++) {
      totalRestrictions[_poolsList[i]] = TotalRestrictions(_maxTotalSupplyList[i]);
      emit SetTotalRestrictions(_poolsList[i], _maxTotalSupplyList[i]);
    }
  }

  function _setVotingSignatures(bytes4[] memory _signatures, bool[] memory _allowed) internal {

    uint256 len = _signatures.length;
    _validateArrayLength(len);
    require(len == _allowed.length, "Arrays lengths are not equals");

    for (uint256 i = 0; i < len; i++) {
      signaturesAllowed[_signatures[i]] = _allowed[i];
      emit SetSignatureAllowed(_signatures[i], _allowed[i]);
    }
  }

  function _setVotingSignaturesForAddress(
    address _votingAddress,
    bool _override,
    bytes4[] memory _signatures,
    bool[] memory _allowed
  ) internal {

    uint256 len = _signatures.length;
    _validateArrayLength(len);
    require(len == _allowed.length, "Arrays lengths are not equals");

    for (uint256 i = 0; i < len; i++) {
      votingSignatures[_votingAddress][_signatures[i]] = VotingSignature(_allowed[i], _override);
      emit SetSignatureAllowedForAddress(_votingAddress, _signatures[i], _allowed[i], _override);
    }
  }

  function _validateArrayLength(uint256 _len) internal {

    require(_len <= 100, "Array length should be less or equal 100");
  }
}