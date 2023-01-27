
pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}//MIT
pragma solidity 0.6.12;

interface IFlashloanExecutor {

    function executeOperation(
        address reserve,
        uint256 amount,
        uint256 fee,
        bytes memory data
    ) external;

}//MIT
pragma solidity 0.6.12;


library SafeRatioMath {

    using SafeMathUpgradeable for uint256;

    uint256 private constant BASE = 10**18;
    uint256 private constant DOUBLE = 10**36;

    function divup(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.add(y.sub(1)).div(y);
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.mul(y).div(BASE);
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.mul(BASE).div(y);
    }

    function rdivup(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.mul(BASE).add(y.sub(1)).div(y);
    }

    function tmul(
        uint256 x,
        uint256 y,
        uint256 z
    ) internal pure returns (uint256 result) {

        result = x.mul(y).mul(z).div(DOUBLE);
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 base
    ) internal pure returns (uint256 z) {

        assembly {
            switch x
                case 0 {
                    switch n
                        case 0 {
                            z := base
                        }
                        default {
                            z := 0
                        }
                }
                default {
                    switch mod(n, 2)
                        case 0 {
                            z := base
                        }
                        default {
                            z := x
                        }
                    let half := div(base, 2) // for rounding.

                    for {
                        n := div(n, 2)
                    } n {
                        n := div(n, 2)
                    } {
                        let xx := mul(x, x)
                        if iszero(eq(div(xx, x), x)) {
                            revert(0, 0)
                        }
                        let xxRound := add(xx, half)
                        if lt(xxRound, xx) {
                            revert(0, 0)
                        }
                        x := div(xxRound, base)
                        if mod(n, 2) {
                            let zx := mul(z, x)
                            if and(
                                iszero(iszero(x)),
                                iszero(eq(div(zx, x), z))
                            ) {
                                revert(0, 0)
                            }
                            let zxRound := add(zx, half)
                            if lt(zxRound, zx) {
                                revert(0, 0)
                            }
                            z := div(zxRound, base)
                        }
                    }
                }
        }
    }
}// MIT
pragma solidity 0.6.12;

abstract contract Initializable {
    bool private _initialized;

    modifier initializer() {
        require(
            !_initialized,
            "Initializable: contract is already initialized"
        );

        _;

        _initialized = true;
    }
}// MIT
pragma solidity 0.6.12;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}//MIT
pragma solidity 0.6.12;

contract Ownable {

    address payable public owner;

    address payable public pendingOwner;

    event NewOwner(address indexed previousOwner, address indexed newOwner);
    event NewPendingOwner(
        address indexed oldPendingOwner,
        address indexed newPendingOwner
    );

    modifier onlyOwner() {

        require(owner == msg.sender, "onlyOwner: caller is not the owner");
        _;
    }

    function __Ownable_init() internal {

        owner = msg.sender;
        emit NewOwner(address(0), msg.sender);
    }

    function _setPendingOwner(address payable newPendingOwner)
        external
        onlyOwner
    {

        require(
            newPendingOwner != address(0) && newPendingOwner != pendingOwner,
            "_setPendingOwner: New owenr can not be zero address and owner has been set!"
        );

        address oldPendingOwner = pendingOwner;

        pendingOwner = newPendingOwner;

        emit NewPendingOwner(oldPendingOwner, newPendingOwner);
    }

    function _acceptOwner() external {

        require(
            msg.sender == pendingOwner,
            "_acceptOwner: Only for pending owner!"
        );

        address oldOwner = owner;
        address oldPendingOwner = pendingOwner;

        owner = pendingOwner;

        pendingOwner = address(0);

        emit NewOwner(oldOwner, owner);
        emit NewPendingOwner(oldPendingOwner, pendingOwner);
    }

    uint256[50] private __gap;
}// MIT
pragma solidity 0.6.12;


contract ERC20 {

    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;

    string public name;
    string public symbol;
    uint8 public decimals;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function __ERC20_init(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) internal {

        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowance[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            msg.sender,
            spender,
            allowance[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            msg.sender,
            spender,
            allowance[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        balanceOf[sender] = balanceOf[sender].sub(amount);
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply = totalSupply.add(amount);
        balanceOf[account] = balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        balanceOf[account] = balanceOf[account].sub(amount);
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint256 amount) internal virtual {

        if (msg.sender != account)
            _approve(
                account,
                msg.sender,
                allowance[account][msg.sender].sub(amount)
            );

        _burn(account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    uint256[50] private __gap;
}//MIT
pragma solidity 0.6.12;

interface IInterestRateModelInterface {

    function isInterestRateModel() external view returns (bool);


    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);


    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveRatio
    ) external view returns (uint256);

}//MIT
pragma solidity 0.6.12;

interface IControllerAdminInterface {

    event MarketAdded(
        address iToken,
        uint256 collateralFactor,
        uint256 borrowFactor,
        uint256 supplyCapacity,
        uint256 borrowCapacity,
        uint256 distributionFactor
    );

    function _addMarket(
        address _iToken,
        uint256 _collateralFactor,
        uint256 _borrowFactor,
        uint256 _supplyCapacity,
        uint256 _borrowCapacity,
        uint256 _distributionFactor
    ) external;


    event NewPriceOracle(address oldPriceOracle, address newPriceOracle);

    function _setPriceOracle(address newOracle) external;


    event NewCloseFactor(
        uint256 oldCloseFactorMantissa,
        uint256 newCloseFactorMantissa
    );

    function _setCloseFactor(uint256 newCloseFactorMantissa) external;


    event NewLiquidationIncentive(
        uint256 oldLiquidationIncentiveMantissa,
        uint256 newLiquidationIncentiveMantissa
    );

    function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa)
        external;


    event NewCollateralFactor(
        address iToken,
        uint256 oldCollateralFactorMantissa,
        uint256 newCollateralFactorMantissa
    );

    function _setCollateralFactor(
        address iToken,
        uint256 newCollateralFactorMantissa
    ) external;


    event NewBorrowFactor(
        address iToken,
        uint256 oldBorrowFactorMantissa,
        uint256 newBorrowFactorMantissa
    );

    function _setBorrowFactor(address iToken, uint256 newBorrowFactorMantissa)
        external;


    event NewBorrowCapacity(
        address iToken,
        uint256 oldBorrowCapacity,
        uint256 newBorrowCapacity
    );

    function _setBorrowCapacity(address iToken, uint256 newBorrowCapacity)
        external;


    event NewSupplyCapacity(
        address iToken,
        uint256 oldSupplyCapacity,
        uint256 newSupplyCapacity
    );

    function _setSupplyCapacity(address iToken, uint256 newSupplyCapacity)
        external;


    event NewPauseGuardian(address oldPauseGuardian, address newPauseGuardian);

    function _setPauseGuardian(address newPauseGuardian) external;


    event MintPaused(address iToken, bool paused);

    function _setMintPaused(address iToken, bool paused) external;


    function _setAllMintPaused(bool paused) external;


    event RedeemPaused(address iToken, bool paused);

    function _setRedeemPaused(address iToken, bool paused) external;


    function _setAllRedeemPaused(bool paused) external;


    event BorrowPaused(address iToken, bool paused);

    function _setBorrowPaused(address iToken, bool paused) external;


    function _setAllBorrowPaused(bool paused) external;


    event TransferPaused(bool paused);

    function _setTransferPaused(bool paused) external;


    event SeizePaused(bool paused);

    function _setSeizePaused(bool paused) external;


    function _setiTokenPaused(address iToken, bool paused) external;


    function _setProtocolPaused(bool paused) external;


    event NewRewardDistributor(
        address oldRewardDistributor,
        address _newRewardDistributor
    );

    function _setRewardDistributor(address _newRewardDistributor) external;

}

interface IControllerPolicyInterface {

    function beforeMint(
        address iToken,
        address account,
        uint256 mintAmount
    ) external;


    function afterMint(
        address iToken,
        address minter,
        uint256 mintAmount,
        uint256 mintedAmount
    ) external;


    function beforeRedeem(
        address iToken,
        address redeemer,
        uint256 redeemAmount
    ) external;


    function afterRedeem(
        address iToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemedAmount
    ) external;


    function beforeBorrow(
        address iToken,
        address borrower,
        uint256 borrowAmount
    ) external;


    function afterBorrow(
        address iToken,
        address borrower,
        uint256 borrowedAmount
    ) external;


    function beforeRepayBorrow(
        address iToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external;


    function afterRepayBorrow(
        address iToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external;


    function beforeLiquidateBorrow(
        address iTokenBorrowed,
        address iTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external;


    function afterLiquidateBorrow(
        address iTokenBorrowed,
        address iTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repaidAmount,
        uint256 seizedAmount
    ) external;


    function beforeSeize(
        address iTokenBorrowed,
        address iTokenCollateral,
        address liquidator,
        address borrower,
        uint256 seizeAmount
    ) external;


    function afterSeize(
        address iTokenBorrowed,
        address iTokenCollateral,
        address liquidator,
        address borrower,
        uint256 seizedAmount
    ) external;


    function beforeTransfer(
        address iToken,
        address from,
        address to,
        uint256 amount
    ) external;


    function afterTransfer(
        address iToken,
        address from,
        address to,
        uint256 amount
    ) external;


    function beforeFlashloan(
        address iToken,
        address to,
        uint256 amount
    ) external;


    function afterFlashloan(
        address iToken,
        address to,
        uint256 amount
    ) external;

}

interface IControllerAccountEquityInterface {

    function calcAccountEquity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function liquidateCalculateSeizeTokens(
        address iTokenBorrowed,
        address iTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256);

}

interface IControllerAccountInterface {

    function hasEnteredMarket(address account, address iToken)
        external
        view
        returns (bool);


    function getEnteredMarkets(address account)
        external
        view
        returns (address[] memory);


    event MarketEntered(address iToken, address account);

    function enterMarkets(address[] calldata iTokens)
        external
        returns (bool[] memory);


        function enterMarketFromiToken(address _account) external;


    event MarketExited(address iToken, address account);

    function exitMarkets(address[] calldata iTokens)
        external
        returns (bool[] memory);


    event BorrowedAdded(address iToken, address account);

    event BorrowedRemoved(address iToken, address account);

    function hasBorrowed(address account, address iToken)
        external
        view
        returns (bool);


    function getBorrowedAssets(address account)
        external
        view
        returns (address[] memory);

}

interface IControllerInterface is
    IControllerAdminInterface,
    IControllerPolicyInterface,
    IControllerAccountEquityInterface,
    IControllerAccountInterface
{

    function isController() external view returns (bool);


    function getAlliTokens() external view returns (address[] memory);


    function hasiToken(address _iToken) external view returns (bool);

}// MIT
pragma solidity 0.6.12;




contract TokenStorage is Initializable, ReentrancyGuard, Ownable, ERC20 {


    uint256 constant BASE = 1e18;

    bool public constant isSupported = true;

    uint256 constant maxBorrowRate = 0.001e18;

    uint256 public reserveRatio;

    uint256 constant maxReserveRatio = 1e18;

    uint256 public flashloanFeeRatio;

    uint256 public protocolFeeRatio;

    IERC20Upgradeable public underlying;

    IInterestRateModelInterface public interestRateModel;

    IControllerInterface public controller;

    uint256 constant initialExchangeRate = 1e18;

    uint256 public borrowIndex;

    uint256 public accrualBlockNumber;

    uint256 public totalBorrows;

    uint256 public totalReserves;

    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

    mapping(address => BorrowSnapshot) internal accountBorrows;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH =
        0x576144ed657c8304561e56ca632e17751956250114636e8c01f64a7f2c6d98cf;
    mapping(address => uint256) public nonces;
}// MIT
pragma solidity 0.6.12;


contract TokenEvent is TokenStorage {


    event UpdateInterest(
        uint256 currentBlockNumber,
        uint256 interestAccumulated,
        uint256 borrowIndex,
        uint256 cash,
        uint256 totalBorrows,
        uint256 totalReserves
    );

    event Mint(
        address sender,
        address recipient,
        uint256 mintAmount,
        uint256 mintTokens
    );

    event Redeem(
        address from,
        address recipient,
        uint256 redeemiTokenAmount,
        uint256 redeemUnderlyingAmount
    );

    event Borrow(
        address borrower,
        uint256 borrowAmount,
        uint256 accountBorrows,
        uint256 accountInterestIndex,
        uint256 totalBorrows
    );

    event RepayBorrow(
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrows,
        uint256 accountInterestIndex,
        uint256 totalBorrows
    );

    event LiquidateBorrow(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        address iTokenCollateral,
        uint256 seizeTokens
    );

    event Flashloan(
        address loaner,
        uint256 loanAmount,
        uint256 flashloanFee,
        uint256 protocolFee,
        uint256 timestamp
    );


    event NewReserveRatio(uint256 oldReserveRatio, uint256 newReserveRatio);
    event NewFlashloanFeeRatio(
        uint256 oldFlashloanFeeRatio,
        uint256 newFlashloanFeeRatio
    );
    event NewProtocolFeeRatio(
        uint256 oldProtocolFeeRatio,
        uint256 newProtocolFeeRatio
    );
    event NewFlashloanFee(
        uint256 oldFlashloanFeeRatio,
        uint256 newFlashloanFeeRatio,
        uint256 oldProtocolFeeRatio,
        uint256 newProtocolFeeRatio
    );

    event NewInterestRateModel(
        IInterestRateModelInterface oldInterestRateModel,
        IInterestRateModelInterface newInterestRateModel
    );

    event NewController(
        IControllerInterface oldController,
        IControllerInterface newController
    );

    event ReservesWithdrawn(
        address admin,
        uint256 amount,
        uint256 newTotalReserves,
        uint256 oldTotalReserves
    );
}// MIT
pragma solidity 0.6.12;


abstract contract TokenAdmin is TokenEvent {

    modifier settleInterest() {
        _updateInterest();
        require(
            accrualBlockNumber == block.number,
            "settleInterest: Fail to accrue interest!"
        );
        _;
    }

    function _setController(IControllerInterface _newController)
        external
        virtual
        onlyOwner
    {
        IControllerInterface _oldController = controller;
        require(
            _newController.isController(),
            "_setController: This is not the controller contract!"
        );

        controller = _newController;

        emit NewController(_oldController, _newController);
    }

    function _setInterestRateModel(
        IInterestRateModelInterface _newInterestRateModel
    ) external virtual onlyOwner {
        IInterestRateModelInterface _oldInterestRateModel = interestRateModel;

        require(
            _newInterestRateModel.isInterestRateModel(),
            "_setInterestRateModel: This is not the rate model contract!"
        );

        interestRateModel = _newInterestRateModel;

        emit NewInterestRateModel(_oldInterestRateModel, _newInterestRateModel);
    }

    function _setNewReserveRatio(uint256 _newReserveRatio)
        external
        virtual
        onlyOwner
        settleInterest
    {
        require(
            _newReserveRatio <= maxReserveRatio,
            "_setNewReserveRatio: New reserve ratio too large!"
        );

        uint256 _oldReserveRatio = reserveRatio;

        reserveRatio = _newReserveRatio;

        emit NewReserveRatio(_oldReserveRatio, _newReserveRatio);
    }

    function _setNewFlashloanFeeRatio(uint256 _newFlashloanFeeRatio)
        external
        virtual
        onlyOwner
        settleInterest
    {
        require(
            _newFlashloanFeeRatio <= BASE,
            "setNewFlashloanFeeRatio: New flashloan ratio too large!"
        );

        uint256 _oldFlashloanFeeRatio = flashloanFeeRatio;

        flashloanFeeRatio = _newFlashloanFeeRatio;

        emit NewFlashloanFeeRatio(_oldFlashloanFeeRatio, _newFlashloanFeeRatio);
    }

    function _setNewProtocolFeeRatio(uint256 _newProtocolFeeRatio)
        external
        virtual
        onlyOwner
        settleInterest
    {
        require(
            _newProtocolFeeRatio <= BASE,
            "_setNewProtocolFeeRatio: New protocol ratio too large!"
        );

        uint256 _oldProtocolFeeRatio = protocolFeeRatio;

        protocolFeeRatio = _newProtocolFeeRatio;

        emit NewProtocolFeeRatio(_oldProtocolFeeRatio, _newProtocolFeeRatio);
    }

    function _withdrawReserves(uint256 _withdrawAmount)
        external
        virtual
        onlyOwner
        settleInterest
    {
        require(
            _withdrawAmount <= totalReserves &&
                _withdrawAmount <= _getCurrentCash(),
            "_withdrawReserves: Invalid withdraw amount and do not have enough cash!"
        );

        uint256 _oldTotalReserves = totalReserves;
        totalReserves = totalReserves.sub(_withdrawAmount);

        _doTransferOut(owner, _withdrawAmount);

        emit ReservesWithdrawn(
            owner,
            _withdrawAmount,
            totalReserves,
            _oldTotalReserves
        );
    }

    function _updateInterest() internal virtual;

    function _doTransferOut(address payable _recipient, uint256 _amount)
        internal
        virtual;

    function _getCurrentCash() internal view virtual returns (uint256);
}// MIT
pragma solidity 0.6.12;


abstract contract TokenERC20 is TokenAdmin {
    function _transferTokens(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal returns (bool) {
        require(
            _sender != _recipient,
            "_transferTokens: Do not self-transfer!"
        );

        controller.beforeTransfer(address(this), _sender, _recipient, _amount);

        _transfer(_sender, _recipient, _amount);

        controller.afterTransfer(address(this), _sender, _recipient, _amount);

        return true;
    }


    function transfer(address _recipient, uint256 _amount)
        public
        virtual
        override
        nonReentrant
        returns (bool)
    {
        return _transferTokens(msg.sender, _recipient, _amount);
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public virtual override nonReentrant returns (bool) {
        _approve(
            _sender,
            msg.sender, // spender
            allowance[_sender][msg.sender].sub(_amount)
        );
        return _transferTokens(_sender, _recipient, _amount);
    }
}// MIT
pragma solidity 0.6.12;



abstract contract Base is TokenERC20 {
    using SafeRatioMath for uint256;

    function _initialize(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        IControllerInterface _controller,
        IInterestRateModelInterface _interestRateModel
    ) internal virtual {
        controller = _controller;
        interestRateModel = _interestRateModel;
        accrualBlockNumber = block.number;
        borrowIndex = BASE;
        flashloanFeeRatio = 0.0008e18;
        protocolFeeRatio = 0.25e18;
        __Ownable_init();
        __ERC20_init(_name, _symbol, _decimals);
        __ReentrancyGuard_init();

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(_name)),
                keccak256(bytes("1")),
                _getChainId(),
                address(this)
            )
        );
    }


    function isiToken() external pure virtual returns (bool) {
        return true;
    }


    struct InterestLocalVars {
        uint256 borrowRate;
        uint256 currentBlockNumber;
        uint256 currentCash;
        uint256 totalBorrows;
        uint256 totalReserves;
        uint256 borrowIndex;
        uint256 blockDelta;
        uint256 simpleInterestFactor;
        uint256 interestAccumulated;
        uint256 newTotalBorrows;
        uint256 newTotalReserves;
        uint256 newBorrowIndex;
    }

    function _updateInterest() internal virtual override {
        if (block.number != accrualBlockNumber) {
            InterestLocalVars memory _vars;
            _vars.currentCash = _getCurrentCash();
            _vars.totalBorrows = totalBorrows;
            _vars.totalReserves = totalReserves;

            _vars.borrowRate = interestRateModel.getBorrowRate(
                _vars.currentCash,
                _vars.totalBorrows,
                _vars.totalReserves
            );
            require(
                _vars.borrowRate <= maxBorrowRate,
                "_updateInterest: Borrow rate is too high!"
            );

            _vars.currentBlockNumber = block.number;

            _vars.blockDelta = _vars.currentBlockNumber.sub(accrualBlockNumber);

            _vars.simpleInterestFactor = _vars.borrowRate.mul(_vars.blockDelta);
            _vars.interestAccumulated = _vars.simpleInterestFactor.rmul(
                _vars.totalBorrows
            );
            _vars.newTotalBorrows = _vars.interestAccumulated.add(
                _vars.totalBorrows
            );
            _vars.newTotalReserves = reserveRatio
                .rmul(_vars.interestAccumulated)
                .add(_vars.totalReserves);

            _vars.borrowIndex = borrowIndex;
            _vars.newBorrowIndex = _vars
                .simpleInterestFactor
                .rmul(_vars.borrowIndex)
                .add(_vars.borrowIndex);

            accrualBlockNumber = _vars.currentBlockNumber;
            borrowIndex = _vars.newBorrowIndex;
            totalBorrows = _vars.newTotalBorrows;
            totalReserves = _vars.newTotalReserves;

            emit UpdateInterest(
                _vars.currentBlockNumber,
                _vars.interestAccumulated,
                _vars.newBorrowIndex,
                _vars.currentCash,
                _vars.newTotalBorrows,
                _vars.newTotalReserves
            );
        }
    }

    struct MintLocalVars {
        uint256 exchangeRate;
        uint256 mintTokens;
        uint256 actualMintAmout;
    }

    function _mintInternal(address _recipient, uint256 _mintAmount)
        internal
        virtual
    {
        controller.beforeMint(address(this), _recipient, _mintAmount);

        MintLocalVars memory _vars;

        _vars.exchangeRate = _exchangeRateInternal();


        _vars.actualMintAmout = _doTransferIn(msg.sender, _mintAmount);

        _vars.mintTokens = _vars.actualMintAmout.rdiv(_vars.exchangeRate);

        _mint(_recipient, _vars.mintTokens);

        controller.afterMint(
            address(this),
            _recipient,
            _mintAmount,
            _vars.mintTokens
        );

        emit Mint(msg.sender, _recipient, _mintAmount, _vars.mintTokens);
    }

    function _redeemInternal(
        address _from,
        uint256 _redeemiTokenAmount,
        uint256 _redeemUnderlyingAmount
    ) internal virtual {
        require(
            _redeemiTokenAmount > 0,
            "_redeemInternal: Redeem iToken amount should be greater than zero!"
        );

        controller.beforeRedeem(address(this), _from, _redeemiTokenAmount);

        _burnFrom(_from, _redeemiTokenAmount);

        _doTransferOut(msg.sender, _redeemUnderlyingAmount);

        controller.afterRedeem(
            address(this),
            _from,
            _redeemiTokenAmount,
            _redeemUnderlyingAmount
        );

        emit Redeem(
            _from,
            msg.sender,
            _redeemiTokenAmount,
            _redeemUnderlyingAmount
        );
    }

    function _borrowInternal(address payable _borrower, uint256 _borrowAmount)
        internal
        virtual
    {
        controller.beforeBorrow(address(this), _borrower, _borrowAmount);

        BorrowSnapshot storage borrowSnapshot = accountBorrows[_borrower];
        borrowSnapshot.principal = _borrowBalanceInternal(_borrower).add(
            _borrowAmount
        );
        borrowSnapshot.interestIndex = borrowIndex;
        totalBorrows = totalBorrows.add(_borrowAmount);

        _doTransferOut(_borrower, _borrowAmount);

        controller.afterBorrow(address(this), _borrower, _borrowAmount);

        emit Borrow(
            _borrower,
            _borrowAmount,
            borrowSnapshot.principal,
            borrowSnapshot.interestIndex,
            totalBorrows
        );
    }

    function _repayInternal(
        address _payer,
        address _borrower,
        uint256 _repayAmount
    ) internal virtual returns (uint256) {
        controller.beforeRepayBorrow(
            address(this),
            _payer,
            _borrower,
            _repayAmount
        );

        uint256 _accountBorrows = _borrowBalanceInternal(_borrower);

        uint256 _actualRepayAmount =
            _doTransferIn(
                _payer,
                _repayAmount > _accountBorrows ? _accountBorrows : _repayAmount
            );


        BorrowSnapshot storage borrowSnapshot = accountBorrows[_borrower];
        borrowSnapshot.principal = _accountBorrows.sub(_actualRepayAmount);
        borrowSnapshot.interestIndex = borrowIndex;

        totalBorrows = totalBorrows < _actualRepayAmount
            ? 0
            : totalBorrows.sub(_actualRepayAmount);

        controller.afterRepayBorrow(
            address(this),
            _payer,
            _borrower,
            _actualRepayAmount
        );

        emit RepayBorrow(
            _payer,
            _borrower,
            _actualRepayAmount,
            borrowSnapshot.principal,
            borrowSnapshot.interestIndex,
            totalBorrows
        );

        return _actualRepayAmount;
    }

    function _liquidateBorrowInternal(
        address _borrower,
        uint256 _repayAmount,
        address _assetCollateral
    ) internal virtual {
        require(
            msg.sender != _borrower,
            "_liquidateBorrowInternal: Liquidator can not be borrower!"
        );
        require(
            _repayAmount != 0,
            "_liquidateBorrowInternal: Liquidate amount should be greater than 0!"
        );

        Base _dlCollateral = Base(_assetCollateral);
        _dlCollateral.updateInterest();

        controller.beforeLiquidateBorrow(
            address(this),
            _assetCollateral,
            msg.sender,
            _borrower,
            _repayAmount
        );

        require(
            _dlCollateral.accrualBlockNumber() == block.number,
            "_liquidateBorrowInternal: Failed to update block number in collateral asset!"
        );

        uint256 _actualRepayAmount =
            _repayInternal(msg.sender, _borrower, _repayAmount);

        uint256 _seizeTokens =
            controller.liquidateCalculateSeizeTokens(
                address(this),
                _assetCollateral,
                _actualRepayAmount
            );

        if (_assetCollateral == address(this)) {
            _seizeInternal(address(this), msg.sender, _borrower, _seizeTokens);
        } else {
            _dlCollateral.seize(msg.sender, _borrower, _seizeTokens);
        }

        controller.afterLiquidateBorrow(
            address(this),
            _assetCollateral,
            msg.sender,
            _borrower,
            _actualRepayAmount,
            _seizeTokens
        );

        emit LiquidateBorrow(
            msg.sender,
            _borrower,
            _actualRepayAmount,
            _assetCollateral,
            _seizeTokens
        );
    }

    function _seizeInternal(
        address _seizerToken,
        address _liquidator,
        address _borrower,
        uint256 _seizeTokens
    ) internal virtual {
        require(
            _borrower != _liquidator,
            "seize: Liquidator can not be borrower!"
        );

        controller.beforeSeize(
            address(this),
            _seizerToken,
            _liquidator,
            _borrower,
            _seizeTokens
        );

        _transfer(_borrower, _liquidator, _seizeTokens);

        controller.afterSeize(
            address(this),
            _seizerToken,
            _liquidator,
            _borrower,
            _seizeTokens
        );
    }

    function _borrowBalanceInternal(address _account)
        internal
        view
        virtual
        returns (uint256)
    {
        BorrowSnapshot storage borrowSnapshot = accountBorrows[_account];

        if (borrowSnapshot.principal == 0 || borrowSnapshot.interestIndex == 0)
            return 0;

        return
            borrowSnapshot.principal.mul(borrowIndex).divup(
                borrowSnapshot.interestIndex
            );
    }

    function _exchangeRateInternal() internal view virtual returns (uint256) {
        if (totalSupply == 0) {
            return initialExchangeRate;
        } else {
            return
                _getCurrentCash().add(totalBorrows).sub(totalReserves).rdiv(
                    totalSupply
                );
        }
    }

    function updateInterest() external virtual returns (bool);

    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        require(_deadline >= block.timestamp, "permit: EXPIRED!");
        uint256 _currentNonce = nonces[_owner];

        bytes32 _digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            _owner,
                            _spender,
                            _getChainId(),
                            _value,
                            _currentNonce,
                            _deadline
                        )
                    )
                )
            );
        address _recoveredAddress = ecrecover(_digest, _v, _r, _s);
        require(
            _recoveredAddress != address(0) && _recoveredAddress == _owner,
            "permit: INVALID_SIGNATURE!"
        );
        nonces[_owner] = _currentNonce.add(1);
        _approve(_owner, _spender, _value);
    }

    function _getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function seize(
        address _liquidator,
        address _borrower,
        uint256 _seizeTokens
    ) external virtual;

    function _doTransferIn(address _sender, uint256 _amount)
        internal
        virtual
        returns (uint256);

    function exchangeRateStored() external view virtual returns (uint256);

    function borrowBalanceStored(address _account)
        external
        view
        virtual
        returns (uint256);
}// MIT
pragma solidity 0.6.12;



contract iToken is Base {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    function initialize(
        address _underlyingToken,
        string memory _name,
        string memory _symbol,
        IControllerInterface _controller,
        IInterestRateModelInterface _interestRateModel
    ) external initializer {

        require(
            address(_underlyingToken) != address(0),
            "initialize: underlying address should not be zero address!"
        );
        require(
            address(_controller) != address(0),
            "initialize: controller address should not be zero address!"
        );
        require(
            address(_interestRateModel) != address(0),
            "initialize: interest model address should not be zero address!"
        );
        _initialize(
            _name,
            _symbol,
            ERC20(_underlyingToken).decimals(),
            _controller,
            _interestRateModel
        );

        underlying = IERC20Upgradeable(_underlyingToken);
    }

    function _doTransferIn(address _sender, uint256 _amount)
        internal
        override
        returns (uint256)
    {

        uint256 _balanceBefore = underlying.balanceOf(address(this));
        underlying.safeTransferFrom(_sender, address(this), _amount);
        return underlying.balanceOf(address(this)).sub(_balanceBefore);
    }

    function _doTransferOut(address payable _recipient, uint256 _amount)
        internal
        override
    {

        underlying.safeTransfer(_recipient, _amount);
    }

    function _getCurrentCash() internal view override returns (uint256) {

        return underlying.balanceOf(address(this));
    }

    function mint(address _recipient, uint256 _mintAmount)
        external
        nonReentrant
        settleInterest
    {

        _mintInternal(_recipient, _mintAmount);
    }

    function mintForSelfAndEnterMarket(uint256 _mintAmount)
        external
        nonReentrant
        settleInterest
    {

        _mintInternal(msg.sender, _mintAmount);
        controller.enterMarketFromiToken(msg.sender);
    }


    function redeem(address _from, uint256 _redeemiToken)
        external
        nonReentrant
        settleInterest
    {

        _redeemInternal(
            _from,
            _redeemiToken,
            _redeemiToken.rmul(_exchangeRateInternal())
        );
    }

    function redeemUnderlying(address _from, uint256 _redeemUnderlying)
        external
        nonReentrant
        settleInterest
    {

        _redeemInternal(
            _from,
            _redeemUnderlying.rdivup(_exchangeRateInternal()),
            _redeemUnderlying
        );
    }

    function borrow(uint256 _borrowAmount)
        external
        nonReentrant
        settleInterest
    {

        _borrowInternal(msg.sender, _borrowAmount);
    }

    function repayBorrow(uint256 _repayAmount)
        external
        nonReentrant
        settleInterest
    {

        _repayInternal(msg.sender, msg.sender, _repayAmount);
    }

    function repayBorrowBehalf(address _borrower, uint256 _repayAmount)
        external
        nonReentrant
        settleInterest
    {

        _repayInternal(msg.sender, _borrower, _repayAmount);
    }

    function liquidateBorrow(
        address _borrower,
        uint256 _repayAmount,
        address _assetCollateral
    ) external nonReentrant settleInterest {

        _liquidateBorrowInternal(_borrower, _repayAmount, _assetCollateral);
    }

    function seize(
        address _liquidator,
        address _borrower,
        uint256 _seizeTokens
    ) external override nonReentrant {

        _seizeInternal(msg.sender, _liquidator, _borrower, _seizeTokens);
    }

    function updateInterest() external override returns (bool) {

        _updateInterest();
        return true;
    }

    function exchangeRateCurrent() external returns (uint256) {

        _updateInterest();

        return _exchangeRateInternal();
    }

    function exchangeRateStored() external view override returns (uint256) {

        return _exchangeRateInternal();
    }

    function balanceOfUnderlying(address _account) external returns (uint256) {

        _updateInterest();

        return _exchangeRateInternal().rmul(balanceOf[_account]);
    }

    function borrowBalanceCurrent(address _account)
        external
        nonReentrant
        returns (uint256)
    {

        _updateInterest();

        return _borrowBalanceInternal(_account);
    }

    function borrowBalanceStored(address _account)
        external
        view
        override
        returns (uint256)
    {

        return _borrowBalanceInternal(_account);
    }

    function borrowSnapshot(address _account)
        external
        view
        returns (uint256, uint256)
    {

        return (
            accountBorrows[_account].principal,
            accountBorrows[_account].interestIndex
        );
    }

    function totalBorrowsCurrent() external returns (uint256) {

        _updateInterest();

        return totalBorrows;
    }

    function borrowRatePerBlock() public view returns (uint256) {

        return
            interestRateModel.getBorrowRate(
                _getCurrentCash(),
                totalBorrows,
                totalReserves
            );
    }

    function supplyRatePerBlock() external view returns (uint256) {

        uint256 _underlyingScaled = totalSupply.mul(_exchangeRateInternal());
        if (_underlyingScaled == 0) return 0;
        uint256 _totalBorrowsScaled = totalBorrows.mul(BASE);

        return
            borrowRatePerBlock().tmul(
                BASE.sub(reserveRatio),
                _totalBorrowsScaled.rdiv(_underlyingScaled)
            );
    }

    function getCash() external view returns (uint256) {

        return _getCurrentCash();
    }
}