
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IAddressRegistry {


    function initialize(
        address lock_manager_,
        address liquidity_,
        address revest_token_,
        address token_vault_,
        address revest_,
        address fnft_,
        address metadata_,
        address admin_,
        address rewards_
    ) external;


    function getAdmin() external view returns (address);


    function setAdmin(address admin) external;


    function getLockManager() external view returns (address);


    function setLockManager(address manager) external;


    function getTokenVault() external view returns (address);


    function setTokenVault(address vault) external;


    function getRevestFNFT() external view returns (address);


    function setRevestFNFT(address fnft) external;


    function getMetadataHandler() external view returns (address);


    function setMetadataHandler(address metadata) external;


    function getRevest() external view returns (address);


    function setRevest(address revest) external;


    function getDEX(uint index) external view returns (address);


    function setDex(address dex) external;


    function getRevestToken() external view returns (address);


    function setRevestToken(address token) external;


    function getRewardsHandler() external view returns(address);


    function setRewardsHandler(address esc) external;


    function getAddress(bytes32 id) external view returns (address);


    function getLPs() external view returns (address);


    function setLPs(address liquidToken) external;


}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;


contract RevestAddressRegistry is Ownable, IAddressRegistry {

    bytes32 public constant ADMIN = "ADMIN";
    bytes32 public constant LOCK_MANAGER = "LOCK_MANAGER";
    bytes32 public constant REVEST_TOKEN = "REVEST_TOKEN";
    bytes32 public constant TOKEN_VAULT = "TOKEN_VAULT";
    bytes32 public constant REVEST = "REVEST";
    bytes32 public constant FNFT = "FNFT";
    bytes32 public constant METADATA = "METADATA";
    bytes32 public constant ESCROW = 'ESCROW';
    bytes32 public constant LIQUIDITY_TOKENS = "LIQUIDITY_TOKENS";

    uint public next_dex = 0;

    mapping(bytes32 => address) public _addresses;
    mapping(uint => address) public _dex;

    constructor() Ownable() {}

    function initialize(
        address lock_manager_,
        address liquidity_,
        address revest_token_,
        address token_vault_,
        address revest_,
        address fnft_,
        address metadata_,
        address admin_,
        address rewards_
    ) external override onlyOwner {

        _addresses[ADMIN] = admin_;
        _addresses[LOCK_MANAGER] = lock_manager_;
        _addresses[REVEST_TOKEN] = revest_token_;
        _addresses[TOKEN_VAULT] = token_vault_;
        _addresses[REVEST] = revest_;
        _addresses[FNFT] = fnft_;
        _addresses[METADATA] = metadata_;
        _addresses[LIQUIDITY_TOKENS] = liquidity_;
        _addresses[ESCROW]=rewards_;
    }

    function getAdmin() external view override returns (address) {

        return _addresses[ADMIN];
    }

    function setAdmin(address admin) external override onlyOwner {

        _addresses[ADMIN] = admin;
    }

    function getLockManager() external view override returns (address) {

        return getAddress(LOCK_MANAGER);
    }

    function setLockManager(address manager) external override onlyOwner {

        _addresses[LOCK_MANAGER] = manager;
    }

    function getTokenVault() external view override returns (address) {

        return getAddress(TOKEN_VAULT);
    }

    function setTokenVault(address vault) external override onlyOwner {

        _addresses[TOKEN_VAULT] = vault;
    }

    function getRevest() external view override returns (address) {

        return getAddress(REVEST);
    }

    function setRevest(address revest) external override onlyOwner {

        _addresses[REVEST] = revest;
    }

    function getRevestFNFT() external view override returns (address) {

        return _addresses[FNFT];
    }

    function setRevestFNFT(address fnft) external override onlyOwner {

        _addresses[FNFT] = fnft;
    }

    function getMetadataHandler() external view override returns (address) {

        return _addresses[METADATA];
    }

    function setMetadataHandler(address metadata) external override onlyOwner {

        _addresses[METADATA] = metadata;
    }

    function getDEX(uint index) external view override returns (address) {

        return _dex[index];
    }

    function setDex(address dex) external override onlyOwner {

        _dex[next_dex] = dex;
        next_dex = next_dex + 1;
    }

    function getRevestToken() external view override returns (address) {

        return _addresses[REVEST_TOKEN];
    }

    function setRevestToken(address token) external override onlyOwner {

        _addresses[REVEST_TOKEN] = token;
    }

    function getRewardsHandler() external view override returns(address) {

        return _addresses[ESCROW];
    }

    function setRewardsHandler(address esc) external override onlyOwner {

        _addresses[ESCROW] = esc;
    }

    function getLPs() external view override returns (address) {

        return _addresses[LIQUIDITY_TOKENS];
    }

    function setLPs(address liquidToken) external override onlyOwner {

        _addresses[LIQUIDITY_TOKENS] = liquidToken;
    }

    function getAddress(bytes32 id) public view override returns (address) {

        return _addresses[id];
    }

}