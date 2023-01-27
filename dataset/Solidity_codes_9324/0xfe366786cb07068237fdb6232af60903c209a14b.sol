



pragma solidity ^0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.7.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}


pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}


pragma solidity ^0.7.0;

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


pragma solidity ^0.7.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}


pragma solidity ^0.7.0;


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}


pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity 0.7.5;



contract Ownable is Context {

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

    modifier onlyOwner() virtual {

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


pragma solidity 0.7.5;


interface IDecentralandLandRegistry {

    function setUpdateOperator(uint256 assetId, address operator) external;

}


pragma solidity 0.7.5;
pragma abicoder v2;


interface IVault {

    function lockVault() external;


    function unlockVault() external;


    function safeAddAsset(address[] calldata tokenAddresses, uint256[] calldata tokenIds,
            string[] calldata categories) external;


    function safeTransferAsset(uint256[] calldata assetIds) external;


    function escapeHatchERC721(address tokenAddress, uint256 tokenId) external;


    function setDecentralandOperator(address registryAddress, address operatorAddress,
        uint256 assetId) external;


    function transferOwnership(address newOwner) external;


    function totalAssetSlots() external view returns (uint256);


    function vaultOwner() external view returns (address);


    function onERC721Received(address, uint256, bytes memory) external pure returns (bytes4);


}


pragma solidity 0.7.5;









contract SimpleVault is IVault, Ownable, ERC721Holder {

    using SafeMath for uint256;
    using Address for address;

    struct Asset {
        string category;
        address tokenAddress;
        uint256 tokenId;
    }

    bool public locked;
    Asset[] public assets;
    uint256 public totalAssets;
    bytes4 public constant ERC721_RECEIVED_OLD = 0xf0b9e5ba;

    modifier onlyOwner() override virtual {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function lockVault() external override onlyOwner {

        toggleLock(true);
    }

    function unlockVault() external override onlyOwner {

        toggleLock(false);
    }

    function safeAddAsset(address[] calldata tokenAddresses, uint256[] calldata tokenIds, string[] calldata categories)
    external override onlyOwner {

        require(!locked, "{safeAddAsset} : locked");
        require(tokenAddresses.length > 0, "{safeAddAsset} : tokenAddresses cannot be empty");
        require(tokenAddresses.length == tokenIds.length,
            "{safeAddAsset} : tokenAddresses and tokenIds lengths are not equal");
        require(tokenAddresses.length == categories.length,
            "{safeAddAsset} : tokenAddresses and categories lengths are not equal");
        for (uint i = 0; i < tokenAddresses.length; i++) {
            require(tokenAddresses[i].isContract(), "{safeAddAsset} : invalid tokenAddress");
            require(IERC721(tokenAddresses[i]).ownerOf(tokenIds[i]) == owner(), "{safeAddAsset} : invalid tokenId");
        }
        for (uint i = 0; i < tokenAddresses.length; i++) {
            totalAssets = totalAssets.add(1);
            IERC721(tokenAddresses[i]).safeTransferFrom(owner(), address(this), tokenIds[i]);
            assets.push(Asset({
                category: categories[i],
                tokenAddress: tokenAddresses[i],
                tokenId: tokenIds[i]
            }));
        }
    }

    function safeTransferAsset(uint256[] calldata assetIds) external override onlyOwner {

        require(!locked, "{safeTransferAsset} : locked");
        require(assetIds.length > 0, "{safeTransferAsset} : assetIds cannot be empty");
        for (uint i = 0; i < assetIds.length; i++) {
            require(assets.length > assetIds[i], "{safeTransferAsset} : 400, Invalid assetId");
            require(assets[assetIds[i]].tokenAddress != address(0),
                "{safeTransferAsset} : 404, asset does not exist");
        }
        for (uint i = 0; i < assetIds.length; i++) {
            totalAssets = totalAssets.sub(1);
            IERC721(assets[assetIds[i]].tokenAddress).safeTransferFrom(address(this),
                owner(), assets[assetIds[i]].tokenId);
            delete assets[assetIds[i]];
        }
    }

    function escapeHatchERC721(address tokenAddress, uint256 tokenId) external override onlyOwner {

        require(tokenAddress != address(0), "{escapeHatchERC721} : invalid tokenAddress");
        require(IERC721(tokenAddress).ownerOf(tokenId) == address(this), "{escapeHatchERC721} : invalid tokenId");
        IERC721(tokenAddress).safeTransferFrom(address(this), owner(), tokenId);
    }

    function setDecentralandOperator(address registryAddress, address operatorAddress, uint256 assetId)
    external override onlyOwner {

        require(registryAddress != address(0), "{setDecentralandOperator} : invalid registryAddress");
        require(operatorAddress != address(0), "{setDecentralandOperator} : invalid operatorAddress");
        require(assets.length > assetId, "{setDecentralandOperator} : 400, Invalid assetId");
        IDecentralandLandRegistry(registryAddress).setUpdateOperator(assets[assetId].tokenId, operatorAddress);
    }

    function totalAssetSlots() external view override returns (uint256) {

        return assets.length;
    }

    function vaultOwner() public view override returns (address) {

        return owner();
    }

    function transferOwnership(address newOwner) public override(IVault, Ownable) virtual onlyOwner {

        require(newOwner != address(0), "{transferOwnership} : invalid new owner");
        super.transferOwnership(newOwner);
    }

    function onERC721Received(address, uint256, bytes memory) public pure override returns (bytes4) {

        return ERC721_RECEIVED_OLD;
    }

    function toggleLock(bool value) internal {

        require(locked == !value, "{toggleLock} : incorrect value");
        locked = value;
    }
}


pragma solidity 0.7.5;





contract SimpleVault2 is SimpleVault {


    using Address for address;

    IERC721 public vaultKey;

    constructor(address vaultKeyAddress) {
        require(vaultKeyAddress.isContract(), "{SimpleVault2} : invalid vaultKeyAddress");
        vaultKey = IERC721(vaultKeyAddress);
    }

    function owner() public view override returns (address) {

        return vaultKey.ownerOf(1);
    }

    modifier onlyOwner() override {

        require(vaultKey.ownerOf(1) == _msgSender(),
            "{SimpleVault2}: caller is not the owner of vault key");
        _;
    }

    function transferOwnership(address newOwner) public override {

        require(newOwner != address(0), "{transferOwnership} : invalid new owner");
        revert();
    }

}