
pragma solidity 0.8.6;






abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



contract CFORole is Context {

    address private _cfo;

    event CFOTransferred(address indexed previousCFO, address indexed newCFO);

    constructor () {
        _transferCFOship(_msgSender());
        emit CFOTransferred(address(0), _msgSender());
    }

    function cfo() public view returns (address) {

        return _cfo;
    }

    modifier onlyCFO() {

        require(isCFO(), "CFOable: caller is not the CFO");
        _;
    }

    function isCFO() public view returns (bool) {

        return _msgSender() == _cfo;
    }

    function renounceCFOship() public onlyCFO {

        emit CFOTransferred(_cfo, address(0));
        _cfo = address(0);
    }

    function transferCFOship(address newCFO) public onlyCFO {

        _transferCFOship(newCFO);
    }

    function _transferCFOship(address newCFO) internal {

        require(newCFO != address(0), "Ownable: new cfo is the zero address");
        emit CFOTransferred(_cfo, newCFO);
        _cfo = newCFO;
    }
}





contract OperatorRole is Context {

    address private _Operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor () {
        _transferOperatorship(_msgSender());
        emit OperatorTransferred(address(0), _msgSender());
    }

    function Operator() public view returns (address) {

        return _Operator;
    }

    modifier onlyOperator() {

        require(isOperator(), "Operatorable: caller is not the Operator");
        _;
    }

    function isOperator() public view returns (bool) {

        return _msgSender() == _Operator;
    }

    function renounceOperatorship() public onlyOperator {

        emit OperatorTransferred(_Operator, address(0));
        _Operator = address(0);
    }

    function transferOperatorship(address newOperator) public onlyOperator {

        _transferOperatorship(newOperator);
    }

    function _transferOperatorship(address newOperator) internal {

        require(newOperator != address(0), "Ownable: new Operator is the zero address");
        emit OperatorTransferred(_Operator, newOperator);
        _Operator = newOperator;
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


contract VerifySignature is Ownable {


    address public  signaturer;

    constructor() {
        signaturer = msg.sender;
    }

    function changeSignaturer(address value) public onlyOwner {

        signaturer = value;
    }

    function getMessageHash(address owner, address contract_addr, address to, uint _nonce) public pure returns (bytes32)
    {

        return keccak256(abi.encodePacked(owner, contract_addr, to, _nonce));
    }

    function getMessageHash2(address owner, address contract_addr, address to, uint256 tokenId, uint256 genes, uint _nonce) public pure returns (bytes32)
    {

        return keccak256(abi.encodePacked(owner, contract_addr, to, tokenId, genes, _nonce));
    }


    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32)
    {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verify(address to, uint _nonce, bytes memory signature) public view returns (bool)
    {

        bytes32 messageHash = getMessageHash(signaturer, address(this), to, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == signaturer;
    }

    function verify2(address to, uint256 tokenId, uint256 genes, uint _nonce, bytes memory signature) public view returns (bool)
    {

        bytes32 messageHash = getMessageHash2(signaturer, address(this), to, tokenId, genes, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == signaturer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address)
    {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v)
    {

        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
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
}



contract Collection is CFORole, OperatorRole, VerifySignature {

    using Address for address payable;
    using SafeMath for uint256;

    struct Event {
        uint256 event_id;
        uint256 price;
        string name;
        string event_type;
        bool start;
        uint256 total_supply;
        uint256 per_limit;
        uint256 supplied;
        mapping(address => uint256) buy_his_count;
        uint256 amount;
    }

    mapping (uint256 => Event) events;
    mapping (uint256 => bool) eventIdMap;
    uint256[] eventIds;

    event OpenEvent(uint256 eventId, uint256 price, string event_type, string name, uint256 total_supply, uint256 per_limit, address setter);
    event ReopenEvent(uint256 eventId, address setter);
    event CloseEvent(uint256 eventId, address setter);
    event Pay(uint256 eventId, uint256 price, uint256 num, string event_type, address payer);
    event ChangeEventProperty(uint256 eventId, string prop, uint256 from, uint256 to);
    event ChangeEventPropertyStr(uint256 eventId, string prop, string from, string to);

    function startEvent(uint256 eventId, uint256 price, string memory event_type, string memory name, uint256 total_supply, uint256 per_limit) public onlyOperator {

        require(!_checkIsEventExist(eventId), 'event already exist');
        require(bytes(name).length > 0, 'event name connot be empty');

        events[eventId].event_id = eventId;
        events[eventId].price = price;
        events[eventId].event_type = event_type;
        events[eventId].name = name;
        events[eventId].total_supply = total_supply;
        events[eventId].per_limit = per_limit;
        events[eventId].start = true;

        eventIdMap[eventId] = true;
        eventIds.push(eventId);
        emit OpenEvent(eventId, price, event_type, name, total_supply, per_limit, _msgSender());
    }

    function restartEvent(uint256 eventId) public onlyOperator {

        require(_checkIsEventExist(eventId), 'event did not exist');
        require(!_checkIsEventDuring(eventId), 'event is during now');
        events[eventId].start = true;
        emit ReopenEvent(eventId, _msgSender());
    }

    function endEvent(uint256 eventId) public onlyOperator {

        require(_checkIsEventExist(eventId), 'event did not exist');
        require(_checkIsEventDuring(eventId), 'event has already closed');
        events[eventId].start = false;
        emit CloseEvent(eventId, _msgSender());
    }

    function setEventPrice(uint256 eventId, uint256 newPrice) public onlyOperator {

        require(_checkIsEventExist(eventId), 'event did not exist');
        require(!_checkIsEventDuring(eventId), 'event is during now');
        uint256 oldPrice = events[eventId].price;
        events[eventId].price = newPrice;
        emit ChangeEventProperty(eventId, 'price', oldPrice, newPrice);
    }

    function setEventType(uint256 eventId, string memory newType) public onlyOperator {

        require(_checkIsEventExist(eventId), 'event did not exist');
        require(!_checkIsEventDuring(eventId), 'event is during now');
        string memory oldType = events[eventId].event_type;
        events[eventId].event_type = newType;
        emit ChangeEventPropertyStr(eventId, 'event_type', oldType, newType);
    }

    function setTotalSupply(uint256 eventId, uint256 newTotalSupply) public onlyOperator {

        require(_checkIsEventExist(eventId), 'event did not exist');
        require(!_checkIsEventDuring(eventId), 'event is during now');
        uint256 oldTotalSupply = events[eventId].total_supply;
        events[eventId].total_supply = newTotalSupply;
        emit ChangeEventProperty(eventId, 'total_supply', oldTotalSupply, newTotalSupply);
    }
    
    function setTotalPerLimit(uint256 eventId, uint256 newPerLimit) public onlyOperator {

        require(_checkIsEventExist(eventId), 'event did not exist');
        require(!_checkIsEventDuring(eventId), 'event is during now');
        uint256 oldPerLimit = events[eventId].per_limit;
        events[eventId].per_limit = newPerLimit;
        emit ChangeEventProperty(eventId, 'per_limit', oldPerLimit, newPerLimit);
    }



    function pay(uint256 eventId, uint256 num, uint nonce, bytes memory signature) public payable {

        require(verify2(_msgSender(), eventId, num, nonce, signature), 'invalid signture');
        require(_checkIsEventExist(eventId), 'event did not exist');
        require(_checkIsEventDuring(eventId), 'event is during now');
        require(_checkIsEnoughSupply(eventId, num), 'Sold out');
        require(_checkIsUnderPerLimit(eventId, num), 'Purchase limit reached');

        events[eventId].supplied = events[eventId].supplied.add(num);
        events[eventId].buy_his_count[_msgSender()] = events[eventId].buy_his_count[_msgSender()].add(num);
        emit Pay(eventId, msg.value, num, events[eventId].event_type, _msgSender());
    }


    function withdraw(address payable to) public onlyCFO {

        uint256 amount = address(this).balance;
        to.sendValue(amount);
    }

    function withdraw(address payable to, uint256 amount) public onlyCFO {

        to.sendValue(amount);
    }

    function getEventBalance(uint256 eventId) public onlyCFO view returns (uint256) {

        require(_checkIsEventExist(eventId), 'event did not exist');
        return events[eventId].amount;
    }

    function totalBalance() public view returns(uint256)  {

        return address(this).balance;
    }

    function getEventInfo(uint256 eventId) public view returns (uint256, string memory, string memory, bool, uint256, uint256, uint256) {

        require(_checkIsEventExist(eventId), 'event did not exist');
        return (
            events[eventId].price, 
            events[eventId].name, 
            events[eventId].event_type, 
            events[eventId].start, 
            events[eventId].total_supply, 
            events[eventId].supplied, 
            events[eventId].per_limit
        );
    }

    function getEventBuyCountOfAddress(uint256 eventId, address addr) public view returns (uint256) {

        require(_checkIsEventExist(eventId), 'event did not exist');

        return events[eventId].buy_his_count[addr];
    }

    function getIsAddressOutOfEventBuyLimit(uint256 eventId, address addr) public view returns (bool) {

        require(_checkIsEventExist(eventId), 'event did not exist');
        if (events[eventId].per_limit == 0) {
            return true;
        }

        if (events[eventId].buy_his_count[addr] < events[eventId].per_limit) {
            return true;
        }

        return false;
    }

    function getAllEventIds() public view returns(uint256[] memory) {

        return eventIds;
    }


    function _checkIsEventExist(uint256 eventId) internal view returns (bool) {

        return eventIdMap[eventId];
    }

    function _checkIsEventDuring(uint256 eventId) internal view returns (bool) {

        return events[eventId].start;
    }


    function _checkIsEnoughSupply(uint256 eventId, uint256 num) internal view returns (bool) {

        if (num > 100) {
            return false;
        }
        return (events[eventId].total_supply == 0) || (events[eventId].total_supply >= events[eventId].supplied.add(num));
    }

    function _checkIsUnderPerLimit(uint256 eventId, uint256 num) internal view returns (bool) {

        if (num > 100) {
            return false;
        }
        return (events[eventId].per_limit == 0) || (events[eventId].per_limit >= events[eventId].buy_his_count[_msgSender()].add(num));
    }
    
}