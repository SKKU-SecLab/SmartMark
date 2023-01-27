

pragma solidity ^0.8.12;

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
}


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
}

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}


interface ERC721TokenReceiver {

    function onERC721Received(address operator,address from, uint256 id, bytes calldata data) external returns (bytes4);

}

interface IInhibitor {

    function mintHelper(address _user, uint256 quantity) external;

}

interface IStakingHelper {

    function startSeason(uint256 _dailyYield) external;

    function endSeason() external;

    function needsRewardsUpdate(address _user) external view returns (bool);

    function aggregateRewards(address _user) external;

}

error OwnerOfNullValue();
error BalanceOfZeroAddress();
error MintZeroAddress();
error MintZeroQuantity();
error SafeMintZeroQuantity();
error SafeMintZeroAddress();
error SafeMintUnsafeDestination();
error TokensLocked();
error CallerLacksTransferPermissions();
error TransferFromNotOwner();
error TransferZeroAddress();
error SafeTransferUnsafeDestination();
error TokensNotBatchable();
error BatchQuantityTooSmall();
error ApprovalToOwner();
error CallerLacksApprovalPermissions();
error getApprovedNonexistentToken();
error stakingNotActive();
error TokensStaked();
error TokensUnstaked();
error StakedTokensTimeLocked();
error StakingActive();
error beginStakingZeroAddress();
error StakingInactive();
error UnsupportedCooldownDuration();
error CooldownTooSmall();
error TokensUnlocked();
error NewOwnerAddressZero();
error TokenURINonexistentToken();
error TokensZeroBalance();
error TokensOfOwnerNullValue();
error CallerNotStakingHelper();
error CallerNotOwner();

abstract contract ERC721LPhantomStakeable {
    using Address for address;
    using Strings for uint256;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Locked(address indexed owner, uint256 unlockCooldown);
    event Unlocked(address indexed owner, uint256 unlockTimestamp);
    event Staked(address indexed owner, uint256 stakedTimestamp);
    event Unstaked(address indexed owner, uint256 unstakedTimestamp);
    event StakingEventStarted(address indexed stakingContract, uint256 dailyYield, uint256 timestamp);
    event StakingEventEnded(uint256 timestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    struct addressData {
        uint64 balance;
        bool staked;
        bool locked;
        uint64 lockedUnlockCooldown;
        uint64 lockedUnlockTimestamp;
    }

    struct collectionData {
        string name;
        string symbol;
        address owner;
        uint256 index;
        uint256 burned;
    }

    struct stakingData {
        IStakingHelper stakingContract;
        bool stakingStatus;
    }

    collectionData internal _collectionData;
    stakingData internal _stakingData;

    mapping(uint256 => address) internal _ownerships;
    mapping(address => addressData) internal _addressData;
    mapping(uint256 => address) internal _tokenApprovals;
    mapping(address => mapping(address => bool)) private  _operatorApprovals;

    constructor(string memory _name, string memory _symbol) {
        _collectionData.name = _name;
        _collectionData.symbol = _symbol;
        _transferOwnership(_msgSender());
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _exists(uint256 tokenId) public view virtual returns (bool) {
        return tokenId < _collectionData.index;
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        unchecked {
            if (tokenId < _collectionData.index) {
                address ownership = _ownerships[tokenId];
                if (ownership != address(0)) {
                    return ownership;
                }
                    while (true) {
                        tokenId--;
                        ownership = _ownerships[tokenId];

                        if (ownership != address(0)) {
                            return ownership;
                        }
                         
                    }
                }
            }

        revert OwnerOfNullValue();
    }

    function balanceOf(address _address) public view returns (uint256) {
        if (_address == address(0)) revert BalanceOfZeroAddress();
        return uint256(_addressData[_address].balance);
    }

    function isUnlocked(address _owner) public view returns (bool) {
        return 
            !_addressData[_owner].locked && 
            _addressData[_owner].lockedUnlockTimestamp < block.timestamp && 
            (_stakingData.stakingStatus ? !_addressData[_owner].staked : true);
    }

    function _mint(address to, uint256 quantity) internal {
        if (to == address(0)) revert MintZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        if (_stakingData.stakingStatus && _addressData[to].staked && _stakingData.stakingContract.needsRewardsUpdate(to)){
            _stakingData.stakingContract.aggregateRewards(to);
        }

        unchecked {
            uint256 updatedIndex = _collectionData.index;
            _addressData[to].balance += uint64(quantity);
            _ownerships[updatedIndex] = to;
            
            for (uint256 i; i < quantity; i++) {
                emit Transfer(address(0), to, updatedIndex++);
            }

            _collectionData.index = updatedIndex;
        }
    }

    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, '');
    }

    function _safeMint(address to, uint256 quantity, bytes memory _data) internal {
        if (to == address(0)) revert SafeMintZeroAddress();
        if (quantity == 0) revert SafeMintZeroQuantity();

        if (_stakingData.stakingStatus && _addressData[to].staked && _stakingData.stakingContract.needsRewardsUpdate(to)){
            _stakingData.stakingContract.aggregateRewards(to);
        }

        unchecked {
            uint256 updatedIndex = _collectionData.index;
            _addressData[to].balance += uint64(quantity);
            _ownerships[updatedIndex] = to;
            
            for (uint256 i; i < quantity; i++) {
                emit Transfer(address(0), to, updatedIndex);
                if(to.code.length > 0 &&
                        ERC721TokenReceiver(to).onERC721Received(_msgSender(), address(0), updatedIndex, _data) !=
                        ERC721TokenReceiver.onERC721Received.selector) revert SafeMintUnsafeDestination();
                updatedIndex++;
            }

            _collectionData.index = updatedIndex;
        }
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        address currentOwner = ownerOf(tokenId);
        if (!isUnlocked(from)) revert TokensLocked();
        if (_msgSender() != currentOwner &&
            getApproved(tokenId) != _msgSender() &&
            !isApprovedForAll(currentOwner,_msgSender())) revert CallerLacksTransferPermissions();
        if (currentOwner != from) revert TransferFromNotOwner();
        if (to == address(0)) revert TransferZeroAddress();

        if (_stakingData.stakingStatus && _addressData[to].staked && _stakingData.stakingContract.needsRewardsUpdate(to)){
            _stakingData.stakingContract.aggregateRewards(to);
        }

        delete _tokenApprovals[tokenId]; 
        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;
            _ownerships[tokenId] = to;
            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId] == address(0) && nextTokenId < _collectionData.index) {
                _ownerships[nextTokenId] = currentOwner;
            }
        }

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual {
        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual {
        transferFrom(from, to, tokenId);
        if (to.code.length > 0 &&
                ERC721TokenReceiver(to).onERC721Received(_msgSender(), address(0), tokenId, _data) !=
                ERC721TokenReceiver.onERC721Received.selector) revert SafeTransferUnsafeDestination();
    }

    function batchTransferFrom(address from, address to, uint256 startID, uint256 quantity) public virtual {
        _batchTransferFrom(from, to, startID, quantity, false, '');
    }

    function batchSafeTransferFrom(address from, address to, uint256 startID, uint256 quantity) public virtual {
        batchSafeTransferFrom(from, to, startID, quantity, '');
    }

    function batchSafeTransferFrom(address from, address to, uint256 startID, uint256 quantity, bytes memory _data) public virtual {
        _batchTransferFrom(from, to, startID, quantity, true, _data);
    }

    function _batchTransferFrom (address from, address to, uint256 startID, uint256 quantity, bool safeTransferCheck, bytes memory _data) internal {
        if (!isUnlocked(from)) revert TokensLocked();
        if (_msgSender() != from && !isApprovedForAll(from,_msgSender())) revert CallerLacksTransferPermissions();
        if (!multiOwnerCheck(from, startID, quantity)) revert TokensNotBatchable();
        if (to == address(0)) revert TransferZeroAddress();

        if (_stakingData.stakingStatus && _addressData[to].staked && _stakingData.stakingContract.needsRewardsUpdate(to)){
            _stakingData.stakingContract.aggregateRewards(to);
        }

        unchecked {
            for (uint256 i; i < quantity; i++) {
                uint256 currentToken = startID + i;
                delete _tokenApprovals[currentToken];

                if (i == 0){
                    _ownerships[currentToken] = to;
                } else {
                    delete _ownerships[currentToken];
                }
                emit Transfer(from, to, currentToken);
                if (safeTransferCheck){
                    if(to.code.length > 0 &&
                        ERC721TokenReceiver(to).onERC721Received(_msgSender(), address(0), currentToken, _data) !=
                        ERC721TokenReceiver.onERC721Received.selector) revert SafeTransferUnsafeDestination();
                }
            }

            _addressData[from].balance -= uint64(quantity);
            _addressData[to].balance += uint64(quantity);
            uint256 nextTokenId = startID + quantity;
            if (_ownerships[nextTokenId] == address(0) && nextTokenId < _collectionData.index) {
                _ownerships[nextTokenId] = from;
            }
        }
    }

    function totalSupply() public view returns (uint256) {
        unchecked {
            return _collectionData.index - _collectionData.burned;
        }
    }

    function multiOwnerCheck(address _addressToCheck, uint256 startID, uint256 quantity) internal view returns (bool) {
        if (quantity < 2) revert BatchQuantityTooSmall();
        unchecked {
            for (uint256 i; i < quantity; i++) {
                if (ownerOf(startID + i) != _addressToCheck){
                    return false;
                }
            }
        }
        return true;
    }

    function setApprovalForAll(address operator, bool approved) public {
        if (operator == _msgSender()) revert ApprovalToOwner();
        if (!isUnlocked(_msgSender())) revert TokensLocked();

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address _owner, address operator) public view returns (bool) {
        return !isUnlocked(_owner) ? false : _operatorApprovals[_owner][operator];
    }

    function approve(address to, uint256 tokenId) public {
        address tokenOwner = ownerOf(tokenId);
        if (to == tokenOwner) revert ApprovalToOwner();
        if (_msgSender() != tokenOwner && !isApprovedForAll(tokenOwner, _msgSender())) revert CallerLacksApprovalPermissions();
        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        if (!_exists(tokenId)) revert getApprovedNonexistentToken();
        return _tokenApprovals[tokenId];
    }

    function stake(address _owner) public stakingHelper {
        if (!_stakingData.stakingStatus) revert stakingNotActive();
        if (_addressData[_owner].staked) revert TokensStaked();

        _addressData[_owner].staked = true;
        emit Staked(_msgSender(), block.timestamp);
    }

    function unstake(address _owner) public stakingHelper {
        if (!_addressData[_owner].staked) revert TokensUnstaked();

        delete _addressData[_owner].staked;
        emit Unstaked(_owner, block.timestamp);
    }

    function beginStaking(address _stakingContract, uint256 _dailyYield) public onlyOwner {
        if (_stakingData.stakingStatus) revert StakingActive();
        if (_stakingContract == address(0)) revert beginStakingZeroAddress();

        _stakingData.stakingContract = IStakingHelper(_stakingContract);
        _stakingData.stakingStatus = true;
        _stakingData.stakingContract.startSeason(_dailyYield);
        
        emit StakingEventStarted(_stakingContract, _dailyYield, block.timestamp);
    }

    function endStaking() public onlyOwner {
        if (!_stakingData.stakingStatus) revert StakingInactive();

        _stakingData.stakingContract.endSeason();
        delete _stakingData;
        
        emit StakingEventEnded(block.timestamp);
    }

    function lock(uint256 _cooldown) public {
        if (_addressData[_msgSender()].locked) revert TokensLocked();
        if (_cooldown < 1 || _cooldown > 30) revert UnsupportedCooldownDuration();

        unchecked {
            uint256 proposedCooldown = _cooldown * 1 days;
            if (block.timestamp + proposedCooldown < _addressData[_msgSender()].lockedUnlockTimestamp) revert CooldownTooSmall();
            _addressData[_msgSender()].locked = true;
            _addressData[_msgSender()].lockedUnlockCooldown = uint64(proposedCooldown);
        }
        
        emit Locked(_msgSender(), _cooldown);
    }

    function unlock() public {
        if (!_addressData[_msgSender()].locked) revert TokensUnlocked();

        delete _addressData[_msgSender()].locked;
        unchecked {
            _addressData[_msgSender()].lockedUnlockTimestamp = uint64(block.timestamp + _addressData[_msgSender()].lockedUnlockCooldown);
        }
        emit Unlocked(_msgSender(), block.timestamp);
    }

    function owner() public view returns (address) {
        return _collectionData.owner;
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner == address(0)) revert NewOwnerAddressZero();
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _collectionData.owner;
        _collectionData.owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function name() public view returns (string memory) {
        return _collectionData.name;
    }

    function symbol() public view returns (string memory) {
        return _collectionData.symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        if (!_exists(tokenId)) revert TokenURINonexistentToken();
        string memory _baseURI = baseURI();
        return bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenId.toString())) : '';
    }

    function baseURI() public view virtual returns (string memory) {
        return '';
    }

    function tokensOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 totalOwned = _addressData[_owner].balance;
        if (totalOwned == 0) revert TokensZeroBalance();
        uint256 supply = _collectionData.index;
        uint256[] memory tokenIDs = new uint256[](totalOwned);
        uint256 ownedIndex;
        address currentOwner;

        unchecked {
            for (uint256 i; i < supply; i++) {
                address currentAddress = _ownerships[i];
                if (currentAddress != address(0)) {
                    currentOwner = currentAddress;
                }
                if (currentOwner == _owner) {
                    tokenIDs[ownedIndex++] = i;
                    if (ownedIndex == totalOwned){
                        return tokenIDs;
                    }
                }
            }
        }

        revert TokensOfOwnerNullValue();
    }

    function getLockData(address _owner) public view returns (bool, uint256, uint256) {
        return (_addressData[_owner].locked, 
        _addressData[_owner].lockedUnlockTimestamp, 
        _addressData[_owner].lockedUnlockCooldown);
    }

    function getStakingStatus(address _address) public view returns (bool) {
        return (_addressData[_address].staked);
    }

    function collectionInformation() public view returns (collectionData memory) {
        return _collectionData;
    }

    function stakingInformation() public view returns (address, bool) {
        return (address(_stakingData.stakingContract), _stakingData.stakingStatus);
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == 0x01ffc9a7 || interfaceId == 0x80ac58cd || interfaceId == 0x5b5e139f;
    }

    modifier stakingHelper() {
      if (address(_stakingData.stakingContract) != _msgSender()) revert CallerNotStakingHelper();
        _;
    }

    modifier onlyOwner() {
        if (owner() != _msgSender()) revert CallerNotOwner();
        _;
    }

}

error CallerIsSmartContract();
error ProofFailure();
error QuantityFailure();
error SupplyFailure();
error PriceFailure();
error AmountFailure();
error MintNotActive();
error InputError();
error WithdrawFailure();

contract MYTHICAL is ERC721LPhantomStakeable {


    struct addressMintData {
        uint128 genesisMinted;
        uint128 inhibitorMinted;
    }
 
    address public royaltyAddress;
    uint256 public royaltySize = 750;
    uint256 public royaltyDenominator = 10000;
    mapping(uint256 => address) private _royaltyReceivers;

    uint256 public maxSupply = 7777;
    string private _baseURI = "ipfs://QmVdZQvv66kvfCkZ4Lwen8bM7KJX5JgtZEmWRaGL8hy54X/";
    uint256 public allowListMaxMint = 1;
    uint256 public publicMaxMint = 5;
    uint256 public priceGenesis = .1 ether;
    uint256 public priceInhibitor = .02 ether;
    mapping(address => addressMintData) internal _addressMintData;
    bytes32 public allowlistRoot = 0x8977b92ce0adeb8244cbc3b448b4332c7d78cd253f33e5e5d80924caf270375d;
    uint256 public presaleActive;
    uint256 public publicActive;
    bool public teamAllocationMinted;
    IInhibitor public INHIB;

  constructor() ERC721LPhantomStakeable("MYTHICAL", "MC") {
      royaltyAddress = owner();
  }

  modifier callerIsUser() {

    if (tx.origin != _msgSender() || _msgSender().code.length != 0) revert CallerIsSmartContract();
    _;
  }

  function presaleMint(uint256 _quantityGenesis, uint256 _quantityInhibitor, bytes32[] calldata _proof) public payable callerIsUser {

    if (presaleActive < 1) revert MintNotActive();
    if (!MerkleProof.verify(_proof, allowlistRoot, keccak256(abi.encodePacked(_msgSender())))) revert ProofFailure();
    unchecked {
        if (_quantityGenesis + _quantityInhibitor < 1) revert QuantityFailure();
        if (totalSupply() + _quantityGenesis > maxSupply) revert SupplyFailure();
        if (msg.value < (_quantityGenesis * priceGenesis) + (_quantityInhibitor * priceInhibitor)) revert PriceFailure();
    }

    if(_quantityInhibitor > 0){
        unchecked {
            if (_quantityInhibitor + _addressMintData[_msgSender()].inhibitorMinted > allowListMaxMint) revert AmountFailure();
            _addressMintData[_msgSender()].inhibitorMinted += uint128(_quantityInhibitor);
        }
        INHIB.mintHelper(_msgSender(), _quantityInhibitor);
    }

    if(_quantityGenesis > 0){
        unchecked {
            if (_quantityGenesis + _addressMintData[_msgSender()].genesisMinted > allowListMaxMint) revert AmountFailure();
            _addressMintData[_msgSender()].genesisMinted += uint128(_quantityGenesis);
        }
        _mint(_msgSender(), _quantityGenesis);
    }
 
  }

  function publicMint(uint256 _quantityGenesis, uint256 _quantityInhibitor) public payable callerIsUser {

    if (publicActive < 1) revert MintNotActive();
    unchecked {
        if (_quantityGenesis + _quantityInhibitor < 1) revert QuantityFailure();
        if (totalSupply() + _quantityGenesis > maxSupply) revert SupplyFailure();
        if (msg.value < (_quantityGenesis * priceGenesis) + (_quantityInhibitor * priceInhibitor)) revert PriceFailure();
    }

    if(_quantityInhibitor > 0){
        unchecked {
            if (_quantityInhibitor > publicMaxMint) revert AmountFailure();
        }
        INHIB.mintHelper(_msgSender(), _quantityInhibitor);
    }

    if(_quantityGenesis > 0){
        unchecked {
            if (_quantityGenesis > publicMaxMint) revert AmountFailure();
        }
        _mint(_msgSender(), _quantityGenesis);
    }
  }

  function baseURI() public view override returns (string memory) {

    return _baseURI;
  }

  function setBaseURI(string calldata newBaseURI) external onlyOwner {

    _baseURI = newBaseURI;
  }

  function setState(uint256 group, uint256 category, uint256 _value) external onlyOwner {

    bool adjusted;
    if (group == 0){
        if (category == 0){
            presaleActive = _value;
            adjusted = true;
        }

        if (category == 1){
            publicActive = _value;
            adjusted = true;
        }
    }

    if (group == 1){
        if (category == 0){
            allowListMaxMint = _value;
            adjusted = true;
        }

        if (category == 1){
            publicMaxMint = _value;
            adjusted = true;
        }
    }

    if (group == 2){

        if (category == 0){
            priceGenesis = _value;
            adjusted = true;
        }

        if (category == 1){
            priceInhibitor = _value;
            adjusted = true;
        }
    }

    if (!adjusted) revert InputError();
  }

  function setInhibitorAddress(IInhibitor _address) external onlyOwner {

    INHIB = _address;
  }

  function setRoot(bytes32 _root) external onlyOwner {

    allowlistRoot = _root;
  }

  function checkRemainingMints(address _address, bytes32[] calldata _proof) external view returns (uint256, uint256) {

      if (!MerkleProof.verify(_proof, allowlistRoot, keccak256(abi.encodePacked(_address)))) return (0, 0);
      return(allowListMaxMint - _addressMintData[_address].genesisMinted, allowListMaxMint - _addressMintData[_address].inhibitorMinted);
  }

  function mintTeamAllocation() external onlyOwner callerIsUser {

      require(!teamAllocationMinted, "Team Allocation already minted");
      INHIB.mintHelper(_msgSender(), 120);
      _mint(_msgSender(), 120);
      teamAllocationMinted = true;
  }

  function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount) {

      uint256 amount = (_salePrice * royaltySize)/(royaltyDenominator);
      address royaltyReceiver = _royaltyReceivers[_tokenId] != address(0) ? _royaltyReceivers[_tokenId] : royaltyAddress;
      return (royaltyReceiver, amount);
   }

    function addRoyaltyReceiverForTokenId(address receiver, uint256 tokenId) public onlyOwner {

      _royaltyReceivers[tokenId] = receiver;
   }

  function withdraw() external onlyOwner {

    uint256 currentBalance = address(this).balance;
    (bool sent, ) = address(msg.sender).call{value: currentBalance}('');
    if (!sent) revert WithdrawFailure();   
  }

}