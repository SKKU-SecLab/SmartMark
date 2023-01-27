

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

contract EthStonks {

    using SafeMath for uint;

    modifier onlyAdmin() {

        require(msg.sender == admin);
        _;
    }

    modifier preMarketOpen() {

        require(block.timestamp < PREMARKET_LENGTH + round[r].seedTime, "premarket closed");
        _;
    }

    modifier preMarketClosed() {

        require(block.timestamp > PREMARKET_LENGTH + round[r].seedTime, "premarket open");
        _;
    }

    modifier checkDeposit(uint amount) {

        require(amount >= MIN_BUY, "min buy");
        require(token.allowance(msg.sender, address(this)) >= amount, "no allowance");
        require(token.balanceOf(msg.sender) >= amount, "no funds");
        _;
    }

    modifier hasName() {

        require(bytes(addressToName[msg.sender]).length > 0, "no name");
        _;
    }

    modifier validName(string memory name) {

        uint length = nameLength(name);
        require(length <= 12);
        require(length >= 3);
        require(checkCharacters(bytes(name)));
        _;
    }

    modifier updatePlayerIndex() {

        Round storage _round = round[r];
        if (_round.addrToId[msg.sender] == 0) {
            _round.addrToId[msg.sender] = _round.playerIndex;
            _round.idToAddr[_round.playerIndex++] = msg.sender;
        }
        _;
    }

    modifier recordGas() {

        uint gas;

        if (enableGas) {
            gas = gasleft();
        }

        _;

        if (enableGas) {
            _recordGas(gas);
        }
    }

    address private admin;
    address private stonkRevenueService;

    uint constant private PSN = 10000;
    uint constant private PSNH = 5000;
    uint constant private INVEST_RATIO = 86400;
    uint constant private MARKET_RESET = 864000000000;
    uint constant private CB_ONE = 1e16;
    uint constant private CB_TWO = 1e25;
    uint constant private CB_THREE = 1e37;
    uint32 constant private RND_MAX = 72 hours;
    uint32 constant private PREMARKET_LENGTH = 24 hours;
    uint8 constant private FEE = 20;

    uint constant public MIN_BUY = 1e6;
    uint constant public BROKER_REQ = 1000e6;

    uint constant public MIN_NFT_BUY = 100e6;

    struct Round {
        mapping(uint => address) idToAddr;
        mapping(address => uint) addrToId;
        uint seedBalance;
        uint preMarketSpent;
        uint preMarketDivs;
        uint stonkMarket;
        address spender;
        address prod;
        address chadBroker;
        mapping(int8 => address) lastBuys;
        uint bailoutFund;
        uint nextCb;
        uint32 playerIndex;
        uint32 seedTime;
        uint32 end;
        uint16 index;
        int8 lastBuyIndex;
    }

    struct PlayerRound {
        uint preMarketSpent;
        uint lastAction;
        uint companies;
        uint oldRateStonks;
        uint spent;
        uint stonkDivs;
        uint cashbackDivs;
        uint brokerDivs;
        uint brokeredTrades;
        uint bailoutDivs;
        uint chadBrokerDivs;
        uint gasSpent;
    }

    struct Player {
        bool isBroker;
        string lastBroker;
        uint preMarketDivsWithdrawn;
        uint availableDivs;
        mapping(uint => PlayerRound) playerRound;
    }

    struct BailoutEvent {
        string prod;
        string spender;
        string b1;
        string b2;
        string b3;
        string b4;
        string b5;
        uint round;
        uint cb;
        uint amount;
    }

    mapping(address => string) public addressToName;
    mapping(string => address) public nameToAddress;

    mapping(address => Player) internal player;
    mapping(uint => Round) internal round;
    uint public r = 1;

    uint public pmDivBal;       // needs to be separate because it is dynamic for users
    uint public divBal;         // includes bailouts, cashback, broker divs and stonk sales
    uint public devBal;         // dev fee balance 😊

    string private featuredBroker = 'MrF';

    TokenInterface private token;

    EthStonksLibrary private lib;

    AggregatorV3Interface internal priceFeed;

    StonkNFT internal nft;

    bool public enableGas = true;

    event LogPreMarketBuy(string name, string broker, uint value, bool isBroker, bool validBroker);
    event LogBuy(string name, string broker, uint value, bool isBroker, bool validBroker);
    event LogInvest(string name, uint value);
    event LogSell(string name, uint value);
    event LogWithdraw(string name, uint value);
    event LogHistory(uint index, uint fund, uint market, uint timestamp);
    event LogBailouts(BailoutEvent e);

    event NewPlayer(address addr, string name);
    event NewBroker(string name);
    event NewChad(string name, uint divs, uint trades);

    event NewRound(uint endBlock);


    constructor(address _tokenAddress, address _stonkRevenueService, uint32 _open, EthStonksLibrary _lib, address _priceFeed, StonkNFT _nft)
    updatePlayerIndex
    {
        nft = _nft;
        lib = _lib;
        token = TokenInterface(_tokenAddress);
        stonkRevenueService = _stonkRevenueService;
        admin = msg.sender;

        addressToName[admin] = 'MrF';
        nameToAddress['MrF'] = admin;
        round[r].chadBroker = admin;

        round[r].seedTime = _open - PREMARKET_LENGTH;
        round[r].stonkMarket = MARKET_RESET;
        round[r].end = _open + RND_MAX;
        round[r].nextCb = CB_ONE;

        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function setStonkRevenueService(address addr)
    external
    onlyAdmin
    {

        stonkRevenueService = addr;
    }

    function setGasFlag(bool val)
    external
    onlyAdmin
    {

        enableGas = val;
    }

    function seedMarket(uint amount)
    external
    checkDeposit(amount)
    onlyAdmin
    preMarketOpen
    {

        address(lib).delegatecall(abi.encodeWithSignature('seedMarket(uint256)', amount));
    }

    function grantBroker(address addr)
    external
    onlyAdmin
    {

        player[addr].isBroker = true;
        emit NewBroker(addressToName[addr]);
    }

    function claimBroker(uint8 _v, bytes32 _r, bytes32 _s)
    public
    {

        require(!player[msg.sender].isBroker);

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        string memory checkMessage = string(abi.encodePacked("Grant stonkbroker to ", toString(msg.sender), " on chain ", toString(chainId)));
        bytes32 checkHash = keccak256(abi.encodePacked(checkMessage));
        bytes memory message = abi.encodePacked(prefix, checkHash);
        bytes32 prefixedHash = keccak256(message);

        address recoveredAddress = ecrecover(prefixedHash, _v, _r, _s);
        require(recoveredAddress == admin, string(abi.encodePacked("Recovered address was ", recoveredAddress)));

        player[msg.sender].isBroker = true;
        emit NewBroker(addressToName[msg.sender]);
    }

    function featureBroker(string calldata _featuredBroker)
    external
    onlyAdmin
    {

        featuredBroker = _featuredBroker;
    }

    function devWithdraw()
    external
    onlyAdmin
    {

        require(devBal > 0);

        token.approve(stonkRevenueService, devBal);
        devBal = 0;
        StonkRevenueServiceInterface(stonkRevenueService).withdraw(address(token));
    }


    function preMarketBuy(uint _amount, string calldata _broker)
    external
    checkDeposit(_amount)
    preMarketOpen
    hasName
    recordGas
    {

        address(lib).delegatecall(abi.encodeWithSignature('preMarketBuy(uint256,string)', _amount, _broker));

        if (r == 1) {
            if (_amount >= MIN_NFT_BUY) {
                nft.mintPreMarket(msg.sender, round[1].addrToId[msg.sender]);
            }
        }
    }

    function buy(uint _amount, string calldata _broker)
    external
    checkDeposit(_amount)
    preMarketClosed
    hasName
    recordGas
    {

        address(lib).delegatecall(abi.encodeWithSignature('buy(uint256,string)', _amount, _broker));

        if (r == 1) {
            if (_amount >= MIN_NFT_BUY) {
                nft.mint(msg.sender, round[1].addrToId[msg.sender]);
            }
        }
    }

    function invest()
    external
    preMarketClosed
    hasName
    recordGas
    {

        address(lib).delegatecall(abi.encodeWithSignature('invest()'));
    }

    function sell()
    external
    preMarketClosed
    hasName
    recordGas
    {

        address(lib).delegatecall(abi.encodeWithSignature('sell()'));
    }

    function withdrawBonus()
    external
    recordGas
    {

        address(lib).delegatecall(abi.encodeWithSignature('withdrawBonus()'));
    }


    function stonkNames(address addr)
    public view
    returns (string memory _name, string memory _broker, string memory _featuredBroker, string memory _spender, string memory _producer, string memory _chad)
    {

        address spender = round[r].spender;
        address prod = round[r].prod;
        address chad = round[r].chadBroker;
        string memory broker;

        if (player[addr].isBroker) {
            broker = addressToName[addr];
        } else {
            broker = player[addr].lastBroker;
        }

        return (
        addressToName[addr],
        broker,
        featuredBroker,
        addressToName[spender],
        addressToName[prod],
        addressToName[chad]
        );
    }

    function stonkNumbers(address addr, uint buyAmount)
    public
    returns (uint companies, uint stonks, uint receiveBuy, uint receiveSell, uint dividends)
    {

        (, bytes memory result) = address(lib).delegatecall(abi.encodeWithSignature('stonkNumbers(address,uint256)', addr, buyAmount));
        return abi.decode(result, (uint, uint, uint, uint, uint));
    }

    function gameData()
    external
    returns (uint rnd, uint index, uint open, uint end, uint fund, uint market, uint bailout)
    {

        (, bytes memory result) = address(lib).delegatecall(abi.encodeWithSignature('gameData()'));
        return abi.decode(result, (uint, uint, uint, uint, uint, uint, uint));
    }

    function lastBuy(uint rnd, int8 index)
    external view
    returns (address)
    {

        return round[rnd].lastBuys[index];
    }


    function userRoundStats(address addr, uint rnd)
    public view
    returns (uint, uint, uint, uint, uint, uint, uint, uint, uint)
    {

        PlayerRound memory _playerRound = player[addr].playerRound[rnd];
        return
        (
        _playerRound.spent,
        calculatePreMarketDivs(addr, rnd),
        _playerRound.stonkDivs,
        _playerRound.cashbackDivs,
        _playerRound.brokerDivs,
        _playerRound.brokeredTrades,
        _playerRound.bailoutDivs,
        _playerRound.chadBrokerDivs,
        _playerRound.gasSpent
        );
    }

    function calculatePreMarketDivs(address addr, uint rnd)
    public view
    returns (uint)
    {

        if (player[addr].playerRound[rnd].preMarketSpent == 0) {
            return 0;
        }

        uint totalDivs = round[rnd].preMarketDivs;
        uint totalSpent = round[rnd].preMarketSpent;
        uint playerSpent = player[addr].playerRound[rnd].preMarketSpent;
        uint playerDivs = (((playerSpent * 2 ** 64) / totalSpent) * totalDivs) / 2 ** 64;

        return playerDivs;
    }

    function getAddrById(uint rnd, uint ind)
    public view
    returns (address)
    {

        return round[rnd].idToAddr[ind];
    }

    function getIdByAddr(uint rnd, address addr)
    public view
    returns (uint)
    {

        return round[rnd].addrToId[addr];
    }

    function getRoundIndex(uint rnd)
    public view
    returns (uint)
    {

        return round[rnd].index;
    }

    function getPlayerMetric(address addr, uint rnd, uint key)
    public view
    returns (uint)
    {

        if (key == 0) {
            return player[addr].playerRound[rnd].preMarketSpent;
        } else if (key == 1) {
            return player[addr].playerRound[rnd].lastAction;
        } else if (key == 2) {
            return player[addr].playerRound[rnd].companies;
        } else if (key == 3) {
            return player[addr].playerRound[rnd].oldRateStonks;
        } else if (key == 4) {
            return player[addr].playerRound[rnd].spent;
        } else if (key == 5) {
            return player[addr].playerRound[rnd].stonkDivs;
        } else if (key == 6) {
            return player[addr].playerRound[rnd].cashbackDivs;
        } else if (key == 7) {
            return player[addr].playerRound[rnd].brokerDivs;
        } else if (key == 8) {
            return player[addr].playerRound[rnd].brokeredTrades;
        } else if (key == 9) {
            return player[addr].playerRound[rnd].bailoutDivs;
        } else if (key == 10) {
            return player[addr].playerRound[rnd].chadBrokerDivs;
        } else if (key == 11) {
            return player[addr].preMarketDivsWithdrawn;
        } else if (key == 12) {
            return player[addr].availableDivs;
        } else if (key == 13) {
            return player[addr].playerRound[rnd].gasSpent;
        } else if (key == 14) {
            return player[addr].isBroker ? 1 : 0;
        } else {
            return 0;
        }
    }

    function leaderNumbers()
    public
    returns (uint, uint, uint, uint, uint, uint, uint)
    {

        (, bytes memory result) = address(lib).delegatecall(abi.encodeWithSignature('leaderNumbers()'));
        return abi.decode(result, (uint, uint, uint, uint, uint, uint, uint));
    }

    function getRoundMetric(uint rnd, uint key)
    public view
    returns (uint)
    {

        if (key == 0) {
            return round[rnd].playerIndex;
        } else if (key == 1) {
            return round[rnd].index;
        } else if (key == 2) {
            return round[rnd].seedTime;
        } else if (key == 3) {
            return round[rnd].seedBalance;
        } else if (key == 4) {
            return round[rnd].preMarketSpent;
        } else if (key == 5) {
            return round[rnd].preMarketDivs;
        } else if (key == 6) {
            return round[rnd].end;
        } else if (key == 7) {
            return round[rnd].stonkMarket;
        } else if (key == 8) {
            return round[rnd].bailoutFund;
        } else if (key == 9) {
            return round[rnd].nextCb;
        } else {
            return 0;
        }
    }

    function getRoundLastBuyIndex(uint rnd)
    external view
    returns (int8)
    {

        return round[rnd].lastBuyIndex;
    }


    function _recordGas(uint gas)
    internal
    {

        (,int price,,,) = priceFeed.latestRoundData();

        player[msg.sender].playerRound[r].gasSpent += ((gas - gasleft() + 58000) * tx.gasprice) * uint(price) / 1e20;
    }


    function calculatePreMarketOwned(address addr)
    internal view
    returns (uint)
    {

        if (player[addr].playerRound[r].preMarketSpent == 0) {
            return 0;
        }
        uint stonks = calculateTrade(round[r].preMarketSpent, round[r].seedBalance, MARKET_RESET);
        uint stonkFee = (stonks * FEE) / 100;
        stonks -= stonkFee;
        uint totalSpentBig = round[r].preMarketSpent * 100;
        uint userPercent = stonks / (totalSpentBig / player[addr].playerRound[r].preMarketSpent);
        return (userPercent * 100) / INVEST_RATIO;
    }

    function userRoundEarned(address addr, uint rnd)
    internal view
    returns (uint earned)
    {

        PlayerRound memory _playerRound = player[addr].playerRound[rnd];
        earned += calculatePreMarketDivs(addr, rnd);
        earned += _playerRound.stonkDivs;
        earned += _playerRound.cashbackDivs;
        earned += _playerRound.brokerDivs;
        earned += _playerRound.bailoutDivs;
        earned += _playerRound.chadBrokerDivs;
    }

    function marketFund()
    internal view
    returns (uint)
    {

        return token.balanceOf(address(this)) - (round[r].bailoutFund + divBal + pmDivBal + devBal);
    }

    function calculateTrade(uint rt, uint rs, uint bs)
    internal pure
    returns (uint)
    {

        return PSN.mul(bs) / PSNH.add(PSN.mul(rs).add(PSNH.mul(rt)) / rt);
    }

    function calculateSell(uint stonks)
    internal view
    returns (uint)
    {

        uint received = calculateTrade(stonks, round[r].stonkMarket, marketFund());
        uint fee = (received * FEE) / 100;
        return (received - fee);
    }

    function calculateBuy(uint spent)
    internal view
    returns (uint)
    {

        uint stonks = calculateTrade(spent, marketFund(), round[r].stonkMarket);
        uint stonkFee = (stonks * FEE) / 100;
        return (stonks - stonkFee);
    }


    function checkName(string calldata name)
    external view
    returns (bool)
    {

        uint length = nameLength(name);
        if (length < 3 || length > 12) {
            return false;
        }
        if (checkCharacters(bytes(name))) {
            return (nameToAddress[name] == address(0));
        }
        return false;
    }

    function registerName(string calldata name)
    public
    updatePlayerIndex
    validName(name)
    {

        require(nameToAddress[name] == address(0));
        require(bytes(addressToName[msg.sender]).length == 0);

        addressToName[msg.sender] = name;
        nameToAddress[name] = msg.sender;
    }

    function registerNameAndClaim(string calldata name, uint8 _v, bytes32 _r, bytes32 _s)
    external {

        registerName(name);
        claimBroker(_v, _r, _s);
    }

    function checkCharacters(bytes memory name)
    internal pure
    returns (bool)
    {

        for (uint i; i < name.length; i++) {
            bytes1 char = name[i];
            if (
                !(char >= 0x30 && char <= 0x39) && //9-0
            !(char >= 0x41 && char <= 0x5A) && //A-Z
            !(char >= 0x61 && char <= 0x7A)    //a-z
            )
                return false;
        }
        return true;
    }

    function nameLength(string memory _str)
    public pure
    returns (uint length)
    {

        uint i = 0;
        bytes memory string_rep = bytes(_str);

        while (i < string_rep.length)
        {
            if (uint8(string_rep[i] >> 7) == 0)
                i += 1;
            else if (uint8(string_rep[i] >> 5) == 0x6)
                i += 2;
            else if (uint8(string_rep[i] >> 4) == 0xE)
                i += 3;
            else if (uint8(string_rep[i] >> 3) == 0x1E)
                i += 4;
            else
                i += 1;

            length++;
        }
    }

    function toString(address account)
    public pure
    returns (string memory)
    {

        return toString(abi.encodePacked(account));
    }

    function toString(uint256 value)
    public pure
    returns (string memory)
    {

        return toString(abi.encodePacked(value));
    }

    function toString(bytes memory data)
    public pure
    returns (string memory)
    {

        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}

interface StonkRevenueServiceInterface {

    function withdraw(address tokenAddress) external;

}


interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
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


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
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


library EnumerableMap {


    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}


library Strings {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}













contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function baseURI() public view virtual returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}



library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
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
}


contract StonkNFT is ERC165, ERC721 {
    using Strings for uint256;

    mapping(address => bool) hasMintedPreMarket;
    mapping(address => bool) hasMinted;

    address public owner;

    address private stonk;

    constructor()
    ERC721("StonkNFT", "SNFT")
    {
        owner = msg.sender;

        _setBaseURI("https://ethstonks.finance/meta/");
    }

    function setStonk(address _stonk)
    public
    {
        require(msg.sender == owner);
        stonk = _stonk;
    }

    function mintPreMarket(address player, uint playerId)
    public
    {
        require(msg.sender == address(stonk));

        if (hasMintedPreMarket[player]) {
            return;
        }

        hasMintedPreMarket[player] = true;

        uint id = uint256(keccak256(abi.encodePacked("premarket_", playerId)));

        _safeMint(player, id);
        _setTokenURI(id, string(abi.encodePacked("live/premarket/", playerId.toString())));
    }

    function mint(address player, uint playerId)
    public
    {
        require(msg.sender == address(stonk));

        if (hasMinted[player]) {
            return;
        }

        hasMinted[player] = true;

        uint id = uint256(keccak256(abi.encodePacked("main_", playerId)));

        _safeMint(player, id);
        _setTokenURI(id, string(abi.encodePacked("live/main/", playerId.toString())));
    }

    function mintRopstenBeta(address player, uint playerId)
    public
    {
        require(msg.sender == owner);

        uint id = uint256(keccak256(abi.encodePacked("ropsten_", playerId)));

        _safeMint(player, id);
        _setTokenURI(id, string(abi.encodePacked("beta/ropsten/", playerId.toString())));
    }

    function mintRinkebyBeta(address player, uint playerId)
    public
    {
        require(msg.sender == owner);

        uint id = uint256(keccak256(abi.encodePacked("rinkeby_", playerId)));

        _safeMint(player, id);
        _setTokenURI(id, string(abi.encodePacked("beta/rinkeby/", playerId.toString())));
    }
}


interface TokenInterface {
    function name() external returns (string memory);
    function symbol() external returns (string memory);
    function decimals() external returns (uint);

    function totalSupply() external view returns (uint);
    function balanceOf(address who) external view returns (uint);
    function transfer(address to, uint value) external;
    event Transfer(address indexed from, address indexed to, uint value);

    function allowance(address owner, address spender) external view returns (uint);
    function transferFrom(address from, address to, uint value) external;
    function approve(address spender, uint value) external;
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract EthStonksLibrary {
    using SafeMath for uint;

    address private admin;
    address private stonkRevenueService;

    uint constant private PSN = 10000;
    uint constant private PSNH = 5000;
    uint constant private INVEST_RATIO = 86400;
    uint constant private MARKET_RESET = 864000000000;
    uint constant private CB_ONE = 1e16;
    uint constant private CB_TWO = 1e25;
    uint constant private CB_THREE = 1e37;
    uint32 constant private RND_MAX = 72 hours;
    uint32 constant private PREMARKET_LENGTH = 24 hours;
    uint8 constant private FEE = 20;

    uint constant public MIN_BUY = 1e6;
    uint constant public BROKER_REQ = 1000e6;

    uint constant public MIN_NFT_BUY = 100e6;

    struct Round {
        mapping(uint => address) idToAddr;
        mapping(address => uint) addrToId;
        uint seedBalance;
        uint preMarketSpent;
        uint preMarketDivs;
        uint stonkMarket;
        address spender;
        address prod;
        address chadBroker;
        mapping(int8 => address) lastBuys;
        uint bailoutFund;
        uint nextCb;
        uint32 playerIndex;
        uint32 seedTime;
        uint32 end;
        uint16 index;
        int8 lastBuyIndex;
    }

    struct PlayerRound {
        uint preMarketSpent;
        uint lastAction;
        uint companies;
        uint oldRateStonks;
        uint spent;
        uint stonkDivs;
        uint cashbackDivs;
        uint brokerDivs;
        uint brokeredTrades;
        uint bailoutDivs;
        uint chadBrokerDivs;
        uint gasSpent;
    }

    struct Player {
        bool isBroker;
        string lastBroker;
        uint preMarketDivsWithdrawn;
        uint availableDivs;
        mapping(uint => PlayerRound) playerRound;
    }

    struct BailoutEvent {
        string prod;
        string spender;
        string b1;
        string b2;
        string b3;
        string b4;
        string b5;
        uint round;
        uint cb;
        uint amount;
    }

    mapping(address => string) public addressToName;
    mapping(string => address) public nameToAddress;

    mapping(address => Player) internal player;
    mapping(uint => Round) internal round;
    uint public r = 1;

    uint public pmDivBal;       // needs to be separate because it is dynamic for users
    uint public divBal;         // includes bailouts, cashback, broker divs and stonk sales
    uint public devBal;         // dev fee balance 😊

    string private featuredBroker = 'MrF';

    TokenInterface private token;

    AggregatorV3Interface internal priceFeed;

    StonkNFT internal nft;

    bool public enableGas = true;

    event LogPreMarketBuy(string name, string broker, uint value, bool isBroker, bool validBroker);
    event LogBuy(string name, string broker, uint value, bool isBroker, bool validBroker);
    event LogInvest(string name, uint value);
    event LogSell(string name, uint value);
    event LogWithdraw(string name, uint value);
    event LogHistory(uint index, uint fund, uint market, uint timestamp);
    event LogBailouts(BailoutEvent e);

    event NewPlayer(address addr, string name);
    event NewBroker(string name);
    event NewChad(string name, uint divs, uint trades);

    event NewRound(uint endBlock);

    function seedMarket(uint amount)
    external
    {
        token.transferFrom(msg.sender, address(this), amount);
        round[r].seedBalance += amount;
        writeHistory();
    }

    function preMarketBuy(uint _amount, string calldata _broker)
    public
    {
        address addr = msg.sender;
        address brokerAddr = nameToAddress[_broker];
        bool validBroker = false;

        Round storage _round = round[r];
        Player storage _player = player[addr];
        PlayerRound storage _playerRound = player[addr].playerRound[r];

        _round.preMarketSpent += _amount;
        _round.stonkMarket = preStonkMarket(_round.preMarketSpent);

        _playerRound.lastAction = PREMARKET_LENGTH + round[r].seedTime;
        _playerRound.preMarketSpent += _amount;

        _playerRound.spent += _amount;
        if (_playerRound.spent > player[_round.spender].playerRound[r].spent) {
            _round.spender = addr;
            _round.prod = addr;
        }

        if (!_player.isBroker && _playerRound.spent >= BROKER_REQ) {
            _player.isBroker = true;
            emit NewBroker(addressToName[addr]);
        }

        if (_player.isBroker) {// if user is a broker, they get 10% back
            divBal += _amount / 10;
            _player.availableDivs += _amount / 10;
            _playerRound.cashbackDivs += _amount / 10;
        } else if (player[brokerAddr].isBroker && brokerAddr != addr) {// or if valid broker, 5% each
            validBroker = true;
            divBal += _amount / 10;
            _player.lastBroker = _broker;
            _player.availableDivs += _amount / 20;
            _playerRound.cashbackDivs += _amount / 20;
            player[brokerAddr].availableDivs += _amount / 20;
            player[brokerAddr].playerRound[r].brokerDivs += _amount / 20;
            player[brokerAddr].playerRound[r].brokeredTrades++;
        }

        if (validBroker) {
            updateChadBroker(brokerAddr);
        }

        token.transferFrom(addr, address(this), _amount);
        feeSplit((_amount * FEE) / 100);

        updateLastBuyer();
        writeHistory();
        emit LogPreMarketBuy(addressToName[addr], _broker, _amount, _player.isBroker, validBroker);
    }

    function buy(uint _amount, string calldata _broker)
    external
    {
        address addr = msg.sender;
        address brokerAddr = nameToAddress[_broker];
        bool validBroker = false;

        if (block.timestamp > round[r].end) {// market crash
            incrementRound();
            preMarketBuy(_amount, _broker);
            return;
        }

        if (round[r].stonkMarket > round[r].nextCb) {
            bool roundOver = handleCircuitBreaker();
            if (roundOver) {
                preMarketBuy(_amount, _broker);
                return;
            }
        }

        Round storage _round = round[r];
        Player storage _player = player[addr];
        PlayerRound storage _playerRound = player[addr].playerRound[r];

        _playerRound.spent += _amount;
        if (_playerRound.spent > player[_round.spender].playerRound[r].spent) {
            _round.spender = addr;
        }

        if (!_player.isBroker && _playerRound.spent >= BROKER_REQ) {
            _player.isBroker = true;
            emit NewBroker(addressToName[addr]);
        }

        if (_player.isBroker) {// if user is a broker, they get 10% back
            divBal += _amount / 10;
            _player.availableDivs += _amount / 10;
            _playerRound.cashbackDivs += _amount / 10;
        } else if (player[brokerAddr].isBroker && brokerAddr != addr) {// or if valid broker, 5% each
            validBroker = true;
            divBal += _amount / 10;
            _player.lastBroker = _broker;
            _player.availableDivs += _amount / 20;
            _playerRound.cashbackDivs += _amount / 20;
            player[brokerAddr].availableDivs += _amount / 20;
            player[brokerAddr].playerRound[r].brokerDivs += _amount / 20;
            player[brokerAddr].playerRound[r].brokeredTrades++;
        }

        uint companies = _playerRound.companies.add(calculatePreMarketOwned(addr));

        _playerRound.oldRateStonks += companies.mul(block.timestamp - _playerRound.lastAction);
        _playerRound.lastAction = block.timestamp;
        _playerRound.companies += calculateBuy(_amount) / INVEST_RATIO;

        if (_playerRound.companies > getCompanies(_round.prod)) {
            _round.prod = addr;
        }

        _round.stonkMarket += (calculateBuy(_amount) / 10);

        if (validBroker) {
            updateChadBroker(brokerAddr);
        }

        token.transferFrom(addr, address(this), _amount);
        feeSplit((_amount * FEE) / 100);

        incrementTimer(_amount);
        updateLastBuyer();
        writeHistory();
        emit LogBuy(addressToName[addr], _broker, _amount, _player.isBroker, validBroker);
    }

    function sell()
    external
    {
        if (block.timestamp > round[r].end) {// market crash
            incrementRound();
            return;
        }

        if (round[r].stonkMarket > round[r].nextCb) {
            bool roundOver = handleCircuitBreaker();
            if (roundOver) {
                return;
            }
        }

        address addr = msg.sender;
        uint stonks = getStonks(addr);
        require(stonks > 0);
        uint received = calculateTrade(stonks, round[r].stonkMarket, marketFund());
        uint fee = (received * FEE) / 100;
        received -= fee;

        player[addr].playerRound[r].lastAction = block.timestamp;
        player[addr].playerRound[r].oldRateStonks = 0;
        player[addr].playerRound[r].stonkDivs += received;
        player[addr].availableDivs += received;
        divBal += received;

        round[r].stonkMarket += stonks;

        feeSplit(fee);

        writeHistory();
        emit LogSell(addressToName[addr], received);

        withdrawBonus(); // gas is expensive
    }

    function handleCircuitBreaker()
    public
    returns (bool)
    {
        if (round[r].stonkMarket > CB_THREE) {
            payBailouts(3, round[r].bailoutFund);
            incrementRound();
            return true;
        }

        uint pool = round[r].bailoutFund / 3;
        round[r].bailoutFund -= pool;

        if (round[r].stonkMarket > CB_TWO) {
            round[r].nextCb = CB_THREE;
            payBailouts(2, pool);
            return false;
        }

        round[r].nextCb = CB_TWO;
        payBailouts(1, pool);
        return false;
    }

    function incrementRound()
    public
    {
        r++;
        round[r].stonkMarket = MARKET_RESET;
        round[r].seedTime = uint32(block.timestamp);
        round[r].seedBalance = marketFund();
        round[r].end = uint32(block.timestamp) + PREMARKET_LENGTH + RND_MAX;
        round[r].nextCb = CB_ONE;
        round[r].chadBroker = admin;
        
        emit NewRound(block.number);
    }

    function payBailouts(uint cb, uint pool)
    internal
    {
        Round storage _round = round[r];

        address spender = _round.spender;
        address prod = _round.prod;
        address b1 = _round.lastBuys[(5 + _round.lastBuyIndex - 1) % 5];
        address b2 = _round.lastBuys[(5 + _round.lastBuyIndex - 2) % 5];
        address b3 = _round.lastBuys[(5 + _round.lastBuyIndex - 3) % 5];
        address b4 = _round.lastBuys[(5 + _round.lastBuyIndex - 4) % 5];
        address b5 = _round.lastBuys[(5 + _round.lastBuyIndex - 5) % 5];

        divBal += pool;
        uint a = pool / 1000;
        uint sent = a * 100;
        player[prod].availableDivs += sent;
        player[prod].playerRound[r].bailoutDivs += sent;

        uint buyerBailout = a * 40;
        player[b1].availableDivs += buyerBailout;
        player[b2].availableDivs += buyerBailout;
        player[b3].availableDivs += buyerBailout;
        player[b4].availableDivs += buyerBailout;
        player[b5].availableDivs += buyerBailout;
        player[b1].playerRound[r].bailoutDivs += buyerBailout;
        player[b2].playerRound[r].bailoutDivs += buyerBailout;
        player[b3].playerRound[r].bailoutDivs += buyerBailout;
        player[b4].playerRound[r].bailoutDivs += buyerBailout;
        player[b5].playerRound[r].bailoutDivs += buyerBailout;
        sent += buyerBailout * 5;

        player[spender].availableDivs += (pool - sent);
        player[spender].playerRound[r].bailoutDivs += (pool - sent);

        BailoutEvent memory e;
        e.prod = addressToName[prod];
        e.spender = addressToName[spender];
        e.b1 = addressToName[b1];
        e.b2 = addressToName[b2];
        e.b3 = addressToName[b3];
        e.b4 = addressToName[b4];
        e.b5 = addressToName[b5];
        e.round = r;
        e.cb = cb;
        e.amount = pool;

        emit LogBailouts(e);
    }

    function invest()
    external
    {
        if (block.timestamp > round[r].end) {// market crash
            incrementRound();
            return;
        }

        if (round[r].stonkMarket > round[r].nextCb) {
            bool roundOver = handleCircuitBreaker();
            if (roundOver) {
                return;
            }
        }

        address addr = msg.sender;
        uint stonks = getStonks(addr);
        require(stonks > 0, 'No stonks to invest');
        uint value = calculateSell(stonks);

        uint companies = stonks / INVEST_RATIO;
        player[addr].playerRound[r].companies += companies;

        address prod = round[r].prod;
        if (getCompanies(addr) > getCompanies(prod)) {
            round[r].prod = addr;
        }

        player[addr].playerRound[r].lastAction = block.timestamp;
        player[addr].playerRound[r].oldRateStonks = 0;

        writeHistory();
        emit LogInvest(addressToName[addr], value);
    }

    function withdrawBonus()
    public
    {
        address addr = msg.sender;
        uint amount = player[addr].availableDivs;
        divBal = divBal.sub(amount);
        uint divs = totalPreMarketDivs(addr).sub(player[addr].preMarketDivsWithdrawn);
        if (divs > 0) {
            pmDivBal = pmDivBal.sub(divs);
            amount += divs;
            player[addr].preMarketDivsWithdrawn += divs;
        }
        require(amount > 0);
        player[addr].availableDivs = 0;
        token.transfer(addr, amount);
        emit LogWithdraw(addressToName[addr], amount);
    }

    function writeHistory()
    internal
    {
        emit LogHistory(round[r].index++, marketFund(), round[r].stonkMarket, block.timestamp);
    }


    function calculatePreMarketOwned(address addr)
    internal view
    returns (uint)
    {
        if (player[addr].playerRound[r].preMarketSpent == 0) {
            return 0;
        }
        uint stonks = calculateTrade(round[r].preMarketSpent, round[r].seedBalance, MARKET_RESET);
        uint stonkFee = (stonks * FEE) / 100;
        stonks -= stonkFee;
        uint totalSpentBig = round[r].preMarketSpent * 100;
        uint userPercent = stonks / (totalSpentBig / player[addr].playerRound[r].preMarketSpent);
        return (userPercent * 100) / INVEST_RATIO;
    }

    function feeSplit(uint amount)
    internal
    {
        uint a = amount / 20;   // 1%

        Round storage _round = round[r];
        if (block.timestamp < PREMARKET_LENGTH + _round.seedTime) { // pre-market open, don't pay PM divs or chad
            _round.bailoutFund += (amount - (a * 3));               // bailout fund gets 17%
        } else {                                    // pre-market over
            if (_round.nextCb == CB_ONE) {          //  - - - cb1:
                _round.preMarketDivs += (a * 4);                    // 4% for pm divs
                pmDivBal += (a * 4);                                // 8 = pm (4) + devs (3) + chad (1)
                _round.bailoutFund += (amount - (a * 8));           // bailout fund gets 12%
            } else if (_round.nextCb == CB_TWO) {   //  - - - cb2:
                _round.preMarketDivs += (a * 7);                    // 7% for pm divs
                pmDivBal += (a * 7);                                // 11 = pm (7) + devs (3) + chad (1)
                _round.bailoutFund += (amount - (a * 11));          // bailout fund gets 9%
            } else {                                //  - - - cb3:
                _round.preMarketDivs += (a * 15);                   // 15% for pm divs
                pmDivBal += (a * 15);                               // 19 = pm (15) + devs (3) + chad (1)
                _round.bailoutFund += (amount - (a * 19));          // bailout fund gets 1%
            }
            player[_round.chadBroker].playerRound[r].chadBrokerDivs += a;
            player[_round.chadBroker].availableDivs += a;
            divBal += a;
        }
        devBal += a * 3;
    }


    function stonkNumbers(address addr, uint buyAmount)
    public view
    returns (uint companies, uint stonks, uint receiveBuy, uint receiveSell, uint dividends)
    {
        companies = getCompanies(addr);
        if (companies > 0) {
            stonks = getStonks(addr);
            if (stonks > 0) {
                receiveSell = calculateSell(stonks);
            }
        }
        if (buyAmount > 0) {
            receiveBuy = calculateBuy(buyAmount) / INVEST_RATIO;
        }
        dividends = player[addr].availableDivs + totalPreMarketDivs(addr).sub(player[addr].preMarketDivsWithdrawn);
    }

    function updateLastBuyer()
    internal
    {
        round[r].lastBuys[round[r].lastBuyIndex] = msg.sender;
        round[r].lastBuyIndex = (round[r].lastBuyIndex + 1) % 5;
    }

    function updateChadBroker(address addr)
    internal
    {
        PlayerRound memory _brokerRound = player[addr].playerRound[r];
        PlayerRound memory _chadBrokerRound = player[round[r].chadBroker].playerRound[r];
        if (
            (_brokerRound.brokerDivs > _chadBrokerRound.brokerDivs) &&
            (_brokerRound.brokeredTrades > _chadBrokerRound.brokeredTrades)
        ) {
            round[r].chadBroker = addr;
            emit NewChad(addressToName[addr], _brokerRound.brokerDivs, _brokerRound.brokeredTrades);
        }
    }

    function incrementTimer(uint amount)
    internal
    {
        uint incr;
        if (round[r].stonkMarket < CB_ONE) {            // CB1 = $48 per day
            incr = 30 minutes;
        } else if (round[r].stonkMarket < CB_TWO) {     // CB2 = $144 per day
            incr = 10 minutes;
        } else {
            incr = 1 minutes;                           // CB3 = $1440 per day
        }
        uint newTime = round[r].end + uint32((amount / 1e6) * incr);
        if (newTime > block.timestamp + RND_MAX) {
            round[r].end = uint32(block.timestamp) + RND_MAX;
        } else {
            round[r].end = uint32(newTime);
        }
    }

    function leaderNumbers()
    public view
    returns (uint, uint, uint, uint, uint, uint, uint)
    {
        address spender = round[r].spender;
        address prod = round[r].prod;
        address chad = round[r].chadBroker;
        return
        (
        player[spender].playerRound[r].spent,
        userRoundEarned(spender, r),
        getCompanies(prod),
        getStonks(prod),
        player[chad].playerRound[r].brokeredTrades,
        player[chad].playerRound[r].brokerDivs,
        player[chad].playerRound[r].chadBrokerDivs
        );
    }

    function userRoundEarned(address addr, uint rnd)
    internal view
    returns (uint earned)
    {
        PlayerRound memory _playerRound = player[addr].playerRound[rnd];
        earned += calculatePreMarketDivs(addr, rnd);
        earned += _playerRound.stonkDivs;
        earned += _playerRound.cashbackDivs;
        earned += _playerRound.brokerDivs;
        earned += _playerRound.bailoutDivs;
        earned += _playerRound.chadBrokerDivs;
    }


    function getCompanies(address addr)
    internal view
    returns (uint)
    {
        return (player[addr].playerRound[r].companies + calculatePreMarketOwned(addr));
    }

    function marketFund()
    internal view
    returns (uint)
    {
        return token.balanceOf(address(this)) - (round[r].bailoutFund + divBal + pmDivBal + devBal);
    }

    function calculateTrade(uint rt, uint rs, uint bs)
    internal pure
    returns (uint)
    {
        return PSN.mul(bs) / PSNH.add(PSN.mul(rs).add(PSNH.mul(rt)) / rt);
    }

    function calculateSell(uint stonks)
    internal view
    returns (uint)
    {
        uint received = calculateTrade(stonks, round[r].stonkMarket, marketFund());
        uint fee = (received * FEE) / 100;
        return (received - fee);
    }

    function calculateBuy(uint spent)
    internal view
    returns (uint)
    {
        uint stonks = calculateTrade(spent, marketFund(), round[r].stonkMarket);
        uint stonkFee = (stonks * FEE) / 100;
        return (stonks - stonkFee);
    }


    function getStonks(address addr)
    internal view
    returns (uint)
    {
        return player[addr].playerRound[r].oldRateStonks.add(currentRateStonks(addr));
    }

    function currentRateStonks(address addr)
    internal view
    returns (uint)
    {
        if (player[addr].playerRound[r].lastAction > block.timestamp) {// applies during premarket
            return 0;
        }
        uint secondsPassed = block.timestamp - player[addr].playerRound[r].lastAction;
        return secondsPassed.mul(getCompanies(addr));
    }

    function preStonkMarket(uint totalSpent) // determines stonkMarket value after premarket buys
    internal view
    returns (uint)
    {
        uint stonks = calculateTrade(totalSpent, round[r].seedBalance, MARKET_RESET);
        uint stonkFee = (stonks * FEE) / 100;
        return ((stonks - stonkFee) / 10) + MARKET_RESET;
    }

    function calculatePreMarketDivs(address addr, uint rnd)
    public view
    returns (uint)
    {
        if (player[addr].playerRound[rnd].preMarketSpent == 0) {
            return 0;
        }

        uint totalDivs = round[rnd].preMarketDivs;
        uint totalSpent = round[rnd].preMarketSpent;
        uint playerSpent = player[addr].playerRound[rnd].preMarketSpent;
        uint playerDivs = (((playerSpent * 2 ** 64) / totalSpent) * totalDivs) / 2 ** 64;

        return playerDivs;
    }

    function gameData()
    public view
    returns (uint rnd, uint index, uint open, uint end, uint fund, uint market, uint bailout)
    {
        return
        (
        r,
        round[r].index,
        marketOpen(),
        round[r].end,
        marketFund(),
        round[r].stonkMarket,
        round[r].bailoutFund
        );
    }

    function totalPreMarketDivs(address addr)
    internal view
    returns (uint)
    {
        uint divs;
        for (uint rnd = 1; rnd <= r; rnd++) {
            divs += calculatePreMarketDivs(addr, rnd);
        }
        return divs;
    }

    function marketOpen()
    internal view
    returns (uint)
    {
        if (block.timestamp > round[r].seedTime + PREMARKET_LENGTH) {
            return 0;
        }
        return (round[r].seedTime + PREMARKET_LENGTH) - block.timestamp;
    }
}