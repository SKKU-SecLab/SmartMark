
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
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT


pragma solidity ^0.8.0;



interface INFTContract {

    function Mint(address _to, uint256 _quantity) external payable;

    function numberMinted(address owner) external view returns (uint256);

    function totalSupplyExternal() external view returns (uint256);

}


contract TroverseMinter is Ownable, ReentrancyGuard {


    INFTContract public NFTContract;

    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public constant TOTAL_PLANETS = 10000;
    uint256 public constant MAX_MINT_PER_ADDRESS = 5;
    uint256 public constant RESERVED_PLANETS = 300;
    uint256 public constant RESERVED_OR_AUCTION_PLANETS = 7300;

    uint256 public constant AUCTION_START_PRICE = 1 ether;
    uint256 public constant AUCTION_END_PRICE = 0.1 ether;
    uint256 public constant AUCTION_PRICE_CURVE_LENGTH = 180 minutes;
    uint256 public constant AUCTION_DROP_INTERVAL = 20 minutes;
    uint256 public constant AUCTION_DROP_PER_STEP = 0.1 ether;

    uint256 public auctionSaleStartTime;
    uint256 public publicSaleStartTime;
    uint256 public whitelistPrice;
    uint256 public publicSalePrice;
    uint256 private publicSaleKey;

    mapping(address => uint256) public whitelist;

    uint256 public lastAuctionSalePrice = AUCTION_START_PRICE;
    mapping(address => uint256) public credits;
    mapping(address => uint256) public creditCount;
    EnumerableSet.AddressSet private _creditOwners;
    uint256 private _totalCredits;
    uint256 private _totalCreditCount;

    event CreditRefunded(address indexed owner, uint256 value);
    
    

    modifier callerIsUser() {

        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    constructor() { }

    function setNFTContract(address _NFTContract) external onlyOwner {

        NFTContract = INFTContract(_NFTContract);
    }

    function auctionMint(uint256 quantity) external payable callerIsUser {

        require(auctionSaleStartTime != 0 && block.timestamp >= auctionSaleStartTime, "Sale has not started yet");
        require(totalSupply() + quantity <= RESERVED_OR_AUCTION_PLANETS, "Not enough remaining reserved for auction to support desired mint amount");
        require(numberMinted(msg.sender) + quantity <= MAX_MINT_PER_ADDRESS, "Can not mint this many");

        lastAuctionSalePrice = getAuctionPrice();
        uint256 totalCost = lastAuctionSalePrice * quantity;

        if (lastAuctionSalePrice > AUCTION_END_PRICE) {
            _creditOwners.add(msg.sender);

            credits[msg.sender] += totalCost;
            creditCount[msg.sender] += quantity;

            _totalCredits += totalCost;
            _totalCreditCount += quantity;
        }

        NFTContract.Mint(msg.sender, quantity);
        refundIfOver(totalCost);
    }
    
    function whitelistMint(uint256 quantity) external payable callerIsUser {

        require(whitelistPrice != 0, "Whitelist sale has not begun yet");
        require(whitelist[msg.sender] > 0, "Not eligible for whitelist mint");
        require(whitelist[msg.sender] >= quantity, "Can not mint this many");
        require(totalSupply() + quantity <= TOTAL_PLANETS, "Reached max supply");

        whitelist[msg.sender] -= quantity;
        NFTContract.Mint(msg.sender, quantity);
        refundIfOver(whitelistPrice * quantity);
    }

    function publicSaleMint(uint256 quantity, uint256 key) external payable callerIsUser {

        require(publicSaleKey == key, "Called with incorrect public sale key");

        require(isPublicSaleOn(), "Public sale has not begun yet");
        require(totalSupply() + quantity <= TOTAL_PLANETS, "Reached max supply");
        require(numberMinted(msg.sender) + quantity <= MAX_MINT_PER_ADDRESS, "Can not mint this many");

        NFTContract.Mint(msg.sender, quantity);
        refundIfOver(publicSalePrice * quantity);
    }

    function refundIfOver(uint256 price) private {

        require(msg.value >= price, "Insufficient funds");

        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function isPublicSaleOn() public view returns (bool) {

        return publicSalePrice != 0 && block.timestamp >= publicSaleStartTime && publicSaleStartTime != 0;
    }

    function getAuctionPrice() public view returns (uint256) {

        if (block.timestamp < auctionSaleStartTime) {
            return AUCTION_START_PRICE;
        }
        
        if (block.timestamp - auctionSaleStartTime >= AUCTION_PRICE_CURVE_LENGTH) {
            return AUCTION_END_PRICE;
        } else {
            uint256 steps = (block.timestamp - auctionSaleStartTime) / AUCTION_DROP_INTERVAL;
            return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    function setAuctionSaleStartTime(uint256 timestamp) external onlyOwner {

        auctionSaleStartTime = timestamp;
    }

    function setWhitelistPrice(uint256 price) external onlyOwner {

        whitelistPrice = price;
    }

    function setPublicSalePrice(uint256 price) external onlyOwner {

        publicSalePrice = price;
    }

    function setPublicSaleStartTime(uint256 timestamp) external onlyOwner {

        publicSaleStartTime = timestamp;
    }

    function setPublicSaleKey(uint256 key) external onlyOwner {

        publicSaleKey = key;
    }

    function addWhitelist(address[] memory addresses, uint256 limit) external onlyOwner {

        for (uint256 i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = limit;
        }
    }

    function reserveMint(uint256 quantity) external onlyOwner {

        require(totalSupply() + quantity <= RESERVED_PLANETS, "Too many already minted before dev mint");
        NFTContract.Mint(msg.sender, quantity);
    }

    function isAuctionPriceFinalized() public view returns(bool) {

        return totalSupply() >= RESERVED_OR_AUCTION_PLANETS || lastAuctionSalePrice == AUCTION_END_PRICE;
    }

    function getRemainingCredits(address owner) external view returns(uint256) {

        if (credits[owner] > 0) {
            return credits[owner] - lastAuctionSalePrice * creditCount[owner];
        }
        return 0;
    }
    
    function getTotalRemainingCredits() public view returns(uint256) {

        return _totalCredits - lastAuctionSalePrice * _totalCreditCount;
    }
    
    function getMaxPossibleCredits() public view returns(uint256) {

        if (isAuctionPriceFinalized()) {
            return getTotalRemainingCredits();
        }

        return _totalCredits - AUCTION_END_PRICE * _totalCreditCount;
    }

    function refundRemainingCredits() external nonReentrant {

        require(isAuctionPriceFinalized(), "Auction price is not finalized yet!");
        require(_creditOwners.contains(msg.sender), "Not a credit owner!");
        
        uint256 remainingCredits = credits[msg.sender];
        uint256 remainingCreditCount = creditCount[msg.sender];
        uint256 toSendCredits = remainingCredits - lastAuctionSalePrice * remainingCreditCount;

        require(toSendCredits > 0, "No credits to refund!");

        delete credits[msg.sender];
        delete creditCount[msg.sender];

        _creditOwners.remove(msg.sender);

        _totalCredits -= remainingCredits;
        _totalCreditCount -= remainingCreditCount;

        emit CreditRefunded(msg.sender, toSendCredits);

        require(payable(msg.sender).send(toSendCredits));
    }

    function refundAllRemainingCreditsByCount(uint256 count) external onlyOwner {

        require(isAuctionPriceFinalized(), "Auction price is not finalized yet!");
        
        address toSendWallet;
        uint256 toSendCredits;
        uint256 remainingCredits;
        uint256 remainingCreditCount;
        
        uint256 j = 0;
        while (_creditOwners.length() > 0 && j < count) {
            toSendWallet = _creditOwners.at(0);
            
            remainingCredits = credits[toSendWallet];
            remainingCreditCount = creditCount[toSendWallet];
            toSendCredits = remainingCredits - lastAuctionSalePrice * remainingCreditCount;
            
            delete credits[toSendWallet];
            delete creditCount[toSendWallet];
            _creditOwners.remove(toSendWallet);

            if (toSendCredits > 0) {
                require(payable(toSendWallet).send(toSendCredits));
                emit CreditRefunded(toSendWallet, toSendCredits);

                _totalCredits -= toSendCredits;
                _totalCreditCount -= remainingCreditCount;
            }
            j++;
        }
    }
    
    function withdrawAll(address to) external onlyOwner {

        uint256 maxPossibleCredits = getMaxPossibleCredits();
        require(address(this).balance > maxPossibleCredits, "No funds to withdraw");

        uint256 toWithdrawFunds = address(this).balance - maxPossibleCredits;
        require(payable(to).send(toWithdrawFunds), "Transfer failed");
    }
    
    function numberMinted(address owner) public view returns (uint256) {

        return NFTContract.numberMinted(owner);
    }

    function totalSupply() public view returns (uint256) {

        return NFTContract.totalSupplyExternal();
    }
}