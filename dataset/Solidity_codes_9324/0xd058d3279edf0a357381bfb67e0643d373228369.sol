
pragma solidity ^0.4.24;



contract SafeBlocksProxy {


    event ContractDeployed(address sourceAddress, string cid, uint blockNumber);
    event Operation(address sourceAddress, bool approved, address token, uint amount, address destination, uint blockNumber);
    event ConfigurationChanged(address sender, address newConfiguration, string message);

    address owner;
    address superOwner;
    bool isBypassMode;
    bytes32 hashedPwd;
    SafeBlocksFirewall safeBlocksFirewall;

    constructor(address _superOwner, bytes32 _hashedPwd) public {
        owner = msg.sender;
        superOwner = _superOwner;
        hashedPwd = _hashedPwd;
        isBypassMode = false;
    }


    modifier onlyContractOwner {

        require(owner == msg.sender, "You are not allowed to run this function, required role: Contract-Owner");
        _;
    }

    modifier onlySuperOwner {

        require(superOwner == msg.sender, "You are not allowed to run this function, required role: Super-Owner");
        _;
    }

    modifier onlySuperOwnerWithPwd(string pwd, bytes32 newHashedPwd) {

        bytes32 hashedInput = keccak256(abi.encodePacked(pwd));
        require(superOwner == msg.sender && hashedInput == hashedPwd, "You are not allowed to run this function, required role: Super-Owner with Password");
        hashedPwd = newHashedPwd;
        _;
    }


    function setSuperOwner(address newSuperOwner, string pwd, bytes32 newHashedPwd)
    onlySuperOwnerWithPwd(pwd, newHashedPwd)
    public {

        superOwner = newSuperOwner;
        emit ConfigurationChanged(msg.sender, newSuperOwner, "a new Super-Owner has been assigned");
    }

    function setOwner(address newOwner, string pwd, bytes32 newHashedPwd)
    onlySuperOwnerWithPwd(pwd, newHashedPwd)
    public {

        owner = newOwner;
        emit ConfigurationChanged(msg.sender, newOwner, "a new Owner has been assigned");
    }

    function setBypassForAll(bool _bypass)
    onlySuperOwner
    public {

        isBypassMode = _bypass;
        emit ConfigurationChanged(msg.sender, msg.sender, "a new Bypass-Mode has been assigned");
    }

    function getBypassStatus()
    public
    view
    onlyContractOwner
    returns (bool){

        return isBypassMode;
    }

    function setSBFWContractAddress(address _sbfwAddress)
    onlyContractOwner
    public {

        safeBlocksFirewall = SafeBlocksFirewall(_sbfwAddress);
        emit ConfigurationChanged(msg.sender, _sbfwAddress, "a new address has been assigned to SafeBlocksFirewall");
    }


    function allowTransaction(uint _amount, address _destination, address _token)
    public
    returns (bool) {

        address contractAddress = msg.sender;

        if (isBypassMode) {
            emit Operation(contractAddress, true, _token, _amount, _destination, block.number);
            return true;
        }
        bool result = safeBlocksFirewall.allowTransaction(contractAddress, _amount, _destination, _token);
        emit Operation(contractAddress, result, _token, _amount, _destination, block.number);
        return result;
    }

    function contractDeployedNotice(string _cid, uint _blockNumber)
    public {

        emit ContractDeployed(msg.sender, _cid, _blockNumber);
    }

}

interface SafeBlocksFirewall {


    function allowTransaction(
        address _contractAddress,
        uint _amount,
        address _destination,
        address _token)
    external
    returns(bool);

}
