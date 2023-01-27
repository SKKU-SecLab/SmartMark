
pragma solidity ^0.4.23;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }
    c = a * b;
    require(c / a == b, "Overflow - Multiplication");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "Underflow - Subtraction");
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    require(c >= a, "Overflow - Addition");
    return c;
  }
}

library Contract {


  using SafeMath for uint;


  modifier conditions(function () pure first, function () pure last) {

    first();
    _;
    last();
  }

  bytes32 internal constant EXEC_PERMISSIONS = keccak256('script_exec_permissions');

  function authorize(address _script_exec) internal view {

    initialize();

    bytes32 perms = EXEC_PERMISSIONS;
    bool authorized;
    assembly {
      mstore(0, _script_exec)
      mstore(0x20, perms)
      mstore(0, keccak256(0x0c, 0x34))
      mstore(0x20, mload(0x80))
      authorized := sload(keccak256(0, 0x40))
    }
    if (!authorized)
      revert("Sender is not authorized as a script exec address");
  }

  function initialize() internal view {

    require(freeMem() == 0x80, "Memory allocated prior to execution");
    assembly {
      mstore(0x80, sload(0))     // Execution id, read from storage
      mstore(0xa0, sload(1))     // Original sender address, read from storage
      mstore(0xc0, 0)            // Pointer to storage buffer
      mstore(0xe0, 0)            // Bytes4 value of the current action requestor being used
      mstore(0x100, 0)           // Enum representing the next type of function to be called (when pushing to buffer)
      mstore(0x120, 0)           // Number of storage slots written to in buffer
      mstore(0x140, 0)           // Number of events pushed to buffer
      mstore(0x160, 0)           // Number of payment destinations pushed to buffer

      mstore(0x40, 0x180)
    }
    assert(execID() != bytes32(0) && sender() != address(0));
  }

  function checks(function () view _check) conditions(validState, validState) internal view {

    _check();
  }

  function checks(function () pure _check) conditions(validState, validState) internal pure {

    _check();
  }

  function commit() conditions(validState, none) internal pure {

    bytes32 ptr = buffPtr();
    require(ptr >= 0x180, "Invalid buffer pointer");

    assembly {
      let size := mload(add(0x20, ptr))
      mstore(ptr, 0x20) // Place dynamic data offset before buffer
      revert(ptr, add(0x40, size))
    }
  }


  function validState() private pure {

    if (freeMem() < 0x180)
      revert('Expected Contract.execute()');

    if (buffPtr() != 0 && buffPtr() < 0x180)
      revert('Invalid buffer pointer');

    assert(execID() != bytes32(0) && sender() != address(0));
  }

  function buffPtr() private pure returns (bytes32 ptr) {

    assembly { ptr := mload(0xc0) }
  }

  function freeMem() private pure returns (bytes32 ptr) {

    assembly { ptr := mload(0x40) }
  }

  function currentAction() private pure returns (bytes4 action) {

    if (buffPtr() == bytes32(0))
      return bytes4(0);

    assembly { action := mload(0xe0) }
  }

  function isStoring() private pure {

    if (currentAction() != STORES)
      revert('Invalid current action - expected STORES');
  }

  function isEmitting() private pure {

    if (currentAction() != EMITS)
      revert('Invalid current action - expected EMITS');
  }

  function isPaying() private pure {

    if (currentAction() != PAYS)
      revert('Invalid current action - expected PAYS');
  }

  function startBuffer() private pure {

    assembly {
      let ptr := msize()
      mstore(0xc0, ptr)
      mstore(ptr, 0)            // temp ptr
      mstore(add(0x20, ptr), 0) // buffer length
      mstore(0x40, add(0x40, ptr))
      mstore(0x100, 1)
    }
  }

  function validStoreBuff() private pure {

    if (buffPtr() == bytes32(0))
      startBuffer();

    if (stored() != 0 || currentAction() == STORES)
      revert('Duplicate request - stores');
  }

  function validEmitBuff() private pure {

    if (buffPtr() == bytes32(0))
      startBuffer();

    if (emitted() != 0 || currentAction() == EMITS)
      revert('Duplicate request - emits');
  }

  function validPayBuff() private pure {

    if (buffPtr() == bytes32(0))
      startBuffer();

    if (paid() != 0 || currentAction() == PAYS)
      revert('Duplicate request - pays');
  }

  function none() private pure { }



  function execID() internal pure returns (bytes32 exec_id) {

    assembly { exec_id := mload(0x80) }
    require(exec_id != bytes32(0), "Execution id overwritten, or not read");
  }

  function sender() internal pure returns (address addr) {

    assembly { addr := mload(0xa0) }
    require(addr != address(0), "Sender address overwritten, or not read");
  }


  function read(bytes32 _location) internal view returns (bytes32 data) {

    data = keccak256(_location, execID());
    assembly { data := sload(data) }
  }


  bytes4 internal constant EMITS = bytes4(keccak256('Emit((bytes32[],bytes)[])'));
  bytes4 internal constant STORES = bytes4(keccak256('Store(bytes32[])'));
  bytes4 internal constant PAYS = bytes4(keccak256('Pay(bytes32[])'));
  bytes4 internal constant THROWS = bytes4(keccak256('Error(string)'));

  enum NextFunction {
    INVALID, NONE, STORE_DEST, VAL_SET, VAL_INC, VAL_DEC, EMIT_LOG, PAY_DEST, PAY_AMT
  }

  function validStoreDest() private pure {

    if (expected() != NextFunction.STORE_DEST)
      revert('Unexpected function order - expected storage destination to be pushed');

    isStoring();
  }

  function validStoreVal() private pure {

    if (
      expected() != NextFunction.VAL_SET &&
      expected() != NextFunction.VAL_INC &&
      expected() != NextFunction.VAL_DEC
    ) revert('Unexpected function order - expected storage value to be pushed');

    isStoring();
  }

  function validPayDest() private pure {

    if (expected() != NextFunction.PAY_DEST)
      revert('Unexpected function order - expected payment destination to be pushed');

    isPaying();
  }

  function validPayAmt() private pure {

    if (expected() != NextFunction.PAY_AMT)
      revert('Unexpected function order - expected payment amount to be pushed');

    isPaying();
  }

  function validEvent() private pure {

    if (expected() != NextFunction.EMIT_LOG)
      revert('Unexpected function order - expected event to be pushed');

    isEmitting();
  }

  function storing() conditions(validStoreBuff, isStoring) internal pure {

    bytes4 action_req = STORES;
    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), action_req)
      mstore(add(0x24, add(ptr, mload(ptr))), 0)
      mstore(ptr, add(0x24, mload(ptr)))
      mstore(0xe0, action_req)
      mstore(0x100, 2)
      mstore(sub(ptr, 0x20), add(ptr, mload(ptr)))
    }
    setFreeMem();
  }

  function set(bytes32 _field) conditions(validStoreDest, validStoreVal) internal pure returns (bytes32) {

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), _field)
      mstore(ptr, add(0x20, mload(ptr)))
      mstore(0x100, 3)
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      mstore(0x120, add(1, mload(0x120)))
    }
    setFreeMem();
    return _field;
  }

  function to(bytes32, bytes32 _val) conditions(validStoreVal, validStoreDest) internal pure {

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), _val)
      mstore(ptr, add(0x20, mload(ptr)))
      mstore(0x100, 2)
    }
    setFreeMem();
  }

  function to(bytes32 _field, uint _val) internal pure {

    to(_field, bytes32(_val));
  }

  function to(bytes32 _field, address _val) internal pure {

    to(_field, bytes32(_val));
  }

  function to(bytes32 _field, bool _val) internal pure {

    to(
      _field,
      _val ? bytes32(1) : bytes32(0)
    );
  }

  function increase(bytes32 _field) conditions(validStoreDest, validStoreVal) internal view returns (bytes32 val) {

    val = keccak256(_field, execID());
    assembly {
      val := sload(val)
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), _field)
      mstore(ptr, add(0x20, mload(ptr)))
      mstore(0x100, 4)
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      mstore(0x120, add(1, mload(0x120)))
    }
    setFreeMem();
    return val;
  }

  function decrease(bytes32 _field) conditions(validStoreDest, validStoreVal) internal view returns (bytes32 val) {

    val = keccak256(_field, execID());
    assembly {
      val := sload(val)
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), _field)
      mstore(ptr, add(0x20, mload(ptr)))
      mstore(0x100, 5)
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      mstore(0x120, add(1, mload(0x120)))
    }
    setFreeMem();
    return val;
  }

  function by(bytes32 _val, uint _amt) conditions(validStoreVal, validStoreDest) internal pure {

    if (expected() == NextFunction.VAL_INC)
      _amt = _amt.add(uint(_val));
    else if (expected() == NextFunction.VAL_DEC)
      _amt = uint(_val).sub(_amt);
    else
      revert('Expected VAL_INC or VAL_DEC');

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), _amt)
      mstore(ptr, add(0x20, mload(ptr)))
      mstore(0x100, 2)
    }
    setFreeMem();
  }

  function byMaximum(bytes32 _val, uint _amt) conditions(validStoreVal, validStoreDest) internal pure {

    if (expected() == NextFunction.VAL_DEC) {
      if (_amt >= uint(_val))
        _amt = 0;
      else
        _amt = uint(_val).sub(_amt);
    } else {
      revert('Expected VAL_DEC');
    }

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), _amt)
      mstore(ptr, add(0x20, mload(ptr)))
      mstore(0x100, 2)
    }
    setFreeMem();
  }

  function emitting() conditions(validEmitBuff, isEmitting) internal pure {

    bytes4 action_req = EMITS;
    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), action_req)
      mstore(add(0x24, add(ptr, mload(ptr))), 0)
      mstore(ptr, add(0x24, mload(ptr)))
      mstore(0xe0, action_req)
      mstore(0x100, 6)
      mstore(sub(ptr, 0x20), add(ptr, mload(ptr)))
    }
    setFreeMem();
  }

  function log(bytes32 _data) conditions(validEvent, validEvent) internal pure {

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), 0)
      if eq(_data, 0) {
        mstore(add(0x40, add(ptr, mload(ptr))), 0)
        mstore(ptr, add(0x40, mload(ptr)))
      }
      if iszero(eq(_data, 0)) {
        mstore(add(0x40, add(ptr, mload(ptr))), 0x20)
        mstore(add(0x60, add(ptr, mload(ptr))), _data)
        mstore(ptr, add(0x60, mload(ptr)))
      }
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      mstore(0x140, add(1, mload(0x140)))
    }
    setFreeMem();
  }

  function log(bytes32[1] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), 1)
      mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
      if eq(_data, 0) {
        mstore(add(0x60, add(ptr, mload(ptr))), 0)
        mstore(ptr, add(0x60, mload(ptr)))
      }
      if iszero(eq(_data, 0)) {
        mstore(add(0x60, add(ptr, mload(ptr))), 0x20)
        mstore(add(0x80, add(ptr, mload(ptr))), _data)
        mstore(ptr, add(0x80, mload(ptr)))
      }
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      mstore(0x140, add(1, mload(0x140)))
    }
    setFreeMem();
  }

  function log(bytes32[2] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), 2)
      mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
      mstore(add(0x60, add(ptr, mload(ptr))), mload(add(0x20, _topics)))
      if eq(_data, 0) {
        mstore(add(0x80, add(ptr, mload(ptr))), 0)
        mstore(ptr, add(0x80, mload(ptr)))
      }
      if iszero(eq(_data, 0)) {
        mstore(add(0x80, add(ptr, mload(ptr))), 0x20)
        mstore(add(0xa0, add(ptr, mload(ptr))), _data)
        mstore(ptr, add(0xa0, mload(ptr)))
      }
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      mstore(0x140, add(1, mload(0x140)))
    }
    setFreeMem();
  }

  function log(bytes32[3] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), 3)
      mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
      mstore(add(0x60, add(ptr, mload(ptr))), mload(add(0x20, _topics)))
      mstore(add(0x80, add(ptr, mload(ptr))), mload(add(0x40, _topics)))
      if eq(_data, 0) {
        mstore(add(0xa0, add(ptr, mload(ptr))), 0)
        mstore(ptr, add(0xa0, mload(ptr)))
      }
      if iszero(eq(_data, 0)) {
        mstore(add(0xa0, add(ptr, mload(ptr))), 0x20)
        mstore(add(0xc0, add(ptr, mload(ptr))), _data)
        mstore(ptr, add(0xc0, mload(ptr)))
      }
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      mstore(0x140, add(1, mload(0x140)))
    }
    setFreeMem();
  }

  function log(bytes32[4] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), 4)
      mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
      mstore(add(0x60, add(ptr, mload(ptr))), mload(add(0x20, _topics)))
      mstore(add(0x80, add(ptr, mload(ptr))), mload(add(0x40, _topics)))
      mstore(add(0xa0, add(ptr, mload(ptr))), mload(add(0x60, _topics)))
      if eq(_data, 0) {
        mstore(add(0xc0, add(ptr, mload(ptr))), 0)
        mstore(ptr, add(0xc0, mload(ptr)))
      }
      if iszero(eq(_data, 0)) {
        mstore(add(0xc0, add(ptr, mload(ptr))), 0x20)
        mstore(add(0xe0, add(ptr, mload(ptr))), _data)
        mstore(ptr, add(0xe0, mload(ptr)))
      }
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      mstore(0x140, add(1, mload(0x140)))
    }
    setFreeMem();
  }

  function paying() conditions(validPayBuff, isPaying) internal pure {

    bytes4 action_req = PAYS;
    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), action_req)
      mstore(add(0x24, add(ptr, mload(ptr))), 0)
      mstore(ptr, add(0x24, mload(ptr)))
      mstore(0xe0, action_req)
      mstore(0x100, 8)
      mstore(sub(ptr, 0x20), add(ptr, mload(ptr)))
    }
    setFreeMem();
  }

  function pay(uint _amount) conditions(validPayAmt, validPayDest) internal pure returns (uint) {

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), _amount)
      mstore(ptr, add(0x20, mload(ptr)))
      mstore(0x100, 7)
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      mstore(0x160, add(1, mload(0x160)))
    }
    setFreeMem();
    return _amount;
  }

  function toAcc(uint, address _dest) conditions(validPayDest, validPayAmt) internal pure {

    assembly {
      let ptr := add(0x20, mload(0xc0))
      mstore(add(0x20, add(ptr, mload(ptr))), _dest)
      mstore(ptr, add(0x20, mload(ptr)))
      mstore(0x100, 8)
    }
    setFreeMem();
  }

  function setFreeMem() private pure {

    assembly { mstore(0x40, msize) }
  }

  function expected() private pure returns (NextFunction next) {

    assembly { next := mload(0x100) }
  }

  function emitted() internal pure returns (uint num_emitted) {

    if (buffPtr() == bytes32(0))
      return 0;

    assembly { num_emitted := mload(0x140) }
  }

  function stored() internal pure returns (uint num_stored) {

    if (buffPtr() == bytes32(0))
      return 0;

    assembly { num_stored := mload(0x120) }
  }

  function paid() internal pure returns (uint num_paid) {

    if (buffPtr() == bytes32(0))
      return 0;

    assembly { num_paid := mload(0x160) }
  }
}

library ManageSale {


  using Contract for *;

  bytes32 internal constant CROWDSALE_CONFIGURED = keccak256("CrowdsaleConfigured(bytes32,bytes32,uint256)");

  bytes32 internal constant CROWDSALE_FINALIZED = keccak256("CrowdsaleFinalized(bytes32)");

  function CONFIGURE(bytes32 _exec_id, bytes32 _name) private pure returns (bytes32[3] memory)
    { return [CROWDSALE_CONFIGURED, _exec_id, _name]; }


  function FINALIZE(bytes32 _exec_id) private pure returns (bytes32[2] memory)
    { return [CROWDSALE_FINALIZED, _exec_id]; }


  function initializeCrowdsale() internal view {

    uint start_time = uint(Contract.read(SaleManager.startTime()));
    bytes32 token_name = Contract.read(SaleManager.tokenName());

    if (start_time < now)
      revert('crowdsale already started');
    if (token_name == 0)
      revert('token not init');

    Contract.storing();

    Contract.set(SaleManager.isConfigured()).to(true);

    Contract.emitting();

    Contract.log(CONFIGURE(Contract.execID(), token_name), bytes32(start_time));
  }

  function finalizeCrowdsale() internal view {

    if (Contract.read(SaleManager.isConfigured()) == 0)
      revert('crowdsale has not been configured');

    Contract.storing();

    Contract.set(SaleManager.isFinished()).to(true);

    Contract.emitting();

    Contract.log(FINALIZE(Contract.execID()), bytes32(0));
  }
}

library ConfigureSale {


  using Contract for *;
  using SafeMath for uint;

  bytes32 private constant TIER_MIN_UPDATE = keccak256("TierMinUpdate(bytes32,uint256,uint256)");

  bytes32 private constant CROWDSALE_TIERS_ADDED = keccak256("CrowdsaleTiersAdded(bytes32,uint256)");

  function MIN_UPDATE(bytes32 _exec_id, uint _idx) private pure returns (bytes32[3] memory)
    { return [TIER_MIN_UPDATE, _exec_id, bytes32(_idx)]; }


  function ADD_TIERS(bytes32 _exec_id) private pure returns (bytes32[2] memory)
    { return [CROWDSALE_TIERS_ADDED, _exec_id]; }


  function createCrowdsaleTiers(
    bytes32[] _tier_names, uint[] _tier_durations, uint[] _tier_prices, uint[] _tier_caps, uint[] _tier_minimums,
    bool[] _tier_modifiable, bool[] _tier_whitelisted
  ) internal view {

    if (
      _tier_names.length != _tier_durations.length
      || _tier_names.length != _tier_prices.length
      || _tier_names.length != _tier_caps.length
      || _tier_names.length != _tier_modifiable.length
      || _tier_names.length != _tier_whitelisted.length
      || _tier_names.length == 0
    ) revert("array length mismatch");

    uint durations_sum = uint(Contract.read(SaleManager.totalDuration()));
    uint num_tiers = uint(Contract.read(SaleManager.saleTierList()));

    Contract.storing();

    Contract.increase(SaleManager.saleTierList()).by(_tier_names.length);

    for (uint i = 0; i < _tier_names.length; i++) {
      if (
        _tier_caps[i] == 0 || _tier_prices[i] == 0 || _tier_durations[i] == 0
      ) revert("invalid tier vals");

      durations_sum = durations_sum.add(_tier_durations[i]);

      Contract.set(SaleManager.tierName(num_tiers + i)).to(_tier_names[i]);
      Contract.set(SaleManager.tierCap(num_tiers + i)).to(_tier_caps[i]);
      Contract.set(SaleManager.tierPrice(num_tiers + i)).to(_tier_prices[i]);
      Contract.set(SaleManager.tierDuration(num_tiers + i)).to(_tier_durations[i]);
      Contract.set(SaleManager.tierMin(num_tiers + i)).to(_tier_minimums[i]);
      Contract.set(SaleManager.tierModifiable(num_tiers + i)).to(_tier_modifiable[i]);
      Contract.set(SaleManager.tierWhitelisted(num_tiers + i)).to(_tier_whitelisted[i]);
    }
    Contract.set(SaleManager.totalDuration()).to(durations_sum);

    Contract.emitting();

    Contract.log(
      ADD_TIERS(Contract.execID()), bytes32(num_tiers.add(_tier_names.length))
    );
  }

  function whitelistMultiForTier(
    uint _tier_index, address[] _to_whitelist, uint[] _min_token_purchase, uint[] _max_purchase_amt
  ) internal view {

    if (
      _to_whitelist.length != _min_token_purchase.length
      || _to_whitelist.length != _max_purchase_amt.length
      || _to_whitelist.length == 0
    ) revert("mismatched input lengths");

    uint tier_whitelist_length = uint(Contract.read(SaleManager.tierWhitelist(_tier_index)));

    Contract.storing();

    for (uint i = 0; i < _to_whitelist.length; i++) {
      Contract.set(
        SaleManager.whitelistMinTok(_tier_index, _to_whitelist[i])
      ).to(_min_token_purchase[i]);
      Contract.set(
        SaleManager.whitelistMaxTok(_tier_index, _to_whitelist[i])
      ).to(_max_purchase_amt[i]);

      if (
        Contract.read(SaleManager.whitelistMinTok(_tier_index, _to_whitelist[i])) == 0 &&
        Contract.read(SaleManager.whitelistMaxTok(_tier_index, _to_whitelist[i])) == 0
      ) {
        Contract.set(
          bytes32(32 + (32 * tier_whitelist_length) + uint(SaleManager.tierWhitelist(_tier_index)))
        ).to(_to_whitelist[i]);
        tier_whitelist_length++;
      }
    }

    Contract.set(SaleManager.tierWhitelist(_tier_index)).to(tier_whitelist_length);
  }

  function updateTierDuration(uint _tier_index, uint _new_duration) internal view {

    if (_new_duration == 0)
      revert('invalid duration');

    uint starts_at = uint(Contract.read(SaleManager.startTime()));
    uint current_tier = uint(Contract.read(SaleManager.currentTier()));
    uint total_duration = uint(Contract.read(SaleManager.totalDuration()));
    uint cur_ends_at = uint(Contract.read(SaleManager.currentEndsAt()));
    uint previous_duration
      = uint(Contract.read(SaleManager.tierDuration(_tier_index)));

    current_tier = current_tier.sub(1);

    if (previous_duration == _new_duration)
      revert("duration unchanged");
    if (total_duration < previous_duration)
      revert("total duration invalid");
    if (uint(Contract.read(SaleManager.saleTierList())) <= _tier_index)
      revert("tier does not exist");
    if (current_tier > _tier_index)
      revert("tier has already completed");
    if (Contract.read(SaleManager.tierModifiable(_tier_index)) == 0)
      revert("tier duration not modifiable");

    Contract.storing();

    if (_tier_index == 0) {
      if (now >= starts_at)
        revert("cannot modify initial tier once sale has started");

      Contract.set(SaleManager.currentEndsAt()).to(_new_duration.add(starts_at));
    } else if (_tier_index > current_tier) {
      if (_tier_index - current_tier == 1 && now >= cur_ends_at)
        revert("cannot modify tier after it has begun");

      for (uint i = current_tier + 1; i < _tier_index; i++)
        cur_ends_at = cur_ends_at.add(uint(Contract.read(SaleManager.tierDuration(i))));

      if (cur_ends_at < now)
        revert("cannot modify current tier");
    } else {
      revert('cannot update tier');
    }

    if (previous_duration > _new_duration) // Subtracting from total_duration
      total_duration = total_duration.sub(previous_duration - _new_duration);
    else // Adding to total_duration
      total_duration = total_duration.add(_new_duration - previous_duration);

    Contract.set(SaleManager.tierDuration(_tier_index)).to(_new_duration);

    Contract.set(SaleManager.totalDuration()).to(total_duration);
  }

  function updateTierMinimum(uint _tier_index, uint _new_minimum) internal view {

    if (uint(Contract.read(SaleManager.saleTierList())) <= _tier_index)
      revert('tier does not exist');
    if (Contract.read(SaleManager.tierModifiable(_tier_index)) == 0)
      revert('tier mincap not modifiable');

    Contract.storing();

    Contract.set(SaleManager.tierMin(_tier_index)).to(_new_minimum);

    Contract.emitting();

    Contract.log(
      MIN_UPDATE(Contract.execID(), _tier_index), bytes32(_new_minimum)
    );
  }
}

library SaleManager {


  using Contract for *;


  function admin() internal pure returns (bytes32)
    { return keccak256('sale_admin'); }


  function isConfigured() internal pure returns (bytes32)
    { return keccak256("sale_is_configured"); }


  function isFinished() internal pure returns (bytes32)
    { return keccak256("sale_is_completed"); }


  function startTime() internal pure returns (bytes32)
    { return keccak256("sale_start_time"); }


  function totalDuration() internal pure returns (bytes32)
    { return keccak256("sale_total_duration"); }



  function saleTierList() internal pure returns (bytes32)
    { return keccak256("sale_tier_list"); }


  function tierName(uint _idx) internal pure returns (bytes32)
    { return keccak256(_idx, "name", saleTierList()); }


  function tierCap(uint _idx) internal pure returns (bytes32)
    { return keccak256(_idx, "cap", saleTierList()); }


  function tierPrice(uint _idx) internal pure returns (bytes32)
    { return keccak256(_idx, "price", saleTierList()); }


  function tierMin(uint _idx) internal pure returns (bytes32)
    { return keccak256(_idx, "minimum", saleTierList()); }


  function tierDuration(uint _idx) internal pure returns (bytes32)
    { return keccak256(_idx, "duration", saleTierList()); }


  function tierModifiable(uint _idx) internal pure returns (bytes32)
    { return keccak256(_idx, "mod_stat", saleTierList()); }


  function tierWhitelisted(uint _idx) internal pure returns (bytes32)
    { return keccak256(_idx, "wl_stat", saleTierList()); }


  function currentTier() internal pure returns (bytes32)
    { return keccak256("sale_current_tier"); }


  function currentEndsAt() internal pure returns (bytes32)
    { return keccak256("current_tier_ends_at"); }



  function tierWhitelist(uint _idx) internal pure returns (bytes32)
    { return keccak256(_idx, "tier_whitelists"); }


  function whitelistMaxTok(uint _idx, address _spender) internal pure returns (bytes32)
    { return keccak256(_spender, "max_tok", tierWhitelist(_idx)); }


  function whitelistMinTok(uint _idx, address _spender) internal pure returns (bytes32)
    { return keccak256(_spender, "min_tok", tierWhitelist(_idx)); }



  function tokenName() internal pure returns (bytes32)
    { return keccak256("token_name"); }


  function tokenSymbol() internal pure returns (bytes32)
    { return keccak256("token_symbol"); }


  function tokenDecimals() internal pure returns (bytes32)
    { return keccak256("token_decimals"); }


  function tokenTotalSupply() internal pure returns (bytes32)
    { return keccak256("token_total_supply"); }


  bytes32 internal constant TOKEN_BALANCES = keccak256("token_balances");

  function balances(address _owner) internal pure returns (bytes32)
    { return keccak256(_owner, TOKEN_BALANCES); }


  function tokensUnlocked() internal pure returns (bytes32)
    { return keccak256('sale_tokens_unlocked'); }



  function onlyAdminAndNotInit() internal view {

    if (address(Contract.read(admin())) != Contract.sender())
      revert('sender is not admin');

    if (Contract.read(isConfigured()) != 0)
      revert('sale has already been configured');
  }

  function onlyAdminAndNotFinal() internal view {

    if (address(Contract.read(admin())) != Contract.sender())
      revert('sender is not admin');

    if (Contract.read(isFinished()) != 0)
      revert('sale has already been finalized');
  }

  function onlyAdmin() internal view {

    if (address(Contract.read(admin())) != Contract.sender())
      revert('sender is not admin');
  }

  function emitAndStore() internal pure {

    if (Contract.emitted() == 0 || Contract.stored() == 0)
      revert('invalid state change');
  }

  function onlyStores() internal pure {

    if (Contract.paid() != 0 || Contract.emitted() != 0)
      revert('expected only storage');

    if (Contract.stored() == 0)
      revert('expected storage');
  }


  function createCrowdsaleTiers(
    bytes32[] _tier_names, uint[] _tier_durations, uint[] _tier_prices, uint[] _tier_caps, uint[] _tier_minimums,
    bool[] _tier_modifiable, bool[] _tier_whitelisted
  ) external view {

    Contract.authorize(msg.sender);
    Contract.checks(onlyAdminAndNotInit);
    ConfigureSale.createCrowdsaleTiers(
      _tier_names, _tier_durations, _tier_prices,
      _tier_caps, _tier_minimums, _tier_modifiable, _tier_whitelisted
    );
    Contract.checks(emitAndStore);
    Contract.commit();
  }

  function whitelistMultiForTier(
    uint _tier_index, address[] _to_whitelist, uint[] _min_token_purchase, uint[] _max_purchase_amt
  ) external view {

    Contract.authorize(msg.sender);
    Contract.checks(onlyAdmin);
    ConfigureSale.whitelistMultiForTier(
      _tier_index, _to_whitelist, _min_token_purchase, _max_purchase_amt
    );
    Contract.checks(onlyStores);
    Contract.commit();
  }

  function updateTierDuration(uint _tier_index, uint _new_duration) external view {

    Contract.authorize(msg.sender);
    Contract.checks(onlyAdminAndNotFinal);
    ConfigureSale.updateTierDuration(_tier_index, _new_duration);
    Contract.checks(onlyStores);
    Contract.commit();
  }

  function updateTierMinimum(uint _tier_index, uint _new_minimum) external view {

    Contract.authorize(msg.sender);
    Contract.checks(onlyAdminAndNotFinal);
    ConfigureSale.updateTierMinimum(_tier_index, _new_minimum);
    Contract.checks(emitAndStore);
    Contract.commit();
  }

  function initializeCrowdsale() external view {

    Contract.authorize(msg.sender);
    Contract.checks(onlyAdminAndNotInit);
    ManageSale.initializeCrowdsale();
    Contract.checks(emitAndStore);
    Contract.commit();
  }

  function finalizeCrowdsale() external view {

    Contract.authorize(msg.sender);
    Contract.checks(onlyAdminAndNotFinal);
    ManageSale.finalizeCrowdsale();
    Contract.checks(emitAndStore);
    Contract.commit();
  }
}