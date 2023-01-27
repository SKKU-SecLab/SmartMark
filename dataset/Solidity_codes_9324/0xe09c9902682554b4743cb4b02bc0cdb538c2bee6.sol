
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}//UNLICENSED
pragma solidity >=0.8.0 <0.9.0;


interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

}

contract GCBankMeta {

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    struct MetaTransaction {
        uint256 nonce;
        address from;
    }

    mapping(address => uint256) public nonces;
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(bytes("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"));
    bytes32 internal constant META_TRANSACTION_TYPEHASH = keccak256(bytes("MetaTransaction(uint256 nonce,address from,address to,uint256 amount)"));
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(uint256 _chainId) {
        DOMAIN_SEPARATOR= keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes("GCBank")),
                keccak256(bytes("1")),
                _chainId,
                address(this)
        ));
    }
}

contract GCBank is Ownable, Pausable, GCBankMeta {


    address GcrAddress;

    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);

    constructor(address _tokenAddress, uint256 _chainId) GCBankMeta(_chainId) {
        GcrAddress = _tokenAddress;
    }

    function pauseContract() onlyOwner external {

        _pause();
    }

    function unpauseContract() onlyOwner external {

        _unpause();
    }

    function withdrawFunds(uint256 _amount) onlyOwner external {

        IERC20 GCR = IERC20(GcrAddress);
        GCR.transfer(owner(), _amount);
    }

    function withdrawPoints (
        uint256 _amount, address _receiverAddress, bytes32 r, bytes32 s, uint8 v
    ) whenNotPaused external {

        IERC20 GCR = IERC20(GcrAddress);
        address contractOwner = owner();
        uint256 previousNonce = nonces[contractOwner];

        require(GCR.balanceOf(address(this)) >= _amount, "Contract doesn't have enough GCR");

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(META_TRANSACTION_TYPEHASH, previousNonce, contractOwner, _receiverAddress, _amount))
            )
        );

        require(contractOwner == ecrecover(digest, v, r, s), "GCBank:invalid-signature");

        nonces[contractOwner] = previousNonce + 1;

        GCR.transfer(_receiverAddress, _amount);

        emit MoneySent(_receiverAddress, _amount);
    }


    function renounceOwnership () public pure override {
        revert("Can't renounceOwnership here"); //not possible with this smart contract
    }

}