
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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
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

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.8.9;



abstract contract AdminControl is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event AdminApproved(address indexed account, address indexed sender);
    event AdminRevoked(address indexed account, address indexed sender);

    EnumerableSet.AddressSet private _admins;

    modifier adminRequired() {
        require(owner() == msg.sender || _admins.contains(msg.sender), "AdminControl: Must be owner or admin");
        _;
    }   

    function getAdmins() external view returns (address[] memory admins) {
        admins = new address[](_admins.length());
        for (uint i = 0; i < _admins.length(); i++) {
            admins[i] = _admins.at(i);
        }
        return admins;
    }

    function approveAdmin(address admin) external onlyOwner {
        if (!_admins.contains(admin)) {
            emit AdminApproved(admin, msg.sender);
            _admins.add(admin);
        }
    }

    function revokeAdmin(address admin) external onlyOwner {
        if (_admins.contains(admin)) {
            emit AdminRevoked(admin, msg.sender);
            _admins.remove(admin);
        }
    }

    function isAdmin(address admin) public view returns (bool) {
        return (owner() == admin || _admins.contains(admin));
    }

}// MIT
pragma solidity ^0.8.0 <0.9.0;




contract PunksMarket is AdminControl, Pausable , ReentrancyGuard{


    IERC721 public punksWrapperContract; // instance of the Cryptopunks contract
    ICryptoPunk public punkContract; // Instance of cryptopunk smart contract

    struct Offer {
        bool isForSale;
        uint punkIndex;
        address seller;
        uint256 minValue;          // in WEI
        address onlySellTo;
    }

    struct Bid {
        bool hasBid;
        uint punkIndex;
        address bidder;
        uint256 value;
    }

    struct Punk {
        bool wrapped;
        address owner;
        Bid bid;
        Offer offer;
    }

    uint256 public totalVolume;
    uint constant public TOTAL_PUNKS = 10000;

    mapping (uint => Offer) private punksOfferedForSale;

    mapping (uint => Bid) private punkBids;

    event PunkOffered(uint indexed punkIndex, uint minValue, address indexed toAddress);
    event PunkBidEntered(uint indexed punkIndex, uint value, address indexed fromAddress);
    event PunkBidWithdrawn(uint indexed punkIndex, uint value, address indexed fromAddress);
    event PunkBought(uint indexed punkIndex, uint value, address indexed fromAddress, address indexed toAddress);
    event PunkNoLongerForSale(uint indexed punkIndex);

    constructor() {
        punksWrapperContract = IERC721(0x7898972F9708358ACb7Ea7d000EbDf28FCdF325C); // TODO change on deploy main net
        punkContract = ICryptoPunk(0x85252f525456D3fCe3654e56f6EAF034075e231C); // TODO change on deploy main net
    }

    function setPunksWrapperContract(address newpunksAddress) public onlyOwner {

      punksWrapperContract = IERC721(newpunksAddress);
    }

    function punkNoLongerForSale(uint punkIndex) public nonReentrant() {

        require(punkIndex < 10000,"Token index not valid");
        require(punksWrapperContract.ownerOf(punkIndex) == msg.sender,"you are not the owner of this token");
        punksOfferedForSale[punkIndex] = Offer(false, punkIndex, msg.sender, 0, address(0x0));
        emit PunkNoLongerForSale(punkIndex);
    }

    function offerPunkForSale(uint punkIndex, uint minSalePriceInWei) public whenNotPaused nonReentrant()  {

        require(punkIndex < 10000,"Token index not valid");
        require(punksWrapperContract.ownerOf(punkIndex) == msg.sender,"you are not the owner of this token");
        punksOfferedForSale[punkIndex] = Offer(true, punkIndex, msg.sender, minSalePriceInWei, address(0x0));
        emit PunkOffered(punkIndex, minSalePriceInWei, address(0x0));
    }

    function offerPunkForSaleToAddress(uint punkIndex, uint minSalePriceInWei, address toAddress) public whenNotPaused nonReentrant() {

        require(punkIndex < 10000,"Token index not valid");
        require(punksWrapperContract.ownerOf(punkIndex) == msg.sender,"you are not the owner of this token");
        punksOfferedForSale[punkIndex] = Offer(true, punkIndex, msg.sender, minSalePriceInWei, toAddress);
        emit PunkOffered(punkIndex, minSalePriceInWei, toAddress);
    }
    

    function buyPunk(uint punkIndex) payable public whenNotPaused nonReentrant() {

        require(punkIndex < 10000,"Token index not valid");
        Offer memory offer = punksOfferedForSale[punkIndex];
        require (offer.isForSale,"Punk is not for sale"); // punk not actually for sale
        require (offer.onlySellTo == address(0x0) || offer.onlySellTo == msg.sender,"Private sale.") ;                
        require (msg.value >= offer.minValue,"Not enough ether send"); // Didn't send enough ETH
        address seller = offer.seller;
        require  (seller == punksWrapperContract.ownerOf(punkIndex),'seller no longer owner of punk'); // Seller no longer owner of punk

        punksOfferedForSale[punkIndex] = Offer(false, punkIndex, msg.sender, 0, address(0x0));
        _withdraw(seller,msg.value);
        totalVolume += msg.value;
        punksWrapperContract.safeTransferFrom(seller, msg.sender, punkIndex);

        emit PunkBought(punkIndex, msg.value, seller, msg.sender);

        Bid memory bid = punkBids[punkIndex];
        if (bid.bidder == msg.sender) {
            _withdraw(msg.sender,bid.value);
            punkBids[punkIndex] = Bid(false, punkIndex, address(0x0), 0);
        }
    }
    function enterBidForPunk(uint punkIndex) payable public whenNotPaused nonReentrant() {

        require(punkIndex < 10000,"Token index not valid");
        require (punksWrapperContract.ownerOf(punkIndex) != msg.sender,"You already own this punk");
        require (msg.value > 0,"Cannot enter bid of zero");
        Bid memory existing = punkBids[punkIndex];
        require (msg.value > existing.value,"your bid is too low");
        if (existing.value > 0) {
            _withdraw(existing.bidder,existing.value);
        }
        punkBids[punkIndex] = Bid(true, punkIndex, msg.sender, msg.value);
        emit PunkBidEntered(punkIndex, msg.value, msg.sender);
    }

    function acceptBidForPunk(uint punkIndex, uint minPrice) public whenNotPaused nonReentrant() {

        require(punkIndex < 10000,"Token index not valid");
        require(punksWrapperContract.ownerOf(punkIndex) == msg.sender,'you are not the owner of this token');
        address seller = msg.sender;
        Bid memory bid = punkBids[punkIndex];
        require(bid.hasBid == true,"Punk has no bid"); 
        require (bid.value >= minPrice,"The bid is too low");

        address bidder = bid.bidder;
        punksOfferedForSale[punkIndex] = Offer(false, punkIndex, bidder, 0, address(0x0));
        uint amount = bid.value;
        punkBids[punkIndex] = Bid(false, punkIndex, address(0x0), 0);

        _withdraw(seller,amount); 
        totalVolume += amount;
        punksWrapperContract.safeTransferFrom(msg.sender, bidder, punkIndex);

        emit PunkBought(punkIndex, bid.value, seller, bidder);
    }

    function withdrawBidForPunk(uint punkIndex) public nonReentrant() {

        require(punkIndex < 10000,"token index not valid");
        Bid memory bid = punkBids[punkIndex];
        require (bid.bidder == msg.sender,"The bidder is not message sender");
        emit PunkBidWithdrawn(punkIndex, bid.value, msg.sender);
        uint amount = bid.value;
        punkBids[punkIndex] = Bid(false, punkIndex, address(0x0), 0);
        _withdraw(msg.sender,amount);
    }

    function getBid(uint punkIndex) external view returns (Bid memory){

        return punkBids[punkIndex];
    }

    function getOffer(uint punkIndex) external view returns (Offer memory){

        return punksOfferedForSale[punkIndex];
    }

    function getPunksDetails(uint index) external view returns (Punk memory) {

            address owner = punkContract.punkIndexToAddress(index);
            bool wrapper = false;
            if (owner==address(punksWrapperContract)){
                owner = punksWrapperContract.ownerOf(index);
                wrapper = true;
            }
            Punk memory punks=Punk(wrapper,owner,punkBids[index],punksOfferedForSale[index]);
        return punks;
    }

    function getAllWrappedPunks() external view returns (int[] memory){

        int[] memory ids = new int[](TOTAL_PUNKS);
        for (uint i=0; i<TOTAL_PUNKS; i++) {
            ids[i]= 11111;
        }
        uint256 j =0;
        for (uint256 i=0; i<TOTAL_PUNKS; i++) {
            if ( punkContract.punkIndexToAddress(i) == address(punksWrapperContract)) {
                ids[j] = int(i);
                j++;
            }
        }
        return ids;
    }

    function getPunksForAddress(address user) external view returns(uint256[] memory) {

        uint256[] memory punks = new uint256[](punkContract.balanceOf(user));
        uint256 j =0;
        for (uint256 i=0; i<TOTAL_PUNKS; i++) {
            if ( punkContract.punkIndexToAddress(i) == user ) {
                punks[j] = i;
                j++;
            }
        }
        return punks;
    }

    function getWrappedPunksForAddress(address user) external view returns(uint256[] memory) {

        uint256[] memory punks = new uint256[](punksWrapperContract.balanceOf(user));
        uint256 j =0;
        for (uint256 i=0; i<TOTAL_PUNKS; i++) {
            try punksWrapperContract.ownerOf(i) returns (address owner){
                if ( owner == user ) {
                    punks[j] = i;
                    j++;
                }
            } catch {
            }
        }
        return punks;
    }

    function _withdraw(address _address, uint256 _amount) private {

        (bool success, ) = _address.call{ value: _amount }("");
        require(success, "Failed to send Ether");
    }

    function returnBid(uint punkIndex) public adminRequired {

        Bid memory bid = punkBids[punkIndex];
        uint amount = bid.value;
        address bidder = bid.bidder;
        punkBids[punkIndex] = Bid(false, punkIndex, address(0x0), 0);
        emit PunkBidWithdrawn(punkIndex, amount, bidder);
        _withdraw(bidder,amount);
    }
    function revokeSale(uint punkIndex) public adminRequired {

        require(punkIndex < 10000,"Token index not valid");
        punksOfferedForSale[punkIndex] = Offer(false, punkIndex, address(0x0), 0, address(0x0));
        emit PunkNoLongerForSale(punkIndex);
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    fallback() external payable { }
    receive() external payable { }

}

interface ICryptoPunk {

    function punkIndexToAddress(uint punkIndex) external view returns (address);

    function buyPunk(uint punkIndex) external payable;

    function transferPunk(address to, uint punkIndex) external;

    function balanceOf(address) external view returns (uint);

}// MIT
pragma solidity ^0.8.0 <0.9.0;



 contract MPHelper{

    PunksMarket public mPContract;

    constructor() {
        mPContract = PunksMarket(payable(0x759c6C1923910930C18ef490B3c3DbeFf24003cE));
        }

    function getAllBids(uint256[] memory ids) external view returns (PunksMarket.Punk[] memory){

        uint tokens = 0;
        for (uint i=0; i<ids.length; i++) {
            PunksMarket.Punk memory punk = mPContract.getPunksDetails(ids[i]);
            if (punk.bid.hasBid && !isForSale(punk)){
                tokens+=1;
            }
        }
        PunksMarket.Punk[] memory punks = new PunksMarket.Punk[](tokens);
        uint index = 0;
        for (uint i=0; i<ids.length; i++) {
            PunksMarket.Punk memory punk = mPContract.getPunksDetails(ids[i]);
            if (punk.bid.hasBid && !isForSale(punk)){
                punks[index]=mPContract.getPunksDetails(ids[i]);
                index +=1;
            }
        }

        return punks;
    }

    function getAllForSale(uint256[] memory ids) external view returns (PunksMarket.Punk[] memory){

        uint tokens = 0;
        for (uint i=0; i<ids.length; i++) {
            PunksMarket.Punk memory punk = mPContract.getPunksDetails(ids[i]);
            if (isForSale(punk)){
                tokens+=1;
            }
        }
        PunksMarket.Punk[] memory punks = new PunksMarket.Punk[](tokens);
        uint index = 0;
        for (uint i=0; i<ids.length; i++) {
            PunksMarket.Punk memory punk = mPContract.getPunksDetails(ids[i]);
            if (isForSale(punk)){
                punks[index]=mPContract.getPunksDetails(ids[i]);
                index +=1;
            }
        }
        return punks;
    }

    function getDetailsForIds(uint256[] memory ids) external view returns (PunksMarket.Punk[] memory){

        PunksMarket.Punk[] memory punks = new PunksMarket.Punk[](ids.length);
        for (uint i=0; i<ids.length; i++) {
            punks[i]=mPContract.getPunksDetails(ids[i]);
        }
        return punks;
    }

    function isForSale(PunksMarket.Punk memory punk) public pure returns (bool){

        return punk.offer.isForSale && punk.owner==punk.offer.seller;
    }

 }