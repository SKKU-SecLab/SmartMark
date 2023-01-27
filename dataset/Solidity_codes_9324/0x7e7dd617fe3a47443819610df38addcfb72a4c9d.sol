



pragma solidity ^0.8.0;

interface IPiRatGame {

}



pragma solidity ^0.8.0;

interface IBOOTY {

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function claimBooty(address owner) external;

    function burnExternal(address from, uint256 amount) external;

    function initTimeStamp(address owner, uint256 timeStamp) external;

    function showPendingClaimable(address owner) external view returns (uint256);

    function showEarningRate(address owner) external view returns (uint256);

    function claimGift(address to) external;

}



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




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

}




pragma solidity ^0.8.0;


interface IPiRats is IERC721 {


    struct CrewCaptain {
        bool isCrew;
        uint8 body;
        uint8 clothes;
        uint8 face;
        uint8 mouth;
        uint8 eyes;
        uint8 head;
        uint8 legendRank;
    }
    
    function paidTokens() external view returns (uint256);

    function maxTokens() external view returns (uint256);

    function mintPiRat(address recipient, uint16 amount, uint256 seed) external;

    function plankPiRat(address recipient, uint16 amount, uint256 seed, uint256 _burnToken) external;

    function getTokenTraits(uint256 tokenId) external view returns (CrewCaptain memory);

    function isCrew(uint256 tokenId) external view returns(bool);

    function getBalanceCrew(address owner) external view returns (uint16);

    function getBalanceCaptain(address owner) external view returns (uint16);

    function getTotalRank(address owner) external view returns (uint256);

    function walletOfOwner(address owner) external view returns (uint256[] memory);

    function getTotalPiratsMinted() external view returns(uint256 totalPiratsMinted);

    function getTotalPiratsBurned() external view returns(uint256 totalPiratsBurned);

    function getTotalPirats() external view returns(uint256 totalPirats);

  
}



pragma solidity ^0.8.0;


interface IPOTMTraits {

  function tokenURI(uint256 tokenId) external view returns (string memory);

  function selectMintTraits(uint256 seed) external view returns (IPiRats.CrewCaptain memory t);

  function selectPlankTraits(uint256 seed) external view returns (IPiRats.CrewCaptain memory t);

}



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
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}




pragma solidity ^0.8.0;









contract PiRatGame is IPiRatGame, Ownable, ReentrancyGuard, Pausable {


    bool public publicSaleStarted;

    uint256 public constant PRESALE_PRICE = 0.0420 ether;
    uint256 public constant MINT_PRICE = 0.0420 ether;

    uint256 private maxBootyCost = 5000 ether;

    struct Whitelist {
        bool isWhitelisted;
        uint16 numMinted;
    }
    
    mapping(address => Whitelist) private _whitelistAddresses;

    struct Legendlist {
        bool isLegendlisted;
        bool giftAvailable;
    }

    mapping(address => Legendlist) private _legendlistAddresses;

    struct MintCommit {
        uint16 amount;
    }

    event MintCommitted(address indexed owner, uint256 indexed amount);
    event MintRevealed(address indexed owner, uint256 indexed amount);

    uint16 private _mintCommitId = 0;
    uint16 public pendingMintAmt;

    mapping(address => mapping(uint16 => MintCommit)) private _mintCommits;   

    mapping(address => uint16) private _pendingMintCommitId;

    struct PlankCommit {
        uint16 amount;
    }

    event PlankCommitted(address indexed owner, uint256 indexed amount);
    event PlankRevealed(address indexed owner, uint256 indexed amount);

    uint16 private _plankCommitId = 20000;
    uint16 private pendingPlankAmt;

    mapping(uint16 => uint256) private _plankCommitRandoms;
    mapping(address => mapping(uint16 => PlankCommit)) private _plankCommits;
    mapping(address => uint16) private _pendingPlankCommitId;

    mapping(uint256 => uint256) private commitIdToRandomNumber;
    mapping(address => uint256) private commitTimeStamp; 

    IPiRats public potm;
    IBOOTY public booty;

    constructor()    
    {
        _pause();
    }


    modifier requireContractsSet() {

        require(
            address(booty) != address(0) && 
            address(potm) != address(0), "Contracts not set");
      _;
    }

    
    function addToWhitelist(address[] calldata addressesToAdd) public onlyOwner {

        for (uint256 i = 0; i < addressesToAdd.length; i++) {
            _whitelistAddresses[addressesToAdd[i]] = Whitelist(true, 0);
        }
    }

    function addToLegendlist(address[] calldata addressesToAdd) public onlyOwner {

        for (uint256 i = 0; i < addressesToAdd.length; i++) {
            _legendlistAddresses[addressesToAdd[i]] = Legendlist(true, true);
        }
    }

    function setPublicSaleStart(bool started) external onlyOwner {

        publicSaleStarted = started;
        if(publicSaleStarted) {
        }
    }


    function commitPirat(uint16 amount) external payable whenNotPaused nonReentrant {

        require(tx.origin == msg.sender, "Only EOA");
        require(_pendingMintCommitId[msg.sender] == 0, "Already have pending mints");
        uint256 totalPirats = potm.getTotalPirats();
        uint256 totalPending = pendingMintAmt + pendingPlankAmt;
        uint256 maxTokens = potm.maxTokens();
        uint256 paidTokens = potm.paidTokens();
        require(totalPirats + totalPending + amount <= maxTokens, "All tokens minted");
        require(amount > 0 && amount <= 10, "Invalid mint amount");
        if (totalPirats < paidTokens) {
            require(totalPirats + totalPending + amount <= paidTokens, "All tokens on-sale already sold");
            if(publicSaleStarted) {
                require(msg.value == amount * MINT_PRICE, "Invalid payment amount");
            } else {
                require(amount * PRESALE_PRICE == msg.value, "Invalid payment amount");
                require(_whitelistAddresses[msg.sender].isWhitelisted, "Not on whitelist");
                require(_whitelistAddresses[msg.sender].numMinted + amount <= 5, "too many mints");
                _whitelistAddresses[msg.sender].numMinted += uint16(amount);
            }
        } else {
            require(msg.value == 0);
        }
        uint256 totalBootyCost = 0;
        for (uint i = 1; i <= amount; i++) {
            totalBootyCost += mintCost(totalPirats + totalPending + i);
            }
        if (totalBootyCost > 0) {
            booty.burnExternal(msg.sender, totalBootyCost);
        }
        _mintCommitId += 1;
        uint16 commitId = _mintCommitId;
        _mintCommits[msg.sender][commitId] = MintCommit(amount);       
        _pendingMintCommitId[msg.sender] = commitId;
        pendingMintAmt += amount;
        uint256 randomNumber = _rand(commitId);
        commitIdToRandomNumber[commitId] = randomNumber;        
        commitTimeStamp[msg.sender] = block.timestamp;
        emit MintCommitted(msg.sender, amount);
    }

    function mintCost(uint256 tokenId) public view returns (uint256) {

        if (tokenId <= potm.paidTokens()) return 0;
        if (tokenId <= potm.maxTokens() * 2 / 4) return 1000 ether;  // 50%
        if (tokenId <= potm.maxTokens() * 3 / 4) return 3000 ether;  // 75%
        return maxBootyCost;
    }

    function revealPiRat() public whenNotPaused nonReentrant {

        address recipient = msg.sender;
        uint16 mintCommitIdCur = getMintCommitId(recipient);
        uint256 _timeStamp = commitTimeStamp[recipient];
        uint256 mintSeedCur = getRandomSeed(mintCommitIdCur);
        require(_timeStamp != block.timestamp, "Please wait, PiRat is still Training!");
        require(mintSeedCur > 0, "random seed not set");
        uint16 amount = getPendingMintAmount(recipient);
        potm.mintPiRat(recipient, amount, mintSeedCur);
        pendingMintAmt -= amount;
        delete _mintCommits[recipient][_mintCommitId];        
        delete _pendingMintCommitId[recipient];
        delete commitIdToRandomNumber[mintCommitIdCur];
        delete commitTimeStamp[recipient];
        emit MintRevealed(recipient, amount);
    }


    function walkPlank() external whenNotPaused nonReentrant {

        require(tx.origin == msg.sender, "Only EOA");
        require(_pendingPlankCommitId[msg.sender] == 0, "Already have pending mints");
        uint16 totalPirats = uint16(potm.getTotalPirats());
        uint16 totalPending = pendingMintAmt + pendingPlankAmt;
        uint256 maxTokens = potm.maxTokens();
        require(totalPirats + totalPending + 1 <= maxTokens, "All tokens minted");
        uint256 totalBootyCost = 0;
        for (uint i = 1; i <= 1; i++) {
            totalBootyCost += plankCost(totalPirats + totalPending + i);
            }
        if (totalBootyCost > 0) {
            booty.burnExternal(msg.sender, totalBootyCost);
        }
        _plankCommitId += 1;
        uint16 commitId = _plankCommitId;
        _plankCommits[msg.sender][commitId] = PlankCommit(1);       
        _pendingPlankCommitId[msg.sender] = commitId;
        pendingPlankAmt += 1;
        uint256 randomNumber = _rand(commitId);
        commitIdToRandomNumber[commitId] = randomNumber;        
        commitTimeStamp[msg.sender] = block.timestamp;
        emit PlankCommitted(msg.sender, 1);
    }

    function plankCost(uint256 tokenId) public view returns (uint256) {

        if (tokenId <= potm.paidTokens()) return 1500 ether; // 25%
        if (tokenId <= potm.maxTokens() * 2 / 4) return 2500 ether;  // 50%
        if (tokenId <= potm.maxTokens() * 3 / 4) return 4500 ether;  // 75%
        return 7500 ether; // 100%
    }

    function revealPlankPiRat(uint256 tokenId) public whenNotPaused nonReentrant {

        require(potm.isCrew(tokenId), "Only Crew can Walk The Plank");
        address recipient = msg.sender;
        uint256 _timeStamp = commitTimeStamp[recipient];
        require(_timeStamp != (block.timestamp + 2), "Please wait, PiRat is still Training!");
        uint16 plankCommitIdCur = getPlankCommitId(recipient);
        uint256 plankSeedCur = getRandomSeed(plankCommitIdCur);
        require(plankSeedCur > 0, "random seed not set");
        potm.plankPiRat(recipient, 1, plankSeedCur, tokenId);
        pendingPlankAmt--;
        delete _plankCommits[recipient][_plankCommitId];        
        delete _pendingPlankCommitId[recipient];
        delete commitTimeStamp[recipient];
        delete commitIdToRandomNumber[plankCommitIdCur];
        emit PlankRevealed(recipient, 1);
    }


    function claimBooty(address owner) public {

        require(tx.origin == msg.sender, "Only EOA");
        booty.claimBooty(owner);
    }


    function getPendingMintAmount(address addr) public view returns (uint16 amount) {

        uint16 mintCommitIdCur = _pendingMintCommitId[addr];
        require(mintCommitIdCur > 0, "No pending commit");
        MintCommit memory mintCommit = _mintCommits[addr][mintCommitIdCur];
        amount = mintCommit.amount;
    }

    function getMintCommitId(address addr) public view returns (uint16) {

        require(_pendingMintCommitId[addr] != 0, "no pending commits");
        return _pendingMintCommitId[addr];
    }

    function hasMintPending(address addr) public view returns (bool) {

        return _pendingMintCommitId[addr] != 0;
    }

    function readyToRevealMint(address addr) public view returns (bool) {

        uint16 mintCommitIdCur = _pendingMintCommitId[addr];
        return getRandomSeed(mintCommitIdCur) !=0;
    }

    function getPendingPlankAmount(address addr) public view returns (uint16 amount) {

        uint16 plankCommitIdCur = _pendingPlankCommitId[addr];
        require(plankCommitIdCur > 0, "No pending commit");
        PlankCommit memory plankCommit = _plankCommits[addr][plankCommitIdCur];
        amount = plankCommit.amount;
    }

    function getPlankCommitId(address addr) public view returns (uint16) {

        require(_pendingPlankCommitId[addr] != 0, "no pending commits");
        return _pendingPlankCommitId[addr];
    }

    function hasPlankPending(address addr) public view returns (bool) {

        return _pendingPlankCommitId[addr] != 0;
    }

    function readyToRevealPlank(address addr) public view returns (bool) {

        uint16 plankCommitIdCur = _pendingPlankCommitId[addr];
        return getRandomSeed(plankCommitIdCur) !=0;
    }

    function claimLegendGift(address addr) public {

        require(_legendlistAddresses[addr].isLegendlisted, "Not on Legend list");
        require(_legendlistAddresses[addr].giftAvailable, "Gift already claimed");
        booty.claimGift(addr);
        _legendlistAddresses[addr].giftAvailable = false;
    }


    function withdraw() external onlyOwner {

        payable(owner()).transfer(address(this).balance);
    }

    function setPaused(bool _paused) external requireContractsSet onlyOwner {

        if (_paused) _pause();
        else _unpause();
    }

    function setContracts(address _booty, address _potm) external onlyOwner {

        booty = IBOOTY(_booty);       
        potm = IPiRats(_potm);

    }

    function deleteMintCommits (address recipient) external onlyOwner {
        uint16 mintCommitIdCur = getMintCommitId(recipient);
        uint256 mintSeedCur = getRandomSeed(mintCommitIdCur);
        require(mintSeedCur > 0, "No seed set");
        uint16 amount = getPendingMintAmount(recipient);
        pendingMintAmt -= amount;
        delete _mintCommits[recipient][_mintCommitId];        
        delete _pendingMintCommitId[recipient];
        delete commitIdToRandomNumber[mintCommitIdCur];
        delete commitTimeStamp[recipient];
    }

    function deletePlankCommits (address recipient) external onlyOwner {
        uint16 plankCommitIdCur = getPlankCommitId(recipient);
        uint256 plankSeedCur = getRandomSeed(plankCommitIdCur);
        require(plankSeedCur > 0, "random seed not set");
        pendingPlankAmt--;
        delete _plankCommits[recipient][_plankCommitId];        
        delete _pendingPlankCommitId[recipient];
        delete commitTimeStamp[recipient];
        delete commitIdToRandomNumber[plankCommitIdCur];
    }

    function _rand(uint256 seed) private view returns (uint256) {

        return uint256(keccak256(abi.encodePacked(block.timestamp, seed)));
    }

    function getRandomSeed(uint16 commitId) private view returns (uint256 randomNumber) {

        randomNumber = commitIdToRandomNumber[commitId];
    }


    function showBootyBalance(address owner) public view returns (uint256 bootyBalance) {

        bootyBalance = booty.balanceOf(owner);
    }

    function showClaimableBooty(address owner) public view returns (uint256 pendingBooty) {

        pendingBooty = booty.showPendingClaimable(owner);
    }

    function showEarningRate(address owner) public view returns (uint256 dailyBooty) {

        dailyBooty = booty.showEarningRate(owner);
    }

    function showTotalMinted() public view returns (uint256 totalMinted) {

        totalMinted = potm.getTotalPiratsMinted();
    }

    function showTotalBurned() public view returns (uint256 totalBurned) {

        totalBurned = potm.getTotalPiratsBurned();
    }

    function showTotalSupply() public view returns (uint256 totalSupply) {

        totalSupply = potm.getTotalPirats();
    }

    function showBalanceCrew(address owner) public view returns (uint16 _balanceCrew) {

        _balanceCrew = potm.getBalanceCrew(owner);
    }

    function showBalanceCaptain(address owner) public view returns (uint16 _balanceCaptain) {

        _balanceCaptain = potm.getBalanceCaptain(owner);
    }

    function showTotalRank(address owner) public view returns (uint256 _totalRank) {

        _totalRank = potm.getTotalRank(owner);
    }

    function showWhitelistStatus(address owner) public view returns (bool) {

        return _whitelistAddresses[owner].isWhitelisted;
    }

    function showWhitelistRemaininMints(address owner) public view returns (uint256) {

        return (5 - _whitelistAddresses[owner].numMinted);
    }

    function showLegendStatus(address owner) public view returns (bool) {

        return _legendlistAddresses[owner].isLegendlisted;
    }

    function showGiftAvailable(address owner) public view returns (bool) {

        return _legendlistAddresses[owner].giftAvailable;
    }

    function showIsCrew(uint256 tokenId) public view returns (bool) {

        return potm.isCrew(tokenId);
    }
}
