pragma solidity ^0.8.0;

interface IQuantumArt {

    function mintTo(uint256 dropId, address artist) external returns (uint256);

    function burn(uint256 tokenId) external;

    function getArtist(uint256 dropId) external view returns (address);

    function balanceOf(address user) external view returns (uint256);

}// MIT
pragma solidity ^0.8.0;

interface IQuantumMintPass {

    function burnFromRedeem(address user, uint256 mpId, uint256 amount) external;

}// MIT
pragma solidity ^0.8.0;

interface IQuantumUnlocked {

    function mint(address to, uint128 dropId, uint256 variant) external returns (uint256);

}// MIT
pragma solidity ^0.8.0;

interface IQuantumKeyRing {

    function make(address to, uint256 id, uint256 amount) external;

    function ownerOf(uint256 tokenId) external view returns (address);

}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT
pragma solidity ^0.8.11;


abstract contract ContinuousDutchAuction {

    struct Auction {
        uint256 startingPrice;
        uint128 decreasingConstant;
        uint64 start;
        uint64 period; //period in seconds : MAX IS 18 HOURS
    }

    mapping (uint => Auction) internal _auctions;

    function auctions(uint256 auctionId) public view returns (
        uint256 startingPrice,
        uint128 decreasingConstant,
        uint64 start,
        uint64 period,
        bool active
    ) {
        Auction memory auction = _auctions[auctionId];
        startingPrice = auction.startingPrice;
        decreasingConstant = auction.decreasingConstant;
        start = auction.start;
        period = auction.period;
        active = start > 0 && block.timestamp >= start;
    }

    function setAuction(
        uint256 auctionId,
        uint256 startingPrice,
        uint128 decreasingConstant,
        uint64 start,
        uint64 period
    ) virtual public {
        unchecked {
            require(startingPrice - decreasingConstant * period <= startingPrice, "setAuction: floor price underflow");
        }
        _auctions[auctionId] = Auction(startingPrice, decreasingConstant, start, period);
    }

    function getPrice(uint256 auctionId) virtual public view returns (uint256 price) {
        Auction memory auction = _auctions[auctionId];
        if (block.timestamp < auction.start) price = auction.startingPrice;
        else if (block.timestamp >= auction.start + auction.period) price = auction.startingPrice - auction.period * auction.decreasingConstant;
        else price = auction.startingPrice - (auction.decreasingConstant * (block.timestamp - auction.start));
    }

    function verifyBid(uint256 auctionId) internal returns (uint256) {
        Auction memory auction = _auctions[auctionId];
        require(auction.start > 0, "AUCTION:NOT CREATED");
        require(block.timestamp >= auction.start, "PURCHASE:AUCTION NOT STARTED");
        uint256 pricePaid = getPrice(auctionId);
        require(msg.value >= pricePaid, "PURCHASE:INCORRECT MSG.VALUE");
        if (msg.value - pricePaid > 0) Address.sendValue(payable(msg.sender), msg.value-pricePaid); //refund difference
        return pricePaid;
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract Auth {
    event OwnerUpdated(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnerUpdated(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function setOwner(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

interface Authority {

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);

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

library BitMaps {

    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {

        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool value
    ) internal {

        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    function set(BitMap storage bitmap, uint256 index) internal {

        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    function unset(BitMap storage bitmap, uint256 index) internal {

        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
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
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}// MIT
pragma solidity ^0.8.11;


contract SalePlatform is ContinuousDutchAuction, ReentrancyGuard, Auth {

    using BitMaps for BitMaps.BitMap;
    using Strings for uint256;

    struct Sale {
        uint128 price;
        uint64 start;
        uint64 limit;
    }

    struct MPClaim {
        uint64 mpId;
        uint64 start;
        uint128 price;
    }

    struct Whitelist {
        uint192 price;
        uint64 start;
        bytes32 merkleRoot;
    }

    event Purchased(uint256 indexed dropId, uint256 tokenId, address to);
    event DropCreated(uint256 dropId);

    mapping (uint256 => Sale) public sales;
    mapping (uint256 => MPClaim) public mpClaims;
    mapping (uint256 => Whitelist) public whitelists;
    uint256 public defaultArtistCut; //10000 * percentage
    IQuantumArt public quantum;
    IQuantumMintPass public mintpass;
    IQuantumUnlocked public keyUnlocks;
    IQuantumKeyRing public keyRing;
    address[] public privilegedContracts;

    BitMaps.BitMap private _disablingLimiter;
    mapping (uint256 => BitMaps.BitMap) private _claimedWL;
    mapping (address => BitMaps.BitMap) private _alreadyBought;
    mapping (uint256 => uint256) private _overridedArtistCut; // dropId -> cut
    address payable private _quantumTreasury;

    struct UnlockSale {
        uint128 price;
        uint64 start;
        uint64 period;
        address artist;
        uint256 overrideArtistcut;
        uint256[] enabledKeyRanges;
    }

    uint private constant SEPARATOR = 10**4;
    uint128 private _nextUnlockDropId;
    mapping(uint256 => mapping(uint256 => bool)) keyUnlockClaims;
    mapping (uint256 => UnlockSale) public keySales;

    constructor(
        address deployedQuantum,
        address deployedMP,
        address deployedKeyRing,
        address deployedUnlocks,
        address admin,
        address payable treasury,
        address authority) Auth(admin, Authority(authority)) {
        quantum = IQuantumArt(deployedQuantum);
        mintpass = IQuantumMintPass(deployedMP);
        keyRing = IQuantumKeyRing(deployedKeyRing);
        keyUnlocks = IQuantumUnlocked(deployedUnlocks);
        _quantumTreasury = treasury;
        defaultArtistCut = 8000; //default 80% for artist
    }

    modifier checkCaller {

        require(msg.sender.code.length == 0, "Contract forbidden");
        _;
    }

    modifier isFirstTime(uint256 dropId) {

        if (!_disablingLimiter.get(dropId)) {
            require(!_alreadyBought[msg.sender].get(dropId), string(abi.encodePacked("Already bought drop ", dropId.toString())));
            _alreadyBought[msg.sender].set(dropId);
        }
        _;
    }

    function setPrivilegedContracts(address[] calldata contracts) requiresAuth public {

        privilegedContracts = contracts;
    }

    function withdraw(address payable to) requiresAuth public {

        Address.sendValue(to, address(this).balance);
    }

    function premint(uint256 dropId, address[] calldata recipients) requiresAuth public {

        for(uint256 i = 0; i < recipients.length; i++) {
            uint256 tokenId = quantum.mintTo(dropId, recipients[i]);
            emit Purchased(dropId, tokenId, recipients[i]);
        }
    }

    function setMintpass(address deployedMP) requiresAuth public {

        mintpass = IQuantumMintPass(deployedMP);
    }

    function setQuantum(address deployedQuantum) requiresAuth public {

        quantum = IQuantumArt(deployedQuantum);
    }

    function setKeyRing(address deployedKeyRing) requiresAuth public {

        keyRing = IQuantumKeyRing(deployedKeyRing);
    }

    function setKeyUnlocks(address deployedUnlocks) requiresAuth public {

        keyUnlocks = IQuantumUnlocked(deployedUnlocks);
    }

    function setDefaultArtistCut(uint256 cut) requiresAuth public {

        defaultArtistCut = cut;
    }
    
    function createSale(uint256 dropId, uint128 price, uint64 start, uint64 limit) requiresAuth public {

        sales[dropId] = Sale(price, start, limit);
    }

    function createMPClaim(uint256 dropId, uint64 mpId, uint64 start, uint128 price) requiresAuth public {

        mpClaims[dropId] = MPClaim(mpId, start, price);
    }

    function createWLClaim(uint256 dropId, uint192 price, uint64 start, bytes32 root) requiresAuth public {

        whitelists[dropId] = Whitelist(price, start, root);
    }

    function flipUint64(uint64 x) internal pure returns (uint64) {

        return x > 0 ? 0 : type(uint64).max;
    }

    function flipSaleState(uint256 dropId) requiresAuth public {

        sales[dropId].start = flipUint64(sales[dropId].start);
    }

    function flipMPClaimState(uint256 dropId) requiresAuth public {

        mpClaims[dropId].start = flipUint64(mpClaims[dropId].start);
    }

    function flipWLState(uint256 dropId) requiresAuth public {

        whitelists[dropId].start = flipUint64(whitelists[dropId].start);
    }

    function flipLimiterForDrop(uint256 dropId) requiresAuth public {

        if (_disablingLimiter.get(dropId)) {
            _disablingLimiter.unset(dropId);
        } else {
            _disablingLimiter.set(dropId);
        }
    }

    function overrideArtistcut(uint256 dropId, uint256 cut) requiresAuth public {

        _overridedArtistCut[dropId] = cut;
    }

    function overrideUnlockArtistCut(uint256 dropId, uint256 cut) requiresAuth public {

        keySales[dropId].overrideArtistcut = cut;
    }

    function setAuction(
        uint256 auctionId,
        uint256 startingPrice,
        uint128 decreasingConstant,
        uint64 start,
        uint64 period
    ) public override requiresAuth {

        super.setAuction(auctionId, startingPrice, decreasingConstant, start, period);
    }

    function curatedPayout(address artist, uint256 dropId, uint256 amount) internal {

        uint256 artistCut = _overridedArtistCut[dropId] == 0 ? defaultArtistCut : _overridedArtistCut[dropId];
        uint256 payout_ = (amount*artistCut)/10000;
        Address.sendValue(payable(artist), payout_);
        Address.sendValue(_quantumTreasury, amount - payout_);
    }

    function genericPayout(address artist, uint256 amount, uint256 cut) internal {

        uint256 artistCut = cut == 0 ? defaultArtistCut : cut;
        uint256 payout_ = (amount*artistCut)/10000;
        Address.sendValue(payable(artist), payout_);
        Address.sendValue(_quantumTreasury, amount - payout_);
    }

    function _isPrivileged(address user) internal view returns (bool) {

        uint256 length = privilegedContracts.length;
        unchecked {
            for(uint i; i < length; i++) {
                if (IQuantumArt(privilegedContracts[i]).balanceOf(user) > 0) {
                    return true;
                }
            }
        }
        return false;
    }

    function purchase(uint256 dropId, uint256 amount) nonReentrant checkCaller isFirstTime(dropId) payable public {

        Sale memory sale = sales[dropId];
        require(block.timestamp >= sale.start, "PURCHASE:SALE INACTIVE");
        require(amount <= sale.limit, "PURCHASE:OVER LIMIT");
        require(msg.value == amount * sale.price, "PURCHASE:INCORRECT MSG.VALUE");
        for(uint256 i = 0; i < amount; i++) {
            uint256 tokenId = quantum.mintTo(dropId, msg.sender);
            emit Purchased(dropId, tokenId, msg.sender);
        }
        curatedPayout(quantum.getArtist(dropId), dropId, msg.value);
    }


    function purchaseThroughAuction(uint256 dropId) nonReentrant checkCaller isFirstTime(dropId) payable public {

        Auction memory auction = _auctions[dropId];
        uint256 userPaid = auction.startingPrice;
        if (
            block.timestamp <= auction.start && 
            block.timestamp >= auction.start - 300 &&
            _isPrivileged(msg.sender)
        ) {
            require(msg.value == userPaid, "PURCHASE:INCORRECT MSG.VALUE");

        } else {
            userPaid = verifyBid(dropId);
        }
        uint256 tokenId = quantum.mintTo(dropId, msg.sender);
        emit Purchased(dropId, tokenId, msg.sender);
        curatedPayout(quantum.getArtist(dropId), dropId, userPaid);
    }

    
    function unlockWithKey(uint256 keyId, uint128 dropId, uint256 variant) nonReentrant checkCaller payable public {

        require(keyRing.ownerOf(keyId) == msg.sender, "PURCHASE:NOT KEY OWNER");
        require(!keyUnlockClaims[dropId][keyId], "PURCHASE:KEY ALREADY USED");
        require(variant>0 && variant<13, "PURCHASE:INVALID VARIANT");

        UnlockSale memory sale = keySales[dropId];
        bool inRange = false;
        if (sale.enabledKeyRanges.length > 0) {
            for (uint256 i=0; i<sale.enabledKeyRanges.length; i++) {
                if ((keyId >= (sale.enabledKeyRanges[i] * SEPARATOR)) && (keyId < (((sale.enabledKeyRanges[i]+1) * SEPARATOR)-1))) inRange = true;
            }
        } 
        else inRange = true;
        require(inRange, "PURCHASE:SALE NOT AVAILABLE TO THIS KEY");
        require(block.timestamp >= sale.start, "PURCHASE:SALE NOT STARTED");
        require(block.timestamp <= (sale.start + sale.period), "PURCHASE:SALE EXPIRED");
        require(msg.value == sale.price, "PURCHASE:INCORRECT MSG.VALUE");

        uint256 tokenId = keyUnlocks.mint(msg.sender, dropId, variant);
        keyUnlockClaims[dropId][keyId] = true;
        emit Purchased(dropId, tokenId, msg.sender);
        genericPayout(sale.artist, msg.value, sale.overrideArtistcut);
    }

    function createUnlockSale(uint128 price, uint64 start, uint64 period, address artist, uint256[] calldata enabledKeyRanges) requiresAuth public {

        emit DropCreated(_nextUnlockDropId);
        uint256[] memory blankRanges;
        keySales[_nextUnlockDropId++] = UnlockSale(price, start, period, artist, 0, blankRanges);
        for (uint i=0; i<enabledKeyRanges.length; i++) keySales[_nextUnlockDropId-1].enabledKeyRanges.push(enabledKeyRanges[i]);
    }

    function isKeyUsed(uint256 dropId, uint256 keyId) public view returns (bool) {

        return keyUnlockClaims[dropId][keyId];
    }

    function claimWithMintPass(uint256 dropId, uint256 amount) nonReentrant payable public {

        MPClaim memory mpClaim = mpClaims[dropId];
        require(block.timestamp >= mpClaim.start, "MP: CLAIMING INACTIVE");
        require(msg.value == amount * mpClaim.price, "MP:WRONG MSG.VALUE");
        mintpass.burnFromRedeem(msg.sender, mpClaim.mpId, amount); //burn mintpasses
        for(uint256 i = 0; i < amount; i++) {
            uint256 tokenId = quantum.mintTo(dropId, msg.sender);
            emit Purchased(dropId, tokenId, msg.sender);
        }
        if (msg.value > 0) curatedPayout(quantum.getArtist(dropId), dropId, msg.value);
    }

    function purchaseThroughWhitelist(uint256 dropId, uint256 amount, uint256 index, bytes32[] calldata merkleProof) nonReentrant external payable {

        Whitelist memory whitelist = whitelists[dropId];
        require(block.timestamp >= whitelist.start, "WL:INACTIVE");
        require(msg.value == whitelist.price * amount, "WL: INVALID MSG.VALUE");
        require(!_claimedWL[dropId].get(index), "WL:ALREADY CLAIMED");
        bytes32 node = keccak256(abi.encodePacked(msg.sender, amount, index));
        require(MerkleProof.verify(merkleProof, whitelist.merkleRoot, node),"WL:INVALID PROOF");
        _claimedWL[dropId].set(index);
        uint256 tokenId = quantum.mintTo(dropId, msg.sender);
        emit Purchased(dropId, tokenId, msg.sender);
        curatedPayout(quantum.getArtist(dropId), dropId, msg.value);
    }

    function isWLClaimed(uint256 dropId, uint256 index) public view returns (bool) {

        return _claimedWL[dropId].get(index);
    }
}