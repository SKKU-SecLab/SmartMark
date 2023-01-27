


pragma solidity 0.5.16;


interface IRegistry {


    function transferOwnership(address newOwner) external;


    function comp() external view returns (address);

    function comptroller() external view returns (address);

    function cEther() external view returns (address);


    function bComptroller() external view returns (address);

    function score() external view returns (address);

    function pool() external view returns (address);


    function delegate(address avatar, address delegatee) external view returns (bool);

    function doesAvatarExist(address avatar) external view returns (bool);

    function doesAvatarExistFor(address owner) external view returns (bool);

    function ownerOf(address avatar) external view returns (address);

    function avatarOf(address owner) external view returns (address);

    function newAvatar() external returns (address);

    function getAvatar(address owner) external returns (address);

    function whitelistedAvatarCalls(address target, bytes4 functionSig) external view returns(bool);


    function setPool(address newPool) external;

    function setWhitelistAvatarCall(address target, bytes4 functionSig, bool list) external;

}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.5.16;



contract GovernanceExecutor is Ownable {


    IRegistry public registry;
    uint public delay;
    mapping(address => uint) public poolRequests;
    mapping(address => mapping(bytes4 => mapping(bool => uint))) whitelistRequests;
    address public governance;

    event RequestPoolUpgrade(address indexed pool);
    event PoolUpgraded(address indexed pool);

    event RequestSetWhitelistCall(address indexed target, bytes4 functionSig, bool list);
    event WhitelistCallUpdated(address indexed target, bytes4 functionSig, bool list);

    constructor(address registry_, uint delay_) public {
        registry = IRegistry(registry_);
        delay = delay_;
    }

    function setGovernance(address governance_) external onlyOwner {

        require(governance == address(0), "governance-already-set");
        governance = governance_;
    }

    function doTransferAdmin(address owner) external {

        require(msg.sender == governance, "unauthorized");
        registry.transferOwnership(owner);
    }

    function reqUpgradePool(address pool) external onlyOwner {

        poolRequests[pool] = now;
        emit RequestPoolUpgrade(pool);
    }

    function dropUpgradePool(address pool) external onlyOwner {

        delete poolRequests[pool];
    }

    function execUpgradePool(address pool) external {

        uint reqTime = poolRequests[pool];
        require(reqTime != 0, "request-not-valid");
        require(now >= add(reqTime, delay), "delay-not-over");

        delete poolRequests[pool];
        registry.setPool(pool);
        emit PoolUpgraded(pool);
    }

    function reqSetWhitelistCall(address target, bytes4 functionSig, bool list) external onlyOwner {

        whitelistRequests[target][functionSig][list] = now;
        emit RequestSetWhitelistCall(target, functionSig, list);
    }

    function dropWhitelistCall(address target, bytes4 functionSig, bool list) external onlyOwner {

        delete whitelistRequests[target][functionSig][list];
    }

    function execSetWhitelistCall(address target, bytes4 functionSig, bool list) external {

        uint reqTime = whitelistRequests[target][functionSig][list];
        require(reqTime != 0, "request-not-valid");
        require(now >= add(reqTime, delay), "delay-not-over");

        delete whitelistRequests[target][functionSig][list];
        registry.setWhitelistAvatarCall(target, functionSig, list);
        emit WhitelistCallUpdated(target, functionSig, list);
    }

    function add(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "overflow");
        return c;
    }
}


pragma solidity 0.5.16;

interface IBTokenScore {

    function start() external view returns (uint);

    function spin() external;


    function getDebtScore(address user, address cToken, uint256 time) external view returns (uint);

    function getCollScore(address user, address cToken, uint256 time) external view returns (uint);


    function getDebtGlobalScore(address cToken, uint256 time) external view returns (uint);

    function getCollGlobalScore(address cToken, uint256 time) external view returns (uint);


    function endDate() external view returns(uint);

}


pragma solidity 0.5.16;


contract JarConnector {


    IBTokenScore public score;
    address[] public cTokens;

    constructor(address[] memory _cTokens, address _score) public {
        score = IBTokenScore(_score);

        cTokens = _cTokens;
    }

    function getUserScore(address user) external view returns (uint) {

        return _getTotalUserScore(user, now);
    }

    function getUserScoreProgressPerSec(address user) external view returns (uint) {

        return _getTotalUserScore(user, now + 1) - _getTotalUserScore(user, now);
    }

    function getGlobalScore() external view returns (uint) {

        return _getTotalGlobalScore(now);
    }

    function _getTotalUserScore(address user, uint time) internal view returns (uint256) {

        uint totalScore = 0;
        for(uint i = 0; i < cTokens.length; i++) {
            uint debtScore = score.getDebtScore(user, cTokens[i], time);
            uint collScore = score.getCollScore(user, cTokens[i], time);
            totalScore = add_(add_(totalScore, debtScore), collScore);
        }
        return totalScore;
    }

    function _getTotalGlobalScore(uint time) internal view returns (uint256) {

        uint totalScore = 0;
        for(uint i = 0; i < cTokens.length; i++) {
            uint debtScore = score.getDebtGlobalScore(cTokens[i], time);
            uint collScore = score.getCollGlobalScore(cTokens[i], time);
            totalScore = add_(add_(totalScore, debtScore), collScore);
        }
        return totalScore;
    }

    function spin() external {

        require(score.endDate() < now, "too-early");
        score.spin();
    }

    function add_(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "overflow");
        return c;
    }
}


pragma solidity 0.5.16;

contract CarefulMath {


    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    function subUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    function addUInt(uint a, uint b) internal pure returns (MathError, uint) {

        uint c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {

        (MathError err0, uint sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}


pragma solidity 0.5.16;


contract Exponential is CarefulMath {

    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    function getExp(uint num, uint denom) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    function mulScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    function mulScalarTruncate(Exp memory a, uint scalar) pure internal returns (MathError, uint) {

        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    function mulExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {


        (MathError err0, uint doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    function mulExp(uint a, uint b) pure internal returns (MathError, Exp memory) {

        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }


    function divExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        return getExp(a.mantissa, b.mantissa);
    }

    function truncate(Exp memory exp) pure internal returns (uint) {

        return exp.mantissa / expScale;
    }


    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {

        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {

        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {

        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {

        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {

        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {

        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {

        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {

        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {

        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {

        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }


    function mulTrucate(uint a, uint b) internal pure returns (uint) {

        return mul_(a, b) / expScale;
    }
}


pragma solidity 0.5.16;





contract Migrate is Exponential {


    event NewProposal(uint indexed proposalId, address newOwner);
    event Voted(uint indexed proposalId, address user, uint score);
    event VoteCancelled(uint indexed proposalId, address user, uint score);
    event Queued(uint indexed proposalId);
    event Executed(uint indexed proposalId);

    struct Proposal {
        uint forVotes;
        uint eta;
        address newOwner;
        mapping (address => bool) voted; // user => voted
    }

    uint public constant DELAY = 2 days;

    JarConnector public jarConnector;
    IRegistry public registry;
    GovernanceExecutor public executor;

    Proposal[] public proposals;

    constructor(
        JarConnector jarConnector_,
        IRegistry registry_,
        GovernanceExecutor executor_
    ) public {
        jarConnector = jarConnector_;
        registry = registry_;
        executor = executor_;
    }

    function propose(address newOwner) external returns (uint) {

        require(newOwner != address(0), "newOwner-cannot-be-zero");

        Proposal memory proposal = Proposal({
            forVotes: 0,
            eta: 0,
            newOwner: newOwner
        });

        uint proposalId = sub_(proposals.push(proposal), uint(1));
        emit NewProposal(proposalId, newOwner);

        return proposalId;
    }

    function vote(uint proposalId) external {

        address user = msg.sender;
        Proposal storage proposal = proposals[proposalId];
        require(proposal.newOwner != address(0), "proposal-not-exist");
        require(! proposal.voted[user], "already-voted");
        require(registry.doesAvatarExistFor(user), "avatar-does-not-exist");

        uint score = jarConnector.getUserScore(user);
        proposal.forVotes = add_(proposal.forVotes, score);
        proposal.voted[user] = true;

        emit Voted(proposalId, user, score);
    }

    function cancelVote(uint proposalId) external {

        address user = msg.sender;
        Proposal storage proposal = proposals[proposalId];
        require(proposal.newOwner != address(0), "proposal-not-exist");
        require(proposal.voted[user], "not-voted");
        require(registry.doesAvatarExistFor(user), "avatar-does-not-exist");

        uint score = jarConnector.getUserScore(user);
        proposal.forVotes = sub_(proposal.forVotes, score);
        proposal.voted[user] = false;

        emit VoteCancelled(proposalId, user, score);
    }

    function queueProposal(uint proposalId) external {

        uint quorum = add_(jarConnector.getGlobalScore() / 2, uint(1)); // 50%
        Proposal storage proposal = proposals[proposalId];
        require(proposal.eta == 0, "already-queued");
        require(proposal.newOwner != address(0), "proposal-not-exist");
        require(proposal.forVotes >= quorum, "quorum-not-passed");

        proposal.eta = now + DELAY;

        emit Queued(proposalId);
    }

    function executeProposal(uint proposalId) external {

        Proposal memory proposal = proposals[proposalId];
        require(proposal.eta > 0, "proposal-not-queued");
        require(now >= proposal.eta, "delay-not-over");

        executor.doTransferAdmin(proposal.newOwner);

        emit Executed(proposalId);
    }
}