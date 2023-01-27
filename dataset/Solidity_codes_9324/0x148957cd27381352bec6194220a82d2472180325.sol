

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;




interface IERC3156FlashBorrower {

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);

}


interface ILendingPool {

    function liquidationCall(
        address _collateral,
        address _reserve,
        address _user,
        uint256 _purchaseAmount,
        bool _receiveAToken
    ) external payable;

}


interface ILendingPoolAddressesProvider {

    function getLendingPool() external view returns (address);

}


interface ITipJar {

    function tip() external payable;


    function updateMinerSplit(
        address minerAddress,
        address splitTo,
        uint32 splitPct
    ) external;


    function setFeeCollector(address newCollector) external;


    function setFee(uint32 newFee) external;


    function changeAdmin(address newAdmin) external;


    function upgradeTo(address newImplementation) external;


    function upgradeToAndCall(address newImplementation, bytes calldata data)
        external
        payable;

}


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
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


interface Uni {

    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;


    function swapExactETHForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}


interface IERC3156FlashLender {

    function maxFlashLoan(address token) external view returns (uint256);


    function flashFee(address token, uint256 amount)
        external
        view
        returns (uint256);


    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

}


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract DeathGod is IERC3156FlashBorrower {

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    enum Action {NORMAL, OTHER}

    address public governance;
    mapping(address => bool) keepers;
    address public darkParadise;
    address public constant uni =
        address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public constant weth =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant sdt =
        address(0x73968b9a57c6E53d41345FD57a6E6ae27d6CDB2F);
    address public lendingPoolAddressProvider =
        address(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);

    IERC3156FlashLender lender;
    ITipJar public tipJar;

    modifier onlyGovernance() {

        require(msg.sender == governance, "!governance");
        _;
    }

    function() external payable {}

    constructor(
        address _keeper,
        address _darkParadise,
        IERC3156FlashLender _lender,
        address _tipJar
    ) public {
        governance = msg.sender;
        keepers[_keeper] = true;
        darkParadise = _darkParadise;
        lender = _lender;
        tipJar = ITipJar(_tipJar);
    }

    function setAaveLendingPoolAddressProvider(
        address _lendingPoolAddressProvider
    ) external onlyGovernance {

        lendingPoolAddressProvider = _lendingPoolAddressProvider;
    }

    function setLender(IERC3156FlashLender _lender) external onlyGovernance {

        lender = _lender;
    }

    function setTipJar(address _tipJar) external onlyGovernance {

        tipJar = ITipJar(_tipJar);
    }

    function setDarkParadise(address _darkParadise) external onlyGovernance {

        darkParadise = _darkParadise;
    }

    function setGovernance(address _governance) external onlyGovernance {

        governance = _governance;
    }

    function addKeeper(address _keeper) external onlyGovernance {

        keepers[_keeper] = true;
    }

    function removeKeeper(address _keeper) external onlyGovernance {

        keepers[_keeper] = false;
    }

    function sendSDTToDarkParadise(address _token, uint256 _amount)
        public
        payable
    {

        require(
            msg.sender == governance || keepers[msg.sender] == true,
            "Not authorised"
        );
        require(msg.value > 0, "tip amount must be > 0");
        require(
            _amount <= IERC20(_token).balanceOf(address(this)),
            "Not enough tokens"
        );
        tipJar.tip.value(msg.value)();

        IERC20(_token).safeApprove(uni, _amount);
        address[] memory path = new address[](3);
        path[0] = _token;
        path[1] = weth;
        path[2] = sdt;

        uint256 _sdtBefore = IERC20(sdt).balanceOf(address(this));
        Uni(uni).swapExactTokensForTokens(
            _amount,
            uint256(0),
            path,
            address(this),
            now.add(1800)
        );
        uint256 _sdtAfter = IERC20(sdt).balanceOf(address(this));

        IERC20(sdt).safeTransfer(darkParadise, _sdtAfter.sub(_sdtBefore));
    }

    function liquidateOnAave(
        address _collateralAsset,
        address _debtAsset,
        address _user,
        uint256 _debtToCover,
        bool _receiveaToken,
        uint256 _minerTipPct
    ) public payable {

        require(keepers[msg.sender] == true, "Not a keeper");
        flashBorrow(_debtAsset, _debtToCover);

        ILendingPool lendingPool =
            ILendingPool(
                ILendingPoolAddressesProvider(lendingPoolAddressProvider)
                    .getLendingPool()
            );
        require(
            IERC20(_debtAsset).approve(address(lendingPool), _debtToCover),
            "Approval error"
        );

        uint256 collateralBefore =
            IERC20(_collateralAsset).balanceOf(address(this));
        lendingPool.liquidationCall(
            _collateralAsset,
            _debtAsset,
            _user,
            _debtToCover,
            _receiveaToken
        );
        uint256 collateralAfter =
            IERC20(_collateralAsset).balanceOf(address(this));

        IERC20(_collateralAsset).safeApprove(
            uni,
            collateralAfter.sub(collateralBefore)
        );
        address[] memory path = new address[](2);
        path[0] = _collateralAsset;
        path[1] = _debtAsset;

        uint256 _debtAssetBefore = IERC20(_debtAsset).balanceOf(address(this));
        Uni(uni).swapExactETHForTokens(
            collateralAfter.sub(collateralBefore),
            uint256(0),
            path,
            address(this),
            now.add(1800)
        );
        uint256 _debtAssetAfter = IERC20(_debtAsset).balanceOf(address(this));

        uint256 profit =
            _debtAssetAfter.sub(_debtAssetBefore).sub(_debtToCover).sub(
                lender.flashFee(_debtAsset, _debtToCover)
            );
        tipMinerInToken(
            _debtAsset,
            profit.mul(_minerTipPct).div(10000),
            _collateralAsset
        );
    }

    function tipMinerInToken(
        address _tipToken,
        uint256 _tipAmount,
        address _collateralAsset
    ) private {

        IERC20(_tipToken).safeApprove(uni, _tipAmount);
        address[] memory path = new address[](2);
        path[0] = _tipToken;
        path[1] = _collateralAsset;

        uint256 _ethBefore = address(this).balance;
        Uni(uni).swapExactTokensForETH(
            _tipAmount,
            uint256(0),
            path,
            address(this),
            now.add(1800)
        );
        uint256 _ethAfter = address(this).balance;
        tipJar.tip.value(_ethAfter.sub(_ethBefore))();
    }

    function flashBorrow(address _token, uint256 _amount) private {

        bytes memory data = abi.encode(Action.NORMAL);
        uint256 _allowance =
            IERC20(_token).allowance(address(this), address(lender));
        uint256 _fee = lender.flashFee(_token, _amount);
        uint256 _repayment = _amount + _fee;
        IERC20(_token).approve(address(lender), _allowance + _repayment);
        lender.flashLoan(this, _token, _amount, data);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {

        require(
            msg.sender == address(lender),
            "FlashBorrower: Untrusted lender"
        );
        require(
            initiator == address(this),
            "FlashBorrower: Untrusted loan initiator"
        );
        Action action = abi.decode(data, (Action));
        if (action == Action.NORMAL) {
        } else if (action == Action.OTHER) {
        }
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}