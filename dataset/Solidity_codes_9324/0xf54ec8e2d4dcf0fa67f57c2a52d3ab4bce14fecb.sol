
pragma solidity 0.6.12;


library AddressUpgradeable {

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


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}


interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}


contract FortubeDao is ERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public reservedToken;

    uint256 public slope;

    uint256 public intercept;

    uint256 public totalToken;

    uint256 public sellDelay;

    address public operator;

    address public multiSig;

    mapping(address => uint256) public lastBoughtTime;

    address public treasury;

    uint256 public penalty; // 300/10000 for 0.03, max % is 10%

    mapping (address => address) public delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    event Bought(address user, uint256 forAmount, uint256 daoAmount, uint256 timestamp);

    event Sold(address user, uint256 userForAmount, uint256 penaltyForAmount, uint256 daoAmount, uint256 timestamp);

    event SponsorIn(address sponsorFrom, uint256 totalToken, uint256 inAmount);

    event SponsorOut(uint256 totalToken, address sponsorTo, uint256 outAmount);

    event SellDelayChanged(uint256 oldSellDelay, uint256 newSellDelay);

    event OperatorChanged(address oldOperator, address newOperator);

    event MultiSigChanged(address oldMultiSig, address newMultiSig);

    event TreasuryChanged(address oldTreasury, address newTreasury);

    event PenaltyChanged(uint256 oldPenalty, uint256 newPenalty);

    event Synced(uint256 oldSlope, uint256 newSlope);

    modifier onlyOperator {

        require(msg.sender == operator, "Operator required");
        _;
    }

    modifier onlyMultiSig {

        require(msg.sender == multiSig, "MultiSig required");
        _;
    }

    function initialize(
        uint256 _slope,
        uint256 _intercept,
        address _reservedToken,
        address _multiSig,
        address _treasury
    ) public initializer {

        __ERC20_init("ForTube DAO", "FDAO");
        slope = _slope;
        intercept = _intercept;
        reservedToken = _reservedToken;
        sellDelay = 3 days;
        operator = msg.sender;
        multiSig = _multiSig;
        penalty = 300;//0.03
        treasury = _treasury;
    }

    function buy(uint256 amount, uint256 amountOutMin) external {

        require(amount > 0, "Invalid amount");
        require(
            IERC20Upgradeable(reservedToken).balanceOf(msg.sender) >= amount,
            "Insufficient token"
        );

        uint256 daoAmount = calculatePurchaseReturn(amount);
        require(daoAmount >= amountOutMin, "ForTubeDAO: INSUFFICIENT_OUTPUT_FDAO_AMOUNT");
        require(daoAmount > 0, "Zero DAO amount");
        _mint(msg.sender, daoAmount);
        totalToken = totalToken.add(amount);

        lastBoughtTime[msg.sender] = block.timestamp;

        sync();
        IERC20Upgradeable(reservedToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        emit Bought(msg.sender, amount, daoAmount, block.timestamp);
    }

    function buyExactDAO(uint256 daoAmount, uint256 amountInMax) external {

        require(daoAmount > 0, "Invalid daoAmount");

        uint256 amount = calculateBuyReturn(daoAmount);
        require(amount <= amountInMax, "ForTubeDAO: INPUT_FOR_AMOUNT");
        require(
            IERC20Upgradeable(reservedToken).balanceOf(msg.sender) >= amount,
            "Insufficient token"
        );

        _mint(msg.sender, daoAmount);
        totalToken = totalToken.add(amount);

        lastBoughtTime[msg.sender] = block.timestamp;

        sync();
        IERC20Upgradeable(reservedToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        emit Bought(msg.sender, amount, daoAmount, block.timestamp);
    }

    function sell(uint256 daoAmount, uint256 amountOutMin) external {

        require(daoAmount > 0, "Invalid daoAmount");
        require(daoAmount <= balanceOf(msg.sender), "Insufficient daoAmount");

        uint256 amount = calculateSaleReturn(daoAmount);
        require(amount >= amountOutMin, "ForTubeDAO: INSUFFICIENT_OUTPUT_FOR_AMOUNT");
        require(amount > 0, "Zero FOR amount");

        uint256 _penaltyAmount = 0;
        _burn(msg.sender, daoAmount);

        amount = min(totalToken, amount);
        totalToken = totalToken.sub(amount);

        if (block.timestamp < lastBoughtTime[msg.sender] + sellDelay) {
            _penaltyAmount = amount.mul(penalty).div(10000);
            amount = amount.sub(_penaltyAmount);
            IERC20Upgradeable(reservedToken).safeTransfer(treasury, _penaltyAmount);
        }

        sync();
        IERC20Upgradeable(reservedToken).safeTransfer(msg.sender, amount);
        emit Sold(msg.sender, amount, _penaltyAmount, daoAmount, block.timestamp);
    }


    function sellExactDAO(uint256 amount, uint256 amountInMax) external {

        require(amount > 0, "Invalid daoAmount");

        uint256 daoAmount = calculateSaleExactReturn(amount);
        require(amountInMax >= daoAmount, "ForTubeDAO: INSUFFICIENT_OUTPUT_FOR_AMOUNT");
        require(daoAmount > 0, "Zero FOR amount");
        require(daoAmount <= balanceOf(msg.sender), "Insufficient daoAmount");

        uint256 _penaltyAmount = 0;
        _burn(msg.sender, daoAmount);

        amount = min(totalToken, amount);
        totalToken = totalToken.sub(amount);

        if (block.timestamp < lastBoughtTime[msg.sender] + sellDelay) {
            _penaltyAmount = amount.mul(penalty).div(10000);
            amount = amount.sub(_penaltyAmount);
            IERC20Upgradeable(reservedToken).safeTransfer(treasury, _penaltyAmount);
        }

        sync();
        IERC20Upgradeable(reservedToken).safeTransfer(msg.sender, amount);
        emit Sold(msg.sender, amount, _penaltyAmount, daoAmount, block.timestamp);
    }


    function sponsorIn(uint256 amount) external {

        require(amount > 0, "Invalid amount");
        require(totalSupply() > 0, "Cannot sponsor when totalSupply is 0");

        totalToken = totalToken.add(amount);
        sync();
        IERC20Upgradeable(reservedToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        emit SponsorIn(msg.sender, totalToken, amount);
    }

    function sponsorOut(address sponsorTo, uint256 amount)
        external
        onlyMultiSig
    {

        require(amount > 0 && amount <= calcMaxSponsorOut(), "Invalid amount");
        require(sponsorTo != address(0), "Invalid address");

        totalToken = totalToken.sub(amount);
        sync();
        require(slope > 0, "Invalid slope");
        IERC20Upgradeable(reservedToken).safeTransfer(sponsorTo, amount);

        emit SponsorOut(totalToken, sponsorTo, amount);
    }

    function sync() internal {

        uint256 oldSlope = slope;
        slope = calcNewSlope(totalToken, totalSupply());

        emit Synced(oldSlope, slope);
    }

    function calculatePurchaseReturn(uint256 _amount)
        public
        view
        returns (uint256 daoAmount)
    {

        uint256 supply = totalSupply();

        uint256 a = slope.mul(supply).div(1e18).add(intercept);
        a = a.mul(a).div(1e18);
        int256 radicand = int256(a.add(slope.mul(_amount).mul(2).div(1e18)));
        uint256 b =
            uint256(sqrt(uint256(radicand * 1e18))).sub(
                slope.mul(supply).div(1e18).add(intercept)
            );

        daoAmount = b.mul(1e18).div(slope);
    }

    function calculateSaleReturn(uint256 _sellAmount)
        public
        view
        returns (uint256 amount)
    {

        uint256 a =
            slope
                .mul(totalSupply())
                .div(1e18)
                .sub(slope.mul(_sellAmount).div(2e18))
                .add(intercept);
        amount = a.mul(_sellAmount).div(1e18);
    }


    function calculateBuyReturn(uint256 _buyFdaoAmount) public view returns (uint256 amount) {

        uint256 a =
            slope
                .mul(totalSupply())
                .div(1e18)
                .add(slope.mul(_buyFdaoAmount).div(2e18))
                .add(intercept);
        amount = a.mul(_buyFdaoAmount).div(1e18);
    }



    function calculateSaleExactReturn(uint256 _amount)
        public
        view
        returns (uint256 daoAmount)
    {

        uint256 supply = totalSupply();

        uint256 a = slope.mul(supply).div(1e18).add(intercept);
        uint256 p = a.mul(a).div(1e18);
        int256 radicand = int256(p.sub(slope.mul(_amount).mul(2).div(1e18)));
        uint256 b = a.sub(sqrt(uint256(radicand * 1e18)));
        daoAmount = b.mul(1e18).div(slope);
    }


    function calcNewSlope(uint256 _totalToken, uint256 supply)
        public
        view
        returns (uint256)
    {

        uint256 dividend =
            _totalToken.mul(2e18).div(supply).sub(intercept.mul(2));
        return dividend.mul(1e18).div(supply);
    }


    function calcMaxSponsorOut() public view returns (uint256) {

        uint256 supply = totalSupply();
        return supply.mul(supply).mul(slope).div(2e36);
    }


    function setSellDelay(uint256 _sellDelay) external onlyOperator {

        uint256 oldDelay = sellDelay;
        sellDelay = _sellDelay;

        emit SellDelayChanged(oldDelay, sellDelay);
    }

    function setPenalty(uint256 _newPenalty) external onlyMultiSig {

        require(_newPenalty <= 1000, "Penalty rate exceed max 10% limit");

        uint256 oldPenalty = penalty;
        penalty = _newPenalty;

        emit PenaltyChanged(oldPenalty, _newPenalty);
    }


    function setOperator(address _operator) external onlyMultiSig {

        address oldOperator = operator;
        operator = _operator;

        emit OperatorChanged(oldOperator, operator);
    }


    function setMultiSig(address _multiSig) external onlyMultiSig {

        address oldMultiSig = multiSig;
        multiSig = _multiSig;

        emit MultiSigChanged(oldMultiSig, multiSig);
    }

    function setTreasury(address _treasury) external onlyMultiSig {

        require(_treasury != address(0), "treasury should not address(0)");

        address oldTreasury = treasury;
        treasury = _treasury;

        emit TreasuryChanged(oldTreasury, treasury);
    }

    function min(uint256 a, uint256 b) public pure returns (uint256) {

        return a > b ? b : a;
    }

    function sqrt(uint x) public pure returns (uint) {

        if (x == 0) return 0;
        uint xx = x;
        uint r = 1;

        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }

        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }

        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint r1 = x / r;
        return (r < r1 ? r : r1);
    }

    function delegate(address delegatee) external {

        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "FDAO::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "FDAO::delegateBySig: invalid nonce");
        require(now <= expiry, "FDAO::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint96) {

        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber) external view returns (uint96) {

        require(blockNumber < block.number, "FDAO::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {

        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = safe96(balanceOf(delegator), "FDAO::balanceOf: amount exceeds 96 bits");
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint96 amount) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, "FDAO::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "FDAO::_moveVotes: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {

      uint32 blockNumber = safe32(block.number, "FDAO::_writeCheckpoint: block number exceeds 32 bits");

      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }

      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {

        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal pure returns (uint) {

        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {

        _moveDelegates(delegates[from], delegates[to], safe96(amount, "FDAO::transfer: amount exceeds 96 bits"));
    }
}