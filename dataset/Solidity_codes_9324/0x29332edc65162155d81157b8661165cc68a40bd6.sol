

pragma solidity =0.8.4;

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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

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
        unchecked {
            _balances[account] = accountBalance - amount;
        }
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

library SafeERC20 {
    using Address for address;
    
    function validate(IERC20 token) internal view {
        require(address(token).isContract(), "SafeERC20: not a contract");
    }

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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

struct User {
    uint256 totalOriginalTaken;
    uint256 lastUpdateTick;
    uint256 goldenBalance;
    uint256 cooldownAmount;
    uint256 cooldownTick;
}

library UserLib {
    function addCooldownAmount(User storage _user, uint256 _currentTick, uint256 _amount) internal {
        if(_user.cooldownTick == _currentTick) {
            _user.cooldownAmount += _amount;
        } else {
           _user.cooldownTick = _currentTick;
           _user.cooldownAmount = _amount;
        }
    }
}

struct Vesting {
    uint256 totalAmount;
    uint256 startBlock;
    uint256 endBlock;
}

library VestingLib {
    function validate(Vesting storage _vesting) internal view {
        require(_vesting.totalAmount > 0, "zero total vesting amount");
        require(_vesting.startBlock < _vesting.endBlock, "invalid vesting blocks");
    }
    
    function isInitialized(Vesting storage _vesting) internal view returns (bool) {
        return _vesting.endBlock > 0;
    }
    
    function currentTick(Vesting storage _vesting) internal view returns (uint256) {
        if(_vesting.endBlock == 0) return 0; // vesting is not yet initialized
        
        if(block.number < _vesting.startBlock) return 0;
            
        if(block.number > _vesting.endBlock) {
            return _vesting.endBlock - _vesting.startBlock + 1;
        }

        return block.number - _vesting.startBlock + 1;
    }
    
    function lastTick(Vesting storage _vesting) internal view returns (uint256) {
        return _vesting.endBlock - _vesting.startBlock;
    }
    
    function unlockAtATickAmount(Vesting storage _vesting) internal view returns (uint256) {
        return _vesting.totalAmount / (_vesting.endBlock - _vesting.startBlock);
    }
}

struct Price {
    address asset;
    uint256 value;
}

contract DeferredVestingPool is ERC20 {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;
    using UserLib for User;
    using VestingLib for Vesting;

    bool public isSalePaused_;
    address public admin_;
    address public revenueOwner_;
    IERC20Metadata public originalToken_;
    address public originalTokenOwner_;
    uint256 public precisionDecimals_;
    mapping(address => User) public users_;
    mapping(address => uint256) public assets_;
    Vesting public vesting_;
    
    string private constant ERR_AUTH_FAILED = "auth failed";
    
    event WithdrawCoin(address indexed msgSender, bool isMsgSenderAdmin, address indexed to, uint256 amount);
    event WithdrawOriginalToken(address indexed msgSender, bool isMsgSenderAdmin, address indexed to, uint256 amount);
    event SetPrice(address indexed asset, uint256 price);
    event PauseCollateralizedSale(bool on);
    event SetRevenueOwner(address indexed msgSender, address indexed newRevenueOwner);
    event SetOriginalTokenOwner(address indexed msgSender, address indexed newOriginalTokenOwner);
    event SwapToCollateralized(address indexed msgSender, address indexed fromAsset, uint256 fromAmount, uint256 toAmount, uint32 indexed refCode);
    event SwapCollateralizedToOriginal(address indexed msgSender, uint256 amount);
    
    constructor(
        string memory _name,
        string memory _symbol,
        address _admin,
        address _revenueOwner,
        IERC20Metadata _originalToken,
        address _originalTokenOwner,
        uint256 _precisionDecimals,
        Price[] memory _prices) ERC20(_name, _symbol, _originalToken.decimals()) {
            
        _originalToken.validate();
        
        admin_ = _admin;
        revenueOwner_ = _revenueOwner;
        originalToken_ = _originalToken;
        originalTokenOwner_ = _originalTokenOwner;
        precisionDecimals_ = _precisionDecimals;
        
        emit SetRevenueOwner(_msgSender(), _revenueOwner);
        emit SetOriginalTokenOwner(_msgSender(), _originalTokenOwner);
        
         for(uint32 i = 0; i < _prices.length; ++i) {
            assets_[_prices[i].asset] = _prices[i].value;
            emit SetPrice(_prices[i].asset, _prices[i].value);
        }
        
        emit PauseCollateralizedSale(false);
    }
    
    function totalOriginalBalance() external view returns (uint256) {
        return originalToken_.balanceOf(address(this));
    }
    
    function availableForSellCollateralizedAmount() public view returns (uint256) {
        if(isSalePaused_) return 0;
        
        if(vesting_.isInitialized()) return 0;
        
        return originalToken_.balanceOf(address(this)) - totalSupply();
    }
    
    function unusedCollateralAmount() public view returns (uint256) {
        return originalToken_.balanceOf(address(this)) - totalSupply();
    }
    
    modifier onlyAdmin() {
        require(admin_ == _msgSender(), ERR_AUTH_FAILED);
        _;
    }
    
    function initializeVesting(uint256 _startBlock, uint256 _endBlock) external onlyAdmin {
        require(!vesting_.isInitialized(), "already initialized");
        
        vesting_.totalAmount = totalSupply();
        vesting_.startBlock = _startBlock;
        vesting_.endBlock = _endBlock;

        vesting_.validate();
    }
    
    function withdrawCoin(uint256 _amount) external onlyAdmin {
        _withdrawCoin(payable(revenueOwner_), _amount);
    }
    
    function withdrawOriginalToken(uint256 _amount) external onlyAdmin {
        _withdrawOriginalToken(originalTokenOwner_, _amount);
    }
    
    function setPrices(Price[] calldata _prices) external onlyAdmin {
        for(uint32 i = 0; i < _prices.length; ++i) {
            assets_[_prices[i].asset] = _prices[i].value;
            emit SetPrice(_prices[i].asset, _prices[i].value);
        }
    }
    
    function pauseCollateralizedSale(bool _on) external onlyAdmin {
        require(isSalePaused_ != _on);
        isSalePaused_ = _on;
        emit PauseCollateralizedSale(_on);
    }
    
    modifier onlyRevenueOwner() {
        require(revenueOwner_ == _msgSender(), ERR_AUTH_FAILED);
        _;
    }
    
    function setRevenueOwner(address _newRevenueOwner) external onlyRevenueOwner {
        revenueOwner_ = _newRevenueOwner;
        
        emit SetRevenueOwner(_msgSender(), _newRevenueOwner);
    }
    
    function withdrawCoin(address payable _to, uint256 _amount) external onlyRevenueOwner {
        _withdrawCoin(_to, _amount);
    }
    
    modifier onlyOriginalTokenOwner() {
        require(originalTokenOwner_ == _msgSender(), ERR_AUTH_FAILED);
        _;
    }
    
    function setOriginalTokenOwner(address _newOriginalTokenOwner) external onlyOriginalTokenOwner {
        originalTokenOwner_ = _newOriginalTokenOwner;
        
        emit SetOriginalTokenOwner(_msgSender(), _newOriginalTokenOwner);
    }
    
    function withdrawOriginalToken(address _to, uint256 _amount) external onlyOriginalTokenOwner {
        _withdrawOriginalToken(_to, _amount);
    }
    
    function _withdrawCoin(address payable _to, uint256 _amount) private {
        if(_amount == 0) {
            _amount = address(this).balance;
        }
        
        _to.transfer(_amount);
        
        emit WithdrawCoin(_msgSender(), _msgSender() == admin_, _to, _amount);
    }
    
    function _withdrawOriginalToken(address _to, uint256 _amount) private {
        uint256 maxWithdrawAmount = unusedCollateralAmount();
        
        if(_amount == 0) {
            _amount = maxWithdrawAmount;
        }
        
        require(_amount > 0, "zero withdraw amount");
        require(_amount <= maxWithdrawAmount, "invalid withdraw amount");
        
        originalToken_.safeTransfer(_to, _amount);
        
        emit WithdrawOriginalToken(_msgSender(), _msgSender() == admin_, _to, _amount);
    }
    
    function calcCollateralizedPrice(address _fromAsset, uint256 _fromAmount) public view
        returns (uint256 toActualAmount_, uint256 fromActualAmount_) {

        require(_fromAmount > 0, "zero payment");
        
        uint256 fromAssetPrice = assets_[_fromAsset];
        require(fromAssetPrice > 0, "asset not supported");
        
        if(isSalePaused_) return (0, 0);
        
        uint256 toAvailableForSell = availableForSellCollateralizedAmount();
        uint256 oneOriginalToken = 10 ** originalToken_.decimals();
        
        fromActualAmount_ = _fromAmount;
        toActualAmount_ = (_fromAmount * oneOriginalToken) / fromAssetPrice;
        
        if(toActualAmount_ > toAvailableForSell) {
            toActualAmount_ = toAvailableForSell;
            fromActualAmount_ = (toAvailableForSell * fromAssetPrice) / oneOriginalToken;
        }
    }
    
    function swapCoinToCollateralized(uint256 _toExpectedAmount, uint32 _refCode) external payable {
        _swapToCollateralized(address(0), msg.value, _toExpectedAmount, _refCode);
    }
    
    function swapTokenToCollateralized(IERC20 _fromAsset, uint256 _fromAmount, uint256 _toExpectedAmount, uint32 _refCode) external {
        require(address(_fromAsset) != address(0), "wrong swap function");
        
        uint256 fromAmount = _fromAmount == 0 ? _fromAsset.allowance(_msgSender(), address(this)) : _fromAmount;
        _fromAsset.safeTransferFrom(_msgSender(), revenueOwner_, fromAmount);
        
        _swapToCollateralized(address(_fromAsset), fromAmount, _toExpectedAmount, _refCode);
    }
    
    function _swapToCollateralized(address _fromAsset, uint256 _fromAmount, uint256 _toExpectedAmount, uint32 _refCode) private {
        require(!isSalePaused_, "swap paused");
        require(!vesting_.isInitialized(), "can't do this after vesting init");
        require(_toExpectedAmount > 0, "zero expected amount");
        
        (uint256 toActualAmount, uint256 fromActualAmount) = calcCollateralizedPrice(_fromAsset, _fromAmount);
        
        toActualAmount = _fixAmount(toActualAmount, _toExpectedAmount);
            
        require(_fromAmount >= fromActualAmount, "wrong payment amount");
        
        _mint(_msgSender(), toActualAmount);
     
        emit SwapToCollateralized(_msgSender(), _fromAsset, _fromAmount, toActualAmount, _refCode);
    }
    
    function _fixAmount(uint256 _actual, uint256 _expected) private view returns (uint256) {
        if(_expected < _actual) return _expected;
        
        require(_expected - _actual <= 10 ** precisionDecimals_, "expected amount mismatch");
        
        return _actual;
    }
    
    function collateralizedBalance(address _userAddr) external view
        returns (
            uint256 blockNumber,
            uint256 totalOriginalTakenAmount,
            uint256 totalCollateralizedAmount,
            uint256 goldenAmount,
            uint256 grayAmount,
            uint256 cooldownAmount) {

        uint256 currentTick = vesting_.currentTick();

        blockNumber = block.number;
        totalOriginalTakenAmount = users_[_userAddr].totalOriginalTaken;
        totalCollateralizedAmount = balanceOf(_userAddr);
        goldenAmount = users_[_userAddr].goldenBalance + _calcNewGoldenAmount(_userAddr, currentTick);
        grayAmount = totalCollateralizedAmount - goldenAmount;
        cooldownAmount = _getCooldownAmount(users_[_userAddr], currentTick);
    }

    function swapCollateralizedToOriginal(uint256 _amount) external {
        address msgSender = _msgSender();

        _updateUserGoldenBalance(msgSender, vesting_.currentTick());

        User storage user = users_[msgSender];

        if(_amount == 0) _amount = user.goldenBalance;

        require(_amount > 0, "zero swap amount");
        require(_amount <= user.goldenBalance, "invalid amount");

        user.totalOriginalTaken += _amount;
        user.goldenBalance -= _amount;

        _burn(msgSender, _amount);
        originalToken_.safeTransfer(msgSender, _amount);
        
        emit SwapCollateralizedToOriginal(msgSender, _amount);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal virtual override {
        if(_from == address(0) || _to == address(0)) return;

        uint256 currentTick = vesting_.currentTick();

        _updateUserGoldenBalance(_from, currentTick);
        _updateUserGoldenBalance(_to, currentTick);

        User storage userTo = users_[_to];
        User storage userFrom = users_[_from];

        uint256 fromGoldenAmount = userFrom.goldenBalance;
        uint256 fromGrayAmount = balanceOf(_from) - fromGoldenAmount;

        if(fromGrayAmount > 0
            && userFrom.cooldownTick == currentTick
            && userFrom.cooldownAmount > 0) {

            if(_getCooldownAmount(userFrom, currentTick) > _amount) {
                userFrom.cooldownAmount -= _amount;
            } else {
                userFrom.cooldownAmount = 0;
            }
        }

        if(_amount > fromGrayAmount) { // golden amount is also transfered
            uint256 transferGoldenAmount = _amount - fromGrayAmount;
            
            userTo.addCooldownAmount(currentTick, fromGrayAmount);
            
            userFrom.goldenBalance -= transferGoldenAmount;
            userTo.goldenBalance += transferGoldenAmount;
        } else { // only gray amount is transfered
            userTo.addCooldownAmount(currentTick, _amount);
        }
    }

    function _updateUserGoldenBalance(address _userAddr, uint256 _currentTick) private {
        if(_currentTick == 0) return;
        
        User storage user = users_[_userAddr];
        
        if(user.lastUpdateTick == vesting_.lastTick()) return;

        user.goldenBalance += _calcNewGoldenAmount(_userAddr, _currentTick);
        user.lastUpdateTick = _currentTick;
    }

    function _calcNewGoldenAmount(address _userAddr, uint256 _currentTick) private view returns (uint256) {
        if(_currentTick == 0) return 0;
        
        User storage user = users_[_userAddr];

        if(user.goldenBalance == balanceOf(_userAddr)) return 0;

        if(_currentTick >= vesting_.lastTick()) {
            return balanceOf(_userAddr) - user.goldenBalance;
        }

        uint256 result = balanceOf(_userAddr) - _getCooldownAmount(user, _currentTick) + user.totalOriginalTaken;
        result *= _currentTick - user.lastUpdateTick;
        result *= vesting_.unlockAtATickAmount();
        result /= vesting_.totalAmount;
        result = _min(result, balanceOf(_userAddr) - user.goldenBalance);

        return result;
    }

    function _getCooldownAmount(User storage _user, uint256 _currentTick) private view returns (uint256) {
        if(_currentTick >= vesting_.lastTick()) return 0;

        return _currentTick == _user.cooldownTick ? _user.cooldownAmount : 0;
    }

    function _min(uint256 a, uint256 b) private pure returns (uint256) {
        return a <= b ? a : b;
    }
}