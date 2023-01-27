
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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
}// MIT

pragma solidity ^0.8.0;

interface IComptroller {

    function oracle() external view returns (address);

    function getAssetsIn(address account) external view returns (address[] memory);

    function isMarketListed(address cTokenAddress) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IConverter {

    function convert(uint256 amount) external;


    function source() external view returns (address);


    function destination() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

interface ICToken {

    function borrow(uint256 borrowAmount) external returns (uint256);


    function repayBorrow(uint256 repayAmount) external returns (uint256);


    function underlying() external view returns (address);


    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function comptroller() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

interface IPriceFeed {

    function getToken() external view returns (address);


    function getPrice() external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IPriceOracle {

    function getUnderlyingPrice(address cToken) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


contract IBAgreementV2 is ReentrancyGuard {

    using SafeERC20 for IERC20;

    address public immutable executor;
    address public immutable borrower;
    address public immutable governor;
    IComptroller public immutable comptroller;
    IERC20 public immutable collateral;
    uint256 public immutable collateralFactor;
    uint256 public immutable liquidationFactor;
    IPriceFeed public priceFeed;
    mapping(address => bool) public allowedMarkets;

    modifier onlyBorrower() {

        require(msg.sender == borrower, "caller is not the borrower");
        _;
    }

    modifier onlyExecutor() {

        require(msg.sender == executor, "caller is not the executor");
        _;
    }

    modifier onlyGovernor() {

        require(msg.sender == governor, "caller is not the governor");
        _;
    }

    modifier marketAllowed(address cy) {

        require(allowedMarkets[cy], "market not allowed");
        _;
    }

    event AllowedMarketsUpdated(address, bool);

    constructor(
        address _executor,
        address _borrower,
        address _governor,
        address _comptroller,
        address _collateral,
        address _priceFeed,
        uint256 _collateralFactor,
        uint256 _liquidationFactor
    ) {
        executor = _executor;
        borrower = _borrower;
        governor = _governor;
        comptroller = IComptroller(_comptroller);
        collateral = IERC20(_collateral);
        priceFeed = IPriceFeed(_priceFeed);
        collateralFactor = _collateralFactor;
        liquidationFactor = _liquidationFactor;

        require(_collateral == priceFeed.getToken(), "mismatch price feed");
        require(
            _collateralFactor > 0 && _collateralFactor <= 1e18,
            "invalid collateral factor"
        );
        require(
            _liquidationFactor >= _collateralFactor &&
                _liquidationFactor <= 1e18,
            "invalid liquidation factor"
        );
    }

    function debtUSD() external view returns (uint256) {

        return getHypotheticalDebtValue(address(0), 0);
    }

    function hypotheticalDebtUSD(ICToken cy, uint256 borrowAmount)
        external
        view
        returns (uint256)
    {

        return getHypotheticalDebtValue(address(cy), borrowAmount);
    }

    function collateralUSD() external view returns (uint256) {

        uint256 value = getHypotheticalCollateralValue(0);
        return (value * collateralFactor) / 1e18;
    }

    function hypotheticalCollateralUSD(uint256 withdrawAmount)
        external
        view
        returns (uint256)
    {

        uint256 value = getHypotheticalCollateralValue(withdrawAmount);
        return (value * collateralFactor) / 1e18;
    }

    function liquidationThreshold() external view returns (uint256) {

        uint256 value = getHypotheticalCollateralValue(0);
        return (value * liquidationFactor) / 1e18;
    }

    function borrow(ICToken cy, uint256 amount) external nonReentrant onlyBorrower marketAllowed(address(cy)) {

        borrowInternal(cy, amount);
    }

    function borrowMax(ICToken cy) external nonReentrant onlyBorrower marketAllowed(address(cy)) {

        (, , uint256 borrowBalance, ) = cy.getAccountSnapshot(address(this));

        IPriceOracle oracle = IPriceOracle(comptroller.oracle());

        uint256 maxBorrowAmount = (this.collateralUSD() * 1e18) /
            oracle.getUnderlyingPrice(address(cy));
        require(maxBorrowAmount > borrowBalance, "undercollateralized");
        borrowInternal(cy, maxBorrowAmount - borrowBalance);
    }

    function withdraw(uint256 amount) external onlyBorrower {

        require(
            this.debtUSD() <= this.hypotheticalCollateralUSD(amount),
            "undercollateralized"
        );
        collateral.safeTransfer(borrower, amount);
    }

    function repay(ICToken cy, uint256 amount) external nonReentrant onlyBorrower marketAllowed(address(cy)) {

        IERC20 underlying = IERC20(cy.underlying());
        underlying.safeTransferFrom(msg.sender, address(this), amount);
        repayInternal(cy, amount);
    }

    function seize(IERC20 token, uint256 amount) external onlyExecutor {

        if (address(token) == address(collateral)) {
            require(
                this.debtUSD() > this.liquidationThreshold(),
                "not liquidatable"
            );
        }
        token.safeTransfer(executor, amount);
    }

    function setPriceFeed(address _priceFeed) external onlyGovernor {

        require(
            address(collateral) == IPriceFeed(_priceFeed).getToken(),
            "mismatch price feed"
        );

        priceFeed = IPriceFeed(_priceFeed);
    }

     function setAllowedMarkets(address[] calldata markets, bool[] calldata states) external onlyExecutor {

         require(markets.length == states.length, "length mismatch");
         for (uint256 i = 0; i < markets.length; i++) {
            if (states[i]) {
                require(comptroller.isMarketListed(markets[i]), "market not listed");
            }
            allowedMarkets[markets[i]] = states[i];
            emit AllowedMarketsUpdated(markets[i], states[i]);
         }
     }


    function getHypotheticalDebtValue(address borrowCy, uint256 borrowAmount)
        internal
        view
        returns (uint256)
    {

        uint256 debt;
        address[] memory borrowedAssets = comptroller.getAssetsIn(address(this));
        IPriceOracle oracle = IPriceOracle(comptroller.oracle());
        for (uint256 i = 0; i < borrowedAssets.length; i++) {
            ICToken cy = ICToken(borrowedAssets[i]);
            uint256 amount;
            (, , uint256 borrowBalance, ) = cy.getAccountSnapshot(address(this));
            if (address(cy) == borrowCy) {
                amount = borrowBalance + borrowAmount;
            } else {
                amount = borrowBalance;
            }
            debt += (amount * oracle.getUnderlyingPrice(address(cy))) / 1e18;
        }
        return debt;
    }

    function getHypotheticalCollateralValue(uint256 withdrawAmount)
        internal
        view
        returns (uint256)
    {

        uint256 amount = collateral.balanceOf(address(this)) - withdrawAmount;
        uint8 decimals = IERC20Metadata(address(collateral)).decimals();
        uint256 normalizedAmount = amount * 10**(18 - decimals);
        return (normalizedAmount * priceFeed.getPrice()) / 1e18;
    }

    function borrowInternal(ICToken cy, uint256 _amount) internal {

        require(
            getHypotheticalDebtValue(address(cy), _amount) <= this.collateralUSD(),
            "undercollateralized"
        );
        require(cy.borrow(_amount) == 0, "borrow failed");
        IERC20(cy.underlying()).safeTransfer(borrower, _amount);
    }

    function repayInternal(ICToken cy, uint256 _amount) internal {

        IERC20(cy.underlying()).safeIncreaseAllowance(address(cy), _amount);
        require(cy.repayBorrow(_amount) == 0, "repay failed");
    }
}