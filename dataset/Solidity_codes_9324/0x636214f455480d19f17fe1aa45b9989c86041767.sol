



pragma solidity >=0.4.23;

contract DSNote {

    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint256           wad,
        bytes             fax
    ) anonymous;

    modifier note {

        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue()
        }

        _;

        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);
    }
}

pragma solidity >=0.5.15 <0.6.0;


contract Auth is DSNote {

    mapping (address => uint) public wards;
    function rely(address usr) public auth note { wards[usr] = 1; }

    function deny(address usr) public auth note { wards[usr] = 0; }

    modifier auth { require(wards[msg.sender] == 1); _; }

}

pragma solidity >=0.5.15 <0.6.0;

contract Math {

    uint256 constant ONE = 10 ** 27;

    function safeAdd(uint x, uint y) public pure returns (uint z) {

        require((z = x + y) >= x, "safe-add-failed");
    }

    function safeSub(uint x, uint y) public pure returns (uint z) {

        require((z = x - y) <= x, "safe-sub-failed");
    }

    function safeMul(uint x, uint y) public pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "safe-mul-failed");
    }

    function safeDiv(uint x, uint y) public pure returns (uint z) {

        z = x / y;
    }

    function rmul(uint x, uint y) public pure returns (uint z) {

        z = safeMul(x, y) / ONE;
    }

    function rdiv(uint x, uint y) public pure returns (uint z) {

        require(y > 0, "division by zero");
        z = safeAdd(safeMul(x, ONE), y / 2) / y;
    }

    function rdivup(uint x, uint y) internal pure returns (uint z) {

        require(y > 0, "division by zero");
        z = safeAdd(safeMul(x, ONE), safeSub(y, 1)) / y;
    }


}

pragma solidity >=0.5.15 <0.6.0;

contract FixedPoint {

    struct Fixed27 {
        uint value;
    }
}

pragma solidity >=0.5.15 <0.6.0;
pragma experimental ABIEncoderV2;


interface ERC20Like {

    function balanceOf(address) external view returns (uint);

    function transferFrom(address, address, uint) external returns (bool);

    function mint(address, uint) external;

    function burn(address, uint) external;

    function totalSupply() external view returns (uint);

    function approve(address usr, uint amount) external;

}

interface ReserveLike {

    function deposit(uint amount) external;

    function payout(uint amount) external;

    function totalBalanceAvailable() external returns (uint);

}

interface EpochTickerLike {

    function currentEpoch() external view returns (uint);

    function lastEpochExecuted() external view returns(uint);

}

contract Tranche is Math, Auth, FixedPoint {

    mapping(uint => Epoch) public epochs;

    struct Epoch {
        Fixed27 redeemFulfillment;
        Fixed27 supplyFulfillment;
        Fixed27 tokenPrice;
    }

    struct UserOrder {
        uint orderedInEpoch;
        uint supplyCurrencyAmount;
        uint redeemTokenAmount;
    }

    mapping(address => UserOrder) public users;

    uint public  totalSupply;
    uint public  totalRedeem;

    ERC20Like public currency;
    ERC20Like public token;
    ReserveLike public reserve;
    EpochTickerLike public epochTicker;

    uint public requestedCurrency;
    address self;

    bool public waitingForUpdate = false;

    modifier orderAllowed(address usr) {

        require((users[usr].supplyCurrencyAmount == 0 && users[usr].redeemTokenAmount == 0)
        || users[usr].orderedInEpoch == epochTicker.currentEpoch(), "disburse required");
        _;
    }

    constructor(address currency_, address token_) public {
        wards[msg.sender] = 1;
        token = ERC20Like(token_);
        currency = ERC20Like(currency_);
        self = address(this);
    }

    function balance() external view returns (uint) {

        return currency.balanceOf(self);
    }

    function tokenSupply() external view returns (uint) {

        return token.totalSupply();
    }

    function depend(bytes32 contractName, address addr) public auth {

        if (contractName == "token") {token = ERC20Like(addr);}
        else if (contractName == "currency") {currency = ERC20Like(addr);}
        else if (contractName == "reserve") {reserve = ReserveLike(addr);}
        else if (contractName == "epochTicker") {epochTicker = EpochTickerLike(addr);}
        else revert();
    }

    function supplyOrder(address usr, uint newSupplyAmount) public auth orderAllowed(usr) {

        users[usr].orderedInEpoch = epochTicker.currentEpoch();

        uint currentSupplyAmount = users[usr].supplyCurrencyAmount;

        users[usr].supplyCurrencyAmount = newSupplyAmount;

        totalSupply = safeAdd(safeTotalSub(totalSupply, currentSupplyAmount), newSupplyAmount);

        if (newSupplyAmount > currentSupplyAmount) {
            uint delta = safeSub(newSupplyAmount, currentSupplyAmount);
            require(currency.transferFrom(usr, self, delta), "currency-transfer-failed");
            return;
        }
        uint delta = safeSub(currentSupplyAmount, newSupplyAmount);
        if (delta > 0) {
            _safeTransfer(currency, usr, delta);
        }
    }

    function redeemOrder(address usr, uint newRedeemAmount) public auth orderAllowed(usr) {

        users[usr].orderedInEpoch = epochTicker.currentEpoch();

        uint currentRedeemAmount = users[usr].redeemTokenAmount;
        users[usr].redeemTokenAmount = newRedeemAmount;
        totalRedeem = safeAdd(safeTotalSub(totalRedeem, currentRedeemAmount), newRedeemAmount);

        if (newRedeemAmount > currentRedeemAmount) {
            uint delta = safeSub(newRedeemAmount, currentRedeemAmount);
            require(token.transferFrom(usr, self, delta), "token-transfer-failed");
            return;
        }

        uint delta = safeSub(currentRedeemAmount, newRedeemAmount);
        if (delta > 0) {
            _safeTransfer(token, usr, delta);
        }
    }

    function calcDisburse(address usr) public view returns(uint payoutCurrencyAmount, uint payoutTokenAmount, uint remainingSupplyCurrency, uint remainingRedeemToken) {

        return calcDisburse(usr, epochTicker.lastEpochExecuted());
    }

    function calcDisburse(address usr, uint endEpoch) public view returns(uint payoutCurrencyAmount, uint payoutTokenAmount, uint remainingSupplyCurrency, uint remainingRedeemToken) {

        uint epochIdx = users[usr].orderedInEpoch;
        uint lastEpochExecuted = epochTicker.lastEpochExecuted();

        if (users[usr].orderedInEpoch == epochTicker.currentEpoch()) {
            return (payoutCurrencyAmount, payoutTokenAmount, users[usr].supplyCurrencyAmount, users[usr].redeemTokenAmount);
        }

        if (endEpoch > lastEpochExecuted) {
            endEpoch = lastEpochExecuted;
        }

        remainingSupplyCurrency = users[usr].supplyCurrencyAmount;
        remainingRedeemToken = users[usr].redeemTokenAmount;
        uint amount = 0;

        while(epochIdx <= endEpoch && (remainingSupplyCurrency != 0 || remainingRedeemToken != 0 )){
            if(remainingSupplyCurrency != 0) {
                amount = rmul(remainingSupplyCurrency, epochs[epochIdx].supplyFulfillment.value);
                if (amount != 0) {
                    payoutTokenAmount = safeAdd(payoutTokenAmount, safeDiv(safeMul(amount, ONE), epochs[epochIdx].tokenPrice.value));
                    remainingSupplyCurrency = safeSub(remainingSupplyCurrency, amount);
                }
            }

            if(remainingRedeemToken != 0) {
                amount = rmul(remainingRedeemToken, epochs[epochIdx].redeemFulfillment.value);
                if (amount != 0) {
                    payoutCurrencyAmount = safeAdd(payoutCurrencyAmount, rmul(amount, epochs[epochIdx].tokenPrice.value));
                    remainingRedeemToken = safeSub(remainingRedeemToken, amount);
                }
            }
            epochIdx = safeAdd(epochIdx, 1);
        }

        return (payoutCurrencyAmount, payoutTokenAmount, remainingSupplyCurrency, remainingRedeemToken);
    }

    function disburse(address usr) public auth returns (uint payoutCurrencyAmount, uint payoutTokenAmount, uint remainingSupplyCurrency, uint remainingRedeemToken) {

        return disburse(usr, epochTicker.lastEpochExecuted());
    }

    function _safeTransfer(ERC20Like erc20, address usr, uint amount) internal returns(uint) {

        uint max = erc20.balanceOf(self);
        if(amount > max) {
            amount = max;
        }
        require(erc20.transferFrom(self, usr, amount), "token-transfer-failed");
        return amount;
    }

    function disburse(address usr,  uint endEpoch) public auth returns (uint payoutCurrencyAmount, uint payoutTokenAmount, uint remainingSupplyCurrency, uint remainingRedeemToken) {

        require(users[usr].orderedInEpoch <= epochTicker.lastEpochExecuted(), "epoch-not-executed-yet");

        uint lastEpochExecuted = epochTicker.lastEpochExecuted();

        if (endEpoch > lastEpochExecuted) {
            endEpoch = lastEpochExecuted;
        }

        (payoutCurrencyAmount, payoutTokenAmount,
        remainingSupplyCurrency, remainingRedeemToken) = calcDisburse(usr, endEpoch);
        users[usr].supplyCurrencyAmount = remainingSupplyCurrency;
        users[usr].redeemTokenAmount = remainingRedeemToken;
        users[usr].orderedInEpoch = safeAdd(endEpoch, 1);


        if (payoutCurrencyAmount > 0) {
            payoutCurrencyAmount = _safeTransfer(currency, usr, payoutCurrencyAmount);
        }

        if (payoutTokenAmount > 0) {
            payoutTokenAmount = _safeTransfer(token, usr, payoutTokenAmount);
        }
        return (payoutCurrencyAmount, payoutTokenAmount, remainingSupplyCurrency, remainingRedeemToken);
    }


    function epochUpdate(uint epochID, uint supplyFulfillment_, uint redeemFulfillment_, uint tokenPrice_, uint epochSupplyOrderCurrency, uint epochRedeemOrderCurrency) public auth {

        require(waitingForUpdate == true);
        waitingForUpdate = false;

        epochs[epochID].supplyFulfillment.value = supplyFulfillment_;
        epochs[epochID].redeemFulfillment.value = redeemFulfillment_;
        epochs[epochID].tokenPrice.value = tokenPrice_;

        uint redeemInToken = 0;
        uint supplyInToken = 0;
        if(tokenPrice_ > 0) {
            supplyInToken = rdiv(epochSupplyOrderCurrency, tokenPrice_);
            redeemInToken = safeDiv(safeMul(epochRedeemOrderCurrency, ONE), tokenPrice_);
        }

        adjustTokenBalance(epochID, supplyInToken, redeemInToken);
        adjustCurrencyBalance(epochID, epochSupplyOrderCurrency, epochRedeemOrderCurrency);

        totalSupply = safeAdd(safeTotalSub(totalSupply, epochSupplyOrderCurrency), rmul(epochSupplyOrderCurrency, safeSub(ONE, epochs[epochID].supplyFulfillment.value)));
        totalRedeem = safeAdd(safeTotalSub(totalRedeem, redeemInToken), rmul(redeemInToken, safeSub(ONE, epochs[epochID].redeemFulfillment.value)));
    }
    function closeEpoch() public auth returns (uint totalSupplyCurrency_, uint totalRedeemToken_) {

        require(waitingForUpdate == false);
        waitingForUpdate = true;
        return (totalSupply, totalRedeem);
    }

    function safeBurn(uint tokenAmount) internal {

        uint max = token.balanceOf(self);
        if(tokenAmount > max) {
            tokenAmount = max;
        }
        token.burn(self, tokenAmount);
    }

    function safePayout(uint currencyAmount) internal returns(uint payoutAmount) {

        uint max = reserve.totalBalanceAvailable();

        if(currencyAmount > max) {
            currencyAmount = max;
        }
        reserve.payout(currencyAmount);
        return currencyAmount;
    }

    function payoutRequestedCurrency() public {

        if(requestedCurrency > 0) {
            uint payoutAmount = safePayout(requestedCurrency);
            requestedCurrency = safeSub(requestedCurrency, payoutAmount);
        }
    }
    function adjustTokenBalance(uint epochID, uint epochSupplyToken, uint epochRedeemToken) internal {


        uint mintAmount = 0;
        if (epochs[epochID].tokenPrice.value > 0) {
            mintAmount = rmul(epochSupplyToken, epochs[epochID].supplyFulfillment.value);
        }

        uint burnAmount = rmul(epochRedeemToken, epochs[epochID].redeemFulfillment.value);
        if (burnAmount > mintAmount) {
            uint diff = safeSub(burnAmount, mintAmount);
            safeBurn(diff);
            return;
        }
        uint diff = safeSub(mintAmount, burnAmount);
        if (diff > 0) {
            token.mint(self, diff);
        }
    }

    function mint(address usr, uint amount) public auth {

        token.mint(usr, amount);
    }

    function adjustCurrencyBalance(uint epochID, uint epochSupply, uint epochRedeem) internal {

        uint currencySupplied = rmul(epochSupply, epochs[epochID].supplyFulfillment.value);
        uint currencyRequired = rmul(epochRedeem, epochs[epochID].redeemFulfillment.value);

        if (currencySupplied > currencyRequired) {
            uint diff = safeSub(currencySupplied, currencyRequired);
            currency.approve(address(reserve), diff);
            reserve.deposit(diff);
            return;
        }
        uint diff = safeSub(currencyRequired, currencySupplied);
        if (diff > 0) {
            uint payoutAmount = safePayout(diff);
            if(payoutAmount < diff) {
                requestedCurrency = safeAdd(requestedCurrency, safeSub(diff, payoutAmount));
            }
        }
    }

    function authTransfer(address erc20, address usr, uint amount) public auth {

        ERC20Like(erc20).transferFrom(self, usr, amount);
    }

    function safeTotalSub(uint total, uint amount) internal returns (uint) {

        if (total < amount) {
            return 0;
        }
        return safeSub(total, amount);
    }
}

pragma solidity >=0.5.15 <0.6.0;


contract Interest is Math {

    function compounding(uint chi, uint ratePerSecond, uint lastUpdated, uint pie) public view returns (uint, uint) {

        require(block.timestamp >= lastUpdated, "tinlake-math/invalid-timestamp");
        require(chi != 0);
        uint updatedChi = _chargeInterest(chi ,ratePerSecond, lastUpdated, block.timestamp);
        return (updatedChi, safeSub(rmul(updatedChi, pie), rmul(chi, pie)));
    }

    function chargeInterest(uint interestBearingAmount, uint ratePerSecond, uint lastUpdated) public view returns (uint) {

        if (block.timestamp >= lastUpdated) {
            interestBearingAmount = _chargeInterest(interestBearingAmount, ratePerSecond, lastUpdated, block.timestamp);
        }
        return interestBearingAmount;
    }

    function _chargeInterest(uint interestBearingAmount, uint ratePerSecond, uint lastUpdated, uint current) internal pure returns (uint) {

        return rmul(rpow(ratePerSecond, current - lastUpdated, ONE), interestBearingAmount);
    }


    function toAmount(uint chi, uint pie) public pure returns (uint) {

        return rmul(pie, chi);
    }

    function toPie(uint chi, uint amount) public pure returns (uint) {

        return rdivup(amount, chi);
    }

    function rpow(uint x, uint n, uint base) public pure returns (uint z) {

        assembly {
            switch x case 0 {switch n case 0 {z := base} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := base } default { z := x }
                let half := div(base, 2)  // for rounding.
                for { n := div(n, 2) } n { n := div(n,2) } {
                let xx := mul(x, x)
                if iszero(eq(div(xx, x), x)) { revert(0,0) }
                let xxRound := add(xx, half)
                if lt(xxRound, xx) { revert(0,0) }
                x := div(xxRound, base)
                if mod(n,2) {
                    let zx := mul(z, x)
                    if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                    let zxRound := add(zx, half)
                    if lt(zxRound, zx) { revert(0,0) }
                    z := div(zxRound, base)
                }
            }
            }
        }
    }
}
