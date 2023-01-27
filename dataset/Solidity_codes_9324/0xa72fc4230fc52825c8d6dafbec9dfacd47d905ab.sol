
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}// MIT LICENSE 

pragma solidity ^0.8.0;

interface IFleet {

    function addManyToFleet(address account, uint16[] calldata tokenIds) external;

    function randomPirateOwner(uint256 seed) external view returns (address);

}// MIT LICENSE

pragma solidity ^0.8.0;


interface IInblockGuard {

    function updateInblockGuard() external;

}// MIT LICENSE

pragma solidity ^0.8.0;



interface ICACAO is IInblockGuard {

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

}// MIT LICENSE

pragma solidity ^0.8.0;


interface IPnG is IERC721 {


    struct GalleonPirate {
        bool isGalleon;

        uint8 base;
        uint8 deck;
        uint8 sails;
        uint8 crowsNest;
        uint8 decor;
        uint8 flags;
        uint8 bowsprit;

        uint8 skin;
        uint8 clothes;
        uint8 hair;
        uint8 earrings;
        uint8 mouth;
        uint8 eyes;
        uint8 weapon;
        uint8 hat;
        uint8 alphaIndex;
    }


    function updateOriginAccess(uint16[] memory tokenIds) external;


    function totalSupply() external view returns(uint256);


    function mint(address recipient, uint256 seed) external;

    function burn(uint256 tokenId) external;

    function minted() external view returns (uint16);


    function getMaxTokens() external view returns (uint256);

    function getPaidTokens() external view returns (uint256);

    function getTokenTraits(uint256 tokenId) external view returns (GalleonPirate memory);

    function getTokenWriteBlock(uint256 tokenId) external view returns(uint64);

    function isGalleon(uint256 tokenId) external view returns(bool);

}// MIT LICENSE

pragma solidity ^0.8.0;



contract Owned is Context {

    address private _contractOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() { 
        _contractOwner = payable(_msgSender()); 
    }

    function owner() public view virtual returns(address) {

        return _contractOwner;
    }

    function _transferOwnership(address newOwner) external virtual onlyOwner {

        require(newOwner != address(0), "Owned: Address can not be 0x0");
        __transferOwnership(newOwner);
    }


    function _renounceOwnership() external virtual onlyOwner {

        __transferOwnership(address(0));
    }

    function __transferOwnership(address _to) internal {

        emit OwnershipTransferred(owner(), _to);
        _contractOwner = _to;
    }


    modifier onlyOwner() {

        require(_msgSender() == _contractOwner, "Owned: Only owner can operate");
        _;
    }
}



contract Accessable is Owned {

    mapping(address => bool) private _admins;
    mapping(address => bool) private _tokenClaimers;

    constructor() {
        _admins[_msgSender()] = true;
        _tokenClaimers[_msgSender()] = true;
    }

    function isAdmin(address user) public view returns(bool) {

        return _admins[user];
    }

    function isTokenClaimer(address user) public view returns(bool) {

        return _tokenClaimers[user];
    }


    function _setAdmin(address _user, bool _isAdmin) external onlyOwner {

        _admins[_user] = _isAdmin;
        require( _admins[owner()], "Accessable: Contract owner must be an admin" );
    }

    function _setTokenClaimer(address _user, bool _isTokenCalimer) external onlyOwner {

        _tokenClaimers[_user] = _isTokenCalimer;
        require( _tokenClaimers[owner()], "Accessable: Contract owner must be an token claimer" );
    }


    modifier onlyAdmin() {

        require(_admins[_msgSender()], "Accessable: Only admin can operate");
        _;
    }

    modifier onlyTokenClaimer() {

        require(_tokenClaimers[_msgSender()], "Accessable: Only Token Claimer can operate");
        _;
    }
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// MIT LICENSE

pragma solidity ^0.8.0;





contract Whitelist is Accessable {

    bytes32 _whitelistRoot = 0;

    constructor() {}

    function _setWhitelistRoot(bytes32 root) external onlyAdmin {

        _whitelistRoot = root;
    }

    function isWhitelistRootSeted() public view returns(bool){

        return (_whitelistRoot != bytes32(0));
    }

    function inWhitelist(address addr, bytes32[] memory proof) public view returns (bool) {

        require(isWhitelistRootSeted(), "Whitelist merkle proof root not setted");
        bytes32 leaf = keccak256(abi.encodePacked(addr));
        return MerkleProof.verify(proof, _whitelistRoot, leaf);
    }
}// MIT LICENSE

pragma solidity ^0.8.0;





contract PirateGame is Accessable, Whitelist, ReentrancyGuard, Pausable {


    event MintCommitted(address indexed owner, uint256 indexed amount);
    event MintRevealed(address indexed owner, uint256 indexed amount);

    uint256[3] private _cacaoCost = [20000 ether, 40000 ether, 80000 ether];
    uint16 public maxBunchSize = 10;

    bool public allowCommits = true;

    bool public isWhitelistSale = true;
    bool public isPublicSale = false;
    uint256 public presalePrice = 0.06 ether;
    uint256 public treasureChestTypeId;


    uint256 public startedTime = 0;

    uint256 private maxPrice = 0.3266 ether;
    uint256 private minPrice = 0.0666 ether;
    uint256 private priceDecrementAmt = 0.01 ether;
    uint256 private timeToDecrementPrice = 30 minutes;



    mapping(address => uint16) public whitelistMinted;
    uint16 public whitelistAmountPerUser = 5;

    struct MintCommit {
        bool exist;
        uint16 amount;
        uint256 blockNumber;
        bool stake;
    }
    mapping(address => MintCommit) private _mintCommits;
    uint16 private _commitsAmount;

    struct MintCommitReturn {
        bool exist;
        bool notExpired;
        bool nextBlockReached;
        uint16 amount;
        uint256 blockNumber;
        bool stake;
    }


    IFleet public fleet;
    ICACAO public cacao;
    IPnG public nftContract;



    constructor() {
        _pause();
    }


    function setContracts(address _cacao, address _nft, address _fleet) external onlyAdmin {

        cacao = ICACAO(_cacao);
        nftContract = IPnG(_nft);
        fleet = IFleet(_fleet);
    }



    function currentEthPriceToMint() view public returns(uint256) {        

        uint16 minted = nftContract.minted();
        uint256 paidTokens = nftContract.getPaidTokens();

        if (minted >= paidTokens) {
            return 0;
        }
        
        uint256 numDecrements = (block.timestamp - startedTime) / timeToDecrementPrice;
        uint256 decrementAmt = (priceDecrementAmt * numDecrements);
        if(decrementAmt > maxPrice) {
            return minPrice;
        }
        uint256 adjPrice = maxPrice - decrementAmt;
        return adjPrice;
    }

    function whitelistPrice() view public returns(uint256) {

        uint16 minted = nftContract.minted();
        uint256 paidTokens = nftContract.getPaidTokens();

        if (minted >= paidTokens) {
            return 0;
        }
        return presalePrice;
    }


    function avaliableWhitelistTokens(address user, bytes32[] memory whitelistProof) external view returns (uint256) {

        if (!inWhitelist(user, whitelistProof) || !isWhitelistSale)
            return 0;
        return whitelistAmountPerUser - whitelistMinted[user];
    }


    function mintCommitWhitelist(uint16 amount, bool isStake, bytes32[] memory whitelistProof) 
        external payable
        nonReentrant
        publicSaleStarted
    {   

        require(isWhitelistSale, "Whitelist sale disabled");
        require(whitelistMinted[_msgSender()] + amount <= whitelistAmountPerUser, "Too many mints");
        require(inWhitelist(_msgSender(), whitelistProof), "Not in whitelist");
        whitelistMinted[_msgSender()] += amount;
        return _commit(amount, isStake, presalePrice);
    }

    function mintCommit(uint16 amount, bool isStake) 
        external payable 
        nonReentrant
        publicSaleStarted
    {

        return _commit(amount, isStake, currentEthPriceToMint());
    }

    function _mintCommitAirdrop(uint16 amount) 
        external payable 
        nonReentrant
        onlyAdmin
    {

        return _commit(amount, false, 0);
    }


    function _commit(uint16 amount, bool isStake, uint256 price) internal
        whenNotPaused 
        onlyEOA
        commitsEnabled
    {

        require(amount > 0 && amount <= maxBunchSize, "Invalid mint amount");
        require( !_hasCommits(_msgSender()), "Already have commit");

        uint16 minted = nftContract.minted() + _commitsAmount;
        uint256 maxTokens = nftContract.getMaxTokens();
        require( minted + amount <= maxTokens, "All tokens minted");

        uint256 paidTokens = nftContract.getPaidTokens();

        if (minted < paidTokens) {
            require(minted + amount <= paidTokens, "All tokens on-sale already sold");
            uint256 price_ = amount * price;
            require(msg.value >= price_, "Invalid payment amount");

            if (msg.value > price_) {
                payable(_msgSender()).transfer(msg.value - price_);
            }
        } 
        else {
            require(msg.value == 0, "");
            uint256 totalCacaoCost = 0;
            for (uint16 i = 1; i <= amount; i++) {
                totalCacaoCost += mintCost(minted + i, maxTokens);
            }
            if (totalCacaoCost > 0) {
                cacao.burn(_msgSender(), totalCacaoCost);
                cacao.updateInblockGuard();
            }           
        }

        _mintCommits[_msgSender()] = MintCommit(true, amount, block.number, isStake);
        _commitsAmount += amount;
        emit MintCommitted(_msgSender(), amount);
    }


    function mintReveal() external 
        whenNotPaused 
        nonReentrant 
        onlyEOA
    {

        return reveal(_msgSender());
    }

    function _mintRevealAirdrop(address _to)  external
        whenNotPaused 
        nonReentrant
        onlyAdmin
        onlyEOA
    {

        return reveal(_to);
    }


    function reveal(address addr) internal {

        require(_hasCommits(addr), "No pending commit");
        uint16 minted = nftContract.minted();
        uint256 paidTokens = nftContract.getPaidTokens();
        MintCommit memory commit = _mintCommits[addr];

        uint16[] memory tokenIds = new uint16[](commit.amount);
        uint16[] memory tokenIdsToStake = new uint16[](commit.amount);

        uint256 seed = uint256(blockhash(commit.blockNumber));
        for (uint k = 0; k < commit.amount; k++) {
            minted++;
            seed = uint256(keccak256(abi.encode(seed, addr)));
            address recipient = selectRecipient(seed, minted, paidTokens);
            tokenIds[k] = minted;
            if (!commit.stake || recipient != addr) {
                nftContract.mint(recipient, seed);
            } else {
                nftContract.mint(address(fleet), seed);
                tokenIdsToStake[k] = minted;
            }
        }
        if(commit.stake) {
            fleet.addManyToFleet(addr, tokenIdsToStake);
        }

        _commitsAmount -= commit.amount;
        delete _mintCommits[addr];
        emit MintRevealed(addr, tokenIds.length);
    }



    function mintCost(uint256 tokenId, uint256 maxTokens) public view returns (uint256) {

        if (tokenId <= nftContract.getPaidTokens()) return 0;
        if (tokenId <= maxTokens * 2 / 5) return _cacaoCost[0];
        if (tokenId <= maxTokens * 4 / 5) return _cacaoCost[1];
        return _cacaoCost[2];
    }






    function _setPaused(bool _paused) external requireContractsSet onlyAdmin {

        if (_paused) _pause();
        else _unpause();
    }

    function _setCacaoCost(uint256[3] memory costs) external onlyAdmin {

        _cacaoCost = costs;
    }

    function _setAllowCommits(bool allowed) external onlyAdmin {

        allowCommits = allowed;
    }

    function _setPublicSaleStart(bool started) external onlyAdmin {

        isPublicSale = started;
        if(isPublicSale) {
            startedTime = block.timestamp;
        }
    }

    function setWhitelistSale(bool isSale) external onlyAdmin {

        isWhitelistSale = isSale;
    }

    function _setMaxBunchSize(uint16 size) external onlyAdmin {

        maxBunchSize = size;
    }

    function _setWhitelistAmountPerUser(uint16 amount) external onlyAdmin {

        whitelistAmountPerUser = amount;
    }

    function _cancelCommit(address user) external onlyAdmin {

        _commitsAmount -= _mintCommits[user].amount;
        delete _mintCommits[user];
    }





    function selectRecipient(uint256 seed, uint256 minted, uint256 paidTokens) internal view returns (address) { //TODO

        if (minted <= paidTokens || ((seed >> 245) % 10) != 0) // top 10 bits haven't been used
            return _msgSender(); 

        address thief = address(fleet) == address(0) ? address(0) : fleet.randomPirateOwner(seed >> 144); // 144 bits reserved for trait selection
        if (thief == address(0)) 
            return _msgSender();
        else
            return thief;
    }




    function getTotalPendingCommits() external view returns (uint256) {

        return _commitsAmount;
    }

    function getCommit(address addr) external view returns (MintCommitReturn memory) {

        MintCommit memory m = _mintCommits[addr];
        (bool ex, bool ne, bool nb) = _commitStatus(m);
        return MintCommitReturn(ex, ne, nb, m.amount, m.blockNumber, m.stake);
    }

    function hasMintPending(address addr) external view returns (bool) {

        return _hasCommits(addr);
    }

    function canMint(address addr) external view returns (bool) {

        return _hasCommits(addr);
    }



    function _hasCommits(address addr) internal view returns (bool) {

        MintCommit memory m = _mintCommits[addr];
        (bool a, bool b, bool c) = _commitStatus(m);
        return a && b && c;
    }

    function _commitStatus(MintCommit memory m) 
        internal view 
        returns (bool exist, bool notExpired, bool nextBlockReached) 
    {        

        exist = m.blockNumber != 0;
        notExpired = blockhash(m.blockNumber) != bytes32(0);
        nextBlockReached = block.number > m.blockNumber;
    }




    function _withdrawAll() external onlyTokenClaimer {

        payable(_msgSender()).transfer(address(this).balance);
    }

    function _withdraw(uint256 amount) external onlyTokenClaimer {

        payable(_msgSender()).transfer(amount);
    }



    modifier requireContractsSet() {

        require(
            address(cacao) != address(0) && address(nftContract) != address(0) && address(fleet) != address(0),
            "Contracts not set"
        );
        _;
    }

    modifier onlyEOA() {

        require(_msgSender() == tx.origin, "Only EOA");
        _;
    }

    modifier commitsEnabled() {

        require(allowCommits, "Adding minting commits disalolwed");
        _;
    }

    modifier publicSaleStarted() {

        require(isPublicSale, "Public sale not started yet");
        _;
    }
}