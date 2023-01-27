

pragma experimental ABIEncoderV2;
pragma solidity ^0.6.0;


interface IRouter {

    function f(uint id, bytes32 k) external view returns (address);

    function defaultDataContract(uint id) external view returns (address);

    function bondNr() external view returns (uint);

    function setBondNr(uint _bondNr) external;


    function setDefaultContract(uint id, address data) external;

    function addField(uint id, bytes32 field, address data) external;

}

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


    function supportRedeem() external view returns (bool);

}

interface ICoreUtils {

    function d(uint256 id) external view returns (address);


    function bondData(uint256 id) external view returns (IBondData);


    function calcPrincipalAndInterest(uint256 principal, uint256 couponRate)
        external
        pure
        returns (uint256);


    function transferableAmount(uint256 id) external view returns (uint256);


    function debt(uint256 id) external view returns (uint256);


    function totalInterest(uint256 id) external view returns (uint256);


    function debtPlusTotalInterest(uint256 id) external view returns (uint256);


    function remainInvestAmount(uint256 id) external view returns (uint256);


        function calcMinCollateralTokenAmount(uint256 id)
        external
        view
        returns (uint256);

    function pawnBalanceInUsd(uint256 id) external view returns (uint256);


    function disCountPawnBalanceInUsd(uint256 id)
        external
        view
        returns (uint256);


    function crowdBalanceInUsd(uint256 id) external view returns (uint256);


    function isInsolvency(uint256 id) external view returns (bool);


    function pawnPrice(uint256 id) external view returns (uint256);


    function crowdPrice(uint256 id) external view returns (uint256);


    function X(uint256 id) external view returns (uint256 res);

    function Y(uint256 id) external view returns (uint256 res);


    function calcLiquidatePawnAmount(uint256 id) external view returns (uint256);

    function calcLiquidatePawnAmount(uint256 id, uint256 liability) external view returns (uint256);


    function investPrincipalWithInterest(uint256 id, address who)
        external
        view
        returns (uint256);


    function convert2BondAmount(address b, address t, uint256 amount)
        external
        view
        returns (uint256);


    function convert2GiveAmount(uint256 id, uint256 bondAmount)
        external
        view
        returns (uint256);

    
    function isUnsafe(uint256 id) external view returns (bool unsafe);

    function isDepositMultipleUnsafe(uint256 id) external view returns (bool unsafe);

    function getLiquidateAmount(uint id, uint y1) external view returns (uint256, uint256);

    function precision(uint256 id) external view returns (uint256);

    function isDebtOpen(uint256 id) external view returns (bool);

    function isMinIssuanceCheckOK(uint256 id) external view returns (bool ok);

}

interface IERC20Detailed {

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

}

interface IOracle {

    function get(address t) external view returns (uint, bool);

}

interface IConfig {

    function voteDuration() external view returns (uint256);


    function investDuration() external view returns (uint256);


    function discount(address token) external view returns (uint256);

    function depositMultiple(address token) external view returns (uint256);

    function liquidateLine(address token) external view returns (uint256);


    function gracePeriod() external view returns (uint256);

    function partialLiquidateAmount(address token) external view returns (uint256);

    function gov() external view returns(address);

    function ratingFeeRatio() external view returns (uint256);

}

interface IACL {

    function accessible(address from, address to, bytes4 sig)
        external
        view
        returns (bool);

}

contract Core {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public ACL;
    address public router;
    address public config;
    address public oracle;
    ICoreUtils public coreUtils;
    address public nameGen;

    modifier auth {

        IACL _ACL = IACL(ACL);
        require(_ACL.accessible(msg.sender, address(this), msg.sig), "core: access unauthorized");
        _;
    }

    constructor(
        address _ACL,
        address _router,
        address _config,
        address _coreUtils,
        address _oracle,
	    address _nameGen
    ) public {
        ACL = _ACL;
        router = _router;
        config = _config;
        coreUtils = ICoreUtils(_coreUtils);
        oracle = _oracle;
	    nameGen = _nameGen;
    }

    function setCoreParamAddress(bytes32 k, address v) external auth {

        if (k == bytes32("router")) {
            router = v;
            return;
        }
        if (k == bytes32("config")) {
            config = v;
            return;
        }
        if (k == bytes32("coreUtils")) {
            coreUtils = ICoreUtils(v);
            return;
        }
        if (k == bytes32("oracle")) {
            oracle = v;
            return;
        }
        revert("setCoreParamAddress: invalid k");
    }

    function setACL(
        address _ACL) external {

        require(msg.sender == ACL, "require ACL");
        ACL = _ACL;
    }

    function d(uint256 id) public view returns (address) {

        return IRouter(router).defaultDataContract(id);
    }

    function bondData(uint256 id) public view returns (IBondData) {

        return IBondData(d(id));
    }

    event MonitorEvent(address indexed who, address indexed bond, bytes32 indexed funcName, bytes);

    function MonitorEventCallback(address who, address bond, bytes32 funcName, bytes calldata payload) external auth {

        emit MonitorEvent(who, bond, funcName, payload);
    }

    function initialDepositCb(uint256 id, uint256 amount) external auth {

        IBondData b = bondData(id);
        b.setBondParam("depositMultiple", IConfig(config).depositMultiple(b.collateralToken()));

        require(amount >= ICoreUtils(coreUtils).calcMinCollateralTokenAmount(id), "invalid deposit amount");
        
        if (b.supportRedeem()) {
            b.setBondParam("bondStage", uint256(BondStage.RiskRating));
            b.setBondParamAddress("gov", IConfig(config).gov());

            uint256 voteDuration = IConfig(config).voteDuration(); //s
            b.setBondParam("voteExpired", now + voteDuration);
        } else {
            b.setBondParam("bondStage", uint256(BondStage.CrowdFunding));
            b.setBondParam("voteExpired", now);//不支持评级的债券发债后，投票立即到期
            b.setBondParam("investExpired", now + IConfig(config).investDuration());
            b.setBondParam("bondExpired", now + IConfig(config).investDuration() + b.maturity());
        }

        b.setBondParam("gracePeriod", IConfig(config).gracePeriod());

        b.setBondParam("discount", IConfig(config).discount(b.collateralToken()));
        b.setBondParam("liquidateLine", IConfig(config).liquidateLine(b.collateralToken()));
        b.setBondParam("partialLiquidateAmount", IConfig(config).partialLiquidateAmount(b.crowdToken()));


        b.setBondParam("borrowAmountGive", b.getBorrowAmountGive().add(amount));
               

    }

    function depositCb(address who, uint256 id, uint256 amount)
        external
        auth
        returns (bool)
    {

        require(d(id) != address(0) && bondData(id).issuer() == who, "invalid address or issuer");

        IBondData b = bondData(id);

        b.setBondParam("borrowAmountGive",b.getBorrowAmountGive().add(amount));

        return true;
    }

    function investCb(address who, uint256 id, uint256 amount)
        external
        auth
        returns (bool)
    {

        IBondData b = bondData(id);
        require(d(id) != address(0) 
            && who != b.issuer() 
            && now <= b.investExpired()
            && b.bondStage() == uint(BondStage.CrowdFunding), "forbidden self invest, or invest is expired");
        uint256 bondAmount = coreUtils.convert2BondAmount(address(b), b.crowdToken(), amount);
        require(
            bondAmount > 0 && bondAmount <= coreUtils.remainInvestAmount(id),
            "invalid bondAmount"
        );
        b.mintBond(who, bondAmount);


        require(coreUtils.remainInvestAmount(id) >= 0, "bond overflow");


        return true;
    }

    function interestBearingPeriod(uint256 id) external {

        IBondData b = bondData(id);

        require(d(id) != address(0)
            && b.bondStage() == uint256(BondStage.CrowdFunding)
            && (now > b.investExpired() || coreUtils.remainInvestAmount(id) == 0), "already closed invest");
        if (coreUtils.isMinIssuanceCheckOK(id)) {
            uint sysDebt = coreUtils.debtPlusTotalInterest(id);
            b.setBondParam("liability", sysDebt);
            b.setBondParam("originLiability", sysDebt);

            uint256 _1 = 1 ether;
            uint256 crowdUsdxLeverage = coreUtils.crowdBalanceInUsd(id)
                .mul(b.depositMultiple())
                .mul(b.liquidateLine())
                .div(1e36);

            bool unsafe = coreUtils.pawnBalanceInUsd(id) < crowdUsdxLeverage;
            if (unsafe) {
                b.setBondParam("bondStage", uint256(BondStage.CrowdFundingFail));
                b.setBondParam("issuerStage", uint256(IssuerStage.UnWithdrawPawn));
            } else {
                b.setBondParam("bondExpired", now + b.maturity());

                b.setBondParam("bondStage", uint256(BondStage.CrowdFundingSuccess));
                b.setBondParam("issuerStage", uint256(IssuerStage.UnWithdrawCrowd));

                uint256 totalFee = b.totalFee();
                uint256 voteFee = totalFee.mul(IConfig(config).ratingFeeRatio()).div(_1);

                if (b.supportRedeem()) {
                    b.setBondParam("fee", voteFee);
                    b.setBondParam("sysProfit", totalFee.sub(voteFee));
                } else {
                    b.setBondParam("fee", 0);//无投票手续费
                    b.setBondParam("sysProfit", totalFee);//发债手续费全部归ForTube平台
                }
            }
        } else {
            b.setBondParam("bondStage", uint256(BondStage.CrowdFundingFail));
            b.setBondParam("issuerStage", uint256(IssuerStage.UnWithdrawPawn));
        }

        emit MonitorEvent(msg.sender, address(b), "interestBearingPeriod", abi.encodePacked());
    }

    function txOutCrowdCb(address who, uint256 id) external auth returns (uint) {

        IBondData b = IBondData(bondData(id));
        require(d(id) != address(0) && b.issuerStage() == uint(IssuerStage.UnWithdrawCrowd) && b.issuer() == who, "only txout crowd once or require issuer");


        uint256 balance = coreUtils.transferableAmount(id);

        b.setBondParam("issuerStage", uint256(IssuerStage.WithdrawCrowdSuccess));
        b.setBondParam("bondStage", uint256(BondStage.UnRepay));

        return balance;
    }

    function overdueCb(uint256 id) external auth {

        IBondData b = IBondData(bondData(id));
        require(now >= b.bondExpired().add(b.gracePeriod()) 
            && (b.bondStage() == uint(BondStage.UnRepay) || b.bondStage() == uint(BondStage.CrowdFundingSuccess) ), "invalid overdue call state");
        b.setBondParam("bondStage", uint256(BondStage.Overdue));
        emit MonitorEvent(msg.sender, address(b), "overdue", abi.encodePacked());
    }

    function repayCb(address who, uint256 id) external auth returns (uint) {

        require(d(id) != address(0) && bondData(id).issuer() == who, "invalid address or issuer");
        IBondData b = bondData(id);
        require(
            b.bondStage() == uint(BondStage.UnRepay) || b.bondStage() == uint(BondStage.Overdue),
            "invalid state"
        );

        uint256 repayAmount = b.liability();
        b.setBondParam("liability", 0);


        b.setBondParam("bondStage", uint256(BondStage.RepaySuccess));
        b.setBondParam("issuerStage", uint256(IssuerStage.UnWithdrawPawn));

        if (b.liquidating()) {
            b.setLiquidating(false);
        }

        return repayAmount;
    }

    function withdrawPawnCb(address who, uint256 id) external auth returns (uint) {

        IBondData b = bondData(id);
        require(d(id) != address(0) 
            && b.issuer() == who
            && b.issuerStage() == uint256(IssuerStage.UnWithdrawPawn), "invalid issuer, txout state or address");

        b.setBondParam("issuerStage", uint256(IssuerStage.WithdrawPawnSuccess));
        uint256 borrowGive = b.getBorrowAmountGive();
        require(borrowGive > 0, "invalid give amount");
        b.setBondParam("borrowAmountGive", 0);//更新抵押品数量为0

        return borrowGive;
    }

    function withdrawPrincipalCb(address who, uint256 id)
        external
        auth
        returns (uint256)
    {

        IBondData b = bondData(id);

        require(d(id) != address(0) && 
            b.bondStage() == uint(BondStage.CrowdFundingFail),
            "must crowdfunding failure"
        );

        (uint256 supplyGive) = b.getSupplyAmount(who);

        uint256 bondAmount = coreUtils.convert2BondAmount(
            address(b),
            b.crowdToken(),
            supplyGive
        );
        b.burnBond(who, bondAmount);


        return supplyGive;
    }

    function withdrawPrincipalAndInterestCb(address who, uint256 id)
        external
        auth
        returns (uint256)
    {

        IBondData b = bondData(id);
        require(d(id) != address(0) && (
            b.bondStage() == uint(BondStage.RepaySuccess)
            || b.bondStage() == uint(BondStage.DebtClosed)),
            "unrepay or unliquidate"
        );


        (uint256 supplyGive) = b.getSupplyAmount(who);
        uint256 bondAmount = coreUtils.convert2BondAmount(
            address(b),
            b.crowdToken(),
            supplyGive
        );

        uint256 actualRepay = coreUtils.investPrincipalWithInterest(id, who);


        b.burnBond(who, bondAmount);


        return actualRepay;
    }

    function abs(uint256 a, uint256 b) internal pure returns (uint c) {

        c = a >= b ? a.sub(b) : b.sub(a);
    }

    function liquidateInternal(address who, uint256 id, uint y1, uint x1) internal returns (uint256, uint256, uint256, uint256) {

        IBondData b = bondData(id);
        require(b.issuer() != who, "can't self-liquidate");

        if (b.liquidating()) {
            bool depositMultipleUnsafe = coreUtils.isDepositMultipleUnsafe(id);
            require(depositMultipleUnsafe, "in depositMultiple safe state");
        } else {
            require(coreUtils.isUnsafe(id), "in safe state");

            b.setLiquidating(true);
        }

        uint256 balance = IERC20(b.crowdToken()).balanceOf(who);
        uint256 y = coreUtils.Y(id);
        uint256 x = coreUtils.X(id);

        require(balance >= y1 && y1 <= y, "insufficient y1 or balance");

        if (y1 == b.liability() || abs(y1, b.liability()) <= uint256(1) 
        || x1 == b.getBorrowAmountGive() 
        || abs(x1, b.getBorrowAmountGive()) <= coreUtils.precision(id)) {
            b.setBondParam("bondStage", uint(BondStage.DebtClosed));
            b.setLiquidating(false);
        }

        if (y1 == b.liability() || abs(y1, b.liability()) <= uint256(1)) {
            if (!(x1 == b.getBorrowAmountGive() || abs(x1, b.getBorrowAmountGive()) <= coreUtils.precision(id))) {
                b.setBondParam("issuerStage", uint(IssuerStage.UnWithdrawPawn));
            }
        }

        if (abs(y1, b.liability()) <= uint256(1)) {
            b.setBondParam("liability", 0);
        } else {
            b.setBondParam("liability", b.liability().sub(y1));
        }

        if (abs(x1, b.getBorrowAmountGive()) <= coreUtils.precision(id)) {
            b.setBondParam("borrowAmountGive", 0);
        } else {
            b.setBondParam("borrowAmountGive", b.getBorrowAmountGive().sub(x1));
        }


        if (!coreUtils.isDepositMultipleUnsafe(id)) {
            b.setLiquidating(false);
        }

        if (coreUtils.isDebtOpen(id)) {
            b.setBondParam("sysProfit", b.sysProfit().add(b.fee()));
            b.setBondParam("fee", 0);
        }

        return (y1, x1, y, x);
    }

    function liquidateCb(address who, uint256 id, uint256 y1)
        external
        auth
        returns (uint256, uint256, uint256, uint256)
    {

        (uint y, uint x) = coreUtils.getLiquidateAmount(id, y1);

        return liquidateInternal(who, id, y, x);
    }

    function withdrawSysProfitCb(address who, uint256 id) external auth returns (uint256) {

        IBondData b = bondData(id);
        uint256 _sysProfit = b.sysProfit();
        require(_sysProfit > 0, "no withdrawable sysProfit");
        b.setBondParam("sysProfit", 0);
        return _sysProfit;
    }
}