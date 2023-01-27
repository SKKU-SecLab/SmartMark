



pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.6.2;


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


pragma solidity ^0.6.0;

interface ENSRegistryOwnerI {

    function owner(bytes32 node) external view returns (address);

}

interface ENSReverseRegistrarI {

    function setName(string calldata name) external returns (bytes32 node);

}


pragma solidity ^0.6.0;

interface CS2PropertiesI {


    enum AssetType {
        Honeybadger,
        Llama,
        Panda,
        Doge
    }

    enum Colors {
        Black,
        Green,
        Blue,
        Yellow,
        Red
    }

    function getType(uint256 tokenId) external view returns (AssetType);

    function getColor(uint256 tokenId) external view returns (Colors);


}


pragma solidity ^0.6.0;



interface AchievementsUpgradingI is IERC165 {


    function onCS2ColorChanged(uint256 tokenId, CS2PropertiesI.Colors previousColor, CS2PropertiesI.Colors newColor)
    external returns (bytes4);


}


pragma solidity ^0.6.0;


interface CollectionsI is IERC721 {

    event NewCollection(address indexed owner, address collectionAddress);

    function create(address _notificationContract,
                    string calldata _ensName,
                    string calldata _ensSubdomainName,
                    address _ensSubdomainRegistrarAddress,
                    address _ensReverseRegistrarAddress)
    external;


    function createFor(address payable _newOwner,
                       address _notificationContract,
                       string calldata _ensName,
                       string calldata _ensSubdomainName,
                       address _ensSubdomainRegistrarAddress,
                       address _ensReverseRegistrarAddress)
    external payable;


    function burn(uint256 tokenId) external;


    function exists(uint256 tokenId) external view returns (bool);


    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);


    function collectionAddress(uint256 tokenId) external view returns (address);


    function tokenIdForCollection(address collectionAddr) external view returns (uint256 tokenId);

}


pragma solidity ^0.6.0;









abstract contract CollectionIHelper {
    address public notificationContract;
}

contract CS2AchievementsHelper is ERC165, AchievementsUpgradingI {

    using SafeMath for uint256;

    bytes4 private constant _INTERFACE_ID_ACHIEVEMENTS_UPGRADING = 0x58cac597;

    address public tokenAssignmentControl;

    CollectionsI public collections;

    event TokenAssignmentControlTransferred(address indexed previousTokenAssignmentControl, address indexed newTokenAssignmentControl);

    constructor(address _collectionsAddress, address _tokenAssignmentControl)
    public
    {
        _registerInterface(_INTERFACE_ID_ACHIEVEMENTS_UPGRADING);
        collections = CollectionsI(_collectionsAddress);
        require(address(collections) != address(0x0), "You need to provide an actual Collections contract.");
        tokenAssignmentControl = _tokenAssignmentControl;
        require(tokenAssignmentControl != address(0), "tokenAssignmentControl cannot be the zero address.");
    }

    modifier onlyTokenAssignmentControl() {

        require(msg.sender == tokenAssignmentControl, "tokenAssignmentControl key required for this function.");
        _;
    }


    function transferTokenAssignmentControl(address _newTokenAssignmentControl)
    public
    onlyTokenAssignmentControl
    {

        require(_newTokenAssignmentControl != address(0), "tokenAssignmentControl cannot be the zero address.");
        emit TokenAssignmentControlTransferred(tokenAssignmentControl, _newTokenAssignmentControl);
        tokenAssignmentControl = _newTokenAssignmentControl;
    }


    function onCS2ColorChanged(uint256 tokenId, CS2PropertiesI.Colors previousColor, CS2PropertiesI.Colors newColor)
    external override
    returns (bytes4)
    {

        address owner = IERC721(msg.sender).ownerOf(tokenId);
        if (collections.exists(uint256(owner))) {
            address notificationAddr = CollectionIHelper(owner).notificationContract();
            if (notificationAddr != address(0)) {
                AchievementsUpgradingI(notificationAddr).onCS2ColorChanged(tokenId, previousColor, newColor);
            }
        }
        return this.onCS2ColorChanged.selector;
    }


    function registerReverseENS(address _reverseRegistrarAddress, string calldata _name)
    external
    onlyTokenAssignmentControl
    {

       require(_reverseRegistrarAddress != address(0), "need a valid reverse registrar");
       ENSReverseRegistrarI(_reverseRegistrarAddress).setName(_name);
    }


    function rescueToken(address _foreignToken, address _to)
    external
    onlyTokenAssignmentControl
    {

        IERC20 erc20Token = IERC20(_foreignToken);
        erc20Token.transfer(_to, erc20Token.balanceOf(address(this)));
    }

    function approveNFTrescue(IERC721 _foreignNFT, address _to)
    external
    onlyTokenAssignmentControl
    {

        _foreignNFT.setApprovalForAll(_to, true);
    }

}