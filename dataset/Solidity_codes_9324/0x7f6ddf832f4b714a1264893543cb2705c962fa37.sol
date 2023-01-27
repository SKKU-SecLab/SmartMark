
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

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

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// UNLICENSED
pragma solidity ^0.8.2;

interface FineCoreInterface {

    function getProjectAddress(uint id) external view returns (address);

    function getRandomness(uint256 id, uint256 seed) external view returns (uint256 randomnesss);

    function getProjectID(address project) external view returns (uint);

    function FINE_TREASURY() external returns (address payable);

    function platformPercentage() external returns (uint256);

    function platformRoyalty() external returns (uint256);

}// MIT
pragma solidity ^0.8.2;


interface FineNFTInterface {

    function mint(address to) external returns (uint);

    function mintBonus(address to, uint infiniteId) external returns (uint);

    function getArtistAddress() external view returns (address payable);

    function getAdditionalPayee() external view returns (address payable);

    function getAdditionalPayeePercentage() external view returns (uint256);

    function getTokenLimit() external view returns (uint256);

    function checkPool() external view returns (uint);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

}

interface BasicNFTInterface {

    function ownerOf(uint256 tokenId) external view returns (address);

    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

}

enum SalePhase {
  Owner,
  PreSale,
  PublicSale
}

contract FineShop is AccessControl {

    using SafeMath for uint256;

    FineCoreInterface fineCore;
    mapping(uint => address) public projectOwner;
    mapping(uint => uint) public projectPremints;
    mapping(uint => uint) public projectPrice;
    mapping(uint => address) public projectCurrencyAddress;
    mapping(uint => string) public projectCurrencySymbol;
    mapping(uint => uint) public projectBulkMintCount;
    mapping(uint => bool) public projectLive;
    mapping(uint256 => bool) public contractFilterProject;
    mapping(address => mapping (uint256 => uint256)) public projectMintCounter;
    mapping(uint256 => uint256) public projectMintLimit;
    mapping(uint256 => SalePhase) public projectPhase;
    mapping(uint256 => mapping (address => uint8) ) public projectAllowList;
    mapping(uint256 => bool ) public infinitesAIWOW;
    mapping(uint256 => mapping (uint256 => address) ) public projectGateTokens;
    mapping(uint256 => uint256) public projectGateTokensCount;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => bool)) ) public redeemed; // projectID, gateContractId, gateTokenId
    
    uint256[17] wowIds = [23,211,223,233,234,244,261,268,292,300,335,359,371,386,407,501,505];

    constructor(address _fineCoreAddresss) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        fineCore = FineCoreInterface(_fineCoreAddresss);
        for (uint256 i = 0; i < 17; i++) infinitesAIWOW[wowIds[i]] = true;
    }

    function stringComp(string memory str1, string memory str2) pure internal returns (bool) {

        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }


    function setOwner(uint _projectId, address newOwner) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(projectOwner[_projectId] != newOwner, "can't be same owner");
        require(newOwner != address(0x0), "owner can't be zero address");
        projectOwner[_projectId] = newOwner;
    }

    function goLive(uint _projectId) external onlyRole(DEFAULT_ADMIN_ROLE) {

        bool ready = projectPrice[_projectId] > 0 && !stringComp(projectCurrencySymbol[_projectId], "");
        require(ready, "project not ready for live");
        projectLive[_projectId] = true;
    }
  
    function setProjectMintLimit(uint256 _projectId, uint8 _limit) public onlyRole(DEFAULT_ADMIN_ROLE) {

        projectMintLimit[_projectId] = _limit;
    }
  
    function setProjectBulkMintCount(uint256 _projectId, uint8 _count) public onlyRole(DEFAULT_ADMIN_ROLE) {

        projectBulkMintCount[_projectId] = _count;
    }

    function toggleContractFilter(uint256 _projectId) public onlyRole(DEFAULT_ADMIN_ROLE) {

        contractFilterProject[_projectId]=!contractFilterProject[_projectId];
    }

    function projectInit(
        uint _projectId,
        address newOwner,
        bool contractFilter,
        uint256 _bulk,
        uint256 _limit
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(newOwner != address(0x0), "owner can't be zero address");
        projectOwner[_projectId] = newOwner;
        contractFilterProject[_projectId] = contractFilter;
        projectBulkMintCount[_projectId] = _bulk;
        projectMintLimit[_projectId] = _limit;
    }


    modifier onlyOwner(uint _projectId) {

      require(msg.sender == projectOwner[_projectId], "only owner");
      _;
    }

    modifier isLive(uint _projectId) {

      require(projectLive[_projectId], "Project not yet live");
      _;
    }

    modifier notLive(uint _projectId) {

      require(!projectLive[_projectId], "Can't call once live");
      _;
    }

    function setPrice(uint _projectId, uint price) external onlyOwner(_projectId) notLive(_projectId) {

        projectPrice[_projectId] = price;
    }

    function setPremints(uint _projectId, uint premints) external onlyOwner(_projectId) notLive(_projectId) {

        projectPremints[_projectId] = premints;
    }

    function setCurrencyToETH(uint _projectId) external onlyOwner(_projectId) notLive(_projectId) {

        projectCurrencySymbol[_projectId] = "ETH";
        projectCurrencyAddress[_projectId] = address(0x0);
    }

    function setCurrency(uint _projectId, string calldata _symbol, address _contract) external onlyOwner(_projectId) notLive(_projectId) {

        require(bytes(_symbol).length > 0, "Symbol must be provided");
        if (!stringComp(_symbol, "ETH"))
            require(_contract != address(0x0), "curency address cant be zero");
        projectCurrencySymbol[_projectId] = _symbol;
        projectCurrencyAddress[_projectId] = _contract;
    }

    function fullSetup(
            uint _projectId,
            string calldata _symbol,
            address _contract,
            uint256 _price,
            uint256 _premints
        ) external onlyOwner(_projectId) notLive(_projectId) {

            require(bytes(_symbol).length > 0, "Symbol must be provided");
            if (!stringComp(_symbol, "ETH"))
                require(_contract != address(0x0), "curency address cant be zero");
            projectCurrencySymbol[_projectId] = _symbol;
            projectCurrencyAddress[_projectId] = _contract;
            projectPrice[_projectId] = _price;
            projectPremints[_projectId] = _premints;
    }

    function setAllowList(uint _projectId, address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner(_projectId) {

        for (uint256 i = 0; i < addresses.length; i++) {
            projectAllowList[_projectId][addresses[i]] = numAllowedToMint;
        }
    }

    function setGateTokens(uint _projectId, address[] calldata addresses) external onlyOwner(_projectId) {

        projectGateTokensCount[_projectId] = addresses.length;
        for (uint256 i = 0; i < addresses.length; i++) {
            projectGateTokens[_projectId][i] = addresses[i];
        }
    }
    
    function setPhase(uint _projectId, SalePhase phase) external onlyOwner(_projectId) isLive(_projectId) {

        projectPhase[_projectId] = phase;
    }


    function handlePayment(uint _projectId, uint count) internal {

        uint price = projectPrice[_projectId].mul(count);
        if (!stringComp(projectCurrencySymbol[_projectId], "ETH")){
            require(msg.value==0, "this project accepts a different currency and cannot accept ETH");
            require(IERC20(projectCurrencyAddress[_projectId]).allowance(msg.sender, address(this)) >= price, "Insufficient Funds Approved for TX");
            require(IERC20(projectCurrencyAddress[_projectId]).balanceOf(msg.sender) >= price, "Insufficient balance.");
            _splitFundsERC20(_projectId, count);
        } else {
            require(msg.value >= price, "Must send minimum value to mint!");
            _splitFundsETH(_projectId, count);
        }
    }

    function _splitFundsETH(uint256 _projectId, uint count) internal {

        if (msg.value > 0) {
            uint256 pricePerTokenInWei = projectPrice[_projectId];
            uint salePrice = pricePerTokenInWei.mul(count);
            uint256 refund = msg.value.sub(salePrice);
            if (refund > 0) {
                payable(msg.sender).transfer(refund);
            }
            uint256 platformAmount = salePrice.mul(fineCore.platformPercentage()).div(10000);
            if (platformAmount > 0) {
                fineCore.FINE_TREASURY().transfer(platformAmount);
            }
            FineNFTInterface nftContract = FineNFTInterface(fineCore.getProjectAddress(_projectId));
            uint256 additionalPayeeAmount = salePrice.mul(nftContract.getAdditionalPayeePercentage()).div(10000);
            if (additionalPayeeAmount > 0) {
                nftContract.getAdditionalPayee().transfer(additionalPayeeAmount);
            }
            uint256 creatorFunds = salePrice.sub(platformAmount).sub(additionalPayeeAmount);
            if (creatorFunds > 0) {
                nftContract.getArtistAddress().transfer(creatorFunds);
            }
        }
    }

    function _splitFundsERC20(uint256 _projectId, uint count) internal {

        uint256 pricePerTokenInWei = projectPrice[_projectId];
        uint salePrice = pricePerTokenInWei.mul(count);
        uint256 platformAmount = salePrice.mul(fineCore.platformPercentage()).div(10000);
        if (platformAmount > 0) {
            IERC20(projectCurrencyAddress[_projectId]).transferFrom(msg.sender, fineCore.FINE_TREASURY(), platformAmount);
        }
        FineNFTInterface nftContract = FineNFTInterface(fineCore.getProjectAddress(_projectId));
        nftContract.getArtistAddress();
        uint256 additionalPayeeAmount = salePrice.mul(nftContract.getAdditionalPayeePercentage()).div(10000);
        if (additionalPayeeAmount > 0) {
            IERC20(projectCurrencyAddress[_projectId]).transferFrom(msg.sender, nftContract.getAdditionalPayee(), additionalPayeeAmount);
        }
        uint256 creatorFunds = salePrice.sub(platformAmount).sub(additionalPayeeAmount);
        if (creatorFunds > 0) {
            IERC20(projectCurrencyAddress[_projectId]).transferFrom(msg.sender, nftContract.getArtistAddress(), creatorFunds);
        }
    }


    function purchaseTo(uint _projectId, address to, uint count) internal isLive(_projectId) returns (string memory) {

        if (contractFilterProject[_projectId]) require(msg.sender == tx.origin, "No Contract Buys");
        FineNFTInterface nftContract = FineNFTInterface(fineCore.getProjectAddress(_projectId));
        require(nftContract.checkPool() > 0, "Sold out");
        require(nftContract.checkPool() >= count, "Count excedes available");

        if (projectPhase[_projectId] == SalePhase.Owner) {
            require(msg.sender == projectOwner[_projectId], "Only owner can mint now");
            require(count <= projectPremints[_projectId], "Excededs max premints");
            projectPremints[_projectId] -= count;
        } else {
            if (projectMintLimit[_projectId] > 0) {
                require(projectMintCounter[msg.sender][_projectId] < projectMintLimit[_projectId], "Reached minting limit");
                projectMintCounter[msg.sender][_projectId] += count;
            }
            if (projectPhase[_projectId] == SalePhase.PreSale) {
                require(count <= projectAllowList[_projectId][msg.sender], "Exceeds allowlisted count");
                projectAllowList[_projectId][msg.sender] -= uint8(count);
            } else if (projectPhase[_projectId] == SalePhase.PublicSale) {
                if (projectBulkMintCount[_projectId] > 0)
                    require(count <= projectBulkMintCount[_projectId], "Count excedes bulk mint limit");
            }
            handlePayment(_projectId, count);
        }
        string memory idList;
        for (uint i = 0; i < count; i++) {
            uint tokenID = nftContract.mint(to);
            if (i == 0) idList = string(abi.encodePacked(tokenID));
            else idList = string(abi.encodePacked(idList, ",", tokenID));
        }

        return idList; // returns a list of ids of all tokens minted
    }

    function mintGated(uint _projectId, address to, uint8 contractId, uint256 redeemId) public payable isLive(_projectId) returns (string memory) {

        if (contractFilterProject[_projectId]) require(msg.sender == tx.origin, "No Contract Buys");
        FineNFTInterface nftContract = FineNFTInterface(fineCore.getProjectAddress(_projectId));
        
        require(projectPhase[_projectId] != SalePhase.Owner, "Must redeem after owner mint");
        BasicNFTInterface allowToken = BasicNFTInterface(projectGateTokens[_projectId][contractId]);
        require(nftContract.checkPool() > 0, "Sold out");
        require(
            allowToken.ownerOf(redeemId) == msg.sender || allowToken.ownerOf(redeemId) == to,
            "Only token owner can redeem pass");
        require(!redeemed[_projectId][contractId][redeemId], "already redeemed for ID");
        redeemed[_projectId][contractId][redeemId] = true;
        uint tokenId = nftContract.mint(to);
        if (contractId == 0) nftContract.mintBonus(to, redeemId);
        if (contractId != 0 || !infinitesAIWOW[redeemId]) handlePayment(_projectId, 1);
        else if (msg.value > 0) payable(msg.sender).transfer(msg.value);

        return string(abi.encodePacked(tokenId)); // returns a list of ids of all tokens minted
    }

    function buy(uint _projectId, uint count) external payable returns (string memory) {

        return purchaseTo(_projectId, msg.sender, count);
    }

    function buyFor(uint _projectId, address to, uint count) external payable returns (string memory) {

        return purchaseTo(_projectId, to, count);
    }
}