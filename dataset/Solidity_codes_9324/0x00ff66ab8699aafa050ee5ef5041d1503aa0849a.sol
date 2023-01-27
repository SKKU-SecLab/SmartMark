




pragma solidity 0.6.11;

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


    function setAddresses(
        address _troveManagerAddress,
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _gasPoolAddress,
        address _collSurplusPoolAddress,
        address _priceFeedAddress,
        address _sortedTrovesAddress,
        address _lusdTokenAddress,
        address _lqtyStakingAddress
    ) external;


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

}





pragma solidity 0.6.11;

interface IStabilityPool {


    
    event StabilityPoolETHBalanceUpdated(uint _newBalance);
    event StabilityPoolLUSDBalanceUpdated(uint _newBalance);

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event LUSDTokenAddressChanged(address _newLUSDTokenAddress);
    event SortedTrovesAddressChanged(address _newSortedTrovesAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event CommunityIssuanceAddressChanged(address _newCommunityIssuanceAddress);

    event P_Updated(uint _P);
    event S_Updated(uint _S, uint128 _epoch, uint128 _scale);
    event G_Updated(uint _G, uint128 _epoch, uint128 _scale);
    event EpochUpdated(uint128 _currentEpoch);
    event ScaleUpdated(uint128 _currentScale);

    event FrontEndRegistered(address indexed _frontEnd, uint _kickbackRate);
    event FrontEndTagSet(address indexed _depositor, address indexed _frontEnd);

    event DepositSnapshotUpdated(address indexed _depositor, uint _P, uint _S, uint _G);
    event FrontEndSnapshotUpdated(address indexed _frontEnd, uint _P, uint _G);
    event UserDepositChanged(address indexed _depositor, uint _newDeposit);
    event FrontEndStakeChanged(address indexed _frontEnd, uint _newFrontEndStake, address _depositor);

    event ETHGainWithdrawn(address indexed _depositor, uint _ETH, uint _LUSDLoss);
    event LQTYPaidToDepositor(address indexed _depositor, uint _LQTY);
    event LQTYPaidToFrontEnd(address indexed _frontEnd, uint _LQTY);
    event EtherSent(address _to, uint _amount);


    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress,
        address _lusdTokenAddress,
        address _sortedTrovesAddress,
        address _priceFeedAddress,
        address _communityIssuanceAddress
    ) external;


    function provideToSP(uint _amount, address _frontEndTag) external;


    function withdrawFromSP(uint _amount) external;


    function withdrawETHGainToTrove(address _upperHint, address _lowerHint) external;


    function registerFrontEnd(uint _kickbackRate) external;


    function offset(uint _debt, uint _coll) external;


    function getETH() external view returns (uint);


    function getTotalLUSDDeposits() external view returns (uint);


    function getDepositorETHGain(address _depositor) external view returns (uint);


    function getDepositorLQTYGain(address _depositor) external view returns (uint);


    function getFrontEndLQTYGain(address _frontEnd) external view returns (uint);


    function getCompoundedLUSDDeposit(address _depositor) external view returns (uint);


    function getCompoundedFrontEndStake(address _frontEnd) external view returns (uint);


}





pragma solidity 0.6.11;

interface IPriceFeed {


    event LastGoodPriceUpdated(uint _lastGoodPrice);
   
    function fetchPrice() external returns (uint);

}





pragma solidity 0.6.11;

interface ILiquityBase {

    function priceFeed() external view returns (IPriceFeed);

}





pragma solidity 0.6.11;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}





pragma solidity 0.6.11;

interface IERC2612 {

    function permit(address owner, address spender, uint256 amount, 
                    uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    
    function nonces(address owner) external view returns (uint256);

    
    function version() external view returns (string memory);

    function permitTypeHash() external view returns (bytes32);

    function domainSeparator() external view returns (bytes32);

}





pragma solidity 0.6.11;


interface ILUSDToken is IERC20, IERC2612 { 

    

    event TroveManagerAddressChanged(address _troveManagerAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);

    event LUSDTokenBalanceUpdated(address _user, uint _amount);


    function mint(address _account, uint256 _amount) external;


    function burn(address _account, uint256 _amount) external;


    function sendToPool(address _sender,  address poolAddress, uint256 _amount) external;


    function returnFromPool(address poolAddress, address user, uint256 _amount ) external;

}





pragma solidity 0.6.11;


interface ILQTYToken is IERC20, IERC2612 { 

   
    
    event CommunityIssuanceAddressSet(address _communityIssuanceAddress);
    event LQTYStakingAddressSet(address _lqtyStakingAddress);
    event LockupContractFactoryAddressSet(address _lockupContractFactoryAddress);

    
    function sendToLQTYStaking(address _sender, uint256 _amount) external;


    function getDeploymentStartTime() external view returns (uint256);


    function getLpRewardsEntitlement() external view returns (uint256);

}





pragma solidity 0.6.11;

interface ILQTYStaking {


    
    event LQTYTokenAddressSet(address _lqtyTokenAddress);
    event LUSDTokenAddressSet(address _lusdTokenAddress);
    event TroveManagerAddressSet(address _troveManager);
    event BorrowerOperationsAddressSet(address _borrowerOperationsAddress);
    event ActivePoolAddressSet(address _activePoolAddress);

    event StakeChanged(address indexed staker, uint newStake);
    event StakingGainsWithdrawn(address indexed staker, uint LUSDGain, uint ETHGain);
    event F_ETHUpdated(uint _F_ETH);
    event F_LUSDUpdated(uint _F_LUSD);
    event TotalLQTYStakedUpdated(uint _totalLQTYStaked);
    event EtherSent(address _account, uint _amount);
    event StakerSnapshotsUpdated(address _staker, uint _F_ETH, uint _F_LUSD);


    function setAddresses
    (
        address _lqtyTokenAddress,
        address _lusdTokenAddress,
        address _troveManagerAddress, 
        address _borrowerOperationsAddress,
        address _activePoolAddress
    )  external;

    function stake(uint _LQTYamount) external;


    function unstake(uint _LQTYamount) external;


    function increaseF_ETH(uint _ETHFee) external; 


    function increaseF_LUSD(uint _LQTYFee) external;  


    function getPendingETHGain(address _user) external view returns (uint);


    function getPendingLUSDGain(address _user) external view returns (uint);

}





pragma solidity 0.6.11;





interface ITroveManager is ILiquityBase {

    

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


    function setAddresses(
        address _borrowerOperationsAddress,
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _gasPoolAddress,
        address _collSurplusPoolAddress,
        address _priceFeedAddress,
        address _lusdTokenAddress,
        address _sortedTrovesAddress,
        address _lqtyTokenAddress,
        address _lqtyStakingAddress
    ) external;


    function stabilityPool() external view returns (IStabilityPool);

    function lusdToken() external view returns (ILUSDToken);

    function lqtyToken() external view returns (ILQTYToken);

    function lqtyStaking() external view returns (ILQTYStaking);


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

}





pragma solidity 0.6.11;

interface ISortedTroves {


    
    event SortedTrovesAddressChanged(address _sortedDoublyLLAddress);
    event BorrowerOperationsAddressChanged(address _borrowerOperationsAddress);
    event NodeAdded(address _id, uint _NICR);
    event NodeRemoved(address _id);

    
    function setParams(uint256 _size, address _TroveManagerAddress, address _borrowerOperationsAddress) external;


    function insert(address _id, uint256 _ICR, address _prevId, address _nextId) external;


    function remove(address _id) external;


    function reInsert(address _id, uint256 _newICR, address _prevId, address _nextId) external;


    function contains(address _id) external view returns (bool);


    function isFull() external view returns (bool);


    function isEmpty() external view returns (bool);


    function getSize() external view returns (uint256);


    function getMaxSize() external view returns (uint256);


    function getFirst() external view returns (address);


    function getLast() external view returns (address);


    function getNext(address _id) external view returns (address);


    function getPrev(address _id) external view returns (address);


    function validInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (bool);


    function findInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (address, address);

}





pragma solidity 0.6.11;

interface ICommunityIssuance { 

    
    
    event LQTYTokenAddressSet(address _lqtyTokenAddress);
    event StabilityPoolAddressSet(address _stabilityPoolAddress);
    event TotalLQTYIssuedUpdated(uint _totalLQTYIssued);


    function setAddresses(address _lqtyTokenAddress, address _stabilityPoolAddress) external;


    function issueLQTY() external returns (uint);


    function sendLQTY(address _account, uint _LQTYamount) external;

}




pragma solidity 0.6.11;


contract BaseMath {

    uint constant public DECIMAL_PRECISION = 1e18;
}





pragma solidity 0.6.11;

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





pragma solidity 0.6.11;

library console {

	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function log() internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log()"));
		ignored;
	}	function logInt(int p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(int)", p0));
		ignored;
	}

	function logUint(uint p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint)", p0));
		ignored;
	}

	function logString(string memory p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string)", p0));
		ignored;
	}

	function logBool(bool p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool)", p0));
		ignored;
	}

	function logAddress(address p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address)", p0));
		ignored;
	}

	function logBytes(bytes memory p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes)", p0));
		ignored;
	}

	function logByte(byte p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(byte)", p0));
		ignored;
	}

	function logBytes1(bytes1 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes1)", p0));
		ignored;
	}

	function logBytes2(bytes2 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes2)", p0));
		ignored;
	}

	function logBytes3(bytes3 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes3)", p0));
		ignored;
	}

	function logBytes4(bytes4 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes4)", p0));
		ignored;
	}

	function logBytes5(bytes5 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes5)", p0));
		ignored;
	}

	function logBytes6(bytes6 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes6)", p0));
		ignored;
	}

	function logBytes7(bytes7 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes7)", p0));
		ignored;
	}

	function logBytes8(bytes8 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes8)", p0));
		ignored;
	}

	function logBytes9(bytes9 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes9)", p0));
		ignored;
	}

	function logBytes10(bytes10 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes10)", p0));
		ignored;
	}

	function logBytes11(bytes11 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes11)", p0));
		ignored;
	}

	function logBytes12(bytes12 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes12)", p0));
		ignored;
	}

	function logBytes13(bytes13 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes13)", p0));
		ignored;
	}

	function logBytes14(bytes14 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes14)", p0));
		ignored;
	}

	function logBytes15(bytes15 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes15)", p0));
		ignored;
	}

	function logBytes16(bytes16 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes16)", p0));
		ignored;
	}

	function logBytes17(bytes17 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes17)", p0));
		ignored;
	}

	function logBytes18(bytes18 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes18)", p0));
		ignored;
	}

	function logBytes19(bytes19 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes19)", p0));
		ignored;
	}

	function logBytes20(bytes20 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes20)", p0));
		ignored;
	}

	function logBytes21(bytes21 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes21)", p0));
		ignored;
	}

	function logBytes22(bytes22 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes22)", p0));
		ignored;
	}

	function logBytes23(bytes23 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes23)", p0));
		ignored;
	}

	function logBytes24(bytes24 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes24)", p0));
		ignored;
	}

	function logBytes25(bytes25 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes25)", p0));
		ignored;
	}

	function logBytes26(bytes26 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes26)", p0));
		ignored;
	}

	function logBytes27(bytes27 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes27)", p0));
		ignored;
	}

	function logBytes28(bytes28 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes28)", p0));
		ignored;
	}

	function logBytes29(bytes29 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes29)", p0));
		ignored;
	}

	function logBytes30(bytes30 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes30)", p0));
		ignored;
	}

	function logBytes31(bytes31 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes31)", p0));
		ignored;
	}

	function logBytes32(bytes32 p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes32)", p0));
		ignored;
	}

	function log(uint p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint)", p0));
		ignored;
	}

	function log(string memory p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string)", p0));
		ignored;
	}

	function log(bool p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool)", p0));
		ignored;
	}

	function log(address p0) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address)", p0));
		ignored;
	}

	function log(uint p0, uint p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint)", p0, p1));
		ignored;
	}

	function log(uint p0, string memory p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string)", p0, p1));
		ignored;
	}

	function log(uint p0, bool p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool)", p0, p1));
		ignored;
	}

	function log(uint p0, address p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address)", p0, p1));
		ignored;
	}

	function log(string memory p0, uint p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint)", p0, p1));
		ignored;
	}

	function log(string memory p0, string memory p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string)", p0, p1));
		ignored;
	}

	function log(string memory p0, bool p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool)", p0, p1));
		ignored;
	}

	function log(string memory p0, address p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address)", p0, p1));
		ignored;
	}

	function log(bool p0, uint p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint)", p0, p1));
		ignored;
	}

	function log(bool p0, string memory p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string)", p0, p1));
		ignored;
	}

	function log(bool p0, bool p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool)", p0, p1));
		ignored;
	}

	function log(bool p0, address p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address)", p0, p1));
		ignored;
	}

	function log(address p0, uint p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint)", p0, p1));
		ignored;
	}

	function log(address p0, string memory p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string)", p0, p1));
		ignored;
	}

	function log(address p0, bool p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool)", p0, p1));
		ignored;
	}

	function log(address p0, address p1) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address)", p0, p1));
		ignored;
	}

	function log(uint p0, uint p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, uint p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, uint p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, uint p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, string memory p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, string memory p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, string memory p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, string memory p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, bool p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, bool p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, bool p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, bool p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, address p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, address p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, address p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, address p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, uint p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, uint p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, uint p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, uint p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, string memory p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, string memory p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, string memory p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, bool p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, bool p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, bool p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, bool p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, address p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, address p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, address p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, address p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, uint p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, uint p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, uint p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, uint p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, string memory p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, string memory p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, string memory p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, string memory p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, bool p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, bool p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, bool p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, bool p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, address p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, address p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, address p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, address p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
		ignored;
	}

	function log(address p0, uint p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
		ignored;
	}

	function log(address p0, uint p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
		ignored;
	}

	function log(address p0, uint p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
		ignored;
	}

	function log(address p0, uint p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
		ignored;
	}

	function log(address p0, string memory p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
		ignored;
	}

	function log(address p0, string memory p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
		ignored;
	}

	function log(address p0, string memory p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
		ignored;
	}

	function log(address p0, string memory p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
		ignored;
	}

	function log(address p0, bool p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
		ignored;
	}

	function log(address p0, bool p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
		ignored;
	}

	function log(address p0, bool p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
		ignored;
	}

	function log(address p0, bool p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
		ignored;
	}

	function log(address p0, address p1, uint p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
		ignored;
	}

	function log(address p0, address p1, string memory p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
		ignored;
	}

	function log(address p0, address p1, bool p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
		ignored;
	}

	function log(address p0, address p1, address p2) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, uint p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, bool p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, address p2, uint p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, address p2, bool p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, address p2, address p3) internal view {

		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
		ignored;
	}

}





pragma solidity 0.6.11;


library LiquityMath {

    using SafeMath for uint;

    uint internal constant DECIMAL_PRECISION = 1e18;

    uint internal constant NICR_PRECISION = 1e20;

    function _min(uint _a, uint _b) internal pure returns (uint) {

        return (_a < _b) ? _a : _b;
    }

    function _max(uint _a, uint _b) internal pure returns (uint) {

        return (_a >= _b) ? _a : _b;
    }

    function decMul(uint x, uint y) internal pure returns (uint decProd) {

        uint prod_xy = x.mul(y);

        decProd = prod_xy.add(DECIMAL_PRECISION / 2).div(DECIMAL_PRECISION);
    }

    function _decPow(uint _base, uint _minutes) internal pure returns (uint) {

       
        if (_minutes > 525600000) {_minutes = 525600000;}  // cap to avoid overflow
    
        if (_minutes == 0) {return DECIMAL_PRECISION;}

        uint y = DECIMAL_PRECISION;
        uint x = _base;
        uint n = _minutes;

        while (n > 1) {
            if (n % 2 == 0) {
                x = decMul(x, x);
                n = n.div(2);
            } else { // if (n % 2 != 0)
                y = decMul(x, y);
                x = decMul(x, x);
                n = (n.sub(1)).div(2);
            }
        }

        return decMul(x, y);
  }

    function _getAbsoluteDifference(uint _a, uint _b) internal pure returns (uint) {

        return (_a >= _b) ? _a.sub(_b) : _b.sub(_a);
    }

    function _computeNominalCR(uint _coll, uint _debt) internal pure returns (uint) {

        if (_debt > 0) {
            return _coll.mul(NICR_PRECISION).div(_debt);
        }
        else { // if (_debt == 0)
            return 2**256 - 1;
        }
    }

    function _computeCR(uint _coll, uint _debt, uint _price) internal pure returns (uint) {

        if (_debt > 0) {
            uint newCollRatio = _coll.mul(_price).div(_debt);

            return newCollRatio;
        }
        else { // if (_debt == 0)
            return 2**256 - 1; 
        }
    }
}





pragma solidity 0.6.11;

interface IPool {

    
    
    event ETHBalanceUpdated(uint _newBalance);
    event LUSDBalanceUpdated(uint _newBalance);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event EtherSent(address _to, uint _amount);

    
    function getETH() external view returns (uint);


    function getLUSDDebt() external view returns (uint);


    function increaseLUSDDebt(uint _amount) external;


    function decreaseLUSDDebt(uint _amount) external;

}





pragma solidity 0.6.11;

interface IActivePool is IPool {

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolLUSDDebtUpdated(uint _LUSDDebt);
    event ActivePoolETHBalanceUpdated(uint _ETH);

    function sendETH(address _account, uint _amount) external;

}





pragma solidity 0.6.11;

interface IDefaultPool is IPool {

    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event DefaultPoolLUSDDebtUpdated(uint _LUSDDebt);
    event DefaultPoolETHBalanceUpdated(uint _ETH);

    function sendETHToActivePool(uint _amount) external;

}





pragma solidity 0.6.11;






contract LiquityBase is BaseMath, ILiquityBase {

    using SafeMath for uint;

    uint constant public _100pct = 1000000000000000000; // 1e18 == 100%

    uint constant public MCR = 1100000000000000000; // 110%

    uint constant public CCR = 1500000000000000000; // 150%

    uint constant public LUSD_GAS_COMPENSATION = 200e18;

    uint constant public MIN_NET_DEBT = 1800e18;

    uint constant public PERCENT_DIVISOR = 200; // dividing by 200 yields 0.5%

    uint constant public BORROWING_FEE_FLOOR = DECIMAL_PRECISION / 1000 * 5; // 0.5%

    IActivePool public activePool;

    IDefaultPool public defaultPool;

    IPriceFeed public override priceFeed;


    function _getCompositeDebt(uint _debt) internal pure returns (uint) {

        return _debt.add(LUSD_GAS_COMPENSATION);
    }

    function _getNetDebt(uint _debt) internal pure returns (uint) {

        return _debt.sub(LUSD_GAS_COMPENSATION);
    }

    function _getCollGasCompensation(uint _entireColl) internal pure returns (uint) {

        return _entireColl / PERCENT_DIVISOR;
    }

    function getEntireSystemColl() public view returns (uint entireSystemColl) {

        uint activeColl = activePool.getETH();
        uint liquidatedColl = defaultPool.getETH();

        return activeColl.add(liquidatedColl);
    }

    function getEntireSystemDebt() public view returns (uint entireSystemDebt) {

        uint activeDebt = activePool.getLUSDDebt();
        uint closedDebt = defaultPool.getLUSDDebt();

        return activeDebt.add(closedDebt);
    }

    function _getTCR(uint _price) internal view returns (uint TCR) {

        uint entireSystemColl = getEntireSystemColl();
        uint entireSystemDebt = getEntireSystemDebt();

        TCR = LiquityMath._computeCR(entireSystemColl, entireSystemDebt, _price);

        return TCR;
    }

    function _checkRecoveryMode(uint _price) internal view returns (bool) {

        uint TCR = _getTCR(_price);

        return TCR < CCR;
    }

    function _requireUserAcceptsFee(uint _fee, uint _amount, uint _maxFeePercentage) internal pure {

        uint feePercentage = _fee.mul(DECIMAL_PRECISION).div(_amount);
        require(feePercentage <= _maxFeePercentage, "Fee exceeded provided maximum");
    }
}





pragma solidity 0.6.11;


library LiquitySafeMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128) {

        uint128 c = a + b;
        require(c >= a, "LiquitySafeMath128: addition overflow");

        return c;
    }
   
    function sub(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b <= a, "LiquitySafeMath128: subtraction overflow");
        uint128 c = a - b;

        return c;
    }
}





pragma solidity 0.6.11;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {

        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
        
    function _renounceOwnership() internal {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}





pragma solidity 0.6.11;


contract CheckContract {

    function checkContract(address _account) internal view {

        require(_account != address(0), "Account cannot be zero address");

        uint256 size;
        assembly { size := extcodesize(_account) }
        require(size > 0, "Account code size cannot be zero");
    }
}





pragma solidity 0.6.11;













contract StabilityPool is LiquityBase, Ownable, CheckContract, IStabilityPool {

    using LiquitySafeMath128 for uint128;

    string constant public NAME = "StabilityPool";

    IBorrowerOperations public borrowerOperations;

    ITroveManager public troveManager;

    ILUSDToken public lusdToken;

    ISortedTroves public sortedTroves;

    ICommunityIssuance public communityIssuance;

    uint256 internal ETH;  // deposited ether tracker

    uint256 internal totalLUSDDeposits;


    struct FrontEnd {
        uint kickbackRate;
        bool registered;
    }

    struct Deposit {
        uint initialValue;
        address frontEndTag;
    }

    struct Snapshots {
        uint S;
        uint P;
        uint G;
        uint128 scale;
        uint128 epoch;
    }

    mapping (address => Deposit) public deposits;  // depositor address -> Deposit struct
    mapping (address => Snapshots) public depositSnapshots;  // depositor address -> snapshots struct

    mapping (address => FrontEnd) public frontEnds;  // front end address -> FrontEnd struct
    mapping (address => uint) public frontEndStakes; // front end address -> last recorded total deposits, tagged with that front end
    mapping (address => Snapshots) public frontEndSnapshots; // front end address -> snapshots struct

    uint public P = DECIMAL_PRECISION;

    uint public constant SCALE_FACTOR = 1e9;

    uint128 public currentScale;

    uint128 public currentEpoch;

    mapping (uint128 => mapping(uint128 => uint)) public epochToScaleToSum;

    mapping (uint128 => mapping(uint128 => uint)) public epochToScaleToG;

    uint public lastLQTYError;
    uint public lastETHError_Offset;
    uint public lastLUSDLossError_Offset;


    event StabilityPoolETHBalanceUpdated(uint _newBalance);
    event StabilityPoolLUSDBalanceUpdated(uint _newBalance);

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event LUSDTokenAddressChanged(address _newLUSDTokenAddress);
    event SortedTrovesAddressChanged(address _newSortedTrovesAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event CommunityIssuanceAddressChanged(address _newCommunityIssuanceAddress);

    event P_Updated(uint _P);
    event S_Updated(uint _S, uint128 _epoch, uint128 _scale);
    event G_Updated(uint _G, uint128 _epoch, uint128 _scale);
    event EpochUpdated(uint128 _currentEpoch);
    event ScaleUpdated(uint128 _currentScale);

    event FrontEndRegistered(address indexed _frontEnd, uint _kickbackRate);
    event FrontEndTagSet(address indexed _depositor, address indexed _frontEnd);

    event DepositSnapshotUpdated(address indexed _depositor, uint _P, uint _S, uint _G);
    event FrontEndSnapshotUpdated(address indexed _frontEnd, uint _P, uint _G);
    event UserDepositChanged(address indexed _depositor, uint _newDeposit);
    event FrontEndStakeChanged(address indexed _frontEnd, uint _newFrontEndStake, address _depositor);

    event ETHGainWithdrawn(address indexed _depositor, uint _ETH, uint _LUSDLoss);
    event LQTYPaidToDepositor(address indexed _depositor, uint _LQTY);
    event LQTYPaidToFrontEnd(address indexed _frontEnd, uint _LQTY);
    event EtherSent(address _to, uint _amount);


    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress,
        address _lusdTokenAddress,
        address _sortedTrovesAddress,
        address _priceFeedAddress,
        address _communityIssuanceAddress
    )
        external
        override
        onlyOwner
    {

        checkContract(_borrowerOperationsAddress);
        checkContract(_troveManagerAddress);
        checkContract(_activePoolAddress);
        checkContract(_lusdTokenAddress);
        checkContract(_sortedTrovesAddress);
        checkContract(_priceFeedAddress);
        checkContract(_communityIssuanceAddress);

        borrowerOperations = IBorrowerOperations(_borrowerOperationsAddress);
        troveManager = ITroveManager(_troveManagerAddress);
        activePool = IActivePool(_activePoolAddress);
        lusdToken = ILUSDToken(_lusdTokenAddress);
        sortedTroves = ISortedTroves(_sortedTrovesAddress);
        priceFeed = IPriceFeed(_priceFeedAddress);
        communityIssuance = ICommunityIssuance(_communityIssuanceAddress);

        emit BorrowerOperationsAddressChanged(_borrowerOperationsAddress);
        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit ActivePoolAddressChanged(_activePoolAddress);
        emit LUSDTokenAddressChanged(_lusdTokenAddress);
        emit SortedTrovesAddressChanged(_sortedTrovesAddress);
        emit PriceFeedAddressChanged(_priceFeedAddress);
        emit CommunityIssuanceAddressChanged(_communityIssuanceAddress);

        _renounceOwnership();
    }


    function getETH() external view override returns (uint) {

        return ETH;
    }

    function getTotalLUSDDeposits() external view override returns (uint) {

        return totalLUSDDeposits;
    }


    function provideToSP(uint _amount, address _frontEndTag) external override {

        _requireFrontEndIsRegisteredOrZero(_frontEndTag);
        _requireFrontEndNotRegistered(msg.sender);
        _requireNonZeroAmount(_amount);

        uint initialDeposit = deposits[msg.sender].initialValue;

        ICommunityIssuance communityIssuanceCached = communityIssuance;

        _triggerLQTYIssuance(communityIssuanceCached);

        if (initialDeposit == 0) {_setFrontEndTag(msg.sender, _frontEndTag);}
        uint depositorETHGain = getDepositorETHGain(msg.sender);
        uint compoundedLUSDDeposit = getCompoundedLUSDDeposit(msg.sender);
        uint LUSDLoss = initialDeposit.sub(compoundedLUSDDeposit); // Needed only for event log

        address frontEnd = deposits[msg.sender].frontEndTag;
        _payOutLQTYGains(communityIssuanceCached, msg.sender, frontEnd);

        uint compoundedFrontEndStake = getCompoundedFrontEndStake(frontEnd);
        uint newFrontEndStake = compoundedFrontEndStake.add(_amount);
        _updateFrontEndStakeAndSnapshots(frontEnd, newFrontEndStake);
        emit FrontEndStakeChanged(frontEnd, newFrontEndStake, msg.sender);

        _sendLUSDtoStabilityPool(msg.sender, _amount);

        uint newDeposit = compoundedLUSDDeposit.add(_amount);
        _updateDepositAndSnapshots(msg.sender, newDeposit);
        emit UserDepositChanged(msg.sender, newDeposit);

        emit ETHGainWithdrawn(msg.sender, depositorETHGain, LUSDLoss); // LUSD Loss required for event log

        _sendETHGainToDepositor(depositorETHGain);
     }

    function withdrawFromSP(uint _amount) external override {

        if (_amount !=0) {_requireNoUnderCollateralizedTroves();}
        uint initialDeposit = deposits[msg.sender].initialValue;
        _requireUserHasDeposit(initialDeposit);

        ICommunityIssuance communityIssuanceCached = communityIssuance;

        _triggerLQTYIssuance(communityIssuanceCached);

        uint depositorETHGain = getDepositorETHGain(msg.sender);

        uint compoundedLUSDDeposit = getCompoundedLUSDDeposit(msg.sender);
        uint LUSDtoWithdraw = LiquityMath._min(_amount, compoundedLUSDDeposit);
        uint LUSDLoss = initialDeposit.sub(compoundedLUSDDeposit); // Needed only for event log

        address frontEnd = deposits[msg.sender].frontEndTag;
        _payOutLQTYGains(communityIssuanceCached, msg.sender, frontEnd);
        
        uint compoundedFrontEndStake = getCompoundedFrontEndStake(frontEnd);
        uint newFrontEndStake = compoundedFrontEndStake.sub(LUSDtoWithdraw);
        _updateFrontEndStakeAndSnapshots(frontEnd, newFrontEndStake);
        emit FrontEndStakeChanged(frontEnd, newFrontEndStake, msg.sender);

        _sendLUSDToDepositor(msg.sender, LUSDtoWithdraw);

        uint newDeposit = compoundedLUSDDeposit.sub(LUSDtoWithdraw);
        _updateDepositAndSnapshots(msg.sender, newDeposit);
        emit UserDepositChanged(msg.sender, newDeposit);

        emit ETHGainWithdrawn(msg.sender, depositorETHGain, LUSDLoss);  // LUSD Loss required for event log

        _sendETHGainToDepositor(depositorETHGain);
    }

    function withdrawETHGainToTrove(address _upperHint, address _lowerHint) external override {

        uint initialDeposit = deposits[msg.sender].initialValue;
        _requireUserHasDeposit(initialDeposit);
        _requireUserHasTrove(msg.sender);
        _requireUserHasETHGain(msg.sender);

        ICommunityIssuance communityIssuanceCached = communityIssuance;

        _triggerLQTYIssuance(communityIssuanceCached);

        uint depositorETHGain = getDepositorETHGain(msg.sender);

        uint compoundedLUSDDeposit = getCompoundedLUSDDeposit(msg.sender);
        uint LUSDLoss = initialDeposit.sub(compoundedLUSDDeposit); // Needed only for event log

        address frontEnd = deposits[msg.sender].frontEndTag;
        _payOutLQTYGains(communityIssuanceCached, msg.sender, frontEnd);

        uint compoundedFrontEndStake = getCompoundedFrontEndStake(frontEnd);
        uint newFrontEndStake = compoundedFrontEndStake;
        _updateFrontEndStakeAndSnapshots(frontEnd, newFrontEndStake);
        emit FrontEndStakeChanged(frontEnd, newFrontEndStake, msg.sender);

        _updateDepositAndSnapshots(msg.sender, compoundedLUSDDeposit);

        emit ETHGainWithdrawn(msg.sender, depositorETHGain, LUSDLoss);
        emit UserDepositChanged(msg.sender, compoundedLUSDDeposit);

        ETH = ETH.sub(depositorETHGain);
        emit StabilityPoolETHBalanceUpdated(ETH);
        emit EtherSent(msg.sender, depositorETHGain);

        borrowerOperations.moveETHGainToTrove{ value: depositorETHGain }(msg.sender, _upperHint, _lowerHint);
    }


    function _triggerLQTYIssuance(ICommunityIssuance _communityIssuance) internal {

        uint LQTYIssuance = _communityIssuance.issueLQTY();
       _updateG(LQTYIssuance);
    }

    function _updateG(uint _LQTYIssuance) internal {

        uint totalLUSD = totalLUSDDeposits; // cached to save an SLOAD
        if (totalLUSD == 0 || _LQTYIssuance == 0) {return;}

        uint LQTYPerUnitStaked;
        LQTYPerUnitStaked =_computeLQTYPerUnitStaked(_LQTYIssuance, totalLUSD);

        uint marginalLQTYGain = LQTYPerUnitStaked.mul(P);
        epochToScaleToG[currentEpoch][currentScale] = epochToScaleToG[currentEpoch][currentScale].add(marginalLQTYGain);

        emit G_Updated(epochToScaleToG[currentEpoch][currentScale], currentEpoch, currentScale);
    }

    function _computeLQTYPerUnitStaked(uint _LQTYIssuance, uint _totalLUSDDeposits) internal returns (uint) {

        uint LQTYNumerator = _LQTYIssuance.mul(DECIMAL_PRECISION).add(lastLQTYError);

        uint LQTYPerUnitStaked = LQTYNumerator.div(_totalLUSDDeposits);
        lastLQTYError = LQTYNumerator.sub(LQTYPerUnitStaked.mul(_totalLUSDDeposits));

        return LQTYPerUnitStaked;
    }


    function offset(uint _debtToOffset, uint _collToAdd) external override {

        _requireCallerIsTroveManager();
        uint totalLUSD = totalLUSDDeposits; // cached to save an SLOAD
        if (totalLUSD == 0 || _debtToOffset == 0) { return; }

        _triggerLQTYIssuance(communityIssuance);

        (uint ETHGainPerUnitStaked,
            uint LUSDLossPerUnitStaked) = _computeRewardsPerUnitStaked(_collToAdd, _debtToOffset, totalLUSD);

        _updateRewardSumAndProduct(ETHGainPerUnitStaked, LUSDLossPerUnitStaked);  // updates S and P

        _moveOffsetCollAndDebt(_collToAdd, _debtToOffset);
    }


    function _computeRewardsPerUnitStaked(
        uint _collToAdd,
        uint _debtToOffset,
        uint _totalLUSDDeposits
    )
        internal
        returns (uint ETHGainPerUnitStaked, uint LUSDLossPerUnitStaked)
    {

        uint ETHNumerator = _collToAdd.mul(DECIMAL_PRECISION).add(lastETHError_Offset);

        assert(_debtToOffset <= _totalLUSDDeposits);
        if (_debtToOffset == _totalLUSDDeposits) {
            LUSDLossPerUnitStaked = DECIMAL_PRECISION;  // When the Pool depletes to 0, so does each deposit 
            lastLUSDLossError_Offset = 0;
        } else {
            uint LUSDLossNumerator = _debtToOffset.mul(DECIMAL_PRECISION).sub(lastLUSDLossError_Offset);
            LUSDLossPerUnitStaked = (LUSDLossNumerator.div(_totalLUSDDeposits)).add(1);
            lastLUSDLossError_Offset = (LUSDLossPerUnitStaked.mul(_totalLUSDDeposits)).sub(LUSDLossNumerator);
        }

        ETHGainPerUnitStaked = ETHNumerator.div(_totalLUSDDeposits);
        lastETHError_Offset = ETHNumerator.sub(ETHGainPerUnitStaked.mul(_totalLUSDDeposits));

        return (ETHGainPerUnitStaked, LUSDLossPerUnitStaked);
    }

    function _updateRewardSumAndProduct(uint _ETHGainPerUnitStaked, uint _LUSDLossPerUnitStaked) internal {

        uint currentP = P;
        uint newP;

        assert(_LUSDLossPerUnitStaked <= DECIMAL_PRECISION);
        uint newProductFactor = uint(DECIMAL_PRECISION).sub(_LUSDLossPerUnitStaked);

        uint128 currentScaleCached = currentScale;
        uint128 currentEpochCached = currentEpoch;
        uint currentS = epochToScaleToSum[currentEpochCached][currentScaleCached];

        uint marginalETHGain = _ETHGainPerUnitStaked.mul(currentP);
        uint newS = currentS.add(marginalETHGain);
        epochToScaleToSum[currentEpochCached][currentScaleCached] = newS;
        emit S_Updated(newS, currentEpochCached, currentScaleCached);

        if (newProductFactor == 0) {
            currentEpoch = currentEpochCached.add(1);
            emit EpochUpdated(currentEpoch);
            currentScale = 0;
            emit ScaleUpdated(currentScale);
            newP = DECIMAL_PRECISION;

        } else if (currentP.mul(newProductFactor).div(DECIMAL_PRECISION) < SCALE_FACTOR) {
            newP = currentP.mul(newProductFactor).mul(SCALE_FACTOR).div(DECIMAL_PRECISION); 
            currentScale = currentScaleCached.add(1);
            emit ScaleUpdated(currentScale);
        } else {
            newP = currentP.mul(newProductFactor).div(DECIMAL_PRECISION);
        }

        assert(newP > 0);
        P = newP;

        emit P_Updated(newP);
    }

    function _moveOffsetCollAndDebt(uint _collToAdd, uint _debtToOffset) internal {

        IActivePool activePoolCached = activePool;

        activePoolCached.decreaseLUSDDebt(_debtToOffset);
        _decreaseLUSD(_debtToOffset);

        lusdToken.burn(address(this), _debtToOffset);

        activePoolCached.sendETH(address(this), _collToAdd);
    }

    function _decreaseLUSD(uint _amount) internal {

        uint newTotalLUSDDeposits = totalLUSDDeposits.sub(_amount);
        totalLUSDDeposits = newTotalLUSDDeposits;
        emit StabilityPoolLUSDBalanceUpdated(newTotalLUSDDeposits);
    }


    function getDepositorETHGain(address _depositor) public view override returns (uint) {

        uint initialDeposit = deposits[_depositor].initialValue;

        if (initialDeposit == 0) { return 0; }

        Snapshots memory snapshots = depositSnapshots[_depositor];

        uint ETHGain = _getETHGainFromSnapshots(initialDeposit, snapshots);
        return ETHGain;
    }

    function _getETHGainFromSnapshots(uint initialDeposit, Snapshots memory snapshots) internal view returns (uint) {

        uint128 epochSnapshot = snapshots.epoch;
        uint128 scaleSnapshot = snapshots.scale;
        uint S_Snapshot = snapshots.S;
        uint P_Snapshot = snapshots.P;

        uint firstPortion = epochToScaleToSum[epochSnapshot][scaleSnapshot].sub(S_Snapshot);
        uint secondPortion = epochToScaleToSum[epochSnapshot][scaleSnapshot.add(1)].div(SCALE_FACTOR);

        uint ETHGain = initialDeposit.mul(firstPortion.add(secondPortion)).div(P_Snapshot).div(DECIMAL_PRECISION);

        return ETHGain;
    }

    function getDepositorLQTYGain(address _depositor) public view override returns (uint) {

        uint initialDeposit = deposits[_depositor].initialValue;
        if (initialDeposit == 0) {return 0;}

        address frontEndTag = deposits[_depositor].frontEndTag;

        uint kickbackRate = frontEndTag == address(0) ? DECIMAL_PRECISION : frontEnds[frontEndTag].kickbackRate;

        Snapshots memory snapshots = depositSnapshots[_depositor];

        uint LQTYGain = kickbackRate.mul(_getLQTYGainFromSnapshots(initialDeposit, snapshots)).div(DECIMAL_PRECISION);

        return LQTYGain;
    }

    function getFrontEndLQTYGain(address _frontEnd) public view override returns (uint) {

        uint frontEndStake = frontEndStakes[_frontEnd];
        if (frontEndStake == 0) { return 0; }

        uint kickbackRate = frontEnds[_frontEnd].kickbackRate;
        uint frontEndShare = uint(DECIMAL_PRECISION).sub(kickbackRate);

        Snapshots memory snapshots = frontEndSnapshots[_frontEnd];

        uint LQTYGain = frontEndShare.mul(_getLQTYGainFromSnapshots(frontEndStake, snapshots)).div(DECIMAL_PRECISION);
        return LQTYGain;
    }

    function _getLQTYGainFromSnapshots(uint initialStake, Snapshots memory snapshots) internal view returns (uint) {

        uint128 epochSnapshot = snapshots.epoch;
        uint128 scaleSnapshot = snapshots.scale;
        uint G_Snapshot = snapshots.G;
        uint P_Snapshot = snapshots.P;

        uint firstPortion = epochToScaleToG[epochSnapshot][scaleSnapshot].sub(G_Snapshot);
        uint secondPortion = epochToScaleToG[epochSnapshot][scaleSnapshot.add(1)].div(SCALE_FACTOR);

        uint LQTYGain = initialStake.mul(firstPortion.add(secondPortion)).div(P_Snapshot).div(DECIMAL_PRECISION);

        return LQTYGain;
    }


    function getCompoundedLUSDDeposit(address _depositor) public view override returns (uint) {

        uint initialDeposit = deposits[_depositor].initialValue;
        if (initialDeposit == 0) { return 0; }

        Snapshots memory snapshots = depositSnapshots[_depositor];

        uint compoundedDeposit = _getCompoundedStakeFromSnapshots(initialDeposit, snapshots);
        return compoundedDeposit;
    }

    function getCompoundedFrontEndStake(address _frontEnd) public view override returns (uint) {

        uint frontEndStake = frontEndStakes[_frontEnd];
        if (frontEndStake == 0) { return 0; }

        Snapshots memory snapshots = frontEndSnapshots[_frontEnd];

        uint compoundedFrontEndStake = _getCompoundedStakeFromSnapshots(frontEndStake, snapshots);
        return compoundedFrontEndStake;
    }

    function _getCompoundedStakeFromSnapshots(
        uint initialStake,
        Snapshots memory snapshots
    )
        internal
        view
        returns (uint)
    {

        uint snapshot_P = snapshots.P;
        uint128 scaleSnapshot = snapshots.scale;
        uint128 epochSnapshot = snapshots.epoch;

        if (epochSnapshot < currentEpoch) { return 0; }

        uint compoundedStake;
        uint128 scaleDiff = currentScale.sub(scaleSnapshot);

        if (scaleDiff == 0) {
            compoundedStake = initialStake.mul(P).div(snapshot_P);
        } else if (scaleDiff == 1) {
            compoundedStake = initialStake.mul(P).div(snapshot_P).div(SCALE_FACTOR);
        } else { // if scaleDiff >= 2
            compoundedStake = 0;
        }

        if (compoundedStake < initialStake.div(1e9)) {return 0;}

        return compoundedStake;
    }


    function _sendLUSDtoStabilityPool(address _address, uint _amount) internal {

        lusdToken.sendToPool(_address, address(this), _amount);
        uint newTotalLUSDDeposits = totalLUSDDeposits.add(_amount);
        totalLUSDDeposits = newTotalLUSDDeposits;
        emit StabilityPoolLUSDBalanceUpdated(newTotalLUSDDeposits);
    }

    function _sendETHGainToDepositor(uint _amount) internal {

        if (_amount == 0) {return;}
        uint newETH = ETH.sub(_amount);
        ETH = newETH;
        emit StabilityPoolETHBalanceUpdated(newETH);
        emit EtherSent(msg.sender, _amount);

        (bool success, ) = msg.sender.call{ value: _amount }("");
        require(success, "StabilityPool: sending ETH failed");
    }

    function _sendLUSDToDepositor(address _depositor, uint LUSDWithdrawal) internal {

        if (LUSDWithdrawal == 0) {return;}

        lusdToken.returnFromPool(address(this), _depositor, LUSDWithdrawal);
        _decreaseLUSD(LUSDWithdrawal);
    }


    function registerFrontEnd(uint _kickbackRate) external override {

        _requireFrontEndNotRegistered(msg.sender);
        _requireUserHasNoDeposit(msg.sender);
        _requireValidKickbackRate(_kickbackRate);

        frontEnds[msg.sender].kickbackRate = _kickbackRate;
        frontEnds[msg.sender].registered = true;

        emit FrontEndRegistered(msg.sender, _kickbackRate);
    }


    function _setFrontEndTag(address _depositor, address _frontEndTag) internal {

        deposits[_depositor].frontEndTag = _frontEndTag;
        emit FrontEndTagSet(_depositor, _frontEndTag);
    }


    function _updateDepositAndSnapshots(address _depositor, uint _newValue) internal {

        deposits[_depositor].initialValue = _newValue;

        if (_newValue == 0) {
            delete deposits[_depositor].frontEndTag;
            delete depositSnapshots[_depositor];
            emit DepositSnapshotUpdated(_depositor, 0, 0, 0);
            return;
        }
        uint128 currentScaleCached = currentScale;
        uint128 currentEpochCached = currentEpoch;
        uint currentP = P;

        uint currentS = epochToScaleToSum[currentEpochCached][currentScaleCached];
        uint currentG = epochToScaleToG[currentEpochCached][currentScaleCached];

        depositSnapshots[_depositor].P = currentP;
        depositSnapshots[_depositor].S = currentS;
        depositSnapshots[_depositor].G = currentG;
        depositSnapshots[_depositor].scale = currentScaleCached;
        depositSnapshots[_depositor].epoch = currentEpochCached;

        emit DepositSnapshotUpdated(_depositor, currentP, currentS, currentG);
    }

    function _updateFrontEndStakeAndSnapshots(address _frontEnd, uint _newValue) internal {

        frontEndStakes[_frontEnd] = _newValue;

        if (_newValue == 0) {
            delete frontEndSnapshots[_frontEnd];
            emit FrontEndSnapshotUpdated(_frontEnd, 0, 0);
            return;
        }

        uint128 currentScaleCached = currentScale;
        uint128 currentEpochCached = currentEpoch;
        uint currentP = P;

        uint currentG = epochToScaleToG[currentEpochCached][currentScaleCached];

        frontEndSnapshots[_frontEnd].P = currentP;
        frontEndSnapshots[_frontEnd].G = currentG;
        frontEndSnapshots[_frontEnd].scale = currentScaleCached;
        frontEndSnapshots[_frontEnd].epoch = currentEpochCached;

        emit FrontEndSnapshotUpdated(_frontEnd, currentP, currentG);
    }

    function _payOutLQTYGains(ICommunityIssuance _communityIssuance, address _depositor, address _frontEnd) internal {

        if (_frontEnd != address(0)) {
            uint frontEndLQTYGain = getFrontEndLQTYGain(_frontEnd);
            _communityIssuance.sendLQTY(_frontEnd, frontEndLQTYGain);
            emit LQTYPaidToFrontEnd(_frontEnd, frontEndLQTYGain);
        }

        uint depositorLQTYGain = getDepositorLQTYGain(_depositor);
        _communityIssuance.sendLQTY(_depositor, depositorLQTYGain);
        emit LQTYPaidToDepositor(_depositor, depositorLQTYGain);
    }


    function _requireCallerIsActivePool() internal view {

        require( msg.sender == address(activePool), "StabilityPool: Caller is not ActivePool");
    }

    function _requireCallerIsTroveManager() internal view {

        require(msg.sender == address(troveManager), "StabilityPool: Caller is not TroveManager");
    }

    function _requireNoUnderCollateralizedTroves() internal {

        uint price = priceFeed.fetchPrice();
        address lowestTrove = sortedTroves.getLast();
        uint ICR = troveManager.getCurrentICR(lowestTrove, price);
        require(ICR >= MCR, "StabilityPool: Cannot withdraw while there are troves with ICR < MCR");
    }

    function _requireUserHasDeposit(uint _initialDeposit) internal pure {

        require(_initialDeposit > 0, 'StabilityPool: User must have a non-zero deposit');
    }

     function _requireUserHasNoDeposit(address _address) internal view {

        uint initialDeposit = deposits[_address].initialValue;
        require(initialDeposit == 0, 'StabilityPool: User must have no deposit');
    }

    function _requireNonZeroAmount(uint _amount) internal pure {

        require(_amount > 0, 'StabilityPool: Amount must be non-zero');
    }

    function _requireUserHasTrove(address _depositor) internal view {

        require(troveManager.getTroveStatus(_depositor) == 1, "StabilityPool: caller must have an active trove to withdraw ETHGain to");
    }

    function _requireUserHasETHGain(address _depositor) internal view {

        uint ETHGain = getDepositorETHGain(_depositor);
        require(ETHGain > 0, "StabilityPool: caller must have non-zero ETH Gain");
    }

    function _requireFrontEndNotRegistered(address _address) internal view {

        require(!frontEnds[_address].registered, "StabilityPool: must not already be a registered front end");
    }

     function _requireFrontEndIsRegisteredOrZero(address _address) internal view {

        require(frontEnds[_address].registered || _address == address(0),
            "StabilityPool: Tag must be a registered front end, or the zero address");
    }

    function  _requireValidKickbackRate(uint _kickbackRate) internal pure {
        require (_kickbackRate <= DECIMAL_PRECISION, "StabilityPool: Kickback rate must be in range [0,1]");
    }


    receive() external payable {
        _requireCallerIsActivePool();
        ETH = ETH.add(msg.value);
        StabilityPoolETHBalanceUpdated(ETH);
    }
}





pragma solidity 0.6.11;

interface VatLike {

    function urns(bytes32, address) external view returns (uint256, uint256);

    function gem(bytes32, address) external view returns (uint256);

    function slip(bytes32, address, int256) external;

}

interface ERC20 {

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(address src, address dst, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function decimals() external returns (uint8);

}

contract CropJoin {


    VatLike     public immutable vat;    // cdp engine
    bytes32     public immutable ilk;    // collateral type
    ERC20       public immutable gem;    // collateral token
    uint256     public immutable dec;    // gem decimals
    ERC20       public immutable bonus;  // rewards token

    uint256     public share;  // crops per gem    [ray]
    uint256     public total;  // total gems       [wad]
    uint256     public stock;  // crop balance     [wad]

    mapping (address => uint256) public crops; // crops per user  [wad]
    mapping (address => uint256) public stake; // gems per user   [wad]

    uint256 immutable internal to18ConversionFactor;
    uint256 immutable internal toGemConversionFactor;

    event Join(uint256 val);
    event Exit(uint256 val);
    event Flee();
    event Tack(address indexed src, address indexed dst, uint256 wad);

    constructor(address vat_, bytes32 ilk_, address gem_, address bonus_) public {
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = ERC20(gem_);
        uint256 dec_ = ERC20(gem_).decimals();
        require(dec_ <= 18);
        dec = dec_;
        to18ConversionFactor = 10 ** (18 - dec_);
        toGemConversionFactor = 10 ** dec_;

        bonus = ERC20(bonus_);
    }

    function add(uint256 x, uint256 y) public pure returns (uint256 z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint256 x, uint256 y) public pure returns (uint256 z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint256 x, uint256 y) public pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
    function divup(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(x, sub(y, 1)) / y;
    }
    uint256 constant WAD  = 10 ** 18;
    function wmul(uint256 x, uint256 y) public pure returns (uint256 z) {

        z = mul(x, y) / WAD;
    }
    function wdiv(uint256 x, uint256 y) public pure returns (uint256 z) {

        z = mul(x, WAD) / y;
    }
    function wdivup(uint256 x, uint256 y) public pure returns (uint256 z) {

        z = divup(mul(x, WAD), y);
    }
    uint256 constant RAY  = 10 ** 27;
    function rmul(uint256 x, uint256 y) public pure returns (uint256 z) {

        z = mul(x, y) / RAY;
    }
    function rmulup(uint256 x, uint256 y) public pure returns (uint256 z) {

        z = divup(mul(x, y), RAY);
    }
    function rdiv(uint256 x, uint256 y) public pure returns (uint256 z) {

        z = mul(x, RAY) / y;
    }

    function nav() public virtual returns (uint256) {

        uint256 _nav = gem.balanceOf(address(this));
        return mul(_nav, to18ConversionFactor);
    }

    function nps() public returns (uint256) {

        if (total == 0) return WAD;
        else return wdiv(nav(), total);
    }

    function crop() internal virtual returns (uint256) {

        return sub(bonus.balanceOf(address(this)), stock);
    }

    function harvest(address from, address to) internal {

        if (total > 0) share = add(share, rdiv(crop(), total));

        uint256 last = crops[from];
        uint256 curr = rmul(stake[from], share);
        if (curr > last) require(bonus.transfer(to, curr - last));
        stock = bonus.balanceOf(address(this));
    }

    function join(address urn, uint256 val) internal virtual {

        harvest(urn, urn);
        if (val > 0) {
            uint256 wad = wdiv(mul(val, to18ConversionFactor), nps());

            require(int256(wad) > 0);

            require(gem.transferFrom(msg.sender, address(this), val));
            vat.slip(ilk, urn, int256(wad));

            total = add(total, wad);
            stake[urn] = add(stake[urn], wad);
        }
        crops[urn] = rmulup(stake[urn], share);
        emit Join(val);
    }

    function exit(address guy, uint256 val) internal virtual {

        harvest(msg.sender, guy);
        if (val > 0) {
            uint256 wad = wdivup(mul(val, to18ConversionFactor), nps());

            require(int256(wad) > 0);

            require(gem.transfer(guy, val));
            vat.slip(ilk, msg.sender, -int256(wad));

            total = sub(total, wad);
            stake[msg.sender] = sub(stake[msg.sender], wad);
        }
        crops[msg.sender] = rmulup(stake[msg.sender], share);
        emit Exit(val);
    }
}





pragma solidity 0.6.11;


contract CropJoinAdapter is CropJoin {

    string constant public name = "B.AMM LUSD-ETH";
    string constant public symbol = "LUSDETH";
    uint constant public decimals = 18;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor(address _lqty) public 
        CropJoin(address(new Dummy()), "B.AMM", address(new DummyGem()), _lqty)
    {
    }

    function nav() public override returns (uint256) {

        return total;
    }
    
    function totalSupply() public view returns (uint256) {

        return total;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {

        balance = stake[owner];
    }

    function mint(address to, uint value) virtual internal {

        join(to, value);
        emit Transfer(address(0), to, value);
    }

    function burn(address owner, uint value) virtual internal {

        exit(owner, value);
        emit Transfer(owner, address(0), value);        
    }
}

contract Dummy {

    fallback() external {}
}

contract DummyGem is Dummy {

    function transfer(address, uint) external pure returns(bool) {

        return true;
    }

    function transferFrom(address, address, uint) external pure returns(bool) {

        return true;
    }

    function decimals() external pure returns(uint) {

        return 18;
    } 
}





pragma solidity 0.6.11;

contract PriceFormula {

    using SafeMath for uint256;

    function getSumFixedPoint(uint x, uint y, uint A) public pure returns(uint) {

        if(x == 0 && y == 0) return 0;

        uint sum = x.add(y);

        for(uint i = 0 ; i < 255 ; i++) {
            uint dP = sum;
            dP = dP.mul(sum) / (x.mul(2)).add(1);
            dP = dP.mul(sum) / (y.mul(2)).add(1);

            uint prevSum = sum;

            uint n = (A.mul(2).mul(x.add(y)).add(dP.mul(2))).mul(sum);
            uint d = (A.mul(2).sub(1).mul(sum));
            sum = n / d.add(dP.mul(3));

            if(sum <= prevSum.add(1) && prevSum <= sum.add(1)) break;
        }

        return sum;
    }

    function getReturn(uint xQty, uint xBalance, uint yBalance, uint A) public pure returns(uint) {

        uint sum = getSumFixedPoint(xBalance, yBalance, A);

        uint c = sum.mul(sum) / (xQty.add(xBalance)).mul(2);
        c = c.mul(sum) / A.mul(4);
        uint b = (xQty.add(xBalance)).add(sum / A.mul(2));
        uint yPrev = 0;
        uint y = sum;

        for(uint i = 0 ; i < 255 ; i++) {
            yPrev = y;
            uint n = (y.mul(y)).add(c);
            uint d = y.mul(2).add(b).sub(sum); 
            y = n / d;

            if(y <= yPrev.add(1) && yPrev <= y.add(1)) break;
        }

        return yBalance.sub(y).sub(1);
    }
}





pragma solidity 0.6.11;

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}





pragma solidity 0.6.11;








contract BAMM is CropJoinAdapter, PriceFormula, Ownable {

    using SafeMath for uint256;

    AggregatorV3Interface public immutable priceAggregator;
    AggregatorV3Interface public immutable lusd2UsdPriceAggregator;    
    IERC20 public immutable LUSD;
    StabilityPool immutable public SP;

    address payable public immutable feePool;
    uint public constant MAX_FEE = 100; // 1%
    uint public fee = 0; // fee in bps
    uint public A = 20;
    uint public constant MIN_A = 20;
    uint public constant MAX_A = 200;    

    uint public immutable maxDiscount; // max discount in bips

    address public immutable frontEndTag;

    uint constant public PRECISION = 1e18;

    event ParamsSet(uint A, uint fee);
    event UserDeposit(address indexed user, uint lusdAmount, uint numShares);
    event UserWithdraw(address indexed user, uint lusdAmount, uint ethAmount, uint numShares);
    event RebalanceSwap(address indexed user, uint lusdAmount, uint ethAmount, uint timestamp);

    constructor(
        address _priceAggregator,
        address _lusd2UsdPriceAggregator,
        address payable _SP,
        address _LUSD,
        address _LQTY,
        uint _maxDiscount,
        address payable _feePool,
        address _fronEndTag)
        public
        CropJoinAdapter(_LQTY)
    {
        priceAggregator = AggregatorV3Interface(_priceAggregator);
        lusd2UsdPriceAggregator = AggregatorV3Interface(_lusd2UsdPriceAggregator);
        LUSD = IERC20(_LUSD);
        SP = StabilityPool(_SP);

        feePool = _feePool;
        maxDiscount = _maxDiscount;
        frontEndTag = _fronEndTag;
    }

    function setParams(uint _A, uint _fee) external onlyOwner {

        require(_fee <= MAX_FEE, "setParams: fee is too big");
        require(_A >= MIN_A, "setParams: A too small");
        require(_A <= MAX_A, "setParams: A too big");

        fee = _fee;
        A = _A;

        emit ParamsSet(_A, _fee);
    }

    function fetchPrice() public view returns(uint) {

        uint chainlinkDecimals;
        uint chainlinkLatestAnswer;
        uint chainlinkTimestamp;

        try priceAggregator.decimals() returns (uint8 decimals) {
            chainlinkDecimals = decimals;
        } catch {
            return 0;
        }

        try priceAggregator.latestRoundData() returns
        (
            uint80 /* roundId */,
            int256 answer,
            uint256 /* startedAt */,
            uint256 timestamp,
            uint80 /* answeredInRound */
        )
        {
            chainlinkLatestAnswer = uint(answer);
            chainlinkTimestamp = timestamp;
        } catch {
            return 0;
        }

        if(chainlinkTimestamp + 1 hours < now) return 0; // price is down

        uint chainlinkFactor = 10 ** chainlinkDecimals;
        return chainlinkLatestAnswer.mul(PRECISION) / chainlinkFactor;
    }

    function deposit(uint lusdAmount) external {        

        uint lusdValue = SP.getCompoundedLUSDDeposit(address(this));
        uint ethValue = SP.getDepositorETHGain(address(this)).add(address(this).balance);

        uint price = fetchPrice();
        require(ethValue == 0 || price > 0, "deposit: chainlink is down");

        uint totalValue = lusdValue.add(ethValue.mul(price) / PRECISION);

        require(totalValue > 0 || total == 0, "deposit: system is rekt");

        uint newShare = PRECISION;
        if(total > 0) newShare = total.mul(lusdAmount) / totalValue;

        require(LUSD.transferFrom(msg.sender, address(this), lusdAmount), "deposit: transferFrom failed");
        SP.provideToSP(lusdAmount, frontEndTag);

        mint(msg.sender, newShare);

        emit UserDeposit(msg.sender, lusdAmount, newShare);        
    }

    function withdraw(uint numShares) external {

        uint lusdValue = SP.getCompoundedLUSDDeposit(address(this));
        uint ethValue = SP.getDepositorETHGain(address(this)).add(address(this).balance);

        uint lusdAmount = lusdValue.mul(numShares).div(total);
        uint ethAmount = ethValue.mul(numShares).div(total);

        SP.withdrawFromSP(lusdAmount);

        burn(msg.sender, numShares);

        if(lusdAmount > 0) LUSD.transfer(msg.sender, lusdAmount);
        if(ethAmount > 0) {
            (bool success, ) = msg.sender.call{ value: ethAmount }(""); // re-entry is fine here
            require(success, "withdraw: sending ETH failed");
        }

        emit UserWithdraw(msg.sender, lusdAmount, ethAmount, numShares);            
    }

    function addBps(uint n, int bps) internal pure returns(uint) {

        require(bps <= 10000, "reduceBps: bps exceeds max");
        require(bps >= -10000, "reduceBps: bps exceeds min");

        return n.mul(uint(10000 + bps)) / 10000;
    }

    function compensateForLusdDeviation(uint ethAmount) public view returns(uint newEthAmount) {

        uint chainlinkDecimals;
        uint chainlinkLatestAnswer;

        chainlinkDecimals = lusd2UsdPriceAggregator.decimals();

        (,int256 answer,,,) = lusd2UsdPriceAggregator.latestRoundData();
        chainlinkLatestAnswer = uint(answer);

        if(chainlinkLatestAnswer > 10 ** chainlinkDecimals ) {
            newEthAmount = ethAmount.mul(chainlinkLatestAnswer) / (10 ** chainlinkDecimals);
        }
        else newEthAmount = ethAmount;
    }

    function getSwapEthAmount(uint lusdQty) public view returns(uint ethAmount, uint feeLusdAmount) {

        uint lusdBalance = SP.getCompoundedLUSDDeposit(address(this));
        uint ethBalance  = SP.getDepositorETHGain(address(this)).add(address(this).balance);

        uint eth2usdPrice = fetchPrice();
        if(eth2usdPrice == 0) return (0, 0); // chainlink is down

        uint ethUsdValue = ethBalance.mul(eth2usdPrice) / PRECISION;
        uint maxReturn = addBps(lusdQty.mul(PRECISION) / eth2usdPrice, int(maxDiscount));

        uint xQty = lusdQty;
        uint xBalance = lusdBalance;
        uint yBalance = lusdBalance.add(ethUsdValue.mul(2));
        
        uint usdReturn = getReturn(xQty, xBalance, yBalance, A);
        uint basicEthReturn = usdReturn.mul(PRECISION) / eth2usdPrice;

        basicEthReturn = compensateForLusdDeviation(basicEthReturn);

        if(ethBalance < basicEthReturn) basicEthReturn = ethBalance; // cannot give more than balance 
        if(maxReturn < basicEthReturn) basicEthReturn = maxReturn;

        ethAmount = basicEthReturn;
        feeLusdAmount = addBps(lusdQty, int(fee)).sub(lusdQty);
    }

    function swap(uint lusdAmount, uint minEthReturn, address payable dest) public returns(uint) {

        (uint ethAmount, uint feeAmount) = getSwapEthAmount(lusdAmount);

        require(ethAmount >= minEthReturn, "swap: low return");

        LUSD.transferFrom(msg.sender, address(this), lusdAmount);
        SP.provideToSP(lusdAmount.sub(feeAmount), frontEndTag);

        if(feeAmount > 0) LUSD.transfer(feePool, feeAmount);
        (bool success, ) = dest.call{ value: ethAmount }(""); // re-entry is fine here
        require(success, "swap: sending ETH failed");

        emit RebalanceSwap(msg.sender, lusdAmount, ethAmount, now);

        return ethAmount;
    }

    function trade(
        IERC20 /* srcToken */,
        uint256 srcAmount,
        IERC20 /* destToken */,
        address payable destAddress,
        uint256 /* conversionRate */,
        bool /* validate */
    ) external payable returns (bool) {

        return swap(srcAmount, 0, destAddress) > 0;
    }

    function getConversionRate(
        IERC20 /* src */,
        IERC20 /* dest */,
        uint256 srcQty,
        uint256 /* blockNumber */
    ) external view returns (uint256) {

        (uint ethQty, ) = getSwapEthAmount(srcQty);
        return ethQty.mul(PRECISION) / srcQty;
    }

    receive() external payable {}
}