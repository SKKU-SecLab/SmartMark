

pragma solidity ^0.4.24;


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


pragma solidity ^0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


pragma solidity ^0.4.24;




contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}


pragma solidity ^0.4.24;



contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


pragma solidity ^0.4.24;




contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {

    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


pragma solidity ^0.4.24;


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


pragma solidity ^0.4.24;



contract Claimable is Ownable {

  address public pendingOwner;

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    pendingOwner = newOwner;
  }

  function claimOwnership() public onlyPendingOwner {

    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}


pragma solidity 0.4.25;



contract Broker is Claimable {

    using SafeMath for uint256;

    struct Offer {
        address maker;
        address offerAsset;
        address wantAsset;
        uint64 nonce;
        uint256 offerAmount;
        uint256 wantAmount;
        uint256 availableAmount; // the remaining offer amount
    }

    struct AnnouncedWithdrawal {
        uint256 amount;
        uint256 canWithdrawAt;
    }

    enum State { Active, Inactive }
    State public state;

    uint32 constant maxAnnounceDelay = 604800;
    address constant etherAddr = address(0);

    uint8 constant ReasonDeposit = 0x01;
    uint8 constant ReasonMakerGive = 0x02;
    uint8 constant ReasonMakerFeeGive = 0x10;
    uint8 constant ReasonMakerFeeReceive = 0x11;
    uint8 constant ReasonFillerGive = 0x03;
    uint8 constant ReasonFillerFeeGive = 0x04;
    uint8 constant ReasonFillerReceive = 0x05;
    uint8 constant ReasonMakerReceive = 0x06;
    uint8 constant ReasonFillerFeeReceive = 0x07;
    uint8 constant ReasonCancel = 0x08;
    uint8 constant ReasonCancelFeeGive = 0x12;
    uint8 constant ReasonCancelFeeReceive = 0x13;
    uint8 constant ReasonWithdraw = 0x09;
    uint8 constant ReasonWithdrawFeeGive = 0x14;
    uint8 constant ReasonWithdrawFeeReceive = 0x15;

    address public coordinator;
    address public operator;
    uint32 public cancelAnnounceDelay;
    uint32 public withdrawAnnounceDelay;

    mapping(address => mapping(address => uint256)) public balances;
    mapping(bytes32 => Offer) public offers;
    mapping(bytes32 => bool) public usedHashes;
    mapping(address => bool) public whitelistedSpenders;
    mapping(address => mapping(address => bool)) public approvedSpenders;
    mapping(address => mapping(address => AnnouncedWithdrawal)) public announcedWithdrawals;
    mapping(bytes32 => uint256) public announcedCancellations;

    event Make(address indexed maker, bytes32 indexed offerHash);
    event Fill(address indexed filler, bytes32 indexed offerHash, uint256 amountFilled, uint256 amountTaken, address indexed maker);
    event Cancel(address indexed maker, bytes32 indexed offerHash);
    event BalanceIncrease(address indexed user, address indexed token, uint256 amount, uint8 indexed reason);
    event BalanceDecrease(address indexed user, address indexed token, uint256 amount, uint8 indexed reason);
    event WithdrawAnnounce(address indexed user, address indexed token, uint256 amount, uint256 canWithdrawAt);
    event CancelAnnounce(address indexed user, bytes32 indexed offerHash, uint256 canCancelAt);
    event SpenderApprove(address indexed user, address indexed spender);
    event SpenderRescind(address indexed user, address indexed spender);

    constructor()
        public
    {
        coordinator = msg.sender;
        operator = msg.sender;
        cancelAnnounceDelay = maxAnnounceDelay;
        withdrawAnnounceDelay = maxAnnounceDelay;
        state = State.Active;
    }

    modifier onlyCoordinator() {

        require(
            msg.sender == coordinator,
            "Invalid sender"
        );
        _;
    }

    modifier onlyActiveState() {

        require(
            state == State.Active,
            "Invalid state"
        );
        _;
    }

    modifier onlyInactiveState() {

        require(
            state == State.Inactive,
            "Invalid state"
        );
        _;
    }

    modifier notMoreThanMaxDelay(uint32 _delay) {

        require(
            _delay <= maxAnnounceDelay,
            "Invalid delay"
        );
        _;
    }

    modifier unusedReasonCode(uint8 _reasonCode) {

        require(
            _reasonCode > ReasonWithdrawFeeReceive,
            "Invalid reason code"
        );
        _;
    }

    function setState(State _state) external onlyOwner { state = _state; }


    function setCoordinator(address _coordinator) external onlyOwner {

        _validateAddress(_coordinator);
        coordinator = _coordinator;
    }

    function setOperator(address _operator) external onlyOwner {

        _validateAddress(operator);
        operator = _operator;
    }

    function setCancelAnnounceDelay(uint32 _delay)
        external
        onlyOwner
        notMoreThanMaxDelay(_delay)
    {

        cancelAnnounceDelay = _delay;
    }

    function setWithdrawAnnounceDelay(uint32 _delay)
        external
        onlyOwner
        notMoreThanMaxDelay(_delay)
    {

        withdrawAnnounceDelay = _delay;
    }

    function addSpender(address _spender)
        external
        onlyOwner
    {

        _validateAddress(_spender);
        whitelistedSpenders[_spender] = true;
    }

    function removeSpender(address _spender)
        external
        onlyOwner
    {

        _validateAddress(_spender);
        delete whitelistedSpenders[_spender];
    }

    function depositEther()
        external
        payable
        onlyActiveState
    {

        require(
            msg.value > 0,
            'Invalid value'
        );
        balances[msg.sender][etherAddr] = balances[msg.sender][etherAddr].add(msg.value);
        emit BalanceIncrease(msg.sender, etherAddr, msg.value, ReasonDeposit);
    }

    function depositERC20(
        address _user,
        address _token,
        uint256 _amount
    )
        external
        onlyCoordinator
        onlyActiveState
    {

        require(
            _amount > 0,
            'Invalid value'
        );
        balances[_user][_token] = balances[_user][_token].add(_amount);

        _validateIsContract(_token);
        require(
            _token.call(
                bytes4(keccak256("transferFrom(address,address,uint256)")),
                _user,
                address(this),
                _amount
            ),
            "transferFrom call failed"
        );
        require(
            _getSanitizedReturnValue(),
            "transferFrom failed."
        );

        emit BalanceIncrease(_user, _token, _amount, ReasonDeposit);
    }

    function withdraw(
        address _withdrawer,
        address _token,
        uint256 _amount,
        address _feeAsset,
        uint256 _feeAmount,
        uint64 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        onlyCoordinator
    {

        bytes32 msgHash = keccak256(abi.encodePacked(
            "withdraw",
            _withdrawer,
            _token,
            _amount,
            _feeAsset,
            _feeAmount,
            _nonce
        ));

        require(
            _recoverAddress(msgHash, _v, _r, _s) == _withdrawer,
            "Invalid signature"
        );

        _validateAndAddHash(msgHash);

        _withdraw(_withdrawer, _token, _amount, _feeAsset, _feeAmount);
    }

    function announceWithdraw(
        address _token,
        uint256 _amount
    )
        external
    {

        require(
            _amount <= balances[msg.sender][_token],
            "Amount too high"
        );

        AnnouncedWithdrawal storage announcement = announcedWithdrawals[msg.sender][_token];
        uint256 canWithdrawAt = now + withdrawAnnounceDelay;

        announcement.canWithdrawAt = canWithdrawAt;
        announcement.amount = _amount;

        emit WithdrawAnnounce(msg.sender, _token, _amount, canWithdrawAt);
    }

    function slowWithdraw(
        address _withdrawer,
        address _token,
        uint256 _amount
    )
        external
    {

        AnnouncedWithdrawal memory announcement = announcedWithdrawals[_withdrawer][_token];

        require(
            announcement.canWithdrawAt != 0 && announcement.canWithdrawAt <= now,
            "Insufficient delay"
        );

        require(
            announcement.amount == _amount,
            "Invalid amount"
        );

        delete announcedWithdrawals[_withdrawer][_token];

        _withdraw(_withdrawer, _token, _amount, etherAddr, 0);
    }

    function emergencyWithdraw(
        address _withdrawer,
        address _token,
        uint256 _amount
    )
        external
        onlyCoordinator
        onlyInactiveState
    {

        _withdraw(_withdrawer, _token, _amount, etherAddr, 0);
    }

    function makeOffer(
        address _maker,
        address _offerAsset,
        address _wantAsset,
        uint256 _offerAmount,
        uint256 _wantAmount,
        address _feeAsset,
        uint256 _feeAmount,
        uint64 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        onlyCoordinator
        onlyActiveState
    {

        require(
            _offerAmount > 0 && _wantAmount > 0,
            "Invalid amounts"
        );

        require(
            _offerAsset != _wantAsset,
            "Invalid assets"
        );

        bytes32 offerHash = keccak256(abi.encodePacked(
            "makeOffer",
            _maker,
            _offerAsset,
            _wantAsset,
            _offerAmount,
            _wantAmount,
            _feeAsset,
            _feeAmount,
            _nonce
        ));

        require(
            _recoverAddress(offerHash, _v, _r, _s) == _maker,
            "Invalid signature"
        );

        _validateAndAddHash(offerHash);

        _decreaseBalanceAndPayFees(
            _maker,
            _offerAsset,
            _offerAmount,
            _feeAsset,
            _feeAmount,
            ReasonMakerGive,
            ReasonMakerFeeGive,
            ReasonMakerFeeReceive
        );

        Offer storage offer = offers[offerHash];
        offer.maker = _maker;
        offer.offerAsset = _offerAsset;
        offer.wantAsset = _wantAsset;
        offer.offerAmount = _offerAmount;
        offer.wantAmount = _wantAmount;
        offer.availableAmount = _offerAmount;
        offer.nonce = _nonce;

        emit Make(_maker, offerHash);
    }

    function fillOffer(
        address _filler,
        bytes32 _offerHash,
        uint256 _amountToTake,
        address _feeAsset,
        uint256 _feeAmount,
        uint64 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        onlyCoordinator
        onlyActiveState
    {

        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "fillOffer",
                _filler,
                _offerHash,
                _amountToTake,
                _feeAsset,
                _feeAmount,
                _nonce
            )
        );

        require(
            _recoverAddress(msgHash, _v, _r, _s) == _filler,
            "Invalid signature"
        );

        _validateAndAddHash(msgHash);

        _fill(_filler, _offerHash, _amountToTake, _feeAsset, _feeAmount);
    }

    function fillOffers(
        address _filler,
        bytes32[] _offerHashes,
        uint256[] _amountsToTake,
        address _feeAsset,
        uint256 _feeAmount,
        uint64 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        onlyCoordinator
        onlyActiveState
    {

        require(
            _offerHashes.length > 0,
            'Invalid input'
        );
        require(
            _offerHashes.length == _amountsToTake.length,
            'Invalid inputs'
        );

        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "fillOffers",
                _filler,
                _offerHashes,
                _amountsToTake,
                _feeAsset,
                _feeAmount,
                _nonce
            )
        );

        require(
            _recoverAddress(msgHash, _v, _r, _s) == _filler,
            "Invalid signature"
        );

        _validateAndAddHash(msgHash);

        for (uint32 i = 0; i < _offerHashes.length; i++) {
            _fill(_filler, _offerHashes[i], _amountsToTake[i], etherAddr, 0);
        }

        _paySeparateFees(
            _filler,
            _feeAsset,
            _feeAmount,
            ReasonFillerFeeGive,
            ReasonFillerFeeReceive
        );
    }

    function cancel(
        bytes32 _offerHash,
        uint256 _expectedAvailableAmount,
        address _feeAsset,
        uint256 _feeAmount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        onlyCoordinator
    {

        require(
            _recoverAddress(keccak256(abi.encodePacked(
                "cancel",
                _offerHash,
                _feeAsset,
                _feeAmount
            )), _v, _r, _s) == offers[_offerHash].maker,
            "Invalid signature"
        );

        _cancel(_offerHash, _expectedAvailableAmount, _feeAsset, _feeAmount);
    }

    function announceCancel(bytes32 _offerHash)
        external
    {

        Offer memory offer = offers[_offerHash];

        require(
            offer.maker == msg.sender,
            "Invalid sender"
        );

        require(
            offer.availableAmount > 0,
            "Offer already cancelled"
        );

        uint256 canCancelAt = now + cancelAnnounceDelay;
        announcedCancellations[_offerHash] = canCancelAt;

        emit CancelAnnounce(offer.maker, _offerHash, canCancelAt);
    }

    function slowCancel(bytes32 _offerHash)
        external
    {

        require(
            announcedCancellations[_offerHash] != 0 && announcedCancellations[_offerHash] <= now,
            "Insufficient delay"
        );

        delete announcedCancellations[_offerHash];

        Offer memory offer = offers[_offerHash];
        _cancel(_offerHash, offer.availableAmount, etherAddr, 0);
    }

    function fastCancel(bytes32 _offerHash, uint256 _expectedAvailableAmount)
        external
        onlyCoordinator
    {

        require(
            announcedCancellations[_offerHash] != 0,
            "Missing annoncement"
        );

        delete announcedCancellations[_offerHash];

        _cancel(_offerHash, _expectedAvailableAmount, etherAddr, 0);
    }

    function emergencyCancel(bytes32 _offerHash, uint256 _expectedAvailableAmount)
        external
        onlyCoordinator
        onlyInactiveState
    {

        _cancel(_offerHash, _expectedAvailableAmount, etherAddr, 0);
    }

    function approveSpender(address _spender)
        external
    {

        require(
            whitelistedSpenders[_spender],
            "Spender is not whitelisted"
        );

        approvedSpenders[msg.sender][_spender] = true;
        emit SpenderApprove(msg.sender, _spender);
    }

    function rescindApproval(address _spender)
        external
    {

        require(
            approvedSpenders[msg.sender][_spender],
            "Spender has not been approved"
        );

        require(
            whitelistedSpenders[_spender] != true,
            "Spender must be removed from the whitelist"
        );

        delete approvedSpenders[msg.sender][_spender];
        emit SpenderRescind(msg.sender, _spender);
    }

    function spendFrom(
        address _from,
        address _to,
        uint256 _amount,
        address _token,
        uint8 _decreaseReason,
        uint8 _increaseReason
    )
        external
        unusedReasonCode(_decreaseReason)
        unusedReasonCode(_increaseReason)
    {

        require(
            approvedSpenders[_from][msg.sender],
            "Spender has not been approved"
        );

        _validateAddress(_to);

        balances[_from][_token] = balances[_from][_token].sub(_amount);
        emit BalanceDecrease(_from, _token, _amount, _decreaseReason);

        balances[_to][_token] = balances[_to][_token].add(_amount);
        emit BalanceIncrease(_to, _token, _amount, _increaseReason);
    }

    function renounceOwnership() public { require(false, "Cannot have no owner"); }


    function _withdraw(
        address _withdrawer,
        address _token,
        uint256 _amount,
        address _feeAsset,
        uint256 _feeAmount
    )
        private
    {

        _decreaseBalanceAndPayFees(
            _withdrawer,
            _token,
            _amount,
            _feeAsset,
            _feeAmount,
            ReasonWithdraw,
            ReasonWithdrawFeeGive,
            ReasonWithdrawFeeReceive
        );

        if (_token == etherAddr) // ether
        {
            _withdrawer.transfer(_amount);
        }
        else
        {
            _validateIsContract(_token);
            require(
                _token.call(
                    bytes4(keccak256("transfer(address,uint256)")), _withdrawer, _amount
                ),
                "transfer call failed"
            );
            require(
                _getSanitizedReturnValue(),
                "transfer failed"
            );
        }
    }

    function _fill(
        address _filler,
        bytes32 _offerHash,
        uint256 _amountToTake,
        address _feeAsset,
        uint256 _feeAmount
    )
        private
    {

        require(
            _amountToTake > 0,
            "Invalid input"
        );

        Offer storage offer = offers[_offerHash];
        require(
            offer.maker != _filler,
            "Invalid filler"
        );

        require(
            offer.availableAmount != 0,
            "Offer already filled"
        );

        uint256 amountToFill = (_amountToTake.mul(offer.wantAmount)).div(offer.offerAmount);

        balances[_filler][offer.wantAsset] = balances[_filler][offer.wantAsset].sub(amountToFill);
        emit BalanceDecrease(_filler, offer.wantAsset, amountToFill, ReasonFillerGive);

        balances[offer.maker][offer.wantAsset] = balances[offer.maker][offer.wantAsset].add(amountToFill);
        emit BalanceIncrease(offer.maker, offer.wantAsset, amountToFill, ReasonMakerReceive);

        offer.availableAmount = offer.availableAmount.sub(_amountToTake);
        _increaseBalanceAndPayFees(
            _filler,
            offer.offerAsset,
            _amountToTake,
            _feeAsset,
            _feeAmount,
            ReasonFillerReceive,
            ReasonFillerFeeGive,
            ReasonFillerFeeReceive
        );
        emit Fill(_filler, _offerHash, amountToFill, _amountToTake, offer.maker);

        if (offer.availableAmount == 0)
        {
            delete offers[_offerHash];
        }
    }

    function _cancel(
        bytes32 _offerHash,
        uint256 _expectedAvailableAmount,
        address _feeAsset,
        uint256 _feeAmount
    )
        private
    {

        Offer memory offer = offers[_offerHash];

        require(
            offer.availableAmount > 0,
            "Offer already cancelled"
        );

        require(
            offer.availableAmount == _expectedAvailableAmount,
            "Invalid input"
        );

        delete offers[_offerHash];

        _increaseBalanceAndPayFees(
            offer.maker,
            offer.offerAsset,
            offer.availableAmount,
            _feeAsset,
            _feeAmount,
            ReasonCancel,
            ReasonCancelFeeGive,
            ReasonCancelFeeReceive
        );

        emit Cancel(offer.maker, _offerHash);
    }

    function _recoverAddress(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s)
        private
        pure
        returns (address)
    {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, _hash));
        return ecrecover(prefixedHash, _v, _r, _s);
    }

    function _decreaseBalanceAndPayFees(
        address _user,
        address _token,
        uint256 _amount,
        address _feeAsset,
        uint256 _feeAmount,
        uint8 _reason,
        uint8 _feeGiveReason,
        uint8 _feeReceiveReason
    )
        private
    {

        uint256 totalAmount = _amount;

        if (_feeAsset == _token) {
            totalAmount = _amount.add(_feeAmount);
        }

        balances[_user][_token] = balances[_user][_token].sub(totalAmount);
        emit BalanceDecrease(_user, _token, totalAmount, _reason);

        _payFees(_user, _token, _feeAsset, _feeAmount, _feeGiveReason, _feeReceiveReason);
    }

    function _increaseBalanceAndPayFees(
        address _user,
        address _token,
        uint256 _amount,
        address _feeAsset,
        uint256 _feeAmount,
        uint8 _reason,
        uint8 _feeGiveReason,
        uint8 _feeReceiveReason
    )
        private
    {

        uint256 totalAmount = _amount;

        if (_feeAsset == _token) {
            totalAmount = _amount.sub(_feeAmount);
        }

        balances[_user][_token] = balances[_user][_token].add(totalAmount);
        emit BalanceIncrease(_user, _token, totalAmount, _reason);

        _payFees(_user, _token, _feeAsset, _feeAmount, _feeGiveReason, _feeReceiveReason);
    }

    function _payFees(
        address _user,
        address _token,
        address _feeAsset,
        uint256 _feeAmount,
        uint8 _feeGiveReason,
        uint8 _feeReceiveReason
    )
        private
    {

        if (_feeAmount == 0) {
            return;
        }

        if (_feeAsset != _token) {
            balances[_user][_feeAsset] = balances[_user][_feeAsset].sub(_feeAmount);
            emit BalanceDecrease(_user, _feeAsset, _feeAmount, _feeGiveReason);
        }

        balances[operator][_feeAsset] = balances[operator][_feeAsset].add(_feeAmount);
        emit BalanceIncrease(operator, _feeAsset, _feeAmount, _feeReceiveReason);
    }

    function _paySeparateFees(
        address _user,
        address _feeAsset,
        uint256 _feeAmount,
        uint8 _feeGiveReason,
        uint8 _feeReceiveReason
    )
        private
    {

        if (_feeAmount == 0) {
            return;
        }

        balances[_user][_feeAsset] = balances[_user][_feeAsset].sub(_feeAmount);
        emit BalanceDecrease(_user, _feeAsset, _feeAmount, _feeGiveReason);

        balances[operator][_feeAsset] = balances[operator][_feeAsset].add(_feeAmount);
        emit BalanceIncrease(operator, _feeAsset, _feeAmount, _feeReceiveReason);
    }

    function _validateAddress(address _address)
        private
        pure
    {

        require(
            _address != address(0),
            'Invalid address'
        );
    }

    function _validateAndAddHash(bytes32 _hash)
        private
    {

        require(
            usedHashes[_hash] != true,
            "hash already used"
        );

        usedHashes[_hash] = true;
    }

    function _validateIsContract(address addr) private view {

        assembly {
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
    }

    function _getSanitizedReturnValue()
        private
        pure
        returns (bool)
    {

        uint256 result = 0;
        assembly {
            switch returndatasize
            case 0 {    // this is an non-standard ERC-20 token
                result := 1 // assume success on no revert
            }
            case 32 {   // this is a standard ERC-20 token
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            default {   // this is not an ERC-20 token
                revert(0, 0) // revert for safety
            }
        }
        return result != 0;
    }
}


pragma solidity 0.4.25;




contract NukeBurner {

    using SafeMath for uint256;

    StandardToken public nuke;
    Broker public broker;

    uint8 constant ReasonDepositBurnGive = 0x40;
    uint8 constant ReasonDepositBurnReceive = 0x41;

    mapping(address => uint256) public preparedBurnAmounts;
    mapping(address => bytes32) public preparedBurnHashes;

    event PrepareBurn(address indexed depositer, uint256 depositAmount, bytes32 indexed approvalTransactionHash, uint256 burnAmount);
    event ExecuteBurn(address indexed depositer, uint256 burnAmount, bytes32 indexed approvalTransactionHash);

    constructor(address brokerAddress, address tokenAddress)
        public
    {
        broker = Broker(brokerAddress);
        nuke = StandardToken(tokenAddress);
    }

    modifier onlyCoordinator() {

        require(
            msg.sender == address(broker.coordinator()),
            "Invalid sender"
        );
        _;
    }

    function prepareBurn(
        address _depositer,
        uint256 _depositAmount,
        bytes32 _approvalTransactionHash
    )
        external
        onlyCoordinator
    {

        require(
            _depositAmount > 0,
            "Invalid deposit amount"
        );

        require(
            nuke.allowance(_depositer, address(broker)) == _depositAmount,
            "Invalid approval amount"
        );

        preparedBurnAmounts[_depositer] = _depositAmount.div(50);
        preparedBurnHashes[_depositer] = _approvalTransactionHash;

        emit PrepareBurn(_depositer, _depositAmount, _approvalTransactionHash, preparedBurnAmounts[_depositer]);
    }

    function executeBurn(
        address _depositer,
        uint256 _burnAmount,
        bytes32 _approvalTransactionHash
    )
        external
        onlyCoordinator
    {

        require(
            _burnAmount == preparedBurnAmounts[_depositer],
            "Invalid burn amount"
        );

        require(
            _approvalTransactionHash == preparedBurnHashes[_depositer],
            "Invalid approval transaction hash"
        );

        require(
            nuke.allowance(_depositer, address(broker)) == 0,
            "Invalid approved amount"
        );

        delete preparedBurnAmounts[_depositer];
        delete preparedBurnHashes[_depositer];

        broker.spendFrom(
            _depositer,
            address(this),
            _burnAmount,
            address(nuke),
            ReasonDepositBurnGive,
            ReasonDepositBurnReceive
        );

        emit ExecuteBurn(_depositer, _burnAmount, _approvalTransactionHash);
    }
}