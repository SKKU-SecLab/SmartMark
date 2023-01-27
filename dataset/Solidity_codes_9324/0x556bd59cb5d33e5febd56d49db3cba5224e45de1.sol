
pragma solidity ^0.4.24;

interface ICheckpoint {


}

contract DividendCheckpointStorage {


    address public wallet;
    uint256 public EXCLUDED_ADDRESS_LIMIT = 150;
    bytes32 public constant DISTRIBUTE = "DISTRIBUTE";
    bytes32 public constant MANAGE = "MANAGE";
    bytes32 public constant CHECKPOINT = "CHECKPOINT";

    struct Dividend {
        uint256 checkpointId;
        uint256 created; // Time at which the dividend was created
        uint256 maturity; // Time after which dividend can be claimed - set to 0 to bypass
        uint256 expiry;  // Time until which dividend can be claimed - after this time any remaining amount can be withdrawn by issuer -
        uint256 amount; // Dividend amount in WEI
        uint256 claimedAmount; // Amount of dividend claimed so far
        uint256 totalSupply; // Total supply at the associated checkpoint (avoids recalculating this)
        bool reclaimed;  // True if expiry has passed and issuer has reclaimed remaining dividend
        uint256 totalWithheld;
        uint256 totalWithheldWithdrawn;
        mapping (address => bool) claimed; // List of addresses which have claimed dividend
        mapping (address => bool) dividendExcluded; // List of addresses which cannot claim dividends
        mapping (address => uint256) withheld; // Amount of tax withheld from claim
        bytes32 name; // Name/title - used for identification
    }

    Dividend[] public dividends;

    address[] public excluded;

    mapping (address => uint256) public withholdingTax;

}

interface IModule {


    function getInitFunction() external pure returns (bytes4);


    function getPermissions() external view returns(bytes32[]);


    function takeFee(uint256 _amount) external returns(bool);


}

interface ISecurityToken {


    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);

    function increaseApproval(address _spender, uint _addedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function verifyTransfer(address _from, address _to, uint256 _value) external returns (bool success);


    function mint(address _investor, uint256 _value) external returns (bool success);


    function mintWithData(address _investor, uint256 _value, bytes _data) external returns (bool success);


    function burnFromWithData(address _from, uint256 _value, bytes _data) external;


    function burnWithData(uint256 _value, bytes _data) external;


    event Minted(address indexed _to, uint256 _value);
    event Burnt(address indexed _burner, uint256 _value);

    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns (bool);


    function getModule(address _module) external view returns(bytes32, address, address, bool, uint8, uint256, uint256);


    function getModulesByName(bytes32 _name) external view returns (address[]);


    function getModulesByType(uint8 _type) external view returns (address[]);


    function totalSupplyAt(uint256 _checkpointId) external view returns (uint256);


    function balanceOfAt(address _investor, uint256 _checkpointId) external view returns (uint256);


    function createCheckpoint() external returns (uint256);


    function getInvestors() external view returns (address[]);


    function getInvestorsAt(uint256 _checkpointId) external view returns(address[]);


    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]);

    
    function currentCheckpointId() external view returns (uint256);


    function investors(uint256 _index) external view returns (address);


    function withdrawERC20(address _tokenContract, uint256 _value) external;


    function changeModuleBudget(address _module, uint256 _budget) external;


    function updateTokenDetails(string _newTokenDetails) external;


    function changeGranularity(uint256 _granularity) external;


    function pruneInvestors(uint256 _start, uint256 _iters) external;


    function freezeTransfers() external;


    function unfreezeTransfers() external;


    function freezeMinting() external;


    function mintMulti(address[] _investors, uint256[] _values) external returns (bool success);


    function addModule(
        address _moduleFactory,
        bytes _data,
        uint256 _maxCost,
        uint256 _budget
    ) external;


    function archiveModule(address _module) external;


    function unarchiveModule(address _module) external;


    function removeModule(address _module) external;


    function setController(address _controller) external;


    function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) external;


    function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) external;


     function disableController() external;


     function getVersion() external view returns(uint8[]);


     function getInvestorCount() external view returns(uint256);


     function transferWithData(address _to, uint256 _value, bytes _data) external returns (bool success);


     function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) external returns(bool);


     function granularity() external view returns(uint256);

}

interface IERC20 {

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);

    function increaseApproval(address _spender, uint _addedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ModuleStorage {


    constructor (address _securityToken, address _polyAddress) public {
        securityToken = _securityToken;
        factory = msg.sender;
        polyToken = IERC20(_polyAddress);
    }
    
    address public factory;

    address public securityToken;

    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";

    IERC20 public polyToken;

}

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

contract Module is IModule, ModuleStorage {


    constructor (address _securityToken, address _polyAddress) public
    ModuleStorage(_securityToken, _polyAddress)
    {
    }

    modifier withPerm(bytes32 _perm) {

        bool isOwner = msg.sender == Ownable(securityToken).owner();
        bool isFactory = msg.sender == factory;
        require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");
        _;
    }

    modifier onlyOwner {

        require(msg.sender == Ownable(securityToken).owner(), "Sender is not owner");
        _;
    }

    modifier onlyFactory {

        require(msg.sender == factory, "Sender is not factory");
        _;
    }

    modifier onlyFactoryOwner {

        require(msg.sender == Ownable(factory).owner(), "Sender is not factory owner");
        _;
    }

    modifier onlyFactoryOrOwner {

        require((msg.sender == Ownable(securityToken).owner()) || (msg.sender == factory), "Sender is not factory or owner");
        _;
    }

    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {

        require(polyToken.transferFrom(securityToken, Ownable(factory).owner(), _amount), "Unable to take fee");
        return true;
    }

}

contract Pausable {


    event Pause(uint256 _timestammp);
    event Unpause(uint256 _timestamp);

    bool public paused = false;

    modifier whenNotPaused() {

        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {

        require(paused, "Contract is not paused");
        _;
    }

    function _pause() internal whenNotPaused {

        paused = true;
        emit Pause(now);
    }

    function _unpause() internal whenPaused {

        paused = false;
        emit Unpause(now);
    }

}

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
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











contract DividendCheckpoint is DividendCheckpointStorage, ICheckpoint, Module, Pausable {

    using SafeMath for uint256;

    event SetDefaultExcludedAddresses(address[] _excluded, uint256 _timestamp);
    event SetWithholding(address[] _investors, uint256[] _withholding, uint256 _timestamp);
    event SetWithholdingFixed(address[] _investors, uint256 _withholding, uint256 _timestamp);
    event SetWallet(address indexed _oldWallet, address indexed _newWallet, uint256 _timestamp);
    event UpdateDividendDates(uint256 indexed _dividendIndex, uint256 _maturity, uint256 _expiry);

    modifier validDividendIndex(uint256 _dividendIndex) {

        _validDividendIndex(_dividendIndex);
        _;
    }

    function _validDividendIndex(uint256 _dividendIndex) internal view {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        require(!dividends[_dividendIndex].reclaimed, "Dividend reclaimed");
        require(now >= dividends[_dividendIndex].maturity, "Dividend maturity in future");
        require(now < dividends[_dividendIndex].expiry, "Dividend expiry in past");
    }

    function pause() public onlyOwner {

        super._pause();
    }

    function unpause() public onlyOwner {

        super._unpause();
    }

    function reclaimERC20(address _tokenContract) external onlyOwner {

        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance), "Transfer failed");
    }

    function reclaimETH() external onlyOwner {

        msg.sender.transfer(address(this).balance);
    }

    function configure(
        address _wallet
    ) public onlyFactory {

        _setWallet(_wallet);
    }

    function getInitFunction() public pure returns (bytes4) {

        return this.configure.selector;
    }

    function changeWallet(address _wallet) external onlyOwner {

        _setWallet(_wallet);
    }

    function _setWallet(address _wallet) internal {

        require(_wallet != address(0));
        emit SetWallet(wallet, _wallet, now);
        wallet = _wallet;
    }

    function getDefaultExcluded() external view returns (address[]) {

        return excluded;
    }

    function createCheckpoint() public withPerm(CHECKPOINT) returns (uint256) {

        return ISecurityToken(securityToken).createCheckpoint();
    }

    function setDefaultExcluded(address[] _excluded) public withPerm(MANAGE) {

        require(_excluded.length <= EXCLUDED_ADDRESS_LIMIT, "Too many excluded addresses");
        for (uint256 j = 0; j < _excluded.length; j++) {
            require (_excluded[j] != address(0), "Invalid address");
            for (uint256 i = j + 1; i < _excluded.length; i++) {
                require (_excluded[j] != _excluded[i], "Duplicate exclude address");
            }
        }
        excluded = _excluded;
        emit SetDefaultExcludedAddresses(excluded, now);
    }

    function setWithholding(address[] _investors, uint256[] _withholding) public withPerm(MANAGE) {

        require(_investors.length == _withholding.length, "Mismatched input lengths");
        emit SetWithholding(_investors, _withholding, now);
        for (uint256 i = 0; i < _investors.length; i++) {
            require(_withholding[i] <= 10**18, "Incorrect withholding tax");
            withholdingTax[_investors[i]] = _withholding[i];
        }
    }

    function setWithholdingFixed(address[] _investors, uint256 _withholding) public withPerm(MANAGE) {

        require(_withholding <= 10**18, "Incorrect withholding tax");
        emit SetWithholdingFixed(_investors, _withholding, now);
        for (uint256 i = 0; i < _investors.length; i++) {
            withholdingTax[_investors[i]] = _withholding;
        }
    }

    function pushDividendPaymentToAddresses(
        uint256 _dividendIndex,
        address[] _payees
    )
        public
        withPerm(DISTRIBUTE)
        validDividendIndex(_dividendIndex)
    {

        Dividend storage dividend = dividends[_dividendIndex];
        for (uint256 i = 0; i < _payees.length; i++) {
            if ((!dividend.claimed[_payees[i]]) && (!dividend.dividendExcluded[_payees[i]])) {
                _payDividend(_payees[i], dividend, _dividendIndex);
            }
        }
    }

    function pushDividendPayment(
        uint256 _dividendIndex,
        uint256 _start,
        uint256 _iterations
    )
        public
        withPerm(DISTRIBUTE)
        validDividendIndex(_dividendIndex)
    {

        Dividend storage dividend = dividends[_dividendIndex];
        uint256 checkpointId = dividend.checkpointId;
        address[] memory investors = ISecurityToken(securityToken).getInvestorsAt(checkpointId);
        uint256 numberInvestors = Math.min256(investors.length, _start.add(_iterations));
        for (uint256 i = _start; i < numberInvestors; i++) {
            address payee = investors[i];
            if ((!dividend.claimed[payee]) && (!dividend.dividendExcluded[payee])) {
                _payDividend(payee, dividend, _dividendIndex);
            }
        }
    }

    function pullDividendPayment(uint256 _dividendIndex) public validDividendIndex(_dividendIndex) whenNotPaused
    {

        Dividend storage dividend = dividends[_dividendIndex];
        require(!dividend.claimed[msg.sender], "Dividend already claimed");
        require(!dividend.dividendExcluded[msg.sender], "msg.sender excluded from Dividend");
        _payDividend(msg.sender, dividend, _dividendIndex);
    }

    function _payDividend(address _payee, Dividend storage _dividend, uint256 _dividendIndex) internal;


    function reclaimDividend(uint256 _dividendIndex) external;


    function calculateDividend(uint256 _dividendIndex, address _payee) public view returns(uint256, uint256) {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        Dividend storage dividend = dividends[_dividendIndex];
        if (dividend.claimed[_payee] || dividend.dividendExcluded[_payee]) {
            return (0, 0);
        }
        uint256 balance = ISecurityToken(securityToken).balanceOfAt(_payee, dividend.checkpointId);
        uint256 claim = balance.mul(dividend.amount).div(dividend.totalSupply);
        uint256 withheld = claim.mul(withholdingTax[_payee]).div(uint256(10**18));
        return (claim, withheld);
    }

    function getDividendIndex(uint256 _checkpointId) public view returns(uint256[]) {

        uint256 counter = 0;
        for(uint256 i = 0; i < dividends.length; i++) {
            if (dividends[i].checkpointId == _checkpointId) {
                counter++;
            }
        }

        uint256[] memory index = new uint256[](counter);
        counter = 0;
        for(uint256 j = 0; j < dividends.length; j++) {
            if (dividends[j].checkpointId == _checkpointId) {
                index[counter] = j;
                counter++;
            }
        }
        return index;
    }

    function withdrawWithholding(uint256 _dividendIndex) external;


    function updateDividendDates(uint256 _dividendIndex, uint256 _maturity, uint256 _expiry) external onlyOwner {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        require(_expiry > _maturity, "Expiry before maturity");
        Dividend storage dividend = dividends[_dividendIndex];
        dividend.expiry = _expiry;
        dividend.maturity = _maturity;
        emit UpdateDividendDates(_dividendIndex, _maturity, _expiry);
    }

    function getDividendsData() external view returns (
        uint256[] memory createds,
        uint256[] memory maturitys,
        uint256[] memory expirys,
        uint256[] memory amounts,
        uint256[] memory claimedAmounts,
        bytes32[] memory names)
    {

        createds = new uint256[](dividends.length);
        maturitys = new uint256[](dividends.length);
        expirys = new uint256[](dividends.length);
        amounts = new uint256[](dividends.length);
        claimedAmounts = new uint256[](dividends.length);
        names = new bytes32[](dividends.length);
        for (uint256 i = 0; i < dividends.length; i++) {
            (createds[i], maturitys[i], expirys[i], amounts[i], claimedAmounts[i], names[i]) = getDividendData(i);
        }
    }

    function getDividendData(uint256 _dividendIndex) public view returns (
        uint256 created,
        uint256 maturity,
        uint256 expiry,
        uint256 amount,
        uint256 claimedAmount,
        bytes32 name)
    {

        created = dividends[_dividendIndex].created;
        maturity = dividends[_dividendIndex].maturity;
        expiry = dividends[_dividendIndex].expiry;
        amount = dividends[_dividendIndex].amount;
        claimedAmount = dividends[_dividendIndex].claimedAmount;
        name = dividends[_dividendIndex].name;
    }

    function getDividendProgress(uint256 _dividendIndex) external view returns (
        address[] memory investors,
        bool[] memory resultClaimed,
        bool[] memory resultExcluded,
        uint256[] memory resultWithheld,
        uint256[] memory resultAmount,
        uint256[] memory resultBalance)
    {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        Dividend storage dividend = dividends[_dividendIndex];
        uint256 checkpointId = dividend.checkpointId;
        investors = ISecurityToken(securityToken).getInvestorsAt(checkpointId);
        resultClaimed = new bool[](investors.length);
        resultExcluded = new bool[](investors.length);
        resultWithheld = new uint256[](investors.length);
        resultAmount = new uint256[](investors.length);
        resultBalance = new uint256[](investors.length);
        for (uint256 i; i < investors.length; i++) {
            resultClaimed[i] = dividend.claimed[investors[i]];
            resultExcluded[i] = dividend.dividendExcluded[investors[i]];
            resultBalance[i] = ISecurityToken(securityToken).balanceOfAt(investors[i], dividend.checkpointId);
            if (!resultExcluded[i]) {
                if (resultClaimed[i]) {
                    resultWithheld[i] = dividend.withheld[investors[i]];
                    resultAmount[i] = resultBalance[i].mul(dividend.amount).div(dividend.totalSupply).sub(resultWithheld[i]);
                } else {
                    (uint256 claim, uint256 withheld) = calculateDividend(_dividendIndex, investors[i]);
                    resultWithheld[i] = withheld;
                    resultAmount[i] = claim.sub(withheld);
                }
            }
        }
    }

    function getCheckpointData(uint256 _checkpointId) external view returns (address[] memory investors, uint256[] memory balances, uint256[] memory withholdings) {

        require(_checkpointId <= ISecurityToken(securityToken).currentCheckpointId(), "Invalid checkpoint");
        investors = ISecurityToken(securityToken).getInvestorsAt(_checkpointId);
        balances = new uint256[](investors.length);
        withholdings = new uint256[](investors.length);
        for (uint256 i; i < investors.length; i++) {
            balances[i] = ISecurityToken(securityToken).balanceOfAt(investors[i], _checkpointId);
            withholdings[i] = withholdingTax[investors[i]];
        }
    }

    function isExcluded(address _investor, uint256 _dividendIndex) external view returns (bool) {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        return dividends[_dividendIndex].dividendExcluded[_investor];
    }

    function isClaimed(address _investor, uint256 _dividendIndex) external view returns (bool) {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        return dividends[_dividendIndex].claimed[_investor];
    }

    function getPermissions() public view returns(bytes32[]) {

        bytes32[] memory allPermissions = new bytes32[](2);
        allPermissions[0] = DISTRIBUTE;
        allPermissions[1] = MANAGE;
        return allPermissions;
    }

}

contract ERC20DividendCheckpointStorage {


    mapping (uint256 => address) public dividendTokens;

}

interface IOwnable {

    function owner() external view returns (address);


    function renounceOwnership() external;


    function transferOwnership(address _newOwner) external;


}

contract ERC20DividendCheckpoint is ERC20DividendCheckpointStorage, DividendCheckpoint {

    using SafeMath for uint256;

    event ERC20DividendDeposited(
        address indexed _depositor,
        uint256 _checkpointId,
        uint256 _created,
        uint256 _maturity,
        uint256 _expiry,
        address indexed _token,
        uint256 _amount,
        uint256 _totalSupply,
        uint256 _dividendIndex,
        bytes32 indexed _name
    );
    event ERC20DividendClaimed(
        address indexed _payee,
        uint256 indexed _dividendIndex,
        address indexed _token,
        uint256 _amount,
        uint256 _withheld
    );
    event ERC20DividendReclaimed(
        address indexed _claimer,
        uint256 indexed _dividendIndex,
        address indexed _token,
        uint256 _claimedAmount
    );
    event ERC20DividendWithholdingWithdrawn(
        address indexed _claimer,
        uint256 indexed _dividendIndex,
        address indexed _token,
        uint256 _withheldAmount
    );

    constructor (address _securityToken, address _polyAddress) public
    Module(_securityToken, _polyAddress)
    {
    }

    function createDividend(
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        bytes32 _name
    )
        external
        withPerm(MANAGE)
    {

        createDividendWithExclusions(_maturity, _expiry, _token, _amount, excluded, _name);
    }

    function createDividendWithCheckpoint(
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        uint256 _checkpointId,
        bytes32 _name
    )
        external
        withPerm(MANAGE)
    {

        _createDividendWithCheckpointAndExclusions(_maturity, _expiry, _token, _amount, _checkpointId, excluded, _name);
    }

    function createDividendWithExclusions(
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        address[] _excluded,
        bytes32 _name
    )
        public
        withPerm(MANAGE)
    {

        uint256 checkpointId = ISecurityToken(securityToken).createCheckpoint();
        _createDividendWithCheckpointAndExclusions(_maturity, _expiry, _token, _amount, checkpointId, _excluded, _name);
    }

    function createDividendWithCheckpointAndExclusions(
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        uint256 _checkpointId,
        address[] _excluded,
        bytes32 _name
    )
        public
        withPerm(MANAGE)
    {

        _createDividendWithCheckpointAndExclusions(_maturity, _expiry, _token, _amount, _checkpointId, _excluded, _name);
    }

    function _createDividendWithCheckpointAndExclusions(
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        uint256 _checkpointId,
        address[] _excluded,
        bytes32 _name
    )
        internal
    {

        ISecurityToken securityTokenInstance = ISecurityToken(securityToken);
        require(_excluded.length <= EXCLUDED_ADDRESS_LIMIT, "Too many addresses excluded");
        require(_expiry > _maturity, "Expiry before maturity");
        require(_expiry > now, "Expiry in past");
        require(_amount > 0, "No dividend sent");
        require(_token != address(0), "Invalid token");
        require(_checkpointId <= securityTokenInstance.currentCheckpointId(), "Invalid checkpoint");
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "insufficent allowance");
        require(_name[0] != 0);
        uint256 dividendIndex = dividends.length;
        uint256 currentSupply = securityTokenInstance.totalSupplyAt(_checkpointId);
        uint256 excludedSupply = 0;
        dividends.push(
          Dividend(
            _checkpointId,
            now, /*solium-disable-line security/no-block-members*/
            _maturity,
            _expiry,
            _amount,
            0,
            0,
            false,
            0,
            0,
            _name
          )
        );

        for (uint256 j = 0; j < _excluded.length; j++) {
            require (_excluded[j] != address(0), "Invalid address");
            require(!dividends[dividendIndex].dividendExcluded[_excluded[j]], "duped exclude address");
            excludedSupply = excludedSupply.add(securityTokenInstance.balanceOfAt(_excluded[j], _checkpointId));
            dividends[dividendIndex].dividendExcluded[_excluded[j]] = true;
        }

        dividends[dividendIndex].totalSupply = currentSupply.sub(excludedSupply);
        dividendTokens[dividendIndex] = _token;
        _emitERC20DividendDepositedEvent(_checkpointId, _maturity, _expiry, _token, _amount, currentSupply, dividendIndex, _name);
    }

    function _emitERC20DividendDepositedEvent(
        uint256 _checkpointId,
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        uint256 currentSupply,
        uint256 dividendIndex,
        bytes32 _name
    )
        internal
    {

        emit ERC20DividendDeposited(msg.sender, _checkpointId, now, _maturity, _expiry, _token, _amount, currentSupply, dividendIndex, _name);
    }

    function _payDividend(address _payee, Dividend storage _dividend, uint256 _dividendIndex) internal {

        (uint256 claim, uint256 withheld) = calculateDividend(_dividendIndex, _payee);
        _dividend.claimed[_payee] = true;
        _dividend.claimedAmount = claim.add(_dividend.claimedAmount);
        uint256 claimAfterWithheld = claim.sub(withheld);
        if (claimAfterWithheld > 0) {
            require(IERC20(dividendTokens[_dividendIndex]).transfer(_payee, claimAfterWithheld), "transfer failed");
        }
        if (withheld > 0) {
            _dividend.totalWithheld = _dividend.totalWithheld.add(withheld);
            _dividend.withheld[_payee] = withheld;
        }
        emit ERC20DividendClaimed(_payee, _dividendIndex, dividendTokens[_dividendIndex], claim, withheld);
    }

    function reclaimDividend(uint256 _dividendIndex) external withPerm(MANAGE) {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        require(now >= dividends[_dividendIndex].expiry, "Dividend expiry in future");
        require(!dividends[_dividendIndex].reclaimed, "already claimed");
        dividends[_dividendIndex].reclaimed = true;
        Dividend storage dividend = dividends[_dividendIndex];
        uint256 remainingAmount = dividend.amount.sub(dividend.claimedAmount);
        require(IERC20(dividendTokens[_dividendIndex]).transfer(wallet, remainingAmount), "transfer failed");
        emit ERC20DividendReclaimed(wallet, _dividendIndex, dividendTokens[_dividendIndex], remainingAmount);
    }

    function withdrawWithholding(uint256 _dividendIndex) external withPerm(MANAGE) {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        Dividend storage dividend = dividends[_dividendIndex];
        uint256 remainingWithheld = dividend.totalWithheld.sub(dividend.totalWithheldWithdrawn);
        dividend.totalWithheldWithdrawn = dividend.totalWithheld;
        require(IERC20(dividendTokens[_dividendIndex]).transfer(wallet, remainingWithheld), "transfer failed");
        emit ERC20DividendWithholdingWithdrawn(wallet, _dividendIndex, dividendTokens[_dividendIndex], remainingWithheld);
    }

}