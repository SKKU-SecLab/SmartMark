
pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// UNLICENSED

pragma solidity =0.6.12;

interface IBaseReward {

    function earned(address account) external view returns (uint256);

    function stake(address _for) external;

    function withdraw(address _for) external;

    function getReward(address _for) external;

    function notifyRewardAmount(uint256 reward) external;

    function addOwner(address _newOwner) external;

    function addOwners(address[] calldata _newOwners) external;

    function removeOwner(address _owner) external;

    function isOwner(address _owner) external view returns (bool);

}// UNLICENSED

pragma solidity =0.6.12;


interface ICompoundComptroller {

    function enterMarkets(address[] calldata cTokens)
        external
        returns (uint256[] memory);


    function exitMarket(address cToken) external returns (uint256);


    function getAssetsIn(address account)
        external
        view
        returns (address[] memory);


    function checkMembership(address account, address cToken)
        external
        view
        returns (bool);


    function claimComp(address holder) external;


    function claimComp(address holder, address[] memory cTokens) external;


    function getCompAddress() external view returns (address);


    function getAllMarkets() external view returns (address[] memory);


    function accountAssets(address user)
        external
        view
        returns (address[] memory);


    function markets(address _cToken)
        external
        view
        returns (bool isListed, uint256 collateralFactorMantissa);

}

interface ICompound {

    function borrow(uint256 borrowAmount) external returns (uint256);


    function isCToken(address) external view returns (bool);


    function comptroller() external view returns (ICompoundComptroller);


    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function accrualBlockNumber() external view returns (uint256);


    function borrowRatePerBlock() external view returns (uint256);


    function borrowBalanceStored(address user) external view returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function decimals() external view returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function exchangeRateCurrent() external returns (uint256);


    function interestRateModel() external view returns (address);

}

interface ICompoundCEther is ICompound {

    function repayBorrow() external payable;


    function mint() external payable;

}

interface ICompoundCErc20 is ICompound {

    function repayBorrow(uint256 repayAmount) external returns (uint256);


    function mint(uint256 mintAmount) external returns (uint256);


    function underlying() external returns (address); // like usdc usdt

}

interface ISupplyRewardFactory {

    function createReward(
        address _rewardToken,
        address _virtualBalance,
        address _owner
    ) external returns (address);

}

contract SupplyTreasuryFundForCompound is ReentrancyGuard {

    using Address for address payable;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public rewardCompPool;
    address public supplyRewardFactory;
    address public virtualBalance;
    address public compAddress;
    address public compoundComptroller;
    address public underlyToken;
    address public lpToken;
    address public owner;
    uint256 public totalUnderlyToken;
    uint256 public frozenUnderlyToken;
    bool public isErc20;
    bool private initialized;

    modifier onlyInitialized() {

        require(initialized, "!initialized");
        _;
    }

    modifier onlyOwner() {

        require(
            msg.sender == owner,
            "SupplyTreasuryFundForCompound: !authorized"
        );
        _;
    }

    constructor(
        address _owner,
        address _lpToken,
        address _compoundComptroller,
        address _supplyRewardFactory
    ) public {
        owner = _owner;
        compoundComptroller = _compoundComptroller;
        lpToken = _lpToken;
        supplyRewardFactory = _supplyRewardFactory;
    }

    function initialize(
        address _virtualBalance,
        address _underlyToken,
        bool _isErc20
    ) public onlyOwner {

        require(!initialized, "initialized");

        compAddress = ICompoundComptroller(compoundComptroller).getCompAddress();

        underlyToken = _underlyToken;

        virtualBalance = _virtualBalance;
        isErc20 = _isErc20;

        rewardCompPool = ISupplyRewardFactory(supplyRewardFactory).createReward(
                compAddress,
                virtualBalance,
                address(this)
            );

        initialized = true;
    }

    function _mintEther(uint256 _amount) internal {

        ICompoundCEther(lpToken).mint{value: _amount}();
    }

    function _mintErc20(uint256 _amount) internal {

        ICompoundCErc20(lpToken).mint(_amount);
    }

    receive() external payable {}

    function migrate(address _newTreasuryFund, bool _setReward)
        external
        onlyOwner
        nonReentrant
        returns (uint256)
    {

        uint256 cTokens = IERC20(lpToken).balanceOf(address(this));

        uint256 redeemState = ICompound(lpToken).redeem(cTokens);

        require(
            redeemState == 0,
            "SupplyTreasuryFundForCompound: !redeemState"
        );

        uint256 bal;

        if (isErc20) {
            bal = IERC20(underlyToken).balanceOf(address(this));

            IERC20(underlyToken).safeTransfer(owner, bal);
        } else {
            bal = address(this).balance;

            if (bal > 0) {
                payable(owner).sendValue(bal);
            }
        }

        if (_setReward) {
            IBaseReward(rewardCompPool).addOwner(_newTreasuryFund);
            IBaseReward(rewardCompPool).removeOwner(address(this));
        }

        return bal;
    }

    function _depositFor(address _for, uint256 _amount) internal {

        totalUnderlyToken = totalUnderlyToken.add(_amount);

        if (isErc20) {
            IERC20(underlyToken).safeApprove(lpToken, 0);
            IERC20(underlyToken).safeApprove(lpToken, _amount);

            _mintErc20(_amount);
        } else {
            _mintEther(_amount);
        }

        if (_for != address(0)) {
            IBaseReward(rewardCompPool).stake(_for);
        }
    }

    function depositFor(address _for)
        public
        payable
        onlyInitialized
        onlyOwner
        nonReentrant
    {

        _depositFor(_for, msg.value);
    }

    function depositFor(address _for, uint256 _amount)
        public
        onlyInitialized
        onlyOwner
        nonReentrant
    {

        _depositFor(_for, _amount);
    }

    function withdrawFor(address _to, uint256 _amount)
        public
        onlyInitialized
        onlyOwner
        nonReentrant
        returns (uint256)
    {

        IBaseReward(rewardCompPool).withdraw(_to);

        require(
            totalUnderlyToken >= _amount,
            "SupplyTreasuryFundForCompound: !insufficient balance"
        );

        totalUnderlyToken = totalUnderlyToken.sub(_amount);

        uint256 redeemState = ICompound(lpToken).redeemUnderlying(_amount);

        require(
            redeemState == 0,
            "SupplyTreasuryFundForCompound: !redeemState"
        );

        uint256 bal;

        if (isErc20) {
            bal = IERC20(underlyToken).balanceOf(address(this));

            IERC20(underlyToken).safeTransfer(_to, bal);
        } else {
            bal = address(this).balance;

            if (bal > 0) {
                payable(_to).sendValue(bal);
            }
        }

        return bal;
    }

    function borrow(
        address _to,
        uint256 _lendingAmount,
        uint256 _lendingInterest
    ) public onlyInitialized nonReentrant onlyOwner returns (uint256) {

        totalUnderlyToken = totalUnderlyToken.sub(_lendingAmount);
        frozenUnderlyToken = frozenUnderlyToken.add(_lendingAmount);

        uint256 redeemState = ICompound(lpToken).redeemUnderlying(
            _lendingAmount
        );

        require(
            redeemState == 0,
            "SupplyTreasuryFundForCompound: !redeemState"
        );

        if (isErc20) {
            IERC20(underlyToken).safeTransfer(
                _to,
                _lendingAmount.sub(_lendingInterest)
            );

            if (_lendingInterest > 0) {
                IERC20(underlyToken).safeTransfer(owner, _lendingInterest);
            }
        } else {
            payable(_to).sendValue(_lendingAmount.sub(_lendingInterest));
            if (_lendingInterest > 0) {
                payable(owner).sendValue(_lendingInterest);
            }
        }

        return _lendingInterest;
    }

    function repayBorrow()
        public
        payable
        onlyInitialized
        nonReentrant
        onlyOwner
    {

        _mintEther(msg.value);

        totalUnderlyToken = totalUnderlyToken.add(msg.value);
        frozenUnderlyToken = frozenUnderlyToken.sub(msg.value);
    }

    function repayBorrow(uint256 _lendingAmount)
        public
        onlyInitialized
        nonReentrant
        onlyOwner
    {

        IERC20(underlyToken).safeApprove(lpToken, 0);
        IERC20(underlyToken).safeApprove(lpToken, _lendingAmount);

        _mintErc20(_lendingAmount);

        totalUnderlyToken = totalUnderlyToken.add(_lendingAmount);
        frozenUnderlyToken = frozenUnderlyToken.sub(_lendingAmount);
    }

    function getBalance() public view returns (uint256) {

        uint256 exchangeRateStored = ICompound(lpToken).exchangeRateStored();
        uint256 cTokens = IERC20(lpToken).balanceOf(address(this));

        return exchangeRateStored.mul(cTokens).div(1e18);
    }

    function claim()
        public
        onlyInitialized
        onlyOwner
        nonReentrant
        returns (uint256)
    {

        ICompoundComptroller(compoundComptroller).claimComp(address(this));

        uint256 balanceOfComp = IERC20(compAddress).balanceOf(address(this));

        if (balanceOfComp > 0) {
            IERC20(compAddress).safeTransfer(rewardCompPool, balanceOfComp);

            IBaseReward(rewardCompPool).notifyRewardAmount(balanceOfComp);
        }

        uint256 bal;
        uint256 cTokens = IERC20(lpToken).balanceOf(address(this));

        if (totalUnderlyToken == 0 && frozenUnderlyToken == 0) {
            if (cTokens > 0) {
                uint256 redeemState = ICompound(lpToken).redeem(cTokens);

                require(
                    redeemState == 0,
                    "SupplyTreasuryFundForCompound: !redeemState"
                );

                if (isErc20) {
                    bal = IERC20(underlyToken).balanceOf(address(this));

                    IERC20(underlyToken).safeTransfer(owner, bal);
                } else {
                    bal = address(this).balance;

                    if (bal > 0) {
                        payable(owner).sendValue(bal);
                    }
                }

                return bal;
            }
        }

        uint256 exchangeRateStored = ICompound(lpToken).exchangeRateCurrent();

        uint256 cTokenPrice = cTokens.mul(exchangeRateStored).div(1e18);

        if (cTokenPrice > totalUnderlyToken.add(frozenUnderlyToken)) {
            uint256 interestCToken = cTokenPrice
                .sub(totalUnderlyToken.add(frozenUnderlyToken))
                .mul(1e18)
                .div(exchangeRateStored);

            uint256 redeemState = ICompound(lpToken).redeem(interestCToken);

            require(
                redeemState == 0,
                "SupplyTreasuryFundForCompound: !redeemState"
            );

            if (isErc20) {
                bal = IERC20(underlyToken).balanceOf(address(this));

                IERC20(underlyToken).safeTransfer(owner, bal);
            } else {
                bal = address(this).balance;

                if (bal > 0) {
                    payable(owner).sendValue(bal);
                }
            }
        }

        return bal;
    }

    function getReward(address _for) public onlyOwner nonReentrant {

        if (IBaseReward(rewardCompPool).earned(_for) > 0) {
            IBaseReward(rewardCompPool).getReward(_for);
        }
    }

    function getBorrowRatePerBlock() public view returns (uint256) {

        return ICompound(lpToken).borrowRatePerBlock();
    }

}// UNLICENSED

pragma solidity =0.6.12;

interface ISupplyBooster {

    function poolInfo(uint256 _pid)
        external
        view
        returns (
            address underlyToken,
            address rewardInterestPool,
            address supplyTreasuryFund,
            address virtualBalance,
            bool isErc20,
            bool shutdown
        );


    function liquidate(bytes32 _lendingId, uint256 _lendingInterest)
        external
        payable
        returns (address);


    function getLendingUnderlyToken(bytes32 _lendingId)
        external
        view
        returns (address);


    function borrow(
        uint256 _pid,
        bytes32 _lendingId,
        address _user,
        uint256 _lendingAmount,
        uint256 _lendingInterest,
        uint256 _borrowNumbers
    ) external;


    function repayBorrow(
        bytes32 _lendingId,
        address _user,
        uint256 _lendingInterest
    ) external payable;


    function repayBorrow(
        bytes32 _lendingId,
        address _user,
        uint256 _lendingAmount,
        uint256 _lendingInterest
    ) external;


    function addSupplyPool(address _underlyToken, address _supplyTreasuryFund)
        external
        returns (bool);


    function getBorrowRatePerBlock(uint256 _pid)
        external
        view
        returns (uint256);


    function getUtilizationRate(uint256 _pid) external view returns (uint256);

}// UNLICENSED

pragma solidity =0.6.12;


interface ISupplyRewardFactoryExtra is ISupplyRewardFactory {

    function addOwner(address _newOwner) external;

}

contract SupplyPoolManager {

    address public supplyBooster;
    address public supplyRewardFactory;
    address public compoundComptroller;

    address public owner;
    address public governance;

    event SetOwner(address owner);
    event SetGovernance(address governance);

    modifier onlyOwner() {

        require(
            owner == msg.sender,
            "SupplyPoolManager: caller is not the owner"
        );
        _;
    }

    modifier onlyGovernance() {

        require(
            governance == msg.sender,
            "SupplyPoolManager: caller is not the governance"
        );
        _;
    }

    constructor(
        address _owner,
        address _supplyBooster,
        address _supplyRewardFactory,
        address _compoundComptroller
    ) public {
        owner = _owner;
        governance = _owner;
        supplyBooster = _supplyBooster;
        supplyRewardFactory = _supplyRewardFactory;
        compoundComptroller = _compoundComptroller;
    }

    function setOwner(address _owner) public onlyOwner {

        owner = _owner;

        emit SetOwner(_owner);
    }

    function setGovernance(address _governance) public onlyOwner {

        governance = _governance;

        emit SetGovernance(_governance);
    }

    function addSupplyPool(address _compoundCToken) public onlyGovernance {

        SupplyTreasuryFundForCompound supplyTreasuryFund = new SupplyTreasuryFundForCompound(
                supplyBooster,
                _compoundCToken,
                compoundComptroller,
                supplyRewardFactory
            );

        address underlyToken;

        if (_compoundCToken == 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5) {
            underlyToken = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else {
            underlyToken = ICompoundCErc20(_compoundCToken).underlying();
        }

        ISupplyRewardFactoryExtra(supplyRewardFactory).addOwner(
            address(supplyTreasuryFund)
        );

        ISupplyBooster(supplyBooster).addSupplyPool(
            underlyToken,
            address(supplyTreasuryFund)
        );
    }
}