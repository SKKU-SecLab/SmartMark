

pragma solidity ^0.5.10;

contract Ownable {

    address public owner;


    constructor() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address newOwner) public onlyOwner {

        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}


pragma solidity ^0.5.10;


contract Pausable is Ownable {

    event Pause();
    event Unpause();

    bool public paused = false;


    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused {

        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused returns (bool) {

        paused = true;
        emit Pause();
        return true;
    }

    function unpause() public onlyOwner whenPaused returns (bool) {

        paused = false;
        emit Unpause();
        return true;
    }
}


pragma solidity ^0.5.10;



contract DragonAccessControl {

    event ContractUpgrade(address newContract);

    address payable public ceoAddress;
    address payable public cioAddress;
    address payable public cmoAddress;
    address payable public cooAddress;
    address payable public cfoAddress;

    bool public paused = false;

    modifier onlyCEO() {

        require(msg.sender == ceoAddress);
        _;
    }

    modifier onlyCIO() {

        require(msg.sender == cioAddress);
        _;
    }

    modifier onlyCMO() {

        require(msg.sender == cmoAddress);
        _;
    }

    modifier onlyCOO() {

        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCFO() {

        require(msg.sender == cfoAddress);
        _;
    }

    modifier onlyCLevel() {

        require(
            msg.sender == ceoAddress ||
            msg.sender == cioAddress ||
            msg.sender == cmoAddress ||
            msg.sender == cooAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    function setCEO(address payable _newCEO) external onlyCEO {

        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    function setCIO(address payable _newCIO) external onlyCEO {

        require(_newCIO != address(0));

        cioAddress = _newCIO;
    }

    function setCMO(address payable _newCMO) external onlyCEO {

        require(_newCMO != address(0));

        cmoAddress = _newCMO;
    }

    function setCOO(address payable _newCOO) external onlyCEO {

        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    function setCFO(address payable _newCFO) external onlyCEO {

        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused {

        require(paused);
        _;
    }

    function pause() external onlyCLevel whenNotPaused {

        paused = true;
    }

    function unpause() public onlyCEO whenPaused {

        paused = false;
    }
}


pragma solidity ^0.5.10;


interface ERC721 /* is ERC165 */ {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);


    function ownerOf(uint256 _tokenId) external view returns (address);


    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;


    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function approve(address _approved, uint256 _tokenId) external payable;


    function setApprovalForAll(address _operator, bool _approved) external;


    function getApproved(uint256 _tokenId) external view returns (address);


    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}

interface ERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}

interface ERC721TokenReceiver {

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);

}

interface ERC721Metadata /* is IERC721Base */ {

  function name() external pure returns (string memory _name);


  function symbol() external pure returns (string memory _symbol);


  function tokenURI(uint256 _tokenId) external view returns (string memory);

}

interface ERC721Enumerable /* is ERC721 */ {

    function totalSupply() external view returns (uint256);


    function tokenByIndex(uint256 _index) external view returns (uint256);


    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);

}

contract DragonERC721 is ERC165, ERC721, ERC721Metadata, ERC721TokenReceiver, ERC721Enumerable {


    mapping (bytes4 => bool) internal supportedInterfaces;

    string public tokenURIPrefix = "https://www.drakons.io/server/api/dragon/metadata/";
    string public tokenURISuffix = "";

    function name() external pure returns (string memory) {

      return "Drakons";
    }

    function symbol() external pure returns (string memory) {

      return "DRKNS";
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {

        return supportedInterfaces[interfaceID];
    }

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4){

        return bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
    }

}


pragma solidity ^0.5.10;


contract ClockAuctionBase {


    struct Auction {
        address payable seller;
        uint128 startingPrice;
        uint128 endingPrice;
        uint64 duration;
        uint64 startedAt;
    }

    DragonERC721 public nonFungibleContract;

    uint256 public ownerCut;

    address payable public ceoAddress;
    address payable public cfoAddress;

    modifier onlyCEOCFO() {

        require(
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    modifier onlyCEO() {

        require(msg.sender == ceoAddress);
        _;
    }

    mapping (uint256 => Auction) tokenIdToAuction;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address buyer, address seller);
    event AuctionCancelled(uint256 tokenId);


    function setCEO(address payable _newCEO) external onlyCEO {

        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    function setCFO(address payable _newCFO) external onlyCEO {

        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {

        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    function _escrow(address _owner, uint256 _tokenId) internal {

        nonFungibleContract.transferFrom(_owner, address(this), _tokenId);
    }

    function _transfer(address _receiver, uint256 _tokenId) internal {

        nonFungibleContract.transferFrom(address(this), _receiver, _tokenId);
    }

    function _addAuction(uint256 _tokenId, Auction memory _auction) internal {

        require(_auction.duration >= 1 minutes);

        tokenIdToAuction[_tokenId] = _auction;

        emit AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration)
        );
    }

    function _cancelAuction(uint256 _tokenId, address _seller) internal {

        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        emit AuctionCancelled(_tokenId);
    }

    function _bid(uint256 _tokenId, uint256 _bidAmount)
    internal
    returns (uint256)
    {

        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction));

        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);

        address payable seller = auction.seller;

        _removeAuction(_tokenId);

        if (price > 0) {
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

            seller.transfer(sellerProceeds);
        }

        uint256 bidExcess = _bidAmount - price;

        msg.sender.transfer(bidExcess);

        emit AuctionSuccessful(_tokenId, price, msg.sender, seller);

        return price;
    }

    function _removeAuction(uint256 _tokenId) internal {

        delete tokenIdToAuction[_tokenId];
    }

    function _isOnAuction(Auction storage _auction) internal view returns (bool) {

        return (_auction.startedAt > 0);
    }

    function _currentPrice(Auction storage _auction)
    internal
    view
    returns (uint256)
    {

        uint256 secondsPassed = 0;

        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
    internal
    pure
    returns (uint256)
    {

        if (_secondsPassed >= _duration) {
            return _endingPrice;
        } else {
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);

            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);

            int256 currentPrice = int256(_startingPrice) + currentPriceChange;

            return uint256(currentPrice);
        }
    }

    function _computeCut(uint256 _price) internal view returns (uint256) {

        return _price * ownerCut / 10000;
    }
}


pragma solidity ^0.5.10;



contract ClockAuction is Pausable, ClockAuctionBase {


    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x80ac58cd);

    constructor (address _nftAddress, uint256 _cut) public {
        require(_cut <= 10000);
        ownerCut = _cut;

        ceoAddress = msg.sender;
        cfoAddress = msg.sender;

        DragonERC721 candidateContract = DragonERC721(_nftAddress);
        nonFungibleContract = candidateContract;
    }


    function withdrawBalance() external {

        address payable nftAddress = address(uint160(address(nonFungibleContract)));

        require(
            msg.sender == owner ||
            msg.sender == nftAddress
        );
        nftAddress.transfer(address(this).balance);
    }

    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address payable _seller
    )
    external
    whenNotPaused
    {

        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    function bid(uint256 _tokenId)
    external
    payable
    whenNotPaused
    {

        _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
    }

    function cancelAuction(uint256 _tokenId)
    external
    {

        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller || msg.sender == address(nonFungibleContract));
        _cancelAuction(_tokenId, seller);
    }

    function cancelAuctionWhenPaused(uint256 _tokenId)
    whenPaused
    onlyOwner
    external
    {

        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }

    function getAuction(uint256 _tokenId)
    external
    view
    returns
    (
        address payable seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {

        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
        auction.seller,
        auction.startingPrice,
        auction.endingPrice,
        auction.duration,
        auction.startedAt
        );
    }

    function getCurrentPrice(uint256 _tokenId)
    external
    view
    returns (uint256)
    {

        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }
}


pragma solidity ^0.5.10;


contract SaleClockAuction is ClockAuction {


    bool public isSaleClockAuction = true;

    constructor(address _nftAddr, uint256 _cut) public
    ClockAuction(_nftAddr, _cut) {}

    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address payable _seller
    )
    external
    {

        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);

        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    function bid(uint256 _tokenId)
    external
    payable
    {

        _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
    }

    function setOwnerCut(uint256 val) external onlyCEOCFO {

        ownerCut = val;
    }
}


pragma solidity ^0.5.10;


contract SiringClockAuction is ClockAuction {


    bool public isSiringClockAuction = true;

    constructor(address _nftAddr, uint256 _cut) public
    ClockAuction(_nftAddr, _cut) {}

    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address payable _seller
    )
    external
    {

        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    function bid(uint256 _tokenId)
    external
    payable
    {

        require(msg.sender == address(nonFungibleContract));
        address seller = tokenIdToAuction[_tokenId].seller;
        _bid(_tokenId, msg.value);
        _transfer(seller, _tokenId);
    }

    function setOwnerCut(uint256 val) external onlyCEOCFO {

        ownerCut = val;
    }

}


pragma solidity ^0.5.10;





contract DragonBase is DragonAccessControl, DragonERC721 {


    event Birth(address owner, uint256 dragonId, uint256 matronId, uint256 sireId, uint256 dna, uint32 generation, uint64 runeLevel);
    event DragonAssetsUpdated(uint256 _dragonId, uint64 _rune, uint64 _agility, uint64 _strength, uint64 _intelligence);
    event DragonAssetRequest(uint256 _dragonId);

    struct Dragon {
        uint256 dna;
        uint64 birthTime;
        uint64 breedTime;
        uint32 matronId;
        uint32 sireId;
        uint32 siringWithId;
        uint32 generation;
    }

    struct DragonAssets {
        uint64 runeLevel;
        uint64 agility;
        uint64 strength;
        uint64 intelligence;
    }

    Dragon[] dragons;
    mapping (uint256 => address) public dragonIndexToOwner;
    mapping (address => uint256) ownershipTokenCount;
    mapping (uint256 => address) public dragonIndexToApproved;
    mapping (uint256 => address) public sireAllowedToAddress;
    mapping (uint256 => DragonAssets) public dragonAssets;

    mapping (address => mapping (address => bool)) internal authorised;

    uint256 public updateAssetFee = 8 finney;

    SaleClockAuction public saleAuction;
    SiringClockAuction public siringAuction;

    modifier isValidToken(uint256 _tokenId) {

        require(dragonIndexToOwner[_tokenId] != address(0));
        _;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {

        ownershipTokenCount[_to]++;
        dragonIndexToOwner[_tokenId] = _to;
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            delete sireAllowedToAddress[_tokenId];
            delete dragonIndexToApproved[_tokenId];
        }


        emit Transfer(_from, _to, _tokenId);
    }

    function _createDragon(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _dna,
        uint64 _agility,
        uint64 _strength,
        uint64 _intelligence,
        uint64 _runelevel,
        address _owner
    )
    internal
    returns (uint)
    {

        require(_matronId == uint256(uint32(_matronId)));
        require(_sireId == uint256(uint32(_sireId)));
        require(_generation == uint256(uint32(_generation)));

        Dragon memory _dragon = Dragon({
            dna: _dna,
            birthTime: uint64(now),
            breedTime: 0,
            matronId: uint32(_matronId),
            sireId: uint32(_sireId),
            siringWithId: 0,
            generation: uint32(_generation)
            });

        DragonAssets memory _dragonAssets = DragonAssets({
            runeLevel: _runelevel,
            agility: _agility,
            strength: _strength,
            intelligence: _intelligence
            });

        uint256 newDragonId = dragons.push(_dragon) - 1;

        dragonAssets[newDragonId] = _dragonAssets;

        require(newDragonId == uint256(uint32(newDragonId)));

        emit Birth(
            _owner,
            newDragonId,
            uint256(_dragon.matronId),
            uint256(_dragon.sireId),
            _dragon.dna,
            _dragon.generation,
            _runelevel
        );

        _transfer(address(0), _owner, newDragonId);

        return newDragonId;
    }

    function setUpdateAssetFee(uint256 newFee) external onlyCLevel {

        updateAssetFee = newFee;
    }


    function updateDragonAsset(uint256 _dragonId, uint64 _rune, uint64 _agility, uint64 _strength, uint64 _intelligence)
    external
    whenNotPaused
    onlyCOO
    {


        DragonAssets storage currentDragonAsset = dragonAssets[_dragonId];

        require(_rune > currentDragonAsset.runeLevel);
        require(_agility >= currentDragonAsset.agility);
        require(_strength >= currentDragonAsset.strength);
        require(_intelligence >= currentDragonAsset.intelligence);

        DragonAssets memory _dragonAsset = DragonAssets({
            runeLevel: _rune,
            agility: _agility,
            strength: _strength,
            intelligence: _intelligence
            });

        dragonAssets[_dragonId] = _dragonAsset;
        msg.sender.transfer(updateAssetFee);
        emit DragonAssetsUpdated(_dragonId, _rune, _agility, _strength, _intelligence);

    }

    function requestAssetUpdate(uint256 _dragonId, uint256 _rune)
    external
    payable
    whenNotPaused
    {

        require(msg.value >= updateAssetFee);

        DragonAssets storage currentDragonAsset = dragonAssets[_dragonId];
        require(_rune > currentDragonAsset.runeLevel);

        emit DragonAssetRequest(_dragonId);

    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool)
    {

        return authorised[_owner][_operator];
    }

    function setApprovalForAll(address _operator, bool _approved) external
    {

        emit ApprovalForAll(msg.sender,_operator, _approved);
        authorised[msg.sender][_operator] = _approved;
    }

    function tokenURI(uint256 _tokenId) external view isValidToken(_tokenId) returns (string memory)
    {

        uint maxlength = 78;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        uint _tmpTokenId = _tokenId;
        uint _offset = 48;

        bytes memory _uriBase;
        _uriBase = bytes(tokenURIPrefix);

        while (_tmpTokenId != 0) {
            uint remainder = _tmpTokenId % 10;
            _tmpTokenId = _tmpTokenId / 10;
            reversed[i++] = byte(uint8(_offset + remainder));
        }

        bytes memory s = new bytes(_uriBase.length + i);
        uint j;

        for (j = 0; j < _uriBase.length; j++) {
            s[j] = _uriBase[j];
        }
        for (j = 0; j < i; j++) {
            s[j + _uriBase.length] = reversed[i - 1 - j];
        }
        return string(s);
    }
}


pragma solidity ^0.5.10;


contract DragonOwnership is DragonBase {


    string public constant name = "Drakons";
    string public constant symbol = "DRKNS";




    function setTokenURIAffixes(string calldata _prefix, string calldata _suffix) external onlyCEO {

        tokenURIPrefix = _prefix;
        tokenURISuffix = _suffix;
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {

        return dragonIndexToOwner[_tokenId] == _claimant;
    }

    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {

        return dragonIndexToApproved[_tokenId] == _claimant;
    }

    function _approve(uint256 _tokenId, address _approved) internal {

        dragonIndexToApproved[_tokenId] = _approved;
    }

    function balanceOf(address _owner) public view returns (uint256 count) {

        return ownershipTokenCount[_owner];
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public payable
    {

        require(_to != address(0));
        require(_to != address(this));
        require(_to != address(saleAuction));
        require(_to != address(siringAuction));

        address owner = ownerOf(_tokenId);
        require(owner == _from);
        require (owner == msg.sender || dragonIndexToApproved[_tokenId] == msg.sender || authorised[owner][msg.sender]);

        _transfer(_from, _to, _tokenId);

        uint32 size;
        assembly {
            size := extcodesize(_to)
        }

        if(size > 0) {
            ERC721TokenReceiver receiver = ERC721TokenReceiver(_to);
            require(receiver.onERC721Received(msg.sender,_from,_tokenId,data) == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable
    {

        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transfer(
        address _to,
        uint256 _tokenId
    )
    external
    whenNotPaused
    {

        require(_to != address(0));
        require(_to != address(this));
        require(_to != address(saleAuction));
        require(_to != address(siringAuction));

        require(_owns(msg.sender, _tokenId));

        _transfer(msg.sender, _to, _tokenId);
    }

    function ownerOf(uint256 _tokenId) public view isValidToken(_tokenId) returns (address)
    {

        return dragonIndexToOwner[_tokenId];
    }

    function approve(address _approved, uint256 _tokenId) external payable whenNotPaused {

        address owner = dragonIndexToOwner[_tokenId];
        require(owner == msg.sender || authorised[owner][msg.sender]);

        _approve(_tokenId, _approved);

        emit Approval(owner, _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) external view isValidToken(_tokenId) returns (address)
    {

        return dragonIndexToApproved[_tokenId];
    }


    function transferFrom(address _from, address _to, uint256 _tokenId) external payable whenNotPaused
    {

        require(_to != address(0));
        require(_to != address(this));
        address owner = ownerOf(_tokenId);
        require(owner == _from);
        require (owner == msg.sender || dragonIndexToApproved[_tokenId] == msg.sender || authorised[owner][msg.sender]);

        _transfer(_from, _to, _tokenId);
    }

    function totalSupply() public view returns (uint) {

        return dragons.length - 1;
    }

    function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {

        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalDragons = totalSupply();
            uint256 resultIndex = 0;

            uint256 dragonId;

            for (dragonId = 1; dragonId <= totalDragons; dragonId++) {
                if (dragonIndexToOwner[dragonId] == _owner) {
                    result[resultIndex] = dragonId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    function tokenByIndex(uint256 _index) external view returns (uint256)
    {

        return _index;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 dragonId)
    {

        uint256 count = 0;
        for (uint256 i = 1; i <= totalSupply(); ++i) {
            if (dragonIndexToOwner[i] == _owner) {
                if (count == _index) {
                    return i;
                } else {
                    count++;
                }
            }
        }
        revert();
    }
}


pragma solidity ^0.5.10;


contract DragonBreeding is DragonOwnership {


    event Pregnant(address owner, uint256 matronId, uint256 sireId);

    uint256 public autoBirthFee = 2 finney;

    uint256 public pregnantDragons;

    uint32 public BREEDING_LIMIT = 3;
    mapping(uint256 => uint64) breeding;





    function _isReadyToBreed(Dragon storage _dragon) internal view returns (bool) {

        return (_dragon.siringWithId == 0);
    }

    function _isSiringPermitted(uint256 _sireId, uint256 _matronId) internal view returns (bool) {

        address matronOwner = dragonIndexToOwner[_matronId];
        address sireOwner = dragonIndexToOwner[_sireId];

        return (matronOwner == sireOwner || sireAllowedToAddress[_sireId] == matronOwner);
    }



    function approveSiring(address _addr, uint256 _sireId)
    external
    whenNotPaused
    {

        require(_owns(msg.sender, _sireId));
        sireAllowedToAddress[_sireId] = _addr;
    }

    function setAutoBirthFee(uint256 val) external onlyCLevel {

        autoBirthFee = val;
    }

    function _isReadyToGiveBirth(Dragon storage _matron) private view returns (bool) {

        return (_matron.siringWithId != 0);
    }

    function isReadyToBreed(uint256 _dragonId)
    public
    view
    returns (bool)
    {

        require(_dragonId > 0);
        Dragon storage dragon = dragons[_dragonId];
        return _isReadyToBreed(dragon);
    }

    function isPregnant(uint256 _dragonId)
    public
    view
    returns (bool)
    {

        require(_dragonId > 0);
        return dragons[_dragonId].siringWithId != 0;
    }

    function _isValidMatingPair(
        Dragon storage _matron,
        uint256 _matronId,
        Dragon storage _sire,
        uint256 _sireId
    )
    private
    view
    returns(bool)
    {

        if(breeding[_matronId] >= BREEDING_LIMIT) {
            return false;
        }

        uint256 sireElement = _sire.dna / 1e34;
        uint256 matronElement = _matron.dna / 1e34;

        if (sireElement != matronElement) {
          return false;
        }

        if (_matronId == _sireId) {
            return false;
        }

        if (_matron.matronId == _sireId || _matron.sireId == _sireId) {
            return false;
        }

        if (_sire.matronId == _matronId || _sire.sireId == _matronId) {
            return false;
        }

        if (_sire.matronId == 0 || _matron.matronId == 0) {
            return true;
        }

        if (_sire.matronId == _matron.matronId || _sire.matronId == _matron.sireId) {
            return false;
        }
        if (_sire.sireId == _matron.matronId || _sire.sireId == _matron.sireId) {
            return false;
        }

        return true;
    }

    function _canBreedWithViaAuction(uint256 _matronId, uint256 _sireId)
    internal
    view
    returns (bool)
    {

        Dragon storage matron = dragons[_matronId];
        Dragon storage sire = dragons[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId);
    }

    function canBreedWith(uint256 _matronId, uint256 _sireId)
    external
    view
    returns(bool)
    {

        require(_matronId > 0);
        require(_sireId > 0);
        Dragon storage matron = dragons[_matronId];
        Dragon storage sire = dragons[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId) &&
        _isSiringPermitted(_sireId, _matronId);
    }

    function _breedWith(uint256 _matronId, uint256 _sireId) internal {

        Dragon storage matron = dragons[_matronId];

        matron.siringWithId = uint32(_sireId);


        delete sireAllowedToAddress[_matronId];
        delete sireAllowedToAddress[_sireId];

        pregnantDragons++;

        emit Pregnant(dragonIndexToOwner[_matronId], _matronId, _sireId);
    }

    function breedWithAuto(uint256 _matronId, uint256 _sireId)
    external
    payable
    whenNotPaused
    {

        require(msg.value >= autoBirthFee);

        require(_owns(msg.sender, _matronId));


        require(_isSiringPermitted(_sireId, _matronId));

        Dragon storage matron = dragons[_matronId];

        require(_isReadyToBreed(matron));

        Dragon storage sire = dragons[_sireId];

        require(_isReadyToBreed(sire));

        matron.breedTime = uint64(now);

        require(_isValidMatingPair(
                matron,
                _matronId,
                sire,
                _sireId
            ));


        _breedWith(_matronId, _sireId);
    }

    function giveBirth(uint256 _matronId, uint256 _dna, uint64 _agility, uint64 _strength, uint64 _intelligence, uint64 _runelevel)
    external
    whenNotPaused
    onlyCOO
    returns(uint256)
    {

        Dragon storage matron = dragons[_matronId];

        require(matron.birthTime != 0);

        require(_isReadyToGiveBirth(matron));

        uint256 sireId = matron.siringWithId;
        Dragon storage sire = dragons[sireId];

        uint32 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }

        uint256 matronId = _matronId;
        uint64 agility = _agility;
        uint64 strength = _strength;
        uint64 intelligence = _intelligence;
        uint64 runelevel = _runelevel;

        uint256 childDNA = _dna;

        address owner = dragonIndexToOwner[matronId];
        uint256 dragonId = _createDragon(matronId, sireId, parentGen + 1, childDNA, agility, strength, intelligence, runelevel, owner);

        breeding[matronId]++;

        delete matron.siringWithId;

        pregnantDragons--;

        msg.sender.transfer(autoBirthFee);

        return dragonId;
    }

    function getPregnantDragons() external view returns(uint256[] memory pregnantDragonsList) {


        if (pregnantDragons == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](pregnantDragons);
            uint256 totalDragons = totalSupply();
            uint256 resultIndex = 0;

             uint256 dragonId;

            for (dragonId = 1; dragonId <= totalDragons; dragonId++) {
                if (isPregnant(dragonId)) {
                    result[resultIndex] = dragonId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    function setBreedingLimit(uint32 _value) external onlyCLevel {

        BREEDING_LIMIT = _value;
    }
}


pragma solidity ^0.5.10;


contract DragonAuction is DragonBreeding {



    function setSaleAuctionAddress(address _address) external onlyCEO {

        SaleClockAuction candidateContract = SaleClockAuction(_address);

        require(candidateContract.isSaleClockAuction());

        saleAuction = candidateContract;
    }

    function setSiringAuctionAddress(address _address) external onlyCEO {

        SiringClockAuction candidateContract = SiringClockAuction(_address);

        require(candidateContract.isSiringClockAuction());

        siringAuction = candidateContract;
    }

    function createSaleAuction(
        uint256 _dragonId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
    external
    whenNotPaused
    {

        require(_owns(msg.sender, _dragonId));
        require(!isPregnant(_dragonId));
        _approve(_dragonId, address(saleAuction));
        saleAuction.createAuction(
            _dragonId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    function createSiringAuction(
        uint256 _dragonId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
    external
    whenNotPaused
    {

        require(_owns(msg.sender, _dragonId));
        require(isReadyToBreed(_dragonId));
        _approve(_dragonId, address(siringAuction));
        siringAuction.createAuction(
            _dragonId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }


    function bidOnSiringAuction(
        uint256 _sireId,
        uint256 _matronId
    )
    external
    payable
    whenNotPaused
    {

        require(_owns(msg.sender, _matronId));
        require(isReadyToBreed(_matronId));
        require(_canBreedWithViaAuction(_matronId, _sireId));

        uint256 currentPrice = siringAuction.getCurrentPrice(_sireId);
        require(msg.value >= currentPrice + autoBirthFee);

        siringAuction.bid.value(msg.value - autoBirthFee)(_sireId);
        _breedWith(uint32(_matronId), uint32(_sireId));
    }

    function withdrawAuctionBalances() external onlyCLevel {

        saleAuction.withdrawBalance();
        siringAuction.withdrawBalance();
    }

    function getAuctionBalances() external view onlyCLevel returns (uint256, uint256) {

        return (
            address(saleAuction).balance,
            address(siringAuction).balance
        );
    }
}


pragma solidity ^0.5.10;


contract DragonMinting is DragonAuction {


    function createPromoDragon(
        uint256 _dna,
        uint64 _agility,
        uint64 _strength,
        uint64 _intelligence,
        uint64 _runelevel,
        address _owner)
        external onlyCLevel {


        address dragonOwner = _owner;
        if (dragonOwner == address(0)) {
            dragonOwner = cmoAddress;
        }

        _createDragon(0, 0, 0, _dna, _agility, _strength, _intelligence, _runelevel, dragonOwner);
    }

    function createGen0Auction(
        uint256 _dna,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint64 _agility,
        uint64 _strength,
        uint64 _intelligence,
        uint256 _duration )
        external onlyCLevel {




        uint256 dragonId = _createDragon(0, 0, 0, _dna, _agility, _strength, _intelligence, 0, address(this));
        _approve(dragonId, address(saleAuction));

        saleAuction.createAuction(
            dragonId,
            _startingPrice,
            _endingPrice,
            _duration,
            address(uint160(address(this)))
        );

    }
}


pragma solidity ^0.5.10;


contract DragonCore is DragonMinting {


    address public newContractAddress;

    constructor () public {
        paused = true;

        ceoAddress = msg.sender;

        cmoAddress = msg.sender;

        cioAddress = msg.sender;

        cfoAddress = msg.sender;

        cooAddress = msg.sender;

        supportedInterfaces[0x01ffc9a7] = true;

        supportedInterfaces[0x80ac58cd] = true;

        supportedInterfaces[0x5b5e139f] = true;

        supportedInterfaces[0x780e9d63] = true;

        supportedInterfaces[0x150b7a02] = true;

        _createDragon(0, 0, 0, uint256(-1), 0,0,0,0,  address(0));
    }

    function setNewAddress(address _newAddress) external onlyCEO whenPaused {

        newContractAddress = _newAddress;
        emit ContractUpgrade(_newAddress);
    }

    function() external payable {
        require(
            msg.sender == address(saleAuction) ||
            msg.sender == address(siringAuction)
        );
    }
    function getDragon(uint256 _id)
    external
    view
    returns (
        uint256 dna,
        uint256 birthTime,
        uint256 breedTime,
        uint256 matronId,
        uint256 sireId,
        uint256 siringWithId,
        uint256 generation,
        uint256 runeLevel,
        uint256 agility,
        uint256 strength,
        uint256 intelligence
    ) {

        Dragon storage dragon = dragons[_id];
        DragonAssets storage dragonAsset = dragonAssets[_id];

        dna = dragon.dna;
        birthTime = uint256(dragon.birthTime);
        breedTime = uint256(dragon.breedTime);
        matronId = uint256(dragon.matronId);
        sireId = uint256(dragon.sireId);
        siringWithId = uint256(dragon.siringWithId);
        generation = uint256(dragon.generation);
        runeLevel = dragonAsset.runeLevel;
        agility = dragonAsset.agility;
        strength = dragonAsset.strength;
        intelligence = dragonAsset.intelligence;
    }

    function unpause() public onlyCEO whenPaused {

        require(address(saleAuction) != address(0));
        require(address(siringAuction) != address(0));
        require(newContractAddress == address(0));

        super.unpause();
    }

    function withdrawBalance() external onlyCLevel {

        uint256 balance = address(this).balance;
        uint256 subtractFees = (pregnantDragons + 1) * autoBirthFee;

        if (balance > subtractFees) {
            cfoAddress.transfer(balance - subtractFees);
        }
    }

    function getBalance() external view onlyCLevel returns (uint256) {

        return address(this).balance;
    }
}