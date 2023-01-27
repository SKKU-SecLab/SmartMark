
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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

interface IPepemonFactory {

    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);

    function mint(address _to, uint256 _id, uint256 _quantity, bytes calldata _data) external;

    function burn(address _account, uint256 _id, uint256 _amount) external;

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;

    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;

}

contract PepemonStake is Ownable {

    using SafeMath for uint256;

    IPepemonFactory public pepemonFactory;

    struct StakingEvent {
        uint256[] cardIdList;
        uint256 cardAmountAny; // If this is > 0, cardAmountList will be ignored, and user will be able to stake multiple cards of any card accepted
        uint256[] cardAmountList; // Will be ignored if cardAmountAny > 0
        uint256 cardRewardId;
        uint256 blockStakeLength; // Amounts of blocks of staking required to complete the event
        uint256 blockEventClose; // Block at which this event will not accept any new stake
        uint256[] toBurnIdList; // Id list of cards to burn on completion of event
        uint256[] toBurnAmountList; // Amount list of cards to burn on completion of event
    }

    struct UserInfo {
        bool isCompleted;
        uint256 blockEnd; // Block at which user will have completed the event (If this is not 0, user is currently staking)
    }

    StakingEvent[] public stakingEvents;
    mapping (address => mapping(uint256 => UserInfo)) public userInfo;
    mapping (address => mapping(uint256 => mapping(uint256 => uint256))) public cardsStaked; // address => eventId => cardId => amountStaked


    event StakingEventCreated(uint256 eventId);
    event StakingEventEntered(address indexed user, uint256 eventId);
    event StakingEventCompleted(address indexed user, uint256 eventId);
    event StakingEventCancelled(address indexed user, uint256 eventId);


    constructor(IPepemonFactory _pepemonFactoryAddress) public {
        pepemonFactory = _pepemonFactoryAddress;
    }


    function getStakingEventsLength() external view returns(uint256) {

        return stakingEvents.length;
    }

    function getAllEvents() public view returns(StakingEvent[] memory) {

        return stakingEvents;
    }

    function getActiveEvents() external view returns(uint256[] memory) {

        StakingEvent[] memory _events = getAllEvents();

        uint256 nbActive = 0;
        for (uint256 i = 0; i < _events.length; i++) {
            if (_events[i].blockEventClose >= block.number) {
                nbActive++;
            }
        }

        uint256[] memory _result = new uint256[](nbActive);
        uint256 idx = 0;
        for (uint256 i = 0; i < _events.length; i++) {
            if (_events[i].blockEventClose >= block.number) {
                _result[idx] = i;
                idx++;
            }
        }

        return _result;
    }

    function getClosedEvents() external view returns(uint256[] memory) {

        StakingEvent[] memory _events = getAllEvents();

        uint256 nbCompleted = 0;
        for (uint256 i = 0; i < _events.length; i++) {
            if (_events[i].blockEventClose < block.number) {
                nbCompleted++;
            }
        }

        uint256[] memory _result = new uint256[](nbCompleted);
        uint256 idx = 0;
        for (uint256 i = 0; i < _events.length; i++) {
            if (_events[i].blockEventClose < block.number) {
                _result[idx] = i;
                idx++;
            }
        }

        return _result;
    }

    function getCardIdListOfEvent(uint256 _eventId) external view returns(uint256[] memory) {

        return stakingEvents[_eventId].cardIdList;
    }

    function getCardAmountListOfEvent(uint256 _eventId) external view returns(uint256[] memory) {

        return stakingEvents[_eventId].cardAmountList;
    }

    function getUserProgress(address _user, uint256 _eventId) external view returns(uint256) {

        StakingEvent memory _event = stakingEvents[_eventId];
        UserInfo memory _userInfo = userInfo[_user][_eventId];

        if (_userInfo.blockEnd == 0) {
            return 0;
        }

        if (_userInfo.isCompleted || block.number >= _userInfo.blockEnd) {
            return 1e5;
        }

        uint256 blocksLeft = _userInfo.blockEnd.sub(block.number);
        uint256 blocksStaked = _event.blockStakeLength.sub(blocksLeft);

        return blocksStaked.mul(1e5).div(_event.blockStakeLength);
    }



    function createStakingEvent(uint256[] memory _cardIdList, uint256 _cardAmountAny, uint256[] memory _cardAmountList, uint256 _cardRewardId,
        uint256 _blockStakeLength, uint256 _blockEventClose, uint256[] memory _toBurnIdList, uint256[] memory _toBurnAmountList) public onlyOwner {


        require(_cardIdList.length > 0, "Accepted card list is empty");
        require(_cardAmountAny > 0 || _cardAmountList.length > 0, "Card amount required not specified");
        require(_blockEventClose > block.number, "blockEventClose < current block");
        require(_toBurnIdList.length == _toBurnAmountList.length, "ToBurn arrays have different length");
        require(_cardAmountAny == 0 || _toBurnIdList.length == 0, "ToBurn not supported with anyEvent");

        stakingEvents.push(StakingEvent({
        cardIdList: _cardIdList,
        cardAmountAny: _cardAmountAny,
        cardAmountList: _cardAmountList,
        cardRewardId: _cardRewardId,
        blockStakeLength: _blockStakeLength,
        blockEventClose: _blockEventClose,
        toBurnIdList: _toBurnIdList,
        toBurnAmountList: _toBurnAmountList
        }));

        emit StakingEventCreated(stakingEvents.length - 1);
    }

    function closeStakingEvent(uint256 _eventId) public onlyOwner {

        require(stakingEvents[_eventId].blockEventClose > block.number, "Event already closed");
        stakingEvents[_eventId].blockEventClose = block.number;
    }


    function stakeAny(uint256 _eventId, uint256[] memory _cardIdList, uint256[] memory _cardAmountList) public {

        require(_cardIdList.length == _cardAmountList.length, "Arrays have different length");

        StakingEvent storage _event = stakingEvents[_eventId];
        UserInfo storage _userInfo = userInfo[msg.sender][_eventId];

        require(block.number <= _event.blockEventClose, "Event is closed");
        require(_userInfo.isCompleted == false, "Address already completed event");
        require(_userInfo.blockEnd == 0, "Address already staked for this event");
        require(_event.cardAmountAny > 0, "Not a stakeAny event");

        for (uint256 i = 0; i < _cardIdList.length; i++) {
            require(_isInArray(_cardIdList[i], _event.cardIdList), "Card not accepted");
        }

        uint256 total = 0;
        for (uint256 i = 0; i < _cardAmountList.length; i++) {
            total = total.add(_cardAmountList[i]);
        }

        require(total == _event.cardAmountAny, "Wrong card total");

        pepemonFactory.safeBatchTransferFrom(msg.sender, address(this), _cardIdList, _cardAmountList, "");

        for (uint256 i = 0; i < _cardIdList.length; i++) {
            uint256 cardId = _cardIdList[i];
            uint256 amount = _cardAmountList[i];

            cardsStaked[msg.sender][_eventId][cardId] = amount;
        }

        _userInfo.blockEnd = block.number.add(_event.blockStakeLength);

        emit StakingEventEntered(msg.sender, _eventId);
    }

    function stake(uint256 _eventId) public {

        StakingEvent storage _event = stakingEvents[_eventId];
        UserInfo storage _userInfo = userInfo[msg.sender][_eventId];

        require(block.number <= _event.blockEventClose, "Event is closed");
        require(_userInfo.isCompleted == false, "Address already completed event");
        require(_userInfo.blockEnd == 0, "Address already staked for this event");

        pepemonFactory.safeBatchTransferFrom(msg.sender, address(this), _event.cardIdList, _event.cardAmountList, "");

        for (uint256 i = 0; i < _event.cardIdList.length; i++) {
            uint256 cardId = _event.cardIdList[i];
            uint256 amount = _event.cardAmountList[i];

            cardsStaked[msg.sender][_eventId][cardId] = amount;
        }

        _userInfo.blockEnd = block.number.add(_event.blockStakeLength);

        emit StakingEventEntered(msg.sender, _eventId);
    }

    function claim(uint256 _eventId) public {

        StakingEvent storage _event = stakingEvents[_eventId];
        UserInfo storage _userInfo = userInfo[msg.sender][_eventId];

        require(block.number >= _userInfo.blockEnd, "BlockEnd not reached");

        _userInfo.isCompleted = true;
        pepemonFactory.mint(msg.sender, _event.cardRewardId, 1, "");
        _withdrawCardsStaked(_eventId, true);

        emit StakingEventCompleted(msg.sender, _eventId);
    }

    function cancel(uint256 _eventId) public {

        UserInfo storage _userInfo = userInfo[msg.sender][_eventId];

        require(_userInfo.isCompleted == false, "Address already completed event");
        require(_userInfo.blockEnd != 0, "Address is not staked for this event");

        delete _userInfo.isCompleted;
        delete _userInfo.blockEnd;

        _withdrawCardsStaked(_eventId, false);

        emit StakingEventCancelled(msg.sender, _eventId);
    }

    function _withdrawCardsStaked(uint256 _eventId, bool _burn) internal {

        StakingEvent storage _event = stakingEvents[_eventId];

        uint256[] memory _cardIdList = _event.cardIdList;
        uint256[] memory _cardAmountList = new uint256[](_cardIdList.length);

        uint256[] memory _toBurnIdList = _event.toBurnIdList;
        uint256[] memory _toBurnAmountList = _event.toBurnAmountList;


        if (_burn == true) {
            for (uint256 i = 0; i < _toBurnIdList.length; i++) {
                uint256 cardId = _toBurnIdList[i];
                uint256 amount = _toBurnAmountList[i];

                cardsStaked[msg.sender][_eventId][cardId] = cardsStaked[msg.sender][_eventId][cardId].sub(amount);
                pepemonFactory.burn(address(this), cardId, amount);
            }
        }

        for (uint256 i = 0; i < _cardIdList.length; i++) {
            uint256 cardId = _cardIdList[i];
            _cardAmountList[i] = cardsStaked[msg.sender][_eventId][cardId];
            delete cardsStaked[msg.sender][_eventId][cardId];
        }

        pepemonFactory.safeBatchTransferFrom(address(this), msg.sender, _cardIdList, _cardAmountList, "");
    }

    function _isInArray(uint256 _value, uint256[] memory _array) internal pure returns(bool) {

        uint256 length = _array.length;
        for (uint256 i = 0; i < length; ++i) {
            if (_array[i] == _value) {
                return true;
            }
        }

        return false;
    }


    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4) {

        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4) {

        return 0xbc197c81;
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {

        return  interfaceID == 0x01ffc9a7 ||    // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
        interfaceID == 0x4e2312e0;      // ERC-1155 `ERC1155TokenReceiver` support (i.e. `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
    }
}