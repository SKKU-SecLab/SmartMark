

pragma experimental ABIEncoderV2;
pragma solidity ^0.6.0;

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

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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


pragma solidity ^0.6.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}



pragma solidity >=0.6.0;






interface IPRA {

    function raters(address who) external view returns (bool);

}


interface IConfig {

    function ratingCandidates(address proposal) external view returns (bool);


    function depositDuration() external view returns (uint256);


    function professionalRatingWeightRatio() external view returns (uint256);


    function communityRatingWeightRatio() external view returns (uint256);


    function investDuration() external view returns (uint256);


    function communityRatingLine() external view returns (uint256);

}


interface IACL {

    function accessible(address sender, address to, bytes4 sig)
        external
        view
        returns (bool);

}


interface IRating {

    function risk() external view returns (uint256);

    function fine() external view returns (bool);

}


contract Vote is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event MonitorEvent(
        address indexed who,
        address indexed bond,
        bytes32 indexed funcName,
        bytes
    );

    function MonitorEventCallback(address who, address bond, bytes32 funcName, bytes calldata payload) external auth {

        emit MonitorEvent(who, bond, funcName, payload);
    }

    address public router;
    address public config;
    address public ACL;
    address public PRA;

    modifier auth {

        require(
            IACL(ACL).accessible(msg.sender, address(this), msg.sig),
            "Vote: access unauthorized"
        );
        _;
    }

    constructor(address _ACL, address _router, address _config, address _PRA)
        public
    {
        router = _router;
        config = _config;
        ACL = _ACL;
        PRA = _PRA;
    }

    function setACL(
        address _ACL) external {

        require(msg.sender == ACL, "require ACL");
        ACL = _ACL;
    }

    function prcast(uint256 id, address proposal, uint256 reason) external nonReentrant {

        IBondData data = IBondData(IRouter(router).defaultDataContract(id));
        require(data.voteExpired() > now, "vote is expired");
        require(
            IPRA(PRA).raters(msg.sender),
            "sender is not a professional rater"
        );
        IBondData.prwhat memory pr = data.pr();
        require(pr.proposal == address(0), "already professional rating");
        IBondData.what memory _what = data.votes(msg.sender);
        require(_what.proposal == address(0), "already community rating");
        require(data.issuer() != msg.sender, "issuer can't vote for self bond");
        require(
            IConfig(config).ratingCandidates(proposal),
            "proposal is not permissive"
        );
        data.setPr(msg.sender, proposal, reason);
        emit MonitorEvent(
            msg.sender,
            address(data),
            "prcast",
            abi.encodePacked(proposal)
        );
    }

    function cast(uint256 id, address who, address proposal, uint256 amount)
        external
        auth
    {

        IBondData data = IBondData(IRouter(router).defaultDataContract(id));
        require(data.voteExpired() > now, "vote is expired");
        require(!IPRA(PRA).raters(who), "sender is a professional rater");
        require(data.issuer() != who, "issuer can't vote for self bond");
        require(
            IConfig(config).ratingCandidates(proposal),
            "proposal is not permissive"
        );

        IBondData.what memory what = data.votes(who);

        address p = what.proposal;
        uint256 w = what.weight;

        if (p != address(0) && p != proposal) {

            data.setBondParamMapping("weights", p, data.weights(p).sub(w));
            data.setBondParamMapping("weights", proposal, data.weights(proposal).add(w));
        }

        data.setVotes(who, proposal, w.add(amount));

        data.setBondParamMapping("weights", proposal, data.weights(proposal).add(amount));
        data.setBondParam("totalWeights", data.totalWeights().add(amount));

        if (data.weights(proposal) >= data.weights(data.top())) {
            data.setBondParamAddress("top", proposal);
        }
    }

    function take(uint256 id, address who) external auth returns (uint256) {

        IBondData data = IBondData(IRouter(router).defaultDataContract(id));
        require(now > data.voteExpired(), "vote is expired");
        require(data.top() != address(0), "vote is not winner");
        uint256 amount = data.voteLedger(who);

        return amount;
    }

    function rating(uint256 id) external {

        IBondData data = IBondData(IRouter(router).defaultDataContract(id));
        require(now > data.voteExpired(), "vote unexpired");

        uint256 _bondStage = data.bondStage();
        require(
            _bondStage == uint256(BondStage.RiskRating),
            "already rating finished"
        );

        uint256 totalWeights = data.totalWeights();
        IBondData.prwhat memory pr = data.pr();

        if (
            totalWeights >= IConfig(config).communityRatingLine() &&
            pr.proposal != address(0)
        ) {
            address top = data.top();
            uint256 p = IConfig(config).professionalRatingWeightRatio(); //40%
            uint256 c = IConfig(config).communityRatingWeightRatio(); //60%
            uint256 pr_weights = totalWeights.mul(p).div(c);

            if (top != pr.proposal) {
                uint256 pr_proposal_weights = data.weights(pr.proposal).add(
                    pr_weights
                );

                if (data.weights(top) < pr_proposal_weights) {
                    data.setBondParamAddress("top", pr.proposal);
                }

                if (data.weights(top) == pr_proposal_weights) {
                    data.setBondParamAddress("top", 
                        IRating(top).risk() < IRating(pr.proposal).risk()
                            ? top
                            : pr.proposal
                    );
                }
            }
            if(IRating(data.top()).fine()) {
                data.setBondParam("bondStage", uint256(BondStage.CrowdFunding));
                data.setBondParam("investExpired", now + IConfig(config).investDuration());
                data.setBondParam("bondExpired", now + IConfig(config).investDuration() + data.maturity());
            } else {
                data.setBondParam("bondStage", uint256(BondStage.RiskRatingFail));
                data.setBondParam("issuerStage", uint256(IssuerStage.UnWithdrawPawn));
            }
        } else {
            data.setBondParam("bondStage", uint256(BondStage.RiskRatingFail));
            data.setBondParam("issuerStage", uint256(IssuerStage.UnWithdrawPawn));
        }

        emit MonitorEvent(
            msg.sender,
            address(data),
            "rating",
            abi.encodePacked(data.top(), data.weights(data.top()))
        );
    }

    function profitOf(uint256 id, address who) public view returns (uint256) {

        IBondData data = IBondData(IRouter(router).defaultDataContract(id));
        uint256 _bondStage = data.bondStage();
        if (
            _bondStage == uint256(BondStage.RepaySuccess) ||
            _bondStage == uint256(BondStage.DebtClosed)
        ) {
            IBondData.what memory what = data.votes(who);
            IBondData.prwhat memory pr = data.pr();

            uint256 p = IConfig(config).professionalRatingWeightRatio();
            uint256 c = IConfig(config).communityRatingWeightRatio();

            uint256 _fee = data.fee();
            uint256 _profit = 0;

            if (pr.who != who) {
                if(what.proposal == address(0)) {
                    return 0;
                }
                _profit = _fee.mul(c).mul(what.weight).div(
                    data.totalWeights()
                );
            } else {
                _profit = _fee.mul(p);
            }

            return _profit.div(1e18);
        }

        return 0;
    }

    function profit(uint256 id, address who) external auth returns (uint256) {

        IBondData data = IBondData(IRouter(router).defaultDataContract(id));
        uint256 _bondStage = data.bondStage();
        require(
            _bondStage == uint256(BondStage.RepaySuccess) ||
                _bondStage == uint256(BondStage.DebtClosed),
            "bond is unrepay or unliquidate"
        );
        require(data.profits(who) == 0, "voting profit withdrawed");
        IBondData.prwhat memory pr = data.pr();
        IBondData.what memory what = data.votes(who);
        require(what.proposal != address(0) || pr.who == who, "user is not rating vote");
        uint256 _profit = profitOf(id, who);
        data.setBondParamMapping("profits", who, _profit);
        data.setBondParam("totalProfits", data.totalProfits().add(_profit));

        return _profit;
    }
}