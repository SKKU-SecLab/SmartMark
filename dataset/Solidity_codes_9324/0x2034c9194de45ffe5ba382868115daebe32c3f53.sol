pragma solidity 0.5.16;

contract CosmosBankStorage {


    struct CosmosDeposit {
        bytes cosmosSender;
        address payable ethereumRecipient;
        address bridgeTokenAddress;
        uint256 amount;
        bool locked;
    }

    uint256 public bridgeTokenCount;

    uint256 public cosmosDepositNonce;
    
    mapping(string => address) controlledBridgeTokens;
    
    mapping(string => string) public lowerToUpperTokens;

    uint256[100] private ____gap;
}pragma solidity 0.5.16;

contract EthereumBankStorage {


    uint256 public lockBurnNonce;

    mapping(address => uint256) public lockedFunds;

    mapping(string => address) public lockedTokenList;

    uint256[100] private ____gap;
}pragma solidity 0.5.16;

contract CosmosWhiteListStorage {


    mapping(address => bool) internal _cosmosTokenWhiteList;

    uint256[100] private ____gap;
}pragma solidity 0.5.16;


contract BankStorage is 
    CosmosBankStorage,
    EthereumBankStorage,
    CosmosWhiteListStorage {


    address public operator;

    address public oracle;

    address public cosmosBridge;

    address public owner;

    mapping (string => uint256) public maxTokenAmount;

    uint256[100] private ____gap;
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.0;


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
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;


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
}pragma solidity ^0.5.0;


contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}pragma solidity ^0.5.0;


contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }
}pragma solidity ^0.5.0;


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
}pragma solidity 0.5.16;




contract BridgeToken is ERC20Mintable, ERC20Burnable, ERC20Detailed {

    constructor(string memory _symbol)
        public
        ERC20Detailed(_symbol, _symbol, 18)
    {
    }
}pragma solidity 0.5.16;

contract ToLower {


    function toLower(string memory str) public pure returns (string memory) {

		bytes memory bStr = bytes(str);
		bytes memory bLower = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			if ((bStr[i] >= bytes1(uint8(65))) && (bStr[i] <= bytes1(uint8(90)))) {
				bLower[i] = bytes1(uint8(bStr[i]) + 32);
			} else {
				bLower[i] = bStr[i];
			}
		}
		return string(bLower);
	}
}pragma solidity 0.5.16;



contract CosmosBank is CosmosBankStorage, ToLower {

    using SafeMath for uint256;

    event LogNewBridgeToken(address _token, string _symbol);

    event LogBridgeTokenMint(
        address _token,
        string _symbol,
        uint256 _amount,
        address _beneficiary
    );

    function getBridgeToken(string memory _symbol)
        public
        view
        returns (address)
    {

        return (controlledBridgeTokens[_symbol]);
    }

    function safeLowerToUpperTokens(string memory _symbol)
        public
        view
        returns (string memory)
    {

        string memory retrievedSymbol = lowerToUpperTokens[_symbol];
        return keccak256(abi.encodePacked(retrievedSymbol)) == keccak256("") ? _symbol : retrievedSymbol;
    }

    function deployNewBridgeToken(string memory _symbol)
        internal
        returns (address)
    {

        bridgeTokenCount = bridgeTokenCount.add(1);

        BridgeToken newBridgeToken = (new BridgeToken)(_symbol);

        address newBridgeTokenAddress = address(newBridgeToken);
        controlledBridgeTokens[_symbol] = newBridgeTokenAddress;
        lowerToUpperTokens[toLower(_symbol)] = _symbol;

        emit LogNewBridgeToken(newBridgeTokenAddress, _symbol);
        return newBridgeTokenAddress;
    }

    function useExistingBridgeToken(address _contractAddress)
        internal
        returns (address)
    {

        bridgeTokenCount = bridgeTokenCount.add(1);

        string memory _symbol = BridgeToken(_contractAddress).symbol();
        address newBridgeTokenAddress = _contractAddress;
        controlledBridgeTokens[_symbol] = newBridgeTokenAddress;
        lowerToUpperTokens[toLower(_symbol)] = _symbol;

        emit LogNewBridgeToken(newBridgeTokenAddress, _symbol);
        return newBridgeTokenAddress;
    }

    function mintNewBridgeTokens(
        address payable _intendedRecipient,
        address _bridgeTokenAddress,
        string memory _symbol,
        uint256 _amount
    ) internal {

        require(
            controlledBridgeTokens[_symbol] == _bridgeTokenAddress,
            "Token must be a controlled bridge token"
        );

        require(
            BridgeToken(_bridgeTokenAddress).mint(_intendedRecipient, _amount),
            "Attempted mint of bridge tokens failed"
        );

        emit LogBridgeTokenMint(
            _bridgeTokenAddress,
            _symbol,
            _amount,
            _intendedRecipient
        );
    }
}pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity 0.5.16;

contract EthereumBank is EthereumBankStorage {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event LogBurn(
        address _from,
        bytes _to,
        address _token,
        string _symbol,
        uint256 _value,
        uint256 _nonce
    );

    event LogLock(
        address _from,
        bytes _to,
        address _token,
        string _symbol,
        uint256 _value,
        uint256 _nonce
    );

    event LogUnlock(
        address _to,
        address _token,
        string _symbol,
        uint256 _value
    );

    function getLockedTokenAddress(string memory _symbol)
        public
        view
        returns (address)
    {

        return lockedTokenList[_symbol];
    }

    function getLockedFunds(string memory _symbol)
        public
        view
        returns (uint256)
    {

        return lockedFunds[lockedTokenList[_symbol]];
    }

    function burnFunds(
        address payable _sender,
        bytes memory _recipient,
        address _token,
        string memory _symbol,
        uint256 _amount
    ) internal {

        lockBurnNonce = lockBurnNonce.add(1);
        emit LogBurn(_sender, _recipient, _token, _symbol, _amount, lockBurnNonce);
    }

    function lockFunds(
        address payable _sender,
        bytes memory _recipient,
        address _token,
        string memory _symbol,
        uint256 _amount
    ) internal {

        lockBurnNonce = lockBurnNonce.add(1);

        lockedTokenList[_symbol] = _token;
        lockedFunds[_token] = lockedFunds[_token].add(_amount);

        emit LogLock(_sender, _recipient, _token, _symbol, _amount, lockBurnNonce);
    }

    function unlockFunds(
        address payable _recipient,
        address _token,
        string memory _symbol,
        uint256 _amount
    ) internal {

        lockedFunds[_token] = lockedFunds[_token].sub(_amount);

        if (_token == address(0)) {
            (bool success,) = _recipient.call.value(_amount)("");
            require(success, "error sending ether");
        } else {
            IERC20 tokenToTransfer = IERC20(_token);
            tokenToTransfer.safeTransfer(_recipient, _amount);
        }

        emit LogUnlock(_recipient, _token, _symbol, _amount);
    }
}pragma solidity 0.5.16;


contract EthereumWhiteList {

    bool private _initialized;

    mapping(address => bool) private _ethereumTokenWhiteList;

    uint256[100] private ____gap;
    event LogWhiteListUpdate(address _token, bool _value);

    function initialize() public {

        require(!_initialized, "Initialized");
        _ethereumTokenWhiteList[address(0)] = true;
        _initialized = true;
    }

    modifier onlyEthTokenWhiteList(address _token) {

        require(
            getTokenInEthWhiteList(_token),
            "Only token in whitelist can be transferred to cosmos"
        );
        _;
    }

    function setTokenInEthWhiteList(address _token, bool _inList)
        internal
        returns (bool)
    {

        _ethereumTokenWhiteList[_token] = _inList;
        emit LogWhiteListUpdate(_token, _inList);
        return _inList;
    }

    function getTokenInEthWhiteList(address _token) public view returns (bool) {

        return _ethereumTokenWhiteList[_token];
    }
}pragma solidity 0.5.16;



contract CosmosWhiteList is CosmosWhiteListStorage {

    bool private _initialized;

    event LogWhiteListUpdate(address _token, bool _value);

    function initialize() public {

        require(!_initialized, "Initialized");
        _cosmosTokenWhiteList[address(0)] = true;
        _initialized = true;
    }

    modifier onlyCosmosTokenWhiteList(address _token) {

        require(
            getCosmosTokenInWhiteList(_token),
            "Only token in whitelist can be transferred to cosmos"
        );
        _;
    }

    function setTokenInCosmosWhiteList(address _token, bool _inList)
        internal
        returns (bool)
    {

        _cosmosTokenWhiteList[_token] = _inList;
        emit LogWhiteListUpdate(_token, _inList);
        return _inList;
    }

    function getCosmosTokenInWhiteList(address _token) public view returns (bool) {

        return _cosmosTokenWhiteList[_token];
    }
}pragma solidity 0.5.16;

contract ValsetStorage {


    uint256 public totalPower;

    uint256 public currentValsetVersion;

    uint256 public validatorCount;

    mapping(address => mapping(uint256 => bool)) public validators;

    address public operator;

    mapping(address => mapping(uint256 => uint256)) public powers;

    uint256[100] private ____gap;
}pragma solidity 0.5.16;


contract Valset is ValsetStorage {

    using SafeMath for uint256;

    bool private _initialized;

    event LogValidatorAdded(
        address _validator,
        uint256 _power,
        uint256 _currentValsetVersion,
        uint256 _validatorCount,
        uint256 _totalPower
    );

    event LogValidatorPowerUpdated(
        address _validator,
        uint256 _power,
        uint256 _currentValsetVersion,
        uint256 _validatorCount,
        uint256 _totalPower
    );

    event LogValidatorRemoved(
        address _validator,
        uint256 _power,
        uint256 _currentValsetVersion,
        uint256 _validatorCount,
        uint256 _totalPower
    );

    event LogValsetReset(
        uint256 _newValsetVersion,
        uint256 _validatorCount,
        uint256 _totalPower
    );

    event LogValsetUpdated(
        uint256 _newValsetVersion,
        uint256 _validatorCount,
        uint256 _totalPower
    );

    modifier onlyOperator() {

        require(msg.sender == operator, "Must be the operator.");
        _;
    }

    function _initialize(
        address _operator,
        address[] memory _initValidators,
        uint256[] memory _initPowers
    ) internal {

        require(!_initialized, "Initialized");

        operator = _operator;
        currentValsetVersion = 0;
        _initialized = true;

        updateValset(_initValidators, _initPowers);
    }

    function addValidator(address _validatorAddress, uint256 _validatorPower)
        public
        onlyOperator
    {

        addValidatorInternal(_validatorAddress, _validatorPower);
    }

    function updateValidatorPower(
        address _validatorAddress,
        uint256 _newValidatorPower
    ) public onlyOperator {


        require(
            validators[_validatorAddress][currentValsetVersion],
            "Can only update the power of active valdiators"
        );

        uint256 priorPower = powers[_validatorAddress][currentValsetVersion];
        totalPower = totalPower.sub(priorPower);
        totalPower = totalPower.add(_newValidatorPower);

        powers[_validatorAddress][currentValsetVersion] = _newValidatorPower;

        emit LogValidatorPowerUpdated(
            _validatorAddress,
            _newValidatorPower,
            currentValsetVersion,
            validatorCount,
            totalPower
        );
    }

    function removeValidator(address _validatorAddress) public onlyOperator {

        require(validators[_validatorAddress][currentValsetVersion], "Can only remove active validators");

        validatorCount = validatorCount.sub(1);
        totalPower = totalPower.sub(powers[_validatorAddress][currentValsetVersion]);

        delete validators[_validatorAddress][currentValsetVersion];
        delete powers[_validatorAddress][currentValsetVersion];

        emit LogValidatorRemoved(
            _validatorAddress,
            0,
            currentValsetVersion,
            validatorCount,
            totalPower
        );
    }

    function updateValset(
        address[] memory _validators,
        uint256[] memory _powers
    ) public onlyOperator {

        require(
            _validators.length == _powers.length,
            "Every validator must have a corresponding power"
        );

        resetValset();

        for (uint256 i = 0; i < _validators.length; i = i.add(1)) {
            addValidatorInternal(_validators[i], _powers[i]);
        }

        emit LogValsetUpdated(currentValsetVersion, validatorCount, totalPower);
    }

    function isActiveValidator(address _validatorAddress)
        public
        view
        returns (bool)
    {

        return validators[_validatorAddress][currentValsetVersion];
    }

    function getValidatorPower(address _validatorAddress)
        external
        view
        returns (uint256)
    {

        return powers[_validatorAddress][currentValsetVersion];
    }

    function recoverGas(uint256 _valsetVersion, address _validatorAddress)
        external
        onlyOperator
    {

        require(
            _valsetVersion < currentValsetVersion,
            "Gas recovery only allowed for previous validator sets"
        );
        delete (validators[_validatorAddress][currentValsetVersion]);
        delete (powers[_validatorAddress][currentValsetVersion]);
    }

    function addValidatorInternal(
        address _validatorAddress,
        uint256 _validatorPower
    ) internal {

        validatorCount = validatorCount.add(1);
        totalPower = totalPower.add(_validatorPower);

        validators[_validatorAddress][currentValsetVersion] = true;
        powers[_validatorAddress][currentValsetVersion] = _validatorPower;

        emit LogValidatorAdded(
            _validatorAddress,
            _validatorPower,
            currentValsetVersion,
            validatorCount,
            totalPower
        );
    }

    function resetValset() internal {

        currentValsetVersion = currentValsetVersion.add(1);
        validatorCount = 0;
        totalPower = 0;

        emit LogValsetReset(currentValsetVersion, validatorCount, totalPower);
    }
}pragma solidity 0.5.16;

contract OracleStorage {

    address public cosmosBridge;

    address public operator;

    uint256 public consensusThreshold; // e.g. 75 = 75%

    mapping(uint256 => uint256) public oracleClaimValidators;

    mapping(uint256 => mapping(address => bool)) public hasMadeClaim;

    uint256[100] private ____gap;
}pragma solidity 0.5.16;



contract Oracle is OracleStorage, Valset {

    using SafeMath for uint256;

    bool private _initialized;

    event LogNewOracleClaim(
        uint256 _prophecyID,
        address _validatorAddress
    );

    event LogProphecyProcessed(
        uint256 _prophecyID,
        uint256 _prophecyPowerCurrent,
        uint256 _prophecyPowerThreshold,
        address _submitter
    );

    modifier onlyOperator() {

        require(msg.sender == operator, "Must be the operator.");
        _;
    }

    function _initialize(
        address _operator,
        uint256 _consensusThreshold,
        address[] memory _initValidators,
        uint256[] memory _initPowers
    ) internal {

        require(!_initialized, "Initialized");
        require(
            _consensusThreshold > 0,
            "Consensus threshold must be positive."
        );
        require(
            _consensusThreshold <= 100,
            "Invalid consensus threshold."
        );
        operator = _operator;
        consensusThreshold = _consensusThreshold;
        _initialized = true;

        Valset._initialize(_operator, _initValidators, _initPowers);
    }

    function newOracleClaim(
        uint256 _prophecyID,
        address validatorAddress
    ) internal
        returns (bool)
    {

        require(
            !hasMadeClaim[_prophecyID][validatorAddress],
            "Cannot make duplicate oracle claims from the same address."
        );

        hasMadeClaim[_prophecyID][validatorAddress] = true;
        oracleClaimValidators[_prophecyID] = oracleClaimValidators[_prophecyID].add(
            this.getValidatorPower(validatorAddress)
        );
        emit LogNewOracleClaim(
            _prophecyID,
            validatorAddress
        );

        (bool valid, , ) = getProphecyThreshold(_prophecyID);

        return valid;
    }

    function getProphecyThreshold(uint256 _prophecyID)
        public
        view
        returns (bool, uint256, uint256)
    {

        uint256 signedPower = 0;
        uint256 totalPower = totalPower;

        signedPower = oracleClaimValidators[_prophecyID];

        uint256 prophecyPowerThreshold = totalPower.mul(consensusThreshold);
        uint256 prophecyPowerCurrent = signedPower.mul(100);
        bool hasReachedThreshold = prophecyPowerCurrent >=
            prophecyPowerThreshold;

        return (
            hasReachedThreshold,
            prophecyPowerCurrent,
            prophecyPowerThreshold
        );
    }
}pragma solidity 0.5.16;


contract CosmosBridgeStorage {

    string COSMOS_NATIVE_ASSET_PREFIX;

    address public operator;
    
    address payable public valset;
    
    address payable public oracle;
    
    address payable public bridgeBank;
    
    bool public hasBridgeBank;

    mapping(uint256 => ProphecyClaim) public prophecyClaims;

    enum Status {Null, Pending, Success, Failed}

    enum ClaimType {Unsupported, Burn, Lock}

    struct ProphecyClaim {
        address payable ethereumReceiver;
        string symbol;
        uint256 amount;
    }

    uint256[100] private ____gap;
}pragma solidity 0.5.16;



contract CosmosBridge is CosmosBridgeStorage, Oracle {

    using SafeMath for uint256;
    
    bool private _initialized;
    uint256[100] private ___gap;


    event LogOracleSet(address _oracle);

    event LogBridgeBankSet(address _bridgeBank);

    event LogNewProphecyClaim(
        uint256 _prophecyID,
        ClaimType _claimType,
        address payable _ethereumReceiver,
        string _symbol,
        uint256 _amount
    );

    event LogProphecyCompleted(uint256 _prophecyID, ClaimType _claimType);

    modifier onlyOperator() {

        require(msg.sender == operator, "Must be the operator.");
        _;
    }

    modifier onlyValidator() {

        require(
            isActiveValidator(msg.sender),
            "Must be an active validator"
        );
        _;
    }

    function initialize(
        address _operator,
        uint256 _consensusThreshold,
        address[] memory _initValidators,
        uint256[] memory _initPowers
    ) public {

        require(!_initialized, "Initialized");

        COSMOS_NATIVE_ASSET_PREFIX = "e";
        operator = _operator;
        hasBridgeBank = false;
        _initialized = true;
        Oracle._initialize(
            _operator,
            _consensusThreshold,
            _initValidators,
            _initPowers
        );
    }

    function changeOperator(address _newOperator) public onlyOperator {

        require(_newOperator != address(0), "invalid address");
        operator = _newOperator;
    }

    function setBridgeBank(address payable _bridgeBank) public onlyOperator {

        require(
            !hasBridgeBank,
            "The Bridge Bank cannot be updated once it has been set"
        );

        hasBridgeBank = true;
        bridgeBank = _bridgeBank;

        emit LogBridgeBankSet(bridgeBank);
    }

    function getProphecyID(
        ClaimType _claimType,
        bytes calldata _cosmosSender,
        uint256 _cosmosSenderSequence,
        address payable _ethereumReceiver,
        string calldata _symbol,
        uint256 _amount
    ) external pure returns (uint256) {

        return uint256(keccak256(abi.encodePacked(_claimType, _cosmosSender, _cosmosSenderSequence, _ethereumReceiver, _symbol, _amount)));
    }

    function newProphecyClaim(
        ClaimType _claimType,
        bytes memory _cosmosSender,
        uint256 _cosmosSenderSequence,
        address payable _ethereumReceiver,
        string memory _symbol,
        uint256 _amount
    ) public onlyValidator {

        uint256 _prophecyID = uint256(keccak256(abi.encodePacked(_claimType, _cosmosSender, _cosmosSenderSequence, _ethereumReceiver, _symbol, _amount)));
        (bool prophecyCompleted, , ) = getProphecyThreshold(_prophecyID);
        require(!prophecyCompleted, "prophecyCompleted");

        if (oracleClaimValidators[_prophecyID] == 0) {
            string memory symbol;
            if (_claimType == ClaimType.Burn) {
                symbol = BridgeBank(bridgeBank).safeLowerToUpperTokens(_symbol);
                require(
                    BridgeBank(bridgeBank).getLockedFunds(symbol) >= _amount,
                    "Not enough locked assets to complete the proposed prophecy"
                );
                address tokenAddress = BridgeBank(bridgeBank).getLockedTokenAddress(symbol);
                if (tokenAddress == address(0) && uint256(keccak256(abi.encodePacked(symbol))) != uint256(keccak256("eth"))) {
                    revert("Invalid token address");
                }
            } else if (_claimType == ClaimType.Lock) {
                symbol = concat(COSMOS_NATIVE_ASSET_PREFIX, _symbol); // Add 'e' symbol prefix
                symbol = BridgeBank(bridgeBank).safeLowerToUpperTokens(symbol);
                address bridgeTokenAddress = BridgeBank(bridgeBank).getBridgeToken(symbol);
                if (bridgeTokenAddress == address(0)) {
                    BridgeBank(bridgeBank).createNewBridgeToken(symbol);
                }
            } else {
                revert("Invalid claim type, only burn and lock are supported.");
            }

            emit LogNewProphecyClaim(
                _prophecyID,
                _claimType,
                _ethereumReceiver,
                symbol,
                _amount
            );
        }

        bool claimComplete = newOracleClaim(_prophecyID, msg.sender);

        if (claimComplete) {
            address tokenAddress;
            if (_claimType == ClaimType.Lock) {
                _symbol = concat(COSMOS_NATIVE_ASSET_PREFIX, _symbol);
                _symbol = BridgeBank(bridgeBank).safeLowerToUpperTokens(_symbol);
                tokenAddress = BridgeBank(bridgeBank).getBridgeToken(_symbol);
            } else {
                _symbol = BridgeBank(bridgeBank).safeLowerToUpperTokens(_symbol);
                tokenAddress = BridgeBank(bridgeBank).getLockedTokenAddress(_symbol);
            }
            completeProphecyClaim(
                _prophecyID,
                tokenAddress,
                _claimType,
                _ethereumReceiver,
                _symbol,
                _amount
            );
        }
    }

    function completeProphecyClaim(
        uint256 _prophecyID,
        address tokenAddress,
        ClaimType claimType,
        address payable ethereumReceiver,
        string memory symbol,
        uint256 amount
    ) internal {


        if (claimType == ClaimType.Burn) {
            unlockTokens(ethereumReceiver, symbol, amount);
        } else {
            issueBridgeTokens(ethereumReceiver, tokenAddress, symbol, amount);
        }

        emit LogProphecyCompleted(_prophecyID, claimType);
    }

    function issueBridgeTokens(
        address payable ethereumReceiver,
        address tokenAddress,
        string memory symbol,
        uint256 amount
    ) internal {

        BridgeBank(bridgeBank).mintBridgeTokens(
            ethereumReceiver,
            tokenAddress,
            symbol,
            amount
        );
    }

    function unlockTokens(
        address payable ethereumReceiver,
        string memory symbol,
        uint256 amount
    ) internal {

        BridgeBank(bridgeBank).unlock(
            ethereumReceiver,
            symbol,
            amount
        );
    }

    function concat(string memory _prefix, string memory _suffix)
        internal
        pure
        returns (string memory)
    {

        return string(abi.encodePacked(_prefix, _suffix));
    }
}pragma solidity 0.5.16;

contract PauserRole {


    mapping (address => bool) public pausers;

    modifier onlyPauser() {

        require(pausers[msg.sender], "PauserRole: caller does not have the Pauser role");
        _;
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {

        pausers[account] = true;
    }

    function _removePauser(address account) internal {

        pausers[account] = false;
    }
}pragma solidity 0.5.16;


contract Pausable is PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;


    function initialize (address _user) internal {
        _addPauser(_user);
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

    function togglePause() private {

        _paused = !_paused;
    }

    function pause() external onlyPauser whenNotPaused {

        togglePause();
        emit Paused(msg.sender);
    }

    function unpause() external onlyPauser whenPaused {

        togglePause();
        emit Unpaused(msg.sender);
    }
}pragma solidity 0.5.16;



contract BridgeBank is BankStorage,
    CosmosBank,
    EthereumBank,
    EthereumWhiteList,
    CosmosWhiteList,
    Pausable {


    bool private _initialized;

    using SafeMath for uint256;

    function initialize(
        address _operatorAddress,
        address _cosmosBridgeAddress,
        address _owner,
        address _pauser
    ) public {

        require(!_initialized, "Init");

        EthereumWhiteList.initialize();
        CosmosWhiteList.initialize();
        Pausable.initialize(_pauser);

        operator = _operatorAddress;
        cosmosBridge = _cosmosBridgeAddress;
        owner = _owner;
        _initialized = true;

        lowerToUpperTokens["erowan"] = "erowan";
        lowerToUpperTokens["eth"] = "eth";
    }

    modifier onlyOperator() {

        require(msg.sender == operator, "!operator");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "!owner");
        _;
    }

    modifier onlyCosmosBridge() {

        require(
            msg.sender == cosmosBridge,
            "!cosmosbridge"
        );
        _;
    }

    modifier validSifAddress(bytes memory _sifAddress) {

        require(_sifAddress.length == 42, "Invalid len");
        require(verifySifPrefix(_sifAddress) == true, "Invalid sif address");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {

        require(_newOwner != address(0), "invalid address");
        owner = _newOwner;
    }

    function changeOperator(address _newOperator) public onlyOperator {

        require(_newOperator != address(0), "invalid address");
        operator = _newOperator;
    }

    function verifySifPrefix(bytes memory _sifAddress) public pure returns (bool) {

        bytes3 sifInHex = 0x736966;

        for (uint256 i = 0; i < sifInHex.length; i++) {
            if (sifInHex[i] != _sifAddress[i]) {
                return false;
            }
        }
        return true;
    }

    function createNewBridgeToken(string memory _symbol)
        public
        onlyCosmosBridge
        returns (address)
    {

        address newTokenAddress = deployNewBridgeToken(_symbol);
        setTokenInCosmosWhiteList(newTokenAddress, true);

        return newTokenAddress;
    }

    function addExistingBridgeToken(
        address _contractAddress
    ) public onlyOwner returns (address) {

        setTokenInCosmosWhiteList(_contractAddress, true);

        return useExistingBridgeToken(_contractAddress);
    }

    function updateEthWhiteList(address _token, bool _inList)
        public
        onlyOperator
        returns (bool)
    {

        string memory symbol = BridgeToken(_token).symbol();
        address listAddress = lockedTokenList[symbol];
        
        if (_inList) {
            require(listAddress == address(0), "whitelisted");
        } else {
            require(uint256(listAddress) > 0, "!whitelisted");
        }
        lowerToUpperTokens[toLower(symbol)] = symbol;
        return setTokenInEthWhiteList(_token, _inList);
    }

    function _updateTokenLimits(address _token, uint256 _amount) private {

        string memory symbol = _token == address(0) ? "eth" : BridgeToken(_token).symbol();
        maxTokenAmount[symbol] = _amount;
    }

    function updateTokenLockBurnLimit(address _token, uint256 _amount)
        public
        onlyOperator
        returns (bool)
    {

        _updateTokenLimits(_token, _amount);
        return true;
    }

    function bulkWhitelistUpdateLimits(
        address[] calldata tokenAddresses,
        uint256[] calldata tokenLimit
        ) external
        onlyOperator
        returns (bool)
    {

        require(tokenAddresses.length == tokenLimit.length, "!same length");
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            _updateTokenLimits(tokenAddresses[i], tokenLimit[i]);
            setTokenInEthWhiteList(tokenAddresses[i], true);
            string memory symbol = BridgeToken(tokenAddresses[i]).symbol();
            lowerToUpperTokens[toLower(symbol)] = symbol;
        }
        return true;
    }

    function mintBridgeTokens(
        address payable _intendedRecipient,
        address _bridgeTokenAddress,
        string memory _symbol,
        uint256 _amount
    ) public onlyCosmosBridge whenNotPaused {

        return
            mintNewBridgeTokens(
                _intendedRecipient,
                _bridgeTokenAddress,
                _symbol,
                _amount
            );
    }

    function burn(
        bytes memory _recipient,
        address _token,
        uint256 _amount
    ) public validSifAddress(_recipient) onlyCosmosTokenWhiteList(_token) whenNotPaused {

        string memory symbol = BridgeToken(_token).symbol();

        if (_amount > maxTokenAmount[symbol]) {
            revert("Amount being transferred is over the limit for this token");
        }

        BridgeToken(_token).burnFrom(msg.sender, _amount);
        burnFunds(msg.sender, _recipient, _token, symbol, _amount);
    }

    function lock(
        bytes memory _recipient,
        address _token,
        uint256 _amount
    ) public payable onlyEthTokenWhiteList(_token) validSifAddress(_recipient) whenNotPaused {

        string memory symbol;

        if (msg.value > 0) {
            require(
                _token == address(0),
                "!address(0)"
            );
            require(
                msg.value == _amount,
                "incorrect eth amount"
            );
            symbol = "eth";
        } else {
            IERC20 tokenToTransfer = IERC20(_token);
            tokenToTransfer.safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
            symbol = BridgeToken(_token).symbol();
        }

        if (_amount > maxTokenAmount[symbol]) {
            revert("Amount being transferred is over the limit");
        }
        lockFunds(msg.sender, _recipient, _token, symbol, _amount);
    }

    function unlock(
        address payable _recipient,
        string memory _symbol,
        uint256 _amount
    ) public onlyCosmosBridge whenNotPaused {

        require(
            getLockedFunds(_symbol) >= _amount,
            "!Bank funds"
        );

        address tokenAddress = lockedTokenList[_symbol];
        if (tokenAddress == address(0)) {
            require(
                ((address(this)).balance) >= _amount,
                "Insufficient ethereum balance for delivery."
            );
        } else {
            require(
                BridgeToken(tokenAddress).balanceOf(address(this)) >= _amount,
                "Insufficient ERC20 token balance for delivery."
            );
        }
        unlockFunds(_recipient, tokenAddress, _symbol, _amount);
    }

    function tokenFallback(address _from, uint _value, bytes memory _data) public {}

}