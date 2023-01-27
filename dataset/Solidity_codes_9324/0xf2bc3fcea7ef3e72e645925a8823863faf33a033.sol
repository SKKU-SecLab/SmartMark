


pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}




pragma solidity >=0.6.0 <0.8.0;


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




pragma solidity >=0.6.0 <0.8.0;


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




pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}




pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity >=0.5.0;

interface IGenMarketFactory {

    event MarketCreated(address indexed caller, address indexed genMarket);

    function feeTo() external view returns (address);

    function feeDivisor() external view returns (uint256);

    function feeToSetter() external view returns (address);


    function getGenMarket(address) external view returns (uint);

    function ticketToMarket(address) external view returns (address);

    function genMarkets(uint) external view returns (address);

    function genMarketsLength() external view returns (uint);


    function createGenMarket(
        address _genTicket,
        uint256[] memory _prices,
        uint256[] memory _numTickets,
        uint256[] memory _purchaseLimits
    ) external returns (address);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setFeeDivisor(uint256) external;

}


pragma solidity 0.6.12;





contract GenMarket is ERC1155Receiver {

    using SafeMath for uint;

    address public genTicket;

    uint256[] public prices;
    uint256[] public numTickets;
    uint256[] public purchaseLimits;
    IGenMarketFactory public factory;
    address public creator;
    bool public active = false;
    mapping(uint256 => mapping(address => bool)) public whitelist;
    mapping(uint256 => mapping(address => uint256)) public purchases;
    mapping(uint256 => uint256) public ticketsPurchased;
    uint public startTime = type(uint).max;

    bytes private constant VALIDATOR = bytes('JC');
    
    constructor (
        address _genTicket,
        uint256[] memory _prices,
        uint256[] memory _numTickets,
        uint256[] memory _purchaseLimits,
        IGenMarketFactory _factory,
        address _creator
    ) 
        public 
    {
        genTicket = _genTicket;
        prices = _prices;
        numTickets = _numTickets;
        purchaseLimits = _purchaseLimits;
        factory = _factory;
        creator = _creator;
    }

    function ticketTypes() external view returns (uint) {

        return numTickets.length;
    }

    function updateStartTime(uint timestamp) external {

        require(msg.sender == creator, "GenMarket: Only creator can update start time");
        require(getBlockTimestamp() < startTime, "GenMarket: Start time already occurred");
        require(getBlockTimestamp() < timestamp, "GenMarket: New start time must be in the future");

        startTime = timestamp;
    }

    function setWhiteList(uint256 id, address[] memory addresses, bool whiteListOn) external {

        require(msg.sender == creator, "GenMarket: Only creator can update whitelist");
        require(addresses.length < 200, "GenMarket: Whitelist less than 200 at a time");

        for (uint8 i=0; i<200; i++) {
            if (i == addresses.length) {
                break;
            }

            whitelist[id][addresses[i]] = whiteListOn;
        }
    }

    function deposit() external {

        require(msg.sender == creator, "GenMarket: Only the creator can deposit the tickets");
        require(!active, "GenMarket: Market is already active");

        uint256[] memory tokenIDs = new uint256[](numTickets.length);
        for (uint8 i = 0; i < numTickets.length; i++)
            tokenIDs[i] = i;

        IERC1155(genTicket).safeBatchTransferFrom(msg.sender, address(this), tokenIDs, numTickets, VALIDATOR);

        active = true;
    }

    function buy(uint256 _id, uint256 _amount) external payable {

        require(active, "GenMarket: Market is not active");
        require(getBlockTimestamp() >= startTime, "GenMarket: Start time must pass");
        require(whitelist[_id][msg.sender], "GenMarket: User not on whitelist");
        require(purchases[_id][msg.sender].add(_amount) <= purchaseLimits[_id], "GenMarket: User will exceed purchase limit");
        require(ticketsPurchased[_id].add(_amount) <= numTickets[_id], "GenMarket: Not enough tickets remaining");
        require(prices[_id].mul(_amount) <= msg.value, "GenMarket: Insufficient payment");

        purchases[_id][msg.sender] = purchases[_id][msg.sender].add(_amount);
        ticketsPurchased[_id] = ticketsPurchased[_id].add(_amount);

        if (factory.feeTo() != address(0)) {
            (bool sent, bytes memory data) = factory.feeTo().call{value: msg.value.div(factory.feeDivisor())}("");
            require(sent, "GenMarket: Failed to send Ether");
        }
        
        bytes memory data;
        IERC1155(genTicket).safeTransferFrom(address(this), msg.sender, _id, _amount, data);
    }

    function claim() external {

        require(msg.sender == creator, "GenMarket: Only the creator can claim");

        (bool sent, bytes memory data) = msg.sender.call{value: address(this).balance}("");
        require(sent, "GenMarket: Failed to send Ether");
    }

    function getBlockTimestamp() internal view returns (uint) {

        return block.timestamp;
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) override external returns(bytes4) {

        if(keccak256(_data) == keccak256(VALIDATOR)){
            return 0xf23a6e61;
        }
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) override external returns(bytes4) {

        if(keccak256(_data) == keccak256(VALIDATOR)){
            return 0xbc197c81;
        }
    }
}


pragma solidity 0.6.12;




contract GenMarketFactory is IGenMarketFactory {

    using SafeMath for uint;
    
    address public override feeTo;
    uint256 public override feeDivisor;
    
    address public override feeToSetter;
    
    address[] public override genMarkets;
    
    mapping(address => uint) public override getGenMarket;
    mapping(address => address) public override ticketToMarket;
    
    event MarketCreated(address indexed caller, address indexed genMarket);
    
    function genMarketsLength() external override view returns (uint) {

        return genMarkets.length;
    }
    
    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function createGenMarket(
        address _genTicket,
        uint256[] memory _prices,
        uint256[] memory _numTickets,
        uint256[] memory _purchaseLimits
    ) external override returns (address) {

        require(_numTickets.length == _prices.length, 'GenMarketFactory: ARRAY SIZE MISMATCH');
        GenMarket gm = new GenMarket(_genTicket, _prices, _numTickets, _purchaseLimits, this, msg.sender);
        getGenMarket[address(gm)] = genMarkets.length;
        ticketToMarket[_genTicket] = address(gm);
        genMarkets.push(address(gm));
        emit MarketCreated(msg.sender, address(gm));
        
        return address(gm);
    }
    
    function setFeeTo(address _feeTo) external override {

        require(msg.sender == feeToSetter, 'GenMarketFactory: FORBIDDEN');
        feeTo = _feeTo;
    }
    
    function setFeeToSetter(address _feeToSetter) external override {

        require(msg.sender == feeToSetter, 'GenMarketFactory: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function setFeeDivisor(uint256 _feeDivisor) external override {

        require(msg.sender == feeToSetter, 'GenMarketFactory: FORBIDDEN');
        require(_feeDivisor > 0, "GenMarketFactory: Fee divisor must not be zero");
        feeDivisor = _feeDivisor;
    }
}