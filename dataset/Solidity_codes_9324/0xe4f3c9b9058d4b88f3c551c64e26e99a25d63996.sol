



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



pragma solidity ^0.6.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
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
}



pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.6.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}



pragma solidity 0.6.8;

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

}



pragma solidity 0.6.8;



abstract contract ERC1155TokenReceiver is IERC1155TokenReceiver, ERC165 {

    bytes4 internal constant _ERC1155_RECEIVED = 0xf23a6e61;

    bytes4 internal constant _ERC1155_BATCH_RECEIVED = 0xbc197c81;

    bytes4 internal constant _ERC1155_REJECTED = 0xffffffff;

    constructor() internal {
        _registerInterface(type(IERC1155TokenReceiver).interfaceId);
    }
}



pragma solidity ^0.6.8;





contract NFTRepairCentre is ERC1155TokenReceiver, Ownable, Pausable {

    using SafeMath for uint256;

    event TokensToRepairAdded(uint256[] defectiveTokens, uint256[] replacementTokens);
    event RepairedSingle(uint256 defectiveToken, uint256 replacementToken);
    event RepairedBatch(uint256[] defectiveTokens, uint256[] replacementTokens);

    IDeltaTimeInventory inventoryContract;
    address tokensGraveyard;
    IREVV revvContract;
    uint256 revvCompensation;

    mapping(uint256 => uint256) repairList;

    constructor(
        address inventoryContract_,
        address tokensGraveyard_,
        address revvContract_,
        uint256 revvCompensation_
    ) public {
        require(
            inventoryContract_ != address(0) && tokensGraveyard_ != address(0) && revvContract_ != address(0),
            "RepairCentre: zero address"
        );
        inventoryContract = IDeltaTimeInventory(inventoryContract_);
        tokensGraveyard = tokensGraveyard_;
        revvContract = IREVV(revvContract_);
        revvCompensation = revvCompensation_;
    }


    function addTokensToRepair(uint256[] calldata defectiveTokens, uint256[] calldata replacementTokens)
        external
        onlyOwner
    {

        uint256 length = defectiveTokens.length;
        require(length != 0 && length == replacementTokens.length, "RepairCentre: wrong lengths");
        for (uint256 i = 0; i < length; ++i) {
            repairList[defectiveTokens[i]] = replacementTokens[i];
        }
        revvContract.transferFrom(msg.sender, address(this), revvCompensation.mul(length));
        emit TokensToRepairAdded(defectiveTokens, replacementTokens);
    }

    function renounceMinter() external onlyOwner {

        inventoryContract.renounceMinter();
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }


    function onERC1155Received(
        address, /*operator*/
        address from,
        uint256 defectiveToken,
        uint256, /*value*/
        bytes calldata /*data*/
    ) external virtual override whenNotPaused returns (bytes4) {

        require(msg.sender == address(inventoryContract), "RepairCentre: wrong inventory");

        uint256 replacementToken = repairList[defectiveToken];
        require(replacementToken != 0, "RepairCentre: token not defective");
        delete repairList[defectiveToken];

        inventoryContract.safeTransferFrom(address(this), tokensGraveyard, defectiveToken, 1, bytes(""));

        try inventoryContract.mintNonFungible(from, replacementToken, bytes32(""), true)  {} catch {
            inventoryContract.mintNonFungible(from, replacementToken, bytes32(""), false);
        }
        revvContract.transfer(from, revvCompensation);

        emit RepairedSingle(defectiveToken, replacementToken);

        return _ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address from,
        uint256[] calldata defectiveTokens,
        uint256[] calldata values,
        bytes calldata /*data*/
    ) external virtual override whenNotPaused returns (bytes4) {
        require(msg.sender == address(inventoryContract), "RepairCentre: wrong inventory");

        uint256 length = defectiveTokens.length;
        require(length != 0, "RepairCentre: empty array");

        address[] memory recipients = new address[](length);
        uint256[] memory replacementTokens = new uint256[](length);
        bytes32[] memory uris = new bytes32[](length);
        for (uint256 i = 0; i < length; ++i) {
            uint256 defectiveToken = defectiveTokens[i];
            uint256 replacementToken = repairList[defectiveToken];
            require(replacementToken != 0, "RepairCentre: token not defective");
            delete repairList[defectiveToken];
            recipients[i] = from;
            replacementTokens[i] = replacementToken;
        }

        inventoryContract.safeBatchTransferFrom(address(this), tokensGraveyard, defectiveTokens, values, bytes(""));

        try inventoryContract.batchMint(recipients, replacementTokens, uris, values, true)  {} catch {
            inventoryContract.batchMint(recipients, replacementTokens, uris, values, false);
        }

        revvContract.transfer(from, revvCompensation.mul(length));

        emit RepairedBatch(defectiveTokens, replacementTokens);

        return _ERC1155_BATCH_RECEIVED;
    }


    function containsDefectiveToken(uint256[] calldata tokens) external view returns(bool) {
        for (uint256 i = 0; i < tokens.length; ++i) {
            if (repairList[tokens[i]] != 0) {
                return true;
            }
        } 
        return false;
    }
}

interface IDeltaTimeInventory {

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;


    function batchMint(
        address[] calldata to,
        uint256[] calldata ids,
        bytes32[] calldata uris,
        uint256[] calldata values,
        bool safe
    ) external;


    function mintNonFungible(
        address to,
        uint256 tokenId,
        bytes32 byteUri,
        bool safe
    ) external;


    function renounceMinter() external;

}

interface IREVV {

    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}