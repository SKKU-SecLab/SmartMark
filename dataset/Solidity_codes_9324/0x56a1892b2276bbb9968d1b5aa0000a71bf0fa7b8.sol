
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

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
}// GPL-3.0


pragma solidity 0.6.12;

interface IIntegrationManager {
    enum SpendAssetsHandleType {None, Approve, Transfer, Remove}
}// GPL-3.0


pragma solidity 0.6.12;


interface IIntegrationAdapter {
    function identifier() external pure returns (string memory identifier_);

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
        external
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        );
}// GPL-3.0


pragma solidity 0.6.12;

abstract contract IntegrationSelectors {
    bytes4 public constant ADD_TRACKED_ASSETS_SELECTOR = bytes4(
        keccak256("addTrackedAssets(address,bytes,bytes)")
    );

    bytes4 public constant TAKE_ORDER_SELECTOR = bytes4(
        keccak256("takeOrder(address,bytes,bytes)")
    );

    bytes4 public constant LEND_SELECTOR = bytes4(keccak256("lend(address,bytes,bytes)"));
    bytes4 public constant REDEEM_SELECTOR = bytes4(keccak256("redeem(address,bytes,bytes)"));
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract AdapterBase is IIntegrationAdapter, IntegrationSelectors {
    using SafeERC20 for ERC20;

    address internal immutable INTEGRATION_MANAGER;

    modifier fundAssetsTransferHandler(
        address _vaultProxy,
        bytes memory _encodedAssetTransferArgs
    ) {
        (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType,
            address[] memory spendAssets,
            uint256[] memory spendAssetAmounts,
            address[] memory incomingAssets
        ) = __decodeEncodedAssetTransferArgs(_encodedAssetTransferArgs);

        if (spendAssetsHandleType == IIntegrationManager.SpendAssetsHandleType.Approve) {
            for (uint256 i = 0; i < spendAssets.length; i++) {
                ERC20(spendAssets[i]).safeTransferFrom(
                    _vaultProxy,
                    address(this),
                    spendAssetAmounts[i]
                );
            }
        }

        _;

        __transferContractAssetBalancesToFund(_vaultProxy, incomingAssets);
        __transferContractAssetBalancesToFund(_vaultProxy, spendAssets);
    }

    modifier onlyIntegrationManager {
        require(
            msg.sender == INTEGRATION_MANAGER,
            "Only the IntegrationManager can call this function"
        );
        _;
    }

    constructor(address _integrationManager) public {
        INTEGRATION_MANAGER = _integrationManager;
    }


    function __approveMaxAsNeeded(
        address _asset,
        address _target,
        uint256 _neededAmount
    ) internal {
        if (ERC20(_asset).allowance(address(this), _target) < _neededAmount) {
            ERC20(_asset).safeApprove(_target, type(uint256).max);
        }
    }

    function __decodeEncodedAssetTransferArgs(bytes memory _encodedAssetTransferArgs)
        internal
        pure
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_
        )
    {
        return
            abi.decode(
                _encodedAssetTransferArgs,
                (IIntegrationManager.SpendAssetsHandleType, address[], uint256[], address[])
            );
    }

    function __transferContractAssetBalancesToFund(address _vaultProxy, address[] memory _assets)
        private
    {
        for (uint256 i = 0; i < _assets.length; i++) {
            uint256 postCallAmount = ERC20(_assets[i]).balanceOf(address(this));
            if (postCallAmount > 0) {
                ERC20(_assets[i]).safeTransfer(_vaultProxy, postCallAmount);
            }
        }
    }


    function getIntegrationManager() external view returns (address integrationManager_) {
        return INTEGRATION_MANAGER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


interface IMockGenericIntegratee {
    function swap(
        address[] calldata,
        uint256[] calldata,
        address[] calldata,
        uint256[] calldata
    ) external payable;

    function swapOnBehalf(
        address payable,
        address[] calldata,
        uint256[] calldata,
        address[] calldata,
        uint256[] calldata
    ) external payable;
}

contract MockGenericAdapter is AdapterBase {
    address public immutable INTEGRATEE;

    constructor(address _integratee) public AdapterBase(address(0)) {
        INTEGRATEE = _integratee;
    }

    function identifier() external pure override returns (string memory) {
        return "MOCK_GENERIC";
    }

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _callArgs)
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory maxSpendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (
            spendAssets_,
            maxSpendAssetAmounts_,
            ,
            incomingAssets_,
            minIncomingAssetAmounts_,

        ) = __decodeCallArgs(_callArgs);

        return (
            __getSpendAssetsHandleTypeForSelector(_selector),
            spendAssets_,
            maxSpendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __getSpendAssetsHandleTypeForSelector(bytes4 _selector)
        private
        pure
        returns (IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_)
    {
        if (_selector == bytes4(keccak256("removeOnly(address,bytes,bytes)"))) {
            return IIntegrationManager.SpendAssetsHandleType.Remove;
        }
        if (_selector == bytes4(keccak256("swapDirectFromVault(address,bytes,bytes)"))) {
            return IIntegrationManager.SpendAssetsHandleType.None;
        }
        if (_selector == bytes4(keccak256("swapViaApproval(address,bytes,bytes)"))) {
            return IIntegrationManager.SpendAssetsHandleType.Approve;
        }
        return IIntegrationManager.SpendAssetsHandleType.Transfer;
    }

    function removeOnly(
        address,
        bytes calldata,
        bytes calldata
    ) external {}

    function swapA(
        address _vaultProxy,
        bytes calldata _callArgs,
        bytes calldata _assetTransferArgs
    ) external fundAssetsTransferHandler(_vaultProxy, _assetTransferArgs) {
        __decodeCallArgsAndSwap(_callArgs);
    }

    function swapB(
        address _vaultProxy,
        bytes calldata _callArgs,
        bytes calldata _assetTransferArgs
    ) external fundAssetsTransferHandler(_vaultProxy, _assetTransferArgs) {
        __decodeCallArgsAndSwap(_callArgs);
    }

    function swapDirectFromVault(
        address _vaultProxy,
        bytes calldata _callArgs,
        bytes calldata
    ) external {
        (
            address[] memory spendAssets,
            ,
            uint256[] memory actualSpendAssetAmounts,
            address[] memory incomingAssets,
            ,
            uint256[] memory actualIncomingAssetAmounts
        ) = __decodeCallArgs(_callArgs);

        IMockGenericIntegratee(INTEGRATEE).swapOnBehalf(
            payable(_vaultProxy),
            spendAssets,
            actualSpendAssetAmounts,
            incomingAssets,
            actualIncomingAssetAmounts
        );
    }

    function swapViaApproval(
        address _vaultProxy,
        bytes calldata _callArgs,
        bytes calldata _assetTransferArgs
    ) external fundAssetsTransferHandler(_vaultProxy, _assetTransferArgs) {
        __decodeCallArgsAndSwap(_callArgs);
    }

    function __decodeCallArgs(bytes memory _callArgs)
        internal
        pure
        returns (
            address[] memory spendAssets_,
            uint256[] memory maxSpendAssetAmounts_,
            uint256[] memory actualSpendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_,
            uint256[] memory actualIncomingAssetAmounts_
        )
    {
        return
            abi.decode(
                _callArgs,
                (address[], uint256[], uint256[], address[], uint256[], uint256[])
            );
    }

    function __decodeCallArgsAndSwap(bytes memory _callArgs) internal {
        (
            address[] memory spendAssets,
            ,
            uint256[] memory actualSpendAssetAmounts,
            address[] memory incomingAssets,
            ,
            uint256[] memory actualIncomingAssetAmounts
        ) = __decodeCallArgs(_callArgs);

        for (uint256 i; i < spendAssets.length; i++) {
            ERC20(spendAssets[i]).approve(INTEGRATEE, actualSpendAssetAmounts[i]);
        }
        IMockGenericIntegratee(INTEGRATEE).swap(
            spendAssets,
            actualSpendAssetAmounts,
            incomingAssets,
            actualIncomingAssetAmounts
        );
    }
}// GPL-3.0


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IZeroExV2 {
    struct Order {
        address makerAddress;
        address takerAddress;
        address feeRecipientAddress;
        address senderAddress;
        uint256 makerAssetAmount;
        uint256 takerAssetAmount;
        uint256 makerFee;
        uint256 takerFee;
        uint256 expirationTimeSeconds;
        uint256 salt;
        bytes makerAssetData;
        bytes takerAssetData;
    }

    struct OrderInfo {
        uint8 orderStatus;
        bytes32 orderHash;
        uint256 orderTakerAssetFilledAmount;
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;
        uint256 takerAssetFilledAmount;
        uint256 makerFeePaid;
        uint256 takerFeePaid;
    }

    function ZRX_ASSET_DATA() external view returns (bytes memory);

    function filled(bytes32) external view returns (uint256);

    function cancelled(bytes32) external view returns (bool);

    function getOrderInfo(Order calldata) external view returns (OrderInfo memory);

    function getAssetProxy(bytes4) external view returns (address);

    function isValidSignature(
        bytes32,
        address,
        bytes calldata
    ) external view returns (bool);

    function preSign(
        bytes32,
        address,
        bytes calldata
    ) external;

    function cancelOrder(Order calldata) external;

    function fillOrder(
        Order calldata,
        uint256,
        bytes calldata
    ) external returns (FillResults memory);
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract MathHelpers {
    using SafeMath for uint256;

    function __calcRelativeQuantity(
        uint256 _quantity1,
        uint256 _quantity2,
        uint256 _relativeQuantity1
    ) internal pure returns (uint256 relativeQuantity2_) {
        return _relativeQuantity1.mul(_quantity2).div(_quantity1);
    }

    function __calcNormalizedRate(
        uint256 _baseAssetDecimals,
        uint256 _baseAssetAmount,
        uint256 _quoteAssetDecimals,
        uint256 _quoteAssetAmount
    ) internal pure returns (uint256 normalizedRate_) {
        return
            _quoteAssetAmount.mul(10**_baseAssetDecimals.add(18)).div(
                _baseAssetAmount.mul(10**_quoteAssetDecimals)
            );
    }
}// GPL-3.0


pragma solidity 0.6.12;

library AddressArrayLib {
    function contains(address[] memory _self, address _target)
        internal
        pure
        returns (bool doesContain_)
    {
        for (uint256 i; i < _self.length; i++) {
            if (_target == _self[i]) {
                return true;
            }
        }
        return false;
    }

    function isUniqueSet(address[] memory _self) internal pure returns (bool isUnique_) {
        if (_self.length <= 1) {
            return true;
        }

        uint256 arrayLength = _self.length;
        for (uint256 i; i < arrayLength; i++) {
            for (uint256 j = i + 1; j < arrayLength; j++) {
                if (_self[i] == _self[j]) {
                    return false;
                }
            }
        }

        return true;
    }

    function removeItems(address[] memory _self, address[] memory _itemsToRemove)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        if (_itemsToRemove.length == 0) {
            return _self;
        }

        bool[] memory indexesToRemove = new bool[](_self.length);
        uint256 remainingItemsCount = _self.length;
        for (uint256 i; i < _self.length; i++) {
            if (contains(_itemsToRemove, _self[i])) {
                indexesToRemove[i] = true;
                remainingItemsCount--;
            }
        }

        if (remainingItemsCount == _self.length) {
            nextArray_ = _self;
        } else if (remainingItemsCount > 0) {
            nextArray_ = new address[](remainingItemsCount);
            uint256 nextArrayIndex;
            for (uint256 i; i < _self.length; i++) {
                if (!indexesToRemove[i]) {
                    nextArray_[nextArrayIndex] = _self[i];
                    nextArrayIndex++;
                }
            }
        }

        return nextArray_;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IFundDeployer {
    enum ReleaseStatus {PreLaunch, Live, Paused}

    function getOwner() external view returns (address);

    function getReleaseStatus() external view returns (ReleaseStatus);

    function isRegisteredVaultCall(address, bytes4) external view returns (bool);
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract FundDeployerOwnerMixin {
    address internal immutable FUND_DEPLOYER;

    modifier onlyFundDeployerOwner() {
        require(
            msg.sender == getOwner(),
            "onlyFundDeployerOwner: Only the FundDeployer owner can call this function"
        );
        _;
    }

    constructor(address _fundDeployer) public {
        FUND_DEPLOYER = _fundDeployer;
    }

    function getOwner() public view returns (address owner_) {
        return IFundDeployer(FUND_DEPLOYER).getOwner();
    }


    function getFundDeployer() external view returns (address fundDeployer_) {
        return FUND_DEPLOYER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract ZeroExV2Adapter is AdapterBase, FundDeployerOwnerMixin, MathHelpers {
    using AddressArrayLib for address[];
    using SafeMath for uint256;

    event AllowedMakerAdded(address indexed account);

    event AllowedMakerRemoved(address indexed account);

    address private immutable EXCHANGE;
    mapping(address => bool) private makerToIsAllowed;

    constructor(
        address _integrationManager,
        address _exchange,
        address _fundDeployer,
        address[] memory _allowedMakers
    ) public AdapterBase(_integrationManager) FundDeployerOwnerMixin(_fundDeployer) {
        EXCHANGE = _exchange;
        if (_allowedMakers.length > 0) {
            __addAllowedMakers(_allowedMakers);
        }
    }


    function identifier() external pure override returns (string memory identifier_) {
        return "ZERO_EX_V2";
    }

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        require(_selector == TAKE_ORDER_SELECTOR, "parseAssetsForMethod: _selector invalid");

        (
            bytes memory encodedZeroExOrderArgs,
            uint256 takerAssetFillAmount
        ) = __decodeTakeOrderCallArgs(_encodedCallArgs);
        IZeroExV2.Order memory order = __constructOrderStruct(encodedZeroExOrderArgs);

        require(
            isAllowedMaker(order.makerAddress),
            "parseAssetsForMethod: Order maker is not allowed"
        );
        require(
            takerAssetFillAmount <= order.takerAssetAmount,
            "parseAssetsForMethod: Taker asset fill amount greater than available"
        );

        address makerAsset = __getAssetAddress(order.makerAssetData);
        address takerAsset = __getAssetAddress(order.takerAssetData);

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = makerAsset;
        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = __calcRelativeQuantity(
            order.takerAssetAmount,
            order.makerAssetAmount,
            takerAssetFillAmount
        );

        if (order.takerFee > 0) {
            address takerFeeAsset = __getAssetAddress(IZeroExV2(EXCHANGE).ZRX_ASSET_DATA());
            uint256 takerFeeFillAmount = __calcRelativeQuantity(
                order.takerAssetAmount,
                order.takerFee,
                takerAssetFillAmount
            ); // fee calculated relative to taker fill amount

            if (takerFeeAsset == makerAsset) {
                require(
                    order.takerFee < order.makerAssetAmount,
                    "parseAssetsForMethod: Fee greater than makerAssetAmount"
                );

                spendAssets_ = new address[](1);
                spendAssets_[0] = takerAsset;

                spendAssetAmounts_ = new uint256[](1);
                spendAssetAmounts_[0] = takerAssetFillAmount;

                minIncomingAssetAmounts_[0] = minIncomingAssetAmounts_[0].sub(takerFeeFillAmount);
            } else if (takerFeeAsset == takerAsset) {
                spendAssets_ = new address[](1);
                spendAssets_[0] = takerAsset;

                spendAssetAmounts_ = new uint256[](1);
                spendAssetAmounts_[0] = takerAssetFillAmount.add(takerFeeFillAmount);
            } else {
                spendAssets_ = new address[](2);
                spendAssets_[0] = takerAsset;
                spendAssets_[1] = takerFeeAsset;

                spendAssetAmounts_ = new uint256[](2);
                spendAssetAmounts_[0] = takerAssetFillAmount;
                spendAssetAmounts_[1] = takerFeeFillAmount;
            }
        } else {
            spendAssets_ = new address[](1);
            spendAssets_[0] = takerAsset;

            spendAssetAmounts_ = new uint256[](1);
            spendAssetAmounts_[0] = takerAssetFillAmount;
        }

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function takeOrder(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        fundAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            bytes memory encodedZeroExOrderArgs,
            uint256 takerAssetFillAmount
        ) = __decodeTakeOrderCallArgs(_encodedCallArgs);
        IZeroExV2.Order memory order = __constructOrderStruct(encodedZeroExOrderArgs);

        __approveMaxAsNeeded(
            __getAssetAddress(order.takerAssetData),
            __getAssetProxy(order.takerAssetData),
            takerAssetFillAmount
        );
        if (order.takerFee > 0) {
            bytes memory zrxData = IZeroExV2(EXCHANGE).ZRX_ASSET_DATA();
            __approveMaxAsNeeded(
                __getAssetAddress(zrxData),
                __getAssetProxy(zrxData),
                __calcRelativeQuantity(
                    order.takerAssetAmount,
                    order.takerFee,
                    takerAssetFillAmount
                ) // fee calculated relative to taker fill amount
            );
        }

        (, , , bytes memory signature) = __decodeZeroExOrderArgs(encodedZeroExOrderArgs);
        IZeroExV2(EXCHANGE).fillOrder(order, takerAssetFillAmount, signature);
    }


    function __constructOrderStruct(bytes memory _encodedOrderArgs)
        private
        pure
        returns (IZeroExV2.Order memory order_)
    {
        (
            address[4] memory orderAddresses,
            uint256[6] memory orderValues,
            bytes[2] memory orderData,

        ) = __decodeZeroExOrderArgs(_encodedOrderArgs);

        return
            IZeroExV2.Order({
                makerAddress: orderAddresses[0],
                takerAddress: orderAddresses[1],
                feeRecipientAddress: orderAddresses[2],
                senderAddress: orderAddresses[3],
                makerAssetAmount: orderValues[0],
                takerAssetAmount: orderValues[1],
                makerFee: orderValues[2],
                takerFee: orderValues[3],
                expirationTimeSeconds: orderValues[4],
                salt: orderValues[5],
                makerAssetData: orderData[0],
                takerAssetData: orderData[1]
            });
    }

    function __decodeTakeOrderCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (bytes memory encodedZeroExOrderArgs_, uint256 takerAssetFillAmount_)
    {
        return abi.decode(_encodedCallArgs, (bytes, uint256));
    }

    function __decodeZeroExOrderArgs(bytes memory _encodedZeroExOrderArgs)
        private
        pure
        returns (
            address[4] memory orderAddresses_,
            uint256[6] memory orderValues_,
            bytes[2] memory orderData_,
            bytes memory signature_
        )
    {
        return abi.decode(_encodedZeroExOrderArgs, (address[4], uint256[6], bytes[2], bytes));
    }

    function __getAssetAddress(bytes memory _assetData)
        private
        pure
        returns (address assetAddress_)
    {
        assembly {
            assetAddress_ := mload(add(_assetData, 36))
        }
    }

    function __getAssetProxy(bytes memory _assetData) private view returns (address assetProxy_) {
        bytes4 assetProxyId;

        assembly {
            assetProxyId := and(
                mload(add(_assetData, 32)),
                0xFFFFFFFF00000000000000000000000000000000000000000000000000000000
            )
        }
        assetProxy_ = IZeroExV2(EXCHANGE).getAssetProxy(assetProxyId);
    }


    function addAllowedMakers(address[] calldata _accountsToAdd) external onlyFundDeployerOwner {
        __addAllowedMakers(_accountsToAdd);
    }

    function removeAllowedMakers(address[] calldata _accountsToRemove)
        external
        onlyFundDeployerOwner
    {
        require(_accountsToRemove.length > 0, "removeAllowedMakers: Empty _accountsToRemove");

        for (uint256 i; i < _accountsToRemove.length; i++) {
            require(
                isAllowedMaker(_accountsToRemove[i]),
                "removeAllowedMakers: Account is not an allowed maker"
            );

            makerToIsAllowed[_accountsToRemove[i]] = false;

            emit AllowedMakerRemoved(_accountsToRemove[i]);
        }
    }

    function __addAllowedMakers(address[] memory _accountsToAdd) private {
        require(_accountsToAdd.length > 0, "__addAllowedMakers: Empty _accountsToAdd");

        for (uint256 i; i < _accountsToAdd.length; i++) {
            require(!isAllowedMaker(_accountsToAdd[i]), "__addAllowedMakers: Value already set");

            makerToIsAllowed[_accountsToAdd[i]] = true;

            emit AllowedMakerAdded(_accountsToAdd[i]);
        }
    }


    function getExchange() external view returns (address exchange_) {
        return EXCHANGE;
    }

    function isAllowedMaker(address _who) public view returns (bool isAllowedMaker_) {
        return makerToIsAllowed[_who];
    }
}// MIT

pragma solidity ^0.6.0;

library EnumerableSet {

    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IMigratableVault {
    function canMigrate(address _who) external view returns (bool canMigrate_);

    function init(
        address _owner,
        address _accessor,
        string calldata _fundName
    ) external;

    function setAccessor(address _nextAccessor) external;

    function setVaultLib(address _nextVaultLib) external;
}// GPL-3.0


pragma solidity 0.6.12;


interface IVault is IMigratableVault {
    function addTrackedAsset(address) external;

    function approveAssetSpender(
        address,
        address,
        uint256
    ) external;

    function burnShares(address, uint256) external;

    function callOnContract(address, bytes calldata) external;

    function getAccessor() external view returns (address);

    function getOwner() external view returns (address);

    function getTrackedAssets() external view returns (address[] memory);

    function isTrackedAsset(address) external view returns (bool);

    function mintShares(address, uint256) external;

    function removeTrackedAsset(address) external;

    function transferShares(
        address,
        address,
        uint256
    ) external;

    function withdrawAssetTo(
        address,
        address,
        uint256
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IComptroller {
    enum VaultAction {
        None,
        BurnShares,
        MintShares,
        TransferShares,
        ApproveAssetSpender,
        WithdrawAssetTo,
        AddTrackedAsset,
        RemoveTrackedAsset
    }

    function activate(address, bool) external;

    function calcGav(bool) external returns (uint256, bool);

    function calcGrossShareValue(bool) external returns (uint256, bool);

    function callOnExtension(
        address,
        uint256,
        bytes calldata
    ) external;

    function configureExtensions(bytes calldata, bytes calldata) external;

    function destruct() external;

    function getDenominationAsset() external view returns (address);

    function getVaultProxy() external view returns (address);

    function init(address, uint256) external;

    function permissionedVaultAction(VaultAction, bytes calldata) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IExtension {
    function activateForFund(bool _isMigration) external;

    function deactivateForFund() external;

    function receiveCallFromComptroller(
        address _comptrollerProxy,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external;

    function setConfigForFund(bytes calldata _configData) external;
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract ExtensionBase is IExtension {
    mapping(address => address) internal comptrollerProxyToVaultProxy;

    function activateForFund(bool) external virtual override {
        return;
    }

    function deactivateForFund() external virtual override {
        return;
    }

    function receiveCallFromComptroller(
        address,
        uint256,
        bytes calldata
    ) external virtual override {
        revert("receiveCallFromComptroller: Unimplemented for Extension");
    }

    function setConfigForFund(bytes calldata) external virtual override {
        return;
    }

    function __setValidatedVaultProxy(address _comptrollerProxy)
        internal
        returns (address vaultProxy_)
    {
        require(
            comptrollerProxyToVaultProxy[_comptrollerProxy] == address(0),
            "__setValidatedVaultProxy: Already set"
        );

        vaultProxy_ = IComptroller(_comptrollerProxy).getVaultProxy();
        require(vaultProxy_ != address(0), "__setValidatedVaultProxy: Missing vaultProxy");

        require(
            _comptrollerProxy == IVault(vaultProxy_).getAccessor(),
            "__setValidatedVaultProxy: Not the VaultProxy accessor"
        );

        comptrollerProxyToVaultProxy[_comptrollerProxy] = vaultProxy_;

        return vaultProxy_;
    }


    function getVaultProxyForFund(address _comptrollerProxy)
        public
        view
        returns (address vaultProxy_)
    {
        return comptrollerProxyToVaultProxy[_comptrollerProxy];
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IPolicyManager {
    enum PolicyHook {
        BuySharesSetup,
        PreBuyShares,
        PostBuyShares,
        BuySharesCompleted,
        PreCallOnIntegration,
        PostCallOnIntegration
    }

    function validatePolicies(
        address,
        PolicyHook,
        bytes calldata
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;


interface IPolicy {
    function activateForFund(address _comptrollerProxy, address _vaultProxy) external;

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings) external;

    function identifier() external pure returns (string memory identifier_);

    function implementedHooks()
        external
        view
        returns (IPolicyManager.PolicyHook[] memory implementedHooks_);

    function updateFundSettings(
        address _comptrollerProxy,
        address _vaultProxy,
        bytes calldata _encodedSettings
    ) external;

    function validateRule(
        address _comptrollerProxy,
        address _vaultProxy,
        IPolicyManager.PolicyHook _hook,
        bytes calldata _encodedArgs
    ) external returns (bool isValid_);
}// GPL-3.0


pragma solidity 0.6.12;


contract PolicyManager is IPolicyManager, ExtensionBase, FundDeployerOwnerMixin {
    using EnumerableSet for EnumerableSet.AddressSet;

    event PolicyDeregistered(address indexed policy, string indexed identifier);

    event PolicyDisabledForFund(address indexed comptrollerProxy, address indexed policy);

    event PolicyEnabledForFund(
        address indexed comptrollerProxy,
        address indexed policy,
        bytes settingsData
    );

    event PolicyRegistered(
        address indexed policy,
        string indexed identifier,
        PolicyHook[] implementedHooks
    );

    EnumerableSet.AddressSet private registeredPolicies;
    mapping(address => mapping(PolicyHook => bool)) private policyToHookToIsImplemented;
    mapping(address => EnumerableSet.AddressSet) private comptrollerProxyToPolicies;

    modifier onlyBuySharesHooks(address _policy) {
        require(
            !policyImplementsHook(_policy, PolicyHook.PreCallOnIntegration) &&
                !policyImplementsHook(_policy, PolicyHook.PostCallOnIntegration),
            "onlyBuySharesHooks: Disallowed hook"
        );
        _;
    }

    modifier onlyEnabledPolicyForFund(address _comptrollerProxy, address _policy) {
        require(
            policyIsEnabledForFund(_comptrollerProxy, _policy),
            "onlyEnabledPolicyForFund: Policy not enabled"
        );
        _;
    }

    constructor(address _fundDeployer) public FundDeployerOwnerMixin(_fundDeployer) {}


    function activateForFund(bool _isMigratedFund) external override {
        address vaultProxy = __setValidatedVaultProxy(msg.sender);

        if (_isMigratedFund) {
            address[] memory enabledPolicies = getEnabledPoliciesForFund(msg.sender);
            for (uint256 i; i < enabledPolicies.length; i++) {
                __activatePolicyForFund(msg.sender, vaultProxy, enabledPolicies[i]);
            }
        }
    }

    function deactivateForFund() external override {
        delete comptrollerProxyToVaultProxy[msg.sender];

        for (uint256 i = comptrollerProxyToPolicies[msg.sender].length(); i > 0; i--) {
            comptrollerProxyToPolicies[msg.sender].remove(
                comptrollerProxyToPolicies[msg.sender].at(i - 1)
            );
        }
    }

    function disablePolicyForFund(address _comptrollerProxy, address _policy)
        external
        onlyBuySharesHooks(_policy)
        onlyEnabledPolicyForFund(_comptrollerProxy, _policy)
    {
        __validateIsFundOwner(getVaultProxyForFund(_comptrollerProxy), msg.sender);

        comptrollerProxyToPolicies[_comptrollerProxy].remove(_policy);

        emit PolicyDisabledForFund(_comptrollerProxy, _policy);
    }

    function enablePolicyForFund(
        address _comptrollerProxy,
        address _policy,
        bytes calldata _settingsData
    ) external onlyBuySharesHooks(_policy) {
        address vaultProxy = getVaultProxyForFund(_comptrollerProxy);
        __validateIsFundOwner(vaultProxy, msg.sender);

        __enablePolicyForFund(_comptrollerProxy, _policy, _settingsData);

        __activatePolicyForFund(_comptrollerProxy, vaultProxy, _policy);
    }

    function setConfigForFund(bytes calldata _configData) external override {
        (address[] memory policies, bytes[] memory settingsData) = abi.decode(
            _configData,
            (address[], bytes[])
        );

        require(
            policies.length == settingsData.length,
            "setConfigForFund: policies and settingsData array lengths unequal"
        );

        for (uint256 i; i < policies.length; i++) {
            __enablePolicyForFund(msg.sender, policies[i], settingsData[i]);
        }
    }

    function updatePolicySettingsForFund(
        address _comptrollerProxy,
        address _policy,
        bytes calldata _settingsData
    ) external onlyBuySharesHooks(_policy) onlyEnabledPolicyForFund(_comptrollerProxy, _policy) {
        address vaultProxy = getVaultProxyForFund(_comptrollerProxy);
        __validateIsFundOwner(vaultProxy, msg.sender);

        IPolicy(_policy).updateFundSettings(_comptrollerProxy, vaultProxy, _settingsData);
    }

    function validatePolicies(
        address _comptrollerProxy,
        PolicyHook _hook,
        bytes calldata _validationData
    ) external override {
        address vaultProxy = getVaultProxyForFund(_comptrollerProxy);
        address[] memory policies = getEnabledPoliciesForFund(_comptrollerProxy);
        for (uint256 i; i < policies.length; i++) {
            if (!policyImplementsHook(policies[i], _hook)) {
                continue;
            }

            require(
                IPolicy(policies[i]).validateRule(
                    _comptrollerProxy,
                    vaultProxy,
                    _hook,
                    _validationData
                ),
                string(
                    abi.encodePacked(
                        "Rule evaluated to false: ",
                        IPolicy(policies[i]).identifier()
                    )
                )
            );
        }
    }


    function __activatePolicyForFund(
        address _comptrollerProxy,
        address _vaultProxy,
        address _policy
    ) private {
        IPolicy(_policy).activateForFund(_comptrollerProxy, _vaultProxy);
    }

    function __enablePolicyForFund(
        address _comptrollerProxy,
        address _policy,
        bytes memory _settingsData
    ) private {
        require(
            !policyIsEnabledForFund(_comptrollerProxy, _policy),
            "__enablePolicyForFund: policy already enabled"
        );
        require(policyIsRegistered(_policy), "__enablePolicyForFund: Policy is not registered");

        if (_settingsData.length > 0) {
            IPolicy(_policy).addFundSettings(_comptrollerProxy, _settingsData);
        }

        comptrollerProxyToPolicies[_comptrollerProxy].add(_policy);

        emit PolicyEnabledForFund(_comptrollerProxy, _policy, _settingsData);
    }

    function __validateIsFundOwner(address _vaultProxy, address _who) private view {
        require(
            _who == IVault(_vaultProxy).getOwner(),
            "Only the fund owner can call this function"
        );
    }


    function deregisterPolicies(address[] calldata _policies) external onlyFundDeployerOwner {
        require(_policies.length > 0, "deregisterPolicies: _policies cannot be empty");

        for (uint256 i; i < _policies.length; i++) {
            require(
                policyIsRegistered(_policies[i]),
                "deregisterPolicies: policy is not registered"
            );

            registeredPolicies.remove(_policies[i]);

            emit PolicyDeregistered(_policies[i], IPolicy(_policies[i]).identifier());
        }
    }

    function registerPolicies(address[] calldata _policies) external onlyFundDeployerOwner {
        require(_policies.length > 0, "registerPolicies: _policies cannot be empty");

        for (uint256 i; i < _policies.length; i++) {
            require(
                !policyIsRegistered(_policies[i]),
                "registerPolicies: policy already registered"
            );

            registeredPolicies.add(_policies[i]);

            IPolicy policyContract = IPolicy(_policies[i]);
            PolicyHook[] memory implementedHooks = policyContract.implementedHooks();
            for (uint256 j; j < implementedHooks.length; j++) {
                policyToHookToIsImplemented[_policies[i]][implementedHooks[j]] = true;
            }

            emit PolicyRegistered(_policies[i], policyContract.identifier(), implementedHooks);
        }
    }


    function getRegisteredPolicies()
        external
        view
        returns (address[] memory registeredPoliciesArray_)
    {
        registeredPoliciesArray_ = new address[](registeredPolicies.length());
        for (uint256 i; i < registeredPoliciesArray_.length; i++) {
            registeredPoliciesArray_[i] = registeredPolicies.at(i);
        }
    }

    function getEnabledPoliciesForFund(address _comptrollerProxy)
        public
        view
        returns (address[] memory enabledPolicies_)
    {
        enabledPolicies_ = new address[](comptrollerProxyToPolicies[_comptrollerProxy].length());
        for (uint256 i; i < enabledPolicies_.length; i++) {
            enabledPolicies_[i] = comptrollerProxyToPolicies[_comptrollerProxy].at(i);
        }
    }

    function policyImplementsHook(address _policy, PolicyHook _hook)
        public
        view
        returns (bool implementsHook_)
    {
        return policyToHookToIsImplemented[_policy][_hook];
    }

    function policyIsEnabledForFund(address _comptrollerProxy, address _policy)
        public
        view
        returns (bool isEnabled_)
    {
        return comptrollerProxyToPolicies[_comptrollerProxy].contains(_policy);
    }

    function policyIsRegistered(address _policy) public view returns (bool isRegistered_) {
        return registeredPolicies.contains(_policy);
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract PolicyBase is IPolicy {
    address internal immutable POLICY_MANAGER;

    modifier onlyPolicyManager {
        require(msg.sender == POLICY_MANAGER, "Only the PolicyManager can make this call");
        _;
    }

    constructor(address _policyManager) public {
        POLICY_MANAGER = _policyManager;
    }

    function activateForFund(address, address) external virtual override {
        return;
    }

    function updateFundSettings(
        address,
        address,
        bytes calldata
    ) external virtual override {
        revert("updateFundSettings: Updates not allowed for this policy");
    }


    function getPolicyManager() external view returns (address policyManager_) {
        return POLICY_MANAGER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract PostCallOnIntegrationValidatePolicyBase is PolicyBase {
    function implementedHooks()
        external
        view
        override
        returns (IPolicyManager.PolicyHook[] memory implementedHooks_)
    {
        implementedHooks_ = new IPolicyManager.PolicyHook[](1);
        implementedHooks_[0] = IPolicyManager.PolicyHook.PostCallOnIntegration;

        return implementedHooks_;
    }

    function __decodeRuleArgs(bytes memory _encodedRuleArgs)
        internal
        pure
        returns (
            address adapter_,
            bytes4 selector_,
            address[] memory incomingAssets_,
            uint256[] memory incomingAssetAmounts_,
            address[] memory outgoingAssets_,
            uint256[] memory outgoingAssetAmounts_
        )
    {
        return
            abi.decode(
                _encodedRuleArgs,
                (address, bytes4, address[], uint256[], address[], uint256[])
            );
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IDispatcher {
    function cancelMigration(address _vaultProxy, bool _bypassFailure) external;

    function claimOwnership() external;

    function deployVaultProxy(
        address _vaultLib,
        address _owner,
        address _vaultAccessor,
        string calldata _fundName
    ) external returns (address vaultProxy_);

    function executeMigration(address _vaultProxy, bool _bypassFailure) external;

    function getCurrentFundDeployer() external view returns (address currentFundDeployer_);

    function getFundDeployerForVaultProxy(address _vaultProxy)
        external
        view
        returns (address fundDeployer_);

    function getMigrationRequestDetailsForVaultProxy(address _vaultProxy)
        external
        view
        returns (
            address nextFundDeployer_,
            address nextVaultAccessor_,
            address nextVaultLib_,
            uint256 executableTimestamp_
        );

    function getMigrationTimelock() external view returns (uint256 migrationTimelock_);

    function getNominatedOwner() external view returns (address nominatedOwner_);

    function getOwner() external view returns (address owner_);

    function getSharesTokenSymbol() external view returns (string memory sharesTokenSymbol_);

    function getTimelockRemainingForMigrationRequest(address _vaultProxy)
        external
        view
        returns (uint256 secondsRemaining_);

    function hasExecutableMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasExecutableRequest_);

    function hasMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasMigrationRequest_);

    function removeNominatedOwner() external;

    function setCurrentFundDeployer(address _nextFundDeployer) external;

    function setMigrationTimelock(uint256 _nextTimelock) external;

    function setNominatedOwner(address _nextNominatedOwner) external;

    function setSharesTokenSymbol(string calldata _nextSymbol) external;

    function signalMigration(
        address _vaultProxy,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IFeeManager {
    enum FeeHook {
        Continuous,
        BuySharesSetup,
        PreBuyShares,
        PostBuyShares,
        BuySharesCompleted,
        PreRedeemShares
    }
    enum SettlementType {None, Direct, Mint, Burn, MintSharesOutstanding, BurnSharesOutstanding}

    function invokeHook(
        FeeHook,
        bytes calldata,
        uint256
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IPrimitivePriceFeed {
    function calcCanonicalValue(
        address,
        uint256,
        address
    ) external view returns (uint256, bool);

    function calcLiveValue(
        address,
        uint256,
        address
    ) external view returns (uint256, bool);

    function isSupportedAsset(address) external view returns (bool);
}// GPL-3.0


pragma solidity 0.6.12;

interface IValueInterpreter {
    function calcCanonicalAssetValue(
        address,
        uint256,
        address
    ) external returns (uint256, bool);

    function calcCanonicalAssetsTotalValue(
        address[] calldata,
        uint256[] calldata,
        address
    ) external returns (uint256, bool);

    function calcLiveAssetValue(
        address,
        uint256,
        address
    ) external returns (uint256, bool);

    function calcLiveAssetsTotalValue(
        address[] calldata,
        uint256[] calldata,
        address
    ) external returns (uint256, bool);
}// GPL-3.0


pragma solidity 0.6.12;

interface ISynthetix {
    function exchangeOnBehalfWithTracking(
        address,
        bytes32,
        uint256,
        bytes32,
        address,
        bytes32
    ) external returns (uint256);
}// GPL-3.0


pragma solidity 0.6.12;

interface ISynthetixAddressResolver {
    function requireAndGetAddress(bytes32, string calldata) external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;

interface ISynthetixExchangeRates {
    function rateAndInvalid(bytes32) external view returns (uint256, bool);
}// GPL-3.0


pragma solidity 0.6.12;

interface ISynthetixProxyERC20 {
    function target() external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;

interface ISynthetixSynth {
    function currencyKey() external view returns (bytes32);
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract DispatcherOwnerMixin {
    address internal immutable DISPATCHER;

    modifier onlyDispatcherOwner() {
        require(
            msg.sender == getOwner(),
            "onlyDispatcherOwner: Only the Dispatcher owner can call this function"
        );
        _;
    }

    constructor(address _dispatcher) public {
        DISPATCHER = _dispatcher;
    }

    function getOwner() public view returns (address owner_) {
        return IDispatcher(DISPATCHER).getOwner();
    }


    function getDispatcher() external view returns (address dispatcher_) {
        return DISPATCHER;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IDerivativePriceFeed {
    function calcUnderlyingValues(address, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function isSupportedAsset(address) external view returns (bool);
}// GPL-3.0


pragma solidity 0.6.12;


contract SynthetixPriceFeed is IDerivativePriceFeed, DispatcherOwnerMixin {
    using SafeMath for uint256;

    event SynthAdded(address indexed synth, bytes32 currencyKey);

    event SynthCurrencyKeyUpdated(
        address indexed synth,
        bytes32 prevCurrencyKey,
        bytes32 nextCurrencyKey
    );

    uint256 private constant SYNTH_UNIT = 10**18;
    address private immutable ADDRESS_RESOLVER;
    address private immutable SUSD;

    mapping(address => bytes32) private synthToCurrencyKey;

    constructor(
        address _dispatcher,
        address _addressResolver,
        address _sUSD,
        address[] memory _synths
    ) public DispatcherOwnerMixin(_dispatcher) {
        ADDRESS_RESOLVER = _addressResolver;
        SUSD = _sUSD;

        address[] memory sUSDSynths = new address[](1);
        sUSDSynths[0] = _sUSD;

        __addSynths(sUSDSynths);
        __addSynths(_synths);
    }

    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        underlyings_ = new address[](1);
        underlyings_[0] = SUSD;
        underlyingAmounts_ = new uint256[](1);

        bytes32 currencyKey = getCurrencyKeyForSynth(_derivative);
        require(currencyKey != 0, "calcUnderlyingValues: _derivative is not supported");

        address exchangeRates = ISynthetixAddressResolver(ADDRESS_RESOLVER).requireAndGetAddress(
            "ExchangeRates",
            "calcUnderlyingValues: Missing ExchangeRates"
        );

        (uint256 rate, bool isInvalid) = ISynthetixExchangeRates(exchangeRates).rateAndInvalid(
            currencyKey
        );
        require(!isInvalid, "calcUnderlyingValues: _derivative rate is not valid");

        underlyingAmounts_[0] = _derivativeAmount.mul(rate).div(SYNTH_UNIT);

        return (underlyings_, underlyingAmounts_);
    }

    function isSupportedAsset(address _asset) public view override returns (bool isSupported_) {
        return getCurrencyKeyForSynth(_asset) != 0;
    }


    function addSynths(address[] calldata _synths) external onlyDispatcherOwner {
        require(_synths.length > 0, "addSynths: Empty _synths");

        __addSynths(_synths);
    }

    function updateSynthCurrencyKeys(address[] calldata _synths) external {
        require(_synths.length > 0, "updateSynthCurrencyKeys: Empty _synths");

        for (uint256 i; i < _synths.length; i++) {
            bytes32 prevCurrencyKey = synthToCurrencyKey[_synths[i]];
            require(prevCurrencyKey != 0, "updateSynthCurrencyKeys: Synth not set");

            bytes32 nextCurrencyKey = __getCurrencyKey(_synths[i]);
            require(
                nextCurrencyKey != prevCurrencyKey,
                "updateSynthCurrencyKeys: Synth has correct currencyKey"
            );

            synthToCurrencyKey[_synths[i]] = nextCurrencyKey;

            emit SynthCurrencyKeyUpdated(_synths[i], prevCurrencyKey, nextCurrencyKey);
        }
    }

    function __addSynths(address[] memory _synths) private {
        for (uint256 i; i < _synths.length; i++) {
            require(synthToCurrencyKey[_synths[i]] == 0, "__addSynths: Value already set");

            bytes32 currencyKey = __getCurrencyKey(_synths[i]);
            require(currencyKey != 0, "__addSynths: No currencyKey");

            synthToCurrencyKey[_synths[i]] = currencyKey;

            emit SynthAdded(_synths[i], currencyKey);
        }
    }

    function __getCurrencyKey(address _synthProxy) private view returns (bytes32 currencyKey_) {
        return ISynthetixSynth(ISynthetixProxyERC20(_synthProxy).target()).currencyKey();
    }


    function getAddressResolver() external view returns (address) {
        return ADDRESS_RESOLVER;
    }

    function getCurrencyKeysForSynths(address[] calldata _synths)
        external
        view
        returns (bytes32[] memory currencyKeys_)
    {
        currencyKeys_ = new bytes32[](_synths.length);
        for (uint256 i; i < _synths.length; i++) {
            currencyKeys_[i] = synthToCurrencyKey[_synths[i]];
        }

        return currencyKeys_;
    }

    function getSUSD() external view returns (address susd_) {
        return SUSD;
    }

    function getCurrencyKeyForSynth(address _synth) public view returns (bytes32 currencyKey_) {
        return synthToCurrencyKey[_synth];
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface ISynthetixExchanger {
    function getAmountsForExchange(
        uint256,
        bytes32,
        bytes32
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function settle(address, bytes32)
        external
        returns (
            uint256,
            uint256,
            uint256
        );
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract AssetFinalityResolver {
    address internal immutable SYNTHETIX_ADDRESS_RESOLVER;
    address internal immutable SYNTHETIX_PRICE_FEED;

    constructor(address _synthetixPriceFeed, address _synthetixAddressResolver) public {
        SYNTHETIX_ADDRESS_RESOLVER = _synthetixAddressResolver;
        SYNTHETIX_PRICE_FEED = _synthetixPriceFeed;
    }

    function __finalizeIfSynthAndGetAssetBalance(
        address _target,
        address _asset,
        bool _requireFinality
    ) internal returns (uint256 assetBalance_) {
        bytes32 currencyKey = SynthetixPriceFeed(SYNTHETIX_PRICE_FEED).getCurrencyKeyForSynth(
            _asset
        );
        if (currencyKey != 0) {
            address synthetixExchanger = ISynthetixAddressResolver(SYNTHETIX_ADDRESS_RESOLVER)
                .requireAndGetAddress(
                "Exchanger",
                "finalizeAndGetAssetBalance: Missing Exchanger"
            );
            try ISynthetixExchanger(synthetixExchanger).settle(_target, currencyKey)  {} catch {
                require(!_requireFinality, "finalizeAndGetAssetBalance: Cannot settle Synth");
            }
        }

        return ERC20(_asset).balanceOf(_target);
    }


    function getSynthetixAddressResolver()
        external
        view
        returns (address synthetixAddressResolver_)
    {
        return SYNTHETIX_ADDRESS_RESOLVER;
    }

    function getSynthetixPriceFeed() external view returns (address synthetixPriceFeed_) {
        return SYNTHETIX_PRICE_FEED;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract ComptrollerLib is IComptroller, AssetFinalityResolver {
    using AddressArrayLib for address[];
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    event MigratedSharesDuePaid(uint256 sharesDue);

    event OverridePauseSet(bool indexed overridePause);

    event PreRedeemSharesHookFailed(
        bytes failureReturnData,
        address redeemer,
        uint256 sharesQuantity
    );

    event SharesBought(
        address indexed caller,
        address indexed buyer,
        uint256 investmentAmount,
        uint256 sharesIssued,
        uint256 sharesReceived
    );

    event SharesRedeemed(
        address indexed redeemer,
        uint256 sharesQuantity,
        address[] receivedAssets,
        uint256[] receivedAssetQuantities
    );

    event VaultProxySet(address vaultProxy);

    uint256 private constant SHARES_UNIT = 10**18;
    address private immutable DISPATCHER;
    address private immutable FUND_DEPLOYER;
    address private immutable FEE_MANAGER;
    address private immutable INTEGRATION_MANAGER;
    address private immutable PRIMITIVE_PRICE_FEED;
    address private immutable POLICY_MANAGER;
    address private immutable VALUE_INTERPRETER;


    address internal denominationAsset;
    address internal vaultProxy;
    bool internal isLib;


    bool internal overridePause;
    bool internal permissionedVaultActionAllowed;
    bool internal reentranceLocked;
    uint256 internal sharesActionTimelock;
    mapping(address => uint256) internal acctToLastSharesAction;


    modifier allowsPermissionedVaultAction {
        __assertPermissionedVaultActionNotAllowed();
        permissionedVaultActionAllowed = true;
        _;
        permissionedVaultActionAllowed = false;
    }

    modifier locksReentrance() {
        __assertNotReentranceLocked();
        reentranceLocked = true;
        _;
        reentranceLocked = false;
    }

    modifier onlyActive() {
        __assertIsActive(vaultProxy);
        _;
    }

    modifier onlyNotPaused() {
        __assertNotPaused();
        _;
    }

    modifier onlyFundDeployer() {
        __assertIsFundDeployer(msg.sender);
        _;
    }

    modifier onlyOwner() {
        __assertIsOwner(msg.sender);
        _;
    }

    modifier timelockedSharesAction(address _account) {
        __assertSharesActionNotTimelocked(_account);
        _;
        acctToLastSharesAction[_account] = block.timestamp;
    }



    function __assertIsActive(address _vaultProxy) private pure {
        require(_vaultProxy != address(0), "Fund not active");
    }

    function __assertIsFundDeployer(address _who) private view {
        require(_who == FUND_DEPLOYER, "Only FundDeployer callable");
    }

    function __assertIsOwner(address _who) private view {
        require(_who == IVault(vaultProxy).getOwner(), "Only fund owner callable");
    }

    function __assertLowLevelCall(bool _success, bytes memory _returnData) private pure {
        require(_success, string(_returnData));
    }

    function __assertNotPaused() private view {
        require(!__fundIsPaused(), "Fund is paused");
    }

    function __assertNotReentranceLocked() private view {
        require(!reentranceLocked, "Re-entrance");
    }

    function __assertPermissionedVaultActionNotAllowed() private view {
        require(!permissionedVaultActionAllowed, "Vault action re-entrance");
    }

    function __assertSharesActionNotTimelocked(address _account) private view {
        require(
            block.timestamp.sub(acctToLastSharesAction[_account]) >= sharesActionTimelock,
            "Shares action timelocked"
        );
    }

    constructor(
        address _dispatcher,
        address _fundDeployer,
        address _valueInterpreter,
        address _feeManager,
        address _integrationManager,
        address _policyManager,
        address _primitivePriceFeed,
        address _synthetixPriceFeed,
        address _synthetixAddressResolver
    ) public AssetFinalityResolver(_synthetixPriceFeed, _synthetixAddressResolver) {
        DISPATCHER = _dispatcher;
        FEE_MANAGER = _feeManager;
        FUND_DEPLOYER = _fundDeployer;
        INTEGRATION_MANAGER = _integrationManager;
        PRIMITIVE_PRICE_FEED = _primitivePriceFeed;
        POLICY_MANAGER = _policyManager;
        VALUE_INTERPRETER = _valueInterpreter;
        isLib = true;
    }


    function callOnExtension(
        address _extension,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external override onlyNotPaused onlyActive locksReentrance allowsPermissionedVaultAction {
        require(
            _extension == FEE_MANAGER || _extension == INTEGRATION_MANAGER,
            "callOnExtension: _extension invalid"
        );

        IExtension(_extension).receiveCallFromComptroller(msg.sender, _actionId, _callArgs);
    }

    function setOverridePause(bool _nextOverridePause) external onlyOwner {
        require(_nextOverridePause != overridePause, "setOverridePause: Value already set");

        overridePause = _nextOverridePause;

        emit OverridePauseSet(_nextOverridePause);
    }

    function vaultCallOnContract(
        address _contract,
        bytes4 _selector,
        bytes calldata _encodedArgs
    ) external onlyNotPaused onlyActive onlyOwner {
        require(
            IFundDeployer(FUND_DEPLOYER).isRegisteredVaultCall(_contract, _selector),
            "vaultCallOnContract: Unregistered"
        );

        IVault(vaultProxy).callOnContract(_contract, abi.encodePacked(_selector, _encodedArgs));
    }

    function __fundIsPaused() private view returns (bool) {
        return
            IFundDeployer(FUND_DEPLOYER).getReleaseStatus() ==
            IFundDeployer.ReleaseStatus.Paused &&
            !overridePause;
    }


    function permissionedVaultAction(VaultAction _action, bytes calldata _actionData)
        external
        override
        onlyNotPaused
        onlyActive
    {
        __assertPermissionedVaultAction(msg.sender, _action);

        if (_action == VaultAction.AddTrackedAsset) {
            __vaultActionAddTrackedAsset(_actionData);
        } else if (_action == VaultAction.ApproveAssetSpender) {
            __vaultActionApproveAssetSpender(_actionData);
        } else if (_action == VaultAction.BurnShares) {
            __vaultActionBurnShares(_actionData);
        } else if (_action == VaultAction.MintShares) {
            __vaultActionMintShares(_actionData);
        } else if (_action == VaultAction.RemoveTrackedAsset) {
            __vaultActionRemoveTrackedAsset(_actionData);
        } else if (_action == VaultAction.TransferShares) {
            __vaultActionTransferShares(_actionData);
        } else if (_action == VaultAction.WithdrawAssetTo) {
            __vaultActionWithdrawAssetTo(_actionData);
        }
    }

    function __assertPermissionedVaultAction(address _caller, VaultAction _action) private view {
        require(
            permissionedVaultActionAllowed,
            "__assertPermissionedVaultAction: No action allowed"
        );

        if (_caller == INTEGRATION_MANAGER) {
            require(
                _action == VaultAction.ApproveAssetSpender ||
                    _action == VaultAction.AddTrackedAsset ||
                    _action == VaultAction.RemoveTrackedAsset ||
                    _action == VaultAction.WithdrawAssetTo,
                "__assertPermissionedVaultAction: Not valid for IntegrationManager"
            );
        } else if (_caller == FEE_MANAGER) {
            require(
                _action == VaultAction.BurnShares ||
                    _action == VaultAction.MintShares ||
                    _action == VaultAction.TransferShares,
                "__assertPermissionedVaultAction: Not valid for FeeManager"
            );
        } else {
            revert("__assertPermissionedVaultAction: Not a valid actor");
        }
    }

    function __vaultActionAddTrackedAsset(bytes memory _actionData) private {
        address asset = abi.decode(_actionData, (address));
        IVault(vaultProxy).addTrackedAsset(asset);
    }

    function __vaultActionApproveAssetSpender(bytes memory _actionData) private {
        (address asset, address target, uint256 amount) = abi.decode(
            _actionData,
            (address, address, uint256)
        );
        IVault(vaultProxy).approveAssetSpender(asset, target, amount);
    }

    function __vaultActionBurnShares(bytes memory _actionData) private {
        (address target, uint256 amount) = abi.decode(_actionData, (address, uint256));
        IVault(vaultProxy).burnShares(target, amount);
    }

    function __vaultActionMintShares(bytes memory _actionData) private {
        (address target, uint256 amount) = abi.decode(_actionData, (address, uint256));
        IVault(vaultProxy).mintShares(target, amount);
    }

    function __vaultActionRemoveTrackedAsset(bytes memory _actionData) private {
        address asset = abi.decode(_actionData, (address));

        if (asset != denominationAsset) {
            IVault(vaultProxy).removeTrackedAsset(asset);
        }
    }

    function __vaultActionTransferShares(bytes memory _actionData) private {
        (address from, address to, uint256 amount) = abi.decode(
            _actionData,
            (address, address, uint256)
        );
        IVault(vaultProxy).transferShares(from, to, amount);
    }

    function __vaultActionWithdrawAssetTo(bytes memory _actionData) private {
        (address asset, address target, uint256 amount) = abi.decode(
            _actionData,
            (address, address, uint256)
        );
        IVault(vaultProxy).withdrawAssetTo(asset, target, amount);
    }


    function init(address _denominationAsset, uint256 _sharesActionTimelock) external override {
        require(denominationAsset == address(0), "init: Already initialized");
        require(
            IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).isSupportedAsset(_denominationAsset),
            "init: Bad denomination asset"
        );

        denominationAsset = _denominationAsset;
        sharesActionTimelock = _sharesActionTimelock;
    }

    function configureExtensions(
        bytes calldata _feeManagerConfigData,
        bytes calldata _policyManagerConfigData
    ) external override onlyFundDeployer {
        if (_feeManagerConfigData.length > 0) {
            IExtension(FEE_MANAGER).setConfigForFund(_feeManagerConfigData);
        }
        if (_policyManagerConfigData.length > 0) {
            IExtension(POLICY_MANAGER).setConfigForFund(_policyManagerConfigData);
        }
    }

    function activate(address _vaultProxy, bool _isMigration) external override onlyFundDeployer {
        vaultProxy = _vaultProxy;

        emit VaultProxySet(_vaultProxy);

        if (_isMigration) {
            uint256 sharesDue = ERC20(_vaultProxy).balanceOf(_vaultProxy);
            if (sharesDue > 0) {
                IVault(_vaultProxy).transferShares(
                    _vaultProxy,
                    IVault(_vaultProxy).getOwner(),
                    sharesDue
                );

                emit MigratedSharesDuePaid(sharesDue);
            }
        }

        IVault(_vaultProxy).addTrackedAsset(denominationAsset);

        IExtension(FEE_MANAGER).activateForFund(_isMigration);
        IExtension(INTEGRATION_MANAGER).activateForFund(_isMigration);
        IExtension(POLICY_MANAGER).activateForFund(_isMigration);
    }

    function destruct()
        external
        override
        onlyFundDeployer
        onlyNotPaused
        allowsPermissionedVaultAction
    {
        require(!isLib, "destruct: Only delegate callable");

        IExtension(FEE_MANAGER).deactivateForFund();
        IExtension(INTEGRATION_MANAGER).deactivateForFund();
        IExtension(POLICY_MANAGER).deactivateForFund();

        selfdestruct(address(0));
    }


    function calcGav(bool _requireFinality) public override returns (uint256 gav_, bool isValid_) {
        address vaultProxyAddress = vaultProxy;
        address[] memory assets = IVault(vaultProxyAddress).getTrackedAssets();
        if (assets.length == 0) {
            return (0, true);
        }

        uint256[] memory balances = new uint256[](assets.length);
        for (uint256 i; i < assets.length; i++) {
            balances[i] = __finalizeIfSynthAndGetAssetBalance(
                vaultProxyAddress,
                assets[i],
                _requireFinality
            );
        }

        (gav_, isValid_) = IValueInterpreter(VALUE_INTERPRETER).calcCanonicalAssetsTotalValue(
            assets,
            balances,
            denominationAsset
        );

        return (gav_, isValid_);
    }

    function calcGrossShareValue(bool _requireFinality)
        external
        override
        returns (uint256 grossShareValue_, bool isValid_)
    {
        uint256 gav;
        (gav, isValid_) = calcGav(_requireFinality);

        grossShareValue_ = __calcGrossShareValue(
            gav,
            ERC20(vaultProxy).totalSupply(),
            10**uint256(ERC20(denominationAsset).decimals())
        );

        return (grossShareValue_, isValid_);
    }

    function __calcGrossShareValue(
        uint256 _gav,
        uint256 _sharesSupply,
        uint256 _denominationAssetUnit
    ) private pure returns (uint256 grossShareValue_) {
        if (_sharesSupply == 0) {
            return _denominationAssetUnit;
        }

        return _gav.mul(SHARES_UNIT).div(_sharesSupply);
    }



    function buyShares(
        address[] calldata _buyers,
        uint256[] calldata _investmentAmounts,
        uint256[] calldata _minSharesQuantities
    )
        external
        onlyNotPaused
        locksReentrance
        allowsPermissionedVaultAction
        returns (uint256[] memory sharesReceivedAmounts_)
    {
        require(_buyers.length > 0, "buyShares: Empty _buyers");
        require(
            _buyers.length == _investmentAmounts.length &&
                _buyers.length == _minSharesQuantities.length,
            "buyShares: Unequal arrays"
        );

        address vaultProxyCopy = vaultProxy;
        __assertIsActive(vaultProxyCopy);
        require(
            !IDispatcher(DISPATCHER).hasMigrationRequest(vaultProxyCopy),
            "buyShares: Pending migration"
        );

        (uint256 gav, bool gavIsValid) = calcGav(true);
        require(gavIsValid, "buyShares: Invalid GAV");

        __buySharesSetupHook(msg.sender, _investmentAmounts, gav);

        address denominationAssetCopy = denominationAsset;
        uint256 sharePrice = __calcGrossShareValue(
            gav,
            ERC20(vaultProxyCopy).totalSupply(),
            10**uint256(ERC20(denominationAssetCopy).decimals())
        );

        sharesReceivedAmounts_ = new uint256[](_buyers.length);
        for (uint256 i; i < _buyers.length; i++) {
            sharesReceivedAmounts_[i] = __buyShares(
                _buyers[i],
                _investmentAmounts[i],
                _minSharesQuantities[i],
                vaultProxyCopy,
                sharePrice,
                gav,
                denominationAssetCopy
            );

            gav = gav.add(_investmentAmounts[i]);
        }

        __buySharesCompletedHook(msg.sender, sharesReceivedAmounts_, gav);

        return sharesReceivedAmounts_;
    }

    function __buyShares(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _minSharesQuantity,
        address _vaultProxy,
        uint256 _sharePrice,
        uint256 _preBuySharesGav,
        address _denominationAsset
    ) private timelockedSharesAction(_buyer) returns (uint256 sharesReceived_) {
        require(_investmentAmount > 0, "__buyShares: Empty _investmentAmount");

        __preBuySharesHook(_buyer, _investmentAmount, _minSharesQuantity, _preBuySharesGav);

        uint256 sharesIssued = _investmentAmount.mul(SHARES_UNIT).div(_sharePrice);

        uint256 prevBuyerShares = ERC20(_vaultProxy).balanceOf(_buyer);
        IVault(_vaultProxy).mintShares(_buyer, sharesIssued);

        ERC20(_denominationAsset).safeTransferFrom(msg.sender, _vaultProxy, _investmentAmount);

        __postBuySharesHook(_buyer, _investmentAmount, sharesIssued, _preBuySharesGav);

        sharesReceived_ = ERC20(_vaultProxy).balanceOf(_buyer).sub(prevBuyerShares);
        require(
            sharesReceived_ >= _minSharesQuantity,
            "__buyShares: Shares received < _minSharesQuantity"
        );

        emit SharesBought(msg.sender, _buyer, _investmentAmount, sharesIssued, sharesReceived_);

        return sharesReceived_;
    }

    function __buySharesCompletedHook(
        address _caller,
        uint256[] memory _sharesReceivedAmounts,
        uint256 _gav
    ) private {
        IPolicyManager(POLICY_MANAGER).validatePolicies(
            address(this),
            IPolicyManager.PolicyHook.BuySharesCompleted,
            abi.encode(_caller, _sharesReceivedAmounts, _gav)
        );

        IFeeManager(FEE_MANAGER).invokeHook(
            IFeeManager.FeeHook.BuySharesCompleted,
            abi.encode(_caller, _sharesReceivedAmounts),
            _gav
        );
    }

    function __buySharesSetupHook(
        address _caller,
        uint256[] memory _investmentAmounts,
        uint256 _gav
    ) private {
        IPolicyManager(POLICY_MANAGER).validatePolicies(
            address(this),
            IPolicyManager.PolicyHook.BuySharesSetup,
            abi.encode(_caller, _investmentAmounts, _gav)
        );

        IFeeManager(FEE_MANAGER).invokeHook(
            IFeeManager.FeeHook.BuySharesSetup,
            abi.encode(_caller, _investmentAmounts),
            _gav
        );
    }

    function __preBuySharesHook(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _minSharesQuantity,
        uint256 _gav
    ) private {
        IFeeManager(FEE_MANAGER).invokeHook(
            IFeeManager.FeeHook.PreBuyShares,
            abi.encode(_buyer, _investmentAmount, _minSharesQuantity),
            _gav
        );

        IPolicyManager(POLICY_MANAGER).validatePolicies(
            address(this),
            IPolicyManager.PolicyHook.PreBuyShares,
            abi.encode(_buyer, _investmentAmount, _minSharesQuantity, _gav)
        );
    }

    function __postBuySharesHook(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _sharesIssued,
        uint256 _preBuySharesGav
    ) private {
        uint256 gav = _preBuySharesGav.add(_investmentAmount);
        IFeeManager(FEE_MANAGER).invokeHook(
            IFeeManager.FeeHook.PostBuyShares,
            abi.encode(_buyer, _investmentAmount, _sharesIssued),
            gav
        );

        IPolicyManager(POLICY_MANAGER).validatePolicies(
            address(this),
            IPolicyManager.PolicyHook.PostBuyShares,
            abi.encode(_buyer, _investmentAmount, _sharesIssued, gav)
        );
    }


    function redeemShares()
        external
        returns (address[] memory payoutAssets_, uint256[] memory payoutAmounts_)
    {
        return
            __redeemShares(
                msg.sender,
                ERC20(vaultProxy).balanceOf(msg.sender),
                new address[](0),
                new address[](0)
            );
    }

    function redeemSharesDetailed(
        uint256 _sharesQuantity,
        address[] calldata _additionalAssets,
        address[] calldata _assetsToSkip
    ) external returns (address[] memory payoutAssets_, uint256[] memory payoutAmounts_) {
        return __redeemShares(msg.sender, _sharesQuantity, _additionalAssets, _assetsToSkip);
    }

    function __parseRedemptionPayoutAssets(
        address[] memory _trackedAssets,
        address[] memory _additionalAssets,
        address[] memory _assetsToSkip
    ) private pure returns (address[] memory payoutAssets_) {
        address[] memory trackedAssetsToPayout = _trackedAssets.removeItems(_assetsToSkip);
        if (_additionalAssets.length == 0) {
            return trackedAssetsToPayout;
        }

        bool[] memory indexesToAdd = new bool[](_additionalAssets.length);
        uint256 additionalItemsCount;
        for (uint256 i; i < _additionalAssets.length; i++) {
            if (!trackedAssetsToPayout.contains(_additionalAssets[i])) {
                indexesToAdd[i] = true;
                additionalItemsCount++;
            }
        }
        if (additionalItemsCount == 0) {
            return trackedAssetsToPayout;
        }

        payoutAssets_ = new address[](trackedAssetsToPayout.length.add(additionalItemsCount));
        for (uint256 i; i < trackedAssetsToPayout.length; i++) {
            payoutAssets_[i] = trackedAssetsToPayout[i];
        }
        uint256 payoutAssetsIndex = trackedAssetsToPayout.length;
        for (uint256 i; i < _additionalAssets.length; i++) {
            if (indexesToAdd[i]) {
                payoutAssets_[payoutAssetsIndex] = _additionalAssets[i];
                payoutAssetsIndex++;
            }
        }

        return payoutAssets_;
    }

    function __preRedeemSharesHook(address _redeemer, uint256 _sharesQuantity)
        private
        allowsPermissionedVaultAction
    {
        try
            IFeeManager(FEE_MANAGER).invokeHook(
                IFeeManager.FeeHook.PreRedeemShares,
                abi.encode(_redeemer, _sharesQuantity),
                0
            )
         {} catch (bytes memory reason) {
            emit PreRedeemSharesHookFailed(reason, _redeemer, _sharesQuantity);
        }
    }

    function __redeemShares(
        address _redeemer,
        uint256 _sharesQuantity,
        address[] memory _additionalAssets,
        address[] memory _assetsToSkip
    )
        private
        locksReentrance
        returns (address[] memory payoutAssets_, uint256[] memory payoutAmounts_)
    {
        require(_sharesQuantity > 0, "__redeemShares: _sharesQuantity must be >0");
        require(
            _additionalAssets.isUniqueSet(),
            "__redeemShares: _additionalAssets contains duplicates"
        );
        require(_assetsToSkip.isUniqueSet(), "__redeemShares: _assetsToSkip contains duplicates");

        IVault vaultProxyContract = IVault(vaultProxy);

        if (!IDispatcher(DISPATCHER).hasMigrationRequest(address(vaultProxyContract))) {
            __assertSharesActionNotTimelocked(_redeemer);
            acctToLastSharesAction[_redeemer] = block.timestamp;
        }

        if (!__fundIsPaused()) {
            __preRedeemSharesHook(_redeemer, _sharesQuantity);
        }

        ERC20 sharesContract = ERC20(address(vaultProxyContract));
        require(
            _sharesQuantity <= sharesContract.balanceOf(_redeemer),
            "__redeemShares: Insufficient shares"
        );

        payoutAssets_ = __parseRedemptionPayoutAssets(
            vaultProxyContract.getTrackedAssets(),
            _additionalAssets,
            _assetsToSkip
        );
        require(payoutAssets_.length > 0, "__redeemShares: No payout assets");

        uint256 sharesSupply = sharesContract.totalSupply();
        vaultProxyContract.burnShares(_redeemer, _sharesQuantity);

        payoutAmounts_ = new uint256[](payoutAssets_.length);
        address denominationAssetCopy = denominationAsset;
        for (uint256 i; i < payoutAssets_.length; i++) {
            uint256 assetBalance = __finalizeIfSynthAndGetAssetBalance(
                address(vaultProxyContract),
                payoutAssets_[i],
                true
            );

            if (_sharesQuantity == sharesSupply) {
                payoutAmounts_[i] = assetBalance;
                if (payoutAssets_[i] != denominationAssetCopy) {
                    vaultProxyContract.removeTrackedAsset(payoutAssets_[i]);
                }
            } else {
                payoutAmounts_[i] = assetBalance.mul(_sharesQuantity).div(sharesSupply);
            }

            if (payoutAmounts_[i] > 0) {
                vaultProxyContract.withdrawAssetTo(payoutAssets_[i], _redeemer, payoutAmounts_[i]);
            }
        }

        emit SharesRedeemed(_redeemer, _sharesQuantity, payoutAssets_, payoutAmounts_);

        return (payoutAssets_, payoutAmounts_);
    }


    function getDenominationAsset() external view override returns (address denominationAsset_) {
        return denominationAsset;
    }

    function getLibRoutes()
        external
        view
        returns (
            address dispatcher_,
            address feeManager_,
            address fundDeployer_,
            address integrationManager_,
            address policyManager_,
            address primitivePriceFeed_,
            address valueInterpreter_
        )
    {
        return (
            DISPATCHER,
            FEE_MANAGER,
            FUND_DEPLOYER,
            INTEGRATION_MANAGER,
            POLICY_MANAGER,
            PRIMITIVE_PRICE_FEED,
            VALUE_INTERPRETER
        );
    }

    function getOverridePause() external view returns (bool overridePause_) {
        return overridePause;
    }

    function getSharesActionTimelock() external view returns (uint256 sharesActionTimelock_) {
        return sharesActionTimelock;
    }

    function getVaultProxy() external view override returns (address vaultProxy_) {
        return vaultProxy;
    }
}// GPL-3.0


pragma solidity 0.6.12;

abstract contract ProxiableVaultLib {
    function __updateCodeAddress(address _nextVaultLib) internal {
        require(
            bytes32(0x027b9570e9fedc1a80b937ae9a06861e5faef3992491af30b684a64b3fbec7a5) ==
                ProxiableVaultLib(_nextVaultLib).proxiableUUID(),
            "__updateCodeAddress: _nextVaultLib not compatible"
        );
        assembly {
            sstore(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
                _nextVaultLib
            )
        }
    }

    function proxiableUUID() public pure returns (bytes32 uuid_) {
        return 0x027b9570e9fedc1a80b937ae9a06861e5faef3992491af30b684a64b3fbec7a5;
    }
}// GPL-3.0


pragma solidity 0.6.12;

library VaultLibSafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "VaultLibSafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "VaultLibSafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "VaultLibSafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "VaultLibSafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "VaultLibSafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract SharesTokenBase {
    using VaultLibSafeMath for uint256;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    string internal sharesName;
    string internal sharesSymbol;
    uint256 internal sharesTotalSupply;
    mapping(address => uint256) internal sharesBalances;
    mapping(address => mapping(address => uint256)) internal sharesAllowances;


    function approve(address _spender, uint256 _amount) public virtual returns (bool) {
        __approve(msg.sender, _spender, _amount);
        return true;
    }

    function transfer(address _recipient, uint256 _amount) public virtual returns (bool) {
        __transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public virtual returns (bool) {
        __transfer(_sender, _recipient, _amount);
        __approve(
            _sender,
            msg.sender,
            sharesAllowances[_sender][msg.sender].sub(
                _amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function allowance(address _owner, address _spender) public view virtual returns (uint256) {
        return sharesAllowances[_owner][_spender];
    }

    function balanceOf(address _account) public view virtual returns (uint256) {
        return sharesBalances[_account];
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function name() public view virtual returns (string memory) {
        return sharesName;
    }

    function symbol() public view virtual returns (string memory) {
        return sharesSymbol;
    }

    function totalSupply() public view virtual returns (uint256) {
        return sharesTotalSupply;
    }


    function __approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        sharesAllowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function __burn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "ERC20: burn from the zero address");

        sharesBalances[_account] = sharesBalances[_account].sub(
            _amount,
            "ERC20: burn amount exceeds balance"
        );
        sharesTotalSupply = sharesTotalSupply.sub(_amount);
        emit Transfer(_account, address(0), _amount);
    }

    function __mint(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "ERC20: mint to the zero address");

        sharesTotalSupply = sharesTotalSupply.add(_amount);
        sharesBalances[_account] = sharesBalances[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }

    function __transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal virtual {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");

        sharesBalances[_sender] = sharesBalances[_sender].sub(
            _amount,
            "ERC20: transfer amount exceeds balance"
        );
        sharesBalances[_recipient] = sharesBalances[_recipient].add(_amount);
        emit Transfer(_sender, _recipient, _amount);
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract VaultLibBaseCore is IMigratableVault, ProxiableVaultLib, SharesTokenBase {
    event AccessorSet(address prevAccessor, address nextAccessor);

    event MigratorSet(address prevMigrator, address nextMigrator);

    event OwnerSet(address prevOwner, address nextOwner);

    event VaultLibSet(address prevVaultLib, address nextVaultLib);

    address internal accessor;
    address internal creator;
    address internal migrator;
    address internal owner;


    function init(
        address _owner,
        address _accessor,
        string calldata _fundName
    ) external override {
        require(creator == address(0), "init: Proxy already initialized");
        creator = msg.sender;
        sharesName = _fundName;

        __setAccessor(_accessor);
        __setOwner(_owner);

        emit VaultLibSet(address(0), getVaultLib());
    }

    function setAccessor(address _nextAccessor) external override {
        require(msg.sender == creator, "setAccessor: Only callable by the contract creator");

        __setAccessor(_nextAccessor);
    }

    function setVaultLib(address _nextVaultLib) external override {
        require(msg.sender == creator, "setVaultLib: Only callable by the contract creator");

        address prevVaultLib = getVaultLib();

        __updateCodeAddress(_nextVaultLib);

        emit VaultLibSet(prevVaultLib, _nextVaultLib);
    }


    function canMigrate(address _who) public view virtual override returns (bool canMigrate_) {
        return _who == owner || _who == migrator;
    }

    function getVaultLib() public view returns (address vaultLib_) {
        assembly {
            vaultLib_ := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }
        return vaultLib_;
    }


    function __setAccessor(address _nextAccessor) internal {
        require(_nextAccessor != address(0), "__setAccessor: _nextAccessor cannot be empty");
        address prevAccessor = accessor;

        accessor = _nextAccessor;

        emit AccessorSet(prevAccessor, _nextAccessor);
    }

    function __setOwner(address _nextOwner) internal {
        require(_nextOwner != address(0), "__setOwner: _nextOwner cannot be empty");
        address prevOwner = owner;
        require(_nextOwner != prevOwner, "__setOwner: _nextOwner is the current owner");

        owner = _nextOwner;

        emit OwnerSet(prevOwner, _nextOwner);
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract VaultLibBase1 is VaultLibBaseCore {
    event AssetWithdrawn(address indexed asset, address indexed target, uint256 amount);

    event TrackedAssetAdded(address asset);

    event TrackedAssetRemoved(address asset);

    address[] internal trackedAssets;
    mapping(address => bool) internal assetToIsTracked;
}// GPL-3.0


pragma solidity 0.6.12;


contract VaultLib is VaultLibBase1, IVault {
    using SafeERC20 for ERC20;

    uint256 private constant TRACKED_ASSETS_LIMIT = 20;

    modifier onlyAccessor() {
        require(msg.sender == accessor, "Only the designated accessor can make this call");
        _;
    }


    function setMigrator(address _nextMigrator) external {
        require(msg.sender == owner, "setMigrator: Only the owner can call this function");
        address prevMigrator = migrator;
        require(_nextMigrator != prevMigrator, "setMigrator: Value already set");

        migrator = _nextMigrator;

        emit MigratorSet(prevMigrator, _nextMigrator);
    }


    function addTrackedAsset(address _asset) external override onlyAccessor {
        if (!isTrackedAsset(_asset)) {
            require(
                trackedAssets.length < TRACKED_ASSETS_LIMIT,
                "addTrackedAsset: Limit exceeded"
            );

            assetToIsTracked[_asset] = true;
            trackedAssets.push(_asset);

            emit TrackedAssetAdded(_asset);
        }
    }

    function approveAssetSpender(
        address _asset,
        address _target,
        uint256 _amount
    ) external override onlyAccessor {
        ERC20(_asset).approve(_target, _amount);
    }

    function callOnContract(address _contract, bytes calldata _callData)
        external
        override
        onlyAccessor
    {
        (bool success, bytes memory returnData) = _contract.call(_callData);
        require(success, string(returnData));
    }

    function removeTrackedAsset(address _asset) external override onlyAccessor {
        __removeTrackedAsset(_asset);
    }

    function withdrawAssetTo(
        address _asset,
        address _target,
        uint256 _amount
    ) external override onlyAccessor {
        ERC20(_asset).safeTransfer(_target, _amount);

        emit AssetWithdrawn(_asset, _target, _amount);
    }

    function __getAssetBalance(address _asset) private view returns (uint256 balance_) {
        return ERC20(_asset).balanceOf(address(this));
    }

    function __removeTrackedAsset(address _asset) private {
        if (isTrackedAsset(_asset)) {
            assetToIsTracked[_asset] = false;

            uint256 trackedAssetsCount = trackedAssets.length;
            for (uint256 i = 0; i < trackedAssetsCount; i++) {
                if (trackedAssets[i] == _asset) {
                    if (i < trackedAssetsCount - 1) {
                        trackedAssets[i] = trackedAssets[trackedAssetsCount - 1];
                    }
                    trackedAssets.pop();
                    break;
                }
            }

            emit TrackedAssetRemoved(_asset);
        }
    }


    function burnShares(address _target, uint256 _amount) external override onlyAccessor {
        __burn(_target, _amount);
    }

    function mintShares(address _target, uint256 _amount) external override onlyAccessor {
        __mint(_target, _amount);
    }

    function transferShares(
        address _from,
        address _to,
        uint256 _amount
    ) external override onlyAccessor {
        __transfer(_from, _to, _amount);
    }


    function approve(address, uint256) public override returns (bool) {
        revert("Unimplemented");
    }

    function symbol() public view override returns (string memory symbol_) {
        return IDispatcher(creator).getSharesTokenSymbol();
    }

    function transfer(address, uint256) public override returns (bool) {
        revert("Unimplemented");
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public override returns (bool) {
        revert("Unimplemented");
    }


    function getAccessor() external view override returns (address accessor_) {
        return accessor;
    }

    function getCreator() external view returns (address creator_) {
        return creator;
    }

    function getMigrator() external view returns (address migrator_) {
        return migrator;
    }

    function getOwner() external view override returns (address owner_) {
        return owner;
    }

    function getTrackedAssets() external view override returns (address[] memory trackedAssets_) {
        return trackedAssets;
    }

    function isTrackedAsset(address _asset) public view override returns (bool isTrackedAsset_) {
        return assetToIsTracked[_asset];
    }
}// GPL-3.0


pragma solidity 0.6.12;


interface IAggregatedDerivativePriceFeed is IDerivativePriceFeed {
    function getPriceFeedForDerivative(address) external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;


contract ValueInterpreter is IValueInterpreter {
    using SafeMath for uint256;

    address private immutable AGGREGATED_DERIVATIVE_PRICE_FEED;
    address private immutable PRIMITIVE_PRICE_FEED;

    constructor(address _primitivePriceFeed, address _aggregatedDerivativePriceFeed) public {
        AGGREGATED_DERIVATIVE_PRICE_FEED = _aggregatedDerivativePriceFeed;
        PRIMITIVE_PRICE_FEED = _primitivePriceFeed;
    }


    function calcLiveAssetsTotalValue(
        address[] calldata _baseAssets,
        uint256[] calldata _amounts,
        address _quoteAsset
    ) external override returns (uint256 value_, bool isValid_) {
        return calcCanonicalAssetsTotalValue(_baseAssets, _amounts, _quoteAsset);
    }

    function calcLiveAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) external override returns (uint256 value_, bool isValid_) {
        return calcCanonicalAssetValue(_baseAsset, _amount, _quoteAsset);
    }


    function calcCanonicalAssetsTotalValue(
        address[] memory _baseAssets,
        uint256[] memory _amounts,
        address _quoteAsset
    ) public override returns (uint256 value_, bool isValid_) {
        require(
            _baseAssets.length == _amounts.length,
            "calcCanonicalAssetsTotalValue: Arrays unequal lengths"
        );
        require(
            IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).isSupportedAsset(_quoteAsset),
            "calcCanonicalAssetsTotalValue: Unsupported _quoteAsset"
        );

        isValid_ = true;
        for (uint256 i; i < _baseAssets.length; i++) {
            (uint256 assetValue, bool assetValueIsValid) = __calcAssetValue(
                _baseAssets[i],
                _amounts[i],
                _quoteAsset
            );
            value_ = value_.add(assetValue);
            if (!assetValueIsValid) {
                isValid_ = false;
            }
        }

        return (value_, isValid_);
    }

    function calcCanonicalAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) public override returns (uint256 value_, bool isValid_) {
        if (_baseAsset == _quoteAsset || _amount == 0) {
            return (_amount, true);
        }

        require(
            IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).isSupportedAsset(_quoteAsset),
            "calcCanonicalAssetValue: Unsupported _quoteAsset"
        );

        return __calcAssetValue(_baseAsset, _amount, _quoteAsset);
    }


    function __calcAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) private returns (uint256 value_, bool isValid_) {
        if (_baseAsset == _quoteAsset || _amount == 0) {
            return (_amount, true);
        }

        if (IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).isSupportedAsset(_baseAsset)) {
            return
                IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).calcCanonicalValue(
                    _baseAsset,
                    _amount,
                    _quoteAsset
                );
        }

        address derivativePriceFeed = IAggregatedDerivativePriceFeed(
            AGGREGATED_DERIVATIVE_PRICE_FEED
        )
            .getPriceFeedForDerivative(_baseAsset);
        if (derivativePriceFeed != address(0)) {
            return __calcDerivativeValue(derivativePriceFeed, _baseAsset, _amount, _quoteAsset);
        }

        revert("__calcAssetValue: Unsupported _baseAsset");
    }

    function __calcDerivativeValue(
        address _derivativePriceFeed,
        address _derivative,
        uint256 _amount,
        address _quoteAsset
    ) private returns (uint256 value_, bool isValid_) {
        (address[] memory underlyings, uint256[] memory underlyingAmounts) = IDerivativePriceFeed(
            _derivativePriceFeed
        )
            .calcUnderlyingValues(_derivative, _amount);

        require(underlyings.length > 0, "__calcDerivativeValue: No underlyings");
        require(
            underlyings.length == underlyingAmounts.length,
            "__calcDerivativeValue: Arrays unequal lengths"
        );

        isValid_ = true;
        for (uint256 i = 0; i < underlyings.length; i++) {
            (uint256 underlyingValue, bool underlyingValueIsValid) = __calcAssetValue(
                underlyings[i],
                underlyingAmounts[i],
                _quoteAsset
            );

            if (!underlyingValueIsValid) {
                isValid_ = false;
            }
            value_ = value_.add(underlyingValue);
        }
    }


    function getAggregatedDerivativePriceFeed()
        external
        view
        returns (address aggregatedDerivativePriceFeed_)
    {
        return AGGREGATED_DERIVATIVE_PRICE_FEED;
    }

    function getPrimitivePriceFeed() external view returns (address primitivePriceFeed_) {
        return PRIMITIVE_PRICE_FEED;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MaxConcentration is PostCallOnIntegrationValidatePolicyBase {
    using SafeMath for uint256;

    event MaxConcentrationSet(address indexed comptrollerProxy, uint256 value);

    uint256 private constant ONE_HUNDRED_PERCENT = 10**18; // 100%

    address private immutable VALUE_INTERPRETER;

    mapping(address => uint256) private comptrollerProxyToMaxConcentration;

    constructor(address _policyManager, address _valueInterpreter)
        public
        PolicyBase(_policyManager)
    {
        VALUE_INTERPRETER = _valueInterpreter;
    }

    function activateForFund(address _comptrollerProxy, address _vaultProxy)
        external
        override
        onlyPolicyManager
    {
        require(
            passesRule(_comptrollerProxy, _vaultProxy, VaultLib(_vaultProxy).getTrackedAssets()),
            "activateForFund: Max concentration exceeded"
        );
    }

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        uint256 maxConcentration = abi.decode(_encodedSettings, (uint256));
        require(maxConcentration > 0, "addFundSettings: maxConcentration must be greater than 0");
        require(
            maxConcentration <= ONE_HUNDRED_PERCENT,
            "addFundSettings: maxConcentration cannot exceed 100%"
        );

        comptrollerProxyToMaxConcentration[_comptrollerProxy] = maxConcentration;

        emit MaxConcentrationSet(_comptrollerProxy, maxConcentration);
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "MAX_CONCENTRATION";
    }

    function passesRule(
        address _comptrollerProxy,
        address _vaultProxy,
        address[] memory _assets
    ) public returns (bool isValid_) {
        uint256 maxConcentration = comptrollerProxyToMaxConcentration[_comptrollerProxy];
        ComptrollerLib comptrollerProxyContract = ComptrollerLib(_comptrollerProxy);
        address denominationAsset = comptrollerProxyContract.getDenominationAsset();
        (uint256 totalGav, bool gavIsValid) = comptrollerProxyContract.calcGav(false);
        if (!gavIsValid) {
            return false;
        }

        for (uint256 i = 0; i < _assets.length; i++) {
            address asset = _assets[i];
            if (
                !__rulePassesForAsset(
                    _vaultProxy,
                    denominationAsset,
                    maxConcentration,
                    totalGav,
                    asset
                )
            ) {
                return false;
            }
        }

        return true;
    }

    function validateRule(
        address _comptrollerProxy,
        address _vaultProxy,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override returns (bool isValid_) {
        (, , address[] memory incomingAssets, , , ) = __decodeRuleArgs(_encodedArgs);
        if (incomingAssets.length == 0) {
            return true;
        }

        return passesRule(_comptrollerProxy, _vaultProxy, incomingAssets);
    }

    function __rulePassesForAsset(
        address _vaultProxy,
        address _denominationAsset,
        uint256 _maxConcentration,
        uint256 _totalGav,
        address _incomingAsset
    ) private returns (bool isValid_) {
        if (_incomingAsset == _denominationAsset) return true;

        uint256 assetBalance = ERC20(_incomingAsset).balanceOf(_vaultProxy);
        (uint256 assetGav, bool assetGavIsValid) = ValueInterpreter(VALUE_INTERPRETER)
            .calcLiveAssetValue(_incomingAsset, assetBalance, _denominationAsset);

        if (
            !assetGavIsValid ||
            assetGav.mul(ONE_HUNDRED_PERCENT).div(_totalGav) > _maxConcentration
        ) {
            return false;
        }

        return true;
    }


    function getMaxConcentrationForFund(address _comptrollerProxy)
        external
        view
        returns (uint256 maxConcentration_)
    {
        return comptrollerProxyToMaxConcentration[_comptrollerProxy];
    }

    function getValueInterpreter() external view returns (address valueInterpreter_) {
        return VALUE_INTERPRETER;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        );

    function kLast() external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint256);
}// GPL-3.0


pragma solidity 0.6.12;

interface IUniswapV2Factory {
    function feeTo() external view returns (address);

    function getPair(address, address) external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract UniswapV2PoolTokenValueCalculator {
    using SafeMath for uint256;

    uint256 private constant POOL_TOKEN_UNIT = 10**18;


    function __calcTrustedPoolTokenValue(
        address _factory,
        address _pair,
        uint256 _token0TrustedRateAmount,
        uint256 _token1TrustedRateAmount
    ) internal view returns (uint256 token0Amount_, uint256 token1Amount_) {
        (uint256 reserve0, uint256 reserve1) = __calcReservesAfterArbitrage(
            _pair,
            _token0TrustedRateAmount,
            _token1TrustedRateAmount
        );

        return __calcPoolTokenValue(_factory, _pair, reserve0, reserve1);
    }


    function __calcPoolTokenValue(
        address _factory,
        address _pair,
        uint256 _reserve0,
        uint256 _reserve1
    ) private view returns (uint256 token0Amount_, uint256 token1Amount_) {
        IUniswapV2Pair pairContract = IUniswapV2Pair(_pair);
        uint256 totalSupply = pairContract.totalSupply();

        if (IUniswapV2Factory(_factory).feeTo() != address(0)) {
            uint256 kLast = pairContract.kLast();
            if (kLast > 0) {
                uint256 rootK = __uniswapSqrt(_reserve0.mul(_reserve1));
                uint256 rootKLast = __uniswapSqrt(kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint256 denominator = rootK.mul(5).add(rootKLast);
                    uint256 feeLiquidity = numerator.div(denominator);
                    totalSupply = totalSupply.add(feeLiquidity);
                }
            }
        }
        return (
            _reserve0.mul(POOL_TOKEN_UNIT).div(totalSupply),
            _reserve1.mul(POOL_TOKEN_UNIT).div(totalSupply)
        );
    }

    function __calcProfitMaximizingTrade(
        uint256 _token0TrustedRateAmount,
        uint256 _token1TrustedRateAmount,
        uint256 _reserve0,
        uint256 _reserve1
    ) private pure returns (bool token0ToToken1_, uint256 amountIn_) {
        token0ToToken1_ =
            _reserve0.mul(_token1TrustedRateAmount).div(_reserve1) < _token0TrustedRateAmount;

        uint256 leftSide;
        uint256 rightSide;
        if (token0ToToken1_) {
            leftSide = __uniswapSqrt(
                _reserve0.mul(_reserve1).mul(_token0TrustedRateAmount).mul(1000).div(
                    _token1TrustedRateAmount.mul(997)
                )
            );
            rightSide = _reserve0.mul(1000).div(997);
        } else {
            leftSide = __uniswapSqrt(
                _reserve0.mul(_reserve1).mul(_token1TrustedRateAmount).mul(1000).div(
                    _token0TrustedRateAmount.mul(997)
                )
            );
            rightSide = _reserve1.mul(1000).div(997);
        }

        if (leftSide < rightSide) {
            return (false, 0);
        }

        amountIn_ = leftSide.sub(rightSide);

        return (token0ToToken1_, amountIn_);
    }

    function __calcReservesAfterArbitrage(
        address _pair,
        uint256 _token0TrustedRateAmount,
        uint256 _token1TrustedRateAmount
    ) private view returns (uint256 reserve0_, uint256 reserve1_) {
        (reserve0_, reserve1_, ) = IUniswapV2Pair(_pair).getReserves();


        (bool token0ToToken1, uint256 amountIn) = __calcProfitMaximizingTrade(
            _token0TrustedRateAmount,
            _token1TrustedRateAmount,
            reserve0_,
            reserve1_
        );
        if (amountIn == 0) {
            return (reserve0_, reserve1_);
        }

        if (token0ToToken1) {
            uint256 amountOut = __uniswapV2GetAmountOut(amountIn, reserve0_, reserve1_);
            reserve0_ = reserve0_.add(amountIn);
            reserve1_ = reserve1_.sub(amountOut);
        } else {
            uint256 amountOut = __uniswapV2GetAmountOut(amountIn, reserve1_, reserve0_);
            reserve1_ = reserve1_.add(amountIn);
            reserve0_ = reserve0_.sub(amountOut);
        }

        return (reserve0_, reserve1_);
    }

    function __uniswapSqrt(uint256 _y) private pure returns (uint256 z_) {
        if (_y > 3) {
            z_ = _y;
            uint256 x = _y / 2 + 1;
            while (x < z_) {
                z_ = x;
                x = (_y / x + x) / 2;
            }
        } else if (_y != 0) {
            z_ = 1;
        }

        return z_;
    }

    function __uniswapV2GetAmountOut(
        uint256 _amountIn,
        uint256 _reserveIn,
        uint256 _reserveOut
    ) private pure returns (uint256 amountOut_) {
        uint256 amountInWithFee = _amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(_reserveOut);
        uint256 denominator = _reserveIn.mul(1000).add(amountInWithFee);

        return numerator.div(denominator);
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract UniswapV2PoolPriceFeed is
    IDerivativePriceFeed,
    DispatcherOwnerMixin,
    MathHelpers,
    UniswapV2PoolTokenValueCalculator
{
    event PoolTokenAdded(address indexed poolToken, address token0, address token1);

    struct PoolTokenInfo {
        address token0;
        address token1;
        uint8 token0Decimals;
        uint8 token1Decimals;
    }

    uint256 private constant POOL_TOKEN_UNIT = 10**18;
    address private immutable DERIVATIVE_PRICE_FEED;
    address private immutable FACTORY;
    address private immutable PRIMITIVE_PRICE_FEED;
    address private immutable VALUE_INTERPRETER;

    mapping(address => PoolTokenInfo) private poolTokenToInfo;

    constructor(
        address _dispatcher,
        address _derivativePriceFeed,
        address _primitivePriceFeed,
        address _valueInterpreter,
        address _factory,
        address[] memory _poolTokens
    ) public DispatcherOwnerMixin(_dispatcher) {
        DERIVATIVE_PRICE_FEED = _derivativePriceFeed;
        FACTORY = _factory;
        PRIMITIVE_PRICE_FEED = _primitivePriceFeed;
        VALUE_INTERPRETER = _valueInterpreter;

        __addPoolTokens(_poolTokens, _derivativePriceFeed, _primitivePriceFeed);
    }

    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        PoolTokenInfo memory poolTokenInfo = poolTokenToInfo[_derivative];

        underlyings_ = new address[](2);
        underlyings_[0] = poolTokenInfo.token0;
        underlyings_[1] = poolTokenInfo.token1;

        (uint256 token0TrustedRateAmount, uint256 token1TrustedRateAmount) = __calcTrustedRate(
            poolTokenInfo.token0,
            poolTokenInfo.token1,
            poolTokenInfo.token0Decimals,
            poolTokenInfo.token1Decimals
        );

        (
            uint256 token0DenormalizedRate,
            uint256 token1DenormalizedRate
        ) = __calcTrustedPoolTokenValue(
            FACTORY,
            _derivative,
            token0TrustedRateAmount,
            token1TrustedRateAmount
        );

        underlyingAmounts_ = new uint256[](2);
        underlyingAmounts_[0] = _derivativeAmount.mul(token0DenormalizedRate).div(POOL_TOKEN_UNIT);
        underlyingAmounts_[1] = _derivativeAmount.mul(token1DenormalizedRate).div(POOL_TOKEN_UNIT);

        return (underlyings_, underlyingAmounts_);
    }

    function isSupportedAsset(address _asset) public view override returns (bool isSupported_) {
        return poolTokenToInfo[_asset].token0 != address(0);
    }


    function __calcTrustedRate(
        address _token0,
        address _token1,
        uint256 _token0Decimals,
        uint256 _token1Decimals
    ) private returns (uint256 token0RateAmount_, uint256 token1RateAmount_) {
        bool rateIsValid;
        if (IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).isSupportedAsset(_token0)) {
            token1RateAmount_ = 10**_token1Decimals;
            (token0RateAmount_, rateIsValid) = ValueInterpreter(VALUE_INTERPRETER)
                .calcCanonicalAssetValue(_token1, token1RateAmount_, _token0);
        } else {
            token0RateAmount_ = 10**_token0Decimals;
            (token1RateAmount_, rateIsValid) = ValueInterpreter(VALUE_INTERPRETER)
                .calcCanonicalAssetValue(_token0, token0RateAmount_, _token1);
        }

        require(rateIsValid, "__calcTrustedRate: Invalid rate");

        return (token0RateAmount_, token1RateAmount_);
    }


    function addPoolTokens(address[] calldata _poolTokens) external onlyDispatcherOwner {
        require(_poolTokens.length > 0, "addPoolTokens: Empty _poolTokens");

        __addPoolTokens(_poolTokens, DERIVATIVE_PRICE_FEED, PRIMITIVE_PRICE_FEED);
    }

    function __addPoolTokens(
        address[] memory _poolTokens,
        address _derivativePriceFeed,
        address _primitivePriceFeed
    ) private {
        for (uint256 i; i < _poolTokens.length; i++) {
            require(_poolTokens[i] != address(0), "__addPoolTokens: Empty poolToken");
            require(
                poolTokenToInfo[_poolTokens[i]].token0 == address(0),
                "__addPoolTokens: Value already set"
            );

            IUniswapV2Pair uniswapV2Pair = IUniswapV2Pair(_poolTokens[i]);
            address token0 = uniswapV2Pair.token0();
            address token1 = uniswapV2Pair.token1();

            require(
                __poolTokenIsSupportable(
                    _derivativePriceFeed,
                    _primitivePriceFeed,
                    token0,
                    token1
                ),
                "__addPoolTokens: Unsupported pool token"
            );

            poolTokenToInfo[_poolTokens[i]] = PoolTokenInfo({
                token0: token0,
                token1: token1,
                token0Decimals: ERC20(token0).decimals(),
                token1Decimals: ERC20(token1).decimals()
            });

            emit PoolTokenAdded(_poolTokens[i], token0, token1);
        }
    }

    function __poolTokenIsSupportable(
        address _derivativePriceFeed,
        address _primitivePriceFeed,
        address _token0,
        address _token1
    ) private view returns (bool isSupportable_) {
        IDerivativePriceFeed derivativePriceFeedContract = IDerivativePriceFeed(
            _derivativePriceFeed
        );
        IPrimitivePriceFeed primitivePriceFeedContract = IPrimitivePriceFeed(_primitivePriceFeed);

        if (primitivePriceFeedContract.isSupportedAsset(_token0)) {
            if (
                primitivePriceFeedContract.isSupportedAsset(_token1) ||
                derivativePriceFeedContract.isSupportedAsset(_token1)
            ) {
                return true;
            }
        } else if (
            derivativePriceFeedContract.isSupportedAsset(_token0) &&
            primitivePriceFeedContract.isSupportedAsset(_token1)
        ) {
            return true;
        }

        return false;
    }


    function getDerivativePriceFeed() external view returns (address derivativePriceFeed_) {
        return DERIVATIVE_PRICE_FEED;
    }

    function getFactory() external view returns (address factory_) {
        return FACTORY;
    }

    function getPoolTokenInfo(address _poolToken)
        external
        view
        returns (PoolTokenInfo memory poolTokenInfo_)
    {
        return poolTokenToInfo[_poolToken];
    }

    function getPoolTokenUnderlyings(address _poolToken)
        external
        view
        returns (address token0_, address token1_)
    {
        return (poolTokenToInfo[_poolToken].token0, poolTokenToInfo[_poolToken].token1);
    }

    function getPrimitivePriceFeed() external view returns (address primitivePriceFeed_) {
        return PRIMITIVE_PRICE_FEED;
    }

    function getValueInterpreter() external view returns (address valueInterpreter_) {
        return VALUE_INTERPRETER;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IChainlinkAggregator {
    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);
}// AGPL-3.0-or-later


pragma solidity 0.6.12;

abstract contract MakerDaoMath {
    function __rpow(uint256 _x, uint256 _n, uint256 _base) internal pure returns (uint256 z_) {
        assembly {
            switch _x case 0 {switch _n case 0 {z_ := _base} default {z_ := 0}}
            default {
                switch mod(_n, 2) case 0 { z_ := _base } default { z_ := _x }
                let half := div(_base, 2)
                for { _n := div(_n, 2) } _n { _n := div(_n,2) } {
                    let xx := mul(_x, _x)
                    if iszero(eq(div(xx, _x), _x)) { revert(0,0) }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) { revert(0,0) }
                    _x := div(xxRound, _base)
                    if mod(_n,2) {
                        let zx := mul(z_, _x)
                        if and(iszero(iszero(_x)), iszero(eq(div(zx, _x), z_))) { revert(0,0) }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) { revert(0,0) }
                        z_ := div(zxRound, _base)
                    }
                }
            }
        }

        return z_;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract WdgldPriceFeed is IDerivativePriceFeed, MakerDaoMath {
    using SafeMath for uint256;

    address private immutable XAU_AGGREGATOR;
    address private immutable ETH_AGGREGATOR;

    address private immutable WDGLD;
    address private immutable WETH;

    uint256 private constant GTR_CONSTANT = 999990821653213975346065101;
    uint256 private constant GTR_PRECISION = 10**27;
    uint256 private constant WDGLD_GENESIS_TIMESTAMP = 1568700000;

    constructor(
        address _wdgld,
        address _weth,
        address _ethAggregator,
        address _xauAggregator
    ) public {
        WDGLD = _wdgld;
        WETH = _weth;
        ETH_AGGREGATOR = _ethAggregator;
        XAU_AGGREGATOR = _xauAggregator;
    }

    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        require(isSupportedAsset(_derivative), "calcUnderlyingValues: Only WDGLD is supported");

        underlyings_ = new address[](1);
        underlyings_[0] = WETH;
        underlyingAmounts_ = new uint256[](1);

        int256 xauToUsdRate = IChainlinkAggregator(XAU_AGGREGATOR).latestAnswer();
        int256 ethToUsdRate = IChainlinkAggregator(ETH_AGGREGATOR).latestAnswer();
        require(xauToUsdRate > 0 && ethToUsdRate > 0, "calcUnderlyingValues: rate invalid");

        uint256 wdgldToXauRate = calcWdgldToXauRate();

        underlyingAmounts_[0] = _derivativeAmount
            .mul(wdgldToXauRate)
            .mul(uint256(xauToUsdRate))
            .div(uint256(ethToUsdRate))
            .div(10**17);

        return (underlyings_, underlyingAmounts_);
    }

    function calcWdgldToXauRate() public view returns (uint256 wdgldToXauRate_) {
        return
            __rpow(
                GTR_CONSTANT,
                ((block.timestamp).sub(WDGLD_GENESIS_TIMESTAMP)).div(28800), // 60 * 60 * 8 (8 hour periods)
                GTR_PRECISION
            )
                .div(10);
    }

    function isSupportedAsset(address _asset) public view override returns (bool isSupported_) {
        return _asset == WDGLD;
    }


    function getEthAggregator() external view returns (address ethAggregatorAddress_) {
        return ETH_AGGREGATOR;
    }

    function getWdgld() external view returns (address wdgld_) {
        return WDGLD;
    }

    function getWeth() external view returns (address weth_) {
        return WETH;
    }

    function getXauAggregator() external view returns (address xauAggregatorAddress_) {
        return XAU_AGGREGATOR;
    }
}// GPL-3.0


pragma solidity 0.6.12;


interface IFee {
    function activateForFund(address _comptrollerProxy, address _vaultProxy) external;

    function addFundSettings(address _comptrollerProxy, bytes calldata _settingsData) external;

    function identifier() external pure returns (string memory identifier_);

    function implementedHooks()
        external
        view
        returns (
            IFeeManager.FeeHook[] memory implementedHooksForSettle_,
            IFeeManager.FeeHook[] memory implementedHooksForUpdate_,
            bool usesGavOnSettle_,
            bool usesGavOnUpdate_
        );

    function payout(address _comptrollerProxy, address _vaultProxy)
        external
        returns (bool isPayable_);

    function settle(
        address _comptrollerProxy,
        address _vaultProxy,
        IFeeManager.FeeHook _hook,
        bytes calldata _settlementData,
        uint256 _gav
    )
        external
        returns (
            IFeeManager.SettlementType settlementType_,
            address payer_,
            uint256 sharesDue_
        );

    function update(
        address _comptrollerProxy,
        address _vaultProxy,
        IFeeManager.FeeHook _hook,
        bytes calldata _settlementData,
        uint256 _gav
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract FeeBase is IFee {
    address internal immutable FEE_MANAGER;

    modifier onlyFeeManager {
        require(msg.sender == FEE_MANAGER, "Only the FeeManger can make this call");
        _;
    }

    constructor(address _feeManager) public {
        FEE_MANAGER = _feeManager;
    }

    function activateForFund(address, address) external virtual override {
        return;
    }

    function payout(address, address) external virtual override returns (bool) {
        return false;
    }

    function update(
        address,
        address,
        IFeeManager.FeeHook,
        bytes calldata,
        uint256
    ) external virtual override {
        return;
    }

    function __decodePreBuySharesSettlementData(bytes memory _settlementData)
        internal
        pure
        returns (
            address buyer_,
            uint256 investmentAmount_,
            uint256 minSharesQuantity_
        )
    {
        return abi.decode(_settlementData, (address, uint256, uint256));
    }

    function __decodePreRedeemSharesSettlementData(bytes memory _settlementData)
        internal
        pure
        returns (address redeemer_, uint256 sharesQuantity_)
    {
        return abi.decode(_settlementData, (address, uint256));
    }

    function __decodePostBuySharesSettlementData(bytes memory _settlementData)
        internal
        pure
        returns (
            address buyer_,
            uint256 investmentAmount_,
            uint256 sharesBought_
        )
    {
        return abi.decode(_settlementData, (address, uint256, uint256));
    }


    function getFeeManager() external view returns (address feeManager_) {
        return FEE_MANAGER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract ManagementFee is FeeBase, MakerDaoMath {
    using SafeMath for uint256;

    event FundSettingsAdded(address indexed comptrollerProxy, uint256 scaledPerSecondRate);

    event Settled(
        address indexed comptrollerProxy,
        uint256 sharesQuantity,
        uint256 secondsSinceSettlement
    );

    struct FeeInfo {
        uint256 scaledPerSecondRate;
        uint256 lastSettled;
    }

    uint256 private constant RATE_SCALE_BASE = 10**27;

    mapping(address => FeeInfo) private comptrollerProxyToFeeInfo;

    constructor(address _feeManager) public FeeBase(_feeManager) {}


    function activateForFund(address _comptrollerProxy, address _vaultProxy)
        external
        override
        onlyFeeManager
    {
        if (VaultLib(_vaultProxy).totalSupply() > 0) {
            comptrollerProxyToFeeInfo[_comptrollerProxy].lastSettled = block.timestamp;
        }
    }

    function addFundSettings(address _comptrollerProxy, bytes calldata _settingsData)
        external
        override
        onlyFeeManager
    {
        uint256 scaledPerSecondRate = abi.decode(_settingsData, (uint256));
        require(
            scaledPerSecondRate > 0,
            "addFundSettings: scaledPerSecondRate must be greater than 0"
        );

        comptrollerProxyToFeeInfo[_comptrollerProxy] = FeeInfo({
            scaledPerSecondRate: scaledPerSecondRate,
            lastSettled: 0
        });

        emit FundSettingsAdded(_comptrollerProxy, scaledPerSecondRate);
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "MANAGEMENT";
    }

    function implementedHooks()
        external
        view
        override
        returns (
            IFeeManager.FeeHook[] memory implementedHooksForSettle_,
            IFeeManager.FeeHook[] memory implementedHooksForUpdate_,
            bool usesGavOnSettle_,
            bool usesGavOnUpdate_
        )
    {
        implementedHooksForSettle_ = new IFeeManager.FeeHook[](3);
        implementedHooksForSettle_[0] = IFeeManager.FeeHook.Continuous;
        implementedHooksForSettle_[1] = IFeeManager.FeeHook.BuySharesSetup;
        implementedHooksForSettle_[2] = IFeeManager.FeeHook.PreRedeemShares;

        return (implementedHooksForSettle_, new IFeeManager.FeeHook[](0), false, false);
    }

    function settle(
        address _comptrollerProxy,
        address _vaultProxy,
        IFeeManager.FeeHook,
        bytes calldata,
        uint256
    )
        external
        override
        onlyFeeManager
        returns (
            IFeeManager.SettlementType settlementType_,
            address,
            uint256 sharesDue_
        )
    {
        FeeInfo storage feeInfo = comptrollerProxyToFeeInfo[_comptrollerProxy];

        uint256 secondsSinceSettlement = block.timestamp.sub(feeInfo.lastSettled);
        if (secondsSinceSettlement == 0) {
            return (IFeeManager.SettlementType.None, address(0), 0);
        }

        VaultLib vaultProxyContract = VaultLib(_vaultProxy);
        uint256 sharesSupply = vaultProxyContract.totalSupply();
        if (sharesSupply > 0) {
            uint256 netSharesSupply = sharesSupply.sub(vaultProxyContract.balanceOf(_vaultProxy));
            if (netSharesSupply > 0) {
                sharesDue_ = netSharesSupply
                    .mul(
                    __rpow(feeInfo.scaledPerSecondRate, secondsSinceSettlement, RATE_SCALE_BASE)
                        .sub(RATE_SCALE_BASE)
                )
                    .div(RATE_SCALE_BASE);
            }
        }

        comptrollerProxyToFeeInfo[_comptrollerProxy].lastSettled = block.timestamp;
        emit Settled(_comptrollerProxy, sharesDue_, secondsSinceSettlement);

        if (sharesDue_ == 0) {
            return (IFeeManager.SettlementType.None, address(0), 0);
        }

        return (IFeeManager.SettlementType.Mint, address(0), sharesDue_);
    }


    function getFeeInfoForFund(address _comptrollerProxy)
        external
        view
        returns (FeeInfo memory feeInfo_)
    {
        return comptrollerProxyToFeeInfo[_comptrollerProxy];
    }
}// MIT

pragma solidity ^0.6.0;

library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract PermissionedVaultActionMixin {
    function __addTrackedAsset(address _comptrollerProxy, address _asset) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IComptroller.VaultAction.AddTrackedAsset,
            abi.encode(_asset)
        );
    }

    function __approveAssetSpender(
        address _comptrollerProxy,
        address _asset,
        address _target,
        uint256 _amount
    ) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IComptroller.VaultAction.ApproveAssetSpender,
            abi.encode(_asset, _target, _amount)
        );
    }

    function __burnShares(
        address _comptrollerProxy,
        address _target,
        uint256 _amount
    ) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IComptroller.VaultAction.BurnShares,
            abi.encode(_target, _amount)
        );
    }

    function __mintShares(
        address _comptrollerProxy,
        address _target,
        uint256 _amount
    ) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IComptroller.VaultAction.MintShares,
            abi.encode(_target, _amount)
        );
    }

    function __removeTrackedAsset(address _comptrollerProxy, address _asset) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IComptroller.VaultAction.RemoveTrackedAsset,
            abi.encode(_asset)
        );
    }

    function __transferShares(
        address _comptrollerProxy,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IComptroller.VaultAction.TransferShares,
            abi.encode(_from, _to, _amount)
        );
    }

    function __withdrawAssetTo(
        address _comptrollerProxy,
        address _asset,
        address _target,
        uint256 _amount
    ) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IComptroller.VaultAction.WithdrawAssetTo,
            abi.encode(_asset, _target, _amount)
        );
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract FeeManager is
    IFeeManager,
    ExtensionBase,
    FundDeployerOwnerMixin,
    PermissionedVaultActionMixin
{
    using AddressArrayLib for address[];
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    event AllSharesOutstandingForcePaidForFund(
        address indexed comptrollerProxy,
        address payee,
        uint256 sharesDue
    );

    event FeeDeregistered(address indexed fee, string indexed identifier);

    event FeeEnabledForFund(
        address indexed comptrollerProxy,
        address indexed fee,
        bytes settingsData
    );

    event FeeRegistered(
        address indexed fee,
        string indexed identifier,
        FeeHook[] implementedHooksForSettle,
        FeeHook[] implementedHooksForUpdate,
        bool usesGavOnSettle,
        bool usesGavOnUpdate
    );

    event FeeSettledForFund(
        address indexed comptrollerProxy,
        address indexed fee,
        SettlementType indexed settlementType,
        address payer,
        address payee,
        uint256 sharesDue
    );

    event SharesOutstandingPaidForFund(
        address indexed comptrollerProxy,
        address indexed fee,
        uint256 sharesDue
    );

    event FeesRecipientSetForFund(
        address indexed comptrollerProxy,
        address prevFeesRecipient,
        address nextFeesRecipient
    );

    EnumerableSet.AddressSet private registeredFees;
    mapping(address => bool) private feeToUsesGavOnSettle;
    mapping(address => bool) private feeToUsesGavOnUpdate;
    mapping(address => mapping(FeeHook => bool)) private feeToHookToImplementsSettle;
    mapping(address => mapping(FeeHook => bool)) private feeToHookToImplementsUpdate;

    mapping(address => address[]) private comptrollerProxyToFees;
    mapping(address => mapping(address => uint256))
        private comptrollerProxyToFeeToSharesOutstanding;

    constructor(address _fundDeployer) public FundDeployerOwnerMixin(_fundDeployer) {}


    function activateForFund(bool) external override {
        address vaultProxy = __setValidatedVaultProxy(msg.sender);

        address[] memory enabledFees = comptrollerProxyToFees[msg.sender];
        for (uint256 i; i < enabledFees.length; i++) {
            IFee(enabledFees[i]).activateForFund(msg.sender, vaultProxy);
        }
    }

    function deactivateForFund() external override {
        __invokeHook(msg.sender, IFeeManager.FeeHook.Continuous, "", 0, false);

        __forcePayoutAllSharesOutstanding(msg.sender);

        __deleteFundStorage(msg.sender);
    }

    function receiveCallFromComptroller(
        address,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external override {
        if (_actionId == 0) {
            __invokeHook(msg.sender, IFeeManager.FeeHook.Continuous, "", 0, true);
        } else if (_actionId == 1) {
            __payoutSharesOutstandingForFees(msg.sender, _callArgs);
        } else {
            revert("receiveCallFromComptroller: Invalid _actionId");
        }
    }

    function setConfigForFund(bytes calldata _configData) external override {
        (address[] memory fees, bytes[] memory settingsData) = abi.decode(
            _configData,
            (address[], bytes[])
        );

        require(
            fees.length == settingsData.length,
            "setConfigForFund: fees and settingsData array lengths unequal"
        );
        require(fees.isUniqueSet(), "setConfigForFund: fees cannot include duplicates");

        for (uint256 i; i < fees.length; i++) {
            require(isRegisteredFee(fees[i]), "setConfigForFund: Fee is not registered");

            IFee(fees[i]).addFundSettings(msg.sender, settingsData[i]);

            comptrollerProxyToFees[msg.sender].push(fees[i]);

            emit FeeEnabledForFund(msg.sender, fees[i], settingsData[i]);
        }
    }

    function invokeHook(
        FeeHook _hook,
        bytes calldata _settlementData,
        uint256 _gav
    ) external override {
        __invokeHook(msg.sender, _hook, _settlementData, _gav, true);
    }


    function __deleteFundStorage(address _comptrollerProxy) private {
        delete comptrollerProxyToFees[_comptrollerProxy];
        delete comptrollerProxyToVaultProxy[_comptrollerProxy];
    }

    function __forcePayoutAllSharesOutstanding(address _comptrollerProxy) private {
        address vaultProxy = getVaultProxyForFund(_comptrollerProxy);

        uint256 totalSharesOutstanding = ERC20(vaultProxy).balanceOf(vaultProxy);
        if (totalSharesOutstanding == 0) {
            return;
        }

        address[] memory fees = comptrollerProxyToFees[_comptrollerProxy];
        for (uint256 i; i < fees.length; i++) {
            delete comptrollerProxyToFeeToSharesOutstanding[_comptrollerProxy][fees[i]];
        }

        address payee = IVault(vaultProxy).getOwner();
        __transferShares(_comptrollerProxy, vaultProxy, payee, totalSharesOutstanding);

        emit AllSharesOutstandingForcePaidForFund(
            _comptrollerProxy,
            payee,
            totalSharesOutstanding
        );
    }

    function __getGavAsNecessary(
        address _comptrollerProxy,
        address _fee,
        uint256 _gavOrZero
    ) private returns (uint256 gav_) {
        if (_gavOrZero == 0 && feeUsesGavOnUpdate(_fee)) {
            bool gavIsValid;
            (gav_, gavIsValid) = IComptroller(_comptrollerProxy).calcGav(true);
            require(gavIsValid, "__getGavAsNecessary: Invalid GAV");
        } else {
            gav_ = _gavOrZero;
        }

        return gav_;
    }

    function __invokeHook(
        address _comptrollerProxy,
        FeeHook _hook,
        bytes memory _settlementData,
        uint256 _gavOrZero,
        bool _updateFees
    ) private {
        address[] memory fees = comptrollerProxyToFees[_comptrollerProxy];
        if (fees.length == 0) {
            return;
        }

        address vaultProxy = getVaultProxyForFund(_comptrollerProxy);

        require(vaultProxy != address(0), "__invokeHook: Fund is not active");

        uint256 gav = __settleFees(
            _comptrollerProxy,
            vaultProxy,
            fees,
            _hook,
            _settlementData,
            _gavOrZero
        );

        if (_updateFees) {
            __updateFees(_comptrollerProxy, vaultProxy, fees, _hook, _settlementData, gav);
        }
    }

    function __payoutSharesOutstandingForFees(address _comptrollerProxy, bytes memory _callArgs)
        private
    {
        address[] memory fees = abi.decode(_callArgs, (address[]));
        address vaultProxy = getVaultProxyForFund(msg.sender);

        uint256 sharesOutstandingDue;
        for (uint256 i; i < fees.length; i++) {
            if (!IFee(fees[i]).payout(_comptrollerProxy, vaultProxy)) {
                continue;
            }


                uint256 sharesOutstandingForFee
             = comptrollerProxyToFeeToSharesOutstanding[_comptrollerProxy][fees[i]];
            if (sharesOutstandingForFee == 0) {
                continue;
            }

            sharesOutstandingDue = sharesOutstandingDue.add(sharesOutstandingForFee);

            comptrollerProxyToFeeToSharesOutstanding[_comptrollerProxy][fees[i]] = 0;

            emit SharesOutstandingPaidForFund(_comptrollerProxy, fees[i], sharesOutstandingForFee);
        }

        if (sharesOutstandingDue > 0) {
            __transferShares(
                _comptrollerProxy,
                vaultProxy,
                IVault(vaultProxy).getOwner(),
                sharesOutstandingDue
            );
        }
    }

    function __settleFee(
        address _comptrollerProxy,
        address _vaultProxy,
        address _fee,
        FeeHook _hook,
        bytes memory _settlementData,
        uint256 _gav
    ) private {
        (SettlementType settlementType, address payer, uint256 sharesDue) = IFee(_fee).settle(
            _comptrollerProxy,
            _vaultProxy,
            _hook,
            _settlementData,
            _gav
        );
        if (settlementType == SettlementType.None) {
            return;
        }

        address payee;
        if (settlementType == SettlementType.Direct) {
            payee = IVault(_vaultProxy).getOwner();
            __transferShares(_comptrollerProxy, payer, payee, sharesDue);
        } else if (settlementType == SettlementType.Mint) {
            payee = IVault(_vaultProxy).getOwner();
            __mintShares(_comptrollerProxy, payee, sharesDue);
        } else if (settlementType == SettlementType.Burn) {
            __burnShares(_comptrollerProxy, payer, sharesDue);
        } else if (settlementType == SettlementType.MintSharesOutstanding) {
            comptrollerProxyToFeeToSharesOutstanding[_comptrollerProxy][_fee] = comptrollerProxyToFeeToSharesOutstanding[_comptrollerProxy][_fee]
                .add(sharesDue);

            payee = _vaultProxy;
            __mintShares(_comptrollerProxy, payee, sharesDue);
        } else if (settlementType == SettlementType.BurnSharesOutstanding) {
            comptrollerProxyToFeeToSharesOutstanding[_comptrollerProxy][_fee] = comptrollerProxyToFeeToSharesOutstanding[_comptrollerProxy][_fee]
                .sub(sharesDue);

            payer = _vaultProxy;
            __burnShares(_comptrollerProxy, payer, sharesDue);
        } else {
            revert("__settleFee: Invalid SettlementType");
        }

        emit FeeSettledForFund(_comptrollerProxy, _fee, settlementType, payer, payee, sharesDue);
    }

    function __settleFees(
        address _comptrollerProxy,
        address _vaultProxy,
        address[] memory _fees,
        FeeHook _hook,
        bytes memory _settlementData,
        uint256 _gavOrZero
    ) private returns (uint256 gav_) {
        gav_ = _gavOrZero;

        for (uint256 i; i < _fees.length; i++) {
            if (!feeSettlesOnHook(_fees[i], _hook)) {
                continue;
            }

            gav_ = __getGavAsNecessary(_comptrollerProxy, _fees[i], gav_);

            __settleFee(_comptrollerProxy, _vaultProxy, _fees[i], _hook, _settlementData, gav_);
        }

        return gav_;
    }

    function __updateFees(
        address _comptrollerProxy,
        address _vaultProxy,
        address[] memory _fees,
        FeeHook _hook,
        bytes memory _settlementData,
        uint256 _gavOrZero
    ) private {
        uint256 gav = _gavOrZero;

        for (uint256 i; i < _fees.length; i++) {
            if (!feeUpdatesOnHook(_fees[i], _hook)) {
                continue;
            }

            gav = __getGavAsNecessary(_comptrollerProxy, _fees[i], gav);

            IFee(_fees[i]).update(_comptrollerProxy, _vaultProxy, _hook, _settlementData, gav);
        }
    }


    function deregisterFees(address[] calldata _fees) external onlyFundDeployerOwner {
        require(_fees.length > 0, "deregisterFees: _fees cannot be empty");

        for (uint256 i; i < _fees.length; i++) {
            require(isRegisteredFee(_fees[i]), "deregisterFees: fee is not registered");

            registeredFees.remove(_fees[i]);

            emit FeeDeregistered(_fees[i], IFee(_fees[i]).identifier());
        }
    }

    function registerFees(address[] calldata _fees) external onlyFundDeployerOwner {
        require(_fees.length > 0, "registerFees: _fees cannot be empty");

        for (uint256 i; i < _fees.length; i++) {
            require(!isRegisteredFee(_fees[i]), "registerFees: fee already registered");

            registeredFees.add(_fees[i]);

            IFee feeContract = IFee(_fees[i]);
            (
                FeeHook[] memory implementedHooksForSettle,
                FeeHook[] memory implementedHooksForUpdate,
                bool usesGavOnSettle,
                bool usesGavOnUpdate
            ) = feeContract.implementedHooks();

            for (uint256 j; j < implementedHooksForSettle.length; j++) {
                feeToHookToImplementsSettle[_fees[i]][implementedHooksForSettle[j]] = true;
            }
            for (uint256 j; j < implementedHooksForUpdate.length; j++) {
                feeToHookToImplementsUpdate[_fees[i]][implementedHooksForUpdate[j]] = true;
            }

            if (usesGavOnSettle) {
                feeToUsesGavOnSettle[_fees[i]] = true;
            }
            if (usesGavOnUpdate) {
                feeToUsesGavOnUpdate[_fees[i]] = true;
            }

            emit FeeRegistered(
                _fees[i],
                feeContract.identifier(),
                implementedHooksForSettle,
                implementedHooksForUpdate,
                usesGavOnSettle,
                usesGavOnUpdate
            );
        }
    }


    function getEnabledFeesForFund(address _comptrollerProxy)
        external
        view
        returns (address[] memory enabledFees_)
    {
        return comptrollerProxyToFees[_comptrollerProxy];
    }

    function getFeeSharesOutstandingForFund(address _comptrollerProxy, address _fee)
        external
        view
        returns (uint256 sharesOutstanding_)
    {
        return comptrollerProxyToFeeToSharesOutstanding[_comptrollerProxy][_fee];
    }

    function getRegisteredFees() external view returns (address[] memory registeredFees_) {
        registeredFees_ = new address[](registeredFees.length());
        for (uint256 i; i < registeredFees_.length; i++) {
            registeredFees_[i] = registeredFees.at(i);
        }

        return registeredFees_;
    }

    function feeSettlesOnHook(address _fee, FeeHook _hook)
        public
        view
        returns (bool settlesOnHook_)
    {
        return feeToHookToImplementsSettle[_fee][_hook];
    }

    function feeUpdatesOnHook(address _fee, FeeHook _hook)
        public
        view
        returns (bool updatesOnHook_)
    {
        return feeToHookToImplementsUpdate[_fee][_hook];
    }

    function feeUsesGavOnSettle(address _fee) public view returns (bool usesGav_) {
        return feeToUsesGavOnSettle[_fee];
    }

    function feeUsesGavOnUpdate(address _fee) public view returns (bool usesGav_) {
        return feeToUsesGavOnUpdate[_fee];
    }

    function isRegisteredFee(address _fee) public view returns (bool isRegisteredFee_) {
        return registeredFees.contains(_fee);
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract PerformanceFee is FeeBase {
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    event ActivatedForFund(address indexed comptrollerProxy, uint256 highWaterMark);

    event FundSettingsAdded(address indexed comptrollerProxy, uint256 rate, uint256 period);

    event LastSharePriceUpdated(
        address indexed comptrollerProxy,
        uint256 prevSharePrice,
        uint256 nextSharePrice
    );

    event PaidOut(
        address indexed comptrollerProxy,
        uint256 prevHighWaterMark,
        uint256 nextHighWaterMark,
        uint256 aggregateValueDue
    );

    event PerformanceUpdated(
        address indexed comptrollerProxy,
        uint256 prevAggregateValueDue,
        uint256 nextAggregateValueDue,
        int256 sharesOutstandingDiff
    );

    struct FeeInfo {
        uint256 rate;
        uint256 period;
        uint256 activated;
        uint256 lastPaid;
        uint256 highWaterMark;
        uint256 lastSharePrice;
        uint256 aggregateValueDue;
    }

    uint256 private constant RATE_DIVISOR = 10**18;
    uint256 private constant SHARE_UNIT = 10**18;

    mapping(address => FeeInfo) private comptrollerProxyToFeeInfo;

    constructor(address _feeManager) public FeeBase(_feeManager) {}


    function activateForFund(address _comptrollerProxy, address) external override onlyFeeManager {
        FeeInfo storage feeInfo = comptrollerProxyToFeeInfo[_comptrollerProxy];

        (uint256 grossSharePrice, bool sharePriceIsValid) = ComptrollerLib(_comptrollerProxy)
            .calcGrossShareValue(false);
        require(sharePriceIsValid, "activateForFund: Invalid share price");

        feeInfo.highWaterMark = grossSharePrice;
        feeInfo.lastSharePrice = grossSharePrice;
        feeInfo.activated = block.timestamp;

        emit ActivatedForFund(_comptrollerProxy, grossSharePrice);
    }

    function addFundSettings(address _comptrollerProxy, bytes calldata _settingsData)
        external
        override
        onlyFeeManager
    {
        (uint256 feeRate, uint256 feePeriod) = abi.decode(_settingsData, (uint256, uint256));
        require(feeRate > 0, "addFundSettings: feeRate must be greater than 0");
        require(feePeriod > 0, "addFundSettings: feePeriod must be greater than 0");

        comptrollerProxyToFeeInfo[_comptrollerProxy] = FeeInfo({
            rate: feeRate,
            period: feePeriod,
            activated: 0,
            lastPaid: 0,
            highWaterMark: 0,
            lastSharePrice: 0,
            aggregateValueDue: 0
        });

        emit FundSettingsAdded(_comptrollerProxy, feeRate, feePeriod);
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "PERFORMANCE";
    }

    function implementedHooks()
        external
        view
        override
        returns (
            IFeeManager.FeeHook[] memory implementedHooksForSettle_,
            IFeeManager.FeeHook[] memory implementedHooksForUpdate_,
            bool usesGavOnSettle_,
            bool usesGavOnUpdate_
        )
    {
        implementedHooksForSettle_ = new IFeeManager.FeeHook[](3);
        implementedHooksForSettle_[0] = IFeeManager.FeeHook.Continuous;
        implementedHooksForSettle_[1] = IFeeManager.FeeHook.BuySharesSetup;
        implementedHooksForSettle_[2] = IFeeManager.FeeHook.PreRedeemShares;

        implementedHooksForUpdate_ = new IFeeManager.FeeHook[](3);
        implementedHooksForUpdate_[0] = IFeeManager.FeeHook.Continuous;
        implementedHooksForUpdate_[1] = IFeeManager.FeeHook.BuySharesCompleted;
        implementedHooksForUpdate_[2] = IFeeManager.FeeHook.PreRedeemShares;

        return (implementedHooksForSettle_, implementedHooksForUpdate_, true, true);
    }

    function payout(address _comptrollerProxy, address)
        external
        override
        onlyFeeManager
        returns (bool isPayable_)
    {
        if (!payoutAllowed(_comptrollerProxy)) {
            return false;
        }

        FeeInfo storage feeInfo = comptrollerProxyToFeeInfo[_comptrollerProxy];
        feeInfo.lastPaid = block.timestamp;

        uint256 prevHighWaterMark = feeInfo.highWaterMark;
        uint256 nextHighWaterMark = __calcUint256Max(feeInfo.lastSharePrice, prevHighWaterMark);
        uint256 prevAggregateValueDue = feeInfo.aggregateValueDue;

        if (prevAggregateValueDue > 0) {
            feeInfo.aggregateValueDue = 0;
        }
        if (nextHighWaterMark > prevHighWaterMark) {
            feeInfo.highWaterMark = nextHighWaterMark;
        }

        emit PaidOut(
            _comptrollerProxy,
            prevHighWaterMark,
            nextHighWaterMark,
            prevAggregateValueDue
        );

        return true;
    }

    function settle(
        address _comptrollerProxy,
        address _vaultProxy,
        IFeeManager.FeeHook,
        bytes calldata,
        uint256 _gav
    )
        external
        override
        onlyFeeManager
        returns (
            IFeeManager.SettlementType settlementType_,
            address,
            uint256 sharesDue_
        )
    {
        if (_gav == 0) {
            return (IFeeManager.SettlementType.None, address(0), 0);
        }

        int256 settlementSharesDue = __settleAndUpdatePerformance(
            _comptrollerProxy,
            _vaultProxy,
            _gav
        );
        if (settlementSharesDue == 0) {
            return (IFeeManager.SettlementType.None, address(0), 0);
        } else if (settlementSharesDue > 0) {
            return (
                IFeeManager.SettlementType.MintSharesOutstanding,
                address(0),
                uint256(settlementSharesDue)
            );
        } else {
            return (
                IFeeManager.SettlementType.BurnSharesOutstanding,
                address(0),
                uint256(-settlementSharesDue)
            );
        }
    }

    function update(
        address _comptrollerProxy,
        address _vaultProxy,
        IFeeManager.FeeHook _hook,
        bytes calldata _settlementData,
        uint256 _gav
    ) external override onlyFeeManager {
        uint256 prevSharePrice = comptrollerProxyToFeeInfo[_comptrollerProxy].lastSharePrice;
        uint256 nextSharePrice = __calcNextSharePrice(
            _comptrollerProxy,
            _vaultProxy,
            _hook,
            _settlementData,
            _gav
        );

        if (nextSharePrice == prevSharePrice) {
            return;
        }

        comptrollerProxyToFeeInfo[_comptrollerProxy].lastSharePrice = nextSharePrice;

        emit LastSharePriceUpdated(_comptrollerProxy, prevSharePrice, nextSharePrice);
    }


    function payoutAllowed(address _comptrollerProxy) public view returns (bool payoutAllowed_) {
        FeeInfo memory feeInfo = comptrollerProxyToFeeInfo[_comptrollerProxy];
        uint256 period = feeInfo.period;

        uint256 timeSinceActivated = block.timestamp.sub(feeInfo.activated);

        if (timeSinceActivated < period) {
            return false;
        }

        uint256 timeSincePeriodStart = timeSinceActivated % period;
        uint256 periodStart = block.timestamp.sub(timeSincePeriodStart);
        return feeInfo.lastPaid < periodStart;
    }


    function __calcAggregateValueDue(
        uint256 _netSharesSupply,
        uint256 _sharePriceWithoutPerformance,
        uint256 _prevSharePrice,
        uint256 _prevAggregateValueDue,
        uint256 _feeRate,
        uint256 _highWaterMark
    ) private pure returns (uint256) {
        int256 superHWMValueSinceLastSettled = (
            int256(__calcUint256Max(_highWaterMark, _sharePriceWithoutPerformance)).sub(
                int256(__calcUint256Max(_highWaterMark, _prevSharePrice))
            )
        )
            .mul(int256(_netSharesSupply))
            .div(int256(SHARE_UNIT));

        int256 valueDueSinceLastSettled = superHWMValueSinceLastSettled.mul(int256(_feeRate)).div(
            int256(RATE_DIVISOR)
        );

        return
            uint256(
                __calcInt256Max(0, int256(_prevAggregateValueDue).add(valueDueSinceLastSettled))
            );
    }

    function __calcInt256Max(int256 _a, int256 _b) private pure returns (int256) {
        if (_a >= _b) {
            return _a;
        }

        return _b;
    }

    function __calcNextSharePrice(
        address _comptrollerProxy,
        address _vaultProxy,
        IFeeManager.FeeHook _hook,
        bytes memory _settlementData,
        uint256 _gav
    ) private view returns (uint256 nextSharePrice_) {
        uint256 denominationAssetUnit = 10 **
            uint256(ERC20(ComptrollerLib(_comptrollerProxy).getDenominationAsset()).decimals());
        if (_gav == 0) {
            return denominationAssetUnit;
        }

        ERC20 vaultProxyContract = ERC20(_vaultProxy);
        uint256 totalSharesSupply = vaultProxyContract.totalSupply();
        uint256 nextNetSharesSupply = totalSharesSupply.sub(
            vaultProxyContract.balanceOf(_vaultProxy)
        );
        if (nextNetSharesSupply == 0) {
            return denominationAssetUnit;
        }

        uint256 nextGav = _gav;

        if (_hook == IFeeManager.FeeHook.PreRedeemShares) {
            (, uint256 sharesDecrease) = __decodePreRedeemSharesSettlementData(_settlementData);

            nextNetSharesSupply = nextNetSharesSupply.sub(sharesDecrease);
            if (nextNetSharesSupply == 0) {
                return denominationAssetUnit;
            }

            uint256 gavDecrease = sharesDecrease
                .mul(_gav)
                .mul(SHARE_UNIT)
                .div(totalSharesSupply)
                .div(denominationAssetUnit);

            nextGav = nextGav.sub(gavDecrease);
            if (nextGav == 0) {
                return denominationAssetUnit;
            }
        }

        return nextGav.mul(SHARE_UNIT).div(nextNetSharesSupply);
    }

    function __calcPerformance(
        address _comptrollerProxy,
        uint256 _totalSharesSupply,
        uint256 _totalSharesOutstanding,
        uint256 _prevAggregateValueDue,
        FeeInfo memory feeInfo,
        uint256 _gav
    ) private view returns (uint256 nextAggregateValueDue_, int256 sharesDue_) {
        uint256 netSharesSupply = _totalSharesSupply.sub(_totalSharesOutstanding);
        uint256 sharePriceWithoutPerformance = _gav.mul(SHARE_UNIT).div(netSharesSupply);

        uint256 prevSharePrice = feeInfo.lastSharePrice;
        if (sharePriceWithoutPerformance == prevSharePrice) {
            return (_prevAggregateValueDue, 0);
        }

        nextAggregateValueDue_ = __calcAggregateValueDue(
            netSharesSupply,
            sharePriceWithoutPerformance,
            prevSharePrice,
            _prevAggregateValueDue,
            feeInfo.rate,
            feeInfo.highWaterMark
        );

        sharesDue_ = __calcSharesDue(
            _comptrollerProxy,
            netSharesSupply,
            _gav,
            nextAggregateValueDue_
        );

        return (nextAggregateValueDue_, sharesDue_);
    }

    function __calcSharesDue(
        address _comptrollerProxy,
        uint256 _netSharesSupply,
        uint256 _gav,
        uint256 _nextAggregateValueDue
    ) private view returns (int256 sharesDue_) {
        uint256 sharesDueForAggregateValueDue = _nextAggregateValueDue.mul(_netSharesSupply).div(
            _gav.sub(_nextAggregateValueDue)
        );

        return
            int256(sharesDueForAggregateValueDue).sub(
                int256(
                    FeeManager(FEE_MANAGER).getFeeSharesOutstandingForFund(
                        _comptrollerProxy,
                        address(this)
                    )
                )
            );
    }

    function __calcUint256Max(uint256 _a, uint256 _b) private pure returns (uint256) {
        if (_a >= _b) {
            return _a;
        }

        return _b;
    }

    function __settleAndUpdatePerformance(
        address _comptrollerProxy,
        address _vaultProxy,
        uint256 _gav
    ) private returns (int256 sharesDue_) {
        ERC20 sharesTokenContract = ERC20(_vaultProxy);

        uint256 totalSharesSupply = sharesTokenContract.totalSupply();
        if (totalSharesSupply == 0) {
            return 0;
        }

        uint256 totalSharesOutstanding = sharesTokenContract.balanceOf(_vaultProxy);
        if (totalSharesOutstanding == totalSharesSupply) {
            return 0;
        }

        FeeInfo storage feeInfo = comptrollerProxyToFeeInfo[_comptrollerProxy];
        uint256 prevAggregateValueDue = feeInfo.aggregateValueDue;

        uint256 nextAggregateValueDue;
        (nextAggregateValueDue, sharesDue_) = __calcPerformance(
            _comptrollerProxy,
            totalSharesSupply,
            totalSharesOutstanding,
            prevAggregateValueDue,
            feeInfo,
            _gav
        );
        if (nextAggregateValueDue == prevAggregateValueDue) {
            return 0;
        }

        feeInfo.aggregateValueDue = nextAggregateValueDue;

        emit PerformanceUpdated(
            _comptrollerProxy,
            prevAggregateValueDue,
            nextAggregateValueDue,
            sharesDue_
        );

        return sharesDue_;
    }


    function getFeeInfoForFund(address _comptrollerProxy)
        external
        view
        returns (FeeInfo memory feeInfo_)
    {
        return comptrollerProxyToFeeInfo[_comptrollerProxy];
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract FundActionsWrapper {
    address private immutable FEE_MANAGER;

    constructor(address _feeManager) public {
        FEE_MANAGER = _feeManager;
    }


    function calcNetShareValueForFund(address _comptrollerProxy)
        external
        returns (uint256 netShareValue_, bool isValid_)
    {
        ComptrollerLib comptrollerProxyContract = ComptrollerLib(_comptrollerProxy);
        comptrollerProxyContract.callOnExtension(FEE_MANAGER, 0, "");

        return comptrollerProxyContract.calcGrossShareValue(false);
    }

    function invokeContinuousFeeHookAndPayoutSharesOutstandingForFund(
        address _comptrollerProxy,
        address[] calldata _fees
    ) external {
        ComptrollerLib comptrollerProxyContract = ComptrollerLib(_comptrollerProxy);

        comptrollerProxyContract.callOnExtension(FEE_MANAGER, 0, "");
        comptrollerProxyContract.callOnExtension(FEE_MANAGER, 1, abi.encode(_fees));
    }


    function getContinuousFeesForFund(address _comptrollerProxy)
        public
        view
        returns (address[] memory continuousFees_)
    {
        FeeManager feeManagerContract = FeeManager(FEE_MANAGER);

        address[] memory fees = feeManagerContract.getEnabledFeesForFund(_comptrollerProxy);

        uint256 continuousFeesCount;
        bool[] memory implementsContinuousHook = new bool[](fees.length);
        for (uint256 i; i < fees.length; i++) {
            if (feeManagerContract.feeSettlesOnHook(fees[i], IFeeManager.FeeHook.Continuous)) {
                continuousFeesCount++;
                implementsContinuousHook[i] = true;
            }
        }

        if (continuousFeesCount == 0) {
            return new address[](0);
        }

        continuousFees_ = new address[](continuousFeesCount);
        uint256 continuousFeesIndex;
        for (uint256 i; i < fees.length; i++) {
            if (implementsContinuousHook[i]) {
                continuousFees_[continuousFeesIndex] = fees[i];
                continuousFeesIndex++;
            }
        }

        return continuousFees_;
    }


    function getFeeManager() external view returns (address feeManager_) {
        return FEE_MANAGER;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IAuthUserExecutedSharesRequestor {
    function init(address) external;
}// GPL-3.0


pragma solidity 0.6.12;


contract AuthUserExecutedSharesRequestorLib is IAuthUserExecutedSharesRequestor {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;

    event RequestCanceled(
        address indexed requestOwner,
        uint256 investmentAmount,
        uint256 minSharesQuantity
    );

    event RequestCreated(
        address indexed requestOwner,
        uint256 investmentAmount,
        uint256 minSharesQuantity
    );

    event RequestExecuted(
        address indexed caller,
        address indexed requestOwner,
        uint256 investmentAmount,
        uint256 minSharesQuantity
    );

    event RequestExecutorAdded(address indexed account);

    event RequestExecutorRemoved(address indexed account);

    struct RequestInfo {
        uint256 investmentAmount;
        uint256 minSharesQuantity;
    }

    uint256 private constant CANCELLATION_COOLDOWN_TIMELOCK = 10 minutes;

    address private comptrollerProxy;
    address private denominationAsset;
    address private fundOwner;

    mapping(address => RequestInfo) private ownerToRequestInfo;
    mapping(address => bool) private acctToIsRequestExecutor;
    mapping(address => uint256) private ownerToLastRequestCancellation;

    modifier onlyFundOwner() {
        require(msg.sender == fundOwner, "Only fund owner callable");
        _;
    }

    function init(address _comptrollerProxy) external override {
        require(comptrollerProxy == address(0), "init: Already initialized");

        comptrollerProxy = _comptrollerProxy;

        ComptrollerLib comptrollerProxyContract = ComptrollerLib(_comptrollerProxy);
        denominationAsset = comptrollerProxyContract.getDenominationAsset();
        fundOwner = VaultLib(comptrollerProxyContract.getVaultProxy()).getOwner();
    }

    function cancelRequest() external {
        RequestInfo memory request = ownerToRequestInfo[msg.sender];
        require(request.investmentAmount > 0, "cancelRequest: Request does not exist");

        delete ownerToRequestInfo[msg.sender];
        ownerToLastRequestCancellation[msg.sender] = block.timestamp;
        ERC20(denominationAsset).safeTransfer(msg.sender, request.investmentAmount);

        emit RequestCanceled(msg.sender, request.investmentAmount, request.minSharesQuantity);
    }

    function createRequest(uint256 _investmentAmount, uint256 _minSharesQuantity) external {
        require(_investmentAmount > 0, "createRequest: _investmentAmount must be > 0");
        require(
            ownerToRequestInfo[msg.sender].investmentAmount == 0,
            "createRequest: The request owner can only create one request before executed or canceled"
        );
        require(
            ownerToLastRequestCancellation[msg.sender] <
                block.timestamp.sub(CANCELLATION_COOLDOWN_TIMELOCK),
            "createRequest: Cannot create request during cancellation cooldown period"
        );

        ownerToRequestInfo[msg.sender] = RequestInfo({
            investmentAmount: _investmentAmount,
            minSharesQuantity: _minSharesQuantity
        });
        ERC20(denominationAsset).safeTransferFrom(msg.sender, address(this), _investmentAmount);

        emit RequestCreated(msg.sender, _investmentAmount, _minSharesQuantity);
    }

    function executeRequests(address[] calldata _requestOwners) external {
        require(
            msg.sender == fundOwner || isRequestExecutor(msg.sender),
            "executeRequests: Invalid caller"
        );
        require(_requestOwners.length > 0, "executeRequests: _requestOwners can not be empty");

        (
            address[] memory buyers,
            uint256[] memory investmentAmounts,
            uint256[] memory minSharesQuantities,
            uint256 totalInvestmentAmount
        ) = __convertRequestsToBuySharesParams(_requestOwners);

        address comptrollerProxyCopy = comptrollerProxy;
        ERC20 denominationAssetContract = ERC20(denominationAsset);
        if (
            denominationAssetContract.allowance(address(this), comptrollerProxyCopy) <
            totalInvestmentAmount
        ) {
            denominationAssetContract.safeApprove(comptrollerProxyCopy, type(uint256).max);
        }

        ComptrollerLib(comptrollerProxyCopy).buyShares(
            buyers,
            investmentAmounts,
            minSharesQuantities
        );
    }

    function __convertRequestsToBuySharesParams(address[] memory _requestOwners)
        private
        returns (
            address[] memory buyers_,
            uint256[] memory investmentAmounts_,
            uint256[] memory minSharesQuantities_,
            uint256 totalInvestmentAmount_
        )
    {
        uint256 existingRequestsCount = _requestOwners.length;
        uint256[] memory allInvestmentAmounts = new uint256[](_requestOwners.length);

        for (uint256 i; i < _requestOwners.length; i++) {
            allInvestmentAmounts[i] = ownerToRequestInfo[_requestOwners[i]].investmentAmount;

            if (allInvestmentAmounts[i] == 0) {
                existingRequestsCount--;
            }
        }

        buyers_ = new address[](existingRequestsCount);
        investmentAmounts_ = new uint256[](existingRequestsCount);
        minSharesQuantities_ = new uint256[](existingRequestsCount);
        uint256 existingRequestsIndex;
        for (uint256 i; i < _requestOwners.length; i++) {
            if (allInvestmentAmounts[i] == 0) {
                continue;
            }

            buyers_[existingRequestsIndex] = _requestOwners[i];
            investmentAmounts_[existingRequestsIndex] = allInvestmentAmounts[i];
            minSharesQuantities_[existingRequestsIndex] = ownerToRequestInfo[_requestOwners[i]]
                .minSharesQuantity;
            totalInvestmentAmount_ = totalInvestmentAmount_.add(allInvestmentAmounts[i]);

            delete ownerToRequestInfo[_requestOwners[i]];

            emit RequestExecuted(
                msg.sender,
                buyers_[existingRequestsIndex],
                investmentAmounts_[existingRequestsIndex],
                minSharesQuantities_[existingRequestsIndex]
            );

            existingRequestsIndex++;
        }

        return (buyers_, investmentAmounts_, minSharesQuantities_, totalInvestmentAmount_);
    }


    function addRequestExecutors(address[] calldata _requestExecutors) external onlyFundOwner {
        require(_requestExecutors.length > 0, "addRequestExecutors: Empty _requestExecutors");

        for (uint256 i; i < _requestExecutors.length; i++) {
            require(
                !isRequestExecutor(_requestExecutors[i]),
                "addRequestExecutors: Value already set"
            );
            require(
                _requestExecutors[i] != fundOwner,
                "addRequestExecutors: The fund owner cannot be added"
            );

            acctToIsRequestExecutor[_requestExecutors[i]] = true;

            emit RequestExecutorAdded(_requestExecutors[i]);
        }
    }

    function removeRequestExecutors(address[] calldata _requestExecutors) external onlyFundOwner {
        require(_requestExecutors.length > 0, "removeRequestExecutors: Empty _requestExecutors");

        for (uint256 i; i < _requestExecutors.length; i++) {
            require(
                isRequestExecutor(_requestExecutors[i]),
                "removeRequestExecutors: Account is not a request executor"
            );

            acctToIsRequestExecutor[_requestExecutors[i]] = false;

            emit RequestExecutorRemoved(_requestExecutors[i]);
        }
    }


    function getComptrollerProxy() external view returns (address comptrollerProxy_) {
        return comptrollerProxy;
    }

    function getDenominationAsset() external view returns (address denominationAsset_) {
        return denominationAsset;
    }

    function getFundOwner() external view returns (address fundOwner_) {
        return fundOwner;
    }

    function getSharesRequestInfoForOwner(address _requestOwner)
        external
        view
        returns (RequestInfo memory requestInfo_)
    {
        return ownerToRequestInfo[_requestOwner];
    }

    function isRequestExecutor(address _who) public view returns (bool isRequestExecutor_) {
        return acctToIsRequestExecutor[_who];
    }
}// GPL-3.0


pragma solidity 0.6.12;

contract Proxy {
    constructor(bytes memory _constructData, address _contractLogic) public {
        assembly {
            sstore(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
                _contractLogic
            )
        }
        (bool success, bytes memory returnData) = _contractLogic.delegatecall(_constructData);
        require(success, string(returnData));
    }

    fallback() external payable {
        assembly {
            let contractLogic := sload(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
            )
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                sub(gas(), 10000),
                contractLogic,
                0x0,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
                case 0 {
                    revert(0, retSz)
                }
                default {
                    return(0, retSz)
                }
        }
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract AuthUserExecutedSharesRequestorProxy is Proxy {
    constructor(bytes memory _constructData, address _authUserExecutedSharesRequestorLib)
        public
        Proxy(_constructData, _authUserExecutedSharesRequestorLib)
    {}
}// GPL-3.0


pragma solidity 0.6.12;


contract AuthUserExecutedSharesRequestorFactory {
    event SharesRequestorProxyDeployed(
        address indexed comptrollerProxy,
        address sharesRequestorProxy
    );

    address private immutable AUTH_USER_EXECUTED_SHARES_REQUESTOR_LIB;
    address private immutable DISPATCHER;

    mapping(address => address) private comptrollerProxyToSharesRequestorProxy;

    constructor(address _dispatcher, address _authUserExecutedSharesRequestorLib) public {
        AUTH_USER_EXECUTED_SHARES_REQUESTOR_LIB = _authUserExecutedSharesRequestorLib;
        DISPATCHER = _dispatcher;
    }

    function deploySharesRequestorProxy(address _comptrollerProxy)
        external
        returns (address sharesRequestorProxy_)
    {
        VaultLib vaultProxyContract = VaultLib(ComptrollerLib(_comptrollerProxy).getVaultProxy());
        require(
            vaultProxyContract.getAccessor() == _comptrollerProxy,
            "deploySharesRequestorProxy: Invalid VaultProxy for ComptrollerProxy"
        );
        require(
            IDispatcher(DISPATCHER).getFundDeployerForVaultProxy(address(vaultProxyContract)) !=
                address(0),
            "deploySharesRequestorProxy: Not a genuine fund"
        );

        require(
            msg.sender == vaultProxyContract.getOwner(),
            "deploySharesRequestorProxy: Only fund owner callable"
        );

        require(
            comptrollerProxyToSharesRequestorProxy[_comptrollerProxy] == address(0),
            "deploySharesRequestorProxy: Proxy already exists"
        );

        bytes memory constructData = abi.encodeWithSelector(
            IAuthUserExecutedSharesRequestor.init.selector,
            _comptrollerProxy
        );
        sharesRequestorProxy_ = address(
            new AuthUserExecutedSharesRequestorProxy(
                constructData,
                AUTH_USER_EXECUTED_SHARES_REQUESTOR_LIB
            )
        );

        comptrollerProxyToSharesRequestorProxy[_comptrollerProxy] = sharesRequestorProxy_;

        emit SharesRequestorProxyDeployed(_comptrollerProxy, sharesRequestorProxy_);

        return sharesRequestorProxy_;
    }


    function getAuthUserExecutedSharesRequestorLib()
        external
        view
        returns (address authUserExecutedSharesRequestorLib_)
    {
        return AUTH_USER_EXECUTED_SHARES_REQUESTOR_LIB;
    }

    function getDispatcher() external view returns (address dispatcher_) {
        return DISPATCHER;
    }

    function getSharesRequestorProxyForComptrollerProxy(address _comptrollerProxy)
        external
        view
        returns (address sharesRequestorProxy_)
    {
        return comptrollerProxyToSharesRequestorProxy[_comptrollerProxy];
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract ComptrollerProxy is Proxy {
    constructor(bytes memory _constructData, address _comptrollerLib)
        public
        Proxy(_constructData, _comptrollerLib)
    {}
}// GPL-3.0


pragma solidity 0.6.12;

interface IMigrationHookHandler {
    enum MigrationOutHook {PreSignal, PostSignal, PreMigrate, PostMigrate, PostCancel}

    function invokeMigrationInCancelHook(
        address _vaultProxy,
        address _prevFundDeployer,
        address _nextVaultAccessor,
        address _nextVaultLib
    ) external;

    function invokeMigrationOutHook(
        MigrationOutHook _hook,
        address _vaultProxy,
        address _nextFundDeployer,
        address _nextVaultAccessor,
        address _nextVaultLib
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;


contract FundDeployer is IFundDeployer, IMigrationHookHandler {
    event ComptrollerLibSet(address comptrollerLib);

    event ComptrollerProxyDeployed(
        address indexed creator,
        address comptrollerProxy,
        address indexed denominationAsset,
        uint256 sharesActionTimelock,
        bytes feeManagerConfigData,
        bytes policyManagerConfigData,
        bool indexed forMigration
    );

    event NewFundCreated(
        address indexed creator,
        address comptrollerProxy,
        address vaultProxy,
        address indexed fundOwner,
        string fundName,
        address indexed denominationAsset,
        uint256 sharesActionTimelock,
        bytes feeManagerConfigData,
        bytes policyManagerConfigData
    );

    event ReleaseStatusSet(ReleaseStatus indexed prevStatus, ReleaseStatus indexed nextStatus);

    event VaultCallDeregistered(address indexed contractAddress, bytes4 selector);

    event VaultCallRegistered(address indexed contractAddress, bytes4 selector);

    address private immutable CREATOR;
    address private immutable DISPATCHER;
    address private immutable VAULT_LIB;

    address private comptrollerLib;

    ReleaseStatus private releaseStatus;
    mapping(address => mapping(bytes4 => bool)) private contractToSelectorToIsRegisteredVaultCall;
    mapping(address => address) private pendingComptrollerProxyToCreator;

    modifier onlyLiveRelease() {
        require(releaseStatus == ReleaseStatus.Live, "Release is not Live");
        _;
    }

    modifier onlyMigrator(address _vaultProxy) {
        require(
            IVault(_vaultProxy).canMigrate(msg.sender),
            "Only a permissioned migrator can call this function"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == getOwner(), "Only the contract owner can call this function");
        _;
    }

    modifier onlyPendingComptrollerProxyCreator(address _comptrollerProxy) {
        require(
            msg.sender == pendingComptrollerProxyToCreator[_comptrollerProxy],
            "Only the ComptrollerProxy creator can call this function"
        );
        _;
    }

    constructor(
        address _dispatcher,
        address _vaultLib,
        address[] memory _vaultCallContracts,
        bytes4[] memory _vaultCallSelectors
    ) public {
        if (_vaultCallContracts.length > 0) {
            __registerVaultCalls(_vaultCallContracts, _vaultCallSelectors);
        }
        CREATOR = msg.sender;
        DISPATCHER = _dispatcher;
        VAULT_LIB = _vaultLib;
    }


    function setComptrollerLib(address _comptrollerLib) external onlyOwner {
        require(
            comptrollerLib == address(0),
            "setComptrollerLib: This value can only be set once"
        );

        comptrollerLib = _comptrollerLib;

        emit ComptrollerLibSet(_comptrollerLib);
    }

    function setReleaseStatus(ReleaseStatus _nextStatus) external {
        require(
            msg.sender == IDispatcher(DISPATCHER).getOwner(),
            "setReleaseStatus: Only the Dispatcher owner can call this function"
        );
        require(
            _nextStatus != ReleaseStatus.PreLaunch,
            "setReleaseStatus: Cannot return to PreLaunch status"
        );
        require(
            comptrollerLib != address(0),
            "setReleaseStatus: Can only set the release status when comptrollerLib is set"
        );

        ReleaseStatus prevStatus = releaseStatus;
        require(_nextStatus != prevStatus, "setReleaseStatus: _nextStatus is the current status");

        releaseStatus = _nextStatus;

        emit ReleaseStatusSet(prevStatus, _nextStatus);
    }

    function getOwner() public view override returns (address owner_) {
        if (releaseStatus == ReleaseStatus.PreLaunch) {
            return CREATOR;
        }

        return IDispatcher(DISPATCHER).getOwner();
    }


    function createMigratedFundConfig(
        address _denominationAsset,
        uint256 _sharesActionTimelock,
        bytes calldata _feeManagerConfigData,
        bytes calldata _policyManagerConfigData
    ) external onlyLiveRelease returns (address comptrollerProxy_) {
        comptrollerProxy_ = __deployComptrollerProxy(
            _denominationAsset,
            _sharesActionTimelock,
            _feeManagerConfigData,
            _policyManagerConfigData,
            true
        );

        pendingComptrollerProxyToCreator[comptrollerProxy_] = msg.sender;

        return comptrollerProxy_;
    }

    function createNewFund(
        address _fundOwner,
        string calldata _fundName,
        address _denominationAsset,
        uint256 _sharesActionTimelock,
        bytes calldata _feeManagerConfigData,
        bytes calldata _policyManagerConfigData
    ) external onlyLiveRelease returns (address comptrollerProxy_, address vaultProxy_) {
        return
            __createNewFund(
                _fundOwner,
                _fundName,
                _denominationAsset,
                _sharesActionTimelock,
                _feeManagerConfigData,
                _policyManagerConfigData
            );
    }

    function __createNewFund(
        address _fundOwner,
        string memory _fundName,
        address _denominationAsset,
        uint256 _sharesActionTimelock,
        bytes memory _feeManagerConfigData,
        bytes memory _policyManagerConfigData
    ) private returns (address comptrollerProxy_, address vaultProxy_) {
        require(_fundOwner != address(0), "__createNewFund: _owner cannot be empty");

        comptrollerProxy_ = __deployComptrollerProxy(
            _denominationAsset,
            _sharesActionTimelock,
            _feeManagerConfigData,
            _policyManagerConfigData,
            false
        );

        vaultProxy_ = IDispatcher(DISPATCHER).deployVaultProxy(
            VAULT_LIB,
            _fundOwner,
            comptrollerProxy_,
            _fundName
        );

        IComptroller(comptrollerProxy_).activate(vaultProxy_, false);

        emit NewFundCreated(
            msg.sender,
            comptrollerProxy_,
            vaultProxy_,
            _fundOwner,
            _fundName,
            _denominationAsset,
            _sharesActionTimelock,
            _feeManagerConfigData,
            _policyManagerConfigData
        );

        return (comptrollerProxy_, vaultProxy_);
    }

    function __deployComptrollerProxy(
        address _denominationAsset,
        uint256 _sharesActionTimelock,
        bytes memory _feeManagerConfigData,
        bytes memory _policyManagerConfigData,
        bool _forMigration
    ) private returns (address comptrollerProxy_) {
        require(
            _denominationAsset != address(0),
            "__deployComptrollerProxy: _denominationAsset cannot be empty"
        );

        bytes memory constructData = abi.encodeWithSelector(
            IComptroller.init.selector,
            _denominationAsset,
            _sharesActionTimelock
        );
        comptrollerProxy_ = address(new ComptrollerProxy(constructData, comptrollerLib));

        if (_feeManagerConfigData.length > 0 || _policyManagerConfigData.length > 0) {
            IComptroller(comptrollerProxy_).configureExtensions(
                _feeManagerConfigData,
                _policyManagerConfigData
            );
        }

        emit ComptrollerProxyDeployed(
            msg.sender,
            comptrollerProxy_,
            _denominationAsset,
            _sharesActionTimelock,
            _feeManagerConfigData,
            _policyManagerConfigData,
            _forMigration
        );

        return comptrollerProxy_;
    }


    function cancelMigration(address _vaultProxy) external {
        __cancelMigration(_vaultProxy, false);
    }

    function cancelMigrationEmergency(address _vaultProxy) external {
        __cancelMigration(_vaultProxy, true);
    }

    function executeMigration(address _vaultProxy) external {
        __executeMigration(_vaultProxy, false);
    }

    function executeMigrationEmergency(address _vaultProxy) external {
        __executeMigration(_vaultProxy, true);
    }

    function invokeMigrationInCancelHook(
        address,
        address,
        address,
        address
    ) external virtual override {
        return;
    }

    function signalMigration(address _vaultProxy, address _comptrollerProxy) external {
        __signalMigration(_vaultProxy, _comptrollerProxy, false);
    }

    function signalMigrationEmergency(address _vaultProxy, address _comptrollerProxy) external {
        __signalMigration(_vaultProxy, _comptrollerProxy, true);
    }

    function __cancelMigration(address _vaultProxy, bool _bypassFailure)
        private
        onlyLiveRelease
        onlyMigrator(_vaultProxy)
    {
        IDispatcher(DISPATCHER).cancelMigration(_vaultProxy, _bypassFailure);
    }

    function __executeMigration(address _vaultProxy, bool _bypassFailure)
        private
        onlyLiveRelease
        onlyMigrator(_vaultProxy)
    {
        IDispatcher dispatcherContract = IDispatcher(DISPATCHER);

        (, address comptrollerProxy, , ) = dispatcherContract
            .getMigrationRequestDetailsForVaultProxy(_vaultProxy);

        dispatcherContract.executeMigration(_vaultProxy, _bypassFailure);

        IComptroller(comptrollerProxy).activate(_vaultProxy, true);

        delete pendingComptrollerProxyToCreator[comptrollerProxy];
    }

    function __signalMigration(
        address _vaultProxy,
        address _comptrollerProxy,
        bool _bypassFailure
    )
        private
        onlyLiveRelease
        onlyPendingComptrollerProxyCreator(_comptrollerProxy)
        onlyMigrator(_vaultProxy)
    {
        IDispatcher(DISPATCHER).signalMigration(
            _vaultProxy,
            _comptrollerProxy,
            VAULT_LIB,
            _bypassFailure
        );
    }


    function invokeMigrationOutHook(
        MigrationOutHook _hook,
        address _vaultProxy,
        address,
        address,
        address
    ) external override {
        if (_hook != MigrationOutHook.PreMigrate) {
            return;
        }

        require(
            msg.sender == DISPATCHER,
            "postMigrateOriginHook: Only Dispatcher can call this function"
        );

        address comptrollerProxy = IVault(_vaultProxy).getAccessor();

        IComptroller(comptrollerProxy).destruct();
    }


    function deregisterVaultCalls(address[] calldata _contracts, bytes4[] calldata _selectors)
        external
        onlyOwner
    {
        require(_contracts.length > 0, "deregisterVaultCalls: Empty _contracts");
        require(
            _contracts.length == _selectors.length,
            "deregisterVaultCalls: Uneven input arrays"
        );

        for (uint256 i; i < _contracts.length; i++) {
            require(
                isRegisteredVaultCall(_contracts[i], _selectors[i]),
                "deregisterVaultCalls: Call not registered"
            );

            contractToSelectorToIsRegisteredVaultCall[_contracts[i]][_selectors[i]] = false;

            emit VaultCallDeregistered(_contracts[i], _selectors[i]);
        }
    }

    function registerVaultCalls(address[] calldata _contracts, bytes4[] calldata _selectors)
        external
        onlyOwner
    {
        require(_contracts.length > 0, "registerVaultCalls: Empty _contracts");

        __registerVaultCalls(_contracts, _selectors);
    }

    function __registerVaultCalls(address[] memory _contracts, bytes4[] memory _selectors)
        private
    {
        require(
            _contracts.length == _selectors.length,
            "__registerVaultCalls: Uneven input arrays"
        );

        for (uint256 i; i < _contracts.length; i++) {
            require(
                !isRegisteredVaultCall(_contracts[i], _selectors[i]),
                "__registerVaultCalls: Call already registered"
            );

            contractToSelectorToIsRegisteredVaultCall[_contracts[i]][_selectors[i]] = true;

            emit VaultCallRegistered(_contracts[i], _selectors[i]);
        }
    }


    function getComptrollerLib() external view returns (address comptrollerLib_) {
        return comptrollerLib;
    }

    function getCreator() external view returns (address creator_) {
        return CREATOR;
    }

    function getDispatcher() external view returns (address dispatcher_) {
        return DISPATCHER;
    }

    function getPendingComptrollerProxyCreator(address _comptrollerProxy)
        external
        view
        returns (address pendingComptrollerProxyCreator_)
    {
        return pendingComptrollerProxyToCreator[_comptrollerProxy];
    }

    function getReleaseStatus() external view override returns (ReleaseStatus status_) {
        return releaseStatus;
    }

    function getVaultLib() external view returns (address vaultLib_) {
        return VAULT_LIB;
    }

    function isRegisteredVaultCall(address _contract, bytes4 _selector)
        public
        view
        override
        returns (bool isRegistered_)
    {
        return contractToSelectorToIsRegisteredVaultCall[_contract][_selector];
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract IntegrationManager is
    IIntegrationManager,
    ExtensionBase,
    FundDeployerOwnerMixin,
    PermissionedVaultActionMixin,
    AssetFinalityResolver
{
    using AddressArrayLib for address[];
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    event AdapterDeregistered(address indexed adapter, string indexed identifier);

    event AdapterRegistered(address indexed adapter, string indexed identifier);

    event AuthUserAddedForFund(address indexed comptrollerProxy, address indexed account);

    event AuthUserRemovedForFund(address indexed comptrollerProxy, address indexed account);

    event CallOnIntegrationExecutedForFund(
        address indexed comptrollerProxy,
        address vaultProxy,
        address caller,
        address indexed adapter,
        bytes4 indexed selector,
        bytes integrationData,
        address[] incomingAssets,
        uint256[] incomingAssetAmounts,
        address[] outgoingAssets,
        uint256[] outgoingAssetAmounts
    );

    address private immutable DERIVATIVE_PRICE_FEED;
    address private immutable POLICY_MANAGER;
    address private immutable PRIMITIVE_PRICE_FEED;

    EnumerableSet.AddressSet private registeredAdapters;

    mapping(address => mapping(address => bool)) private comptrollerProxyToAcctToIsAuthUser;

    constructor(
        address _fundDeployer,
        address _policyManager,
        address _derivativePriceFeed,
        address _primitivePriceFeed,
        address _synthetixPriceFeed,
        address _synthetixAddressResolver
    )
        public
        FundDeployerOwnerMixin(_fundDeployer)
        AssetFinalityResolver(_synthetixPriceFeed, _synthetixAddressResolver)
    {
        DERIVATIVE_PRICE_FEED = _derivativePriceFeed;
        POLICY_MANAGER = _policyManager;
        PRIMITIVE_PRICE_FEED = _primitivePriceFeed;
    }


    function activateForFund(bool) external override {
        __setValidatedVaultProxy(msg.sender);
    }

    function addAuthUserForFund(address _comptrollerProxy, address _who) external {
        __validateSetAuthUser(_comptrollerProxy, _who, true);

        comptrollerProxyToAcctToIsAuthUser[_comptrollerProxy][_who] = true;

        emit AuthUserAddedForFund(_comptrollerProxy, _who);
    }

    function deactivateForFund() external override {
        delete comptrollerProxyToVaultProxy[msg.sender];
    }

    function removeAuthUserForFund(address _comptrollerProxy, address _who) external {
        __validateSetAuthUser(_comptrollerProxy, _who, false);

        comptrollerProxyToAcctToIsAuthUser[_comptrollerProxy][_who] = false;

        emit AuthUserRemovedForFund(_comptrollerProxy, _who);
    }

    function isAuthUserForFund(address _comptrollerProxy, address _who)
        public
        view
        returns (bool isAuthUser_)
    {
        return
            comptrollerProxyToAcctToIsAuthUser[_comptrollerProxy][_who] ||
            _who == IVault(comptrollerProxyToVaultProxy[_comptrollerProxy]).getOwner();
    }

    function __validateSetAuthUser(
        address _comptrollerProxy,
        address _who,
        bool _nextIsAuthUser
    ) private view {
        require(
            comptrollerProxyToVaultProxy[_comptrollerProxy] != address(0),
            "__validateSetAuthUser: Fund has not been activated"
        );

        address fundOwner = IVault(comptrollerProxyToVaultProxy[_comptrollerProxy]).getOwner();
        require(
            msg.sender == fundOwner,
            "__validateSetAuthUser: Only the fund owner can call this function"
        );
        require(_who != fundOwner, "__validateSetAuthUser: Cannot set for the fund owner");

        if (_nextIsAuthUser) {
            require(
                !comptrollerProxyToAcctToIsAuthUser[_comptrollerProxy][_who],
                "__validateSetAuthUser: Account is already an authorized user"
            );
        } else {
            require(
                comptrollerProxyToAcctToIsAuthUser[_comptrollerProxy][_who],
                "__validateSetAuthUser: Account is not an authorized user"
            );
        }
    }


    function receiveCallFromComptroller(
        address _caller,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external override {
        address vaultProxy = comptrollerProxyToVaultProxy[msg.sender];
        require(vaultProxy != address(0), "receiveCallFromComptroller: Fund is not active");
        require(
            isAuthUserForFund(msg.sender, _caller),
            "receiveCallFromComptroller: Not an authorized user"
        );

        if (_actionId == 0) {
            __callOnIntegration(_caller, vaultProxy, _callArgs);
        } else if (_actionId == 1) {
            __addZeroBalanceTrackedAssets(vaultProxy, _callArgs);
        } else if (_actionId == 2) {
            __removeZeroBalanceTrackedAssets(vaultProxy, _callArgs);
        } else {
            revert("receiveCallFromComptroller: Invalid _actionId");
        }
    }

    function __addZeroBalanceTrackedAssets(address _vaultProxy, bytes memory _callArgs) private {
        address[] memory assets = abi.decode(_callArgs, (address[]));
        for (uint256 i; i < assets.length; i++) {
            require(
                __finalizeIfSynthAndGetAssetBalance(_vaultProxy, assets[i], true) == 0,
                "__addZeroBalanceTrackedAssets: Balance is not zero"
            );

            __addTrackedAsset(msg.sender, assets[i]);
        }
    }

    function __removeZeroBalanceTrackedAssets(address _vaultProxy, bytes memory _callArgs)
        private
    {
        address[] memory assets = abi.decode(_callArgs, (address[]));
        address denominationAsset = IComptroller(msg.sender).getDenominationAsset();
        for (uint256 i; i < assets.length; i++) {
            require(
                assets[i] != denominationAsset,
                "__removeZeroBalanceTrackedAssets: Cannot remove denomination asset"
            );
            require(
                __finalizeIfSynthAndGetAssetBalance(_vaultProxy, assets[i], true) == 0,
                "__removeZeroBalanceTrackedAssets: Balance is not zero"
            );

            __removeTrackedAsset(msg.sender, assets[i]);
        }
    }


    function __callOnIntegration(
        address _caller,
        address _vaultProxy,
        bytes memory _callArgs
    ) private {
        (
            address adapter,
            bytes4 selector,
            bytes memory integrationData
        ) = __decodeCallOnIntegrationArgs(_callArgs);

        __preCoIHook(adapter, selector);

        (
            address[] memory incomingAssets,
            uint256[] memory incomingAssetAmounts,
            address[] memory outgoingAssets,
            uint256[] memory outgoingAssetAmounts
        ) = __callOnIntegrationInner(_vaultProxy, _callArgs);

        __postCoIHook(
            adapter,
            selector,
            incomingAssets,
            incomingAssetAmounts,
            outgoingAssets,
            outgoingAssetAmounts
        );

        __emitCoIEvent(
            _vaultProxy,
            _caller,
            adapter,
            selector,
            integrationData,
            incomingAssets,
            incomingAssetAmounts,
            outgoingAssets,
            outgoingAssetAmounts
        );
    }

    function __callOnIntegrationInner(address vaultProxy, bytes memory _callArgs)
        private
        returns (
            address[] memory incomingAssets_,
            uint256[] memory incomingAssetAmounts_,
            address[] memory outgoingAssets_,
            uint256[] memory outgoingAssetAmounts_
        )
    {
        (
            address[] memory expectedIncomingAssets,
            uint256[] memory preCallIncomingAssetBalances,
            uint256[] memory minIncomingAssetAmounts,
            SpendAssetsHandleType spendAssetsHandleType,
            address[] memory spendAssets,
            uint256[] memory maxSpendAssetAmounts,
            uint256[] memory preCallSpendAssetBalances
        ) = __preProcessCoI(vaultProxy, _callArgs);

        __executeCoI(
            vaultProxy,
            _callArgs,
            abi.encode(
                spendAssetsHandleType,
                spendAssets,
                maxSpendAssetAmounts,
                expectedIncomingAssets
            )
        );

        (
            incomingAssets_,
            incomingAssetAmounts_,
            outgoingAssets_,
            outgoingAssetAmounts_
        ) = __postProcessCoI(
            vaultProxy,
            expectedIncomingAssets,
            preCallIncomingAssetBalances,
            minIncomingAssetAmounts,
            spendAssetsHandleType,
            spendAssets,
            maxSpendAssetAmounts,
            preCallSpendAssetBalances
        );

        return (incomingAssets_, incomingAssetAmounts_, outgoingAssets_, outgoingAssetAmounts_);
    }

    function __decodeCallOnIntegrationArgs(bytes memory _callArgs)
        private
        pure
        returns (
            address adapter_,
            bytes4 selector_,
            bytes memory integrationData_
        )
    {
        return abi.decode(_callArgs, (address, bytes4, bytes));
    }

    function __emitCoIEvent(
        address _vaultProxy,
        address _caller,
        address _adapter,
        bytes4 _selector,
        bytes memory _integrationData,
        address[] memory _incomingAssets,
        uint256[] memory _incomingAssetAmounts,
        address[] memory _outgoingAssets,
        uint256[] memory _outgoingAssetAmounts
    ) private {
        emit CallOnIntegrationExecutedForFund(
            msg.sender,
            _vaultProxy,
            _caller,
            _adapter,
            _selector,
            _integrationData,
            _incomingAssets,
            _incomingAssetAmounts,
            _outgoingAssets,
            _outgoingAssetAmounts
        );
    }

    function __executeCoI(
        address _vaultProxy,
        bytes memory _callArgs,
        bytes memory _encodedAssetTransferArgs
    ) private {
        (
            address adapter,
            bytes4 selector,
            bytes memory integrationData
        ) = __decodeCallOnIntegrationArgs(_callArgs);

        (bool success, bytes memory returnData) = adapter.call(
            abi.encodeWithSelector(
                selector,
                _vaultProxy,
                integrationData,
                _encodedAssetTransferArgs
            )
        );
        require(success, string(returnData));
    }

    function __getVaultAssetBalance(address _vaultProxy, address _asset)
        private
        view
        returns (uint256)
    {
        return ERC20(_asset).balanceOf(_vaultProxy);
    }

    function __isSupportedAsset(address _asset) private view returns (bool isSupported_) {
        return
            IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).isSupportedAsset(_asset) ||
            IDerivativePriceFeed(DERIVATIVE_PRICE_FEED).isSupportedAsset(_asset);
    }

    function __preCoIHook(address _adapter, bytes4 _selector) private {
        IPolicyManager(POLICY_MANAGER).validatePolicies(
            msg.sender,
            IPolicyManager.PolicyHook.PreCallOnIntegration,
            abi.encode(_adapter, _selector)
        );
    }

    function __preProcessCoI(address _vaultProxy, bytes memory _callArgs)
        private
        returns (
            address[] memory expectedIncomingAssets_,
            uint256[] memory preCallIncomingAssetBalances_,
            uint256[] memory minIncomingAssetAmounts_,
            SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory maxSpendAssetAmounts_,
            uint256[] memory preCallSpendAssetBalances_
        )
    {
        (
            address adapter,
            bytes4 selector,
            bytes memory integrationData
        ) = __decodeCallOnIntegrationArgs(_callArgs);

        require(adapterIsRegistered(adapter), "callOnIntegration: Adapter is not registered");

        (
            spendAssetsHandleType_,
            spendAssets_,
            maxSpendAssetAmounts_,
            expectedIncomingAssets_,
            minIncomingAssetAmounts_
        ) = IIntegrationAdapter(adapter).parseAssetsForMethod(selector, integrationData);
        require(
            spendAssets_.length == maxSpendAssetAmounts_.length,
            "__preProcessCoI: Spend assets arrays unequal"
        );
        require(
            expectedIncomingAssets_.length == minIncomingAssetAmounts_.length,
            "__preProcessCoI: Incoming assets arrays unequal"
        );
        require(spendAssets_.isUniqueSet(), "__preProcessCoI: Duplicate spend asset");
        require(
            expectedIncomingAssets_.isUniqueSet(),
            "__preProcessCoI: Duplicate incoming asset"
        );

        IVault vaultProxyContract = IVault(_vaultProxy);

        preCallIncomingAssetBalances_ = new uint256[](expectedIncomingAssets_.length);
        for (uint256 i = 0; i < expectedIncomingAssets_.length; i++) {
            require(
                expectedIncomingAssets_[i] != address(0),
                "__preProcessCoI: Empty incoming asset address"
            );
            require(
                minIncomingAssetAmounts_[i] > 0,
                "__preProcessCoI: minIncomingAssetAmount must be >0"
            );
            require(
                __isSupportedAsset(expectedIncomingAssets_[i]),
                "__preProcessCoI: Non-receivable incoming asset"
            );

            if (vaultProxyContract.isTrackedAsset(expectedIncomingAssets_[i])) {
                preCallIncomingAssetBalances_[i] = __finalizeIfSynthAndGetAssetBalance(
                    _vaultProxy,
                    expectedIncomingAssets_[i],
                    false
                );
            }
        }

        preCallSpendAssetBalances_ = new uint256[](spendAssets_.length);
        for (uint256 i = 0; i < spendAssets_.length; i++) {
            require(spendAssets_[i] != address(0), "__preProcessCoI: Empty spend asset");
            require(maxSpendAssetAmounts_[i] > 0, "__preProcessCoI: Empty max spend asset amount");
            require(
                vaultProxyContract.isTrackedAsset(spendAssets_[i]) ||
                    __isSupportedAsset(spendAssets_[i]),
                "__preProcessCoI: Non-spendable spend asset"
            );

            if (!expectedIncomingAssets_.contains(spendAssets_[i])) {
                preCallSpendAssetBalances_[i] = __finalizeIfSynthAndGetAssetBalance(
                    _vaultProxy,
                    spendAssets_[i],
                    true
                );
            }

            if (spendAssetsHandleType_ == SpendAssetsHandleType.Approve) {
                __approveAssetSpender(
                    msg.sender,
                    spendAssets_[i],
                    adapter,
                    maxSpendAssetAmounts_[i]
                );
            } else if (spendAssetsHandleType_ == SpendAssetsHandleType.Transfer) {
                __withdrawAssetTo(msg.sender, spendAssets_[i], adapter, maxSpendAssetAmounts_[i]);
            } else if (spendAssetsHandleType_ == SpendAssetsHandleType.Remove) {
                __removeTrackedAsset(msg.sender, spendAssets_[i]);
            }
        }
    }

    function __postCoIHook(
        address _adapter,
        bytes4 _selector,
        address[] memory _incomingAssets,
        uint256[] memory _incomingAssetAmounts,
        address[] memory _outgoingAssets,
        uint256[] memory _outgoingAssetAmounts
    ) private {
        IPolicyManager(POLICY_MANAGER).validatePolicies(
            msg.sender,
            IPolicyManager.PolicyHook.PostCallOnIntegration,
            abi.encode(
                _adapter,
                _selector,
                _incomingAssets,
                _incomingAssetAmounts,
                _outgoingAssets,
                _outgoingAssetAmounts
            )
        );
    }

    function __postProcessCoI(
        address _vaultProxy,
        address[] memory _expectedIncomingAssets,
        uint256[] memory _preCallIncomingAssetBalances,
        uint256[] memory _minIncomingAssetAmounts,
        SpendAssetsHandleType _spendAssetsHandleType,
        address[] memory _spendAssets,
        uint256[] memory _maxSpendAssetAmounts,
        uint256[] memory _preCallSpendAssetBalances
    )
        private
        returns (
            address[] memory incomingAssets_,
            uint256[] memory incomingAssetAmounts_,
            address[] memory outgoingAssets_,
            uint256[] memory outgoingAssetAmounts_
        )
    {
        address[] memory increasedSpendAssets;
        uint256[] memory increasedSpendAssetAmounts;
        (
            outgoingAssets_,
            outgoingAssetAmounts_,
            increasedSpendAssets,
            increasedSpendAssetAmounts
        ) = __reconcileCoISpendAssets(
            _vaultProxy,
            _spendAssetsHandleType,
            _spendAssets,
            _maxSpendAssetAmounts,
            _preCallSpendAssetBalances
        );

        (incomingAssets_, incomingAssetAmounts_) = __reconcileCoIIncomingAssets(
            _vaultProxy,
            _expectedIncomingAssets,
            _preCallIncomingAssetBalances,
            _minIncomingAssetAmounts,
            increasedSpendAssets,
            increasedSpendAssetAmounts
        );

        return (incomingAssets_, incomingAssetAmounts_, outgoingAssets_, outgoingAssetAmounts_);
    }

    function __reconcileCoIIncomingAssets(
        address _vaultProxy,
        address[] memory _expectedIncomingAssets,
        uint256[] memory _preCallIncomingAssetBalances,
        uint256[] memory _minIncomingAssetAmounts,
        address[] memory _increasedSpendAssets,
        uint256[] memory _increasedSpendAssetAmounts
    ) private returns (address[] memory incomingAssets_, uint256[] memory incomingAssetAmounts_) {
        uint256 incomingAssetsCount = _expectedIncomingAssets.length.add(
            _increasedSpendAssets.length
        );

        incomingAssets_ = new address[](incomingAssetsCount);
        incomingAssetAmounts_ = new uint256[](incomingAssetsCount);
        for (uint256 i = 0; i < _expectedIncomingAssets.length; i++) {
            uint256 balanceDiff = __getVaultAssetBalance(_vaultProxy, _expectedIncomingAssets[i])
                .sub(_preCallIncomingAssetBalances[i]);
            require(
                balanceDiff >= _minIncomingAssetAmounts[i],
                "__reconcileCoIAssets: Received incoming asset less than expected"
            );

            __addTrackedAsset(msg.sender, _expectedIncomingAssets[i]);

            incomingAssets_[i] = _expectedIncomingAssets[i];
            incomingAssetAmounts_[i] = balanceDiff;
        }

        if (_increasedSpendAssets.length > 0) {
            uint256 incomingAssetIndex = _expectedIncomingAssets.length;
            for (uint256 i = 0; i < _increasedSpendAssets.length; i++) {
                incomingAssets_[incomingAssetIndex] = _increasedSpendAssets[i];
                incomingAssetAmounts_[incomingAssetIndex] = _increasedSpendAssetAmounts[i];
                incomingAssetIndex++;
            }
        }

        return (incomingAssets_, incomingAssetAmounts_);
    }

    function __reconcileCoISpendAssets(
        address _vaultProxy,
        SpendAssetsHandleType _spendAssetsHandleType,
        address[] memory _spendAssets,
        uint256[] memory _maxSpendAssetAmounts,
        uint256[] memory _preCallSpendAssetBalances
    )
        private
        returns (
            address[] memory outgoingAssets_,
            uint256[] memory outgoingAssetAmounts_,
            address[] memory increasedSpendAssets_,
            uint256[] memory increasedSpendAssetAmounts_
        )
    {
        uint256[] memory postCallSpendAssetBalances = new uint256[](_spendAssets.length);
        uint256 outgoingAssetsCount;
        uint256 increasedSpendAssetsCount;
        for (uint256 i = 0; i < _spendAssets.length; i++) {
            if (_preCallSpendAssetBalances[i] == 0) {
                continue;
            }

            if (_spendAssetsHandleType == SpendAssetsHandleType.Remove) {
                outgoingAssetsCount++;
                continue;
            }

            postCallSpendAssetBalances[i] = __getVaultAssetBalance(_vaultProxy, _spendAssets[i]);
            if (postCallSpendAssetBalances[i] < _preCallSpendAssetBalances[i]) {
                outgoingAssetsCount++;
            } else if (postCallSpendAssetBalances[i] > _preCallSpendAssetBalances[i]) {
                increasedSpendAssetsCount++;
            }
        }

        outgoingAssets_ = new address[](outgoingAssetsCount);
        outgoingAssetAmounts_ = new uint256[](outgoingAssetsCount);
        increasedSpendAssets_ = new address[](increasedSpendAssetsCount);
        increasedSpendAssetAmounts_ = new uint256[](increasedSpendAssetsCount);
        uint256 outgoingAssetsIndex;
        uint256 increasedSpendAssetsIndex;
        for (uint256 i = 0; i < _spendAssets.length; i++) {
            if (_preCallSpendAssetBalances[i] == 0) {
                continue;
            }

            if (_spendAssetsHandleType == SpendAssetsHandleType.Remove) {
                outgoingAssets_[outgoingAssetsIndex] = _spendAssets[i];
                outgoingAssetAmounts_[outgoingAssetsIndex] = _preCallSpendAssetBalances[i];
                outgoingAssetsIndex++;
                continue;
            }

            if (postCallSpendAssetBalances[i] < _preCallSpendAssetBalances[i]) {
                if (postCallSpendAssetBalances[i] == 0) {
                    __removeTrackedAsset(msg.sender, _spendAssets[i]);
                    outgoingAssetAmounts_[outgoingAssetsIndex] = _preCallSpendAssetBalances[i];
                } else {
                    outgoingAssetAmounts_[outgoingAssetsIndex] = _preCallSpendAssetBalances[i].sub(
                        postCallSpendAssetBalances[i]
                    );
                }
                require(
                    outgoingAssetAmounts_[outgoingAssetsIndex] <= _maxSpendAssetAmounts[i],
                    "__reconcileCoISpendAssets: Spent amount greater than expected"
                );

                outgoingAssets_[outgoingAssetsIndex] = _spendAssets[i];
                outgoingAssetsIndex++;
            } else if (postCallSpendAssetBalances[i] > _preCallSpendAssetBalances[i]) {
                increasedSpendAssetAmounts_[increasedSpendAssetsIndex] = postCallSpendAssetBalances[i]
                    .sub(_preCallSpendAssetBalances[i]);
                increasedSpendAssets_[increasedSpendAssetsIndex] = _spendAssets[i];
                increasedSpendAssetsIndex++;
            }
        }

        return (
            outgoingAssets_,
            outgoingAssetAmounts_,
            increasedSpendAssets_,
            increasedSpendAssetAmounts_
        );
    }


    function deregisterAdapters(address[] calldata _adapters) external onlyFundDeployerOwner {
        require(_adapters.length > 0, "deregisterAdapters: _adapters cannot be empty");

        for (uint256 i; i < _adapters.length; i++) {
            require(
                adapterIsRegistered(_adapters[i]),
                "deregisterAdapters: Adapter is not registered"
            );

            registeredAdapters.remove(_adapters[i]);

            emit AdapterDeregistered(_adapters[i], IIntegrationAdapter(_adapters[i]).identifier());
        }
    }

    function registerAdapters(address[] calldata _adapters) external onlyFundDeployerOwner {
        require(_adapters.length > 0, "registerAdapters: _adapters cannot be empty");

        for (uint256 i; i < _adapters.length; i++) {
            require(_adapters[i] != address(0), "registerAdapters: Adapter cannot be empty");

            require(
                !adapterIsRegistered(_adapters[i]),
                "registerAdapters: Adapter already registered"
            );

            registeredAdapters.add(_adapters[i]);

            emit AdapterRegistered(_adapters[i], IIntegrationAdapter(_adapters[i]).identifier());
        }
    }


    function adapterIsRegistered(address _adapter) public view returns (bool isRegistered_) {
        return registeredAdapters.contains(_adapter);
    }

    function getDerivativePriceFeed() external view returns (address derivativePriceFeed_) {
        return DERIVATIVE_PRICE_FEED;
    }

    function getPolicyManager() external view returns (address policyManager_) {
        return POLICY_MANAGER;
    }

    function getPrimitivePriceFeed() external view returns (address primitivePriceFeed_) {
        return PRIMITIVE_PRICE_FEED;
    }

    function getRegisteredAdapters()
        external
        view
        returns (address[] memory registeredAdaptersArray_)
    {
        registeredAdaptersArray_ = new address[](registeredAdapters.length());
        for (uint256 i = 0; i < registeredAdaptersArray_.length; i++) {
            registeredAdaptersArray_[i] = registeredAdapters.at(i);
        }

        return registeredAdaptersArray_;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract SynthetixAdapter is AdapterBase {
    address private immutable ORIGINATOR;
    address private immutable SYNTHETIX;
    address private immutable SYNTHETIX_PRICE_FEED;
    bytes32 private immutable TRACKING_CODE;

    constructor(
        address _integrationManager,
        address _synthetixPriceFeed,
        address _originator,
        address _synthetix,
        bytes32 _trackingCode
    ) public AdapterBase(_integrationManager) {
        ORIGINATOR = _originator;
        SYNTHETIX = _synthetix;
        SYNTHETIX_PRICE_FEED = _synthetixPriceFeed;
        TRACKING_CODE = _trackingCode;
    }


    function identifier() external pure override returns (string memory identifier_) {
        return "SYNTHETIX";
    }

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        require(_selector == TAKE_ORDER_SELECTOR, "parseAssetsForMethod: _selector invalid");

        (
            address incomingAsset,
            uint256 minIncomingAssetAmount,
            address outgoingAsset,
            uint256 outgoingAssetAmount
        ) = __decodeCallArgs(_encodedCallArgs);

        spendAssets_ = new address[](1);
        spendAssets_[0] = outgoingAsset;
        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingAssetAmount;

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = incomingAsset;
        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingAssetAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.None,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function takeOrder(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata
    ) external onlyIntegrationManager {
        (
            address incomingAsset,
            ,
            address outgoingAsset,
            uint256 outgoingAssetAmount
        ) = __decodeCallArgs(_encodedCallArgs);

        address[] memory synths = new address[](2);
        synths[0] = outgoingAsset;
        synths[1] = incomingAsset;

        bytes32[] memory currencyKeys = SynthetixPriceFeed(SYNTHETIX_PRICE_FEED)
            .getCurrencyKeysForSynths(synths);

        ISynthetix(SYNTHETIX).exchangeOnBehalfWithTracking(
            _vaultProxy,
            currencyKeys[0],
            outgoingAssetAmount,
            currencyKeys[1],
            ORIGINATOR,
            TRACKING_CODE
        );
    }


    function __decodeCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address incomingAsset_,
            uint256 minIncomingAssetAmount_,
            address outgoingAsset_,
            uint256 outgoingAssetAmount_
        )
    {
        return abi.decode(_encodedCallArgs, (address, uint256, address, uint256));
    }


    function getOriginator() external view returns (address originator_) {
        return ORIGINATOR;
    }

    function getSynthetix() external view returns (address synthetix_) {
        return SYNTHETIX;
    }

    function getSynthetixPriceFeed() external view returns (address synthetixPriceFeed_) {
        return SYNTHETIX_PRICE_FEED;
    }

    function getTrackingCode() external view returns (bytes32 trackingCode_) {
        return TRACKING_CODE;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract ChainlinkPriceFeed is IPrimitivePriceFeed, DispatcherOwnerMixin {
    using SafeMath for uint256;

    event EthUsdAggregatorSet(address prevEthUsdAggregator, address nextEthUsdAggregator);

    event PrimitiveAdded(
        address indexed primitive,
        address aggregator,
        RateAsset rateAsset,
        uint256 unit
    );

    event PrimitiveRemoved(address indexed primitive);

    event PrimitiveUpdated(
        address indexed primitive,
        address prevAggregator,
        address nextAggregator
    );

    event StalePrimitiveRemoved(address indexed primitive);

    event StaleRateThresholdSet(uint256 prevStaleRateThreshold, uint256 nextStaleRateThreshold);

    enum RateAsset {ETH, USD}

    struct AggregatorInfo {
        address aggregator;
        RateAsset rateAsset;
    }

    uint256 private constant ETH_UNIT = 10**18;
    address private immutable WETH_TOKEN;

    address private ethUsdAggregator;
    uint256 private staleRateThreshold;
    mapping(address => AggregatorInfo) private primitiveToAggregatorInfo;
    mapping(address => uint256) private primitiveToUnit;

    constructor(
        address _dispatcher,
        address _wethToken,
        address _ethUsdAggregator,
        address[] memory _primitives,
        address[] memory _aggregators,
        RateAsset[] memory _rateAssets
    ) public DispatcherOwnerMixin(_dispatcher) {
        WETH_TOKEN = _wethToken;
        staleRateThreshold = 25 hours; // 24 hour heartbeat + 1hr buffer
        __setEthUsdAggregator(_ethUsdAggregator);
        if (_primitives.length > 0) {
            __addPrimitives(_primitives, _aggregators, _rateAssets);
        }
    }


    function calcCanonicalValue(
        address _baseAsset,
        uint256 _baseAssetAmount,
        address _quoteAsset
    ) public view override returns (uint256 quoteAssetAmount_, bool isValid_) {

        int256 baseAssetRate = __getLatestRateData(_baseAsset);
        if (baseAssetRate <= 0) {
            return (0, false);
        }

        int256 quoteAssetRate = __getLatestRateData(_quoteAsset);
        if (quoteAssetRate <= 0) {
            return (0, false);
        }

        (quoteAssetAmount_, isValid_) = __calcConversionAmount(
            _baseAsset,
            _baseAssetAmount,
            uint256(baseAssetRate),
            _quoteAsset,
            uint256(quoteAssetRate)
        );

        return (quoteAssetAmount_, isValid_);
    }

    function calcLiveValue(
        address _baseAsset,
        uint256 _baseAssetAmount,
        address _quoteAsset
    ) external view override returns (uint256 quoteAssetAmount_, bool isValid_) {
        return calcCanonicalValue(_baseAsset, _baseAssetAmount, _quoteAsset);
    }

    function isSupportedAsset(address _asset) external view override returns (bool isSupported_) {
        return _asset == WETH_TOKEN || primitiveToAggregatorInfo[_asset].aggregator != address(0);
    }

    function setEthUsdAggregator(address _nextEthUsdAggregator) external onlyDispatcherOwner {
        __setEthUsdAggregator(_nextEthUsdAggregator);
    }


    function __calcConversionAmount(
        address _baseAsset,
        uint256 _baseAssetAmount,
        uint256 _baseAssetRate,
        address _quoteAsset,
        uint256 _quoteAssetRate
    ) private view returns (uint256 quoteAssetAmount_, bool isValid_) {
        RateAsset baseAssetRateAsset = getRateAssetForPrimitive(_baseAsset);
        RateAsset quoteAssetRateAsset = getRateAssetForPrimitive(_quoteAsset);
        uint256 baseAssetUnit = getUnitForPrimitive(_baseAsset);
        uint256 quoteAssetUnit = getUnitForPrimitive(_quoteAsset);

        if (baseAssetRateAsset == quoteAssetRateAsset) {
            return (
                __calcConversionAmountSameRateAsset(
                    _baseAssetAmount,
                    baseAssetUnit,
                    _baseAssetRate,
                    quoteAssetUnit,
                    _quoteAssetRate
                ),
                true
            );
        }

        int256 ethPerUsdRate = IChainlinkAggregator(ethUsdAggregator).latestAnswer();
        if (ethPerUsdRate <= 0) {
            return (0, false);
        }

        if (baseAssetRateAsset == RateAsset.ETH) {
            return (
                __calcConversionAmountEthRateAssetToUsdRateAsset(
                    _baseAssetAmount,
                    baseAssetUnit,
                    _baseAssetRate,
                    quoteAssetUnit,
                    _quoteAssetRate,
                    uint256(ethPerUsdRate)
                ),
                true
            );
        }

        return (
            __calcConversionAmountUsdRateAssetToEthRateAsset(
                _baseAssetAmount,
                baseAssetUnit,
                _baseAssetRate,
                quoteAssetUnit,
                _quoteAssetRate,
                uint256(ethPerUsdRate)
            ),
            true
        );
    }

    function __calcConversionAmountEthRateAssetToUsdRateAsset(
        uint256 _baseAssetAmount,
        uint256 _baseAssetUnit,
        uint256 _baseAssetRate,
        uint256 _quoteAssetUnit,
        uint256 _quoteAssetRate,
        uint256 _ethPerUsdRate
    ) private pure returns (uint256 quoteAssetAmount_) {
        uint256 intermediateStep = _baseAssetAmount.mul(_baseAssetRate).mul(_ethPerUsdRate).div(
            ETH_UNIT
        );

        return intermediateStep.mul(_quoteAssetUnit).div(_baseAssetUnit).div(_quoteAssetRate);
    }

    function __calcConversionAmountSameRateAsset(
        uint256 _baseAssetAmount,
        uint256 _baseAssetUnit,
        uint256 _baseAssetRate,
        uint256 _quoteAssetUnit,
        uint256 _quoteAssetRate
    ) private pure returns (uint256 quoteAssetAmount_) {
        return
            _baseAssetAmount.mul(_baseAssetRate).mul(_quoteAssetUnit).div(
                _baseAssetUnit.mul(_quoteAssetRate)
            );
    }

    function __calcConversionAmountUsdRateAssetToEthRateAsset(
        uint256 _baseAssetAmount,
        uint256 _baseAssetUnit,
        uint256 _baseAssetRate,
        uint256 _quoteAssetUnit,
        uint256 _quoteAssetRate,
        uint256 _ethPerUsdRate
    ) private pure returns (uint256 quoteAssetAmount_) {
        uint256 intermediateStep = _baseAssetAmount.mul(_baseAssetRate).mul(_quoteAssetUnit).div(
            _ethPerUsdRate
        );

        return intermediateStep.mul(ETH_UNIT).div(_baseAssetUnit).div(_quoteAssetRate);
    }

    function __getLatestRateData(address _primitive) private view returns (int256 rate_) {
        if (_primitive == WETH_TOKEN) {
            return int256(ETH_UNIT);
        }

        address aggregator = primitiveToAggregatorInfo[_primitive].aggregator;
        require(aggregator != address(0), "__getLatestRateData: Primitive does not exist");

        return IChainlinkAggregator(aggregator).latestAnswer();
    }

    function __setEthUsdAggregator(address _nextEthUsdAggregator) private {
        address prevEthUsdAggregator = ethUsdAggregator;
        require(
            _nextEthUsdAggregator != prevEthUsdAggregator,
            "__setEthUsdAggregator: Value already set"
        );

        __validateAggregator(_nextEthUsdAggregator);

        ethUsdAggregator = _nextEthUsdAggregator;

        emit EthUsdAggregatorSet(prevEthUsdAggregator, _nextEthUsdAggregator);
    }


    function addPrimitives(
        address[] calldata _primitives,
        address[] calldata _aggregators,
        RateAsset[] calldata _rateAssets
    ) external onlyDispatcherOwner {
        require(_primitives.length > 0, "addPrimitives: _primitives cannot be empty");

        __addPrimitives(_primitives, _aggregators, _rateAssets);
    }

    function removePrimitives(address[] calldata _primitives) external onlyDispatcherOwner {
        require(_primitives.length > 0, "removePrimitives: _primitives cannot be empty");

        for (uint256 i; i < _primitives.length; i++) {
            require(
                primitiveToAggregatorInfo[_primitives[i]].aggregator != address(0),
                "removePrimitives: Primitive not yet added"
            );

            delete primitiveToAggregatorInfo[_primitives[i]];
            delete primitiveToUnit[_primitives[i]];

            emit PrimitiveRemoved(_primitives[i]);
        }
    }

    function removeStalePrimitives(address[] calldata _primitives) external {
        require(_primitives.length > 0, "removeStalePrimitives: _primitives cannot be empty");

        for (uint256 i; i < _primitives.length; i++) {
            address aggregatorAddress = primitiveToAggregatorInfo[_primitives[i]].aggregator;
            require(aggregatorAddress != address(0), "removeStalePrimitives: Invalid primitive");
            require(rateIsStale(aggregatorAddress), "removeStalePrimitives: Rate is not stale");

            delete primitiveToAggregatorInfo[_primitives[i]];
            delete primitiveToUnit[_primitives[i]];

            emit StalePrimitiveRemoved(_primitives[i]);
        }
    }

    function setStaleRateThreshold(uint256 _nextStaleRateThreshold) external onlyDispatcherOwner {
        uint256 prevStaleRateThreshold = staleRateThreshold;
        require(
            _nextStaleRateThreshold != prevStaleRateThreshold,
            "__setStaleRateThreshold: Value already set"
        );

        staleRateThreshold = _nextStaleRateThreshold;

        emit StaleRateThresholdSet(prevStaleRateThreshold, _nextStaleRateThreshold);
    }

    function updatePrimitives(address[] calldata _primitives, address[] calldata _aggregators)
        external
        onlyDispatcherOwner
    {
        require(_primitives.length > 0, "updatePrimitives: _primitives cannot be empty");
        require(
            _primitives.length == _aggregators.length,
            "updatePrimitives: Unequal _primitives and _aggregators array lengths"
        );

        for (uint256 i; i < _primitives.length; i++) {
            address prevAggregator = primitiveToAggregatorInfo[_primitives[i]].aggregator;
            require(prevAggregator != address(0), "updatePrimitives: Primitive not yet added");
            require(_aggregators[i] != prevAggregator, "updatePrimitives: Value already set");

            __validateAggregator(_aggregators[i]);

            primitiveToAggregatorInfo[_primitives[i]].aggregator = _aggregators[i];

            emit PrimitiveUpdated(_primitives[i], prevAggregator, _aggregators[i]);
        }
    }

    function rateIsStale(address _aggregator) public view returns (bool rateIsStale_) {
        return
            IChainlinkAggregator(_aggregator).latestTimestamp() <
            block.timestamp.sub(staleRateThreshold);
    }

    function __addPrimitives(
        address[] memory _primitives,
        address[] memory _aggregators,
        RateAsset[] memory _rateAssets
    ) private {
        require(
            _primitives.length == _aggregators.length,
            "__addPrimitives: Unequal _primitives and _aggregators array lengths"
        );
        require(
            _primitives.length == _rateAssets.length,
            "__addPrimitives: Unequal _primitives and _rateAssets array lengths"
        );

        for (uint256 i = 0; i < _primitives.length; i++) {
            require(
                primitiveToAggregatorInfo[_primitives[i]].aggregator == address(0),
                "__addPrimitives: Value already set"
            );

            __validateAggregator(_aggregators[i]);

            primitiveToAggregatorInfo[_primitives[i]] = AggregatorInfo({
                aggregator: _aggregators[i],
                rateAsset: _rateAssets[i]
            });

            uint256 unit = 10**uint256(ERC20(_primitives[i]).decimals());
            primitiveToUnit[_primitives[i]] = unit;

            emit PrimitiveAdded(_primitives[i], _aggregators[i], _rateAssets[i], unit);
        }
    }

    function __validateAggregator(address _aggregator) private view {
        require(_aggregator != address(0), "__validateAggregator: Empty _aggregator");

        require(
            IChainlinkAggregator(_aggregator).latestAnswer() > 0,
            "__validateAggregator: No rate detected"
        );
        require(!rateIsStale(_aggregator), "__validateAggregator: Stale rate detected");
    }


    function getAggregatorInfoForPrimitive(address _primitive)
        external
        view
        returns (AggregatorInfo memory aggregatorInfo_)
    {
        return primitiveToAggregatorInfo[_primitive];
    }

    function getEthUsdAggregator() external view returns (address ethUsdAggregator_) {
        return ethUsdAggregator;
    }

    function getStaleRateThreshold() external view returns (uint256 staleRateThreshold_) {
        return staleRateThreshold;
    }

    function getWethToken() external view returns (address wethToken_) {
        return WETH_TOKEN;
    }

    function getRateAssetForPrimitive(address _primitive)
        public
        view
        returns (RateAsset rateAsset_)
    {
        if (_primitive == WETH_TOKEN) {
            return RateAsset.ETH;
        }

        return primitiveToAggregatorInfo[_primitive].rateAsset;
    }

    function getUnitForPrimitive(address _primitive) public view returns (uint256 unit_) {
        if (_primitive == WETH_TOKEN) {
            return ETH_UNIT;
        }

        return primitiveToUnit[_primitive];
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}// GPL-3.0


pragma solidity 0.6.12;


contract CentralizedRateProvider is Ownable {
    using SafeMath for uint256;

    address private immutable WETH;
    uint256 private maxDeviationPerSender;

    address private valueInterpreter;
    address private aggregateDerivativePriceFeed;
    address private primitivePriceFeed;

    constructor(address _weth, uint256 _maxDeviationPerSender) public {
        maxDeviationPerSender = _maxDeviationPerSender;
        WETH = _weth;
    }

    function calcLiveAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) public returns (uint256 value_) {
        uint256 baseDecimalsRate = 10**uint256(ERC20(_baseAsset).decimals());
        uint256 quoteDecimalsRate = 10**uint256(ERC20(_quoteAsset).decimals());

        if (IPrimitivePriceFeed(primitivePriceFeed).isSupportedAsset(_quoteAsset)) {
            (value_, ) = IValueInterpreter(valueInterpreter).calcLiveAssetValue(
                _baseAsset,
                _amount,
                _quoteAsset
            );
            return value_;
        }

        if (IPrimitivePriceFeed(primitivePriceFeed).isSupportedAsset(_baseAsset)) {
            (uint256 inverseRate, ) = IValueInterpreter(valueInterpreter).calcLiveAssetValue(
                _quoteAsset,
                10**uint256(ERC20(_quoteAsset).decimals()),
                _baseAsset
            );

            uint256 rate = uint256(baseDecimalsRate).mul(quoteDecimalsRate).div(inverseRate);

            value_ = _amount.mul(rate).div(baseDecimalsRate);
            return value_;
        }

        (uint256 baseToWeth, ) = IValueInterpreter(valueInterpreter).calcLiveAssetValue(
            _baseAsset,
            baseDecimalsRate,
            WETH
        );

        (uint256 quoteToWeth, ) = IValueInterpreter(valueInterpreter).calcLiveAssetValue(
            _quoteAsset,
            quoteDecimalsRate,
            WETH
        );

        value_ = _amount.mul(baseToWeth).mul(quoteDecimalsRate).div(quoteToWeth).div(
            baseDecimalsRate
        );
        return value_;
    }

    function calcLiveAssetValueRandomized(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset,
        uint256 _maxDeviationPerBlock
    ) external returns (uint256 value_) {
        uint256 liveAssetValue = calcLiveAssetValue(_baseAsset, _amount, _quoteAsset);

        uint256 senderRandomizedValue_ = __calcValueRandomizedByAddress(
            liveAssetValue,
            msg.sender,
            maxDeviationPerSender
        );

        value_ = __calcValueRandomizedByUint(
            senderRandomizedValue_,
            block.number,
            _maxDeviationPerBlock
        );

        return value_;
    }

    function calcLiveAssetValueRandomizedByBlockNumber(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset,
        uint256 _maxDeviationPerBlock
    ) external returns (uint256 value_) {
        uint256 liveAssetValue = calcLiveAssetValue(_baseAsset, _amount, _quoteAsset);

        value_ = __calcValueRandomizedByUint(liveAssetValue, block.number, _maxDeviationPerBlock);

        return value_;
    }

    function calcLiveAssetValueRandomizedBySender(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) external returns (uint256 value_) {
        uint256 liveAssetValue = calcLiveAssetValue(_baseAsset, _amount, _quoteAsset);

        value_ = __calcValueRandomizedByAddress(liveAssetValue, msg.sender, maxDeviationPerSender);

        return value_;
    }

    function setMaxDeviationPerSender(uint256 _maxDeviationPerSender) external onlyOwner {
        maxDeviationPerSender = _maxDeviationPerSender;
    }

    function setReleasePriceAddresses(
        address _valueInterpreter,
        address _aggregateDerivativePriceFeed,
        address _primitivePriceFeed
    ) external onlyOwner {
        valueInterpreter = _valueInterpreter;
        aggregateDerivativePriceFeed = _aggregateDerivativePriceFeed;
        primitivePriceFeed = _primitivePriceFeed;
    }


    function __calcValueRandomizedByAddress(
        uint256 _meanValue,
        address _seed,
        uint256 _maxDeviation
    ) private pure returns (uint256 value_) {
        uint256 senderRandomFactor = uint256(uint8(_seed))
            .mul(100)
            .div(256)
            .mul(_maxDeviation)
            .div(100);

        value_ = __calcDeviatedValue(_meanValue, senderRandomFactor, _maxDeviation);

        return value_;
    }

    function __calcValueRandomizedByUint(
        uint256 _meanValue,
        uint256 _seed,
        uint256 _maxDeviation
    ) private pure returns (uint256 value_) {
        uint256 randomFactor = (_seed.mod(2).mul(20))
            .add((_seed.mod(3).mul(40)))
            .mul(_maxDeviation)
            .div(100);

        value_ = __calcDeviatedValue(_meanValue, randomFactor, _maxDeviation);

        return value_;
    }

    function __calcDeviatedValue(
        uint256 _meanValue,
        uint256 _offset,
        uint256 _maxDeviation
    ) private pure returns (uint256 value_) {
        return
            _meanValue.add((_meanValue.mul((uint256(2)).mul(_offset)).div(uint256(100)))).sub(
                _meanValue.mul(_maxDeviation).div(uint256(100))
            );
    }


    function getMaxDeviationPerSender() public view returns (uint256 maxDeviationPerSender_) {
        return maxDeviationPerSender;
    }

    function getValueInterpreter() public view returns (address valueInterpreter_) {
        return valueInterpreter;
    }
}// MIT

pragma solidity ^0.6.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockToken is ERC20Burnable, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) private addressToIsMinter;

    modifier onlyMinter() {
        require(
            addressToIsMinter[msg.sender] || owner() == msg.sender,
            "msg.sender is not owner or minter"
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public ERC20(_name, _symbol) {
        _setupDecimals(_decimals);
        _mint(msg.sender, uint256(100000000).mul(10**uint256(_decimals)));
    }

    function mintFor(address _who, uint256 _amount) external onlyMinter {
        _mint(_who, _amount);
    }

    function mint(uint256 _amount) external onlyMinter {
        _mint(msg.sender, _amount);
    }

    function addMinters(address[] memory _minters) public onlyOwner {
        for (uint256 i = 0; i < _minters.length; i++) {
            addressToIsMinter[_minters[i]] = true;
        }
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockUniswapV2PriceSource is MockToken("Uniswap V2", "UNI-V2", 18) {
    using SafeMath for uint256;

    address private immutable TOKEN_0;
    address private immutable TOKEN_1;
    address private immutable CENTRALIZED_RATE_PROVIDER;

    constructor(
        address _centralizedRateProvider,
        address _token0,
        address _token1
    ) public {
        CENTRALIZED_RATE_PROVIDER = _centralizedRateProvider;
        TOKEN_0 = _token0;
        TOKEN_1 = _token1;
    }

    function getReserves()
        external
        returns (
            uint112 reserve0_,
            uint112 reserve1_,
            uint32 blockTimestampLast_
        )
    {
        uint256 baseAmount = ERC20(TOKEN_0).balanceOf(address(this));
        reserve0_ = uint112(baseAmount);
        reserve1_ = uint112(
            CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER).calcLiveAssetValue(
                TOKEN_0,
                baseAmount,
                TOKEN_1
            )
        );

        return (reserve0_, reserve1_, blockTimestampLast_);
    }


    function token0() public view returns (address) {
        return TOKEN_0;
    }

    function token1() public view returns (address) {
        return TOKEN_1;
    }

    function kLast() public pure returns (uint256) {
        return 0;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockReentrancyToken is MockToken("Mock Reentrancy Token", "MRT", 18) {
    bool public bad;
    address public comptrollerProxy;

    function makeItReentracyToken(address _comptrollerProxy) external {
        bad = true;
        comptrollerProxy = _comptrollerProxy;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (bad) {
            ComptrollerLib(comptrollerProxy).redeemShares();
        } else {
            _transfer(_msgSender(), recipient, amount);
        }
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if (bad) {
            ComptrollerLib(comptrollerProxy).buyShares(
                new address[](0),
                new uint256[](0),
                new uint256[](0)
            );
        } else {
            _transfer(sender, recipient, amount);
        }
        return true;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockSynthetixToken is ISynthetixProxyERC20, ISynthetixSynth, MockToken {
    using SafeMath for uint256;

    bytes32 public override currencyKey;
    uint256 public constant WAITING_PERIOD_SECS = 3 * 60;

    mapping(address => uint256) public timelockByAccount;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        bytes32 _currencyKey
    ) public MockToken(_name, _symbol, _decimals) {
        currencyKey = _currencyKey;
    }

    function setCurrencyKey(bytes32 _currencyKey) external onlyOwner {
        currencyKey = _currencyKey;
    }

    function _isLocked(address account) internal view returns (bool) {
        return timelockByAccount[account] >= now;
    }

    function _beforeTokenTransfer(
        address from,
        address,
        uint256
    ) internal override {
        require(!_isLocked(from), "Cannot settle during waiting period");
    }

    function target() external view override returns (address) {
        return address(this);
    }

    function isLocked(address account) external view returns (bool) {
        return _isLocked(account);
    }

    function burnFrom(address account, uint256 amount) public override {
        _burn(account, amount);
    }

    function lock(address account) public {
        timelockByAccount[account] = now.add(WAITING_PERIOD_SECS);
    }

    function unlock(address account) public {
        timelockByAccount[account] = 0;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IUniswapV2Router2 {
    function addLiquidity(
        address,
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        );

    function removeLiquidity(
        address,
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external returns (uint256, uint256);

    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external returns (uint256[] memory);
}// GPL-3.0


pragma solidity 0.6.12;


contract UniswapV2Adapter is AdapterBase {
    using SafeMath for uint256;

    address private immutable FACTORY;
    address private immutable ROUTER;

    constructor(
        address _integrationManager,
        address _router,
        address _factory
    ) public AdapterBase(_integrationManager) {
        FACTORY = _factory;
        ROUTER = _router;
    }


    function identifier() external pure override returns (string memory identifier_) {
        return "UNISWAP_V2";
    }

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        if (_selector == LEND_SELECTOR) {
            (
                address[2] memory outgoingAssets,
                uint256[2] memory maxOutgoingAssetAmounts,
                ,
                uint256 minIncomingAssetAmount
            ) = __decodeLendCallArgs(_encodedCallArgs);

            spendAssets_ = new address[](2);
            spendAssets_[0] = outgoingAssets[0];
            spendAssets_[1] = outgoingAssets[1];

            spendAssetAmounts_ = new uint256[](2);
            spendAssetAmounts_[0] = maxOutgoingAssetAmounts[0];
            spendAssetAmounts_[1] = maxOutgoingAssetAmounts[1];

            incomingAssets_ = new address[](1);
            incomingAssets_[0] = IUniswapV2Factory(FACTORY).getPair(
                outgoingAssets[0],
                outgoingAssets[1]
            );

            minIncomingAssetAmounts_ = new uint256[](1);
            minIncomingAssetAmounts_[0] = minIncomingAssetAmount;
        } else if (_selector == REDEEM_SELECTOR) {
            (
                uint256 outgoingAssetAmount,
                address[2] memory incomingAssets,
                uint256[2] memory minIncomingAssetAmounts
            ) = __decodeRedeemCallArgs(_encodedCallArgs);

            spendAssets_ = new address[](1);
            spendAssets_[0] = IUniswapV2Factory(FACTORY).getPair(
                incomingAssets[0],
                incomingAssets[1]
            );

            spendAssetAmounts_ = new uint256[](1);
            spendAssetAmounts_[0] = outgoingAssetAmount;

            incomingAssets_ = new address[](2);
            incomingAssets_[0] = incomingAssets[0];
            incomingAssets_[1] = incomingAssets[1];

            minIncomingAssetAmounts_ = new uint256[](2);
            minIncomingAssetAmounts_[0] = minIncomingAssetAmounts[0];
            minIncomingAssetAmounts_[1] = minIncomingAssetAmounts[1];
        } else if (_selector == TAKE_ORDER_SELECTOR) {
            (
                address[] memory path,
                uint256 outgoingAssetAmount,
                uint256 minIncomingAssetAmount
            ) = __decodeTakeOrderCallArgs(_encodedCallArgs);

            require(path.length >= 2, "parseAssetsForMethod: _path must be >= 2");

            spendAssets_ = new address[](1);
            spendAssets_[0] = path[0];
            spendAssetAmounts_ = new uint256[](1);
            spendAssetAmounts_[0] = outgoingAssetAmount;

            incomingAssets_ = new address[](1);
            incomingAssets_[0] = path[path.length - 1];
            minIncomingAssetAmounts_ = new uint256[](1);
            minIncomingAssetAmounts_[0] = minIncomingAssetAmount;
        } else {
            revert("parseAssetsForMethod: _selector invalid");
        }

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function lend(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        fundAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            address[2] memory outgoingAssets,
            uint256[2] memory maxOutgoingAssetAmounts,
            uint256[2] memory minOutgoingAssetAmounts,

        ) = __decodeLendCallArgs(_encodedCallArgs);

        __lend(
            _vaultProxy,
            outgoingAssets[0],
            outgoingAssets[1],
            maxOutgoingAssetAmounts[0],
            maxOutgoingAssetAmounts[1],
            minOutgoingAssetAmounts[0],
            minOutgoingAssetAmounts[1]
        );
    }

    function redeem(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        fundAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            uint256 outgoingAssetAmount,
            address[2] memory incomingAssets,
            uint256[2] memory minIncomingAssetAmounts
        ) = __decodeRedeemCallArgs(_encodedCallArgs);

        (, address[] memory spendAssets, , ) = __decodeEncodedAssetTransferArgs(
            _encodedAssetTransferArgs
        );

        __redeem(
            _vaultProxy,
            spendAssets[0],
            outgoingAssetAmount,
            incomingAssets[0],
            incomingAssets[1],
            minIncomingAssetAmounts[0],
            minIncomingAssetAmounts[1]
        );
    }

    function takeOrder(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        fundAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            address[] memory path,
            uint256 outgoingAssetAmount,
            uint256 minIncomingAssetAmount
        ) = __decodeTakeOrderCallArgs(_encodedCallArgs);

        __takeOrder(_vaultProxy, outgoingAssetAmount, minIncomingAssetAmount, path);
    }


    function __decodeLendCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address[2] memory outgoingAssets_,
            uint256[2] memory maxOutgoingAssetAmounts_,
            uint256[2] memory minOutgoingAssetAmounts_,
            uint256 minIncomingAssetAmount_
        )
    {
        return abi.decode(_encodedCallArgs, (address[2], uint256[2], uint256[2], uint256));
    }

    function __decodeRedeemCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            uint256 outgoingAssetAmount_,
            address[2] memory incomingAssets_,
            uint256[2] memory minIncomingAssetAmounts_
        )
    {
        return abi.decode(_encodedCallArgs, (uint256, address[2], uint256[2]));
    }

    function __decodeTakeOrderCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address[] memory path_,
            uint256 outgoingAssetAmount_,
            uint256 minIncomingAssetAmount_
        )
    {
        return abi.decode(_encodedCallArgs, (address[], uint256, uint256));
    }

    function __lend(
        address _vaultProxy,
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        uint256 _amountAMin,
        uint256 _amountBMin
    ) private {
        __approveMaxAsNeeded(_tokenA, ROUTER, _amountADesired);
        __approveMaxAsNeeded(_tokenB, ROUTER, _amountBDesired);

        IUniswapV2Router2(ROUTER).addLiquidity(
            _tokenA,
            _tokenB,
            _amountADesired,
            _amountBDesired,
            _amountAMin,
            _amountBMin,
            _vaultProxy,
            block.timestamp.add(1)
        );
    }

    function __redeem(
        address _vaultProxy,
        address _poolToken,
        uint256 _poolTokenAmount,
        address _tokenA,
        address _tokenB,
        uint256 _amountAMin,
        uint256 _amountBMin
    ) private {
        __approveMaxAsNeeded(_poolToken, ROUTER, _poolTokenAmount);

        IUniswapV2Router2(ROUTER).removeLiquidity(
            _tokenA,
            _tokenB,
            _poolTokenAmount,
            _amountAMin,
            _amountBMin,
            _vaultProxy,
            block.timestamp.add(1)
        );
    }

    function __takeOrder(
        address _vaultProxy,
        uint256 _outgoingAssetAmount,
        uint256 _minIncomingAssetAmount,
        address[] memory _path
    ) private {
        __approveMaxAsNeeded(_path[0], ROUTER, _outgoingAssetAmount);

        IUniswapV2Router2(ROUTER).swapExactTokensForTokens(
            _outgoingAssetAmount,
            _minIncomingAssetAmount,
            _path,
            _vaultProxy,
            block.timestamp.add(1)
        );
    }


    function getFactory() external view returns (address factory_) {
        return FACTORY;
    }

    function getRouter() external view returns (address router_) {
        return ROUTER;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IMakerDaoPot {
    function chi() external view returns (uint256);

    function rho() external view returns (uint256);

    function drip() external returns (uint256);
}// GPL-3.0


pragma solidity 0.6.12;


contract ChaiPriceFeed is IDerivativePriceFeed {
    using SafeMath for uint256;

    uint256 private constant CHI_DIVISOR = 10**27;
    address private immutable CHAI;
    address private immutable DAI;
    address private immutable DSR_POT;

    constructor(
        address _chai,
        address _dai,
        address _dsrPot
    ) public {
        CHAI = _chai;
        DAI = _dai;
        DSR_POT = _dsrPot;
    }

    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        require(isSupportedAsset(_derivative), "calcUnderlyingValues: Only Chai is supported");

        underlyings_ = new address[](1);
        underlyings_[0] = DAI;
        underlyingAmounts_ = new uint256[](1);
        underlyingAmounts_[0] = _derivativeAmount.mul(IMakerDaoPot(DSR_POT).chi()).div(
            CHI_DIVISOR
        );
    }

    function isSupportedAsset(address _asset) public view override returns (bool isSupported_) {
        return _asset == CHAI;
    }


    function getChai() external view returns (address chai_) {
        return CHAI;
    }

    function getDai() external view returns (address dai_) {
        return DAI;
    }

    function getDsrPot() external view returns (address dsrPot_) {
        return DSR_POT;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract PreCallOnIntegrationValidatePolicyBase is PolicyBase {
    function implementedHooks()
        external
        view
        override
        returns (IPolicyManager.PolicyHook[] memory implementedHooks_)
    {
        implementedHooks_ = new IPolicyManager.PolicyHook[](1);
        implementedHooks_[0] = IPolicyManager.PolicyHook.PreCallOnIntegration;

        return implementedHooks_;
    }

    function __decodeRuleArgs(bytes memory _encodedRuleArgs)
        internal
        pure
        returns (address adapter_, bytes4 selector_)
    {
        return abi.decode(_encodedRuleArgs, (address, bytes4));
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract GuaranteedRedemption is PreCallOnIntegrationValidatePolicyBase, FundDeployerOwnerMixin {
    using SafeMath for uint256;

    event AdapterAdded(address adapter);

    event AdapterRemoved(address adapter);

    event FundSettingsSet(
        address indexed comptrollerProxy,
        uint256 startTimestamp,
        uint256 duration
    );

    event RedemptionWindowBufferSet(uint256 prevBuffer, uint256 nextBuffer);

    struct RedemptionWindow {
        uint256 startTimestamp;
        uint256 duration;
    }

    uint256 private constant ONE_DAY = 24 * 60 * 60;

    mapping(address => bool) private adapterToCanBlockRedemption;
    mapping(address => RedemptionWindow) private comptrollerProxyToRedemptionWindow;
    uint256 private redemptionWindowBuffer;

    constructor(
        address _policyManager,
        address _fundDeployer,
        uint256 _redemptionWindowBuffer,
        address[] memory _redemptionBlockingAdapters
    ) public PolicyBase(_policyManager) FundDeployerOwnerMixin(_fundDeployer) {
        redemptionWindowBuffer = _redemptionWindowBuffer;

        __addRedemptionBlockingAdapters(_redemptionBlockingAdapters);
    }


    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        (uint256 startTimestamp, uint256 duration) = abi.decode(
            _encodedSettings,
            (uint256, uint256)
        );

        if (startTimestamp == 0) {
            require(duration == 0, "addFundSettings: duration must be 0 if startTimestamp is 0");
            return;
        }

        require(
            duration > 0 && duration <= 23 hours,
            "addFundSettings: duration must be between 1 second and 23 hours"
        );

        comptrollerProxyToRedemptionWindow[_comptrollerProxy].startTimestamp = startTimestamp;
        comptrollerProxyToRedemptionWindow[_comptrollerProxy].duration = duration;

        emit FundSettingsSet(_comptrollerProxy, startTimestamp, duration);
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "GUARANTEED_REDEMPTION";
    }

    function passesRule(address _comptrollerProxy, address _adapter)
        public
        view
        returns (bool isValid_)
    {
        if (!adapterCanBlockRedemption(_adapter)) {
            return true;
        }


            RedemptionWindow memory redemptionWindow
         = comptrollerProxyToRedemptionWindow[_comptrollerProxy];

        if (redemptionWindow.startTimestamp == 0) {
            return false;
        }

        uint256 latestRedemptionWindowStart = calcLatestRedemptionWindowStart(
            redemptionWindow.startTimestamp
        );

        if (
            block.timestamp >= latestRedemptionWindowStart.add(redemptionWindow.duration) ||
            block.timestamp <= latestRedemptionWindowStart.sub(redemptionWindowBuffer)
        ) {
            return true;
        }

        return false;
    }

    function setRedemptionWindowBuffer(uint256 _nextRedemptionWindowBuffer)
        external
        onlyFundDeployerOwner
    {
        uint256 prevRedemptionWindowBuffer = redemptionWindowBuffer;
        require(
            _nextRedemptionWindowBuffer != prevRedemptionWindowBuffer,
            "setRedemptionWindowBuffer: Value already set"
        );

        redemptionWindowBuffer = _nextRedemptionWindowBuffer;

        emit RedemptionWindowBufferSet(prevRedemptionWindowBuffer, _nextRedemptionWindowBuffer);
    }

    function validateRule(
        address _comptrollerProxy,
        address,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override returns (bool isValid_) {
        (address adapter, ) = __decodeRuleArgs(_encodedArgs);

        return passesRule(_comptrollerProxy, adapter);
    }


    function calcLatestRedemptionWindowStart(uint256 _startTimestamp)
        public
        view
        returns (uint256 latestRedemptionWindowStart_)
    {
        if (block.timestamp <= _startTimestamp) {
            return _startTimestamp;
        }

        uint256 timeSinceStartTimestamp = block.timestamp.sub(_startTimestamp);
        uint256 timeSincePeriodStart = timeSinceStartTimestamp.mod(ONE_DAY);

        return block.timestamp.sub(timeSincePeriodStart);
    }


    function addRedemptionBlockingAdapters(address[] calldata _adapters)
        external
        onlyFundDeployerOwner
    {
        require(
            _adapters.length > 0,
            "__addRedemptionBlockingAdapters: _adapters cannot be empty"
        );

        __addRedemptionBlockingAdapters(_adapters);
    }

    function removeRedemptionBlockingAdapters(address[] calldata _adapters)
        external
        onlyFundDeployerOwner
    {
        require(
            _adapters.length > 0,
            "removeRedemptionBlockingAdapters: _adapters cannot be empty"
        );

        for (uint256 i; i < _adapters.length; i++) {
            require(
                adapterCanBlockRedemption(_adapters[i]),
                "removeRedemptionBlockingAdapters: adapter is not added"
            );

            adapterToCanBlockRedemption[_adapters[i]] = false;

            emit AdapterRemoved(_adapters[i]);
        }
    }

    function __addRedemptionBlockingAdapters(address[] memory _adapters) private {
        for (uint256 i; i < _adapters.length; i++) {
            require(
                _adapters[i] != address(0),
                "__addRedemptionBlockingAdapters: adapter cannot be empty"
            );
            require(
                !adapterCanBlockRedemption(_adapters[i]),
                "__addRedemptionBlockingAdapters: adapter already added"
            );

            adapterToCanBlockRedemption[_adapters[i]] = true;

            emit AdapterAdded(_adapters[i]);
        }
    }


    function getRedemptionWindowBuffer() external view returns (uint256 redemptionWindowBuffer_) {
        return redemptionWindowBuffer;
    }

    function getRedemptionWindowForFund(address _comptrollerProxy)
        external
        view
        returns (RedemptionWindow memory redemptionWindow_)
    {
        return comptrollerProxyToRedemptionWindow[_comptrollerProxy];
    }

    function adapterCanBlockRedemption(address _adapter)
        public
        view
        returns (bool canBlockRedemption_)
    {
        return adapterToCanBlockRedemption[_adapter];
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract AddressListPolicyMixin {
    using EnumerableSet for EnumerableSet.AddressSet;

    event AddressesAdded(address indexed comptrollerProxy, address[] items);

    event AddressesRemoved(address indexed comptrollerProxy, address[] items);

    mapping(address => EnumerableSet.AddressSet) private comptrollerProxyToList;


    function getList(address _comptrollerProxy) external view returns (address[] memory list_) {
        list_ = new address[](comptrollerProxyToList[_comptrollerProxy].length());
        for (uint256 i = 0; i < list_.length; i++) {
            list_[i] = comptrollerProxyToList[_comptrollerProxy].at(i);
        }
        return list_;
    }


    function isInList(address _comptrollerProxy, address _item)
        public
        view
        returns (bool isInList_)
    {
        return comptrollerProxyToList[_comptrollerProxy].contains(_item);
    }


    function __addToList(address _comptrollerProxy, address[] memory _items) internal {
        require(_items.length > 0, "__addToList: No addresses provided");

        for (uint256 i = 0; i < _items.length; i++) {
            require(
                comptrollerProxyToList[_comptrollerProxy].add(_items[i]),
                "__addToList: Address already exists in list"
            );
        }

        emit AddressesAdded(_comptrollerProxy, _items);
    }

    function __removeFromList(address _comptrollerProxy, address[] memory _items) internal {
        require(_items.length > 0, "__removeFromList: No addresses provided");

        for (uint256 i = 0; i < _items.length; i++) {
            require(
                comptrollerProxyToList[_comptrollerProxy].remove(_items[i]),
                "__removeFromList: Address does not exist in list"
            );
        }

        emit AddressesRemoved(_comptrollerProxy, _items);
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract AdapterWhitelist is PreCallOnIntegrationValidatePolicyBase, AddressListPolicyMixin {
    constructor(address _policyManager) public PolicyBase(_policyManager) {}

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        __addToList(_comptrollerProxy, abi.decode(_encodedSettings, (address[])));
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "ADAPTER_WHITELIST";
    }

    function passesRule(address _comptrollerProxy, address _adapter)
        public
        view
        returns (bool isValid_)
    {
        return isInList(_comptrollerProxy, _adapter);
    }

    function validateRule(
        address _comptrollerProxy,
        address,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override returns (bool isValid_) {
        (address adapter, ) = __decodeRuleArgs(_encodedArgs);

        return passesRule(_comptrollerProxy, adapter);
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract AssetWhitelist is PostCallOnIntegrationValidatePolicyBase, AddressListPolicyMixin {
    using AddressArrayLib for address[];

    constructor(address _policyManager) public PolicyBase(_policyManager) {}

    function activateForFund(address _comptrollerProxy, address _vaultProxy)
        external
        override
        onlyPolicyManager
    {
        require(
            passesRule(_comptrollerProxy, VaultLib(_vaultProxy).getTrackedAssets()),
            "activateForFund: Non-whitelisted asset detected"
        );
    }

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        address[] memory assets = abi.decode(_encodedSettings, (address[]));
        require(
            assets.contains(ComptrollerLib(_comptrollerProxy).getDenominationAsset()),
            "addFundSettings: Must whitelist denominationAsset"
        );

        __addToList(_comptrollerProxy, abi.decode(_encodedSettings, (address[])));
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "ASSET_WHITELIST";
    }

    function passesRule(address _comptrollerProxy, address[] memory _assets)
        public
        view
        returns (bool isValid_)
    {
        for (uint256 i; i < _assets.length; i++) {
            if (!isInList(_comptrollerProxy, _assets[i])) {
                return false;
            }
        }

        return true;
    }

    function validateRule(
        address _comptrollerProxy,
        address,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override returns (bool isValid_) {
        (, , address[] memory incomingAssets, , , ) = __decodeRuleArgs(_encodedArgs);

        return passesRule(_comptrollerProxy, incomingAssets);
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract AssetBlacklist is PostCallOnIntegrationValidatePolicyBase, AddressListPolicyMixin {
    using AddressArrayLib for address[];

    constructor(address _policyManager) public PolicyBase(_policyManager) {}

    function activateForFund(address _comptrollerProxy, address _vaultProxy)
        external
        override
        onlyPolicyManager
    {
        require(
            passesRule(_comptrollerProxy, VaultLib(_vaultProxy).getTrackedAssets()),
            "activateForFund: Blacklisted asset detected"
        );
    }

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        address[] memory assets = abi.decode(_encodedSettings, (address[]));
        require(
            !assets.contains(ComptrollerLib(_comptrollerProxy).getDenominationAsset()),
            "addFundSettings: Cannot blacklist denominationAsset"
        );

        __addToList(_comptrollerProxy, assets);
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "ASSET_BLACKLIST";
    }

    function passesRule(address _comptrollerProxy, address[] memory _assets)
        public
        view
        returns (bool isValid_)
    {
        for (uint256 i; i < _assets.length; i++) {
            if (isInList(_comptrollerProxy, _assets[i])) {
                return false;
            }
        }

        return true;
    }

    function validateRule(
        address _comptrollerProxy,
        address,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override returns (bool isValid_) {
        (, , address[] memory incomingAssets, , , ) = __decodeRuleArgs(_encodedArgs);

        return passesRule(_comptrollerProxy, incomingAssets);
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract TrackedAssetsAdapter is AdapterBase {
    constructor(address _integrationManager) public AdapterBase(_integrationManager) {}

    function addTrackedAssets(
        address,
        bytes calldata,
        bytes calldata
    ) external view {}

    function identifier() external pure override returns (string memory identifier_) {
        return "TRACKED_ASSETS";
    }

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        require(
            _selector == ADD_TRACKED_ASSETS_SELECTOR,
            "parseAssetsForMethod: _selector invalid"
        );

        incomingAssets_ = __decodeCallArgs(_encodedCallArgs);

        minIncomingAssetAmounts_ = new uint256[](incomingAssets_.length);
        for (uint256 i; i < minIncomingAssetAmounts_.length; i++) {
            minIncomingAssetAmounts_[i] = 1;
        }

        return (
            spendAssetsHandleType_,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }


    function __decodeCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (address[] memory incomingAssets_)
    {
        return abi.decode(_encodedCallArgs, (address[]));
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract VaultProxy {
    constructor(bytes memory _constructData, address _vaultLib) public {
        require(
            bytes32(0x027b9570e9fedc1a80b937ae9a06861e5faef3992491af30b684a64b3fbec7a5) ==
                ProxiableVaultLib(_vaultLib).proxiableUUID(),
            "constructor: _vaultLib not compatible"
        );

        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _vaultLib)
        }

        (bool success, bytes memory returnData) = _vaultLib.delegatecall(_constructData); // solium-disable-line
        require(success, string(returnData));
    }

    fallback() external payable {
        assembly {
            let contractLogic := sload(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
            )
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                sub(gas(), 10000),
                contractLogic,
                0x0,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
                case 0 {
                    revert(0, retSz)
                }
                default {
                    return(0, retSz)
                }
        }
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract Dispatcher is IDispatcher {
    event CurrentFundDeployerSet(address prevFundDeployer, address nextFundDeployer);

    event MigrationCancelled(
        address indexed vaultProxy,
        address indexed prevFundDeployer,
        address indexed nextFundDeployer,
        address nextVaultAccessor,
        address nextVaultLib,
        uint256 executableTimestamp
    );

    event MigrationExecuted(
        address indexed vaultProxy,
        address indexed prevFundDeployer,
        address indexed nextFundDeployer,
        address nextVaultAccessor,
        address nextVaultLib,
        uint256 executableTimestamp
    );

    event MigrationSignaled(
        address indexed vaultProxy,
        address indexed prevFundDeployer,
        address indexed nextFundDeployer,
        address nextVaultAccessor,
        address nextVaultLib,
        uint256 executableTimestamp
    );

    event MigrationTimelockSet(uint256 prevTimelock, uint256 nextTimelock);

    event NominatedOwnerSet(address indexed nominatedOwner);

    event NominatedOwnerRemoved(address indexed nominatedOwner);

    event OwnershipTransferred(address indexed prevOwner, address indexed nextOwner);

    event MigrationInCancelHookFailed(
        bytes failureReturnData,
        address indexed vaultProxy,
        address indexed prevFundDeployer,
        address indexed nextFundDeployer,
        address nextVaultAccessor,
        address nextVaultLib
    );

    event MigrationOutHookFailed(
        bytes failureReturnData,
        IMigrationHookHandler.MigrationOutHook hook,
        address indexed vaultProxy,
        address indexed prevFundDeployer,
        address indexed nextFundDeployer,
        address nextVaultAccessor,
        address nextVaultLib
    );

    event SharesTokenSymbolSet(string _nextSymbol);

    event VaultProxyDeployed(
        address indexed fundDeployer,
        address indexed owner,
        address vaultProxy,
        address indexed vaultLib,
        address vaultAccessor,
        string fundName
    );

    struct MigrationRequest {
        address nextFundDeployer;
        address nextVaultAccessor;
        address nextVaultLib;
        uint256 executableTimestamp;
    }

    address private currentFundDeployer;
    address private nominatedOwner;
    address private owner;
    uint256 private migrationTimelock;
    string private sharesTokenSymbol;
    mapping(address => address) private vaultProxyToFundDeployer;
    mapping(address => MigrationRequest) private vaultProxyToMigrationRequest;

    modifier onlyCurrentFundDeployer() {
        require(
            msg.sender == currentFundDeployer,
            "Only the current FundDeployer can call this function"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor() public {
        migrationTimelock = 2 days;
        owner = msg.sender;
        sharesTokenSymbol = "ENZF";
    }


    function setSharesTokenSymbol(string calldata _nextSymbol) external override onlyOwner {
        sharesTokenSymbol = _nextSymbol;

        emit SharesTokenSymbolSet(_nextSymbol);
    }


    function claimOwnership() external override {
        address nextOwner = nominatedOwner;
        require(
            msg.sender == nextOwner,
            "claimOwnership: Only the nominatedOwner can call this function"
        );

        delete nominatedOwner;

        address prevOwner = owner;
        owner = nextOwner;

        emit OwnershipTransferred(prevOwner, nextOwner);
    }

    function removeNominatedOwner() external override onlyOwner {
        address removedNominatedOwner = nominatedOwner;
        require(
            removedNominatedOwner != address(0),
            "removeNominatedOwner: There is no nominated owner"
        );

        delete nominatedOwner;

        emit NominatedOwnerRemoved(removedNominatedOwner);
    }

    function setCurrentFundDeployer(address _nextFundDeployer) external override onlyOwner {
        require(
            _nextFundDeployer != address(0),
            "setCurrentFundDeployer: _nextFundDeployer cannot be empty"
        );
        require(
            __isContract(_nextFundDeployer),
            "setCurrentFundDeployer: Non-contract _nextFundDeployer"
        );

        address prevFundDeployer = currentFundDeployer;
        require(
            _nextFundDeployer != prevFundDeployer,
            "setCurrentFundDeployer: _nextFundDeployer is already currentFundDeployer"
        );

        currentFundDeployer = _nextFundDeployer;

        emit CurrentFundDeployerSet(prevFundDeployer, _nextFundDeployer);
    }

    function setNominatedOwner(address _nextNominatedOwner) external override onlyOwner {
        require(
            _nextNominatedOwner != address(0),
            "setNominatedOwner: _nextNominatedOwner cannot be empty"
        );
        require(
            _nextNominatedOwner != owner,
            "setNominatedOwner: _nextNominatedOwner is already the owner"
        );
        require(
            _nextNominatedOwner != nominatedOwner,
            "setNominatedOwner: _nextNominatedOwner is already nominated"
        );

        nominatedOwner = _nextNominatedOwner;

        emit NominatedOwnerSet(_nextNominatedOwner);
    }

    function __isContract(address _who) private view returns (bool isContract_) {
        uint256 size;
        assembly {
            size := extcodesize(_who)
        }

        return size > 0;
    }


    function deployVaultProxy(
        address _vaultLib,
        address _owner,
        address _vaultAccessor,
        string calldata _fundName
    ) external override onlyCurrentFundDeployer returns (address vaultProxy_) {
        require(__isContract(_vaultAccessor), "deployVaultProxy: Non-contract _vaultAccessor");

        bytes memory constructData = abi.encodeWithSelector(
            IMigratableVault.init.selector,
            _owner,
            _vaultAccessor,
            _fundName
        );
        vaultProxy_ = address(new VaultProxy(constructData, _vaultLib));

        address fundDeployer = msg.sender;
        vaultProxyToFundDeployer[vaultProxy_] = fundDeployer;

        emit VaultProxyDeployed(
            fundDeployer,
            _owner,
            vaultProxy_,
            _vaultLib,
            _vaultAccessor,
            _fundName
        );

        return vaultProxy_;
    }


    function cancelMigration(address _vaultProxy, bool _bypassFailure) external override {
        MigrationRequest memory request = vaultProxyToMigrationRequest[_vaultProxy];
        address nextFundDeployer = request.nextFundDeployer;
        require(nextFundDeployer != address(0), "cancelMigration: No migration request exists");

        require(
            msg.sender == nextFundDeployer || IMigratableVault(_vaultProxy).canMigrate(msg.sender),
            "cancelMigration: Not an allowed caller"
        );

        address prevFundDeployer = vaultProxyToFundDeployer[_vaultProxy];
        address nextVaultAccessor = request.nextVaultAccessor;
        address nextVaultLib = request.nextVaultLib;
        uint256 executableTimestamp = request.executableTimestamp;

        delete vaultProxyToMigrationRequest[_vaultProxy];

        __invokeMigrationOutHook(
            IMigrationHookHandler.MigrationOutHook.PostCancel,
            _vaultProxy,
            prevFundDeployer,
            nextFundDeployer,
            nextVaultAccessor,
            nextVaultLib,
            _bypassFailure
        );
        __invokeMigrationInCancelHook(
            _vaultProxy,
            prevFundDeployer,
            nextFundDeployer,
            nextVaultAccessor,
            nextVaultLib,
            _bypassFailure
        );

        emit MigrationCancelled(
            _vaultProxy,
            prevFundDeployer,
            nextFundDeployer,
            nextVaultAccessor,
            nextVaultLib,
            executableTimestamp
        );
    }

    function executeMigration(address _vaultProxy, bool _bypassFailure) external override {
        MigrationRequest memory request = vaultProxyToMigrationRequest[_vaultProxy];
        address nextFundDeployer = request.nextFundDeployer;
        require(
            nextFundDeployer != address(0),
            "executeMigration: No migration request exists for _vaultProxy"
        );
        require(
            msg.sender == nextFundDeployer,
            "executeMigration: Only the target FundDeployer can call this function"
        );
        require(
            nextFundDeployer == currentFundDeployer,
            "executeMigration: The target FundDeployer is no longer the current FundDeployer"
        );
        uint256 executableTimestamp = request.executableTimestamp;
        require(
            block.timestamp >= executableTimestamp,
            "executeMigration: The migration timelock has not elapsed"
        );

        address prevFundDeployer = vaultProxyToFundDeployer[_vaultProxy];
        address nextVaultAccessor = request.nextVaultAccessor;
        address nextVaultLib = request.nextVaultLib;

        __invokeMigrationOutHook(
            IMigrationHookHandler.MigrationOutHook.PreMigrate,
            _vaultProxy,
            prevFundDeployer,
            nextFundDeployer,
            nextVaultAccessor,
            nextVaultLib,
            _bypassFailure
        );

        IMigratableVault(_vaultProxy).setVaultLib(nextVaultLib);
        IMigratableVault(_vaultProxy).setAccessor(nextVaultAccessor);

        vaultProxyToFundDeployer[_vaultProxy] = nextFundDeployer;

        delete vaultProxyToMigrationRequest[_vaultProxy];

        __invokeMigrationOutHook(
            IMigrationHookHandler.MigrationOutHook.PostMigrate,
            _vaultProxy,
            prevFundDeployer,
            nextFundDeployer,
            nextVaultAccessor,
            nextVaultLib,
            _bypassFailure
        );

        emit MigrationExecuted(
            _vaultProxy,
            prevFundDeployer,
            nextFundDeployer,
            nextVaultAccessor,
            nextVaultLib,
            executableTimestamp
        );
    }

    function setMigrationTimelock(uint256 _nextTimelock) external override onlyOwner {
        uint256 prevTimelock = migrationTimelock;
        require(
            _nextTimelock != prevTimelock,
            "setMigrationTimelock: _nextTimelock is the current timelock"
        );

        migrationTimelock = _nextTimelock;

        emit MigrationTimelockSet(prevTimelock, _nextTimelock);
    }

    function signalMigration(
        address _vaultProxy,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) external override onlyCurrentFundDeployer {
        require(
            __isContract(_nextVaultAccessor),
            "signalMigration: Non-contract _nextVaultAccessor"
        );

        address prevFundDeployer = vaultProxyToFundDeployer[_vaultProxy];
        require(prevFundDeployer != address(0), "signalMigration: _vaultProxy does not exist");

        address nextFundDeployer = msg.sender;
        require(
            nextFundDeployer != prevFundDeployer,
            "signalMigration: Can only migrate to a new FundDeployer"
        );

        __invokeMigrationOutHook(
            IMigrationHookHandler.MigrationOutHook.PreSignal,
            _vaultProxy,
            prevFundDeployer,
            nextFundDeployer,
            _nextVaultAccessor,
            _nextVaultLib,
            _bypassFailure
        );

        uint256 executableTimestamp = block.timestamp + migrationTimelock;
        vaultProxyToMigrationRequest[_vaultProxy] = MigrationRequest({
            nextFundDeployer: nextFundDeployer,
            nextVaultAccessor: _nextVaultAccessor,
            nextVaultLib: _nextVaultLib,
            executableTimestamp: executableTimestamp
        });

        __invokeMigrationOutHook(
            IMigrationHookHandler.MigrationOutHook.PostSignal,
            _vaultProxy,
            prevFundDeployer,
            nextFundDeployer,
            _nextVaultAccessor,
            _nextVaultLib,
            _bypassFailure
        );

        emit MigrationSignaled(
            _vaultProxy,
            prevFundDeployer,
            nextFundDeployer,
            _nextVaultAccessor,
            _nextVaultLib,
            executableTimestamp
        );
    }

    function __invokeMigrationInCancelHook(
        address _vaultProxy,
        address _prevFundDeployer,
        address _nextFundDeployer,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) private {
        (bool success, bytes memory returnData) = _nextFundDeployer.call(
            abi.encodeWithSelector(
                IMigrationHookHandler.invokeMigrationInCancelHook.selector,
                _vaultProxy,
                _prevFundDeployer,
                _nextVaultAccessor,
                _nextVaultLib
            )
        );
        if (!success) {
            require(
                _bypassFailure,
                string(abi.encodePacked("MigrationOutCancelHook: ", returnData))
            );

            emit MigrationInCancelHookFailed(
                returnData,
                _vaultProxy,
                _prevFundDeployer,
                _nextFundDeployer,
                _nextVaultAccessor,
                _nextVaultLib
            );
        }
    }

    function __invokeMigrationOutHook(
        IMigrationHookHandler.MigrationOutHook _hook,
        address _vaultProxy,
        address _prevFundDeployer,
        address _nextFundDeployer,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) private {
        (bool success, bytes memory returnData) = _prevFundDeployer.call(
            abi.encodeWithSelector(
                IMigrationHookHandler.invokeMigrationOutHook.selector,
                _hook,
                _vaultProxy,
                _nextFundDeployer,
                _nextVaultAccessor,
                _nextVaultLib
            )
        );
        if (!success) {
            require(
                _bypassFailure,
                string(abi.encodePacked(__migrationOutHookFailureReasonPrefix(_hook), returnData))
            );

            emit MigrationOutHookFailed(
                returnData,
                _hook,
                _vaultProxy,
                _prevFundDeployer,
                _nextFundDeployer,
                _nextVaultAccessor,
                _nextVaultLib
            );
        }
    }

    function __migrationOutHookFailureReasonPrefix(IMigrationHookHandler.MigrationOutHook _hook)
        private
        pure
        returns (string memory failureReasonPrefix_)
    {
        if (_hook == IMigrationHookHandler.MigrationOutHook.PreSignal) {
            return "MigrationOutHook.PreSignal: ";
        }
        if (_hook == IMigrationHookHandler.MigrationOutHook.PostSignal) {
            return "MigrationOutHook.PostSignal: ";
        }
        if (_hook == IMigrationHookHandler.MigrationOutHook.PreMigrate) {
            return "MigrationOutHook.PreMigrate: ";
        }
        if (_hook == IMigrationHookHandler.MigrationOutHook.PostMigrate) {
            return "MigrationOutHook.PostMigrate: ";
        }
        if (_hook == IMigrationHookHandler.MigrationOutHook.PostCancel) {
            return "MigrationOutHook.PostCancel: ";
        }

        return "";
    }



    function getCurrentFundDeployer()
        external
        view
        override
        returns (address currentFundDeployer_)
    {
        return currentFundDeployer;
    }

    function getFundDeployerForVaultProxy(address _vaultProxy)
        external
        view
        override
        returns (address fundDeployer_)
    {
        return vaultProxyToFundDeployer[_vaultProxy];
    }

    function getMigrationRequestDetailsForVaultProxy(address _vaultProxy)
        external
        view
        override
        returns (
            address nextFundDeployer_,
            address nextVaultAccessor_,
            address nextVaultLib_,
            uint256 executableTimestamp_
        )
    {
        MigrationRequest memory r = vaultProxyToMigrationRequest[_vaultProxy];
        if (r.executableTimestamp > 0) {
            return (
                r.nextFundDeployer,
                r.nextVaultAccessor,
                r.nextVaultLib,
                r.executableTimestamp
            );
        }
    }

    function getMigrationTimelock() external view override returns (uint256 migrationTimelock_) {
        return migrationTimelock;
    }

    function getNominatedOwner() external view override returns (address nominatedOwner_) {
        return nominatedOwner;
    }

    function getOwner() external view override returns (address owner_) {
        return owner;
    }

    function getSharesTokenSymbol()
        external
        view
        override
        returns (string memory sharesTokenSymbol_)
    {
        return sharesTokenSymbol;
    }

    function getTimelockRemainingForMigrationRequest(address _vaultProxy)
        external
        view
        override
        returns (uint256 secondsRemaining_)
    {
        uint256 executableTimestamp = vaultProxyToMigrationRequest[_vaultProxy]
            .executableTimestamp;
        if (executableTimestamp == 0) {
            return 0;
        }

        if (block.timestamp >= executableTimestamp) {
            return 0;
        }

        return executableTimestamp - block.timestamp;
    }

    function hasExecutableMigrationRequest(address _vaultProxy)
        external
        view
        override
        returns (bool hasExecutableRequest_)
    {
        uint256 executableTimestamp = vaultProxyToMigrationRequest[_vaultProxy]
            .executableTimestamp;

        return executableTimestamp > 0 && block.timestamp >= executableTimestamp;
    }

    function hasMigrationRequest(address _vaultProxy)
        external
        view
        override
        returns (bool hasMigrationRequest_)
    {
        return vaultProxyToMigrationRequest[_vaultProxy].executableTimestamp > 0;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockVaultLib is VaultLibBaseCore {
    function getAccessor() external view returns (address) {
        return accessor;
    }

    function getCreator() external view returns (address) {
        return creator;
    }

    function getMigrator() external view returns (address) {
        return migrator;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IKyberNetworkProxy {
    function swapEtherToToken(address, uint256) external payable returns (uint256);

    function swapTokenToEther(
        address,
        uint256,
        uint256
    ) external returns (uint256);

    function swapTokenToToken(
        address,
        uint256,
        address,
        uint256
    ) external returns (uint256);
}// GPL-3.0


pragma solidity 0.6.12;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}// GPL-3.0


pragma solidity 0.6.12;


contract KyberAdapter is AdapterBase, MathHelpers {
    address private immutable EXCHANGE;
    address private immutable WETH_TOKEN;

    constructor(
        address _integrationManager,
        address _exchange,
        address _wethToken
    ) public AdapterBase(_integrationManager) {
        EXCHANGE = _exchange;
        WETH_TOKEN = _wethToken;
    }

    receive() external payable {}


    function identifier() external pure override returns (string memory identifier_) {
        return "KYBER_NETWORK";
    }

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        require(_selector == TAKE_ORDER_SELECTOR, "parseAssetsForMethod: _selector invalid");

        (
            address incomingAsset,
            uint256 minIncomingAssetAmount,
            address outgoingAsset,
            uint256 outgoingAssetAmount
        ) = __decodeCallArgs(_encodedCallArgs);

        require(
            incomingAsset != outgoingAsset,
            "parseAssetsForMethod: incomingAsset and outgoingAsset asset cannot be the same"
        );
        require(outgoingAssetAmount > 0, "parseAssetsForMethod: outgoingAssetAmount must be >0");

        spendAssets_ = new address[](1);
        spendAssets_[0] = outgoingAsset;
        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingAssetAmount;

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = incomingAsset;
        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingAssetAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function takeOrder(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        fundAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            address incomingAsset,
            uint256 minIncomingAssetAmount,
            address outgoingAsset,
            uint256 outgoingAssetAmount
        ) = __decodeCallArgs(_encodedCallArgs);

        uint256 minExpectedRate = __calcNormalizedRate(
            ERC20(outgoingAsset).decimals(),
            outgoingAssetAmount,
            ERC20(incomingAsset).decimals(),
            minIncomingAssetAmount
        );

        if (outgoingAsset == WETH_TOKEN) {
            __swapNativeAssetToToken(incomingAsset, outgoingAssetAmount, minExpectedRate);
        } else if (incomingAsset == WETH_TOKEN) {
            __swapTokenToNativeAsset(outgoingAsset, outgoingAssetAmount, minExpectedRate);
        } else {
            __swapTokenToToken(incomingAsset, outgoingAsset, outgoingAssetAmount, minExpectedRate);
        }
    }


    function __decodeCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address incomingAsset_,
            uint256 minIncomingAssetAmount_,
            address outgoingAsset_,
            uint256 outgoingAssetAmount_
        )
    {
        return abi.decode(_encodedCallArgs, (address, uint256, address, uint256));
    }

    function __swapNativeAssetToToken(
        address _incomingAsset,
        uint256 _outgoingAssetAmount,
        uint256 _minExpectedRate
    ) private {
        IWETH(payable(WETH_TOKEN)).withdraw(_outgoingAssetAmount);

        IKyberNetworkProxy(EXCHANGE).swapEtherToToken{value: _outgoingAssetAmount}(
            _incomingAsset,
            _minExpectedRate
        );
    }

    function __swapTokenToNativeAsset(
        address _outgoingAsset,
        uint256 _outgoingAssetAmount,
        uint256 _minExpectedRate
    ) private {
        __approveMaxAsNeeded(_outgoingAsset, EXCHANGE, _outgoingAssetAmount);

        IKyberNetworkProxy(EXCHANGE).swapTokenToEther(
            _outgoingAsset,
            _outgoingAssetAmount,
            _minExpectedRate
        );

        IWETH(payable(WETH_TOKEN)).deposit{value: payable(address(this)).balance}();
    }

    function __swapTokenToToken(
        address _incomingAsset,
        address _outgoingAsset,
        uint256 _outgoingAssetAmount,
        uint256 _minExpectedRate
    ) private {
        __approveMaxAsNeeded(_outgoingAsset, EXCHANGE, _outgoingAssetAmount);

        IKyberNetworkProxy(EXCHANGE).swapTokenToToken(
            _outgoingAsset,
            _outgoingAssetAmount,
            _incomingAsset,
            _minExpectedRate
        );
    }


    function getExchange() external view returns (address exchange_) {
        return EXCHANGE;
    }

    function getWethToken() external view returns (address wethToken_) {
        return WETH_TOKEN;
    }
}// GPL-3.0


pragma solidity 0.6.12;

abstract contract EthConstantMixin {
    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract SwapperBase is EthConstantMixin {
    receive() external payable {}

    function __swapAssets(
        address payable _trader,
        address _srcToken,
        uint256 _srcAmount,
        address _destToken,
        uint256 _actualRate
    ) internal returns (uint256 destAmount_) {
        address[] memory assetsToIntegratee = new address[](1);
        assetsToIntegratee[0] = _srcToken;
        uint256[] memory assetsToIntegrateeAmounts = new uint256[](1);
        assetsToIntegrateeAmounts[0] = _srcAmount;

        address[] memory assetsFromIntegratee = new address[](1);
        assetsFromIntegratee[0] = _destToken;
        uint256[] memory assetsFromIntegrateeAmounts = new uint256[](1);
        assetsFromIntegrateeAmounts[0] = _actualRate;
        __swap(
            _trader,
            assetsToIntegratee,
            assetsToIntegrateeAmounts,
            assetsFromIntegratee,
            assetsFromIntegrateeAmounts
        );

        return assetsFromIntegrateeAmounts[0];
    }

    function __swap(
        address payable _trader,
        address[] memory _assetsToIntegratee,
        uint256[] memory _assetsToIntegrateeAmounts,
        address[] memory _assetsFromIntegratee,
        uint256[] memory _assetsFromIntegrateeAmounts
    ) internal {
        for (uint256 i = 0; i < _assetsToIntegratee.length; i++) {
            address asset = _assetsToIntegratee[i];
            uint256 amount = _assetsToIntegrateeAmounts[i];
            require(asset != address(0), "__swap: empty value in _assetsToIntegratee");
            require(amount > 0, "__swap: empty value in _assetsToIntegrateeAmounts");
            if (asset == ETH_ADDRESS) {
                continue;
            }
            ERC20(asset).transferFrom(_trader, address(this), amount);
        }

        for (uint256 i = 0; i < _assetsFromIntegratee.length; i++) {
            address asset = _assetsFromIntegratee[i];
            uint256 amount = _assetsFromIntegrateeAmounts[i];
            require(asset != address(0), "__swap: empty value in _assetsFromIntegratee");
            require(amount > 0, "__swap: empty value in _assetsFromIntegrateeAmounts");
            if (asset == ETH_ADDRESS) {
                _trader.transfer(amount);
            } else {
                ERC20(asset).transfer(_trader, amount);
            }
        }
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockKyberIntegratee is SwapperBase, Ownable, MathHelpers {
    using SafeMath for uint256;

    address private immutable CENTRALIZED_RATE_PROVIDER;
    address private immutable WETH;

    uint256 private constant PRECISION = 18;

    uint256 private blockNumberDeviation;

    constructor(
        address _centralizedRateProvider,
        address _weth,
        uint256 _blockNumberDeviation
    ) public {
        CENTRALIZED_RATE_PROVIDER = _centralizedRateProvider;
        WETH = _weth;
        blockNumberDeviation = _blockNumberDeviation;
    }

    function swapEtherToToken(address _destToken, uint256) external payable returns (uint256) {
        uint256 destAmount = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValueRandomized(WETH, msg.value, _destToken, blockNumberDeviation);

        __swapAssets(msg.sender, ETH_ADDRESS, msg.value, _destToken, destAmount);
        return msg.value;
    }

    function swapTokenToEther(
        address _srcToken,
        uint256 _srcAmount,
        uint256
    ) external returns (uint256) {
        uint256 destAmount = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValueRandomized(_srcToken, _srcAmount, WETH, blockNumberDeviation);

        __swapAssets(msg.sender, _srcToken, _srcAmount, ETH_ADDRESS, destAmount);
        return _srcAmount;
    }

    function swapTokenToToken(
        address _srcToken,
        uint256 _srcAmount,
        address _destToken,
        uint256
    ) external returns (uint256) {
        uint256 destAmount = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValueRandomized(_srcToken, _srcAmount, _destToken, blockNumberDeviation);

        __swapAssets(msg.sender, _srcToken, _srcAmount, _destToken, destAmount);
        return _srcAmount;
    }

    function setBlockNumberDeviation(uint256 _deviationPct) external onlyOwner {
        blockNumberDeviation = _deviationPct;
    }

    function getExpectedRate(
        address _srcToken,
        address _destToken,
        uint256 _amount
    ) external returns (uint256 rate_, uint256 worstRate_) {
        if (_srcToken == ETH_ADDRESS) {
            _srcToken = WETH;
        }
        if (_destToken == ETH_ADDRESS) {
            _destToken = WETH;
        }

        uint256 destAmount = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValueRandomizedBySender(_srcToken, _amount, _destToken);
        rate_ = __calcNormalizedRate(
            ERC20(_srcToken).decimals(),
            _amount,
            ERC20(_destToken).decimals(),
            destAmount
        );
        worstRate_ = rate_.mul(uint256(100).sub(blockNumberDeviation)).div(100);
    }


    function getCentralizedRateProvider() public view returns (address) {
        return CENTRALIZED_RATE_PROVIDER;
    }

    function getWeth() public view returns (address) {
        return WETH;
    }

    function getBlockNumberDeviation() public view returns (uint256) {
        return blockNumberDeviation;
    }

    function getPrecision() public pure returns (uint256) {
        return PRECISION;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract RateProviderBase is EthConstantMixin {
    mapping(address => mapping(address => uint256)) public assetToAssetRate;

    mapping(address => uint8) public specialAssetToDecimals;

    constructor(address[] memory _specialAssets, uint8[] memory _specialAssetDecimals) public {
        require(
            _specialAssets.length == _specialAssetDecimals.length,
            "constructor: _specialAssets and _specialAssetDecimals are uneven lengths"
        );
        for (uint256 i = 0; i < _specialAssets.length; i++) {
            specialAssetToDecimals[_specialAssets[i]] = _specialAssetDecimals[i];
        }

        specialAssetToDecimals[ETH_ADDRESS] = 18;
    }

    function __getDecimalsForAsset(address _asset) internal view returns (uint256) {
        uint256 decimals = specialAssetToDecimals[_asset];
        if (decimals == 0) {
            decimals = uint256(ERC20(_asset).decimals());
        }

        return decimals;
    }

    function __getRate(address _baseAsset, address _quoteAsset)
        internal
        view
        virtual
        returns (uint256)
    {
        return assetToAssetRate[_baseAsset][_quoteAsset];
    }

    function setRates(
        address[] calldata _baseAssets,
        address[] calldata _quoteAssets,
        uint256[] calldata _rates
    ) external {
        require(
            _baseAssets.length == _quoteAssets.length,
            "setRates: _baseAssets and _quoteAssets are uneven lengths"
        );
        require(
            _baseAssets.length == _rates.length,
            "setRates: _baseAssets and _rates are uneven lengths"
        );
        for (uint256 i = 0; i < _baseAssets.length; i++) {
            assetToAssetRate[_baseAssets[i]][_quoteAssets[i]] = _rates[i];
        }
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract NormalizedRateProviderBase is RateProviderBase {
    using SafeMath for uint256;

    uint256 public immutable RATE_PRECISION;

    constructor(
        address[] memory _defaultRateAssets,
        address[] memory _specialAssets,
        uint8[] memory _specialAssetDecimals,
        uint256 _ratePrecision
    ) public RateProviderBase(_specialAssets, _specialAssetDecimals) {
        RATE_PRECISION = _ratePrecision;

        for (uint256 i = 0; i < _defaultRateAssets.length; i++) {
            for (uint256 j = i + 1; j < _defaultRateAssets.length; j++) {
                assetToAssetRate[_defaultRateAssets[i]][_defaultRateAssets[j]] =
                    10**_ratePrecision;
                assetToAssetRate[_defaultRateAssets[j]][_defaultRateAssets[i]] =
                    10**_ratePrecision;
            }
        }
    }

    function __calcDenormalizedQuoteAssetAmount(
        uint256 _baseAssetDecimals,
        uint256 _baseAssetAmount,
        uint256 _quoteAssetDecimals,
        uint256 _rate
    ) internal view returns (uint256) {
        return
            _rate.mul(_baseAssetAmount).mul(10**_quoteAssetDecimals).div(
                10**(RATE_PRECISION.add(_baseAssetDecimals))
            );
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract MockIntegrateeBase is NormalizedRateProviderBase, SwapperBase {
    constructor(
        address[] memory _defaultRateAssets,
        address[] memory _specialAssets,
        uint8[] memory _specialAssetDecimals,
        uint256 _ratePrecision
    )
        public
        NormalizedRateProviderBase(
            _defaultRateAssets,
            _specialAssets,
            _specialAssetDecimals,
            _ratePrecision
        )
    {}

    function __getRate(address _baseAsset, address _quoteAsset)
        internal
        view
        override
        returns (uint256)
    {
        if (_baseAsset == _quoteAsset) {
            return 10**RATE_PRECISION;
        }

        uint256 directRate = assetToAssetRate[_baseAsset][_quoteAsset];
        if (directRate > 0) {
            return directRate;
        }

        uint256 iDirectRate = assetToAssetRate[_quoteAsset][_baseAsset];
        if (iDirectRate > 0) {
            return 10**(RATE_PRECISION.mul(2)).div(iDirectRate);
        }

        return 10**RATE_PRECISION;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract SimpleMockIntegrateeBase is MockIntegrateeBase {
    constructor(
        address[] memory _defaultRateAssets,
        address[] memory _specialAssets,
        uint8[] memory _specialAssetDecimals,
        uint256 _ratePrecision
    )
        public
        MockIntegrateeBase(
            _defaultRateAssets,
            _specialAssets,
            _specialAssetDecimals,
            _ratePrecision
        )
    {}

    function __getRateAndSwapAssets(
        address payable _trader,
        address _srcToken,
        uint256 _srcAmount,
        address _destToken
    ) internal returns (uint256 destAmount_) {
        uint256 actualRate = __getRate(_srcToken, _destToken);
        __swapAssets(_trader, _srcToken, _srcAmount, _destToken, actualRate);
        return actualRate;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockUniswapV2Integratee is SwapperBase, Ownable {
    using SafeMath for uint256;
    mapping(address => mapping(address => address)) private assetToAssetToPair;

    address private immutable CENTRALIZED_RATE_PROVIDER;
    uint256 private constant PRECISION = 18;

    uint256 private blockNumberDeviation;

    constructor(
        address[] memory _listOfToken0,
        address[] memory _listOfToken1,
        address[] memory _listOfPair,
        address _centralizedRateProvider,
        uint256 _blockNumberDeviation
    ) public {
        addPair(_listOfToken0, _listOfToken1, _listOfPair);
        CENTRALIZED_RATE_PROVIDER = _centralizedRateProvider;
        blockNumberDeviation = _blockNumberDeviation;
    }

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        uint256,
        uint256,
        address,
        uint256
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        __addLiquidity(_tokenA, _tokenB, _amountADesired, _amountBDesired);
    }

    function removeLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _liquidity,
        uint256,
        uint256,
        address,
        uint256
    ) public returns (uint256, uint256) {
        __removeLiquidity(_tokenA, _tokenB, _liquidity);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256,
        address[] calldata path,
        address,
        uint256
    ) external returns (uint256[] memory) {
        uint256 amountOut = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValueRandomized(path[0], amountIn, path[1], blockNumberDeviation);

        __swapAssets(msg.sender, path[0], amountIn, path[path.length - 1], amountOut);
    }

    function getAmountsOut(uint256 _amountIn, address[] calldata _path)
        external
        returns (uint256[] memory amounts_)
    {
        require(_path.length >= 2, "getAmountsOut: path must be >= 2");

        address assetIn = _path[0];
        address assetOut = _path[_path.length - 1];

        uint256 amountOut = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValueRandomizedBySender(assetIn, _amountIn, assetOut);

        amounts_ = new uint256[](_path.length);
        amounts_[0] = _amountIn;
        amounts_[_path.length - 1] = amountOut;

        return amounts_;
    }

    function addPair(
        address[] memory _listOfToken0,
        address[] memory _listOfToken1,
        address[] memory _listOfPair
    ) public onlyOwner {
        require(
            _listOfPair.length == _listOfToken0.length,
            "constructor: _listOfPair and _listOfToken0 have an unequal length"
        );
        require(
            _listOfPair.length == _listOfToken1.length,
            "constructor: _listOfPair and _listOfToken1 have an unequal length"
        );
        for (uint256 i; i < _listOfPair.length; i++) {
            address token0 = _listOfToken0[i];
            address token1 = _listOfToken1[i];
            address pair = _listOfPair[i];
            assetToAssetToPair[token0][token1] = pair;
            assetToAssetToPair[token1][token0] = pair;
        }
    }

    function setBlockNumberDeviation(uint256 _deviationPct) external onlyOwner {
        blockNumberDeviation = _deviationPct;
    }


    function __addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired
    ) private {
        address pair = getPair(_tokenA, _tokenB);

        uint256 amountA;
        uint256 amountB;

        uint256 amountBFromA = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValue(_tokenA, _amountADesired, _tokenB);
        uint256 amountAFromB = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValue(_tokenB, _amountBDesired, _tokenA);

        if (amountBFromA >= _amountBDesired) {
            amountA = amountAFromB;
            amountB = _amountBDesired;
        } else {
            amountA = _amountADesired;
            amountB = amountBFromA;
        }

        uint256 tokenPerLPToken = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValue(pair, 10**uint256(PRECISION), _tokenA);

        uint256 inverseRate = uint256(10**PRECISION).mul(10**PRECISION).div(tokenPerLPToken);

        uint256 totalLiquidity = uint256(2).mul(
            amountA.mul(inverseRate).div(uint256(10**PRECISION))
        );

        require(
            ERC20(pair).balanceOf(address(this)) >= totalLiquidity,
            "__addLiquidity: Integratee doesn't have enough pair balance to cover the expected amount"
        );

        address[] memory assetsToIntegratee = new address[](2);
        uint256[] memory assetsToIntegrateeAmounts = new uint256[](2);
        address[] memory assetsFromIntegratee = new address[](1);
        uint256[] memory assetsFromIntegrateeAmounts = new uint256[](1);

        assetsToIntegratee[0] = _tokenA;
        assetsToIntegrateeAmounts[0] = amountA;
        assetsToIntegratee[1] = _tokenB;
        assetsToIntegrateeAmounts[1] = amountB;
        assetsFromIntegratee[0] = pair;
        assetsFromIntegrateeAmounts[0] = totalLiquidity;

        __swap(
            msg.sender,
            assetsToIntegratee,
            assetsToIntegrateeAmounts,
            assetsFromIntegratee,
            assetsFromIntegrateeAmounts
        );
    }

    function __removeLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _liquidity
    ) private {
        address pair = assetToAssetToPair[_tokenA][_tokenB];
        require(pair != address(0), "__removeLiquidity: this pair doesn't exist");

        uint256 amountA = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValue(pair, _liquidity, _tokenA)
            .div(uint256(2));

        uint256 amountB = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValue(pair, _liquidity, _tokenB)
            .div(uint256(2));

        address[] memory assetsToIntegratee = new address[](1);
        uint256[] memory assetsToIntegrateeAmounts = new uint256[](1);
        address[] memory assetsFromIntegratee = new address[](2);
        uint256[] memory assetsFromIntegrateeAmounts = new uint256[](2);

        assetsToIntegratee[0] = pair;
        assetsToIntegrateeAmounts[0] = _liquidity;
        assetsFromIntegratee[0] = _tokenA;
        assetsFromIntegrateeAmounts[0] = amountA;
        assetsFromIntegratee[1] = _tokenB;
        assetsFromIntegrateeAmounts[1] = amountB;

        require(
            ERC20(_tokenA).balanceOf(address(this)) >= amountA,
            "__removeLiquidity: Integratee doesn't have enough tokenA balance to cover the expected amount"
        );
        require(
            ERC20(_tokenB).balanceOf(address(this)) >= amountA,
            "__removeLiquidity: Integratee doesn't have enough tokenB balance to cover the expected amount"
        );

        __swap(
            msg.sender,
            assetsToIntegratee,
            assetsToIntegrateeAmounts,
            assetsFromIntegratee,
            assetsFromIntegrateeAmounts
        );
    }


    function feeTo() external pure returns (address) {
        return address(0);
    }

    function getCentralizedRateProvider() public view returns (address) {
        return CENTRALIZED_RATE_PROVIDER;
    }

    function getBlockNumberDeviation() public view returns (uint256) {
        return blockNumberDeviation;
    }

    function getPrecision() public pure returns (uint256) {
        return PRECISION;
    }

    function getPair(address _token0, address _token1) public view returns (address) {
        return assetToAssetToPair[_token0][_token1];
    }
}// GPL-3.0


pragma solidity 0.6.12;

contract MockChainlinkPriceSource {
    event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);

    uint256 public DECIMALS;

    int256 public latestAnswer;
    uint256 public latestTimestamp;
    uint256 public roundId;
    address public aggregator;

    constructor(uint256 _decimals) public {
        DECIMALS = _decimals;
        latestAnswer = int256(10**_decimals);
        latestTimestamp = now;
        roundId = 1;
        aggregator = address(this);
    }

    function setLatestAnswer(int256 _nextAnswer, uint256 _nextTimestamp) external {
        latestAnswer = _nextAnswer;
        latestTimestamp = _nextTimestamp;
        roundId = roundId + 1;

        emit AnswerUpdated(latestAnswer, roundId, latestTimestamp);
    }

    function setAggregator(address _nextAggregator) external {
        aggregator = _nextAggregator;
    }

    function decimals() public view returns (uint256) {
        return DECIMALS;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockSynthetixPriceSource is Ownable, ISynthetixExchangeRates {
    using SafeMath for uint256;

    mapping(bytes32 => uint256) private fixedRate;
    mapping(bytes32 => AggregatorInfo) private currencyKeyToAggregator;

    enum RateAsset {ETH, USD}

    struct AggregatorInfo {
        address aggregator;
        RateAsset rateAsset;
    }

    constructor(address _ethUsdAggregator) public {
        currencyKeyToAggregator[bytes32("ETH")] = AggregatorInfo({
            aggregator: _ethUsdAggregator,
            rateAsset: RateAsset.USD
        });
    }

    function setPriceSourcesForCurrencyKeys(
        bytes32[] calldata _currencyKeys,
        address[] calldata _aggregators,
        RateAsset[] calldata _rateAssets
    ) external onlyOwner {
        require(
            _currencyKeys.length == _aggregators.length &&
                _rateAssets.length == _aggregators.length
        );
        for (uint256 i = 0; i < _currencyKeys.length; i++) {
            currencyKeyToAggregator[_currencyKeys[i]] = AggregatorInfo({
                aggregator: _aggregators[i],
                rateAsset: _rateAssets[i]
            });
        }
    }

    function setRate(bytes32 _currencyKey, uint256 _rate) external onlyOwner {
        fixedRate[_currencyKey] = _rate;
    }

    function rateAndInvalid(bytes32 _currencyKey)
        external
        view
        override
        returns (uint256 rate_, bool isInvalid_)
    {
        uint256 storedRate = getFixedRate(_currencyKey);
        if (storedRate != 0) {
            rate_ = storedRate;
        } else {
            AggregatorInfo memory aggregatorInfo = getAggregatorFromCurrencyKey(_currencyKey);
            address aggregator = aggregatorInfo.aggregator;
            if (aggregator == address(0)) {
                rate_ = 0;
                isInvalid_ = true;
                return (rate_, isInvalid_);
            }
            uint256 decimals = MockChainlinkPriceSource(aggregator).decimals();
            rate_ = uint256(MockChainlinkPriceSource(aggregator).latestAnswer()).mul(
                10**(uint256(18).sub(decimals))
            );

            if (aggregatorInfo.rateAsset == RateAsset.ETH) {
                uint256 ethToUsd = uint256(
                    MockChainlinkPriceSource(
                        getAggregatorFromCurrencyKey(bytes32("ETH"))
                            .aggregator
                    )
                        .latestAnswer()
                );
                rate_ = rate_.mul(ethToUsd).div(10**8);
            }
        }

        isInvalid_ = (rate_ == 0);
        return (rate_, isInvalid_);
    }


    function getAggregatorFromCurrencyKey(bytes32 _currencyKey)
        public
        view
        returns (AggregatorInfo memory _aggregator)
    {
        return currencyKeyToAggregator[_currencyKey];
    }

    function getFixedRate(bytes32 _currencyKey) public view returns (uint256) {
        return fixedRate[_currencyKey];
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockSynthetixIntegratee is Ownable, MockToken {
    using SafeMath for uint256;

    mapping(address => mapping(address => bool)) private authorizerToDelegateToApproval;
    mapping(bytes32 => address) private currencyKeyToSynth;

    address private immutable CENTRALIZED_RATE_PROVIDER;
    address private immutable EXCHANGE_RATES;
    uint256 private immutable FEE;

    uint256 private constant UNIT_FEE = 1000;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _centralizedRateProvider,
        address _exchangeRates,
        uint256 _fee
    ) public MockToken(_name, _symbol, _decimals) {
        CENTRALIZED_RATE_PROVIDER = _centralizedRateProvider;
        EXCHANGE_RATES = address(_exchangeRates);
        FEE = _fee;
    }

    receive() external payable {}

    function exchangeOnBehalfWithTracking(
        address _exchangeForAddress,
        bytes32 _srcCurrencyKey,
        uint256 _srcAmount,
        bytes32 _destinationCurrencyKey,
        address,
        bytes32
    ) external returns (uint256 amountReceived_) {
        require(
            canExchangeFor(_exchangeForAddress, msg.sender),
            "exchangeOnBehalfWithTracking: Not approved to act on behalf"
        );

        amountReceived_ = __calculateAndSwap(
            _exchangeForAddress,
            _srcAmount,
            _srcCurrencyKey,
            _destinationCurrencyKey
        );

        return amountReceived_;
    }

    function getAmountsForExchange(
        uint256 _srcAmount,
        bytes32 _srcCurrencyKey,
        bytes32 _destCurrencyKey
    )
        public
        returns (
            uint256 amountReceived_,
            uint256 fee_,
            uint256 exchangeFeeRate_
        )
    {
        address srcToken = currencyKeyToSynth[_srcCurrencyKey];
        address destToken = currencyKeyToSynth[_destCurrencyKey];

        require(
            currencyKeyToSynth[_srcCurrencyKey] != address(0) &&
                currencyKeyToSynth[_destCurrencyKey] != address(0),
            "getAmountsForExchange: Currency key doesn't have an associated synth"
        );

        uint256 destAmount = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValueRandomizedBySender(srcToken, _srcAmount, destToken);

        exchangeFeeRate_ = FEE;
        amountReceived_ = destAmount.mul(UNIT_FEE.sub(exchangeFeeRate_)).div(UNIT_FEE);
        fee_ = destAmount.sub(amountReceived_);

        return (amountReceived_, fee_, exchangeFeeRate_);
    }

    function setSynthFromCurrencyKeys(bytes32[] calldata _currencyKeys, address[] calldata _synths)
        external
    {
        require(
            _currencyKeys.length == _synths.length,
            "setSynthFromCurrencyKey: Unequal _currencyKeys and _synths lengths"
        );
        for (uint256 i = 0; i < _currencyKeys.length; i++) {
            currencyKeyToSynth[_currencyKeys[i]] = _synths[i];
        }
    }

    function approveExchangeOnBehalf(address _delegate) external {
        authorizerToDelegateToApproval[msg.sender][_delegate] = true;
    }

    function __calculateAndSwap(
        address _exchangeForAddress,
        uint256 _srcAmount,
        bytes32 _srcCurrencyKey,
        bytes32 _destCurrencyKey
    ) private returns (uint256 amountReceived_) {
        MockSynthetixToken srcSynth = MockSynthetixToken(currencyKeyToSynth[_srcCurrencyKey]);
        MockSynthetixToken destSynth = MockSynthetixToken(currencyKeyToSynth[_destCurrencyKey]);

        require(address(srcSynth) != address(0), "__calculateAndSwap: Source synth is not listed");
        require(
            address(destSynth) != address(0),
            "__calculateAndSwap: Destination synth is not listed"
        );
        require(
            !srcSynth.isLocked(_exchangeForAddress),
            "__calculateAndSwap: Cannot settle during waiting period"
        );

        (amountReceived_, , ) = getAmountsForExchange(
            _srcAmount,
            _srcCurrencyKey,
            _destCurrencyKey
        );

        srcSynth.burnFrom(_exchangeForAddress, _srcAmount);
        destSynth.mintFor(_exchangeForAddress, amountReceived_);
        destSynth.lock(_exchangeForAddress);

        return amountReceived_;
    }

    function requireAndGetAddress(bytes32 _name, string calldata)
        external
        view
        returns (address resolvedAddress_)
    {
        if (_name == "ExchangeRates") {
            return EXCHANGE_RATES;
        }
        return address(this);
    }

    function settle(address, bytes32)
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {}


    function canExchangeFor(address _authorizer, address _delegate)
        public
        view
        returns (bool canExchange_)
    {
        return authorizerToDelegateToApproval[_authorizer][_delegate];
    }

    function getExchangeRates() public view returns (address exchangeRates_) {
        return EXCHANGE_RATES;
    }

    function getFee() public view returns (uint256 fee_) {
        return FEE;
    }

    function getSynthFromCurrencyKey(bytes32 _currencyKey) public view returns (address synth_) {
        return currencyKeyToSynth[_currencyKey];
    }

    function getUnitFee() public pure returns (uint256 fee_) {
        return UNIT_FEE;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockCTokenBase is ERC20, SwapperBase, Ownable {
    address internal immutable TOKEN;
    address internal immutable CENTRALIZED_RATE_PROVIDER;

    uint256 internal rate;

    mapping(address => mapping(address => uint256)) internal _allowances;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _token,
        address _centralizedRateProvider,
        uint256 _initialRate
    ) public ERC20(_name, _symbol) {
        _setupDecimals(_decimals);
        TOKEN = _token;
        CENTRALIZED_RATE_PROVIDER = _centralizedRateProvider;
        rate = _initialRate;
    }

    function approve(address _spender, uint256 _amount) public virtual override returns (bool) {
        _allowances[msg.sender][_spender] = _amount;
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256) {
        if (_spender == address(this) || _owner == _spender) {
            return 2**256 - 1;
        } else {
            return _allowances[_owner][_spender];
        }
    }

    function mintFor(address _who, uint256 _amount) external onlyOwner {
        _mint(_who, _amount);
    }

    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public virtual override returns (bool) {
        _transfer(_sender, _recipient, _amount);
        return true;
    }


    function __calcCTokenAmount(uint256 _tokenAmount) internal returns (uint256 cTokenAmount_) {
        uint256 tokenDecimals = ERC20(TOKEN).decimals();
        uint256 cTokenDecimals = decimals();

        uint256 tokenPerCTokenUnit = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValue(address(this), 10**uint256(cTokenDecimals), TOKEN);

        uint256 inverseRate = uint256(10**tokenDecimals).mul(10**uint256(cTokenDecimals)).div(
            tokenPerCTokenUnit
        );

        cTokenAmount_ = _tokenAmount.mul(inverseRate).div(10**tokenDecimals);
    }


    function underlying() public view returns (address) {
        return TOKEN;
    }

    function exchangeRateStored() public view returns (uint256) {
        return rate;
    }

    function getCentralizedRateProvider() public view returns (address) {
        return CENTRALIZED_RATE_PROVIDER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockCTokenIntegratee is MockCTokenBase {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _token,
        address _centralizedRateProvider,
        uint256 _initialRate
    )
        public
        MockCTokenBase(_name, _symbol, _decimals, _token, _centralizedRateProvider, _initialRate)
    {}

    function mint(uint256 _amount) external returns (uint256) {
        uint256 destAmount = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER).calcLiveAssetValue(
            TOKEN,
            _amount,
            address(this)
        );

        __swapAssets(msg.sender, TOKEN, _amount, address(this), destAmount);
        return _amount;
    }

    function redeem(uint256 _amount) external returns (uint256) {
        uint256 destAmount = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER).calcLiveAssetValue(
            address(this),
            _amount,
            TOKEN
        );
        __swapAssets(msg.sender, address(this), _amount, TOKEN, destAmount);
        return _amount;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockCEtherIntegratee is MockCTokenBase {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _weth,
        address _centralizedRateProvider,
        uint256 _initialRate
    )
        public
        MockCTokenBase(_name, _symbol, _decimals, _weth, _centralizedRateProvider, _initialRate)
    {}

    function mint() external payable {
        uint256 amount = msg.value;
        uint256 destAmount = __calcCTokenAmount(amount);
        __swapAssets(msg.sender, ETH_ADDRESS, amount, address(this), destAmount);
    }

    function redeem(uint256 _amount) external returns (uint256) {
        uint256 destAmount = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER).calcLiveAssetValue(
            address(this),
            _amount,
            TOKEN
        );
        __swapAssets(msg.sender, address(this), _amount, ETH_ADDRESS, destAmount);
        return _amount;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IParaSwapAugustusSwapper {
    struct Route {
        address payable exchange;
        address targetExchange;
        uint256 percent;
        bytes payload;
        uint256 networkFee;
    }

    struct Path {
        address to;
        uint256 totalNetworkFee;
        Route[] routes;
    }

    function multiSwap(
        address,
        address,
        uint256,
        uint256,
        uint256,
        Path[] calldata,
        uint256,
        address payable,
        uint256,
        string calldata
    ) external payable returns (uint256);
}// GPL-3.0


pragma solidity 0.6.12;


contract MockParaSwapIntegratee is SwapperBase {
    using SafeMath for uint256;

    address private immutable MOCK_CENTRALIZED_RATE_PROVIDER;

    uint256 private blockNumberDeviation;

    constructor(address _mockCentralizedRateProvider, uint256 _blockNumberDeviation) public {
        MOCK_CENTRALIZED_RATE_PROVIDER = _mockCentralizedRateProvider;
        blockNumberDeviation = _blockNumberDeviation;
    }

    function multiSwap(
        address _fromToken,
        address _toToken,
        uint256 _fromAmount,
        uint256, // toAmount (min received amount)
        uint256, // expectedAmount
        IParaSwapAugustusSwapper.Path[] memory _paths,
        uint256, // mintPrice
        address, // beneficiary
        uint256, // donationPercentage
        string memory // referrer
    ) public payable returns (uint256) {
        return __multiSwap(_fromToken, _toToken, _fromAmount, _paths);
    }

    function __calcTotalNetworkFees(IParaSwapAugustusSwapper.Path[] memory _paths)
        private
        pure
        returns (uint256 totalNetworkFees_)
    {
        for (uint256 i; i < _paths.length; i++) {
            totalNetworkFees_ = totalNetworkFees_.add(_paths[i].totalNetworkFee);
        }

        return totalNetworkFees_;
    }

    function __multiSwap(
        address _fromToken,
        address _toToken,
        uint256 _fromAmount,
        IParaSwapAugustusSwapper.Path[] memory _paths
    ) private returns (uint256) {
        address[] memory assetsFromIntegratee = new address[](1);
        assetsFromIntegratee[0] = _toToken;

        uint256[] memory assetsFromIntegrateeAmounts = new uint256[](1);
        assetsFromIntegrateeAmounts[0] = CentralizedRateProvider(MOCK_CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValueRandomized(_fromToken, _fromAmount, _toToken, blockNumberDeviation);

        uint256 totalNetworkFees = __calcTotalNetworkFees(_paths);
        address[] memory assetsToIntegratee;
        uint256[] memory assetsToIntegrateeAmounts;
        if (totalNetworkFees > 0) {
            assetsToIntegratee = new address[](2);
            assetsToIntegratee[1] = ETH_ADDRESS;

            assetsToIntegrateeAmounts = new uint256[](2);
            assetsToIntegrateeAmounts[1] = totalNetworkFees;
        } else {
            assetsToIntegratee = new address[](1);
            assetsToIntegrateeAmounts = new uint256[](1);
        }
        assetsToIntegratee[0] = _fromToken;
        assetsToIntegrateeAmounts[0] = _fromAmount;

        __swap(
            msg.sender,
            assetsToIntegratee,
            assetsToIntegrateeAmounts,
            assetsFromIntegratee,
            assetsFromIntegrateeAmounts
        );

        return assetsFromIntegrateeAmounts[0];
    }


    function getBlockNumberDeviation() external view returns (uint256 blockNumberDeviation_) {
        return blockNumberDeviation;
    }

    function getCentralizedRateProvider()
        external
        view
        returns (address centralizedRateProvider_)
    {
        return MOCK_CENTRALIZED_RATE_PROVIDER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract ParaSwapAdapter is AdapterBase {
    using SafeMath for uint256;

    string private constant REFERRER = "enzyme";

    address private immutable EXCHANGE;
    address private immutable TOKEN_TRANSFER_PROXY;
    address private immutable WETH_TOKEN;

    constructor(
        address _integrationManager,
        address _exchange,
        address _tokenTransferProxy,
        address _wethToken
    ) public AdapterBase(_integrationManager) {
        EXCHANGE = _exchange;
        TOKEN_TRANSFER_PROXY = _tokenTransferProxy;
        WETH_TOKEN = _wethToken;
    }

    receive() external payable {}


    function identifier() external pure override returns (string memory identifier_) {
        return "PARASWAP";
    }

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        require(_selector == TAKE_ORDER_SELECTOR, "parseAssetsForMethod: _selector invalid");

        (
            address incomingAsset,
            uint256 minIncomingAssetAmount,
            ,
            address outgoingAsset,
            uint256 outgoingAssetAmount,
            IParaSwapAugustusSwapper.Path[] memory paths
        ) = __decodeCallArgs(_encodedCallArgs);

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = incomingAsset;
        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingAssetAmount;

        uint256 totalNetworkFees = __calcTotalNetworkFees(paths);
        if (totalNetworkFees > 0) {
            if (outgoingAsset == WETH_TOKEN) {
                spendAssets_ = new address[](1);
                spendAssets_[0] = outgoingAsset;

                spendAssetAmounts_ = new uint256[](1);
                spendAssetAmounts_[0] = outgoingAssetAmount.add(totalNetworkFees);
            } else {
                spendAssets_ = new address[](2);
                spendAssets_[0] = outgoingAsset;
                spendAssets_[1] = WETH_TOKEN;

                spendAssetAmounts_ = new uint256[](2);
                spendAssetAmounts_[0] = outgoingAssetAmount;
                spendAssetAmounts_[1] = totalNetworkFees;
            }
        } else {
            spendAssets_ = new address[](1);
            spendAssets_[0] = outgoingAsset;

            spendAssetAmounts_ = new uint256[](1);
            spendAssetAmounts_[0] = outgoingAssetAmount;
        }

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function takeOrder(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        fundAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        __takeOrder(_vaultProxy, _encodedCallArgs);
    }


    function __calcTotalNetworkFees(IParaSwapAugustusSwapper.Path[] memory _paths)
        private
        pure
        returns (uint256 totalNetworkFees_)
    {
        for (uint256 i; i < _paths.length; i++) {
            totalNetworkFees_ = totalNetworkFees_.add(_paths[i].totalNetworkFee);
        }

        return totalNetworkFees_;
    }

    function __decodeCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address incomingAsset_,
            uint256 minIncomingAssetAmount_,
            uint256 expectedIncomingAssetAmount_, // Passed as a courtesy to ParaSwap for analytics
            address outgoingAsset_,
            uint256 outgoingAssetAmount_,
            IParaSwapAugustusSwapper.Path[] memory paths_
        )
    {
        return
            abi.decode(
                _encodedCallArgs,
                (address, uint256, uint256, address, uint256, IParaSwapAugustusSwapper.Path[])
            );
    }

    function __encodeMultiSwapCallData(
        address _vaultProxy,
        address _incomingAsset,
        uint256 _minIncomingAssetAmount,
        uint256 _expectedIncomingAssetAmount, // Passed as a courtesy to ParaSwap for analytics
        address _outgoingAsset,
        uint256 _outgoingAssetAmount,
        IParaSwapAugustusSwapper.Path[] memory _paths
    ) private pure returns (bytes memory multiSwapCallData) {
        return
            abi.encodeWithSelector(
                IParaSwapAugustusSwapper.multiSwap.selector,
                _outgoingAsset, // fromToken
                _incomingAsset, // toToken
                _outgoingAssetAmount, // fromAmount
                _minIncomingAssetAmount, // toAmount
                _expectedIncomingAssetAmount, // expectedAmount
                _paths, // path
                0, // mintPrice
                payable(_vaultProxy), // beneficiary
                0, // donationPercentage
                REFERRER // referrer
            );
    }

    function __executeMultiSwap(bytes memory _multiSwapCallData, uint256 _totalNetworkFees)
        private
    {
        (bool success, bytes memory returnData) = EXCHANGE.call{value: _totalNetworkFees}(
            _multiSwapCallData
        );
        require(success, string(returnData));
    }

    function __takeOrder(address _vaultProxy, bytes memory _encodedCallArgs) private {
        (
            address incomingAsset,
            uint256 minIncomingAssetAmount,
            uint256 expectedIncomingAssetAmount,
            address outgoingAsset,
            uint256 outgoingAssetAmount,
            IParaSwapAugustusSwapper.Path[] memory paths
        ) = __decodeCallArgs(_encodedCallArgs);

        __approveMaxAsNeeded(outgoingAsset, TOKEN_TRANSFER_PROXY, outgoingAssetAmount);

        uint256 totalNetworkFees = __calcTotalNetworkFees(paths);
        if (totalNetworkFees > 0) {
            __unwrapWeth(totalNetworkFees);
        }

        bytes memory multiSwapCallData = __encodeMultiSwapCallData(
            _vaultProxy,
            incomingAsset,
            minIncomingAssetAmount,
            expectedIncomingAssetAmount,
            outgoingAsset,
            outgoingAssetAmount,
            paths
        );

        __executeMultiSwap(multiSwapCallData, totalNetworkFees);

        if (totalNetworkFees > 0) {
            __wrapEth();
        }
    }

    function __unwrapWeth(uint256 _amount) private {
        IWETH(payable(WETH_TOKEN)).withdraw(_amount);
    }

    function __wrapEth() private {
        uint256 ethBalance = payable(address(this)).balance;
        if (ethBalance > 0) {
            IWETH(payable(WETH_TOKEN)).deposit{value: ethBalance}();
        }
    }


    function getExchange() external view returns (address exchange_) {
        return EXCHANGE;
    }

    function getTokenTransferProxy() external view returns (address tokenTransferProxy_) {
        return TOKEN_TRANSFER_PROXY;
    }

    function getWethToken() external view returns (address wethToken_) {
        return WETH_TOKEN;
    }
}// GPL-3.0


pragma solidity ^0.6.12;

interface ICERC20 is IERC20 {
    function decimals() external view returns (uint8);

    function mint(uint256) external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function underlying() external returns (address);
}// GPL-3.0


pragma solidity 0.6.12;


contract CompoundPriceFeed is IDerivativePriceFeed, DispatcherOwnerMixin {
    using SafeMath for uint256;

    event CTokenAdded(address indexed cToken, address indexed token);

    uint256 private constant CTOKEN_RATE_DIVISOR = 10**18;

    mapping(address => address) private cTokenToToken;

    constructor(
        address _dispatcher,
        address _weth,
        address _ceth,
        address[] memory cERC20Tokens
    ) public DispatcherOwnerMixin(_dispatcher) {
        cTokenToToken[_ceth] = _weth;
        emit CTokenAdded(_ceth, _weth);

        if (cERC20Tokens.length > 0) {
            __addCERC20Tokens(cERC20Tokens);
        }
    }

    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        underlyings_ = new address[](1);
        underlyings_[0] = cTokenToToken[_derivative];
        require(underlyings_[0] != address(0), "calcUnderlyingValues: Unsupported derivative");

        underlyingAmounts_ = new uint256[](1);
        underlyingAmounts_[0] = _derivativeAmount
            .mul(ICERC20(_derivative).exchangeRateStored())
            .div(CTOKEN_RATE_DIVISOR);

        return (underlyings_, underlyingAmounts_);
    }

    function isSupportedAsset(address _asset) external view override returns (bool isSupported_) {
        return cTokenToToken[_asset] != address(0);
    }


    function addCTokens(address[] calldata _cTokens) external onlyDispatcherOwner {
        __addCERC20Tokens(_cTokens);
    }

    function __addCERC20Tokens(address[] memory _cTokens) private {
        require(_cTokens.length > 0, "__addCTokens: Empty _cTokens");

        for (uint256 i; i < _cTokens.length; i++) {
            require(cTokenToToken[_cTokens[i]] == address(0), "__addCTokens: Value already set");

            address token = ICERC20(_cTokens[i]).underlying();
            cTokenToToken[_cTokens[i]] = token;

            emit CTokenAdded(_cTokens[i], token);
        }
    }


    function getTokenFromCToken(address _cToken) public view returns (address token_) {
        return cTokenToToken[_cToken];
    }
}// GPL-3.0


pragma solidity ^0.6.12;

interface ICEther {
    function mint() external payable;
}// GPL-3.0


pragma solidity 0.6.12;


contract CompoundAdapter is AdapterBase {
    address private immutable COMPOUND_PRICE_FEED;
    address private immutable WETH_TOKEN;

    constructor(
        address _integrationManager,
        address _compoundPriceFeed,
        address _wethToken
    ) public AdapterBase(_integrationManager) {
        COMPOUND_PRICE_FEED = _compoundPriceFeed;
        WETH_TOKEN = _wethToken;
    }

    receive() external payable {}

    function identifier() external pure override returns (string memory identifier_) {
        return "COMPOUND";
    }

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        if (_selector == LEND_SELECTOR) {
            (address cToken, uint256 tokenAmount, uint256 minCTokenAmount) = __decodeCallArgs(
                _encodedCallArgs
            );
            address token = CompoundPriceFeed(COMPOUND_PRICE_FEED).getTokenFromCToken(cToken);
            require(token != address(0), "parseAssetsForMethod: Unsupported cToken");

            spendAssets_ = new address[](1);
            spendAssets_[0] = token;
            spendAssetAmounts_ = new uint256[](1);
            spendAssetAmounts_[0] = tokenAmount;

            incomingAssets_ = new address[](1);
            incomingAssets_[0] = cToken;
            minIncomingAssetAmounts_ = new uint256[](1);
            minIncomingAssetAmounts_[0] = minCTokenAmount;
        } else if (_selector == REDEEM_SELECTOR) {
            (address cToken, uint256 cTokenAmount, uint256 minTokenAmount) = __decodeCallArgs(
                _encodedCallArgs
            );
            address token = CompoundPriceFeed(COMPOUND_PRICE_FEED).getTokenFromCToken(cToken);
            require(token != address(0), "parseAssetsForMethod: Unsupported cToken");

            spendAssets_ = new address[](1);
            spendAssets_[0] = cToken;
            spendAssetAmounts_ = new uint256[](1);
            spendAssetAmounts_[0] = cTokenAmount;

            incomingAssets_ = new address[](1);
            incomingAssets_[0] = token;
            minIncomingAssetAmounts_ = new uint256[](1);
            minIncomingAssetAmounts_[0] = minTokenAmount;
        } else {
            revert("parseAssetsForMethod: _selector invalid");
        }

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function lend(
        address _vaultProxy,
        bytes calldata,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        fundAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            ,
            address[] memory spendAssets,
            uint256[] memory spendAssetAmounts,
            address[] memory incomingAssets
        ) = __decodeEncodedAssetTransferArgs(_encodedAssetTransferArgs);

        if (spendAssets[0] == WETH_TOKEN) {
            IWETH(WETH_TOKEN).withdraw(spendAssetAmounts[0]);
            ICEther(incomingAssets[0]).mint{value: spendAssetAmounts[0]}();
        } else {
            __approveMaxAsNeeded(spendAssets[0], incomingAssets[0], spendAssetAmounts[0]);
            ICERC20(incomingAssets[0]).mint(spendAssetAmounts[0]);
        }
    }

    function redeem(
        address _vaultProxy,
        bytes calldata,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        fundAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            ,
            address[] memory spendAssets,
            uint256[] memory spendAssetAmounts,
            address[] memory incomingAssets
        ) = __decodeEncodedAssetTransferArgs(_encodedAssetTransferArgs);

        ICERC20(spendAssets[0]).redeem(spendAssetAmounts[0]);

        if (incomingAssets[0] == WETH_TOKEN) {
            IWETH(payable(WETH_TOKEN)).deposit{value: payable(address(this)).balance}();
        }
    }


    function __decodeCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address cToken_,
            uint256 outgoingAssetAmount_,
            uint256 minIncomingAssetAmount_
        )
    {
        return abi.decode(_encodedCallArgs, (address, uint256, uint256));
    }


    function getCompoundPriceFeed() external view returns (address compoundPriceFeed_) {
        return COMPOUND_PRICE_FEED;
    }

    function getWethToken() external view returns (address wethToken_) {
        return WETH_TOKEN;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IChai is IERC20 {
    function exit(address, uint256) external;

    function join(address, uint256) external;
}// GPL-3.0


pragma solidity 0.6.12;


contract ChaiAdapter is AdapterBase {
    address private immutable CHAI;
    address private immutable DAI;

    constructor(
        address _integrationManager,
        address _chai,
        address _dai
    ) public AdapterBase(_integrationManager) {
        CHAI = _chai;
        DAI = _dai;
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "CHAI";
    }

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        if (_selector == LEND_SELECTOR) {
            (uint256 daiAmount, uint256 minChaiAmount) = __decodeCallArgs(_encodedCallArgs);

            spendAssets_ = new address[](1);
            spendAssets_[0] = DAI;
            spendAssetAmounts_ = new uint256[](1);
            spendAssetAmounts_[0] = daiAmount;

            incomingAssets_ = new address[](1);
            incomingAssets_[0] = CHAI;
            minIncomingAssetAmounts_ = new uint256[](1);
            minIncomingAssetAmounts_[0] = minChaiAmount;
        } else if (_selector == REDEEM_SELECTOR) {
            (uint256 chaiAmount, uint256 minDaiAmount) = __decodeCallArgs(_encodedCallArgs);

            spendAssets_ = new address[](1);
            spendAssets_[0] = CHAI;
            spendAssetAmounts_ = new uint256[](1);
            spendAssetAmounts_[0] = chaiAmount;

            incomingAssets_ = new address[](1);
            incomingAssets_[0] = DAI;
            minIncomingAssetAmounts_ = new uint256[](1);
            minIncomingAssetAmounts_[0] = minDaiAmount;
        } else {
            revert("parseAssetsForMethod: _selector invalid");
        }

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function lend(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        fundAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (uint256 daiAmount, ) = __decodeCallArgs(_encodedCallArgs);

        __approveMaxAsNeeded(DAI, CHAI, daiAmount);

        IChai(CHAI).join(_vaultProxy, daiAmount);
    }

    function redeem(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        fundAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (uint256 chaiAmount, ) = __decodeCallArgs(_encodedCallArgs);

        IChai(CHAI).exit(address(this), chaiAmount);
    }


    function __decodeCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (uint256 outgoingAmount_, uint256 minIncomingAmount_)
    {
        return abi.decode(_encodedCallArgs, (uint256, uint256));
    }


    function getChai() external view returns (address chai_) {
        return CHAI;
    }

    function getDai() external view returns (address dai_) {
        return DAI;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockGenericIntegratee is SwapperBase {
    function swap(
        address[] calldata _assetsToIntegratee,
        uint256[] calldata _assetsToIntegrateeAmounts,
        address[] calldata _assetsFromIntegratee,
        uint256[] calldata _assetsFromIntegrateeAmounts
    ) external payable {
        __swap(
            msg.sender,
            _assetsToIntegratee,
            _assetsToIntegrateeAmounts,
            _assetsFromIntegratee,
            _assetsFromIntegrateeAmounts
        );
    }

    function swapOnBehalf(
        address payable _trader,
        address[] calldata _assetsToIntegratee,
        uint256[] calldata _assetsToIntegrateeAmounts,
        address[] calldata _assetsFromIntegratee,
        uint256[] calldata _assetsFromIntegrateeAmounts
    ) external payable {
        __swap(
            _trader,
            _assetsToIntegratee,
            _assetsToIntegrateeAmounts,
            _assetsFromIntegratee,
            _assetsFromIntegrateeAmounts
        );
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockChaiIntegratee is MockToken, SwapperBase {
    address private immutable CENTRALIZED_RATE_PROVIDER;
    address public immutable DAI;

    constructor(
        address _dai,
        address _centralizedRateProvider,
        uint8 _decimals
    ) public MockToken("Chai", "CHAI", _decimals) {
        _setupDecimals(_decimals);
        CENTRALIZED_RATE_PROVIDER = _centralizedRateProvider;
        DAI = _dai;
    }

    function join(address, uint256 _daiAmount) external {
        uint256 tokenDecimals = ERC20(DAI).decimals();
        uint256 chaiDecimals = decimals();

        uint256 daiPerChaiUnit = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER)
            .calcLiveAssetValue(address(this), 10**uint256(chaiDecimals), DAI);

        uint256 inverseRate = uint256(10**tokenDecimals).mul(10**uint256(chaiDecimals)).div(
            daiPerChaiUnit
        );
        uint256 destAmount = _daiAmount.mul(inverseRate).div(10**tokenDecimals);
        _mint(address(this), destAmount);
        __swapAssets(msg.sender, DAI, _daiAmount, address(this), destAmount);
    }

    function exit(address payable _trader, uint256 _chaiAmount) external {
        uint256 destAmount = CentralizedRateProvider(CENTRALIZED_RATE_PROVIDER).calcLiveAssetValue(
            address(this),
            _chaiAmount,
            DAI
        );
        _burn(_trader, _chaiAmount);
        ERC20(DAI).transfer(msg.sender, destAmount);
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract AdapterBlacklist is PreCallOnIntegrationValidatePolicyBase, AddressListPolicyMixin {
    constructor(address _policyManager) public PolicyBase(_policyManager) {}

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        __addToList(_comptrollerProxy, abi.decode(_encodedSettings, (address[])));
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "ADAPTER_BLACKLIST";
    }

    function passesRule(address _comptrollerProxy, address _adapter)
        public
        view
        returns (bool isValid_)
    {
        return !isInList(_comptrollerProxy, _adapter);
    }

    function validateRule(
        address _comptrollerProxy,
        address,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override returns (bool isValid_) {
        (address adapter, ) = __decodeRuleArgs(_encodedArgs);

        return passesRule(_comptrollerProxy, adapter);
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract PreBuySharesValidatePolicyBase is PolicyBase {
    function implementedHooks()
        external
        view
        override
        returns (IPolicyManager.PolicyHook[] memory implementedHooks_)
    {
        implementedHooks_ = new IPolicyManager.PolicyHook[](1);
        implementedHooks_[0] = IPolicyManager.PolicyHook.PreBuyShares;

        return implementedHooks_;
    }

    function __decodeRuleArgs(bytes memory _encodedArgs)
        internal
        pure
        returns (
            address buyer_,
            uint256 investmentAmount_,
            uint256 minSharesQuantity_,
            uint256 gav_
        )
    {
        return abi.decode(_encodedArgs, (address, uint256, uint256, uint256));
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract InvestorWhitelist is PreBuySharesValidatePolicyBase, AddressListPolicyMixin {
    constructor(address _policyManager) public PolicyBase(_policyManager) {}

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        __updateList(_comptrollerProxy, _encodedSettings);
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "INVESTOR_WHITELIST";
    }

    function updateFundSettings(
        address _comptrollerProxy,
        address,
        bytes calldata _encodedSettings
    ) external override onlyPolicyManager {
        __updateList(_comptrollerProxy, _encodedSettings);
    }

    function passesRule(address _comptrollerProxy, address _investor)
        public
        view
        returns (bool isValid_)
    {
        return isInList(_comptrollerProxy, _investor);
    }

    function validateRule(
        address _comptrollerProxy,
        address,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override returns (bool isValid_) {
        (address buyer, , , ) = __decodeRuleArgs(_encodedArgs);

        return passesRule(_comptrollerProxy, buyer);
    }

    function __updateList(address _comptrollerProxy, bytes memory _settingsData) private {
        (address[] memory itemsToAdd, address[] memory itemsToRemove) = abi.decode(
            _settingsData,
            (address[], address[])
        );

        if (itemsToAdd.length > 0) {
            __addToList(_comptrollerProxy, itemsToAdd);
        }
        if (itemsToRemove.length > 0) {
            __removeFromList(_comptrollerProxy, itemsToRemove);
        }
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MinMaxInvestment is PreBuySharesValidatePolicyBase {
    event FundSettingsSet(
        address indexed comptrollerProxy,
        uint256 minInvestmentAmount,
        uint256 maxInvestmentAmount
    );

    struct FundSettings {
        uint256 minInvestmentAmount;
        uint256 maxInvestmentAmount;
    }

    mapping(address => FundSettings) private comptrollerProxyToFundSettings;

    constructor(address _policyManager) public PolicyBase(_policyManager) {}

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        __setFundSettings(_comptrollerProxy, _encodedSettings);
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "MIN_MAX_INVESTMENT";
    }

    function updateFundSettings(
        address _comptrollerProxy,
        address,
        bytes calldata _encodedSettings
    ) external override onlyPolicyManager {
        __setFundSettings(_comptrollerProxy, _encodedSettings);
    }

    function passesRule(address _comptrollerProxy, uint256 _investmentAmount)
        public
        view
        returns (bool isValid_)
    {
        uint256 minInvestmentAmount = comptrollerProxyToFundSettings[_comptrollerProxy]
            .minInvestmentAmount;
        uint256 maxInvestmentAmount = comptrollerProxyToFundSettings[_comptrollerProxy]
            .maxInvestmentAmount;

        if (minInvestmentAmount == 0) {
            return _investmentAmount <= maxInvestmentAmount;
        } else if (maxInvestmentAmount == 0) {
            return _investmentAmount >= minInvestmentAmount;
        }
        return
            _investmentAmount >= minInvestmentAmount && _investmentAmount <= maxInvestmentAmount;
    }

    function validateRule(
        address _comptrollerProxy,
        address,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override returns (bool isValid_) {
        (, uint256 investmentAmount, , ) = __decodeRuleArgs(_encodedArgs);

        return passesRule(_comptrollerProxy, investmentAmount);
    }

    function __setFundSettings(address _comptrollerProxy, bytes memory _encodedSettings) private {
        (uint256 minInvestmentAmount, uint256 maxInvestmentAmount) = abi.decode(
            _encodedSettings,
            (uint256, uint256)
        );

        require(
            maxInvestmentAmount == 0 || minInvestmentAmount < maxInvestmentAmount,
            "__setFundSettings: minInvestmentAmount must be less than maxInvestmentAmount"
        );

        comptrollerProxyToFundSettings[_comptrollerProxy]
            .minInvestmentAmount = minInvestmentAmount;
        comptrollerProxyToFundSettings[_comptrollerProxy]
            .maxInvestmentAmount = maxInvestmentAmount;

        emit FundSettingsSet(_comptrollerProxy, minInvestmentAmount, maxInvestmentAmount);
    }


    function getFundSettings(address _comptrollerProxy)
        external
        view
        returns (FundSettings memory fundSettings_)
    {
        return comptrollerProxyToFundSettings[_comptrollerProxy];
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract BuySharesSetupPolicyBase is PolicyBase {
    function implementedHooks()
        external
        view
        override
        returns (IPolicyManager.PolicyHook[] memory implementedHooks_)
    {
        implementedHooks_ = new IPolicyManager.PolicyHook[](1);
        implementedHooks_[0] = IPolicyManager.PolicyHook.BuySharesSetup;

        return implementedHooks_;
    }

    function __decodeRuleArgs(bytes memory _encodedArgs)
        internal
        pure
        returns (
            address caller_,
            uint256[] memory investmentAmounts_,
            uint256 gav_
        )
    {
        return abi.decode(_encodedArgs, (address, uint256[], uint256));
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract BuySharesCallerWhitelist is BuySharesSetupPolicyBase, AddressListPolicyMixin {
    constructor(address _policyManager) public PolicyBase(_policyManager) {}

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        __updateList(_comptrollerProxy, _encodedSettings);
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "BUY_SHARES_CALLER_WHITELIST";
    }

    function updateFundSettings(
        address _comptrollerProxy,
        address,
        bytes calldata _encodedSettings
    ) external override onlyPolicyManager {
        __updateList(_comptrollerProxy, _encodedSettings);
    }

    function passesRule(address _comptrollerProxy, address _buySharesCaller)
        public
        view
        returns (bool isValid_)
    {
        return isInList(_comptrollerProxy, _buySharesCaller);
    }

    function validateRule(
        address _comptrollerProxy,
        address,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override returns (bool isValid_) {
        (address caller, , ) = __decodeRuleArgs(_encodedArgs);

        return passesRule(_comptrollerProxy, caller);
    }

    function __updateList(address _comptrollerProxy, bytes memory _settingsData) private {
        (address[] memory itemsToAdd, address[] memory itemsToRemove) = abi.decode(
            _settingsData,
            (address[], address[])
        );

        if (itemsToAdd.length > 0) {
            __addToList(_comptrollerProxy, itemsToAdd);
        }
        if (itemsToRemove.length > 0) {
            __removeFromList(_comptrollerProxy, itemsToRemove);
        }
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract EntranceRateFeeBase is FeeBase {
    using SafeMath for uint256;

    event FundSettingsAdded(address indexed comptrollerProxy, uint256 rate);

    event Settled(address indexed comptrollerProxy, address indexed payer, uint256 sharesQuantity);

    uint256 private constant RATE_DIVISOR = 10**18;
    IFeeManager.SettlementType private immutable SETTLEMENT_TYPE;

    mapping(address => uint256) private comptrollerProxyToRate;

    constructor(address _feeManager, IFeeManager.SettlementType _settlementType)
        public
        FeeBase(_feeManager)
    {
        require(
            _settlementType == IFeeManager.SettlementType.Burn ||
                _settlementType == IFeeManager.SettlementType.Direct,
            "constructor: Invalid _settlementType"
        );
        SETTLEMENT_TYPE = _settlementType;
    }


    function addFundSettings(address _comptrollerProxy, bytes calldata _settingsData)
        external
        override
        onlyFeeManager
    {
        uint256 rate = abi.decode(_settingsData, (uint256));
        require(rate > 0, "addFundSettings: Fee rate must be >0");

        comptrollerProxyToRate[_comptrollerProxy] = rate;

        emit FundSettingsAdded(_comptrollerProxy, rate);
    }

    function implementedHooks()
        external
        view
        override
        returns (
            IFeeManager.FeeHook[] memory implementedHooksForSettle_,
            IFeeManager.FeeHook[] memory implementedHooksForUpdate_,
            bool usesGavOnSettle_,
            bool usesGavOnUpdate_
        )
    {
        implementedHooksForSettle_ = new IFeeManager.FeeHook[](1);
        implementedHooksForSettle_[0] = IFeeManager.FeeHook.PostBuyShares;

        return (implementedHooksForSettle_, new IFeeManager.FeeHook[](0), false, false);
    }

    function settle(
        address _comptrollerProxy,
        address,
        IFeeManager.FeeHook,
        bytes calldata _settlementData,
        uint256
    )
        external
        override
        onlyFeeManager
        returns (
            IFeeManager.SettlementType settlementType_,
            address payer_,
            uint256 sharesDue_
        )
    {
        uint256 sharesBought;
        (payer_, , sharesBought) = __decodePostBuySharesSettlementData(_settlementData);

        uint256 rate = comptrollerProxyToRate[_comptrollerProxy];
        sharesDue_ = sharesBought.mul(rate).div(RATE_DIVISOR.add(rate));

        if (sharesDue_ == 0) {
            return (IFeeManager.SettlementType.None, address(0), 0);
        }

        emit Settled(_comptrollerProxy, payer_, sharesDue_);

        return (SETTLEMENT_TYPE, payer_, sharesDue_);
    }


    function getRateForFund(address _comptrollerProxy) external view returns (uint256 rate_) {
        return comptrollerProxyToRate[_comptrollerProxy];
    }

    function getSettlementType()
        external
        view
        returns (IFeeManager.SettlementType settlementType_)
    {
        return SETTLEMENT_TYPE;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract EntranceRateDirectFee is EntranceRateFeeBase {
    constructor(address _feeManager)
        public
        EntranceRateFeeBase(_feeManager, IFeeManager.SettlementType.Direct)
    {}

    function identifier() external pure override returns (string memory identifier_) {
        return "ENTRANCE_RATE_DIRECT";
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract EntranceRateBurnFee is EntranceRateFeeBase {
    constructor(address _feeManager)
        public
        EntranceRateFeeBase(_feeManager, IFeeManager.SettlementType.Burn)
    {}

    function identifier() external pure override returns (string memory identifier_) {
        return "ENTRANCE_RATE_BURN";
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract MockChaiPriceSource {
    using SafeMath for uint256;

    uint256 private chiStored = 10**27;
    uint256 private rhoStored = now;

    function drip() external returns (uint256) {
        require(now >= rhoStored, "drip: invalid now");
        rhoStored = now;
        chiStored = chiStored.mul(99).div(100);
        return chi();
    }


    function chi() public view returns (uint256) {
        return chiStored;
    }

    function rho() public view returns (uint256) {
        return rhoStored;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract AggregatedDerivativePriceFeed is IAggregatedDerivativePriceFeed, DispatcherOwnerMixin {
    event DerivativeAdded(address indexed derivative, address priceFeed);

    event DerivativeRemoved(address indexed derivative);

    event DerivativeUpdated(
        address indexed derivative,
        address prevPriceFeed,
        address nextPriceFeed
    );

    mapping(address => address) private derivativeToPriceFeed;

    constructor(
        address _dispatcher,
        address[] memory _derivatives,
        address[] memory _priceFeeds
    ) public DispatcherOwnerMixin(_dispatcher) {
        if (_derivatives.length > 0) {
            __addDerivatives(_derivatives, _priceFeeds);
        }
    }

    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        address derivativePriceFeed = derivativeToPriceFeed[_derivative];
        require(
            derivativePriceFeed != address(0),
            "calcUnderlyingValues: _derivative is not supported"
        );

        return
            IDerivativePriceFeed(derivativePriceFeed).calcUnderlyingValues(
                _derivative,
                _derivativeAmount
            );
    }

    function isSupportedAsset(address _asset) external view override returns (bool isSupported_) {
        return derivativeToPriceFeed[_asset] != address(0);
    }


    function addDerivatives(address[] calldata _derivatives, address[] calldata _priceFeeds)
        external
        onlyDispatcherOwner
    {
        require(_derivatives.length > 0, "addDerivatives: _derivatives cannot be empty");

        __addDerivatives(_derivatives, _priceFeeds);
    }

    function removeDerivatives(address[] calldata _derivatives) external onlyDispatcherOwner {
        require(_derivatives.length > 0, "removeDerivatives: _derivatives cannot be empty");

        for (uint256 i = 0; i < _derivatives.length; i++) {
            require(
                derivativeToPriceFeed[_derivatives[i]] != address(0),
                "removeDerivatives: Derivative not yet added"
            );

            delete derivativeToPriceFeed[_derivatives[i]];

            emit DerivativeRemoved(_derivatives[i]);
        }
    }

    function updateDerivatives(address[] calldata _derivatives, address[] calldata _priceFeeds)
        external
        onlyDispatcherOwner
    {
        require(_derivatives.length > 0, "updateDerivatives: _derivatives cannot be empty");
        require(
            _derivatives.length == _priceFeeds.length,
            "updateDerivatives: Unequal _derivatives and _priceFeeds array lengths"
        );

        for (uint256 i = 0; i < _derivatives.length; i++) {
            address prevPriceFeed = derivativeToPriceFeed[_derivatives[i]];

            require(prevPriceFeed != address(0), "updateDerivatives: Derivative not yet added");
            require(_priceFeeds[i] != prevPriceFeed, "updateDerivatives: Value already set");

            __validateDerivativePriceFeed(_derivatives[i], _priceFeeds[i]);

            derivativeToPriceFeed[_derivatives[i]] = _priceFeeds[i];

            emit DerivativeUpdated(_derivatives[i], prevPriceFeed, _priceFeeds[i]);
        }
    }

    function __addDerivatives(address[] memory _derivatives, address[] memory _priceFeeds)
        private
    {
        require(
            _derivatives.length == _priceFeeds.length,
            "__addDerivatives: Unequal _derivatives and _priceFeeds array lengths"
        );

        for (uint256 i = 0; i < _derivatives.length; i++) {
            require(
                derivativeToPriceFeed[_derivatives[i]] == address(0),
                "__addDerivatives: Already added"
            );

            __validateDerivativePriceFeed(_derivatives[i], _priceFeeds[i]);

            derivativeToPriceFeed[_derivatives[i]] = _priceFeeds[i];

            emit DerivativeAdded(_derivatives[i], _priceFeeds[i]);
        }
    }

    function __validateDerivativePriceFeed(address _derivative, address _priceFeed) private view {
        require(_derivative != address(0), "__validateDerivativePriceFeed: Empty _derivative");
        require(_priceFeed != address(0), "__validateDerivativePriceFeed: Empty _priceFeed");
        require(
            IDerivativePriceFeed(_priceFeed).isSupportedAsset(_derivative),
            "__validateDerivativePriceFeed: Unsupported derivative"
        );
    }


    function getPriceFeedForDerivative(address _derivative)
        external
        view
        override
        returns (address priceFeed_)
    {
        return derivativeToPriceFeed[_derivative];
    }
}