
pragma solidity ^0.7.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IMomijiToken {

    function tokenQuantityWithId(uint256 tokenId) view external returns(uint256);

    function tokenMaxQuantityWithId(uint256 tokenId) view external returns(uint256);

    function mintManuallyQuantityWithId(uint256 tokenId) view external returns(uint256);

    function creators(uint256 tokenId) view external returns(address);

    function removeMintManuallyQuantity(uint256 tokenId, uint256 amount) external;

    function addMintManuallyQuantity(uint256 tokenId, uint256 amount) external;

    function mint(uint256 tokenId, address to, uint256 quantity, bytes memory data) external;

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;

}

abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}

contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}

interface IERC20 {


    function burn(uint256 amount) external;

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract GachaMachineAzuki is Ownable, ERC1155Holder {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Round {
        uint256 id; // request id.
        address player; // address of player.
        RoundStatus status; // status of the round.
        uint256 times; // how many times of this round;
        uint256 totalTimes; // total time of an account.
        uint256[20] cards; // Prize card ot this round.
    }
    enum RoundStatus { Pending, Finished } // status of this round
    mapping(address => Round) public gameRounds;
    uint256 public currentRoundIdCount; //until now, the total round of this Gamemachine.
    uint256 public totalRoundCount;

    uint256 public machineId;
    string public machineTitle;
    string public machineDescription;
    string public machineUri;
    uint256 public machineType = 1;
    bool public maintaining = true;
    bool public banned = false;

    EnumerableSet.UintSet private _cardsSet;
    mapping(uint256 => uint256) public amountWithId;
    mapping(uint256 => uint256) public mintedCardAmountWithId;
    mapping(uint256 => uint256) private _prizePool;
    uint256 public cardAmount;

    uint256 private _salt;
    uint256 public shuffleCount = 10;

    uint256 public totalBurned = 0;

    uint256 public currencyBurnRate = 50;
    uint256 public forArtistRate = 40;
    IERC20 public currencyToken;
    uint256 public playOncePrice;
    IMomijiToken public momijiToken;

    EnumerableSet.AddressSet private _devAccountSet;

    address public administrator;

    event AddCardNotMinted(uint256 cardId, uint256 amount, uint256 cardAmount);
    event AddCardMinted(uint256 cardId, uint256 amount, uint256 cardAmount);
    event RemoveCard(uint256 card, uint256 removeAmount, uint256 cardAmount);
    event RunMachineSuccessfully(address account, uint256 times, uint256 playFee);
    event ChangePlayOncePrice(uint256 newPrice);
    event LockMachine(bool locked);
    event BanMachine(bool banned);

    constructor(uint256 _machineId,
                string memory _machineTitle,
                IMomijiToken _momijiToken,
                IERC20 _currencyToken) {
        machineId = _machineId;
        machineTitle = _machineTitle;
        machineDescription = _machineTitle;
        momijiToken = _momijiToken;
        currencyToken = _currencyToken;
        administrator = owner();
        _salt = uint256(keccak256(abi.encodePacked(_momijiToken, _currencyToken, block.timestamp))).mod(10000);
    }

    function addCardNotMintedWithAmount(uint256 cardId, uint256 amount) public onlyOwner unbanned {

        require((momijiToken.tokenQuantityWithId(cardId) + amount) <= momijiToken.tokenMaxQuantityWithId(cardId), "You add too much.");
        require(momijiToken.creators(cardId) == msg.sender, "You are not the creator of this Card.");
        _cardsSet.add(cardId);
        for (uint256 i = 0; i < amount; i ++) {
            _prizePool[cardAmount + i] = cardId;
        }
        amountWithId[cardId] = amountWithId[cardId].add(amount);
        momijiToken.removeMintManuallyQuantity(cardId, amount);
        cardAmount = cardAmount.add(amount);
        emit AddCardNotMinted(cardId, amount, cardAmount);
    }

    function addCardMintedWithAmount(uint256 cardId, uint256 amount) public onlyOwner unbanned {

        require(momijiToken.balanceOf(msg.sender, cardId) >= amount, "You don't have enough Cards");
        momijiToken.safeTransferFrom(msg.sender, address(this), cardId, amount, "Add Card");
        _cardsSet.add(cardId);
        mintedCardAmountWithId[cardId] = mintedCardAmountWithId[cardId].add(amount);
        amountWithId[cardId] = amountWithId[cardId].add(amount);
        for (uint256 i = 0; i < amount; i ++) {
            _prizePool[cardAmount + i] = cardId;
        }
        cardAmount = cardAmount.add(amount);
        emit AddCardMinted(cardId, amount, cardAmount);
    }

    function runMachine(uint256 userProvidedSeed, uint256 times) public onlyHuman unbanned {

        require(!maintaining, "This machine is under maintenance");
        require(!banned, "This machine is banned.");
        require(cardAmount > 0, "There is no card in this machine anymore.");
        require(times > 0, "Times can not be 0");
        require(times <= 20, "Over times.");
        require(times <= cardAmount, "You play too many times.");
        _createARound(times);
        uint256 seed = uint256(keccak256(abi.encode(userProvidedSeed, msg.sender)));
        _shufflePrizePool(seed);

        for (uint256 i = 0; i < times; i ++) {
            uint256 randomResult = _getRandomNumebr(seed, _salt, cardAmount);
            _salt = ((randomResult + cardAmount + _salt) * (i + 1) * block.timestamp).mod(cardAmount) + 1;
            uint256 result = (randomResult * _salt).mod(cardAmount);
            _updateRound(result, i);
        }

        totalRoundCount = totalRoundCount.add(times);
        uint256 playFee = playOncePrice.mul(times);
        _transferAndBurnToken(playFee);
        _distributePrize();

        emit RunMachineSuccessfully(msg.sender, times, playFee);
    }

    function _transferAndBurnToken(uint256 amount) private {

        _burnCurrencyTokenBalance();
        uint256 burnAmount = amount.mul(currencyBurnRate).div(100);
        currencyToken.transferFrom(msg.sender, address(this), burnAmount);

        uint256 forArtistAmount = amount.mul(forArtistRate).div(100);
        currencyToken.transferFrom(msg.sender, owner(), burnAmount);

        uint256 remainingAmount = amount.sub(burnAmount).sub(forArtistAmount);
        uint256 devAccountAmount = _devAccountSet.length();
        uint256 transferAmount = remainingAmount.div(devAccountAmount);

        for (uint256 i = 0; i < devAccountAmount; i ++) {
            address toAddress = _devAccountSet.at(i);
            currencyToken.safeTransferFrom(msg.sender, toAddress, transferAmount);
        }
    }

    function _distributePrize() private {

        for (uint i = 0; i < gameRounds[msg.sender].times; i ++) {
            uint256 cardId = gameRounds[msg.sender].cards[i];
            require(amountWithId[cardId] > 0, "No enough cards of this kind in the Mchine.");
            require(_calculateLastQuantityWithId(cardId) > 0, "Can not mint more cards of this kind.");

            if (mintedCardAmountWithId[cardId] > 0) {
                momijiToken.safeTransferFrom(address(this), msg.sender, cardId, 1, '');
                mintedCardAmountWithId[cardId] = mintedCardAmountWithId[cardId].sub(1);
            } else {
                momijiToken.mint(cardId, msg.sender, 1, "Minted by Gacha Machine.");
            }

            amountWithId[cardId] = amountWithId[cardId].sub(1);
            if (amountWithId[cardId] == 0) {
                _removeCardId(cardId);
            }
        }
        gameRounds[msg.sender].status = RoundStatus.Finished;
    }

    function _updateRound(uint256 randomResult, uint256 rand) private {

        uint256 cardId = _prizePool[randomResult];
        _prizePool[randomResult] = _prizePool[cardAmount - 1];
        cardAmount = cardAmount.sub(1);
        gameRounds[msg.sender].cards[rand] = cardId;
    }

    function _getRandomNumebr(uint256 seed, uint256 salt, uint256 mod) view private returns(uint256) {

        return uint256(keccak256(abi.encode(block.timestamp, block.difficulty, block.coinbase, block.gaslimit, seed, block.number))).mod(mod).add(seed).add(salt);
    }

    function _calculateLastQuantityWithId(uint256 cardId) view private returns(uint256) {

        return momijiToken.tokenMaxQuantityWithId(cardId)
                          .sub(momijiToken.tokenQuantityWithId(cardId));
    }

    function _createARound(uint256 times) private {

        gameRounds[msg.sender].id = currentRoundIdCount + 1;
        gameRounds[msg.sender].player = msg.sender;
        gameRounds[msg.sender].status = RoundStatus.Pending;
        gameRounds[msg.sender].times = times;
        gameRounds[msg.sender].totalTimes = gameRounds[msg.sender].totalTimes.add(times);
        currentRoundIdCount = currentRoundIdCount.add(1);
    }

    function _burnCurrencyTokenBalance() private {

        uint256 balance = currencyToken.balanceOf(address(this));
        if (balance > 0) {
            currencyToken.burn(balance);
            totalBurned = totalBurned.add(balance);
        }
    }

    function _shufflePrizePool(uint256 seed) private {

        for (uint256 i = 0; i < shuffleCount; i++) {
            uint256 randomResult = _getRandomNumebr(seed, _salt, cardAmount);
            _salt = ((randomResult + cardAmount + _salt) * (i + 1) * block.timestamp).mod(cardAmount);
            _swapPrize(i, _salt);
        }
    }

    function _swapPrize(uint256 a, uint256 b) private {

        uint256 temp = _prizePool[a];
        _prizePool[a] = _prizePool[b];
        _prizePool[b] = temp;
    }

    function _removeCardId(uint256 _cardId) private {

        _cardsSet.remove(_cardId);
    }

    function cardIdCount() view public returns(uint256) {

        return _cardsSet.length();
    }

    function cardIdWithIndex(uint256 index) view public returns(uint256) {

        return _cardsSet.at(index);
    }

    function changeShuffleCount(uint256 _shuffleCount) public onlyAdministrator {

        shuffleCount = _shuffleCount;
    }

    function changePlayOncePrice(uint256 newPrice) public onlyOwner {

        playOncePrice = newPrice;
        emit ChangePlayOncePrice(newPrice);
    }

    function getCardId(address account, uint256 at) view public returns(uint256) {

        return gameRounds[account].cards[at];
    }

    function unlockMachine() public onlyOwner {

        maintaining = false;
        emit LockMachine(false);
    }

    function lockMachine() public onlyOwner {

        maintaining = true;
        emit LockMachine(true);
    }

    function addDevAccount(address payable account) public onlyAdministrator {

        _devAccountSet.add(account);
    }

    function removeDevAccount(address payable account) public onlyAdministrator {

        _devAccountSet.remove(account);
    }

    function getDevAccount(uint256 index) public returns(address) {

        return _devAccountSet.at(index);
    }

    function devAccountLength() view public returns(uint256) {

        return _devAccountSet.length();
    }

    function changeBurnRate(uint256 rate) public onlyAdministrator {

        currencyBurnRate = rate;
    }

    function changeForArtistRate(uint256 rate) public onlyAdministrator {

        forArtistRate = rate;
    }

    function transferAdministrator(address account) public onlyAdministrator {

        require(account != address(0), "Ownable: new owner is the zero address");
        administrator = account;
    }

    function transferOwnership(address newOwner) public override onlyAdministrator {

        super.transferOwnership(newOwner);
    }

    function banThisMachine() public onlyAdministrator {

        banned = true;
    }

    function unbanThisMachine() public onlyAdministrator {

        banned = false;
    }

    function changeMachineTitle(string memory title) public onlyOwner {

        machineTitle = title;
    }

    function changeMachineDescription(string memory description) public onlyOwner {

        machineDescription = description;
    }

    function changeMachineUri(string memory newUri) public onlyOwner {

        machineUri = newUri;
    }

    function abandonMachine() public {

        require(msg.sender == administrator || msg.sender == owner(), "Only for administrator.");
        maintaining = true;
        banned = true;

        for (uint256 i = 0; i < cardIdCount(); i ++) {
            uint256 cardId = cardIdWithIndex(i);
            if (mintedCardAmountWithId[cardId] > 0) {
                momijiToken.safeTransferFrom(address(this), owner(), cardId, mintedCardAmountWithId[cardId], "Reset Machine");
                amountWithId[cardId] = amountWithId[cardId].sub(mintedCardAmountWithId[cardId]);
                cardAmount = cardAmount.sub(mintedCardAmountWithId[cardId]);
                mintedCardAmountWithId[cardId] = 0;
            }
            cardAmount = cardAmount.sub(amountWithId[cardId]);
            momijiToken.addMintManuallyQuantity(cardId, amountWithId[cardId]);
            amountWithId[cardId] = 0;
        }
    }

    modifier onlyHuman() {

        require(!address(msg.sender).isContract() && tx.origin == msg.sender, "Only for human.");
        _;
    }

    modifier onlyAdministrator() {

        require(address(msg.sender) == administrator, "Only for administrator.");
        _;
    }

    modifier unbanned() {

        require(!banned, "This machine is banned.");
        _;
    }
}