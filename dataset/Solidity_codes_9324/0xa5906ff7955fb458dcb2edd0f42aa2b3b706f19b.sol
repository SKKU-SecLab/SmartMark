

pragma solidity 0.5.7;

interface IERC20 {

    function balanceOf(
        address _owner
    )
        external
        view
        returns (uint256);


    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256);


    function transfer(
        address _to,
        uint256 _quantity
    )
        external;


    function transferFrom(
        address _from,
        address _to,
        uint256 _quantity
    )
        external;


    function approve(
        address _spender,
        uint256 _quantity
    )
        external
        returns (bool);


    function totalSupply()
        external
        returns (uint256);

}



pragma solidity 0.5.7;



contract ERC20Viewer {


    function batchFetchBalancesOf(
        address[] calldata _tokenAddresses,
        address _owner
    )
        external
        returns (uint256[] memory)
    {

        uint256 _addressesCount = _tokenAddresses.length;

        uint256[] memory balances = new uint256[](_addressesCount);

        for (uint256 i = 0; i < _addressesCount; i++) {
            balances[i] = IERC20(_tokenAddresses[i]).balanceOf(_owner);
        }

        return balances;
    }

    function batchFetchUsersBalances(
        address[] calldata _tokenAddresses,
        address[] calldata _tokenOwners
    )
        external
        returns (uint256[] memory)
    {

        uint256 _addressesCount = _tokenAddresses.length;

        uint256[] memory balances = new uint256[](_addressesCount);

        for (uint256 i = 0; i < _addressesCount; i++) {
            balances[i] = IERC20(_tokenAddresses[i]).balanceOf(_tokenOwners[i]);
        }

        return balances;
    }

    function batchFetchSupplies(
        address[] calldata _tokenAddresses
    )
        external
        returns (uint256[] memory)
    {

        uint256 _addressesCount = _tokenAddresses.length;

        uint256[] memory supplies = new uint256[](_addressesCount);

        for (uint256 i = 0; i < _addressesCount; i++) {
            supplies[i] = IERC20(_tokenAddresses[i]).totalSupply();
        }

        return supplies;
    }
}



pragma solidity 0.5.7;


interface IAssetPairManager {

    function signalConfirmationMinTime() external view returns (uint256);

    function signalConfirmationMaxTime() external view returns (uint256);

    function recentInitialProposeTimestamp() external view returns (uint256);

}



pragma solidity 0.5.7;


interface IMACOStrategyManagerV2 {

    function crossoverConfirmationMinTime() external view returns (uint256);

    function crossoverConfirmationMaxTime() external view returns (uint256);

    function lastCrossoverConfirmationTimestamp() external view returns (uint256);

}



pragma solidity 0.5.7;





contract ManagerViewer {


    function batchFetchMACOV2CrossoverTimestamp(
        IMACOStrategyManagerV2[] calldata _managers
    )
        external
        view
        returns (uint256[] memory)
    {

        uint256 _managerCount = _managers.length;

        uint256[] memory timestamps = new uint256[](_managerCount);

        for (uint256 i = 0; i < _managerCount; i++) {
            IMACOStrategyManagerV2 manager = _managers[i];

            timestamps[i] = manager.lastCrossoverConfirmationTimestamp();
        }

        return timestamps;
    }

    function batchFetchAssetPairCrossoverTimestamp(
        IAssetPairManager[] calldata _managers
    )
        external
        view
        returns (uint256[] memory)
    {

        uint256 _managerCount = _managers.length;

        uint256[] memory timestamps = new uint256[](_managerCount);

        for (uint256 i = 0; i < _managerCount; i++) {
            IAssetPairManager manager = _managers[i];

            timestamps[i] = manager.recentInitialProposeTimestamp();
        }

        return timestamps;
    }

}



pragma solidity 0.5.7;


interface IOracle {


    function read()
        external
        view
        returns (uint256);

}



pragma solidity 0.5.7;




contract OracleViewer {

    function batchFetchOraclePrices(
        IOracle[] calldata _oracles
    )
        external
        returns (uint256[] memory)
    {

        uint256 _addressesCount = _oracles.length;

        uint256[] memory prices = new uint256[](_addressesCount);

        for (uint256 i = 0; i < _addressesCount; i++) {
            prices[i] = _oracles[i].read();
        }

        return prices;
    }
}


pragma solidity ^0.5.2;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}



pragma solidity 0.5.7;

interface ISetToken {



    function naturalUnit()
        external
        view
        returns (uint256);


    function getComponents()
        external
        view
        returns (address[] memory);


    function getUnits()
        external
        view
        returns (uint256[] memory);


    function tokenIsComponent(
        address _tokenAddress
    )
        external
        view
        returns (bool);


    function mint(
        address _issuer,
        uint256 _quantity
    )
        external;


    function burn(
        address _from,
        uint256 _quantity
    )
        external;


    function transfer(
        address to,
        uint256 value
    )
        external;

}



pragma solidity 0.5.7;


library RebalancingLibrary {



    enum State { Default, Proposal, Rebalance, Drawdown }


    struct AuctionPriceParameters {
        uint256 auctionStartTime;
        uint256 auctionTimeToPivot;
        uint256 auctionStartPrice;
        uint256 auctionPivotPrice;
    }

    struct BiddingParameters {
        uint256 minimumBid;
        uint256 remainingCurrentSets;
        uint256[] combinedCurrentUnits;
        uint256[] combinedNextSetUnits;
        address[] combinedTokenArray;
    }
}



pragma solidity 0.5.7;




interface IRebalancingSetToken {


    function auctionLibrary()
        external
        view
        returns (address);


    function totalSupply()
        external
        view
        returns (uint256);


    function proposalStartTime()
        external
        view
        returns (uint256);


    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);


    function rebalanceInterval()
        external
        view
        returns (uint256);


    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);


    function startingCurrentSetAmount()
        external
        view
        returns (uint256);


    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);


    function propose(
        address _nextSet,
        address _auctionLibrary,
        uint256 _auctionTimeToPivot,
        uint256 _auctionStartPrice,
        uint256 _auctionPivotPrice
    )
        external;


    function naturalUnit()
        external
        view
        returns (uint256);


    function currentSet()
        external
        view
        returns (address);


    function nextSet()
        external
        view
        returns (address);


    function unitShares()
        external
        view
        returns (uint256);


    function burn(
        address _from,
        uint256 _quantity
    )
        external;


    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);


    function getCombinedTokenArrayLength()
        external
        view
        returns (uint256);


    function getCombinedTokenArray()
        external
        view
        returns (address[] memory);


    function getFailedAuctionWithdrawComponents()
        external
        view
        returns (address[] memory);


    function getAuctionPriceParameters()
        external
        view
        returns (uint256[] memory);


    function getBiddingParameters()
        external
        view
        returns (uint256[] memory);


    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);


}



pragma solidity 0.5.7;



library Rebalance {


    struct TokenFlow {
        address[] addresses;
        uint256[] inflow;
        uint256[] outflow;
    }

    function composeTokenFlow(
        address[] memory _addresses,
        uint256[] memory _inflow,
        uint256[] memory _outflow
    )
        internal
        pure
        returns(TokenFlow memory)
    {

        return TokenFlow({addresses: _addresses, inflow: _inflow, outflow: _outflow });
    }

    function decomposeTokenFlow(TokenFlow memory _tokenFlow)
        internal
        pure
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {

        return (_tokenFlow.addresses, _tokenFlow.inflow, _tokenFlow.outflow);
    }

    function decomposeTokenFlowToBidPrice(TokenFlow memory _tokenFlow)
        internal
        pure
        returns (uint256[] memory, uint256[] memory)
    {

        return (_tokenFlow.inflow, _tokenFlow.outflow);
    }

    function getTokenFlows(
        IRebalancingSetToken _rebalancingSetToken,
        uint256 _quantity
    )
        internal
        view
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {

        address[] memory combinedTokenArray = _rebalancingSetToken.getCombinedTokenArray();

        (
            uint256[] memory inflowArray,
            uint256[] memory outflowArray
        ) = _rebalancingSetToken.getBidPrice(_quantity);

        return (combinedTokenArray, inflowArray, outflowArray);
    }
}



pragma solidity 0.5.7;





interface ILiquidator {



    function startRebalance(
        ISetToken _currentSet,
        ISetToken _nextSet,
        uint256 _startingCurrentSetQuantity,
        bytes calldata _liquidatorData
    )
        external;


    function getBidPrice(
        address _set,
        uint256 _quantity
    )
        external
        view
        returns (Rebalance.TokenFlow memory);


    function placeBid(
        uint256 _quantity
    )
        external
        returns (Rebalance.TokenFlow memory);



    function settleRebalance()
        external;


    function endFailedRebalance() external;



    function auctionPriceParameters(address _set)
        external
        view
        returns (RebalancingLibrary.AuctionPriceParameters memory);



    function hasRebalanceFailed(address _set) external view returns (bool);

    function minimumBid(address _set) external view returns (uint256);

    function startingCurrentSets(address _set) external view returns (uint256);

    function remainingCurrentSets(address _set) external view returns (uint256);

    function getCombinedCurrentSetUnits(address _set) external view returns (uint256[] memory);

    function getCombinedNextSetUnits(address _set) external view returns (uint256[] memory);

    function getCombinedTokenArray(address _set) external view returns (address[] memory);

}



pragma solidity 0.5.7;


library PerformanceFeeLibrary {



    struct FeeState {
        uint256 profitFeePeriod;                // Time required between accruing profit fees
        uint256 highWatermarkResetPeriod;       // Time required after last profit fee to reset high watermark
        uint256 profitFeePercentage;            // Percent of profits that accrue to manager
        uint256 streamingFeePercentage;         // Percent of Set that accrues to manager each year
        uint256 highWatermark;                  // Value of Set at last profit fee accrual
        uint256 lastProfitFeeTimestamp;         // Timestamp last profit fee was accrued
        uint256 lastStreamingFeeTimestamp;      // Timestamp last streaming fee was accrued
    }
}



pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;


interface IPerformanceFeeCalculator {



    function feeState(
        address _rebalancingSetToken
    )
        external
        view
        returns (PerformanceFeeLibrary.FeeState memory);


    function getCalculatedFees(
        address _setAddress
    )
        external
        view
        returns (uint256, uint256);

}



pragma solidity 0.5.7;

interface IFeeCalculator {



    function initialize(
        bytes calldata _feeCalculatorData
    )
        external;


    function getFee()
        external
        view
        returns(uint256);


    function updateAndGetFee()
        external
        returns(uint256);


    function adjustFee(
        bytes calldata _newFeeData
    )
        external;

}



pragma solidity 0.5.7;







interface IRebalancingSetTokenV2 {


    function totalSupply()
        external
        view
        returns (uint256);


    function liquidator()
        external
        view
        returns (ILiquidator);


    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);


    function rebalanceStartTime()
        external
        view
        returns (uint256);


    function startingCurrentSetAmount()
        external
        view
        returns (uint256);


    function rebalanceInterval()
        external
        view
        returns (uint256);


    function getAuctionPriceParameters() external view returns (uint256[] memory);


    function getBiddingParameters() external view returns (uint256[] memory);


    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);


    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);


    function manager()
        external
        view
        returns (address);


    function feeRecipient()
        external
        view
        returns (address);


    function entryFee()
        external
        view
        returns (uint256);


    function rebalanceFee()
        external
        view
        returns (uint256);


    function rebalanceFeeCalculator()
        external
        view
        returns (IFeeCalculator);


    function initialize(
        bytes calldata _rebalanceFeeCalldata
    )
        external;


    function setLiquidator(
        ILiquidator _newLiquidator
    )
        external;


    function setFeeRecipient(
        address _newFeeRecipient
    )
        external;


    function setEntryFee(
        uint256 _newEntryFee
    )
        external;


    function startRebalance(
        address _nextSet,
        bytes calldata _liquidatorData

    )
        external;


    function settleRebalance()
        external;


    function naturalUnit()
        external
        view
        returns (uint256);


    function currentSet()
        external
        view
        returns (ISetToken);


    function nextSet()
        external
        view
        returns (ISetToken);


    function unitShares()
        external
        view
        returns (uint256);


    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);


    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);


    function name()
        external
        view
        returns (string memory);


    function symbol()
        external
        view
        returns (string memory);

}



pragma solidity 0.5.7;







interface IRebalancingSetTokenV3 {


    function totalSupply()
        external
        view
        returns (uint256);


    function liquidator()
        external
        view
        returns (ILiquidator);


    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);


    function rebalanceStartTime()
        external
        view
        returns (uint256);


    function startingCurrentSetAmount()
        external
        view
        returns (uint256);


    function rebalanceInterval()
        external
        view
        returns (uint256);


    function rebalanceFailPeriod()
        external
        view
        returns (uint256);


    function getAuctionPriceParameters() external view returns (uint256[] memory);


    function getBiddingParameters() external view returns (uint256[] memory);


    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);


    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);


    function manager()
        external
        view
        returns (address);


    function feeRecipient()
        external
        view
        returns (address);


    function entryFee()
        external
        view
        returns (uint256);


    function rebalanceFee()
        external
        view
        returns (uint256);


    function rebalanceFeeCalculator()
        external
        view
        returns (IFeeCalculator);


    function initialize(
        bytes calldata _rebalanceFeeCalldata
    )
        external;


    function setLiquidator(
        ILiquidator _newLiquidator
    )
        external;


    function setFeeRecipient(
        address _newFeeRecipient
    )
        external;


    function setEntryFee(
        uint256 _newEntryFee
    )
        external;


    function startRebalance(
        address _nextSet,
        bytes calldata _liquidatorData

    )
        external;


    function settleRebalance()
        external;


    function actualizeFee()
        external;


    function adjustFee(
        bytes calldata _newFeeData
    )
        external;


    function naturalUnit()
        external
        view
        returns (uint256);


    function currentSet()
        external
        view
        returns (ISetToken);


    function nextSet()
        external
        view
        returns (ISetToken);


    function unitShares()
        external
        view
        returns (uint256);


    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);


    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);


    function name()
        external
        view
        returns (string memory);


    function symbol()
        external
        view
        returns (string memory);

}



pragma solidity 0.5.7;


interface ITWAPAuctionGetters {


    function getOrderSize(address _set) external view returns (uint256);


    function getOrderRemaining(address _set) external view returns (uint256);


    function getTotalSetsRemaining(address _set) external view returns (uint256);


    function getChunkSize(address _set) external view returns (uint256);


    function getChunkAuctionPeriod(address _set) external view returns (uint256);


    function getLastChunkAuctionEnd(address _set) external view returns (uint256);

}



pragma solidity 0.5.7;













contract RebalancingSetTokenViewer {


    struct CollateralAndState {
        address collateralSet;
        RebalancingLibrary.State state;
    }

    struct CollateralSetInfo {
        address[] components;
        uint256[] units;
        uint256 naturalUnit;
        string name;
        string symbol;
    }

    struct RebalancingSetRebalanceInfo {
        uint256 rebalanceStartTime;
        uint256 timeToPivot;
        uint256 startPrice;
        uint256 endPrice;
        uint256 startingCurrentSets;
        uint256 remainingCurrentSets;
        uint256 minimumBid;
        RebalancingLibrary.State rebalanceState;
        ISetToken nextSet;
        ILiquidator liquidator;
    }

    struct RebalancingSetCreateInfo {
        address manager;
        address feeRecipient;
        ISetToken currentSet;
        ILiquidator liquidator;
        uint256 unitShares;
        uint256 naturalUnit;
        uint256 rebalanceInterval;
        uint256 entryFee;
        uint256 rebalanceFee;
        uint256 lastRebalanceTimestamp;
        RebalancingLibrary.State rebalanceState;
        string name;
        string symbol;
    }

    struct TWAPRebalanceInfo {
        uint256 rebalanceStartTime;
        uint256 timeToPivot;
        uint256 startPrice;
        uint256 endPrice;
        uint256 startingCurrentSets;
        uint256 remainingCurrentSets;
        uint256 minimumBid;
        RebalancingLibrary.State rebalanceState;
        ISetToken nextSet;
        ILiquidator liquidator;
        uint256 orderSize;
        uint256 orderRemaining;
        uint256 totalSetsRemaining;
        uint256 chunkSize;
        uint256 chunkAuctionPeriod;
        uint256 lastChunkAuctionEnd;
    }


    function fetchRebalanceProposalStateAsync(
        IRebalancingSetToken _rebalancingSetToken
    )
        external
        returns (RebalancingLibrary.State, address[] memory, uint256[] memory)
    {

        RebalancingLibrary.State rebalanceState = _rebalancingSetToken.rebalanceState();

        address[] memory auctionAddressParams = new address[](2);
        auctionAddressParams[0] = _rebalancingSetToken.nextSet();
        auctionAddressParams[1] = _rebalancingSetToken.auctionLibrary();

        uint256[] memory auctionIntegerParams = new uint256[](4);
        auctionIntegerParams[0] = _rebalancingSetToken.proposalStartTime();

        uint256[] memory auctionParameters = _rebalancingSetToken.getAuctionPriceParameters();
        auctionIntegerParams[1] = auctionParameters[1]; // auctionTimeToPivot
        auctionIntegerParams[2] = auctionParameters[2]; // auctionStartPrice
        auctionIntegerParams[3] = auctionParameters[3]; // auctionPivotPrice

        return (rebalanceState, auctionAddressParams, auctionIntegerParams);
    }

    function fetchRebalanceAuctionStateAsync(
        IRebalancingSetToken _rebalancingSetToken
    )
        external
        returns (RebalancingLibrary.State, uint256[] memory)
    {

        RebalancingLibrary.State rebalanceState = _rebalancingSetToken.rebalanceState();

        uint256[] memory auctionIntegerParams = new uint256[](4);
        auctionIntegerParams[0] = _rebalancingSetToken.startingCurrentSetAmount();

        uint256[] memory auctionParameters = _rebalancingSetToken.getAuctionPriceParameters();
        auctionIntegerParams[1] = auctionParameters[0]; // auctionStartTime

        uint256[] memory biddingParameters = _rebalancingSetToken.getBiddingParameters();
        auctionIntegerParams[2] = biddingParameters[0]; // minimumBid
        auctionIntegerParams[3] = biddingParameters[1]; // remainingCurrentSets

        return (rebalanceState, auctionIntegerParams);
    }


    function fetchNewRebalancingSetDetails(
        IRebalancingSetTokenV3 _rebalancingSetToken
    )
        public
        view
        returns (
            RebalancingSetCreateInfo memory,
            PerformanceFeeLibrary.FeeState memory,
            CollateralSetInfo memory,
            address
        )
    {

        RebalancingSetCreateInfo memory rbSetInfo = getRebalancingSetInfo(
            address(_rebalancingSetToken)
        );

        PerformanceFeeLibrary.FeeState memory performanceFeeInfo = getPerformanceFeeState(
            address(_rebalancingSetToken)
        );

        CollateralSetInfo memory collateralSetInfo = getCollateralSetInfo(
            rbSetInfo.currentSet
        );

        address performanceFeeCalculatorAddress = address(_rebalancingSetToken.rebalanceFeeCalculator());

        return (rbSetInfo, performanceFeeInfo, collateralSetInfo, performanceFeeCalculatorAddress);
    }

    function fetchRBSetRebalanceDetails(
        IRebalancingSetTokenV2 _rebalancingSetToken
    )
        public
        view
        returns (RebalancingSetRebalanceInfo memory, CollateralSetInfo memory)
    {

        uint256[] memory auctionParams = _rebalancingSetToken.getAuctionPriceParameters();
        uint256[] memory biddingParams = _rebalancingSetToken.getBiddingParameters();

        RebalancingSetRebalanceInfo memory rbSetInfo = RebalancingSetRebalanceInfo({
            rebalanceStartTime: auctionParams[0],
            timeToPivot: auctionParams[1],
            startPrice: auctionParams[2],
            endPrice: auctionParams[3],
            startingCurrentSets: _rebalancingSetToken.startingCurrentSetAmount(),
            remainingCurrentSets: biddingParams[1],
            minimumBid: biddingParams[0],
            rebalanceState: _rebalancingSetToken.rebalanceState(),
            nextSet: _rebalancingSetToken.nextSet(),
            liquidator: _rebalancingSetToken.liquidator()
        });

        CollateralSetInfo memory collateralSetInfo = getCollateralSetInfo(_rebalancingSetToken.nextSet());

        return (rbSetInfo, collateralSetInfo);
    }

    function fetchRBSetTWAPRebalanceDetails(
        IRebalancingSetTokenV2 _rebalancingSetToken
    )
        public
        view
        returns (TWAPRebalanceInfo memory, CollateralSetInfo memory)
    {

        uint256[] memory auctionParams = _rebalancingSetToken.getAuctionPriceParameters();
        uint256[] memory biddingParams = _rebalancingSetToken.getBiddingParameters();
        ILiquidator liquidator = _rebalancingSetToken.liquidator();

        ITWAPAuctionGetters twapStateGetters = ITWAPAuctionGetters(address(liquidator));

        TWAPRebalanceInfo memory rbSetInfo = TWAPRebalanceInfo({
            rebalanceStartTime: auctionParams[0],
            timeToPivot: auctionParams[1],
            startPrice: auctionParams[2],
            endPrice: auctionParams[3],
            startingCurrentSets: _rebalancingSetToken.startingCurrentSetAmount(),
            remainingCurrentSets: biddingParams[1],
            minimumBid: biddingParams[0],
            rebalanceState: _rebalancingSetToken.rebalanceState(),
            nextSet: _rebalancingSetToken.nextSet(),
            liquidator: liquidator,
            orderSize: twapStateGetters.getOrderSize(address(_rebalancingSetToken)),
            orderRemaining: twapStateGetters.getOrderRemaining(address(_rebalancingSetToken)),
            totalSetsRemaining: twapStateGetters.getTotalSetsRemaining(address(_rebalancingSetToken)),
            chunkSize: twapStateGetters.getChunkSize(address(_rebalancingSetToken)),
            chunkAuctionPeriod: twapStateGetters.getChunkAuctionPeriod(address(_rebalancingSetToken)),
            lastChunkAuctionEnd: twapStateGetters.getLastChunkAuctionEnd(address(_rebalancingSetToken))
        });

        CollateralSetInfo memory collateralSetInfo = getCollateralSetInfo(_rebalancingSetToken.nextSet());

        return (rbSetInfo, collateralSetInfo);
    }


    function batchFetchRebalanceStateAsync(
        IRebalancingSetToken[] calldata _rebalancingSetTokens
    )
        external
        returns (RebalancingLibrary.State[] memory)
    {

        uint256 _addressesCount = _rebalancingSetTokens.length;

        RebalancingLibrary.State[] memory states = new RebalancingLibrary.State[](_addressesCount);

        for (uint256 i = 0; i < _addressesCount; i++) {
            states[i] = _rebalancingSetTokens[i].rebalanceState();
        }

        return states;
    }

    function batchFetchUnitSharesAsync(
        IRebalancingSetToken[] calldata _rebalancingSetTokens
    )
        external
        returns (uint256[] memory)
    {

        uint256 _addressesCount = _rebalancingSetTokens.length;

        uint256[] memory unitShares = new uint256[](_addressesCount);

        for (uint256 i = 0; i < _addressesCount; i++) {
            unitShares[i] = _rebalancingSetTokens[i].unitShares();
        }

        return unitShares;
    }

    function batchFetchLiquidator(
        IRebalancingSetTokenV2[] calldata _rebalancingSetTokens
    )
        external
        returns (address[] memory)
    {

        uint256 _addressesCount = _rebalancingSetTokens.length;

        address[] memory liquidators = new address[](_addressesCount);

        for (uint256 i = 0; i < _addressesCount; i++) {
            liquidators[i] = address(_rebalancingSetTokens[i].liquidator());
        }

        return liquidators;
    }

    function batchFetchStateAndCollateral(
        IRebalancingSetToken[] calldata _rebalancingSetTokens
    )
        external
        returns (CollateralAndState[] memory)
    {

        uint256 _addressesCount = _rebalancingSetTokens.length;

        CollateralAndState[] memory statuses = new CollateralAndState[](_addressesCount);

        for (uint256 i = 0; i < _addressesCount; i++) {
            statuses[i].collateralSet = address(_rebalancingSetTokens[i].currentSet());
            statuses[i].state = _rebalancingSetTokens[i].rebalanceState();
        }

        return statuses;
    }


    function getCollateralSetInfo(
        ISetToken _collateralSet
    )
        internal
        view
        returns (CollateralSetInfo memory)
    {

        return CollateralSetInfo({
            components: _collateralSet.getComponents(),
            units: _collateralSet.getUnits(),
            naturalUnit: _collateralSet.naturalUnit(),
            name: ERC20Detailed(address(_collateralSet)).name(),
            symbol: ERC20Detailed(address(_collateralSet)).symbol()
        });
    }

    function getRebalancingSetInfo(
        address _rebalancingSetToken
    )
        internal
        view
        returns (RebalancingSetCreateInfo memory)
    {

        IRebalancingSetTokenV2 rebalancingSetTokenV2Instance = IRebalancingSetTokenV2(_rebalancingSetToken);

        return RebalancingSetCreateInfo({
            manager: rebalancingSetTokenV2Instance.manager(),
            feeRecipient: rebalancingSetTokenV2Instance.feeRecipient(),
            currentSet: rebalancingSetTokenV2Instance.currentSet(),
            liquidator: rebalancingSetTokenV2Instance.liquidator(),
            unitShares: rebalancingSetTokenV2Instance.unitShares(),
            naturalUnit: rebalancingSetTokenV2Instance.naturalUnit(),
            rebalanceInterval: rebalancingSetTokenV2Instance.rebalanceInterval(),
            entryFee: rebalancingSetTokenV2Instance.entryFee(),
            rebalanceFee: rebalancingSetTokenV2Instance.rebalanceFee(),
            lastRebalanceTimestamp: rebalancingSetTokenV2Instance.lastRebalanceTimestamp(),
            rebalanceState: rebalancingSetTokenV2Instance.rebalanceState(),
            name: rebalancingSetTokenV2Instance.name(),
            symbol: rebalancingSetTokenV2Instance.symbol()
        });
    }

    function getPerformanceFeeState(
        address _rebalancingSetToken
    )
        internal
        view
        returns (PerformanceFeeLibrary.FeeState memory)
    {

        IRebalancingSetTokenV2 rebalancingSetTokenV3Instance = IRebalancingSetTokenV2(_rebalancingSetToken);

        address rebalanceFeeCalculatorAddress = address(rebalancingSetTokenV3Instance.rebalanceFeeCalculator());
        return IPerformanceFeeCalculator(rebalanceFeeCalculatorAddress).feeState(_rebalancingSetToken);
    }
}



pragma solidity 0.5.7;



interface ISocialAllocator {


    function determineNewAllocation(
        uint256 _targetBaseAssetAllocation
    )
        external
        returns (ISetToken);


    function calculateCollateralSetValue(
        ISetToken _collateralSet
    )
        external
        view
        returns(uint256);

}



pragma solidity 0.5.7;




library SocialTradingLibrary {


    struct PoolInfo {
        address trader;                 // Address allowed to make admin and allocation decisions
        ISocialAllocator allocator;     // Allocator used to make collateral Sets, defines asset pair being used
        uint256 currentAllocation;      // Current base asset allocation of tradingPool
        uint256 newEntryFee;            // New fee percentage to change to after time lock passes, defaults to 0
        uint256 feeUpdateTimestamp;     // Timestamp when fee update process can be finalized, defaults to maxUint256
    }
}



pragma solidity 0.5.7;






interface ISocialTradingManager {


    function pools(address _tradingPool) external view returns (SocialTradingLibrary.PoolInfo memory);


    function createTradingPool(
        ISocialAllocator _tradingPairAllocator,
        uint256 _startingBaseAssetAllocation,
        uint256 _startingUSDValue,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _rebalancingSetCallData
    )
        external;


    function updateAllocation(
        IRebalancingSetTokenV2 _tradingPool,
        uint256 _newAllocation,
        bytes calldata _liquidatorData
    )
        external;


    function setTrader(
        IRebalancingSetTokenV2 _tradingPool,
        address _newTrader
    )
        external;


    function setLiquidator(
        IRebalancingSetTokenV2 _tradingPool,
        ILiquidator _newLiquidator
    )
        external;


    function setFeeRecipient(
        IRebalancingSetTokenV2 _tradingPool,
        address _newFeeRecipient
    )
        external;

}



pragma solidity 0.5.7;










contract TradingPoolViewer is RebalancingSetTokenViewer {


    function fetchNewTradingPoolDetails(
        IRebalancingSetTokenV2 _tradingPool
    )
        external
        view
        returns (SocialTradingLibrary.PoolInfo memory, RebalancingSetCreateInfo memory, CollateralSetInfo memory)
    {

        RebalancingSetCreateInfo memory tradingPoolInfo = getRebalancingSetInfo(
            address(_tradingPool)
        );

        SocialTradingLibrary.PoolInfo memory poolInfo = ISocialTradingManager(tradingPoolInfo.manager).pools(
            address(_tradingPool)
        );

        CollateralSetInfo memory collateralSetInfo = getCollateralSetInfo(
            tradingPoolInfo.currentSet
        );

        return (poolInfo, tradingPoolInfo, collateralSetInfo);
    }

    function fetchNewTradingPoolV2Details(
        IRebalancingSetTokenV3 _tradingPool
    )
        external
        view
        returns (
            SocialTradingLibrary.PoolInfo memory,
            RebalancingSetCreateInfo memory,
            PerformanceFeeLibrary.FeeState memory,
            CollateralSetInfo memory,
            address
        )
    {

        (
            RebalancingSetCreateInfo memory tradingPoolInfo,
            PerformanceFeeLibrary.FeeState memory performanceFeeInfo,
            CollateralSetInfo memory collateralSetInfo,
            address performanceFeeCalculatorAddress
        ) = fetchNewRebalancingSetDetails(_tradingPool);

        SocialTradingLibrary.PoolInfo memory poolInfo = ISocialTradingManager(tradingPoolInfo.manager).pools(
            address(_tradingPool)
        );

        return (poolInfo, tradingPoolInfo, performanceFeeInfo, collateralSetInfo, performanceFeeCalculatorAddress);
    }

    function fetchTradingPoolRebalanceDetails(
        IRebalancingSetTokenV2 _tradingPool
    )
        external
        view
        returns (SocialTradingLibrary.PoolInfo memory, RebalancingSetRebalanceInfo memory, CollateralSetInfo memory)
    {

        (
            RebalancingSetRebalanceInfo memory tradingPoolInfo,
            CollateralSetInfo memory collateralSetInfo
        ) = fetchRBSetRebalanceDetails(_tradingPool);

        address manager = _tradingPool.manager();

        SocialTradingLibrary.PoolInfo memory poolInfo = ISocialTradingManager(manager).pools(
            address(_tradingPool)
        );

        return (poolInfo, tradingPoolInfo, collateralSetInfo);
    }

    function fetchTradingPoolTWAPRebalanceDetails(
        IRebalancingSetTokenV2 _tradingPool
    )
        external
        view
        returns (SocialTradingLibrary.PoolInfo memory, TWAPRebalanceInfo memory, CollateralSetInfo memory)
    {

        (
            TWAPRebalanceInfo memory tradingPoolInfo,
            CollateralSetInfo memory collateralSetInfo
        ) = fetchRBSetTWAPRebalanceDetails(_tradingPool);

        address manager = _tradingPool.manager();

        SocialTradingLibrary.PoolInfo memory poolInfo = ISocialTradingManager(manager).pools(
            address(_tradingPool)
        );

        return (poolInfo, tradingPoolInfo, collateralSetInfo);
    }

    function batchFetchTradingPoolOperator(
        IRebalancingSetTokenV2[] calldata _tradingPools
    )
        external
        view
        returns (address[] memory)
    {

        uint256 _poolCount = _tradingPools.length;

        address[] memory operators = new address[](_poolCount);

        for (uint256 i = 0; i < _poolCount; i++) {
            IRebalancingSetTokenV2 tradingPool = _tradingPools[i];

            operators[i] = ISocialTradingManager(tradingPool.manager()).pools(
                address(tradingPool)
            ).trader;
        }

        return operators;
    }

    function batchFetchTradingPoolEntryFees(
        IRebalancingSetTokenV2[] calldata _tradingPools
    )
        external
        view
        returns (uint256[] memory)
    {

        uint256 _poolCount = _tradingPools.length;

        uint256[] memory entryFees = new uint256[](_poolCount);

        for (uint256 i = 0; i < _poolCount; i++) {
            entryFees[i] = _tradingPools[i].entryFee();
        }

        return entryFees;
    }

    function batchFetchTradingPoolRebalanceFees(
        IRebalancingSetTokenV2[] calldata _tradingPools
    )
        external
        view
        returns (uint256[] memory)
    {

        uint256 _poolCount = _tradingPools.length;

        uint256[] memory rebalanceFees = new uint256[](_poolCount);

        for (uint256 i = 0; i < _poolCount; i++) {
            rebalanceFees[i] = _tradingPools[i].rebalanceFee();
        }

        return rebalanceFees;
    }

    function batchFetchTradingPoolAccumulation(
        IRebalancingSetTokenV3[] calldata _tradingPools
    )
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {

        uint256 _poolCount = _tradingPools.length;

        uint256[] memory streamingFees = new uint256[](_poolCount);

        uint256[] memory profitFees = new uint256[](_poolCount);

        for (uint256 i = 0; i < _poolCount; i++) {
            address rebalanceFeeCalculatorAddress = address(_tradingPools[i].rebalanceFeeCalculator());

            (
                streamingFees[i],
                profitFees[i]
            ) = IPerformanceFeeCalculator(rebalanceFeeCalculatorAddress).getCalculatedFees(
                address(_tradingPools[i])
            );
        }

        return (streamingFees, profitFees);
    }


    function batchFetchTradingPoolFeeState(
        IRebalancingSetTokenV3[] calldata _tradingPools
    )
        external
        view
        returns (PerformanceFeeLibrary.FeeState[] memory)
    {

        uint256 _poolCount = _tradingPools.length;

        PerformanceFeeLibrary.FeeState[] memory feeStates = new PerformanceFeeLibrary.FeeState[](_poolCount);

        for (uint256 i = 0; i < _poolCount; i++) {
            feeStates[i] = getPerformanceFeeState(
                address(_tradingPools[i])
            );
        }

        return feeStates;
    }
}



pragma solidity 0.5.7;


interface ICToken {


    function exchangeRateCurrent()
        external
        returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function decimals() external view returns(uint8);


    function mint(uint mintAmount) external returns (uint);


    function redeem(uint redeemTokens) external returns (uint);

}



pragma solidity 0.5.7;




contract CTokenViewer {


    function batchFetchExchangeRateStored(
        address[] calldata _cTokenAddresses
    )
        external
        view
        returns (uint256[] memory)
    {

        uint256 _addressesCount = _cTokenAddresses.length;

        uint256[] memory cTokenExchangeRates = new uint256[](_addressesCount);

        for (uint256 i = 0; i < _addressesCount; i++) {
            cTokenExchangeRates[i] = ICToken(_cTokenAddresses[i]).exchangeRateStored();
        }

        return cTokenExchangeRates;
    }
}



pragma solidity 0.5.7;









contract ProtocolViewer is
    ERC20Viewer,
    TradingPoolViewer,
    CTokenViewer,
    ManagerViewer,
    OracleViewer
{}
