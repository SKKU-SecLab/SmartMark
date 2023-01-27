



pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}



pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}



pragma solidity ^0.8.2;



abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(address newImplementation, bytes memory data, bool forceCall) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature(
                    "upgradeTo(address)",
                    oldImplementation
                )
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _setImplementation(newImplementation);
            emit Upgraded(newImplementation);
        }
    }

    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(
            Address.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
}




pragma solidity ^0.8.0;

abstract contract UUPSUpgradeable is ERC1967Upgrade {
    function upgradeTo(address newImplementation) external virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
}



pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}



pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}



pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _newOwner = newOwner;
    }

    function acceptOwnership() public virtual {
        require(msg.sender == _newOwner);
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }

    uint256[48] private __gap;
}



pragma solidity >=0.8.0;



interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}


abstract contract ERC20Interface {
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address tokenOwner) public virtual view returns (uint balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint remaining);
    function transfer(address to, uint tokens) public virtual returns (bool success);
    function approve(address spender, uint tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint tokens) public virtual returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


abstract contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public virtual;
}


contract OnePlanetCarbonOffsetRootV1 is ERC20Interface, OwnableUpgradeable, UUPSUpgradeable {

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint public startDate;
    uint public endDate;
    uint public _maxSupply;
    uint public updateInterval;
    uint public currentIntervalRound;
    AggregatorV3Interface internal priceFeed;
    uint public ethPrice;
    uint public ethAmount;
    uint public ethPrice1PL;
    uint public sigDigits;
    uint public offsetSigDigits;
    uint public tokenPrice;
	address payable public oracleAddress;
	address payable public daiAddress;
	address payable public tetherAddress;
    address payable public usdcAddress;
	address public retireAddress;
	uint256 public gasCO2factor;
	uint256 public CO2factor1; // for future use cases
	uint256 public CO2factor2;
	uint256 public CO2factor3;
	uint256 public CO2factor4;
	uint256 public CO2factor5;
	uint256 public gasEst;
	address public MintableERC20PredicateProxy;
	
    event CarbonOffset(string message);
    event ApprovedDaiPurchase(address buyer, uint256 ApprovedAmount, bool success, bytes data);
    event Deposit(address indexed sender, uint value);
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    
function initialize() public initializer {

        symbol = "1PLCO2";
        name = "1PLANET Carbon Credit";
        decimals = 18;
        sigDigits = 100;
        offsetSigDigits = 1e15; // to 1 kg CO2e
        tokenPrice = 1000;
        updateInterval = 1;
        endDate = block.timestamp + 2000 weeks;
        _maxSupply = 150000000000000000000000000; // 150M metric tons CO2e
		oracleAddress = payable(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
		retireAddress = 0x0000000000000000000000000000000000000000;
		daiAddress = payable(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        tetherAddress = payable(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        usdcAddress = payable(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
		priceFeed = AggregatorV3Interface(oracleAddress);
        gasCO2factor = 380000000000;
        __Ownable_init();
        
        MintableERC20PredicateProxy = 0x9923263fA127b3d1484cFD649df8f1831c2A74e4;
    }


    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    
    modifier onlyPredicate {

        require(msg.sender == MintableERC20PredicateProxy);
        _;
    }

    modifier estGas {

        uint256 gasAtStart = gasleft();
        _;
        gasEst = gasAtStart - gasleft();
    }
    
    function totalSupply() public override view returns (uint) {

        return _totalSupply  - balances[address(0)];
    }
	
    function maxSupply() public view returns (uint) {

        return _maxSupply;
    }

    function balanceOf(address tokenOwner) public override view returns (uint balance) {

        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success) {

        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public override returns (bool success) {

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {

        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {

        return allowed[tokenOwner][spender];
    }


    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    receive() external payable {
        require(block.timestamp >= startDate && block.timestamp <= endDate);
        uint256 weiAmount = msg.value;
        uint256 tokens = _getTokenAmount(weiAmount);
        balances[msg.sender] += tokens;
        _totalSupply += tokens;
        emit Transfer(address(0), msg.sender, tokens);
        payable(owner()).transfer(msg.value);
        currentIntervalRound += 1;
        if(currentIntervalRound == updateInterval) {
            getLatestPrice();
            currentIntervalRound = 0;
        }
    
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        uint256 temp = weiAmount * ethPrice;
        temp /= sigDigits;
        temp /= tokenPrice;
        temp *= 100;
        return temp;
    }
    
    function buy1PLwithDAI(uint256 daiAmount) public returns (bool success) {

        
        ERC20Interface DAIpaymentInstance = ERC20Interface(daiAddress);
        
        require(daiAmount > 0, "You need to send at least some DAI");
        require(DAIpaymentInstance.balanceOf(address(msg.sender)) >= daiAmount, "Not enough DAI");
        uint256 daiAllowance = DAIpaymentInstance.allowance(msg.sender, address(this));
        require(daiAllowance >= daiAmount, "You need to approve more DAI to be spent");
        
        uint256 tokens = daiAmount / tokenPrice;
        tokens *= 100;
        
        DAIpaymentInstance.transferFrom(msg.sender, address(this), daiAmount);
        
        balances[msg.sender] += tokens;
        _totalSupply += tokens;
        
        emit Transfer(address(0), msg.sender, tokens);
        return true;
    }

    function buy1PLwithUSDT(uint256 tetherAmount) public returns (bool success) {

        
        ERC20Interface TETHERpaymentInstance = ERC20Interface(tetherAddress);
        
        require(tetherAmount > 0, "You need to send at least some TETHER");
        require(TETHERpaymentInstance.balanceOf(address(msg.sender)) >= tetherAmount, "Not enough TETHER");
        uint256 tetherAllowance = TETHERpaymentInstance.allowance(msg.sender, address(this));
        require(tetherAllowance >= tetherAmount, "You need to approve more TETHER to be spent");
        
        uint256 tokens = (tetherAmount * 1e14) / tokenPrice;
        
        TETHERpaymentInstance.transferFrom(msg.sender, address(this), tetherAmount);
        
        balances[msg.sender] += tokens;
        _totalSupply += tokens;
        
        emit Transfer(address(0), msg.sender, tokens);
        return true;
    }

    function buy1PLwithUSDC(uint256 usdcAmount) public returns (bool success) {

        
        ERC20Interface USDCpaymentInstance = ERC20Interface(usdcAddress);
        
        require(usdcAmount > 0, "You need to send at least some USDC");
        require(USDCpaymentInstance.balanceOf(address(msg.sender)) >= usdcAmount, "Not enough USDC");
        uint256 usdcAllowance = USDCpaymentInstance.allowance(msg.sender, address(this));
        require(usdcAllowance >= usdcAmount, "You need to approve more USDC to be spent");
        
        uint256 tokens = (usdcAmount * 1e14) / tokenPrice;
        
        USDCpaymentInstance.transferFrom(msg.sender, address(this), usdcAmount);
        
        balances[msg.sender] += tokens;
        _totalSupply += tokens;
        
        emit Transfer(address(0), msg.sender, tokens);
        return true;
    }
    
    function retire1PLCO2(uint tokens, string calldata message) external returns (bool success) {

        require(tokens > offsetSigDigits, "Retire at least 0.001 (1kg) 1PLCO2");
        tokens /= offsetSigDigits;
        tokens *= offsetSigDigits; // retire in kg
        transfer(retireAddress, tokens);
        emit CarbonOffset(message);
        return true;
    }
    
    function offsetDirect(string calldata message) external payable returns (bool success) {

        
        require(msg.value > 0, "You need to send at least some ETH");
        ethAmount = msg.value * (1e18 / offsetSigDigits);
        uint tokens = ethAmount / ethPrice1PL;
        tokens *= offsetSigDigits; // only retire in kg
        balances[retireAddress] += tokens;
        emit Transfer(address(0), retireAddress, tokens);
        emit CarbonOffset(message);
        _totalSupply += tokens;
        getLatestPrice();
        return true;
    }
        
    function update1PLpriceInt(uint price) public onlyOwner {

        tokenPrice = price;
    }
	
	function setOracleAddress(address payable newOracleAddress) public onlyOwner {

        oracleAddress = newOracleAddress;
        priceFeed = AggregatorV3Interface(oracleAddress);
	}

    function setRetireAddress(address newAddress) public onlyOwner {

        retireAddress = newAddress;
    }
    
    function updateGasCO2factor (uint256 CO2factor) external onlyOwner {
        gasCO2factor = CO2factor;
    }
    
    function updateCO2factor1 (uint256 CO2factor) external onlyOwner {
        CO2factor1 = CO2factor;
    }
    
    function updateCO2factor2 (uint256 CO2factor) external onlyOwner {
        CO2factor2 = CO2factor;
    }
    
    function updateCO2factor3 (uint256 CO2factor) external onlyOwner {
        CO2factor3 = CO2factor;
    }
    
    function updateCO2factor4 (uint256 CO2factor) external onlyOwner {
        CO2factor4 = CO2factor;
    }
    
    function updateCO2factor5 (uint256 CO2factor) external onlyOwner {
        CO2factor5 = CO2factor;
    }
    
    
    function setOracleUpdateInterval(uint interval) public onlyOwner {

        updateInterval = interval;
    }

    function genAndSendTokens(address to, uint tokens) external onlyOwner returns (bool success) {

        require(block.timestamp >= startDate && block.timestamp <= endDate);
        require(_maxSupply >= (_totalSupply + tokens));
        balances[to] += tokens;
        _totalSupply += tokens;
        emit Transfer(address(0), to, tokens);
        
        return true;
    }

    function getLatestPrice() public {

        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        require(timeStamp > 0, "Round not complete");
        ethPrice = uint(price) / 1000000;
        uint256 temp = tokenPrice * 1e18;
        ethPrice1PL = temp / ethPrice;
    }

    function updateEthPriceManually(uint price) external onlyOwner {

        ethPrice = price;
    }
    
    function update1PLethPriceManually(uint price) external onlyOwner {

        ethPrice1PL = price;
    }
    
    
    function setMaxVolume(uint maxVolume) external onlyOwner {

        _maxSupply = maxVolume;
    }
    
    function setSigDigits(uint digits) external onlyOwner {

        sigDigits = digits;
    }
    
    function setOffsetSigDigits(uint digits) external onlyOwner {

        offsetSigDigits = digits;
    }


    function topUpBalance() public payable {

    }

    function withdrawFromBalance() public onlyOwner {

        payable(owner()).transfer(address(this).balance);
    }
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) external onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(payable(owner()), tokens);
    }
    
    
    function removePermanently(address account, uint256 amount) external onlyOwner returns (bool success) {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        
        return true;
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    
    
    function mint(address user, uint256 amount) external onlyPredicate {

        _mint(user, amount);
    }
    

    function _mint(address to, uint256 tokens) internal virtual estGas {

        require(to != address(0), "ERC20: mint to the zero address");
        require(block.timestamp >= startDate && block.timestamp <= endDate);
        require(_maxSupply >= (_totalSupply + tokens));
        _beforeTokenTransfer(address(0), to, tokens);
        balances[to] += tokens;
        _totalSupply += tokens;
        emit Transfer(address(0), to, tokens);
    }
    
	
    function updatePredicate(address payable newERC20PredicateProxy) external onlyOwner {

        require(newERC20PredicateProxy != address(0), "Bad ERC20PredicateProxy address");
        MintableERC20PredicateProxy = newERC20PredicateProxy;
    }
    
}