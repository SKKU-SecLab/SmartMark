
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
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity 0.8.3;


contract Governed is Context, Initializable {

    address public governor;
    address private proposedGovernor;

    event UpdatedGovernor(address indexed previousGovernor, address indexed proposedGovernor);

    constructor() {
        address msgSender = _msgSender();
        governor = msgSender;
        emit UpdatedGovernor(address(0), msgSender);
    }

    function _initializeGoverned() internal initializer {

        address msgSender = _msgSender();
        governor = msgSender;
        emit UpdatedGovernor(address(0), msgSender);
    }

    modifier onlyGovernor {

        require(governor == _msgSender(), "not-the-governor");
        _;
    }

    function transferGovernorship(address _proposedGovernor) external onlyGovernor {

        require(_proposedGovernor != address(0), "proposed-governor-is-zero");
        proposedGovernor = _proposedGovernor;
    }

    function acceptGovernorship() external {

        require(proposedGovernor == _msgSender(), "not-the-proposed-governor");
        emit UpdatedGovernor(governor, proposedGovernor);
        governor = proposedGovernor;
        proposedGovernor = address(0);
    }
}// MIT

pragma solidity 0.8.3;

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

}// MIT

pragma solidity 0.8.3;

interface ICollateralManager {

    function addGemJoin(address[] calldata _gemJoins) external;


    function borrow(uint256 _amount) external;


    function createVault(bytes32 _collateralType) external returns (uint256 _vaultNum);


    function depositCollateral(uint256 _amount) external;


    function payback(uint256 _amount) external;


    function transferVaultOwnership(address _newOwner) external;


    function withdrawCollateral(uint256 _amount) external;


    function getVaultBalance(address _vaultOwner) external view returns (uint256 collateralLocked);


    function getVaultDebt(address _vaultOwner) external view returns (uint256 daiDebt);


    function getVaultInfo(address _vaultOwner)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );


    function mcdManager() external view returns (address);


    function vaultNum(address _vaultOwner) external view returns (uint256 _vaultNum);


    function whatWouldWithdrawDo(address _vaultOwner, uint256 _amount)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );

}// MIT

pragma solidity 0.8.3;


contract DSMath {

    uint256 internal constant RAY = 10**27;
    uint256 internal constant WAD = 10**18;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = ((x * y) + (WAD / 2)) / WAD;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = ((x * WAD) + (y / 2)) / y;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = ((x * y) + (RAY / 2)) / RAY;
    }

    function toRad(uint256 wad) internal pure returns (uint256 rad) {

        rad = wad * RAY;
    }

    function convertTo18(uint256 _dec, uint256 _amt) internal pure returns (uint256 amt) {

        amt = _amt * 10**(18 - _dec);
    }
}

contract CollateralManager is ICollateralManager, DSMath, ReentrancyGuard, Governed {

    using SafeERC20 for IERC20;

    mapping(uint256 => bytes32) public collateralType;
    mapping(address => uint256) public override vaultNum;
    mapping(bytes32 => address) public mcdGemJoin;

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public override mcdManager = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address public mcdDaiJoin = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address public mcdSpot = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;
    address public mcdJug = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address public treasury;
    uint256 internal constant MAX_UINT_VALUE = type(uint256).max;

    event AddedGemJoin(address indexed gemJoin, bytes32 ilk);
    event CreatedVault(address indexed owner, uint256 indexed vaultNum, bytes32 indexed collateralType);
    event TransferredVaultOwnership(uint256 indexed vaultNum, address indexed previousOwner, address indexed newOwner);
    event UpdatedMCDAddresses(address mcdManager, address mcdDaiJoin, address mcdSpot, address mcdJug);
    event UpdatedTreasury(address indexed previousTreasury, address indexed newTreasury);

    modifier onlyVaultOwner() {

        require(vaultNum[msg.sender] != 0, "caller-doesn't-own-any-vault");
        _;
    }

    function addGemJoin(address[] calldata _gemJoins) external override onlyGovernor {

        require(_gemJoins.length != 0, "no-gemJoin-address");
        for (uint256 i; i < _gemJoins.length; i++) {
            address gemJoin = _gemJoins[i];
            bytes32 ilk = GemJoinLike(gemJoin).ilk();
            mcdGemJoin[ilk] = gemJoin;
            emit AddedGemJoin(gemJoin, ilk);
        }
    }

    function createVault(bytes32 _collateralType) external override returns (uint256 _vaultNum) {

        require(vaultNum[msg.sender] == 0, "caller-owns-another-vault");
        ManagerLike manager = ManagerLike(mcdManager);
        _vaultNum = manager.open(_collateralType, address(this));
        manager.cdpAllow(_vaultNum, address(this), 1);

        vaultNum[msg.sender] = _vaultNum;
        collateralType[_vaultNum] = _collateralType;
        emit CreatedVault(msg.sender, _vaultNum, _collateralType);
    }

    function transferVaultOwnership(address _newOwner) external override onlyVaultOwner {

        _transferVaultOwnership(vaultNum[msg.sender], msg.sender, _newOwner);
    }

    function transferVaultOwnership(
        uint256 _vaultNum,
        address _owner,
        address _newOwner
    ) external onlyGovernor {

        require(_vaultNum != 0, "vault-number-is-zero");
        require(_owner != address(0), "owner-address-zero");
        _transferVaultOwnership(_vaultNum, _owner, _newOwner);
    }

    function updateMCDAddresses(
        address _mcdManager,
        address _mcdDaiJoin,
        address _mcdSpot,
        address _mcdJug
    ) external onlyGovernor {

        require(_mcdManager != address(0), "mcdManager-address-is-zero");
        require(_mcdDaiJoin != address(0), "mcdDaiJoin-address-is-zero");
        require(_mcdSpot != address(0), "mcdSpot-address-is-zero");
        require(_mcdJug != address(0), "mcdJug-address-is-zero");
        mcdManager = _mcdManager;
        mcdDaiJoin = _mcdDaiJoin;
        mcdSpot = _mcdSpot;
        mcdJug = _mcdJug;
        emit UpdatedMCDAddresses(_mcdManager, _mcdDaiJoin, _mcdSpot, _mcdJug);
    }

    function updateTreasury(address _treasury) external onlyGovernor {

        require(_treasury != address(0), "treasury-address-is-zero");
        emit UpdatedTreasury(treasury, _treasury);
        treasury = _treasury;
    }

    function depositCollateral(uint256 _amount) external override nonReentrant onlyVaultOwner {

        uint256 _vaultNum = vaultNum[msg.sender];
        _amount = _joinGem(mcdGemJoin[collateralType[_vaultNum]], _amount);

        ManagerLike manager = ManagerLike(mcdManager);
        VatLike(manager.vat()).frob(
            collateralType[_vaultNum],
            manager.urns(_vaultNum),
            address(this),
            address(this),
            int256(_amount),
            0
        );
    }

    function withdrawCollateral(uint256 _amount) external override nonReentrant onlyVaultOwner {

        uint256 _vaultNum = vaultNum[msg.sender];
        ManagerLike manager = ManagerLike(mcdManager);
        GemJoinLike gemJoin = GemJoinLike(mcdGemJoin[collateralType[_vaultNum]]);
        uint256 amount18 = convertTo18(gemJoin.dec(), _amount);
        manager.frob(_vaultNum, -int256(amount18), 0);
        manager.flux(_vaultNum, address(this), amount18);
        gemJoin.exit(address(this), _amount);
        IERC20(gemJoin.gem()).safeTransfer(msg.sender, _amount);
    }

    function payback(uint256 _amount) external override onlyVaultOwner {

        uint256 _vaultNum = vaultNum[msg.sender];
        ManagerLike manager = ManagerLike(mcdManager);
        address urn = manager.urns(_vaultNum);
        address vat = manager.vat();
        bytes32 ilk = collateralType[_vaultNum];
        uint256 _daiDebt = _getVaultDebt(ilk, urn, vat);
        require(_daiDebt >= _amount, "paying-excess-debt");
        _joinDai(urn, _amount);
        manager.frob(_vaultNum, 0, _getWipeAmount(ilk, urn, vat));
    }

    function borrow(uint256 _amount) external override onlyVaultOwner {

        uint256 _vaultNum = vaultNum[msg.sender];
        ManagerLike manager = ManagerLike(mcdManager);
        address vat = manager.vat();
        uint256 _maxAmount = _maxAvailableDai(vat, collateralType[_vaultNum]);
        if (_amount > _maxAmount) {
            _amount = _maxAmount;
        }

        manager.frob(_vaultNum, 0, _getBorrowAmount(vat, manager.urns(_vaultNum), _vaultNum, _amount));
        manager.move(_vaultNum, address(this), toRad(_amount));
        if (VatLike(vat).can(address(this), mcdDaiJoin) == 0) {
            VatLike(vat).hope(mcdDaiJoin);
        }
        DaiJoinLike(mcdDaiJoin).exit(msg.sender, _amount);
    }

    function sweepErc20(address _fromToken) external {

        require(treasury != address(0), "treasury-not-set");
        uint256 amount = IERC20(_fromToken).balanceOf(address(this));
        IERC20(_fromToken).safeTransfer(treasury, amount);
    }

    function getVaultDebt(address _vaultOwner) external view override returns (uint256 daiDebt) {

        uint256 _vaultNum = vaultNum[_vaultOwner];
        require(_vaultNum != 0, "invalid-vault-number");
        address _urn = ManagerLike(mcdManager).urns(_vaultNum);
        address _vat = ManagerLike(mcdManager).vat();
        bytes32 _ilk = collateralType[_vaultNum];
        daiDebt = _getVaultDebt(_ilk, _urn, _vat);
    }

    function getVaultBalance(address _vaultOwner) external view override returns (uint256 collateralLocked) {

        uint256 _vaultNum = vaultNum[_vaultOwner];
        require(_vaultNum != 0, "invalid-vault-number");
        address _vat = ManagerLike(mcdManager).vat();
        address _urn = ManagerLike(mcdManager).urns(_vaultNum);
        (collateralLocked, ) = VatLike(_vat).urns(collateralType[_vaultNum], _urn);
    }

    function whatWouldWithdrawDo(address _vaultOwner, uint256 _amount)
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

        uint256 _vaultNum = vaultNum[_vaultOwner];
        require(_vaultNum != 0, "invalid-vault-number");
        (collateralLocked, daiDebt, collateralUsdRate, collateralRatio, minimumDebt) = getVaultInfo(_vaultOwner);

        GemJoinLike _gemJoin = GemJoinLike(mcdGemJoin[collateralType[_vaultNum]]);
        uint256 _amount18 = convertTo18(_gemJoin.dec(), _amount);
        require(_amount18 <= collateralLocked, "insufficient-collateral-locked");
        collateralLocked = collateralLocked - _amount18;
        collateralRatio = _getCollateralRatio(collateralLocked, collateralUsdRate, daiDebt);
    }

    function getVaultInfo(address _vaultOwner)
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

        uint256 _vaultNum = vaultNum[_vaultOwner];
        require(_vaultNum != 0, "invalid-vault-number");
        (collateralLocked, collateralUsdRate, daiDebt, minimumDebt) = _getVaultInfo(_vaultNum);
        collateralRatio = _getCollateralRatio(collateralLocked, collateralUsdRate, daiDebt);
    }

    function maxAvailableDai(bytes32 _collateralType) public view returns (uint256) {

        return _maxAvailableDai(ManagerLike(mcdManager).vat(), _collateralType);
    }

    function _maxAvailableDai(address _vat, bytes32 _collateralType) internal view returns (uint256) {

        (uint256 Art, uint256 rate, , uint256 line, ) = VatLike(_vat).ilks(_collateralType);
        uint256 _totalAvailableDai = (line - (Art * rate)) / RAY;
        return (_totalAvailableDai * 99) / 100;
    }

    function _joinDai(address _urn, uint256 _amount) internal {

        DaiJoinLike _daiJoin = DaiJoinLike(mcdDaiJoin);
        IERC20(DAI).safeTransferFrom(msg.sender, address(this), _amount);
        IERC20(DAI).safeApprove(mcdDaiJoin, 0);
        IERC20(DAI).safeApprove(mcdDaiJoin, _amount);
        _daiJoin.join(_urn, _amount);
    }

    function _joinGem(address _adapter, uint256 _amount) internal returns (uint256) {

        GemJoinLike gemJoin = GemJoinLike(_adapter);

        IERC20 token = IERC20(gemJoin.gem());
        token.safeTransferFrom(msg.sender, address(this), _amount);
        token.safeApprove(_adapter, 0);
        token.safeApprove(_adapter, _amount);
        gemJoin.join(address(this), _amount);
        return convertTo18(gemJoin.dec(), _amount);
    }

    function _getBorrowAmount(
        address _vat,
        address _urn,
        uint256 _vaultNum,
        uint256 _wad
    ) internal returns (int256 amount) {

        uint256 rate = JugLike(mcdJug).drip(collateralType[_vaultNum]);
        uint256 dai = VatLike(_vat).dai(_urn);
        if (dai < _wad * RAY) {
            amount = int256(((_wad * RAY) - dai) / rate);
            amount = (uint256(amount) * rate) < (_wad * RAY) ? amount + 1 : amount;
        }
    }

    function _transferVaultOwnership(
        uint256 _vaultNum,
        address _owner,
        address _newOwner
    ) internal {

        require(_newOwner != address(0), "new-owner-address-is-zero");
        require(vaultNum[_owner] == _vaultNum, "invalid-vault-num");
        require(vaultNum[_newOwner] == 0, "new-owner-owns-another-vault");

        vaultNum[_newOwner] = _vaultNum;
        vaultNum[_owner] = 0;
        emit TransferredVaultOwnership(_vaultNum, _owner, _newOwner);
    }

    function _getVaultDebt(
        bytes32 _ilk,
        address _urn,
        address _vat
    ) internal view returns (uint256 wad) {

        (, uint256 art) = VatLike(_vat).urns(_ilk, _urn);
        (, uint256 rate, , , ) = VatLike(_vat).ilks(_ilk);
        uint256 dai = VatLike(_vat).dai(_urn);
        wad = _getVaultDebt(art, rate, dai);
    }

    function _getVaultInfo(uint256 _vaultNum)
        internal
        view
        returns (
            uint256 collateralLocked,
            uint256 collateralUsdRate,
            uint256 daiDebt,
            uint256 minimumDebt
        )
    {

        address _urn = ManagerLike(mcdManager).urns(_vaultNum);
        address _vat = ManagerLike(mcdManager).vat();
        bytes32 _ilk = collateralType[_vaultNum];
        (, uint256 mat) = SpotterLike(mcdSpot).ilks(_ilk);
        (uint256 ink, uint256 art) = VatLike(_vat).urns(_ilk, _urn);
        (, uint256 rate, uint256 spot, , uint256 dust) = VatLike(_vat).ilks(_ilk);

        collateralLocked = ink;
        daiDebt = _getVaultDebt(art, rate, VatLike(_vat).dai(_urn));
        minimumDebt = dust / RAY;
        collateralUsdRate = rmul(mat, spot) / 10**9;
    }

    function _getWipeAmount(
        bytes32 _ilk,
        address _urn,
        address _vat
    ) internal view returns (int256 amount) {

        (, uint256 _art) = VatLike(_vat).urns(_ilk, _urn);
        (, uint256 _rate, , , ) = VatLike(_vat).ilks(_ilk);
        uint256 _dai = VatLike(_vat).dai(_urn);

        amount = int256(_dai / _rate);
        amount = uint256(amount) <= _art ? -amount : -int256(_art);
    }

    function _getCollateralRatio(
        uint256 _collateralLocked,
        uint256 _collateralRate,
        uint256 _daiDebt
    ) internal pure returns (uint256) {

        if (_collateralLocked == 0) {
            return 0;
        }

        if (_daiDebt == 0) {
            return MAX_UINT_VALUE;
        }

        require(_collateralRate != 0, "collateral-rate-is-zero");
        return wdiv(wmul(_collateralLocked, _collateralRate), _daiDebt);
    }

    function _getVaultDebt(
        uint256 _art,
        uint256 _rate,
        uint256 _dai
    ) internal pure returns (uint256 wad) {

        if (_dai < (_art * _rate)) {
            uint256 rad = ((_art * _rate) - _dai);
            wad = rad / RAY;
            wad = (wad * RAY) < rad ? wad + 1 : wad;
        } else {
            wad = 0;
        }
    }
}