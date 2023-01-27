
pragma solidity ^0.8.0;

library AddressUpgradeable {

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
}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library SafeCastUpgradeable {

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}//Unlicense
pragma solidity ^0.8.4;



contract Repository is Initializable {

    using SafeCastUpgradeable for uint256;

    struct Player {
        bool register;
        address upline;
        uint256 playingHigh;
        uint256 playingMedium;
        uint256 playCountHigh;
        uint256 playCountMedium;
        uint256 maxPlayCountHigh;
        uint256 maxPlayCountMedium;
        uint256 trophyHigh;
        uint256 trophyMedium;
    }

    struct PlayingTable {
        TablePrice price;
        uint8 trophy;
        uint8 playCount;
        uint8 maxCount;
        uint32 no;
    }

    struct PlayerInfo {
        bool register;
        bool playing;
        address account;
        address upline;
        address[] downlines;
        PlayingTable[] playingTable;
    }

    enum TableType {
        Original,
        Split
    }

    enum TablePrice {
        High,
        Medium
    }

    struct Table {
        bool isOpen;
        TableType tableType;
        TablePrice price;
        uint256 index; //index at opening
    }

    struct TableInfo {
        bool isOpen;
        TableType tableType;
        TablePrice priceType;
        uint32 tableNo;
        uint256 price;
        address[] seats;
    }

    uint256 internal playerCount; //total player count
    uint256 internal tableCount; //total table count
    mapping(address => bytes32) internal players; //player address =>  encoded Player struct; 1:1
    mapping(address => address) internal upline; //player address =>  upline address; 1:1
    mapping(uint256 => bytes32) internal tables; //table no => encoded Table struct; 1:1

    mapping(address => address[]) downlines; //player address => downlines address; 1:N

    mapping(uint256 => uint256[]) internal opening; //TablePrice => tables no; 1:N

    mapping(uint256 => address[]) seats; //table no => players adderss; 1:N


    function initialize() public virtual initializer {

        tableCount = 1;
    }

    function PlayerSerializing(
        uint8 _register,
        uint8 _trophyHigh,
        uint8 _trophyMedium,
        uint8 _playCountHigh,
        uint8 _playCountMedium,
        uint8 _maxPlayCountHigh,
        uint8 _maxPlayCountMedium,
        uint32 _playingHigh,
        uint32 _playingMedium
    ) internal pure returns (bytes32 bytecode) {

        assembly {
            mstore(0x20, _register)
            mstore(0x1f, _trophyHigh)
            mstore(0x1e, _trophyMedium)
            mstore(0x1d, _playCountHigh)
            mstore(0x1c, _playCountMedium)
            mstore(0x1b, _maxPlayCountHigh)
            mstore(0x1a, _maxPlayCountMedium)
            mstore(0x19, _playingHigh)
            mstore(0x15, _playingMedium)

            bytecode := mload(0x20)
        }
    }

    function PlayerDeserializing(bytes32 _bytecode)
        internal
        pure
        returns (
            uint8 register,
            uint8 trophyHigh,
            uint8 trophyMedium,
            uint8 playCountHigh,
            uint8 playCountMedium,
            uint8 maxPlayCountHigh,
            uint8 maxPlayCountMedium,
            uint32 playingHigh,
            uint32 playingMedium
        )
    {

        assembly {
            register := _bytecode
            mstore(0x20, _bytecode)
            trophyHigh := or(mload(0x1f), 0)
            trophyMedium := or(mload(0x1e), 0)
            playCountHigh := or(mload(0x1d), 0)
            playCountMedium := or(mload(0x1c), 0)
            maxPlayCountHigh := or(mload(0x1b), 0)
            maxPlayCountMedium := or(mload(0x1a), 0)
            playingHigh := or(mload(0x19), 0)
            playingMedium := or(mload(0x15), 0)
        }
    }

    function incrementPlayer() internal returns (uint256 count) {

        count = playerCount;
        playerCount++;
    }

    function getPlayerRegisetr(address _addr) internal view returns (bool) {

        (uint8 register, , , , , , , , ) = PlayerDeserializing(players[_addr]);
        return register == 1;
    }

    function getPlayerTrophy(address _addr, TablePrice _price) internal view returns (uint256) {

        (, uint8 trophyHigh, uint8 trophyMedium, , , , , , ) = PlayerDeserializing(players[_addr]);
        return _price == TablePrice.High ? uint256(trophyHigh) : uint256(trophyMedium);
    }

    function setPlayerTrophy(
        address _addr,
        uint256 _amount,
        TablePrice _price
    ) internal {

        assert(_amount <= 2); //maximum 2
        (
            uint8 register,
            uint8 trophyHigh,
            uint8 trophyMedium,
            uint8 playCountHigh,
            uint8 playCountMedium,
            uint8 maxPlayCountHigh,
            uint8 maxPlayCountMedium,
            uint32 playingHigh,
            uint32 playingMedium
        ) = PlayerDeserializing(players[_addr]);

        uint8 amt = _amount.toUint8();
        _price == TablePrice.High ? trophyHigh = amt : trophyMedium = amt;

        players[_addr] = PlayerSerializing(
            register,
            trophyHigh,
            trophyMedium,
            playCountHigh,
            playCountMedium,
            maxPlayCountHigh,
            maxPlayCountMedium,
            playingHigh,
            playingMedium
        );
    }

    function getPlayerUpline(address _addr) internal view returns (address) {

        return upline[_addr];
    }

    function getPlayingTable(address _addr, TablePrice _price) internal view returns (uint256 no) {

        (, , , , , , , uint32 playingHigh, uint32 playingMedium) = PlayerDeserializing(
            players[_addr]
        );
        return _price == TablePrice.High ? uint256(playingHigh) : uint256(playingMedium);
    }

    function setPlayingTable(
        address _addr,
        TablePrice _price,
        uint256 _no
    ) internal {

        (
            uint8 register,
            uint8 trophyHigh,
            uint8 trophyMedium,
            uint8 playCountHigh,
            uint8 playCountMedium,
            uint8 maxPlayCountHigh,
            uint8 maxPlayCountMedium,
            uint32 playingHigh,
            uint32 playingMedium
        ) = PlayerDeserializing(players[_addr]);

        uint32 no = _no.toUint32();

        _price == TablePrice.High ? playingHigh = no : playingMedium = no;

        players[_addr] = PlayerSerializing(
            register,
            trophyHigh,
            trophyMedium,
            playCountHigh,
            playCountMedium,
            maxPlayCountHigh,
            maxPlayCountMedium,
            playingHigh,
            playingMedium
        );
    }

    

    function TableSerializing(
        uint8 _isOpen,
        uint8 _tableType,
        uint8 _price,
        uint32 _index
    ) internal pure returns (bytes32 bytecode) {

        assembly {
            mstore(0x20, _isOpen)
            mstore(0x1f, _tableType)
            mstore(0x1e, _price)
            mstore(0x1d, _index)

            bytecode := mload(0x20)
        }
    }

    function TableDeserializing(bytes32 _bytecode)
        internal
        pure
        returns (
            uint8 isOpen,
            uint8 tableType,
            uint8 price,
            uint32 index
        )
    {

        assembly {
            isOpen := _bytecode
            mstore(0x20, _bytecode)
            tableType := or(mload(0x1f), 0)
            price := or(mload(0x1e), 0)
            index := or(mload(0x1d), 0)
        }
    }

    function getOpening(TablePrice _price, uint256 _index) internal view returns (uint256 no) {

        uint256 price = uint256(_price);
        no = opening[price][_index];
        return no;
    }

    function pushOpening(TablePrice _price, uint256 _no) internal returns (uint256 index) {

        uint256 price = uint256(_price);
        opening[price].push(_no);
        index = index > 0 ? index - 1 : 0;
        return index;
    }

    function deleteOpening(
        TablePrice _price,
        uint256 _index,
        uint256 _no
    ) internal returns (bool) {

        uint256 price = uint256(_price);
        uint256 no = opening[price][_index];
        if (no == _no) {
            delete (opening[price][_index]);
            return true;
        }

        uint256[] storage open = opening[price];
        for (uint256 i = 0; i < open.length; i++) {
            if (open[i] == _no) {
                delete (open[i]);
                return true;
            }
            if (i == 20) {
                break;
            }
        }
        return false;
    }

    function incrementTable() internal returns (uint256 count) {

        count = tableCount;
        tableCount++;
    }

    function getTableIsOpen(uint256 _no) internal view returns (bool) {

        (uint8 isOpen, , , ) = TableDeserializing(tables[_no]);
        return isOpen == 1;
    }

    function setTableIsOpen(uint256 _no, bool _isOpen) internal {

        (uint8 isOpen, uint8 tableType, uint8 price, uint32 index) = TableDeserializing(
            tables[_no]
        );
        isOpen = _isOpen ? 1 : 0;
        tables[_no] = TableSerializing(isOpen, tableType, price, index);
    }

    function getTablePrice(uint256 _no) internal view returns (TablePrice) {

        (, , uint8 price, ) = TableDeserializing(tables[_no]);
        return TablePrice(price);
    }

    function getTableIndex(uint256 _no) internal view returns (uint256) {

        (, , , uint32 index) = TableDeserializing(tables[_no]);
        return uint256(index);
    }

    function setTableIndex(uint256 _no, uint256 _index) internal {

        (uint8 isOpen, uint8 tableType, uint8 price, uint32 index) = TableDeserializing(
            tables[_no]
        );
        index = _index.toUint32();
        tables[_no] = TableSerializing(isOpen, tableType, price, index);
    }

    function getTableSeats(uint256 _no) internal view returns (address[] storage) {

        return seats[_no];
    }

    function pushTableSeats(uint256 _no, address _addr) internal {

        assert(seats[_no].length < 7);
        seats[_no].push(_addr);
    }

    function deleteTableSeats(uint256 _no, address _addr) internal {

        address[] storage tbSeats = seats[_no];
        bool exist = false;
        uint256 inx = 0;

        for (uint256 i = 0; i < tbSeats.length; i++) {
            if (i > 7) {
                break;
            }
            if (tbSeats[i] != _addr) {
                tbSeats[inx] = tbSeats[i];
                inx++;
            } else {
                exist = true;
            }
        }

        if (exist) {
            tbSeats.pop();
        }
    }
}//Unlicense
pragma solidity ^0.8.4;



contract Usecase is Repository {

    using SafeCastUpgradeable for uint256;

    function initialize() public virtual override {

        Repository.initialize();
    }

    function _createPlayer(address _player, address _upline) internal {

        uint8 register = 1;
        uint8 trophyHigh;
        uint8 trophyMedium;
        uint8 playCountHigh;
        uint8 playCountMedium;
        uint32 playingHigh;
        uint32 playingMedium;

        players[_player] = PlayerSerializing(
            register,
            trophyHigh,
            trophyMedium,
            playCountHigh,
            playCountMedium,
            playCountHigh,
            playCountMedium,
            playingHigh,
            playingMedium
        );
        upline[_player] = _upline;

        incrementPlayer();

        downlines[_upline].push(_player);
    }

    function _createTable(TablePrice _price, TableType _type) internal returns (uint256 tableNo) {

        tableNo = incrementTable();
        uint256 inx = pushOpening(_price, tableNo);
        tables[tableNo] = TableSerializing(uint8(1), uint8(_type), uint8(_price), uint16(inx));
        return tableNo;
    }

    function _joinTable(
        uint256 _tableNo,
        address _player,
        TablePrice _price
    ) internal virtual {

        assert(seats[_tableNo].length < 7);

        uint256 pno = getPlayingTable(_player, _price);
        assert(pno == 0);

        setPlayingTable(_player, _price, _tableNo);
        pushTableSeats(_tableNo, _player);
    }

    function _getPlayerInfo(address _player) internal view returns (PlayerInfo memory) {

        (uint8 register, , , , , , , , ) = PlayerDeserializing(players[_player]);

        PlayingTable[] memory playingTable = _getPlayingTable(_player);

        bool playing = _isPlaying(_player);

        address[] memory downlines = downlines[_player];
        address upline = getPlayerUpline(_player);
        return
            PlayerInfo({
                account: _player,
                register: register == 1,
                playing: playing,
                upline: upline,
                downlines: downlines,
                playingTable: playingTable
            });
    }

    function _getPlayingTable(address _player) private view returns (PlayingTable[] memory) {

        (
            ,
            uint8 trophyHigh,
            uint8 trophyMedium,
            uint8 playCountHigh,
            uint8 playCountMedium,
            uint8 maxPlayCountHigh,
            uint8 maxPlayCountMedium,
            uint32 playingHigh,
            uint32 playingMedium
        ) = PlayerDeserializing(players[_player]);

        PlayingTable[] memory playingTable = new PlayingTable[](2);

        playingTable[0].price = TablePrice.High;
        playingTable[0].no = playingHigh;
        playingTable[0].trophy = trophyHigh;
        playingTable[0].playCount = playCountHigh;
        playingTable[0].maxCount = maxPlayCountHigh;

        playingTable[1].price = TablePrice.Medium;
        playingTable[1].no = playingMedium;
        playingTable[1].trophy = trophyMedium;
        playingTable[1].playCount = playCountMedium;
        playingTable[1].maxCount = maxPlayCountMedium;

        return playingTable;
    }

    function _setAutoplayCount(
        address _player,
        TablePrice _price,
        uint256 _count,
        uint256 _maxCount
    ) internal {

        (
            uint8 register,
            uint8 trophyHigh,
            uint8 trophyMedium,
            uint8 playCountHigh,
            uint8 playCountMedium,
            uint8 maxPlayCountHigh,
            uint8 maxPlayCountMedium,
            uint32 playingHigh,
            uint32 playingMedium
        ) = PlayerDeserializing(players[_player]);

        if (_price == TablePrice.High) {
            playCountHigh = _count.toUint8();
            maxPlayCountHigh = _maxCount.toUint8();
        } else {
            playCountMedium = _count.toUint8();
            maxPlayCountMedium = _maxCount.toUint8();
        }

        players[_player] = PlayerSerializing(
            register,
            trophyHigh,
            trophyMedium,
            playCountHigh,
            playCountMedium,
            maxPlayCountHigh,
            maxPlayCountMedium,
            playingHigh,
            playingMedium
        );
    }

    function _isPlaying(address _player) internal view returns (bool) {

        (, , , , , , , uint32 playingHigh, uint32 playingMedium) = PlayerDeserializing(
            players[_player]
        );
        return playingHigh != 0 || playingMedium != 0;
    }

    function _getTableInfo(uint256 _tableNo) internal view returns (TableInfo memory info) {

        (uint8 isOpen, uint8 tableType, uint8 price, ) = TableDeserializing(tables[_tableNo]);
        address[] memory seats = getTableSeats(_tableNo);

        info = TableInfo({
            isOpen: isOpen == 1,
            tableType: TableType(tableType),
            price: _transfromPriceAmount(TablePrice(price)),
            seats: seats,
            tableNo: _tableNo.toUint16(),
            priceType: TablePrice(price)
        });
    }

    function _closeTable(uint256 _tableNo) internal {

        (uint8 isOpen, uint8 tableType, uint8 price, uint32 index) = TableDeserializing(
            tables[_tableNo]
        );

        isOpen = 0;
        index = 0;
        deleteOpening(TablePrice(price), uint256(index), _tableNo);
        tables[_tableNo] = TableSerializing(isOpen, tableType, price, index);
    }

    function _changeTable(address[3] memory _players, TablePrice _price)
        internal
        returns (uint256 tableNo)
    {

        uint256 no = _createTable(_price, TableType.Split);
        seats[no] = _players;

        setPlayingTable(_players[0], _price, no);
        setPlayingTable(_players[1], _price, no);
        setPlayingTable(_players[2], _price, no);

        return no;
    }

    function _getUplineGameTable(
        address _firstAddr,
        address _finalAddr,
        TablePrice _price
    ) internal view returns (uint256 tableNo) {

        address nextUplineAddr = _firstAddr;
        tableNo = 0;
        uint256 pno;

        for (uint256 i = 0; i < 5; i++) {
            pno = getPlayingTable(nextUplineAddr, _price);
            if (pno == 0) {
                if (nextUplineAddr == _finalAddr) {
                    return 0;
                }
                nextUplineAddr = getPlayerUpline(nextUplineAddr);
                continue;
            }

            if (!getTableIsOpen(pno)) {
                continue;
            }

            tableNo = pno;
            break;
        }
        if (tableNo == 0) {
            tableNo = _getOpeningTable(_price);
        }
    }

    function _getOpeningTable(TablePrice _price) private view returns (uint256) {

        address[] storage seats;
        uint256[] storage open = opening[uint256(_price)];
        for (uint256 i = 0; i < open.length; i++) {
            if (i == 10) {
                break;
            }

            seats = getTableSeats(open[i]);
            if (seats.length < 7) {
                return open[i];
            }
        }

        return 0;
    }

    function _calcRanking(address[] memory _seats, TablePrice _price)
        internal
        view
        returns (address[] memory sorted)
    {

        uint256[] memory inx = new uint256[](7);
        sorted = new address[](_seats.length);
        uint256 cnt = 0;

        for (uint256 i = 0; i < _seats.length; i++) {
            if (getPlayerTrophy(_seats[i], _price) == 2) {
                inx[cnt] = i;
                cnt++;
            }
        }

        for (uint256 i = 0; i < _seats.length; i++) {
            if (getPlayerTrophy(_seats[i], _price) == 1) {
                inx[cnt] = i;
                cnt++;
            }
        }

        for (uint256 i = 0; i < _seats.length; i++) {
            if (getPlayerTrophy(_seats[i], _price) == 0) {
                inx[cnt] = i;
                cnt++;
            }
        }

        for (uint256 i = 0; i < inx.length; i++) {
            sorted[i] = _seats[inx[i]];
        }

        return sorted;
    }

    function _assignIntroducerTrophy(address _player, TablePrice _price)
        internal
        returns (address taker, address giver)
    {

        address upline = getPlayerUpline(_player);
        if (_isCanGainTrophy(upline, _price)) {
            _giveTrophy(upline, _price);
            return (upline, _player);
        }

        address[] storage downlines = downlines[upline];
        for (uint256 i = 0; i < downlines.length; i++) {
            if (i > 19) {
                break;
            }

            if (_isCanGainTrophy(downlines[i], _price)) {
                _giveTrophy(downlines[i], _price);
                return (downlines[i], upline);
            }
        }

        return (address(0), address(0));
    }

    function _assignReplayTrophy(address _player, TablePrice _price)
        internal
        returns (address taker, address giver)
    {

        taker = getPlayerUpline(_player);
        giver = _player;

        for (uint256 i = 0; i < 2; i++) {
            if (_isCanGainTrophy(taker, _price)) {
                _giveTrophy(taker, _price);
                return (taker, giver);
            }

            giver = taker;
            taker = getPlayerUpline(giver);
        }

        return (address(0), address(0));
    }

    function _transfromPriceType(uint256 _amount) internal pure returns (TablePrice price) {

        assert(_amount == 0.5 ether || _amount == 0.1 ether);

        return _amount == 0.5 ether ? TablePrice.High : TablePrice.Medium;
    }

    function _transfromPriceAmount(TablePrice _price) internal pure returns (uint256 amount) {

        return _price == TablePrice.High ? 0.5 ether : 0.1 ether;
    }

    function _setWinner(address _player, TablePrice _price)
        internal
        returns (bool autoplay, address introducer)
    {

        (
            uint8 register,
            uint8 trophyHigh,
            uint8 trophyMedium,
            uint8 playCountHigh,
            uint8 playCountMedium,
            uint8 maxPlayCountHigh,
            uint8 maxPlayCountMedium,
            uint32 playingHigh,
            uint32 playingMedium
        ) = PlayerDeserializing(players[_player]);

        if (_price == TablePrice.High) {
            playingHigh = 0;
            trophyHigh = 0;
            autoplay = playCountHigh < maxPlayCountHigh ? true : false;
            playCountHigh = playCountHigh < maxPlayCountHigh ? playCountHigh++ : maxPlayCountHigh;
        } else {
            playingMedium = 0;
            trophyMedium = 0;
            autoplay = playCountMedium < maxPlayCountMedium ? true : false;
            playCountMedium = playCountMedium < maxPlayCountMedium
                ? playCountMedium++
                : maxPlayCountMedium;
        }

        players[_player] = PlayerSerializing(
            register,
            trophyHigh,
            trophyMedium,
            playCountHigh,
            playCountMedium,
            maxPlayCountHigh,
            maxPlayCountMedium,
            playingHigh,
            playingMedium
        );

        return (autoplay, upline[_player]);
    }

    function _isCanGainTrophy(address _player, TablePrice _price) private view returns (bool) {

        (
            ,
            uint8 trophyHigh,
            uint8 trophyMedium,
            ,
            ,
            ,
            ,
            uint32 playingHigh,
            uint32 playingMedium
        ) = PlayerDeserializing(players[_player]);
        return
            _price == TablePrice.High
                ? playingHigh > 0 && trophyHigh < 2
                : playingMedium > 0 && trophyMedium < 2;
    }

    function _giveTrophy(address _player, TablePrice _price) private {

        uint256 trophy = getPlayerTrophy(_player, _price);
        assert(trophy < 2);
        trophy += 1;
        setPlayerTrophy(_player, trophy, _price);
    }

    function _quitTable(uint256 _tableNo, address _player) internal returns (uint256 returnPrice) {

        assert(getTableIsOpen(_tableNo) == true);
        (
            uint8 register,
            uint8 trophyHigh,
            uint8 trophyMedium,
            uint8 playCountHigh,
            uint8 playCountMedium,
            uint8 maxPlayCountHigh,
            uint8 maxPlayCountMedium,
            uint32 playingHigh,
            uint32 playingMedium
        ) = PlayerDeserializing(players[_player]);

        TablePrice priceType = getTablePrice(_tableNo);

        if (priceType == TablePrice.High) {
            playingHigh = 0;
            trophyHigh = 0;
            playCountHigh = 0;
        } else {
            playingMedium = 0;
            trophyMedium = 0;
            playCountMedium = 0;
        }

        setTableIsOpen(_tableNo, false);

        deleteTableSeats(_tableNo, _player);

        setTableIsOpen(_tableNo, true);

        players[_player] = PlayerSerializing(
            register,
            trophyHigh,
            trophyMedium,
            playCountHigh,
            playCountMedium,
            maxPlayCountHigh,
            maxPlayCountMedium,
            playingHigh,
            playingMedium
        );

        uint256 price = _transfromPriceAmount(priceType);
        returnPrice = price - ((price / 2) + (price / 10));
    }
}//Unlicense
pragma solidity ^0.8.4;



contract Pyramid is Usecase, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using AddressUpgradeable for address;
    using SafeCastUpgradeable for uint256;

    enum Environment {
        Maintaince,
        Opening
    }

    Environment private env;

    enum TableEventState {
        Create,
        PlayerJoin,
        FinishGame
    }

    enum PlayerEventState {
        Create,
        JoinTable,
        ChaingTable,
        LeaveTable,
        QuitGame
    }

    enum GainReasonType {
        Introducer,
        Replay,
        Winner
    }

    enum WithdrawType {
        Bonus,
        Income
    }

    uint256 internal income;

    struct Withdraw {
        uint256 limitBlockNumber; //after block number could be withdraw
        uint256 amount;
    }

    mapping(address => Withdraw) public pendingWithdrawals;

    event LogReceived(address indexed addr, uint256 amount);

    event LogTable(uint32 indexed tableNo, TableEventState indexed state, address indexed player);

    event LogPlayer(
        address indexed player,
        address indexed upline,
        PlayerEventState indexed state,
        uint32 tableNo
    );

    event LogGainTrophy(
        address indexed taker,
        address indexed giver,
        GainReasonType indexed reason
    );

    event LogGainBonus(
        address indexed player,
        GainReasonType indexed reason,
        uint256 indexed amount,
        uint32 table,
        address downline,
        TablePrice price
    );

    event LogWithdraw(address indexed player, WithdrawType indexed withdrawType, uint256 amount);

    event LogFinishGame(
        uint32 indexed tableNo,
        address indexed winner,
        address second,
        address third
    );

    event LogIncome(address indexed player, uint256 amount);

    error RequestError(uint256 code, bytes32 message);

    function __matchPrice(uint256 _amount) internal pure {

        if (_amount != 0.1 ether && _amount != 0.5 ether)
            revert RequestError(500, "Unmatch price.");
    }

    function __onlyAccount(address _addr) internal view {

        if (_addr.isContract()) revert RequestError(502, "Only account can call this");
    }

    function __onlyMaintaince() internal view {

        if (env != Environment.Maintaince)
            revert RequestError(503, "Only can call when maintenance");
    }

    function __blockingMaintaince() internal view {

        if (env == Environment.Maintaince) revert RequestError(504, "System maintenance");
    }


    function initialize() public virtual override initializer {

        Usecase.initialize();
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    }

    function startGame() external onlyOwner returns (bool) {

        __onlyMaintaince();

        address owner = owner();
        if (getPlayerRegisetr(owner)) {
            return false;
        }

        newPlayer(msg.sender, msg.sender);
        uint256 no;
        no = newTable(TablePrice.High, TableType.Original);
        joinTable(no, msg.sender, TablePrice.High);

        no = newTable(TablePrice.Medium, TableType.Original);
        joinTable(no, msg.sender, TablePrice.Medium);

        env = Environment.Opening;

        return true;
    }

    receive() external payable {
        emit LogReceived(msg.sender, msg.value);
    }

    fallback() external {}

    function withdrawIncome() external onlyOwner nonReentrant {

        if (income <= 0) revert RequestError(401, "Income not enough");
        uint256 thisAmount = income;
        income = 0;
        payable(owner()).transfer(income);
        emit LogWithdraw(owner(), WithdrawType.Income, thisAmount);
    }

    function withdrawBonus() external nonReentrant {

        __blockingMaintaince();
        __onlyAccount(msg.sender);

        if (pendingWithdrawals[msg.sender].limitBlockNumber > block.number)
            revert RequestError(403, "Not yet up to limit block");

        uint256 amount = pendingWithdrawals[msg.sender].amount;
        if (amount <= 0) revert RequestError(402, "Bonus not enough");
        pendingWithdrawals[msg.sender].amount = 0;

        payable(msg.sender).transfer(amount);
        emit LogWithdraw(msg.sender, WithdrawType.Bonus, amount);
    }

    function play(address _introducer, bool _autoplay) external payable nonReentrant {

        __blockingMaintaince();
        __onlyAccount(msg.sender);
        __matchPrice(msg.value);

        if (getPlayerRegisetr(msg.sender)) revert RequestError(111, "Account already exist");
        if (!getPlayerRegisetr(_introducer)) revert RequestError(121, "Unfound introducer");

        TablePrice price = _transfromPriceType(msg.value);

        newPlayer(msg.sender, _introducer);

        assignTable(msg.sender, _introducer, price);

        uint256 maxPlayCount = _autoplay ? 10 : 1;
        _setAutoplayCount(msg.sender, price, uint256(1), maxPlayCount);

        giveIntBonus(msg.sender, _introducer, price);

        giverIntTrophy(msg.sender, price);

        emit LogReceived(msg.sender, msg.value);
    }

    function replay(bool _autoplay) public payable nonReentrant {

        __blockingMaintaince();
        __onlyAccount(msg.sender);
        __matchPrice(msg.value);

        (
            uint8 register,
            ,
            ,
            ,
            ,
            ,
            ,
            uint32 playingHigh,
            uint32 playingMedium
        ) = PlayerDeserializing(players[msg.sender]);

        bool reg = register == 1;
        if (!reg) revert RequestError(110, "Unfound account");

        uint256 pno = msg.value == 0.5 ether ? uint256(playingHigh) : uint256(playingMedium);
        if (pno > 0) revert RequestError(113, "Account playing");

        address upline = upline[msg.sender];

        if (upline == address(0)) {
            upline = owner();
        }

        TablePrice price = _transfromPriceType(msg.value);
        uint256 maxPlayCount = _autoplay ? 10 : 1;
        _setAutoplayCount(msg.sender, price, uint256(1), maxPlayCount);

        assignTable(msg.sender, upline, price);
        giveIntBonus(msg.sender, upline, price);
        giveReplayTrophy(msg.sender, price);

        emit LogReceived(msg.sender, msg.value);
    }


    function getIncome() external view onlyOwner returns (uint256) {

        return income;
    }

    function setEnv(uint256 _env) external onlyOwner {

        if (_env < 0 || _env > 1) revert RequestError(501, "Unknown environment");
        env = Environment(_env);
    }

    function getEnv() external view onlyOwner returns (Environment) {

        return env;
    }

    function fetchPlayer(address _addr) external view returns (PlayerInfo memory) {

        return _getPlayerInfo(_addr);
    }

    function fetchTable(uint256 _no) external view returns (TableInfo memory) {

        return _getTableInfo(_no);
    }


    function newTable(TablePrice _price, TableType _type) private returns (uint256 tableNo) {

        tableNo = _createTable(_price, _type);
        emit LogTable(tableNo.toUint32(), TableEventState.Create, address(0));

        return tableNo;
    }

    function joinTable(
        uint256 _tableNo,
        address _player,
        TablePrice _price
    ) private {

        _joinTable(_tableNo, _player, _price);
        EmitLogPlayer(_player, PlayerEventState.JoinTable, _tableNo);
        emit LogTable(_tableNo.toUint32(), TableEventState.PlayerJoin, _player);
    }

    function assignTable(
        address _player,
        address _upline,
        TablePrice _price
    ) private returns (uint256 tableNo) {

        tableNo = _getUplineGameTable(_upline, owner(), _price);

        if (tableNo != 0 && getTableSeats(tableNo).length < 7) {
            joinTable(tableNo, _player, _price);

            finishGame(tableNo, _price);
            return tableNo;
        }

        tableNo = newTable(_price, TableType.Split);
        joinTable(tableNo, _player, _price);
        return tableNo;
    }

    function finishGame(uint256 _tableNo, TablePrice _price) private returns (bool) {

        address[] storage seats = getTableSeats(_tableNo);
        if (seats.length < 7) {
            return false;
        }

        address[] memory rank = _calcRanking(seats, _price);

        emit LogFinishGame(_tableNo.toUint32(), rank[0], rank[1], rank[2]);

        _closeTable(_tableNo);
        emit LogTable(_tableNo.toUint32(), TableEventState.FinishGame, address(0));

        winnerHandler(rank[0], _tableNo, _price);

        splitTable(rank, _price);

        return true;
    }

    function winnerHandler(
        address _winner,
        uint256 _tableNo,
        TablePrice _price
    ) private {

        (bool autoplay, address upline) = _setWinner(_winner, _price);
        EmitLogPlayer(_winner, PlayerEventState.LeaveTable, _tableNo);
        giveWinnerBonus(_winner, _tableNo, _price, autoplay);

        if (autoplay) {
            assignTable(_winner, upline, _price);
            giveIntBonus(_winner, upline, _price);
            giveReplayTrophy(_winner, _price);
        }
    }

    function splitTable(address[] memory _players, TablePrice _price) private {

        address[3] memory atb = [_players[1], _players[3], _players[4]];
        address[3] memory btb = [_players[2], _players[5], _players[6]];
        uint256 ano = _changeTable(atb, _price);
        uint256 bno = _changeTable(btb, _price);

        emit LogTable(ano.toUint32(), TableEventState.Create, address(0));
        emit LogTable(bno.toUint32(), TableEventState.Create, address(0));

        EmitLogPlayer(_players[1], PlayerEventState.ChaingTable, ano);
        EmitLogPlayer(_players[3], PlayerEventState.ChaingTable, ano);
        EmitLogPlayer(_players[4], PlayerEventState.ChaingTable, ano);

        EmitLogPlayer(_players[2], PlayerEventState.ChaingTable, bno);
        EmitLogPlayer(_players[5], PlayerEventState.ChaingTable, bno);
        EmitLogPlayer(_players[6], PlayerEventState.ChaingTable, bno);
    }

    function newPlayer(address _player, address _upline) private {

        _createPlayer(_player, _upline);
        EmitLogPlayer(_player, PlayerEventState.Create, 0);
    }

    function giveIntBonus(
        address _downline,
        address _upline,
        TablePrice _price
    ) private returns (bool) {

        uint256 amt = _transfromPriceAmount(_price) / 2;
        pendingWithdrawals[_upline].amount += amt;
        pendingWithdrawals[_upline].limitBlockNumber = block.number + 12;

        emit LogGainBonus(_upline, GainReasonType.Introducer, amt, 0, _downline, _price);

        return true;
    }

    function giveWinnerBonus(
        address _winner,
        uint256 _tableNo,
        TablePrice _price,
        bool _autoplay
    ) private returns (bool) {

        uint256 priceWei = _transfromPriceAmount(_price);
        uint256 handlingFee = (priceWei / 10); //10% for handling fee
        uint256 amt;

        if (_autoplay) {
            amt = priceWei - handlingFee;
        } else {
            amt = (priceWei * 2) - handlingFee;
        }

        income += handlingFee;

        pendingWithdrawals[_winner].amount += amt;
        pendingWithdrawals[_winner].limitBlockNumber = block.number + 12; //can be withdrawls after 12 block

        emit LogGainBonus(
            _winner,
            GainReasonType.Winner,
            amt,
            _tableNo.toUint32(),
            address(0),
            _price
        );

        emit LogIncome(_winner, handlingFee);

        return true;
    }

    function giverIntTrophy(address _player, TablePrice _price) private returns (bool) {

        (address taker, address giver) = _assignIntroducerTrophy(_player, _price);

        if (taker == address(0) || giver == address(0)) {
            return false;
        }

        emit LogGainTrophy(taker, giver, GainReasonType.Introducer);

        return true;
    }

    function giveReplayTrophy(address _player, TablePrice _price) private returns (bool) {

        (address taker, address giver) = _assignReplayTrophy(_player, _price);

        if (taker == address(0) || giver == address(0)) {
            return false;
        }

        emit LogGainTrophy(taker, giver, GainReasonType.Replay);

        return true;
    }

    function EmitLogPlayer(
        address _player,
        PlayerEventState _state,
        uint256 _tableNo
    ) private {

        address uplien = getPlayerUpline(_player);

        emit LogPlayer(_player, uplien, _state, _tableNo.toUint32());
    }

    function quit(uint256 _tableNo) external {

        uint256 returnPrice = _quitTable(_tableNo, msg.sender);
        pendingWithdrawals[msg.sender].amount += returnPrice;
        pendingWithdrawals[msg.sender].limitBlockNumber = block.number + 12;

        EmitLogPlayer(msg.sender, PlayerEventState.QuitGame, _tableNo);
    }
}