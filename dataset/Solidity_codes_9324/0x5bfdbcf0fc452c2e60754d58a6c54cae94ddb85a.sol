
pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}// MIT

pragma solidity =0.6.12;

interface IERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity =0.6.12;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT
pragma solidity =0.6.12;


contract MintLogic is Initializable {


    address public storageAddr;

    mapping(address => address) public projectOwner;

    constructor() public initializer {}

    modifier onlyStorage() {

        require(storageAddr == msg.sender, "MintProxy: caller is not the storage");
        _;
    }

    function initialize(address _storage) public initializer {

        storageAddr = _storage;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns(bytes4) {

        return this.onERC721Received.selector;
    }

    function execute(address _contolAddr, address _nftAddr, bytes memory _data) external payable onlyStorage {

        require(projectOwner[_nftAddr] == address(0) || projectOwner[_nftAddr] == tx.origin, "The project already has an owner");

        (bool success,) = _contolAddr.call{value : msg.value}(_data);
        require(success, "Call Contol Address Error");

        if(projectOwner[_nftAddr] == address(0)){
            projectOwner[_nftAddr] = tx.origin;
        }

        if(address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
    }

    function fetchNft(address _nftAddr, uint256 _tokenId) external onlyStorage {

        require(projectOwner[_nftAddr] == tx.origin, "require project owner");
        try IERC721Enumerable(_nftAddr).transferFrom(address(this), tx.origin, _tokenId) {} catch {}
    }
}// MIT
pragma solidity =0.6.12;

interface IChiGasToken {

  function allowance(address owner, address spender) external view returns(uint256);

  function approve(address spender, uint256 amount) external returns(bool);

  function balanceOf(address account) external view returns (uint256);

  function computeAddress2(uint256 salt) external view returns(address);

  function decimals() external view returns(uint8);

  function free(uint256 value) external returns(uint256);

  function freeFrom(address from, uint256 value) external returns(uint256);

  function freeFromUpTo(address from, uint256 value) external returns(uint256);

  function freeUpTo(uint256 value ) external returns(uint256);

  function mint(uint256 value) external;

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function totalBurned() external view returns(uint256);

  function totalMinted() external view returns(uint256);

  function totalSupply() external view returns(uint256);

  function transfer(address recipient, uint256 amount) external returns(bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract UpgradeableProxy is Proxy {

    constructor(address _logic, bytes memory _data) public payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            Address.functionDelegateCall(_logic, _data);
        }
    }

    event Upgraded(address indexed implementation);

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal view virtual override returns (address impl) {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal virtual {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract MintLogicProxy is UpgradeableProxy {

    constructor(address _logic, address admin_, bytes memory _data) public payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(admin_);
    }

    event AdminChanged(address previousAdmin, address newAdmin);

    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _admin();
    }

    function implementation() external view returns (address implementation_) {

        implementation_ = _implementation();
    }

    function _implementation() internal view override returns (address impl) {

        (bool success, bytes memory data) = _admin().staticcall(abi.encodeWithSignature("logicAddr()"));
        require(success && data.length > 0, "Get Logic Address Error");
        impl = abi.decode(data, (address));
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external virtual ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable virtual ifAdmin {

        _upgradeTo(newImplementation);
        Address.functionDelegateCall(newImplementation, data);
    }

    function _admin() internal view virtual returns (address adm) {

        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) private {

        bytes32 slot = _ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

}// MIT
pragma solidity =0.6.12;


contract MintStorage is Initializable {

    using Address for address;

    address public owner;
    address public logicAddr;
    address[] public mintProxys;

    bool public paidUse;
    bool public gasOptimization;
    IChiGasToken public chiGasToken;

    constructor() public initializer {}

    modifier onlyOwner() {

        require(owner == msg.sender, "MintProxy: caller is not the owner");
        _;
    }

    modifier optimization() {

        if(gasOptimization){
            uint u1 = gasleft();
            _;
            uint u2 = gasleft();
            uint chiUse = ((u1 - u2) / 2) / 24000;
            if(chiUse > 9) {
                chiGasToken.freeFromUpTo(tx.origin, chiUse);
            }
        }else {
            _;
        }
    }

    modifier paid() {

        if(paidUse){
            createProxys(1);
        }
        _;
    }

    function initialize() public initializer {

        owner = msg.sender;
    }

    function setPaidUse(bool _paidUse) external onlyOwner {

        paidUse = _paidUse;
    }

    function setLogicAddr(address _logicAddr) external onlyOwner {

        logicAddr = _logicAddr;
    }

    function setGasOptimization(bool _gasOptimization, address _chiGasToken) external onlyOwner {

        gasOptimization = _gasOptimization;
        chiGasToken = IChiGasToken(_chiGasToken);
    }

    function createProxys(uint256 _quantity) public optimization {

        for(uint i = 0; i < _quantity; i++){
            MintLogicProxy mintProxy = new MintLogicProxy(logicAddr, address(this), abi.encodeWithSignature("initialize(address)", address(this)));
            mintProxys.push(address(mintProxy));
        }
    }

    function getProxySize() public view returns(uint256) {

        return mintProxys.length;
    }

    function execute(uint256 _start, uint256 _end, address _contolAddr, address _nftAddr, uint256 _price, bytes memory _data) external payable optimization paid {

        for(uint i = _start; i < _end; i++){
            try MintLogic(mintProxys[i]).execute{value : _price}(_contolAddr, _nftAddr, _data) {
                continue;
            } catch {
                break;
            }
        }
        if(address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        
    }

    function fetchNft(address _nftAddr, uint256[] memory _tokenIds) external optimization {
        IERC721Enumerable nft = IERC721Enumerable(_nftAddr);
        for(uint i = 0; i < _tokenIds.length; i++){
            address nftOwner = nft.ownerOf(_tokenIds[i]);
            if (nftOwner.isContract()) {
                try MintLogic(nftOwner).fetchNft(_nftAddr, _tokenIds[i]) {
                    continue;
                } catch {
                    break;
                }
            }
        }
    }

    function fetchNft(address _nftAddr, uint256 _startId, uint256 _quantity) external optimization {
        IERC721Enumerable nft = IERC721Enumerable(_nftAddr);
        for(uint i = _startId; i < _startId + _quantity; i++){
            address nftOwner = nft.ownerOf(i);
            if (nftOwner.isContract()) {
                try MintLogic(nftOwner).fetchNft(_nftAddr, i) {
                    continue;
                } catch {
                    break;
                }
            }
        }
    }

}