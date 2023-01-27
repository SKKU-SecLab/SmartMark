
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

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

}//Unlicense
pragma solidity ^0.8.0;


struct TokenData {
    uint256 balance;

    uint256 lastClaimAt;
}

struct RealmConfig {
    IERC20 token;

    uint256 dailyRate;

    RealmConstraints constraints;
}

struct RealmConstraints {
    uint256 minInfusionAmount;

    uint256 maxTokenBalance;

    uint256 minClaimAmount;

    bool requireNftIsOwned;

    bool allowMultiInfuse;

    bool allowPublicInfusion;

    bool allowPublicClaiming;

    bool allowAllCollections;
}

struct CreateRealmInput {
    string name;

    string description;

    RealmConfig config;

    address[] admins;

    address[] infusers;

    address[] claimers;

    IERC721[] collections;
}

struct ModifyRealmInput {
    uint256 realmId;
    address[] adminsToAdd;
    address[] adminsToRemove;
    address[] infusersToAdd;
    address[] infusersToRemove;
    address[] claimersToAdd;
    address[] claimersToRemove;
    IERC721[] collectionsToAdd;
    IERC721[] collectionsToRemove;
}

struct InfuseInput {
    uint256 realmId;

    IERC721 collection;

    uint256 tokenId;

    address infuser;

    uint256 amount;

    string comment;
}

struct ClaimInput {
    uint256 realmId;

    IERC721 collection;

    uint256 tokenId;

    uint256 amount;
}

interface IHyperVIBES {

    event RealmCreated(uint256 indexed realmId, string name, string description);

    event AdminAdded(uint256 indexed realmId, address indexed admin);

    event AdminRemoved(uint256 indexed realmId, address indexed admin);

    event InfuserAdded(uint256 indexed realmId, address indexed infuser);

    event InfuserRemoved(uint256 indexed realmId, address indexed infuser);

    event CollectionAdded(uint256 indexed realmId, IERC721 indexed collection);

    event CollectionRemoved(uint256 indexed realmId, IERC721 indexed collection);

    event ClaimerAdded(uint256 indexed realmId, address indexed claimer);

    event ClaimerRemoved(uint256 indexed realmId, address indexed claimer);

    event ProxyAdded(uint256 indexed realmId, address indexed proxy);

    event ProxyRemoved(uint256 indexed realmId, address indexed proxy);

    event Infused(
        uint256 indexed realmId,
        IERC721 indexed collection,
        uint256 indexed tokenId,
        address infuser,
        uint256 amount,
        string comment
    );

    event Claimed(
        uint256 indexed realmId,
        IERC721 indexed collection,
        uint256 indexed tokenId,
        uint256 amount
    );

    function createRealm(CreateRealmInput memory create) external returns (uint256);


    function modifyRealm(ModifyRealmInput memory input) external;


    function infuse(InfuseInput memory input) external returns (uint256);


    function allowProxy(uint256 realmId, address proxy) external;


    function denyProxy(uint256 realmId, address proxy) external;


    function claim(ClaimInput memory input) external returns (uint256);


    function batchClaim(ClaimInput[] memory batch) external returns (uint256);


    function batchInfuse(InfuseInput[] memory batch) external returns (uint256);


    function name() external pure returns (string memory);


    function currentMinedTokens(uint256 realmId, IERC721 collection, uint256 tokenId) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}//Unlicense
pragma solidity ^0.8.0;



contract HyperVIBES is IHyperVIBES, ReentrancyGuard {

    bool constant public FEEL_FREE_TO_USE_HYPERVIBES_IN_ANY_WAY_YOU_WANT = true;


    mapping(uint256 => RealmConfig) public realmConfig;

    mapping(uint256 => mapping(address => bool)) public isAdmin;

    mapping(uint256 => mapping(address => bool)) public isInfuser;

    mapping(uint256 => mapping(address => bool)) public isClaimer;

    mapping(uint256 => mapping(IERC721 => bool)) public isCollection;

    mapping(uint256 => mapping(IERC721 => mapping(uint256 => TokenData)))
        public tokenData;

    mapping(uint256 => mapping(address => mapping(address => bool))) public isProxy;

    uint256 public nextRealmId = 1;


    function createRealm(CreateRealmInput memory create) override external returns (uint256) {

        require(create.config.token != IERC20(address(0)), "invalid token");
        require(create.config.constraints.maxTokenBalance > 0, "invalid max token balance");
        require(
            create.config.constraints.minClaimAmount <= create.config.constraints.maxTokenBalance,
            "invalid min claim amount");

        uint256 realmId = nextRealmId++;
        realmConfig[realmId] = create.config;

        emit RealmCreated(realmId, create.name, create.description);

        for (uint256 i = 0; i < create.admins.length; i++) {
            _addAdmin(realmId, create.admins[i]);
        }

        for (uint256 i = 0; i < create.infusers.length; i++) {
            _addInfuser(realmId, create.infusers[i]);
        }

        for (uint256 i = 0; i < create.claimers.length; i++) {
            _addClaimer(realmId, create.claimers[i]);
        }

        for (uint256 i = 0; i < create.collections.length; i++) {
            _addCollection(realmId, create.collections[i]);
        }

        return realmId;
    }

    function modifyRealm(ModifyRealmInput memory input) override external {

        require(_realmExists(input.realmId), "invalid realm");
        require(isAdmin[input.realmId][msg.sender], "not realm admin");


        for (uint256 i = 0; i < input.adminsToAdd.length; i++) {
            _addAdmin(input.realmId, input.adminsToAdd[i]);
        }

        for (uint256 i = 0; i < input.infusersToAdd.length; i++) {
            _addInfuser(input.realmId, input.infusersToAdd[i]);
        }

        for (uint256 i = 0; i < input.claimersToAdd.length; i++) {
            _addClaimer(input.realmId, input.claimersToAdd[i]);
        }

        for (uint256 i = 0; i < input.collectionsToAdd.length; i++) {
            _addCollection(input.realmId, input.collectionsToAdd[i]);
        }


        for (uint256 i = 0; i < input.adminsToRemove.length; i++) {
            _removeAdmin(input.realmId, input.adminsToRemove[i]);
        }

        for (uint256 i = 0; i < input.infusersToRemove.length; i++) {
            _removeInfuser(input.realmId, input.infusersToRemove[i]);
        }

        for (uint256 i = 0; i < input.claimersToRemove.length; i++) {
            _removeClaimer(input.realmId, input.claimersToRemove[i]);
        }

        for (uint256 i = 0; i < input.collectionsToRemove.length; i++) {
            _removeCollection(input.realmId, input.collectionsToRemove[i]);
        }
    }

    function _addAdmin(uint256 realmId, address admin) internal {

        require(admin != address(0), "invalid admin");
        isAdmin[realmId][admin] = true;
        emit AdminAdded(realmId, admin);
    }

    function _removeAdmin(uint256 realmId, address admin) internal {

        require(admin != address(0), "invalid admin");
        delete isAdmin[realmId][admin];
        emit AdminRemoved(realmId, admin);
    }

    function _addInfuser(uint256 realmId, address infuser) internal {

        require(infuser != address(0), "invalid infuser");
        isInfuser[realmId][infuser] = true;
        emit InfuserAdded(realmId, infuser);
    }

    function _removeInfuser(uint256 realmId, address infuser) internal {

        require(infuser != address(0), "invalid infuser");
        delete isInfuser[realmId][infuser];
        emit InfuserRemoved(realmId, infuser);
    }

    function _addClaimer(uint256 realmId, address claimer) internal {

        require(claimer != address(0), "invalid claimer");
        isClaimer[realmId][claimer] = true;
        emit ClaimerAdded(realmId, claimer);
    }

    function _removeClaimer(uint256 realmId, address claimer) internal {

        require(claimer != address(0), "invalid claimer");
        delete isClaimer[realmId][claimer];
        emit ClaimerRemoved(realmId, claimer);
    }

    function _addCollection(uint256 realmId, IERC721 collection) internal {

        require(collection != IERC721(address(0)), "invalid collection");
        isCollection[realmId][collection] = true;
        emit CollectionAdded(realmId, collection);
    }

    function _removeCollection(uint256 realmId, IERC721 collection) internal {

        require(collection != IERC721(address(0)), "invalid collection");
        delete isCollection[realmId][collection];
        emit CollectionRemoved(realmId, collection);
    }


    function infuse(InfuseInput memory input) override external nonReentrant returns (uint256) {

        return _infuse(input);
    }

    function _infuse(InfuseInput memory input) private returns (uint256) {

        TokenData storage data = tokenData[input.realmId][input.collection][input.tokenId];
        RealmConfig memory realm = realmConfig[input.realmId];

        _validateInfusion(input, data, realm);

        if (data.lastClaimAt == 0) {
            data.lastClaimAt = block.timestamp;
        }
        else if (data.balance == 0) {
            data.lastClaimAt = block.timestamp;
        }

        uint256 nextBalance = data.balance + input.amount;
        uint256 clampedBalance = nextBalance > realm.constraints.maxTokenBalance
            ? realm.constraints.maxTokenBalance
            : nextBalance;
        uint256 amountToTransfer = clampedBalance - data.balance;

        require(amountToTransfer > 0, "nothing to transfer");
        require(amountToTransfer >= realm.constraints.minInfusionAmount, "amount too low");

        data.balance += amountToTransfer;
        realm.token.transferFrom(msg.sender, address(this), amountToTransfer);

        emit Infused(
            input.realmId,
            input.collection,
            input.tokenId,
            input.infuser,
            input.amount,
            input.comment
        );

        return amountToTransfer;
    }

    function _validateInfusion(InfuseInput memory input, TokenData memory data, RealmConfig memory realm) internal view {

        require(_isTokenValid(input.collection, input.tokenId), "invalid token");
        require(_realmExists(input.realmId), "invalid realm");

        bool isOwnedByInfuser = input.collection.ownerOf(input.tokenId) == input.infuser;
        bool isOnInfuserAllowlist = isInfuser[input.realmId][msg.sender];
        bool isOnCollectionAllowlist = isCollection[input.realmId][input.collection];
        bool isValidProxy = isProxy[input.realmId][msg.sender][input.infuser];

        require(isOwnedByInfuser || !realm.constraints.requireNftIsOwned, "nft not owned by infuser");
        require(isOnInfuserAllowlist || realm.constraints.allowPublicInfusion, "invalid infuser");
        require(isOnCollectionAllowlist || realm.constraints.allowAllCollections, "invalid collection");
        require(isValidProxy || msg.sender == input.infuser, "invalid proxy");

        if (data.lastClaimAt != 0) {
            require(realm.constraints.allowMultiInfuse, "multi infuse disabled");
        }
    }


    function allowProxy(uint256 realmId, address proxy) override external {

        require(_realmExists(realmId), "invalid realm");
        isProxy[realmId][proxy][msg.sender] = true;
        emit ProxyAdded(realmId, proxy);
    }

    function denyProxy(uint256 realmId, address proxy) override external {

        require(_realmExists(realmId), "invalid realm");
        delete isProxy[realmId][proxy][msg.sender];
        emit ProxyRemoved(realmId, proxy);
    }


    function claim(ClaimInput memory input) override external nonReentrant returns (uint256) {

        return _claim(input);
    }

    function _claim(ClaimInput memory input) private returns (uint256) {

        require(_isTokenValid(input.collection, input.tokenId), "invalid token");
        require(_isValidClaimer(input.realmId, input.collection, input.tokenId), "invalid claimer");

        TokenData storage data = tokenData[input.realmId][input.collection][input.tokenId];
        require(data.lastClaimAt != 0, "token not infused");

        uint256 secondsToClaim = block.timestamp - data.lastClaimAt;
        uint256 mined = (secondsToClaim * realmConfig[input.realmId].dailyRate) / 1 days;
        uint256 availableToClaim = mined > data.balance ? data.balance : mined;

        uint256 toClaim = input.amount < availableToClaim ? input.amount : availableToClaim;
        require(toClaim >= realmConfig[input.realmId].constraints.minClaimAmount, "amount too low");
        require(toClaim > 0, "nothing to claim");

        uint256 claimAt = data.lastClaimAt + (toClaim * 1 days) / realmConfig[input.realmId].dailyRate;

        data.balance -= toClaim;
        data.lastClaimAt = claimAt;
        realmConfig[input.realmId].token.transfer(msg.sender, toClaim);

        emit Claimed(input.realmId, input.collection, input.tokenId, toClaim);

        return toClaim;
    }

    function _isValidClaimer(uint256 realmId, IERC721 collection, uint256 tokenId) internal view returns (bool) {

        address owner = collection.ownerOf(tokenId);

        bool isOwned = owner == msg.sender;
        bool isValidProxy = isProxy[realmId][msg.sender][owner];

        if (!isOwned && !isValidProxy) {
            return false;
        }

        if (realmConfig[realmId].constraints.allowPublicClaiming) {
            return true;
        }

        return isClaimer[realmId][msg.sender];
    }



    function batchClaim(ClaimInput[] memory batch)
        override external nonReentrant
        returns (uint256)
    {

        uint256 totalClaimed = 0;
        for (uint256 i = 0; i < batch.length; i++) {
            totalClaimed += _claim(batch[i]);
        }
        return totalClaimed;
    }

    function batchInfuse(InfuseInput[] memory batch)
        override external nonReentrant
        returns (uint256)
    {

        uint256 totalInfused = 0;
        for (uint256 i; i < batch.length; i++) {
            totalInfused += _infuse(batch[i]);
        }
        return totalInfused;
    }



    function name() override external pure returns (string memory) {

        return "HyperVIBES";
    }


    function currentMinedTokens(uint256 realmId, IERC721 collection, uint256 tokenId)
        override external view returns (uint256)
    {

        require(_realmExists(realmId), "invalid realm");

        TokenData memory data = tokenData[realmId][collection][tokenId];

        if (!_isTokenValid(collection, tokenId)) {
            return 0;
        }

        if (data.lastClaimAt == 0) {
            return 0;
        }

        uint256 miningTime = block.timestamp - data.lastClaimAt;
        uint256 mined = (miningTime * realmConfig[realmId].dailyRate) / 1 days;
        uint256 clamped = mined > data.balance ? data.balance : mined;
        return clamped;
    }


    function _realmExists(uint256 realmId) internal view returns (bool) {

        return realmConfig[realmId].token != IERC20(address(0));
    }

    function _isTokenValid(IERC721 collection, uint256 tokenId)
        internal view returns (bool)
    {

        try collection.ownerOf(tokenId) returns (address) {
            return true;
        } catch {
            return false;
        }
    }
}