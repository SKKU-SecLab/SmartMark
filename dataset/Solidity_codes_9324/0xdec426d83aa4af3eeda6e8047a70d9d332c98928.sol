
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}// GPL-3.0
pragma solidity ^0.8.4;


contract FlashEscrow {


    constructor(address target, bytes memory payload) {
        (bool success, ) = target.call(payload);
        require(success, "FlashEscrow: call_failed");

        selfdestruct(payable(target));
    }
}

abstract contract NFTEscrow is Initializable {
    address public nftAddress;

    function __NFTEscrow_init(address _nftAddress) internal initializer {
        nftAddress = _nftAddress;
    }

    function _encodeFlashEscrow(uint256 _idx)
        internal
        view
        returns (bytes memory)
    {
        return
            abi.encodePacked(
                type(FlashEscrow).creationCode,
                abi.encode(nftAddress, _encodeFlashEscrowPayload(_idx))
            );
    }

    function _encodeFlashEscrowPayload(uint256 _idx)
        internal
        view
        virtual
        returns (bytes memory);

    function _executeTransfer(address _owner, uint256 _idx) internal {
        (bytes32 salt, ) = precompute(_owner, _idx);
        new FlashEscrow{salt: salt}(
            nftAddress,
            _encodeFlashEscrowPayload(_idx)
        );
    }

    function precompute(address _owner, uint256 _idx)
        public
        view
        returns (bytes32 salt, address predictedAddress)
    {
        require(
            _owner != address(this) && _owner != address(0),
            "NFTEscrow: invalid_owner"
        );

        salt = sha256(abi.encodePacked(_owner));

        bytes memory bytecode = _encodeFlashEscrow(_idx);

        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );

        predictedAddress = address(uint160(uint256(hash)));
        return (salt, predictedAddress);
    }

    function rescueNFT(uint256 _idx) external virtual;

    uint256[50] private __gap;
}// GPL-3.0
pragma solidity ^0.8.4;

interface IEtherRocks {

    function getRockInfo(uint256 rockNumber)
        external
        view
        returns (
            address,
            bool,
            uint256,
            uint256
        );


    function giftRock(uint256 rockNumber, address receiver) external;


    function dontSellRock(uint256 rockNumber) external;

}// GPL-3.0
pragma solidity ^0.8.4;



contract EtherRocksHelper is NFTEscrow, OwnableUpgradeable {


    function initialize(address rocksAddress) external initializer {

        __NFTEscrow_init(rocksAddress);
        __Ownable_init();
    }

    function ownerOf(uint256 _idx) external view returns (address) {

        (address account,,,) = IEtherRocks(nftAddress).getRockInfo(_idx);

        return account == address(this) ? owner() : account;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _idx
    ) external onlyOwner {

        _transferFrom(_from, _to, _idx);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _idx
    ) external onlyOwner {

        _transferFrom(_from, _to, _idx);
    }

    function rescueNFT(uint256 _idx) external override {

        IEtherRocks rocks = IEtherRocks(nftAddress);
        (, address predictedAddress) = precompute(msg.sender, _idx);
        (address owner,,,) = rocks.getRockInfo(_idx);
        require(owner == predictedAddress, "NOT_OWNER");
        assert(owner != address(this)); //this should never happen

        _executeTransfer(msg.sender, _idx);
        rocks.giftRock(_idx, msg.sender);
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _idx
    ) internal {

        IEtherRocks rocks = IEtherRocks(nftAddress);

        (address account,,,) = rocks.getRockInfo(_idx);

        if (account != address(this)) {
            _executeTransfer(_from, _idx);
        }

        (address newOwner,,,) = rocks.getRockInfo(_idx);

        assert(
            newOwner == address(this) //this should never be false
        );

        rocks.dontSellRock(_idx);

        if (_to != owner()) rocks.giftRock(_idx, _to);
    }

    function renounceOwnership() public view override onlyOwner {

        revert("Cannot renounce ownership");
    }

    function _encodeFlashEscrowPayload(uint256 _idx)
        internal
        view
        override
        returns (bytes memory)
    {

        return
            abi.encodeWithSignature(
                "giftRock(uint256,address)",
                _idx,
                address(this)
            );
    }
}