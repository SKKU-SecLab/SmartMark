
pragma solidity ^0.8.0;


library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library SignedSafeMathUpgradeable {

    function mul(int256 a, int256 b) internal pure returns (int256) {

        return a * b;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        return a - b;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        return a + b;
    }
}// MIT

pragma solidity ^0.8.0;

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

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
}// MIT

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
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}pragma solidity ^0.8.0;

interface ICertToken {


    event PoolContractChanged(address oldPool, address newPool);

    event BondTokenChanged(address oldBondToken, address newBondToken);

    function changePoolContract(address newPoolContract) external;


    function changeBondToken(address newBondToken) external;


    function burn(address account, uint256 amount) external;


    function mint(address account, uint256 amount) external;


    function bondTransferTo(address account, uint256 shares) external;


    function bondTransferFrom(address account, uint256 shares) external;


    function balanceWithRewardsOf(address account) external returns (uint256);


    function isRebasing() external returns (bool);


    function ratio() external view returns (uint256);

}// GPL-3.0-only
pragma solidity ^0.8.6;

interface IinternetBond_R1 {


    event CertTokenChanged(address oldCertToken, address newCertToken);

    event SwapFeeOperatorChanged(address oldSwapFeeOperator, address newSwapFeeOperator);

    event SwapFeeRatioUpdate(uint256 newSwapFeeRatio);

    function balanceToShares(uint256 bonds) external view returns (uint256);


    function burn(address account, uint256 amount) external;


    function changeCertToken(address newCertToken) external;


    function changeSwapFeeOperator(address newSwapFeeOperator) external;


    function commitDelayedBurn(address account, uint256 amount) external;


    function getSwapFeeInBonds(uint256 bonds) external view returns(uint256);


    function getSwapFeeInShares(uint256 shares) external view returns(uint256);


    function lockForDelayedBurn(address account, uint256 amount) external;


    function lockShares(uint256 shares) external;


    function lockSharesFor(address account, uint256 shares) external;


    function mintBonds(address account, uint256 amount) external;


    function pendingBurn(address account) external view returns (uint256);


    function ratio() external view returns (uint256);


    function sharesOf(address account) external view returns (uint256);


    function sharesToBalance(uint256 shares) external view returns (uint256);


    function totalSharesSupply() external view returns (uint256);


    function unlockShares(uint256 shares) external;


    function unlockSharesFor(address account, uint256 bonds) external;


    function updateSwapFeeRatio(uint256 newSwapFeeRatio) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;



contract ERC20BondBase is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

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
    unchecked {
        _balances[sender] = senderBalance - amount;
    }
        _balances[recipient] += amount;

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
    }
        _totalSupply -= amount;

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    uint256[45] private __gap;
}// GPL-3.0-only
pragma solidity ^0.8.0;



contract aMATICb_R4 is OwnableUpgradeable, ERC20BondBase, IinternetBond_R1 {


    using SafeMathUpgradeable for uint256;
    using MathUpgradeable for uint256;
    using SignedSafeMathUpgradeable for int256;

    event RatioUpdate(uint256 newRatio);
    event LastConfirmedRatioUpdate(uint256 newRatio);

    address private _operator;
    address private _crossChainBridge;
    address private _polygonPool;
    uint256 private _ratio;
    int256 private _lockedShares;

    mapping(address => uint256) private _pendingBurn;
    uint256 private _pendingBurnsTotal;

    uint256 private _collectableFee;

    string private _name;
    string private _symbol;

    address public certToken; // aMATICc

    address public swapFeeOperator;
    uint256 public swapFeeRatio;

    function initialize(address operator) public initializer {

        __Ownable_init();
        __ERC20_init("Ankr MATIC Reward Earning Bond", "aMATICb");
        _operator = operator;
        _ratio = 1e18;
    }

    function ratio() public override view returns (uint256) {

        return _ratio;
    }

    function isRebasing() public pure returns (bool) {

        return true;
    }

    function updateRatio(uint256 newRatio) public onlyOperator {

        require(newRatio <= 1e18, "new ratio should be less or equal to 1e18");
        _ratio = newRatio;
        emit RatioUpdate(_ratio);
    }

    function repairRatio(uint256 newRatio) public onlyOwner {

        _ratio = newRatio;
        emit RatioUpdate(_ratio);
    }

    function collectableFee() public view returns (uint256) {

        return _collectableFee;
    }

    function repairCollectableFee(uint256 newFee) public onlyOwner {

        _collectableFee = newFee;
    }

    function updateRatioAndFee(uint256 newRatio, uint256 newFee) public onlyOperator {

        uint256 threshold = _ratio.div(500);
        require(newRatio < _ratio.add(threshold) || newRatio > _ratio.sub(threshold), "New ratio should be in limits");
        require(newRatio <= 1e18, "new ratio should be less or equal to 1e18");
        _ratio = newRatio;
        _collectableFee = newFee;
        emit RatioUpdate(_ratio);
    }

    function totalSupply() public view override returns (uint256) {

        uint256 supply = totalSharesSupply();
        return _sharesToBonds(supply);
    }

    function totalSharesSupply() public view override returns (uint256) {

        return super.totalSupply();
    }

    function balanceOf(address account) public view override returns (uint256) {

        uint256 shares = super.balanceOf(account);
        return _sharesToBonds(shares).sub(_pendingBurn[account]);
    }

    function sharesOf(address account) public view override returns (uint256) {

        return super.balanceOf(account);
    }

    function mintBonds(address account, uint256 amount) public override onlyBondMinter {

        uint256 shares = _bondsToShares(amount);
        _mint(account, shares);
        emit Transfer(address(0), account, _sharesToBonds(shares));
    }

    function mint(address account, uint256 shares) public onlyMinter {

        _lockedShares = _lockedShares.sub(int256(shares));
        _mint(account, shares);
        emit Transfer(address(0), account, _sharesToBonds(shares));
    }

    function burn(address account, uint256 amount) public override onlyMinter {

        uint256 shares = _bondsToShares(amount);
        _lockedShares = _lockedShares.add(int256(shares));
        _burn(account, shares);
        emit Transfer(account, address(0), _sharesToBonds(shares));
    }

    function _mint(address account, uint256 shares) internal override {

        super._mint(account, shares);
        ICertToken(certToken).mint(address(this), shares);
    }

    function _burn(address account, uint256 shares) internal override {

        super._burn(account, shares);
        ICertToken(certToken).burn(address(this), shares);
    }

    function pendingBurn(address account) external view override returns (uint256) {

        return _pendingBurn[account];
    }

    function lockForDelayedBurn(address account, uint256 amount) public override onlyBondMinter {

        _pendingBurn[account] = _pendingBurn[account].add(amount);
        _pendingBurnsTotal = _pendingBurnsTotal.add(amount);
    }

    function commitDelayedBurn(address account, uint256 amount) public override onlyBondMinter {

        uint256 burnableAmount = _pendingBurn[account];
        require(burnableAmount >= amount, "Too big amount to burn");
        uint256 sharesToBurn = _bondsToShares(amount);
        _pendingBurn[account] = burnableAmount.sub(amount);
        _pendingBurnsTotal = _pendingBurnsTotal.sub(amount);
        _burn(account, sharesToBurn);
        emit Transfer(account, address(0), _sharesToBonds(sharesToBurn));
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        uint256 shares = _bondsToShares(amount);
        super.transfer(recipient, shares);
        emit Transfer(msg.sender, recipient, _sharesToBonds(shares));
        return true;
    }

    function transferShares(address sender, address recipient, uint256 shares) internal returns (bool) {

        super._transfer(sender, recipient, shares);
        emit Transfer(sender, recipient, _sharesToBonds(shares));
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _sharesToBonds(super.allowance(owner, spender));
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        uint256 shares = _bondsToShares(amount);
        super.approve(spender, shares);
        emit Approval(msg.sender, spender, allowance(msg.sender, spender));
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        uint256 shares = _bondsToShares(amount);
        super.transferFrom(sender, recipient, shares);
        emit Transfer(sender, recipient, _sharesToBonds(shares));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {

        uint256 shares = _bondsToShares(addedValue);
        super.increaseAllowance(spender, shares);
        emit Approval(msg.sender, spender, allowance(msg.sender, spender));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {

        uint256 shares = _bondsToShares(subtractedValue);
        super.decreaseAllowance(spender, shares);
        emit Approval(msg.sender, spender, allowance(msg.sender, spender));
        return true;
    }

    function _bondsToShares(uint256 amount) internal view returns (uint256) {

        return safeCeilMultiplyAndDivide(amount, _ratio, 1e18);
    }

    function _sharesToBonds(uint256 amount) internal view returns (uint256) {

        return safeFloorMultiplyAndDivide(amount, 1e18, _ratio);
    }

    modifier onlyOperator() {

        require(msg.sender == owner() || msg.sender == _operator, "Operator: not allowed");
        _;
    }

    modifier onlyMinter() {

        require(msg.sender == owner() || msg.sender == _crossChainBridge, "Minter: not allowed");
        _;
    }

    modifier onlyBondMinter() {

        require(msg.sender == owner() || msg.sender == _polygonPool, "Minter: not allowed");
        _;
    }

    function changeOperator(address operator) public onlyOwner {

        _operator = operator;
    }

    function changePolygonPool(address polygonPool) public onlyOwner {

        _polygonPool = polygonPool;
    }

    function changeCrossChainBridge(address crossChainBridge) public onlyOwner {

        _crossChainBridge = crossChainBridge;
    }

    function lockedSupply() public view returns (int256) {

        return _lockedShares;
    }

    function name() public view override returns (string memory) {

        if (bytes(_name).length != 0) {
            return _name;
        }
        return super.name();
    }

    function symbol() public view override returns (string memory) {

        if (bytes(_symbol).length != 0) {
            return _symbol;
        }
        return super.symbol();
    }

    function setNameAndSymbol(string memory new_name, string memory new_symbol) public onlyOperator {

        _name = new_name;
        _symbol = new_symbol;
    }


    function sharesToBalance(uint256 amount) public override view returns (uint256) {

        return _sharesToBonds(amount);
    }

    function balanceToShares(uint256 amount) public override view returns (uint256) {

        return _bondsToShares(amount);
    }

    function getSwapFeeInBonds(uint256 bonds) public view override returns(uint256) {

        uint256 shares = balanceToShares(bonds);
        uint256 feeInShares = getSwapFeeInShares(shares);
        return sharesToBalance(feeInShares);
    }

    function getSwapFeeInShares(uint256 shares) public view override returns(uint256) {

        return safeCeilMultiplyAndDivide(shares, swapFeeRatio, 1e18);
    }

    function changeCertToken(address newCertToken) external override onlyOwner {

        address oldCertToken = certToken;
        certToken = newCertToken;
        emit CertTokenChanged(oldCertToken, newCertToken);
    }

    function changeSwapFeeOperator(address newSwapFeeOperator) external override onlyOwner {

        address oldSwapFeeOperator = swapFeeOperator;
        swapFeeOperator = newSwapFeeOperator;
        emit SwapFeeOperatorChanged(oldSwapFeeOperator, newSwapFeeOperator);
    }

    function updateSwapFeeRatio(uint256 newRatio) external override onlyOwner {

        require(newRatio <= 1e16, "swapFee must be not greater that 1%");
        swapFeeRatio = newRatio;
        emit SwapFeeRatioUpdate(newRatio);
    }

    function unlockShares(uint256 shares) external override {

        _unlockShares(msg.sender, shares, true);
    }

    function unlockSharesFor(address account, uint256 bonds) external override onlyBondMinter {

        uint256 shares = balanceToShares(bonds);
        _unlockShares(account, shares, false);
    }

    function _unlockShares(address account, uint256 shares, bool takeFee) internal {

        require(sharesOf(account) >= shares, "Insufficient aMATICb balance");

        uint256 fee = 0;
        if (takeFee) {
            fee = getSwapFeeInShares(shares);
        }

        transferShares(account, address(this), shares - fee);
        if (fee != 0) {
            transferShares(account, swapFeeOperator, fee);
        }

        ICertToken(certToken).bondTransferTo(account, shares - fee);
    }

    function lockShares(uint256 shares) external override {

        _lockShares(msg.sender, shares, true);
    }

    function lockSharesFor(address account, uint256 shares) external override onlyBondMinter {

        _lockShares(account, shares, false);
    }

    function _lockShares(address account, uint256 shares, bool takeFee) internal {

        require(IERC20Upgradeable(certToken).balanceOf(account) >= shares, "Insufficient aMATICc balance");

        uint256 fee = 0;
        if (takeFee) {
            fee = getSwapFeeInShares(shares);
        }

        ICertToken(certToken).bondTransferFrom(account, shares);
        transferShares(address(this), account, shares - fee); // can not fail as _balance[address(this)] always equals to amount of aFTMc minted
        if (fee != 0) {
            transferShares(address(this), swapFeeOperator, fee);
        }
    }



    function safeFloorMultiplyAndDivide(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {

        uint256 remainder = a.mod(c);
        uint256 result = a.div(c);
        bool safe;
        (safe, result) = result.tryMul(b);
        if (!safe) {
            return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        }
        (safe, result) = result.tryAdd(remainder.mul(b).div(c));
        if (!safe) {
            return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        }
        return result;
    }

    function safeCeilMultiplyAndDivide(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {

        uint256 remainder = a.mod(c);
        uint256 result = a.div(c);
        bool safe;
        (safe, result) = result.tryMul(b);
        if (!safe) {
            return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        }
        (safe, result) = result.tryAdd(remainder.mul(b).add(c.sub(1)).div(c));
        if (!safe) {
            return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        }
        return result;
    }
}