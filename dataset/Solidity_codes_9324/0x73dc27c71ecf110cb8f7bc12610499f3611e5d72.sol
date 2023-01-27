
pragma solidity ^0.7.0;
pragma experimental SMTChecker;


abstract contract OwnableIf {

    modifier onlyOwner() {
        require(msg.sender == _owner(), "not owner......");
        _;
    }

    function _owner() view virtual public returns (address);
}

pragma solidity ^0.7.0;




contract Ownable is OwnableIf {

    address public owner;

    function _owner() view override public returns (address){

        return owner;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() {
        owner = msg.sender;
    }



    function transferOwnership(address _newOwner) virtual public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0), "invalid _newOwner");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}



pragma solidity ^0.7.0;




contract Claimable is Ownable {

    address public pendingOwner;

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner, "no permission");
        _;
    }

    function transferOwnership(address newOwner) override public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

pragma solidity ^0.7.0;

abstract contract MemberMgrIf {
    function requireMerchant(address _who) virtual public view;

    function requireCustodian(address _who) virtual public view;
}
pragma solidity ^0.7.0;

abstract contract ERC20If {
    function totalSupply() virtual public view returns (uint256);

    function balanceOf(address _who) virtual public view returns (uint256);

    function transfer(address _to, uint256 _value) virtual public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address _owner, address _spender) virtual public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool);

    function approve(address _spender, uint256 _value) virtual public returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity ^0.7.0;


abstract contract ERC20ControllerViewIf {
    function blocked(address _who) virtual public view returns (bool);

    function paused() virtual public view returns (bool);
}

abstract contract MTokenControllerIf is MemberMgrIf, ERC20ControllerViewIf {
    function mint(address to, uint amount) virtual external returns (bool);

    function burn(uint value) virtual external returns (bool);

    function getMToken() virtual external returns (ERC20If);
}
pragma solidity ^0.7.0;

contract NamedERC20 {

    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
}

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
pragma solidity ^0.7.0;



contract ERC20Basic is ERC20If {

    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 internal totalSupply_;

    function _notPaused() virtual internal view returns (bool){return false;}


    function _notBlocked(address) virtual internal view returns (bool){return false;}


    modifier notPaused() {

        require(_notPaused(), "contract has been paused");
        _;
    }

    modifier notBlocked() {

        require(_notBlocked(msg.sender), "sender has been blocked");
        _;
    }

    function totalSupply() override public view returns (uint256) {

        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) override public notPaused notBlocked returns (bool) {

        require(_notBlocked(_to), "to-address has been blocked");
        require(_value <= balances[msg.sender], "insufficient balance");
        require(_to != address(0), "invalid to-address");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) override public view returns (uint256) {

        return balances[_owner];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    override public notPaused notBlocked
    returns (bool)
    {

        require(_notBlocked(_from), "from-address has been blocked");
        require(_notBlocked(_to), "to-address has been blocked");
        require(_value <= balances[_from], "insufficient balance");
        require(_to != address(0), "invalid to-address");
        if (_from == msg.sender){
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            return true;
        }

        require(_value <= allowed[_from][msg.sender], "value > allowed");


        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
    override public notPaused notBlocked
    returns (bool) {

        require(_notBlocked(_spender), "spender-address has been blocked");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public notPaused notBlocked
    returns (bool)
    {

        require(_notBlocked(_spender), "spender-address has been blocked");
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
    public
    notPaused notBlocked
    returns (bool success)
    {

        require(_notBlocked(_spender), "spender-address has been blocked");

        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    )
    override
    public
    view
    returns (uint256)
    {

        return allowed[_owner][_spender];
    }
}
pragma solidity ^0.7.0;



abstract contract MintableERC20 is ERC20Basic, OwnableIf {
    using SafeMath for uint256;

    event Mint(address indexed to, uint256 amount);
    event MintFinished(bool indexed finished);

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished, "can't mint");
        _;
    }

    modifier hasMintPermission() {
        require(msg.sender == _owner(), "no permission...");
        _;
    }

    function mint(
        address _to,
        uint256 _amount
    )
    public
    hasMintPermission
    canMint
    notPaused
    returns (bool)
    {
        require(_notBlocked(_to), "to-address has been blocked");
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function finishMinting(bool finished)
    public
    onlyOwner
    returns (bool) {
        mintingFinished = finished;
        emit MintFinished(mintingFinished);
        return true;
    }
}
pragma solidity ^0.7.0;



contract BurnableToken is ERC20Basic {

    using SafeMath for uint256;

    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public returns (bool){

        address _who = msg.sender;
        require(_value <= balances[_who]);

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);

        return true;
    }
}
pragma solidity ^0.7.0;



abstract contract CanReclaimToken is OwnableIf {

    function reclaimToken(ERC20If _token) external onlyOwner {
        uint256 balance = _token.balanceOf((address)(this));
        require(_token.transfer(_owner(), balance));
    }

}

pragma solidity ^0.7.0;



contract MToken is NamedERC20, Claimable, MintableERC20, BurnableToken, CanReclaimToken {

    using SafeMath for uint256;

    ERC20ControllerViewIf public erc20Controller;
    constructor(string memory _name,
        string memory _symbol,
        uint8 _decimals,
        ERC20ControllerViewIf _erc20Controller
    ) NamedERC20(_name, _symbol, _decimals){
        erc20Controller = _erc20Controller;
    }

    function hasController() view public returns (bool){

        return (address)(erc20Controller) != (address)(0);
    }

    function _notPaused() override internal view returns (bool){

        if (hasController()) {
            return !erc20Controller.paused();
        }
        return true;
    }

    function _notBlocked(address _who) override internal view returns (bool){

        if (hasController()) {
            return !erc20Controller.blocked(_who);
        }
        return true;
    }

    function setController(ERC20ControllerViewIf newController) public onlyOwner {

        erc20Controller = newController;
    }

    event BurnBlocked(address indexed burner, uint256 value);

    function burnBlocked(address addrBlocked, uint256 amount) public onlyOwner returns (bool){

        address _who = addrBlocked;
        require(!_notBlocked(_who), "addr not blocked");

        uint256 _value = amount;
        if (_value > balances[_who]) {
            _value = balances[_who];
        }

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit BurnBlocked(_who, _value);
        emit Transfer(_who, address(0), _value);

        return true;
    }

}
pragma solidity ^0.7.0;

abstract contract BlockedList is OwnableIf, ERC20ControllerViewIf {
    mapping(address => bool) public blockedList;

    event Blocked(
        address indexed _who,
        bool indexed status
    );

    function _block(address _who, bool _blocked) public onlyOwner {
        require(_who != (address)(0x0), "0 address");
        blockedList[_who] = _blocked;
        emit Blocked(_who, _blocked);
    }

    function blocked(address _who) override view public returns (bool){
        return blockedList[_who];
    }
}
pragma solidity ^0.7.0;

//pragma experimental ABIEncoderV2;

abstract contract MintFactoryIfView {
    MTokenControllerIf public controller;

    mapping(address => string) public custodianBtcAddressForMerchant;

    mapping(address => string) public btcDepositAddressOfMerchant;

    enum RequestStatus {PENDING, CANCELED, APPROVED, REJECTED}
    struct Request {
        address requester;
        uint amount;
        string btcAddress;
        string btcTxId;
        uint seq;
        uint requestBlockNo;
        uint confirmedBlockNo;
        RequestStatus status;
    }

    mapping(bytes32 => uint) public mintRequestSeqMap;

    mapping(bytes32 => uint) public burnRequestSeqMap;

    Request[] public mintRequests;

    Request[] public burnRequests;

    function getMintRequest(uint seq)
    external
    view
    virtual
    returns (
        uint requestSeq,
        address requester,
        uint amount,
        string memory btcAddress,
        string memory btcTxId,
        uint requestBlockNo,
        uint confirmedBlockNo,
        string  memory status,
        bytes32 requestHash
    );

    function getMintRequestsLength() virtual external view returns (uint length);

    function getBurnRequest(uint seq)
    external
    view
    virtual
    returns (
        uint requestSeq,
        address requester,
        uint amount,
        string memory btcAddress,
        string memory btcTxId,
        uint requestBlockNo,
        uint confirmedBlockNo,
        string  memory status,
        bytes32 requestHash
    );

    function getBurnRequestsLength() virtual external view returns (uint length);

    function getPendingMintRequestV(bytes32 _requestHash)
    virtual
    view public returns (
        uint requestSeq,
        address requester,
        uint amount,
        string memory btcAddress,
        string memory btcTxId,
        uint requestBlockNo,
        uint confirmedBlockNo,
        string  memory status);


}
pragma solidity ^0.7.0;


contract MintFactory is Ownable, MintFactoryIfView, CanReclaimToken {

    function getStatusString(RequestStatus status) internal pure returns (string memory) {

        if (status == RequestStatus.PENDING) {
            return "pending";
        } else if (status == RequestStatus.CANCELED) {
            return "canceled";
        } else if (status == RequestStatus.APPROVED) {
            return "approved";
        } else if (status == RequestStatus.REJECTED) {
            return "rejected";
        } else {
            return "unknown";
        }
    }

    function getMintRequest(uint seq) override
    external
    view
    returns (
        uint requestSeq,
        address requester,
        uint amount,
        string memory btcAddress,
        string memory btcTxId,
        uint requestBlockNo,
        uint confirmedBlockNo,
        string  memory status,
        bytes32 requestHash
    )
    {

        require(seq > 0, "seq from 1");
        require(seq < mintRequests.length, "invalid seq");
        Request memory request = mintRequests[seq];
        string memory statusString = getStatusString(request.status);

        requestSeq = seq;
        requester = request.requester;
        amount = request.amount;
        btcAddress = request.btcAddress;
        btcTxId = request.btcTxId;
        requestBlockNo = request.requestBlockNo;
        confirmedBlockNo = request.confirmedBlockNo;
        status = statusString;
        requestHash = calcRequestHash(request);
    }

    function getMintRequestsLength() override external view returns (uint length) {

        return mintRequests.length;
    }

    function getBurnRequest(uint seq) override
    external
    view
    returns (
        uint requestSeq,
        address requester,
        uint amount,
        string memory btcAddress,
        string memory btcTxId,
        uint requestBlockNo,
        uint confirmedBlockNo,
        string  memory status,
        bytes32 requestHash
    )
    {

        require(seq > 0, "seq from 1");
        require(seq < burnRequests.length, "invalid seq");
        Request storage request = burnRequests[seq];
        string memory statusString = getStatusString(request.status);

        requestSeq = seq;
        requester = request.requester;
        amount = request.amount;
        btcAddress = request.btcAddress;
        btcTxId = request.btcTxId;
        requestBlockNo = request.requestBlockNo;
        confirmedBlockNo = request.confirmedBlockNo;
        status = statusString;
        requestHash = calcRequestHash(request);
    }

    function getBurnRequestsLength() override external view returns (uint length) {

        return burnRequests.length;
    }

    constructor() {
        controller = (MTokenControllerIf)(owner);

        Request memory request = Request({
            requester : (address)(0),
            amount : 0,
            btcAddress : "invalid.address",
            btcTxId : "invalid.tx",
            seq : 0,
            requestBlockNo : 0,
            confirmedBlockNo : 0,
            status : RequestStatus.REJECTED
            });

        mintRequests.push(request);
        burnRequests.push(request);
    }

    modifier onlyMerchant() {

        controller.requireMerchant(msg.sender);
        _;
    }

    modifier onlyCustodian() {

        controller.requireCustodian(msg.sender);
        _;
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {

        if (bytes(a).length != bytes(b).length) {
            return false;
        }
        for (uint i = 0; i < bytes(a).length; i ++) {
            if (bytes(a)[i] != bytes(b)[i]) {
                return false;
            }
        }
        return true;
    }

    function isEmptyString(string memory a) internal pure returns (bool) {

        return (compareStrings(a, ""));
    }

    event CustodianBtcAddressForMerchantSet(address indexed merchant,
        address indexed sender,
        string btcDepositAddress);

    function setCustodianBtcAddressForMerchant(
        address merchant,
        string  memory btcAddress
    )
    external
    onlyCustodian
    returns (bool)
    {

        require((address)(merchant) != address(0), "invalid merchant address");
        controller.requireMerchant(merchant);
        require(!isEmptyString(btcAddress), "invalid btc address");

        custodianBtcAddressForMerchant[merchant] = btcAddress;
        emit CustodianBtcAddressForMerchantSet(merchant, msg.sender, btcAddress);
        return true;
    }

    event BtcDepositAddressOfMerchantSet(address indexed merchant,
        string btcDepositAddress);

    function setMerchantBtcDepositAddress(string  memory btcAddress)
    external
    onlyMerchant
    returns (bool) {

        require(!isEmptyString(btcAddress), "invalid btc address");

        btcDepositAddressOfMerchant[msg.sender] = btcAddress;
        emit BtcDepositAddressOfMerchantSet(msg.sender, btcAddress);
        return true;
    }

    event NewMintRequest(
        uint indexed seq,
        address indexed requester,
        string btcAddress,
        string btcTxId,
        uint blockNo,
        bytes32 requestHash
    );

    function requestMint(
        uint amount,
        string memory btcTxId
    )
    external
    onlyMerchant
    returns (bool)
    {

        require(!isEmptyString(btcTxId), "invalid btcTxId");
        require(!isEmptyString(custodianBtcAddressForMerchant[msg.sender]), "invalid btc deposit address");

        uint seq = mintRequests.length;
        uint blockNo = block.number;

        Request memory request = Request({
            requester : msg.sender,
            amount : amount,
            btcAddress : custodianBtcAddressForMerchant[msg.sender],
            btcTxId : btcTxId,
            seq : seq,
            requestBlockNo : blockNo,
            confirmedBlockNo : 0,
            status : RequestStatus.PENDING
            });

        bytes32 requestHash = calcRequestHash(request);
        mintRequestSeqMap[requestHash] = seq;
        mintRequests.push(request);

        emit NewMintRequest(seq, msg.sender, request.btcAddress, btcTxId, blockNo, requestHash);
        return true;
    }

    function calcRequestHash(Request memory request) internal pure returns (bytes32) {

        return keccak256(abi.encode(
                request.requester,
                request.btcAddress,
                request.btcTxId,
                request.seq,
                request.requestBlockNo
            ));
    }

    event MintRequestCancel(uint indexed seq, address indexed requester, bytes32 requestHash);

    function getPendingMintRequest(bytes32 _requestHash) view private returns (Request memory) {

        uint seq = mintRequestSeqMap[_requestHash];
        require(mintRequests.length > seq, "invalid seq");
        require(seq > 0, "invalid requestHash");
        Request memory request = mintRequests[seq];
        require(request.status == RequestStatus.PENDING, "status not pending.");
        require(_requestHash == calcRequestHash(request), "invalid hash");

        return request;
    }

    function getPendingMintRequestV(bytes32 _requestHash) override view public returns (
        uint requestSeq,
        address requester,
        uint amount,
        string memory btcAddress,
        string memory btcTxId,
        uint requestBlockNo,
        uint confirmedBlockNo,
        string  memory status) {

        Request memory request = getPendingMintRequest(_requestHash);

        requestSeq = request.seq;
        requester = request.requester;
        amount = request.amount;
        btcAddress = request.btcAddress;
        btcTxId = request.btcTxId;
        requestBlockNo = request.requestBlockNo;
        confirmedBlockNo = request.confirmedBlockNo;
        status = getStatusString(request.status);
    }


    function cancelMintRequest(bytes32 requestHash) external onlyMerchant returns (bool) {

        Request memory request = getPendingMintRequest(requestHash);
        uint seq = request.seq;
        require(msg.sender == request.requester, "cancel sender is different than pending request initiator");

        mintRequests[seq].status = RequestStatus.CANCELED;

        emit MintRequestCancel(request.seq, msg.sender, calcRequestHash(request));
        return true;
    }

    event MintConfirmed(
        uint indexed seq,
        address indexed requester,
        uint amount,
        string btcDepositAddress,
        string btcTxid,
        uint blockNo,
        bytes32 requestHash
    );

    function confirmMintRequest(bytes32 requestHash) external onlyCustodian returns (bool) {

        uint blockNo = block.number;
        Request memory request = getPendingMintRequest(requestHash);
        require(blockNo > request.requestBlockNo, "confirmMintRequest failed");

        require(blockNo - 20 >= request.requestBlockNo, "confirmMintRequest failed, wait for 20 blocks");
        uint seq = request.seq;
        mintRequests[seq].status = RequestStatus.APPROVED;
        uint amount = mintRequests[seq].amount;
        mintRequests[seq].confirmedBlockNo = blockNo;

        require(controller.mint(request.requester, amount), "mint failed");
        emit MintConfirmed(
            request.seq,
            request.requester,
            amount,
            request.btcAddress,
            request.btcTxId,
            blockNo,
            calcRequestHash(request)
        );
        return true;
    }

    event MintRejected(
        uint indexed seq,
        address indexed requester,
        uint amount,
        string btcDepositAddress,
        string btcTxid,
        uint blockNo,
        bytes32 requestHash
    );

    function rejectMintRequest(bytes32 requestHash) external onlyCustodian returns (bool) {

        Request memory request = getPendingMintRequest(requestHash);
        uint seq = request.seq;

        mintRequests[seq].status = RequestStatus.REJECTED;
        uint blockNo = block.number;
        mintRequests[seq].confirmedBlockNo = blockNo;

        emit MintRejected(
            request.seq,
            request.requester,
            request.amount,
            request.btcAddress,
            request.btcTxId,
            blockNo,
            calcRequestHash(request)
        );
        return true;
    }

    event Burned(
        uint indexed seq,
        address indexed requester,
        uint amount,
        string btcAddress,
        uint blockNo,
        bytes32 requestHash
    );

    function burn(uint amount) external onlyMerchant returns (bool) {

        string memory btcDepositAddress = btcDepositAddressOfMerchant[msg.sender];
        require(!isEmptyString(btcDepositAddress), "merchant btc deposit address was not set");

        uint seq = burnRequests.length;
        uint blockNo = block.number;

        Request memory request = Request({
            requester : msg.sender,
            amount : amount,
            btcAddress : btcDepositAddress,
            btcTxId : "",
            seq : seq,
            requestBlockNo : blockNo,
            confirmedBlockNo : 0, //由确认阶段回填
            status : RequestStatus.PENDING
            });

        bytes32 requestHash = calcRequestHash(request);
        burnRequestSeqMap[requestHash] = seq;
        burnRequests.push(request);

        require(controller.getMToken().transferFrom(msg.sender, (address)(controller), amount), "trasnfer tokens to burn failed");
        require(controller.burn(amount), "burn failed");

        emit Burned(seq, msg.sender, amount, btcDepositAddress, blockNo, requestHash);
        return true;
    }

    event BurnConfirmed(
        uint indexed seq,
        address indexed requester,
        uint amount,
        string btcAddress,
        string btcTxId,
        uint blockNo
    );

    function confirmBurnRequest(bytes32 requestHash, string memory btcTxId) external onlyCustodian returns (bool) {

        uint seq = burnRequestSeqMap[requestHash];
        require(burnRequests.length > seq, "invalid seq");
        require(seq > 0, "invalid requestHash");
        Request memory request = burnRequests[seq];
        require(requestHash == calcRequestHash(request), "invalid requestHash");
        require(request.status == RequestStatus.PENDING, "status not pending.");

        burnRequests[seq].btcTxId = btcTxId;
        burnRequests[seq].status = RequestStatus.APPROVED;
        uint blockNo = block.number;
        burnRequests[seq].confirmedBlockNo = blockNo;
        request.btcTxId = btcTxId;
        burnRequestSeqMap[calcRequestHash(request)] = seq;

        emit BurnConfirmed(
            request.seq,
            request.requester,
            request.amount,
            request.btcAddress,
            btcTxId,
            blockNo
        );
        return true;
    }
}
pragma solidity ^0.7.0;


contract MTokenController is MTokenControllerIf, Claimable, BlockedList, CanReclaimToken {

    MToken public mtoken;
    MemberMgrIf public members;
    address public factory;

    function getMToken() view override external returns (ERC20If){

        return mtoken;
    }

    function requireCustodian(address _who) override public view {

        members.requireCustodian(_who);
    }

    function requireMerchant(address _who) override public view {

        members.requireMerchant(_who);
    }

    event MembersSet(MemberMgrIf indexed members);

    function setMembers(MemberMgrIf _members) external onlyOwner returns (bool) {

        require((address)(_members) != address(0), "invalid _members address");
        members = _members;
        emit MembersSet(members);
        return true;
    }

    event FactorySet(address indexed factory);

    function setFactory(address _factory) external onlyOwner returns (bool) {

        require(_factory != address(0), "invalid _factory address");
        factory = _factory;
        emit FactorySet(factory);
        return true;
    }

    event Paused(bool indexed status);

    bool public _paused = false;

    constructor(MToken _mtoken){
        mtoken = _mtoken;
        factory = (address)(new MintFactory());
    }

    modifier onlyFactory() {

        require(msg.sender == factory, "sender not authorized for minting or burning.");
        _;
    }

    function transferOwnershipOfOwned(address _newOwner, Ownable owned) public onlyOwner {

        owned.transferOwnership(_newOwner);
    }

    function reclaimTokenOfOwned(ERC20If _token, CanReclaimToken owned) external onlyOwner {

        owned.reclaimToken(_token);
    }

    function claimOwnershipOfMToken() public onlyOwner {

        mtoken.claimOwnership();
        mtoken.setController((ERC20ControllerViewIf)(this));
    }

    function paused() override public view returns (bool){

        return _paused;
    }

    function setPaused(bool status) public onlyOwner {

        _paused = status;
        emit Paused(status);
    }

    function mint(address to, uint amount) override external onlyFactory returns (bool) {

        require(to != address(0), "invalid to address");
        require(!paused(), "paused.");
        require(mtoken.mint(to, amount), "minting failed.");
        return true;
    }

    function burn(uint value) override external onlyFactory returns (bool) {

        require(!paused(), "token is paused.");
        require(mtoken.burn(value));
        return true;
    }

    function burnBlocked(address addrBlocked, uint256 amount) public onlyOwner returns (bool){

        require(mtoken.burnBlocked(addrBlocked,amount), "burnBlocked failed");
        return true;
    }

}

