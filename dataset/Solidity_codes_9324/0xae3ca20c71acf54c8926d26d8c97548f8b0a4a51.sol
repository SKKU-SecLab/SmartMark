


pragma solidity 0.6.12;

contract LiteSig {


    event Deposit(address indexed source, uint value);
    event Execution(uint indexed transactionId, address indexed destination, uint value, bytes data);
    event ExecutionFailure(uint indexed transactionId, address indexed destination, uint value, bytes data);

    address[] public owners;

    mapping(address => bool) ownersMap;

    uint public nonce = 0;

    uint public requiredSignatures = 0;

    bytes32 constant EIP712DOMAINTYPE_HASH = 0xd87cd6ef79d4e2b95e15ce8abf732db51ec771f1ca2edccf22a46c729ac56472;

    bytes32 constant NAME_HASH = 0x3308695f49e3f28122810c848e1569a04488ca4f6a11835568450d7a38a86120;

    bytes32 constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    bytes32 constant TXTYPE_HASH = 0x81336c6b66e18c614f29c0c96edcbcbc5f8e9221f35377412f0ea5d6f428918e;

    bytes32 constant SALT = 0x9c360831104e550f13ec032699c5f1d7f17190a31cdaf5c83945a04dfd319eea;

    bytes32 public DOMAIN_SEPARATOR;

    bool initialized = false;

    function init(address[] memory _owners, uint _requiredSignatures, uint chainId) public {

        require(!initialized, "Init function can only be run once");
        initialized = true;

        require(_owners.length > 0 && _owners.length <= 10, "Owners List min is 1 and max is 10");
        require(
            _requiredSignatures > 0 && _requiredSignatures <= _owners.length,
            "Required signatures must be in the proper range"
        );

        address lastAdd = address(0);
        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] > lastAdd, "Owner addresses must be unique and in order");
            ownersMap[_owners[i]] = true;
            lastAdd = _owners[i];
        }

        owners = _owners;
        requiredSignatures = _requiredSignatures;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(EIP712DOMAINTYPE_HASH,
            NAME_HASH,
            VERSION_HASH,
            chainId,
            address(this),
            SALT)
        );
    }

    function safeRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {


        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function submit(
        uint8[] memory sigV,
        bytes32[] memory sigR,
        bytes32[] memory sigS,
        address destination,
        uint value,
        bytes memory data
    ) public returns (bool)
    {

        require(initialized, "Initialization must be complete");

        require(sigR.length == sigS.length && sigR.length == sigV.length, "Sig arrays not the same lengths");
        require(sigR.length == requiredSignatures, "Signatures list is not the expected length");

        bytes32 txInputHash = keccak256(abi.encode(TXTYPE_HASH, destination, value, keccak256(data), nonce, tx.origin));
        bytes32 totalHash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, txInputHash));

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, totalHash));

        address lastAdd = address(0); // cannot have address(0) as an owner
        for (uint i = 0; i < requiredSignatures; i++) {

            address recovered = safeRecover(prefixedHash, sigV[i], sigR[i], sigS[i]);

            require(ownersMap[recovered], "Signature must be from an owner");
            require(recovered > lastAdd, "Signature must be unique");
            lastAdd = recovered;
        }

        nonce = nonce + 1;
        (bool success, ) = address(destination).call{value: value}(data);
        if(success) {
            emit Execution(nonce, destination, value, data);
        } else {
            emit ExecutionFailure(nonce, destination, value, data);
        }

        return success;
    }

    receive () external payable {
        emit Deposit(msg.sender, msg.value);
    }

}



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


contract Administratable is Ownable {


    mapping (address => bool) public administrators;

    event AdminAdded(address indexed addedAdmin, address indexed addedBy);
    event AdminRemoved(address indexed removedAdmin, address indexed removedBy);

    modifier onlyAdministrator() {

        require(isAdministrator(msg.sender), "Calling account is not an administrator.");
        _;
    }

    function isAdministrator(address addressToTest) public view returns (bool) {

        return administrators[addressToTest];
    }

    function addAdmin(address adminToAdd) public onlyOwner {

        require(administrators[adminToAdd] == false, "Account to be added to admin list is already an admin");

        administrators[adminToAdd] = true;

        emit AdminAdded(adminToAdd, msg.sender);
    }

    function removeAdmin(address adminToRemove) public onlyOwner {

        require(administrators[adminToRemove] == true, "Account to be removed from admin list is not already an admin");

        administrators[adminToRemove] = false;

        emit AdminRemoved(adminToRemove, msg.sender);
    }
}


pragma solidity 0.6.12;

contract Proxy {

    
    uint256 constant PROXIABLE_SLOT = 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;

    constructor(address contractLogic) public {
        require(contractLogic != address(0), "Contract Logic cannot be 0x0");

        assembly { // solium-disable-line
            sstore(PROXIABLE_SLOT, contractLogic)
        }
    }

    fallback() external payable {
        assembly { // solium-disable-line
            let contractLogic := sload(PROXIABLE_SLOT)
            let ptr := mload(0x40)
            calldatacopy(ptr, 0x0, calldatasize())
            let success := delegatecall(gas(), contractLogic, ptr, calldatasize(), 0, 0)
            let retSz := returndatasize()
            returndatacopy(ptr, 0, retSz)
            switch success
            case 0 {
                revert(ptr, retSz)
            }
            default {
                return(ptr, retSz)
            }
        }
    }
}


pragma solidity 0.6.12;




contract LiteSigFactory is Administratable {


  event Deployed(address indexed deployedAddress);

  address public liteSigLogicAddress;

  constructor(address _liteSigLogicAddress) public {
    Administratable.addAdmin(msg.sender);

    liteSigLogicAddress = _liteSigLogicAddress;
  }

  function createLiteSig(bytes32 salt, address[] memory _owners, uint _requiredSignatures, uint chainId)
    public onlyAdministrator returns (address) {

    address payable deployedAddress;

    bytes memory code = type(Proxy).creationCode;

    bytes memory deployCode = abi.encodePacked(code, abi.encode(liteSigLogicAddress));

    assembly {
      deployedAddress := create2(0, add(deployCode, 0x20), mload(deployCode), salt)
      if iszero(extcodesize(deployedAddress)) { revert(0, 0) }
    }

    LiteSig(deployedAddress).init(_owners, _requiredSignatures, chainId);

    emit Deployed(deployedAddress);

    return deployedAddress;
  }
}