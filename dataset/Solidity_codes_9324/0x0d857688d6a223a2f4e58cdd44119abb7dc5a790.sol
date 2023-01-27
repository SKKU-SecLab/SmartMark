
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

interface IController {

    function balanceOf(address) external view returns (uint256);

    function earn(address, uint256) external;

    function investEnabled() external view returns (bool);

    function harvestStrategy(address) external;

    function strategyTokens(address) external returns (address);

    function vaults(address) external view returns (address);

    function want(address) external view returns (address);

    function withdraw(address, uint256) external;

    function withdrawFee(address, uint256) external view returns (uint256);

}// MIT

pragma solidity 0.6.12;

interface IConverter {

    function token() external view returns (address _share);

    function convert(
        address _input,
        address _output,
        uint _inputAmount
    ) external returns (uint _outputAmount);

    function convert_rate(
        address _input,
        address _output,
        uint _inputAmount
    ) external view returns (uint _outputAmount);

    function convert_stables(
        uint[3] calldata amounts
    ) external returns (uint _shareAmount); // 0: DAI, 1: USDC, 2: USDT

    function calc_token_amount(
        uint[3] calldata amounts,
        bool deposit
    ) external view returns (uint _shareAmount);

    function calc_token_amount_withdraw(
        uint _shares,
        address _output
    ) external view returns (uint _outputAmount);

    function setStrategy(address _strategy, bool _status) external;

}// MIT

pragma solidity 0.6.12;

interface IHarvester {

    function addStrategy(address, address, uint256) external;

    function removeStrategy(address, address, uint256) external;

}// MIT

pragma solidity 0.6.12;

interface IMetaVault {

    function balance() external view returns (uint);

    function setController(address _controller) external;

    function claimInsurance() external;

    function token() external view returns (address);

    function available() external view returns (uint);

    function withdrawFee(uint _amount) external view returns (uint);

    function earn() external;

    function calc_token_amount_deposit(uint[3] calldata amounts) external view returns (uint);

    function calc_token_amount_withdraw(uint _shares, address _output) external view returns (uint);

    function convert_rate(address _input, uint _amount) external view returns (uint);

    function deposit(uint _amount, address _input, uint _min_mint_amount, bool _isStake) external;

    function harvest(address reserve, uint amount) external;

    function withdraw(uint _shares, address _output) external;

    function want() external view returns (address);

    function getPricePerFullShare() external view returns (uint);

}// MIT

pragma solidity 0.6.12;

interface IStrategy {

    function balanceOf() external view returns (uint256);

    function balanceOfPool() external view returns (uint256);

    function balanceOfWant() external view returns (uint256);

    function deposit() external;

    function harvest() external;

    function name() external view returns (string memory);

    function skim() external;

    function want() external view returns (address);

    function withdraw(address) external;

    function withdraw(uint256) external;

    function withdrawAll() external;

}// MIT

pragma solidity 0.6.12;

interface IVaultManager {

    function controllers(address) external view returns (bool);

    function getHarvestFeeInfo() external view returns (address, address, uint256, address, uint256, address, uint256);

    function governance() external view returns (address);

    function harvester() external view returns (address);

    function insuranceFee() external view returns (uint256);

    function insurancePool() external view returns (address);

    function insurancePoolFee() external view returns (uint256);

    function stakingPool() external view returns (address);

    function stakingPoolShareFee() external view returns (uint256);

    function strategist() external view returns (address);

    function treasury() external view returns (address);

    function treasuryBalance() external view returns (uint256);

    function treasuryFee() external view returns (uint256);

    function vaults(address) external view returns (bool);

    function withdrawalProtectionFee() external view returns (uint256);

    function yax() external view returns (address);

}// MIT
pragma solidity 0.6.12;


contract StrategyControllerV2 is IController {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bool public globalInvestEnabled;
    uint256 public maxStrategies;
    IVaultManager public vaultManager;

    struct TokenStrategy {
        address[] strategies;
        mapping(address => uint256) index;
        mapping(address => bool) active;
        mapping(address => uint256) caps;
    }

    mapping(address => mapping(address => address)) public converters;
    mapping(address => TokenStrategy) internal tokenStrategies;
    mapping(address => address) public override strategyTokens;
    mapping(address => address) public override vaults;
    mapping(address => address) public vaultTokens;

    event Earn(address indexed strategy);

    event Harvest(address indexed strategy);

    event InsuranceClaimed(address indexed vault);

    event SetConverter(address input, address output, address converter);

    event SetVaultManager(address vaultManager);

    event StrategyAdded(address indexed token, address indexed strategy, uint256 cap);

    event StrategyRemoved(address indexed token, address indexed strategy);

    event StrategiesReordered(
        address indexed token,
        address indexed strategy1,
        address indexed strategy2
    );

    constructor(address _vaultManager) public {
        vaultManager = IVaultManager(_vaultManager);
        globalInvestEnabled = true;
        maxStrategies = 10;
    }


    function addStrategy(
        address _token,
        address _strategy,
        uint256 _cap,
        address _converter,
        bool _canHarvest,
        uint256 _timeout
    ) external onlyGovernance {

        require(!tokenStrategies[_token].active[_strategy], "active");
        address _want = IStrategy(_strategy).want();
        if (_want != IMetaVault(vaults[_token]).want()) {
            require(_converter != address(0), "!_converter");
            converters[_token][_want] = _converter;
            IConverter(_converter).setStrategy(_strategy, true);
        }
        uint256 index = tokenStrategies[_token].strategies.length;
        require(index < maxStrategies, "!maxStrategies");
        tokenStrategies[_token].strategies.push(_strategy);
        tokenStrategies[_token].caps[_strategy] = _cap;
        tokenStrategies[_token].index[_strategy] = index;
        tokenStrategies[_token].active[_strategy] = true;
        strategyTokens[_strategy] = _token;
        if (_canHarvest) {
            IHarvester(vaultManager.harvester()).addStrategy(_token, _strategy, _timeout);
        }
        emit StrategyAdded(_token, _strategy, _cap);
    }

    function claimInsurance(address _vault) external onlyGovernance {

        IMetaVault(_vault).claimInsurance();
        emit InsuranceClaimed(_vault);
    }

    function setVaultManager(address _vaultManager) external onlyGovernance {

        vaultManager = IVaultManager(_vaultManager);
        emit SetVaultManager(_vaultManager);
    }


    function inCaseStrategyGetStuck(
        address _strategy,
        address _token
    ) external onlyStrategist {

        IStrategy(_strategy).withdraw(_token);
        IERC20(_token).safeTransfer(
            vaultManager.governance(),
            IERC20(_token).balanceOf(address(this))
        );
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount
    ) external onlyStrategist {

        IERC20(_token).safeTransfer(vaultManager.governance(), _amount);
    }

    function removeStrategy(
        address _token,
        address _strategy,
        uint256 _timeout
    ) external onlyStrategist {

        TokenStrategy storage tokenStrategy = tokenStrategies[_token];
        require(tokenStrategy.active[_strategy], "!active");
        uint256 index = tokenStrategy.index[_strategy];
        uint256 tail = tokenStrategy.strategies.length.sub(1);
        address replace = tokenStrategy.strategies[tail];
        tokenStrategy.strategies[index] = replace;
        tokenStrategy.index[replace] = index;
        tokenStrategy.strategies.pop();
        delete tokenStrategy.index[_strategy];
        delete tokenStrategy.caps[_strategy];
        delete tokenStrategy.active[_strategy];
        IStrategy(_strategy).withdrawAll();
        IHarvester(vaultManager.harvester()).removeStrategy(_token, _strategy, _timeout);
        address _want = IStrategy(_strategy).want();
        if (_want != IMetaVault(vaults[_token]).want()) {
            IConverter(converters[_token][_want]).setStrategy(_strategy, false);
        }
        emit StrategyRemoved(_token, _strategy);
    }

    function reorderStrategies(
        address _token,
        address _strategy1,
        address _strategy2
    ) external onlyStrategist {

        require(_strategy1 != _strategy2, "_strategy1 == _strategy2");
        TokenStrategy storage tokenStrategy = tokenStrategies[_token];
        require(tokenStrategy.active[_strategy1]
             && tokenStrategy.active[_strategy2],
             "!active");
        uint256 index1 = tokenStrategy.index[_strategy1];
        uint256 index2 = tokenStrategy.index[_strategy2];
        tokenStrategy.strategies[index1] = _strategy2;
        tokenStrategy.strategies[index2] = _strategy1;
        tokenStrategy.index[_strategy1] = index2;
        tokenStrategy.index[_strategy2] = index1;
        emit StrategiesReordered(_token, _strategy1, _strategy2);
    }

    function setCap(
        address _token,
        address _strategy,
        uint256 _cap
    ) external onlyStrategist {

        require(tokenStrategies[_token].active[_strategy], "!active");
        tokenStrategies[_token].caps[_strategy] = _cap;
        uint256 _balance = IStrategy(_strategy).balanceOf();
        if (_balance > _cap && _cap != 0) {
            uint256 _diff = _balance.sub(_cap);
            IStrategy(_strategy).withdraw(_diff);
        }
    }

    function setConverter(
        address _input,
        address _output,
        address _converter
    ) external onlyStrategist {

        converters[_input][_output] = _converter;
        emit SetConverter(_input, _output, _converter);
    }

    function setInvestEnabled(bool _investEnabled) external onlyStrategist {

        globalInvestEnabled = _investEnabled;
    }

    function setMaxStrategies(uint256 _maxStrategies) external onlyStrategist {

        require(_maxStrategies > 0, "!_maxStrategies");
        maxStrategies = _maxStrategies;
    }

    function setVault(address _token, address _vault) external onlyStrategist {

        require(vaults[_token] == address(0), "vault");
        vaults[_token] = _vault;
        vaultTokens[_vault] = _token;
    }

    function withdrawAll(address _strategy) external onlyStrategist {

        IStrategy(_strategy).withdrawAll();
    }


    function harvestStrategy(address _strategy) external override onlyHarvester {

        IStrategy(_strategy).harvest();
        emit Harvest(_strategy);
    }


    function earn(address _token, uint256 _amount) external override onlyVault(_token) {

        address _strategy = getBestStrategyEarn(_token, _amount);
        address _want = IStrategy(_strategy).want();
        if (_want != _token) {
            address _converter = converters[_token][_want];
            IERC20(_token).safeTransfer(_converter, _amount);
            _amount = IConverter(_converter).convert(
                _token,
                _want,
                _amount
            );
            IERC20(_want).safeTransfer(_strategy, _amount);
        } else {
            IERC20(_token).safeTransfer(_strategy, _amount);
        }
        IStrategy(_strategy).deposit();
        emit Earn(_strategy);
    }

    function withdraw(address _token, uint256 _amount) external override onlyVault(_token) {

        (
            address[] memory _strategies,
            uint256[] memory _amounts
        ) = getBestStrategyWithdraw(_token, _amount);
        for (uint i = 0; i < _strategies.length; i++) {
            if (_strategies[i] == address(0)) {
                break;
            }
            IStrategy(_strategies[i]).withdraw(_amounts[i]);
        }
    }


    function balanceOf(address _token) external view override returns (uint256 _balance) {

        uint256 k = tokenStrategies[_token].strategies.length;
        for (uint i = 0; i < k; i++) {
            IStrategy _strategy = IStrategy(tokenStrategies[_token].strategies[i]);
            address _want = _strategy.want();
            if (_want != _token) {
                address _converter = converters[_token][_want];
                _balance = _balance.add(IConverter(_converter).convert_rate(
                    _want,
                    _token,
                    _strategy.balanceOf()
               ));
            } else {
                _balance = _balance.add(_strategy.balanceOf());
            }
        }
    }

    function getCap(address _token, address _strategy) external view returns (uint256) {

        return tokenStrategies[_token].caps[_strategy];
    }

    function investEnabled() external view override returns (bool) {

        if (globalInvestEnabled) {
            return tokenStrategies[vaultTokens[msg.sender]].strategies.length > 0;
        }
        return false;
    }

    function strategies(address _token) external view returns (address[] memory) {

        return tokenStrategies[_token].strategies;
    }

    function want(address _token) external view override returns (address) {

        return IMetaVault(vaults[_token]).want();
    }

    function withdrawFee(
        address,
        uint256 _amount
    ) external view override returns (uint256 _fee) {

        return vaultManager.withdrawalProtectionFee().mul(_amount).div(10000);
    }


    function getBestStrategyEarn(
        address _token,
        uint256 _amount
    ) public view returns (address _strategy) {

        uint256 k = tokenStrategies[_token].strategies.length;
        for (uint i = k; i > 0; i--) {
            _strategy = tokenStrategies[_token].strategies[i - 1];
            uint256 balance = IStrategy(_strategy).balanceOf().add(_amount);
            uint256 cap = tokenStrategies[_token].caps[_strategy];
            if (balance <= cap || cap == 0) {
                break;
            }
        }
    }

    function getBestStrategyWithdraw(
        address _token,
        uint256 _amount
    ) public view returns (
        address[] memory _strategies,
        uint256[] memory _amounts
    ) {

        uint256 k = tokenStrategies[_token].strategies.length;
        _strategies = new address[](k);
        _amounts = new uint256[](k);
        for (uint i = 0; i < k; i++) {
            address _strategy = tokenStrategies[_token].strategies[i];
            _strategies[i] = _strategy;
            uint256 _balance = IStrategy(_strategy).balanceOf();
            if (_balance < _amount) {
                _amounts[i] = _balance;
                _amount = _amount.sub(_balance);
            } else {
                _amounts[i] = _amount;
                break;
            }
        }
    }


    modifier onlyGovernance() {

        require(msg.sender == vaultManager.governance(), "!governance");
        _;
    }

    modifier onlyStrategist() {

        require(msg.sender == vaultManager.strategist()
             || msg.sender == vaultManager.governance(),
             "!strategist"
        );
        _;
    }

    modifier onlyHarvester() {

        require(
            msg.sender == vaultManager.harvester() ||
            msg.sender == vaultManager.strategist() ||
            msg.sender == vaultManager.governance(),
            "!harvester"
        );
        _;
    }

    modifier onlyVault(address _token) {

        require(msg.sender == vaults[_token], "!vault");
        _;
    }
}