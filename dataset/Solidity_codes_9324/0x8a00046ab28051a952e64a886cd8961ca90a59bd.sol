
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



interface ICurvePairs {

    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external;

    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 _min_amount) external;

    function balances(uint256 i) external view returns (uint256);

}

interface IGauge {

    function balanceOf(address _address) external view returns (uint256);

    function deposit(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function getReward() external; // For Pickle Farm only

}

interface IMintr {

    function mint(address _address) external;

}

interface IRouter {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint[] memory amounts);


    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

}

interface IPickleJar is IERC20 {

    function deposit(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function balance() external view returns (uint256);

}

interface IMasterChef {

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function userInfo(uint256, address) external view returns(uint256, uint256);

}

interface IWETH is IERC20 {

    function withdraw(uint256 _amount) external;

}

interface ICitadelVault {

    function getReimburseTokenAmount(uint256) external view returns (uint256);

}

interface IChainlink {

    function latestAnswer() external view returns (int256);

}

interface ISLPToken is IERC20 {

    function getReserves() external view returns (uint112, uint112, uint32);

}

contract CitadelStrategy is Ownable {

    using SafeERC20 for IERC20;
    using SafeERC20 for IWETH;
    using SafeERC20 for IPickleJar;
    using SafeERC20 for ISLPToken;
    using SafeMath for uint256;

    IERC20 private constant WBTC = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 private constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 private constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 private constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IRouter private constant router = IRouter(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // SushiSwap
    ICitadelVault public vault;

    ICurvePairs private constant cPairs = ICurvePairs(0x4CA9b3063Ec5866A4B82E437059D2C43d1be596F); // HBTC/WBTC
    IERC20 private constant clpToken = IERC20(0xb19059ebb43466C323583928285a49f558E572Fd);
    IERC20 private constant CRV = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
    IGauge private constant gaugeC = IGauge(0x4c18E409Dc8619bFb6a1cB56D114C3f592E0aE79);
    IMintr private constant mintr = IMintr(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);

    ISLPToken private constant slpWBTC = ISLPToken(0xCEfF51756c56CeFFCA006cD410B03FFC46dd3a58); // WBTC/ETH
    ISLPToken private constant slpDAI = ISLPToken(0xC3D03e4F041Fd4cD388c549Ee2A29a9E5075882f); // DAI/ETH
    IERC20 private constant PICKLE = IERC20(0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5);
    IPickleJar private constant pickleJarWBTC = IPickleJar(0xde74b6c547bd574c3527316a2eE30cd8F6041525);
    IPickleJar private constant pickleJarDAI = IPickleJar(0x55282dA27a3a02ffe599f6D11314D239dAC89135);
    IGauge private constant gaugeP_WBTC = IGauge(0xD55331E7bCE14709d825557E5Bca75C73ad89bFb);
    IGauge private constant gaugeP_DAI = IGauge(0x6092c7084821057060ce2030F9CC11B22605955F);

    IERC20 private constant DPI = IERC20(0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b);
    ISLPToken private constant slpDPI = ISLPToken(0x34b13F8CD184F55d0Bd4Dd1fe6C07D46f245c7eD); // DPI/ETH
    IERC20 private constant SUSHI = IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    IMasterChef private constant masterChef = IMasterChef(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);

    uint256 private _HBTCWBTCLPTokenPrice;
    uint256 private _WBTCETHLPTokenPrice;
    uint256 private _DPIETHLPTokenPrice;
    uint256 private _DAIETHLPTokenPrice;

    uint256 private _poolHBTCWBTC;
    uint256 private _poolWBTCETH;
    uint256 private _poolDPIETH;
    uint256 private _poolDAIETH;
    uint256 private _pool; // For emergencyWithdraw() only

    uint256 private constant DENOMINATOR = 10000;
    bool public isVesting;

    uint256 public yieldFeePerc = 1000;
    address public admin;
    address public communityWallet;
    address public strategist;

    event ETHToInvest(uint256 amount);
    event LatestLPTokenPrice(uint256 curveHBTC, uint256 pickleWBTC, uint256 sushiSwapDPI, uint256 pickleDAI);
    event YieldAmount(uint256 curveHBTC, uint256 pickleWBTC, uint256 sushiSwapDPI, uint256 pickleDAI); // in ETH
    event CurrentComposition(uint256 curveHBTC, uint256 pickleWBTC, uint256 sushiSwapDPI, uint256 pickleDAI); // in ETH
    event TargetComposition(uint256 curveHBTC, uint256 pickleWBTC, uint256 sushiSwapDPI, uint256 pickleDAI); // in ETH
    event AddLiquidity(address pairs, uint256 amountA, uint256 amountB, uint256 lpTokenMinted); // in ETH

    modifier onlyVault {

        require(msg.sender == address(vault), "Only vault");
        _;
    }

    constructor(address _communityWallet, address _strategist, address _admin) {
        communityWallet = _communityWallet;
        strategist = _strategist;
        admin = _admin;

        WETH.safeApprove(address(router), type(uint256).max);
        WBTC.safeApprove(address(router), type(uint256).max);
        DAI.safeApprove(address(router), type(uint256).max);
        slpWBTC.safeApprove(address(router), type(uint256).max);
        slpDAI.safeApprove(address(router), type(uint256).max);
        slpDPI.safeApprove(address(router), type(uint256).max);
        CRV.safeApprove(address(router), type(uint256).max);
        PICKLE.safeApprove(address(router), type(uint256).max);
        SUSHI.safeApprove(address(router), type(uint256).max);
        WBTC.safeApprove(address(cPairs), type(uint256).max);
        clpToken.safeApprove(address(gaugeC), type(uint256).max);
        slpWBTC.safeApprove(address(pickleJarWBTC), type(uint256).max);
        slpDAI.safeApprove(address(pickleJarDAI), type(uint256).max);
        pickleJarWBTC.safeApprove(address(gaugeP_WBTC), type(uint256).max);
        pickleJarDAI.safeApprove(address(gaugeP_DAI), type(uint256).max);
        DPI.safeApprove(address(router), type(uint256).max);
        slpDPI.safeApprove(address(masterChef), type(uint256).max);

        (uint256 _clpTokenPriceHBTC, uint256 _pSlpTokenPriceWBTC, uint256 _slpTokenPriceDPI, uint256 _pSlpTokenPriceDAI) = _getLPTokenPrice();
        _HBTCWBTCLPTokenPrice = _clpTokenPriceHBTC;
        _WBTCETHLPTokenPrice = _pSlpTokenPriceWBTC;
        _DPIETHLPTokenPrice = _slpTokenPriceDPI;
        _DAIETHLPTokenPrice = _pSlpTokenPriceDAI;
    }

    function setVault(address _address) external onlyOwner {

        require(address(vault) == address(0), "Vault set");

        vault = ICitadelVault(_address);
    }

    function invest(uint256 _amount) external onlyVault {

        _updatePoolForPriceChange();

        WETH.safeTransferFrom(address(vault), address(this), _amount);
        emit ETHToInvest(_amount);
        _updatePoolForProvideLiquidity();
    }

    function _updatePoolForPriceChange() private {

        (uint256 _clpTokenPriceHBTC, uint256 _pSlpTokenPriceWBTC, uint256 _slpTokenPriceDPI, uint256 _pSlpTokenPriceDAI) = _getLPTokenPrice();
        _poolHBTCWBTC = _poolHBTCWBTC.mul(_clpTokenPriceHBTC).div(_HBTCWBTCLPTokenPrice);
        _poolWBTCETH = _poolWBTCETH.mul(_pSlpTokenPriceWBTC).div(_WBTCETHLPTokenPrice);
        _poolDPIETH = _poolDPIETH.mul(_slpTokenPriceDPI).div(_DPIETHLPTokenPrice);
        _poolDAIETH = _poolDAIETH.mul(_pSlpTokenPriceDAI).div(_DAIETHLPTokenPrice);
        emit CurrentComposition(_poolHBTCWBTC, _poolWBTCETH, _poolDPIETH, _poolDAIETH);
        _HBTCWBTCLPTokenPrice = _clpTokenPriceHBTC;
        _WBTCETHLPTokenPrice = _pSlpTokenPriceWBTC;
        _DPIETHLPTokenPrice = _slpTokenPriceDPI;
        _DAIETHLPTokenPrice = _pSlpTokenPriceDAI;
        emit LatestLPTokenPrice(_HBTCWBTCLPTokenPrice, _WBTCETHLPTokenPrice, _DPIETHLPTokenPrice, _DAIETHLPTokenPrice);
    }

    function yield() external onlyVault {

        _updatePoolForPriceChange();

        uint256[] memory _yieldAmts = new uint256[](4); // For emit yield amount of each farm
        uint256 _yieldFees;
        mintr.mint(address(gaugeC)); // Claim CRV
        uint256 _balanceOfCRV = CRV.balanceOf(address(this));
        if (_balanceOfCRV > 0) {
            uint256[] memory _amounts = _swapExactTokensForTokens(address(CRV), address(WETH), _balanceOfCRV);
            _yieldAmts[0] = _amounts[1];
            uint256 _fee = _amounts[1].mul(yieldFeePerc).div(DENOMINATOR);
            _poolHBTCWBTC = _poolHBTCWBTC.add(_amounts[1].sub(_fee));
            _yieldFees = _yieldFees.add(_fee);
        }
        gaugeP_WBTC.getReward(); // Claim PICKLE
        uint256 _balanceOfPICKLEForWETH = PICKLE.balanceOf(address(this));
        if (_balanceOfPICKLEForWETH > 0) {
            uint256[] memory _amounts = _swapExactTokensForTokens(address(PICKLE), address(WETH), _balanceOfPICKLEForWETH);
            _yieldAmts[1] = _amounts[1];
            uint256 _fee = _amounts[1].mul(yieldFeePerc).div(DENOMINATOR);
            _poolWBTCETH = _poolWBTCETH.add(_amounts[1].sub(_fee));
            _yieldFees = _yieldFees.add(_fee);
        }
        (uint256 _slpDPIAmt,) = masterChef.userInfo(42, address(this));
        if (_slpDPIAmt > 0) {
            uint256 _balanceOfSUSHI = SUSHI.balanceOf(address(this));
            if (_balanceOfSUSHI > 0) {
                uint256[] memory _amounts = _swapExactTokensForTokens(address(SUSHI), address(WETH), _balanceOfSUSHI);
                uint256 _fee = _amounts[1].mul(yieldFeePerc).div(DENOMINATOR);
                _yieldAmts[2] = _amounts[1];
                _poolDPIETH = _poolDPIETH.add(_amounts[1].sub(_fee));
                _yieldFees = _yieldFees.add(_fee);
            }
        }
        gaugeP_DAI.getReward(); // Claim PICKLE
        uint256 _balanceOfPICKLEForDAI = PICKLE.balanceOf(address(this));
        if (_balanceOfPICKLEForDAI > 0) {
            uint256[] memory _amounts = _swapExactTokensForTokens(address(PICKLE), address(WETH), _balanceOfPICKLEForDAI);
            _yieldAmts[3] = _amounts[1];
            uint256 _fee = _amounts[1].mul(yieldFeePerc).div(DENOMINATOR);
            _poolDAIETH = _poolDAIETH.add(_amounts[1].sub(_fee));
            _yieldFees = _yieldFees.add(_fee);
        }
        emit YieldAmount(_yieldAmts[0], _yieldAmts[1], _yieldAmts[2], _yieldAmts[3]);

        _splitYieldFees(_yieldFees);

        _updatePoolForProvideLiquidity();
    }

    function _splitYieldFees(uint256 _amount) private {

        WETH.withdraw(_amount);
        uint256 _yieldFee = (address(this).balance).mul(2).div(5);
        (bool _a,) = admin.call{value: _yieldFee}(""); // 40%
        require(_a);
        (bool _t,) = communityWallet.call{value: _yieldFee}(""); // 40%
        require(_t);
        (bool _s,) = strategist.call{value: (address(this).balance)}(""); // 20%
        require(_s);
    }

    receive() external payable {}

    function _updatePoolForProvideLiquidity() private {

        uint256 _totalPool = _getTotalPool().add(WETH.balanceOf(address(this)));
        uint256 _thirtyPercOfPool = _totalPool.mul(3000).div(DENOMINATOR);
        uint256 _poolHBTCWBTCTarget = _thirtyPercOfPool; // 30% for Curve HBTC/WBTC
        uint256 _poolWBTCETHTarget = _thirtyPercOfPool; // 30% for Pickle WBTC/ETH
        uint256 _poolDPIETHTarget = _thirtyPercOfPool; // 30% for SushiSwap DPI/ETH
        uint256 _poolDAIETHTarget = _totalPool.sub(_thirtyPercOfPool).sub(_thirtyPercOfPool).sub(_thirtyPercOfPool); // 10% for Pickle DAI/ETH
        emit CurrentComposition(_poolHBTCWBTC, _poolWBTCETH, _poolDPIETH, _poolDAIETH);
        emit TargetComposition(_poolHBTCWBTCTarget, _poolWBTCETHTarget, _poolDPIETHTarget, _poolDAIETHTarget);
        if (
            _poolHBTCWBTCTarget > _poolHBTCWBTC &&
            _poolWBTCETHTarget > _poolWBTCETH &&
            _poolDPIETHTarget > _poolDPIETH &&
            _poolDAIETHTarget > _poolDAIETH
        ) {
            uint256 _investHBTCWBTCAmt = _poolHBTCWBTCTarget.sub(_poolHBTCWBTC);
            _investHBTCWBTC(_investHBTCWBTCAmt);
            uint256 _investWBTCETHAmt = _poolWBTCETHTarget.sub(_poolWBTCETH);
            _investWBTCETH(_investWBTCETHAmt);
            uint256 _investDPIETHAmt = _poolDPIETHTarget.sub(_poolDPIETH);
            _investDPIETH(_investDPIETHAmt);
            uint256 _investDAIETHAmt = _poolDAIETHTarget.sub(_poolDAIETH);
            _investDAIETH(_investDAIETHAmt);
        } else {
            uint256 _furthest;
            uint256 _farmIndex;
            if (_poolHBTCWBTCTarget > _poolHBTCWBTC) {
                uint256 _diff = _poolHBTCWBTCTarget.sub(_poolHBTCWBTC);
                _furthest = _diff;
                _farmIndex = 0;
            }
            if (_poolWBTCETHTarget > _poolWBTCETH) {
                uint256 _diff = _poolWBTCETHTarget.sub(_poolWBTCETH);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 1;
                }
            }
            if (_poolDPIETHTarget > _poolDPIETH) {
                uint256 _diff = _poolDPIETHTarget.sub(_poolDPIETH);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 2;
                }
            }
            if (_poolDAIETHTarget > _poolDAIETH) {
                uint256 _diff = _poolDAIETHTarget.sub(_poolDAIETH);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 3;
                }
            }
            uint256 _balanceOfWETH = WETH.balanceOf(address(this));
            if (_farmIndex == 0) {
                _investHBTCWBTC(_balanceOfWETH);
            } else if (_farmIndex == 1) {
                _investWBTCETH(_balanceOfWETH);
            } else if (_farmIndex == 2) {
                _investDPIETH(_balanceOfWETH);
            } else {
                _investDAIETH(_balanceOfWETH);
            }
        }
        emit CurrentComposition(_poolHBTCWBTC, _poolWBTCETH, _poolDPIETH, _poolDAIETH);
    }

    function _investHBTCWBTC(uint256 _amount) private {

        uint256[] memory _amounts = _swapExactTokensForTokens(address(WETH), address(WBTC), _amount);
        if (_amounts[1] > 0) {
            cPairs.add_liquidity([0, _amounts[1]], 0);
            uint256 _balanceOfClpToken = clpToken.balanceOf(address(this));
            gaugeC.deposit(_balanceOfClpToken);
            _poolHBTCWBTC = _poolHBTCWBTC.add(_amount);
            emit AddLiquidity(address(cPairs), _amounts[1], 0, _balanceOfClpToken);
        }
    }

    function _investWBTCETH(uint256 _amount) private {

        uint256 _amountIn = _amount.div(2);
        uint256[] memory _amounts = _swapExactTokensForTokens(address(WETH), address(WBTC), _amountIn);
        if (_amounts[1] > 0) {
            (uint256 _amountA, uint256 _amountB, uint256 _slpWBTC) = router.addLiquidity(
                address(WBTC), address(WETH), 
                _amounts[1], _amountIn,
                0, 0,
                address(this), block.timestamp
            );
            emit AddLiquidity(address(slpWBTC), _amountA, _amountB, _slpWBTC);
            pickleJarWBTC.deposit(_slpWBTC);
            gaugeP_WBTC.deposit(pickleJarWBTC.balanceOf(address(this)));
            _poolWBTCETH = _poolWBTCETH.add(_amount);
        }
    }

    function _investDPIETH(uint256 _amount) private {

        uint256 _amountIn = _amount.div(2);
        uint256[] memory _amounts = _swapExactTokensForTokens(address(WETH), address(DPI), _amountIn);
        if (_amounts[1] > 0) {
            (uint256 _amountA, uint256 _amountB, uint256 _slpDPI) = router.addLiquidity(address(DPI), address(WETH), _amounts[1], _amountIn, 0, 0, address(this), block.timestamp);
            masterChef.deposit(42, _slpDPI);
            _poolDPIETH = _poolDPIETH.add(_amount);
            emit AddLiquidity(address(slpDPI), _amountA, _amountB, _slpDPI);
        }
    }

    function _investDAIETH(uint256 _amount) private {

        uint256 _amountIn = _amount.div(2);
        uint256[] memory _amounts = _swapExactTokensForTokens(address(WETH), address(DAI), _amountIn);
        if (_amounts[1] > 0) {
            (uint256 _amountA, uint256 _amountB, uint256 _slpDAI) = router.addLiquidity(
                address(DAI), address(WETH), 
                _amounts[1], _amountIn,
                0, 0,
                address(this), block.timestamp
            );
            emit AddLiquidity(address(slpDAI), _amountA, _amountB, _slpDAI); // 1389.083912192186144530 0.335765206816332767 17.202418926243352766
            pickleJarDAI.deposit(_slpDAI);
            gaugeP_DAI.deposit(pickleJarDAI.balanceOf(address(this)));
            _poolDAIETH = _poolDAIETH.add(_amount);
        }
    }

    function reimburse() external onlyVault {

        uint256 _reimburseUSDT = vault.getReimburseTokenAmount(0);
        uint256 _reimburseUSDC = vault.getReimburseTokenAmount(1);
        uint256 _reimburseDAI = vault.getReimburseTokenAmount(2);
        uint256 _totalReimburse = _reimburseUSDT.add(_reimburseUSDC).add(_reimburseDAI.div(1e12));

        uint256[] memory _amounts = router.getAmountsOut(_totalReimburse, _getPath(address(USDT), address(WETH)));
        if (WETH.balanceOf(address(this)) < _amounts[1]) { // Balance of WETH > _amounts[1] when execute emergencyWithdraw()
            _updatePoolForPriceChange();
            uint256 _thirtyPercOfAmtWithdraw = _amounts[1].mul(3000).div(DENOMINATOR);
            _withdrawCurve(_thirtyPercOfAmtWithdraw); // 30% from Curve HBTC/WBTC
            _withdrawPickleWBTC(_thirtyPercOfAmtWithdraw); // 30% from Pickle WBTC/ETH
            _withdrawSushiswap(_thirtyPercOfAmtWithdraw); // 30% from SushiSwap DPI/ETH
            _withdrawPickleDAI(_amounts[1].sub(_thirtyPercOfAmtWithdraw).sub(_thirtyPercOfAmtWithdraw).sub(_thirtyPercOfAmtWithdraw)); // 10% from Pickle DAI/ETH
            _swapAllToETH(); // Swap WBTC, DPI & DAI that get from withdrawal above to WETH
        }

        uint256 _WETHBalance = WETH.balanceOf(address(this));
        _reimburse(_WETHBalance.mul(_reimburseUSDT).div(_totalReimburse), USDT);
        _reimburse(_WETHBalance.mul(_reimburseUSDC).div(_totalReimburse), USDC);
        _reimburse((WETH.balanceOf(address(this))), DAI);
    }

    function _reimburse(uint256 _reimburseAmt, IERC20 _token) private {

        if (_reimburseAmt > 0) {
            uint256[] memory _amounts = _swapExactTokensForTokens(address(WETH), address(_token), _reimburseAmt);
            _token.safeTransfer(address(vault), _amounts[1]);
        }
    }

    function emergencyWithdraw() external onlyVault {

        mintr.mint(address(gaugeC));
        _withdrawCurve(_poolHBTCWBTC);
        gaugeP_WBTC.getReward();
        _withdrawPickleWBTC(_poolWBTCETH);
        _withdrawSushiswap(_poolDPIETH);
        gaugeP_WBTC.getReward();
        _withdrawPickleDAI(_poolDAIETH);

        uint256 balanceOfWETHBefore = WETH.balanceOf(address(this));
        _swapExactTokensForTokens(address(CRV), address(WETH), CRV.balanceOf(address(this)));
        _swapExactTokensForTokens(address(PICKLE), address(WETH), PICKLE.balanceOf(address(this)));
        _swapExactTokensForTokens(address(SUSHI), address(WETH), SUSHI.balanceOf(address(this)));
        uint256 _rewards = (WETH.balanceOf(address(this))).sub(balanceOfWETHBefore);
        uint256 _adminFees = _rewards.mul(yieldFeePerc).div(DENOMINATOR);
        _splitYieldFees(_adminFees);

        _swapAllToETH();
        _pool = WETH.balanceOf(address(this));
        isVesting = true;
    }

    function reinvest() external onlyVault {

        _pool = 0;
        isVesting = false;
        _updatePoolForProvideLiquidity();
    }

    function _swapExactTokensForTokens(address _tokenA, address _tokenB, uint256 _amountIn) private returns (uint256[] memory _amounts) {

        address[] memory _path = _getPath(_tokenA, _tokenB);
        uint256[] memory _amountsOut = router.getAmountsOut(_amountIn, _path);
        if (_amountsOut[1] > 0) {
            _amounts = router.swapExactTokensForTokens(_amountIn, 0, _path, address(this), block.timestamp);
        } else {
            uint256[] memory _zeroReturn = new uint256[](2);
            _zeroReturn[0] = 0;
            _zeroReturn[1] = 0;
            return _zeroReturn;
        }
    }

    function withdraw(uint256 _amount) external onlyVault {

        if (!isVesting) {
            _updatePoolForPriceChange();
            uint256 _totalPool = _getTotalPool();
            uint256 _WETHAmtBefore = WETH.balanceOf(address(this));

            _withdrawCurve(_poolHBTCWBTC.mul(_amount).div(_totalPool));
            _withdrawPickleWBTC(_poolWBTCETH.mul(_amount).div(_totalPool));
            _withdrawSushiswap(_poolDPIETH.mul(_amount).div(_totalPool));
            _withdrawPickleDAI(_poolDAIETH.mul(_amount).div(_totalPool));

            _swapAllToETH(); // Swap WBTC, DPI & DAI that get from withdrawal above to WETH
            WETH.safeTransfer(msg.sender, (WETH.balanceOf(address(this))).sub(_WETHAmtBefore));
        } else {
            _pool = _pool.sub(_amount);
            WETH.safeTransfer(msg.sender, _amount);
        }
    }

    function _withdrawCurve(uint256 _amount) private {

        uint256 _totalClpToken = gaugeC.balanceOf(address(this));
        uint256 _clpTokenShare = _totalClpToken.mul(_amount).div(_poolHBTCWBTC);
        gaugeC.withdraw(_clpTokenShare);
        cPairs.remove_liquidity_one_coin(_clpTokenShare, 1, 0);
        _poolHBTCWBTC = _poolHBTCWBTC.sub(_amount);
    }

    function _withdrawPickleWBTC(uint256 _amount) private {

        uint256 _totalPlpToken = gaugeP_WBTC.balanceOf(address(this));
        uint256 _plpTokenShare = _totalPlpToken.mul(_amount).div(_poolWBTCETH);
        gaugeP_WBTC.withdraw(_plpTokenShare);
        pickleJarWBTC.withdraw(_plpTokenShare);
        router.removeLiquidity(address(WBTC), address(WETH), slpWBTC.balanceOf(address(this)), 0, 0, address(this), block.timestamp);
        _poolWBTCETH = _poolWBTCETH.sub(_amount);
    }

    function _withdrawSushiswap(uint256 _amount) private {

        (uint256 _totalSlpToken,) = masterChef.userInfo(42, address(this));
        uint256 _slpTokenShare = _totalSlpToken.mul(_amount).div(_poolDPIETH);
        masterChef.withdraw(42, _slpTokenShare);
        router.removeLiquidity(address(DPI), address(WETH), _slpTokenShare, 0, 0, address(this), block.timestamp);
        _poolDPIETH = _poolDPIETH.sub(_amount);
    }

    function _withdrawPickleDAI(uint256 _amount) private {

        uint256 _totalPlpToken = gaugeP_DAI.balanceOf(address(this));
        uint256 _plpTokenShare = _totalPlpToken.mul(_amount).div(_poolDAIETH);
        gaugeP_DAI.withdraw(_plpTokenShare);
        pickleJarDAI.withdraw(_plpTokenShare);
        router.removeLiquidity(address(DAI), address(WETH), slpDAI.balanceOf(address(this)), 0, 0, address(this), block.timestamp);
        _poolDAIETH = _poolDAIETH.sub(_amount);
    }

    function _swapAllToETH() private {

        _swapExactTokensForTokens(address(WBTC), address(WETH), WBTC.balanceOf(address(this)));
        _swapExactTokensForTokens(address(DPI), address(WETH), DPI.balanceOf(address(this)));
        _swapExactTokensForTokens(address(DAI), address(WETH), DAI.balanceOf(address(this)));
    }

    function setAdmin(address _admin) external onlyVault {

        admin = _admin;
    }

    function setStrategist(address _strategist) external onlyVault {

        strategist = _strategist;
    }

    function approveMigrate() external onlyOwner {

        require(isVesting, "Not in vesting state");

        if (WETH.allowance(address(this), address(vault)) == 0) {
            WETH.safeApprove(address(vault), type(uint256).max);
        }
    }

    function _getPath(address _tokenA, address _tokenB) private pure returns (address[] memory) {

        address[] memory _path = new address[](2);
        _path[0] = _tokenA;
        _path[1] = _tokenB;
        return _path;
    }

    function _getLPTokenPrice() private view returns (uint256, uint256, uint256, uint256) {

        uint256 _wbtcPrice = (router.getAmountsOut(1e8, _getPath(address(WBTC), address(WETH))))[1];
        uint256 _dpiPrice = _getTokenPriceFromChainlink(0x029849bbc0b1d93b85a8b6190e979fd38F5760E2); // DPI/ETH
        uint256 _daiPrice = _getTokenPriceFromChainlink(0x773616E4d11A78F511299002da57A0a94577F1f4); // DAI/ETH

        uint256 _amountACurve = cPairs.balances(0); // HBTC, 18 decimals
        uint256 _amountBCurve = (cPairs.balances(1)).mul(1e10); // WBTC, 8 decimals to 18 decimals
        uint256 _totalValueOfHBTCWBTC = _calcTotalValueOfLiquidityPool(_amountACurve, _wbtcPrice, _amountBCurve, _wbtcPrice);
        uint256 _clpTokenPriceHBTC = _calcValueOf1LPToken(_totalValueOfHBTCWBTC, clpToken.totalSupply());
        uint256 _pSlpTokenPriceWBTC = _calcPslpTokenPrice(pickleJarWBTC, slpWBTC, _wbtcPrice);
        uint256 _slpTokenPriceDPI = _calcSlpTokenPrice(slpDPI, _dpiPrice);
        uint256 _pSlpTokenPriceDAI = _calcPslpTokenPrice(pickleJarDAI, slpDAI, _daiPrice);

        return (_clpTokenPriceHBTC, _pSlpTokenPriceWBTC, _slpTokenPriceDPI, _pSlpTokenPriceDAI);
    }

    function _calcPslpTokenPrice(IPickleJar _pslpToken, ISLPToken _slpToken, uint256 _tokenAPrice) private view returns (uint256) {

        uint256 _slpTokenPrice = _calcSlpTokenPrice(_slpToken, _tokenAPrice);
        uint256 _totalValueOfPSlpToken = _calcTotalValueOfLiquidityPool(_pslpToken.balance(), _slpTokenPrice, 0, 0);
        return _calcValueOf1LPToken(_totalValueOfPSlpToken, _pslpToken.totalSupply());
    }

    function _calcSlpTokenPrice(ISLPToken _slpToken, uint256 _tokenAPrice) private view returns (uint256) {

        (uint112 _reserveA, uint112 _reserveB,) = _slpToken.getReserves();
        if (_slpToken == slpWBTC) { // Change WBTC to 18 decimals
            _reserveA * 1e10;
        }
        uint256 _totalValueOfLiquidityPool = _calcTotalValueOfLiquidityPool(uint256(_reserveA), _tokenAPrice, uint256(_reserveB), 1e18);
        return _calcValueOf1LPToken(_totalValueOfLiquidityPool, _slpToken.totalSupply());
    }

    function _calcTotalValueOfLiquidityPool(uint256 _amountA, uint256 _priceA, uint256 _amountB, uint256 _priceB) private pure returns (uint256) {

        return (_amountA.mul(_priceA)).add(_amountB.mul(_priceB));
    }

    function _calcValueOf1LPToken(uint256 _totalValueOfLiquidityPool, uint256 _circulatingSupplyOfLPTokens) private pure returns (uint256) {

        return _totalValueOfLiquidityPool.div(_circulatingSupplyOfLPTokens);
    }

    function _getTokenPriceFromChainlink(address _priceFeedProxy) private view returns (uint256) {

        IChainlink _pricefeed = IChainlink(_priceFeedProxy);
        int256 _price = _pricefeed.latestAnswer();
        return uint256(_price);
    }

    function getCurrentPool() public view returns (uint256) {

        if (!isVesting) {
            (uint256 _clpTokenPriceHBTC, uint256 _pSlpTokenPriceWBTC, uint256 _slpTokenPriceDPI, uint256 _pSlpTokenPriceDAI) = _getLPTokenPrice();
            uint256 poolHBTCWBTC = _poolHBTCWBTC.mul(_clpTokenPriceHBTC).div(_HBTCWBTCLPTokenPrice);
            uint256 poolWBTCETH = _poolWBTCETH.mul(_pSlpTokenPriceWBTC).div(_WBTCETHLPTokenPrice);
            uint256 poolDPIETH = _poolDPIETH.mul(_slpTokenPriceDPI).div(_DPIETHLPTokenPrice);
            uint256 poolDAIETH = _poolDAIETH.mul(_pSlpTokenPriceDAI).div(_DAIETHLPTokenPrice);
            return poolHBTCWBTC.add(poolWBTCETH).add(poolDPIETH).add(poolDAIETH);
        } else {
            return _pool;
        }
    }

    function _getTotalPool() private view returns (uint256) {

        if (!isVesting) {
            return _poolHBTCWBTC.add(_poolWBTCETH).add(_poolDPIETH).add(_poolDAIETH);
        } else {
            return _pool;
        }
    }
}