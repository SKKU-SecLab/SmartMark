pragma solidity 0.8.0;

interface IPlus {

    function governance() external view returns (address);


    function strategists(address _account) external view returns (bool);


    function treasury() external view returns (address);


    function rebase() external;


    function totalUnderlying() external view returns (uint256);


    function donate(uint256 _amount) external;

}// MIT
pragma solidity 0.8.0;


interface ICompositePlus is IPlus {

    function tokens(uint256 _index) external view returns (address);


    function tokenList() external view returns (address[] memory);


    function tokenSupported(address _token) external view returns (bool);


    function getMintAmount(address[] calldata _tokens, uint256[] calldata _amounts) external view returns(uint256);


    function mint(address[] calldata _tokens, uint256[] calldata _amounts) external;


    function getRedeemAmount(uint256 _amount) external view returns (address[] memory, uint256[] memory, uint256);


    function redeem(uint256 _amount) external;


    function getRedeemSingleAmount(address _token, uint256 _amount) external view returns (uint256, uint256);


    function redeemSingle(address _token, uint256 _amount) external;

}// MIT
pragma solidity 0.8.0;


interface ISinglePlus is IPlus {

    function token() external view returns (address);


    function divest() external;


    function investable() external view returns (uint256);


    function invest() external;


    function harvestable() external view returns (uint256);


    function harvest() external;


    function getMintAmount(uint256 _amount) external view returns(uint256);


    function mint(uint256 _amount) external;


    function getRedeemAmount(uint256 _amount) external view returns (uint256, uint256);


    function redeem(uint256 _amount) external;

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

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

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

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

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

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.8.0;



contract CurveBTCZap is Initializable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    event Minted(address indexed account, address[] tokens, uint256[] amounts, uint256 mintAmount);
    event Redeemed(address indexed account, address[] tokens, uint256[] amounts, uint256 redeemAmount);

    address public constant BADGER_RENCRV = address(0x6dEf55d2e18486B9dDfaA075bc4e4EE0B28c1545);
    address public constant BADGER_RENCRV_PLUS = address(0x87BAA3E048528d21302Fb15acd09a4e5cB5098cB);
    address public constant BADGER_SBTCCRV = address(0xd04c48A53c111300aD41190D63681ed3dAd998eC);
    address public constant BADGER_SBTCCRV_PLUS = address(0xb346d6Fcea1F328b64cF5F1Fe5108841607A7Fef);
    address public constant BADGER_TBTCCRV = address(0xb9D076fDe463dbc9f915E5392F807315Bf940334);
    address public constant BADGER_TBTCCRV_PLUS = address(0x25d8293E1d6209d6fa21983f5E46ee6CD36d7196);
    address public constant BADGER_HRENCRV = address(0xAf5A1DECfa95BAF63E0084a35c62592B774A2A87);
    address public constant BADGER_HRENCRV_PLUS = address(0xd929f4d3ACBD19107BC416685e7f6559dC07F3F5);
    address public constant CURVE_BTC_PLUS = address(0xDe79d36aB6D2489dd36729A657a25f299Cb2Fbca);

    address public governance;
    
    function initialize() public initializer {

        governance = msg.sender;

        IERC20Upgradeable(BADGER_RENCRV).safeApprove(BADGER_RENCRV_PLUS, uint256(int256(-1)));
        IERC20Upgradeable(BADGER_SBTCCRV).safeApprove(BADGER_SBTCCRV_PLUS, uint256(int256(-1)));
        IERC20Upgradeable(BADGER_TBTCCRV).safeApprove(BADGER_TBTCCRV_PLUS, uint256(int256(-1)));
        IERC20Upgradeable(BADGER_HRENCRV).safeApprove(BADGER_HRENCRV_PLUS, uint256(int256(-1)));

        IERC20Upgradeable(BADGER_RENCRV_PLUS).safeApprove(CURVE_BTC_PLUS, uint256(int256(-1)));
        IERC20Upgradeable(BADGER_SBTCCRV_PLUS).safeApprove(CURVE_BTC_PLUS, uint256(int256(-1)));
        IERC20Upgradeable(BADGER_TBTCCRV_PLUS).safeApprove(CURVE_BTC_PLUS, uint256(int256(-1)));
        IERC20Upgradeable(BADGER_HRENCRV_PLUS).safeApprove(CURVE_BTC_PLUS, uint256(int256(-1)));
    }

    function getMintAmount(address[] memory _singles, uint256[] memory _lpAmounts) public view returns (uint256) {

        require(_singles.length == _lpAmounts.length, "input mismatch");
        
        uint256[] memory _amounts = new uint256[](_singles.length);
        for (uint256 i = 0; i < _singles.length; i++) {
            if (_lpAmounts[i] == 0) continue;
            _amounts[i] = ISinglePlus(_singles[i]).getMintAmount(_lpAmounts[i]);
        }

        return ICompositePlus(CURVE_BTC_PLUS).getMintAmount(_singles, _amounts);
    }

    function mint(address[] memory _singles, uint256[] memory _lpAmounts) public {

        require(_singles.length == _lpAmounts.length, "input mismatch");
        
        address[] memory _lps = new address[](_singles.length);
        uint256[] memory _amounts = new uint256[](_singles.length);
        for (uint256 i = 0; i < _singles.length; i++) {
            if (_lpAmounts[i] == 0) continue;

            _lps[i] = ISinglePlus(_singles[i]).token();
            IERC20Upgradeable(_lps[i]).safeTransferFrom(msg.sender, address(this), _lpAmounts[i]);
            ISinglePlus(_singles[i]).mint(_lpAmounts[i]);

            _amounts[i] = IERC20Upgradeable(_singles[i]).balanceOf(address(this));
        }

        ICompositePlus(CURVE_BTC_PLUS).mint(_singles, _amounts);
        uint256 _badgerBTCPlus = IERC20Upgradeable(CURVE_BTC_PLUS).balanceOf(address(this));
        IERC20Upgradeable(CURVE_BTC_PLUS).safeTransfer(msg.sender, _badgerBTCPlus);

        emit Minted(msg.sender, _lps, _lpAmounts, _badgerBTCPlus);
    }

    function getRedeemAmount(uint256 _amount) public view returns (address[] memory, uint256[] memory) {

        (address[] memory _singles, uint256[] memory _amounts,) = ICompositePlus(CURVE_BTC_PLUS).getRedeemAmount(_amount);

        address[] memory _lps = new address[](_singles.length);
        uint256[] memory _lpAmounts = new uint256[](_singles.length);

        for (uint256 i = 0; i < _singles.length; i++) {
            _lps[i] = ISinglePlus(_singles[i]).token();
            (_lpAmounts[i],) = ISinglePlus(_singles[i]).getRedeemAmount(_amounts[i]);
        }

        return (_lps, _lpAmounts);
    }

    function redeem(uint256 _amount) public {

        IERC20Upgradeable(CURVE_BTC_PLUS).safeTransferFrom(msg.sender, address(this), _amount);
        ICompositePlus(CURVE_BTC_PLUS).redeem(_amount);

        address[] memory _singles = ICompositePlus(CURVE_BTC_PLUS).tokenList();
        address[] memory _lps = new address[](_singles.length);
        uint256[] memory _lpAmounts = new uint256[](_singles.length);

        for (uint256 i = 0; i < _singles.length; i++) {
            _lps[i] = ISinglePlus(_singles[i]).token();
            uint256 _balance = IERC20Upgradeable(_singles[i]).balanceOf(address(this));
            ISinglePlus(_singles[i]).redeem(_balance);

            _lpAmounts[i] = IERC20Upgradeable(_lps[i]).balanceOf(address(this));
            IERC20Upgradeable(_lps[i]).safeTransfer(msg.sender, _lpAmounts[i]);  
        }

        emit Redeemed(msg.sender, _lps, _lpAmounts, _amount);
    }

    function getMaxRedeemable(address _single) public view returns (uint256, uint256) {

        uint256 _singleAmount = IERC20Upgradeable(_single).balanceOf(CURVE_BTC_PLUS);
        return getRedeemSingleAmount(_single, _singleAmount);
    }

    function getRedeemSingleAmount(address _single, uint256 _amount) public view returns (uint256, uint256) {

        (uint256 _singleAmount, uint256 _fee) = ICompositePlus(CURVE_BTC_PLUS).getRedeemSingleAmount(_single, _amount);
        (uint256 _lpAmount,) = ISinglePlus(_single).getRedeemAmount(_singleAmount);

        return (_lpAmount, _fee);
    }

    function redeemSingle(address _single, uint256 _amount) public {

        IERC20Upgradeable(CURVE_BTC_PLUS).safeTransferFrom(msg.sender, address(this), _amount);
        
        ICompositePlus(CURVE_BTC_PLUS).redeemSingle(_single, _amount);
        
        uint256 _singleAmount = IERC20Upgradeable(_single).balanceOf(address(this));
        ISinglePlus(_single).redeem(_singleAmount);
        
        address _lp = ISinglePlus(_single).token();
        uint256 _lpAmount = IERC20Upgradeable(_lp).balanceOf(address(this));
        IERC20Upgradeable(_lp).safeTransfer(msg.sender, _lpAmount);

        address[] memory _lps = new address[](1);
        _lps[0] = _lp;
        uint256[] memory _lpAmounts = new uint256[](1);
        _lpAmounts[0] = _lpAmount;

        emit Redeemed(msg.sender, _lps, _lpAmounts, _amount);
    }

    function salvage() external {

        require(msg.sender == governance, "not governance");

        uint256 _amount = address(this).balance;
        address payable _target = payable(governance);
        (bool _success, ) = _target.call{value: _amount}(new bytes(0));
        require(_success, 'ETH salvage failed');
    }

    function salvageToken(address _token) external {

        require(msg.sender == governance, "not governance");

        IERC20Upgradeable _target = IERC20Upgradeable(_token);
        _target.safeTransfer(governance, _target.balanceOf(address(this)));
    }
}