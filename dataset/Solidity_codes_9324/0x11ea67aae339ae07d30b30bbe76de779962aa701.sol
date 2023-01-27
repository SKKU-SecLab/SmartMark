
pragma solidity ^0.4.19;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


library Math {

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {

    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {

    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;
  }
}




contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);

}


contract Controlled {

    address public controller;

    function Controlled() {

         controller = msg.sender;
    }

    modifier onlyController {

        require(msg.sender == controller);
        _;
    }

    function changeController(address _newController) onlyController {

        controller = _newController;
    }
}


contract TokenController {

    function proxyPayment(address _owner) payable returns(bool);


    function onTransfer(address _from, address _to, uint _amount) returns(bool);


    function onApprove(address _owner, address _spender, uint _amount) returns(bool);

}



contract MiniMeToken is Controlled {


    string public name;               //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;               //An identifier: e.g. REP
    string public version = "MMT_0.1"; //An arbitrary versioning scheme


    struct    Checkpoint {

        uint128 fromBlock;

        uint128 value;
    }

    MiniMeToken public parentToken;

    uint public parentSnapShotBlock;

    uint public creationBlock;

    mapping (address => Checkpoint[]) balances;

    mapping (address => mapping (address => uint256)) allowed;

    Checkpoint[] totalSupplyHistory;

    bool public transfersEnabled;

    MiniMeTokenFactory public tokenFactory;


    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) {

        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                // Set the name
        decimals = _decimalUnits;                            // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }



    function transfer(address _to, uint256 _amount) returns (bool success) {

        require(transfersEnabled);
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {


        if (msg.sender != controller) {
            require(transfersEnabled);

            require(allowed[_from][msg.sender] >= _amount);
            allowed[_from][msg.sender] -= _amount;
        }
        doTransfer(_from, _to, _amount);
        return true;
    }

    function doTransfer(address _from, address _to, uint _amount
    ) internal {


             if (_amount == 0) {
             Transfer(_from, _to, _amount);    // Follow the spec to issue the event when transfer 0
             return;
             }

             require(parentSnapShotBlock < block.number);

             require((_to != 0) && (_to != address(this)));

             uint256 previousBalanceFrom = balanceOfAt(_from, block.number);
             require(previousBalanceFrom >= _amount);

             if (isContract(controller)) {
                 require(TokenController(controller).onTransfer(_from, _to, _amount));
             }

             updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

             uint256 previousBalanceTo = balanceOfAt(_to, block.number);
             require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
             updateValueAtNow(balances[_to], previousBalanceTo + _amount);

             Transfer(_from, _to, _amount);

    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balanceOfAt(_owner, block.number);
    }

    function approve(address _spender, uint256 _amount) returns (bool success) {

        require(transfersEnabled);

        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender
    ) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }

    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) public returns (bool success) {

        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    function totalSupply() constant returns (uint) {

        return totalSupplyAt(block.number);
    }



    function balanceOfAt(address _owner, uint _blockNumber) public view
        returns (uint) {


        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
               return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
               return 0;
            }

        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    function totalSupplyAt(uint _blockNumber) public view returns(uint) {


        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
               return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
               return 0;
            }

        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }


    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) returns(address) {

        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }


    function generateTokens(address _owner, uint _amount
    ) onlyController returns (bool) {

        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    function destroyTokens(address _owner, uint256 _amount
    ) onlyController returns (bool) {

        uint256 curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint256 previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }



    function enableTransfers(bool _transfersEnabled) onlyController {

        transfersEnabled = _transfersEnabled;
    }


    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) internal view returns (uint) {

        if (checkpoints.length == 0) return 0;

        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
               min = mid;
            } else {
               max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal    {

        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
                 Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
                 newCheckPoint.fromBlock =    uint128(block.number);
                 newCheckPoint.value = uint128(_value);
             } else {
                 Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
                 oldCheckPoint.value = uint128(_value);
             }
    }

    function isContract(address _addr) internal view returns(bool) {

        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function min(uint a, uint b) internal pure returns (uint) {

        return a < b ? a : b;
    }

    function ()    payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }


    function claimTokens(address _token) onlyController {

        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}



contract MiniMeTokenFactory {


    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) returns (MiniMeToken) {

        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}




contract MiniMeIrrevocableVestedToken is MiniMeToken {


    using SafeMath for uint256;

    uint256 MAX_GRANTS_PER_ADDRESS = 20;
    struct TokenGrant {
    address granter;    // 20 bytes
    uint256 value;         // 32 bytes
    uint64 cliff;
    uint64 vesting;
    uint64 start;        // 3 * 8 = 24 bytes
    bool revokable;
    bool burnsOnRevoke;    // 2 * 1 = 2 bits? or 2 bytes?
    } // total 78 bytes = 3 sstore per operation (32 per sstore)

    mapping (address => TokenGrant[]) public grants;

    event NewTokenGrant(address indexed from, address indexed to, uint256 value, uint64 start, uint64 cliff, uint64 vesting, uint256 grantId);

    mapping (address => bool) canCreateGrants;
    address vestingWhitelister;

    modifier canTransfer(address _sender, uint _value) {

    require(_value <= spendableBalanceOf(_sender));
    _;
    }

    modifier onlyVestingWhitelister {

    require(msg.sender == vestingWhitelister);
    _;
    }

    function MiniMeIrrevocableVestedToken (
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public MiniMeToken(_tokenFactory, _parentToken, _parentSnapShotBlock, _tokenName, _decimalUnits, _tokenSymbol, _transfersEnabled) {
    vestingWhitelister = msg.sender;
    doSetCanCreateGrants(vestingWhitelister, true);
    }

    function transfer(address _to, uint _value)
             canTransfer(msg.sender, _value)
             public
             returns (bool success) {

    return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value)
             canTransfer(_from, _value)
             public
             returns (bool success) {

    return super.transferFrom(_from, _to, _value);
    }

    function spendableBalanceOf(address _holder) constant public returns (uint) {

    return transferableTokens(_holder, uint64(now));
    }

    function grantVestedTokens(
    address _to,
    uint256 _value,
    uint64 _start,
    uint64 _cliff,
    uint64 _vesting,
    bool _revokable,
    bool _burnsOnRevoke
    ) public {


    require(_cliff >= _start && _vesting >= _cliff);
    require(canCreateGrants[msg.sender]);

    require(tokenGrantsCount(_to) < MAX_GRANTS_PER_ADDRESS);    // To prevent a user being spammed and have his balance locked (out of gas attack when calculating vesting).

    uint256 count = grants[_to].push(
               TokenGrant(
                   _revokable ? msg.sender : 0, // avoid storing an extra 20 bytes when it is non-revokable
                   _value,
                   _cliff,
                   _vesting,
                   _start,
                   _revokable,
                   _burnsOnRevoke
               )
               );

    transfer(_to, _value);

    NewTokenGrant(msg.sender, _to, _value, _cliff, _vesting, _start, count - 1);
    }

    function setCanCreateGrants(address _addr, bool _allowed) onlyVestingWhitelister public {

    doSetCanCreateGrants(_addr, _allowed);
    }

    function doSetCanCreateGrants(address _addr, bool _allowed) internal {

    canCreateGrants[_addr] = _allowed;
    }

    function changeVestingWhitelister(address _newWhitelister) onlyVestingWhitelister public {

    doSetCanCreateGrants(vestingWhitelister, false);
    vestingWhitelister = _newWhitelister;
    doSetCanCreateGrants(vestingWhitelister, true);
    }

    function revokeTokenGrant(address _holder, uint256 _grantId) public {

    TokenGrant storage grant = grants[_holder][_grantId];

    require(grant.revokable);
    require(grant.granter == msg.sender); // Only granter can revoke it

    address receiver = grant.burnsOnRevoke ? 0xdead : msg.sender;

    uint256 nonVested = nonVestedTokens(grant, uint64(now));

    delete grants[_holder][_grantId];
    grants[_holder][_grantId] = grants[_holder][grants[_holder].length.sub(1)];
    grants[_holder].length -= 1;

    var previousBalanceReceiver = balanceOfAt(receiver, block.number);

    updateValueAtNow(balances[receiver], previousBalanceReceiver + nonVested);

    var previousBalance_holder = balanceOfAt(_holder, block.number);

    updateValueAtNow(balances[_holder], previousBalance_holder - nonVested);

    Transfer(_holder, receiver, nonVested);
    }

    function transferableTokens(address holder, uint64 time) public view returns (uint256) {

    uint256 grantIndex = tokenGrantsCount(holder);

    if (grantIndex == 0) return balanceOf(holder); // shortcut for holder without grants

    uint256 nonVested = 0;
    for (uint256 i = 0; i < grantIndex; i++) {
        nonVested = SafeMath.add(nonVested, nonVestedTokens(grants[holder][i], time));
    }

    uint256 vestedTransferable = SafeMath.sub(balanceOf(holder), nonVested);

    return Math.min256(vestedTransferable, balanceOf(holder));
    }

    function tokenGrantsCount(address _holder) public view returns (uint256 index) {

    return grants[_holder].length;
    }

    function calculateVestedTokens(
    uint256 tokens,
    uint256 time,
    uint256 start,
    uint256 cliff,
    uint256 vesting) internal view returns (uint256)
    {

        if (time < cliff) return 0;
        if (time >= vesting) return tokens;


        uint256 vestedTokens = SafeMath.div(
                                    SafeMath.mul(
                                       tokens,
                                       SafeMath.sub(time, start)
                                       ),
                                    SafeMath.sub(vesting, start)
                                    );

        return vestedTokens;
    }

    function tokenGrant(address _holder, uint256 _grantId) public view returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting, bool revokable, bool burnsOnRevoke) {

    TokenGrant storage grant = grants[_holder][_grantId];

    granter = grant.granter;
    value = grant.value;
    start = grant.start;
    cliff = grant.cliff;
    vesting = grant.vesting;
    revokable = grant.revokable;
    burnsOnRevoke = grant.burnsOnRevoke;

    vested = vestedTokens(grant, uint64(now));
    }

    function vestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {

    return calculateVestedTokens(
        grant.value,
        uint256(time),
        uint256(grant.start),
        uint256(grant.cliff),
        uint256(grant.vesting)
    );
    }

    function nonVestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {

    return grant.value.sub(vestedTokens(grant, time));
    }

    function lastTokenIsTransferableDate(address holder) constant public returns (uint64 date) {

    date = uint64(now);
    uint256 grantIndex = grants[holder].length;
    for (uint256 i = 0; i < grantIndex; i++) {
        date = Math.max64(grants[holder][i].vesting, date);
    }
    }

}


contract MiniMeIrrVesDivToken is MiniMeIrrevocableVestedToken {


    event DividendDeposited(address indexed _depositor, uint256 _blockNumber, uint256 _timestamp, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);
    event DividendClaimed(address indexed _claimer, uint256 _dividendIndex, uint256 _claim);
    event DividendRecycled(address indexed _recycler, uint256 _blockNumber, uint256 _timestamp, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);

    uint256 public RECYCLE_TIME = 1 years;

    function MiniMeIrrVesDivToken (
         address _tokenFactory,
         address _parentToken,
         uint _parentSnapShotBlock,
         string _tokenName,
         uint8 _decimalUnits,
         string _tokenSymbol,
         bool _transfersEnabled
    ) public MiniMeIrrevocableVestedToken(_tokenFactory, _parentToken, _parentSnapShotBlock, _tokenName, _decimalUnits, _tokenSymbol, _transfersEnabled) {}

    struct Dividend {
    uint256 blockNumber;
    uint256 timestamp;
    uint256 amount;
    uint256 claimedAmount;
    uint256 totalSupply;
    bool recycled;
    mapping (address => bool) claimed;
    }

    Dividend[] public dividends;

    mapping (address => uint256) dividendsClaimed;

    modifier validDividendIndex(uint256 _dividendIndex) {

    require(_dividendIndex < dividends.length);
    _;
    }

    function depositDividend() public payable
    onlyController
    {

    uint256 currentSupply = super.totalSupplyAt(block.number);
    uint256 dividendIndex = dividends.length;
    uint256 blockNumber = SafeMath.sub(block.number, 1);
    dividends.push(
         Dividend(
         blockNumber,
         getNow(),
         msg.value,
         0,
         currentSupply,
         false
         )
    );
    DividendDeposited(msg.sender, blockNumber, getNow(), msg.value, currentSupply, dividendIndex);
    }

    function claimDividend(uint256 _dividendIndex) public
    validDividendIndex(_dividendIndex)
    {

    Dividend storage dividend = dividends[_dividendIndex];
    require(dividend.claimed[msg.sender] == false);
    require(dividend.recycled == false);
    uint256 balance = super.balanceOfAt(msg.sender, dividend.blockNumber);
    uint256 claim = balance.mul(dividend.amount).div(dividend.totalSupply);
    dividend.claimed[msg.sender] = true;
    dividend.claimedAmount = SafeMath.add(dividend.claimedAmount, claim);
    if (claim > 0) {
         msg.sender.transfer(claim);
         DividendClaimed(msg.sender, _dividendIndex, claim);
    }
    }

    function claimDividendAll() public {

    require(dividendsClaimed[msg.sender] < dividends.length);
    for (uint i = dividendsClaimed[msg.sender]; i < dividends.length; i++) {
         if ((dividends[i].claimed[msg.sender] == false) && (dividends[i].recycled == false)) {
         dividendsClaimed[msg.sender] = SafeMath.add(i, 1);
         claimDividend(i);
         }
    }
    }

    function recycleDividend(uint256 _dividendIndex) public
    onlyController
    validDividendIndex(_dividendIndex)
    {

    Dividend storage dividend = dividends[_dividendIndex];
    require(dividend.recycled == false);
    require(dividend.timestamp < SafeMath.sub(getNow(), RECYCLE_TIME));
    dividends[_dividendIndex].recycled = true;
    uint256 currentSupply = super.totalSupplyAt(block.number);
    uint256 remainingAmount = SafeMath.sub(dividend.amount, dividend.claimedAmount);
    uint256 dividendIndex = dividends.length;
    uint256 blockNumber = SafeMath.sub(block.number, 1);
    dividends.push(
         Dividend(
         blockNumber,
         getNow(),
         remainingAmount,
         0,
         currentSupply,
         false
         )
    );
    DividendRecycled(msg.sender, blockNumber, getNow(), remainingAmount, currentSupply, dividendIndex);
    }

    function getNow() internal constant returns (uint256) {

    return now;
    }
}


contract ESCBCoin is MiniMeIrrVesDivToken {

    function ESCBCoin (
      address _tokenFactory
    ) public MiniMeIrrVesDivToken(
    _tokenFactory,
    0x0,            // no parent token
    0,               // no snapshot block number from parent
    "ESCB token",    // Token name
    18,             // Decimals
    "ESCB",         // Symbol
    true            // Enable transfers
    ) {}
}



contract ESCBCoinPlaceholder is TokenController {

    address public tokenSale;
    ESCBCoin public token;

    function ESCBCoinPlaceholder(address _sale, address _ESCBCoin) public {

    tokenSale = _sale;
    token = ESCBCoin(_ESCBCoin);
    }

    function changeController(address network) public {

    assert(msg.sender == tokenSale);
    token.changeController(network);
    selfdestruct(network); // network gets all amount
    }

    function proxyPayment(address _owner) public payable returns (bool) {

    revert();
    return false;
    }

    function onTransfer(address _from, address _to, uint _amount) public returns (bool) {

    return true;
    }

    function onApprove(address _owner, address _spender, uint _amount) public returns (bool) {

    return true;
    }
}


contract AbstractSale {

    function saleFinalized() public returns (bool);

    function minGoalReached() public returns (bool);

}

contract SaleWallet {

    using SafeMath for uint256;

    enum State { Active, Refunding }
    State public currentState;

    mapping (address => uint256) public deposited;

    event Withdrawal();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);
    event Deposit(address beneficiary, uint256 weiAmount);

    address public multisig;
    AbstractSale public tokenSale;

    function SaleWallet(address _multisig, address _tokenSale) {

    currentState = State.Active;
    multisig = _multisig;
    tokenSale = AbstractSale(_tokenSale);
    }

    function deposit(address investor, uint256 amount) public {

    require(currentState == State.Active);
    require(msg.sender == address(tokenSale));
    deposited[investor] = deposited[investor].add(amount);
    Deposit(investor, amount);
    }

    function withdraw() public {

    require(currentState == State.Active);
    assert(msg.sender == multisig);    // Only the multisig can request it
    if (tokenSale.minGoalReached()) {    // Allow when sale reached minimum goal
        return doWithdraw();
    }
    }

    function doWithdraw() internal {

    assert(multisig.send(this.balance));
    Withdrawal();
    }

    function enableRefunds() public {

    require(currentState == State.Active);
    assert(msg.sender == multisig);    // Only the multisig can request it
    require(!tokenSale.minGoalReached());    // Allow when minimum goal isn't reached
    require(tokenSale.saleFinalized()); // Allow when sale is finalized
    currentState = State.Refunding;
    RefundsEnabled();
    }

    function refund(address investor) public {

    require(currentState == State.Refunding);
    require(msg.sender == address(tokenSale));
    require(deposited[investor] != 0);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    assert(investor.send(depositedValue));
    Refunded(investor, depositedValue);
    }

    function () public payable {}
}



 contract ESCBTokenSale is TokenController {

   uint256 public initialTime;           // Time in which the sale starts. Inclusive. sale will be opened at initial time.
   uint256 public controlTime;           // The Unix time in which the sale needs to check on the refunding start.
   uint256 public price;                 // Number of wei-ESCBCoin tokens for 1 ether
   address public ESCBDevMultisig;       // The address to hold the funds donated

   uint256 public affiliateBonusPercent = 2;     // Purpose in percentage of payment via referral
   uint256 public totalCollected = 0;            // In wei
   bool public saleStopped = false;              // Has ESCB Dev stopped the sale?
   bool public saleFinalized = false;            // Has ESCB Dev finalized the sale?

   mapping (address => bool) public activated;   // Address confirmates that wants to activate the sale

   ESCBCoin public token;                         // The token
   ESCBCoinPlaceholder public networkPlaceholder; // The network placeholder
   SaleWallet public saleWallet;                  // Wallet that receives all sale funds

   uint256 constant public dust = 1 finney; // Minimum investment
   uint256 public minGoal;                  // amount of minimum fund in wei
   uint256 public goal;                     // Goal for IITO in wei
   uint256 public currentStage = 1;         // Current stage
   uint256 public allocatedStage = 1;       // Current stage when was allocated tokens for ESCB
   uint256 public usedTotalSupply = 0;      // This uses for calculation ESCB allocation part

   event ActivatedSale();
   event FinalizedSale();
   event NewBuyer(address indexed holder, uint256 ESCBCoinAmount, uint256 etherAmount);
   event NewExternalFoundation(address indexed holder, uint256 ESCBCoinAmount, uint256 etherAmount, bytes32 externalId);
   event AllocationForESCBFund(address indexed holder, uint256 ESCBCoinAmount);
   event NewStage(uint64 numberStage);
   function ESCBTokenSale (uint _initialTime, uint _controlTime, address _ESCBDevMultisig, uint256 _price)
            non_zero_address(_ESCBDevMultisig) {
     assert (_initialTime >= getNow());
     assert (_initialTime < _controlTime);

     initialTime = _initialTime;
     controlTime = _controlTime;
     ESCBDevMultisig = _ESCBDevMultisig;
     price = _price;
   }

   modifier only(address x) {

     require(msg.sender == x);
     _;
   }

   modifier only_before_sale {

     require(getNow() < initialTime);
     _;
   }

   modifier only_during_sale_period {

     require(getNow() >= initialTime);

     require(getNow() < controlTime || minGoalReached());
     _;
   }

   modifier only_after_sale {

     require(getNow() >= controlTime || goalReached());
     _;
   }

   modifier only_sale_stopped {

     require(saleStopped);
     _;
   }

   modifier only_sale_not_stopped {

     require(!saleStopped);
     _;
   }

   modifier only_before_sale_activation {

     require(!isActivated());
     _;
   }

   modifier only_sale_activated {

     require(isActivated());
     _;
   }

   modifier only_finalized_sale {

     require(getNow() >= controlTime || goalReached());
     require(saleFinalized);
     _;
   }

   modifier non_zero_address(address x) {

     require(x != 0);
     _;
   }

   modifier minimum_value(uint256 x) {

     require(msg.value >= x);
     _;
   }

   function setESCBCoin(address _token, address _networkPlaceholder, address _saleWallet, uint256 _minGoal, uint256 _goal)
            payable
            non_zero_address(_token)
            only(ESCBDevMultisig)
            public {


     require(_networkPlaceholder != 0);
     require(_saleWallet != 0);

     assert(!activated[this]);

     token = ESCBCoin(_token);
     networkPlaceholder = ESCBCoinPlaceholder(_networkPlaceholder);
     saleWallet = SaleWallet(_saleWallet);

     assert(token.controller() == address(this));             // sale is controller
     assert(token.totalSupply() == 0);                        // token is empty

     assert(networkPlaceholder.tokenSale() == address(this)); // placeholder has reference to Sale
     assert(networkPlaceholder.token() == address(token));    // placeholder has reference to ESCBCoin

     assert(saleWallet.multisig() == ESCBDevMultisig);        // receiving wallet must match
     assert(saleWallet.tokenSale() == address(this));         // watched token sale must be self

     assert(_minGoal > 0);                                   // minimum goal is not empty
     assert(_goal > 0);                                      // the main goal is not empty
     assert(_minGoal < _goal);                               // minimum goal is less than the main goal

     minGoal = _minGoal;
     goal = _goal;

     doActivateSale(this);
   }

   function activateSale()
            public {

     doActivateSale(msg.sender);
     ActivatedSale();
   }

   function doActivateSale(address _entity)
     non_zero_address(token) // cannot activate before setting token
     only_before_sale
     private {

     activated[_entity] = true;
   }

   function isActivated()
            constant
            public
            returns (bool) {

     return activated[this] && activated[ESCBDevMultisig];
   }

   function getPrice(uint256 _amount)
            only_during_sale_period
            only_sale_not_stopped
            only_sale_activated
            constant
            public
            returns (uint256) {

     return priceForStage(SafeMath.mul(_amount, price));
   }

   function priceForStage(uint256 _amount)
            internal
            returns (uint256) {


     if (totalCollected >= 0 && totalCollected <= 80 ether) { // 1 ETH = 500 USD, then 40 000 USD 1 stage
       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 20), 100));
     }

     if (totalCollected > 80 ether && totalCollected <= 200 ether) { // 1 ETH = 500 USD, then 100 000 USD 2 stage
       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 18), 100));
     }

     if (totalCollected > 200 ether && totalCollected <= 400 ether) { // 1 ETH = 500 USD, then 200 000 USD 3 stage
       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 16), 100));
     }

     if (totalCollected > 400 ether && totalCollected <= 1000 ether) { // 1 ETH = 500 USD, then 500 000 USD 4 stage
       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 14), 100));
     }

     if (totalCollected > 1000 ether && totalCollected <= 2000 ether) { // 1 ETH = 500 USD, then 1 000 000 USD 5 stage
       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 12), 100));
     }

     if (totalCollected > 2000 ether && totalCollected <= 4000 ether) { // 1 ETH = 500 USD, then 2 000 000 USD 6 stage
       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 10), 100));
     }

     if (totalCollected > 4000 ether && totalCollected <= 8000 ether) { // 1 ETH = 500 USD, then 4 000 000 USD 7 stage
       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 8), 100));
     }

     if (totalCollected > 8000 ether && totalCollected <= 12000 ether) { // 1 ETH = 500 USD, then 6 000 000 USD 8 stage
       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 6), 100));
     }

     if (totalCollected > 12000 ether && totalCollected <= 16000 ether) { // 1 ETH = 500 USD, then 8 000 000 USD 9 stage
       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 4), 100));
     }

     if (totalCollected > 16000 ether && totalCollected <= 20000 ether) { // 1 ETH = 500 USD, then 10 000 000 USD 10 stage
       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 2), 100));
     }

     if (totalCollected > 20000 ether) { // without bonus
       return _amount;
     }
   }

   function allocationForESCBbyStage()
            only(ESCBDevMultisig)
            public {

      if (totalCollected >= 0 && totalCollected <= 80 ether) { // 1 ETH = 500 USD, then 40 000 USD 1 stage
        currentStage = 1;
      }

      if (totalCollected > 80 ether && totalCollected <= 200 ether) { // 1 ETH = 500 USD, then 100 000 USD 2 stage
        currentStage = 2;
      }

      if (totalCollected > 200 ether && totalCollected <= 400 ether) { // 1 ETH = 500 USD, then 200 000 USD 3 stage
        currentStage = 3;
      }

      if (totalCollected > 400 ether && totalCollected <= 1000 ether) { // 1 ETH = 500 USD, then 500 000 USD 4 stage
        currentStage = 4;
      }

      if (totalCollected > 1000 ether && totalCollected <= 2000 ether) { // 1 ETH = 500 USD, then 1 000 000 USD 5 stage
        currentStage = 5;
      }

      if (totalCollected > 2000 ether && totalCollected <= 4000 ether) { // 1 ETH = 500 USD, then 2 000 000 USD 6 stage
        currentStage = 6;
      }

      if (totalCollected > 4000 ether && totalCollected <= 8000 ether) { // 1 ETH = 500 USD, then 4 000 000 USD 7 stage
        currentStage = 7;
      }

      if (totalCollected > 8000 ether && totalCollected <= 12000 ether) { // 1 ETH = 500 USD, then 6 000 000 USD 8 stage
        currentStage = 8;
      }

      if (totalCollected > 12000 ether && totalCollected <= 16000 ether) { // 1 ETH = 500 USD, then 8 000 000 USD 9 stage
        currentStage = 9;
      }

      if (totalCollected > 16000 ether && totalCollected <= 20000 ether) { // 1 ETH = 500 USD, then 10 000 000 USD 10 stage
        currentStage = 10;
      }
     if(currentStage > allocatedStage) {
       uint256 ESCBTokens = SafeMath.div(SafeMath.mul(SafeMath.sub(uint256(token.totalSupply()), usedTotalSupply), 15), 33);
       uint256 prevTotalSupply = uint256(token.totalSupply());
       if(token.generateTokens(address(this), ESCBTokens)) {
         allocatedStage = currentStage;
         usedTotalSupply = prevTotalSupply;
         uint64 cliffDate = uint64(SafeMath.add(uint256(now), 365 days));
         uint64 vestingDate = uint64(SafeMath.add(uint256(now), 547 days));
         token.grantVestedTokens(ESCBDevMultisig, ESCBTokens, uint64(now), cliffDate, vestingDate, true, false);
         AllocationForESCBFund(ESCBDevMultisig, ESCBTokens);
       } else {
         revert();
       }
     }
   }

   function onTransfer(address _from, address _to, uint _amount)
            public
            returns (bool) {

     return true;
   }

   function onApprove(address _owner, address _spender, uint _amount)
            public
            returns (bool) {

     return true;
   }

   function ()
            public
            payable {
     doPayment(msg.sender);
   }

   function paymentAffiliate(address _referral)
            non_zero_address(_referral)
            payable
            public {

     uint256 boughtTokens = doPayment(msg.sender);
     uint256 affiliateBonus = SafeMath.div(
                                SafeMath.mul(boughtTokens, affiliateBonusPercent), 100
                              ); // Calculate how many bonus tokens need to add
     assert(token.generateTokens(_referral, affiliateBonus));
     assert(token.generateTokens(msg.sender, affiliateBonus));
   }



   function proxyPayment(address _owner)
            payable
            public
            returns (bool) {

     doPayment(_owner);
     return true;
   }

   function doPayment(address _owner)
            only_during_sale_period
            only_sale_not_stopped
            only_sale_activated
            non_zero_address(_owner)
            minimum_value(dust)
            internal
            returns (uint256) {

     assert(totalCollected + msg.value <= goal); // If goal is reached, throw
     uint256 boughtTokens = priceForStage(SafeMath.mul(msg.value, price)); // Calculate how many tokens bought
     saleWallet.transfer(msg.value); // Send funds to multisig
     saleWallet.deposit(_owner, msg.value); // Send info about deposit to multisig
     assert(token.generateTokens(_owner, boughtTokens)); // Allocate tokens.
     totalCollected = SafeMath.add(totalCollected, msg.value); // Save total collected amount
     NewBuyer(_owner, boughtTokens, msg.value);

     return boughtTokens;
   }

   function issueWithExternalFoundation(address _owner, uint256 _amount, bytes32 _extId)
            only_during_sale_period
            only_sale_not_stopped
            only_sale_activated
            non_zero_address(_owner)
            only(ESCBDevMultisig)
            public
            returns (uint256) {

     assert(totalCollected + _amount <= goal); // If goal is reached, throw
     uint256 boughtTokens = priceForStage(SafeMath.mul(_amount, price)); // Calculate how many tokens bought

     assert(token.generateTokens(_owner, boughtTokens)); // Allocate tokens.
     totalCollected = SafeMath.add(totalCollected, _amount); // Save total collected amount

     NewBuyer(_owner, boughtTokens, _amount);
     NewExternalFoundation(_owner, boughtTokens, _amount, _extId);

     return boughtTokens;
   }

   function emergencyStopSale()
            only_sale_activated
            only_sale_not_stopped
            only(ESCBDevMultisig)
            public {

     saleStopped = true;
   }

   function restartSale()
            only_during_sale_period
            only_sale_stopped
            only(ESCBDevMultisig)
            public {

     saleStopped = false;
   }

   function finalizeSale()
            only_after_sale
            only(ESCBDevMultisig)
            public {

     token.changeController(networkPlaceholder); // Sale loses token controller power in favor of network placeholder
     saleFinalized = true;  // Set finalized flag as true, that will allow enabling network deployment
     saleStopped = true;
     FinalizedSale();
   }

   function deployNetwork(address _networkAddress)
            only_finalized_sale
            non_zero_address(_networkAddress)
            only(ESCBDevMultisig)
            public {

     networkPlaceholder.changeController(_networkAddress);
   }

   function setESCBDevMultisig(address _newMultisig)
            non_zero_address(_newMultisig)
            only(ESCBDevMultisig)
            public {

     ESCBDevMultisig = _newMultisig;
   }

   function getNow()
            constant
            internal
            returns (uint) {

     return now;
   }

   function claimRefund()
            only_finalized_sale
            public {

     require(!minGoalReached());
     saleWallet.refund(msg.sender);
   }

   function minGoalReached()
            public
            view
            returns (bool) {

     return totalCollected >= minGoal;
   }

   function goalReached()
            public
            view
            returns (bool) {

     return totalCollected >= goal;
   }
 }