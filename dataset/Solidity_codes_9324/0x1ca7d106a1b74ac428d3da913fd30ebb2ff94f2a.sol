



pragma experimental ABIEncoderV2;
pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }



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



    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract ERC20Detailed is IERC20 {
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
contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }



    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");


        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");


        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


}





contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public virtual {

        _burn(_msgSender(), amount);
    }

}


pragma solidity ^0.6.0;

interface IRouter {

    function f(uint id, bytes32 k) external view returns (address);

    function defaultDataContract(uint id) external view returns (address);

    function bondNr() external view returns (uint);

    function setBondNr(uint _bondNr) external;


    function setDefaultContract(uint id, address data) external;

    function addField(uint id, bytes32 field, address data) external;

}


pragma solidity ^0.6.0;

    enum BondStage {
        DefaultStage,
        RiskRating,
        RiskRatingFail,
        CrowdFunding,
        CrowdFundingSuccess,
        CrowdFundingFail,
        UnRepay,//待还款
        RepaySuccess,
        Overdue,
        DebtClosed
    }

    enum IssuerStage {
        DefaultStage,
		UnWithdrawCrowd,
        WithdrawCrowdSuccess,
		UnWithdrawPawn,
        WithdrawPawnSuccess       
    }



pragma solidity ^0.6.0;


interface IBondData {

    struct what {
        address proposal;
        uint256 weight;
    }

    struct prwhat {
        address who;
        address proposal;
        uint256 reason;
    }

    struct Balance {

        uint256 amountGive;
        uint256 amountGet;
    }

    function issuer() external view returns (address);


    function collateralToken() external view returns (address);


    function crowdToken() external view returns (address);


    function getBorrowAmountGive() external view returns (uint256);




    function getSupplyAmount(address who) external view returns (uint256);



    function par() external view returns (uint256);


    function mintBond(address who, uint256 amount) external;


    function burnBond(address who, uint256 amount) external;



    function transferableAmount() external view returns (uint256);


    function debt() external view returns (uint256);


    function actualBondIssuance() external view returns (uint256);


    function couponRate() external view returns (uint256);


    function depositMultiple() external view returns (uint256);


    function discount() external view returns (uint256);



    function voteExpired() external view returns (uint256);



    function investExpired() external view returns (uint256);


    function totalBondIssuance() external view returns (uint256);


    function maturity() external view returns (uint256);


    function config() external view returns (address);


    function weightOf(address who) external view returns (uint256);


    function totalWeight() external view returns (uint256);


    function bondExpired() external view returns (uint256);


    function interestBearingPeriod() external;



    function bondStage() external view returns (uint256);


    function issuerStage() external view returns (uint256);


    function issueFee() external view returns (uint256);



    function totalInterest() external view returns (uint256);


    function gracePeriod() external view returns (uint256);


    function liability() external view returns (uint256);


    function remainInvestAmount() external view returns (uint256);


    function supplyMap(address) external view returns (Balance memory);



    function balanceOf(address account) external view returns (uint256);


    function setPar(uint256) external;


    function liquidateLine() external view returns (uint256);


    function setBondParam(bytes32 k, uint256 v) external;


    function setBondParamAddress(bytes32 k, address v) external;


    function minIssueRatio() external view returns (uint256);


    function partialLiquidateAmount() external view returns (uint256);


    function votes(address who) external view returns (what memory);


    function setVotes(address who, address proposal, uint256 amount) external;


    function weights(address proposal) external view returns (uint256);


    function setBondParamMapping(bytes32 name, address k, uint256 v) external;


    function top() external view returns (address);



    function voteLedger(address who) external view returns (uint256);


    function totalWeights() external view returns (uint256);



    function setPr(address who, address proposal, uint256 reason) external;


    function pr() external view returns (prwhat memory);


    function fee() external view returns (uint256);


    function profits(address who) external view returns (uint256);




    function totalProfits() external view returns (uint256);


    function originLiability() external view returns (uint256);


    function liquidating() external view returns (bool);

    function setLiquidating(bool _liquidating) external;


    function sysProfit() external view returns (uint256);

    function totalFee() external view returns (uint256);

}


//pragma experimental ABIEncoderV2;
pragma solidity ^0.6.0;





interface IERC20Detailed {

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

}

interface IOracle {

    function get(address t) external view returns (uint, bool);

}

contract CoreUtils {

    using SafeMath for uint256;

    address public router;
    address public oracle;

    constructor (address _router, address _oracle) public {
        router = _router;
        oracle = _oracle;
    }

    function d(uint256 id) public view returns (address) {

        return IRouter(router).defaultDataContract(id);
    }

    function bondData(uint256 id) public view returns (IBondData) {

        return IBondData(d(id));
    }

    function calcPrincipalAndInterest(uint256 principal, uint256 couponRate)
        public
        pure
        returns (uint256)
    {

        uint256 _1 = 1 ether;
        return principal.mul(_1.add(couponRate)).div(_1);
    }

    function transferableAmount(uint256 id) external view returns (uint256) {

        IBondData b = bondData(id);
        uint256 baseDec = 18;
        uint256 delta = baseDec.sub(
            uint256(ERC20Detailed(b.crowdToken()).decimals())
        );
        uint256 _1 = 1 ether;
        return
            b.actualBondIssuance().mul(b.par()).mul((_1).sub(b.issueFee())).div(
                10**delta
            );
    }

    function debt(uint256 id) public view returns (uint256) {

        IBondData b = bondData(id);
        uint256 crowdDec = ERC20Detailed(b.crowdToken()).decimals();
        return b.actualBondIssuance().mul(b.par()).mul(10**crowdDec);
    }

    function totalInterest(uint256 id) external view returns (uint256) {

        IBondData b = bondData(id);
        uint256 crowdDec = ERC20Detailed(b.crowdToken()).decimals();
        return
            b
                .actualBondIssuance()
                .mul(b.par())
                .mul(10**crowdDec)
                .mul(b.couponRate())
                .div(1e18);
    }

    function debtPlusTotalInterest(uint256 id) public view returns (uint256) {

        IBondData b = bondData(id);
        uint256 crowdDec = ERC20Detailed(b.crowdToken()).decimals();
        uint256 _1 = 1 ether;
        return
            b
                .actualBondIssuance()
                .mul(b.par())
                .mul(10**crowdDec)
                .mul(_1.add(b.couponRate()))
                .div(1e18);
    }

    function CollateralDecimal(uint256 id) public view returns (uint256) {

        IBondData b = bondData(id);
        if (b.collateralToken() == address(0)) return 18;//ETH
        if (keccak256(abi.encodePacked(IERC20Detailed(b.collateralToken()).symbol())) == keccak256(abi.encodePacked(string("BAT")))) return 18;
        return ERC20Detailed(b.collateralToken()).decimals();
    }

    function remainInvestAmount(uint256 id) external view returns (uint256) {

        IBondData b = bondData(id);

        uint256 crowdDec = ERC20Detailed(b.crowdToken()).decimals();
        return
            b.totalBondIssuance().div(10**crowdDec).div(b.par()).sub(
                b.actualBondIssuance()
            );
    }

        function calcMinCollateralTokenAmount(uint256 id)
        external
        view
        returns (uint256)
    {

        IBondData b = bondData(id);
        uint256 CollateralDec = CollateralDecimal(id);
        uint256 crowdDec = ERC20Detailed(b.crowdToken()).decimals();//18

        uint256 unit = 10 ** (crowdDec.add(18).sub(CollateralDec));



        return
            b
                .totalBondIssuance()
                .mul(b.depositMultiple())
                .mul(crowdPrice(id))
                .div(pawnPrice(id))
                .div(unit);
    }

    function pawnBalanceInUsd(uint256 id) public view returns (uint256) {

        IBondData b = bondData(id);

        uint256 unitPawn = 10 **
            uint256(CollateralDecimal(id));
        uint256 pawnUsd = pawnPrice(id).mul(b.getBorrowAmountGive()).div(unitPawn); //1e18
        return pawnUsd;
    }

    function disCountPawnBalanceInUsd(uint256 id)
        public
        view
        returns (uint256)
    {

        uint256 _1 = 1 ether;
        IBondData b = bondData(id);

        return pawnBalanceInUsd(id).mul(b.discount()).div(_1);
    }

    function crowdBalanceInUsd(uint256 id) public view returns (uint256) {

        IBondData b = bondData(id);

        uint256 unitCrowd = 10 **
            uint256(ERC20Detailed(b.crowdToken()).decimals());
        return crowdPrice(id).mul(b.liability()).div(unitCrowd);
    }

    function isInsolvency(uint256 id) public view returns (bool) {

        return disCountPawnBalanceInUsd(id) < crowdBalanceInUsd(id);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a <= b ? a : b;
    }

    function pawnPrice(uint256 id) public view returns (uint256) {

        IBondData b = bondData(id);

        (uint256 price, bool pawnPriceOk) = IOracle(oracle).get(b.collateralToken());
        require(pawnPriceOk, "invalid pawn price");
        return price;
    }

    function crowdPrice(uint256 id) public view returns (uint256) {

        IBondData b = bondData(id);

        (uint256 price, bool crowdPriceOk) = IOracle(oracle).get(b.crowdToken());
        require(crowdPriceOk, "invalid crowd price");
        return price;
    }

    function X(uint256 id) public view returns (uint256 res) {

        IBondData b = bondData(id);

        if (!isUnsafe(id)) {
            return 0;
        }

        if (isInsolvency(id)) {
            return b.getBorrowAmountGive();
        }

        if (now >= b.bondExpired().add(b.gracePeriod())) {
            return calcLiquidatePawnAmount(id);
        }

        uint256 _1 = 1 ether;
        uint256 price = pawnPrice(id); //1e18
        uint256 pawnUsd = pawnBalanceInUsd(id);
        uint256 debtUsd = crowdBalanceInUsd(id).mul(b.depositMultiple()).div(_1);

        uint256 gap = pawnUsd >= debtUsd
            ? pawnUsd.sub(debtUsd)
            : debtUsd.sub(pawnUsd);
        uint256 pcrXdis = b.depositMultiple().mul(b.discount()).div(_1); //1e18
        require(pcrXdis != _1, "PCR*Discout == 1 error");
        pcrXdis = pawnUsd >= debtUsd ? _1.sub(pcrXdis) : pcrXdis.sub(_1);
        uint256 denominator = price.mul(pcrXdis).div(_1); //1e18
        uint256 unitPawn = 10 **
            uint256(CollateralDecimal(id));
        res = gap.mul(unitPawn).div(denominator); //1e18/1e18*1e18 == 1e18

        res = min(res, b.getBorrowAmountGive());
    }

    function Y(uint256 id) public view returns (uint256 res) {

        IBondData b = bondData(id);

        if (!isUnsafe(id)) {
            return 0;
        }

        uint256 _1 = 1 ether;
        uint256 unitPawn = 10 **
            uint256(CollateralDecimal(id));
        uint256 xp = X(id).mul(pawnPrice(id)).div(unitPawn);
        xp = xp.mul(b.discount()).div(_1);

        uint256 unitCrowd = 10 **
            uint256(ERC20Detailed(b.crowdToken()).decimals());
        res = xp.mul(unitCrowd).div(crowdPrice(id));

        res = min(res, b.liability());
    }

    function calcLiquidatePawnAmount(uint256 id) public view returns (uint256) {

        IBondData b = bondData(id);
        return calcLiquidatePawnAmount(id, b.liability());
    }
    
    function ceil(uint256 a, uint256 m) public pure returns (uint256) {

        return (a.add(m).sub(1)).div(m).mul(m);
    }
    
    function precision(uint256 id) public view returns (uint256) {

        IBondData b = bondData(id);

        uint256 decCrowd = uint256(ERC20Detailed(b.crowdToken()).decimals());
        uint256 decPawn = uint256(CollateralDecimal(id));

        if (decPawn != decCrowd) {
            return 10 ** (abs(decPawn, decCrowd).add(1));
        }

        return 10;
    }
    
    function ceilPawn(uint256 id, uint256 a) public view returns (uint256) {

        IBondData b = bondData(id);
        
        uint256 decCrowd = uint256(ERC20Detailed(b.crowdToken()).decimals());
        uint256 decPawn = uint256(CollateralDecimal(id));
        
        if (decPawn != decCrowd) {
            a = ceil(a, 10 ** abs(decPawn, decCrowd).sub(1));
        } else {
            a = ceil(a, 10);
        }
        return a;
    }
    
    function calcLiquidatePawnAmount(uint256 id, uint256 liability) public view returns (uint256) {

        IBondData b = bondData(id);

        uint256 _crowdPrice = crowdPrice(id);
        uint256 _pawnPrice = pawnPrice(id);

        uint256 decPawn = uint256(CollateralDecimal(id));
        uint256 decCrowd = uint256(ERC20Detailed(b.crowdToken()).decimals());

        uint256 unit = 10 ** (decPawn.add(18).sub(decCrowd));


        uint256 x = liability
            .mul(_crowdPrice)
            .mul(unit)
            .div(_pawnPrice.mul(b.discount()));
        
        if (decPawn != decCrowd) {
            x = ceil(x, 10 ** abs(decPawn, decCrowd).sub(1));
        } else {
            x = ceil(x, 10);
        }
        
        x = min(x, b.getBorrowAmountGive());

        if (x < b.getBorrowAmountGive()) {
            if (abs(x, b.getBorrowAmountGive()) <= precision(id)) {
                x = b.getBorrowAmountGive();//资不抵债情况
            }
        }

        return x;
    }

    function investPrincipalWithInterest(uint256 id, address who)
        external
        view
        returns (uint256)
    {

        require(d(id) != address(0), "invalid address");

        IBondData bond = bondData(id);
        address give = bond.crowdToken();

        (uint256 supplyGive) = bond.getSupplyAmount(who);
        uint256 bondAmount = convert2BondAmount(
            address(bond),
            give,
            supplyGive
        );

        uint256 crowdDec = IERC20Detailed(bond.crowdToken()).decimals();

        uint256 unrepayAmount = bond.liability(); //未还的债务
        uint256 actualRepay;

        if (unrepayAmount == 0) {
            actualRepay = calcPrincipalAndInterest(
                bondAmount.mul(1e18),
                bond.couponRate()
            );
            actualRepay = actualRepay.mul(bond.par()).mul(10**crowdDec).div(
                1e18
            );
        } else {
            uint256 debtTotal = debtPlusTotalInterest(id);
            require(
                debtTotal >= unrepayAmount,
                "debtPlusTotalInterest < borrowGet, overflow"
            );
            actualRepay = debtTotal
                .sub(unrepayAmount)
                .mul(bondAmount)
                .div(bond.actualBondIssuance());
        }

        return actualRepay;
    }

    function convert2BondAmount(address b, address t, uint256 amount)
        public
        view
        returns (uint256)
    {

        IERC20Detailed erc20 = IERC20Detailed(t);
        uint256 dec = uint256(erc20.decimals());
        uint256 _par = IBondData(b).par();
        uint256 minAmount = _par.mul(10**dec);
        require(amount.mod(minAmount) == 0, "invalid amount"); //投资时，必须按份买

        return amount.div(minAmount);
    }

    function abs(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a >= b ? a.sub(b) : b.sub(a);
    }

    function convert2GiveAmount(uint256 id, uint256 bondAmount)
        external
        view
        returns (uint256)
    {

        IBondData b = bondData(id);

        ERC20Detailed erc20 = ERC20Detailed(b.crowdToken());
        uint256 dec = uint256(erc20.decimals());
        return bondAmount.mul(b.par()).mul(10**dec);
    }

    function isDepositMultipleUnsafe(uint256 id) external view returns (bool unsafe) {

        IBondData b = bondData(id);

        if (b.liability() == 0 || b.getBorrowAmountGive() == 0) {
            return false;
        }

        if (b.bondStage() == uint(BondStage.CrowdFundingSuccess)
            || b.bondStage() == uint(BondStage.UnRepay)
            || b.bondStage() == uint(BondStage.Overdue)) {

            if (now >= b.bondExpired().add(b.gracePeriod())) {
                return true;
            }

            uint256 _1 = 1 ether;
            uint256 crowdUsdxLeverage = crowdBalanceInUsd(id)
                .mul(b.depositMultiple())
                .div(1e36);

            
            uint256 _ceilPawn = ceilPawn(id, pawnBalanceInUsd(id));
            
            uint256 _crowdPrice = crowdPrice(id);
            uint256 decCrowd = uint256(ERC20Detailed(b.crowdToken()).decimals());
            uint256 minCrowdInUsd = _crowdPrice.div(10 ** decCrowd);
            
            unsafe = _ceilPawn < crowdUsdxLeverage;
            if (abs(_ceilPawn, crowdUsdxLeverage) <= minCrowdInUsd && _ceilPawn < crowdUsdxLeverage) {
                unsafe = false;
            }
            return unsafe;
        }
        
        return false;
    }

    function isDebtOpen(uint256 id) public view returns (bool) {

        IBondData b = bondData(id);
        uint256 decCrowd = uint256(ERC20Detailed(b.crowdToken()).decimals());
        uint256 _crowdPrice = crowdPrice(id);
        return b.liability().mul(_crowdPrice).div(10 ** decCrowd) > 1e15 && b.getBorrowAmountGive() == 0;
    }

    function isMinIssuanceCheckOK(uint256 id) public view returns (bool ok) {

        IBondData b = bondData(id);
        return b.totalBondIssuance().mul(b.minIssueRatio()).div(1e18) <= debt(id);
    }
    
    function isUnsafe(uint256 id) public view returns (bool unsafe) {

        IBondData b = bondData(id);
        uint256 decCrowd = uint256(ERC20Detailed(b.crowdToken()).decimals());
        uint256 _crowdPrice = crowdPrice(id);
        if (b.liability().mul(_crowdPrice).div(10 ** decCrowd) <= 1e15 || b.getBorrowAmountGive() == 0) {
            return false;
        }

        if (b.liquidating()) {
            return true;
        }

        if (b.bondStage() == uint(BondStage.CrowdFundingSuccess)
            || b.bondStage() == uint(BondStage.UnRepay)
            || b.bondStage() == uint(BondStage.Overdue)) {

            if (now >= b.bondExpired().add(b.gracePeriod())) {
                return true;
            }

            uint256 _1 = 1 ether;
            uint256 crowdUsdxLeverage = crowdBalanceInUsd(id)
                .mul(b.depositMultiple())
                .mul(b.liquidateLine())
                .div(1e36);

            
            uint256 _ceilPawn = ceilPawn(id, pawnBalanceInUsd(id));
            


            uint256 minCrowdInUsd = _crowdPrice.div(10 ** decCrowd);
            
            unsafe = _ceilPawn < crowdUsdxLeverage;
            if (abs(_ceilPawn, crowdUsdxLeverage) <= minCrowdInUsd && _ceilPawn < crowdUsdxLeverage) {
                unsafe = false;
            }
            return unsafe;
        }
        
        return false;
    }

    function getLiquidateAmount(uint id, uint y1) external view returns (uint256, uint256) {

        uint256 y2 = y1;//y2为实际清算额度
        uint256 y = Y(id);//y为剩余清算额度
        require(y1 <= y, "exceed max liquidate amount");

        IBondData b = bondData(id);

        uint decUnit = 10 ** uint(IERC20Detailed(b.crowdToken()).decimals());
        if (y <= b.partialLiquidateAmount()) {
            y2 = y;
        } else {
           require(y1 >= decUnit, "below min liquidate amount");//设置最小清算额度为1单位
        }
        uint256 x = calcLiquidatePawnAmount(id, y2);
        return (y2, x);
    }
}