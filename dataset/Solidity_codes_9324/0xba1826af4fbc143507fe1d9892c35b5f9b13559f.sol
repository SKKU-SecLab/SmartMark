

pragma solidity ^0.8.0;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function balanceOf(address account) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}


pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}


pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}


interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}

pragma solidity ^0.8.13;

contract TerraformStaking is Ownable {

    using SafeMath for uint256;

    struct Bracket {
        uint256 lockedDays;
        uint256 APYRewards;
        bool enabled;
    }

    struct DepositInfo {
        uint256 amount;
        uint256 timestamp;
    }
 
    struct TruthStake {
        uint256 tokenId;
        uint256 amount;
        uint256 timestamp;
    }

    struct Deposit {
        DepositInfo info;
        Bracket bracket;
        TruthStake truth;
        uint256 claimed;
        bool active;
        bool truthcircle;
    }
   

    uint256 private PRECISION_FACTOR = 10000;
    IERC20 public depositToken;
    IERC20 public rewardsToken;
    IERC721 public truthToken;
    bool public terraFormInitiated = false;

    address[] public depositAddresses;
    uint256[] public stakedTokenIds;
    mapping (uint256 => Bracket) public brackets;
    mapping (address => Deposit) public deposits;

    event UserDeposit(address wallet, uint256 amount);
    event RewardsWithdraw(address wallet, uint256 rewardsAmount);
    event FullWithdraw(address wallet, uint256 depositAmount, uint256 rewardsAmount, uint256 tokenId);
    event ExtendLock(address wallet, uint256 duration);
    event UserTruthStake(address wallet, uint256 tokenId);

    function calculateRewards(address wallet) public view returns (uint256) {

        uint256 rewards = 0;
        Deposit memory userDeposit = deposits[wallet];
        if (userDeposit.active) {
            uint256 depositSeconds = block.timestamp.sub(userDeposit.info.timestamp);
            uint256 APYRate = userDeposit.bracket.APYRewards;
            if (userDeposit.truthcircle) {
                APYRate = APYRate + APYRate.div(100).mul(5);   
                uint256 baseSeconds = userDeposit.truth.timestamp.sub(userDeposit.info.timestamp);
                uint256 truthSeconds = block.timestamp.sub(userDeposit.truth.timestamp);
                uint256 grossrewards = userDeposit.info.amount.mul(userDeposit.bracket.APYRewards).mul(baseSeconds) + userDeposit.info.amount.mul(APYRate).mul(truthSeconds);
                rewards = grossrewards.div(365).div(86400).div(PRECISION_FACTOR);
            }
            else {
                uint256 calcdrewards = userDeposit.info.amount.mul(APYRate).mul(depositSeconds);
                rewards = calcdrewards.div(365).div(86400).div(PRECISION_FACTOR);
            }
        }
        return rewards.sub(userDeposit.claimed);
    }

    function deposit(uint256 tokenAmount, uint256 bracket) external {

        require(!deposits[_msgSender()].active, "user has already deposited");
        require(brackets[bracket].enabled, "bracket is not enabled");
        require(terraFormInitiated, "Terraform Staking Not Live");

        uint256 previousBalance = depositToken.balanceOf(address(this));
        depositToken.transferFrom(_msgSender(), address(this), tokenAmount);
        uint256 deposited = depositToken.balanceOf(address(this)).sub(previousBalance);

        DepositInfo memory info = DepositInfo(deposited, block.timestamp);
        TruthStake memory truth = TruthStake(0,0,0);
        deposits[_msgSender()] = Deposit(info, brackets[bracket], truth, 0, true, false);
        depositAddresses.push(_msgSender());
        emit UserDeposit(_msgSender(), deposited);
    }

    function updateDeposit(address _wallet, uint256 _bracket, uint256 _lockedDays, uint256 _APYRewards) external onlyOwner {

        require(deposits[_wallet].active, "user has no active deposits");
        require(brackets[_bracket].enabled, "bracket is not enabled");
        deposits[_wallet].bracket.lockedDays = _lockedDays;
        deposits[_wallet].bracket.APYRewards = _APYRewards.mul(PRECISION_FACTOR);
    }

    function currentTimstamp() external view returns (uint256) {

        return block.timestamp;
    }

    function checkCalculations(address wallet) external view returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256) {

        uint256 earnedrewards = 0;
        uint256 grossrewards;
        uint256 toclaim;
        uint256 unlocktime;
        uint256 locked;
        Deposit memory userDeposit = deposits[wallet];
        uint256 depositSeconds = block.timestamp.sub(userDeposit.info.timestamp);

        uint256 APYRate = userDeposit.bracket.APYRewards;
        if (userDeposit.truthcircle) {
            APYRate = APYRate + APYRate.div(100).mul(5);
            uint256 baseSeconds = userDeposit.truth.timestamp.sub(userDeposit.info.timestamp);
            uint256 truthSeconds = block.timestamp.sub(userDeposit.truth.timestamp);
            grossrewards = userDeposit.info.amount.mul(userDeposit.bracket.APYRewards).mul(baseSeconds) + userDeposit.info.amount.mul(APYRate).mul(truthSeconds);
            earnedrewards = grossrewards.div(365).div(86400).div(PRECISION_FACTOR);
            toclaim = earnedrewards.sub(userDeposit.claimed);
            unlocktime = userDeposit.info.timestamp + userDeposit.bracket.lockedDays * 1 days;
            locked = userDeposit.info.timestamp;
        }
        else {
            grossrewards = userDeposit.info.amount.mul(APYRate).mul(depositSeconds);
            earnedrewards = grossrewards.div(365).div(86400).div(PRECISION_FACTOR);
            toclaim = earnedrewards.sub(userDeposit.claimed);
            unlocktime = userDeposit.info.timestamp + userDeposit.bracket.lockedDays * 1 days;
            locked = userDeposit.info.timestamp;
        }
        return (depositSeconds,APYRate,grossrewards,earnedrewards,toclaim,locked,unlocktime);
    }

    function claimRewards() external {

        Deposit memory userDeposit = deposits[_msgSender()];
        require(userDeposit.active, "user has no active deposits");
        uint256 rewardsAmount = calculateRewards(_msgSender());
        require (rewardsToken.balanceOf(address(this)) >= rewardsAmount, "insufficient rewards balance");
        deposits[_msgSender()].claimed += rewardsAmount;
        rewardsToken.transfer(_msgSender(), rewardsAmount);
        emit RewardsWithdraw(_msgSender(), rewardsAmount);
    }

    function stakeTruth(uint256 _tokenId) external {

        Deposit memory userDeposit = deposits[_msgSender()];
        require(userDeposit.active, "user has no active deposits");
        require(userDeposit.truth.amount == 0, "user has already staked their Truth");
        truthToken.safeTransferFrom(_msgSender(), address(this), _tokenId);
        deposits[_msgSender()].truth.tokenId = _tokenId;
        deposits[_msgSender()].truth.amount = 1;
        deposits[_msgSender()].truth.timestamp = block.timestamp;
        deposits[_msgSender()].truthcircle = true;
        stakedTokenIds.push(_tokenId);
        emit UserTruthStake(_msgSender(), _tokenId);
    }

    function extendStake(uint256 _bracket) external {

        Deposit memory userDeposit = deposits[_msgSender()];
        require(userDeposit.active, "user has no active deposits");
        require(brackets[_bracket].enabled, "bracket is not enabled");

        uint256 oldDuration = userDeposit.info.timestamp + userDeposit.bracket.lockedDays * 1 days;
        uint256 newDuration = block.timestamp + brackets[_bracket].lockedDays * 1 days;

        require(newDuration > oldDuration, "cannot reduce lock duration, ur trying to lock for a shorter time");

        uint256 rewardsAmount = calculateRewards(_msgSender());
        require (rewardsToken.balanceOf(address(this)) >= rewardsAmount, "insufficient rewards balance");
        deposits[_msgSender()].claimed = rewardsAmount;
        rewardsToken.transfer(_msgSender(), rewardsAmount);

        deposits[_msgSender()].bracket.lockedDays = brackets[_bracket].lockedDays;
        deposits[_msgSender()].bracket.APYRewards = brackets[_bracket].APYRewards;
        deposits[_msgSender()].info.timestamp = block.timestamp;
        deposits[_msgSender()].truth.timestamp = block.timestamp;
        deposits[_msgSender()].claimed = 0;
        emit ExtendLock(_msgSender(),newDuration);

    }

    function withdraw() external {

        Deposit memory userDeposit = deposits[_msgSender()];
        require(userDeposit.active, "user has no active deposits");
        require(block.timestamp >= userDeposit.info.timestamp + userDeposit.bracket.lockedDays * 1 days, "Can't withdraw yet");
        uint256 depositedAmount = userDeposit.info.amount;
        uint256 rewardsAmount = calculateRewards(_msgSender());
        uint256 tokenId = 0;
        require (rewardsToken.balanceOf(address(this)) >= rewardsAmount, "insufficient rewards balance");

        deposits[_msgSender()].info.amount = 0;
        deposits[_msgSender()].claimed = 0;
        deposits[_msgSender()].active = false;
        rewardsToken.transfer(_msgSender(), rewardsAmount);
        depositToken.transfer(_msgSender(), depositedAmount);
        if (deposits[_msgSender()].truthcircle) {
            tokenId = deposits[_msgSender()].truth.tokenId;
            truthToken.safeTransferFrom(address(this), _msgSender(), deposits[_msgSender()].truth.tokenId);
            deposits[_msgSender()].truth.tokenId = 0;
            deposits[_msgSender()].truthcircle = false;
            deposits[_msgSender()].truth.amount = 0;
            for (uint i=0;i<stakedTokenIds.length;i++) {
                if (stakedTokenIds[i] == deposits[_msgSender()].truth.tokenId) {
                    delete stakedTokenIds[i];
                }
            }
        }

        emit FullWithdraw(_msgSender(), depositedAmount, rewardsAmount, tokenId);
    }

    function addBracket(uint256 id, uint256 lockedDays, uint256 APYRewards) external onlyOwner {

        APYRewards = APYRewards.mul(PRECISION_FACTOR).div(100);
        brackets[id] = Bracket(lockedDays, APYRewards, true);
    }

    function addMultipleBrackets(uint256[] memory id, uint256[] memory lockedDays, uint256[] memory APYRewards) external onlyOwner {

        uint256 i = 0;
        require(id.length == lockedDays.length, "must be same length");
        require(APYRewards.length == id.length, "must be same length");
        while (i < id.length) {
            uint256 _APYRewards = APYRewards[i].mul(PRECISION_FACTOR).div(100);
            brackets[id[i]] = Bracket(lockedDays[i], _APYRewards, true);
            i +=1;
        }
    }

    function setTokens(address depositAddress, address rewardsAddress, address truthAddress) external onlyOwner {

        depositToken = IERC20(depositAddress);
        truthToken = IERC721(truthAddress);
        rewardsToken = IERC20(rewardsAddress);
    }

    function beginTerraform(bool _terraformInitiated) external onlyOwner {

        terraFormInitiated = _terraformInitiated;
        
    }

    function rescueTokens() external onlyOwner {

        if (rewardsToken.balanceOf(address(this)) > 0) {
            rewardsToken.transfer(_msgSender(), rewardsToken.balanceOf(address(this)));
        }

        if (depositToken.balanceOf(address(this)) > 0) {
            depositToken.transfer(_msgSender(), depositToken.balanceOf(address(this)));
        }
        for (uint i=0;i<stakedTokenIds.length;i++) {
            if (stakedTokenIds[i] != 0) {
                truthToken.safeTransferFrom(address(this), _msgSender(), stakedTokenIds[i]);
            }
        }
        delete stakedTokenIds;
    }

     function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {

        return this.onERC721Received.selector;
    }
}