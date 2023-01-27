

pragma solidity =0.8.10 >=0.6.0 >=0.8.0 >=0.6.0 <0.9.0 >=0.8.0 <0.9.0;



library BokkyPooBahsDateTimeLibrary {


    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {

        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {

        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {

        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {

        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {

        (uint year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {

        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {

        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {

        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {

        (uint year, uint month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {

        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {

        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {

        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {

        (,month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {

        (,,day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {

        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {

        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {

        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {

        require(fromTimestamp <= toTimestamp);
        (uint fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {

        require(fromTimestamp <= toTimestamp);
        (uint fromYear, uint fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear, uint toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {

        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {

        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {

        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {

        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}



library Base64 {

    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';

        string memory table = TABLE_ENCODE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {

        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        bytes memory table = TABLE_DECODE;

        uint256 decodedLen = (data.length / 4) * 3;

        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            mstore(result, decodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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


abstract contract ERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);


    mapping(address => uint256) public balanceOf;

    mapping(uint256 => address) public ownerOf;

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }


    function approve(address spender, uint256 id) public virtual {
        address owner = ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || msg.sender == getApproved[id] || isApprovedForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        unchecked {
            balanceOf[from]--;

            balanceOf[to]++;
        }

        ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }


    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }


    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(ownerOf[id] == address(0), "ALREADY_MINTED");

        unchecked {
            balanceOf[to]++;
        }

        ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = ownerOf[id];

        require(ownerOf[id] != address(0), "NOT_MINTED");

        unchecked {
            balanceOf[owner]--;
        }

        delete ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }


    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

interface ERC721TokenReceiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4);

}


abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}



error CharitySplitter__InvalidCharityAddress();

error CharitySplitter__InvalidCharityFee();

contract CharitySplitter {


    address payable public charity;

    uint256 public charityFeeBp;

    constructor(address payable _charity, uint256 _charityFeeBp) {
        if (_charity == address(0)) {
            revert CharitySplitter__InvalidCharityAddress();
        }

        if (_charityFeeBp == 0) {
            revert CharitySplitter__InvalidCharityFee();
        }

        charity = _charity;
        charityFeeBp = _charityFeeBp;
    }


    event CharityUpdated(address charity);

    function _updateCharity(address payable _charity)
        internal
    {

        if (_charity == address(0)) {
            revert CharitySplitter__InvalidCharityAddress();
        }

        charity = _charity;
    }


    uint256 public charityBalance;

    uint256 public ownerBalance;

    uint256 private constant BP_DENOMINATOR = 10000;

    function _updateBalance(uint256 value)
        internal
    {

        if (value == 0) {
            return;
        }

        uint256 charityValue = (value * charityFeeBp) / BP_DENOMINATOR;
        uint256 ownerValue = value - charityValue;

        charityBalance += charityValue;
        ownerBalance += ownerValue;
    }


    function _withdrawCharityBalance()
        internal
    {

        uint256 value = charityBalance;

        if (value == 0) {
            return;
        }

        charityBalance = 0;

        (bool sent, ) = charity.call{value: value}("");
        require(sent);
    }

    function _withdrawOwnerBalance(address payable destination)
        internal
    {

        uint256 value = ownerBalance;

        if (value == 0) {
            return;
        }

        ownerBalance = 0;

        (bool sent, ) = destination.call{value: value}("");
        require(sent);
    }
}





error EthTime__DoesNotExist();

error EthTime__NotOwner();

error EthTime__InvalidTimeOffset();

error EthTime__NumberOutOfRange();

error EthTime__InvalidMintValue();

error EthTime__InvalidMintAmount();

error EthTime__CollectionMintClosed();

contract EthTime is ERC721, CharitySplitter, Ownable, ReentrancyGuard {


    constructor(address payable charity, uint256 charityFeeBp)
        ERC721("ETH Time", "ETHT")
        CharitySplitter(charity, charityFeeBp)
    {
    }

    receive() external payable {}


    mapping(uint256 => uint160) public historyAccumulator;

    function transferFrom(address from, address to, uint256 id)
        public
        nonReentrant
        override
    {

        _transferFrom(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id)
        public
        nonReentrant
        override
    {

        _transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes memory /* data */)
        public
        nonReentrant
        override
    {

        _transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }


    function withdrawCharityBalance()
        public
        nonReentrant
    {

        _withdrawCharityBalance();
    }

    function withdrawOwnerBalance(address payable destination)
        public
        onlyOwner
        nonReentrant
    {

        _withdrawOwnerBalance(destination);
    }

    function updateCharity(address payable charity)
        public
        onlyOwner
        nonReentrant
    {

        _updateCharity(charity);
    }


    mapping(uint256 => int128) public timeOffsetMinutes;

    event TimeOffsetUpdated(uint256 indexed id, int128 offsetMinutes);

    function setTimeOffsetMinutes(uint256 id, int128 offsetMinutes)
        public
    {

        if (ownerOf[id] == address(0)) {
            revert EthTime__DoesNotExist();
        }

        if (ownerOf[id] != msg.sender) {
            revert EthTime__NotOwner();
        }

        _validateTimeOffset(offsetMinutes);

        timeOffsetMinutes[id] = offsetMinutes;

        emit TimeOffsetUpdated(id, offsetMinutes);
    }

    function _validateTimeOffset(int128 offsetMinutes)
        internal
    {

        int128 offsetSeconds = offsetMinutes * 60;

        if (offsetSeconds > 14 hours || offsetSeconds < -12 hours) {
            revert EthTime__InvalidTimeOffset();
        }
    }


    uint256 public totalSupply;

    uint256 public constant maximumSupply = 100;

    uint256 private constant TARGET_PRICE = 1 ether;
    uint256 private constant PRICE_INCREMENT = TARGET_PRICE / maximumSupply * 2;

    function mint(address to, int128 offsetMinutes, uint256 id)
        public
        payable
        nonReentrant
        virtual
    {

        uint256 valueLeft = _mint(to, offsetMinutes, id, msg.value);
    
        if (valueLeft > 0) {
            (bool success, ) = msg.sender.call{value: valueLeft}("");
            require(success);
        }
    }

    function batchMint(address to, int128 offsetMinutes, uint256[] calldata ids)
        public
        payable
        nonReentrant
        virtual
    {

        uint256 count = ids.length;

        _validateBatchMintCount(count);

        uint256 valueLeft = msg.value;
        for (uint256 i = 0; i < count; i++) {
            valueLeft = _mint(to, offsetMinutes, ids[i], valueLeft);
        }

        if (valueLeft > 0) {
            (bool success, ) = msg.sender.call{value: valueLeft}("");
            require(success);
        }
    }

    function getBatchMintPrice(uint256 count)
        public
        view
        returns (uint256)
    {

        _validateBatchMintCount(count);

        uint256 supply = totalSupply;
        uint256 price = 0;
        for (uint256 i = 0; i < count; i++) {
            price += _priceAtSupplyLevel(supply + i);
        }
        
        return price;
    }

    function getMintPrice()
        public
        view
        returns (uint256)
    {

        return _priceAtSupplyLevel(totalSupply);
    }

    function _mint(address to, int128 offsetMinutes, uint256 id, uint256 value)
        internal
        returns (uint256 valueLeft)
    {

        uint256 price = _priceAtSupplyLevel(totalSupply);

        if (value < price) {
            revert EthTime__InvalidMintValue();
        }

        if (totalSupply == maximumSupply) {
            revert EthTime__CollectionMintClosed();
        }

        _validateTimeOffset(offsetMinutes);

        historyAccumulator[id] = uint160(id >> 4);

        totalSupply += 1;

        _updateBalance(value);

        timeOffsetMinutes[id] = offsetMinutes;

        _safeMint(to, id);

        valueLeft = value - price;
    }

    function _priceAtSupplyLevel(uint256 supply)
        internal
        pure
        returns (uint256)
    {

        uint256 price = supply * PRICE_INCREMENT;

        if (supply > 50) {
            price = TARGET_PRICE;
        }

        return price;
    }

    function _validateBatchMintCount(uint256 count)
        internal
        view
    {

        if (count > 10) {
            revert EthTime__InvalidMintAmount();
        }

        if (totalSupply + count > maximumSupply) {
            revert EthTime__InvalidMintAmount();
        }
    }


    function tokenURI(uint256 id)
        public
        view
        override
        returns (string memory)
    {

        if (ownerOf[id] == address(0)) {
            revert EthTime__DoesNotExist();
        }

        string memory tokenId = Strings.toString(id);

        (uint256 hour, uint256 minute) = _adjustedHourMinutes(id);

        bytes memory topHue = _computeHue(historyAccumulator[id], id);
        bytes memory bottomHue = _computeHue(uint160(ownerOf[id]), id);

        int128 offset = timeOffsetMinutes[id];
        bytes memory offsetSign = offset >= 0 ? bytes('+') : bytes('-');
        uint256 offsetUnsigned = offset >= 0 ? uint256(int256(offset)) : uint256(int256(-offset));

        return
            string(
                bytes.concat(
                    'data:application/json;base64,',
                    bytes(
                        Base64.encode(
                            bytes.concat(
                                '{"name": "ETH Time #',
                                bytes(tokenId),
                                '", "description": "ETH Time", "image": "data:image/svg+xml;base64,',
                                bytes(_tokenImage(topHue, bottomHue, hour, minute)),
                                '", "attributes": [{"trait_type": "top_color", "value": "hsl(', topHue, ',100%,89%)"},',
                                '{"trait_type": "bottom_color", "value": "hsl(', bottomHue, ',77%,36%)"},',
                                '{"trait_type": "time_offset", "value": "', offsetSign, bytes(Strings.toString(offsetUnsigned)),  '"},',
                                '{"trait_type": "time", "value": "', bytes(Strings.toString(hour)), ':', bytes(Strings.toString(minute)), '"}]}'
                            )
                        )
                    )
                )
            );
    }

    function tokenImagePreview(address to, uint256 id)
        public
        view
        returns (string memory)
    {
        (uint256 hour, uint256 minute) = _adjustedHourMinutes(id);

        bytes memory topHue = _computeHue(uint160(id >> 4), id);
        bytes memory bottomHue = _computeHue(uint160(to), id);

        return _tokenImage(topHue, bottomHue, hour, minute);
    }


    function _updateHistory(address to, uint256 id)
        internal
    {
        historyAccumulator[id] ^= uint160(to) << 2;
    }

    function _transferFrom(address from, address to, uint256 id)
        internal
    {
        require(from == ownerOf[id], "WRONG_FROM");
        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || msg.sender == getApproved[id] || isApprovedForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        unchecked {
            balanceOf[from]--;
            balanceOf[to]++;
        }

        ownerOf[id] = to;

        delete getApproved[id];

        _updateHistory(to, id);

        emit Transfer(from, to, id);
    }

    bytes constant onColor = "FFF";
    bytes constant offColor = "333";

    function _tokenImage(bytes memory topHue, bytes memory bottomHue, uint256 hour, uint256 minute)
        internal
        pure
        returns (string memory)
    {

        return
            Base64.encode(
                bytes.concat(
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000">',
                    '<linearGradient id="bg" gradientTransform="rotate(90)">',
                    '<stop offset="0%" stop-color="hsl(', topHue, ',100%,89%)"/>',
                    '<stop offset="100%" stop-color="hsl(', bottomHue, ',77%,36%)"/>',
                    '</linearGradient>',
                    '<rect x="0" y="0" width="1000" height="1000" fill="url(#bg)"/>',
                    _binaryHour(hour),
                    _binaryMinute(minute),
                    '</svg>'
                )
            );
    }

    function _binaryHour(uint256 hour)
        internal
        pure
        returns (bytes memory)
    {
        if (hour > 24) {
            revert EthTime__NumberOutOfRange();
        }

        bytes[7] memory colors = _binaryColor(hour);

        return
            bytes.concat(
                '<circle cx="665" cy="875" r="25" fill="#', colors[0], '"/>',
                '<circle cx="665" cy="805" r="25" fill="#', colors[1], '"/>',
                '<circle cx="735" cy="875" r="25" fill="#', colors[3], '"/>',
                '<circle cx="735" cy="805" r="25" fill="#', colors[4], '"/>',
                '<circle cx="735" cy="735" r="25" fill="#', colors[5], '"/>',
                '<circle cx="735" cy="665" r="25" fill="#', colors[6], '"/>'
            );
    }

    function _binaryMinute(uint256 minute)
        internal
        pure
        returns (bytes memory)
    {
        if (minute > 59) {
            revert EthTime__NumberOutOfRange();
        }

        bytes[7] memory colors = _binaryColor(minute);

        return
            bytes.concat(
                '<circle cx="805" cy="875" r="25" fill="#', colors[0], '"/>',
                '<circle cx="805" cy="805" r="25" fill="#', colors[1], '"/>',
                '<circle cx="805" cy="735" r="25" fill="#', colors[2], '"/>',

                '<circle cx="875" cy="875" r="25" fill="#', colors[3], '"/>',
                '<circle cx="875" cy="805" r="25" fill="#', colors[4], '"/>',
                '<circle cx="875" cy="735" r="25" fill="#', colors[5], '"/>',
                '<circle cx="875" cy="665" r="25" fill="#', colors[6], '"/>'
            );
    }

    function _binaryColor(uint256 n)
        internal
        pure
        returns (bytes[7] memory)
    {
        unchecked {
            uint256 firstDigit = n / 10;
            uint256 secondDigit = n % 10;

            return [
                (firstDigit & 0x1 != 0) ? onColor : offColor,
                (firstDigit & 0x2 != 0) ? onColor : offColor,
                (firstDigit & 0x4 != 0) ? onColor : offColor,

                (secondDigit & 0x1 != 0) ? onColor : offColor,
                (secondDigit & 0x2 != 0) ? onColor : offColor,
                (secondDigit & 0x4 != 0) ? onColor : offColor,
                (secondDigit & 0x8 != 0) ? onColor : offColor
            ];
        }
    }

    function _computeHue(uint160 n, uint256 id)
        internal
        pure
        returns (bytes memory)
    {
        uint160 t = n ^ uint160(id);
        uint160 acc = t % 360;
        return bytes(Strings.toString(acc));
    }

    function _adjustedHourMinutes(uint256 id)
        internal
        view
        returns (uint256 hour, uint256 minute)
    {
        int256 signedUserTimestamp = int256(block.timestamp) - 60 * timeOffsetMinutes[id];

        uint256 userTimestamp;
        if (signedUserTimestamp <= 0) {
            userTimestamp = 0;
        } else {
            userTimestamp = uint256(signedUserTimestamp);
        }
        hour = BokkyPooBahsDateTimeLibrary.getHour(userTimestamp);
        minute = BokkyPooBahsDateTimeLibrary.getMinute(userTimestamp);
    }
}