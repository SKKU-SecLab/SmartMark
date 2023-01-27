
pragma solidity >=0.7.6 <0.8.0;

interface IERC1155TokenReceiver {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity >=0.7.6 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.7.6 <0.8.0;


abstract contract ERC1155TokenReceiver is IERC1155TokenReceiver, IERC165 {
    bytes4 private constant _ERC165_INTERFACE_ID = type(IERC165).interfaceId;
    bytes4 private constant _ERC1155_TOKEN_RECEIVER_INTERFACE_ID = type(IERC1155TokenReceiver).interfaceId;

    bytes4 internal constant _ERC1155_RECEIVED = 0xf23a6e61;

    bytes4 internal constant _ERC1155_BATCH_RECEIVED = 0xbc197c81;

    bytes4 internal constant _ERC1155_REJECTED = 0xffffffff;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == _ERC165_INTERFACE_ID || interfaceId == _ERC1155_TOKEN_RECEIVER_INTERFACE_ID;
    }
}// MIT

pragma solidity >=0.7.6 <0.8.0;

interface IERC1155InventoryBurnable {

    function burnFrom(
        address from,
        uint256 id,
        uint256 value
    ) external;


    function batchBurnFrom(
        address from,
        uint256[] calldata ids,
        uint256[] calldata values
    ) external;

}// MIT

pragma solidity >=0.7.6 <0.8.0;

abstract contract ManagedIdentity {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        return msg.data;
    }
}// MIT

pragma solidity >=0.7.6 <0.8.0;

interface IERC173 {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;

}// MIT

pragma solidity >=0.7.6 <0.8.0;


abstract contract Ownable is ManagedIdentity, IERC173 {
    address internal _owner;

    constructor(address owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    function owner() public view virtual override returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public virtual override {
        _requireOwnership(_msgSender());
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function _requireOwnership(address account) internal virtual {
        require(account == this.owner(), "Ownable: not the owner");
    }
}// MIT

pragma solidity >=0.7.6 <0.8.0;


abstract contract Recoverable is ManagedIdentity, Ownable {
    using ERC20Wrapper for IWrappedERC20;

    function recoverERC20s(
        address[] calldata accounts,
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external virtual {
        _requireOwnership(_msgSender());
        uint256 length = accounts.length;
        require(length == tokens.length && length == amounts.length, "Recov: inconsistent arrays");
        for (uint256 i = 0; i != length; ++i) {
            IWrappedERC20(tokens[i]).wrappedTransfer(accounts[i], amounts[i]);
        }
    }

    function recoverERC721s(
        address[] calldata accounts,
        address[] calldata contracts,
        uint256[] calldata tokenIds
    ) external virtual {
        _requireOwnership(_msgSender());
        uint256 length = accounts.length;
        require(length == contracts.length && length == tokenIds.length, "Recov: inconsistent arrays");
        for (uint256 i = 0; i != length; ++i) {
            IRecoverableERC721(contracts[i]).transferFrom(address(this), accounts[i], tokenIds[i]);
        }
    }
}

interface IRecoverableERC721 {

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}// MIT

pragma solidity >=0.7.6 <0.8.0;


abstract contract Pausable is ManagedIdentity {
    event Paused(address account);

    event Unpaused(address account);

    bool public paused;

    constructor(bool paused_) {
        paused = paused_;
    }

    function _requireNotPaused() internal view {
        require(!paused, "Pausable: paused");
    }

    function _requirePaused() internal view {
        require(paused, "Pausable: not paused");
    }

    function _pause() internal virtual {
        _requireNotPaused();
        paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual {
        _requirePaused();
        paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.7.6 <0.8.0;



contract DoseVoucherRedeemer is Recoverable, Pausable, ERC1155TokenReceiver{

    
    using ERC20Wrapper for IWrappedERC20;
    using SafeMath for uint256;

    IERC1155InventoryBurnable public immutable vouchersContract;
    IWrappedERC20 public immutable tokenContract;
    address public tokenHolder;

    mapping (uint256 => uint256) private _voucherTokenAmount;

    constructor(
        IERC1155InventoryBurnable _vouchersContract,
        IWrappedERC20 _tokenContract,
        address _tokenHolder
    ) Ownable(msg.sender) Pausable(true){
        vouchersContract = _vouchersContract;
        tokenContract = _tokenContract;
        tokenHolder = _tokenHolder;
    }

    function setVoucherValues(uint256[] memory tokenIds, uint256[] memory amounts) external virtual{

        _requireOwnership(_msgSender());
        require(tokenIds.length == amounts.length, "DoseVoucherRedeemer: invalid length of array");
        for(uint256 i; i < tokenIds.length; ++i){
            uint256 amount = amounts[i];
            require(amount > 0, "DoseVoucherRedeemer: invalid amount");
            _voucherTokenAmount[tokenIds[i]] = amount;
        }
    }

    function getVoucherValue(uint256 tokenId) external view virtual returns (uint256){

        return _voucherTokenAmount[tokenId];
    }

    function _voucherValue(uint256 tokenId) internal view virtual returns (uint256) {

        uint256 tokenValue = _voucherTokenAmount[tokenId];
        require(tokenValue > 0, "DoseVoucherRedeemer: invalid voucher");
        return tokenValue;
    }

    function setTokenHolder(address _tokenHolder) external virtual {

        _requireOwnership(_msgSender());
        tokenHolder = _tokenHolder;
    }

    function pause() public{

        _requireOwnership(_msgSender());
        _pause();
    }

    function unpause() public{

        _requireOwnership(_msgSender());
        _unpause();
    }

    function onERC1155Received(
        address, /*operator*/
        address from,
        uint256 id,
        uint256 value,
        bytes calldata /*data*/
    ) external virtual override returns (bytes4) {

        _requireNotPaused();
        require(msg.sender == address(vouchersContract), "DoseVoucherRedeemer: wrong sender");
        vouchersContract.burnFrom(address(this), id, value);
        uint256 tokenAmount = _voucherValue(id).mul(value);
        tokenContract.wrappedTransferFrom(tokenHolder, from, tokenAmount);
        return _ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata /*data*/
    ) external virtual override returns (bytes4) {

        _requireNotPaused();
        require(msg.sender == address(vouchersContract), "DoseVoucherRedeemer: wrong sender");
        vouchersContract.batchBurnFrom(address(this), ids, values);
        uint256 tokenAmount;
        for (uint256 i; i != ids.length; ++i) {
            uint256 id = ids[i];
            tokenAmount = tokenAmount.add(_voucherValue(id).mul(values[i]));
        }
        tokenContract.wrappedTransferFrom(tokenHolder, from, tokenAmount);
        return _ERC1155_BATCH_RECEIVED;
    }
}// MIT


pragma solidity >=0.7.6 <0.8.0;

library AddressIsContract {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}// MIT

pragma solidity >=0.7.6 <0.8.0;


library ERC20Wrapper {

    using AddressIsContract for address;

    function wrappedTransfer(
        IWrappedERC20 token,
        address to,
        uint256 value
    ) internal {

        _callWithOptionalReturnData(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function wrappedTransferFrom(
        IWrappedERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callWithOptionalReturnData(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function wrappedApprove(
        IWrappedERC20 token,
        address spender,
        uint256 value
    ) internal {

        _callWithOptionalReturnData(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callWithOptionalReturnData(IWrappedERC20 token, bytes memory callData) internal {

        address target = address(token);
        require(target.isContract(), "ERC20Wrapper: non-contract");

        (bool success, bytes memory data) = target.call(callData);
        if (success) {
            if (data.length != 0) {
                require(abi.decode(data, (bool)), "ERC20Wrapper: operation failed");
            }
        } else {
            if (data.length == 0) {
                revert("ERC20Wrapper: operation failed");
            }

            assembly {
                let size := mload(data)
                revert(add(32, data), size)
            }
        }
    }
}

interface IWrappedERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);

}