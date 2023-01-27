

pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;



contract MinterRole is Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


pragma solidity ^0.5.0;



contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}


pragma solidity ^0.5.0;


contract ERC20Capped is ERC20Mintable {

    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    function cap() public view returns (uint256) {

        return _cap;
    }

    function _mint(address account, uint256 value) internal {

        require(totalSupply().add(value) <= _cap, "ERC20Capped: cap exceeded");
        super._mint(account, value);
    }
}


pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.5.0;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}


pragma solidity ^0.5.0;



contract PauserRole is Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


pragma solidity ^0.5.0;



contract Pausable is Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}


pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.2;


contract ReferrableSale is Ownable {


    event DefaultReferralSet(
        uint256 percentage
    );

    event CustomReferralSet(
        address indexed referrer,
        uint256 percentage
    );

    uint256 public _defaultReferralPercentage;
    mapping (address => uint256) public _customReferralPercentages;

    function setDefaultReferral(uint256 defaultReferralPercentage) public onlyOwner {

        require(defaultReferralPercentage < 10000, "Referral must be less than 100 percent");
        require(defaultReferralPercentage != _defaultReferralPercentage, "New referral must be different from the previous");
        _defaultReferralPercentage = defaultReferralPercentage;
        emit DefaultReferralSet(defaultReferralPercentage);
    }

    function setCustomReferral(address _referrer, uint256 customReferralPercentage) public onlyOwner {

        require(customReferralPercentage < 10000, "Referral must be less than 100 percent");
        require(customReferralPercentage != _customReferralPercentages[_referrer], "New referral must be different from the previous");
        _customReferralPercentages[_referrer] = customReferralPercentage;
        emit CustomReferralSet(_referrer, customReferralPercentage);
    }
}


pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}


pragma solidity ^0.5.0;

interface IRelayRecipient {

    function getHubAddr() external view returns (address);


    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    )
        external
        view
        returns (uint256, bytes memory);


    function preRelayedCall(bytes calldata context) external returns (bytes32);


    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external;

}


pragma solidity ^0.5.0;

interface IRelayHub {


    function stake(address relayaddr, uint256 unstakeDelay) external payable;


    event Staked(address indexed relay, uint256 stake, uint256 unstakeDelay);

    function registerRelay(uint256 transactionFee, string calldata url) external;


    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    function removeRelayByOwner(address relay) external;


    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    function unstake(address relay) external;


    event Unstaked(address indexed relay, uint256 stake);

    enum RelayState {
        Unknown, // The relay is unknown to the system: it has never been staked for
        Staked, // The relay has been staked for, but it is not yet active
        Registered, // The relay has registered itself, and is active (can relay calls)
        Removed    // The relay has been removed by its owner and can no longer relay calls. It must wait for its unstakeDelay to elapse before it can unstake
    }

    function getRelay(address relay) external view returns (uint256 totalStake, uint256 unstakeDelay, uint256 unstakeTime, address payable owner, RelayState state);



    function depositFor(address target) external payable;


    event Deposited(address indexed recipient, address indexed from, uint256 amount);

    function balanceOf(address target) external view returns (uint256);


    function withdraw(uint256 amount, address payable dest) external;


    event Withdrawn(address indexed account, address indexed dest, uint256 amount);


    function canRelay(
        address relay,
        address from,
        address to,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata signature,
        bytes calldata approvalData
    ) external view returns (uint256 status, bytes memory recipientContext);


    enum PreconditionCheck {
        OK,                         // All checks passed, the call can be relayed
        WrongSignature,             // The transaction to relay is not signed by requested sender
        WrongNonce,                 // The provided nonce has already been used by the sender
        AcceptRelayedCallReverted,  // The recipient rejected this call via acceptRelayedCall
        InvalidRecipientStatusCode  // The recipient returned an invalid (reserved) status code
    }

    function relayCall(
        address from,
        address to,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata signature,
        bytes calldata approvalData
    ) external;


    event CanRelayFailed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 reason);

    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, RelayCallStatus status, uint256 charge);

    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful - never included in the event
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    function requiredGas(uint256 relayedCallStipend) external view returns (uint256);


    function maxPossibleCharge(uint256 relayedCallStipend, uint256 gasPrice, uint256 transactionFee) external view returns (uint256);



    function penalizeRepeatedNonce(bytes calldata unsignedTx1, bytes calldata signature1, bytes calldata unsignedTx2, bytes calldata signature2) external;


    function penalizeIllegalTransaction(bytes calldata unsignedTx, bytes calldata signature) external;


    event Penalized(address indexed relay, address sender, uint256 amount);

    function getNonce(address from) external view returns (uint256);

}


pragma solidity ^0.5.0;




contract GSNRecipient is IRelayRecipient, Context {

    address private _relayHub = 0xD216153c06E857cD7f72665E0aF1d7D82172F494;

    uint256 constant private RELAYED_CALL_ACCEPTED = 0;
    uint256 constant private RELAYED_CALL_REJECTED = 11;

    uint256 constant internal POST_RELAYED_CALL_MAX_GAS = 100000;

    event RelayHubChanged(address indexed oldRelayHub, address indexed newRelayHub);

    function getHubAddr() public view returns (address) {

        return _relayHub;
    }

    function _upgradeRelayHub(address newRelayHub) internal {

        address currentRelayHub = _relayHub;
        require(newRelayHub != address(0), "GSNRecipient: new RelayHub is the zero address");
        require(newRelayHub != currentRelayHub, "GSNRecipient: new RelayHub is the current one");

        emit RelayHubChanged(currentRelayHub, newRelayHub);

        _relayHub = newRelayHub;
    }

    function relayHubVersion() public view returns (string memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return "1.0.0";
    }

    function _withdrawDeposits(uint256 amount, address payable payee) internal {

        IRelayHub(_relayHub).withdraw(amount, payee);
    }


    function _msgSender() internal view returns (address payable) {

        if (msg.sender != _relayHub) {
            return msg.sender;
        } else {
            return _getRelayedCallSender();
        }
    }

    function _msgData() internal view returns (bytes memory) {

        if (msg.sender != _relayHub) {
            return msg.data;
        } else {
            return _getRelayedCallData();
        }
    }


    function preRelayedCall(bytes calldata context) external returns (bytes32) {

        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        return _preRelayedCall(context);
    }

    function _preRelayedCall(bytes memory context) internal returns (bytes32);


    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external {

        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        _postRelayedCall(context, success, actualCharge, preRetVal);
    }

    function _postRelayedCall(bytes memory context, bool success, uint256 actualCharge, bytes32 preRetVal) internal;


    function _approveRelayedCall() internal pure returns (uint256, bytes memory) {

        return _approveRelayedCall("");
    }

    function _approveRelayedCall(bytes memory context) internal pure returns (uint256, bytes memory) {

        return (RELAYED_CALL_ACCEPTED, context);
    }

    function _rejectRelayedCall(uint256 errorCode) internal pure returns (uint256, bytes memory) {

        return (RELAYED_CALL_REJECTED + errorCode, "");
    }

    function _computeCharge(uint256 gas, uint256 gasPrice, uint256 serviceFee) internal pure returns (uint256) {

        return (gas * gasPrice * (100 + serviceFee)) / 100;
    }

    function _getRelayedCallSender() private pure returns (address payable result) {



        bytes memory array = msg.data;
        uint256 index = msg.data.length;

        assembly {
            result := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function _getRelayedCallData() private pure returns (bytes memory) {


        uint256 actualDataLength = msg.data.length - 20;
        bytes memory actualData = new bytes(actualDataLength);

        for (uint256 i = 0; i < actualDataLength; ++i) {
            actualData[i] = msg.data[i];
        }

        return actualData;
    }
}


pragma solidity = 0.5.16;


interface ICrateOpenEmitter {

    function openCrate(address from, uint256 lotId, uint256 amount) external;

}


pragma solidity = 0.5.16;






contract F1DeltaCrate is ERC20Capped, ERC20Detailed, GSNRecipient, Ownable {

    enum ErrorCodes {
        RESTRICTED_METHOD,
        INSUFFICIENT_BALANCE
    }

    struct AcceptRelayedCallVars {
        bytes4 methodId;
        bytes ef;
    }

    string _uri;
    address _crateOpener;
    uint256 _lotId;
    uint256 public _cratesIssued;

    constructor(
        uint256 lotId, 
        uint256 cap,
        string memory name, 
        string memory symbol,
        string memory uri,
        address crateOpener
    ) ERC20Capped(cap) ERC20Detailed(name, symbol, 0) public {
        require(crateOpener != address(0));

        _uri = uri;
        _crateOpener = crateOpener;
        _lotId = lotId;
    }

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
        ICrateOpenEmitter(_crateOpener).openCrate(_msgSender(), _lotId, amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
        ICrateOpenEmitter(_crateOpener).openCrate(account, _lotId, amount);
    }

    function _mint(address account, uint256 amount) internal {

        _cratesIssued = _cratesIssued + amount; // not enough money in the world to cover 2 ^ 256 - 1 increments
        require(_cratesIssued <= cap(), "cratesIssued exceeded cap");
        super._mint(account, amount);
    }

    function tokenURI() public view returns (string memory) {

        return _uri;
    }

    function setURI(string memory uri) public onlyOwner {

        _uri = uri;
    }

    function acceptRelayedCall(
        address /*relay*/,
        address from,
        bytes calldata encodedFunction,
        uint256 /*transactionFee*/,
        uint256 /*gasPrice*/,
        uint256 /*gasLimit*/,
        uint256 /*nonce*/,
        bytes calldata /*approvalData*/,
        uint256 /*maxPossibleCharge*/
    )
        external
        view
        returns (uint256, bytes memory mem)
    {

        bytes4 methodId;
        uint256 amountParam;
        mem = encodedFunction;
        assembly {
            let dest := add(mem, 32)
            methodId := mload(dest)
            dest := add(dest, 4)
            amountParam := mload(dest)
        }

        if (methodId != 0x42966c68) {
            return _rejectRelayedCall(uint256(ErrorCodes.RESTRICTED_METHOD));
        }

        if (balanceOf(from) < amountParam) {
            return _rejectRelayedCall(uint256(ErrorCodes.INSUFFICIENT_BALANCE));
        }

        return _approveRelayedCall();
    }

    function _preRelayedCall(bytes memory) internal returns (bytes32) {

    }

    function _postRelayedCall(bytes memory, bool, uint256, bytes32) internal {

    }

    function withdrawDeposits(uint256 amount, address payable payee) external onlyOwner {

        _withdrawDeposits(amount, payee);
    }
}


pragma solidity = 0.5.16;



interface IKyber {

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view
        returns (uint expectedRate, uint slippageRate);


    function trade(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
    external
    payable
        returns(uint);

}


pragma solidity = 0.5.16;





contract KyberAdapter {

    using SafeMath for uint256;

    IKyber public kyber;
    
    ERC20 public ETH_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    constructor(address _kyberProxy) public {
        kyber = IKyber(_kyberProxy);
    }

    function () external payable {}

    function _getTokenDecimals(ERC20 _token) internal view returns (uint8 _decimals) {

        return _token != ETH_ADDRESS ? ERC20Detailed(address(_token)).decimals() : 18;
    }

    function _getTokenBalance(ERC20 _token, address _account) internal view returns (uint256 _balance) {

        return _token != ETH_ADDRESS ? _token.balanceOf(_account) : _account.balance;
    }

    function ceilingDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

        return a.div(b).add(a.mod(b) > 0 ? 1 : 0);
    }

    function _fixTokenDecimals(
        ERC20 _src,
        ERC20 _dest,
        uint256 _unfixedDestAmount,
        bool _ceiling
    )
    internal
    view
    returns (uint256 _destTokenAmount)
    {

        uint256 _unfixedDecimals = _getTokenDecimals(_src) + 18; // Kyber by default returns rates with 18 decimals.
        uint256 _decimals = _getTokenDecimals(_dest);

        if (_unfixedDecimals > _decimals) {
            if (_ceiling) {
                return ceilingDiv(_unfixedDestAmount, (10 ** (_unfixedDecimals - _decimals)));
            } else {
                return _unfixedDestAmount.div(10 ** (_unfixedDecimals - _decimals));
            }
        } else {
            return _unfixedDestAmount.mul(10 ** (_decimals - _unfixedDecimals));
        }
    }

    function _convertToken(
        ERC20 _src,
        uint256 _srcAmount,
        ERC20 _dest
    )
    internal
    view
    returns (
        uint256 _expectedAmount,
        uint256 _slippageAmount
    )
    {

        (uint256 _expectedRate, uint256 _slippageRate) = kyber.getExpectedRate(_src, _dest, _srcAmount);

        return (
            _fixTokenDecimals(_src, _dest, _srcAmount.mul(_expectedRate), false),
            _fixTokenDecimals(_src, _dest, _srcAmount.mul(_slippageRate), false)
        );
    }

    function _swapTokenAndHandleChange(
        ERC20 _src,
        uint256 _maxSrcAmount,
        ERC20 _dest,
        uint256 _maxDestAmount,
        uint256 _minConversionRate,
        address payable _initiator,
        address payable _receiver
    )
    internal
    returns (
        uint256 _srcAmount,
        uint256 _destAmount
    )
    {

        if (_src == _dest) {
            require(_maxSrcAmount >= _maxDestAmount);
            _destAmount = _srcAmount = _maxDestAmount;
            require(IERC20(_src).transferFrom(_initiator, address(this), _destAmount));
        } else {
            require(_src == ETH_ADDRESS ? msg.value >= _maxSrcAmount : msg.value == 0);

            uint256 _balanceBefore = _getTokenBalance(_src, address(this));

            if (_src != ETH_ADDRESS) {
                require(IERC20(_src).transferFrom(_initiator, address(this), _maxSrcAmount));
                require(IERC20(_src).approve(address(kyber), _maxSrcAmount));
            } else {
                _balanceBefore = _balanceBefore.sub(_maxSrcAmount);
            }

            _destAmount = kyber.trade.value(
                _src == ETH_ADDRESS ? _maxSrcAmount : 0
            )(
                _src,
                _maxSrcAmount,
                _dest,
                _receiver,
                _maxDestAmount,
                _minConversionRate,
                address(0)
            );
            
            uint256 _balanceAfter = _getTokenBalance(_src, address(this));
            _srcAmount = _maxSrcAmount;

            if (_balanceAfter > _balanceBefore) {
                uint256 _change = _balanceAfter - _balanceBefore;
                _srcAmount = _srcAmount.sub(_change);

                if (_src != ETH_ADDRESS) {
                    require(IERC20(_src).transfer(_initiator, _change));
                } else {
                    _initiator.transfer(_change);
                }
            }
        }
    }
}


pragma solidity = 0.5.16;











contract FixedSupplyCratesSale is ReferrableSale, Pausable, KyberAdapter, ICrateOpenEmitter {

    using SafeMath for uint256;

    struct Lot {
        F1DeltaCrate crateToken;
        uint256 price; // in stable coin
    }

    struct PurchaseForVars {
        Lot lot;
        uint256 discount;
        uint256 price;
        uint256 referralReward;
        uint256 tokensSent;
        uint256 tokensReceived;
    }

    event Purchased (
        address indexed owner,
        address operator,
        uint256 indexed lotId,
        uint256 indexed quantity,
        uint256 pricePaid,
        address tokenAddress,
        uint256 tokensSent,
        uint256 tokensReceived,
        uint256 discountApplied,
        address referrer,
        uint256 referralRewarded
    );

    event LotCreated (
        uint256 lotId,
        uint256 supply,
        uint256 price,
        string uri,
        ERC20 crateToken
    );

    event LotPriceUpdated (
        uint256 lotId,
        uint256 price
    );

    event CrateOpened(address indexed from, uint256 lotId, uint256 amount);

    uint256 private constant PERCENT_PRECISION = 10000;
    uint256 private constant MULTI_PURCHASE_DISCOUNT_STEP = 5;

    ERC20 public _stableCoinAddress;
    address payable public _payoutWallet;

    mapping (uint256 => Lot) public _lots; // lotId => lot
    mapping (uint256 => mapping (address => address)) public _referrersByLot; // lotId => (buyer => referrer)
    mapping (address => mapping(uint256 => uint256)) public _cratesPurchased; // owner => (lot id => quantity)

    uint256 public _initialDiscountPercentage;
    uint256 public _initialDiscountPeriod;
    uint256 public _startedAt;
    uint256 public _multiPurchaseDiscount;

    modifier whenStarted() {

        require(_startedAt != 0);
        _;
    }

    modifier whenNotStarted() {

        require(_startedAt == 0);
        _;
    }

    constructor(
        address payable payoutWallet, 
        address kyberProxy, 
        ERC20 stableCoinAddress
    ) KyberAdapter(kyberProxy) public {
        require(payoutWallet != address(0));
        require(stableCoinAddress != ERC20(address(0)));
        setPayoutWallet(payoutWallet); 

        _stableCoinAddress = stableCoinAddress;
        pause();
    }

    function setPayoutWallet(address payable payoutWallet) public onlyOwner {

        require(payoutWallet != address(uint160(address(this))));
        _payoutWallet = payoutWallet;
    }

    function start(
        uint256 initialDiscountPercentage, 
        uint256 initialDiscountPeriod, 
        uint256 multiPurchaseDiscount
    ) 
    public 
    onlyOwner 
    whenNotStarted
    {

        require(initialDiscountPercentage < PERCENT_PRECISION);
        require(multiPurchaseDiscount < PERCENT_PRECISION);

        _initialDiscountPercentage = initialDiscountPercentage;
        _initialDiscountPeriod = initialDiscountPeriod;
        _multiPurchaseDiscount = multiPurchaseDiscount;
        
        _startedAt = now;
        unpause();
    }

    function initialDiscountActive() public view returns (bool) {

        if (_initialDiscountPeriod == 0 || _initialDiscountPercentage == 0 || _startedAt == 0) {
            return false;
        }

        uint256 elapsed = (now - _startedAt);
        return elapsed < _initialDiscountPeriod;
    }

    function createLot(
        uint256 lotId,
        uint256 supply,
        uint256 price,
        string memory name,
        string memory symbol,
        string memory uri,
        F1DeltaCrate crateToken
    ) 
        public 
        onlyOwner 
    {

        require(price != 0 && supply != 0);
        require(_lots[lotId].price == 0);
        
        Lot memory lot;
        lot.price = price;
        if (crateToken == F1DeltaCrate(address(0))) {
            lot.crateToken = new F1DeltaCrate(lotId, supply, name, symbol, uri, address(this));
            lot.crateToken.transferOwnership(owner());
            lot.crateToken.addMinter(owner());
        } else {
            lot.crateToken = crateToken;
        }
        
        _lots[lotId] = lot;

        emit LotCreated(lotId, supply, price, uri, ERC20(address(lot.crateToken)));
    }

    function updateLotPrice(uint256 lotId, uint128 price) external onlyOwner whenPaused {

        require(price != 0);
        require(_lots[lotId].price != 0);
        require(_lots[lotId].price != price);

        _lots[lotId].price = price;

        emit LotPriceUpdated(lotId, price);
    }

    function _nthPurchaseDiscount(uint lotPrice, uint quantity, uint cratesPurchased) private view returns(uint) {

        uint discountsApplied = cratesPurchased / MULTI_PURCHASE_DISCOUNT_STEP;
        uint discountsToApply = (cratesPurchased + quantity) / MULTI_PURCHASE_DISCOUNT_STEP - discountsApplied;

        return lotPrice.mul(discountsToApply).mul(_multiPurchaseDiscount).div(PERCENT_PRECISION);
    }

    function _getPriceWithDiscounts(Lot memory lot, uint quantity, uint cratesPurchased) private view returns(uint price, uint discount) {

        price = lot.price.mul(quantity);

        if (initialDiscountActive()) {
            discount = price.mul(_initialDiscountPercentage).div(PERCENT_PRECISION);
        }

        discount += _nthPurchaseDiscount(lot.price, quantity, cratesPurchased);
        price = price.sub(discount);
    }

    function purchaseFor(
        address payable destination,
        uint256 lotId,
        ERC20Capped tokenAddress,
        uint256 quantity,
        uint256 maxTokenAmount,
        uint256 minConversionRate,
        address payable referrer
    )
        external 
        payable
        whenNotPaused 
        whenStarted
    {

        require (quantity > 0);
        require (referrer != destination && referrer != msg.sender); //Inefficient

        PurchaseForVars memory vars;

        vars.lot = _lots[lotId];
        require(vars.lot.price != 0);

        (vars.price, vars.discount) = _getPriceWithDiscounts(vars.lot, quantity, _cratesPurchased[destination][lotId]);

        (vars.tokensSent, vars.tokensReceived) = _swapTokenAndHandleChange(
            tokenAddress,
            maxTokenAmount,
            _stableCoinAddress,
            vars.price,
            minConversionRate,
            msg.sender,
            address(uint160(address(this)))
        );
        
        require(vars.tokensReceived >= vars.price);
        
        if (referrer != address(0)) {
            bool sendReferral = true;
            if (_customReferralPercentages[referrer] == 0) {
                if (_referrersByLot[lotId][destination] == referrer) { 
                    sendReferral = false;
                }
            }
            
            if (sendReferral) {
                vars.referralReward = vars.tokensReceived
                    .mul(Math.max(_customReferralPercentages[referrer], _defaultReferralPercentage))
                    .div(PERCENT_PRECISION);

                if (vars.referralReward > 0) {
                    _referrersByLot[lotId][destination] = referrer;
                    require(_stableCoinAddress.transfer(referrer, vars.referralReward));
                }
            }
        }

        vars.tokensReceived = vars.tokensReceived.sub(vars.referralReward);

        require(vars.lot.crateToken.mint(destination, quantity)); 
        require(_stableCoinAddress.transfer(_payoutWallet, vars.tokensReceived));
        _cratesPurchased[destination][lotId] += quantity;

        emit Purchased(
            destination,
            msg.sender,
            lotId,
            quantity,
            vars.price,
            address(tokenAddress),
            vars.tokensSent,
            vars.tokensReceived,
            vars.discount,
            referrer,
            vars.referralReward
        );
    }

    function getPrice(
        uint256 lotId,
        uint256 quantity,
        ERC20 tokenAddress,
        address destination
    )
    external
    view
    returns (
        uint256 minConversionRate,
        uint256 lotPrice,
        uint256 lotPriceWithoutDiscount
    )
    {

        lotPriceWithoutDiscount = _lots[lotId].price.mul(quantity);
        (uint totalPrice, ) = _getPriceWithDiscounts(_lots[lotId], quantity, _cratesPurchased[destination][lotId]);

        (, uint tokenAmount) = _convertToken(_stableCoinAddress, totalPrice, tokenAddress);
        (, minConversionRate) = kyber.getExpectedRate(tokenAddress, _stableCoinAddress, tokenAmount);
        lotPrice = ceilingDiv(totalPrice.mul(10**36), minConversionRate);
        lotPrice = _fixTokenDecimals(_stableCoinAddress, tokenAddress, lotPrice, true);

        lotPriceWithoutDiscount = ceilingDiv(lotPriceWithoutDiscount.mul(10**36), minConversionRate);
        lotPriceWithoutDiscount = _fixTokenDecimals(_stableCoinAddress, tokenAddress, lotPriceWithoutDiscount, true);
    }

    function openCrate(address from, uint256 lotId, uint256 amount) external {

        require(address(_lots[lotId].crateToken) == msg.sender);
        for (uint256 i = 0; i < amount; i++ ) {
            emit CrateOpened(from, lotId, 1);
        }
    }

}