
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
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

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}// MIT
pragma solidity 0.7.6;


interface ICERC20 is IERC20 {
    function mint(uint256) external returns (uint256);

    function redeem(uint256) external returns (uint256);
}// MIT
pragma solidity 0.7.6;


interface ICOMPERC20 is IERC20 {}// MIT
pragma solidity 0.7.6;



interface IComptroller {
    function claimComp(address, ICERC20[] memory) external;
}// MIT
pragma solidity 0.7.6;


interface IDAOVault is IERC20 {}// MIT
pragma solidity 0.7.6;

interface IUniswapV2Router02 {
    function getAmountsOut(uint256, address[] memory)
        external
        view
        returns (uint256[] memory);

    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external returns (uint256[] memory);
}// MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;



contract CompoundFarmerDAI is ERC20, Ownable {
    using SafeERC20 for IERC20;
    using SafeERC20 for ICOMPERC20;
    using SafeMath for uint256;

    IERC20 public token;
    ICERC20 public cToken;
    ICOMPERC20 public compToken;
    IComptroller public comptroller;
    IUniswapV2Router02 public uniswapRouter;
    IDAOVault public DAOVault;
    address public WETH;
    uint256 private constant MAX_UNIT = 2**256 - 2;
    bool public isVesting;
    uint256 public pool;

    uint256 public amountOutMinPerc = 9500;
    uint256 public deadline = 20 minutes;

    address public treasuryWallet = 0x59E83877bD248cBFe392dbB5A8a29959bcb48592;
    address public communityWallet = 0xdd6c35aFF646B2fB7d8A8955Ccbe0994409348d0;

    uint256[] public networkFeeTier2 = [50000e18+1, 100000e18];
    uint256 public customNetworkFeeTier = 1000000e18;

    uint256 public constant DENOMINATOR = 10000;
    uint256[] public networkFeePercentage = [100, 75, 50];
    uint256 public customNetworkFeePercentage = 25;
    uint256 public profileSharingFeePercentage = 1000;
    uint256 public constant treasuryFee = 5000; // 50% on profile sharing fee
    uint256 public constant communityFee = 5000; // 50% on profile sharing fee

    event SetTreasuryWallet(address indexed oldTreasuryWallet, address indexed newTreasuryWallet);
    event SetCommunityWallet(address indexed oldCommunityWallet, address indexed newCommunityWallet);
    event SetNetworkFeeTier2(uint256[] oldNetworkFeeTier2, uint256[] newNetworkFeeTier2);
    event SetNetworkFeePercentage(uint256[] oldNetworkFeePercentage, uint256[] newNetworkFeePercentage);
    event SetCustomNetworkFeeTier(uint256 indexed oldCustomNetworkFeeTier, uint256 indexed newCustomNetworkFeeTier);
    event SetCustomNetworkFeePercentage(uint256 oldCustomNetworkFeePercentage, uint256 newCustomNetworkFeePercentage);
    event SetProfileSharingFeePercentage(
        uint256 indexed oldProfileSharingFeePercentage, uint256 indexed newProfileSharingFeePercentage);

    constructor(
        address _token, address _cToken, address _compToken, address _comptroller, address _uniswapRouter, address _WETH
    ) ERC20("Compound-Farmer DAI", "cfDAI") {
        _setupDecimals(18);

        token = IERC20(_token);
        cToken = ICERC20(_cToken);
        compToken = ICOMPERC20(_compToken);
        comptroller = IComptroller(_comptroller);
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        WETH = _WETH;

        token.safeApprove(address(cToken), MAX_UNIT);
    }

    function setVault(address _address) external onlyOwner {
        require(address(DAOVault) == address(0), "Vault set");

        DAOVault = IDAOVault(_address);
    }

    function setTreasuryWallet(address _treasuryWallet) external onlyOwner {
        address oldTreasuryWallet = treasuryWallet;
        treasuryWallet = _treasuryWallet;
        emit SetTreasuryWallet(oldTreasuryWallet, _treasuryWallet);
    }

    function setCommunityWallet(address _communityWallet) external onlyOwner {
        address oldCommunityWallet = communityWallet;
        communityWallet = _communityWallet;
        emit SetCommunityWallet(oldCommunityWallet, _communityWallet);
    }

    function setNetworkFeeTier2(uint256[] calldata _networkFeeTier2) external onlyOwner {
        require(_networkFeeTier2[0] != 0, "Minimun amount cannot be 0");
        require(_networkFeeTier2[1] > _networkFeeTier2[0], "Maximun amount must greater than minimun amount");
        uint256[] memory oldNetworkFeeTier2 = networkFeeTier2;
        networkFeeTier2 = _networkFeeTier2;
        emit SetNetworkFeeTier2(oldNetworkFeeTier2, _networkFeeTier2);
    }

    function setCustomNetworkFeeTier(uint256 _customNetworkFeeTier) external onlyOwner {
        require(_customNetworkFeeTier > networkFeeTier2[1], "Custom network fee tier must greater than tier 2");

        uint256 oldCustomNetworkFeeTier = customNetworkFeeTier;
        customNetworkFeeTier = _customNetworkFeeTier;
        emit SetCustomNetworkFeeTier(oldCustomNetworkFeeTier, _customNetworkFeeTier);
    }

    function setNetworkFeePercentage(uint256[] calldata _networkFeePercentage) external onlyOwner {
        require(
            _networkFeePercentage[0] < 3000 && 
            _networkFeePercentage[1] < 3000 && 
            _networkFeePercentage[2] < 3000, "Network fee percentage cannot be more than 30%"
        );
        uint256[] memory oldNetworkFeePercentage = networkFeePercentage;
        networkFeePercentage = _networkFeePercentage;
        emit SetNetworkFeePercentage(oldNetworkFeePercentage, _networkFeePercentage);
    }

    function setCustomNetworkFeePercentage(uint256 _percentage) public onlyOwner {
        require(_percentage < networkFeePercentage[2], "Custom network fee percentage cannot be more than tier 2");

        uint256 oldCustomNetworkFeePercentage = customNetworkFeePercentage;
        customNetworkFeePercentage = _percentage;
        emit SetCustomNetworkFeePercentage(oldCustomNetworkFeePercentage, _percentage);
    }

    function setProfileSharingFeePercentage(uint256 _percentage) public onlyOwner {
        require(_percentage < 3000, "Profile sharing fee percentage cannot be more than 30%");

        uint256 oldProfileSharingFeePercentage = profileSharingFeePercentage;
        profileSharingFeePercentage = _percentage;
        emit SetProfileSharingFeePercentage(oldProfileSharingFeePercentage, _percentage);
    }

    function setAmountOutMinPerc(uint256 _percentage) external onlyOwner {
        require(_percentage <= 9700, "Amount out minimun > 97%");

        amountOutMinPerc = _percentage;
    }

    function setDeadline(uint256 _seconds) external onlyOwner {
        require(_seconds >= 60, "Deadline < 60 seconds");

        deadline = _seconds;
    }

    function getCurrentBalance(address _address) external view returns (uint256 result) {
        uint256 _shares = DAOVault.balanceOf(_address);
        result = _shares > 0 ? pool.mul(_shares).div(totalSupply()) : 0;
    }

    function deposit(uint256 _amount) external {
        require(!isVesting, "Contract in vesting state");
        require(msg.sender == address(DAOVault), "Only can call from Vault");

        token.safeTransferFrom(tx.origin, address(this), _amount);

        uint256 _networkFeePercentage;
        if (_amount < networkFeeTier2[0]) { // Tier 1
            _networkFeePercentage = networkFeePercentage[0];
        } else if (_amount >= networkFeeTier2[0] && _amount <= networkFeeTier2[1]) { // Tier 2
            _networkFeePercentage = networkFeePercentage[1];
        } else if (_amount > networkFeeTier2[1] && _amount < customNetworkFeeTier) { // Tier 3
            _networkFeePercentage = networkFeePercentage[2];
        } else {
            _networkFeePercentage = customNetworkFeePercentage;
        }

        uint256 _fee = _amount.mul(_networkFeePercentage).div(DENOMINATOR);
        _amount = _amount.sub(_fee);
        uint256 error = cToken.mint(_amount);
        require(error == 0, "Failed to lend into Compound");
        token.safeTransfer(treasuryWallet, _fee.mul(treasuryFee).div(DENOMINATOR));
        token.safeTransfer(communityWallet, _fee.mul(communityFee).div(DENOMINATOR));

        uint256 _shares;
        _shares = totalSupply() == 0 ? _amount : _amount.mul(totalSupply()).div(pool);
        pool = pool.add(_amount);
        _mint(address(DAOVault), _shares);
    }

    function withdraw(uint256 _amount) external {
        require(!isVesting, "Contract in vesting state");
        require(msg.sender == address(DAOVault), "Only can call from Vault");
        uint256 _shares = _amount.mul(totalSupply()).div(pool);
        require(DAOVault.balanceOf(tx.origin) >= _shares, "Insufficient balance");

        ICERC20[] memory _cTokens = new ICERC20[](1);
        _cTokens[0] = cToken;
        comptroller.claimComp(address(this), _cTokens);

        uint256 _cTokenBalance = cToken.balanceOf(address(this)).mul(_amount).div(pool);
        uint256 error = cToken.redeem(_cTokenBalance);
        require(error == 0, "Failed to redeem from Compound");

        if (compToken.balanceOf(address(this)) > 0) {
            uint256 _amountIn = compToken.balanceOf(address(this)).mul(_amount).div(pool);
            compToken.safeIncreaseAllowance(address(uniswapRouter), _amountIn);

            address[] memory _path = new address[](3);
            _path[0] = address(compToken);
            _path[1] = WETH;
            _path[2] = address(token);

            uint256[] memory _amountsOut = uniswapRouter.getAmountsOut(_amountIn, _path);
            if (_amountsOut[2] > 0) {
                uint256 _amountOutMin = _amountsOut[2].mul(amountOutMinPerc).div(DENOMINATOR);
                uniswapRouter.swapExactTokensForTokens(
                    _amountIn, _amountOutMin, _path, address(this), block.timestamp.add(deadline));
            }
        }

        uint256 _r = token.balanceOf(address(this));
        if (_r > _amount) {
            uint256 _p = _r.sub(_amount);
            uint256 _fee = _p.mul(profileSharingFeePercentage).div(DENOMINATOR);
            token.safeTransfer(tx.origin, _r.sub(_fee));
            token.safeTransfer(treasuryWallet, _fee.mul(treasuryFee).div(DENOMINATOR));
            token.safeTransfer(communityWallet, _fee.mul(communityFee).div(DENOMINATOR));
        } else {
            token.safeTransfer(tx.origin, _r);
        }

        pool = pool.sub(_amount);
        _burn(address(DAOVault), _shares);
    }

    function vesting() external onlyOwner {
        require(!isVesting, "Already in vesting state");

        ICERC20[] memory _cTokens = new ICERC20[](1);
        _cTokens[0] = cToken;
        comptroller.claimComp(address(this), _cTokens);

        uint256 _cTokenAll = cToken.balanceOf(address(this));
        if (_cTokenAll > 0) {
            uint256 error = cToken.redeem(_cTokenAll);
            require(error == 0, "Failed to redeem from Compound");
        }

        if (compToken.balanceOf(address(this)) > 0) {
            uint256 _amountIn = compToken.balanceOf(address(this));
            compToken.safeApprove(address(uniswapRouter), _amountIn);

            address[] memory _path = new address[](3);
            _path[0] = address(compToken);
            _path[1] = WETH;
            _path[2] = address(token);

            uint256[] memory _amountsOut = uniswapRouter.getAmountsOut(_amountIn, _path);
            if (_amountsOut[2] > 0) {
                uint256 _amountOutMin = _amountsOut[2].mul(amountOutMinPerc).div(DENOMINATOR);
                uniswapRouter.swapExactTokensForTokens(
                    _amountIn, _amountOutMin, _path, address(this), block.timestamp.add(deadline));
            }
        }

        uint256 _r = token.balanceOf(address(this));
        if (_r > pool) {
            uint256 _p = _r.sub(pool);
            uint256 _fee = _p.mul(profileSharingFeePercentage).div(DENOMINATOR);
            token.safeTransfer(treasuryWallet, _fee.mul(treasuryFee).div(DENOMINATOR));
            token.safeTransfer(communityWallet, _fee.mul(communityFee).div(DENOMINATOR));
        }

        pool = token.balanceOf(address(this));
        isVesting = true;
    }

    function refund(uint256 _shares) external {
        require(isVesting, "Not in vesting state");
        require(msg.sender == address(DAOVault), "Only can call from Vault");

        uint256 _refundAmount = pool.mul(_shares).div(totalSupply());
        token.safeTransfer(tx.origin, _refundAmount);
        pool = pool.sub(_refundAmount);
        _burn(address(DAOVault), _shares);
    }

    function revertVesting() external onlyOwner {
        require(isVesting, "Not in vesting state");

        uint256 _amount = token.balanceOf(address(this));
        if (_amount > 0) {
            uint256 error = cToken.mint(_amount);
            require(error == 0, "Failed to lend into Compound");
        }

        isVesting = false;
    }

    function approveMigrate() external onlyOwner {
        require(isVesting, "Not in vesting state");

        if (token.allowance(address(this), address(DAOVault)) == 0) {
            token.safeApprove(address(DAOVault), MAX_UNIT);
        }
    }
}