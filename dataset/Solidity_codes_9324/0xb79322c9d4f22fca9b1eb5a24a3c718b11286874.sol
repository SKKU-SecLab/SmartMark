pragma solidity 0.8.10;

contract BaseMath {


    uint256 constant internal DECIMAL_PRECISION = 1e18;

    uint256 constant internal ACR_DECIMAL_PRECISION = 1e4;

}// MIT

pragma solidity =0.8.10;

contract CentralLogger {


    event LogEvent(
        address indexed contractAddress,
        address indexed caller,
        string indexed logName,
        bytes data
    );

	constructor() {
	}

    function log(
        address _contract,
        address _caller,
        string memory _logName,
        bytes memory _data
    ) public {

        emit LogEvent(_contract, _caller, _logName, _data);
    }
}// MIT

pragma solidity ^0.8.10;

abstract contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _firstOwner) {
        _transferOwnership(_firstOwner);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address _newOwner) public virtual onlyOwner {
        require(_newOwner != address(0), "Ownable: cannot be zero address");
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal virtual {
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }
}// LGPL-3.0
pragma solidity =0.8.10;


contract CommunityAcknowledgement is Ownable {


	mapping (bytes32 => uint16) public rccar;

	event ContributorRecognised(bytes32 indexed contributor, uint16 indexed previousAcknowledgementRate, uint16 indexed newAcknowledgementRate);

	constructor(address _adoptionDAOAddress) Ownable(_adoptionDAOAddress) {

	}

	function getAcknowledgementRate(bytes32 _contributor) external view returns (uint16) {

		return rccar[_contributor];
	}

	function senderAcknowledgementRate() external view returns (uint16) {

		return rccar[keccak256(abi.encodePacked(msg.sender))];
	}

	function recogniseContributor(bytes32 _contributor, uint16 _acknowledgementRate) public onlyOwner {

		uint16 _previousAcknowledgementRate = rccar[_contributor];
		rccar[_contributor] = _acknowledgementRate;
		emit ContributorRecognised(_contributor, _previousAcknowledgementRate, _acknowledgementRate);
	}

	function batchRecogniseContributor(bytes32[] calldata _contributors, uint16[] calldata _acknowledgementRates) external onlyOwner {

		require(_contributors.length == _acknowledgementRates.length, "Lists do not match in length");

		for (uint256 i = 0; i < _contributors.length; i++) {
			recogniseContributor(_contributors[i], _acknowledgementRates[i]);
		}
	}

}// MIT
pragma solidity =0.8.10;


contract Config is Ownable {


	uint16 public adoptionContributionRate;

	address payable public adoptionDAOAddress;

	event ACRChanged(address indexed caller, uint16 previousACR, uint16 newACR);

	event AdoptionDAOAddressChanged(address indexed caller, address previousAdoptionDAOAddress, address newAdoptionDAOAddress);

	constructor(address payable _adoptionDAOAddress, uint16 _initialACR) Ownable(_adoptionDAOAddress) {
		adoptionContributionRate = _initialACR;
		adoptionDAOAddress = _adoptionDAOAddress;
	}


	function setAdoptionContributionRate(uint16 _newACR) external onlyOwner {

		uint16 _previousACR = adoptionContributionRate;
		adoptionContributionRate = _newACR;
		emit ACRChanged(msg.sender, _previousACR, _newACR);
	}

	function setAdoptionDAOAddress(address payable _newAdoptionDAOAddress) external onlyOwner {

		address payable _previousAdoptionDAOAddress = adoptionDAOAddress;
		adoptionDAOAddress = _newAdoptionDAOAddress;
		emit AdoptionDAOAddressChanged(msg.sender, _previousAdoptionDAOAddress, _newAdoptionDAOAddress);
	}

}// MIT
pragma solidity =0.8.10;


contract Registry is Ownable {


	mapping (bytes32 => address) public addresses;

	event AddressRegistered(bytes32 indexed id, address indexed previousAddress, address indexed newAddress);

	constructor(address _initialOwner) Ownable(_initialOwner) {

	}


	function getAddress(bytes32 _id) external view returns(address) {

		return addresses[_id];
	}


	function registerAddress(bytes32 _id, address _address) public onlyOwner {

		require(_address != address(0), "Can't register 0x0 address");
		address _previousAddress = addresses[_id];
		addresses[_id] = _address;
		emit AddressRegistered(_id, _previousAddress, _address);
	}

	function batchRegisterAddresses(bytes32[] calldata _ids, address[] calldata _addresses) external onlyOwner {

		require(_ids.length == _addresses.length, "Lists do not match in length");

		for (uint256 i = 0; i < _ids.length; i++) {
			registerAddress(_ids[i], _addresses[i]);
		}
	}
}// MIT
pragma solidity =0.8.10;

abstract contract DSAuthority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) public view virtual returns (bool);
}// MIT
pragma solidity =0.8.10;


contract DSAuthEvents {

    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

abstract contract DSAuth is DSAuthEvents {
    DSAuthority public authority;
    address public owner;

    constructor() {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public virtual;

    function setAuthority(DSAuthority authority_) public virtual;

    function isAuthorized(address src, bytes4 sig) internal view virtual returns (bool);
}// MIT
pragma solidity =0.8.10;


abstract contract DSProxy is DSAuth {
    DSProxyCache public cache; // global cache for contracts

    constructor(address _cacheAddr) {
        require(setCache(_cacheAddr), "Cache not set");
    }

    receive() external payable {}

    function execute(bytes memory _code, bytes memory _data)
        public
        payable
        virtual
        returns (address target, bytes32 response);

    function execute(address _target, bytes memory _data)
        public
        payable
        virtual
        returns (bytes32 response);

    function setCache(address _cacheAddr) public payable virtual returns (bool);
}

abstract contract DSProxyCache {
    mapping(bytes32 => address) cache;

    function read(bytes memory _code) public view virtual returns (address);

    function write(bytes memory _code) public virtual returns (address target);
}// MIT
pragma solidity =0.8.10;


abstract contract DSProxyFactory {
    function build(address owner) public virtual returns (DSProxy proxy);
    function build() public virtual returns (DSProxy proxy);
    function isProxy(address proxy) public virtual view returns (bool);
}// MIT

pragma solidity =0.8.10;

interface IBorrowerOperations {



    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event PriceFeedAddressChanged(address  _newPriceFeedAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event LUSDTokenAddressChanged(address _lusdTokenAddress);
    event LQTYStakingAddressChanged(address _lqtyStakingAddress);

    event TroveCreated(address indexed _borrower, uint arrayIndex);
    event TroveUpdated(address indexed _borrower, uint _debt, uint _coll, uint stake, uint8 operation);
    event LUSDBorrowingFeePaid(address indexed _borrower, uint _LUSDFee);


    function openTrove(uint _maxFee, uint _LUSDAmount, address _upperHint, address _lowerHint) external payable;


    function addColl(address _upperHint, address _lowerHint) external payable;


    function moveETHGainToTrove(address _user, address _upperHint, address _lowerHint) external payable;


    function withdrawColl(uint _amount, address _upperHint, address _lowerHint) external;


    function withdrawLUSD(uint _maxFee, uint _amount, address _upperHint, address _lowerHint) external;


    function repayLUSD(uint _amount, address _upperHint, address _lowerHint) external;


    function closeTrove() external;


    function adjustTrove(uint _maxFee, uint _collWithdrawal, uint _debtChange, bool isDebtIncrease, address _upperHint, address _lowerHint) external payable;


    function claimCollateral() external;


    function getCompositeDebt(uint _debt) external pure returns (uint);

}// MIT

pragma solidity =0.8.10;


interface ITroveManager {

    

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event LUSDTokenAddressChanged(address _newLUSDTokenAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event LQTYTokenAddressChanged(address _lqtyTokenAddress);
    event LQTYStakingAddressChanged(address _lqtyStakingAddress);

    event Liquidation(uint _liquidatedDebt, uint _liquidatedColl, uint _collGasCompensation, uint _LUSDGasCompensation);
    event Redemption(uint _attemptedLUSDAmount, uint _actualLUSDAmount, uint _ETHSent, uint _ETHFee);
    event TroveUpdated(address indexed _borrower, uint _debt, uint _coll, uint stake, uint8 operation);
    event TroveLiquidated(address indexed _borrower, uint _debt, uint _coll, uint8 operation);
    event BaseRateUpdated(uint _baseRate);
    event LastFeeOpTimeUpdated(uint _lastFeeOpTime);
    event TotalStakesUpdated(uint _newTotalStakes);
    event SystemSnapshotsUpdated(uint _totalStakesSnapshot, uint _totalCollateralSnapshot);
    event LTermsUpdated(uint _L_ETH, uint _L_LUSDDebt);
    event TroveSnapshotsUpdated(uint _L_ETH, uint _L_LUSDDebt);
    event TroveIndexUpdated(address _borrower, uint _newIndex);

    function getTroveOwnersCount() external view returns (uint);


    function getTroveFromTroveOwnersArray(uint _index) external view returns (address);


    function getNominalICR(address _borrower) external view returns (uint);

    function getCurrentICR(address _borrower, uint _price) external view returns (uint);


    function liquidate(address _borrower) external;


    function liquidateTroves(uint _n) external;


    function batchLiquidateTroves(address[] calldata _troveArray) external;


    function redeemCollateral(
        uint _LUSDAmount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        uint _maxFee
    ) external; 


    function updateStakeAndTotalStakes(address _borrower) external returns (uint);


    function updateTroveRewardSnapshots(address _borrower) external;


    function addTroveOwnerToArray(address _borrower) external returns (uint index);


    function applyPendingRewards(address _borrower) external;


    function getPendingETHReward(address _borrower) external view returns (uint);


    function getPendingLUSDDebtReward(address _borrower) external view returns (uint);


     function hasPendingRewards(address _borrower) external view returns (bool);


    function getEntireDebtAndColl(address _borrower) external view returns (
        uint debt, 
        uint coll, 
        uint pendingLUSDDebtReward, 
        uint pendingETHReward
    );


    function closeTrove(address _borrower) external;


    function removeStake(address _borrower) external;


    function getRedemptionRate() external view returns (uint);

    function getRedemptionRateWithDecay() external view returns (uint);


    function getRedemptionFeeWithDecay(uint _ETHDrawn) external view returns (uint);


    function getBorrowingRate() external view returns (uint);

    function getBorrowingRateWithDecay() external view returns (uint);


    function getBorrowingFee(uint LUSDDebt) external view returns (uint);

    function getBorrowingFeeWithDecay(uint _LUSDDebt) external view returns (uint);


    function decayBaseRateFromBorrowing() external;


    function getTroveStatus(address _borrower) external view returns (uint);

    
    function getTroveStake(address _borrower) external view returns (uint);


    function getTroveDebt(address _borrower) external view returns (uint);


    function getTroveColl(address _borrower) external view returns (uint);


    function setTroveStatus(address _borrower, uint num) external;


    function increaseTroveColl(address _borrower, uint _collIncrease) external returns (uint);


    function decreaseTroveColl(address _borrower, uint _collDecrease) external returns (uint); 


    function increaseTroveDebt(address _borrower, uint _debtIncrease) external returns (uint); 


    function decreaseTroveDebt(address _borrower, uint _collDecrease) external returns (uint); 


    function getTCR(uint _price) external view returns (uint);


    function checkRecoveryMode(uint _price) external view returns (bool);


    function Troves(address) external view returns (uint256, uint256, uint256, uint8, uint128); 

}// MIT

pragma solidity =0.8.10;


interface ICollSurplusPool {


    
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);

    event CollBalanceUpdated(address indexed _account, uint _newBalance);
    event EtherSent(address _to, uint _amount);


    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress
    ) external;


    function getETH() external view returns (uint);


    function getCollateral(address _account) external view returns (uint);


    function accountSurplus(address _account, uint _amount) external;


    function claimColl(address _account) external;

}// MIT

pragma solidity 0.8.10;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity 0.8.10;

interface IERC2612 {

    function permit(address owner, address spender, uint256 amount, 
                    uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    
    function nonces(address owner) external view returns (uint256);

    
    function version() external view returns (string memory);

    function permitTypeHash() external view returns (bytes32);

    function domainSeparator() external view returns (bytes32);

}// MIT

pragma solidity 0.8.10;


interface ILUSDToken is IERC20, IERC2612 { 

    

    event TroveManagerAddressChanged(address _troveManagerAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);

    event LUSDTokenBalanceUpdated(address _user, uint _amount);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function mint(address _account, uint256 _amount) external;


    function burn(address _account, uint256 _amount) external;


    function sendToPool(address _sender,  address poolAddress, uint256 _amount) external;


    function returnFromPool(address poolAddress, address user, uint256 _amount ) external;

}// MIT

pragma solidity 0.8.10;

interface IPriceFeed {


    event LastGoodPriceUpdated(uint _lastGoodPrice);
   
    function fetchPrice() external returns (uint);


    function lastGoodPrice() external view returns (uint);


}// MIT
pragma solidity 0.8.10;


contract LiquityMath is BaseMath {


    uint256 internal constant LIQUITY_PROTOCOL_MAX_BORROWING_FEE = DECIMAL_PRECISION / 100 * 5; // 5%

    uint256 internal constant LIQUITY_LUSD_GAS_COMPENSATION = 200e18;

    function calcNeededLiquityLUSDAmount(uint256 _LUSDRequestedAmount, uint256 _expectedLiquityProtocolRate, uint16 _adoptionContributionRate) internal pure returns (
        uint256 neededLiquityLUSDAmount
    ) {


        uint256 acr = DECIMAL_PRECISION / ACR_DECIMAL_PRECISION * _adoptionContributionRate;

        acr = acr < _expectedLiquityProtocolRate ? _expectedLiquityProtocolRate : acr;

        uint256 expectedDebtToRepay = _LUSDRequestedAmount * acr / DECIMAL_PRECISION + _LUSDRequestedAmount;

        neededLiquityLUSDAmount = DECIMAL_PRECISION * expectedDebtToRepay / ( DECIMAL_PRECISION + _expectedLiquityProtocolRate ); 

        require(neededLiquityLUSDAmount >= _LUSDRequestedAmount, "Cannot mint less than requested.");
    }

    function applyRccarOnAcr(uint16 _rccar, uint16 _adoptionContributionRate) internal pure returns (
        uint16 adjustedAcr
    ) {

        return (_adoptionContributionRate > _rccar ? _adoptionContributionRate - _rccar : 0);
    }
}// LGPL-3.0
pragma solidity =0.8.10;


contract Executor is LiquityMath{



	bytes32 private constant CONFIG_ID = keccak256("Config");
	bytes32 private constant CENTRAL_LOGGER_ID = keccak256("CentralLogger");
	bytes32 private constant COMMUNITY_ACKNOWLEDGEMENT_ID = keccak256("CommunityAcknowledgement");

	address public immutable registry;
	
	DSProxyFactory public immutable ProxyFactory;

	IBorrowerOperations public immutable BorrowerOperations;
	ITroveManager public immutable TroveManager;
	ICollSurplusPool public immutable CollSurplusPool;
    ILUSDToken public immutable LUSDToken;
	IPriceFeed public immutable PriceFeed;
	

	enum AdjustCreditLineLiquityChoices {
		DebtIncrease, DebtDecrease, CollateralIncrease, CollateralDecrease
	}

	struct LocalVariables_adjustCreditLineLiquity {
		Config config;
		uint256 neededLUSDChange;
		uint256 expectedLiquityProtocolRate;
		uint256 previousLUSDBalance;
		uint256 previousETHBalance;	
		uint16 acr;
		uint256 price;
		bool isDebtIncrease;
		uint256 mintedLUSD;
		uint256 adoptionContributionLUSD;				
	}


	modifier onlyProxy() {

		require(ProxyFactory.isProxy(address(this)), "Only proxy can call Executor");
		_;
	}

	constructor(
		address _registry,
		address _borrowerOperations,
		address _troveManager,
		address _collSurplusPool,
		address _lusdToken,
		address _priceFeed,
		address _proxyFactory
	) {
		registry = _registry;
		BorrowerOperations = IBorrowerOperations(_borrowerOperations);
		TroveManager = ITroveManager(_troveManager);
		CollSurplusPool = ICollSurplusPool(_collSurplusPool);
		LUSDToken = ILUSDToken(_lusdToken);
		PriceFeed = IPriceFeed(_priceFeed);
		ProxyFactory = DSProxyFactory(_proxyFactory);
	}


	function sendLUSD(address _LUSDTo, uint256 _amount) internal {

		if (_amount == type(uint256).max) {
            _amount = getLUSDBalance(address(this));
        }
        if (_LUSDTo != address(this) && _amount != 0) {
            LUSDToken.transfer(_LUSDTo, _amount);
		}
	}

	function pullLUSDFrom(address _from, uint256 _amount) internal {

		if (_amount == type(uint256).max) {
            _amount = getLUSDBalance(_from);
        }
		if (_from != address(this) && _amount != 0) {
			LUSDToken.transferFrom(_from, address(this), _amount);
		}
	}

	function getLUSDBalance(address _acc) internal view returns (uint256) {

		return LUSDToken.balanceOf(_acc);
	}

	function adjustAcrForRequestor(uint16 _acr, address _requestor) internal view returns (uint16) {

		CommunityAcknowledgement ca = CommunityAcknowledgement(Registry(registry).getAddress(COMMUNITY_ACKNOWLEDGEMENT_ID));

		uint16 rccar = ca.getAcknowledgementRate(keccak256(abi.encodePacked(_requestor)));

		return applyRccarOnAcr(rccar, _acr);
	}


	function openCreditLineLiquity(uint256 _LUSDRequestedDebt, address _LUSDTo, address _upperHint, address _lowerHint, address _caller) external payable onlyProxy {


		
		Config config = Config(Registry(registry).getAddress(CONFIG_ID));

		uint256 mintedLUSD;
		uint256 neededLUSDAmount;
		uint256 expectedLiquityProtocolRate;

		{ // scope to avoid stack too deep errors
			uint16 acr = adjustAcrForRequestor(config.adoptionContributionRate(), _caller);

			uint256 price = PriceFeed.lastGoodPrice();
			expectedLiquityProtocolRate = (TroveManager.checkRecoveryMode(price)) ? 0 : TroveManager.getBorrowingRateWithDecay();

			neededLUSDAmount = calcNeededLiquityLUSDAmount(_LUSDRequestedDebt, expectedLiquityProtocolRate, acr);

			uint256 previousLUSDBalance = getLUSDBalance(address(this));

			BorrowerOperations.openTrove{value: msg.value}(
				LIQUITY_PROTOCOL_MAX_BORROWING_FEE,
				neededLUSDAmount,
				_upperHint,
				_lowerHint
			);

			mintedLUSD = getLUSDBalance(address(this)) - previousLUSDBalance;
		}

		uint256 adoptionContributionLUSD = mintedLUSD - _LUSDRequestedDebt;

		CentralLogger logger = CentralLogger(Registry(registry).getAddress(CENTRAL_LOGGER_ID));
		logger.log(
			address(this), _caller, "openCreditLineLiquity",
			abi.encode(_LUSDRequestedDebt, _LUSDTo, _upperHint, _lowerHint, neededLUSDAmount, mintedLUSD, expectedLiquityProtocolRate)
		);

		sendLUSD(config.adoptionDAOAddress(), adoptionContributionLUSD);

		sendLUSD(_LUSDTo, _LUSDRequestedDebt);
	}


	function closeCreditLineLiquity(address _LUSDFrom, address payable _collateralTo, address _caller) public onlyProxy {


		uint256 collateral = TroveManager.getTroveColl(address(this));

		uint256 debtToRepay = TroveManager.getTroveDebt(address(this)) - LIQUITY_LUSD_GAS_COMPENSATION;

		pullLUSDFrom(_LUSDFrom, debtToRepay);

		BorrowerOperations.closeTrove(); 

		CentralLogger logger = CentralLogger(Registry(registry).getAddress(CENTRAL_LOGGER_ID));
		logger.log(
			address(this), _caller, "closeCreditLineLiquity",
			abi.encode(_LUSDFrom, _collateralTo, debtToRepay, collateral)
		);

		(bool success, ) = _collateralTo.call{ value: collateral }("");
		require(success, "Sending collateral ETH failed");

	}

	function closeCreditLineLiquityWithPermit(address _LUSDFrom, address payable _collateralTo, uint8 v, bytes32 r, bytes32 s, address _caller) external onlyProxy {

		uint256 debtToRepay = TroveManager.getTroveDebt(address(this)) - LIQUITY_LUSD_GAS_COMPENSATION;

		LUSDToken.permit(_LUSDFrom, address(this), debtToRepay, type(uint256).max, v, r, s);

		closeCreditLineLiquity(_LUSDFrom, _collateralTo, _caller);
	}

	function adjustCreditLineLiquity(
		bool _isDebtIncrease,
		uint256 _LUSDRequestedChange,
		address _LUSDAddress,
		uint256 _collWithdrawal,
		address _collateralTo,
		address _upperHint, address _lowerHint, address _caller
	) public payable onlyProxy {



		LocalVariables_adjustCreditLineLiquity memory vars;
		
		vars.config = Config(Registry(registry).getAddress(CONFIG_ID));

		vars.isDebtIncrease = _isDebtIncrease && (_LUSDRequestedChange > 0);

		if (vars.isDebtIncrease) {
			{
			vars.acr = adjustAcrForRequestor(vars.config.adoptionContributionRate(), _caller);

			vars.price = PriceFeed.lastGoodPrice();
			vars.expectedLiquityProtocolRate = (TroveManager.checkRecoveryMode(vars.price)) ? 0 : TroveManager.getBorrowingRateWithDecay();

			vars.neededLUSDChange = calcNeededLiquityLUSDAmount(_LUSDRequestedChange, vars.expectedLiquityProtocolRate, vars.acr);
			}
		} else {
			vars.neededLUSDChange = _LUSDRequestedChange;

			if (vars.neededLUSDChange > 0) {
				pullLUSDFrom(_LUSDAddress, vars.neededLUSDChange);
			}
		}

		vars.previousLUSDBalance = getLUSDBalance(address(this));
		vars.previousETHBalance = address(this).balance;

		BorrowerOperations.adjustTrove{value: msg.value}(
				LIQUITY_PROTOCOL_MAX_BORROWING_FEE,
				_collWithdrawal,
				vars.neededLUSDChange,
				vars.isDebtIncrease,
				_upperHint,
				_lowerHint
			);

		CentralLogger logger = CentralLogger(Registry(registry).getAddress(CENTRAL_LOGGER_ID));

		if (vars.isDebtIncrease) {
			vars.mintedLUSD = getLUSDBalance(address(this)) - vars.previousLUSDBalance;
			vars.adoptionContributionLUSD = vars.mintedLUSD - _LUSDRequestedChange;

			sendLUSD(vars.config.adoptionDAOAddress(), vars.adoptionContributionLUSD);

			sendLUSD(_LUSDAddress, _LUSDRequestedChange);


			logger.log(
				address(this), _caller, "adjustCreditLineLiquity",
				abi.encode(
					AdjustCreditLineLiquityChoices.DebtIncrease, 
					vars.mintedLUSD, 
					_LUSDRequestedChange,
					_LUSDAddress
					)
			);

		} else if (vars.neededLUSDChange > 0) {
			logger.log(
				address(this), _caller, "adjustCreditLineLiquity",
				abi.encode(AdjustCreditLineLiquityChoices.DebtDecrease, _LUSDRequestedChange, _LUSDAddress)
			);
		}

		if (msg.value > 0) {
			logger.log(
				address(this), _caller, "adjustCreditLineLiquity",
				abi.encode(AdjustCreditLineLiquityChoices.CollateralIncrease, msg.value, _caller)
			);

		} else if (_collWithdrawal > 0) {

			uint256 collateralChange = address(this).balance - vars.previousETHBalance;

			logger.log(
				address(this), _caller, "adjustCreditLineLiquity",
				abi.encode(AdjustCreditLineLiquityChoices.CollateralDecrease, collateralChange, _collWithdrawal, _collateralTo)
			);

			(bool success, ) = _collateralTo.call{ value: collateralChange }("");
			require(success, "Sending collateral ETH failed");
		}
	}

	function adjustCreditLineLiquityWithPermit(
		uint256 _LUSDRequestedChange,
		address _LUSDFrom,
		uint256 _collWithdrawal,
		address _collateralTo,
		address _upperHint, address _lowerHint,
		uint8 v, bytes32 r, bytes32 s,
		address _caller
	) external payable onlyProxy {

		LUSDToken.permit(_LUSDFrom, address(this), _LUSDRequestedChange, type(uint256).max, v, r, s);

		adjustCreditLineLiquity(false, _LUSDRequestedChange, _LUSDFrom, _collWithdrawal, _collateralTo, _upperHint, _lowerHint, _caller);
	}

	function claimRemainingCollateralLiquity(address payable _collateralTo, address _caller) external onlyProxy {

		
		uint256 remainingCollateral = CollSurplusPool.getCollateral(address(this));

		BorrowerOperations.claimCollateral();

		CentralLogger logger = CentralLogger(Registry(registry).getAddress(CENTRAL_LOGGER_ID));
		logger.log(
			address(this), _caller, "claimRemainingCollateralLiquity",
			abi.encode(_collateralTo, remainingCollateral)
		);

		(bool success, ) = _collateralTo.call{ value: remainingCollateral }("");
		require(success, "Sending of claimed collateral failed.");
	}

	function addCollateralLiquity(address _upperHint, address _lowerHint, address _caller) external payable onlyProxy {


		BorrowerOperations.addColl{value: msg.value}(_upperHint, _lowerHint);

		CentralLogger logger = CentralLogger(Registry(registry).getAddress(CENTRAL_LOGGER_ID));
		logger.log(
			address(this), _caller, "addCollateralLiquity",
			abi.encode(msg.value, _caller)
		);
	}


	function withdrawCollateralLiquity(uint256 _collWithdrawal, address payable _collateralTo, address _upperHint, address _lowerHint, address _caller) external onlyProxy {


		BorrowerOperations.withdrawColl(_collWithdrawal, _upperHint, _lowerHint);

		CentralLogger logger = CentralLogger(Registry(registry).getAddress(CENTRAL_LOGGER_ID));
		logger.log(
			address(this), _caller, "withdrawCollateralLiquity",
			abi.encode(_collWithdrawal, _collateralTo)
		);

		(bool success, ) = _collateralTo.call{ value: _collWithdrawal }("");
		require(success, "Sending collateral ETH failed");

	}

	function repayLUSDLiquity(uint256 _LUSDRequestedChange, address _LUSDFrom, address _upperHint, address _lowerHint, address _caller) public onlyProxy {

		pullLUSDFrom(_LUSDFrom, _LUSDRequestedChange);

		BorrowerOperations.repayLUSD(_LUSDRequestedChange, _upperHint, _lowerHint);

		CentralLogger logger = CentralLogger(Registry(registry).getAddress(CENTRAL_LOGGER_ID));
		logger.log(
			address(this), _caller, "repayLUSDLiquity",
			abi.encode(_LUSDRequestedChange, _LUSDFrom)
		);

	}

	function repayLUSDLiquityWithPermit(uint256 _LUSDRequestedChange, address _LUSDFrom, address _upperHint, address _lowerHint, uint8 v, bytes32 r, bytes32 s, address _caller) external onlyProxy {

		LUSDToken.permit(_LUSDFrom, address(this), _LUSDRequestedChange, type(uint256).max, v, r, s);

		repayLUSDLiquity(_LUSDRequestedChange, _LUSDFrom, _upperHint, _lowerHint, _caller);
	}

}