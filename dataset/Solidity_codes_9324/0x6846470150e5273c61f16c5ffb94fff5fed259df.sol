


pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity 0.6.12;

interface ManagerLike {

    function cdpCan(
        address,
        uint256,
        address
    ) external view returns (uint256);


    function ilks(uint256) external view returns (bytes32);


    function owns(uint256) external view returns (address);


    function urns(uint256) external view returns (address);


    function vat() external view returns (address);


    function open(bytes32, address) external returns (uint256);


    function give(uint256, address) external;


    function cdpAllow(
        uint256,
        address,
        uint256
    ) external;


    function urnAllow(address, uint256) external;


    function frob(
        uint256,
        int256,
        int256
    ) external;


    function flux(
        uint256,
        address,
        uint256
    ) external;


    function move(
        uint256,
        address,
        uint256
    ) external;


    function exit(
        address,
        uint256,
        address,
        uint256
    ) external;


    function quit(uint256, address) external;


    function enter(address, uint256) external;


    function shift(uint256, uint256) external;

}

interface VatLike {

    function can(address, address) external view returns (uint256);


    function ilks(bytes32)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );


    function dai(address) external view returns (uint256);


    function urns(bytes32, address) external view returns (uint256, uint256);


    function frob(
        bytes32,
        address,
        address,
        address,
        int256,
        int256
    ) external;


    function hope(address) external;


    function nope(address) external;


    function move(
        address,
        address,
        uint256
    ) external;

}

interface GemJoinLike {

    function dec() external view returns (uint256);


    function gem() external view returns (address);


    function ilk() external view returns (bytes32);


    function join(address, uint256) external payable;


    function exit(address, uint256) external;

}

interface DaiJoinLike {

    function vat() external returns (VatLike);


    function dai() external view returns (address);


    function join(address, uint256) external payable;


    function exit(address, uint256) external;

}

interface JugLike {

    function drip(bytes32) external returns (uint256);

}

interface SpotterLike {

    function ilks(bytes32) external view returns (address, uint256);

}




pragma solidity 0.6.12;

interface ICollateralManager {

    function addGemJoin(address[] calldata gemJoins) external;


    function mcdManager() external view returns (address);


    function borrow(uint256 vaultNum, uint256 amount) external;


    function depositCollateral(uint256 vaultNum, uint256 amount) external;


    function getVaultBalance(uint256 vaultNum) external view returns (uint256 collateralLocked);


    function getVaultDebt(uint256 vaultNum) external view returns (uint256 daiDebt);


    function getVaultInfo(uint256 vaultNum)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );


    function payback(uint256 vaultNum, uint256 amount) external;


    function registerVault(uint256 vaultNum, bytes32 collateralType) external;


    function vaultOwner(uint256 vaultNum) external returns (address owner);


    function whatWouldWithdrawDo(uint256 vaultNum, uint256 amount)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );


    function withdrawCollateral(uint256 vaultNum, uint256 amount) external;

}




pragma solidity 0.6.12;

interface IController {

    function aaveReferralCode() external view returns (uint16);


    function feeCollector(address) external view returns (address);


    function founderFee() external view returns (uint256);


    function founderVault() external view returns (address);


    function interestFee(address) external view returns (uint256);


    function isPool(address) external view returns (bool);


    function pools() external view returns (address);


    function strategy(address) external view returns (address);


    function rebalanceFriction(address) external view returns (uint256);


    function poolRewards(address) external view returns (address);


    function treasuryPool() external view returns (address);


    function uniswapRouter() external view returns (address);


    function withdrawFee(address) external view returns (uint256);

}




pragma solidity 0.6.12;







contract DSMath {

    uint256 internal constant RAY = 10**27;
    uint256 internal constant WAD = 10**18;

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "sub-overflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, WAD), y / 2) / y;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function toInt(uint256 x) internal pure returns (int256 y) {

        y = int256(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint256 wad) internal pure returns (uint256 rad) {

        rad = mul(wad, RAY);
    }

    function convertTo18(uint256 _dec, uint256 _amt) internal pure returns (uint256 amt) {

        amt = mul(_amt, 10**(18 - _dec));
    }
}

contract CollateralManager is ICollateralManager, DSMath, ReentrancyGuard {

    using SafeERC20 for IERC20;
    mapping(uint256 => address) public override vaultOwner;
    mapping(bytes32 => address) public mcdGemJoin;
    mapping(uint256 => bytes32) public vaultType;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public override mcdManager = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address public mcdDaiJoin = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address public mcdSpot = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;
    address public mcdJug = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    uint256 internal constant MAX_UINT_VALUE = uint256(-1);
    IController public immutable controller;

    modifier onlyVaultOwner(uint256 vaultNum) {

        require(msg.sender == vaultOwner[vaultNum], "Not a vault owner");
        _;
    }

    modifier onlyController() {

        require(msg.sender == address(controller), "Not a controller");
        _;
    }

    constructor(address _controller) public {
        require(_controller != address(0), "_controller is zero");
        controller = IController(_controller);
    }

    function addGemJoin(address[] calldata gemJoins) external override onlyController {

        require(gemJoins.length != 0, "No gemJoin address");
        for (uint256 i; i < gemJoins.length; i++) {
            address gemJoin = gemJoins[i];
            bytes32 ilk = GemJoinLike(gemJoin).ilk();
            mcdGemJoin[ilk] = gemJoin;
        }
    }

    function registerVault(uint256 vaultNum, bytes32 collateralType) external override {

        require(msg.sender == ManagerLike(mcdManager).owns(vaultNum), "Not a vault owner");
        vaultOwner[vaultNum] = msg.sender;
        vaultType[vaultNum] = collateralType;
    }

    function updateMCDAddresses(
        address _mcdManager,
        address _mcdDaiJoin,
        address _mcdSpot,
        address _mcdJug
    ) external onlyController {

        mcdManager = _mcdManager;
        mcdDaiJoin = _mcdDaiJoin;
        mcdSpot = _mcdSpot;
        mcdJug = _mcdJug;
    }

    function depositCollateral(uint256 vaultNum, uint256 amount)
        external
        override
        nonReentrant
        onlyVaultOwner(vaultNum)
    {

        amount = joinGem(mcdGemJoin[vaultType[vaultNum]], amount);

        ManagerLike manager = ManagerLike(mcdManager);
        VatLike(manager.vat()).frob(
            vaultType[vaultNum],
            manager.urns(vaultNum),
            address(this),
            address(this),
            toInt(amount),
            0
        );
    }

    function withdrawCollateral(uint256 vaultNum, uint256 amount)
        external
        override
        nonReentrant
        onlyVaultOwner(vaultNum)
    {

        ManagerLike manager = ManagerLike(mcdManager);
        GemJoinLike gemJoin = GemJoinLike(mcdGemJoin[vaultType[vaultNum]]);

        uint256 amount18 = convertTo18(gemJoin.dec(), amount);

        manager.frob(vaultNum, -toInt(amount18), 0);

        manager.flux(vaultNum, address(this), amount18);

        gemJoin.exit(address(this), amount);

        IERC20(gemJoin.gem()).safeTransfer(vaultOwner[vaultNum], amount);
    }

    function payback(uint256 vaultNum, uint256 amount) external override onlyVaultOwner(vaultNum) {

        ManagerLike manager = ManagerLike(mcdManager);
        address urn = manager.urns(vaultNum);
        address vat = manager.vat();
        bytes32 ilk = vaultType[vaultNum];

        uint256 _daiDebt = _getVaultDebt(ilk, urn, vat);
        require(_daiDebt >= amount, "paying-excess-debt");

        joinDai(urn, amount);
        manager.frob(vaultNum, 0, _getWipeAmount(ilk, urn, vat));
    }

    function borrow(uint256 vaultNum, uint256 amount) external override onlyVaultOwner(vaultNum) {

        ManagerLike manager = ManagerLike(mcdManager);
        address vat = manager.vat();
        uint256 _maxAmount = maxAvailableDai(vat, vaultNum);
        if (amount > _maxAmount) {
            amount = _maxAmount;
        }

        manager.frob(vaultNum, 0, _getBorrowAmount(vat, manager.urns(vaultNum), vaultNum, amount));
        manager.move(vaultNum, address(this), toRad(amount));
        if (VatLike(vat).can(address(this), mcdDaiJoin) == 0) {
            VatLike(vat).hope(mcdDaiJoin);
        }
        DaiJoinLike(mcdDaiJoin).exit(msg.sender, amount);
    }

    function sweepErc20(address fromToken) external {

        uint256 amount = IERC20(fromToken).balanceOf(address(this));
        address treasuryPool = controller.treasuryPool();
        IERC20(fromToken).safeTransfer(treasuryPool, amount);
    }

    function getVaultDebt(uint256 vaultNum) external view override returns (uint256 daiDebt) {

        address urn = ManagerLike(mcdManager).urns(vaultNum);
        address vat = ManagerLike(mcdManager).vat();
        bytes32 ilk = vaultType[vaultNum];

        daiDebt = _getVaultDebt(ilk, urn, vat);
    }

    function getVaultBalance(uint256 vaultNum)
        external
        view
        override
        returns (uint256 collateralLocked)
    {

        address vat = ManagerLike(mcdManager).vat();
        address urn = ManagerLike(mcdManager).urns(vaultNum);
        (collateralLocked, ) = VatLike(vat).urns(vaultType[vaultNum], urn);
    }

    function whatWouldWithdrawDo(uint256 vaultNum, uint256 amount)
        external
        view
        override
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        )
    {

        (collateralLocked, daiDebt, collateralUsdRate, collateralRatio, minimumDebt) = getVaultInfo(
            vaultNum
        );

        GemJoinLike gemJoin = GemJoinLike(mcdGemJoin[vaultType[vaultNum]]);
        uint256 amount18 = convertTo18(gemJoin.dec(), amount);
        require(amount18 <= collateralLocked, "insufficient collateral locked");
        collateralLocked = sub(collateralLocked, amount18);
        collateralRatio = getCollateralRatio(collateralLocked, collateralUsdRate, daiDebt);
    }

    function getVaultInfo(uint256 vaultNum)
        public
        view
        override
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        )
    {

        (collateralLocked, collateralUsdRate, daiDebt, minimumDebt) = _getVaultInfo(vaultNum);
        collateralRatio = getCollateralRatio(collateralLocked, collateralUsdRate, daiDebt);
    }

    function maxAvailableDai(address vat, uint256 vaultNum) public view returns (uint256) {

        (uint256 Art, uint256 rate, , uint256 line, ) = VatLike(vat).ilks(vaultType[vaultNum]);
        uint256 _totalAvailableDai = sub(line, mul(Art, rate)) / RAY;
        return mul(_totalAvailableDai, 99) / 100;
    }

    function joinDai(address urn, uint256 amount) internal {

        DaiJoinLike daiJoin = DaiJoinLike(mcdDaiJoin);
        IERC20(DAI).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(DAI).safeApprove(mcdDaiJoin, 0);
        IERC20(DAI).safeApprove(mcdDaiJoin, amount);
        daiJoin.join(urn, amount);
    }

    function joinGem(address adapter, uint256 amount) internal returns (uint256) {

        GemJoinLike gemJoin = GemJoinLike(adapter);

        IERC20 token = IERC20(gemJoin.gem());
        token.safeTransferFrom(msg.sender, address(this), amount);
        token.safeApprove(adapter, 0);
        token.safeApprove(adapter, amount);
        gemJoin.join(address(this), amount);
        return convertTo18(gemJoin.dec(), amount);
    }

    function _getBorrowAmount(
        address vat,
        address urn,
        uint256 vaultNum,
        uint256 wad
    ) internal returns (int256 amount) {

        uint256 rate = JugLike(mcdJug).drip(vaultType[vaultNum]);

        uint256 dai = VatLike(vat).dai(urn);

        if (dai < mul(wad, RAY)) {
            amount = toInt(sub(mul(wad, RAY), dai) / rate);
            amount = mul(uint256(amount), rate) < mul(wad, RAY) ? amount + 1 : amount;
        }
    }

    function getCollateralRatio(
        uint256 collateralLocked,
        uint256 collateralRate,
        uint256 daiDebt
    ) internal pure returns (uint256) {

        if (collateralLocked == 0) {
            return 0;
        }

        if (daiDebt == 0) {
            return MAX_UINT_VALUE;
        }

        require(collateralRate != 0, "Collateral rate is zero");
        return wdiv(wmul(collateralLocked, collateralRate), daiDebt);
    }

    function _getVaultDebt(
        bytes32 ilk,
        address urn,
        address vat
    ) internal view returns (uint256 wad) {

        (, uint256 art) = VatLike(vat).urns(ilk, urn);
        (, uint256 rate, , , ) = VatLike(vat).ilks(ilk);
        uint256 dai = VatLike(vat).dai(urn);

        wad = _getVaultDebt(art, rate, dai);
    }

    function _getVaultDebt(
        uint256 art,
        uint256 rate,
        uint256 dai
    ) internal pure returns (uint256 wad) {

        if (dai < mul(art, rate)) {
            uint256 rad = sub(mul(art, rate), dai);
            wad = rad / RAY;
            wad = mul(wad, RAY) < rad ? wad + 1 : wad;
        } else {
            wad = 0;
        }
    }

    function _getVaultInfo(uint256 vaultNum)
        internal
        view
        returns (
            uint256 collateralLocked,
            uint256 collateralUsdRate,
            uint256 daiDebt,
            uint256 minimumDebt
        )
    {

        address urn = ManagerLike(mcdManager).urns(vaultNum);
        address vat = ManagerLike(mcdManager).vat();
        bytes32 ilk = vaultType[vaultNum];

        (, uint256 mat) = SpotterLike(mcdSpot).ilks(ilk);

        (uint256 ink, uint256 art) = VatLike(vat).urns(ilk, urn);
        (, uint256 rate, uint256 spot, , uint256 dust) = VatLike(vat).ilks(ilk);

        collateralLocked = ink;
        daiDebt = _getVaultDebt(art, rate, VatLike(vat).dai(urn));
        minimumDebt = dust / RAY;
        collateralUsdRate = rmul(mat, spot) / 10**9;
    }

    function _getWipeAmount(
        bytes32 ilk,
        address urn,
        address vat
    ) internal view returns (int256 amount) {

        (, uint256 art) = VatLike(vat).urns(ilk, urn);
        (, uint256 rate, , , ) = VatLike(vat).ilks(ilk);
        uint256 dai = VatLike(vat).dai(urn);

        amount = toInt(dai / rate);
        amount = uint256(amount) <= art ? -amount : -toInt(art);
    }
}