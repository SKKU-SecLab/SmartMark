
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

pragma solidity 0.6.12;

interface IConvexVault {

    function poolInfo(uint256 pid)
        external
        view
        returns (
            address lptoken,
            address token,
            address gauge,
            address crvRewards,
            address stash,
            bool shutdown
        );


    function deposit(
        uint256 pid,
        uint256 amount,
        bool stake
    ) external returns (bool);


    function depositAll(uint256 pid, bool stake) external returns (bool);


    function withdraw(uint256 pid, uint256 amount) external returns (bool);


    function withdrawAll(uint256 pid) external returns (bool);

}

interface IConvexRewards {

    function getReward(address _account, bool _claimExtras) external returns (bool);


    function extraRewardsLength() external view returns (uint256);


    function extraRewards(uint256 _pid) external view returns (address);


    function rewardToken() external view returns (address);


    function earned(address _account) external view returns (uint256);

}// MIT

pragma solidity ^0.6.2;

interface ExtendedIERC20 {

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

}// MIT

pragma solidity 0.6.12;

interface IStableSwapPool {

    function coins(uint256) external view returns (address);

    function get_virtual_price() external view returns (uint);

}// MIT

pragma solidity 0.6.12;

interface IStableSwap2Pool {

    function get_virtual_price() external view returns (uint256);


    function balances(uint256) external view returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256 dy);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount) external;


    function remove_liquidity(uint256 _amount, uint256[2] calldata amounts) external;


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external;


    function calc_token_amount(uint256[2] calldata amounts, bool deposit)
        external
        view
        returns (uint256);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i)
        external
        view
        returns (uint256);

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

interface IStableSwap3Pool {

    function get_virtual_price() external view returns (uint);

    function balances(uint) external view returns (uint);

    function coins(uint) external view returns (address);

    function get_dy(int128 i, int128 j, uint dx) external view returns (uint dy);

    function exchange(int128 i, int128 j, uint dx, uint min_dy) external;

    function add_liquidity(uint[3] calldata amounts, uint min_mint_amount) external;

    function remove_liquidity(uint _amount, uint[3] calldata amounts) external;

    function remove_liquidity_one_coin(uint _token_amount, int128 i, uint min_amount) external;

    function calc_token_amount(uint[3] calldata amounts, bool deposit) external view returns (uint);

    function calc_withdraw_one_coin(uint _token_amount, int128 i) external view returns (uint);

}// MIT
pragma solidity ^0.6.2;

interface ISwap {

    function swapExactTokensForTokens(uint256, uint256, address[] calldata, address, uint256) external;

    function getAmountsOut(uint256, address[] calldata) external view returns (uint256[] memory);

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



abstract contract BaseStrategy is IStrategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 public constant ONE_HUNDRED_PERCENT = 10000;

    address public immutable override want;
    address public immutable override weth;
    address public immutable controller;
    IManager public immutable override manager;
    string public override name;
    address[] public routerArray;
    ISwap public override router;

    constructor(
        string memory _name,
        address _controller,
        address _manager,
        address _want,
        address _weth,
        address[] memory _routerArray
    ) public {
        name = _name;
        want = _want;
        controller = _controller;
        manager = IManager(_manager);
        weth = _weth;
        require(_routerArray.length > 0, "Must input at least one router");
        routerArray = _routerArray;
        router = ISwap(_routerArray[0]);
        for(uint i = 0; i < _routerArray.length; i++) {
            IERC20(_weth).safeApprove(address(_routerArray[i]), 0);
            IERC20(_weth).safeApprove(address(_routerArray[i]), type(uint256).max);
        }
        
    }


    function approveForSpender(
        IERC20 _token,
        address _spender,
        uint256 _amount
    )
        external
    {
        require(msg.sender == manager.governance(), "!governance");
        _token.safeApprove(_spender, 0);
        _token.safeApprove(_spender, _amount);
    }

     function setRouter(
        address[] calldata _routerArray,
        address[] calldata _tokenArray
    )
        external
    {
        require(msg.sender == manager.governance(), "!governance");
        routerArray = _routerArray;
        router = ISwap(_routerArray[0]);
        address _router;
        uint256 _routerLength = _routerArray.length;
        uint256 _tokenArrayLength = _tokenArray.length;
        for(uint i = 0; i < _routerLength; i++) {
            _router = _routerArray[i];
            IERC20(weth).safeApprove(_router, 0);
            IERC20(weth).safeApprove(_router, type(uint256).max);
            for(uint j = 0; j < _tokenArrayLength; j++) {
                IERC20(_tokenArray[j]).safeApprove(_router, 0);
                IERC20(_tokenArray[j]).safeApprove(_router, type(uint256).max);
            }
        }

    }
    
     function setDefaultRouter(
        uint256 _routerIndex
    )
        external
    {
    	require(msg.sender == manager.governance(), "!governance");
    	router = ISwap(routerArray[_routerIndex]);
    }


    function deposit()
        external
        override
        onlyController
    {
        _deposit();
    }

    function harvest(
        uint256[] calldata _estimates
    )
        external
        override
        onlyController
    {
        _harvest(_estimates);
    }

    function skim()
        external
        override
        onlyController
    {
        IERC20(want).safeTransfer(controller, balanceOfWant());
    }

    function withdraw(
        address _asset
    )
        external
        override
        onlyController
    {
        require(want != _asset, "want");

        IERC20 _assetToken = IERC20(_asset);
        uint256 _balance = _assetToken.balanceOf(address(this));
        _assetToken.safeTransfer(controller, _balance);
    }

    function withdraw(
        uint256 _amount
    )
        external
        override
        onlyController
    {
        uint256 _balance = balanceOfWant();
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        IERC20(want).safeTransfer(controller, _amount);
    }

    function withdrawAll()
        external
        override
        onlyController
    {
        _withdrawAll();

        uint256 _balance = IERC20(want).balanceOf(address(this));

        IERC20(want).safeTransfer(controller, _balance);
    }


    function balanceOf()
        external
        view
        override
        returns (uint256)
    {
        return balanceOfWant().add(balanceOfPool());
    }


    function balanceOfPool()
        public
        view
        virtual
        override
        returns (uint256);

    function balanceOfWant()
        public
        view
        override
        returns (uint256)
    {
        return IERC20(want).balanceOf(address(this));
    }


    function _deposit()
        internal
        virtual;

    function _harvest(
        uint256[] calldata _estimates
    )
        internal
        virtual;

    function _payHarvestFees(
        address _poolToken,
        uint256 _estimatedWETH,
        uint256 _estimatedYAXIS,
        uint256 _routerIndex
    )
        internal
        returns (uint256 _wethBal)
    {
        uint256 _amount = IERC20(_poolToken).balanceOf(address(this));
        _swapTokens(_poolToken, weth, _amount, _estimatedWETH);
        _wethBal = IERC20(weth).balanceOf(address(this));

        if (_wethBal > 0) {
            (
                address yaxis,
                address treasury,
                uint256 treasuryFee
            ) = manager.getHarvestFeeInfo();

            uint256 _fee;

            if (treasuryFee > 0 && treasury != address(0)) {
                _fee = _wethBal.mul(treasuryFee).div(ONE_HUNDRED_PERCENT);

                _swapTokensWithRouterIndex(weth, yaxis, _fee, _estimatedYAXIS, _routerIndex);
                IERC20(yaxis).safeTransfer(treasury, IERC20(yaxis).balanceOf(address(this)));
            }

            _wethBal = IERC20(weth).balanceOf(address(this));
        }
    }

    function _swapTokensWithRouterIndex(
        address _input,
        address _output,
        uint256 _amount,
        uint256 _expected,
        uint256 _routerIndex
    )
        internal
    {
        address[] memory path = new address[](2);
        path[0] = _input;
        path[1] = _output;
        ISwap(routerArray[_routerIndex]).swapExactTokensForTokens(
            _amount,
            _expected,
            path,
            address(this),
            1e10
        );
    }
    
    function _swapTokens(
        address _input,
        address _output,
        uint256 _amount,
        uint256 _expected
    )
        internal
    {
        address[] memory path = new address[](2);
        path[0] = _input;
        path[1] = _output;
        router.swapExactTokensForTokens(
            _amount,
            _expected,
            path,
            address(this),
            1e10
        );
    }

    function _withdraw(
        uint256 _amount
    )
        internal
        virtual;

    function _withdrawAll()
        internal
        virtual;

    function _withdrawSome(
        uint256 _amount
    )
        internal
        returns (uint256)
    {
        uint256 _before = IERC20(want).balanceOf(address(this));
        _withdraw(_amount);
        uint256 _after = IERC20(want).balanceOf(address(this));
        _amount = _after.sub(_before);

        return _amount;
    }


    modifier onlyStrategist() {
        require(msg.sender == manager.strategist(), "!strategist");
        _;
    }

    modifier onlyController() {
        require(msg.sender == controller, "!controller");
        _;
    }
}// MIT

pragma solidity 0.6.12;

interface ICVXMinter {

    function maxSupply() external view returns (uint256);

    function totalCliffs() external view returns (uint256);

    function reductionPerCliff() external view returns (uint256);

}// MIT

pragma solidity 0.6.12;


interface IHarvester {

    function addStrategy(address, address, uint256) external;

    function manager() external view returns (IManager);

    function removeStrategy(address, address, uint256) external;

    function slippage() external view returns (uint256);

}// MIT

pragma solidity 0.6.12;



contract GeneralConvexStrategy is BaseStrategy {

    using SafeMath for uint8;

    address public immutable crv;
    address public immutable cvx;

    uint256 public immutable pid;
    IConvexVault public immutable convexVault;
    address public immutable cvxDepositLP;
    IConvexRewards public immutable crvRewards;
    address public immutable stableSwapPool;

    address[] public tokens;
    uint8[] public decimalMultiples;

    constructor(
        string memory _name,
        address _want,
        address _crv,
        address _cvx,
        address _weth,
        uint256 _pid,
        uint256 _coinCount,
        IConvexVault _convexVault,
        address _stableSwapPool,
        address _controller,
        address _manager,
        address[] memory _routerArray // [1] should be set to Uniswap router
    ) public BaseStrategy(_name, _controller, _manager, _want, _weth, _routerArray) {
        require(_coinCount == 2 || _coinCount == 3, '_coinCount should be 2 or 3');
        require(address(_crv) != address(0), '!_crv');
        require(address(_cvx) != address(0), '!_cvx');
        require(address(_convexVault) != address(0), '!_convexVault');
        require(address(_stableSwapPool) != address(0), '!_stableSwapPool');

        (, address _token, , address _crvRewards, , ) = _convexVault.poolInfo(_pid);
        crv = _crv;
        cvx = _cvx;
        pid = _pid;
        convexVault = _convexVault;
        cvxDepositLP = _token;
        crvRewards = IConvexRewards(_crvRewards);
        stableSwapPool = _stableSwapPool;

        for (uint256 i = 0; i < _coinCount; i++) {
            tokens.push(IStableSwapPool(_stableSwapPool).coins(i));
            decimalMultiples.push(18 - ExtendedIERC20(tokens[i]).decimals());
            IERC20(tokens[i]).safeApprove(_stableSwapPool, type(uint256).max);
        }

        IERC20(_want).safeApprove(address(_convexVault), type(uint256).max);
        IERC20(_want).safeApprove(address(_stableSwapPool), type(uint256).max);
        _setApprovals(_cvx, _crv, _routerArray);
    }

    function _setApprovals(
    	address _cvx,
    	address _crv,
    	address[] memory _routerArray
    ) internal {

    	uint _routerArrayLength = _routerArray.length;
        for(uint i=0; i<_routerArrayLength; i++) {
            address _router = _routerArray[i];
            IERC20(_crv).safeApprove(address(_router), 0);
            IERC20(_crv).safeApprove(address(_router), type(uint256).max);
            IERC20(_cvx).safeApprove(address(_router), 0);
            IERC20(_cvx).safeApprove(address(_router), type(uint256).max);	
    	}
    }	
    
    function _deposit() internal override {

        convexVault.depositAll(pid, true);
    }

    function _claimReward() internal {

        crvRewards.getReward(address(this), true);
    }

    function _addLiquidity(uint256 _estimate) internal {

        if (tokens.length == 2) {
            uint256[2] memory amounts;
            amounts[0] = IERC20(tokens[0]).balanceOf(address(this));
            amounts[1] = IERC20(tokens[1]).balanceOf(address(this));
            IStableSwap2Pool(stableSwapPool).add_liquidity(amounts, _estimate);
            return;
        }

        uint256[3] memory amounts;
        amounts[0] = IERC20(tokens[0]).balanceOf(address(this));
        amounts[1] = IERC20(tokens[1]).balanceOf(address(this));
        amounts[2] = IERC20(tokens[2]).balanceOf(address(this));
        IStableSwap3Pool(stableSwapPool).add_liquidity(amounts, _estimate);
    }

    function getMostPremium() public view returns (address, uint256) {

        uint256 balance0 = IStableSwap3Pool(stableSwapPool).balances(0).mul(
            10**(decimalMultiples[0])
        );
        uint256 balance1 = IStableSwap3Pool(stableSwapPool).balances(1).mul(
            10**(decimalMultiples[1])
        );

        if (tokens.length == 2) {
            if (balance0 > balance1) {
                return (tokens[1], 1);
            }

            return (tokens[0], 0);
        }

        uint256 balance2 = IStableSwap3Pool(stableSwapPool).balances(2).mul(
            10**(decimalMultiples[2])
        );

        if (balance0 < balance1 && balance0 < balance2) {
            return (tokens[0], 0);
        }

        if (balance1 < balance0 && balance1 < balance2) {
            return (tokens[1], 1);
        }

        if (balance2 < balance0 && balance2 < balance1) {
            return (tokens[2], 2);
        }

        return (tokens[0], 0);
    }

    function _harvest(uint256[] calldata _estimates) internal override {

        _claimReward();
        uint256 _cvxBalance = IERC20(cvx).balanceOf(address(this));
        if (_cvxBalance > 0) {
            _swapTokens(cvx, weth, _cvxBalance, _estimates[0]);
        }

        uint256 _extraRewardsLength = crvRewards.extraRewardsLength();
        for (uint256 i = 0; i < _extraRewardsLength; i++) {
            address _rewardToken = IConvexRewards(crvRewards.extraRewards(i)).rewardToken();
            uint256 _extraRewardBalance = IERC20(_rewardToken).balanceOf(address(this));
            if (_extraRewardBalance > 0) {
                _swapTokens(_rewardToken, weth, _extraRewardBalance, _estimates[i+1]);
            }
        }
        uint256 _remainingWeth = _payHarvestFees(crv, _estimates[_extraRewardsLength + 1], _estimates[_extraRewardsLength + 2], 1);
        if (_remainingWeth > 0) {
            (address _targetCoin, ) = getMostPremium();
            _swapTokens(weth, _targetCoin, _remainingWeth, _estimates[_extraRewardsLength + 3]);
            _addLiquidity(_estimates[_extraRewardsLength + 4]);

            if (balanceOfWant() > 0) {
                _deposit();
            }
        }
    }

    function getEstimates() external view returns (uint256[] memory) {

    	
        uint rewardsLength = crvRewards.extraRewardsLength();
        uint256[] memory _estimates = new uint256[](rewardsLength.add(5));
        address[] memory _path = new address[](2);
        uint256[] memory _amounts;
        uint256 _notSlippage = ONE_HUNDRED_PERCENT.sub(IHarvester(manager.harvester()).slippage());
        uint256 wethAmount;

        _path[0] = cvx;
        _path[1] = weth;
        _amounts = router.getAmountsOut(
            (crvRewards.earned(address(this)))
            .mul(ICVXMinter(cvx).totalCliffs().sub(ICVXMinter(cvx).maxSupply().div(ICVXMinter(cvx).reductionPerCliff())))
            .div(ICVXMinter(cvx).totalCliffs()),
            _path
        );
        _estimates[0]= _amounts[1].mul(_notSlippage).div(ONE_HUNDRED_PERCENT);

        wethAmount += _estimates[0];

        
        if (rewardsLength > 0) {
            for (uint256 i = 0; i < rewardsLength; i++) {
                _path[0] = IConvexRewards(crvRewards.extraRewards(i)).rewardToken();
                _path[1] = weth;
                _amounts = router.getAmountsOut(
                    IConvexRewards(crvRewards.extraRewards(i)).earned(address(this)),
                    _path
                );
                _estimates[i + 1] = _amounts[1].mul(_notSlippage).div(ONE_HUNDRED_PERCENT);

                wethAmount += _estimates[i + 1];
            }
        }

        _path[0] = crv;
        _path[1] = weth;
        _amounts = router.getAmountsOut(
            crvRewards.earned(address(this)),
            _path
        );
        _estimates[rewardsLength + 1] = _amounts[1].mul(_notSlippage).div(ONE_HUNDRED_PERCENT);

        wethAmount += _estimates[rewardsLength + 1];

        _path[0] = weth;
        _path[1] = manager.yaxis();
        _amounts = ISwap(routerArray[1]).getAmountsOut(wethAmount.mul(manager.treasuryFee()).div(ONE_HUNDRED_PERCENT), _path); // Set to UniswapV2 to calculate output for YAXIS
        _estimates[rewardsLength + 2] = _amounts[1].mul(_notSlippage).div(ONE_HUNDRED_PERCENT);
        
        (address _targetCoin,) = getMostPremium(); 
        _path[0] = weth;
        _path[1] = _targetCoin;
        _amounts = router.getAmountsOut(
            wethAmount - _amounts[0],
            _path
        );
        _estimates[rewardsLength + 3] = _amounts[1].mul(_notSlippage).div(ONE_HUNDRED_PERCENT);

        _estimates[rewardsLength + 4] = _amounts[1].mul(_notSlippage).div(ONE_HUNDRED_PERCENT).mul(10**(18-ExtendedIERC20(_targetCoin).decimals())).div(IStableSwapPool(stableSwapPool).get_virtual_price());
        
        return _estimates;
    }

    function _withdrawAll() internal override {

        convexVault.withdrawAll(pid);
    }

    function _withdraw(uint256 _amount) internal override {

        convexVault.withdraw(pid, _amount);
    }

    function balanceOfPool() public view override returns (uint256) {

        return IERC20(cvxDepositLP).balanceOf(address(this));
    }
}