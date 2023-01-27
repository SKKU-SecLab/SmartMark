
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


interface ISushiSwap {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts);


    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint[] memory amounts);

}

interface IChainlink {

    function latestAnswer() external view returns (int256);

}

contract CubanApeStrategy is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 private constant _WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // 18 decimals
    ISushiSwap private constant _sSwap = ISushiSwap(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    IERC20 private constant _renDOGE = IERC20(0x3832d2F059E55934220881F831bE501D180671A7); // 8 decimals
    IERC20 private constant _MATIC = IERC20(0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0); // 18 decimals
    IERC20 private constant _AAVE = IERC20(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9); // 18 decimals
    IERC20 private constant _SUSHI = IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2); // 18 decimals
    IERC20 private constant _AXS = IERC20(0xBB0E17EF65F82Ab018d8EDd776e8DD940327B28b); // 18 decimals
    IERC20 private constant _INJ = IERC20(0xe28b3B32B6c345A34Ff64674606124Dd5Aceca30); // 18 decimals
    IERC20 private constant _ALCX = IERC20(0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF); // 18 decimals

    address public vault;
    uint256[] public weights; // [renDOGE, MATIC, AAVE, SUSHI, AXS, INJ, ALCX]
    uint256 private constant DENOMINATOR = 10000;
    bool public isVesting;

    event AmtToInvest(uint256 _amount); // In ETH
    event CurrentComposition(uint256, uint256, uint256, uint256, uint256, uint256, uint256);
    event TargetComposition(uint256, uint256, uint256, uint256, uint256, uint256, uint256);

    modifier onlyVault {

        require(msg.sender == vault, "Only vault");
        _;
    }

    constructor(uint256[] memory _weights) {
        weights = _weights;

        _WETH.safeApprove(address(_sSwap), type(uint256).max);
        _renDOGE.safeApprove(address(_sSwap), type(uint256).max);
        _MATIC.safeApprove(address(_sSwap), type(uint256).max);
        _AAVE.safeApprove(address(_sSwap), type(uint256).max);
        _SUSHI.safeApprove(address(_sSwap), type(uint256).max);
        _AXS.safeApprove(address(_sSwap), type(uint256).max);
        _INJ.safeApprove(address(_sSwap), type(uint256).max);
        _ALCX.safeApprove(address(_sSwap), type(uint256).max);
    }

    function setVault(address _vault) external onlyOwner {

        require(vault == address(0), "Vault set");
        vault = _vault;
    }

    function invest(uint256 _amount) external onlyVault {

        _WETH.safeTransferFrom(address(vault), address(this), _amount);
        emit AmtToInvest(_amount);

        uint256[] memory _pools = getFarmsPool();
        uint256 _totalPool = _amount.add(_getTotalPool());
        uint256[] memory _poolsTarget = new uint256[](7);
        for (uint256 _i=0 ; _i<7 ; _i++) {
            _poolsTarget[_i] = _totalPool.mul(weights[_i]).div(DENOMINATOR);
        }
        emit CurrentComposition(_pools[0], _pools[1], _pools[2], _pools[3], _pools[4], _pools[5], _pools[6]);
        emit TargetComposition(_poolsTarget[0], _poolsTarget[1], _poolsTarget[2], _poolsTarget[3], _poolsTarget[4], _poolsTarget[5], _poolsTarget[6]);
        if (
            _poolsTarget[0] > _pools[0] &&
            _poolsTarget[1] > _pools[1] &&
            _poolsTarget[2] > _pools[2] &&
            _poolsTarget[3] > _pools[3] &&
            _poolsTarget[4] > _pools[4] &&
            _poolsTarget[5] > _pools[5] &&
            _poolsTarget[6] > _pools[6]
        ) {
            _invest(_poolsTarget[0].sub(_pools[0]), _renDOGE);
            _invest(_poolsTarget[1].sub(_pools[1]), _MATIC);
            _invest(_poolsTarget[2].sub(_pools[2]), _AAVE);
            _invest(_poolsTarget[3].sub(_pools[3]), _SUSHI);
            _invest(_poolsTarget[4].sub(_pools[4]), _AXS);
            _invest(_poolsTarget[5].sub(_pools[5]), _INJ);
            _invest(_poolsTarget[6].sub(_pools[6]), _ALCX);
        } else {
            uint256 _furthest;
            uint256 _farmIndex;
            uint256 _diff;
            if (_poolsTarget[0] > _pools[0]) {
                _furthest = _poolsTarget[0].sub(_pools[0]);
                _farmIndex = 0;
            }
            if (_poolsTarget[1] > _pools[1]) {
                _diff = _poolsTarget[1].sub(_pools[1]);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 1;
                }
            }
            if (_poolsTarget[2] > _pools[2]) {
                _diff = _poolsTarget[2].sub(_pools[2]);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 2;
                }
            }
            if (_poolsTarget[3] > _pools[3]) {
                _diff = _poolsTarget[3].sub(_pools[3]);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 3;
                }
            }
            if (_poolsTarget[4] > _pools[4]) {
                _diff = _poolsTarget[4].sub(_pools[4]);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 4;
                }
            }
            if (_poolsTarget[5] > _pools[5]) {
                _diff = _poolsTarget[5].sub(_pools[5]);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 5;
                }
            }
            if (_poolsTarget[6] > _pools[6]) {
                _diff = _poolsTarget[6].sub(_pools[6]);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 6;
                }
            }
            if (_farmIndex == 0) {
                _invest(_amount, _renDOGE);
            } else if (_farmIndex == 1) {
                _invest(_amount, _MATIC);
            } else if (_farmIndex == 2) {
                _invest(_amount, _AAVE);
            } else if (_farmIndex == 3) {
                _invest(_amount, _SUSHI);
            } else if (_farmIndex == 4) {
                _invest(_amount, _AXS);
            } else if (_farmIndex == 5) {
                _invest(_amount, _INJ);
            } else {
                _invest(_amount, _ALCX);
            }
        }
    }

    function _invest(uint256 _amount, IERC20 _farm) private {

        _swapExactTokensForTokens(address(_WETH), address(_farm), _amount);
    }

    function withdraw(uint256 _amount) external onlyVault returns (uint256) {

        uint256 _withdrawAmt;
        if (!isVesting) {
            uint256 _totalPool = _getTotalPool();
            _swapExactTokensForTokens(address(_renDOGE), address(_WETH), (_renDOGE.balanceOf(address(this))).mul(_amount).div(_totalPool));
            _swapExactTokensForTokens(address(_MATIC), address(_WETH), (_MATIC.balanceOf(address(this))).mul(_amount).div(_totalPool));
            _swapExactTokensForTokens(address(_AAVE), address(_WETH), (_AAVE.balanceOf(address(this))).mul(_amount).div(_totalPool));
            _swapExactTokensForTokens(address(_SUSHI), address(_WETH), (_SUSHI.balanceOf(address(this))).mul(_amount).div(_totalPool));
            _swapExactTokensForTokens(address(_AXS), address(_WETH), (_AXS.balanceOf(address(this))).mul(_amount).div(_totalPool));
            _swapExactTokensForTokens(address(_INJ), address(_WETH), (_INJ.balanceOf(address(this))).mul(_amount).div(_totalPool));
            _swapExactTokensForTokens(address(_ALCX), address(_WETH), (_ALCX.balanceOf(address(this))).mul(_amount).div(_totalPool));
            _withdrawAmt = _WETH.balanceOf(address(this));
        } else {
            _withdrawAmt = _amount;
        }
        _WETH.safeTransfer(address(vault), _withdrawAmt);
        return _withdrawAmt;
    }

    function releaseETHToVault(uint256 _amount, uint256 _farmIndex) external onlyVault returns (uint256) {

        if (_farmIndex == 0) {
            _swapTokensForExactTokens(address(_renDOGE), address(_WETH), _amount);
        } else if (_farmIndex == 1) {
            _swapTokensForExactTokens(address(_MATIC), address(_WETH), _amount);
        } else if (_farmIndex == 2) {
            _swapTokensForExactTokens(address(_AAVE), address(_WETH), _amount);
        } else if (_farmIndex == 3) {
            _swapTokensForExactTokens(address(_SUSHI), address(_WETH), _amount);
        } else if (_farmIndex == 4) {
            _swapTokensForExactTokens(address(_AXS), address(_WETH), _amount);
        } else if (_farmIndex == 5) {
            _swapTokensForExactTokens(address(_INJ), address(_WETH), _amount);
        } else {
            _swapTokensForExactTokens(address(_ALCX), address(_WETH), _amount);
        }
        uint256 _WETHBalance = _WETH.balanceOf(address(this));
        _WETH.safeTransfer(address(vault), _WETHBalance);
        return _WETHBalance;
    }

    function emergencyWithdraw() external onlyVault {

        _swapExactTokensForTokens(address(_renDOGE), address(_WETH), _renDOGE.balanceOf(address(this)));
        _swapExactTokensForTokens(address(_MATIC), address(_WETH), _MATIC.balanceOf(address(this)));
        _swapExactTokensForTokens(address(_AAVE), address(_WETH), _AAVE.balanceOf(address(this)));
        _swapExactTokensForTokens(address(_SUSHI), address(_WETH), _SUSHI.balanceOf(address(this)));
        _swapExactTokensForTokens(address(_AXS), address(_WETH), _AXS.balanceOf(address(this)));
        _swapExactTokensForTokens(address(_INJ), address(_WETH), _INJ.balanceOf(address(this)));
        _swapExactTokensForTokens(address(_ALCX), address(_WETH), _ALCX.balanceOf(address(this)));

        isVesting = true;
    }

    function reinvest() external onlyVault {

        isVesting = false;

        uint256 _WETHBalance = _WETH.balanceOf(address(this));
        _invest(_WETHBalance.mul(weights[0]).div(DENOMINATOR), _renDOGE);
        _invest(_WETHBalance.mul(weights[1]).div(DENOMINATOR), _MATIC);
        _invest(_WETHBalance.mul(weights[2]).div(DENOMINATOR), _AAVE);
        _invest(_WETHBalance.mul(weights[3]).div(DENOMINATOR), _SUSHI);
        _invest(_WETHBalance.mul(weights[4]).div(DENOMINATOR), _AXS);
        _invest(_WETHBalance.mul(weights[5]).div(DENOMINATOR), _INJ);
        _invest(_WETH.balanceOf(address(this)), _ALCX);
    }

    function approveMigrate() external onlyOwner {

        require(isVesting, "Not in vesting state");
        _WETH.safeApprove(address(vault), type(uint256).max);
    }

    function setWeights(uint256[] memory _weights) external onlyVault {

        weights = _weights;
    }

    function _swapExactTokensForTokens(address _tokenA, address _tokenB, uint256 _amountIn) private returns (uint256[] memory _amounts) {

        address[] memory _path = _getPath(_tokenA, _tokenB);
        uint256[] memory _amountsOut = _sSwap.getAmountsOut(_amountIn, _path);
        if (_amountsOut[1] > 0) {
            _amounts = _sSwap.swapExactTokensForTokens(_amountIn, 0, _path, address(this), block.timestamp);
        }
    }

    function _swapTokensForExactTokens(address _tokenA, address _tokenB, uint256 _amountOut) private returns (uint256[] memory _amounts) {

        address[] memory _path = _getPath(_tokenA, _tokenB);
        uint256[] memory _amountsOut = _sSwap.getAmountsIn(_amountOut, _path);
        if (_amountsOut[1] > 0) {
            _amounts = _sSwap.swapTokensForExactTokens(_amountOut, type(uint256).max, _path, address(this), block.timestamp);
        }
    }

    function _getPath(address _tokenA, address _tokenB) private pure returns (address[] memory) {

        address[] memory _path = new address[](2);
        _path[0] = _tokenA;
        _path[1] = _tokenB;
        return _path;
    }

    function getTotalPoolInUSD() public view returns (uint256) {

        IChainlink _pricefeed = IChainlink(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);  // ETH/USD
        return _getTotalPool().mul(uint256(_pricefeed.latestAnswer())).div(1e20);
    }

    function _getTotalPool() private view returns (uint256) {

        if (!isVesting) {
            uint256[] memory _pools = getFarmsPool();
            return _pools[0].add(_pools[1]).add(_pools[2]).add(_pools[3]).add(_pools[4]).add(_pools[5]).add(_pools[6]);
        } else {
            return _WETH.balanceOf(address(this));
        }
    }

    function getFarmsPool() public view returns (uint256[] memory) {

        uint256[] memory _pools = new uint256[](7);
        uint256[] memory _renDOGEPrice = _sSwap.getAmountsOut(1e8, _getPath(address(_renDOGE), address(_WETH)));
        _pools[0] = (_renDOGE.balanceOf(address(this))).mul(_renDOGEPrice[1]).div(1e8);
        uint256[] memory _MATICPrice = _sSwap.getAmountsOut(1e18, _getPath(address(_MATIC), address(_WETH)));
        _pools[1] = (_MATIC.balanceOf(address(this))).mul(_MATICPrice[1]).div(1e18);
        uint256[] memory _AAVEPrice = _sSwap.getAmountsOut(1e18, _getPath(address(_AAVE), address(_WETH)));
        _pools[2] = (_AAVE.balanceOf(address(this))).mul(_AAVEPrice[1]).div(1e18);
        uint256[] memory _SUSHIPrice = _sSwap.getAmountsOut(1e18, _getPath(address(_SUSHI), address(_WETH)));
        _pools[3] = (_SUSHI.balanceOf(address(this))).mul(_SUSHIPrice[1]).div(1e18);
        uint256[] memory _AXSPrice = _sSwap.getAmountsOut(1e18, _getPath(address(_AXS), address(_WETH)));
        _pools[4] = (_AXS.balanceOf(address(this))).mul(_AXSPrice[1]).div(1e18);
        uint256[] memory _INJPrice = _sSwap.getAmountsOut(1e18, _getPath(address(_INJ), address(_WETH)));
        _pools[5] = (_INJ.balanceOf(address(this))).mul(_INJPrice[1]).div(1e18);
        uint256[] memory _ALCXPrice = _sSwap.getAmountsOut(1e18, _getPath(address(_ALCX), address(_WETH)));
        _pools[6] = (_ALCX.balanceOf(address(this))).mul(_ALCXPrice[1]).div(1e18);

        return _pools;
    }
}