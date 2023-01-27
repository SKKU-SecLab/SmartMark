
pragma solidity 0.5.12;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    function initReentrancyStatus() internal {

        _status = _NOT_ENTERED;
    }
}

contract DSAuthority {

    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) public view returns (bool);

}

contract DSAuthEvents {

    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
    event OwnerUpdate(address indexed owner, address indexed newOwner);
}

contract DSAuth is DSAuthEvents {

    DSAuthority public authority;
    address public owner;
    address public newOwner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function disableOwnership() public onlyOwner {

        owner = address(0);
        emit OwnerUpdate(msg.sender, owner);
    }

    function transferOwnership(address newOwner_) public onlyOwner {

        require(newOwner_ != owner, "TransferOwnership: the same owner.");
        newOwner = newOwner_;
    }

    function acceptOwnership() public {

        require(
            msg.sender == newOwner,
            "AcceptOwnership: only new owner do this."
        );
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0x0);
    }

    function setAuthority(DSAuthority authority_) public onlyOwner {

        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier onlyOwner {

        require(isOwner(msg.sender), "ds-auth-non-owner");
        _;
    }

    function isOwner(address src) internal view returns (bool) {

        return bool(src == owner);
    }

    modifier auth {

        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig)
        internal
        view
        returns (bool)
    {

        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

contract Pausable is DSAuth {

    bool public paused;

    event Paused(address account);

    event Unpaused(address account);

    modifier whenNotPaused() {

        require(!paused, "whenNotPaused: paused");
        _;
    }

    modifier whenPaused() {

        require(paused, "whenPaused: not paused");
        _;
    }

    constructor() internal {
        paused = false;
    }

    function pause() public whenNotPaused auth {

        paused = true;
        emit Paused(owner);
    }

    function unpause() public whenPaused auth {

        paused = false;
        emit Unpaused(owner);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external;


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external;


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function decimals() external view returns (uint8);

}

contract ERC20SafeTransfer {

    function doTransferOut(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (bool) {

        IERC20 token = IERC20(_token);
        bool result;

        token.transfer(_to, _amount);

        assembly {
            switch returndatasize()
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        return result;
    }

    function doTransferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {

        IERC20 token = IERC20(_token);
        bool result;

        token.transferFrom(_from, _to, _amount);

        assembly {
            switch returndatasize()
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        return result;
    }

    function doApprove(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (bool) {

        IERC20 token = IERC20(_token);
        bool result;

        token.approve(_to, _amount);

        assembly {
            switch returndatasize()
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        return result;
    }
}

library SafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y > 0, "ds-math-div-overflow");
        z = x / y;
    }
}

interface IDispatcher {

    function getHandlers()
        external
        view
        returns (address[] memory, uint256[] memory);


    function getDepositStrategy(uint256 _amount)
        external
        view
        returns (address[] memory, uint256[] memory);


    function getWithdrawStrategy(address _token, uint256 _amount)
        external
        returns (address[] memory, uint256[] memory);


    function isHandlerActive(address _handler) external view returns (bool);


    function defaultHandler() external view returns (address);

}

interface IHandler {

    function deposit(address _token, uint256 _amount)
        external
        returns (uint256);


    function withdraw(address _token, uint256 _amount)
        external
        returns (uint256);


    function getRealBalance(address _token) external returns (uint256);


    function getRealLiquidity(address _token) external returns (uint256);


    function getBalance(address _token) external view returns (uint256);


    function getLiquidity(address _token) external view returns (uint256);


    function paused() external view returns (bool);


    function tokenIsEnabled(address _underlyingToken)
        external
        view
        returns (bool);

}

contract DToken is ReentrancyGuard, Pausable, ERC20SafeTransfer {

    using SafeMath for uint256;
    bool private initialized; // Flag of initialize data

    struct DTokenData {
        uint256 exchangeRate;
        uint256 totalInterest;
    }

    DTokenData public data;

    address public feeRecipient;
    mapping(bytes4 => uint256) public originationFee; // Trade fee

    address public dispatcher;
    address public token;
    address public swapModel;

    uint256 constant BASE = 10**18;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    struct Balance {
        uint256 value;
        uint256 exchangeRate;
        uint256 interest;
    }
    mapping(address => Balance) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);

    event Interest(
        address indexed src,
        uint256 interest,
        uint256 increase,
        uint256 totalInterest
    );

    event Mint(
        address indexed account,
        uint256 indexed pie,
        uint256 wad,
        uint256 totalSupply,
        uint256 exchangeRate
    );

    event Redeem(
        address indexed account,
        uint256 indexed pie,
        uint256 wad,
        uint256 totalSupply,
        uint256 exchangeRate
    );

    event Rebalance(
        address[] withdraw,
        uint256[] withdrawAmount,
        address[] supply,
        uint256[] supplyAmount
    );

    event TransferFee(address token, address feeRecipient, uint256 amount);

    event FeeRecipientSet(address oldFeeRecipient, address newFeeRecipient);

    event NewDispatcher(address oldDispatcher, address Dispatcher);
    event NewSwapModel(address _oldSwapModel, address _newSwapModel);

    event NewOriginationFee(
        bytes4 sig,
        uint256 oldOriginationFeeMantissa,
        uint256 newOriginationFeeMantissa
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address _token,
        address _dispatcher
    ) public {
        initialize(_name, _symbol, _token, _dispatcher);
    }


    function initialize(
        string memory _name,
        string memory _symbol,
        address _token,
        address _dispatcher
    ) public {

        require(!initialized, "initialize: Already initialized!");
        owner = msg.sender;
        initReentrancyStatus();
        feeRecipient = address(this);
        name = _name;
        symbol = _symbol;
        token = _token;
        dispatcher = _dispatcher;
        decimals = IERC20(_token).decimals();
        data.exchangeRate = BASE;
        initialized = true;

        emit NewDispatcher(address(0), _dispatcher);
    }

    function updateDispatcher(address _newDispatcher) external auth {

        address _oldDispatcher = dispatcher;
        require(
            _newDispatcher != address(0) && _newDispatcher != _oldDispatcher,
            "updateDispatcher: dispatcher can be not set to 0 or the current one."
        );

        dispatcher = _newDispatcher;
        emit NewDispatcher(_oldDispatcher, _newDispatcher);
    }

    function setSwapModel(address _newSwapModel) external auth {

        address _oldSwapModel = swapModel;
        require(
            _newSwapModel != address(0) && _newSwapModel != _oldSwapModel,
            "setSwapModel: swap model can be not set to 0 or the current one."
        );
        swapModel = _newSwapModel;
        emit NewSwapModel(_oldSwapModel, _newSwapModel);
    }

    function setFeeRecipient(address _newFeeRecipient) external auth {

        address _oldFeeRecipient = feeRecipient;
        require(
            _newFeeRecipient != address(0) &&
                _newFeeRecipient != _oldFeeRecipient,
            "setFeeRecipient: feeRecipient can be not set to 0 or the current one."
        );

        feeRecipient = _newFeeRecipient;
        emit FeeRecipientSet(_oldFeeRecipient, feeRecipient);
    }

    function updateOriginationFee(bytes4 _sig, uint256 _newOriginationFee)
        external
        auth
    {

        require(
            _newOriginationFee < BASE,
            "updateOriginationFee: incorrect fee."
        );
        uint256 _oldOriginationFee = originationFee[_sig];
        require(
            _oldOriginationFee != _newOriginationFee,
            "updateOriginationFee: fee has already set to this value."
        );

        originationFee[_sig] = _newOriginationFee;
        emit NewOriginationFee(_sig, _oldOriginationFee, _newOriginationFee);
    }

    function swap(address _token, uint256 _amount) external auth {

        require(swapModel != address(0), "swap: no swap model available!");

        (bool success, ) = swapModel.delegatecall(
            abi.encodeWithSignature("swap(address,uint256)", _token, _amount)
        );

        require(success, "swap: swap to another token failed!");
    }

    function transferFee(address _token, uint256 _amount) external auth {

        require(
            feeRecipient != address(this),
            "transferFee: Can not transfer fee back to this contract."
        );

        require(
            doTransferOut(_token, feeRecipient, _amount),
            "transferFee: Token transfer out of contract failed."
        );

        emit TransferFee(_token, feeRecipient, _amount);
    }

    function rebalance(
        address[] calldata _withdraw,
        uint256[] calldata _withdrawAmount,
        address[] calldata _deposit,
        uint256[] calldata _depositAmount
    ) external auth {

        require(
            _withdraw.length == _withdrawAmount.length &&
                _deposit.length == _depositAmount.length,
            "rebalance: the length of addresses and amounts must match."
        );

        address _token = token;
        address _defaultHandler = IDispatcher(dispatcher).defaultHandler();

        uint256[] memory _realWithdrawAmount = new uint256[](
            _withdrawAmount.length
        );
        uint256[] memory _realDepositAmount = new uint256[](
            _depositAmount.length
        );
        for (uint256 i = 0; i < _withdraw.length; i++) {
            if (_withdrawAmount[i] == 0 || _defaultHandler == _withdraw[i])
                continue;

            _realWithdrawAmount[i] = _withdrawAmount[i] == uint256(-1)
                ? IHandler(_withdraw[i]).getRealBalance(_token)
                : _withdrawAmount[i];

            require(
                IHandler(_withdraw[i]).withdraw(_token, _withdrawAmount[i]) ==
                    _realWithdrawAmount[i],
                "rebalance: actual withdrown amount does not match the wanted"
            );

            require(
                doTransferFrom(
                    _token,
                    _withdraw[i],
                    _defaultHandler,
                    _realWithdrawAmount[i]
                ),
                "rebalance: transfer to default handler failed"
            );
        }

        for (uint256 i = 0; i < _deposit.length; i++) {
            require(
                IDispatcher(dispatcher).isHandlerActive(_deposit[i]) &&
                    IHandler(_deposit[i]).tokenIsEnabled(_token),
                "rebalance: both handler and token must be enabled"
            );

            if (_depositAmount[i] == 0 || _defaultHandler == _deposit[i])
                continue;

            require(
                doTransferFrom(
                    _token,
                    _defaultHandler,
                    _deposit[i],
                    _depositAmount[i]
                ),
                "rebalance: transfer to target handler failed"
            );

            _realDepositAmount[i] = IHandler(_deposit[i]).deposit(
                _token,
                _depositAmount[i]
            );

            require(
                _realDepositAmount[i] > 0 &&
                    _realDepositAmount[i] <= _depositAmount[i],
                "rebalance: deposit to the target protocal failed"
            );
        }

        emit Rebalance(
            _withdraw,
            _withdrawAmount,
            _deposit,
            _realDepositAmount
        );
    }


    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.mul(y) / BASE;
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.mul(BASE).div(y);
    }

    function rdivup(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.mul(BASE).add(y.sub(1)).div(y);
    }

    function getCurrentExchangeRate() internal returns (uint256) {

        address[] memory _handlers = getHandlers();
        return getCurrentExchangeRateByHandler(_handlers, token);
    }

    function getCurrentExchangeRateByHandler(
        address[] memory _handlers,
        address _token
    ) internal returns (uint256) {

        uint256 _totalToken = 0;

        for (uint256 i = 0; i < _handlers.length; i++)
            _totalToken = _totalToken.add(
                IHandler(_handlers[i]).getRealBalance(_token)
            );

        uint256 _exchangeRate = (totalSupply == 0)
            ? BASE
            : rdiv(_totalToken, totalSupply);

        require(_exchangeRate > 0, "Exchange rate should not be 0!");

        return _exchangeRate;
    }

    function updateInterest(address _account, uint256 _exchangeRate) internal {

        Balance storage _balance = balances[_account];

        if (
            _balance.exchangeRate > 0 && _exchangeRate > _balance.exchangeRate
        ) {
            uint256 _interestIncrease = rmul(
                _exchangeRate.sub(_balance.exchangeRate),
                _balance.value
            );

            _balance.interest = _balance.interest.add(_interestIncrease);

            data.totalInterest = data.totalInterest.add(_interestIncrease);

            emit Interest(
                _account,
                _balance.interest,
                _interestIncrease,
                data.totalInterest
            );
        }

        _balance.exchangeRate = _exchangeRate;
        data.exchangeRate = _exchangeRate;
    }

    function withdrawFromHandlers(
        address _defaultHandler,
        address[] memory _handlers,
        uint256[] memory _amounts
    ) internal returns (uint256 _totalWithdrown) {

        address _token = token;

        uint256 _withdrown;
        for (uint256 i = 0; i < _handlers.length; i++) {
            if (_amounts[i] == 0) continue;

            _withdrown = IHandler(_handlers[i]).withdraw(_token, _amounts[i]);
            require(
                _withdrown > 0,
                "withdrawFromHandlers: handler withdraw failed"
            );

            if (_defaultHandler != _handlers[i]) {
                require(
                    doTransferFrom(
                        _token,
                        _handlers[i],
                        _defaultHandler,
                        _withdrown
                    ),
                    "withdrawFromHandlers: transfer to default handler failed"
                );
            }

            _totalWithdrown = _totalWithdrown.add(_withdrown);
        }
    }


    struct MintLocalVars {
        address token;
        address[] handlers;
        uint256[] amounts;
        uint256 exchangeRate;
        uint256 originationFee;
        uint256 fee;
        uint256 netDepositAmount;
        uint256 mintAmount;
        uint256 wad;
    }

    function mint(address _dst, uint256 _pie)
        external
        nonReentrant
        whenNotPaused
    {

        MintLocalVars memory _mintLocal;
        _mintLocal.token = token;

        _mintLocal.originationFee = originationFee[msg.sig];
        _mintLocal.fee = rmul(_pie, _mintLocal.originationFee);
        if (_mintLocal.fee > 0)
            require(
                doTransferFrom(
                    _mintLocal.token,
                    msg.sender,
                    feeRecipient,
                    _mintLocal.fee
                ),
                "mint: transferFrom fee failed"
            );

        _mintLocal.netDepositAmount = _pie.sub(_mintLocal.fee);

        (_mintLocal.handlers, _mintLocal.amounts) = IDispatcher(dispatcher)
            .getDepositStrategy(_mintLocal.netDepositAmount);
        require(
            _mintLocal.handlers.length > 0,
            "mint: no deposit strategy available, possibly due to a paused handler"
        );

        _mintLocal.exchangeRate = getCurrentExchangeRateByHandler(
            _mintLocal.handlers,
            _mintLocal.token
        );

        for (uint256 i = 0; i < _mintLocal.handlers.length; i++) {
            if (_mintLocal.amounts[i] == 0) continue;

            require(
                doTransferFrom(
                    _mintLocal.token,
                    msg.sender,
                    _mintLocal.handlers[i],
                    _mintLocal.amounts[i]
                ),
                "mint: transfer token to handler failed."
            );

            _mintLocal.mintAmount = _mintLocal.mintAmount.add(
                IHandler(_mintLocal.handlers[i]).deposit(
                    _mintLocal.token,
                    _mintLocal.amounts[i]
                )
            );
        }

        require(
            _mintLocal.mintAmount <= _mintLocal.netDepositAmount,
            "mint: deposited more than intended"
        );

        _mintLocal.wad = rdiv(_mintLocal.mintAmount, _mintLocal.exchangeRate);
        require(
            _mintLocal.wad > 0,
            "mint: can not mint the smallest unit with the given amount"
        );

        updateInterest(_dst, _mintLocal.exchangeRate);

        Balance storage _balance = balances[_dst];
        _balance.value = _balance.value.add(_mintLocal.wad);
        totalSupply = totalSupply.add(_mintLocal.wad);

        emit Transfer(address(0), _dst, _mintLocal.wad);
        emit Mint(
            _dst,
            _pie,
            _mintLocal.wad,
            totalSupply,
            _mintLocal.exchangeRate
        );
    }

    struct RedeemLocalVars {
        address token;
        address defaultHandler;
        address[] handlers;
        uint256[] amounts;
        uint256 exchangeRate;
        uint256 originationFee;
        uint256 fee;
        uint256 grossAmount;
        uint256 redeemTotalAmount;
        uint256 userAmount;
    }

    function redeem(address _src, uint256 _wad)
        external
        nonReentrant
        whenNotPaused
    {

        Balance storage _balance = balances[_src];
        require(_balance.value >= _wad, "redeem: insufficient balance");
        if (_src != msg.sender && allowance[_src][msg.sender] != uint256(-1)) {
            require(
                allowance[_src][msg.sender] >= _wad,
                "redeem: insufficient allowance"
            );
            allowance[_src][msg.sender] = allowance[_src][msg.sender].sub(_wad);
        }

        RedeemLocalVars memory _redeemLocal;
        _redeemLocal.token = token;

        _redeemLocal.exchangeRate = getCurrentExchangeRate();
        _redeemLocal.grossAmount = rmul(_wad, _redeemLocal.exchangeRate);

        _redeemLocal.defaultHandler = IDispatcher(dispatcher).defaultHandler();
        require(
            _redeemLocal.defaultHandler != address(0) &&
                IDispatcher(dispatcher).isHandlerActive(
                    _redeemLocal.defaultHandler
                ),
            "redeem: default handler is inactive"
        );

        (_redeemLocal.handlers, _redeemLocal.amounts) = IDispatcher(dispatcher)
            .getWithdrawStrategy(_redeemLocal.token, _redeemLocal.grossAmount);
        require(
            _redeemLocal.handlers.length > 0,
            "redeem: no withdraw strategy available, possibly due to a paused handler"
        );

        _redeemLocal.redeemTotalAmount = withdrawFromHandlers(
            _redeemLocal.defaultHandler,
            _redeemLocal.handlers,
            _redeemLocal.amounts
        );

        require(
            _redeemLocal.redeemTotalAmount <= _redeemLocal.grossAmount,
            "redeem: redeemed more than intended"
        );

        updateInterest(_src, _redeemLocal.exchangeRate);

        _balance.value = _balance.value.sub(_wad);
        totalSupply = totalSupply.sub(_wad);

        _redeemLocal.originationFee = originationFee[msg.sig];
        _redeemLocal.fee = rmul(
            _redeemLocal.redeemTotalAmount,
            _redeemLocal.originationFee
        );

        if (_redeemLocal.fee > 0)
            require(
                doTransferFrom(
                    _redeemLocal.token,
                    _redeemLocal.defaultHandler,
                    feeRecipient,
                    _redeemLocal.fee
                ),
                "redeem: transfer fee from default handler failed"
            );

        _redeemLocal.userAmount = _redeemLocal.redeemTotalAmount.sub(
            _redeemLocal.fee
        );

        if (_redeemLocal.userAmount > 0)
            require(
                doTransferFrom(
                    _redeemLocal.token,
                    _redeemLocal.defaultHandler,
                    msg.sender,
                    _redeemLocal.userAmount
                ),
                "redeem: transfer from default handler to user failed"
            );

        emit Transfer(_src, address(0), _wad);
        emit Redeem(
            _src,
            _redeemLocal.redeemTotalAmount,
            _wad,
            totalSupply,
            _redeemLocal.exchangeRate
        );
    }

    struct RedeemUnderlyingLocalVars {
        address token;
        address defaultHandler;
        address[] handlers;
        uint256[] amounts;
        uint256 exchangeRate;
        uint256 originationFee;
        uint256 fee;
        uint256 consumeAmountWithFee;
        uint256 redeemTotalAmount;
        uint256 wad;
    }

    function redeemUnderlying(address _src, uint256 _pie)
        external
        nonReentrant
        whenNotPaused
    {

        RedeemUnderlyingLocalVars memory _redeemLocal;
        _redeemLocal.token = token;

        _redeemLocal.originationFee = originationFee[DToken(this)
            .redeem
            .selector];

        _redeemLocal.consumeAmountWithFee = rdivup(
            _pie,
            BASE.sub(_redeemLocal.originationFee)
        );

        _redeemLocal.defaultHandler = IDispatcher(dispatcher).defaultHandler();
        require(
            _redeemLocal.defaultHandler != address(0) &&
                IDispatcher(dispatcher).isHandlerActive(
                    _redeemLocal.defaultHandler
                ),
            "redeemUnderlying: default handler is inactive"
        );

        (_redeemLocal.handlers, _redeemLocal.amounts) = IDispatcher(dispatcher)
            .getWithdrawStrategy(
            _redeemLocal.token,
            _redeemLocal.consumeAmountWithFee
        );
        require(
            _redeemLocal.handlers.length > 0,
            "redeemUnderlying: no withdraw strategy available, possibly due to a paused handler"
        );

        _redeemLocal.exchangeRate = getCurrentExchangeRateByHandler(
            _redeemLocal.handlers,
            _redeemLocal.token
        );

        _redeemLocal.redeemTotalAmount = withdrawFromHandlers(
            _redeemLocal.defaultHandler,
            _redeemLocal.handlers,
            _redeemLocal.amounts
        );

        require(
            _redeemLocal.redeemTotalAmount == _redeemLocal.consumeAmountWithFee,
            "redeemUnderlying: withdrown more than intended"
        );

        _redeemLocal.wad = rdivup(
            _redeemLocal.redeemTotalAmount,
            _redeemLocal.exchangeRate
        );

        updateInterest(_src, _redeemLocal.exchangeRate);

        Balance storage _balance = balances[_src];
        require(
            _balance.value >= _redeemLocal.wad,
            "redeemUnderlying: insufficient balance"
        );
        if (_src != msg.sender && allowance[_src][msg.sender] != uint256(-1)) {
            require(
                allowance[_src][msg.sender] >= _redeemLocal.wad,
                "redeemUnderlying: insufficient allowance"
            );
            allowance[_src][msg.sender] = allowance[_src][msg.sender].sub(
                _redeemLocal.wad
            );
        }

        _balance.value = _balance.value.sub(_redeemLocal.wad);
        totalSupply = totalSupply.sub(_redeemLocal.wad);

        _redeemLocal.fee = _redeemLocal.redeemTotalAmount.sub(_pie);

        if (_redeemLocal.fee > 0)
            require(
                doTransferFrom(
                    _redeemLocal.token,
                    _redeemLocal.defaultHandler,
                    feeRecipient,
                    _redeemLocal.fee
                ),
                "redeemUnderlying: transfer fee from default handler failed"
            );

        require(
            doTransferFrom(
                _redeemLocal.token,
                _redeemLocal.defaultHandler,
                msg.sender,
                _pie
            ),
            "redeemUnderlying: transfer to user failed"
        );

        emit Transfer(_src, address(0), _redeemLocal.wad);
        emit Redeem(
            _src,
            _redeemLocal.redeemTotalAmount,
            _redeemLocal.wad,
            totalSupply,
            _redeemLocal.exchangeRate
        );
    }

    function transfer(address _dst, uint256 _wad) external returns (bool) {

        return transferFrom(msg.sender, _dst, _wad);
    }

    function transferFrom(
        address _src,
        address _dst,
        uint256 _wad
    ) public nonReentrant whenNotPaused returns (bool) {

        Balance storage _srcBalance = balances[_src];

        require(
            _srcBalance.value >= _wad,
            "transferFrom: insufficient balance"
        );
        if (_src != msg.sender && allowance[_src][msg.sender] != uint256(-1)) {
            require(
                allowance[_src][msg.sender] >= _wad,
                "transferFrom: insufficient allowance"
            );
            allowance[_src][msg.sender] = allowance[_src][msg.sender].sub(_wad);
        }

        uint256 _exchangeRate = getCurrentExchangeRate();
        updateInterest(_src, _exchangeRate);
        updateInterest(_dst, _exchangeRate);

        Balance storage _dstBalance = balances[_dst];
        _srcBalance.value = _srcBalance.value.sub(_wad);
        _dstBalance.value = _dstBalance.value.add(_wad);

        emit Transfer(_src, _dst, _wad);
        return true;
    }

    function approve(address _spender, uint256 _wad)
        public
        whenNotPaused
        returns (bool)
    {

        allowance[msg.sender][_spender] = _wad;
        emit Approval(msg.sender, _spender, _wad);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {

        return approve(spender, allowance[msg.sender][spender].add(addedValue));
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {

        return
            approve(
                spender,
                allowance[msg.sender][spender].sub(subtractedValue)
            );
    }

    function balanceOf(address account) external view returns (uint256) {

        return balances[account].value;
    }

    function getTokenBalance(address _account) external view returns (uint256) {

        return rmul(balances[_account].value, getExchangeRate());
    }

    function getCurrentInterest(address _account)
        external
        view
        returns (uint256)
    {

        return
            balances[_account].interest.add(
                rmul(
                    getExchangeRate().sub(balances[_account].exchangeRate),
                    balances[_account].value
                )
            );
    }

    function getHandlers() public view returns (address[] memory) {

        (address[] memory _handlers, ) = IDispatcher(dispatcher).getHandlers();
        return _handlers;
    }

    function getTotalBalance() external view returns (uint256) {

        address[] memory _handlers = getHandlers();
        uint256 _tokenTotalBalance = 0;
        for (uint256 i = 0; i < _handlers.length; i++)
            _tokenTotalBalance = _tokenTotalBalance.add(
                IHandler(_handlers[i]).getBalance(token)
            );
        return _tokenTotalBalance;
    }

    function getLiquidity() external view returns (uint256) {

        address[] memory _handlers = getHandlers();
        uint256 _liquidity = 0;
        for (uint256 i = 0; i < _handlers.length; i++)
            _liquidity = _liquidity.add(
                IHandler(_handlers[i]).getLiquidity(token)
            );
        return _liquidity;
    }

    function getExchangeRate() public view returns (uint256) {

        address[] memory _handlers = getHandlers();
        address _token = token;
        uint256 _totalToken = 0;
        for (uint256 i = 0; i < _handlers.length; i++)
            _totalToken = _totalToken.add(
                IHandler(_handlers[i]).getBalance(_token)
            );

        return totalSupply == 0 ? BASE : rdiv(_totalToken, totalSupply);
    }

    function currentExchangeRate() external returns (uint256) {

        return getCurrentExchangeRate();
    }

    function totalUnderlying() external returns (uint256) {

        address[] memory _handlers = getHandlers();
        uint256 _tokenTotalBalance = 0;
        for (uint256 i = 0; i < _handlers.length; i++)
            _tokenTotalBalance = _tokenTotalBalance.add(
                IHandler(_handlers[i]).getRealBalance(token)
            );
        return _tokenTotalBalance;
    }

    function getRealLiquidity() external returns (uint256) {

        address[] memory _handlers = getHandlers();
        uint256 _liquidity = 0;
        for (uint256 i = 0; i < _handlers.length; i++)
            _liquidity = _liquidity.add(
                IHandler(_handlers[i]).getRealLiquidity(token)
            );
        return _liquidity;
    }

    function balanceOfUnderlying(address _account) external returns (uint256) {

        uint256 _underlying = rmul(
            balances[_account].value,
            getCurrentExchangeRate()
        );
        return
            _underlying.sub(
                rmul(_underlying, originationFee[this.redeem.selector])
            );
    }

    function getBaseData()
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        address[] memory _handlers = getHandlers();
        uint256 _tokenTotalBalance = 0;
        for (uint256 i = 0; i < _handlers.length; i++)
            _tokenTotalBalance = _tokenTotalBalance.add(
                IHandler(_handlers[i]).getRealBalance(token)
            );
        return (
            decimals,
            getCurrentExchangeRate(),
            originationFee[DToken(this).mint.selector],
            originationFee[DToken(this).redeem.selector],
            _tokenTotalBalance
        );
    }

    function getHandlerInfo()
        external
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {

        address[] memory _handlers = getHandlers();
        uint256[] memory _balances = new uint256[](_handlers.length);
        uint256[] memory _liquidities = new uint256[](_handlers.length);
        for (uint256 i = 0; i < _handlers.length; i++) {
            _balances[i] = IHandler(_handlers[i]).getRealBalance(token);
            _liquidities[i] = IHandler(_handlers[i]).getRealLiquidity(token);
        }
        return (_handlers, _balances, _liquidities);
    }
}