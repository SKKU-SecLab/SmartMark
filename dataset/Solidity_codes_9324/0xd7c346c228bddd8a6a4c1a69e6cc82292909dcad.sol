
pragma solidity 0.5.16;


interface ISavingsContractV2 {


    function redeem(uint256 _amount) external returns (uint256 massetReturned);

    function creditBalances(address) external view returns (uint256); // V1 & V2 (use balanceOf)



    function depositInterest(uint256 _amount) external; // V1 & V2


    function depositSavings(uint256 _amount) external returns (uint256 creditsIssued); // V1 & V2

    function depositSavings(uint256 _amount, address _beneficiary) external returns (uint256 creditsIssued); // V2


    function redeemCredits(uint256 _amount) external returns (uint256 underlyingReturned); // V2

    function redeemUnderlying(uint256 _amount) external returns (uint256 creditsBurned); // V2


    function exchangeRate() external view returns (uint256); // V1 & V2


    function balanceOfUnderlying(address _user) external view returns (uint256 balance); // V2


    function underlyingToCredits(uint256 _credits) external view returns (uint256 underlying); // V2

    function creditsToUnderlying(uint256 _underlying) external view returns (uint256 credits); // V2


}

interface MassetStructs {


    struct Basket {

        Basset[] bassets;

        uint8 maxBassets;

        bool undergoingRecol;

        bool failed;
        uint256 collateralisationRatio;

    }

    struct Basset {

        address addr;

        BassetStatus status; // takes uint8 datatype (1 byte) in storage

        bool isTransferFeeCharged; // takes a byte in storage

        uint256 ratio;

        uint256 maxWeight;

        uint256 vaultBalance;

    }

    enum BassetStatus {
        Default,
        Normal,
        BrokenBelowPeg,
        BrokenAbovePeg,
        Blacklisted,
        Liquidating,
        Liquidated,
        Failed
    }

    struct BassetDetails {
        Basset bAsset;
        address integrator;
        uint8 index;
    }

    struct ForgePropsMulti {
        bool isValid; // Flag to signify that forge bAssets have passed validity check
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }
    struct RedeemProps {
        bool isValid;
        Basset[] allBassets;
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }

    struct RedeemPropsMulti {
        uint256 colRatio;
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }
}

contract IMasset is MassetStructs {


    function collectInterest() external returns (uint256 swapFeesGained, uint256 newTotalSupply);

    function collectPlatformInterest() external returns (uint256 interestGained, uint256 newTotalSupply);


    function mint(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetMinted);

    function mintTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);

    function mintMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);


    function swap( address _input, address _output, uint256 _quantity, address _recipient)
        external returns (uint256 output);

    function getSwapOutput( address _input, address _output, uint256 _quantity)
        external view returns (bool, string memory, uint256 output);


    function redeem(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetRedeemed);

    function redeemTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetRedeemed);

    function redeemMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantities, address _recipient)
        external returns (uint256 massetRedeemed);

    function redeemMasset(uint256 _mAssetQuantity, address _recipient) external;


    function upgradeForgeValidator(address _newForgeValidator) external;


    function setSwapFee(uint256 _swapFee) external;


    function getBasketManager() external view returns(address);

    function forgeValidator() external view returns (address);

    function totalSupply() external view returns (uint256);

    function swapFee() external view returns (uint256);

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IUniswapV2Router02 {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin, // calculated off chain
        address[] calldata path, // also worked out off chain
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}

interface ICurveMetaPool {

    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);

    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);

}

interface IBasicToken {

    function decimals() external view returns (uint8);

}

interface IBoostedSavingsVault {

    function stake(address _beneficiary, uint256 _amount) external;

}

contract SaveWrapper {


    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address save;
    address vault;
    address mAsset;

    IUniswapV2Router02 uniswap;
    ICurveMetaPool curve;

    constructor(
        address _save,
        address _vault,
        address _mAsset,
        address[] memory _bAssets,
        address _uniswapAddress,
        address _curveAddress,
        address[] memory _curveAssets
    ) public {
        require(_save != address(0), "Invalid save address");
        save = _save;
        require(_vault != address(0), "Invalid vault address");
        vault = _vault;
        require(_mAsset != address(0), "Invalid mAsset address");
        mAsset = _mAsset;
        require(_uniswapAddress != address(0), "Invalid uniswap address");
        uniswap = IUniswapV2Router02(_uniswapAddress);
        require(_curveAddress != address(0), "Invalid curve address");
        curve = ICurveMetaPool(_curveAddress);

        IERC20(_mAsset).safeApprove(save, uint256(-1));
        IERC20(_save).approve(_vault, uint256(-1));
        for(uint256 i = 0; i < _curveAssets.length; i++ ) {
            IERC20(_curveAssets[i]).safeApprove(address(curve), uint256(-1));
        }
        for(uint256 i = 0; i < _bAssets.length; i++ ) {
            IERC20(_bAssets[i]).safeApprove(_mAsset, uint256(-1));
        }
    }


    function saveAndStake(uint256 _amount) external {

        IERC20(mAsset).transferFrom(msg.sender, address(this), _amount);
        uint256 credits = ISavingsContractV2(save).depositSavings(_amount);
        IBoostedSavingsVault(vault).stake(msg.sender, credits);
    }

    function saveViaMint(address _bAsset, uint256 _amt, bool _stake) external {

        IERC20(_bAsset).transferFrom(msg.sender, address(this), _amt);
        IMasset mAsset_ = IMasset(mAsset);
        uint256 massetsMinted = mAsset_.mint(_bAsset, _amt);
        _saveAndStake(massetsMinted, _stake);
    }

    function saveViaCurve(
        address _input,
        int128 _curvePosition,
        uint256 _amountIn,
        uint256 _minOutCrv,
        bool _stake
    ) external {

        IERC20(_input).transferFrom(msg.sender, address(this), _amountIn);
        uint256 purchased = curve.exchange_underlying(_curvePosition, 0, _amountIn, _minOutCrv);
        _saveAndStake(purchased, _stake);
    }

    function estimate_saveViaCurve(
        int128 _curvePosition,
        uint256 _amountIn
    )
        external
        view
        returns (uint256 out)
    {

        return curve.get_dy(_curvePosition, 0, _amountIn);
    }

    function saveViaUniswapETH(
        uint256 _amountOutMin,
        address[] calldata _path,
        int128 _curvePosition,
        uint256 _minOutCrv,
        bool _stake
    ) external payable {

        uint[] memory amounts = uniswap.swapExactETHForTokens.value(msg.value)(
            _amountOutMin,
            _path,
            address(this),
            now + 1000
        );
        uint256 purchased = curve.exchange_underlying(_curvePosition, 0, amounts[amounts.length-1], _minOutCrv);
        _saveAndStake(purchased, _stake);
    }
    function estimate_saveViaUniswapETH(
        uint256 _ethAmount,
        address[] calldata _path,
        int128 _curvePosition
    )
        external
        view
        returns (uint256 out)
    {

        uint256 estimatedBasset = _getAmountOut(_ethAmount, _path);
        return curve.get_dy(_curvePosition, 0, estimatedBasset);
    }

    function _saveAndStake(
        uint256 _amount,
        bool _stake
    ) internal {

        if(_stake){
            uint256 credits = ISavingsContractV2(save).depositSavings(_amount, address(this));
            IBoostedSavingsVault(vault).stake(msg.sender, credits);
        } else {
            ISavingsContractV2(save).depositSavings(_amount, msg.sender);
        }
    }

    function _getAmountOut(uint256 _amountIn, address[] memory _path) internal view returns (uint256) {

        uint256[] memory amountsOut = uniswap.getAmountsOut(_amountIn, _path);
        return amountsOut[amountsOut.length - 1];
    }
}