

pragma solidity 0.6.12;

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

interface IMultiVaultStrategy {

    function want() external view returns (address);

    function deposit() external;

    function withdraw(address _asset) external;

    function withdraw(uint _amount) external returns (uint);

    function withdrawToController(uint _amount) external;

    function skim() external;

    function harvest(address _mergedStrategy) external;

    function withdrawAll() external returns (uint);

    function balanceOf() external view returns (uint);

    function withdrawFee(uint) external view returns (uint); // pJar: 0.5% (50/10000)

}

interface IValueMultiVault {

    function cap() external view returns (uint);

    function getConverter(address _want) external view returns (address);

    function getVaultMaster() external view returns (address);

    function balance() external view returns (uint);

    function token() external view returns (address);

    function available(address _want) external view returns (uint);

    function accept(address _input) external view returns (bool);


    function claimInsurance() external;

    function earn(address _want) external;

    function harvest(address reserve, uint amount) external;


    function withdraw_fee(uint _shares) external view returns (uint);

    function calc_token_amount_deposit(uint[] calldata _amounts) external view returns (uint);

    function calc_token_amount_withdraw(uint _shares, address _output) external view returns (uint);

    function convert_rate(address _input, uint _amount) external view returns (uint);

    function getPricePerFullShare() external view returns (uint);

    function get_virtual_price() external view returns (uint); // average dollar value of vault share token


    function deposit(address _input, uint _amount, uint _min_mint_amount) external returns (uint _mint_amount);

    function depositFor(address _account, address _to, address _input, uint _amount, uint _min_mint_amount) external returns (uint _mint_amount);

    function depositAll(uint[] calldata _amounts, uint _min_mint_amount) external returns (uint _mint_amount);

    function depositAllFor(address _account, address _to, uint[] calldata _amounts, uint _min_mint_amount) external returns (uint _mint_amount);

    function withdraw(uint _shares, address _output, uint _min_output_amount) external returns (uint);

    function withdrawFor(address _account, uint _shares, address _output, uint _min_output_amount) external returns (uint _output_amount);


    function harvestStrategy(address _strategy) external;

    function harvestWant(address _want) external;

    function harvestAllStrategies() external;

}

interface IShareConverter {

    function convert_shares_rate(address _input, address _output, uint _inputAmount) external view returns (uint _outputAmount);


    function convert_shares(address _input, address _output, uint _inputAmount) external returns (uint _outputAmount);

}

interface Converter {

    function convert(address) external returns (uint);

}

contract MultiStablesVaultController {

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    address public governance;
    address public strategist;

    struct StrategyInfo {
        address strategy;
        uint quota; // set = 0 to disable
        uint percent;
    }

    IValueMultiVault public vault;

    address public basedWant;
    address[] public wantTokens; // sorted by preference

    mapping(address => uint) public wantQuota;
    mapping(address => uint) public wantStrategyLength;

    mapping(address => mapping(uint => StrategyInfo)) public strategies;

    mapping(address => mapping(address => bool)) public approvedStrategies;

    mapping(address => bool) public investDisabled;
    IShareConverter public shareConverter; // converter for shares (3CRV <-> BCrv, etc ...)
    address public lazySelectedBestStrategy; // we pre-set the best strategy to avoid gas cost of iterating the array

    constructor(IValueMultiVault _vault) public {
        require(address(_vault) != address(0), "!_vault");
        vault = _vault;
        basedWant = vault.token();
        governance = msg.sender;
        strategist = msg.sender;
    }

    function setGovernance(address _governance) external {

        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setStrategist(address _strategist) external {

        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function approveStrategy(address _want, address _strategy) external {

        require(msg.sender == governance, "!governance");
        approvedStrategies[_want][_strategy] = true;
    }

    function revokeStrategy(address _want, address _strategy) external {

        require(msg.sender == governance, "!governance");
        approvedStrategies[_want][_strategy] = false;
    }

    function setWantQuota(address _want, uint _quota) external {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        wantQuota[_want] = _quota;
    }

    function setWantStrategyLength(address _want, uint _length) external {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        wantStrategyLength[_want] = _length;
    }

    function setStrategyInfo(address _want, uint _sid, address _strategy, uint _quota, uint _percent) external {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        require(approvedStrategies[_want][_strategy], "!approved");
        strategies[_want][_sid].strategy = _strategy;
        strategies[_want][_sid].quota = _quota;
        strategies[_want][_sid].percent = _percent;
    }

    function setShareConverter(IShareConverter _shareConverter) external {

        require(msg.sender == governance, "!governance");
        shareConverter = _shareConverter;
    }

    function setInvestDisabled(address _want, bool _investDisabled) external {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        investDisabled[_want] = _investDisabled;
    }

    function setWantTokens(address[] memory _wantTokens) external {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        delete wantTokens;
        uint _wlength = _wantTokens.length;
        for (uint i = 0; i < _wlength; ++i) {
            wantTokens.push(_wantTokens[i]);
        }
    }

    function getStrategyCount() external view returns(uint _strategyCount) {

        _strategyCount = 0;
        uint _wlength = wantTokens.length;
        for (uint i = 0; i < _wlength; i++) {
            _strategyCount = _strategyCount.add(wantStrategyLength[wantTokens[i]]);
        }
    }

    function wantLength() external view returns (uint) {

        return wantTokens.length;
    }

    function wantStrategyBalance(address _want) public view returns (uint) {

        uint _bal = 0;
        for (uint _sid = 0; _sid < wantStrategyLength[_want]; _sid++) {
            _bal = _bal.add(IMultiVaultStrategy(strategies[_want][_sid].strategy).balanceOf());
        }
        return _bal;
    }

    function want() external view returns (address) {

        if (lazySelectedBestStrategy != address(0)) {
            return IMultiVaultStrategy(lazySelectedBestStrategy).want();
        }
        uint _wlength = wantTokens.length;
        if (_wlength > 0) {
            if (_wlength == 1) {
                return wantTokens[0];
            }
            for (uint i = 0; i < _wlength; i++) {
                address _want = wantTokens[i];
                uint _bal = wantStrategyBalance(_want);
                if (_bal < wantQuota[_want]) {
                    return _want;
                }
            }
        }
        return basedWant;
    }

    function setLazySelectedBestStrategy(address _strategy) external {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        lazySelectedBestStrategy = _strategy;
    }

    function getBestStrategy(address _want) public view returns (address _strategy) {

        if (lazySelectedBestStrategy != address(0) && IMultiVaultStrategy(lazySelectedBestStrategy).want() == _want) {
            return lazySelectedBestStrategy;
        }
        uint _wantStrategyLength = wantStrategyLength[_want];
        _strategy = address(0);
        if (_wantStrategyLength == 0) return _strategy;
        uint _totalBal = wantStrategyBalance(_want);
        if (_totalBal == 0) {
            return strategies[_want][0].strategy;
        }
        uint _bestDiff = 201;
        for (uint _sid = 0; _sid < _wantStrategyLength; _sid++) {
            StrategyInfo storage sinfo = strategies[_want][_sid];
            uint _stratBal = IMultiVaultStrategy(sinfo.strategy).balanceOf();
            if (_stratBal < sinfo.quota) {
                uint _diff = _stratBal.add(_totalBal).mul(100).div(_totalBal).sub(sinfo.percent); // [100, 200] - [percent]
                if (_diff < _bestDiff) {
                    _bestDiff = _diff;
                    _strategy = sinfo.strategy;
                }
            }
        }
        if (_strategy == address(0)) {
            _strategy = strategies[_want][0].strategy;
        }
    }

    function earn(address _token, uint _amount) external {

        require(msg.sender == address(vault) || msg.sender == strategist || msg.sender == governance, "!strategist");
        address _strategy = getBestStrategy(_token);
        if (_strategy == address(0) || IMultiVaultStrategy(_strategy).want() != _token) {
            IERC20(_token).safeTransfer(address(vault), _amount);
        } else {
            IERC20(_token).safeTransfer(_strategy, _amount);
            IMultiVaultStrategy(_strategy).deposit();
        }
    }

    function withdraw_fee(address _want, uint _amount) external view returns (uint) {

        address _strategy = getBestStrategy(_want);
        return (_strategy == address(0)) ? 0 : IMultiVaultStrategy(_strategy).withdrawFee(_amount);
    }

    function balanceOf(address _want, bool _sell) external view returns (uint _totalBal) {

        uint _wlength = wantTokens.length;
        if (_wlength == 0) {
            return 0;
        }
        _totalBal = 0;
        for (uint i = 0; i < _wlength; i++) {
            address wt = wantTokens[i];
            uint _bal = wantStrategyBalance(wt);
            if (wt != _want) {
                _bal = shareConverter.convert_shares_rate(wt, _want, _bal);
                if (_sell) {
                    _bal = _bal.mul(9998).div(10000); // minus 0.02% for selling
                }
            }
            _totalBal = _totalBal.add(_bal);
        }
    }

    function withdrawAll(address _strategy) external {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        IMultiVaultStrategy(_strategy).withdrawAll();
    }

    function inCaseTokensGetStuck(address _token, uint _amount) external {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        IERC20(_token).safeTransfer(address(vault), _amount);
    }

    function inCaseStrategyGetStuck(address _strategy, address _token) external {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        IMultiVaultStrategy(_strategy).withdraw(_token);
        IERC20(_token).safeTransfer(address(vault), IERC20(_token).balanceOf(address(this)));
    }

    function claimInsurance() external {

        require(msg.sender == governance, "!governance");
        vault.claimInsurance();
    }

    function harvestStrategy(address _strategy) external {

        require(msg.sender == address(vault) || msg.sender == strategist || msg.sender == governance, "!strategist && !vault");
        IMultiVaultStrategy(_strategy).harvest(address(0));
    }

    function harvestWant(address _want) external {

        require(msg.sender == address(vault) || msg.sender == strategist || msg.sender == governance, "!strategist && !vault");
        uint _wantStrategyLength = wantStrategyLength[_want];
        address _firstStrategy = address(0); // to send all harvested WETH and proceed the profit sharing all-in-one here
        for (uint _sid = 0; _sid < _wantStrategyLength; _sid++) {
            StrategyInfo storage sinfo = strategies[_want][_sid];
            if (_firstStrategy == address(0)) {
                _firstStrategy = sinfo.strategy;
            } else {
                IMultiVaultStrategy(sinfo.strategy).harvest(_firstStrategy);
            }
        }
        if (_firstStrategy != address(0)) {
            IMultiVaultStrategy(_firstStrategy).harvest(address(0));
        }
    }

    function harvestAllStrategies() external {

        require(msg.sender == address(vault) || msg.sender == strategist || msg.sender == governance, "!strategist && !vault");
        uint _wlength = wantTokens.length;
        address _firstStrategy = address(0); // to send all harvested WETH and proceed the profit sharing all-in-one here
        for (uint i = 0; i < _wlength; i++) {
            address _want = wantTokens[i];
            uint _wantStrategyLength = wantStrategyLength[_want];
            for (uint _sid = 0; _sid < _wantStrategyLength; _sid++) {
                StrategyInfo storage sinfo = strategies[_want][_sid];
                if (_firstStrategy == address(0)) {
                    _firstStrategy = sinfo.strategy;
                } else {
                    IMultiVaultStrategy(sinfo.strategy).harvest(_firstStrategy);
                }
            }
        }
        if (_firstStrategy != address(0)) {
            IMultiVaultStrategy(_firstStrategy).harvest(address(0));
        }
    }

    function switchFund(IMultiVaultStrategy _srcStrat, IMultiVaultStrategy _destStrat, uint _amount) external {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        _srcStrat.withdrawToController(_amount);
        address _srcWant = _srcStrat.want();
        address _destWant = _destStrat.want();
        if (_srcWant != _destWant) {
            _amount = IERC20(_srcWant).balanceOf(address(this));
            require(shareConverter.convert_shares_rate(_srcWant, _destWant, _amount) > 0, "rate=0");
            IERC20(_srcWant).safeTransfer(address(shareConverter), _amount);
            shareConverter.convert_shares(_srcWant, _destWant, _amount);
        }
        IERC20(_destWant).safeTransfer(address(_destStrat), IERC20(_destWant).balanceOf(address(this)));
        _destStrat.deposit();
    }

    function withdraw(address _want, uint _amount) external returns (uint _withdrawFee) {

        require(msg.sender == address(vault), "!vault");
        _withdrawFee = 0;
        uint _toWithdraw = _amount;
        uint _wantStrategyLength = wantStrategyLength[_want];
        uint _received;
        for (uint _sid = _wantStrategyLength; _sid > 0; _sid--) {
            StrategyInfo storage sinfo = strategies[_want][_sid - 1];
            IMultiVaultStrategy _strategy = IMultiVaultStrategy(sinfo.strategy);
            uint _stratBal = _strategy.balanceOf();
            if (_toWithdraw < _stratBal) {
                _received = _strategy.withdraw(_toWithdraw);
                _withdrawFee = _withdrawFee.add(_strategy.withdrawFee(_received));
                return _withdrawFee;
            }
            _received = _strategy.withdrawAll();
            _withdrawFee = _withdrawFee.add(_strategy.withdrawFee(_received));
            if (_received >= _toWithdraw) {
                return _withdrawFee;
            }
            _toWithdraw = _toWithdraw.sub(_received);
        }
        if (_toWithdraw > 0) {
            uint _wlength = wantTokens.length;
            for (uint i = _wlength; i > 0; i--) {
                address wt = wantTokens[i - 1];
                if (wt != _want) {
                    (uint _wamt, uint _wdfee) = _withdrawOtherWant(_want, wt, _toWithdraw);
                    _withdrawFee = _withdrawFee.add(_wdfee);
                    if (_wamt >= _toWithdraw) {
                        return _withdrawFee;
                    }
                    _toWithdraw = _toWithdraw.sub(_wamt);
                }
            }
        }
        return _withdrawFee;
    }

    function _withdrawOtherWant(address _want, address _other, uint _amount) internal returns (uint _wantAmount, uint _withdrawFee) {

        uint b = IERC20(_want).balanceOf(address(this));
        _withdrawFee = 0;
        if (b >= _amount) {
            _wantAmount = b;
        } else {
            uint _toWithdraw = _amount.sub(b);
            uint _toWithdrawOther = _toWithdraw.mul(101).div(100); // add 1% extra
            uint _otherBal = IERC20(_other).balanceOf(address(this));
            if (_otherBal < _toWithdrawOther) {
                uint _otherStrategyLength = wantStrategyLength[_other];
                for (uint _sid = _otherStrategyLength; _sid > 0; _sid--) {
                    StrategyInfo storage sinfo = strategies[_other][_sid - 1];
                    IMultiVaultStrategy _strategy = IMultiVaultStrategy(sinfo.strategy);
                    uint _stratBal = _strategy.balanceOf();
                    uint _needed = _toWithdrawOther.sub(_otherBal);
                    uint _wdamt = (_needed < _stratBal) ? _needed : _stratBal;
                    _strategy.withdrawToController(_wdamt);
                    _withdrawFee = _withdrawFee.add(_strategy.withdrawFee(_wdamt));
                    _otherBal = IERC20(_other).balanceOf(address(this));
                    if (_otherBal >= _toWithdrawOther) {
                        break;
                    }
                }
            }
            IERC20(_other).safeTransfer(address(shareConverter), _otherBal);
            shareConverter.convert_shares(_other, _want, _otherBal);
            _wantAmount = IERC20(_want).balanceOf(address(this));
        }
        IERC20(_want).safeTransfer(address(vault), _wantAmount);
    }
}