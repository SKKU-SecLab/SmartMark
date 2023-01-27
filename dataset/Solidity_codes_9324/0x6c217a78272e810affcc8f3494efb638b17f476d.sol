



pragma solidity ^0.8.3;

contract Proxy {


    address immutable public implementation;

    event Received(uint indexed value, address indexed sender, bytes data);

    constructor(address _implementation) {
        implementation = _implementation;
    }

    fallback() external payable {
        address target = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), target, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }

    receive() external payable {
        emit Received(msg.value, msg.sender, "");
    }
}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;

interface IModule {


    function addModule(address _wallet, address _module) external;


    function init(address _wallet) external;



    function supportsStaticCall(bytes4 _methodId) external view returns (bool _isSupported);

}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>




pragma solidity >=0.5.4 <0.9.0;

interface IWallet {

    function owner() external view returns (address);


    function modules() external view returns (uint);


    function setOwner(address _newOwner) external;


    function authorised(address _module) external view returns (bool);


    function enabled(bytes4 _sig) external view returns (address);


    function authoriseModule(address _module, bool _value) external;


    function enableStaticCall(address _module, bytes4 _method) external;

}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;


contract BaseWallet is IWallet {


    address public override owner;
    mapping (address => bool) public override authorised;
    address public staticCallExecutor;
    uint public override modules;

    event AuthorisedModule(address indexed module, bool value);
    event Invoked(address indexed module, address indexed target, uint indexed value, bytes data);
    event Received(uint indexed value, address indexed sender, bytes data);
    event OwnerChanged(address owner);

    modifier moduleOnly {

        require(authorised[msg.sender], "BW: sender not authorized");
        _;
    }

    function init(address _owner, address[] calldata _modules) external {

        require(owner == address(0) && modules == 0, "BW: wallet already initialised");
        require(_modules.length > 0, "BW: empty modules");
        owner = _owner;
        modules = _modules.length;
        for (uint256 i = 0; i < _modules.length; i++) {
            require(authorised[_modules[i]] == false, "BW: module is already added");
            authorised[_modules[i]] = true;
            IModule(_modules[i]).init(address(this));
            emit AuthorisedModule(_modules[i], true);
        }
        if (address(this).balance > 0) {
            emit Received(address(this).balance, address(0), "");
        }
    }

    function authoriseModule(address _module, bool _value) external override moduleOnly {

        if (authorised[_module] != _value) {
            emit AuthorisedModule(_module, _value);
            if (_value == true) {
                modules += 1;
                authorised[_module] = true;
                IModule(_module).init(address(this));
            } else {
                modules -= 1;
                require(modules > 0, "BW: cannot remove last module");
                delete authorised[_module];
            }
        }
    }

    function enabled(bytes4 _sig) public view override returns (address) {

        address executor = staticCallExecutor;
        if(executor != address(0) && IModule(executor).supportsStaticCall(_sig)) {
            return executor;
        }
        return address(0);
    }

    function enableStaticCall(address _module, bytes4 /* _method */) external override moduleOnly {

        if(staticCallExecutor != _module) {
            require(authorised[_module], "BW: unauthorized executor");
            staticCallExecutor = _module;
        }
    }

    function setOwner(address _newOwner) external override moduleOnly {

        require(_newOwner != address(0), "BW: address cannot be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }

    function invoke(address _target, uint _value, bytes calldata _data) external moduleOnly returns (bytes memory _result) {

        bool success;
        (success, _result) = _target.call{value: _value}(_data);
        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
        emit Invoked(msg.sender, _target, _value, _data);
    }

    fallback() external payable {
        address module = enabled(msg.sig);
        if (module == address(0)) {
            emit Received(msg.value, msg.sender, msg.data);
        } else {
            require(authorised[module], "BW: unauthorised module");

            assembly {
                calldatacopy(0, 0, calldatasize())
                let result := staticcall(gas(), module, 0, calldatasize(), 0, 0)
                returndatacopy(0, 0, returndatasize())
                switch result
                case 0 {revert(0, returndatasize())}
                default {return (0, returndatasize())}
            }
        }
    }

    receive() external payable {
    }
}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>




pragma solidity >=0.5.4 <0.9.0;

contract Owned {


    address public owner;

    event OwnerChanged(address indexed _newOwner);

    modifier onlyOwner {

        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;


contract Managed is Owned {


    mapping (address => bool) public managers;

    modifier onlyManager {

        require(managers[msg.sender] == true, "M: Must be manager");
        _;
    }

    event ManagerAdded(address indexed _manager);
    event ManagerRevoked(address indexed _manager);

    function addManager(address _manager) external onlyOwner {

        require(_manager != address(0), "M: Address must not be null");
        if (managers[_manager] == false) {
            managers[_manager] = true;
            emit ManagerAdded(_manager);
        }
    }

    function revokeManager(address _manager) external virtual onlyOwner {

        require(managers[_manager] == true, "M: Target must be an existing manager");
        delete managers[_manager];
        emit ManagerRevoked(_manager);
    }
}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>




pragma solidity >=0.5.4 <0.9.0;

interface IGuardianStorage {


    function addGuardian(address _wallet, address _guardian) external;


    function revokeGuardian(address _wallet, address _guardian) external;


    function isGuardian(address _wallet, address _guardian) external view returns (bool);


    function isLocked(address _wallet) external view returns (bool);


    function getLock(address _wallet) external view returns (uint256);


    function getLocker(address _wallet) external view returns (address);


    function setLock(address _wallet, uint256 _releaseAfter) external;


    function getGuardians(address _wallet) external view returns (address[] memory);


    function guardianCount(address _wallet) external view returns (uint256);

}// Copyright (C) 2020  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;

library Utils {


    bytes4 private constant ERC20_TRANSFER = bytes4(keccak256("transfer(address,uint256)"));
    bytes4 private constant ERC20_APPROVE = bytes4(keccak256("approve(address,uint256)"));
    bytes4 private constant ERC721_SET_APPROVAL_FOR_ALL = bytes4(keccak256("setApprovalForAll(address,bool)"));
    bytes4 private constant ERC721_TRANSFER_FROM = bytes4(keccak256("transferFrom(address,address,uint256)"));
    bytes4 private constant ERC721_SAFE_TRANSFER_FROM = bytes4(keccak256("safeTransferFrom(address,address,uint256)"));
    bytes4 private constant ERC721_SAFE_TRANSFER_FROM_BYTES = bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"));
    bytes4 private constant ERC1155_SAFE_TRANSFER_FROM = bytes4(keccak256("safeTransferFrom(address,address,uint256,uint256,bytes)"));

    bytes4 private constant OWNER_SIG = 0x8da5cb5b;
    function recoverSigner(bytes32 _signedHash, bytes memory _signatures, uint _index) internal pure returns (address) {

        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly {
            r := mload(add(_signatures, add(0x20,mul(0x41,_index))))
            s := mload(add(_signatures, add(0x40,mul(0x41,_index))))
            v := and(mload(add(_signatures, add(0x41,mul(0x41,_index)))), 0xff)
        }
        require(v == 27 || v == 28, "Utils: bad v value in signature");

        address recoveredAddress = ecrecover(_signedHash, v, r, s);
        require(recoveredAddress != address(0), "Utils: ecrecover returned 0");
        return recoveredAddress;
    }

    function recoverSpender(address _to, bytes memory _data) internal pure returns (address spender) {

        if(_data.length >= 68) {
            bytes4 methodId;
            assembly {
                methodId := mload(add(_data, 0x20))
            }
            if(
                methodId == ERC20_TRANSFER ||
                methodId == ERC20_APPROVE ||
                methodId == ERC721_SET_APPROVAL_FOR_ALL) 
            {
                assembly {
                    spender := mload(add(_data, 0x24))
                }
                return spender;
            }
            if(
                methodId == ERC721_TRANSFER_FROM ||
                methodId == ERC721_SAFE_TRANSFER_FROM ||
                methodId == ERC721_SAFE_TRANSFER_FROM_BYTES ||
                methodId == ERC1155_SAFE_TRANSFER_FROM)
            {
                assembly {
                    spender := mload(add(_data, 0x44))
                }
                return spender;
            }
        }

        spender = _to;
    }

    function functionPrefix(bytes memory _data) internal pure returns (bytes4 prefix) {

        require(_data.length >= 4, "Utils: Invalid functionPrefix");
        assembly {
            prefix := mload(add(_data, 0x20))
        }
    }

    function isContract(address _addr) internal view returns (bool) {

        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function isGuardianOrGuardianSigner(address[] memory _guardians, address _guardian) internal view returns (bool, address[] memory) {

        if (_guardians.length == 0 || _guardian == address(0)) {
            return (false, _guardians);
        }
        bool isFound = false;
        address[] memory updatedGuardians = new address[](_guardians.length - 1);
        uint256 index = 0;
        for (uint256 i = 0; i < _guardians.length; i++) {
            if (!isFound) {
                if (_guardian == _guardians[i]) {
                    isFound = true;
                    continue;
                }
                if (isContract(_guardians[i]) && isGuardianOwner(_guardians[i], _guardian)) {
                    isFound = true;
                    continue;
                }
            }
            if (index < updatedGuardians.length) {
                updatedGuardians[index] = _guardians[i];
                index++;
            }
        }
        return isFound ? (true, updatedGuardians) : (false, _guardians);
    }

    function isGuardianOwner(address _guardian, address _owner) internal view returns (bool) {

        address owner = address(0);

        assembly {
            let ptr := mload(0x40)
            mstore(ptr,OWNER_SIG)
            let result := staticcall(25000, _guardian, ptr, 0x20, ptr, 0x20)
            if eq(result, 1) {
                owner := mload(ptr)
            }
        }
        return owner == _owner;
    }

    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        if (a % b == 0) {
            return c;
        } else {
            return c + 1;
        }
    }
}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;


contract WalletFactory is Managed {


    address constant internal ETH_TOKEN = address(0);

    address immutable public walletImplementation;
    address immutable public guardianStorage;
    address public refundAddress; 


    event RefundAddressChanged(address addr);
    event WalletCreated(address indexed wallet, address indexed owner, address indexed guardian, address refundToken, uint256 refundAmount);


    constructor(address _walletImplementation, address _guardianStorage, address _refundAddress) {
        require(_walletImplementation != address(0), "WF: empty wallet implementation");
        require(_guardianStorage != address(0), "WF: empty guardian storage");
        require(_refundAddress != address(0), "WF: empty refund address");
        walletImplementation = _walletImplementation;
        guardianStorage = _guardianStorage;
        refundAddress = _refundAddress;
    }


    function revokeManager(address /*_manager*/) override external pure {

        revert("WF: managers can't be revoked");
    }
     
    function createCounterfactualWallet(
        address _owner,
        address[] calldata _modules,
        address _guardian,
        bytes20 _salt,
        uint256 _refundAmount,
        address _refundToken,
        bytes calldata _ownerSignature,
        bytes calldata _managerSignature
    )
        external
        returns (address _wallet)
    {

        validateInputs(_owner, _modules, _guardian);
        bytes32 newsalt = newSalt(_salt, _owner, _modules, _guardian);
        address payable wallet = payable(new Proxy{salt: newsalt}(walletImplementation));
        validateAuthorisedCreation(wallet, _managerSignature);
        configureWallet(BaseWallet(wallet), _owner, _modules, _guardian);
        if (_refundAmount > 0 && _ownerSignature.length == 65) {
            validateAndRefund(wallet, _owner, _refundAmount, _refundToken, _ownerSignature);
        }
        BaseWallet(wallet).authoriseModule(address(this), false);

        emit WalletCreated(wallet, _owner, _guardian, _refundToken, _refundAmount);

        return wallet;
    }

    function getAddressForCounterfactualWallet(
        address _owner,
        address[] calldata _modules,
        address _guardian,
        bytes20 _salt
    )
        external
        view
        returns (address _wallet)
    {

        validateInputs(_owner, _modules, _guardian);
        bytes32 newsalt = newSalt(_salt, _owner, _modules, _guardian);
        bytes memory code = abi.encodePacked(type(Proxy).creationCode, uint256(uint160(walletImplementation)));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), newsalt, keccak256(code)));
        _wallet = address(uint160(uint256(hash)));
    }

    function changeRefundAddress(address _refundAddress) external onlyOwner {

        require(_refundAddress != address(0), "WF: cannot set to empty");
        refundAddress = _refundAddress;
        emit RefundAddressChanged(_refundAddress);
    }

    function init(BaseWallet _wallet) external pure {

    }


    function configureWallet(BaseWallet _wallet, address _owner, address[] calldata _modules, address _guardian) internal {

        address[] memory extendedModules = new address[](_modules.length + 1);
        extendedModules[0] = address(this);
        for (uint i = 0; i < _modules.length; i++) {
            extendedModules[i + 1] = _modules[i];
        }

        _wallet.init(_owner, extendedModules);

        IGuardianStorage(guardianStorage).addGuardian(address(_wallet), _guardian);
    }

    function newSalt(bytes20 _salt, address _owner, address[] calldata _modules, address _guardian) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(_owner, _modules, _guardian)), _salt));
    }

    function validateInputs(address _owner, address[] calldata _modules, address _guardian) internal pure {

        require(_owner != address(0), "WF: empty owner address");
        require(_owner != _guardian, "WF: owner cannot be guardian");
        require(_modules.length > 0, "WF: empty modules");
        require(_guardian != (address(0)), "WF: empty guardian");        
    }

    function validateAuthorisedCreation(address _wallet, bytes memory _managerSignature) internal view {

        address manager;
        if(_managerSignature.length != 65) {
            manager = msg.sender;
        } else {
            bytes32 signedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", bytes32(uint256(uint160(_wallet)))));
            manager = Utils.recoverSigner(signedHash, _managerSignature, 0);
        }
        require(managers[manager], "WF: unauthorised wallet creation");
    }

    function validateAndRefund(
        address _wallet,
        address _owner,
        uint256 _refundAmount,
        address _refundToken,
        bytes memory _ownerSignature
    )
        internal
    {

        bytes32 signedHash = keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(_wallet, _refundAmount, _refundToken))
            ));
        address signer = Utils.recoverSigner(signedHash, _ownerSignature, 0);
        if (signer == _owner) {
            if (_refundToken == ETH_TOKEN) {
                invokeWallet(_wallet, refundAddress, _refundAmount, "");
            } else {
                bytes memory methodData = abi.encodeWithSignature("transfer(address,uint256)", refundAddress, _refundAmount);
                bytes memory transferSuccessBytes = invokeWallet(_wallet, _refundToken, 0, methodData);
                if (transferSuccessBytes.length > 0) {
                    require(abi.decode(transferSuccessBytes, (bool)), "WF: Refund transfer failed");
                }
            }
        }
    }

    function invokeWallet(
        address _wallet,
        address _to,
        uint256 _value,
        bytes memory _data
    )
        internal
        returns (bytes memory _res)
    {

        bool success;
        (success, _res) = _wallet.call(abi.encodeWithSignature("invoke(address,uint256,bytes)", _to, _value, _data));
        if (success) {
            (_res) = abi.decode(_res, (bytes));
        } else {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }
}