
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

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

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

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

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
        return
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
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
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata =
            address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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


pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IShare {
    function poolBurnFrom(address _address, uint256 _amount) external;

    function poolMint(address _address, uint256 m_amount) external;
}


pragma solidity 0.8.4;

interface IDollar {
    function poolBurnFrom(address _address, uint256 _amount) external;

    function poolMint(address _address, uint256 m_amount) external;
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
}


pragma solidity 0.8.4;

contract Pool is Ownable, ReentrancyGuard, Initializable, IPool {
    using SafeERC20 for ERC20;

    address public oracle;
    address public collateral;
    address public dollar;
    address public treasury;
    address public share;


    mapping(address => uint256) public redeem_share_balances;
    mapping(address => uint256) public redeem_collateral_balances;

    uint256 public override unclaimed_pool_collateral;
    uint256 public unclaimed_pool_share;

    uint256 public netDollarMinted;

    mapping(address => uint256) public last_redeemed;

    uint256 private constant PRICE_PRECISION = 1e6;
    uint256 private constant COLLATERAL_RATIO_PRECISION = 1e6;
    uint256 private constant COLLATERAL_RATIO_MAX = 1e6;

    uint256 private missing_decimals;

    uint256 public redemption_delay = 1;

    bool public mint_paused = false;
    bool public redeem_paused = false;
    uint256 public period; // how many seconds before limit resets
    uint256 public mintLimit; // max amount per period
    uint256 public redeemLimit; // max amount per period
    uint256 public currentPeriodEnd; // timestamp which the current period ends at
    uint256 public currentPeriodMintAmount; // amount already minted this period
    uint256 public currentPeriodRedeemAmount; // amount already redeemed this period


    modifier onlyTreasury() {
        require(msg.sender == treasury, "!treasury");
        _;
    }


    function initialize(
        address _dollar,
        address _share,
        address _collateral,
        address _treasury,
        uint256 _period,
        uint256 _mintLimit,
        uint256 _redeemLimit
    ) external initializer onlyOwner {
        dollar = _dollar;
        share = _share;
        collateral = _collateral;
        treasury = _treasury;
        missing_decimals = 18 - ERC20(_collateral).decimals();
        period = _period;
        mintLimit = _mintLimit;
        redeemLimit = _redeemLimit;
    }


    function info()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        return (
            unclaimed_pool_collateral, // unclaimed amount of COLLATERAL
            unclaimed_pool_share, // unclaimed amount of SHARE
            getCollateralPrice(), // collateral price
            mint_paused,
            redeem_paused
        );
    }

    function collateralReserve() public view returns (address) {
        return ITreasury(treasury).collateralReserve();
    }

    function getCollateralPrice() public view override returns (uint256) {
        return IOracle(oracle).consult();
    }


    function mint(
        uint256 _collateral_amount,
        uint256 _share_amount,
        uint256 _dollar_out_min
    ) external {
        require(mint_paused == false, "Minting is paused");
        (, uint256 _share_price, , uint256 _tcr, , , uint256 _minting_fee, ) =
            ITreasury(treasury).info();
        require(_share_price > 0, "Invalid share price");
        uint256 _price_collateral = getCollateralPrice();
        uint256 _total_dollar_value = 0;
        uint256 _required_share_amount = 0;

        if (_tcr > 0) {
            uint256 _collateral_value =
                ((_collateral_amount * (10**missing_decimals)) * _price_collateral) /
                    PRICE_PRECISION;
            _total_dollar_value = (_collateral_value * COLLATERAL_RATIO_PRECISION) / _tcr;
            if (_tcr < COLLATERAL_RATIO_MAX) {
                _required_share_amount =
                    ((_total_dollar_value - _collateral_value) * PRICE_PRECISION) /
                    _share_price;
            }
        } else {
            _total_dollar_value = (_share_amount * _share_price) / PRICE_PRECISION;
            _required_share_amount = _share_amount;
        }

        uint256 _actual_dollar_amount =
            _total_dollar_value - ((_total_dollar_value * _minting_fee) / PRICE_PRECISION);
        require(_dollar_out_min <= _actual_dollar_amount, "slippage");

        if (_required_share_amount > 0) {
            require(_required_share_amount <= _share_amount, "Not enough SHARE input");
            IShare(share).poolBurnFrom(msg.sender, _required_share_amount); // burns the user's share tokens
        }
        if (_collateral_amount > 0) {
            _transferCollateralToReserve(msg.sender, _collateral_amount);
        }
        IDollar(dollar).poolMint(msg.sender, _actual_dollar_amount);

        netDollarMinted = netDollarMinted + _actual_dollar_amount;

        updatePeriod();

        uint totalAmount = currentPeriodMintAmount + _actual_dollar_amount;
        require(totalAmount >= currentPeriodMintAmount, 'overflow');

        require(currentPeriodMintAmount + _actual_dollar_amount < mintLimit, 'exceeds period limit');
        currentPeriodMintAmount += _actual_dollar_amount;
    }

    function redeem(
        uint256 _dollar_amount,
        uint256 _share_out_min,
        uint256 _collateral_out_min
    ) external {
        require(redeem_paused == false, "Redeeming is paused");

        updatePeriod();

        uint totalAmount = currentPeriodRedeemAmount + _dollar_amount;
        require(totalAmount >= currentPeriodRedeemAmount, 'overflow');

        require(currentPeriodRedeemAmount + _dollar_amount < redeemLimit, 'exceeds period limit');
        currentPeriodRedeemAmount += _dollar_amount;

        (, uint256 _share_price, , , uint256 _ecr, , , uint256 _redemption_fee) =
            ITreasury(treasury).info();
        uint256 _collateral_price = getCollateralPrice();
        require(_collateral_price > 0, "Invalid collateral price");
        require(_share_price > 0, "Invalid share price");
        uint256 _dollar_amount_post_fee =
            _dollar_amount - ((_dollar_amount * _redemption_fee) / PRICE_PRECISION);
        uint256 _collateral_output_amount = 0;
        uint256 _share_output_amount = 0;

        if (_ecr < COLLATERAL_RATIO_MAX) {
            uint256 _share_output_value =
                _dollar_amount_post_fee - ((_dollar_amount_post_fee * _ecr) / PRICE_PRECISION);
            _share_output_amount = (_share_output_value * PRICE_PRECISION) / _share_price;
        }

        if (_ecr > 0) {
            uint256 _collateral_output_value =
                ((_dollar_amount_post_fee * _ecr) / PRICE_PRECISION) / (10**missing_decimals);
            _collateral_output_amount =
                (_collateral_output_value * PRICE_PRECISION) /
                _collateral_price;
        }

        uint256 _totalCollateralBalance = ITreasury(treasury).globalCollateralBalance();
        require(_collateral_output_amount <= _totalCollateralBalance, "<collateralBalance");
        require(
            _collateral_out_min <= _collateral_output_amount &&
                _share_out_min <= _share_output_amount,
            ">slippage"
        );

        if (_collateral_output_amount > 0) {
            redeem_collateral_balances[msg.sender] =
                redeem_collateral_balances[msg.sender] +
                _collateral_output_amount;
            unclaimed_pool_collateral = unclaimed_pool_collateral + _collateral_output_amount;
        }

        if (_share_output_amount > 0) {
            redeem_share_balances[msg.sender] =
                redeem_share_balances[msg.sender] +
                _share_output_amount;
            unclaimed_pool_share = unclaimed_pool_share + _share_output_amount;
        }

        last_redeemed[msg.sender] = block.number;

        IDollar(dollar).poolBurnFrom(msg.sender, _dollar_amount);
        if (_share_output_amount > 0) {
            _mintShareToCollateralReserve(_share_output_amount);
        }

        if (_dollar_amount > netDollarMinted) {
          netDollarMinted = 0;
        } else {
          uint newNetAmount = netDollarMinted - _dollar_amount;
          require(newNetAmount <= netDollarMinted, 'overflow');

          netDollarMinted = netDollarMinted - _dollar_amount;
        }
    }

    function getNetDollarMinted() public view returns (uint256) {
      return netDollarMinted;
    }

    function collectRedemption() external {
        require(
            (last_redeemed[msg.sender] + redemption_delay) <= block.number,
            "<redemption_delay"
        );

        bool _send_share = false;
        bool _send_collateral = false;
        uint256 _share_amount;
        uint256 _collateral_amount;

        if (redeem_share_balances[msg.sender] > 0) {
            _share_amount = redeem_share_balances[msg.sender];
            redeem_share_balances[msg.sender] = 0;
            unclaimed_pool_share = unclaimed_pool_share - _share_amount;
            _send_share = true;
        }

        if (redeem_collateral_balances[msg.sender] > 0) {
            _collateral_amount = redeem_collateral_balances[msg.sender];
            redeem_collateral_balances[msg.sender] = 0;
            unclaimed_pool_collateral = unclaimed_pool_collateral - _collateral_amount;
            _send_collateral = true;
        }

        if (_send_share) {
            _requestTransferShare(msg.sender, _share_amount);
        }

        if (_send_collateral) {
            _requestTransferCollateral(msg.sender, _collateral_amount);
        }
    }

    function updatePeriod() internal {
        if (currentPeriodEnd < block.timestamp) {
            currentPeriodEnd = block.timestamp + period;
            currentPeriodMintAmount = 0;
            currentPeriodRedeemAmount = 0;
        }
    }


    function _transferCollateralToReserve(address _sender, uint256 _amount) internal {
        address _reserve = collateralReserve();
        require(_reserve != address(0), "Invalid reserve address");
        ERC20(collateral).safeTransferFrom(_sender, _reserve, _amount);
    }

    function _mintShareToCollateralReserve(uint256 _amount) internal {
        address _reserve = collateralReserve();
        require(_reserve != address(0), "Invalid reserve address");
        IShare(share).poolMint(_reserve, _amount);
    }

    function _requestTransferCollateral(address _receiver, uint256 _amount) internal {
        ITreasury(treasury).requestTransfer(collateral, _receiver, _amount);
    }

    function _requestTransferShare(address _receiver, uint256 _amount) internal {
        ITreasury(treasury).requestTransfer(share, _receiver, _amount);
    }


    function toggleMinting() external onlyOwner {
        mint_paused = !mint_paused;
    }

    function toggleRedeeming() external onlyOwner {
        redeem_paused = !redeem_paused;
    }

    function setOracle(address _oracle) external onlyOwner {
        require(_oracle != address(0), "Invalid address");
        oracle = _oracle;
    }

    function setRedemptionDelay(uint256 _redemption_delay) external onlyOwner {
        redemption_delay = _redemption_delay;
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Invalid address");
        treasury = _treasury;
        emit TreasuryChanged(_treasury);
    }

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function setMintLimit(uint256 _mintLimit) external onlyOwner {
        mintLimit = _mintLimit;
    }

    function setRedeemLimit(uint256 _redeemLimit) external onlyOwner {
        redeemLimit = _redeemLimit;
    }

    event TreasuryChanged(address indexed newTreasury);
    
}