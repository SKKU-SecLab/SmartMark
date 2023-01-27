
pragma solidity ^0.8.0;





abstract contract Ownable {
    address public owner; 
    constructor() { owner = msg.sender; }
    modifier onlyOwner { require(owner == msg.sender, "Not Owner!"); _; }
    function transferOwnership(address new_) external onlyOwner { owner = new_; }
}

interface IERC20 {

    function owner() external view returns (address);

    function balanceOf(address address_) external view returns (uint256);

    function transfer(address to_, uint256 amount_) external returns (bool);

    function transferFrom(address from_, address to_, uint256 amount_) external;

}

interface IOwnable {

    function owner() external view returns (address);

}

interface IPriceController {

    function getPriceOfItem(address contract_, uint256 index_) external view
    returns (uint256);

}

interface ITokenController {

    function getTokenNameOfItem(address contract_, uint256 index_) external view
    returns (string memory);

    function getTokenImageOfItem(address contract_, uint256 index_) external view
    returns (string memory);

    function getTokenOfItem(address contract_, uint256 index_) external view
    returns (address);

}

contract MartianMarketWL is Ownable {


    event TreasuryManaged(address indexed contract_, address indexed operator_,
        address treasury_);
    event TokenManaged(address indexed contract_, address indexed operator_,
        address token_);

    event OperatorManaged(address indexed contract_, address operator_, bool bool_);
    event MarketAdminManaged(address indexed contract_, address admin_, bool bool_);

    event GovernorUnstuckOwner(address indexed contract_, address indexed operator_,
        address unstuckOwner_);

    event WLVendingItemAdded(address indexed contract_, address indexed operator_,
        WLVendingItem item_);
    event WLVendingItemModified(address indexed contract_, address indexed operator_, 
        WLVendingItem before_, WLVendingItem after_);
    event WLVendingItemRemoved(address indexed contract_, address indexed operator_,
        WLVendingItem item_);
    event WLVendingItemPurchased(address indexed contract_, address indexed purchaser_, 
        uint256 index_, WLVendingObject object_);
    event WLVendingItemGifted(address indexed contract_, address indexed gifted_,
        uint256 index_, WLVendingObject object_);

    event ContractRegistered(address indexed contract_, address registerer_,
        uint256 registrationPrice_);
    event ContractAdministered(address indexed contract_, address registerer_,
        bool bool_);

    event ProjectInfoPushed(address indexed contract_, address registerer_,
        string projectName_, string tokenImage_);

    IERC20 public MES = 
        IERC20(0x3C2Eb40D25a4b2B5A068a959a40d57D63Dc98B95);
    function O_setMES(address address_) external onlyOwner {

        MES = IERC20(address_);
    } // good

    ITokenController public TokenController = 
        ITokenController(0x3C2Eb40D25a4b2B5A068a959a40d57D63Dc98B95);
    function O_setTokenController(address address_) external onlyOwner {

        TokenController = ITokenController(address_);
    } // good

    IPriceController public PriceController = 
        IPriceController(0x3C2Eb40D25a4b2B5A068a959a40d57D63Dc98B95);
    function O_setPriceController(address address_) external onlyOwner {

        PriceController = IPriceController(address_);
    } // good

    address public superGovernorAddress;
    address public governorAddress;
    address public registrationCollector;
    
    constructor() {
        superGovernorAddress = msg.sender;
        governorAddress = msg.sender;
        registrationCollector = address(this);
    } 

    function O_setSuperGovernorAddress(address superGovernor_) external onlyOwner {

        require(superGovernorAddress != address(0),
            "Super Governor Access has been renounced");

        superGovernorAddress = superGovernor_;
    } 
    modifier onlySuperGovernor {

        require(msg.sender == superGovernorAddress,
            "You are not the contract super governor!");
        _;
    } 
    function O_setGovernorAddress(address governor_) external onlyOwner {

        governorAddress = governor_;
    }
    modifier onlyGovernor {

        require(msg.sender == governorAddress,
            "You are not the contract governor!");
        _;
    }

    mapping(address => address) contractToUnstuckOwner;

    function SG_SetContractToVending(address contract_, bool bool_) external
    onlySuperGovernor {

        require(contractToEnabled[contract_] != bool_,
            "Contract Already Set as Boolean!");

        contractToEnabled[contract_] = bool_;
        
        bool_ ? _addContractToEnum(contract_) : _removeContractFromEnum(contract_);
        
        emit ContractAdministered(contract_, msg.sender, bool_);
    }
    function SG_SetContractToProjectInfo(address contract_, string calldata 
    projectName_, string calldata tokenName_, string calldata tokenImage_) 
    external onlySuperGovernor {

        
        contractToProjectInfo[contract_] = ProjectInfo(
            projectName_, 
            tokenName_,
            tokenImage_
        );
        
        emit ProjectInfoPushed(contract_, msg.sender, projectName_, tokenImage_);
    }
    function SG_SetStuckOwner(address contract_, address unstuckOwner_) 
    external onlySuperGovernor {



        require(!contractToMESRegistry[contract_],
            "Ownership has been proven through registration.");

        require(contractToWLVendingItems[contract_].length == 0,
            "Ownership has been proven.");
            
        contractToUnstuckOwner[contract_] = unstuckOwner_;


        emit GovernorUnstuckOwner(contract_, msg.sender, unstuckOwner_);
    }
    
    uint256 public registrationPrice = 2000 ether; // 2000 $MES
    function G_setRegistrationPrice(uint256 price_) external onlyGovernor {

        registrationPrice = price_;
    }
    function G_setRegistrationCollector(address collector_) external onlyGovernor {

        registrationCollector = collector_;
    }
    function G_withdrawMESfromContract(address receiver_) external onlyGovernor {

        MES.transfer(receiver_, MES.balanceOf(address(this)));
    }

    mapping(address => bool) public contractToEnabled;

    address[] public enabledContracts;
    mapping(address => uint256) public enabledContractsIndex;

    function getAllEnabledContracts() external view returns (address[] memory) {

        return enabledContracts;
    }
    function _addContractToEnum(address contract_) internal {

        enabledContractsIndex[contract_] = enabledContracts.length;
        enabledContracts.push(contract_);
    }
    function _removeContractFromEnum(address contract_) internal {

        uint256 _lastIndex = enabledContracts.length - 1;
        uint256 _currentIndex = enabledContractsIndex[contract_];

        if (_currentIndex != _lastIndex) {
            address _lastAddress = enabledContracts[_lastIndex];
            enabledContracts[_currentIndex] = _lastAddress;
        }

        enabledContracts.pop();
        delete enabledContractsIndex[contract_];
    }

    mapping(address => bool) public contractToMESRegistry;

    function registerContractToVending(address contract_) external {

        require(msg.sender == IOwnable(contract_).owner(),
            "You are not the Contract Owner!");
        require(!contractToEnabled[contract_],
            "Your contract has already been registered!");
        require(MES.balanceOf(msg.sender) >= registrationPrice,
            "You don't have enough $MES!");
        
        MES.transferFrom(msg.sender, registrationCollector, registrationPrice);
        
        contractToEnabled[contract_] = true;
        contractToMESRegistry[contract_] = true;

        _addContractToEnum(contract_);
        
        emit ContractRegistered(contract_, msg.sender, registrationPrice);
    }

    function contractOwner(address contract_) public view returns (address) { 

        return contractToUnstuckOwner[contract_] != address(0) ?
            contractToUnstuckOwner[contract_] : IOwnable(contract_).owner();
    }
    modifier onlyContractOwnerEnabled (address contract_) {

        require(msg.sender == contractOwner(contract_),
            "You are not the Contract Owner!");
        require(contractToEnabled[contract_],
            "Please register your Contract first!");
        _;
    }
    modifier onlyAuthorized (address contract_, address operator_) {

        require(contractToControllersApproved[contract_][operator_]
            || msg.sender == contractOwner(contract_),
            "You are not Authorized for this Contract!");
        require(contractToEnabled[contract_],
            "Contract is not enabled!");
        _;
    }

    function isContractOwner(address contract_, address sender_) public 
    view returns (bool) {

        return contractOwner(contract_) == sender_;    
    }
    function isAuthorized(address contract_, address operator_) public
    view returns (bool) {

        if (contractToControllersApproved[contract_][operator_]) return true;
        else return contractOwner(contract_) == operator_;
    }

    struct ProjectInfo {
        string projectName;
        string tokenName;
        string tokenImageUri;
    }
    
    mapping(address => ProjectInfo) public contractToProjectInfo;
    
    function registerProjectInfo(address contract_, string calldata projectName_,
    string calldata tokenName_, string calldata tokenImage_) 
    external onlyContractOwnerEnabled(contract_) {

    
        contractToProjectInfo[contract_] = ProjectInfo(
            projectName_, 
            tokenName_,
            tokenImage_
        );
    
        emit ProjectInfoPushed(contract_, msg.sender, projectName_, tokenImage_);
    }

    mapping(address => mapping(address => bool)) public contractToControllersApproved;
    
    function manageController(address contract_, address operator_, bool bool_) 
    external onlyContractOwnerEnabled(contract_) {


        contractToControllersApproved[contract_][operator_] = bool_;
        
        emit OperatorManaged(contract_, operator_, bool_);
    }

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => address) public contractToTreasuryAddress;
    
    function getTreasury(address contract_) public view returns (address) {

        return contractToTreasuryAddress[contract_] != address(0) ? 
            contractToTreasuryAddress[contract_] : burnAddress; 
    }
    function setTreasuryAddress(address contract_, address treasury_) external 
    onlyContractOwnerEnabled(contract_) {


        contractToTreasuryAddress[contract_] = treasury_;

        emit TreasuryManaged(contract_, msg.sender, treasury_);
    }

    struct WLVendingItem {
        string title; // for metadata uri, set title to metadata uri instead
        string imageUri;
        string projectUri;
        string description;

        uint32 amountAvailable;
        uint32 amountPurchased;

        uint32 startTime;
        uint32 endTime;
        
        uint256 price;
    }

    mapping(address => WLVendingItem[]) public contractToWLVendingItems;
    
    mapping(address => mapping(uint256 => address[])) public contractToWLPurchasers;
    mapping(address => mapping(uint256 => mapping(address => bool))) public 
        contractToWLPurchased;

    function addWLVendingItem(address contract_, WLVendingItem memory WLVendingItem_)
    external onlyAuthorized(contract_, msg.sender) {

        require(bytes(WLVendingItem_.title).length > 0,
            "You must specify a Title!");
        require(uint256(WLVendingItem_.endTime) > block.timestamp,
            "Already expired timestamp!");
        require(WLVendingItem_.endTime > WLVendingItem_.startTime,
            "endTime > startTime!");
        
        WLVendingItem_.amountPurchased = 0;

        contractToWLVendingItems[contract_].push(WLVendingItem_);
        
        emit WLVendingItemAdded(contract_, msg.sender, WLVendingItem_);
    }

    function modifyWLVendingItem(address contract_, uint256 index_,
    WLVendingItem memory WLVendingItem_) external 
    onlyAuthorized(contract_, msg.sender) {

        WLVendingItem memory _item = contractToWLVendingItems[contract_][index_];

        require(bytes(_item.title).length > 0,
            "This WLVendingItem does not exist!");
        require(bytes(WLVendingItem_.title).length > 0,
            "Title must not be empty!");
        
        require(WLVendingItem_.amountAvailable >= _item.amountPurchased,
            "Amount Available must be >= Amount Purchased!");
        
        contractToWLVendingItems[contract_][index_] = WLVendingItem_;
        
        emit WLVendingItemModified(contract_, msg.sender, _item, WLVendingItem_);
    }

    function deleteMostRecentWLVendingItem(address contract_) external
    onlyAuthorized(contract_, msg.sender) {

        uint256 _lastIndex = contractToWLVendingItems[contract_].length - 1;

        WLVendingItem memory _item = contractToWLVendingItems[contract_][_lastIndex];

        require(_item.amountPurchased == 0,
            "Cannot delete item with already bought goods!");
        
        contractToWLVendingItems[contract_].pop();
        emit WLVendingItemRemoved(contract_, msg.sender, _item);
    }

    function purchaseWLVendingItem(address contract_, uint256 index_) external {

        
        WLVendingObject memory _object = getWLVendingObject(contract_, index_);

        require(bytes(_object.title).length > 0,
            "This WLVendingObject does not exist!");
        require(_object.amountAvailable > _object.amountPurchased,
            "No more WL remaining!");
        require(_object.startTime <= block.timestamp,
            "Not started yet!");
        require(_object.endTime >= block.timestamp,
            "Past deadline!");
        require(!contractToWLPurchased[contract_][index_][msg.sender], 
            "Already purchased!");
        require(_object.price != 0,
            "Item does not have a set price!");
        require(IERC20(contract_).balanceOf(msg.sender) >= _object.price,
            "Not enough tokens!");

        IERC20( _object.tokenAddress ) // aggregated thru TokenController
        .transferFrom(msg.sender, getTreasury(contract_), _object.price);
        
        contractToWLPurchased[contract_][index_][msg.sender] = true;
        contractToWLPurchasers[contract_][index_].push(msg.sender);

        contractToWLVendingItems[contract_][index_].amountPurchased++;

        emit WLVendingItemPurchased(contract_, msg.sender, index_, _object);
    }

    mapping(address => mapping(address => bool)) public contractToMarketAdminsApproved;

    function manageMarketAdmin(address contract_, address operator_, bool bool_) 
    external onlyContractOwnerEnabled(contract_) {


        contractToMarketAdminsApproved[contract_][operator_] = bool_;
        
        emit MarketAdminManaged(contract_, operator_, bool_);
    }

    modifier onlyMarketAdmin (address contract_, address operator_) {

        require(contractToMarketAdminsApproved[contract_][operator_]
            || msg.sender == contractOwner(contract_),
            "You are not a Market Admin!");
        require(contractToEnabled[contract_],
            "Contract is not enabled!");
        _;
    }

    function giftPurchaserAsMarketAdmin(address contract_, uint256 index_,
    address giftedAddress_) external onlyMarketAdmin(contract_, msg.sender) {


        WLVendingObject memory _object = getWLVendingObject(contract_, index_);

        require(bytes(_object.title).length > 0,
            "This WLVendingObject does not exist!");
        require(_object.amountAvailable > _object.amountPurchased,
            "No more WL remaining!");
        require(!contractToWLPurchased[contract_][index_][giftedAddress_],
            "Already added!");

        contractToWLPurchased[contract_][index_][giftedAddress_] = true;
        contractToWLPurchasers[contract_][index_].push(giftedAddress_);

        contractToWLVendingItems[contract_][index_].amountPurchased++;

        emit WLVendingItemGifted(contract_, giftedAddress_, index_, _object);
    }

    function getFixedPriceOfItem(address contract_, uint256 index_) external 
    view returns (uint256) {

        return contractToWLVendingItems[contract_][index_].price;
    }
    function getDefaultTokenOfContract(address contract_) external 
    pure returns (address) {

        return contract_;
    }
    function getDefaultTokenNameOfContract(address contract_) external
    view returns (string memory) {

        return contractToProjectInfo[contract_].tokenName;
    }
    function getDefaultTokenImageOfContract(address contract_) external 
    view returns (string memory) {

        return contractToProjectInfo[contract_].tokenImageUri;
    }


    struct WLVendingObject {
        string title;
        string imageUri;
        string projectUri;
        string description;
        
        uint32 amountAvailable;
        uint32 amountPurchased;
        uint32 startTime;
        uint32 endTime;

        string tokenName;
        string tokenImageUri;
        address tokenAddress;

        uint256 price;
    }

    function getWLPurchasersOf(address contract_, uint256 index_) public view 
    returns (address[] memory) { 

        return contractToWLPurchasers[contract_][index_];
    }

    function getWLVendingItemsLength(address contract_) public view 
    returns (uint256) {

        return contractToWLVendingItems[contract_].length;
    }

    function raw_getWLVendingItemsAll(address contract_) public view 
    returns (WLVendingItem[] memory) {

        return contractToWLVendingItems[contract_];
    }
    function raw_getWLVendingItemsPaginated(address contract_, uint256 start_, 
    uint256 end_) public view returns (WLVendingItem[] memory) {

        uint256 _arrayLength = end_ - start_ + 1;
        WLVendingItem[] memory _items = new WLVendingItem[] (_arrayLength);
        uint256 _index;

        for (uint256 i = 0; i < _arrayLength; i++) {
            _items[_index++] = contractToWLVendingItems[contract_][start_ + i];
        }

        return _items;
    }

    function getWLVendingObject(address contract_, uint256 index_) public 
    view returns (WLVendingObject memory) {

        WLVendingItem memory _item = contractToWLVendingItems[contract_][index_];
        WLVendingObject memory _object = WLVendingObject(
            _item.title,
            _item.imageUri,
            _item.projectUri,
            _item.description,

            _item.amountAvailable,
            _item.amountPurchased,
            _item.startTime,
            _item.endTime,

            TokenController.getTokenNameOfItem(contract_, index_),
            TokenController.getTokenImageOfItem(contract_, index_),
            TokenController.getTokenOfItem(contract_, index_),

            PriceController.getPriceOfItem(contract_, index_)
        );
        return _object;
    }

    function getWLVendingObjectsPaginated(address contract_, uint256 start_, 
    uint256 end_) public view returns (WLVendingObject[] memory) {

        uint256 _arrayLength = end_ - start_ + 1;
        WLVendingObject[] memory _objects = new WLVendingObject[] (_arrayLength);
        uint256 _index;

        for (uint256 i = 0; i < _arrayLength; i++) {

            uint256 _itemIndex = start_ + i;
            
            WLVendingItem memory _item = contractToWLVendingItems[contract_][_itemIndex];
            WLVendingObject memory _object = WLVendingObject(
                _item.title,
                _item.imageUri,
                _item.projectUri,
                _item.description,

                _item.amountAvailable,
                _item.amountPurchased,
                _item.startTime,
                _item.endTime,

                TokenController.getTokenNameOfItem(contract_, (_itemIndex)),
                TokenController.getTokenImageOfItem(contract_, (_itemIndex)),
                TokenController.getTokenOfItem(contract_, (_itemIndex)),

                PriceController.getPriceOfItem(contract_, (_itemIndex))
            );

            _objects[_index++] = _object;
        }

        return _objects;
    }
}