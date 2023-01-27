
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

library Address {

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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity 0.8.10;


interface IOwnership {

    function owner() external view returns (address);


    function futureOwner() external view returns (address);


    function commitTransferOwnership(address newOwner) external;


    function acceptTransferOwnership() external;

}pragma solidity 0.8.10;

interface IVault {

    function addValueBatch(
        uint256 _amount,
        address _from,
        address[2] memory _beneficiaries,
        uint256[2] memory _shares
    ) external returns (uint256[2] memory _allocations);


    function addValue(
        uint256 _amount,
        address _from,
        address _attribution
    ) external returns (uint256 _attributions);


    function withdrawValue(uint256 _amount, address _to)
        external
        returns (uint256 _attributions);


    function transferValue(uint256 _amount, address _destination)
        external
        returns (uint256 _attributions);


    function withdrawAttribution(uint256 _attribution, address _to)
        external
        returns (uint256 _retVal);


    function withdrawAllAttribution(address _to)
        external
        returns (uint256 _retVal);


    function transferAttribution(uint256 _amount, address _destination)
        external;


    function attributionOf(address _target) external view returns (uint256);


    function underlyingValue(address _target) external view returns (uint256);


    function attributionValue(uint256 _attribution)
        external
        view
        returns (uint256);


    function utilize() external returns (uint256 _amount);

    function valueAll() external view returns (uint256);



    function token() external returns (address);


    function borrowValue(uint256 _amount, address _to) external;



    function offsetDebt(uint256 _amount, address _target)
        external
        returns (uint256 _attributions);


    function repayDebt(uint256 _amount, address _target) external;


    function debts(address _debtor) external view returns (uint256);


    function transferDebt(uint256 _amount) external;


    function withdrawRedundant(address _token, address _to) external;


    function setController(address _controller) external;


    function setKeeper(address _keeper) external;

}pragma solidity 0.8.10;

interface IController {

    function withdraw(address, uint256) external;


    function valueAll() external view returns (uint256);


    function utilizeAmount() external returns (uint256);


    function earn(address, uint256) external;


    function migrate(address) external;

}pragma solidity 0.8.10;

interface IRegistry {

    function isListed(address _market) external view returns (bool);


    function getCDS(address _address) external view returns (address);


    function confirmExistence(address _template, address _target)
        external
        view
        returns (bool);


    function setFactory(address _factory) external;


    function supportMarket(address _market) external;


    function setExistence(address _template, address _target) external;


    function setCDS(address _address, address _cds) external;

}pragma solidity 0.8.10;




contract Vault is IVault {

    using SafeERC20 for IERC20;


    address public override token;
    IController public controller;
    IRegistry public registry;
    IOwnership public immutable ownership;

    mapping(address => uint256) public override debts;
    mapping(address => uint256) public attributions;
    uint256 public totalAttributions;

    address public keeper; //keeper can operate utilize(), if address zero, anyone can operate.
    uint256 public balance; //balance of underlying token
    uint256 public totalDebt; //total debt balance. 1debt:1token

    uint256 private constant MAGIC_SCALE_1E6 = 1e6; //internal multiplication scale 1e6 to reduce decimal truncation



    event ControllerSet(address controller);
    event KeeperChanged(address keeper);

    modifier onlyOwner() {

        require(
            ownership.owner() == msg.sender,
            "Caller is not allowed to operate"
        );
        _;
    }

    modifier onlyMarket() {

        require(
            IRegistry(registry).isListed(msg.sender),
            "ERROR_ONLY_MARKET"
        );
        _;
    }

    constructor(
        address _token,
        address _registry,
        address _controller,
        address _ownership
    ) {
        require(_token != address(0), "ERROR_ZERO_ADDRESS");
        require(_registry != address(0), "ERROR_ZERO_ADDRESS");
        require(_ownership != address(0), "ERROR_ZERO_ADDRESS");

        token = _token;
        registry = IRegistry(_registry);
        controller = IController(_controller);
        ownership = IOwnership(_ownership);
    }


    function addValueBatch(
        uint256 _amount,
        address _from,
        address[2] calldata _beneficiaries,
        uint256[2] calldata _shares
    ) external override onlyMarket returns (uint256[2] memory _allocations) {

        
        require(_shares[0] + _shares[1] == 1000000, "ERROR_INCORRECT_SHARE");

        uint256 _attributions;
        uint256 _pool = valueAll();
        if (totalAttributions == 0) {
            _attributions = _amount;
        } else {
            require(_pool != 0, "ERROR_VALUE_ALL_IS_ZERO"); //should never triggered
            _attributions = (_amount * totalAttributions) / _pool;
        }
        IERC20(token).safeTransferFrom(_from, address(this), _amount);

        balance += _amount;
        totalAttributions += _attributions;

        uint256 _allocation = (_shares[0] * _attributions) / MAGIC_SCALE_1E6;
        attributions[_beneficiaries[0]] += _allocation;
        _allocations[0] = _allocation;

        _allocation = (_shares[1] * _attributions) / MAGIC_SCALE_1E6;
        attributions[_beneficiaries[1]] += _allocation;
        _allocations[1] = _allocation;
    }


    function addValue(
        uint256 _amount,
        address _from,
        address _beneficiary
    ) external override onlyMarket returns (uint256 _attributions) {


        if (totalAttributions == 0) {
            _attributions = _amount;
        } else {
            uint256 _pool = valueAll();
            _attributions = (_amount * totalAttributions) / _pool;
        }
        IERC20(token).safeTransferFrom(_from, address(this), _amount);
        balance += _amount;
        totalAttributions += _attributions;
        attributions[_beneficiary] += _attributions;
    }

    function withdrawValue(uint256 _amount, address _to)
        external
        override
        returns (uint256 _attributions)
    {

        require(_to != address(0), "ERROR_ZERO_ADDRESS");
        
        uint256 _valueAll = valueAll();
        require(
            attributions[msg.sender] != 0 &&
                underlyingValue(msg.sender, _valueAll) >= _amount,
            "WITHDRAW-VALUE_BADCONDITIONS"
        );

        _attributions = _divRoundUp(totalAttributions * _amount, valueAll());
        uint256 _available = available();

        require(
            attributions[msg.sender] >= _attributions,
            "WITHDRAW-VALUE_BADCONDITIONS"
        );
        attributions[msg.sender] -= _attributions;

        totalAttributions -= _attributions;

        if (_available < _amount) {
            uint256 _shortage;
            unchecked {
                _shortage = _amount - _available;
            }
            _unutilize(_shortage);

            require(available() >= _amount, "Withdraw amount > Available");
        }

        balance -= _amount;
        IERC20(token).safeTransfer(_to, _amount);
    }


    function transferValue(uint256 _amount, address _destination)
        external
        override
        returns (uint256 _attributions)
    {

        require(_destination != address(0), "ERROR_ZERO_ADDRESS");
        
        uint256 _valueAll = valueAll();
        
        require(
            attributions[msg.sender] != 0 &&
                underlyingValue(msg.sender, _valueAll) >= _amount,
            "TRANSFER-VALUE_BADCONDITIONS"
        );
        _attributions = _divRoundUp(totalAttributions * _amount, valueAll());
        attributions[msg.sender] -= _attributions;
        attributions[_destination] += _attributions;
    }

    function borrowValue(uint256 _amount, address _to) external onlyMarket override {

        if (_amount != 0) {
            debts[msg.sender] += _amount;
            totalDebt += _amount;

            IERC20(token).safeTransfer(_to, _amount);
        }
    }


    function offsetDebt(uint256 _amount, address _target)
        external
        override
        returns (uint256 _attributions)
    {

        uint256 _valueAll = valueAll();
        require(
            attributions[msg.sender] != 0 &&
                underlyingValue(msg.sender, _valueAll) >= _amount,
            "ERROR_REPAY_DEBT_BADCONDITIONS"
        );
         _attributions = _divRoundUp(totalAttributions * _amount, valueAll());
        attributions[msg.sender] -= _attributions;
        totalAttributions -= _attributions;
        balance -= _amount;
        debts[_target] -= _amount;
        totalDebt -= _amount;
    }

    function transferDebt(uint256 _amount) external onlyMarket override {


        if(_amount != 0){
            debts[msg.sender] -= _amount;
            debts[address(0)] += _amount;
        }
    }

    function repayDebt(uint256 _amount, address _target) external override {

        uint256 _debt = debts[_target];

        if (_debt > _amount) {
            unchecked {
                debts[_target] = _debt - _amount;
            }
        } else {
            debts[_target] = 0;
            _amount = _debt;
        }
        totalDebt -= _amount;
        IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
    }

    function withdrawAttribution(uint256 _attribution, address _to)
        external
        override
        returns (uint256 _retVal)
    {

        require(_to != address(0), "ERROR_ZERO_ADDRESS");

        _retVal = _withdrawAttribution(_attribution, _to);
    }

    function withdrawAllAttribution(address _to)
        external
        override
        returns (uint256 _retVal)
    {

        require(_to != address(0), "ERROR_ZERO_ADDRESS");
        
        _retVal = _withdrawAttribution(attributions[msg.sender], _to);
    }

    function _withdrawAttribution(uint256 _attribution, address _to)
        internal
        returns (uint256 _retVal)
    {

        require(
            attributions[msg.sender] >= _attribution,
            "WITHDRAW-ATTRIBUTION_BADCONS"
        );
        uint256 _available = available();
        _retVal = (_attribution * valueAll()) / totalAttributions;

        unchecked {
            attributions[msg.sender] -= _attribution;
        }
        totalAttributions -= _attribution;

        if (_available < _retVal) {
            uint256 _shortage;
            unchecked {
                _shortage = _retVal - _available;
            }
            _unutilize(_shortage);
        }

        balance -= _retVal;
        IERC20(token).safeTransfer(_to, _retVal);
    }

    function transferAttribution(uint256 _amount, address _destination)
        external
        override
    {

        require(_destination != address(0), "ERROR_ZERO_ADDRESS");

        require(
            _amount != 0 && attributions[msg.sender] >= _amount,
            "TRANSFER-ATTRIBUTION_BADCONS"
        );

        unchecked {
            attributions[msg.sender] -= _amount;
        }
        attributions[_destination] += _amount;
    }

    function utilize() external override returns (uint256) {

        require(address(controller) != address(0), "ERROR_CONTROLLER_NOT_SET");
        
        address _token = token;
        if (keeper != address(0)) {
            require(msg.sender == keeper, "ERROR_NOT_KEEPER");
        }

        uint256 _amount = controller.utilizeAmount(); //balance
        require(_amount <= available(), "EXCEED_AVAILABLE");

        if (_amount != 0) {
            IERC20(_token).safeTransfer(address(controller), _amount);
            balance -= _amount;
            controller.earn(_token, _amount);
        }

        return _amount;
    }


    function attributionOf(address _target)
        external
        view
        override
        returns (uint256)
    {

        return attributions[_target];
    }

    function attributionAll() external view returns (uint256) {

        return totalAttributions;
    }

    function attributionValue(uint256 _attribution)
        external
        view
        override
        returns (uint256)
    {

        uint256 _totalAttributions = totalAttributions;

        if (_totalAttributions != 0 && _attribution != 0) {
            return (_attribution * valueAll()) / _totalAttributions;
        }
    }

    function underlyingValue(address _target)
        public
        view
        override
        returns (uint256)
    {

        uint256 _valueAll = valueAll();
        uint256 attribution = attributions[_target];

        if (_valueAll != 0 && attribution != 0) {
            return (_valueAll * attribution) / totalAttributions;
        }
    }
    
    function underlyingValue(address _target, uint256 _valueAll)
        public
        view
        returns (uint256)
    {

        uint256 attribution = attributions[_target];
        if (_valueAll != 0 && attribution != 0) {
            return (_valueAll * attribution) / totalAttributions;
        }
    }

    function valueAll() public view returns (uint256) {

        if (address(controller) != address(0)) {
            return balance + controller.valueAll();
        } else {
            return balance;
        }
    }

    function _unutilize(uint256 _amount) internal {

        require(address(controller) != address(0), "ERROR_CONTROLLER_NOT_SET");

        uint256 beforeBalance = IERC20(token).balanceOf(address(this));
        controller.withdraw(address(this), _amount);
        uint256 received = IERC20(token).balanceOf(address(this)) - beforeBalance;
        require(received >= _amount, "ERROR_INSUFFICIENT_RETURN_VALUE");
        balance += received;
    }

    function available() public view returns (uint256) {

        return balance - totalDebt;
    }

    function getPricePerFullShare() external view returns (uint256) {

        return (valueAll() * MAGIC_SCALE_1E6) / totalAttributions;
    }


    function withdrawRedundant(address _token, address _to)
        external
        override
        onlyOwner
    {

        uint256 _balance = balance;
        uint256 _tokenBalance = IERC20(_token).balanceOf(address(this));
        if (
            _token == token &&
            _balance < _tokenBalance
        ) {
            uint256 _utilized = controller.valueAll();
            uint256 _actualValue = IERC20(token).balanceOf(address(this)) + _utilized;
            uint256 _virtualValue = balance + _utilized;
            if(_actualValue > _virtualValue){
                uint256 _redundant;
                unchecked{
                    _redundant = _tokenBalance - _balance;
                }
                IERC20(token).safeTransfer(_to, _redundant);
            }
        } else if (_token != address(token) && _tokenBalance != 0) {
            IERC20(_token).safeTransfer(
                _to,
                _tokenBalance
            );
        }
    }

    function setController(address _controller) external override onlyOwner {

        require(_controller != address(0), "ERROR_ZERO_ADDRESS");

        if (address(controller) != address(0)) {
            uint256 beforeUnderlying = controller.valueAll();
            controller.migrate(address(_controller));
            require(IController(_controller).valueAll() >= beforeUnderlying, "ERROR_VALUE_ALL_DECREASED");
        }
        controller = IController(_controller);

        emit ControllerSet(_controller);
    }

    function setKeeper(address _keeper) external override onlyOwner {

        if (keeper != _keeper) {
            keeper = _keeper;
        }

        emit KeeperChanged(_keeper);
    }

    function _divRoundUp(uint _a, uint _b) internal pure returns (uint256) {

        require(_a >= _b, "ERROR_NUMERATOR_TOO_SMALL");
        uint _c = _a/ _b;
        if(_c * _b != _a){
            _c += 1;
        }
        return _c;
    }
}