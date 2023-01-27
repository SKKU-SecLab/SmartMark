


pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity 0.7.1;


interface Validating {

  modifier notZero(uint number) { require(number > 0, "invalid 0 value"); _; }

  modifier notEmpty(string memory text) { require(bytes(text).length > 0, "invalid empty string"); _; }

  modifier validAddress(address value) { require(value != address(0x0), "invalid address"); _; }

}


pragma solidity 0.7.1;

library BytesLib {

  function concat(
    bytes memory _preBytes,
    bytes memory _postBytes
  )
    internal
    pure
    returns (bytes memory)
  {

    bytes memory tempBytes;

    assembly {
      tempBytes := mload(0x40)

      let length := mload(_preBytes)
      mstore(tempBytes, length)

      let mc := add(tempBytes, 0x20)
      let end := add(mc, length)

      for {
        let cc := add(_preBytes, 0x20)
      } lt(mc, end) {
        mc := add(mc, 0x20)
        cc := add(cc, 0x20)
      } {
        mstore(mc, mload(cc))
      }

      length := mload(_postBytes)
      mstore(tempBytes, add(length, mload(tempBytes)))

      mc := end
      end := add(mc, length)

      for {
        let cc := add(_postBytes, 0x20)
      } lt(mc, end) {
        mc := add(mc, 0x20)
        cc := add(cc, 0x20)
      } {
        mstore(mc, mload(cc))
      }

      mstore(0x40, and(
        add(add(end, iszero(add(length, mload(_preBytes)))), 31),
        not(31) // Round down to the nearest 32 bytes.
      ))
    }

    return tempBytes;
  }

  function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

    assembly {
      let fslot := sload(_preBytes.slot)
      let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
      let mlength := mload(_postBytes)
      let newlength := add(slength, mlength)
      switch add(lt(slength, 32), lt(newlength, 32))
      case 2 {
        sstore(
          _preBytes.slot,
          add(
            fslot,
            add(
              mul(
                div(
                  mload(add(_postBytes, 0x20)),
                  exp(0x100, sub(32, mlength))
                ),
                exp(0x100, sub(32, newlength))
              ),
              mul(mlength, 2)
            )
          )
        )
      }
      case 1 {
        mstore(0x0, _preBytes.slot)
        let sc := add(keccak256(0x0, 0x20), div(slength, 32))

        sstore(_preBytes.slot, add(mul(newlength, 2), 1))


        let submod := sub(32, slength)
        let mc := add(_postBytes, submod)
        let end := add(_postBytes, mlength)
        let mask := sub(exp(0x100, submod), 1)

        sstore(
          sc,
          add(
            and(
              fslot,
              0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
            ),
            and(mload(mc), mask)
          )
        )

        for {
          mc := add(mc, 0x20)
          sc := add(sc, 1)
        } lt(mc, end) {
          sc := add(sc, 1)
          mc := add(mc, 0x20)
        } {
          sstore(sc, mload(mc))
        }

        mask := exp(0x100, sub(mc, end))

        sstore(sc, mul(div(mload(mc), mask), mask))
      }
      default {
        mstore(0x0, _preBytes.slot)
        let sc := add(keccak256(0x0, 0x20), div(slength, 32))

        sstore(_preBytes.slot, add(mul(newlength, 2), 1))

        let slengthmod := mod(slength, 32)
        let mlengthmod := mod(mlength, 32)
        let submod := sub(32, slengthmod)
        let mc := add(_postBytes, submod)
        let end := add(_postBytes, mlength)
        let mask := sub(exp(0x100, submod), 1)

        sstore(sc, add(sload(sc), and(mload(mc), mask)))

        for {
          sc := add(sc, 1)
          mc := add(mc, 0x20)
        } lt(mc, end) {
          sc := add(sc, 1)
          mc := add(mc, 0x20)
        } {
          sstore(sc, mload(mc))
        }

        mask := exp(0x100, sub(mc, end))

        sstore(sc, mul(div(mload(mc), mask), mask))
      }
    }
  }

  function slice(
    bytes memory _bytes,
    uint _start,
    uint _length
  )
    internal
    pure
    returns (bytes memory)
  {

    require(_length + 31 >= _length, "slice_overflow");
    require(_start + _length >= _start, "slice_overflow");
    require(_bytes.length >= _start + _length, "slice_outOfBounds");

    bytes memory tempBytes;

    assembly {
      switch iszero(_length)
      case 0 {
        tempBytes := mload(0x40)

        let lengthmod := and(_length, 31)

        let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
        let end := add(mc, _length)

        for {
          let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
        } lt(mc, end) {
          mc := add(mc, 0x20)
          cc := add(cc, 0x20)
        } {
          mstore(mc, mload(cc))
        }

        mstore(tempBytes, _length)

        mstore(0x40, and(add(mc, 31), not(31)))
      }
      default {
        tempBytes := mload(0x40)

        mstore(0x40, add(tempBytes, 0x20))
      }
    }

    return tempBytes;
  }

  function toAddress(bytes memory _bytes, uint _start) internal pure returns (address) {

    require(_start + 20 >= _start, "toAddress_overflow");
    require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
    address tempAddress;

    assembly {
      tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
    }

    return tempAddress;
  }

  function toUint8(bytes memory _bytes, uint _start) internal pure returns (uint8) {

    require(_start + 1 >= _start, "toUint8_overflow");
    require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
    uint8 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x1), _start))
    }

    return tempUint;
  }

  function toUint16(bytes memory _bytes, uint _start) internal pure returns (uint16) {

    require(_start + 2 >= _start, "toUint16_overflow");
    require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
    uint16 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x2), _start))
    }

    return tempUint;
  }

  function toUint32(bytes memory _bytes, uint _start) internal pure returns (uint32) {

    require(_start + 4 >= _start, "toUint32_overflow");
    require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
    uint32 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x4), _start))
    }

    return tempUint;
  }

  function toUint64(bytes memory _bytes, uint _start) internal pure returns (uint64) {

    require(_start + 8 >= _start, "toUint64_overflow");
    require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
    uint64 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x8), _start))
    }

    return tempUint;
  }

  function toUint96(bytes memory _bytes, uint _start) internal pure returns (uint96) {

    require(_start + 12 >= _start, "toUint96_overflow");
    require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
    uint96 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0xc), _start))
    }

    return tempUint;
  }

  function toUint128(bytes memory _bytes, uint _start) internal pure returns (uint128) {

    require(_start + 16 >= _start, "toUint128_overflow");
    require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
    uint128 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x10), _start))
    }

    return tempUint;
  }

  function toUint256(bytes memory _bytes, uint _start) internal pure returns (uint) {

    require(_start + 32 >= _start, "toUint256_overflow");
    require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
    uint tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x20), _start))
    }

    return tempUint;
  }

  function toUint(bytes memory _bytes, uint _start) internal pure returns (uint) {

    return toUint256(_bytes, _start);
  }

  function toBytes32(bytes memory _bytes, uint _start) internal pure returns (bytes32) {

    require(_start + 32 >= _start, "toBytes32_overflow");
    require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
    bytes32 tempBytes32;

    assembly {
      tempBytes32 := mload(add(add(_bytes, 0x20), _start))
    }

    return tempBytes32;
  }

  function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

    bool success = true;

    assembly {
      let length := mload(_preBytes)

      switch eq(length, mload(_postBytes))
      case 1 {
        let cb := 1

        let mc := add(_preBytes, 0x20)
        let end := add(mc, length)

        for {
          let cc := add(_postBytes, 0x20)
        } eq(add(lt(mc, end), cb), 2) {
          mc := add(mc, 0x20)
          cc := add(cc, 0x20)
        } {
          if iszero(eq(mload(mc), mload(cc))) {
            success := 0
            cb := 0
          }
        }
      }
      default {
        success := 0
      }
    }

    return success;
  }

  function equalStorage(
    bytes storage _preBytes,
    bytes memory _postBytes
  )
    internal
    view
    returns (bool)
  {

    bool success = true;

    assembly {
      let fslot := sload(_preBytes.slot)
      let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
      let mlength := mload(_postBytes)

      switch eq(slength, mlength)
      case 1 {
        if iszero(iszero(slength)) {
          switch lt(slength, 32)
          case 1 {
            fslot := mul(div(fslot, 0x100), 0x100)

            if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
              success := 0
            }
          }
          default {
            let cb := 1

            mstore(0x0, _preBytes.slot)
            let sc := keccak256(0x0, 0x20)

            let mc := add(_postBytes, 0x20)
            let end := add(mc, mlength)

            for {} eq(add(lt(mc, end), cb), 2) {
              sc := add(sc, 1)
              mc := add(mc, 0x20)
            } {
              if iszero(eq(sload(sc), mload(mc))) {
                success := 0
                cb := 0
              }
            }
          }
        }
      }
      default {
        success := 0
      }
    }

    return success;
  }
}


pragma solidity 0.7.1;


interface AppGovernance {

  function approve(uint32 id) external;

  function disapprove(uint32 id) external;

  function activate(uint32 id) external;

}


pragma solidity 0.7.1;


interface AppLogic {


  function upgrade() external;


  function credit(address account, address asset, uint quantity) external;


  function debit(address account, bytes calldata parameters) external returns (address asset, uint quantity);

}


pragma solidity 0.7.1;

contract AppState {


  enum State { OFF, ON, RETIRED }
  State public state = State.ON;
  event Off();
  event Retired();

  modifier whenOn() { require(state == State.ON, "must be on"); _; }


  modifier whenOff() { require(state == State.OFF, "must be off"); _; }


  modifier whenRetired() { require(state == State.RETIRED, "must be retired"); _; }


  function retire_() internal whenOn {

    state = State.RETIRED;
    emit Retired();
  }

  function switchOff_() internal whenOn {

    state = State.OFF;
    emit Off();
  }

  function isOn() external view returns (bool) { return state == State.ON; }


}



pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity 0.7.1;


contract Versioned {


  string public version;

  constructor(string memory version_) { version = version_; }

}


pragma solidity 0.7.1;


interface GluonWallet {

  function depositEther(uint32 id) external payable;

  function depositToken(uint32 id, address token, uint quantity) external;

  function withdraw(uint32 id, bytes calldata parameters) external;

  function transfer(uint32 from, uint32 to, bytes calldata parameters) external;

}


pragma solidity 0.7.1;


interface Governing {

  function deleteVoteTally(address proposal) external;

  function activationInterval() external view returns (uint);

  function governanceToken() external returns (address);

}


pragma solidity 0.7.1;



contract HasOwners is Validating {


  address[] public owners;
  mapping(address => bool) public isOwner;

  event OwnerAdded(address indexed owner);
  event OwnerRemoved(address indexed owner);

  constructor(address[] memory owners_) {
    require(owners_.length > 0, "there must be at least one owner");
    for (uint i = 0; i < owners_.length; i++) addOwner_(owners_[i]);
  }

  modifier onlyOwner { require(isOwner[msg.sender], "invalid sender; must be owner"); _; }


  function getOwners() public view returns (address[] memory) { return owners; }


  function addOwner(address owner) external onlyOwner { addOwner_(owner); }


  function addOwner_(address owner) private validAddress(owner) {

    if (!isOwner[owner]) {
      isOwner[owner] = true;
      owners.push(owner);
      emit OwnerAdded(owner);
    }
  }

  function removeOwner(address owner) external onlyOwner {

    require(isOwner[owner], 'only owners can be removed');
    require(owners.length > 1, 'can not remove last owner');
    isOwner[owner] = false;
    for (uint i = 0; i < owners.length; i++) {
      if (owners[i] == owner) {
        owners[i] = owners[owners.length - 1];
        owners.pop();
        emit OwnerRemoved(owner);
        break;
      }
    }
  }

}


pragma solidity 0.7.1;



contract HasAppOwners is HasOwners {


  mapping(uint32 => address[]) public appOwners;

  event AppOwnerAdded (uint32 appId, address appOwner);
  event AppOwnerRemoved (uint32 appId, address appOwner);

  constructor(address[] memory owners_) HasOwners(owners_) { }

  modifier onlyAppOwner(uint32 appId) { require(isAppOwner(appId, msg.sender), "invalid sender; must be app owner"); _; }


  function isAppOwner(uint32 appId, address appOwner) public view returns (bool) {

    address[] memory currentOwners = appOwners[appId];
    for (uint i = 0; i < currentOwners.length; i++) {
      if (currentOwners[i] == appOwner) return true;
    }
    return false;
  }

  function getAppOwners(uint32 appId) public view returns (address[] memory) { return appOwners[appId]; }


  function addAppOwners(uint32 appId, address[] calldata toBeAdded) external onlyAppOwner(appId) {

    addAppOwners_(appId, toBeAdded);
  }

  function addAppOwners_(uint32 appId, address[] memory toBeAdded) internal {

    for (uint i = 0; i < toBeAdded.length; i++) {
      if (!isAppOwner(appId, toBeAdded[i])) {
        appOwners[appId].push(toBeAdded[i]);
        emit AppOwnerAdded(appId, toBeAdded[i]);
      }
    }
  }


  function removeAppOwners(uint32 appId, address[] calldata toBeRemoved) external onlyAppOwner(appId) {

    address[] storage currentOwners = appOwners[appId];
    require(currentOwners.length > toBeRemoved.length, "can not remove last owner");
    for (uint i = 0; i < toBeRemoved.length; i++) {
      for (uint j = 0; j < currentOwners.length; j++) {
        if (currentOwners[j] == toBeRemoved[i]) {
          currentOwners[j] = currentOwners[currentOwners.length - 1];
          currentOwners.pop();
          emit AppOwnerRemoved(appId, toBeRemoved[i]);
          break;
        }
      }
    }
  }

}


pragma solidity 0.7.1;











contract Gluon is Validating, Versioned, AppGovernance, GluonWallet, HasAppOwners {

  using SafeMath for uint;

  struct App {
    address[] history;
    address proposal;
    uint activationBlock;
    mapping(address => uint) balances;
  }

  address private constant ETH = address(0x0);
  uint32 private constant REGISTRY_INDEX = 0;
  uint32 private constant STAKE_INDEX = 1;

  mapping(uint32 => App) public apps;
  mapping(address => bool) public proposals;
  uint32 public totalAppsCount = 0;

  event AppRegistered (uint32 appId);
  event AppProvisioned(uint32 indexed appId, uint8 version, address logic);
  event ProposalAdded(uint32 indexed appId, uint8 version, address logic, uint activationBlock);
  event ProposalRemoved(uint32 indexed appId, uint8 version, address logic);
  event Activated(uint32 indexed appId, uint8 version, address logic);

  constructor(address[] memory owners_, string memory version_) Versioned(version_) HasAppOwners(owners_) {
    registerApp_(REGISTRY_INDEX, owners);
    registerApp_(STAKE_INDEX, owners);
  }

  modifier onlyCurrentLogic(uint32 appId) { require(msg.sender == current(appId), "invalid sender; must be latest logic contract"); _; }


  modifier provisioned(uint32 appId) { require(apps[appId].history.length > 0, "App is not yet provisioned"); _; }


  function registerApp(uint32 appId, address[] calldata accounts) external onlyOwner { registerApp_(appId, accounts); }


  function registerApp_(uint32 appId, address[] memory accounts) private {

    require(appOwners[appId].length == 0, "App already has app owner");
    require(totalAppsCount == appId, "app ids are incremented by 1");
    totalAppsCount++;
    emit AppRegistered(appId);
    addAppOwners_(appId, accounts);
  }

  function provisionApp(uint32 appId, address logic) external onlyAppOwner(appId) validAddress(logic) {

    App storage app = apps[appId];
    require(app.history.length == 0, "App is already provisioned");
    app.history.push(logic);
    emit AppProvisioned(appId, uint8(app.history.length - 1), logic);
  }


  function addProposal(uint32 appId, address logic) external onlyAppOwner(appId) provisioned(appId) validAddress(logic) {

    App storage app = apps[appId];
    require(app.proposal == address(0x0), "Proposal already exists. remove proposal before adding new one");
    app.proposal = logic;
    app.activationBlock = block.number + Governing(current(STAKE_INDEX)).activationInterval();
    proposals[logic] = true;
    emit ProposalAdded(appId, uint8(app.history.length - 1), app.proposal, app.activationBlock);
  }

  function removeProposal(uint32 appId) external onlyAppOwner(appId) provisioned(appId) {

    App storage app = apps[appId];
    emit ProposalRemoved(appId, uint8(app.history.length - 1), app.proposal);
    deleteProposal(app);
  }

  function deleteProposal(App storage app) private {

    Governing(current(STAKE_INDEX)).deleteVoteTally(app.proposal);
    delete proposals[app.proposal];
    delete app.proposal;
    app.activationBlock = 0;
  }


  function approve(uint32 appId) external override onlyCurrentLogic(STAKE_INDEX) {

    apps[appId].activationBlock = block.number;
  }

  function disapprove(uint32 appId) external override onlyCurrentLogic(STAKE_INDEX) {

    App storage app = apps[appId];
    emit ProposalRemoved(appId, uint8(app.history.length - 1), app.proposal);
    deleteProposal(app);
  }

  function activate(uint32 appId) external override onlyCurrentLogic(appId) provisioned(appId) {

    App storage app = apps[appId];
    require(app.activationBlock > 0, "nothing to activate");
    require(app.activationBlock < block.number, "new app can not be activated before activation block");
    app.history.push(app.proposal); // now make it the current
    deleteProposal(app);
    emit Activated(appId, uint8(app.history.length - 1), current(appId));
  }


  function depositEther(uint32 appId) external override payable provisioned(appId) {

    App storage app = apps[appId];
    app.balances[ETH] = app.balances[ETH].add(msg.value);
    AppLogic(current(appId)).credit(msg.sender, ETH, msg.value);
  }

  function depositToken(uint32 appId, address token, uint quantity) external override provisioned(appId) {

    transferTokensToGluonSecurely(appId, IERC20(token), quantity);
    AppLogic(current(appId)).credit(msg.sender, token, quantity);
  }

  function transferTokensToGluonSecurely(uint32 appId, IERC20 token, uint quantity) private {

    uint balanceBefore = token.balanceOf(address(this));
    require(token.transferFrom(msg.sender, address(this), quantity), "failure to transfer quantity from token");
    uint balanceAfter = token.balanceOf(address(this));
    require(balanceAfter.sub(balanceBefore) == quantity, "bad Token; transferFrom erroneously reported of successful transfer");
    App storage app = apps[appId];
    app.balances[address(token)] = app.balances[address(token)].add(quantity);
  }

  function withdraw(uint32 appId, bytes calldata parameters) external override provisioned(appId) {

    (address asset, uint quantity) = AppLogic(current(appId)).debit(msg.sender, parameters);
    if (quantity > 0) {
      App storage app = apps[appId];
      require(app.balances[asset] >= quantity, "not enough funds to transfer");
      app.balances[asset] = apps[appId].balances[asset].sub(quantity);
      asset == ETH ?
        require(address(uint160(msg.sender)).send(quantity), "failed to transfer ether") : // explicit casting to `address payable`
        transferTokensToAccountSecurely(IERC20(asset), quantity, msg.sender);
    }
  }

  function transferTokensToAccountSecurely(IERC20 token, uint quantity, address to) private {

    uint balanceBefore = token.balanceOf(to);
    require(token.transfer(to, quantity), "failure to transfer quantity from token");
    uint balanceAfter = token.balanceOf(to);
    require(balanceAfter.sub(balanceBefore) == quantity, "bad Token; transferFrom erroneously reported of successful transfer");
  }

  function transfer(uint32 from, uint32 to, bytes calldata parameters) external override provisioned(from) provisioned(to) {

    (address asset, uint quantity) = AppLogic(current(from)).debit(msg.sender, parameters);
    if (quantity > 0) {
      if (from != to) {
        require(apps[from].balances[asset] >= quantity, "not enough balance in logic to transfer");
        apps[from].balances[asset] = apps[from].balances[asset].sub(quantity);
        apps[to].balances[asset] = apps[to].balances[asset].add(quantity);
      }
      AppLogic(current(to)).credit(msg.sender, asset, quantity);
    }
  }


  function app(uint32 appId) external view returns (address current, address proposal, uint activationBlock) {

    App storage app_ = apps[appId];
    current = app_.history[app_.history.length - 1];
    proposal = app_.proposal;
    activationBlock = app_.activationBlock;
  }

  function current(uint32 appId) public view returns (address) { return apps[appId].history[apps[appId].history.length - 1]; }


  function history(uint32 appId) external view returns (address[] memory) { return apps[appId].history; }


  function isAnyLogic(uint32 appId, address logic) public view returns (bool) {

    address[] memory history_ = apps[appId].history;
    for (uint i = history_.length; i > 0; i--) {
      if (history_[i - 1] == logic) return true;
    }
    return false;
  }

  function getBalance(uint32 appId, address asset) external view returns (uint) { return apps[appId].balances[asset]; }


}


pragma solidity 0.7.1;



contract GluonCentric {


  uint32 internal constant REGISTRY_INDEX = 0;
  uint32 internal constant STAKE_INDEX = 1;

  uint32 public id;
  Gluon public gluon;

  constructor(uint32 id_, address gluon_) {
    id = id_;
    gluon = Gluon(gluon_);
  }

  modifier onlyCurrentLogic { require(currentLogic() == msg.sender, "invalid sender; must be current logic contract"); _; }


  modifier onlyGluon { require(address(gluon) == msg.sender, "invalid sender; must be gluon contract"); _; }


  modifier onlyOwner { require(gluon.isAppOwner(id, msg.sender), "invalid sender; must be app owner"); _; }


  function currentLogic() public view returns (address) { return gluon.current(id); }


}


pragma solidity 0.7.1;




abstract contract GluonLogic is GluonCentric {
  address public upgradeOperator;

  constructor(uint32 id_, address gluon_) GluonCentric(id_, gluon_) { }

  modifier onlyUpgradeOperator { require(upgradeOperator == msg.sender, "invalid sender; must be upgrade operator"); _; }

  function setUpgradeOperator(address upgradeOperator_) external onlyOwner { upgradeOperator = upgradeOperator_; }

  function upgrade_(AppGovernance appGovernance, uint32 id) internal {
    appGovernance.activate(id);
    delete upgradeOperator;
  }
}


pragma solidity 0.7.1;


interface OldRegistry {

  function contains(address apiKey) external view returns (bool);

  function register(address apiKey) external;

  function registerWithUserAgreement(address apiKey, bytes32 userAgreement) external;

  function translate(address apiKey) external view returns (address);

}


pragma solidity 0.7.1;



contract RegistryData is GluonCentric {


  mapping(address => address) public accounts;

  constructor(address gluon_) GluonCentric(REGISTRY_INDEX, gluon_) { }

  function addKey(address apiKey, address account) external onlyCurrentLogic {

    accounts[apiKey] = account;
  }

}


pragma solidity 0.7.1;









contract RegistryLogic is Validating, AppLogic, AppState, GluonLogic {


  RegistryData public data;
  OldRegistry public old;

  event Registered(address apiKey, address indexed account);

  constructor(address gluon_, address old_, address data_) GluonLogic(REGISTRY_INDEX, gluon_) {
    data = RegistryData(data_);
    old = OldRegistry(old_);
  }

  modifier isAbsent(address apiKey) { require(translate(apiKey) == address (0x0), "api key already in use"); _; }


  function register(address apiKey) external whenOn validAddress(apiKey) isAbsent(apiKey) {

    data.addKey(apiKey, msg.sender);
    emit Registered(apiKey, msg.sender);
  }

  function translate(address apiKey) public view returns (address) {

    address account = data.accounts(apiKey);
    if (account == address(0x0)) account = old.translate(apiKey);
    return account;
  }


  function upgrade() external override onlyUpgradeOperator {

    retire_();
    upgrade_(AppGovernance(gluon), id);
  }

  function credit(address, address, uint) external override pure { revert("not supported"); }


  function debit(address, bytes calldata) external override pure returns (address, uint) { revert("not supported"); }



  function switchOff() external onlyOwner {

    uint32 totalAppsCount = gluon.totalAppsCount();
    for (uint32 i = 2; i < totalAppsCount; i++) {
      AppState appState = AppState(gluon.current(i));
      require(!appState.isOn(), "One of the apps is still ON");
    }
    switchOff_();
  }

}


pragma solidity 0.7.1;


interface Redeeming {

  function redeem(address account, uint quantity) external returns (uint toRestake, uint toStake, uint toWithdraw);

}


pragma solidity 0.7.1;




contract StakeData is GluonCentric {

  using SafeMath for uint;

  mapping(address => address[]) public accountToProposals;
  mapping(address => bool[]) public accountToSides;
  mapping(address => mapping(bool => uint)) public voteTally; /// proposal => side(true/false) => totalVotes
  mapping(address => address) public accountLocation;         /// account => logic
  mapping(address => uint) public balance;

  constructor(address gluon) GluonCentric(STAKE_INDEX, gluon) { }

  function updateAccountLocation(address account, address logic) external onlyCurrentLogic { accountLocation[account] = logic; }


  function updateBalance(address account, uint quantity) external onlyCurrentLogic { balance[account] = quantity; }


  function voteAppUpgrade(address proposal, address account, bool side, uint quantity) external onlyCurrentLogic returns (uint, uint) {

    uint index = getVoteIndex(account, proposal);
    bool firstVote = index == accountToProposals[account].length;
    require(firstVote || accountToSides[account][index] != side, "cannot vote same side again");
    if (firstVote) {
      accountToProposals[account].push(proposal);
      accountToSides[account].push(side);
    } else {
      voteTally[proposal][!side] = voteTally[proposal][!side].sub(quantity);
      accountToSides[account][index] = side;
    }
    voteTally[proposal][side] = voteTally[proposal][side].add(quantity);
    return getVoteTally(proposal);
  }

  function deleteVoteTally(address proposal) external onlyCurrentLogic {

    voteTally[proposal][true] = voteTally[proposal][false] = 0;
  }

  function getVoteIndex(address account, address proposal) public view returns (uint) {

    address[] memory proposals = accountToProposals[account];
    for (uint i = 0; i < proposals.length; i++) {
      if (proposals[i] == proposal) return i;
    }
    return proposals.length;
  }

  function getAllProposals(address account) external view returns (address[] memory proposals, bool[] memory sides) {

    proposals = accountToProposals[account];
    sides = accountToSides[account];
  }

  function removeResolvedProposals(address account) external onlyCurrentLogic {

    if (accountToProposals[account].length == 0) return;
    address[] storage allProposed = accountToProposals[account];
    bool[] storage sides = accountToSides[account];
    for (uint i = allProposed.length; i > 0; i--) {
      if (!gluon.proposals(allProposed[i - 1])) {
        allProposed[i - 1] = allProposed[allProposed.length - 1];
        allProposed.pop();
        sides[i - 1] = sides[sides.length - 1];
        sides.pop();
      }
    }
  }

  function updateVotes(address proposal, bool side, uint quantity, bool increased) external onlyCurrentLogic returns (uint approvals, uint disapprovals) {

    uint tally = voteTally[proposal][side];
    voteTally[proposal][side] = increased ? tally.add(quantity) : tally.sub(quantity);
    return getVoteTally(proposal);
  }

  function getVoteTally(address proposal) public view returns (uint approvals, uint disapprovals) {

    approvals = voteTally[proposal][true];
    disapprovals = voteTally[proposal][false];
  }

}


pragma solidity 0.7.1;













contract StakeLogic is Validating, AppLogic, AppState, GluonLogic, Governing, Redeeming {

  using BytesLib for bytes;
  using SafeMath for uint;

  struct Interval {
    uint worth;
    uint[] rewards;
    uint start;
    uint end;
  }

  struct UserStake {
    uint intervalIndex;
    uint quantity;
    uint worth;
  }

  address constant private ETH = address(0x0);
  uint public constant name = uint(keccak256("StakeLogic"));
  bool initiated;
  StakeData public data;
  address public override governanceToken;
  address[] public tokens;
  address[] public extensions;
  uint[] public toBeDistributed;

  uint public intervalSize;
  uint public currentIntervalIndex;
  uint public quorumPercentage;
  uint public override activationInterval;
  mapping(uint => Interval) public intervals;
  mapping(address => UserStake) public stakes;

  event Staked(address indexed user, uint quantity, uint start, uint end, uint intervalIndex);
  event Restaked(address indexed user, uint quantity, uint start, uint end, uint intervalIndex);
  event Redeemed(address indexed user, uint quantity, uint start, uint end, uint intervalIndex);
  event Reward(address indexed user, address asset, uint reward, uint start, uint end, uint intervalIndex);
  event NewInterval(uint start, uint end, uint intervalIndex);
  event Voted(uint32 indexed appId, address indexed proposal, uint approvals, uint disapprovals, address account);
  event VotingConcluded(uint32 indexed appId, address indexed proposal, uint approvals, uint disapprovals, bool result);

  constructor(address gluon_, address data_, address governanceToken_, address[] memory tokens_, address apiKey_, uint intervalSize_, uint quorumPercentage_, uint activationInterval_, address[] memory extensions_)
    GluonLogic(STAKE_INDEX, gluon_)
    validAddress(gluon_)
    validAddress(governanceToken_)
    validAddress(apiKey_)
    notZero(intervalSize_)
    notZero(activationInterval_)
  {
    data = StakeData(data_);
    governanceToken = governanceToken_;
    tokens = tokens_;
    for (uint i = 0; i < tokens.length; i++) toBeDistributed.push(0);
    quorumPercentage = quorumPercentage_;
    intervalSize = intervalSize_;
    registerApiKey_(apiKey_);
    activationInterval = activationInterval_;
    extensions = extensions_;
  }

  receive() external payable {}

  function init(uint intervalId) external onlyOwner {

    require(initiated == false, "already initiated");
    currentIntervalIndex = intervalId;
    intervals[currentIntervalIndex].start = block.number;
    intervals[currentIntervalIndex].end = block.number.add(intervalSize);
    for (uint i = 0; i < tokens.length; i++) intervals[currentIntervalIndex].rewards.push(0);
    initiated = true;
  }

  function setIntervalSize(uint intervalSize_) external notZero(intervalSize_) onlyOwner {

    ensureInterval();
    intervalSize = intervalSize_;
  }

  function addToken(address token) external onlyOwner whenOn {

    require(tokens.length < 50, "Can not add more than 50 tokens");
    tokens.push(token);
    toBeDistributed.push(0);
    intervals[currentIntervalIndex].rewards.push(0);
  }

  function addExtention(address extension) external onlyOwner whenOn {

    extensions.push(extension);
  }

  function ensureInterval() public whenOn {

    if (intervals[currentIntervalIndex].end > block.number) return;

    Interval storage interval = intervals[currentIntervalIndex];
    for (uint i = 0; i < interval.rewards.length; i++) {
      uint reward = interval.worth == 0 ? 0 : calculateIntervalReward(interval.start, interval.end, i);
      toBeDistributed[i] = toBeDistributed[i].add(reward);
      interval.rewards[i] = reward;
    }

    uint diff = block.number.sub(interval.end) % intervalSize;
    currentIntervalIndex += 1;
    uint start = interval.end;
    uint end = block.number.sub(diff).add(intervalSize);
    intervals[currentIntervalIndex].start = start;
    intervals[currentIntervalIndex].end = end;
    for (uint i = 0; i < tokens.length; i++) intervals[currentIntervalIndex].rewards.push(0);
    emit NewInterval(start, end, currentIntervalIndex);
  }

  function restake(address account, uint quantity) private returns (uint, uint) {

    (uint toRestake, uint toStake, uint toWithdraw) = Redeeming(stakeLocation(account)).redeem(account, quantity);
    if (toRestake == 0) return (toStake, toWithdraw);

    UserStake storage stake = stakes[account];
    stake.quantity = toRestake;
    Interval storage interval = intervals[currentIntervalIndex];
    stake.intervalIndex = currentIntervalIndex;
    stake.worth = stake.quantity.mul(interval.end.sub(interval.start));
    interval.worth = interval.worth.add(stake.worth);
    emit Restaked(account, stake.quantity, interval.start, interval.end, currentIntervalIndex);
    return (toStake, toWithdraw);
  }

  function stake(address account, uint quantity) private whenOn returns (uint toStake, uint toWithdraw) {

    ensureInterval();
    (toStake, toWithdraw) = restake(account, quantity);
    data.removeResolvedProposals(account);
    if (toWithdraw > 0) {
      updateVotes(account, toWithdraw, false);
    }
    if (toStake > 0) {
      updateVotes(account, toStake, true);
      stakeInCurrentPeriod(account, toStake);
    }
    data.updateBalance(account, quantity);
    data.updateAccountLocation(account, stakes[account].worth == 0 ? address(0x0) : address(this));
  }

  function stakeInCurrentPeriod(address account, uint quantity) private {

    Interval storage interval = intervals[currentIntervalIndex];
    stakes[account].intervalIndex = currentIntervalIndex;
    uint worth = quantity.mul(interval.end.sub(block.number));
    stakes[account].worth = stakes[account].worth.add(worth);
    stakes[account].quantity = stakes[account].quantity.add(quantity);
    interval.worth = interval.worth.add(worth);
    emit Staked(account, quantity, interval.start, interval.end, currentIntervalIndex);
  }

  function calculateIntervalReward(uint start, uint end, uint index) public view returns (uint) {

    uint balance = tokens[index] == ETH ? address(this).balance : LegacyToken(tokens[index]).balanceOf(address(this));
    return balance.sub(toBeDistributed[index]).mul(end.sub(start)).div(block.number.sub(start));
  }

  function registerApiKey(address apiKey) public onlyOwner { registerApiKey_(apiKey); }


  function registerApiKey_(address apiKey) private {

    RegistryLogic registry = RegistryLogic(gluon.current(REGISTRY_INDEX));
    registry.register(apiKey);
  }

  function withdrawFromApp(uint32 appId, bytes memory withdrawData) public {

    uint action = withdrawData.toUint(0);
    require(action == 1 || action == 5, "only assisted withdraw or exit on halt is allowed");
    GluonWallet(gluon).withdraw(appId, withdrawData);
  }

  function withdrawFromExtension(uint32 appId, bytes memory withdrawData, uint index) public {

    uint action = withdrawData.toUint(0);
    require(action == 1 || action == 5, "only assisted withdraw or exit on halt is allowed");
    GluonWallet(extensions[index]).withdraw(appId, withdrawData);
  }

  function transferToLatestStakeAfterRetire() public whenRetired {

    for (uint i = 0; i < tokens.length; i++) {
      uint balance = tokens[i] == ETH ? address(this).balance : LegacyToken(tokens[i]).balanceOf(address(this));
      uint quantity = balance.sub(toBeDistributed[i]);
      transfer(tokens[i], currentLogic(), quantity);
    }
  }


  function redeem(address account, uint quantity) public override onlyCurrentLogic returns (uint /* toRestake */, uint  /* toStake */, uint  /* toWithdraw */) {

    UserStake memory userStake = stakes[account];
    if (userStake.intervalIndex == 0) return (0, quantity, 0);

    uint staked = userStake.quantity;
    uint intervalIndex = userStake.intervalIndex;
    Interval memory interval = intervals[intervalIndex];
    uint toWithdraw = staked > quantity ? staked.sub(quantity) : 0;
    if (intervalIndex == currentIntervalIndex) {
      if (toWithdraw > 0) {
        uint worth = toWithdraw.mul(intervals[currentIntervalIndex].end.sub(block.number));
        stakes[account].worth = userStake.worth.sub(worth);
        stakes[account].quantity = userStake.quantity.sub(toWithdraw);
        intervals[currentIntervalIndex].worth = intervals[currentIntervalIndex].worth.sub(worth);
        emit Redeemed(account, toWithdraw, interval.start, interval.end, intervalIndex);
        return (0, 0, toWithdraw);
      } else {
        uint toStake = quantity.sub(staked); // some is already staked, so stake the difference
        return (0, toStake, 0);
      }
    }

    uint toRestake = staked.sub(toWithdraw);
    uint toStake = quantity > staked ? quantity.sub(staked) : 0;
    uint worth = userStake.worth;
    delete stakes[account];
    distributeRewards(account, worth, interval, intervalIndex);
    emit Redeemed(account, toWithdraw, interval.start, interval.end, intervalIndex);
    return (toRestake, toStake, toWithdraw);
  }

  function distributeRewards(address account, uint worth, Interval memory interval, uint intervalIndex) private {

    if (worth == 0) return;

    for (uint i = 0; i < tokens.length; i++) {
      uint reward = interval.rewards[i].mul(worth).div(interval.worth);
      if (reward == 0) continue;
      toBeDistributed[i] = toBeDistributed[i].sub(reward);
      transfer(tokens[i], account, reward);
      emit Reward(account, tokens[i], reward, interval.start, interval.end, intervalIndex);
    }
  }

  function transfer(address token, address to, uint quantity) private {

    if (quantity == 0) return;

    token == ETH ?
      require(address(uint160(to)).send(quantity), "failed to transfer ether") : // explicit casting to `address payable`
      transferTokensToAccountSecurely(LegacyToken(token), quantity, to);
  }

  function transferTokensToAccountSecurely(LegacyToken token, uint quantity, address to) private {

    uint balanceBefore = token.balanceOf(to);
    token.transfer(to, quantity);
    uint balanceAfter = token.balanceOf(to);
    require(balanceAfter.sub(balanceBefore) == quantity, "bad Token; transferFrom erroneously reported of successful transfer");
  }

  function getTokens() public view returns (address[] memory) { return tokens; }

  function getExtensions() public view returns (address[] memory) { return extensions; }


  function getToBeDistributed() public view returns (uint[] memory) { return toBeDistributed; }


  function getInterval(uint intervalIndex) public view returns (uint worth, uint[] memory rewards, uint start, uint end) {

    Interval memory interval = intervals[intervalIndex];
    worth = interval.worth;
    rewards = interval.rewards;
    start = interval.start;
    end = interval.end;
  }


  function deleteVoteTally(address proposal) external override onlyGluon { data.deleteVoteTally(proposal); }



  function upgrade() external override whenOn onlyUpgradeOperator {

    (, address proposal, uint activationBlock) = gluon.app(id);
    require(activationBlock > 0, "nothing to activate");
    address[] memory logics = gluon.history(id);
    require(proposal != address(this), "can not be the same contract");
    require(GluonCentric(proposal).id() == id, "invalid app id");
    for (uint i = 0; i < logics.length; i++) require(proposal != logics[i], "can not be old contract");
    require(StakeLogic(payable(proposal)).name() == name, "proposal name is different");
    intervals[currentIntervalIndex].end = block.number;
    ensureInterval();
    retire_();
    upgrade_(AppGovernance(gluon), id);
  }

  function stakeLocation(address account) public view returns (address) {

    address accountStakeLocation = data.accountLocation(account);
    if (accountStakeLocation == address(0x0) || accountStakeLocation == address(this)) return address(this);

    (, , uint worth) = StakeLogic(payable(accountStakeLocation)).stakes(account);
    return worth == 0 ?
      address(this) :       // this is a new staker
      accountStakeLocation; // this is an old staker that already withdrew their LEV from previous contract
  }

  function credit(address account, address asset, uint quantity) external override whenOn onlyGluon {

    require(address(governanceToken) == Governing(stakeLocation(account)).governanceToken(), "cannot stake new governance-token (L2) before all of old governance-token (LEV) are redeemed");
    require(asset == address(governanceToken), "can only stake governance-token (L2)");
    stake(account, data.balance(account).add(quantity));
  }

  function debit(address account, bytes calldata parameters) external override whenOn onlyGluon returns (address asset, uint quantity) {

    (asset, quantity) = abi.decode(parameters, (address, uint));
    address stakedGovernanceToken = Governing(stakeLocation(account)).governanceToken();
    bool newWorld = asset == address(governanceToken) && asset == stakedGovernanceToken;
    require(
      newWorld || /* old world */ asset != address(governanceToken) && asset == stakedGovernanceToken,
      "can only redeem new governance-token (L2) or all of old governance-token (LEV)"
    );
    if (newWorld) {
      stake(account, data.balance(account).sub(quantity));
    } else {
      require(data.balance(account) == quantity, "must redeem all of staked quantity");
      stake(account, 0);
    }
  }


  function voteAppUpgrade(uint32 appId, bool side) external whenOn {

    (, address proposal, uint activationBlock) = gluon.app(appId);
    require(activationBlock > block.number, "can not be voted");
    uint quantity = data.balance(msg.sender);
    (uint approvals, uint disapprovals) = data.voteAppUpgrade(proposal, msg.sender, side, quantity);
    emit Voted(appId, proposal, approvals, disapprovals, msg.sender);
    concludeVoting(appId, proposal, approvals, disapprovals);
  }

  function updateVotes(address account, uint quantity, bool increased) private {

    (address[] memory allProposed, bool[] memory sides) = data.getAllProposals(account);
    for (uint i; i < allProposed.length; i++) {
      uint32 appId = GluonCentric(allProposed[i]).id();
      (, , uint activationBlock) = gluon.app(appId);
      if (block.number > activationBlock) continue;
      (uint approvals, uint disapprovals) = data.updateVotes(allProposed[i], sides[i], quantity, increased);
      emit Voted(appId, allProposed[i], approvals, disapprovals, msg.sender);
      concludeVoting(appId, allProposed[i], approvals, disapprovals);
    }
  }

  function concludeVoting(uint32 appId, address proposal, uint approvals, uint disapprovals) private {

    if (approvals.add(disapprovals) >= LegacyToken(governanceToken).totalSupply().mul(quorumPercentage).div(100)) {
      if (approvals > disapprovals) {
        AppGovernance(gluon).approve(appId);
        emit VotingConcluded(appId, proposal, approvals, disapprovals, true);
      } else {
        AppGovernance(gluon).disapprove(appId);
        emit VotingConcluded(appId, proposal, approvals, disapprovals, false);
      }
    }
  }


  function switchOff() external onlyOwner {

    uint32 totalAppsCount = gluon.totalAppsCount();
    for (uint32 appId = 2; appId < totalAppsCount; appId++) {
      AppState appState = AppState(gluon.current(appId));
      require(!appState.isOn(), "One of the apps is still ON");
    }
    switchOff_();
  }

}

interface LegacyToken {

  function totalSupply() external view returns (uint);

  function balanceOf(address who) external view returns (uint);

  function transfer(address to, uint value) external;

  function allowance(address owner, address spender) external view returns (uint);

  function transferFrom(address from, address to, uint value) external;

  function approve(address spender, uint value) external;


  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}