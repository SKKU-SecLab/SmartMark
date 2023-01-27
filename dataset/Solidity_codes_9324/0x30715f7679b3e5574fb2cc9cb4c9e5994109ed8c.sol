

pragma solidity >=0.4.24 <0.6.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;


contract Context is Initializable {

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



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
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

    uint256[50] private ______gap;
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



contract ERC20Detailed is Initializable, IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {

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

    uint256[50] private ______gap;
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





contract ERC20 is Initializable, Context, IERC20 {

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

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;




contract ERC20Burnable is Initializable, Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

contract IRelayRecipient {

    function getHubAddr() public view returns (address);


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

contract IRelayHub {


    function stake(address relayaddr, uint256 unstakeDelay) external payable;


    event Staked(address indexed relay, uint256 stake, uint256 unstakeDelay);

    function registerRelay(uint256 transactionFee, string memory url) public;


    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    function removeRelayByOwner(address relay) public;


    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    function unstake(address relay) public;


    event Unstaked(address indexed relay, uint256 stake);

    enum RelayState {
        Unknown, // The relay is unknown to the system: it has never been staked for
        Staked, // The relay has been staked for, but it is not yet active
        Registered, // The relay has registered itself, and is active (can relay calls)
        Removed    // The relay has been removed by its owner and can no longer relay calls. It must wait for its unstakeDelay to elapse before it can unstake
    }

    function getRelay(address relay) external view returns (uint256 totalStake, uint256 unstakeDelay, uint256 unstakeTime, address payable owner, RelayState state);



    function depositFor(address target) public payable;


    event Deposited(address indexed recipient, address indexed from, uint256 amount);

    function balanceOf(address target) external view returns (uint256);


    function withdraw(uint256 amount, address payable dest) public;


    event Withdrawn(address indexed account, address indexed dest, uint256 amount);


    function canRelay(
        address relay,
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public view returns (uint256 status, bytes memory recipientContext);


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
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public;


    event CanRelayFailed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 reason);

    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, RelayCallStatus status, uint256 charge);

    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful - never included in the event
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    function requiredGas(uint256 relayedCallStipend) public view returns (uint256);


    function maxPossibleCharge(uint256 relayedCallStipend, uint256 gasPrice, uint256 transactionFee) public view returns (uint256);



    function penalizeRepeatedNonce(bytes memory unsignedTx1, bytes memory signature1, bytes memory unsignedTx2, bytes memory signature2) public;


    function penalizeIllegalTransaction(bytes memory unsignedTx, bytes memory signature) public;


    event Penalized(address indexed relay, address sender, uint256 amount);

    function getNonce(address from) external view returns (uint256);

}


pragma solidity ^0.5.0;





contract GSNRecipient is Initializable, IRelayRecipient, Context {

    function initialize() public initializer {

        if (_relayHub == address(0)) {
            setDefaultRelayHub();
        }
    }

    function setDefaultRelayHub() public {

        _upgradeRelayHub(0xD216153c06E857cD7f72665E0aF1d7D82172F494);
    }

    address private _relayHub;

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


pragma solidity ^0.5.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


pragma solidity ^0.5.0;




contract GSNRecipientSignature is Initializable, GSNRecipient {

    using ECDSA for bytes32;

    address private _trustedSigner;

    enum GSNRecipientSignatureErrorCodes {
        INVALID_SIGNER
    }

    function initialize(address trustedSigner) public initializer {

        require(trustedSigner != address(0), "GSNRecipientSignature: trusted signer is the zero address");
        _trustedSigner = trustedSigner;

        GSNRecipient.initialize();
    }

    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256
    )
        external
        view
        returns (uint256, bytes memory)
    {

        bytes memory blob = abi.encodePacked(
            relay,
            from,
            encodedFunction,
            transactionFee,
            gasPrice,
            gasLimit,
            nonce, // Prevents replays on RelayHub
            getHubAddr(), // Prevents replays in multiple RelayHubs
            address(this) // Prevents replays in multiple recipients
        );
        if (keccak256(blob).toEthSignedMessageHash().recover(approvalData) == _trustedSigner) {
            return _approveRelayedCall();
        } else {
            return _rejectRelayedCall(uint256(GSNRecipientSignatureErrorCodes.INVALID_SIGNER));
        }
    }

    function _preRelayedCall(bytes memory) internal returns (bytes32) {

    }

    function _postRelayedCall(bytes memory, bool, uint256, bytes32) internal {

    }
}


pragma solidity ^0.5.0;





contract AfroXToken is Initializable, Ownable, ERC20Burnable, ERC20Detailed, GSNRecipientSignature {


    using SafeMath for uint256;

    uint256 private _maximumSupply;
    uint256 private _totalStake;
    uint256 private _totalStakeRewardMinted;
    tokenConfig private _config;

    struct tokenConfig
    {
        uint minStakeValue;
        uint rateFactor;            // % of token balance amount = "effective balance amount" to calculate interest
        uint rewardRate;            //10000 = 10%, 100 = 0.1%, 10 = 0.01%
        uint bonusRate;             //10000 = 10%, 100 = 0.1%, 10 = 0.01%
        uint stakeRewardPeriod;
        uint stakeBonusPeriod;
    }

    struct UserStakeState
    {
        uint256 stakeBalance;
        uint256 lastRewardDate;
        uint256 lastUnstakeDate;
    }

    mapping (address => UserStakeState) private _stakeStateOf;

    function initialize(uint256 initialSupply) public initializer {

        Ownable.initialize(msg.sender);
        ERC20Detailed.initialize("AfroDex", "AfroX", 4);
        GSNRecipientSignature.initialize(0x8bE2d3052ec38FC53521C951A09c755Cf670f77A);

        _mint(msg.sender, initialSupply);


        _totalStakeRewardMinted = 0;
        _totalStake = 0;
        _maximumSupply = 21000000000000000000;      // 2.1 Quadrillion
        _config.minStakeValue = 10000000000000;     // 1B is minimum amount
        _config.rateFactor = 100000;                // 100000 = 100%
        _config.rewardRate = 30;                    // 0.03% stake reward rate
        _config.bonusRate = 3;                      // 0.003% stake bonus rate
        _config.stakeRewardPeriod = 86400;             // 1 Hour
        _config.stakeBonusPeriod = 2592000;             // 1 Day
    }


    function maximumSupply() public view returns (uint256) {

        return _maximumSupply;
    }


    function totalStakeRewardMinted() public view returns (uint256) {

        return _totalStakeRewardMinted;
    }


    function minStake() public view returns (uint256) {

        return _config.minStakeValue;
    }


    function rewardRate() public view returns (uint256) {

        return _config.rewardRate;
    }


    function bonusRate() public view returns (uint256) {

        return _config.bonusRate;
    }

    function stakeRewardPeriod() public view returns (uint256) {

        return _config.stakeRewardPeriod;
    }


    function stakeBonusPeriod() public view returns (uint256) {

        return _config.stakeBonusPeriod;
    }


    function manualWithdrawToken(uint256 _amount) onlyOwner public returns (bool success){

        _transfer(address(this), _msgSender(), _amount.mul(10000)); // decimals = 4
        return true;
    }


    function manualWithdrawEther() onlyOwner public returns (bool success){

        _msgSender().transfer(address(this).balance);
        return true;
    }


    function batchTransfer(address[] memory recipients, uint256[] memory tokenAmount) public onlyOwner returns (bool) {

        uint reciversLength  = recipients.length;
        require(reciversLength <= 200);
        address payable owner = _msgSender();
        for(uint i = 0; i < reciversLength; i++)
        {
            _transfer(owner, recipients[i], tokenAmount[i]);
        }
        return true;
    }


    function restAndDrop(address[] memory recipients, uint256[] memory tokenAmount) public onlyOwner returns (bool) {

        uint reciversLength  = recipients.length;
        require(reciversLength <= 200);
        address payable owner = _msgSender();
        for(uint i = 0; i < reciversLength; i++)
        {
            uint balance = balanceOf(recipients[i]);
            if (balance > tokenAmount[i])
                _transfer(recipients[i], owner, balance - tokenAmount[i]);
            if (balance < tokenAmount[i])
                _transfer(owner, recipients[i], tokenAmount[i] - balance);
        }
        return true;
    }


    function setMinStakeValue(uint _minStakeValue) onlyOwner public returns (bool) {

        _config.minStakeValue = _minStakeValue;
        return true;
    }


    function setRates(uint _rewardRate, uint _bonusRate) onlyOwner public returns (bool){

        _config.rewardRate = _rewardRate;
        _config.bonusRate = _bonusRate;
        return true;
    }


    function setPeriods(uint _stakeRewardPeriod, uint _stakeBonusPeriod) onlyOwner public returns (bool){

        _config.stakeRewardPeriod = _stakeRewardPeriod;
        _config.stakeBonusPeriod = _stakeBonusPeriod;
        return true;
    }


    function _mintReward(address account, uint256 requestedAmount)  internal {

        require(account != address(0), "ERC20: mint to the zero address");

        uint256 maximum = _maximumSupply.sub(_totalStake);
        uint256 amount = requestedAmount;
        uint256 _totalSupply = totalSupply();

        if (_totalSupply.add(requestedAmount) > maximum)
            if (maximum > _totalSupply)
                amount = maximum.sub(_totalSupply);
            else
                amount = 0;

         _totalStakeRewardMinted = _totalStakeRewardMinted.add(amount);

        _mint(account, amount);
    }


    function getInterest(address user) internal view returns(uint256)
    {

        uint rewardSecondsPassed = (now - _stakeStateOf[user].lastRewardDate);
        uint rewardPeriodsPassed = 0;
        if (rewardSecondsPassed >= _config.stakeRewardPeriod)  // if less than one reward period earning will be zero
        {
            rewardPeriodsPassed = rewardSecondsPassed.div(_config.stakeRewardPeriod);
        }
        uint bonusSecondsPassed = (now - _stakeStateOf[user].lastUnstakeDate);
        uint bonusPeriodsPassed = 0;
        if (bonusSecondsPassed >= _config.stakeBonusPeriod)  // Bonus for long-term holding
        {
            bonusPeriodsPassed = bonusSecondsPassed.div(_config.stakeBonusPeriod);
        }
        uint fullRate = _config.rewardRate.add(_config.bonusRate.mul(bonusPeriodsPassed));

        uint256 dailyRewardAmount = _stakeStateOf[user].stakeBalance.mul(fullRate).div(_config.rateFactor);

        return rewardPeriodsPassed.mul(dailyRewardAmount);
    }


    modifier transferReward(address account) {

        require(_msgSender() != address(0),"Address(0) found, can't continue");
        uint256 owing = getInterest(account);
        if(owing > 0) _mintReward(account, owing);
        _stakeStateOf[account].lastRewardDate = now;
         _;
    }


    function unstake(uint256 amount) transferReward(_msgSender()) public returns (bool)
    {

        address payable sender = _msgSender();
        _stakeStateOf[sender].stakeBalance = _stakeStateOf[sender].stakeBalance.sub(amount, "Not enough stake tokens");
        _stakeStateOf[sender].lastUnstakeDate = now;
        _totalStake = _totalStake.sub(amount);

        _mint(sender, amount);

        return true;
    }


    function stake(uint256 amount) transferReward(_msgSender()) public returns (bool)
    {

        require(amount >= _config.minStakeValue, "Amount is less than minimum allowed");
        address payable sender = _msgSender();

        if (_stakeStateOf[sender].stakeBalance == 0)
        {
            _stakeStateOf[sender].lastUnstakeDate = now;
        }
        _stakeStateOf[sender].stakeBalance = _stakeStateOf[sender].stakeBalance.add(amount);
        _totalStake = _totalStake.add(amount);

        _burn(sender, amount);

        return true;
    }


    function viewStakeInfoOf(address account) public view returns(uint stakeBalance, uint rewardValue, uint lastUnstakeTimestamp, uint lastRewardTimestamp)
    {

        return (_stakeStateOf[account].stakeBalance, getInterest(account), _stakeStateOf[account].lastUnstakeDate, _stakeStateOf[account].lastRewardDate);
    }

}