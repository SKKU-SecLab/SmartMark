
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

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT
pragma solidity 0.8.6;


abstract contract Adapter {

    function purchase(
        address caller,
        address[] memory currencies,
        uint256[] memory amounts,
        bytes calldata data
    ) internal virtual returns (uint256[] memory, bytes memory);

    function _preparePayment(address[] memory currencies, uint256[] memory amounts) internal {
        require(currencies.length == amounts.length, 'A2');
        for (uint256 currencyIdx = 0; currencyIdx < currencies.length; ++currencyIdx) {
            if (currencies[currencyIdx] == address(0)) {
                require(msg.value >= amounts[currencyIdx], 'A1');
            } else {
                require(
                    IERC20(currencies[currencyIdx]).transferFrom(msg.sender, address(this), amounts[currencyIdx]),
                    'A2'
                );
            }
        }
    }


    function run(
        address caller,
        address[] memory currencies,
        uint256[] memory amounts,
        bytes calldata data
    ) external payable returns (uint256[] memory, bytes memory) {
        _preparePayment(currencies, amounts);
        return purchase(caller, currencies, amounts, data);
    }

    function name() external view virtual returns (string memory);
}// MIT
pragma solidity 0.8.6;


contract Versioned {


    uint256 version;

    bool private _initializing;


    modifier initVersion(uint256 _version) {

        require(!_initializing, 'V1');
        require(_version == version + 1, 'V2');
        version = _version;

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }


    function getVersion() public view returns (uint256) {

        return version;
    }
}// MIT

pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT
pragma solidity 0.8.6;


contract Pausable {


    bytes32 internal constant _PAUSED_SLOT = 0x8dea8703c3cf94703383ce38a9c894669dccd4ca8e65ddb43267aa0248711450;


    modifier whenPaused() {

        require(StorageSlot.getBooleanSlot(_PAUSED_SLOT).value == true, 'P1');
        _;
    }

    modifier whenNotPaused() {

        require(StorageSlot.getBooleanSlot(_PAUSED_SLOT).value == false, 'P1');
        _;
    }
}// MIT
pragma solidity 0.8.6;


contract Owned {


    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;


    modifier isAdmin() {

        require(StorageSlot.getAddressSlot(_ADMIN_SLOT).value == msg.sender, 'O1');
        _;
    }


    function getAdmin() public view returns (address) {

        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }
}// MIT
pragma solidity 0.8.6;



contract GatewayV1 is Versioned, Pausable, Owned, ReentrancyGuardUpgradeable {


    uint256 constant FEE_DENOMINATOR = 1000000;

    mapping(string => Adapter) public adapters;

    mapping(address => uint256) public collectedFees;

    uint256 public fee;

    address public feeCollector;


    event AdapterChanged(string indexed actionType, address indexed adapter, address oldAdapter, address admin);

    event ExecutedAction(
        string indexed actionType,
        address indexed caller,
        address[] currencies,
        uint256[] amounts,
        uint256[] fees,
        bytes data,
        bytes outputData
    );


    struct Action {
        string actionType;
        address[] currencies;
        uint256[] amounts;
        bytes data;
    }


    modifier isFeeCollector() {

        require(msg.sender == feeCollector, 'G9');
        _;
    }


    function _getAvailableBalance(address[] memory currencies)
        internal
        view
        returns (uint256[] memory, uint256[] memory)
    {

        uint256[] memory currentBalances = new uint256[](currencies.length);
        uint256[] memory availableBalances = new uint256[](currencies.length);
        for (uint256 idx = 0; idx < currencies.length; ++idx) {
            uint256 balance = _getBalance(currencies[idx]);
            currentBalances[idx] = balance;
            availableBalances[idx] = balance - collectedFees[currencies[idx]];
        }
        return (currentBalances, availableBalances);
    }

    function _getBalance(address currency) internal view returns (uint256) {

        if (currency == address(0)) {
            return address(this).balance;
        } else {
            return IERC20(currency).balanceOf(address(this));
        }
    }

    function _transferAndGetAmount(
        address[] memory currencies,
        uint256[] memory amounts,
        Adapter adapter
    )
        internal
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {

        uint256[] memory amountsWithoutFees = new uint256[](amounts.length);
        uint256[] memory extractedFees = new uint256[](amounts.length);
        uint256 callValue = 0;
        for (uint256 idx; idx < currencies.length; ++idx) {
            amountsWithoutFees[idx] = (amounts[idx] * FEE_DENOMINATOR) / (FEE_DENOMINATOR + fee) + 1;
            extractedFees[idx] = amounts[idx] - amountsWithoutFees[idx];

            collectedFees[currencies[idx]] += extractedFees[idx];

            if (currencies[idx] == address(0)) {
                callValue = amountsWithoutFees[idx];
            } else {
                IERC20(currencies[idx]).approve(address(adapter), amountsWithoutFees[idx]);
            }
        }

        return (callValue, amountsWithoutFees, extractedFees);
    }

    function _pull(Action[] calldata actions) internal {

        if (actions.length > 1) {
            uint256 totalCurrencies = 0;
            for (uint256 actionIdx = 0; actionIdx < actions.length; ++actionIdx) {
                Action memory action = actions[actionIdx];
                totalCurrencies += action.amounts.length;
                require(action.amounts.length == action.currencies.length, 'G1');
            }
            uint256[] memory totalAmounts = new uint256[](totalCurrencies);
            address[] memory currencies = new address[](totalCurrencies);
            for (uint256 actionIdx = 0; actionIdx < actions.length; ++actionIdx) {
                Action memory action = actions[actionIdx];
                for (uint256 currencyIdx = 0; currencyIdx < action.amounts.length; ++currencyIdx) {
                    if (action.currencies[currencyIdx] == address(0)) {
                        continue;
                    }
                    for (uint256 storedIdx; storedIdx < currencies.length; ++storedIdx) {
                        if (currencies[storedIdx] == action.currencies[currencyIdx]) {
                            totalAmounts[storedIdx] += action.amounts[currencyIdx];
                            break;
                        } else if (currencies[storedIdx] == address(0)) {
                            currencies[storedIdx] = action.currencies[currencyIdx];
                            totalAmounts[storedIdx] += action.amounts[currencyIdx];
                            break;
                        }
                    }
                }
            }
            for (
                uint256 currencyIdx = 0;
                currencyIdx < currencies.length && currencies[currencyIdx] != address(0);
                ++currencyIdx
            ) {
                IERC20(currencies[currencyIdx]).transferFrom(msg.sender, address(this), totalAmounts[currencyIdx]);
            }
        } else {
            require(actions[0].amounts.length == actions[0].currencies.length, 'G2');
            for (uint256 idx = 0; idx < actions[0].currencies.length; ++idx) {
                if (actions[0].currencies[idx] != address(0)) {
                    IERC20(actions[0].currencies[idx]).transferFrom(msg.sender, address(this), actions[0].amounts[idx]);
                }
            }
        }
    }


    function execute(Action[] calldata actions) external payable nonReentrant whenNotPaused {

        _pull(actions);
        for (uint256 actionIdx = 0; actionIdx < actions.length; ++actionIdx) {
            Action memory action = actions[actionIdx];

            (uint256[] memory preBalances, uint256[] memory availableBalances) = _getAvailableBalance(
                action.currencies
            );

            for (uint256 idx = 0; idx < action.amounts.length; ++idx) {
                require(availableBalances[idx] >= action.amounts[idx], 'G3');
            }

            Adapter adapter = adapters[action.actionType];

            require(address(adapter) != address(0), 'G4');

            (
                uint256 callValue,
                uint256[] memory amountsWithoutFees,
                uint256[] memory extractedFees
            ) = _transferAndGetAmount(action.currencies, action.amounts, adapter);

            (uint256[] memory usedAmount, bytes memory outputData) = adapter.run{value: callValue}(
                msg.sender,
                action.currencies,
                amountsWithoutFees,
                action.data
            );

            for (uint256 idx = 0; idx < action.currencies.length; ++idx) {
                uint256 postBalance = _getBalance(action.currencies[idx]);
                if (postBalance > preBalances[idx] - amountsWithoutFees[idx]) {
                    if (action.currencies[idx] == address(0)) {
                        (bool success, ) = payable(msg.sender).call{
                            value: postBalance - (preBalances[idx] - amountsWithoutFees[idx])
                        }('');
                        require(success, 'G5');
                    } else {
                        IERC20(action.currencies[idx]).transfer(
                            msg.sender,
                            postBalance - (preBalances[idx] - amountsWithoutFees[idx])
                        );
                    }
                }
            }

            emit ExecutedAction(
                action.actionType,
                msg.sender,
                action.currencies,
                usedAmount,
                extractedFees,
                action.data,
                outputData
            );
        }
    }

    function registerAdapter(string calldata actionType, address adapter) external isAdmin {

        require(AddressUpgradeable.isContract(adapter), 'G6');
        require(adapters[actionType] != Adapter(adapter), 'G7');

        emit AdapterChanged(actionType, adapter, address(adapters[actionType]), Owned.getAdmin());

        adapters[actionType] = Adapter(adapter);
    }

    function setFeeCollector(address newFeeCollector) external isAdmin {

        require(newFeeCollector != feeCollector, 'G8');
        feeCollector = newFeeCollector;
    }

    function withdrawCollectedFees(address[] memory currencies) external isFeeCollector returns (uint256[] memory) {

        uint256[] memory withdrawnFees = new uint256[](currencies.length);
        for (uint256 idx = 0; idx < currencies.length; ++idx) {
            if (currencies[idx] == address(0)) {
                (bool success, ) = feeCollector.call{value: collectedFees[currencies[idx]]}('');
                require(success, 'G10');
            } else {
                IERC20(currencies[idx]).transfer(feeCollector, collectedFees[currencies[idx]]);
            }
            withdrawnFees[idx] = collectedFees[currencies[idx]];
            collectedFees[currencies[idx]] = 0;
        }
        return withdrawnFees;
    }


    function __GatewayV1__constructor() public initVersion(1) {

        fee = 1000;
        feeCollector = getAdmin();
    }
}