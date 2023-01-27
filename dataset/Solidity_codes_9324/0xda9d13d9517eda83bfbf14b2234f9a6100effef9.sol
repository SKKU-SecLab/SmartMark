


pragma solidity ^0.6.0;

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


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.6.0;






contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    function __ERC20_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {



        _name = name;
        _symbol = symbol;
        _decimals = 18;

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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


    uint256[44] private __gap;
}


pragma solidity ^0.6.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

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


    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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


pragma solidity 0.6.12;


interface ISimpleToken is IERC20 {

    function initialize(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) external;


    function mint(address to, uint256 amount) external;


    function burn(address account, uint256 amount) external;


    function selfDestructToken(address payable refundAddress) external;

}


pragma solidity 0.6.12;



interface IMarket {

    enum MarketState {
        OPEN,
        EXPIRED,
        CLOSED
    }

    enum MarketStyle {
        EUROPEAN_STYLE,
        AMERICAN_STYLE
    }

    function state() external view returns (MarketState);


    function mintOptions(uint256 collateralAmount) external;


    function calculatePaymentAmount(uint256 collateralAmount)
        external
        view
        returns (uint256);


    function calculateFee(uint256 amount, uint16 basisPoints)
        external
        pure
        returns (uint256);


    function exerciseOption(uint256 collateralAmount) external;


    function claimCollateral(uint256 collateralAmount) external;


    function closePosition(uint256 collateralAmount) external;


    function recoverTokens(IERC20 token) external;


    function selfDestructMarket(address payable refundAddress) external;


    function updateRestrictedMinter(address _restrictedMinter) external;


    function marketName() external view returns (string memory);


    function priceRatio() external view returns (uint256);


    function expirationDate() external view returns (uint256);


    function collateralToken() external view returns (IERC20);


    function wToken() external view returns (ISimpleToken);


    function bToken() external view returns (ISimpleToken);


    function updateImplementation(address newImplementation) external;


    function initialize(
        string calldata _marketName,
        address _collateralToken,
        address _paymentToken,
        MarketStyle _marketStyle,
        uint256 _priceRatio,
        uint256 _expirationDate,
        uint16 _exerciseFeeBasisPoints,
        uint16 _closeFeeBasisPoints,
        uint16 _claimFeeBasisPoints,
        address _tokenImplementation
    ) external;

}


pragma solidity 0.6.12;

contract Proxy {

    uint256 constant PROXY_MEM_SLOT = 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;

    constructor(address contractLogic) public {
        require(contractLogic != address(0), "Contract Logic cannot be 0x0");

        assembly {
            sstore(PROXY_MEM_SLOT, contractLogic)
        }
    }

    fallback() external payable {
        assembly {
            let contractLogic := sload(PROXY_MEM_SLOT)
            let ptr := mload(0x40)
            calldatacopy(ptr, 0x0, calldatasize())
            let success := delegatecall(
                gas(),
                contractLogic,
                ptr,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(ptr, 0, retSz)
            switch success
                case 0 {
                    revert(ptr, retSz)
                }
                default {
                    return(ptr, retSz)
                }
        }
    }
}


pragma solidity 0.6.12;

contract Proxiable {

    uint256 constant PROXY_MEM_SLOT = 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;

    event CodeAddressUpdated(address newAddress);

    function _updateCodeAddress(address newAddress) internal {

        require(
            bytes32(PROXY_MEM_SLOT) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly {
            sstore(PROXY_MEM_SLOT, newAddress)
        }

        emit CodeAddressUpdated(newAddress);
    }

    function getLogicAddress() public view returns (address logicAddress) {

        assembly {
            logicAddress := sload(PROXY_MEM_SLOT)
        }
    }

    function proxiableUUID() public pure returns (bytes32) {

        return bytes32(PROXY_MEM_SLOT);
    }
}


pragma solidity 0.6.12;










contract Market is IMarket, OwnableUpgradeSafe, Proxiable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    string public override marketName;
    IERC20 public override collateralToken;
    IERC20 public paymentToken;
    MarketStyle public marketStyle;

    uint256 public override priceRatio;
    uint256 public override expirationDate;

    uint16 public exerciseFeeBasisPoints;
    uint16 public closeFeeBasisPoints;
    uint16 public claimFeeBasisPoints;

    ISimpleToken public override wToken;
    ISimpleToken public override bToken;

    address public restrictedMinter;

    enum FeeType {EXERCISE_FEE, CLOSE_FEE, CLAIM_FEE}

    event MarketInitialized(
        string marketName,
        MarketStyle marketStyle,
        address wToken,
        address bToken
    );

    event OptionMinted(address indexed minter, uint256 value);

    event OptionExercised(address indexed redeemer, uint256 value);

    event CollateralClaimed(address indexed redeemer, uint256 value);

    event OptionClosed(address indexed redeemer, uint256 value);

    event FeePaid(
        FeeType indexed feeType,
        address indexed token,
        uint256 value
    );

    event TokensRecovered(
        address indexed token,
        address indexed to,
        uint256 value
    );

    event MarketDestroyed();

    event RestrictedMinterUpdated(address newRestrictedMinter);

    function initialize(
        string calldata _marketName,
        address _collateralToken,
        address _paymentToken,
        MarketStyle _marketStyle,
        uint256 _priceRatio,
        uint256 _expirationDate,
        uint16 _exerciseFeeBasisPoints,
        uint16 _closeFeeBasisPoints,
        uint16 _claimFeeBasisPoints,
        address _tokenImplementation
    ) public override {

        __Market_init(
            _marketName,
            _collateralToken,
            _paymentToken,
            _marketStyle,
            _priceRatio,
            _expirationDate,
            _exerciseFeeBasisPoints,
            _closeFeeBasisPoints,
            _claimFeeBasisPoints,
            _tokenImplementation
        );
    }

    struct MarketInitLocalVars {
        uint8 decimals;
        Proxy wTokenProxy;
        string wTokenName;
        Proxy bTokenProxy;
        string bTokenName;
    }

    function __Market_init(
        string calldata _marketName,
        address _collateralToken,
        address _paymentToken,
        MarketStyle _marketStyle,
        uint256 _priceRatio,
        uint256 _expirationDate,
        uint16 _exerciseFeeBasisPoints,
        uint16 _closeFeeBasisPoints,
        uint16 _claimFeeBasisPoints,
        address _tokenImplementation
    ) internal initializer {

        require(_collateralToken != address(0x0), "Invalid _collateralToken");
        require(_paymentToken != address(0x0), "Invalid _paymentToken");
        require(_tokenImplementation != address(0x0), "Invalid _tokenImplementation");

        MarketInitLocalVars memory localVars;

        marketName = _marketName;

        collateralToken = IERC20(_collateralToken);
        paymentToken = IERC20(_paymentToken);

        marketStyle = _marketStyle;

        priceRatio = _priceRatio;
        expirationDate = _expirationDate;

        exerciseFeeBasisPoints = _exerciseFeeBasisPoints;
        closeFeeBasisPoints = _closeFeeBasisPoints;
        claimFeeBasisPoints = _claimFeeBasisPoints;

        localVars.decimals = ERC20UpgradeSafe(address(collateralToken))
            .decimals();

        localVars.wTokenProxy = new Proxy(_tokenImplementation);
        wToken = ISimpleToken(address(localVars.wTokenProxy));
        localVars.wTokenName = string(abi.encodePacked("W-", _marketName));
        wToken.initialize(
            localVars.wTokenName,
            localVars.wTokenName,
            localVars.decimals
        );

        localVars.bTokenProxy = new Proxy(_tokenImplementation);
        bToken = ISimpleToken(address(localVars.bTokenProxy));
        localVars.bTokenName = string(abi.encodePacked("B-", _marketName));
        bToken.initialize(
            localVars.bTokenName,
            localVars.bTokenName,
            localVars.decimals
        );

        __Ownable_init();

        emit MarketInitialized(
            marketName,
            marketStyle,
            address(wToken),
            address(bToken)
        );
    }

    function state() public override view returns (MarketState) {

        if (now < expirationDate) {
            return MarketState.OPEN;
        }

        if (now < expirationDate.add(180 days)) {
            return MarketState.EXPIRED;
        }

        return MarketState.CLOSED;
    }

    function mintOptions(uint256 collateralAmount) public override {

        require(
            state() == MarketState.OPEN,
            "Option contract must be in Open State to mint"
        );

        address minter = _msgSender();

        if (restrictedMinter != address(0)) {
            require(
                restrictedMinter == minter,
                "mintOptions: only restrictedMinter can mint"
            );
        }

        collateralToken.safeTransferFrom(
            minter,
            address(this),
            collateralAmount
        );

        wToken.mint(minter, collateralAmount);
        bToken.mint(minter, collateralAmount);

        emit OptionMinted(minter, collateralAmount);
    }

    function calculatePaymentAmount(uint256 collateralAmount)
        public
        override
        view
        returns (uint256)
    {

        return collateralAmount.mul(priceRatio).div(10**18);
    }

    function calculateFee(uint256 amount, uint16 basisPoints)
        public
        override
        pure
        returns (uint256)
    {

        return amount.mul(basisPoints).div(10000);
    }

    function exerciseOption(uint256 collateralAmount) public override {

        require(
            state() == MarketState.OPEN,
            "Option contract must be in Open State to exercise"
        );
        if (marketStyle == IMarket.MarketStyle.EUROPEAN_STYLE) {
            require(
                now >= expirationDate - 1 days,
                "Option contract cannot yet be exercised"
            );
        }

        address redeemer = _msgSender();

        bToken.burn(redeemer, collateralAmount);

        uint256 paymentAmount = calculatePaymentAmount(collateralAmount);
        paymentToken.safeTransferFrom(redeemer, address(this), paymentAmount);

        uint256 feeAmount = calculateFee(
            collateralAmount,
            exerciseFeeBasisPoints
        );
        if (feeAmount > 0) {
            collateralAmount = collateralAmount.sub(feeAmount);

            collateralToken.safeTransfer(owner(), feeAmount);

            emit FeePaid(
                FeeType.EXERCISE_FEE,
                address(collateralToken),
                feeAmount
            );
        }

        collateralToken.safeTransfer(redeemer, collateralAmount);

        emit OptionExercised(redeemer, collateralAmount);
    }

    function claimCollateral(uint256 collateralAmount) public override {

        require(
            state() == MarketState.EXPIRED,
            "Option contract must be in EXPIRED State to claim collateral"
        );

        address redeemer = _msgSender();

        uint256 wTokenSupply = wToken.totalSupply();

        wToken.burn(redeemer, collateralAmount);

        uint256 totalCollateralAmount = collateralToken.balanceOf(
            address(this)
        );

        if (totalCollateralAmount > 0) {
            uint256 owedCollateralAmount = collateralAmount.mul(totalCollateralAmount).div(wTokenSupply);

            uint256 feeAmount = calculateFee(
                owedCollateralAmount,
                claimFeeBasisPoints
            );
            if (feeAmount > 0) {
                owedCollateralAmount = owedCollateralAmount.sub(feeAmount);

                collateralToken.safeTransfer(owner(), feeAmount);

                emit FeePaid(
                    FeeType.CLAIM_FEE,
                    address(collateralToken),
                    feeAmount
                );
            }

            uint256 currentBalance = collateralToken.balanceOf(address(this));
            if(currentBalance < owedCollateralAmount){
                owedCollateralAmount = currentBalance;
            }

            collateralToken.safeTransfer(redeemer, owedCollateralAmount);
        }

        uint256 totalPaymentAmount = paymentToken.balanceOf(address(this));

        if (totalPaymentAmount > 0) {
            uint256 owedPaymentAmount = collateralAmount.mul(totalPaymentAmount).div(wTokenSupply);

            uint256 feeAmount = calculateFee(
                owedPaymentAmount,
                claimFeeBasisPoints
            );
            if (feeAmount > 0) {
                owedPaymentAmount = owedPaymentAmount.sub(feeAmount);

                paymentToken.safeTransfer(owner(), feeAmount);

                emit FeePaid(
                    FeeType.CLAIM_FEE,
                    address(paymentToken),
                    feeAmount
                );
            }

            uint256 currentBalance = paymentToken.balanceOf(address(this));
            if(currentBalance < owedPaymentAmount){
                owedPaymentAmount = currentBalance;
            }

            paymentToken.safeTransfer(redeemer, owedPaymentAmount);
        }

        emit CollateralClaimed(redeemer, collateralAmount);
    }

    function closePosition(uint256 collateralAmount) public override {

        require(
            state() == MarketState.OPEN,
            "Option contract must be in Open State to close a position"
        );

        address redeemer = _msgSender();

        bToken.burn(redeemer, collateralAmount);
        wToken.burn(redeemer, collateralAmount);

        uint256 feeAmount = calculateFee(collateralAmount, closeFeeBasisPoints);
        if (feeAmount > 0) {
            collateralAmount = collateralAmount.sub(feeAmount);

            collateralToken.safeTransfer(owner(), feeAmount);

            emit FeePaid(
                FeeType.CLOSE_FEE,
                address(collateralToken),
                feeAmount
            );
        }

        collateralToken.safeTransfer(redeemer, collateralAmount);

        emit OptionClosed(redeemer, collateralAmount);
    }

    function recoverTokens(IERC20 token) public override {

        require(
            state() == MarketState.CLOSED,
            "ERC20s can't be recovered until the market is closed"
        );

        uint256 balance = token.balanceOf(address(this));

        token.safeTransfer(owner(), balance);

        emit TokensRecovered(address(token), owner(), balance);
    }

    function selfDestructMarket(address payable refundAddress)
        public
        override
        onlyOwner
    {

        require(refundAddress != address(0x0), "Invalid refundAddress");

        require(
            state() == MarketState.CLOSED,
            "Markets can't be destroyed until it is closed"
        );

        uint256 collateralBalance = collateralToken.balanceOf(address(this));
        if(collateralBalance > 0){
            collateralToken.transfer(owner(), collateralBalance);
        }

        uint256 paymentTokenBalance = paymentToken.balanceOf(address(this));
        if(paymentTokenBalance > 0){
            paymentToken.transfer(owner(), paymentTokenBalance);
        }

        wToken.selfDestructToken(refundAddress);
        bToken.selfDestructToken(refundAddress);

        emit MarketDestroyed();

        selfdestruct(refundAddress);
    }

    function updateImplementation(address newImplementation) public override {

        require(newImplementation != address(0x0), "Invalid newImplementation");

        _updateCodeAddress(newImplementation);
    }

    function updateRestrictedMinter(address _restrictedMinter)
        public
        override
        onlyOwner
    {

        restrictedMinter = _restrictedMinter;

        emit RestrictedMinterUpdated(restrictedMinter);
    }
}