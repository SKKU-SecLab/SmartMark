
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

library ArrayUtils {


  function toBytes4Arr(bytes32[] memory _arr) internal pure returns (bytes4[] memory _conv) {

    assembly { _conv := _arr }
  }

  function toAddressArr(bytes32[] memory _arr) internal pure returns (address[] memory _conv) {

    assembly { _conv := _arr }
  }

  function toUintArr(bytes32[] memory _arr) internal pure returns (uint[] memory _conv) {

    assembly { _conv := _arr }
  }
}

interface GetterInterface {

  function read(bytes32 exec_id, bytes32 location) external view returns (bytes32 data);

  function readMulti(bytes32 exec_id, bytes32[] locations) external view returns (bytes32[] data);

}

library MintedCappedIdx {


  using Contract for *;
  using SafeMath for uint;
  using ArrayUtils for bytes32[];

  bytes32 internal constant EXEC_PERMISSIONS = keccak256('script_exec_permissions');

  function execPermissions(address _exec) internal pure returns (bytes32)
    { return keccak256(_exec, EXEC_PERMISSIONS); }



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


  function tokensSold() internal pure returns (bytes32)
    { return keccak256("sale_tokens_sold"); }


  function contributors() internal pure returns (bytes32)
    { return keccak256("sale_contributors"); }


  function hasContributed(address _purchaser) internal pure returns (bytes32)
    { return keccak256(_purchaser, contributors()); }



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


  function currentTokensRemaining() internal pure returns (bytes32)
    { return keccak256("current_tier_tokens_remaining"); }



  function wallet() internal pure returns (bytes32)
    { return keccak256("sale_destination_wallet"); }


  function totalWeiRaised() internal pure returns (bytes32)
    { return keccak256("sale_tot_wei_raised"); }



  function tierWhitelist(uint _idx) internal pure returns (bytes32)
    { return keccak256(_idx, "tier_whitelists"); }


  function whitelistMinTok(uint _idx, address _spender) internal pure returns (bytes32)
    { return keccak256(_spender, "min_tok", tierWhitelist(_idx)); }


  function whitelistMaxTok(uint _idx, address _spender) internal pure returns (bytes32)
    { return keccak256(_spender, "max_tok", tierWhitelist(_idx)); }



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


  bytes32 internal constant TOKEN_ALLOWANCES = keccak256("token_allowances");

  function allowed(address _owner, address _spender) internal pure returns (bytes32)
    { return keccak256(_spender, keccak256(_owner, TOKEN_ALLOWANCES)); }


  bytes32 internal constant TOKEN_TRANSFER_AGENTS = keccak256("token_transfer_agents");

  function transferAgents(address _agent) internal pure returns (bytes32)
    { return keccak256(_agent, TOKEN_TRANSFER_AGENTS); }


  function tokensUnlocked() internal pure returns (bytes32)
    { return keccak256('sale_tokens_unlocked'); }



  function reservedDestinations() internal pure returns (bytes32)
    { return keccak256("reserved_token_dest_list"); }


  function destIndex(address _destination) internal pure returns (bytes32)
    { return keccak256(_destination, "index", reservedDestinations()); }


  function destTokens(address _destination) internal pure returns (bytes32)
    { return keccak256(_destination, "numtokens", reservedDestinations()); }


  function destPercent(address _destination) internal pure returns (bytes32)
    { return keccak256(_destination, "numpercent", reservedDestinations()); }


  function destPrecision(address _destination) internal pure returns (bytes32)
    { return keccak256(_destination, "precision", reservedDestinations()); }


  function init(
    address _team_wallet,
    uint _start_time,
    bytes32 _initial_tier_name,
    uint _initial_tier_price,
    uint _initial_tier_duration,
    uint _initial_tier_token_sell_cap,
    uint _initial_tier_min_purchase,
    bool _initial_tier_is_whitelisted,
    bool _initial_tier_duration_is_modifiable,
    address _admin
  ) external view {

    Contract.initialize();

    if (
      _team_wallet == 0
      || _initial_tier_price == 0
      || _start_time < now
      || _start_time + _initial_tier_duration <= _start_time
      || _initial_tier_token_sell_cap == 0
      || _admin == address(0)
    ) revert('improper initialization');

    Contract.storing();
    Contract.set(execPermissions(msg.sender)).to(true);
    Contract.set(admin()).to(_admin);
    Contract.set(wallet()).to(_team_wallet);
    Contract.set(totalDuration()).to(_initial_tier_duration);
    Contract.set(startTime()).to(_start_time);
    Contract.set(saleTierList()).to(uint(1));
    Contract.set(tierName(uint(0))).to(_initial_tier_name);
    Contract.set(tierCap(uint(0))).to(_initial_tier_token_sell_cap);
    Contract.set(tierPrice(uint(0))).to(_initial_tier_price);
    Contract.set(tierDuration(uint(0))).to(_initial_tier_duration);
    Contract.set(tierMin(uint(0))).to(_initial_tier_min_purchase);
    Contract.set(tierModifiable(uint(0))).to(_initial_tier_duration_is_modifiable);
    Contract.set(tierWhitelisted(uint(0))).to(_initial_tier_is_whitelisted);

    Contract.set(currentTier()).to(uint(1));
    Contract.set(currentEndsAt()).to(_initial_tier_duration.add(_start_time));
    Contract.set(currentTokensRemaining()).to(_initial_tier_token_sell_cap);

    Contract.commit();
  }


  function getAdmin(address _storage, bytes32 _exec_id) external view returns (address)
    { return address(GetterInterface(_storage).read(_exec_id, admin())); }


  function getCrowdsaleInfo(address _storage, bytes32 _exec_id) external view
  returns (uint wei_raised, address team_wallet, bool is_initialized, bool is_finalized) {


    GetterInterface target = GetterInterface(_storage);

    bytes32[] memory arr_indices = new bytes32[](4);

    arr_indices[0] = totalWeiRaised();
    arr_indices[1] = wallet();
    arr_indices[2] = isConfigured();
    arr_indices[3] = isFinished();

    bytes32[] memory read_values = target.readMulti(_exec_id, arr_indices);

    wei_raised = uint(read_values[0]);
    team_wallet = address(read_values[1]);
    is_initialized = (read_values[2] == 0 ? false : true);
    is_finalized = (read_values[3] == 0 ? false : true);
  }

  function isCrowdsaleFull(address _storage, bytes32 _exec_id) external view returns (bool is_crowdsale_full, uint max_sellable) {

    GetterInterface target = GetterInterface(_storage);

    bytes32[] memory initial_arr = new bytes32[](2);
    initial_arr[0] = saleTierList();
    initial_arr[1] = tokensSold();
    uint[] memory read_values = target.readMulti(_exec_id, initial_arr).toUintArr();

    uint num_tiers = read_values[0];
    uint _tokens_sold = read_values[1];

    bytes32[] memory arr_indices = new bytes32[](num_tiers);
    for (uint i = 0; i < num_tiers; i++)
      arr_indices[i] = tierCap(i);

    read_values = target.readMulti(_exec_id, arr_indices).toUintArr();
    assert(read_values.length == num_tiers);

    for (i = 0; i < read_values.length; i++)
      max_sellable += read_values[i];

    is_crowdsale_full = (_tokens_sold >= max_sellable ? true : false);
  }

  function getCrowdsaleUniqueBuyers(address _storage, bytes32 _exec_id) external view returns (uint)
    { return uint(GetterInterface(_storage).read(_exec_id, contributors())); }


  function getCrowdsaleStartAndEndTimes(address _storage, bytes32 _exec_id) external view returns (uint start_time, uint end_time) {

    bytes32[] memory arr_indices = new bytes32[](2);
    arr_indices[0] = startTime();
    arr_indices[1] = totalDuration();

    uint[] memory read_values = GetterInterface(_storage).readMulti(_exec_id, arr_indices).toUintArr();

    start_time = read_values[0];
    end_time = start_time + read_values[1];
  }

  function getCurrentTierInfo(address _storage, bytes32 _exec_id) external view
  returns (bytes32 tier_name, uint tier_index, uint tier_ends_at, uint tier_tokens_remaining, uint tier_price, uint tier_min, bool duration_is_modifiable, bool is_whitelisted) {


    bytes32[] memory initial_arr = new bytes32[](4);
    initial_arr[0] = currentEndsAt();
    initial_arr[1] = currentTier();
    initial_arr[2] = currentTokensRemaining();
    initial_arr[3] = saleTierList();
    uint[] memory read_values = GetterInterface(_storage).readMulti(_exec_id, initial_arr).toUintArr();
    assert(read_values.length == 4);

    if (read_values[1] == 0)
      return;

    tier_ends_at = read_values[0];
    tier_index = read_values[1] - 1;
    tier_tokens_remaining = read_values[2];
    uint num_tiers = read_values[3];
    bool updated_tier;

    while (now >= tier_ends_at && ++tier_index < num_tiers) {
      tier_ends_at += uint(GetterInterface(_storage).read(_exec_id, tierDuration(tier_index)));
      updated_tier = true;
    }

    if (tier_index >= num_tiers)
      return (0, 0, 0, 0, 0, 0, false, false);

    initial_arr = new bytes32[](6);
    initial_arr[0] = tierName(tier_index);
    initial_arr[1] = tierPrice(tier_index);
    initial_arr[2] = tierModifiable(tier_index);
    initial_arr[3] = tierWhitelisted(tier_index);
    initial_arr[4] = tierMin(tier_index);
    initial_arr[5] = tierCap(tier_index);

    read_values = GetterInterface(_storage).readMulti(_exec_id, initial_arr).toUintArr();

    assert(read_values.length == 6);

    tier_name = bytes32(read_values[0]);
    tier_price = read_values[1];
    duration_is_modifiable = (read_values[2] == 0 ? false : true);
    is_whitelisted = (read_values[3] == 0 ? false : true);
    tier_min = read_values[4];
    if (updated_tier)
      tier_tokens_remaining = read_values[5];
  }

  function getCrowdsaleTier(address _storage, bytes32 _exec_id, uint _index) external view
  returns (bytes32 tier_name, uint tier_sell_cap, uint tier_price, uint tier_min, uint tier_duration, bool duration_is_modifiable, bool is_whitelisted) {

    GetterInterface target = GetterInterface(_storage);

    bytes32[] memory arr_indices = new bytes32[](7);
    arr_indices[0] = tierName(_index);
    arr_indices[1] = tierCap(_index);
    arr_indices[2] = tierPrice(_index);
    arr_indices[3] = tierDuration(_index);
    arr_indices[4] = tierModifiable(_index);
    arr_indices[5] = tierWhitelisted(_index);
    arr_indices[6] = tierMin(_index);
    bytes32[] memory read_values = target.readMulti(_exec_id, arr_indices);
    assert(read_values.length == 7);

    tier_name = read_values[0];
    tier_sell_cap = uint(read_values[1]);
    tier_price = uint(read_values[2]);
    tier_duration = uint(read_values[3]);
    duration_is_modifiable = (read_values[4] == 0 ? false : true);
    is_whitelisted = (read_values[5] == 0 ? false : true);
    tier_min = uint(read_values[6]);
  }

  function getCrowdsaleMaxRaise(address _storage, bytes32 _exec_id) external view returns (uint wei_raise_cap, uint total_sell_cap) {

    GetterInterface target = GetterInterface(_storage);

    bytes32[] memory arr_indices = new bytes32[](3);
    arr_indices[0] = saleTierList();
    arr_indices[1] = tokenDecimals();
    arr_indices[2] = tokenName();

    uint[] memory read_values = target.readMulti(_exec_id, arr_indices).toUintArr();
    assert(read_values.length == 3);

    uint num_tiers = read_values[0];
    uint num_decimals = read_values[1];

    if (read_values[2] == 0)
      return (0, 0);

    bytes32[] memory last_arr = new bytes32[](2 * num_tiers);
    for (uint i = 0; i < 2 * num_tiers; i += 2) {
      last_arr[i] = tierCap(i / 2);
      last_arr[i + 1] = tierPrice(i / 2);
    }

    read_values = target.readMulti(_exec_id, last_arr).toUintArr();
    assert(read_values.length == 2 * num_tiers);

    for (i = 0; i < read_values.length; i+=2) {
      total_sell_cap += read_values[i];
      wei_raise_cap += (read_values[i] * read_values[i + 1]) / (10 ** num_decimals);
    }
  }

  function getCrowdsaleTierList(address _storage, bytes32 _exec_id) external view returns (bytes32[] memory crowdsale_tiers) {

    GetterInterface target = GetterInterface(_storage);
    uint list_length = uint(target.read(_exec_id, saleTierList()));

    bytes32[] memory arr_indices = new bytes32[](list_length);
    for (uint i = 0; i < list_length; i++)
      arr_indices[i] = tierName(i);

    crowdsale_tiers = target.readMulti(_exec_id, arr_indices);
  }

  function getTierStartAndEndDates(address _storage, bytes32 _exec_id, uint _index) external view returns (uint tier_start, uint tier_end) {

    GetterInterface target = GetterInterface(_storage);

    bytes32[] memory arr_indices = new bytes32[](3 + _index);

    arr_indices[0] = saleTierList();
    arr_indices[1] = startTime();

    for (uint i = 0; i <= _index; i++)
      arr_indices[2 + i] = tierDuration(i);

    uint[] memory read_values = target.readMulti(_exec_id, arr_indices).toUintArr();
    assert(read_values.length == 3 + _index);

    if (read_values[0] <= _index)
      return (0, 0);

    tier_start = read_values[1];
    for (i = 0; i < _index; i++)
      tier_start += read_values[2 + i];

    tier_end = tier_start + read_values[read_values.length - 1];
  }

  function getTokensSold(address _storage, bytes32 _exec_id) external view returns (uint)
    { return uint(GetterInterface(_storage).read(_exec_id, tokensSold())); }


  function getWhitelistStatus(address _storage, bytes32 _exec_id, uint _tier_index, address _buyer) external view
  returns (uint minimum_purchase_amt, uint max_tokens_remaining) {

    GetterInterface target = GetterInterface(_storage);

    bytes32[] memory arr_indices = new bytes32[](2);
    arr_indices[0] = whitelistMinTok(_tier_index, _buyer);
    arr_indices[1] = whitelistMaxTok(_tier_index, _buyer);

    uint[] memory read_values = target.readMulti(_exec_id, arr_indices).toUintArr();
    assert(read_values.length == 2);

    minimum_purchase_amt = read_values[0];
    max_tokens_remaining = read_values[1];
  }

  function getTierWhitelist(address _storage, bytes32 _exec_id, uint _tier_index) external view returns (uint num_whitelisted, address[] memory whitelist) {

    num_whitelisted = uint(GetterInterface(_storage).read(_exec_id, tierWhitelist(_tier_index)));

    if (num_whitelisted == 0)
      return;

    bytes32[] memory arr_indices = new bytes32[](num_whitelisted);
    for (uint i = 0; i < num_whitelisted; i++)
      arr_indices[i] = bytes32(32 + (32 * i) + uint(tierWhitelist(_tier_index)));

    whitelist = GetterInterface(_storage).readMulti(_exec_id, arr_indices).toAddressArr();
  }


  function balanceOf(address _storage, bytes32 _exec_id, address _owner) external view returns (uint)
    { return uint(GetterInterface(_storage).read(_exec_id, balances(_owner))); }


  function allowance(address _storage, bytes32 _exec_id, address _owner, address _spender) external view returns (uint)
    { return uint(GetterInterface(_storage).read(_exec_id, allowed(_owner, _spender))); }


  function decimals(address _storage, bytes32 _exec_id) external view returns (uint)
    { return uint(GetterInterface(_storage).read(_exec_id, tokenDecimals())); }


  function totalSupply(address _storage, bytes32 _exec_id) external view returns (uint)
    { return uint(GetterInterface(_storage).read(_exec_id, tokenTotalSupply())); }


  function name(address _storage, bytes32 _exec_id) external view returns (bytes32)
    { return GetterInterface(_storage).read(_exec_id, tokenName()); }


  function symbol(address _storage, bytes32 _exec_id) external view returns (bytes32)
    { return GetterInterface(_storage).read(_exec_id, tokenSymbol()); }


  function getTokenInfo(address _storage, bytes32 _exec_id) external view
  returns (bytes32 token_name, bytes32 token_symbol, uint token_decimals, uint total_supply) {

    bytes32[] memory seed_arr = new bytes32[](4);

    seed_arr[0] = tokenName();
    seed_arr[1] = tokenSymbol();
    seed_arr[2] = tokenDecimals();
    seed_arr[3] = tokenTotalSupply();

    bytes32[] memory values_arr = GetterInterface(_storage).readMulti(_exec_id, seed_arr);

    token_name = values_arr[0];
    token_symbol = values_arr[1];
    token_decimals = uint(values_arr[2]);
    total_supply = uint(values_arr[3]);
  }

  function getTransferAgentStatus(address _storage, bytes32 _exec_id, address _agent) external view returns (bool)
    { return GetterInterface(_storage).read(_exec_id, transferAgents(_agent)) != 0 ? true : false; }


  function getReservedTokenDestinationList(address _storage, bytes32 _exec_id) external view
  returns (uint num_destinations, address[] reserved_destinations) {

    num_destinations = uint(GetterInterface(_storage).read(_exec_id, reservedDestinations()));

    if (num_destinations == 0)
      return (num_destinations, reserved_destinations);


    bytes32[] memory arr_indices = new bytes32[](num_destinations);
    for (uint i = 1; i <= num_destinations; i++)
      arr_indices[i - 1] = bytes32((32 * i) + uint(reservedDestinations()));

    reserved_destinations = GetterInterface(_storage).readMulti(_exec_id, arr_indices).toAddressArr();
  }

  function getReservedDestinationInfo(address _storage, bytes32 _exec_id, address _destination) external view
  returns (uint destination_list_index, uint num_tokens, uint num_percent, uint percent_decimals) {

    bytes32[] memory arr_indices = new bytes32[](4);
    arr_indices[0] = destIndex(_destination);
    arr_indices[1] = destTokens(_destination);
    arr_indices[2] = destPercent(_destination);
    arr_indices[3] = destPrecision(_destination);

    bytes32[] memory read_values = GetterInterface(_storage).readMulti(_exec_id, arr_indices);

    destination_list_index = uint(read_values[0]);
    if (destination_list_index == 0)
      return;
    destination_list_index--;
    num_tokens = uint(read_values[1]);
    num_percent = uint(read_values[2]);
    percent_decimals = uint(read_values[3]);
  }
}