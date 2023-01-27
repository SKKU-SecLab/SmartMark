

pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

}

contract BooLottery is Ownable {

    using NameFilter for string;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public runTime = 2 days;

    uint256 public ticketPrice = 1000000000000000000;

    IERC20 public boob;
    IERC721 public nft;

    struct Lottery {
        uint256 ticketPrice;
        uint256 potValue; // Total value of pot
        uint256 startTs; // Lottery start timestamp
        uint256 endTs; // Lottery end timestamp (should be at startTs + runTime or as close after as possible)
        uint256 startBlock; // Lottery start block
        uint256 endBlock; // Lottery end block
        address winner; // Address of winner
        uint256 luckyNumber; // rnd number
        uint256 fee; // How much was earmarked for devs
        bool running; // Is still running - just to keep track of whether it's been processed
        uint256 totalTickets; // Tickets sold
    }

    struct Ticket {
        uint256 price; // Price of ticket
        address ticketHolder; // Address of ticket holder
        uint256 ts; // timestamp
    }

    struct UserInfo {
        address wallet;
        bytes32 name; // Yep you can name your wallet
        uint256 wins;
        uint256 entries;
    }

    Lottery[] public lotteryInfo;

    mapping (uint256 => mapping (address => Ticket[])) public userPlayRecord;
    mapping (uint256 => mapping (address => bool)) public freeEntry;
    mapping (uint256 => Ticket[]) public lotteryTickets;
    mapping (address => UserInfo) public userInfo;

    uint256 public feeDivisor;

    address public feeAddress;

    event TicketPurchase(address indexed user, uint256 indexed lottery, uint256 tickets, uint256 amount);
    event FreeTicket(address indexed user, uint256 indexed lottery, address nft, uint256 id);
    event LotteryStart(uint256 indexed lottery, uint256 startTimestamp);
    event LotteryEnd(uint256 prize, address indexed winner, uint256 totalTickets);
    event NameChange(address indexed user, bytes32 name);

    constructor(IERC20 _boob, IERC721 _nft) public
    {
        boob = _boob;
        nft = _nft;
        feeAddress = msg.sender;
        feeDivisor = 100;
        startLottery();
    }

    modifier isHuman() {

        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "humans only fren");
        _;
    }

    function lotteryInfoLength() external view returns (uint256) {

        return lotteryInfo.length;
    }

    function currentLotteryPotValue() external view returns (uint256) {

        if (lotteryInfo.length == 0) {
            return 0;
        }

        return lotteryInfo[lotteryInfo.length - 1].potValue;
    }

    function getUserPlayRecord(address _user, uint256 _lottery) external view returns (Ticket[] memory _tickets) {

        return userPlayRecord[_lottery][_user];
    }

    function getLotteryEntries(uint256 _lottery) external view returns (Ticket[] memory _tickets) {

        return lotteryTickets[_lottery];
    }

    function totalLotteryEntries(uint256 _lottery) external view returns (uint256) {

        return lotteryInfo[_lottery].totalTickets;
    }

    function currentLotteryEntryCount() external view returns (uint256) {

        return lotteryInfo[lotteryInfo.length - 1].totalTickets;
    }

    function setBoobAddress(IERC20 _boob) public onlyOwner {

        require(address(_boob) != address(0), 'Cannot be 0x0');
        boob = _boob;
    }

    function setBoobNftAddress(IERC721 _nft) public onlyOwner {

        require(address(_nft) != address(0), 'Cannot be 0x0');
        nft = _nft;
    }

    function rand(uint256 _to) internal returns(uint256) {

        uint256 seed = uint256(keccak256(abi.encodePacked(
                (block.timestamp).add
                (block.difficulty).add
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))).div(now)).add
                (block.gaslimit).add
                ((uint256(keccak256(abi.encodePacked(msg.sender)))).div(now)).add
                (block.number)
            )));

        return (seed - ((seed.div(_to)).mul(_to)));
    }

    function setFee(uint256 _fee) public onlyOwner {

        feeDivisor = _fee;
    }

    function setFeeAddress(IERC20 _feeAddress) public onlyOwner {

        feeAddress = address(_feeAddress);
    }

    function setRunTime(uint _runTime) public onlyOwner {

        require(_runTime > 1 days, 'runTime must be greater than 1 day');
        runTime = _runTime;
    }

    function setTicketPrice(uint256 _ticketPrice) public onlyOwner {

        require(_ticketPrice > 0, 'price must be greater than zero');
        ticketPrice = _ticketPrice;
    }

    function checkLotteryStatus() public {

        uint256 len = lotteryInfo.length;
        if (len > 0) {
            Lottery storage lottery = lotteryInfo[len - 1];
            if (lottery.endTs <= block.timestamp && lottery.running) {
                concludeLottery(lottery);
            }
        } else {
            startLottery();
        }
    }

    function xEmergencyStartLottery() public onlyOwner {

        startLottery();
    }

    function xEmergencyStopLottery() public onlyOwner {

        Lottery storage lottery = lotteryInfo[lotteryInfo.length - 1];
        lottery.endTs = 1;
        concludeLottery(lottery);
    }

    function startLottery() internal {

        lotteryInfo.push(Lottery({
            ticketPrice: ticketPrice,
            potValue: 0,
            startTs: now,
            endTs: now.add(runTime),
            startBlock: block.number,
            endBlock: 0,
            winner: address(0),
            luckyNumber: 0,
            fee: 0,
            running: true,
            totalTickets: 0
        }));

        emit LotteryStart(lotteryInfo.length - 1, block.timestamp);
    }

    function concludeLottery(Lottery storage lottery) internal {

        lottery.running = false;
        lottery.endTs = block.timestamp;
        lottery.endBlock = block.number;

        if (feeDivisor > 0 && lottery.potValue > 0) {
            lottery.fee = lottery.potValue.div(feeDivisor);
            lottery.potValue = lottery.potValue.sub(lottery.fee);
        }

        if (lotteryTickets[lotteryInfo.length - 1].length > 0) {
            uint256 rnd = rand(lotteryTickets[lotteryInfo.length - 1].length);
            Ticket storage winningTicket = lotteryTickets[lotteryInfo.length - 1][rnd];
            lottery.winner = winningTicket.ticketHolder;
            lottery.luckyNumber = rnd;

            UserInfo storage user = userInfo[lottery.winner];
            user.wins = user.wins + 1;

            if (lottery.fee > 0) {
                safeBoobTransfer(feeAddress, lottery.fee);
            }

            safeBoobTransfer(lottery.winner, lottery.potValue);

            emit LotteryEnd(lottery.potValue, lottery.winner, lottery.totalTickets);
        }
        startLottery();
    }

    function safeBoobTransfer(address _to, uint256 _amount) internal {

        uint256 boobBal = boob.balanceOf(address(this));
        if (_amount > boobBal) {
            boob.transfer(_to, boobBal);
        } else {
            boob.transfer(_to, _amount);
        }
    }


    function buyTicket(uint256 _ticketCount) isHuman public {

        require(_ticketCount > 0, 'You must buy at least one ticket');
        uint256 amount = ticketPrice.mul(_ticketCount);
        require(boob.balanceOf(address(msg.sender)) > amount, 'Insufficient funds for amount of tickets requested');

        checkLotteryStatus();

        if(lotteryInfo.length > 0) {
            UserInfo storage user = userInfo[msg.sender];
            uint256 _lot = lotteryInfo.length.sub(1);
            Lottery storage lottery = lotteryInfo[_lot];

            boob.safeTransferFrom(address(msg.sender), address(this), amount);

            lottery.potValue = lottery.potValue.add(amount);
            lottery.totalTickets = lottery.totalTickets.add(_ticketCount);

            user.entries = user.entries.add(_ticketCount);

            Ticket memory _ticket = Ticket({price: ticketPrice, ticketHolder: address(msg.sender), ts: now});
            for (uint256 _t = 0; _t < _ticketCount; _t++) {
                userPlayRecord[_lot][msg.sender].push(_ticket);
                lotteryTickets[_lot].push(_ticket);
            }

            if (
                address(nft) != address(0) &&
                nft.balanceOf(address(msg.sender)) > 0 &&
                !freeEntry[_lot][msg.sender]
            ) {
                freeEntry[_lot][msg.sender] = true;
                Ticket memory _freeTicket = Ticket({price: 0, ticketHolder: address(msg.sender), ts: now});
                userPlayRecord[_lot][msg.sender].push(_freeTicket);
                lotteryTickets[_lot].push(_freeTicket);
                lottery.totalTickets = lottery.totalTickets.add(1);
            }

            emit TicketPurchase(msg.sender, _lot, _ticketCount, amount);
        }
    }

    function registerName(string memory _nameString) isHuman public {

        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        UserInfo storage user = userInfo[_addr];
        user.wallet = _addr;
        user.name = _name;

        emit NameChange(_addr, _name);
    }
}

library NameFilter {

    function nameFilter(string memory _input)
    internal
    pure
    returns(bytes32)
    {

        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        bool _hasNonNumber;

        for (uint256 i = 0; i < _length; i++)
        {
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                _temp[i] = byte(uint8(_temp[i]) + 32);

                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    _temp[i] == 0x20 ||
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}