


pragma solidity 0.5.12;


interface Validating {

  modifier notZero(uint number) { require(number > 0, "invalid 0 value"); _; }

  modifier notEmpty(string memory text) { require(bytes(text).length > 0, "invalid empty string"); _; }

  modifier validAddress(address value) { require(value != address(0x0), "invalid address"); _; }

}



pragma solidity 0.5.12;


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
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                    _preBytes_slot,
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
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))


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
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

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
    ) internal pure returns (bytes memory)
    {

        require(_bytes.length >= (_start + _length));

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

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20));
        address tempAddress;
        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }
        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1));
        uint8 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }
        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        require(_bytes.length >= (_start + 2));
        uint16 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }
        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        require(_bytes.length >= (_start + 4));
        uint32 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }
        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {

        require(_bytes.length >= (_start + 8));
        uint64 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }
        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {

        require(_bytes.length >= (_start + 12));
        uint96 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }
        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {

        require(_bytes.length >= (_start + 16));
        uint128 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }
        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32));
        uint256 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));
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
            let fslot := sload(_preBytes_slot)
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

                        mstore(0x0, _preBytes_slot)
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


pragma solidity 0.5.12;


library SafeMath {


  function min(uint x, uint y) internal pure returns (uint) { return x <= y ? x : y; }

  function max(uint x, uint y) internal pure returns (uint) { return x >= y ? x : y; }



  function plus(uint x, uint y) internal pure returns (uint z) { require((z = x + y) >= x, "bad addition"); }


  function minus(uint x, uint y) internal pure returns (uint z) { require((z = x - y) <= x, "bad subtraction"); }



  function times(uint x, uint y) internal pure returns (uint z) { require(y == 0 || (z = x * y) / y == x, "bad multiplication"); }


  function mod(uint x, uint y) internal pure returns (uint z) {

    require(y != 0, "bad modulo; using 0 as divisor");
    z = x % y;
  }

  function div(uint a, uint b) internal pure returns (uint c) {

    c = a / b;
  }

}


pragma solidity 0.5.12;


contract Token {

  uint public totalSupply;

  function balanceOf(address _owner) public view returns (uint balance);


  function transfer(address _to, uint _value) public returns (bool success);


  function transferFrom(address _from, address _to, uint _value) public returns (bool success);


  function approve(address _spender, uint _value) public returns (bool success);


  function allowance(address _owner, address _spender) public view returns (uint remaining);


  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);
}


pragma solidity 0.5.12;


interface AppGovernance {

  function approve(uint32 id) external;

  function disapprove(uint32 id) external;

  function activate(uint32 id) external;

}


pragma solidity 0.5.12;


interface AppLogic {


  function upgrade() external;


  function credit(address account, address asset, uint quantity) external;


  function debit(address account, bytes calldata parameters) external returns (address asset, uint quantity);

}


pragma solidity 0.5.12;

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


pragma solidity 0.5.12;


interface GluonView {

  function app(uint32 id) external view returns (address current, address proposal, uint activationBlock);

  function current(uint32 id) external view returns (address);

  function history(uint32 id) external view returns (address[] memory);

  function getBalance(uint32 id, address asset) external view returns (uint);

  function isAnyLogic(uint32 id, address logic) external view returns (bool);

  function isAppOwner(uint32 id, address appOwner) external view returns (bool);

  function proposals(address logic) external view returns (bool);

  function totalAppsCount() external view returns(uint32);

}


pragma solidity 0.5.12;



contract GluonCentric {


  uint32 internal constant REGISTRY_INDEX = 0;
  uint32 internal constant STAKE_INDEX = 1;

  uint32 public id;
  address public gluon;

  constructor(uint32 id_, address gluon_) public {
    id = id_;
    gluon = gluon_;
  }

  modifier onlyCurrentLogic { require(currentLogic() == msg.sender, "invalid sender; must be current logic contract"); _; }


  modifier onlyGluon { require(gluon == msg.sender, "invalid sender; must be gluon contract"); _; }


  modifier onlyOwner { require(GluonView(gluon).isAppOwner(id, msg.sender), "invalid sender; must be app owner"); _; }


  function currentLogic() public view returns (address) { return GluonView(gluon).current(id); }


}


pragma solidity 0.5.12;


interface GluonWallet {

  function depositEther(uint32 id) external payable;

  function depositToken(uint32 id, address token, uint quantity) external;

  function withdraw(uint32 id, bytes calldata parameters) external;

  function transfer(uint32 from, uint32 to, bytes calldata parameters) external;

}


pragma solidity 0.5.12;




contract Upgrading {

  address public upgradeOperator;

  modifier onlyOwner { require(false, "modifier onlyOwner must be implemented"); _; }

  modifier onlyUpgradeOperator { require(upgradeOperator == msg.sender, "invalid sender; must be upgrade operator"); _; }

  function setUpgradeOperator(address upgradeOperator_) external onlyOwner { upgradeOperator = upgradeOperator_; }

  function upgrade_(AppGovernance appGovernance, uint32 id) internal {

    appGovernance.activate(id);
    delete upgradeOperator;
  }
}


pragma solidity 0.5.12;


interface OldRegistry {

  function contains(address apiKey) external view returns (bool);

  function register(address apiKey) external;

  function registerWithUserAgreement(address apiKey, bytes32 userAgreement) external;

  function translate(address apiKey) external view returns (address);

}


pragma solidity 0.5.12;



contract RegistryData is GluonCentric {


  mapping(address => address) public accounts;

  constructor(address gluon) GluonCentric(REGISTRY_INDEX, gluon) public { }

  function addKey(address apiKey, address account) external onlyCurrentLogic {

    accounts[apiKey] = account;
  }

}


pragma solidity 0.5.12;










contract RegistryLogic is Upgrading, Validating, AppLogic, AppState, GluonCentric {


  RegistryData public data;
  OldRegistry public old;

  event Registered(address apiKey, address indexed account);

  constructor(address gluon, address old_, address data_) GluonCentric(REGISTRY_INDEX, gluon) public {
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


  function upgrade() external onlyUpgradeOperator {

    retire_();
    upgrade_(AppGovernance(gluon), id);
  }

  function credit(address, address, uint) external { revert("not supported"); }


  function debit(address, bytes calldata) external returns (address, uint) { revert("not supported"); }



  function switchOff() external onlyOwner {

    uint32 totalAppsCount = GluonView(gluon).totalAppsCount();
    for (uint32 i = 2; i < totalAppsCount; i++) {
      AppState appState = AppState(GluonView(gluon).current(i));
      require(!appState.isOn(), "One of the apps is still ON");
    }
    switchOff_();
  }

}


pragma solidity 0.5.12;


interface Governing {

  function deleteVoteTally(address proposal) external;

  function activationInterval() external view returns (uint);

}


pragma solidity 0.5.12;


interface Redeeming {

  function redeem(address account, uint quantity) external returns (uint toRestake, uint toStake, uint toWithdraw);

}


pragma solidity 0.5.12;




contract StakeData is GluonCentric {

  using SafeMath for uint;

  mapping(address => address[]) public accountToProposals;
  mapping(address => bool[]) public accountToSides;
  mapping(address => mapping(bool => uint)) public voteTally; /// proposal => side(true/false) => totalVotes
  mapping(address => address) public accountLocation;         /// account => logic
  mapping(address => uint) public balance;

  constructor(address gluon) GluonCentric(STAKE_INDEX, gluon) public { }

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
      voteTally[proposal][!side] = voteTally[proposal][!side].minus(quantity);
      accountToSides[account][index] = side;
    }
    voteTally[proposal][side] = voteTally[proposal][side].plus(quantity);
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
      if (!GluonView(gluon).proposals(allProposed[i - 1])) {
        allProposed[i - 1] = allProposed[allProposed.length - 1];
        allProposed.pop();
        sides[i - 1] = sides[sides.length - 1];
        sides.pop();
      }
    }
  }

  function updateVotes(address proposal, bool side, uint quantity, bool increased) external onlyCurrentLogic returns (uint approvals, uint disapprovals) {

    uint tally = voteTally[proposal][side];
    voteTally[proposal][side] = increased ? tally.plus(quantity) : tally.minus(quantity);
    return getVoteTally(proposal);
  }

  function getVoteTally(address proposal) public view returns (uint approvals, uint disapprovals) {

    approvals = voteTally[proposal][true];
    disapprovals = voteTally[proposal][false];
  }

}


pragma solidity 0.5.12;
















contract StakeLogicV1 is Upgrading, Validating, AppLogic, AppState, GluonCentric, Governing, Redeeming {

  using BytesLib for bytes;
  using SafeMath for uint;
  address constant private ETH = address(0x0);
  bool initiated;
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

  StakeData public data;
  Token public LEV;
  address[] public tokens;
  uint[] public toBeDistributed;

  uint public intervalSize;
  uint public currentIntervalIndex;
  uint public quorumPercentage;
  uint public activationInterval;
  mapping(uint => Interval) public intervals;
  mapping(address => UserStake) public stakes;

  event Staked(address indexed user, uint levs, uint start, uint end, uint intervalIndex);
  event Restaked(address indexed user, uint levs, uint start, uint end, uint intervalIndex);
  event Redeemed(address indexed user, uint levs, uint start, uint end, uint intervalIndex);
  event Reward(address indexed user, address asset, uint reward, uint start, uint end, uint intervalIndex);
  event NewInterval(uint start, uint end, uint intervalIndex);
  event Voted(uint32 indexed appId, address indexed proposal, uint approvals, uint disapprovals, address account);
  event VotingConcluded(uint32 indexed appId, address indexed proposal, uint approvals, uint disapprovals, bool result);

  constructor(address gluon, address data_, address lev, address[] memory tokens_, address apiKey, uint intervalSize_, uint quorumPercentage_, uint activationInterval_)
  GluonCentric(STAKE_INDEX, gluon)
  public
  validAddress(gluon)
  validAddress(lev)
  validAddress(apiKey)
  notZero(intervalSize_)
  notZero(activationInterval_)
  {
    data = StakeData(data_);
    LEV = Token(lev);
    tokens = tokens_;
    for (uint i = 0; i < tokens.length; i++) {
      toBeDistributed.push(0);
    }
    quorumPercentage = quorumPercentage_;
    intervalSize = intervalSize_;
    registerApiKey_(apiKey);
    activationInterval = activationInterval_;
  }

  function() external payable {}

  function governanceToken() external view returns (address) {return address(LEV);}


  function init(uint intervalId) external onlyOwner {

    require(initiated == false, "already initiated");
    currentIntervalIndex = intervalId;
    intervals[currentIntervalIndex].start = block.number;
    intervals[currentIntervalIndex].end = block.number + intervalSize;
    for (uint i = 0; i < tokens.length; i++) intervals[currentIntervalIndex].rewards.push(0);
    initiated = true;
  }

  function setIntervalSize(uint intervalSize_) external notZero(intervalSize_) onlyOwner {

    ensureInterval();
    intervalSize = intervalSize_;
  }

  function addToken(address token) external validAddress(token) onlyOwner whenOn {

    require(tokens.length < 50, "Can not add more than 50 tokens");
    tokens.push(token);
    toBeDistributed.push(0);
    intervals[currentIntervalIndex].rewards.push(0);
  }

  function ensureInterval() public whenOn {

    if (intervals[currentIntervalIndex].end > block.number) return;

    Interval storage interval = intervals[currentIntervalIndex];
    for (uint i = 0; i < interval.rewards.length; i++) {
      uint reward = interval.worth == 0 ? 0 : calculateIntervalReward(interval.start, interval.end, i);
      toBeDistributed[i] = toBeDistributed[i].plus(reward);
      interval.rewards[i] = reward;
    }

    uint diff = (block.number - interval.end) % intervalSize;
    currentIntervalIndex += 1;
    uint start = interval.end;
    uint end = block.number - diff + intervalSize;
    intervals[currentIntervalIndex].start = start;
    intervals[currentIntervalIndex].end = end;
    for (uint i = 0; i < tokens.length; i++) intervals[currentIntervalIndex].rewards.push(0);
    emit NewInterval(start, end, currentIntervalIndex);
  }

  function restake(address account, uint quantity) private returns (uint, uint) {

    Redeeming stakeLocation = Redeeming(data.accountLocation(account) == address(0x0) ? address(this) : data.accountLocation(account));
    (uint toRestake, uint toStake, uint toWithdraw) = stakeLocation.redeem(account, quantity);
    if (toRestake == 0) return (toStake, toWithdraw);

    UserStake storage stake = stakes[account];
    stake.quantity = toRestake;
    Interval storage interval = intervals[currentIntervalIndex];
    stake.intervalIndex = currentIntervalIndex;
    stake.worth = stake.quantity.times(interval.end.minus(interval.start));
    interval.worth = interval.worth.plus(stake.worth);
    emit Restaked(account, stake.quantity, interval.start, interval.end, currentIntervalIndex);
    return (toStake, toWithdraw);
  }

  function stake(address account, uint quantity) private whenOn returns (uint toStake, uint toWithdraw) {

    ensureInterval();
    (toStake, toWithdraw) = restake(account, quantity);
    data.updateAccountLocation(account, address(this));
    data.removeResolvedProposals(account);
    if (toWithdraw > 0) {
      updateVotes(account, toWithdraw, false);
    }
    if (toStake > 0) {
      updateVotes(account, toStake, true);
      stakeInCurrentPeriod(account, toStake);
    }
    data.updateBalance(account, quantity);
  }

  function stakeInCurrentPeriod(address account, uint quantity) private {

    Interval storage interval = intervals[currentIntervalIndex];
    stakes[account].intervalIndex = currentIntervalIndex;
    uint worth = quantity.times(interval.end.minus(block.number));
    stakes[account].worth = stakes[account].worth.plus(worth);
    stakes[account].quantity = stakes[account].quantity.plus(quantity);
    interval.worth = interval.worth.plus(worth);
    emit Staked(account, quantity, interval.start, interval.end, currentIntervalIndex);
  }

  function calculateIntervalReward(uint start, uint end, uint index) public view returns (uint) {

    uint balance = tokens[index] == ETH ? address(this).balance : Token(tokens[index]).balanceOf(address(this));
    return balance.minus(toBeDistributed[index]).times(end.minus(start)).div(block.number.minus(start));
  }

  function registerApiKey(address apiKey) public onlyOwner {registerApiKey_(apiKey);}


  function registerApiKey_(address apiKey) private {

    RegistryLogic registry = RegistryLogic(GluonView(gluon).current(REGISTRY_INDEX));
    registry.register(apiKey);
  }

  function withdrawFromApp(uint32 appId, bytes memory withdrawData) public {

    uint action = withdrawData.toUint(0);
    require(action == 1 || action == 5, "only assisted withdraw or exit on halt is allowed");
    GluonWallet(gluon).withdraw(appId, withdrawData);
  }

  function transferToLatestStakeAfterRetire() public whenRetired {

    for (uint i = 0; i < tokens.length; i++) {
      uint balance = tokens[i] == ETH ? address(this).balance : Token(tokens[i]).balanceOf(address(this));
      uint quantity = balance.minus(toBeDistributed[i]);
      transfer(tokens[i], currentLogic(), quantity);
    }
  }


  function redeem(address account, uint quantity) public onlyCurrentLogic returns (uint, uint, uint) {// (toRestake, toStake, toWithdraw)

    UserStake memory userStake = stakes[account];
    if (userStake.intervalIndex == 0) return (0, quantity, 0);

    uint staked = userStake.quantity;
    if (userStake.intervalIndex == currentIntervalIndex) {
      require(quantity > staked, "Can not reduce stake in the latest interval");
      return (0, quantity.minus(staked), 0);
    }

    uint toWithdraw = staked > quantity ? staked.minus(quantity) : 0;
    uint toRestake = staked.minus(toWithdraw);
    uint toStake = quantity > staked ? quantity.minus(staked) : 0;

    uint intervalIndex = userStake.intervalIndex;
    Interval memory interval = intervals[intervalIndex];
    uint worth = userStake.worth;
    delete stakes[account];
    distributeRewards(account, worth, interval, intervalIndex);
    emit Redeemed(account, toWithdraw, interval.start, interval.end, intervalIndex);
    return (toRestake, toStake, toWithdraw);
  }

  function distributeRewards(address account, uint worth, Interval memory interval, uint intervalIndex) private {

    if (worth == 0) return;
    for (uint i = 0; i < tokens.length; i++) {
      uint reward = interval.rewards[i].times(worth).div(interval.worth);
      if (reward == 0) continue;
      toBeDistributed[i] = toBeDistributed[i].minus(reward);
      transfer(tokens[i], account, reward);
      emit Reward(account, tokens[i], reward, interval.start, interval.end, intervalIndex);
    }
  }

  function transfer(address token, address to, uint quantity) private {

    if (quantity == 0) return;
    token == ETH ?
    require(address(uint160(to)).send(quantity), "failed to transfer ether") : // explicit casting to `address payable`
    transferTokensToAccountSecurely(Token(token), quantity, to);
  }

  function transferTokensToAccountSecurely(Token token, uint quantity, address to) private {

    uint balanceBefore = token.balanceOf(to);
    require(token.transfer(to, quantity), "failure to transfer quantity from token");
    uint balanceAfter = token.balanceOf(to);
    require(balanceAfter.minus(balanceBefore) == quantity, "bad Token; transferFrom erroneously reported of successful transfer");
  }

  function getTokens() public view returns (address[] memory){return tokens;}


  function getToBeDistributed() public view returns (uint[] memory) {return toBeDistributed;}


  function getInterval(uint intervalIndex) public view returns (uint worth, uint[] memory rewards, uint start, uint end){

    Interval memory interval = intervals[intervalIndex];
    worth = interval.worth;
    rewards = interval.rewards;
    start = interval.start;
    end = interval.end;
  }

  function deleteVoteTally(address proposal) external onlyGluon {data.deleteVoteTally(proposal);}



  function upgrade() external whenOn onlyUpgradeOperator {

    intervals[currentIntervalIndex].end = block.number;
    ensureInterval();
    retire_();
    upgrade_(AppGovernance(gluon), id);
  }

  function credit(address account, address asset, uint quantity) external whenOn onlyGluon {

    require(asset == address(LEV), "can only deposit lev tokens");
    stake(account, data.balance(account).plus(quantity));
  }

  function debit(address account, bytes calldata parameters) external whenOn onlyGluon returns (address asset, uint quantity) {

    (asset, quantity) = abi.decode(parameters, (address, uint));
    require(asset == address(LEV), "can only withdraw lev tokens");
    stake(account, data.balance(account).minus(quantity));
  }


  function voteAppUpgrade(uint32 appId, bool side) external whenOn {

    (, address proposal, uint activationBlock) = GluonView(gluon).app(appId);
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
      (,,uint activationBlock) = GluonView(gluon).app(appId);
      if (block.number > activationBlock) continue;
      (uint approvals, uint disapprovals) = data.updateVotes(allProposed[i], sides[i], quantity, increased);
      emit Voted(appId, allProposed[i], approvals, disapprovals, msg.sender);
      concludeVoting(appId, allProposed[i], approvals, disapprovals);
    }
  }

  function concludeVoting(uint32 appId, address proposal, uint approvals, uint disapprovals) private {

    if (approvals.plus(disapprovals) >= LEV.totalSupply().times(quorumPercentage).div(100)) {
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

    uint32 totalAppsCount = GluonView(gluon).totalAppsCount();
    for (uint32 appId = 2; appId < totalAppsCount; appId++) {
      AppState appState = AppState(GluonView(gluon).current(appId));
      require(!appState.isOn(), "One of the apps is still ON");
    }
    switchOff_();
  }

}