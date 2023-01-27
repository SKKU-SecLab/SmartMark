
pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity 0.6.12;

interface IManager {

    function addVault(address) external;

    function allowedControllers(address) external view returns (bool);

    function allowedConverters(address) external view returns (bool);

    function allowedStrategies(address) external view returns (bool);

    function allowedVaults(address) external view returns (bool);

    function controllers(address) external view returns (address);

    function getHarvestFeeInfo() external view returns (address, address, uint256);

    function getToken(address) external view returns (address);

    function governance() external view returns (address);

    function halted() external view returns (bool);

    function harvester() external view returns (address);

    function insuranceFee() external view returns (uint256);

    function insurancePool() external view returns (address);

    function insurancePoolFee() external view returns (uint256);

    function pendingStrategist() external view returns (address);

    function removeVault(address) external;

    function stakingPool() external view returns (address);

    function stakingPoolShareFee() external view returns (uint256);

    function strategist() external view returns (address);

    function treasury() external view returns (address);

    function treasuryFee() external view returns (uint256);

    function withdrawalProtectionFee() external view returns (uint256);

    function yaxis() external view returns (address);

}// MIT

pragma solidity 0.6.12;


interface IController {

    function balanceOf() external view returns (uint256);

    function converter(address _vault) external view returns (address);

    function earn(address _strategy, address _token, uint256 _amount) external;

    function investEnabled() external view returns (bool);

    function harvestStrategy(address _strategy, uint256[] calldata _estimates) external;

    function manager() external view returns (IManager);

    function strategies() external view returns (uint256);

    function withdraw(address _token, uint256 _amount) external;

    function withdrawAll(address _strategy, address _convert) external;

}// MIT

pragma solidity 0.6.12;


interface IConverter {

    function manager() external view returns (IManager);

    function convert(
        address _input,
        address _output,
        uint256 _inputAmount,
        uint256 _estimatedOutput
    ) external returns (uint256 _outputAmount);

    function expected(
        address _input,
        address _output,
        uint256 _inputAmount
    ) external view returns (uint256 _outputAmount);

}// MIT

pragma solidity 0.6.12;


interface IVault {

    function available() external view returns (uint256);

    function balance() external view returns (uint256);

    function deposit(uint256 _amount) external returns (uint256);

    function earn(address _strategy) external;

    function gauge() external returns (address);

    function getLPToken() external view returns (address);

    function getPricePerFullShare() external view returns (uint256);

    function getToken() external view returns (address);

    function manager() external view returns (IManager);

    function withdraw(uint256 _amount) external;

    function withdrawAll() external;

    function withdrawFee(uint256 _amount) external view returns (uint256);

}// MIT

pragma solidity 0.6.12;


interface IHarvester {

    function addStrategy(address, address, uint256) external;

    function manager() external view returns (IManager);

    function removeStrategy(address, address, uint256) external;

    function slippage() external view returns (uint256);

}// MIT
pragma solidity ^0.6.2;

interface ISwap {

    function swapExactTokensForTokens(uint256, uint256, address[] calldata, address, uint256) external;

    function getAmountsOut(uint256, address[] calldata) external view returns (uint256[] memory);

}// MIT

pragma solidity 0.6.12;


interface IStrategy {

    function balanceOf() external view returns (uint256);

    function balanceOfPool() external view returns (uint256);

    function balanceOfWant() external view returns (uint256);

    function deposit() external;

    function harvest(uint256[] calldata) external;

    function manager() external view returns (IManager);

    function name() external view returns (string memory);

    function router() external view returns (ISwap);

    function skim() external;

    function want() external view returns (address);

    function weth() external view returns (address);

    function withdraw(address) external;

    function withdraw(uint256) external;

    function withdrawAll() external;

}

interface IStrategyExtended {

    function getEstimates() external view returns (uint256[] memory);

}// MIT

pragma solidity 0.6.12;


contract Controller is IController {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IManager public immutable override manager;

    bool public globalInvestEnabled;
    uint256 public maxStrategies;

    struct VaultDetail {
        address converter;
        uint256 balance;
        address[] strategies;
        mapping(address => uint256) balances;
        mapping(address => uint256) index;
        mapping(address => uint256) caps;
    }

    mapping(address => VaultDetail) internal _vaultDetails;
    mapping(address => address) internal _vaultStrategies;

    event Harvest(address indexed strategy);

    event StrategyAdded(address indexed vault, address indexed strategy, uint256 cap);

    event StrategyRemoved(address indexed vault, address indexed strategy);

    event StrategiesReordered(
        address indexed vault,
        address indexed strategy1,
        address indexed strategy2
    );

    constructor(
        address _manager
    )
        public
    {
        manager = IManager(_manager);
        globalInvestEnabled = true;
        maxStrategies = 10;
    }


    function addStrategy(
        address _vault,
        address _strategy,
        uint256 _cap,
        uint256 _timeout
    )
        external
        notHalted
        onlyStrategist
        onlyStrategy(_strategy)
    {

        require(manager.allowedVaults(_vault), "!_vault");
        if(IStrategy(_strategy).want() != IVault(_vault).getToken()) {
            require(_vaultDetails[_vault].converter != address(0), "!converter");
        }
        require(_vaultStrategies[_strategy] == address(0), "Strategy is already added"); 
        uint256 index = _vaultDetails[_vault].strategies.length;
        require(index < maxStrategies, "!maxStrategies");
        _vaultDetails[_vault].strategies.push(_strategy);
        _vaultDetails[_vault].caps[_strategy] = _cap;
        _vaultDetails[_vault].index[_strategy] = index;
        _vaultStrategies[_strategy] = _vault;
        if (_timeout > 0) {
            IHarvester(manager.harvester()).addStrategy(_vault, _strategy, _timeout);
        }
        emit StrategyAdded(_vault, _strategy, _cap);
    }

    function inCaseStrategyGetStuck(
        address _strategy,
        address _token
    )
        external
        onlyStrategist
    {

        IStrategy(_strategy).withdraw(_token);
        IERC20(_token).safeTransfer(
            manager.treasury(),
            IERC20(_token).balanceOf(address(this))
        );
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount
    )
        external
        onlyStrategist
    {

        IERC20(_token).safeTransfer(manager.treasury(), _amount);
    }

    function removeStrategy(
        address _vault,
        address _strategy,
        uint256 _timeout
    )
        external
        notHalted
        onlyStrategist
    {

        require(manager.allowedVaults(_vault), "!_vault");
        VaultDetail storage vaultDetail = _vaultDetails[_vault];
        uint256 index = vaultDetail.index[_strategy];
        uint256 tail = vaultDetail.strategies.length.sub(1);
        address replace = vaultDetail.strategies[tail];
        vaultDetail.strategies[index] = replace;
        vaultDetail.index[replace] = index;
        vaultDetail.strategies.pop();
        delete vaultDetail.index[_strategy];
        delete vaultDetail.caps[_strategy];
        delete vaultDetail.balances[_strategy];
        delete _vaultStrategies[_strategy];
        IStrategy(_strategy).withdrawAll();
        IHarvester(manager.harvester()).removeStrategy(_vault, _strategy, _timeout);
        emit StrategyRemoved(_vault, _strategy);
    }

    function reorderStrategies(
        address _vault,
        address _strategy1,
        address _strategy2
    )
        external
        notHalted
        onlyStrategist
    {

        require(manager.allowedVaults(_vault), "!_vault");
        require(_vaultStrategies[_strategy1] == _vault, "!_strategy1");
        require(_vaultStrategies[_strategy2] == _vault, "!_strategy2");
        VaultDetail storage vaultDetail = _vaultDetails[_vault];
        uint256 index1 = vaultDetail.index[_strategy1];
        uint256 index2 = vaultDetail.index[_strategy2];
        vaultDetail.strategies[index1] = _strategy2;
        vaultDetail.strategies[index2] = _strategy1;
        vaultDetail.index[_strategy1] = index2;
        vaultDetail.index[_strategy2] = index1;
        emit StrategiesReordered(_vault, _strategy1, _strategy2);
    }

    function setCap(
        address _vault,
        address _strategy,
        uint256 _cap,
        address _convert
    )
        external
        notHalted
        onlyStrategist
        onlyStrategy(_strategy)
    {

        _vaultDetails[_vault].caps[_strategy] = _cap;
        uint256 _balance = IStrategy(_strategy).balanceOf();
        if (_balance > _cap && _cap != 0) {
            uint256 _diff = _balance.sub(_cap);
            IStrategy(_strategy).withdraw(_diff);
            updateBalance(_vault, _strategy);
            _balance = IStrategy(_strategy).balanceOf();
            _vaultDetails[_vault].balance = _vaultDetails[_vault].balance.sub(_diff);
            address _want = IStrategy(_strategy).want();
            _balance = IERC20(_want).balanceOf(address(this));
            if (_convert != address(0)) {
                IConverter _converter = IConverter(_vaultDetails[_vault].converter);
                IERC20(_want).safeTransfer(address(_converter), _balance);
                _balance = _converter.convert(_want, _convert, _balance, 1);
                IERC20(_convert).safeTransfer(_vault, _balance);
            } else {
                IERC20(_want).safeTransfer(_vault, _balance);
            }
        }
    }

    function setConverter(
        address _vault,
        address _converter
    )
        external
        notHalted
        onlyStrategist
    {

        require(manager.allowedConverters(_converter), "!allowedConverters");
        _vaultDetails[_vault].converter = _converter;
    }

    function setInvestEnabled(
        bool _investEnabled
    )
        external
        notHalted
        onlyStrategist
    {

        globalInvestEnabled = _investEnabled;
    }

    function setMaxStrategies(
        uint256 _maxStrategies
    )
        external
        notHalted
        onlyStrategist
    {

        maxStrategies = _maxStrategies;
    }

    function skim(
        address _strategy
    )
        external
        onlyStrategist
        onlyStrategy(_strategy)
    {

        address _want = IStrategy(_strategy).want();
        IStrategy(_strategy).skim();
        IERC20(_want).safeTransfer(_vaultStrategies[_strategy], IERC20(_want).balanceOf(address(this)));
    }

    function withdrawAll(
        address _strategy,
        address _convert
    )
        external
        override
        onlyStrategist
        onlyStrategy(_strategy)
    {

        address _want = IStrategy(_strategy).want();
        IStrategy(_strategy).withdrawAll();
        uint256 _amount = IERC20(_want).balanceOf(address(this));
        address _vault = _vaultStrategies[_strategy];
        updateBalance(_vault, _strategy);
        if (_convert != address(0)) {
            IConverter _converter = IConverter(_vaultDetails[_vault].converter);
            IERC20(_want).safeTransfer(address(_converter), _amount);
            _amount = _converter.convert(_want, _convert, _amount, 1);
            IERC20(_convert).safeTransfer(_vault, _amount);
        } else {
            IERC20(_want).safeTransfer(_vault, _amount);
        }
        uint256 _balance = _vaultDetails[_vault].balance;
        if (_balance >= _amount) {
            _vaultDetails[_vault].balance = _balance.sub(_amount);
        } else {
            _vaultDetails[_vault].balance = 0;
        }
    }


    function harvestStrategy(
        address _strategy,
        uint256[] calldata _estimates
    )
        external
        override
        notHalted
        onlyHarvester
        onlyStrategy(_strategy)
    {

        uint256 _before = IStrategy(_strategy).balanceOf();
        IStrategy(_strategy).harvest(_estimates);
        uint256 _after = IStrategy(_strategy).balanceOf();
        address _vault = _vaultStrategies[_strategy];
        _vaultDetails[_vault].balance = _vaultDetails[_vault].balance.add(_after.sub(_before));
        _vaultDetails[_vault].balances[_strategy] = _after;
        emit Harvest(_strategy);
    }


    function earn(
        address _strategy,
        address _token,
        uint256 _amount
    )
        external
        override
        notHalted
        onlyStrategy(_strategy)
        onlyVault()
    {

        address _want = IStrategy(_strategy).want();
        if (_want != _token) {
            IConverter _converter = IConverter(_vaultDetails[msg.sender].converter);
            IERC20(_token).safeTransfer(address(_converter), _amount);
            _amount = _converter.convert(_token, _want, _amount, 1);
            IERC20(_want).safeTransfer(_strategy, _amount);
        } else {
            IERC20(_token).safeTransfer(_strategy, _amount);
        }
        _vaultDetails[msg.sender].balance = _vaultDetails[msg.sender].balance.add(_amount);
        IStrategy(_strategy).deposit();
        updateBalance(msg.sender, _strategy);
    }

    function withdraw(
        address _token,
        uint256 _amount
    )
        external
        override
        onlyVault()
    {

        (
            address[] memory _strategies,
            uint256[] memory _amounts
        ) = getBestStrategyWithdraw(msg.sender, _amount);
        for (uint i = 0; i < _strategies.length; i++) {
            if (_strategies[i] == address(0)) {
                break;
            }
            IStrategy(_strategies[i]).withdraw(_amounts[i]);
            updateBalance(msg.sender, _strategies[i]);
            address _want = IStrategy(_strategies[i]).want();
            if (_want != _token) {
                address _converter = _vaultDetails[msg.sender].converter;
                IERC20(_want).safeTransfer(_converter, _amounts[i]);
                IConverter(_converter).convert(_want, _token, _amounts[i], 1);
            }
        }
        _amount = IERC20(_token).balanceOf(address(this));
        _vaultDetails[msg.sender].balance = _vaultDetails[msg.sender].balance.sub(_amount);
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }


    function balanceOf()
        external
        view
        override
        returns (uint256 _balance)
    {

        return _vaultDetails[msg.sender].balance;
    }

    function converter(
        address _vault
    )
        external
        view
        override
        returns (address)
    {

        return _vaultDetails[_vault].converter;
    }

    function getCap(
        address _vault,
        address _strategy
    )
        external
        view
        returns (uint256)
    {

        return _vaultDetails[_vault].caps[_strategy];
    }

    function investEnabled()
        external
        view
        override
        returns (bool)
    {

        if (globalInvestEnabled) {
            return _vaultDetails[msg.sender].strategies.length > 0;
        }
        return false;
    }

    function strategies(
        address _vault
    )
        external
        view
        returns (address[] memory)
    {

        return _vaultDetails[_vault].strategies;
    }

    function strategies()
        external
        view
        override
        returns (uint256)
    {

        return _vaultDetails[msg.sender].strategies.length;
    }


    function getBestStrategyWithdraw(
        address _vault,
        uint256 _amount
    )
        internal
        view
        returns (
            address[] memory _strategies,
            uint256[] memory _amounts
        )
    {

        uint256 k = _vaultDetails[_vault].strategies.length;
        _strategies = new address[](k);
        _amounts = new uint256[](k);
        address _strategy;
        uint256 _balance;
        for (uint i = 0; i < k; i++) {
            _strategy = _vaultDetails[_vault].strategies[i];
            _strategies[i] = _strategy;
            _balance = _vaultDetails[_vault].balances[_strategy];
            if (_balance < _amount) {
                _amounts[i] = _balance;
                _amount = _amount.sub(_balance);
            } else {
                _amounts[i] = _amount;
                break;
            }
        }
    }

    function updateBalance(
        address _vault,
        address _strategy
    )
        internal
    {

        _vaultDetails[_vault].balances[_strategy] = IStrategy(_strategy).balanceOf();
    }


    modifier notHalted() {

        require(!manager.halted(), "halted");
        _;
    }

    modifier onlyGovernance() {

        require(msg.sender == manager.governance(), "!governance");
        _;
    }

    modifier onlyStrategist() {

        require(msg.sender == manager.strategist(), "!strategist");
        _;
    }

    modifier onlyStrategy(address _strategy) {

        require(manager.allowedStrategies(_strategy), "!allowedStrategy");
        _;
    }

    modifier onlyHarvester() {

        require(msg.sender == manager.harvester(), "!harvester");
        _;
    }

    modifier onlyVault() {

        require(manager.allowedVaults(msg.sender), "!vault");
        _;
    }
}