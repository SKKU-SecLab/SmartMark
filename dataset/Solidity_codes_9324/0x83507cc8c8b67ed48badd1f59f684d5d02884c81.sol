

pragma solidity 0.8.9;




interface IBasicRewards {

    function stakeFor(address, uint256) external returns (bool);


    function balanceOf(address) external view returns (uint256);


    function earned(address) external view returns (uint256);


    function withdrawAll(bool) external returns (bool);


    function withdraw(uint256, bool) external returns (bool);


    function getReward() external returns (bool);


    function stake(uint256) external returns (bool);

}


interface ICurveFactoryPool {

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_balances() external view returns (uint256[2] memory);


    function add_liquidity(
        uint256[2] memory _amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) external returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 _dx,
        uint256 _min_dy,
        address _receiver
    ) external returns (uint256);

}


interface ICurvePool {

    function remove_liquidity_one_coin(
        uint256 token_amount,
        int128 i,
        uint256 min_amount
    ) external;


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i)
        external
        view
        returns (uint256);

}


interface ICurveTriCrypto {

    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy,
        bool use_eth
    ) external;


    function get_dy(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256);

}


interface ICurveV2Pool {

    function get_dy(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256);


    function exchange_underlying(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256);

}


interface ICvxCrvDeposit {

    function deposit(uint256, bool) external;

}


interface ICvxMining {

    function ConvertCrvToCvx(uint256 _amount) external view returns (uint256);

}


interface IVirtualBalanceRewardPool {

    function earned(address account) external view returns (uint256);

}


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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract UnionBase {

    address public constant CVXCRV_STAKING_CONTRACT =
        0x3Fe65692bfCD0e6CF84cB1E7d24108E434A7587e;
    address public constant CURVE_CRV_ETH_POOL =
        0x8301AE4fc9c624d1D396cbDAa1ed877821D7C511;
    address public constant CURVE_CVX_ETH_POOL =
        0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4;
    address public constant CURVE_CVXCRV_CRV_POOL =
        0x9D0464996170c6B9e75eED71c68B99dDEDf279e8;

    address public constant CRV_TOKEN =
        0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant CVXCRV_TOKEN =
        0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
    address public constant CVX_TOKEN =
        0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;

    uint256 public constant CRVETH_ETH_INDEX = 0;
    uint256 public constant CRVETH_CRV_INDEX = 1;
    int128 public constant CVXCRV_CRV_INDEX = 0;
    int128 public constant CVXCRV_CVXCRV_INDEX = 1;
    uint256 public constant CVXETH_ETH_INDEX = 0;
    uint256 public constant CVXETH_CVX_INDEX = 1;

    IBasicRewards cvxCrvStaking = IBasicRewards(CVXCRV_STAKING_CONTRACT);
    ICurveV2Pool cvxEthSwap = ICurveV2Pool(CURVE_CVX_ETH_POOL);
    ICurveV2Pool crvEthSwap = ICurveV2Pool(CURVE_CRV_ETH_POOL);
    ICurveFactoryPool crvCvxCrvSwap = ICurveFactoryPool(CURVE_CVXCRV_CRV_POOL);

    function _swapCrvToCvxCrv(uint256 amount, address recipient)
        internal
        returns (uint256)
    {

        return _crvToCvxCrv(amount, recipient, 0);
    }

    function _swapCrvToCvxCrv(
        uint256 amount,
        address recipient,
        uint256 minAmountOut
    ) internal returns (uint256) {

        return _crvToCvxCrv(amount, recipient, minAmountOut);
    }

    function _crvToCvxCrv(
        uint256 amount,
        address recipient,
        uint256 minAmountOut
    ) internal returns (uint256) {

        return
            crvCvxCrvSwap.exchange(
                CVXCRV_CRV_INDEX,
                CVXCRV_CVXCRV_INDEX,
                amount,
                minAmountOut,
                recipient
            );
    }

    function _swapCvxCrvToCrv(uint256 amount, address recipient)
        internal
        returns (uint256)
    {

        return _cvxCrvToCrv(amount, recipient, 0);
    }

    function _swapCvxCrvToCrv(
        uint256 amount,
        address recipient,
        uint256 minAmountOut
    ) internal returns (uint256) {

        return _cvxCrvToCrv(amount, recipient, minAmountOut);
    }

    function _cvxCrvToCrv(
        uint256 amount,
        address recipient,
        uint256 minAmountOut
    ) internal returns (uint256) {

        return
            crvCvxCrvSwap.exchange(
                CVXCRV_CVXCRV_INDEX,
                CVXCRV_CRV_INDEX,
                amount,
                minAmountOut,
                recipient
            );
    }

    function _swapCrvToEth(uint256 amount) internal returns (uint256) {

        return _crvToEth(amount, 0);
    }

    function _swapCrvToEth(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return _crvToEth(amount, minAmountOut);
    }

    function _crvToEth(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return
            crvEthSwap.exchange_underlying{value: 0}(
                CRVETH_CRV_INDEX,
                CRVETH_ETH_INDEX,
                amount,
                minAmountOut
            );
    }

    function _swapEthToCrv(uint256 amount) internal returns (uint256) {

        return _ethToCrv(amount, 0);
    }

    function _swapEthToCrv(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return _ethToCrv(amount, minAmountOut);
    }

    function _ethToCrv(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return
            crvEthSwap.exchange_underlying{value: amount}(
                CRVETH_ETH_INDEX,
                CRVETH_CRV_INDEX,
                amount,
                minAmountOut
            );
    }

    function _swapEthToCvx(uint256 amount) internal returns (uint256) {

        return _ethToCvx(amount, 0);
    }

    function _swapEthToCvx(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return _ethToCvx(amount, minAmountOut);
    }

    function _ethToCvx(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return
            cvxEthSwap.exchange_underlying{value: amount}(
                CVXETH_ETH_INDEX,
                CVXETH_CVX_INDEX,
                amount,
                minAmountOut
            );
    }

    modifier notToZeroAddress(address _to) {

        require(_to != address(0), "Invalid address!");
        _;
    }
}


contract ClaimZaps is ReentrancyGuard, UnionBase {

    using SafeERC20 for IERC20;

    enum Option {
        Claim,
        ClaimAsETH,
        ClaimAsCRV,
        ClaimAsCVX,
        ClaimAndStake
    }

    function _setApprovals() internal {

        IERC20(CRV_TOKEN).safeApprove(CURVE_CRV_ETH_POOL, 0);
        IERC20(CRV_TOKEN).safeApprove(CURVE_CRV_ETH_POOL, type(uint256).max);

        IERC20(CVXCRV_TOKEN).safeApprove(CVXCRV_STAKING_CONTRACT, 0);
        IERC20(CVXCRV_TOKEN).safeApprove(
            CVXCRV_STAKING_CONTRACT,
            type(uint256).max
        );

        IERC20(CVXCRV_TOKEN).safeApprove(CURVE_CVXCRV_CRV_POOL, 0);
        IERC20(CVXCRV_TOKEN).safeApprove(
            CURVE_CVXCRV_CRV_POOL,
            type(uint256).max
        );
    }

    function _claimAs(
        address account,
        uint256 amount,
        Option option
    ) internal {

        _claim(account, amount, option, 0);
    }

    function _claimAs(
        address account,
        uint256 amount,
        Option option,
        uint256 minAmountOut
    ) internal {

        _claim(account, amount, option, minAmountOut);
    }

    function _claim(
        address account,
        uint256 amount,
        Option option,
        uint256 minAmountOut
    ) internal nonReentrant {

        if (option == Option.ClaimAsCRV) {
            _swapCvxCrvToCrv(amount, account, minAmountOut);
        } else if (option == Option.ClaimAsETH) {
            uint256 _crvBalance = _swapCvxCrvToCrv(amount, address(this));
            uint256 _ethAmount = _swapCrvToEth(_crvBalance, minAmountOut);
            (bool success, ) = account.call{value: _ethAmount}("");
            require(success, "ETH transfer failed");
        } else if (option == Option.ClaimAsCVX) {
            uint256 _crvBalance = _swapCvxCrvToCrv(amount, address(this));
            uint256 _ethAmount = _swapCrvToEth(_crvBalance);
            uint256 _cvxAmount = _swapEthToCvx(_ethAmount, minAmountOut);
            IERC20(CVX_TOKEN).safeTransfer(account, _cvxAmount);
        } else if (option == Option.ClaimAndStake) {
            require(cvxCrvStaking.stakeFor(account, amount), "Staking failed");
        } else {
            IERC20(CVXCRV_TOKEN).safeTransfer(account, amount);
        }
    }
}


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

}


contract UnionVault is ClaimZaps, ERC20, Ownable {
    using SafeERC20 for IERC20;

    address private constant TRIPOOL =
        0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address private constant THREECRV_TOKEN =
        0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
    address private constant USDT_TOKEN =
        0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address private constant TRICRYPTO =
        0xD51a44d3FaE010294C616388b506AcdA1bfAAE46;
    address private constant CVX_MINING_LIB =
        0x3c75BFe6FbfDa3A94E7E7E8c2216AFc684dE5343;
    address private constant THREE_CRV_REWARDS =
        0x7091dbb7fcbA54569eF1387Ac89Eb2a5C9F6d2EA;
    address private constant CVXCRV_DEPOSIT =
        0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae;
    address public platform = 0x9Bc7c6ad7E7Cf3A6fCB58fb21e27752AC1e53f99;

    uint256 public withdrawalPenalty = 100;
    uint256 public constant MAX_WITHDRAWAL_PENALTY = 150;
    uint256 public platformFee = 500;
    uint256 public constant MAX_PLATFORM_FEE = 2000;
    uint256 public callIncentive = 500;
    uint256 public constant MAX_CALL_INCENTIVE = 500;
    uint256 public constant FEE_DENOMINATOR = 10000;

    ICurvePool private tripool = ICurvePool(TRIPOOL);
    ICurveTriCrypto private tricrypto = ICurveTriCrypto(TRICRYPTO);

    event Harvest(address indexed _caller, uint256 _value);
    event Deposit(address indexed _from, address indexed _to, uint256 _value);
    event Withdraw(address indexed _from, address indexed _to, uint256 _value);

    event WithdrawalPenaltyUpdated(uint256 _penalty);
    event CallerIncentiveUpdated(uint256 _incentive);
    event PlatformFeeUpdated(uint256 _fee);
    event PlatformUpdated(address indexed _platform);

    constructor()
        ERC20(
            string(abi.encodePacked("Unionized cvxCRV")),
            string(abi.encodePacked("uCRV"))
        )
    {}

    function setApprovals() external onlyOwner {
        IERC20(THREECRV_TOKEN).safeApprove(TRIPOOL, 0);
        IERC20(THREECRV_TOKEN).safeApprove(TRIPOOL, type(uint256).max);

        IERC20(CVX_TOKEN).safeApprove(CURVE_CVX_ETH_POOL, 0);
        IERC20(CVX_TOKEN).safeApprove(CURVE_CVX_ETH_POOL, type(uint256).max);

        IERC20(USDT_TOKEN).safeApprove(TRICRYPTO, 0);
        IERC20(USDT_TOKEN).safeApprove(TRICRYPTO, type(uint256).max);

        IERC20(CRV_TOKEN).safeApprove(CVXCRV_DEPOSIT, 0);
        IERC20(CRV_TOKEN).safeApprove(CVXCRV_DEPOSIT, type(uint256).max);

        IERC20(CRV_TOKEN).safeApprove(CURVE_CVXCRV_CRV_POOL, 0);
        IERC20(CRV_TOKEN).safeApprove(CURVE_CVXCRV_CRV_POOL, type(uint256).max);

        _setApprovals();
    }

    function setWithdrawalPenalty(uint256 _penalty) external onlyOwner {
        require(_penalty <= MAX_WITHDRAWAL_PENALTY);
        withdrawalPenalty = _penalty;
        emit WithdrawalPenaltyUpdated(_penalty);
    }

    function setCallIncentive(uint256 _incentive) external onlyOwner {
        require(_incentive <= MAX_CALL_INCENTIVE);
        callIncentive = _incentive;
        emit CallerIncentiveUpdated(_incentive);
    }

    function setPlatformFee(uint256 _fee) external onlyOwner {
        require(_fee <= MAX_PLATFORM_FEE);
        platformFee = _fee;
        emit PlatformFeeUpdated(_fee);
    }

    function setPlatform(address _platform)
        external
        onlyOwner
        notToZeroAddress(_platform)
    {
        platform = _platform;
        emit PlatformUpdated(_platform);
    }

    function totalUnderlying() public view returns (uint256 total) {
        return cvxCrvStaking.balanceOf(address(this));
    }

    function outstandingCrvRewards() public view returns (uint256 total) {
        return cvxCrvStaking.earned(address(this));
    }

    function outstandingCvxRewards() external view returns (uint256 total) {
        return
            ICvxMining(CVX_MINING_LIB).ConvertCrvToCvx(outstandingCrvRewards());
    }

    function outstanding3CrvRewards() external view returns (uint256 total) {
        return
            IVirtualBalanceRewardPool(THREE_CRV_REWARDS).earned(address(this));
    }

    function balanceOfUnderlying(address user)
        external
        view
        returns (uint256 amount)
    {
        require(totalSupply() > 0, "No users");
        return ((balanceOf(user) * totalUnderlying()) / totalSupply());
    }

    function underlying() external view returns (address) {
        return CVXCRV_TOKEN;
    }

    function harvest() public {
        cvxCrvStaking.getReward();

        uint256 _cvxAmount = IERC20(CVX_TOKEN).balanceOf(address(this));
        if (_cvxAmount > 0) {
            cvxEthSwap.exchange_underlying{value: 0}(
                CVXETH_CVX_INDEX,
                CVXETH_ETH_INDEX,
                _cvxAmount,
                0
            );
        }

        uint256 _threeCrvBalance = IERC20(THREECRV_TOKEN).balanceOf(
            address(this)
        );
        if (_threeCrvBalance > 0) {
            tripool.remove_liquidity_one_coin(_threeCrvBalance, 2, 0);

            uint256 _usdtBalance = IERC20(USDT_TOKEN).balanceOf(address(this));
            if (_usdtBalance > 0) {
                tricrypto.exchange(0, 2, _usdtBalance, 0, true);
            }
        }
        uint256 _crvBalance = IERC20(CRV_TOKEN).balanceOf(address(this));
        uint256 _ethBalance = address(this).balance;
        if (_ethBalance > 0) {
            _crvBalance += _swapEthToCrv(address(this).balance);
        }
        if (_crvBalance > 0) {
            uint256 _quote = crvCvxCrvSwap.get_dy(
                CVXCRV_CRV_INDEX,
                CVXCRV_CVXCRV_INDEX,
                _crvBalance
            );
            if (_quote > _crvBalance) {
                _swapCrvToCvxCrv(_crvBalance, address(this));
            }
            else {
                ICvxCrvDeposit(CVXCRV_DEPOSIT).deposit(_crvBalance, true);
            }
        }
        uint256 _cvxCrvBalance = IERC20(CVXCRV_TOKEN).balanceOf(address(this));

        emit Harvest(msg.sender, _cvxCrvBalance);

        if (totalSupply() == 0) {
            return;
        }

        if (_cvxCrvBalance > 0) {
            uint256 _stakingAmount = _cvxCrvBalance;
            if (callIncentive > 0) {
                uint256 incentiveAmount = (_cvxCrvBalance * callIncentive) /
                    FEE_DENOMINATOR;
                IERC20(CVXCRV_TOKEN).safeTransfer(msg.sender, incentiveAmount);
                _stakingAmount = _stakingAmount - incentiveAmount;
            }
            if (platformFee > 0) {
                uint256 feeAmount = (_cvxCrvBalance * platformFee) /
                    FEE_DENOMINATOR;
                IERC20(CVXCRV_TOKEN).safeTransfer(platform, feeAmount);
                _stakingAmount = _stakingAmount - feeAmount;
            }
            cvxCrvStaking.stake(_stakingAmount);
        }
    }

    function deposit(address _to, uint256 _amount)
        public
        notToZeroAddress(_to)
        returns (uint256 _shares)
    {
        require(_amount > 0, "Deposit too small");

        uint256 _before = totalUnderlying();
        IERC20(CVXCRV_TOKEN).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        cvxCrvStaking.stake(_amount);

        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply()) / _before;
        }
        _mint(_to, shares);
        emit Deposit(msg.sender, _to, _amount);
        return shares;
    }

    function depositAll(address _to) external returns (uint256 _shares) {
        return deposit(_to, IERC20(CVXCRV_TOKEN).balanceOf(msg.sender));
    }

    function _withdraw(uint256 _shares)
        internal
        returns (uint256 _withdrawable)
    {
        require(totalSupply() > 0);
        uint256 amount = (_shares * totalUnderlying()) / totalSupply();
        _burn(msg.sender, _shares);
        if (totalSupply() == 0) {
            harvest();
            cvxCrvStaking.withdraw(totalUnderlying(), false);
            _withdrawable = IERC20(CVXCRV_TOKEN).balanceOf(address(this));
        }
        else {
            _withdrawable = amount;
            uint256 _penalty = (_withdrawable * withdrawalPenalty) /
                FEE_DENOMINATOR;
            _withdrawable = _withdrawable - _penalty;
            cvxCrvStaking.withdraw(_withdrawable, false);
        }
        return _withdrawable;
    }

    function withdraw(address _to, uint256 _shares)
        public
        notToZeroAddress(_to)
        returns (uint256 withdrawn)
    {
        uint256 _withdrawable = _withdraw(_shares);
        IERC20(CVXCRV_TOKEN).safeTransfer(_to, _withdrawable);
        emit Withdraw(msg.sender, _to, _withdrawable);
        return _withdrawable;
    }

    function withdrawAll(address _to)
        external
        notToZeroAddress(_to)
        returns (uint256 withdrawn)
    {
        return withdraw(_to, balanceOf(msg.sender));
    }

    function withdrawAs(
        address _to,
        uint256 _shares,
        Option option
    ) external notToZeroAddress(_to) {
        uint256 _withdrawn = _withdraw(_shares);
        _claimAs(_to, _withdrawn, option);
    }

    function withdrawAllAs(address _to, Option option)
        external
        notToZeroAddress(_to)
    {
        uint256 _withdrawn = _withdraw(balanceOf(msg.sender));
        _claimAs(_to, _withdrawn, option);
    }

    function withdrawAs(
        address _to,
        uint256 _shares,
        Option option,
        uint256 minAmountOut
    ) external notToZeroAddress(_to) {
        uint256 _withdrawn = _withdraw(_shares);
        _claimAs(_to, _withdrawn, option, minAmountOut);
    }

    function withdrawAllAs(
        address _to,
        Option option,
        uint256 minAmountOut
    ) external notToZeroAddress(_to) {
        uint256 _withdrawn = _withdraw(balanceOf(msg.sender));
        _claimAs(_to, _withdrawn, option, minAmountOut);
    }

    receive() external payable {}
}