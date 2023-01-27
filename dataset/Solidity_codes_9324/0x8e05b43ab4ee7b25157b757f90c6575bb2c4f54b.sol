


// Adapted to use pragma ^0.4.24 and satisfy our linter rules

pragma solidity ^0.4.24;


library SafeMath {

    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}




pragma solidity ^0.4.24;


contract IsContract {

    function isContract(address _target) internal view returns (bool) {

        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}



pragma solidity ^0.4.24;

interface IERC721Receiver {

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);

}



pragma solidity ^0.4.24;

contract ERC165 {

    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() internal {
        _registerInterface(_InterfaceId_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}




pragma solidity ^0.4.24;

library Strings {

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits;
        temp = value;
        while (temp != 0) {
            buffer[--index] = bytes1(uint8(48 + uint256(temp % 10)));
            temp /= 10;
        }
        return string(buffer);
    }
}



pragma solidity ^0.4.24;






contract ERC721 is ERC165, IsContract {

    using SafeMath for uint256;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;

    bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;

    bytes4 private constant _InterfaceId_ERC721Metadata = 0x5b5e139f;

    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

    string private _baseURI;
     
    function configureToken(string name, string symbol) internal {


        require(bytes(_name).length == 0 && bytes(_symbol).length == 0);

        _name = name;
        _symbol = symbol;

        _registerInterface(_InterfaceId_ERC165);
        _registerInterface(_InterfaceId_ERC721);
        _registerInterface(_InterfaceId_ERC721Metadata);
        _registerInterface(_InterfaceId_ERC721Enumerable);
    }

    function name() external view returns (string) {

        return _name;
    }

    function symbol() external view returns (string) {

        return _symbol;
    }

    function tokenURI(uint256 _tokenId) external view returns (string){

        require(_exists(_tokenId));
        string memory _tokenURI = _tokenURIs[_tokenId];

        if (bytes(_tokenURI).length == 0) {
            return string(abi.encodePacked(_baseURI, Strings.toString(_tokenId)));
        } else {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
    }

    function balanceOf(address _owner) external view returns (uint256) {

        return _balanceOf(_owner);
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {

        return _ownerOf(_tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external payable {

        require(msg.value == 0);

        _safeTransferFrom(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {

        require(msg.value == 0);

        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {

        require(msg.value == 0);

        _transferFrom(_from, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) external payable {

        require(msg.value == 0);

        address owner = _ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || _isApprovedForAll(owner, msg.sender));

        _tokenApprovals[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {

        require(_operator != msg.sender);
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {

        return _getApproved(_tokenId);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {

        return _isApprovedForAll(_owner,_operator);
    }

    function totalSupply() external view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {

        require(_index < _allTokens.length);
        return _allTokens[_index];
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {

        require(_owner != address(0));
        require(_index < _balanceOf(_owner));
        return _ownedTokens[_owner][_index];
    }

    function _balanceOf(address _owner) internal view returns (uint256) {

        require(_owner != address(0));
        return _ownedTokens[_owner].length;
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {

        require(_isApprovedOrOwner(msg.sender, _tokenId));
        require(_to != address(0));

        _clearApproval(_from, _tokenId);
        _removeTokenFrom(_from, _tokenId);
        _addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) internal {

        _transferFrom(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data));
    }

    function _isApprovedForAll(address _owner, address _operator) internal view returns (bool) {

        return _operatorApprovals[_owner][_operator];
    }

    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {

        address owner = _ownerOf(_tokenId);
        return (_spender == owner || _getApproved(_tokenId) == _spender || _isApprovedForAll(owner, _spender));
    }

    function _getApproved(uint256 _tokenId) internal view returns (address) {

        require(_exists(_tokenId));
        return _tokenApprovals[_tokenId];
    }

    function _mint(address _to, uint256 _tokenId) internal {

        require(_to != address(0));
        _addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    function _burn(address _owner, uint256 _tokenId) internal {

        _clearApproval(_owner, _tokenId);
        _removeTokenFrom(_owner, _tokenId);

        uint256 tokenIndex = _allTokensIndex[_tokenId];
        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 lastToken = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastToken;
        _allTokens[lastTokenIndex] = 0;

        _allTokens.length--;
        _allTokensIndex[_tokenId] = 0;
        _allTokensIndex[lastToken] = tokenIndex;

        if (bytes(_tokenURIs[_tokenId]).length != 0) {
            delete _tokenURIs[_tokenId];
        }

        emit Transfer(_owner, address(0), _tokenId);
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address) {

        address owner = _tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

    function _addTokenTo(address to, uint256 tokenId) internal {

        require(_tokenOwner[tokenId] == address(0));

        uint256 length = _ownedTokens[to].length;

        _tokenOwner[tokenId] = to;
        _ownedTokens[to].push(tokenId);
        _ownedTokensIndex[tokenId] = length;
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _setTokenURI(uint256 _tokenId, string _uri) internal {

        require(_exists(_tokenId));
        _tokenURIs[_tokenId] = _uri;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _removeTokenFrom(address from, uint256 tokenId) internal {

        require(_ownerOf(tokenId) == from);
        _tokenOwner[tokenId] = address(0);

        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 lastToken = _ownedTokens[from][lastTokenIndex];

        _ownedTokens[from][tokenIndex] = lastToken;
        _ownedTokens[from].length--;


        _ownedTokensIndex[tokenId] = 0;
        _ownedTokensIndex[lastToken] = tokenIndex;
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes _data) internal returns (bool) {

        if (!isContract(to)) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }


    function _clearApproval(address _owner, uint256 _tokenId) internal {

        require(_ownerOf(_tokenId) == _owner);
        if (_tokenApprovals[_tokenId] != address(0)) {
            _tokenApprovals[_tokenId] = address(0);
        }
    }

    function _setBaseURI(string memory baseURI) internal {

        _baseURI = baseURI;
    }

    function baseURI() external view returns (string memory) {

        return _baseURI;
    }
}




pragma solidity ^0.4.24;


library UnstructuredStorage {

    function getStorageBool(bytes32 position) internal view returns (bool data) {

        assembly { data := sload(position) }
    }

    function getStorageAddress(bytes32 position) internal view returns (address data) {

        assembly { data := sload(position) }
    }

    function getStorageBytes32(bytes32 position) internal view returns (bytes32 data) {

        assembly { data := sload(position) }
    }

    function getStorageUint256(bytes32 position) internal view returns (uint256 data) {

        assembly { data := sload(position) }
    }

    function setStorageBool(bytes32 position, bool data) internal {

        assembly { sstore(position, data) }
    }

    function setStorageAddress(bytes32 position, address data) internal {

        assembly { sstore(position, data) }
    }

    function setStorageBytes32(bytes32 position, bytes32 data) internal {

        assembly { sstore(position, data) }
    }

    function setStorageUint256(bytes32 position, uint256 data) internal {

        assembly { sstore(position, data) }
    }
}




pragma solidity ^0.4.24;


interface IACL {

    function initialize(address permissionsCreator) external;


    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);

}




pragma solidity ^0.4.24;


interface IVaultRecoverable {

    function transferToVault(address token) external;


    function allowRecoverability(address token) external view returns (bool);

    function getRecoveryVault() external view returns (address);

}




pragma solidity ^0.4.24;


contract IKernel is IVaultRecoverable {

    event SetApp(bytes32 indexed namespace, bytes32 indexed appId, address app);

    function acl() public view returns (IACL);

    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);


    function setApp(bytes32 namespace, bytes32 appId, address app) public;

    function getApp(bytes32 namespace, bytes32 appId) public view returns (address);

}




pragma solidity ^0.4.24;


contract AppStorage {

    using UnstructuredStorage for bytes32;

    bytes32 internal constant KERNEL_POSITION = 0x4172f0f7d2289153072b0a6ca36959e0cbe2efc3afe50fc81636caa96338137b;
    bytes32 internal constant APP_ID_POSITION = 0xd625496217aa6a3453eecb9c3489dc5a53e6c67b444329ea2b2cbc9ff547639b;

    function kernel() public view returns (IKernel) {

        return IKernel(KERNEL_POSITION.getStorageAddress());
    }

    function appId() public view returns (bytes32) {

        return APP_ID_POSITION.getStorageBytes32();
    }

    function setKernel(IKernel _kernel) internal {

        KERNEL_POSITION.setStorageAddress(address(_kernel));
    }

    function setAppId(bytes32 _appId) internal {

        APP_ID_POSITION.setStorageBytes32(_appId);
    }
}



pragma solidity ^0.4.24;


library Uint256Helpers {

    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint64(uint256 a) internal pure returns (uint64) {

        require(a <= MAX_UINT64, ERROR_NUMBER_TOO_BIG);
        return uint64(a);
    }
}




pragma solidity ^0.4.24;

contract TimeHelpers {

    using Uint256Helpers for uint256;

    function getBlockNumber() internal view returns (uint256) {

        return block.number;
    }

    function getBlockNumber64() internal view returns (uint64) {

        return getBlockNumber().toUint64();
    }

    function getTimestamp() internal view returns (uint256) {

        return block.timestamp; // solium-disable-line security/no-block-members
    }

    function getTimestamp64() internal view returns (uint64) {

        return getTimestamp().toUint64();
    }
}




pragma solidity ^0.4.24;


contract Initializable is TimeHelpers {

    using UnstructuredStorage for bytes32;

    bytes32 internal constant INITIALIZATION_BLOCK_POSITION = 0xebb05b386a8d34882b8711d156f463690983dc47815980fb82aeeff1aa43579e;

    string private constant ERROR_ALREADY_INITIALIZED = "INIT_ALREADY_INITIALIZED";
    string private constant ERROR_NOT_INITIALIZED = "INIT_NOT_INITIALIZED";

    modifier onlyInit {

        require(getInitializationBlock() == 0, ERROR_ALREADY_INITIALIZED);
        _;
    }

    modifier isInitialized {

        require(hasInitialized(), ERROR_NOT_INITIALIZED);
        _;
    }

    function getInitializationBlock() public view returns (uint256) {

        return INITIALIZATION_BLOCK_POSITION.getStorageUint256();
    }

    function hasInitialized() public view returns (bool) {

        uint256 initializationBlock = getInitializationBlock();
        return initializationBlock != 0 && getBlockNumber() >= initializationBlock;
    }

    function initialized() internal onlyInit {

        INITIALIZATION_BLOCK_POSITION.setStorageUint256(getBlockNumber());
    }

    function initializedAt(uint256 _blockNumber) internal onlyInit {

        INITIALIZATION_BLOCK_POSITION.setStorageUint256(_blockNumber);
    }
}




pragma solidity ^0.4.24;

contract Petrifiable is Initializable {

    uint256 internal constant PETRIFIED_BLOCK = uint256(-1);

    function isPetrified() public view returns (bool) {

        return getInitializationBlock() == PETRIFIED_BLOCK;
    }

    function petrify() internal onlyInit {

        initializedAt(PETRIFIED_BLOCK);
    }
}




pragma solidity ^0.4.24;

contract Autopetrified is Petrifiable {

    constructor() public {
        petrify();
    }
}




pragma solidity ^0.4.24;


contract ERC20 {

    function totalSupply() public view returns (uint256);


    function balanceOf(address _who) public view returns (uint256);


    function allowance(address _owner, address _spender)
        public view returns (uint256);


    function transfer(address _to, uint256 _value) public returns (bool);


    function approve(address _spender, uint256 _value)
        public returns (bool);


    function transferFrom(address _from, address _to, uint256 _value)
        public returns (bool);


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}




pragma solidity ^0.4.24;


contract EtherTokenConstant {

    address internal constant ETH = address(0);
}




pragma solidity ^0.4.24;




contract VaultRecoverable is IVaultRecoverable, EtherTokenConstant, IsContract {

    string private constant ERROR_DISALLOWED = "RECOVER_DISALLOWED";
    string private constant ERROR_VAULT_NOT_CONTRACT = "RECOVER_VAULT_NOT_CONTRACT";

    function transferToVault(address _token) external {

        require(allowRecoverability(_token), ERROR_DISALLOWED);
        address vault = getRecoveryVault();
        require(isContract(vault), ERROR_VAULT_NOT_CONTRACT);

        if (_token == ETH) {
            vault.transfer(address(this).balance);
        } else {
            uint256 amount = ERC20(_token).balanceOf(this);
            ERC20(_token).transfer(vault, amount);
        }
    }

    function allowRecoverability(address token) public view returns (bool) {

        return true;
    }

    function getRecoveryVault() public view returns (address);

}




pragma solidity ^0.4.24;


interface IEVMScriptExecutor {

    function execScript(bytes script, bytes input, address[] blacklist) external returns (bytes);

    function executorType() external pure returns (bytes32);

}




pragma solidity ^0.4.24;

contract EVMScriptRegistryConstants {

    bytes32 internal constant EVMSCRIPT_REGISTRY_APP_ID = 0xddbcfd564f642ab5627cf68b9b7d374fb4f8a36e941a75d89c87998cef03bd61;
}


interface IEVMScriptRegistry {

    function addScriptExecutor(IEVMScriptExecutor executor) external returns (uint id);

    function disableScriptExecutor(uint256 executorId) external;


    function getScriptExecutor(bytes script) public view returns (IEVMScriptExecutor);

}




pragma solidity ^0.4.24;


contract KernelAppIds {

    bytes32 internal constant KERNEL_CORE_APP_ID = 0x3b4bf6bf3ad5000ecf0f989d5befde585c6860fea3e574a4fab4c49d1c177d9c;
    bytes32 internal constant KERNEL_DEFAULT_ACL_APP_ID = 0xe3262375f45a6e2026b7e7b18c2b807434f2508fe1a2a3dfb493c7df8f4aad6a;
    bytes32 internal constant KERNEL_DEFAULT_VAULT_APP_ID = 0x7e852e0fcfce6551c13800f1e7476f982525c2b5277ba14b24339c68416336d1;
}


contract KernelNamespaceConstants {

    bytes32 internal constant KERNEL_CORE_NAMESPACE = 0xc681a85306374a5ab27f0bbc385296a54bcd314a1948b6cf61c4ea1bc44bb9f8;
    bytes32 internal constant KERNEL_APP_BASES_NAMESPACE = 0xf1f3eb40f5bc1ad1344716ced8b8a0431d840b5783aea1fd01786bc26f35ac0f;
    bytes32 internal constant KERNEL_APP_ADDR_NAMESPACE = 0xd6f028ca0e8edb4a8c9757ca4fdccab25fa1e0317da1188108f7d2dee14902fb;
}




pragma solidity ^0.4.24;




contract EVMScriptRunner is AppStorage, Initializable, EVMScriptRegistryConstants, KernelNamespaceConstants {

    string private constant ERROR_EXECUTOR_UNAVAILABLE = "EVMRUN_EXECUTOR_UNAVAILABLE";
    string private constant ERROR_EXECUTION_REVERTED = "EVMRUN_EXECUTION_REVERTED";
    string private constant ERROR_PROTECTED_STATE_MODIFIED = "EVMRUN_PROTECTED_STATE_MODIFIED";

    event ScriptResult(address indexed executor, bytes script, bytes input, bytes returnData);

    function getEVMScriptExecutor(bytes _script) public view returns (IEVMScriptExecutor) {

        return IEVMScriptExecutor(getEVMScriptRegistry().getScriptExecutor(_script));
    }

    function getEVMScriptRegistry() public view returns (IEVMScriptRegistry) {

        address registryAddr = kernel().getApp(KERNEL_APP_ADDR_NAMESPACE, EVMSCRIPT_REGISTRY_APP_ID);
        return IEVMScriptRegistry(registryAddr);
    }

    function runScript(bytes _script, bytes _input, address[] _blacklist)
        internal
        isInitialized
        protectState
        returns (bytes)
    {

        IEVMScriptExecutor executor = getEVMScriptExecutor(_script);
        require(address(executor) != address(0), ERROR_EXECUTOR_UNAVAILABLE);

        bytes4 sig = executor.execScript.selector;
        bytes memory data = abi.encodeWithSelector(sig, _script, _input, _blacklist);
        require(address(executor).delegatecall(data), ERROR_EXECUTION_REVERTED);

        bytes memory output = returnedDataDecoded();

        emit ScriptResult(address(executor), _script, _input, output);

        return output;
    }

    function returnedDataDecoded() internal pure returns (bytes ret) {

        assembly {
            let size := returndatasize
            switch size
            case 0 {}
            default {
                ret := mload(0x40) // free mem ptr get
                mstore(0x40, add(ret, add(size, 0x20))) // free mem ptr set
                returndatacopy(ret, 0x20, sub(size, 0x20)) // copy return data
            }
        }
        return ret;
    }

    modifier protectState {

        address preKernel = address(kernel());
        bytes32 preAppId = appId();
        _; // exec
        require(address(kernel()) == preKernel, ERROR_PROTECTED_STATE_MODIFIED);
        require(appId() == preAppId, ERROR_PROTECTED_STATE_MODIFIED);
    }
}




pragma solidity ^0.4.24;


contract ACLSyntaxSugar {

    function arr() internal pure returns (uint256[]) {}


    function arr(bytes32 _a) internal pure returns (uint256[] r) {

        return arr(uint256(_a));
    }

    function arr(bytes32 _a, bytes32 _b) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a) internal pure returns (uint256[] r) {

        return arr(uint256(_a));
    }

    function arr(address _a, address _b) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {

        return arr(uint256(_a), _b, _c);
    }

    function arr(address _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {

        return arr(uint256(_a), _b, _c, _d);
    }

    function arr(address _a, uint256 _b) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a, address _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b), _c, _d, _e);
    }

    function arr(address _a, address _b, address _c) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b), uint256(_c));
    }

    function arr(address _a, address _b, uint256 _c) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b), uint256(_c));
    }

    function arr(uint256 _a) internal pure returns (uint256[] r) {

        r = new uint256[](1);
        r[0] = _a;
    }

    function arr(uint256 _a, uint256 _b) internal pure returns (uint256[] r) {

        r = new uint256[](2);
        r[0] = _a;
        r[1] = _b;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {

        r = new uint256[](3);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {

        r = new uint256[](4);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
        r[3] = _d;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {

        r = new uint256[](5);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
        r[3] = _d;
        r[4] = _e;
    }
}


contract ACLHelpers {

    function decodeParamOp(uint256 _x) internal pure returns (uint8 b) {

        return uint8(_x >> (8 * 30));
    }

    function decodeParamId(uint256 _x) internal pure returns (uint8 b) {

        return uint8(_x >> (8 * 31));
    }

    function decodeParamsList(uint256 _x) internal pure returns (uint32 a, uint32 b, uint32 c) {

        a = uint32(_x);
        b = uint32(_x >> (8 * 4));
        c = uint32(_x >> (8 * 8));
    }
}




pragma solidity ^0.4.24;





contract AragonApp is AppStorage, Autopetrified, VaultRecoverable, EVMScriptRunner, ACLSyntaxSugar {

    string private constant ERROR_AUTH_FAILED = "APP_AUTH_FAILED";

    modifier auth(bytes32 _role) {

        require(canPerform(msg.sender, _role, new uint256[](0)), ERROR_AUTH_FAILED);
        _;
    }

    modifier authP(bytes32 _role, uint256[] _params) {

        require(canPerform(msg.sender, _role, _params), ERROR_AUTH_FAILED);
        _;
    }

    function canPerform(address _sender, bytes32 _role, uint256[] _params) public view returns (bool) {

        if (!hasInitialized()) {
            return false;
        }

        IKernel linkedKernel = kernel();
        if (address(linkedKernel) == address(0)) {
            return false;
        }

        bytes memory how;
        uint256 byteLength = _params.length * 32;
        assembly {
            how := _params
            mstore(how, byteLength)
        }
        return linkedKernel.hasPermission(_sender, address(this), _role, how);
    }

    function getRecoveryVault() public view returns (address) {

        return kernel().getRecoveryVault(); // if kernel is not set, it will revert
    }
}



pragma solidity ^0.4.24;


contract AragonNFT is ERC721, AragonApp {


    bytes32 constant public MINT_ROLE = keccak256("MINT_ROLE");
    bytes32 constant public BURN_ROLE = keccak256("BURN_ROLE");

    function initialize(string _name, string _symbol) public onlyInit {

        require(bytes(_name).length != 0);
        require(bytes(_symbol).length != 0);

        configureToken(_name, _symbol);
        initialized();
    }
    
    function mint(address _to, uint256 _tokenId) auth(MINT_ROLE) public {

        _mint(_to, _tokenId);
    }

    function burn(uint256 _tokenId) auth(BURN_ROLE) public {

        require(msg.sender == _ownerOf(_tokenId));
        _burn(_ownerOf(_tokenId), _tokenId);
    }

    function setTokenURI(uint256 _tokenId, string _uri) auth(MINT_ROLE) public {

        _setTokenURI(_tokenId, _uri);
    }

    function setBaseURI(string memory baseURI) auth(MINT_ROLE) public {

        _setBaseURI(baseURI);
    }

    function clearApproval(address _owner, uint256 _tokenId) public {

        require(msg.sender == _ownerOf(_tokenId));
        _clearApproval(msg.sender, _tokenId);
    }

    function exists(uint256 _tokenId) public view returns (bool) {

        return _exists(_tokenId);
    }

    function tokensOfOwner(address _owner) public view returns (uint256[] memory) {

        return _tokensOfOwner(_owner);
    }
}