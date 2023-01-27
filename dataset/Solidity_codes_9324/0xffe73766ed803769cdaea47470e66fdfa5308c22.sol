

pragma solidity ^0.4.23;


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

pragma solidity ^0.4.24;

contract SolidStampRegister is Ownable
{

    address public contractSolidStamp;

    uint8 public constant NOT_AUDITED = 0x00;

    uint8 public constant AUDITED_AND_APPROVED = 0x01;

    uint8 public constant AUDITED_AND_REJECTED = 0x02;

    mapping (bytes32 => uint8) public AuditOutcomes;

    event AuditRegistered(address auditor, bytes32 codeHash, bool isApproved);

    constructor(address[] _existingAuditors, bytes32[] _existingCodeHashes, bool[] _outcomes) public {
        uint noOfExistingAudits = _existingAuditors.length;
        require(noOfExistingAudits == _existingCodeHashes.length, "paramters mismatch");
        require(noOfExistingAudits == _outcomes.length, "paramters mismatch");

        contractSolidStamp = msg.sender;
        for (uint i=0; i<noOfExistingAudits; i++){
            registerAuditOutcome(_existingAuditors[i], _existingCodeHashes[i], _outcomes[i]);
        }
        contractSolidStamp = 0x0;
    }

    function getAuditOutcome(address _auditor, bytes32 _codeHash) public view returns (uint8)
    {

        bytes32 hashAuditorCode = keccak256(abi.encodePacked(_auditor, _codeHash));
        return AuditOutcomes[hashAuditorCode];
    }

    function registerAuditOutcome(address _auditor, bytes32 _codeHash, bool _isApproved) public onlySolidStampContract
    {

        require(_auditor != 0x0, "auditor cannot be 0x0");
        bytes32 hashAuditorCode = keccak256(abi.encodePacked(_auditor, _codeHash));
        if ( _isApproved )
            AuditOutcomes[hashAuditorCode] = AUDITED_AND_APPROVED;
        else
            AuditOutcomes[hashAuditorCode] = AUDITED_AND_REJECTED;
        emit AuditRegistered(_auditor, _codeHash, _isApproved);
    }


    event SolidStampContractChanged(address newSolidStamp);
    modifier onlySolidStampContract() {

      require(msg.sender == contractSolidStamp, "cannot be run by not SolidStamp contract");
      _;
    }

    function changeSolidStampContract(address _newSolidStamp) public onlyOwner {

      require(_newSolidStamp != address(0), "SolidStamp contract cannot be 0x0");
      emit SolidStampContractChanged(_newSolidStamp);
      contractSolidStamp = _newSolidStamp;
    }

}