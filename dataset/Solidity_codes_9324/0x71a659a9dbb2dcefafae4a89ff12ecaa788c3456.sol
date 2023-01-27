
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

pragma solidity 0.8.3;

interface IAddressList {

    function add(address a) external returns (bool);


    function remove(address a) external returns (bool);


    function get(address a) external view returns (uint256);


    function contains(address a) external view returns (bool);


    function length() external view returns (uint256);


    function grantRole(bytes32 role, address account) external;

}// MIT

pragma solidity 0.8.3;

interface IVesperPool is IERC20 {

    function deposit() external payable;


    function deposit(uint256 _share) external;


    function multiTransfer(address[] memory _recipients, uint256[] memory _amounts) external returns (bool);


    function excessDebt(address _strategy) external view returns (uint256);


    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;


    function poolRewards() external returns (address);


    function reportEarning(
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    ) external;


    function reportLoss(uint256 _loss) external;


    function resetApproval() external;


    function sweepERC20(address _fromToken) external;


    function withdraw(uint256 _amount) external;


    function withdrawETH(uint256 _amount) external;


    function whitelistedWithdraw(uint256 _amount) external;


    function governor() external view returns (address);


    function keepers() external view returns (IAddressList);


    function maintainers() external view returns (IAddressList);


    function feeCollector() external view returns (address);


    function pricePerShare() external view returns (uint256);


    function strategy(address _strategy)
        external
        view
        returns (
            bool _active,
            uint256 _interestFee,
            uint256 _debtRate,
            uint256 _lastRebalance,
            uint256 _totalDebt,
            uint256 _totalLoss,
            uint256 _totalProfit,
            uint256 _debtRatio
        );


    function stopEverything() external view returns (bool);


    function token() external view returns (IERC20);


    function tokensHere() external view returns (uint256);


    function totalDebtOf(address _strategy) external view returns (uint256);


    function totalValue() external view returns (uint256);


    function withdrawFee() external view returns (uint256);

}// MIT

pragma solidity 0.8.3;


interface IVFRCoveragePool is IVesperPool {

    function buffer() external view returns (address);

}// MIT

pragma solidity 0.8.3;


interface IVFRStablePool is IVesperPool {

    function targetAPY() external view returns (uint256);


    function buffer() external view returns (address);


    function targetPricePerShare() external view returns (uint256);


    function amountToReachTarget(address _strategy) external view returns (uint256);

}// MIT

pragma solidity 0.8.3;



contract VFRBuffer {

    address public token;
    address public stablePool;
    address public coveragePool;
    uint256 public coverageTime;

    event CoverageTimeUpdated(uint256 oldCoverageTime, uint256 newCoverageTime);

    constructor(
        address _stablePool,
        address _coveragePool,
        uint256 _coverageTime
    ) {
        address stablePoolToken = address(IVesperPool(_stablePool).token());
        address coveragePoolToken = address(IVesperPool(_coveragePool).token());
        require(stablePoolToken == coveragePoolToken, "non-matching-tokens");

        token = stablePoolToken;
        stablePool = _stablePool;
        coveragePool = _coveragePool;
        coverageTime = _coverageTime;
    }

    function target() external view returns (uint256 amount) {

        uint256 targetAPY = IVFRStablePool(stablePool).targetAPY();
        uint256 fromPricePerShare = IVFRStablePool(stablePool).pricePerShare();
        uint256 toPricePerShare =
            fromPricePerShare + (fromPricePerShare * targetAPY * coverageTime) / (365 * 24 * 3600 * 1e18);
        uint256 totalSupply = IVFRStablePool(stablePool).totalSupply();
        uint256 fromTotalValue = (fromPricePerShare * totalSupply) / 1e18;
        uint256 toTotalValue = (toPricePerShare * totalSupply) / 1e18;
        if (toTotalValue > fromTotalValue) {
            amount = toTotalValue - fromTotalValue;
        }
    }

    function request(uint256 _amount) public {

        (bool activeInStablePool, , , , , , , ) = IVFRStablePool(stablePool).strategy(msg.sender);
        (bool activeInCoveragePool, , , , , , , ) = IVFRCoveragePool(coveragePool).strategy(msg.sender);
        require(activeInStablePool || activeInCoveragePool, "invalid-strategy");
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance >= _amount, "insufficient-balance");
        IERC20(token).transfer(msg.sender, _amount);
    }

    function flush() public {

        require(IVFRStablePool(stablePool).keepers().contains(msg.sender), "not-a-keeper");
        IERC20(token).transfer(coveragePool, IERC20(token).balanceOf(address(this)));
    }

    function updateCoverageTime(uint256 _coverageTime) external {

        require(IVFRStablePool(stablePool).keepers().contains(msg.sender), "not-a-keeper");
        emit CoverageTimeUpdated(coverageTime, _coverageTime);
        coverageTime = _coverageTime;
    }
}