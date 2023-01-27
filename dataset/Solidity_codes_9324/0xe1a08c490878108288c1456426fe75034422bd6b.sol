
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

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

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

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
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


interface IRandomizer {

    function randomMod(uint256,uint256,uint256) external returns (uint256);

}

interface ILandStaker {

    function getStakedBalance(address, uint256) external returns (uint256);

}

interface IIngameItems {

    function addGemToPlayer(uint256, address) external;

    function addTotemToPlayer(uint256, address) external;

    function addGhostToPlayer(uint256, address) external;

}

contract Battles is Ownable {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private counter;
    uint256 constant public DECIMALS_18 = 1e18;
    IERC20 public paymentToken;
    IERC721 public piratesContract;
    IERC1155 public landContract;
    ILandStaker public landStakingContract;
    IRandomizer public randomizer;
    IIngameItems public ingameItems;
    uint256 public stakingCostInEtherUnits;

    event BattleAdded(uint256 battleId);

    struct Battle {
        uint256 battleId; 
        bool open; // open to add pirates
        bool started;
        bool ended;
        uint256 startTime;
        uint256 endTime;
        EnumerableSet.AddressSet players;
        EnumerableSet.AddressSet xbmfWinners;
        EnumerableSet.AddressSet gemWinners;
        EnumerableSet.AddressSet totemWinners;
        EnumerableSet.AddressSet ghostWinners;
        mapping(address => EnumerableSet.UintSet) piratesByPlayer;
        mapping(uint256 => address) pirateOwners;
        uint256 rewardsInEtherUnits;
        uint256 numXbmfPrizes;
        uint256 numGemPrizes;
        uint256 numGhostPrizes;
        uint256 numTotemPrizes;
        uint256 stakedPiratesCount;
        address[] tickets;
    }

    mapping (uint256 => Battle) battles;

    function addXBMF(uint256 amount) external onlyOwner {

        paymentToken.transferFrom(msg.sender, address(this), amount);
    }

    function setPaymentToken(address _address) external onlyOwner {

        paymentToken = IERC20(_address);
    }

    function setStakingCost(uint256 _stakingCostInEtherUnits) external onlyOwner {

        stakingCostInEtherUnits = _stakingCostInEtherUnits;
    }

    function setLandStakingContract(address _address) external onlyOwner {

        landStakingContract = ILandStaker(_address);
    }

    function setIngameItemsContract(address _address) external onlyOwner {

        ingameItems = IIngameItems(_address);
    }

    function setRandomizerContract(address _address) external onlyOwner {

        randomizer = IRandomizer(_address);
    }

    function setPiratesContract(address _address) external onlyOwner {

        piratesContract = IERC721(_address);
    }

    function setLandContract(address _address) external onlyOwner {

        landContract = IERC1155(_address);
    }

    function addBattle(uint256 _startTime, uint256 _endTime, uint256 _rewardsInEtherUnits, uint256 _numXBmfPrizes, uint256 _numGemPrizes,
        uint256 _numGhostPrizes, uint256 _numTotemPrizes
    ) external onlyOwner {

        Battle storage battle = battles[counter.current()];
        battle.battleId = counter.current();
        battle.started = false;
        battle.ended = false;
        battle.open = false;
        battle.startTime = _startTime;
        battle.endTime = _endTime;
        battle.rewardsInEtherUnits = _rewardsInEtherUnits;
        battle.numXbmfPrizes = _numXBmfPrizes;
        battle.numGemPrizes = _numGemPrizes;
        battle.numGhostPrizes = _numGhostPrizes;
        battle.numTotemPrizes = _numTotemPrizes;

        emit BattleAdded(counter.current());

        counter.increment();
    }

    function getBattleData(uint256 battleId) public view returns (uint256[] memory) {

        Battle storage battle = battles[battleId];
        uint256[] memory data = new uint256[](10);
        data[0] = battle.battleId;
        data[1] = battle.started ? 1 : 0;
        data[2] = battle.ended ? 1 : 0;
        data[3] = battle.startTime;
        data[4] = battle.endTime;
        data[5] = battle.rewardsInEtherUnits;
        data[6] = battle.numXbmfPrizes;
        data[7] = battle.numGemPrizes;
        data[8] = battle.numGhostPrizes;
        data[9] = battle.numTotemPrizes;
        return data;
    }

    function hasLand(address _address) internal returns (bool){

        return landContract.balanceOf(_address, 0) > 0 ||
            landContract.balanceOf(_address, 1) > 0 ||
            landContract.balanceOf(_address, 2) > 0 ||
            landContract.balanceOf(_address, 3) > 0 ||
            landContract.balanceOf(_address, 4) > 0 ||
            landContract.balanceOf(_address, 5) > 0 ||
            landContract.balanceOf(_address, 6) > 0 ||
            landContract.balanceOf(_address, 7) > 0 ||
            landStakingContract.getStakedBalance(_address, 0) > 0 ||
            landStakingContract.getStakedBalance(_address, 1) > 0 ||
            landStakingContract.getStakedBalance(_address, 2) > 0 ||
            landStakingContract.getStakedBalance(_address, 3) > 0 ||
            landStakingContract.getStakedBalance(_address, 4) > 0 ||
            landStakingContract.getStakedBalance(_address, 5) > 0 ||
            landStakingContract.getStakedBalance(_address, 6) > 0 ||
            landStakingContract.getStakedBalance(_address, 7) > 0;
    }

    function addMultiplePiratesToBattleWithLand(uint256 battleId, uint256[] calldata pirateIds) external {

        require(
            battles[battleId].started == false, "Can't add pirates to a started Battle"
        );
        require(
            hasLand(msg.sender), "You need land or skull caves to add a pirate for free"
        );
        for (uint i = 0; i < pirateIds.length; i++){
            addPirateToBattle(battleId, pirateIds[i]);
        }
    }

    function addMultiplePiratesToBattleWithXBMF(uint256 battleId, uint256[] calldata pirateIds, uint256 paymentAmountInEthUnits) external {

        require(
            battles[battleId].started == false, "Can't add pirates to a started Battle"
        );
        require(
            paymentAmountInEthUnits == stakingCostInEtherUnits.mul(pirateIds.length),
            "wrong payment amount"
        );
        require(
            paymentToken.transferFrom(msg.sender, address(this), paymentAmountInEthUnits.mul(DECIMALS_18)),
            "Transfer of payment token could not be made"
        );
        for (uint i = 0; i < pirateIds.length; i++){
            addPirateToBattle(battleId, pirateIds[i]);
        }
    }

    function addPirateToBattle(uint256 battleId, uint256 pirateId) public { //change to internal _


        Battle storage battle = battles[battleId];
        battle.pirateOwners[pirateId] = msg.sender;
        if (!battle.players.contains(msg.sender)) {
             battle.players.add(msg.sender);
        }
        if (!battle.piratesByPlayer[msg.sender].contains(pirateId)){
            battle.piratesByPlayer[msg.sender].add(pirateId);
        }
        
        piratesContract.transferFrom(msg.sender, address(this), pirateId);
        battle.stakedPiratesCount++;
    }

    function removePirateFromBattle(uint battleId, uint256 pirateId) external {

        Battle storage battle = battles[battleId];
        require(battle.piratesByPlayer[msg.sender].contains(pirateId), "Sender doesn't own pirate");
        piratesContract.transferFrom(address(this), msg.sender, pirateId);
        battle.piratesByPlayer[msg.sender].remove(pirateId);
        battle.stakedPiratesCount--;
    }

    function removeAllPiratesFromBattleForPlayer(uint battleId) external { 

       EnumerableSet.UintSet storage pirates =  battles[battleId].piratesByPlayer[msg.sender];
       while (pirates.length() > 0){
           require(battles[battleId].piratesByPlayer[msg.sender].contains(pirates.at(0)), "Sender doesn't own pirate");
           piratesContract.transferFrom(address(this), msg.sender, pirates.at(0));
           pirates.remove(pirates.at(0));
           battles[battleId].stakedPiratesCount--;
       }
    }

    function openBattle(uint256 battleId, bool value) external onlyOwner {

       battles[battleId].open = value;
    }

    function startBattle(uint256 battleId) external onlyOwner {

        battles[battleId].open = false;
        battles[battleId].started = true;
    }

    function endBattle(uint256 battleId) external onlyOwner {

        battles[battleId].ended = true;
        _createTicketList(battleId);
        _pickXbmfWinners(battleId, 0, 0, 0);
        _pickGemWinners(battleId, 0, 1000, 1000);
        _pickTotemWinners(battleId, 0, 2000, 2000);
        _pickGhostWinners(battleId, 0, 3000, 3000);
    }

    function ownsLandType(address _address, uint256 landType) internal returns (bool){

        return landContract.balanceOf(_address, landType) > 0 || landStakingContract.getStakedBalance(_address, landType) > 0;
    }

    function _createTicketList(uint256 battleId) internal {

         for (uint256 i = 0; i < battles[battleId].players.length(); i++) {
            address player = battles[battleId].players.at(i);
            if (ownsLandType(player, 6)) {
                battles[battleId].tickets.push(player);
            }
            if (ownsLandType(player, 7)) {
                battles[battleId].tickets.push(player);
                battles[battleId].tickets.push(player); 
            }
            for (uint256 j = 0; j < battles[battleId].piratesByPlayer[player].length(); j++) {
                battles[battleId].tickets.push(player);
            }
         }
    }

    function claimXbmfPrize(uint256 battleId) external {

        bool winner = false;
        for (uint256 i = 0; i < battles[battleId].xbmfWinners.length(); i++) {
            if (battles[battleId].xbmfWinners.at(i) == msg.sender){
                winner = true;
            }
        }
        paymentToken.transfer(msg.sender, battles[battleId].rewardsInEtherUnits.mul(DECIMALS_18));
    }

    function isXbmfWinner(uint256 battleId, address _address) external view returns (bool) {

        bool winner = false;
        for (uint256 i = 0; i < battles[battleId].xbmfWinners.length(); i++) {
            if (battles[battleId].xbmfWinners.at(i) == _address){
                winner = true;
            }
        }
        return winner;
    }

    function getXbmfWinners(uint256 battleId) public view returns (address[] memory){

        if (!battles[battleId].ended){
            return new address[](0);
        }
        uint256 length = battles[battleId].xbmfWinners.length();
        address[] memory arr = new address[](length);//3 winners
        for (uint256 i = 0; i < length; i++){
            arr[i] = battles[battleId].xbmfWinners.at(i);
        }
        return arr;
    }

    function getGemWinners(uint256 battleId) public view returns (address[] memory){

        if (!battles[battleId].ended){
            return new address[](0);
        }
        uint256 length = battles[battleId].gemWinners.length();
        address[] memory arr = new address[](length);
        for (uint256 i = 0; i < length; i++){
            arr[i] = battles[battleId].gemWinners.at(i);
        }
        return arr;
    }

    function getTotemWinners(uint256 battleId) public view returns (address[] memory){

        if (!battles[battleId].ended){
            return new address[](0);
        }
        uint256 length = battles[battleId].totemWinners.length();
        address[] memory arr = new address[](length);
        for (uint256 i = 0; i < length; i++){
            arr[i] = battles[battleId].totemWinners.at(i);
        }
        return arr;
    }

    function getGhostWinners(uint256 battleId) public view returns (address[] memory){

        if (!battles[battleId].ended){
            return new address[](0);
        }
        uint256 length = battles[battleId].ghostWinners.length();
        address[] memory arr = new address[](length);
        for (uint256 i = 0; i < length; i++){
            arr[i] = battles[battleId].ghostWinners.at(i);
        }
        return arr;
    }

    function _pickXbmfWinners(uint256 battleId, uint256 count, uint256 nonce, uint256 seed) internal {

        Battle storage battle = battles[battleId];
        while (count < battle.numXbmfPrizes){
            address candidate = battle.tickets[randomizer.randomMod(seed, nonce, battle.tickets.length)];
            if (!battle.xbmfWinners.contains(candidate)){
                battle.xbmfWinners.add(candidate);
                count++;
            }
            nonce++;
        }
    }

    function _pickGemWinners(uint256 battleId, uint256 count, uint256 nonce, uint256 seed) internal {

        while (count < battles[battleId].numGemPrizes){
            address winner = battles[battleId].tickets[randomizer.randomMod(seed, nonce, battles[battleId].tickets.length)];
            ingameItems.addGemToPlayer(battleId, winner);
            battles[battleId].gemWinners.add(winner);
            count++;
            nonce++;
        }
    }

    function _pickTotemWinners(uint256 battleId, uint256 count, uint256 nonce, uint256 seed) internal {

        while (count < battles[battleId].numTotemPrizes){
            address winner = battles[battleId].tickets[randomizer.randomMod(seed, nonce, battles[battleId].tickets.length)];
            ingameItems.addTotemToPlayer(battleId, winner);
            battles[battleId].totemWinners.add(winner);
            count++;
            nonce++;
        }
    }

    function _pickGhostWinners(uint256 battleId, uint256 count, uint256 nonce, uint256 seed) internal {

        while (count < battles[battleId].numGhostPrizes){
            address winner = battles[battleId].tickets[randomizer.randomMod(seed, nonce, battles[battleId].tickets.length)];
            ingameItems.addGhostToPlayer(battleId, winner);
            battles[battleId].ghostWinners.add(winner);
            count++;
            nonce++;
        }
    }

    function getStakedPiratesForPlayer(uint256 battleId, address playerAddress) view public returns(uint256[] memory) {

        EnumerableSet.UintSet storage pirates = battles[battleId].piratesByPlayer[playerAddress];
        uint256[] memory arr = new uint256[](pirates.length());
        for (uint256 i = 0; i < pirates.length(); i++){
            arr[i] = pirates.at(i);
        }
        return arr;
    }

    function getAllStakedPiratesForBattle(uint256 battleId) view public returns(uint256[] memory) {

        EnumerableSet.AddressSet storage players = battles[battleId].players;
        uint256[] memory arr = new uint256[](battles[battleId].stakedPiratesCount);
        uint256 count = 0;
        for (uint256 i = 0; i < players.length(); i++){
            EnumerableSet.UintSet storage pirates = battles[battleId].piratesByPlayer[players.at(i)];
            for (uint256 j = 0; j < pirates.length(); j++){
                arr[count] = pirates.at(j);
                count++;
            }
        }
        return arr;
    }
    

    function withdraw() public payable onlyOwner {

        uint256 bal = address(this).balance;
        require(payable(msg.sender).send(bal));
    }

    function withdrawPaymentToken() public payable onlyOwner {

        uint256 bal = paymentToken.balanceOf(address(this));
        paymentToken.transfer(msg.sender, bal);
    }

}