

pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;

library BatchActions {

    using SafeMath for uint256;
    enum ActionType {
        Deposit,   // Move asset from your wallet to tradeable balance
        Withdraw,  // Move asset from your tradeable balance to wallet
        Transfer,  // Move asset between tradeable balance and margin account
        Borrow,    // Borrow asset from pool
        Repay,     // Repay asset to pool
        Supply,    // Move asset from tradeable balance to pool to earn interest
        Unsupply   // Move asset from pool back to tradeable balance
    }

    struct Action {
        ActionType actionType;  // The action type
        bytes encodedParams;    // Encoded params, it's different for each action
    }

    function batch(
        Store.State storage state,
        Action[] memory actions,
        uint256 msgValue
    )
        public
    {

        uint256 totalDepositedEtherAmount = 0;

        for (uint256 i = 0; i < actions.length; i++) {
            Action memory action = actions[i];
            ActionType actionType = action.actionType;

            if (actionType == ActionType.Deposit) {
                uint256 depositedEtherAmount = deposit(state, action);
                totalDepositedEtherAmount = totalDepositedEtherAmount.add(depositedEtherAmount);
            } else if (actionType == ActionType.Withdraw) {
                withdraw(state, action);
            } else if (actionType == ActionType.Transfer) {
                transfer(state, action);
            } else if (actionType == ActionType.Borrow) {
                borrow(state, action);
            } else if (actionType == ActionType.Repay) {
                repay(state, action);
            } else if (actionType == ActionType.Supply) {
                supply(state, action);
            } else if (actionType == ActionType.Unsupply) {
                unsupply(state, action);
            }
        }

        require(totalDepositedEtherAmount == msgValue, "MSG_VALUE_AND_AMOUNT_MISMATCH");
    }

    function deposit(
        Store.State storage state,
        Action memory action
    )
        private
        returns (uint256)
    {

        (
            address asset,
            uint256 amount
        ) = abi.decode(
            action.encodedParams,
            (
                address,
                uint256
            )
        );

        return Transfer.deposit(
            state,
            asset,
            amount
        );
    }

    function withdraw(
        Store.State storage state,
        Action memory action
    )
        private
    {

        (
            address asset,
            uint256 amount
        ) = abi.decode(
            action.encodedParams,
            (
                address,
                uint256
            )
        );

        Transfer.withdraw(
            state,
            msg.sender,
            asset,
            amount
        );
    }

    function transfer(
        Store.State storage state,
        Action memory action
    )
        private
    {

        (
            address asset,
            Types.BalancePath memory fromBalancePath,
            Types.BalancePath memory toBalancePath,
            uint256 amount
        ) = abi.decode(
            action.encodedParams,
            (
                address,
                Types.BalancePath,
                Types.BalancePath,
                uint256
            )
        );

        require(fromBalancePath.user == msg.sender, "CAN_NOT_MOVE_OTHER_USER_ASSET");
        require(toBalancePath.user == msg.sender, "CAN_NOT_MOVE_ASSET_TO_OTHER_USER");

        Requires.requirePathNormalStatus(state, fromBalancePath);
        Requires.requirePathNormalStatus(state, toBalancePath);


        if (fromBalancePath.category == Types.BalanceCategory.CollateralAccount) {
            require(
                CollateralAccounts.getTransferableAmount(state, fromBalancePath.marketID, fromBalancePath.user, asset) >= amount,
                "COLLATERAL_ACCOUNT_TRANSFERABLE_AMOUNT_NOT_ENOUGH"
            );
        }

        Transfer.transfer(
            state,
            asset,
            fromBalancePath,
            toBalancePath,
            amount
        );

        if (toBalancePath.category == Types.BalanceCategory.CollateralAccount) {
            Events.logIncreaseCollateral(msg.sender, toBalancePath.marketID, asset, amount);
        }
        if (fromBalancePath.category == Types.BalanceCategory.CollateralAccount) {
            Events.logDecreaseCollateral(msg.sender, fromBalancePath.marketID, asset, amount);
        }
    }

    function borrow(
        Store.State storage state,
        Action memory action
    )
        private
    {

        (
            uint16 marketID,
            address asset,
            uint256 amount
        ) = abi.decode(
            action.encodedParams,
            (
                uint16,
                address,
                uint256
            )
        );

        Requires.requireMarketIDExist(state, marketID);
        Requires.requireMarketBorrowEnabled(state, marketID);
        Requires.requireMarketIDAndAssetMatch(state, marketID, asset);
        Requires.requireAccountNormal(state, marketID, msg.sender);
        LendingPool.borrow(
            state,
            msg.sender,
            marketID,
            asset,
            amount
        );
    }

    function repay(
        Store.State storage state,
        Action memory action
    )
        private
    {

        (
            uint16 marketID,
            address asset,
            uint256 amount
        ) = abi.decode(
            action.encodedParams,
            (
                uint16,
                address,
                uint256
            )
        );

        Requires.requireMarketIDExist(state, marketID);
        Requires.requireMarketIDAndAssetMatch(state, marketID, asset);

        LendingPool.repay(
            state,
            msg.sender,
            marketID,
            asset,
            amount
        );
    }

    function supply(
        Store.State storage state,
        Action memory action
    )
        private
    {

        (
            address asset,
            uint256 amount
        ) = abi.decode(
            action.encodedParams,
            (
                address,
                uint256
            )
        );

        Requires.requireAssetExist(state, asset);
        LendingPool.supply(
            state,
            asset,
            amount,
            msg.sender
        );
    }

    function unsupply(
        Store.State storage state,
        Action memory action
    )
        private
    {

        (
            address asset,
            uint256 amount
        ) = abi.decode(
            action.encodedParams,
            (
                address,
                uint256
            )
        );

        Requires.requireAssetExist(state, asset);
        LendingPool.unsupply(
            state,
            asset,
            amount,
            msg.sender
        );
    }
}

library CollateralAccounts {

    using SafeMath for uint256;

    function getDetails(
        Store.State storage state,
        address user,
        uint16 marketID
    )
        internal
        view
        returns (Types.CollateralAccountDetails memory details)
    {

        Types.CollateralAccount storage account = state.accounts[user][marketID];
        Types.Market storage market = state.markets[marketID];

        details.status = account.status;

        address baseAsset = market.baseAsset;
        address quoteAsset = market.quoteAsset;

        uint256 baseUSDPrice = AssemblyCall.getAssetPriceFromPriceOracle(
            address(state.assets[baseAsset].priceOracle),
            baseAsset
        );
        uint256 quoteUSDPrice = AssemblyCall.getAssetPriceFromPriceOracle(
            address(state.assets[quoteAsset].priceOracle),
            quoteAsset
        );

        uint256 baseBorrowOf = LendingPool.getAmountBorrowed(state, baseAsset, user, marketID);
        uint256 quoteBorrowOf = LendingPool.getAmountBorrowed(state, quoteAsset, user, marketID);

        details.debtsTotalUSDValue = SafeMath.add(
            baseBorrowOf.mul(baseUSDPrice),
            quoteBorrowOf.mul(quoteUSDPrice)
        ) / Decimal.one();

        details.balancesTotalUSDValue = SafeMath.add(
            account.balances[baseAsset].mul(baseUSDPrice),
            account.balances[quoteAsset].mul(quoteUSDPrice)
        ) / Decimal.one();

        if (details.status == Types.CollateralAccountStatus.Normal) {
            details.liquidatable = details.balancesTotalUSDValue < Decimal.mulCeil(details.debtsTotalUSDValue, market.liquidateRate);
        } else {
            details.liquidatable = false;
        }
    }

    function getTransferableAmount(
        Store.State storage state,
        uint16 marketID,
        address user,
        address asset
    )
        internal
        view
        returns (uint256)
    {

        Types.CollateralAccountDetails memory details = getDetails(state, user, marketID);


        uint256 assetBalance = state.accounts[user][marketID].balances[asset];

        uint256 transferableThresholdUSDValue = Decimal.mulCeil(
            details.debtsTotalUSDValue,
            state.markets[marketID].withdrawRate
        );

        if(transferableThresholdUSDValue > details.balancesTotalUSDValue) {
            return 0;
        } else {
            uint256 transferableUSD = details.balancesTotalUSDValue - transferableThresholdUSDValue;
            uint256 assetUSDPrice = state.assets[asset].priceOracle.getPrice(asset);
            uint256 transferableAmount = Decimal.divFloor(transferableUSD, assetUSDPrice);
            if (transferableAmount > assetBalance) {
                return assetBalance;
            } else {
                return transferableAmount;
            }
        }
    }
}

library LendingPool {

    using SafeMath for uint256;
    using SafeMath for int256;

    uint256 private constant SECONDS_OF_YEAR = 31536000;

    function initializeAssetLendingPool(
        Store.State storage state,
        address asset
    )
        internal
    {

        state.pool.borrowIndex[asset] = Decimal.one();
        state.pool.supplyIndex[asset] = Decimal.one();

        state.pool.indexStartTime[asset] = block.timestamp;
    }

    function supply(
        Store.State storage state,
        address asset,
        uint256 amount,
        address user
    )
        internal
    {

        updateIndex(state, asset);

        Transfer.transferOut(state, asset, BalancePath.getCommonPath(user), amount);

        uint256 normalizedAmount = Decimal.divFloor(amount, state.pool.supplyIndex[asset]);

        state.assets[asset].lendingPoolToken.mint(user, normalizedAmount);

        updateInterestRate(state, asset);

        Events.logSupply(user, asset, amount);
    }

    function unsupply(
        Store.State storage state,
        address asset,
        uint256 amount,
        address user
    )
        internal
        returns (uint256)
    {

        updateIndex(state, asset);

        uint256 normalizedAmount = Decimal.divCeil(amount, state.pool.supplyIndex[asset]);

        uint256 unsupplyAmount = amount;

        if (getNormalizedSupplyOf(state, asset, user) <= normalizedAmount) {
            normalizedAmount = getNormalizedSupplyOf(state, asset, user);
            unsupplyAmount = Decimal.mulFloor(normalizedAmount, state.pool.supplyIndex[asset]);
        }

        Transfer.transferIn(state, asset, BalancePath.getCommonPath(user), unsupplyAmount);
        Requires.requireCashLessThanOrEqualContractBalance(state, asset);

        state.assets[asset].lendingPoolToken.burn(user, normalizedAmount);

        updateInterestRate(state, asset);

        Events.logUnsupply(user, asset, unsupplyAmount);

        return unsupplyAmount;
    }

    function borrow(
        Store.State storage state,
        address user,
        uint16 marketID,
        address asset,
        uint256 amount
    )
        internal
    {

        updateIndex(state, asset);

        uint256 normalizedAmount = Decimal.divCeil(amount, state.pool.borrowIndex[asset]);

        Transfer.transferIn(state, asset, BalancePath.getMarketPath(user, marketID), amount);
        Requires.requireCashLessThanOrEqualContractBalance(state, asset);

        state.pool.normalizedBorrow[user][marketID][asset] = state.pool.normalizedBorrow[user][marketID][asset].add(normalizedAmount);

        state.pool.normalizedTotalBorrow[asset] = state.pool.normalizedTotalBorrow[asset].add(normalizedAmount);

        updateInterestRate(state, asset);

        Requires.requireCollateralAccountNotLiquidatable(state, user, marketID);

        Events.logBorrow(user, marketID, asset, amount);
    }

    function repay(
        Store.State storage state,
        address user,
        uint16 marketID,
        address asset,
        uint256 amount
    )
        internal
        returns (uint256)
    {

        updateIndex(state, asset);

        uint256 normalizedAmount = Decimal.divFloor(amount, state.pool.borrowIndex[asset]);

        uint256 repayAmount = amount;

        if (state.pool.normalizedBorrow[user][marketID][asset] <= normalizedAmount) {
            normalizedAmount = state.pool.normalizedBorrow[user][marketID][asset];
            repayAmount = Decimal.mulCeil(normalizedAmount, state.pool.borrowIndex[asset]);
        }

        Transfer.transferOut(state, asset, BalancePath.getMarketPath(user, marketID), repayAmount);

        state.pool.normalizedBorrow[user][marketID][asset] = state.pool.normalizedBorrow[user][marketID][asset].sub(normalizedAmount);

        state.pool.normalizedTotalBorrow[asset] = state.pool.normalizedTotalBorrow[asset].sub(normalizedAmount);

        updateInterestRate(state, asset);

        Events.logRepay(user, marketID, asset, repayAmount);

        return repayAmount;
    }

    function recognizeLoss(
        Store.State storage state,
        address asset,
        uint256 amount
    )
        internal
    {

        uint256 totalnormalizedSupply = getTotalNormalizedSupply(
            state,
            asset
        );

        uint256 actualSupply = getTotalSupply(
            state,
            asset
        ).sub(amount);

        state.pool.supplyIndex[asset] = Decimal.divFloor(
            actualSupply,
            totalnormalizedSupply
        );

        updateIndex(state, asset);

        Events.logLoss(asset, amount);
    }

    function claimInsurance(
        Store.State storage state,
        address asset,
        uint256 amount
    )
        internal
    {

        uint256 insuranceBalance = state.pool.insuranceBalances[asset];

        uint256 compensationAmount = SafeMath.min(amount, insuranceBalance);

        state.cash[asset] = state.cash[asset].add(amount);

        state.pool.insuranceBalances[asset] = SafeMath.sub(
            state.pool.insuranceBalances[asset],
            compensationAmount
        );

        if (compensationAmount < amount) {
            recognizeLoss(
                state,
                asset,
                amount.sub(compensationAmount)
            );
        }

        Events.logInsuranceCompensation(
            asset,
            compensationAmount
        );

    }

    function updateInterestRate(
        Store.State storage state,
        address asset
    )
        private
    {

        (uint256 borrowInterestRate, uint256 supplyInterestRate) = getInterestRates(state, asset, 0);
        state.pool.borrowAnnualInterestRate[asset] = borrowInterestRate;
        state.pool.supplyAnnualInterestRate[asset] = supplyInterestRate;
    }

    function getInterestRates(
        Store.State storage state,
        address asset,
        uint256 extraBorrowAmount
    )
        internal
        view
        returns (uint256 borrowInterestRate, uint256 supplyInterestRate)
    {

        (uint256 currentSupplyIndex, uint256 currentBorrowIndex) = getCurrentIndex(state, asset);

        uint256 _supply = getTotalSupplyWithIndex(state, asset, currentSupplyIndex);

        if (_supply == 0) {
            return (0, 0);
        }

        uint256 _borrow = getTotalBorrowWithIndex(state, asset, currentBorrowIndex).add(extraBorrowAmount);

        uint256 borrowRatio = _borrow.mul(Decimal.one()).div(_supply);

        borrowInterestRate = AssemblyCall.getBorrowInterestRate(
            address(state.assets[asset].interestModel),
            borrowRatio
        );
        require(borrowInterestRate <= 3 * Decimal.one(), "BORROW_INTEREST_RATE_EXCEED_300%");

        uint256 borrowInterest = Decimal.mulCeil(_borrow, borrowInterestRate);
        uint256 supplyInterest = Decimal.mulFloor(borrowInterest, Decimal.one().sub(state.pool.insuranceRatio));

        supplyInterestRate = Decimal.divFloor(supplyInterest, _supply);
    }

    function updateIndex(
        Store.State storage state,
        address asset
    )
        private
    {

        if (state.pool.indexStartTime[asset] == block.timestamp) {
            return;
        }

        (uint256 currentSupplyIndex, uint256 currentBorrowIndex) = getCurrentIndex(state, asset);

        uint256 normalizedBorrow = state.pool.normalizedTotalBorrow[asset];
        uint256 normalizedSupply = getTotalNormalizedSupply(state, asset);

        uint256 recentBorrowInterest = Decimal.mulCeil(
            normalizedBorrow,
            currentBorrowIndex.sub(state.pool.borrowIndex[asset])
        );

        uint256 recentSupplyInterest = Decimal.mulFloor(
            normalizedSupply,
            currentSupplyIndex.sub(state.pool.supplyIndex[asset])
        );

        state.pool.insuranceBalances[asset] = state.pool.insuranceBalances[asset].add(recentBorrowInterest.sub(recentSupplyInterest));

        Events.logUpdateIndex(
            asset,
            state.pool.borrowIndex[asset],
            currentBorrowIndex,
            state.pool.supplyIndex[asset],
            currentSupplyIndex
        );

        state.pool.supplyIndex[asset] = currentSupplyIndex;
        state.pool.borrowIndex[asset] = currentBorrowIndex;
        state.pool.indexStartTime[asset] = block.timestamp;

    }

    function getAmountSupplied(
        Store.State storage state,
        address asset,
        address user
    )
        internal
        view
        returns (uint256)
    {

        (uint256 currentSupplyIndex, ) = getCurrentIndex(state, asset);
        return Decimal.mulFloor(getNormalizedSupplyOf(state, asset, user), currentSupplyIndex);
    }

    function getAmountBorrowed(
        Store.State storage state,
        address asset,
        address user,
        uint16 marketID
    )
        internal
        view
        returns (uint256)
    {

        (, uint256 currentBorrowIndex) = getCurrentIndex(state, asset);
        return Decimal.mulCeil(state.pool.normalizedBorrow[user][marketID][asset], currentBorrowIndex);
    }

    function getTotalSupply(
        Store.State storage state,
        address asset
    )
        internal
        view
        returns (uint256)
    {

        (uint256 currentSupplyIndex, ) = getCurrentIndex(state, asset);
        return getTotalSupplyWithIndex(state, asset, currentSupplyIndex);
    }

    function getTotalBorrow(
        Store.State storage state,
        address asset
    )
        internal
        view
        returns (uint256)
    {

        (, uint256 currentBorrowIndex) = getCurrentIndex(state, asset);
        return getTotalBorrowWithIndex(state, asset, currentBorrowIndex);
    }

    function getTotalSupplyWithIndex(
        Store.State storage state,
        address asset,
        uint256 currentSupplyIndex
    )
        private
        view
        returns (uint256)
    {

        return Decimal.mulFloor(getTotalNormalizedSupply(state, asset), currentSupplyIndex);
    }

    function getTotalBorrowWithIndex(
        Store.State storage state,
        address asset,
        uint256 currentBorrowIndex
    )
        private
        view
        returns (uint256)
    {

        return Decimal.mulCeil(state.pool.normalizedTotalBorrow[asset], currentBorrowIndex);
    }

    function getCurrentIndex(
        Store.State storage state,
        address asset
    )
        internal
        view
        returns (uint256 currentSupplyIndex, uint256 currentBorrowIndex)
    {

        uint256 timeDelta = block.timestamp.sub(state.pool.indexStartTime[asset]);

        uint256 borrowInterestRate = state.pool.borrowAnnualInterestRate[asset]
            .mul(timeDelta).divCeil(SECONDS_OF_YEAR); // Ceil Ensure asset greater than liability

        uint256 supplyInterestRate = state.pool.supplyAnnualInterestRate[asset]
            .mul(timeDelta).div(SECONDS_OF_YEAR);

        currentBorrowIndex = Decimal.mulCeil(state.pool.borrowIndex[asset], Decimal.onePlus(borrowInterestRate));
        currentSupplyIndex = Decimal.mulFloor(state.pool.supplyIndex[asset], Decimal.onePlus(supplyInterestRate));

        return (currentSupplyIndex, currentBorrowIndex);
    }

    function getNormalizedSupplyOf(
        Store.State storage state,
        address asset,
        address user
    )
        private
        view
        returns (uint256)
    {

        return state.assets[asset].lendingPoolToken.balanceOf(user);
    }

    function getTotalNormalizedSupply(
        Store.State storage state,
        address asset
    )
        private
        view
        returns (uint256)
    {

        return state.assets[asset].lendingPoolToken.totalSupply();
    }
}

interface IInterestModel {

    function polynomialInterestModel(
        uint256 borrowRatio
    )
        external
        pure
        returns(uint256);

}

interface ILendingPoolToken {

    function mint(
        address user,
        uint256 value
    )
        external;


    function burn(
        address user,
        uint256 value
    )
        external;


    function balanceOf(
        address user
    )
        external
        view
        returns (uint256);


    function totalSupply()
        external
        view
        returns (uint256);

}

interface IPriceOracle {

    function getPrice(
        address asset
    )
        external
        view
        returns (uint256);

}

interface IStandardToken {

    function transfer(
        address _to,
        uint256 _amount
    )
        external
        returns (bool);


    function balanceOf(
        address _owner)
        external
        view
        returns (uint256 balance);


    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    )
        external
        returns (bool);


    function approve(
        address _spender,
        uint256 _amount
    )
        external
        returns (bool);


    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256);

}

library AssemblyCall {

    function getAssetPriceFromPriceOracle(
        address oracleAddress,
        address asset
    )
        internal
        view
        returns (uint256)
    {


        bytes32 functionSelector = 0x41976e0900000000000000000000000000000000000000000000000000000000;

        (uint256 result, bool success) = callWith32BytesReturnsUint256(
            oracleAddress,
            functionSelector,
            bytes32(uint256(uint160(asset)))
        );

        if (!success) {
            revert("ASSEMBLY_CALL_GET_ASSET_PRICE_FAILED");
        }

        return result;
    }

    function getHotBalance(
        address hotToken,
        address owner
    )
        internal
        view
        returns (uint256)
    {


        bytes32 functionSelector = 0x70a0823100000000000000000000000000000000000000000000000000000000;

        (uint256 result, bool success) = callWith32BytesReturnsUint256(
            hotToken,
            functionSelector,
            bytes32(uint256(uint160(owner)))
        );

        if (!success) {
            revert("ASSEMBLY_CALL_GET_HOT_BALANCE_FAILED");
        }

        return result;
    }

    function getBorrowInterestRate(
        address interestModel,
        uint256 borrowRatio
    )
        internal
        view
        returns (uint256)
    {


        bytes32 functionSelector = 0x69e8a15f00000000000000000000000000000000000000000000000000000000;

        (uint256 result, bool success) = callWith32BytesReturnsUint256(
            interestModel,
            functionSelector,
            bytes32(borrowRatio)
        );

        if (!success) {
            revert("ASSEMBLY_CALL_GET_BORROW_INTEREST_RATE_FAILED");
        }

        return result;
    }

    function callWith32BytesReturnsUint256(
        address to,
        bytes32 functionSelector,
        bytes32 param1
    )
        private
        view
        returns (uint256 result, bool success)
    {

        assembly {
            let freePtr := mload(0x40)
            let tmp1 := mload(freePtr)
            let tmp2 := mload(add(freePtr, 4))

            mstore(freePtr, functionSelector)
            mstore(add(freePtr, 4), param1)

            success := staticcall(
                gas,           // Forward all gas
                to,            // Interest Model Address
                freePtr,       // Pointer to start of calldata
                36,            // Length of calldata
                freePtr,       // Overwrite calldata with output
                32             // Expecting uint256 output
            )

            result := mload(freePtr)

            mstore(freePtr, tmp1)
            mstore(add(freePtr, 4), tmp2)
        }
    }
}

library Consts {

    function ETHEREUM_TOKEN_ADDRESS()
        internal
        pure
        returns (address)
    {

        return 0x000000000000000000000000000000000000000E;
    }

    function DISCOUNT_RATE_BASE()
        internal
        pure
        returns (uint256)
    {

        return 100;
    }

    function REBATE_RATE_BASE()
        internal
        pure
        returns (uint256)
    {

        return 100;
    }
}

library Decimal {

    using SafeMath for uint256;

    uint256 constant BASE = 10**18;

    function one()
        internal
        pure
        returns (uint256)
    {

        return BASE;
    }

    function onePlus(
        uint256 d
    )
        internal
        pure
        returns (uint256)
    {

        return d.add(BASE);
    }

    function mulFloor(
        uint256 target,
        uint256 d
    )
        internal
        pure
        returns (uint256)
    {

        return target.mul(d) / BASE;
    }

    function mulCeil(
        uint256 target,
        uint256 d
    )
        internal
        pure
        returns (uint256)
    {

        return target.mul(d).divCeil(BASE);
    }

    function divFloor(
        uint256 target,
        uint256 d
    )
        internal
        pure
        returns (uint256)
    {

        return target.mul(BASE).div(d);
    }

    function divCeil(
        uint256 target,
        uint256 d
    )
        internal
        pure
        returns (uint256)
    {

        return target.mul(BASE).divCeil(d);
    }
}

library EIP712 {

    string private constant DOMAIN_NAME = "Hydro Protocol";

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(
        abi.encodePacked("EIP712Domain(string name)")
    );

    bytes32 private constant DOMAIN_SEPARATOR = keccak256(
        abi.encodePacked(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes(DOMAIN_NAME))
        )
    );

    function hashMessage(
        bytes32 eip712hash
    )
        internal
        pure
        returns (bytes32)
    {

        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, eip712hash));
    }
}

library Events {


    event Deposit(
        address indexed user,
        address indexed asset,
        uint256 amount
    );

    function logDeposit(
        address user,
        address asset,
        uint256 amount
    )
        internal
    {

        emit Deposit(
            user,
            asset,
            amount
        );
    }

    event Withdraw(
        address indexed user,
        address indexed asset,
        uint256 amount
    );

    function logWithdraw(
        address user,
        address asset,
        uint256 amount
    )
        internal
    {

        emit Withdraw(
            user,
            asset,
            amount
        );
    }

    event IncreaseCollateral (
        address indexed user,
        uint16 indexed marketID,
        address indexed asset,
        uint256 amount
    );

    function logIncreaseCollateral(
        address user,
        uint16 marketID,
        address asset,
        uint256 amount
    )
        internal
    {

        emit IncreaseCollateral(
            user,
            marketID,
            asset,
            amount
        );
    }

    event DecreaseCollateral (
        address indexed user,
        uint16 indexed marketID,
        address indexed asset,
        uint256 amount
    );

    function logDecreaseCollateral(
        address user,
        uint16 marketID,
        address asset,
        uint256 amount
    )
        internal
    {

        emit DecreaseCollateral(
            user,
            marketID,
            asset,
            amount
        );
    }


    event UpdateIndex(
        address indexed asset,
        uint256 oldBorrowIndex,
        uint256 newBorrowIndex,
        uint256 oldSupplyIndex,
        uint256 newSupplyIndex
    );

    function logUpdateIndex(
        address asset,
        uint256 oldBorrowIndex,
        uint256 newBorrowIndex,
        uint256 oldSupplyIndex,
        uint256 newSupplyIndex
    )
        internal
    {

        emit UpdateIndex(
            asset,
            oldBorrowIndex,
            newBorrowIndex,
            oldSupplyIndex,
            newSupplyIndex
        );
    }

    event Borrow(
        address indexed user,
        uint16 indexed marketID,
        address indexed asset,
        uint256 amount
    );

    function logBorrow(
        address user,
        uint16 marketID,
        address asset,
        uint256 amount
    )
        internal
    {

        emit Borrow(
            user,
            marketID,
            asset,
            amount
        );
    }

    event Repay(
        address indexed user,
        uint16 indexed marketID,
        address indexed asset,
        uint256 amount
    );

    function logRepay(
        address user,
        uint16 marketID,
        address asset,
        uint256 amount
    )
        internal
    {

        emit Repay(
            user,
            marketID,
            asset,
            amount
        );
    }

    event Supply(
        address indexed user,
        address indexed asset,
        uint256 amount
    );

    function logSupply(
        address user,
        address asset,
        uint256 amount
    )
        internal
    {

        emit Supply(
            user,
            asset,
            amount
        );
    }

    event Unsupply(
        address indexed user,
        address indexed asset,
        uint256 amount
    );

    function logUnsupply(
        address user,
        address asset,
        uint256 amount
    )
        internal
    {

        emit Unsupply(
            user,
            asset,
            amount
        );
    }

    event Loss(
        address indexed asset,
        uint256 amount
    );

    function logLoss(
        address asset,
        uint256 amount
    )
        internal
    {

        emit Loss(
            asset,
            amount
        );
    }

    event InsuranceCompensation(
        address indexed asset,
        uint256 amount
    );

    function logInsuranceCompensation(
        address asset,
        uint256 amount
    )
        internal
    {

        emit InsuranceCompensation(
            asset,
            amount
        );
    }


    event CreateMarket(Types.Market market);

    function logCreateMarket(
        Types.Market memory market
    )
        internal
    {

        emit CreateMarket(market);
    }

    event UpdateMarket(
        uint16 indexed marketID,
        uint256 newAuctionRatioStart,
        uint256 newAuctionRatioPerBlock,
        uint256 newLiquidateRate,
        uint256 newWithdrawRate
    );

    function logUpdateMarket(
        uint16 marketID,
        uint256 newAuctionRatioStart,
        uint256 newAuctionRatioPerBlock,
        uint256 newLiquidateRate,
        uint256 newWithdrawRate
    )
        internal
    {

        emit UpdateMarket(
            marketID,
            newAuctionRatioStart,
            newAuctionRatioPerBlock,
            newLiquidateRate,
            newWithdrawRate
        );
    }

    event MarketBorrowDisable(
        uint16 indexed marketID
    );

    function logMarketBorrowDisable(
        uint16 marketID
    )
        internal
    {

        emit MarketBorrowDisable(
            marketID
        );
    }

    event MarketBorrowEnable(
        uint16 indexed marketID
    );

    function logMarketBorrowEnable(
        uint16 marketID
    )
        internal
    {

        emit MarketBorrowEnable(
            marketID
        );
    }

    event UpdateDiscountConfig(bytes32 newConfig);

    function logUpdateDiscountConfig(
        bytes32 newConfig
    )
        internal
    {

        emit UpdateDiscountConfig(newConfig);
    }

    event CreateAsset(
        address asset,
        address oracleAddress,
        address poolTokenAddress,
        address interestModelAddress
    );

    function logCreateAsset(
        address asset,
        address oracleAddress,
        address poolTokenAddress,
        address interestModelAddress
    )
        internal
    {

        emit CreateAsset(
            asset,
            oracleAddress,
            poolTokenAddress,
            interestModelAddress
        );
    }

    event UpdateAsset(
        address indexed asset,
        address oracleAddress,
        address interestModelAddress
    );

    function logUpdateAsset(
        address asset,
        address oracleAddress,
        address interestModelAddress
    )
        internal
    {

        emit UpdateAsset(
            asset,
            oracleAddress,
            interestModelAddress
        );
    }

    event UpdateAuctionInitiatorRewardRatio(
        uint256 newInitiatorRewardRatio
    );

    function logUpdateAuctionInitiatorRewardRatio(
        uint256 newInitiatorRewardRatio
    )
        internal
    {

        emit UpdateAuctionInitiatorRewardRatio(
            newInitiatorRewardRatio
        );
    }

    event UpdateInsuranceRatio(
        uint256 newInsuranceRatio
    );

    function logUpdateInsuranceRatio(
        uint256 newInsuranceRatio
    )
        internal
    {

        emit UpdateInsuranceRatio(newInsuranceRatio);
    }


    event Liquidate(
        address indexed user,
        uint16 indexed marketID,
        bool indexed hasAuction
    );

    function logLiquidate(
        address user,
        uint16 marketID,
        bool hasAuction
    )
        internal
    {

        emit Liquidate(
            user,
            marketID,
            hasAuction
        );
    }

    event AuctionCreate(
        uint256 auctionID
    );

    function logAuctionCreate(
        uint256 auctionID
    )
        internal
    {

        emit AuctionCreate(auctionID);
    }

    event FillAuction(
        uint256 indexed auctionID,
        address bidder,
        uint256 repayDebt,
        uint256 bidderRepayDebt,
        uint256 bidderCollateral,
        uint256 leftDebt
    );

    function logFillAuction(
        uint256 auctionID,
        address bidder,
        uint256 repayDebt,
        uint256 bidderRepayDebt,
        uint256 bidderCollateral,
        uint256 leftDebt
    )
        internal
    {

        emit FillAuction(
            auctionID,
            bidder,
            repayDebt,
            bidderRepayDebt,
            bidderCollateral,
            leftDebt
        );
    }


    event RelayerApproveDelegate(
        address indexed relayer,
        address indexed delegate
    );

    function logRelayerApproveDelegate(
        address relayer,
        address delegate
    )
        internal
    {

        emit RelayerApproveDelegate(
            relayer,
            delegate
        );
    }

    event RelayerRevokeDelegate(
        address indexed relayer,
        address indexed delegate
    );

    function logRelayerRevokeDelegate(
        address relayer,
        address delegate
    )
        internal
    {

        emit RelayerRevokeDelegate(
            relayer,
            delegate
        );
    }

    event RelayerExit(
        address indexed relayer
    );

    function logRelayerExit(
        address relayer
    )
        internal
    {

        emit RelayerExit(relayer);
    }

    event RelayerJoin(
        address indexed relayer
    );

    function logRelayerJoin(
        address relayer
    )
        internal
    {

        emit RelayerJoin(relayer);
    }


    event Match(
        Types.OrderAddressSet addressSet,
        address maker,
        address taker,
        address buyer,
        uint256 makerFee,
        uint256 makerRebate,
        uint256 takerFee,
        uint256 makerGasFee,
        uint256 takerGasFee,
        uint256 baseAssetFilledAmount,
        uint256 quoteAssetFilledAmount

    );

    function logMatch(
        Types.MatchResult memory result,
        Types.OrderAddressSet memory addressSet
    )
        internal
    {

        emit Match(
            addressSet,
            result.maker,
            result.taker,
            result.buyer,
            result.makerFee,
            result.makerRebate,
            result.takerFee,
            result.makerGasFee,
            result.takerGasFee,
            result.baseAssetFilledAmount,
            result.quoteAssetFilledAmount
        );
    }

    event OrderCancel(
        bytes32 indexed orderHash
    );

    function logOrderCancel(
        bytes32 orderHash
    )
        internal
    {

        emit OrderCancel(orderHash);
    }
}

library Requires {

    function requireAssetExist(
        Store.State storage state,
        address asset
    )
        internal
        view
    {

        require(isAssetExist(state, asset), "ASSET_NOT_EXIST");
    }

    function requireAssetNotExist(
        Store.State storage state,
        address asset
    )
        internal
        view
    {

        require(!isAssetExist(state, asset), "ASSET_ALREADY_EXIST");
    }

    function requireMarketIDAndAssetMatch(
        Store.State storage state,
        uint16 marketID,
        address asset
    )
        internal
        view
    {

        require(
            asset == state.markets[marketID].baseAsset || asset == state.markets[marketID].quoteAsset,
            "ASSET_NOT_BELONGS_TO_MARKET"
        );
    }

    function requireMarketNotExist(
        Store.State storage state,
        Types.Market memory market
    )
        internal
        view
    {

        require(!isMarketExist(state, market), "MARKET_ALREADY_EXIST");
    }

    function requireMarketAssetsValid(
        Store.State storage state,
        Types.Market memory market
    )
        internal
        view
    {

        require(market.baseAsset != market.quoteAsset, "BASE_QUOTE_DUPLICATED");
        require(isAssetExist(state, market.baseAsset), "MARKET_BASE_ASSET_NOT_EXIST");
        require(isAssetExist(state, market.quoteAsset), "MARKET_QUOTE_ASSET_NOT_EXIST");
    }

    function requireCashLessThanOrEqualContractBalance(
        Store.State storage state,
        address asset
    )
        internal
        view
    {

        if (asset == Consts.ETHEREUM_TOKEN_ADDRESS()) {
            if (state.cash[asset] > 0) {
                require(uint256(state.cash[asset]) <= address(this).balance, "CONTRACT_BALANCE_NOT_ENOUGH");
            }
        } else {
            if (state.cash[asset] > 0) {
                require(uint256(state.cash[asset]) <= IStandardToken(asset).balanceOf(address(this)), "CONTRACT_BALANCE_NOT_ENOUGH");
            }
        }
    }

    function requirePriceOracleAddressValid(
        address oracleAddress
    )
        internal
        pure
    {

        require(oracleAddress != address(0), "ORACLE_ADDRESS_NOT_VALID");
    }

    function requireDecimalLessOrEquanThanOne(
        uint256 decimal
    )
        internal
        pure
    {

        require(decimal <= Decimal.one(), "DECIMAL_GREATER_THAN_ONE");
    }

    function requireDecimalGreaterThanOne(
        uint256 decimal
    )
        internal
        pure
    {

        require(decimal > Decimal.one(), "DECIMAL_LESS_OR_EQUAL_THAN_ONE");
    }

    function requireMarketIDExist(
        Store.State storage state,
        uint16 marketID
    )
        internal
        view
    {

        require(marketID < state.marketsCount, "MARKET_NOT_EXIST");
    }

    function requireMarketBorrowEnabled(
        Store.State storage state,
        uint16 marketID
    )
        internal
        view
    {

        require(state.markets[marketID].borrowEnable, "MARKET_BORROW_DISABLED");
    }

    function requirePathNormalStatus(
        Store.State storage state,
        Types.BalancePath memory path
    )
        internal
        view
    {

        if (path.category == Types.BalanceCategory.CollateralAccount) {
            requireAccountNormal(state, path.marketID, path.user);
        }
    }

    function requireAccountNormal(
        Store.State storage state,
        uint16 marketID,
        address user
    )
        internal
        view
    {

        require(
            state.accounts[user][marketID].status == Types.CollateralAccountStatus.Normal,
            "CAN_NOT_OPERATE_LIQUIDATING_COLLATERAL_ACCOUNT"
        );
    }

    function requirePathMarketIDAssetMatch(
        Store.State storage state,
        Types.BalancePath memory path,
        address asset
    )
        internal
        view
    {

        if (path.category == Types.BalanceCategory.CollateralAccount) {
            requireMarketIDExist(state, path.marketID);
            requireMarketIDAndAssetMatch(state, path.marketID, asset);
        }
    }

    function requireCollateralAccountNotLiquidatable(
        Store.State storage state,
        Types.BalancePath memory path
    )
        internal
        view
    {

        if (path.category == Types.BalanceCategory.CollateralAccount) {
            requireCollateralAccountNotLiquidatable(state, path.user, path.marketID);
        }
    }

    function requireCollateralAccountNotLiquidatable(
        Store.State storage state,
        address user,
        uint16 marketID
    )
        internal
        view
    {

        require(
            !CollateralAccounts.getDetails(state, user, marketID).liquidatable,
            "COLLATERAL_ACCOUNT_LIQUIDATABLE"
        );
    }

    function requireAuctionNotFinished(
        Store.State storage state,
        uint32 auctionID
    )
        internal
        view
    {

        require(
            state.auction.auctions[auctionID].status == Types.AuctionStatus.InProgress,
            "AUCTION_ALREADY_FINISHED"
        );
    }

    function requireAuctionExist(
        Store.State storage state,
        uint32 auctionID
    )
        internal
        view
    {

        require(
            auctionID < state.auction.auctionsCount,
            "AUCTION_NOT_EXIST"
        );
    }

    function isAssetExist(
        Store.State storage state,
        address asset
    )
        private
        view
        returns (bool)
    {

        return state.assets[asset].priceOracle != IPriceOracle(address(0));
    }

    function isMarketExist(
        Store.State storage state,
        Types.Market memory market
    )
        private
        view
        returns (bool)
    {

        for(uint16 i = 0; i < state.marketsCount; i++) {
            if (state.markets[i].baseAsset == market.baseAsset && state.markets[i].quoteAsset == market.quoteAsset) {
                return true;
            }
        }

        return false;
    }

}

library SafeERC20 {

    function safeTransfer(
        address token,
        address to,
        uint256 amount
    )
        internal
    {

        bool result;

        assembly {
            let tmp1 := mload(0)
            let tmp2 := mload(4)
            let tmp3 := mload(36)

            mstore(0, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(4, to)
            mstore(36, amount)

            let callResult := call(gas, token, 0, 0, 68, 0, 32)
            let returnValue := mload(0)

            mstore(0, tmp1)
            mstore(4, tmp2)
            mstore(36, tmp3)

            result := and (
                eq(callResult, 1),
                or(eq(returndatasize, 0), and(eq(returndatasize, 32), gt(returnValue, 0)))
            )
        }

        if (!result) {
            revert("TOKEN_TRANSFER_ERROR");
        }
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        internal
    {

        bool result;

        assembly {
            let tmp1 := mload(0)
            let tmp2 := mload(4)
            let tmp3 := mload(36)
            let tmp4 := mload(68)

            mstore(0, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(4, from)
            mstore(36, to)
            mstore(68, amount)

            let callResult := call(gas, token, 0, 0, 100, 0, 32)
            let returnValue := mload(0)

            mstore(0, tmp1)
            mstore(4, tmp2)
            mstore(36, tmp3)
            mstore(68, tmp4)

            result := and (
                eq(callResult, 1),
                or(eq(returndatasize, 0), and(eq(returndatasize, 32), gt(returnValue, 0)))
            )
        }

        if (!result) {
            revert("TOKEN_TRANSFER_FROM_ERROR");
        }
    }
}

library SafeMath {


    function mul(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function sub(
        int256 a,
        uint256 b
    )
        internal
        pure
        returns (int256)
    {

        require(b <= 2**255-1, "INT256_SUB_ERROR");
        int256 c = a - int256(b);
        require(c <= a, "INT256_SUB_ERROR");
        return c;
    }

    function add(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function add(
        int256 a,
        uint256 b
    )
        internal
        pure
        returns (int256)
    {

        require(b <= 2**255 - 1, "INT256_ADD_ERROR");
        int256 c = a + int256(b);
        require(c >= a, "INT256_ADD_ERROR");
        return c;
    }

    function mod(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        require(b != 0, "MOD_ERROR");
        return a % b;
    }

    function isRoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 multiple
    )
        internal
        pure
        returns (bool)
    {

        return mul(mod(mul(numerator, multiple), denominator), 1000) >= mul(numerator, multiple);
    }

    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 multiple
    )
        internal
        pure
        returns (uint256)
    {

        require(!isRoundingError(numerator, denominator, multiple), "ROUNDING_ERROR");
        return div(mul(numerator, multiple), denominator);
    }

    function min(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
    }
}

library Signature {


    enum SignatureMethod {
        EthSign,
        EIP712
    }

    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        Types.Signature memory signature
    )
        internal
        pure
        returns (bool)
    {

        uint8 method = uint8(signature.config[1]);
        address recovered;
        uint8 v = uint8(signature.config[0]);

        if (method == uint8(SignatureMethod.EthSign)) {
            recovered = ecrecover(
                keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),
                v,
                signature.r,
                signature.s
            );
        } else if (method == uint8(SignatureMethod.EIP712)) {
            recovered = ecrecover(hash, v, signature.r, signature.s);
        } else {
            revert("INVALID_SIGN_METHOD");
        }

        return signerAddress == recovered;
    }
}

library Store {


    struct RelayerState {
        mapping (address => mapping (address => bool)) relayerDelegates;

        mapping (address => bool) hasExited;
    }

    struct ExchangeState {

        bytes32 discountConfig;

        mapping (bytes32 => uint256) filled;

        mapping (bytes32 => bool) cancelled;

        address hotTokenAddress;
    }

    struct LendingPoolState {
        uint256 insuranceRatio;

        mapping(address => uint256) insuranceBalances;

        mapping (address => uint256) borrowIndex; // decimal
        mapping (address => uint256) supplyIndex; // decimal
        mapping (address => uint256) indexStartTime; // timestamp

        mapping (address => uint256) borrowAnnualInterestRate; // decimal
        mapping (address => uint256) supplyAnnualInterestRate; // decimal

        mapping(address => uint256) normalizedTotalBorrow;

        mapping (address => mapping (uint16 => mapping(address => uint256))) normalizedBorrow;
    }

    struct AuctionState {

        uint32 auctionsCount;

        mapping(uint32 => Types.Auction) auctions;

        uint32[] currentAuctions;

        uint256 initiatorRewardRatio;
    }

    struct State {

        uint16 marketsCount;

        mapping(address => Types.Asset) assets;
        mapping(address => int256) cash;

        mapping(address => mapping(uint16 => Types.CollateralAccount)) accounts;

        mapping(uint16 => Types.Market) markets;

        mapping(address => mapping(address => uint256)) balances;

        LendingPoolState pool;

        ExchangeState exchange;

        RelayerState relayer;

        AuctionState auction;
    }
}

library Transfer {

    using SafeMath for uint256;
    using SafeMath for int256;
    using BalancePath for Types.BalancePath;

    function deposit(
        Store.State storage state,
        address asset,
        uint256 amount
    )
        internal
        returns (uint256)
    {

        uint256 depositedEtherAmount = 0;

        if (asset == Consts.ETHEREUM_TOKEN_ADDRESS()) {
            depositedEtherAmount = amount;
        } else {
            SafeERC20.safeTransferFrom(asset, msg.sender, address(this), amount);
        }

        transferIn(state, asset, BalancePath.getCommonPath(msg.sender), amount);
        Events.logDeposit(msg.sender, asset, amount);

        return depositedEtherAmount;
    }

    function withdraw(
        Store.State storage state,
        address user,
        address asset,
        uint256 amount
    )
        internal
    {

        require(state.balances[user][asset] >= amount, "BALANCE_NOT_ENOUGH");

        if (asset == Consts.ETHEREUM_TOKEN_ADDRESS()) {
            address payable payableUser = address(uint160(user));
            payableUser.transfer(amount);
        } else {
            SafeERC20.safeTransfer(asset, user, amount);
        }

        transferOut(state, asset, BalancePath.getCommonPath(user), amount);

        Events.logWithdraw(user, asset, amount);
    }

    function balanceOf(
        Store.State storage state,
        Types.BalancePath memory balancePath,
        address asset
    )
        internal
        view
        returns (uint256)
    {

        mapping(address => uint256) storage balances = balancePath.getBalances(state);
        return balances[asset];
    }

    function transfer(
        Store.State storage state,
        address asset,
        Types.BalancePath memory fromBalancePath,
        Types.BalancePath memory toBalancePath,
        uint256 amount
    )
        internal
    {


        Requires.requirePathMarketIDAssetMatch(state, fromBalancePath, asset);
        Requires.requirePathMarketIDAssetMatch(state, toBalancePath, asset);

        mapping(address => uint256) storage fromBalances = fromBalancePath.getBalances(state);
        mapping(address => uint256) storage toBalances = toBalancePath.getBalances(state);

        require(fromBalances[asset] >= amount, "TRANSFER_BALANCE_NOT_ENOUGH");

        fromBalances[asset] = fromBalances[asset] - amount;
        toBalances[asset] = toBalances[asset].add(amount);
    }

    function transferIn(
        Store.State storage state,
        address asset,
        Types.BalancePath memory path,
        uint256 amount
    )
        internal
    {

        mapping(address => uint256) storage balances = path.getBalances(state);
        balances[asset] = balances[asset].add(amount);
        state.cash[asset] = state.cash[asset].add(amount);
    }

    function transferOut(
        Store.State storage state,
        address asset,
        Types.BalancePath memory path,
        uint256 amount
    )
        internal
    {

        mapping(address => uint256) storage balances = path.getBalances(state);
        balances[asset] = balances[asset].sub(amount);
        state.cash[asset] = state.cash[asset].sub(amount);
    }
}

library Types {

    enum AuctionStatus {
        InProgress,
        Finished
    }

    enum CollateralAccountStatus {
        Normal,
        Liquid
    }

    enum OrderStatus {
        EXPIRED,
        CANCELLED,
        FILLABLE,
        FULLY_FILLED
    }

    struct Signature {
        bytes32 config;
        bytes32 r;
        bytes32 s;
    }

    enum BalanceCategory {
        Common,
        CollateralAccount
    }

    struct BalancePath {
        BalanceCategory category;
        uint16          marketID;
        address         user;
    }

    struct Asset {
        ILendingPoolToken  lendingPoolToken;
        IPriceOracle      priceOracle;
        IInterestModel    interestModel;
    }

    struct Market {
        address baseAsset;
        address quoteAsset;

        uint256 liquidateRate;

        uint256 withdrawRate;

        uint256 auctionRatioStart;
        uint256 auctionRatioPerBlock;

        bool borrowEnable;
    }

    struct CollateralAccount {
        uint32 id;
        uint16 marketID;
        CollateralAccountStatus status;
        address owner;

        mapping(address => uint256) balances;
    }

    struct CollateralAccountDetails {
        bool       liquidatable;
        CollateralAccountStatus status;
        uint256    debtsTotalUSDValue;
        uint256    balancesTotalUSDValue;
    }

    struct Auction {
        uint32 id;
        AuctionStatus status;

        uint32 startBlockNumber;

        uint16 marketID;

        address borrower;
        address initiator;

        address debtAsset;
        address collateralAsset;
    }

    struct AuctionDetails {
        address borrower;
        uint16  marketID;
        address debtAsset;
        address collateralAsset;
        uint256 leftDebtAmount;
        uint256 leftCollateralAmount;
        uint256 ratio;
        uint256 price;
        bool    finished;
    }

    struct Order {
        address trader;
        address relayer;
        address baseAsset;
        address quoteAsset;
        uint256 baseAssetAmount;
        uint256 quoteAssetAmount;
        uint256 gasTokenAmount;

        bytes32 data;
    }

    struct OrderParam {
        address trader;
        uint256 baseAssetAmount;
        uint256 quoteAssetAmount;
        uint256 gasTokenAmount;
        bytes32 data;
        Signature signature;
    }


    struct OrderAddressSet {
        address baseAsset;
        address quoteAsset;
        address relayer;
    }

    struct MatchResult {
        address maker;
        address taker;
        address buyer;
        uint256 makerFee;
        uint256 makerRebate;
        uint256 takerFee;
        uint256 makerGasFee;
        uint256 takerGasFee;
        uint256 baseAssetFilledAmount;
        uint256 quoteAssetFilledAmount;
        BalancePath makerBalancePath;
        BalancePath takerBalancePath;
    }
    struct MatchParams {
        OrderParam       takerOrderParam;
        OrderParam[]     makerOrderParams;
        uint256[]        baseAssetFilledAmounts;
        OrderAddressSet  orderAddressSet;
    }
}

library Auction {

    using SafeMath for uint256;

    function ratio(
        Types.Auction memory auction,
        Store.State storage state
    )
        internal
        view
        returns (uint256)
    {

        uint256 increasedRatio = (block.number - auction.startBlockNumber).mul(state.markets[auction.marketID].auctionRatioPerBlock);
        uint256 initRatio = state.markets[auction.marketID].auctionRatioStart;
        uint256 totalRatio = initRatio.add(increasedRatio);
        return totalRatio;
    }
}

library BalancePath {


    function getBalances(
        Types.BalancePath memory path,
        Store.State storage state
    )
        internal
        view
        returns (mapping(address => uint256) storage)
    {

        if (path.category == Types.BalanceCategory.Common) {
            return state.balances[path.user];
        } else {
            return state.accounts[path.user][path.marketID].balances;
        }
    }

    function getCommonPath(
        address user
    )
        internal
        pure
        returns (Types.BalancePath memory)
    {

        return Types.BalancePath({
            user: user,
            category: Types.BalanceCategory.Common,
            marketID: 0
        });
    }

    function getMarketPath(
        address user,
        uint16 marketID
    )
        internal
        pure
        returns (Types.BalancePath memory)
    {

        return Types.BalancePath({
            user: user,
            category: Types.BalanceCategory.CollateralAccount,
            marketID: marketID
        });
    }
}

library Order {


    bytes32 public constant EIP712_ORDER_TYPE = keccak256(
        abi.encodePacked(
            "Order(address trader,address relayer,address baseAsset,address quoteAsset,uint256 baseAssetAmount,uint256 quoteAssetAmount,uint256 gasTokenAmount,bytes32 data)"
        )
    );

    function getHash(
        Types.Order memory order
    )
        internal
        pure
        returns (bytes32 orderHash)
    {

        orderHash = EIP712.hashMessage(_hashContent(order));
        return orderHash;
    }

    function _hashContent(
        Types.Order memory order
    )
        internal
        pure
        returns (bytes32 result)
    {


        bytes32 orderType = EIP712_ORDER_TYPE;

        assembly {
            let start := sub(order, 32)
            let tmp := mload(start)

            mstore(start, orderType)
            result := keccak256(start, 288)

            mstore(start, tmp)
        }

        return result;
    }
}

library OrderParam {


    function getOrderVersion(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (uint256)
    {

        return uint256(uint8(byte(order.data)));
    }

    function getExpiredAtFromOrderData(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (uint256)
    {

        return uint256(uint40(bytes5(order.data << (8*3))));
    }

    function isSell(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (bool)
    {

        return uint8(order.data[1]) == 1;
    }

    function isMarketOrder(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (bool)
    {

        return uint8(order.data[2]) == 1;
    }

    function isMakerOnly(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (bool)
    {

        return uint8(order.data[22]) == 1;
    }

    function isMarketBuy(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (bool)
    {

        return !isSell(order) && isMarketOrder(order);
    }

    function getAsMakerFeeRateFromOrderData(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (uint256)
    {

        return uint256(uint16(bytes2(order.data << (8*8))));
    }

    function getAsTakerFeeRateFromOrderData(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (uint256)
    {

        return uint256(uint16(bytes2(order.data << (8*10))));
    }

    function getMakerRebateRateFromOrderData(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (uint256)
    {

        uint256 makerRebate = uint256(uint16(bytes2(order.data << (8*12))));

        return SafeMath.min(makerRebate, Consts.REBATE_RATE_BASE());
    }

    function getBalancePathFromOrderData(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (Types.BalancePath memory)
    {

        Types.BalanceCategory category;
        uint16 marketID;

        if (byte(order.data << (8*23)) == "\x01") {
            category = Types.BalanceCategory.CollateralAccount;
            marketID = uint16(bytes2(order.data << (8*24)));
        } else {
            category = Types.BalanceCategory.Common;
            marketID = 0;
        }

        return Types.BalancePath({
            user: order.trader,
            category: category,
            marketID: marketID
        });
    }
}