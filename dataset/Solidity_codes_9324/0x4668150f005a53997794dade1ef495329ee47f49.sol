
            

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
}




            

pragma solidity ^0.8.0;

library AddressUpgradeable {

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
}




            

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}




            

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}




            

pragma solidity =0.8.6;

contract cLendingEventEmitter {

    event LoanTermsChanged(
        uint256 previousYearlyInterst,
        uint256 newYearlyInterst,
        uint256 previousLoanDefaultThresholdPercent,
        uint256 newLoanDefaultThresholdPercent,
        uint256 timestamp,
        address changedBy
    );

    event NewTokenAdded(
        address token,
        uint256 collaterability,
        address liquidationBeneficiary,
        uint256 timestamp,
        address addedBy
    );

    event TokenLiquidationBeneficiaryChanged(
        address token,
        address oldBeneficiary,
        address newBeneficiary,
        uint256 timestamp,
        address changedBy
    );

    event TokenCollaterabilityChanged(
        address token,
        uint256 oldCollaterability,
        uint256 newCollaterability,
        uint256 timestamp,
        address changedBy
    );

    event CollateralAdded(address token, uint256 amount, uint256 timestamp, address addedBy);

    event LoanTaken(uint256 amount, uint256 timestamp, address takenBy);

    event Repayment(address token, uint256 amountTokens, uint256 timestamp, address addedBy);

    event InterestPaid(address paidInToken, uint256 interestAmountInDAI, uint256 timestamp, address paidBy);

    event Liquidation(
        address userWhoWasLiquidated,
        uint256 totalCollateralValueLiquidated,
        uint256 timestamp,
        address caller
    );

    event CollateralReclaimed(address token, uint256 amount, uint256 timestamp, address byWho);
}




            

pragma solidity =0.8.6;

struct DebtorSummary {
    uint256 timeLastBorrow; // simple timestamp
    uint256 amountDAIBorrowed; // denominated in DAI units (1e18)
    uint256 pendingInterests; // interests accumulated from previous loans
    Collateral[] collateral;
}

struct Collateral {
    address collateralAddress;
    uint256 amountCollateral;
}




            
pragma solidity =0.8.6;


library CLendingLibrary {

    function safeTransferFrom(
        IERC20 token,
        address person,
        uint256 sendAmount
    ) internal returns (uint256 transferedAmount) {

        uint256 balanceBefore = token.balanceOf(address(this));
        token.transferFrom(person, address(this), sendAmount);
        uint256 balanceAfter = token.balanceOf(address(this));

        transferedAmount = balanceAfter - balanceBefore;
        require(transferedAmount == sendAmount, "UNSUPPORTED_TOKEN");
    }
}




            

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}




pragma solidity =0.8.6;


contract CLending is OwnableUpgradeable, cLendingEventEmitter {

    using CLendingLibrary for IERC20;

    IERC20 public constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public constant CORE_TOKEN = IERC20(0x62359Ed7505Efc61FF1D56fEF82158CcaffA23D7);
    address private constant DEADBEEF = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;

    mapping(address => DebtorSummary) public debtorSummary;
    mapping(address => uint256) public collaterabilityOfToken;
    mapping(address => address) public liquidationBeneficiaryOfToken;
    mapping(address => bool) public isAngel;


    address public coreDAOTreasury;
    uint256 public yearlyPercentInterest;
    uint256 public loanDefaultThresholdPercent;
    IERC20 public coreDAO; // initialized hence not immutable but should be

    bool private entered;
    bool private holyIntervention;

    uint256[52] private _____gap;

    modifier nonEntered {

        require(!entered, "NO_REENTRY");
        entered = true;
        _;
        entered = false;
    }

    modifier notHaram {

        require(!holyIntervention,"GOD_SAYS_NO");
        _;
    }

    function editAngels(address _angel, bool _isAngel) external onlyOwner {

        isAngel[_angel] = _isAngel;
    }

    function intervenienteHomine() external {

        require(isAngel[msg.sender] || msg.sender == owner(),"HERETICAL");
        holyIntervention = true;
    }

    function godIsDead() external onlyOwner {

        holyIntervention = false;
    }

    function initialize(
        address _coreDAOTreasury,
        IERC20 _daoToken,
        uint256 _yearlyPercentInterest,
        uint256 _loanDefaultThresholdPercent,
        uint256 _coreTokenCollaterability
    ) external initializer {

        require(msg.sender == 0x5A16552f59ea34E44ec81E58b3817833E9fD5436, "BUM");
        __Ownable_init();

        coreDAOTreasury = _coreDAOTreasury;

        changeLoanTerms(_yearlyPercentInterest, _loanDefaultThresholdPercent);

        require(loanDefaultThresholdPercent > 100, "WOULD_LIQUIDATE");

        addNewToken(address(_daoToken), DEADBEEF, 1, 18);
        addNewToken(address(CORE_TOKEN), DEADBEEF, _coreTokenCollaterability, 18);
        addNewToken(address(DAI), _coreDAOTreasury, 1, 18); // DAI should never be liquidated but this is just in case

        coreDAO = _daoToken;
    }

    receive() external payable {
        revert("ETH_NOT_ACCEPTED");
    }

    function changeLoanTerms(uint256 _yearlyPercentInterest, uint256 _loanDefaultThresholdPercent) public onlyOwner {

        require(_loanDefaultThresholdPercent > 100, "WOULD_LIQUIDATE");

        emit LoanTermsChanged(
            yearlyPercentInterest,
            _yearlyPercentInterest,
            loanDefaultThresholdPercent,
            _loanDefaultThresholdPercent,
            block.timestamp,
            msg.sender
        );

        yearlyPercentInterest = _yearlyPercentInterest;
        loanDefaultThresholdPercent = _loanDefaultThresholdPercent;
    }

    function editTokenCollaterability(address token, uint256 newCollaterability) external onlyOwner {

        emit TokenCollaterabilityChanged(
            token,
            collaterabilityOfToken[token],
            newCollaterability,
            block.timestamp,
            msg.sender
        );
        require(liquidationBeneficiaryOfToken[token] != address(0), "NOT_ADDED");
        collaterabilityOfToken[token] = newCollaterability;
    }

    function addNewToken(
        address token,
        address liquidationBeneficiary,
        uint256 collaterabilityInDAI,
        uint256 decimals
    ) public onlyOwner {


        require(decimals == 18, "UNSUPPORTED_DECIMALS");
        require(
            collaterabilityOfToken[token] == 0 && liquidationBeneficiaryOfToken[token] == address(0),
            "ALREADY_ADDED"
        );
        if (liquidationBeneficiary == address(0)) {
            liquidationBeneficiary = DEADBEEF;
        } // covers not send to 0 tokens
        require(collaterabilityInDAI > 0, "INVALID_COLLATERABILITY");
        emit NewTokenAdded(token, collaterabilityInDAI, liquidationBeneficiary, block.timestamp, msg.sender);
        liquidationBeneficiaryOfToken[token] = liquidationBeneficiary;
        collaterabilityOfToken[token] = collaterabilityInDAI;
    }

    function editTokenLiquidationBeneficiary(address token, address newBeneficiary) external onlyOwner {

        require(liquidationBeneficiaryOfToken[token] != address(0), "NOT_ADDED");
        require(token != address(CORE_TOKEN) && token != address(coreDAO), "CANNOT_MODIFY"); // Those should stay burned or floor doesnt hold
        if (newBeneficiary == address(0)) {
            newBeneficiary = DEADBEEF;
        } // covers not send to 0 tokens
        emit TokenLiquidationBeneficiaryChanged(
            token,
            liquidationBeneficiaryOfToken[token],
            newBeneficiary,
            block.timestamp,
            msg.sender
        );
        liquidationBeneficiaryOfToken[token] = newBeneficiary;
    }

    function repayLoan(IERC20 token, uint256 amount) external notHaram nonEntered {


        (uint256 totalDebt, ) = _liquidateDeliquent(msg.sender);
        DebtorSummary storage userSummaryStorage = debtorSummary[msg.sender];
        uint256 tokenCollateralAbility = collaterabilityOfToken[address(token)];
        uint256 offeredCollateralValue = amount * tokenCollateralAbility;
        uint256 _accruedInterest = accruedInterest(msg.sender);

        require(offeredCollateralValue > 0, "NOT_ENOUGH_COLLATERAL_OFFERED"); // covers both cases its a not supported token and 0 case
        require(totalDebt > 0, "NOT_DEBT");
        require(offeredCollateralValue >= _accruedInterest, "INSUFFICIENT_AMOUNT"); // Has to be done because we have to update debt time
        require(amount > 0, "REPAYMENT_NOT_SUCESSFUL");

        if (offeredCollateralValue > totalDebt) {

            amount = quantityOfTokenForValueInDAI(totalDebt, tokenCollateralAbility);

            require(amount > 0, "REPAYMENT_NOT_SUCESSFUL");
            userSummaryStorage.amountDAIBorrowed = 0;

        } else {
            userSummaryStorage.amountDAIBorrowed -= (offeredCollateralValue - _accruedInterest);



        }
        
        token.safeTransferFrom(msg.sender, amount); // amount is changed if user supplies more than is neesesry to wipe their debt and interest

        emit Repayment(address(token), amount, block.timestamp, msg.sender);

        uint256 amountTokensForInterestRepayment = quantityOfTokenForValueInDAI(
            _accruedInterest,
            tokenCollateralAbility
        );

        if (amountTokensForInterestRepayment > 0) {

            _safeTransfer(address(token), coreDAOTreasury, amountTokensForInterestRepayment);

        }
        _wipeInterestOwed(userSummaryStorage);
        emit InterestPaid(address(token), _accruedInterest, block.timestamp, msg.sender);
    }

    function quantityOfTokenForValueInDAI(uint256 quantityOfDAI, uint256 tokenCollateralAbility)
        public
        pure
        returns (uint256)
    {

        require(tokenCollateralAbility > 0, "TOKEN_UNSUPPORTED");
        return quantityOfDAI / tokenCollateralAbility;
    }

    function _supplyCollateral(
        DebtorSummary storage userSummaryStorage,
        address user,
        IERC20 token,
        uint256 amount
    ) private nonEntered {

        _liquidateDeliquent(user);

        uint256 tokenCollateralAbility = collaterabilityOfToken[address(token)]; // essentially a whitelist

        require(token != DAI, "DAI_IS_ONLY_FOR_REPAYMENT");
        require(tokenCollateralAbility != 0, "NOT_ACCEPTED");
        require(amount > 0, "!AMOUNT");
        require(user != address(0), "NO_ADDRESS");

        token.safeTransferFrom(user, amount);

        _upsertCollateralInUserSummary(userSummaryStorage, token, amount);
        emit CollateralAdded(address(token), amount, block.timestamp, msg.sender);
    }

    function addCollateral(IERC20 token, uint256 amount) external {

        DebtorSummary storage userSummaryStorage = debtorSummary[msg.sender];
        _supplyCollateral(userSummaryStorage, msg.sender, token, amount);
    }

    function addCollateralAndBorrow(
        IERC20 tokenCollateral,
        uint256 amountCollateral,
        uint256 amountBorrow
    ) external notHaram {


        DebtorSummary storage userSummaryStorage = debtorSummary[msg.sender];
        _supplyCollateral(userSummaryStorage, msg.sender, tokenCollateral, amountCollateral);
        _borrow(userSummaryStorage, msg.sender, amountBorrow);
    }

    function borrow(uint256 amount) external notHaram {


        DebtorSummary storage userSummaryStorage = debtorSummary[msg.sender];
        _borrow(userSummaryStorage, msg.sender, amount);
    }

    function _borrow(
        DebtorSummary storage userSummaryStorage,
        address user,
        uint256 amountBorrow
    ) private nonEntered {

        uint256 totalCollateral = userCollateralValue(user); // Value of collateral in DAI
        uint256 userAccruedInterest = accruedInterest(user); // Interest in DAI
        uint256 totalAmountBorrowed = userSummaryStorage.amountDAIBorrowed;
        uint256 totalDebt = userAccruedInterest + totalAmountBorrowed;

        require(totalDebt < totalCollateral, "OVER_DEBTED");
        require(amountBorrow > 0, "NO_BORROW"); // This is intentional after adding accured interest
        require(user != address(0), "NO_ADDRESS");

        uint256 userRemainingCollateral = totalCollateral - totalDebt; // User's collateral before making this loan

        if (amountBorrow > userRemainingCollateral) {
            amountBorrow = userRemainingCollateral;
        }
        userSummaryStorage.amountDAIBorrowed += amountBorrow;
        _wipeInterestOwed(userSummaryStorage); // because we added it to their borrowed amount

        userSummaryStorage.pendingInterests = userAccruedInterest;

        DAI.transfer(user, amountBorrow); // DAI transfer function doesnt need safe transfer

        emit LoanTaken(amountBorrow, block.timestamp, user);
    }

    function _upsertCollateralInUserSummary(
        DebtorSummary storage userSummaryStorage,
        IERC20 token,
        uint256 amount
    ) private returns (uint256 collateralIndex) {

        require(amount != 0, "INVALID_AMOUNT");
        bool collateralAdded;

        uint256 length = userSummaryStorage.collateral.length;

        for (uint256 i = 0; i < length; i++) {
            Collateral storage collateral = userSummaryStorage.collateral[i];

            if (collateral.collateralAddress == address(token)) {
                
                collateral.amountCollateral += amount;
                collateralIndex = i;
                collateralAdded = true;
            }
        }

        if (!collateralAdded) {

            collateralIndex = userSummaryStorage.collateral.length;
            
            userSummaryStorage.collateral.push(
                Collateral({collateralAddress: address(token), amountCollateral: amount})
            );
        }
    }

    function _isLiquidable(uint256 totalDebt, uint256 totalCollateral) private view returns (bool) {

        return totalDebt > (totalCollateral * loanDefaultThresholdPercent) / 100;
    }

    function liquidateDelinquent(address user) external notHaram nonEntered returns (uint256 totalDebt, uint256 totalCollateral)  {

        return _liquidateDeliquent(user);
    }

    function _liquidateDeliquent(address user) private returns (uint256 totalDebt, uint256 totalCollateral) {

        totalDebt = userTotalDebt(user); // This is with interest
        totalCollateral = userCollateralValue(user);

        if (_isLiquidable(totalDebt, totalCollateral)) {

            _liquidate(user); // only callsite
            emit Liquidation(user, totalCollateral, block.timestamp, msg.sender);
            return (0, 0);
        }
    }

    function _liquidate(address user) private  {

        uint256 length = debtorSummary[user].collateral.length;

        for (uint256 i = 0; i < length; i++) {
            uint256 amount = debtorSummary[user].collateral[i].amountCollateral;
            address currentCollateralAddress = debtorSummary[user].collateral[i].collateralAddress;
            
            if (
                msg.sender == user || // User liquidates himself no incentive.
                currentCollateralAddress == address(coreDAO) || // no incentive for coreDAO to maintain floor, burned anyway
                currentCollateralAddress == address(CORE_TOKEN)
            ) {

                _safeTransfer(
                    currentCollateralAddress, //token
                    liquidationBeneficiaryOfToken[currentCollateralAddress], // to
                    amount //amount
                );
            } else {

                _safeTransfer(
                    currentCollateralAddress, //token
                    liquidationBeneficiaryOfToken[currentCollateralAddress], // to
                    (amount * 199) / 200 //amount 99.5%
                );

                _safeTransfer(
                    currentCollateralAddress, //token
                    msg.sender, // to
                    amount / 200 //amount 0.5%
                );
            }
        }

        delete debtorSummary[user];
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(bytes4(keccak256(bytes("transfer(address,uint256)"))), to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    function reclaimAllCollateral() external notHaram nonEntered {

        (uint256 totalDebt,) = _liquidateDeliquent(msg.sender);

        require(totalDebt == 0, "STILL_IN_DEBT");

        uint256 length = debtorSummary[msg.sender].collateral.length;
        require(length > 0, "NOTHING_TO_CLAIM");
        for (uint256 i = 0; i < length; i++) {
            address collateralAddress = debtorSummary[msg.sender].collateral[i].collateralAddress;
            uint256 amount = debtorSummary[msg.sender].collateral[i].amountCollateral;

            require(amount > 0, "SAFETY_CHECK_FAIL");

            _safeTransfer(
                collateralAddress, //token
                msg.sender, // to
                amount //amount
            );
                        
            emit CollateralReclaimed(collateralAddress, amount, block.timestamp, msg.sender);
        }

        delete debtorSummary[msg.sender];
    }

    function userCollaterals(address user) public view returns (Collateral[] memory) {

        return debtorSummary[user].collateral;
    }

    function userTotalDebt(address user) public view returns (uint256) {

        return accruedInterest(user) + debtorSummary[user].amountDAIBorrowed;
    }

    function accruedInterest(address user) public view returns (uint256) {

        DebtorSummary memory userSummaryMemory = debtorSummary[user];
        uint256 timeSinceLastLoan = block.timestamp - userSummaryMemory.timeLastBorrow;

        return
            ((userSummaryMemory.amountDAIBorrowed * yearlyPercentInterest * timeSinceLastLoan) / 365_00 days) + // 365days * 100 in seconds
            userSummaryMemory.pendingInterests;
    }

    function _wipeInterestOwed(DebtorSummary storage userSummaryStorage) private {

        userSummaryStorage.timeLastBorrow = block.timestamp;

        userSummaryStorage.pendingInterests = 0; // clear user pending interests
    }

    function userCollateralValue(address user) public view returns (uint256 collateral) {

        Collateral[] memory userCollateralTokens = debtorSummary[user].collateral;
        for (uint256 i = 0; i < userCollateralTokens.length; i++) {
            Collateral memory currentToken = userCollateralTokens[i];

            uint256 tokenDebit = collaterabilityOfToken[currentToken.collateralAddress] * currentToken.amountCollateral;
            collateral += tokenDebit;
        }
    }
}