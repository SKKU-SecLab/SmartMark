
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

interface GetterInterface {

  function read(bytes32 exec_id, bytes32 location) external view returns (bytes32 data);

  function readMulti(bytes32 exec_id, bytes32[] locations) external view returns (bytes32[] data);

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

library DutchCrowdsaleIdx {


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


  function burnExcess() internal pure returns (bytes32)
    { return keccak256("burn_excess_unsold"); }


  function startTime() internal pure returns (bytes32)
    { return keccak256("sale_start_time"); }


  function totalDuration() internal pure returns (bytes32)
    { return keccak256("sale_total_duration"); }


  function tokensRemaining() internal pure returns (bytes32)
    { return keccak256("sale_tokens_remaining"); }


  function maxSellCap() internal pure returns (bytes32)
    { return keccak256("token_sell_cap"); }


  function startRate() internal pure returns (bytes32)
    { return keccak256("sale_start_rate"); }


  function endRate() internal pure returns (bytes32)
    { return keccak256("sale_end_rate"); }


  function tokensSold() internal pure returns (bytes32)
    { return keccak256("sale_tokens_sold"); }


  function globalMinPurchaseAmt() internal pure returns (bytes32)
    { return keccak256("sale_min_purchase_amt"); }


  function contributors() internal pure returns (bytes32)
    { return keccak256("sale_contributors"); }


  function hasContributed(address _purchaser) internal pure returns (bytes32)
    { return keccak256(_purchaser, contributors()); }



  function wallet() internal pure returns (bytes32)
    { return keccak256("sale_destination_wallet"); }


  function totalWeiRaised() internal pure returns (bytes32)
    { return keccak256("sale_tot_wei_raised"); }



  function isWhitelisted() internal pure returns (bytes32)
    { return keccak256('sale_is_whitelisted'); }


  function saleWhitelist() internal pure returns (bytes32)
    { return keccak256("sale_whitelist"); }


  function whitelistMaxTok(address _spender) internal pure returns (bytes32)
    { return keccak256(_spender, "max_tok", saleWhitelist()); }


  function whitelistMinTok(address _spender) internal pure returns (bytes32)
    { return keccak256(_spender, "min_tok", saleWhitelist()); }



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



  function init(
    address _wallet, uint _total_supply, uint _max_amount_to_sell, uint _starting_rate,
    uint _ending_rate, uint _duration, uint _start_time, bool _sale_is_whitelisted,
    address _admin, bool _burn_excess
  ) external view {

    if (
      _wallet == 0
      || _max_amount_to_sell == 0
      || _max_amount_to_sell > _total_supply
      || _starting_rate <= _ending_rate
      || _ending_rate == 0
      || _start_time <= now
      || _duration + _start_time <= _start_time
      || _admin == 0
    ) revert("Improper Initialization");

    Contract.initialize();

    Contract.storing();
    Contract.set(execPermissions(msg.sender)).to(true);
    Contract.set(wallet()).to(_wallet);
    Contract.set(admin()).to(_admin);
    Contract.set(totalDuration()).to(_duration);
    Contract.set(startTime()).to(_start_time);
    Contract.set(startRate()).to(_starting_rate);
    Contract.set(endRate()).to(_ending_rate);
    Contract.set(tokenTotalSupply()).to(_total_supply);
    Contract.set(maxSellCap()).to(_max_amount_to_sell);
    Contract.set(tokensRemaining()).to(_max_amount_to_sell);
    Contract.set(isWhitelisted()).to(_sale_is_whitelisted);
    Contract.set(balances(_admin)).to(_total_supply - _max_amount_to_sell);
    Contract.set(burnExcess()).to(_burn_excess);

    Contract.commit();
  }


  function getAdmin(address _storage, bytes32 _exec_id) external view returns (address)
    { return address(GetterInterface(_storage).read(_exec_id, admin())); }


  function getCrowdsaleInfo(address _storage, bytes32 _exec_id) external view
  returns (uint wei_raised, address team_wallet, uint minimum_contribution, bool is_initialized, bool is_finalized, bool burn_excess) {

    bytes32[] memory seed_arr = new bytes32[](6);

    seed_arr[0] = totalWeiRaised();
    seed_arr[1] = wallet();
    seed_arr[2] = globalMinPurchaseAmt();
    seed_arr[3] = isConfigured();
    seed_arr[4] = isFinished();
    seed_arr[5] = burnExcess();

    bytes32[] memory values_arr = GetterInterface(_storage).readMulti(_exec_id, seed_arr);

    wei_raised = uint(values_arr[0]);
    team_wallet = address(values_arr[1]);
    minimum_contribution = uint(values_arr[2]);
    is_initialized = (values_arr[3] != 0 ? true : false);
    is_finalized = (values_arr[4] != 0 ? true : false);
    burn_excess = values_arr[5] != 0 ? true : false;
  }

  function isCrowdsaleFull(address _storage, bytes32 _exec_id) external view returns (bool is_crowdsale_full, uint max_sellable) {

    bytes32[] memory seed_arr = new bytes32[](2);
    seed_arr[0] = tokensRemaining();
    seed_arr[1] = maxSellCap();

    uint[] memory values_arr = GetterInterface(_storage).readMulti(_exec_id, seed_arr).toUintArr();

    is_crowdsale_full = (values_arr[0] == 0 ? true : false);
    max_sellable = values_arr[1];

    seed_arr = new bytes32[](5);
    seed_arr[0] = startTime();
    seed_arr[1] = startRate();
    seed_arr[2] = totalDuration();
    seed_arr[3] = endRate();
    seed_arr[4] = tokenDecimals();

    uint num_remaining = values_arr[0];
    values_arr = GetterInterface(_storage).readMulti(_exec_id, seed_arr).toUintArr();

    uint current_rate;
    (current_rate, ) = getRateAndTimeRemaining(values_arr[0], values_arr[2], values_arr[1], values_arr[3]);

    if (current_rate.mul(num_remaining).div(10 ** values_arr[4]) == 0)
      return (true, max_sellable);
  }

  function getCrowdsaleUniqueBuyers(address _storage, bytes32 _exec_id) external view returns (uint)
    { return uint(GetterInterface(_storage).read(_exec_id, contributors())); }


  function getCrowdsaleStartAndEndTimes(address _storage, bytes32 _exec_id) external view returns (uint start_time, uint end_time) {

    bytes32[] memory seed_arr = new bytes32[](2);
    seed_arr[0] = startTime();
    seed_arr[1] = totalDuration();

    uint[] memory values_arr = GetterInterface(_storage).readMulti(_exec_id, seed_arr).toUintArr();

    start_time = values_arr[0];
    end_time = values_arr[1] + start_time;
  }

  function getCrowdsaleStatus(address _storage, bytes32 _exec_id) external view
  returns (uint start_rate, uint end_rate, uint current_rate, uint sale_duration, uint time_remaining, uint tokens_remaining, bool is_whitelisted) {

    bytes32[] memory seed_arr = new bytes32[](6);

    seed_arr[0] = startRate();
    seed_arr[1] = endRate();
    seed_arr[2] = startTime();
    seed_arr[3] = totalDuration();
    seed_arr[4] = tokensRemaining();
    seed_arr[5] = isWhitelisted();

    uint[] memory values_arr = GetterInterface(_storage).readMulti(_exec_id, seed_arr).toUintArr();

    start_rate = values_arr[0];
    end_rate = values_arr[1];
    uint start_time = values_arr[2];
    sale_duration = values_arr[3];
    tokens_remaining = values_arr[4];
    is_whitelisted = values_arr[5] == 0 ? false : true;

    (current_rate, time_remaining) =
      getRateAndTimeRemaining(start_time, sale_duration, start_rate, end_rate);
  }

  function getRateAndTimeRemaining(uint _start_time, uint _duration, uint _start_rate, uint _end_rate) internal view
  returns (uint current_rate, uint time_remaining)  {

    if (now <= _start_time)
      return (_start_rate, (_duration + _start_time - now));

    uint time_elapsed = now - _start_time;
    if (time_elapsed >= _duration)
      return (0, 0);

    time_remaining = _duration - time_elapsed;
    time_elapsed *= (10 ** 18);
    current_rate = ((_start_rate - _end_rate) * time_elapsed) / _duration;
    current_rate /= (10 ** 18); // Remove additional precision decimals
    current_rate = _start_rate - current_rate;
  }

  function getTokensSold(address _storage, bytes32 _exec_id) external view returns (uint)
    { return uint(GetterInterface(_storage).read(_exec_id, tokensSold())); }


  function getWhitelistStatus(address _storage, bytes32 _exec_id, address _buyer) external view
  returns (uint minimum_purchase_amt, uint max_tokens_remaining) {

    bytes32[] memory seed_arr = new bytes32[](2);
    seed_arr[0] = whitelistMinTok(_buyer);
    seed_arr[1] = whitelistMaxTok(_buyer);

    uint[] memory values_arr = GetterInterface(_storage).readMulti(_exec_id, seed_arr).toUintArr();

    minimum_purchase_amt = values_arr[0];
    max_tokens_remaining = values_arr[1];
  }

  function getCrowdsaleWhitelist(address _storage, bytes32 _exec_id) external view returns (uint num_whitelisted, address[] whitelist) {

    num_whitelisted = uint(GetterInterface(_storage).read(_exec_id, saleWhitelist()));

    if (num_whitelisted == 0)
      return (num_whitelisted, whitelist);

    bytes32[] memory seed_arr = new bytes32[](num_whitelisted);

    for (uint i = 0; i < num_whitelisted; i++)
    	seed_arr[i] = bytes32(32 * (i + 1) + uint(saleWhitelist()));

    whitelist = GetterInterface(_storage).readMulti(_exec_id, seed_arr).toAddressArr();
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

}