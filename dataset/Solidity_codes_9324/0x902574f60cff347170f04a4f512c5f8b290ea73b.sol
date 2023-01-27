
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.8.4;

interface ITreasury {
    function hasPool(address _address) external view returns (bool);

    function collateralReserve() external view returns (address);

    function globalCollateralBalance() external view returns (uint256);

    function globalCollateralValue() external view returns (uint256);

    function requestTransfer(
        address token,
        address receiver,
        uint256 amount
    ) external;

    function info()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );
}


pragma solidity 0.8.4;

interface IOracle {
    function consult() external view returns (uint256);
}


pragma solidity 0.8.4;

interface IPool {
    function getCollateralPrice() external view returns (uint256);

    function unclaimed_pool_collateral() external view returns (uint256);
    
    function getNetDollarMinted() external view returns (uint256);
}


pragma solidity 0.8.4;

interface ICollateralRatioPolicy {
    function target_collateral_ratio() external view returns (uint256);

    function effective_collateral_ratio() external view returns (uint256);
}


pragma solidity 0.8.4;

interface ITreasuryPolicy {
    function minting_fee() external view returns (uint256);

    function redemption_fee() external view returns (uint256);

    function excess_collateral_safety_margin() external view returns (uint256);

    function idleCollateralUtilizationRatio() external view returns (uint256);

    function reservedCollateralThreshold() external view returns (uint256);
}


pragma solidity 0.8.4;

interface ICollateralReserve {
    function transferTo(
        address _token,
        address _receiver,
        uint256 _amount
    ) external;
}

pragma solidity 0.8.4;

interface ITreasuryVault {
    function vaultBalance() external view returns (uint256);

    function deposit(uint256 _amount) external;

    function withdraw() external;
}


pragma solidity 0.8.4;

contract Treasury is ITreasury, Ownable, Initializable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public override collateralReserve;
    address public oracleDollar;
    address public oracleShare;
    address public oracleCollateral;
    address public dollar;
    address public share;
    address public collateral;
    address public collateralRatioPolicy;
    address public treasuryPolicy;
    address public controller;
    address public vault;

    address[] public pools_array;
    mapping(address => bool) public pools;

    uint256 private constant PRICE_PRECISION = 1e6;
    uint256 private constant RATIO_PRECISION = 1e6;

    uint256 public missing_decimals;


    modifier onlyPools {
        require(pools[msg.sender], "Only pools can use this function");
        _;
    }

    modifier onlyController {
        require(msg.sender == controller || msg.sender == owner(), "Only controller or owner can trigger");
        _;
    }


    function initialize(
        address _dollar,
        address _share,
        address _collateral,
        address _treasuryPolicy,
        address _collateralRatioPolicy,
        address _collateralReserve,
        address _controller
    ) external initializer onlyOwner {
        require(_dollar != address(0), "invalidAddress");
        require(_share != address(0), "invalidAddress");
        dollar = _dollar;
        share = _share;
        setCollateralAddress(_collateral);
        setTreasuryPolicy(_treasuryPolicy);
        setCollateralRatioPolicy(_collateralRatioPolicy);
        setCollateralReserve(_collateralReserve);
        setController(_controller);
    }


    function dollarPrice() public view returns (uint256) {
        return IOracle(oracleDollar).consult();
    }

    function sharePrice() public view returns (uint256) {
        return IOracle(oracleShare).consult();
    }

    function collateralPrice() public view returns (uint256) {
        return IOracle(oracleCollateral).consult();
    }

    function hasPool(address _address) external view override returns (bool) {
        return pools[_address] == true;
    }

    function target_collateral_ratio() public view returns (uint256) {
        return ICollateralRatioPolicy(collateralRatioPolicy).target_collateral_ratio();
    }

    function effective_collateral_ratio() public view returns (uint256) {
        return ICollateralRatioPolicy(collateralRatioPolicy).effective_collateral_ratio();
    }

    function minting_fee() public view returns (uint256) {
        return ITreasuryPolicy(treasuryPolicy).minting_fee();
    }

    function redemption_fee() public view returns (uint256) {
        return ITreasuryPolicy(treasuryPolicy).redemption_fee();
    }

    function info()
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (dollarPrice(), sharePrice(), IERC20(dollar).totalSupply(), target_collateral_ratio(), effective_collateral_ratio(), globalCollateralValue(), minting_fee(), redemption_fee());
    }

    function globalCollateralBalance() public view override returns (uint256) {
        uint256 _collateralReserveBalance = IERC20(collateral).balanceOf(collateralReserve);
        uint256 _vaultBalance = 0;
        if (vault != address(0)) {
            _vaultBalance = ITreasuryVault(vault).vaultBalance();
        }
        return _collateralReserveBalance + _vaultBalance - totalUnclaimedBalance();
    }

    function globalCollateralValue() public view override returns (uint256) {
        return (globalCollateralBalance() * collateralPrice() * (10**missing_decimals)) / PRICE_PRECISION;
    }

    function totalUnclaimedBalance() public view returns (uint256) {
        uint256 _totalUnclaimed = 0;
        for (uint256 i = 0; i < pools_array.length; i++) {
            if (pools_array[i] != address(0)) {
                _totalUnclaimed = _totalUnclaimed + (IPool(pools_array[i]).unclaimed_pool_collateral());
            }
        }
        return _totalUnclaimed;
    }

    function totalNetDollarMinted() public view returns (uint256) {
        uint256 _totalMinted = 0;
        for (uint256 i = 0; i < pools_array.length; i++) {
            if (pools_array[i] != address(0)) {
                _totalMinted = _totalMinted + (IPool(pools_array[i]).getNetDollarMinted());
            }
        }
        return _totalMinted;
    }

    function excessCollateralBalance() public view returns (uint256 _excess) {
        uint256 _tcr = target_collateral_ratio();
        uint256 _ecr = effective_collateral_ratio();
        if (_ecr <= _tcr) {
            _excess = 0;
        } else {
            _excess = ((_ecr - _tcr) * globalCollateralBalance()) / RATIO_PRECISION;
        }
    }

    function calcCollateralReserveRatio() public view returns (uint256) {
        uint256 _collateralReserveBalance = IERC20(collateral).balanceOf(collateralReserve);
        uint256 _collateralBalanceWithoutVault = _collateralReserveBalance - totalUnclaimedBalance();
        uint256 _globalCollateralBalance = globalCollateralBalance();
        if (_globalCollateralBalance == 0) {
            return 0;
        }
        return (_collateralBalanceWithoutVault * RATIO_PRECISION) / _globalCollateralBalance;
    }

    function isAboveThreshold() public view returns (bool) {
        uint256 _ratio = calcCollateralReserveRatio();
        uint256 _threshold = ITreasuryPolicy(treasuryPolicy).reservedCollateralThreshold();
        return _ratio >= _threshold;
    }


    function recallFromVault() public onlyController {
        _recallFromVault();
    }

    function enterVault() public onlyController {
        _enterVault();
    }

    function rebalanceVault() external onlyController {
        _recallFromVault();
        _enterVault();
    }

    function rebalanceIfUnderThreshold() external onlyController {
        if (!isAboveThreshold()) {
            _recallFromVault();
            _enterVault();
        }
    }

    function extractExcess(uint256 _amount, address _to) external onlyController {
        require(_amount > 0, "zero amount");
        require(_to != address(0), "Invalid _to");
        uint256 _maxExcess = excessCollateralBalance();
        uint256 _maxAllowableAmount = _maxExcess - ((_maxExcess * ITreasuryPolicy(treasuryPolicy).excess_collateral_safety_margin()) / RATIO_PRECISION);
        require(_amount <= _maxAllowableAmount, "Excess allowable amount");
        ICollateralReserve(collateralReserve).transferTo(collateral, _to, _amount);
        emit Excess(_amount);
    }

    function controllerExtract(uint256 _amount, address _to) external onlyController {
        require(_amount > 0, "zero amount");
        require(_to != address(0), "Invalid _to");
        ICollateralReserve(collateralReserve).transferTo(collateral, _to, _amount);
        emit Excess(_amount);
    }

    function _recallFromVault() internal {
        require(vault != address(0), "Vault does not exist");
        ITreasuryVault(vault).withdraw();
        IERC20 _collateral = IERC20(collateral);
        uint256 _balance = _collateral.balanceOf(address(this));
        if (_balance > 0) {
            _collateral.safeTransfer(collateralReserve, _balance);
        }
    }

    function _enterVault() internal {
        require(treasuryPolicy != address(0), "No treasury policy");
        require(vault != address(0), "No vault");
        IERC20 _collateral = IERC20(collateral);

        uint256 _balance = _collateral.balanceOf(address(this));
        if (_balance > 0) {
            _collateral.safeTransfer(collateralReserve, _balance);
        }

        uint256 _collateralBalance = globalCollateralBalance();
        uint256 _idleCollateralUltiRatio = ITreasuryPolicy(treasuryPolicy).idleCollateralUtilizationRatio();
        uint256 _usedAmount = (_idleCollateralUltiRatio * _collateralBalance) / RATIO_PRECISION;
        if (_usedAmount > 0) {
            ICollateralReserve(collateralReserve).transferTo(collateral, address(this), _usedAmount);
            _collateral.safeApprove(vault, 0);
            _collateral.safeApprove(vault, _usedAmount);
            ITreasuryVault(vault).deposit(_usedAmount);
        }
    }


    function requestTransfer(
        address _token,
        address _receiver,
        uint256 _amount
    ) external override onlyPools {
        ICollateralReserve(collateralReserve).transferTo(_token, _receiver, _amount);
    }

    function addPool(address pool_address) public onlyOwner {
        require(pools[pool_address] == false, "poolExisted");
        pools[pool_address] = true;
        pools_array.push(pool_address);
        emit PoolAdded(pool_address);
    }

    function removePool(address pool_address) public onlyOwner {
        require(pools[pool_address] == true, "!pool");
        delete pools[pool_address];
        for (uint256 i = 0; i < pools_array.length; i++) {
            if (pools_array[i] == pool_address) {
                pools_array[i] = address(0); // This will leave a null in the array and keep the indices the same
                break;
            }
        }
        emit PoolRemoved(pool_address);
    }

    function setTreasuryPolicy(address _treasuryPolicy) public onlyOwner {
        require(_treasuryPolicy != address(0), "invalidAddress");
        treasuryPolicy = _treasuryPolicy;
        emit TreasuryPolicyUpdated(_treasuryPolicy);
    }

    function setCollateralRatioPolicy(address _collateralRatioPolicy) public onlyOwner {
        require(_collateralRatioPolicy != address(0), "invalidAddress");
        collateralRatioPolicy = _collateralRatioPolicy;
        emit CollateralPolicyUpdated(_collateralRatioPolicy);
    }

    function setOracleDollar(address _oracleDollar) external onlyOwner {
        require(_oracleDollar != address(0), "invalidAddress");
        oracleDollar = _oracleDollar;
    }

    function setOracleShare(address _oracleShare) external onlyOwner {
        require(_oracleShare != address(0), "invalidAddress");
        oracleShare = _oracleShare;
    }

    function setOracleCollateral(address _oracleCollateral) external onlyOwner {
        require(_oracleCollateral != address(0), "invalidAddress");
        oracleCollateral = _oracleCollateral;
    }

    function setCollateralAddress(address _collateral) public onlyOwner {
        require(_collateral != address(0), "invalidAddress");
        collateral = _collateral;
        missing_decimals = 18 - ERC20(_collateral).decimals();
    }

    function setCollateralReserve(address _collateralReserve) public onlyOwner {
        require(_collateralReserve != address(0), "invalidAddress");
        collateralReserve = _collateralReserve;
        emit CollateralReserveUpdated(_collateralReserve);
    }

    function setController(address _controller) public onlyOwner {
        require(_controller != address(0), "invalidAddress");
        controller = _controller;
        emit ControllerUpdated(_controller);
    }

    function setVault(address _vault) external onlyController {
        require(_vault != address(0), "invalidAddress");
        vault = _vault;
        emit VaultUpdated(_vault);
    }


    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) public onlyOwner returns (bytes memory) {
        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, string("TreasuryVaultAave::executeTransaction: Transaction execution reverted."));
        return returnData;
    }

    receive() external payable {}

    event PoolAdded(address indexed pool);
    event PoolRemoved(address indexed pool);
    event CollateralPolicyUpdated(address indexed pool);
    event VaultUpdated(address indexed pool);
    event ControllerUpdated(address indexed pool);
    event CollateralReserveUpdated(address indexed pool);
    event TreasuryPolicyUpdated(address indexed pool);
    event Excess(uint256 amount);
    
}