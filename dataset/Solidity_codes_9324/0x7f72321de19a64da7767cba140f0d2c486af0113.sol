





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




interface ISetValuer {

    function calculateSetTokenValuation(ISetToken _setToken, address _quoteAsset) external view returns (uint256);

}


interface IPriceOracle {



    function getPrice(address _assetOne, address _assetTwo) external view returns (uint256);

    function masterQuoteAsset() external view returns (address);

}


interface IIntegrationRegistry {

    function addIntegration(address _module, string memory _id, address _wrapper) external;

    function getIntegrationAdapter(address _module, string memory _id) external view returns(address);

    function getIntegrationAdapterWithHash(address _module, bytes32 _id) external view returns(address);

    function isValidIntegration(address _module, string memory _id) external view returns(bool);

}



interface IModule {

    function removeModule() external;

}




library ExplicitERC20 {

    using SafeMath for uint256;

    function transferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _quantity
    )
        internal
    {

        if (_quantity > 0) {
            uint256 existingBalance = _token.balanceOf(_to);

            SafeERC20.safeTransferFrom(
                _token,
                _from,
                _to,
                _quantity
            );

            uint256 newBalance = _token.balanceOf(_to);

            require(
                newBalance == existingBalance.add(_quantity),
                "Invalid post transfer balance"
            );
        }
    }
}





library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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





abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





library ResourceIdentifier {


    uint256 constant internal INTEGRATION_REGISTRY_RESOURCE_ID = 0;
    uint256 constant internal PRICE_ORACLE_RESOURCE_ID = 1;
    uint256 constant internal SET_VALUER_RESOURCE_ID = 2;


    function getIntegrationRegistry(IController _controller) internal view returns (IIntegrationRegistry) {

        return IIntegrationRegistry(_controller.resourceId(INTEGRATION_REGISTRY_RESOURCE_ID));
    }

    function getPriceOracle(IController _controller) internal view returns (IPriceOracle) {

        return IPriceOracle(_controller.resourceId(PRICE_ORACLE_RESOURCE_ID));
    }

    function getSetValuer(IController _controller) internal view returns (ISetValuer) {

        return ISetValuer(_controller.resourceId(SET_VALUER_RESOURCE_ID));
    }
}


// pragma experimental ABIEncoderV2;



library PreciseUnitMath {

    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 constant internal PRECISE_UNIT = 10 ** 18;
    int256 constant internal PRECISE_UNIT_INT = 10 ** 18;

    uint256 constant internal MAX_UINT_256 = type(uint256).max;
    int256 constant internal MAX_INT_256 = type(int256).max;
    int256 constant internal MIN_INT_256 = type(int256).min;

    function preciseUnit() internal pure returns (uint256) {

        return PRECISE_UNIT;
    }

    function preciseUnitInt() internal pure returns (int256) {

        return PRECISE_UNIT_INT;
    }

    function maxUint256() internal pure returns (uint256) {

        return MAX_UINT_256;
    }

    function maxInt256() internal pure returns (int256) {

        return MAX_INT_256;
    }

    function minInt256() internal pure returns (int256) {

        return MIN_INT_256;
    }

    function preciseMul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a.mul(b).div(PRECISE_UNIT);
    }

    function preciseMul(int256 a, int256 b) internal pure returns (int256) {

        return a.mul(b).div(PRECISE_UNIT_INT);
    }

    function preciseMulCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0 || b == 0) {
            return 0;
        }
        return a.mul(b).sub(1).div(PRECISE_UNIT).add(1);
    }

    function preciseDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a.mul(PRECISE_UNIT).div(b);
    }


    function preciseDiv(int256 a, int256 b) internal pure returns (int256) {

        return a.mul(PRECISE_UNIT_INT).div(b);
    }

    function preciseDivCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "Cant divide by 0");

        return a > 0 ? a.mul(PRECISE_UNIT).sub(1).div(b).add(1) : 0;
    }

    function divDown(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "Cant divide by 0");
        require(a != MIN_INT_256 || b != -1, "Invalid input");

        int256 result = a.div(b);
        if (a ^ b < 0 && a % b != 0) {
            result -= 1;
        }

        return result;
    }

    function conservativePreciseMul(int256 a, int256 b) internal pure returns (int256) {

        return divDown(a.mul(b), PRECISE_UNIT_INT);
    }

    function conservativePreciseDiv(int256 a, int256 b) internal pure returns (int256) {

        return divDown(a.mul(PRECISE_UNIT_INT), b);
    }
}


// pragma experimental "ABIEncoderV2";



library Position {

    using SafeCast for uint256;
    using SafeMath for uint256;
    using SafeCast for int256;
    using SignedSafeMath for int256;
    using PreciseUnitMath for uint256;


    function hasDefaultPosition(ISetToken _setToken, address _component) internal view returns(bool) {

        return _setToken.getDefaultPositionRealUnit(_component) > 0;
    }

    function hasExternalPosition(ISetToken _setToken, address _component) internal view returns(bool) {

        return _setToken.getExternalPositionModules(_component).length > 0;
    }
    
    function hasSufficientDefaultUnits(ISetToken _setToken, address _component, uint256 _unit) internal view returns(bool) {

        return _setToken.getDefaultPositionRealUnit(_component) >= _unit.toInt256();
    }

    function hasSufficientExternalUnits(
        ISetToken _setToken,
        address _component,
        address _positionModule,
        uint256 _unit
    )
        internal
        view
        returns(bool)
    {

       return _setToken.getExternalPositionRealUnit(_component, _positionModule) >= _unit.toInt256();    
    }

    function editDefaultPosition(ISetToken _setToken, address _component, uint256 _newUnit) internal {

        bool isPositionFound = hasDefaultPosition(_setToken, _component);
        if (!isPositionFound && _newUnit > 0) {
            if (!hasExternalPosition(_setToken, _component)) {
                _setToken.addComponent(_component);
            }
        } else if (isPositionFound && _newUnit == 0) {
            if (!hasExternalPosition(_setToken, _component)) {
                _setToken.removeComponent(_component);
            }
        }

        _setToken.editDefaultPositionUnit(_component, _newUnit.toInt256());
    }

    function editExternalPosition(
        ISetToken _setToken,
        address _component,
        address _module,
        int256 _newUnit,
        bytes memory _data
    )
        internal
    {

        if (!_setToken.isComponent(_component)) {
            _setToken.addComponent(_component);
            addExternalPosition(_setToken, _component, _module, _newUnit, _data);
        } else if (!_setToken.isExternalPositionModule(_component, _module)) {
            addExternalPosition(_setToken, _component, _module, _newUnit, _data);
        } else if (_newUnit != 0) {
            _setToken.editExternalPositionUnit(_component, _module, _newUnit);
        } else {
            if (_setToken.getDefaultPositionRealUnit(_component) == 0 && _setToken.getExternalPositionModules(_component).length == 1) {
                _setToken.removeComponent(_component);
            }
            _setToken.removeExternalPositionModule(_component, _module);
        }
    }

    function addExternalPosition(
        ISetToken _setToken,
        address _component,
        address _module,
        int256 _newUnit,
        bytes memory _data
    )
        internal
    {

        _setToken.addExternalPositionModule(_component, _module);
        _setToken.editExternalPositionUnit(_component, _module, _newUnit);
        _setToken.editExternalPositionData(_component, _module, _data);
    }

    function getDefaultTotalNotional(uint256 _setTokenSupply, uint256 _positionUnit) internal pure returns (uint256) {

        return _setTokenSupply.preciseMul(_positionUnit);
    }

    function getDefaultPositionUnit(uint256 _setTokenSupply, uint256 _totalNotional) internal pure returns (uint256) {

        return _totalNotional.preciseDiv(_setTokenSupply);
    }

    function getDefaultTrackedBalance(ISetToken _setToken, address _component) internal view returns(uint256) {

        int256 positionUnit = _setToken.getDefaultPositionRealUnit(_component); 
        return _setToken.totalSupply().preciseMul(positionUnit.toUint256());
    }

    function calculateAndEditDefaultPosition(
        ISetToken _setToken,
        address _component,
        uint256 _setTotalSupply,
        uint256 _componentPreviousBalance
    )
        internal
        returns(uint256, uint256, uint256)
    {

        uint256 currentBalance = IERC20(_component).balanceOf(address(_setToken));
        uint256 positionUnit = _setToken.getDefaultPositionRealUnit(_component).toUint256();

        uint256 newTokenUnit = calculateDefaultEditPositionUnit(
            _setTotalSupply,
            _componentPreviousBalance,
            currentBalance,
            positionUnit
        );

        editDefaultPosition(_setToken, _component, newTokenUnit);

        return (currentBalance, positionUnit, newTokenUnit);
    }

    function calculateDefaultEditPositionUnit(
        uint256 _setTokenSupply,
        uint256 _preTotalNotional,
        uint256 _postTotalNotional,
        uint256 _prePositionUnit
    )
        internal
        pure
        returns (uint256)
    {

        if (_preTotalNotional >= _postTotalNotional) {
            uint256 unitsToSub = _preTotalNotional.sub(_postTotalNotional).preciseDivCeil(_setTokenSupply);
            return _prePositionUnit.sub(unitsToSub);
        } else {
            uint256 unitsToAdd = _postTotalNotional.sub(_preTotalNotional).preciseDiv(_setTokenSupply);
            return _prePositionUnit.add(unitsToAdd);
        }
    }
}






abstract contract ModuleBase is IModule {
    using PreciseUnitMath for uint256;
    using Invoke for ISetToken;
    using ResourceIdentifier for IController;


    IController public controller;


    modifier onlyManagerAndValidSet(ISetToken _setToken) { 
        require(isSetManager(_setToken, msg.sender), "Must be the SetToken manager");
        require(isSetValidAndInitialized(_setToken), "Must be a valid and initialized SetToken");
        _;
    }

    modifier onlySetManager(ISetToken _setToken, address _caller) {
        require(isSetManager(_setToken, _caller), "Must be the SetToken manager");
        _;
    }

    modifier onlyValidAndInitializedSet(ISetToken _setToken) {
        require(isSetValidAndInitialized(_setToken), "Must be a valid and initialized SetToken");
        _;
    }

    modifier onlyModule(ISetToken _setToken) {
        require(
            _setToken.moduleStates(msg.sender) == ISetToken.ModuleState.INITIALIZED,
            "Only the module can call"
        );

        require(
            controller.isModule(msg.sender),
            "Module must be enabled on controller"
        );
        _;
    }

    modifier onlyValidAndPendingSet(ISetToken _setToken) {
        require(controller.isSet(address(_setToken)), "Must be controller-enabled SetToken");
        require(isSetPendingInitialization(_setToken), "Must be pending initialization");        
        _;
    }


    constructor(IController _controller) public {
        controller = _controller;
    }


    function transferFrom(IERC20 _token, address _from, address _to, uint256 _quantity) internal {
        ExplicitERC20.transferFrom(_token, _from, _to, _quantity);
    }

    function getAndValidateAdapter(string memory _integrationName) internal view returns(address) { 
        bytes32 integrationHash = getNameHash(_integrationName);
        return getAndValidateAdapterWithHash(integrationHash);
    }

    function getAndValidateAdapterWithHash(bytes32 _integrationHash) internal view returns(address) { 
        address adapter = controller.getIntegrationRegistry().getIntegrationAdapterWithHash(
            address(this),
            _integrationHash
        );

        require(adapter != address(0), "Must be valid adapter"); 
        return adapter;
    }

    function getModuleFee(uint256 _feeIndex, uint256 _quantity) internal view returns(uint256) {
        uint256 feePercentage = controller.getModuleFee(address(this), _feeIndex);
        return _quantity.preciseMul(feePercentage);
    }

    function payProtocolFeeFromSetToken(ISetToken _setToken, address _token, uint256 _feeQuantity) internal {
        if (_feeQuantity > 0) {
            _setToken.strictInvokeTransfer(_token, controller.feeRecipient(), _feeQuantity); 
        }
    }

    function isSetPendingInitialization(ISetToken _setToken) internal view returns(bool) {
        return _setToken.isPendingModule(address(this));
    }

    function isSetManager(ISetToken _setToken, address _toCheck) internal view returns(bool) {
        return _setToken.manager() == _toCheck;
    }

    function isSetValidAndInitialized(ISetToken _setToken) internal view returns(bool) {
        return controller.isSet(address(_setToken)) &&
            _setToken.isInitializedModule(address(this));
    }

    function getNameHash(string memory _name) internal pure returns(bytes32) {
        return keccak256(bytes(_name));
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





interface IWETH is IERC20{

    function deposit()
        external
        payable;


    function withdraw(
        uint256 wad
    )
        external;

}



interface ISetToken is IERC20 {



    enum ModuleState {
        NONE,
        PENDING,
        INITIALIZED
    }

    struct Position {
        address component;
        address module;
        int256 unit;
        uint8 positionState;
        bytes data;
    }

    struct ComponentPosition {
      int256 virtualUnit;
      address[] externalPositionModules;
      mapping(address => ExternalPosition) externalPositions;
    }

    struct ExternalPosition {
      int256 virtualUnit;
      bytes data;
    }


    
    function addComponent(address _component) external;

    function removeComponent(address _component) external;

    function editDefaultPositionUnit(address _component, int256 _realUnit) external;

    function addExternalPositionModule(address _component, address _positionModule) external;

    function removeExternalPositionModule(address _component, address _positionModule) external;

    function editExternalPositionUnit(address _component, address _positionModule, int256 _realUnit) external;

    function editExternalPositionData(address _component, address _positionModule, bytes calldata _data) external;


    function invoke(address _target, uint256 _value, bytes calldata _data) external returns(bytes memory);


    function editPositionMultiplier(int256 _newMultiplier) external;


    function mint(address _account, uint256 _quantity) external;

    function burn(address _account, uint256 _quantity) external;


    function lock() external;

    function unlock() external;


    function addModule(address _module) external;

    function removeModule(address _module) external;

    function initializeModule() external;


    function setManager(address _manager) external;


    function manager() external view returns (address);

    function moduleStates(address _module) external view returns (ModuleState);

    function getModules() external view returns (address[] memory);

    
    function getDefaultPositionRealUnit(address _component) external view returns(int256);

    function getExternalPositionRealUnit(address _component, address _positionModule) external view returns(int256);

    function getComponents() external view returns(address[] memory);

    function getExternalPositionModules(address _component) external view returns(address[] memory);

    function getExternalPositionData(address _component, address _positionModule) external view returns(bytes memory);

    function isExternalPositionModule(address _component, address _module) external view returns(bool);

    function isComponent(address _component) external view returns(bool);

    
    function positionMultiplier() external view returns (int256);

    function getPositions() external view returns (Position[] memory);

    function getTotalComponentRealUnits(address _component) external view returns(int256);


    function isInitializedModule(address _module) external view returns(bool);

    function isPendingModule(address _module) external view returns(bool);

    function isLocked() external view returns (bool);

}






library Invoke {

    using SafeMath for uint256;


    function invokeApprove(
        ISetToken _setToken,
        address _token,
        address _spender,
        uint256 _quantity
    )
        internal
    {

        bytes memory callData = abi.encodeWithSignature("approve(address,uint256)", _spender, _quantity);
        _setToken.invoke(_token, 0, callData);
    }

    function invokeTransfer(
        ISetToken _setToken,
        address _token,
        address _to,
        uint256 _quantity
    )
        internal
    {

        if (_quantity > 0) {
            bytes memory callData = abi.encodeWithSignature("transfer(address,uint256)", _to, _quantity);
            _setToken.invoke(_token, 0, callData);
        }
    }

    function strictInvokeTransfer(
        ISetToken _setToken,
        address _token,
        address _to,
        uint256 _quantity
    )
        internal
    {

        if (_quantity > 0) {
            uint256 existingBalance = IERC20(_token).balanceOf(address(_setToken));

            Invoke.invokeTransfer(_setToken, _token, _to, _quantity);

            uint256 newBalance = IERC20(_token).balanceOf(address(_setToken));

            require(
                newBalance == existingBalance.sub(_quantity),
                "Invalid post transfer balance"
            );
        }
    }

    function invokeUnwrapWETH(ISetToken _setToken, address _weth, uint256 _quantity) internal {

        bytes memory callData = abi.encodeWithSignature("withdraw(uint256)", _quantity);
        _setToken.invoke(_weth, 0, callData);
    }

    function invokeWrapWETH(ISetToken _setToken, address _weth, uint256 _quantity) internal {

        bytes memory callData = abi.encodeWithSignature("deposit()");
        _setToken.invoke(_weth, _quantity, callData);
    }
}



interface INAVIssuanceHook {

    function invokePreIssueHook(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _reserveAssetQuantity,
        address _sender,
        address _to
    )
        external;


    function invokePreRedeemHook(
        ISetToken _setToken,
        uint256 _redeemQuantity,
        address _sender,
        address _to
    )
        external;

}


interface IController {

    function addSet(address _setToken) external;

    function feeRecipient() external view returns(address);

    function getModuleFee(address _module, uint256 _feeType) external view returns(uint256);

    function isModule(address _module) external view returns(bool);

    function isSet(address _setToken) external view returns(bool);

    function isSystemContract(address _contractAddress) external view returns (bool);

    function resourceId(uint256 _id) external view returns(address);

}



library AddressArrayUtils {


    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {

        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (uint256(-1), false);
    }

    function contains(address[] memory A, address a) internal pure returns (bool) {

        (, bool isIn) = indexOf(A, a);
        return isIn;
    }

    function hasDuplicate(address[] memory A) internal pure returns(bool) {

        require(A.length > 0, "A is empty");

        for (uint256 i = 0; i < A.length - 1; i++) {
            address current = A[i];
            for (uint256 j = i + 1; j < A.length; j++) {
                if (current == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {

        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert("Address not in array.");
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {

        uint256 length = A.length;
        require(index < A.length, "Index must be < A length");
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }
}




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






library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}





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

}


pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";




contract NavIssuanceModule is ModuleBase, ReentrancyGuard {
    using AddressArrayUtils for address[];
    using Invoke for ISetToken;
    using Position for ISetToken;
    using PreciseUnitMath for uint256;
    using PreciseUnitMath for int256;
    using ResourceIdentifier for IController;
    using SafeMath for uint256;
    using SafeCast for int256;
    using SafeCast for uint256;
    using SignedSafeMath for int256;


    event SetTokenNAVIssued(
        address indexed _setToken,
        address _issuer,
        address _to,
        address _reserveAsset,
        address _hookContract,
        uint256 _setTokenQuantity,
        uint256 _managerFee,
        uint256 _premium
    );

    event SetTokenNAVRedeemed(
        address indexed _setToken,
        address _redeemer,
        address _to,
        address _reserveAsset,
        address _hookContract,
        uint256 _setTokenQuantity,
        uint256 _managerFee,
        uint256 _premium
    );


    struct NAVIssuanceSettings {
        INAVIssuanceHook managerIssuanceHook;      // Issuance hook configurations
        INAVIssuanceHook managerRedemptionHook;    // Redemption hook configurations
        address[] reserveAssets;                       // Allowed reserve assets - Must have a price enabled with the price oracle
        address feeRecipient;                          // Manager fee recipient
        uint256[2] managerFees;                        // Manager fees. 0 index is issue and 1 index is redeem fee (0.01% = 1e14, 1% = 1e16)
        uint256 maxManagerFee;                         // Maximum fee manager is allowed to set for issue and redeem
        uint256 premiumPercentage;                     // Premium percentage (0.01% = 1e14, 1% = 1e16). This premium is a buffer around oracle
        uint256 maxPremiumPercentage;                  // Maximum premium percentage manager is allowed to set (configured by manager)
        uint256 minSetTokenSupply;                     // Minimum SetToken supply required for issuance and redemption 
    }

    struct ActionInfo {
        uint256 preFeeReserveQuantity;                 // Reserve value before fees; During issuance, represents raw quantity
        uint256 protocolFees;                          // Total protocol fees (direct + manager revenue share)
        uint256 managerFee;                            // Total manager fee paid in reserve asset
        uint256 netFlowQuantity;                       // When issuing, quantity of reserve asset sent to SetToken
        uint256 setTokenQuantity;                      // When issuing, quantity of SetTokens minted to mintee
        uint256 previousSetTokenSupply;                // SetToken supply prior to issue/redeem action
        uint256 newSetTokenSupply;                     // SetToken supply after issue/redeem action
        int256 newPositionMultiplier;                  // SetToken position multiplier after issue/redeem
        uint256 newReservePositionUnit;                // SetToken reserve asset position unit after issue/redeem
    }


    IWETH public weth;

    mapping(ISetToken => NAVIssuanceSettings) public navIssuanceSettings;
    
    mapping(ISetToken => mapping(address => bool)) public isReserveAsset;


    uint256 constant internal MANAGER_ISSUE_FEE_INDEX = 0;

    uint256 constant internal MANAGER_REDEEM_FEE_INDEX = 1;

    uint256 constant internal PROTOCOL_ISSUE_MANAGER_REVENUE_SHARE_FEE_INDEX = 0;

    uint256 constant internal PROTOCOL_REDEEM_MANAGER_REVENUE_SHARE_FEE_INDEX = 1;

    uint256 constant internal PROTOCOL_ISSUE_DIRECT_FEE_INDEX = 2;

    uint256 constant internal PROTOCOL_REDEEM_DIRECT_FEE_INDEX = 3;


    constructor(IController _controller, IWETH _weth) public ModuleBase(_controller) {
        weth = _weth;
    }

    
    function issue(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _reserveAssetQuantity,
        uint256 _minSetTokenReceiveQuantity,
        address _to
    ) 
        external
        nonReentrant
        onlyValidAndInitializedSet(_setToken)
    {
        _validateCommon(_setToken, _reserveAsset, _reserveAssetQuantity);
        
        _callPreIssueHooks(_setToken, _reserveAsset, _reserveAssetQuantity, msg.sender, _to);

        ActionInfo memory issueInfo = _getIssuanceInfo(_setToken, _reserveAsset, _reserveAssetQuantity);

        _validateIssuanceInfo(_setToken, _minSetTokenReceiveQuantity, issueInfo);

        _transferCollateralAndHandleFees(_setToken, IERC20(_reserveAsset), issueInfo);

        _handleIssueStateUpdates(_setToken, _reserveAsset, _to, issueInfo);
    }

    function issueWithEther(
        ISetToken _setToken,
        uint256 _minSetTokenReceiveQuantity,
        address _to
    ) 
        external
        payable
        nonReentrant
        onlyValidAndInitializedSet(_setToken)
    {
        weth.deposit{ value: msg.value }();

        _validateCommon(_setToken, address(weth), msg.value);
        
        _callPreIssueHooks(_setToken, address(weth), msg.value, msg.sender, _to);

        ActionInfo memory issueInfo = _getIssuanceInfo(_setToken, address(weth), msg.value);

        _validateIssuanceInfo(_setToken, _minSetTokenReceiveQuantity, issueInfo);

        _transferWETHAndHandleFees(_setToken, issueInfo);

        _handleIssueStateUpdates(_setToken, address(weth), _to, issueInfo);
    }

    function redeem(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _setTokenQuantity,
        uint256 _minReserveReceiveQuantity,
        address _to
    ) 
        external
        nonReentrant
        onlyValidAndInitializedSet(_setToken)
    {
        _validateCommon(_setToken, _reserveAsset, _setTokenQuantity);

        _callPreRedeemHooks(_setToken, _setTokenQuantity, msg.sender, _to);

        ActionInfo memory redeemInfo = _getRedemptionInfo(_setToken, _reserveAsset, _setTokenQuantity);

        _validateRedemptionInfo(_setToken, _minReserveReceiveQuantity, _setTokenQuantity, redeemInfo);

        _setToken.burn(msg.sender, _setTokenQuantity);

        _setToken.strictInvokeTransfer(
            _reserveAsset,
            _to,
            redeemInfo.netFlowQuantity
        );

        _handleRedemptionFees(_setToken, _reserveAsset, redeemInfo);

        _handleRedeemStateUpdates(_setToken, _reserveAsset, _to, redeemInfo);
    }

    function redeemIntoEther(
        ISetToken _setToken,
        uint256 _setTokenQuantity,
        uint256 _minReserveReceiveQuantity,
        address payable _to
    ) 
        external
        nonReentrant
        onlyValidAndInitializedSet(_setToken)
    {
        _validateCommon(_setToken, address(weth), _setTokenQuantity);

        _callPreRedeemHooks(_setToken, _setTokenQuantity, msg.sender, _to);

        ActionInfo memory redeemInfo = _getRedemptionInfo(_setToken, address(weth), _setTokenQuantity);

        _validateRedemptionInfo(_setToken, _minReserveReceiveQuantity, _setTokenQuantity, redeemInfo);

        _setToken.burn(msg.sender, _setTokenQuantity);

        _setToken.strictInvokeTransfer(
            address(weth),
            address(this),
            redeemInfo.netFlowQuantity
        );

        weth.withdraw(redeemInfo.netFlowQuantity);
        
        _to.transfer(redeemInfo.netFlowQuantity);

        _handleRedemptionFees(_setToken, address(weth), redeemInfo);

        _handleRedeemStateUpdates(_setToken, address(weth), _to, redeemInfo);
    }

    function addReserveAsset(ISetToken _setToken, address _reserveAsset) external onlyManagerAndValidSet(_setToken) {
        require(!isReserveAsset[_setToken][_reserveAsset], "Reserve asset already exists");
        
        navIssuanceSettings[_setToken].reserveAssets.push(_reserveAsset);
        isReserveAsset[_setToken][_reserveAsset] = true;
    }

    function removeReserveAsset(ISetToken _setToken, address _reserveAsset) external onlyManagerAndValidSet(_setToken) {
        require(isReserveAsset[_setToken][_reserveAsset], "Reserve asset does not exist");

        navIssuanceSettings[_setToken].reserveAssets = navIssuanceSettings[_setToken].reserveAssets.remove(_reserveAsset);
        delete isReserveAsset[_setToken][_reserveAsset];
    }

    function editPremium(ISetToken _setToken, uint256 _premiumPercentage) external onlyManagerAndValidSet(_setToken) {
        require(_premiumPercentage < navIssuanceSettings[_setToken].maxPremiumPercentage, "Premium must be less than maximum allowed");
        
        navIssuanceSettings[_setToken].premiumPercentage = _premiumPercentage;
    }

    function editManagerFee(
        ISetToken _setToken,
        uint256 _managerFeePercentage,
        uint256 _managerFeeIndex
    )
        external
        onlyManagerAndValidSet(_setToken)
    {
        require(_managerFeePercentage < navIssuanceSettings[_setToken].maxManagerFee, "Manager fee must be less than maximum allowed");
        
        navIssuanceSettings[_setToken].managerFees[_managerFeeIndex] = _managerFeePercentage;
    }

    function editFeeRecipient(ISetToken _setToken, address _managerFeeRecipient) external onlyManagerAndValidSet(_setToken) {
        require(_managerFeeRecipient != address(0), "Fee recipient must not be 0 address");
        
        navIssuanceSettings[_setToken].feeRecipient = _managerFeeRecipient;
    }

    function initialize(
        ISetToken _setToken,
        NAVIssuanceSettings memory _navIssuanceSettings
    )
        external
        onlySetManager(_setToken, msg.sender)
        onlyValidAndPendingSet(_setToken)
    {
        require(_navIssuanceSettings.reserveAssets.length > 0, "Reserve assets must be greater than 0");
        require(_navIssuanceSettings.maxManagerFee < PreciseUnitMath.preciseUnit(), "Max manager fee must be less than 100%");
        require(_navIssuanceSettings.maxPremiumPercentage < PreciseUnitMath.preciseUnit(), "Max premium percentage must be less than 100%");
        require(_navIssuanceSettings.managerFees[0] <= _navIssuanceSettings.maxManagerFee, "Manager issue fee must be less than max");
        require(_navIssuanceSettings.managerFees[1] <= _navIssuanceSettings.maxManagerFee, "Manager redeem fee must be less than max");
        require(_navIssuanceSettings.premiumPercentage <= _navIssuanceSettings.maxPremiumPercentage, "Premium must be less than max");
        require(_navIssuanceSettings.feeRecipient != address(0), "Fee Recipient must be non-zero address.");
        require(_navIssuanceSettings.minSetTokenSupply > 0, "Min SetToken supply must be greater than 0");

        for (uint256 i = 0; i < _navIssuanceSettings.reserveAssets.length; i++) {
            isReserveAsset[_setToken][_navIssuanceSettings.reserveAssets[i]] = true;
        }

        navIssuanceSettings[_setToken] = _navIssuanceSettings;

        _setToken.initializeModule();
    }

    function removeModule() external override {
        ISetToken setToken = ISetToken(msg.sender);
        for (uint256 i = 0; i < navIssuanceSettings[setToken].reserveAssets.length; i++) {
            delete isReserveAsset[setToken][navIssuanceSettings[setToken].reserveAssets[i]];
        }
        
        delete navIssuanceSettings[setToken];
    }

    receive() external payable {}


    function getReserveAssets(ISetToken _setToken) external view returns (address[] memory) {
        return navIssuanceSettings[_setToken].reserveAssets;
    }

    function isValidReserveAsset(ISetToken _setToken, address _reserveAsset) external view returns (bool) {
        return isReserveAsset[_setToken][_reserveAsset];
    }

    function getIssuePremium(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _reserveAssetQuantity
    )
        external
        view
        returns (uint256)
    {
        return _getIssuePremium(_setToken, _reserveAsset, _reserveAssetQuantity);
    }

    function getRedeemPremium(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _setTokenQuantity
    )
        external
        view
        returns (uint256)
    {
        return _getRedeemPremium(_setToken, _reserveAsset, _setTokenQuantity);
    }

    function getManagerFee(ISetToken _setToken, uint256 _managerFeeIndex) external view returns (uint256) {
        return navIssuanceSettings[_setToken].managerFees[_managerFeeIndex];
    }

    function getExpectedSetTokenIssueQuantity(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _reserveAssetQuantity
    )
        external
        view
        returns (uint256)
    {
        (,, uint256 netReserveFlow) = _getFees(
            _setToken,
            _reserveAssetQuantity,
            PROTOCOL_ISSUE_MANAGER_REVENUE_SHARE_FEE_INDEX,
            PROTOCOL_ISSUE_DIRECT_FEE_INDEX,
            MANAGER_ISSUE_FEE_INDEX
        );

        uint256 setTotalSupply = _setToken.totalSupply();

        return _getSetTokenMintQuantity(
            _setToken,
            _reserveAsset,
            netReserveFlow,
            setTotalSupply
        );
    }

    function getExpectedReserveRedeemQuantity(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _setTokenQuantity
    )
        external
        view
        returns (uint256)
    {
        uint256 preFeeReserveQuantity = _getRedeemReserveQuantity(_setToken, _reserveAsset, _setTokenQuantity);

        (,, uint256 netReserveFlows) = _getFees(
            _setToken,
            preFeeReserveQuantity,
            PROTOCOL_REDEEM_MANAGER_REVENUE_SHARE_FEE_INDEX,
            PROTOCOL_REDEEM_DIRECT_FEE_INDEX,
            MANAGER_REDEEM_FEE_INDEX
        );

        return netReserveFlows;
    }

    function isIssueValid(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _reserveAssetQuantity
    )
        external
        view
        returns (bool)
    {
        uint256 setTotalSupply = _setToken.totalSupply();

        if (
            _reserveAssetQuantity == 0
            || !isReserveAsset[_setToken][_reserveAsset]
            || setTotalSupply < navIssuanceSettings[_setToken].minSetTokenSupply
        ) {
            return false;
        }

        return true;
    }

    function isRedeemValid(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _setTokenQuantity
    )
        external
        view
        returns (bool)
    {
        uint256 setTotalSupply = _setToken.totalSupply();

        if (
            _setTokenQuantity == 0
            || !isReserveAsset[_setToken][_reserveAsset]
            || setTotalSupply < navIssuanceSettings[_setToken].minSetTokenSupply.add(_setTokenQuantity)
        ) {
            return false;
        }

        uint256 totalRedeemValue =_getRedeemReserveQuantity(_setToken, _reserveAsset, _setTokenQuantity);

        (,, uint256 expectedRedeemQuantity) = _getFees(
            _setToken,
            totalRedeemValue,
            PROTOCOL_REDEEM_MANAGER_REVENUE_SHARE_FEE_INDEX,
            PROTOCOL_REDEEM_DIRECT_FEE_INDEX,
            MANAGER_REDEEM_FEE_INDEX
        );

        uint256 existingUnit = _setToken.getDefaultPositionRealUnit(_reserveAsset).toUint256();

        if (existingUnit.preciseMul(setTotalSupply) < expectedRedeemQuantity) {
            return false;
        }
        
        return true;
    }


    function _validateCommon(ISetToken _setToken, address _reserveAsset, uint256 _quantity) internal view {
        require(_quantity > 0, "Quantity must be > 0");
        require(isReserveAsset[_setToken][_reserveAsset], "Must be valid reserve asset");
    }

    function _validateIssuanceInfo(ISetToken _setToken, uint256 _minSetTokenReceiveQuantity, ActionInfo memory _issueInfo) internal view {
        require(
            _issueInfo.previousSetTokenSupply >= navIssuanceSettings[_setToken].minSetTokenSupply,
            "Supply must be greater than minimum to enable issuance"
        );

        require(_issueInfo.setTokenQuantity >= _minSetTokenReceiveQuantity, "Must be greater than min SetToken");
    }

    function _validateRedemptionInfo(
        ISetToken _setToken,
        uint256 _minReserveReceiveQuantity,
        uint256 _setTokenQuantity,
        ActionInfo memory _redeemInfo
    )
        internal
        view
    {
        require(
            _redeemInfo.newSetTokenSupply >= navIssuanceSettings[_setToken].minSetTokenSupply,
            "Supply must be greater than minimum to enable redemption"
        );

        require(_redeemInfo.netFlowQuantity >= _minReserveReceiveQuantity, "Must be greater than min receive reserve quantity");
    }

    function _getIssuanceInfo(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _reserveAssetQuantity
    )
        internal
        view
        returns (ActionInfo memory)
    {
        ActionInfo memory issueInfo;

        issueInfo.previousSetTokenSupply = _setToken.totalSupply();

        issueInfo.preFeeReserveQuantity = _reserveAssetQuantity;

        (issueInfo.protocolFees, issueInfo.managerFee, issueInfo.netFlowQuantity) = _getFees(
            _setToken,
            issueInfo.preFeeReserveQuantity,
            PROTOCOL_ISSUE_MANAGER_REVENUE_SHARE_FEE_INDEX,
            PROTOCOL_ISSUE_DIRECT_FEE_INDEX,
            MANAGER_ISSUE_FEE_INDEX
        );

        issueInfo.setTokenQuantity = _getSetTokenMintQuantity(
            _setToken,
            _reserveAsset,
            issueInfo.netFlowQuantity,
            issueInfo.previousSetTokenSupply
        );

        (issueInfo.newSetTokenSupply, issueInfo.newPositionMultiplier) = _getIssuePositionMultiplier(_setToken, issueInfo);

        issueInfo.newReservePositionUnit = _getIssuePositionUnit(_setToken, _reserveAsset, issueInfo);

        return issueInfo;
    }

    function _getRedemptionInfo(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _setTokenQuantity
    )
        internal
        view
        returns (ActionInfo memory)
    {
        ActionInfo memory redeemInfo;

        redeemInfo.setTokenQuantity = _setTokenQuantity;

        redeemInfo.preFeeReserveQuantity =_getRedeemReserveQuantity(_setToken, _reserveAsset, _setTokenQuantity);

        (redeemInfo.protocolFees, redeemInfo.managerFee, redeemInfo.netFlowQuantity) = _getFees(
            _setToken,
            redeemInfo.preFeeReserveQuantity,
            PROTOCOL_REDEEM_MANAGER_REVENUE_SHARE_FEE_INDEX,
            PROTOCOL_REDEEM_DIRECT_FEE_INDEX,
            MANAGER_REDEEM_FEE_INDEX
        );

        redeemInfo.previousSetTokenSupply = _setToken.totalSupply();

        (redeemInfo.newSetTokenSupply, redeemInfo.newPositionMultiplier) = _getRedeemPositionMultiplier(_setToken, _setTokenQuantity, redeemInfo);

        redeemInfo.newReservePositionUnit = _getRedeemPositionUnit(_setToken, _reserveAsset, redeemInfo);

        return redeemInfo;
    }

    function _transferCollateralAndHandleFees(ISetToken _setToken, IERC20 _reserveAsset, ActionInfo memory _issueInfo) internal {
        transferFrom(_reserveAsset, msg.sender, address(_setToken), _issueInfo.netFlowQuantity);

        if (_issueInfo.protocolFees > 0) {
            transferFrom(_reserveAsset, msg.sender, controller.feeRecipient(), _issueInfo.protocolFees);
        }

        if (_issueInfo.managerFee > 0) {
            transferFrom(_reserveAsset, msg.sender, navIssuanceSettings[_setToken].feeRecipient, _issueInfo.managerFee);
        }
    }


    function _transferWETHAndHandleFees(ISetToken _setToken, ActionInfo memory _issueInfo) internal {
        weth.transfer(address(_setToken), _issueInfo.netFlowQuantity);

        if (_issueInfo.protocolFees > 0) {
            weth.transfer(controller.feeRecipient(), _issueInfo.protocolFees);
        }

        if (_issueInfo.managerFee > 0) {
            weth.transfer(navIssuanceSettings[_setToken].feeRecipient, _issueInfo.managerFee);
        }
    }

    function _handleIssueStateUpdates(
        ISetToken _setToken,
        address _reserveAsset,
        address _to,
        ActionInfo memory _issueInfo
    ) 
        internal
    {
        _setToken.editPositionMultiplier(_issueInfo.newPositionMultiplier);

        _setToken.editDefaultPosition(_reserveAsset, _issueInfo.newReservePositionUnit);

        _setToken.mint(_to, _issueInfo.setTokenQuantity);

        emit SetTokenNAVIssued(
            address(_setToken),
            msg.sender,
            _to,
            _reserveAsset,
            address(navIssuanceSettings[_setToken].managerIssuanceHook),
            _issueInfo.setTokenQuantity,
            _issueInfo.managerFee,
            _issueInfo.protocolFees
        );        
    }

    function _handleRedeemStateUpdates(
        ISetToken _setToken,
        address _reserveAsset,
        address _to,
        ActionInfo memory _redeemInfo
    ) 
        internal
    {
        _setToken.editPositionMultiplier(_redeemInfo.newPositionMultiplier);

        _setToken.editDefaultPosition(_reserveAsset, _redeemInfo.newReservePositionUnit);

        emit SetTokenNAVRedeemed(
            address(_setToken),
            msg.sender,
            _to,
            _reserveAsset,
            address(navIssuanceSettings[_setToken].managerRedemptionHook),
            _redeemInfo.setTokenQuantity,
            _redeemInfo.managerFee,
            _redeemInfo.protocolFees
        );      
    }

    function _handleRedemptionFees(ISetToken _setToken, address _reserveAsset, ActionInfo memory _redeemInfo) internal {
        payProtocolFeeFromSetToken(_setToken, _reserveAsset, _redeemInfo.protocolFees);

        if (_redeemInfo.managerFee > 0) {
            _setToken.strictInvokeTransfer(
                _reserveAsset,
                navIssuanceSettings[_setToken].feeRecipient,
                _redeemInfo.managerFee
            );
        }
    }

    function _getIssuePremium(
        ISetToken _setToken,
        address /* _reserveAsset */,
        uint256 /* _reserveAssetquantity */
    )
        virtual
        internal
        view
        returns (uint256)
    {
        return navIssuanceSettings[_setToken].premiumPercentage;
    }

    function _getRedeemPremium(
        ISetToken _setToken,
        address /* _reserveAsset */,
        uint256 /* _setTokenquantity */
    )
        virtual
        internal
        view
        returns (uint256)
    {
        return navIssuanceSettings[_setToken].premiumPercentage;
    }

    function _getFees(
        ISetToken _setToken,
        uint256 _reserveAssetQuantity,
        uint256 _protocolManagerFeeIndex,
        uint256 _protocolDirectFeeIndex,
        uint256 _managerFeeIndex
    )
        internal
        view
        returns (uint256, uint256, uint256)
    {
        (uint256 protocolFeePercentage, uint256 managerFeePercentage) = _getProtocolAndManagerFeePercentages(
            _setToken,
            _protocolManagerFeeIndex,
            _protocolDirectFeeIndex,
            _managerFeeIndex
        );

        uint256 protocolFees = protocolFeePercentage.preciseMul(_reserveAssetQuantity);
        uint256 managerFee = managerFeePercentage.preciseMul(_reserveAssetQuantity);

        uint256 netReserveFlow = _reserveAssetQuantity.sub(protocolFees).sub(managerFee);

        return (protocolFees, managerFee, netReserveFlow);
    }

    function _getProtocolAndManagerFeePercentages(
        ISetToken _setToken,
        uint256 _protocolManagerFeeIndex,
        uint256 _protocolDirectFeeIndex,
        uint256 _managerFeeIndex
    )
        internal
        view
        returns(uint256, uint256)
    {
        uint256 protocolDirectFeePercent = controller.getModuleFee(address(this), _protocolDirectFeeIndex);
        uint256 protocolManagerShareFeePercent = controller.getModuleFee(address(this), _protocolManagerFeeIndex);
        uint256 managerFeePercent = navIssuanceSettings[_setToken].managerFees[_managerFeeIndex];
        
        uint256 protocolRevenueSharePercentage = protocolManagerShareFeePercent.preciseMul(managerFeePercent);
        uint256 managerRevenueSharePercentage = managerFeePercent.sub(protocolRevenueSharePercentage);
        uint256 totalProtocolFeePercentage = protocolRevenueSharePercentage.add(protocolDirectFeePercent);

        return (managerRevenueSharePercentage, totalProtocolFeePercentage);
    }

    function _getSetTokenMintQuantity(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _netReserveFlows,            // Value of reserve asset net of fees
        uint256 _setTotalSupply
    )
        internal
        view
        returns (uint256)
    {
        uint256 premiumPercentage = _getIssuePremium(_setToken, _reserveAsset, _netReserveFlows);
        uint256 premiumValue = _netReserveFlows.preciseMul(premiumPercentage);

        uint256 setTokenValuation = controller.getSetValuer().calculateSetTokenValuation(_setToken, _reserveAsset);

        uint256 reserveAssetDecimals = ERC20(_reserveAsset).decimals();
        uint256 normalizedTotalReserveQuantityNetFees = _netReserveFlows.preciseDiv(10 ** reserveAssetDecimals);
        uint256 normalizedTotalReserveQuantityNetFeesAndPremium = _netReserveFlows.sub(premiumValue).preciseDiv(10 ** reserveAssetDecimals);

        uint256 denominator = _setTotalSupply.preciseMul(setTokenValuation).add(normalizedTotalReserveQuantityNetFees).sub(normalizedTotalReserveQuantityNetFeesAndPremium);
        return normalizedTotalReserveQuantityNetFeesAndPremium.preciseMul(_setTotalSupply).preciseDiv(denominator);
    }

    function _getRedeemReserveQuantity(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _setTokenQuantity
    )
        internal
        view
        returns (uint256)
    {
        uint256 setTokenValuation = controller.getSetValuer().calculateSetTokenValuation(_setToken, _reserveAsset);

        uint256 totalRedeemValueInPreciseUnits = _setTokenQuantity.preciseMul(setTokenValuation);
        uint256 reserveAssetDecimals = ERC20(_reserveAsset).decimals();
        uint256 prePremiumReserveQuantity = totalRedeemValueInPreciseUnits.preciseMul(10 ** reserveAssetDecimals);

        uint256 premiumPercentage = _getRedeemPremium(_setToken, _reserveAsset, _setTokenQuantity);
        uint256 premiumQuantity = prePremiumReserveQuantity.preciseMulCeil(premiumPercentage);

        return prePremiumReserveQuantity.sub(premiumQuantity);
    }

    function _getIssuePositionMultiplier(
        ISetToken _setToken,
        ActionInfo memory _issueInfo
    )
        internal
        view
        returns (uint256, int256)
    {
        uint256 newTotalSupply = _issueInfo.setTokenQuantity.add(_issueInfo.previousSetTokenSupply);
        int256 inflation = _issueInfo.setTokenQuantity.preciseDivCeil(newTotalSupply).toInt256();

        int256 newPositionMultiplier = PreciseUnitMath.preciseUnitInt().sub(inflation).preciseMul(_setToken.positionMultiplier());

        return (newTotalSupply, newPositionMultiplier);
    }

    function _getRedeemPositionMultiplier(
        ISetToken _setToken,
        uint256 _setTokenQuantity,
        ActionInfo memory _redeemInfo
    )
        internal
        view
        returns (uint256, int256)
    {
        uint256 newTotalSupply = _redeemInfo.previousSetTokenSupply.sub(_setTokenQuantity);
        int256 deflation = _setTokenQuantity.preciseDiv(newTotalSupply).toInt256();
        
        int256 newPositionMultiplier = PreciseUnitMath.preciseUnitInt().add(deflation).preciseMul(_setToken.positionMultiplier());

        return (newTotalSupply, newPositionMultiplier);
    }

    function _getIssuePositionUnit(
        ISetToken _setToken,
        address _reserveAsset,
        ActionInfo memory _issueInfo
    )
        internal
        view
        returns (uint256)
    {
        uint256 existingUnit = _setToken.getDefaultPositionRealUnit(_reserveAsset).toUint256();
        uint256 totalReserve = existingUnit
            .preciseMul(_issueInfo.previousSetTokenSupply)
            .add(_issueInfo.netFlowQuantity);

        return totalReserve.preciseDiv(_issueInfo.newSetTokenSupply);
    }

    function _getRedeemPositionUnit(
        ISetToken _setToken,
        address _reserveAsset,
        ActionInfo memory _redeemInfo
    )
        internal
        view
        returns (uint256)
    {
        uint256 existingUnit = _setToken.getDefaultPositionRealUnit(_reserveAsset).toUint256();
        uint256 totalExistingUnits = existingUnit.preciseMul(_redeemInfo.previousSetTokenSupply);

        uint256 outflow = _redeemInfo.netFlowQuantity.add(_redeemInfo.protocolFees).add(_redeemInfo.managerFee);

        require(totalExistingUnits >= outflow, "Must be greater than total available collateral");

        return totalExistingUnits.sub(outflow).preciseDiv(_redeemInfo.newSetTokenSupply);
    }

    function _callPreIssueHooks(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _reserveAssetQuantity,
        address _caller,
        address _to
    )
        internal
    {
        INAVIssuanceHook preIssueHook = navIssuanceSettings[_setToken].managerIssuanceHook;
        if (address(preIssueHook) != address(0)) {
            preIssueHook.invokePreIssueHook(_setToken, _reserveAsset, _reserveAssetQuantity, _caller, _to);
        }
    }

    function _callPreRedeemHooks(ISetToken _setToken, uint256 _setQuantity, address _caller, address _to) internal {
        INAVIssuanceHook preRedeemHook = navIssuanceSettings[_setToken].managerRedemptionHook;
        if (address(preRedeemHook) != address(0)) {
            preRedeemHook.invokePreRedeemHook(_setToken, _setQuantity, _caller, _to);
        }
    }
}