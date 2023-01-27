
pragma solidity 0.8.0;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
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
}

interface PolvenStakingStructs {

    struct Stake {
        uint256 amount;
        uint256 normalizedAmount;
    }

    struct StakeTimeframe {
        uint256 amount;
        uint256 normalizedAmount;
        uint256 lastStakeTime;
    }
}

interface PolvenStaking is PolvenStakingStructs {

    function userStakes(address) external view returns(Stake memory);

    function userStakesTimeframe(address) external view returns(StakeTimeframe memory);

}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ClubDealSwap is Ownable, PolvenStakingStructs {

    using SafeMath for uint256;
    
    event SwappFromPolven (address user, uint256 polvenAmount, uint256 tokenAmount, uint256 discountPercentage, uint256 counter);
    event SwappFromToken (address user, uint256 polvenAmount, uint256 tokenAmount, uint256 discountPercentage, uint256 counter);
    event SetPolvenPrice(uint256 oldPolvenPrice, uint256 newPolvenPrice);
    event SetTokenPrice(uint256 oldTokenPrice, uint256 newTokenPrice);
    event NewTier(string title, uint256 percent, uint256 amount);
    event DeleteTier(uint index, string title, uint256 percent, uint256 amount);
    event UpdateTier(uint index, string oldTitle, uint256 oldPercent, uint256 oldAmount, string newTitle, uint256 newPercent, uint256 newAmount);
    event CreateProposal(uint256 expirationDate, address token, uint256 tokenPrice);
    event TransferStuckERC20(IERC20 _token, address _to, uint256 _amount);
    event CloseProposal(uint256 counter);
    
    uint256 public counter;
    
    enum AdminStatus { CLOSED, OPEN }
    enum ProposalStatus { CLOSED, OPEN }
    
    struct Tier {
        string title;
        uint256 percent;
        uint256 amount;
    }
    
    struct Proposal {
        uint256 expirationDate;
        IERC20 token;
        uint256 tokenPrice;
        AdminStatus adminStatus;
    }
    
    PolvenStaking public staking;
    
    uint256 public polvenPrice;
    IERC20 public polven;
    
    Tier[] tiers;
    mapping(uint256 => Proposal) public proposals;
    
    address burnAddress;
    uint256 oneHundredPercent = 10000;
    
    constructor(address _staking, address _polven, uint256 _polvenPrice) public {
        counter = 0;
        staking = PolvenStaking(_staking);
        polven = IERC20(_polven);
        polvenPrice = _polvenPrice;
        burnAddress = address(0x0000000000000000000000000000000000000000dEaD);
    }
    
    function create(uint256 expirationDate, address token, uint256 tokenPrice) external onlyOwner {

        require(expirationDate > block.timestamp, "Incorrect expiration date");
        
        if(counter > 0) {
            require(getProposalStatus(counter) == ProposalStatus.CLOSED, "The previous proposal is not over yet");
        }
        
        counter++;
        
        proposals[counter].expirationDate = expirationDate;
        proposals[counter].token = IERC20(token);
        proposals[counter].tokenPrice = tokenPrice;
        proposals[counter].adminStatus = AdminStatus.OPEN;
        
        emit CreateProposal(expirationDate, token, tokenPrice);
    }
    
    function swappFromPolven(uint256 _counter, uint256 polvensAmount) external {

        require(counter > 0, "Proposal has not been created yet");
        require(_counter == counter, "Incorrect counter");
        require(getProposalStatus(counter) == ProposalStatus.OPEN, "Proposal closed");
        require(polvensAmount > 0, "Incorrect polvens amount");
        
        uint256 tokensAmount;
        uint256 discountPercentage;

        (tokensAmount, discountPercentage) = calculateTokensAmount(msg.sender, polvensAmount);

        require(polven.transferFrom(msg.sender, burnAddress, polvensAmount), "Polven transfer failed");
        
        require(proposals[counter].token.transfer(msg.sender, tokensAmount), "Token transfer failed");
        
        emit SwappFromPolven(msg.sender, polvensAmount, tokensAmount, discountPercentage, counter);
    }
    
    function swappFromToken(uint256 _counter, uint256 tokensAmount) external {

        require(counter > 0, "Proposal has not been created yet");
        require(_counter == counter, "Incorrect counter");
        require(getProposalStatus(counter) == ProposalStatus.OPEN, "Proposal closed");
        require(tokensAmount > 0, "Incorrect tokens amount");
        
        uint256 polvensAmount;
        uint256 discountPercentage;

        (polvensAmount, discountPercentage) = calculatePolvensAmount(msg.sender, tokensAmount);
        
        require(polvensAmount > 0, "Incorrect polvens amount");
        
        require(polven.transferFrom(msg.sender, burnAddress, polvensAmount), "Polven transfer failed");
        
        require(proposals[counter].token.transfer(msg.sender, tokensAmount), "Token transfer failed");
        
        emit SwappFromToken(msg.sender, polvensAmount, tokensAmount, discountPercentage, counter);
    }
    
    function calculateTokensAmount(address user, uint256 polvensAmount) public view returns(uint256, uint256) {

        require(counter > 0, "Proposal has not been created yet");
        int tierIndex = getAvailableTierIndex(user);
        require(tierIndex >= 0, "Not enough staked Polvens");
        
        uint256 tokenPrice = proposals[counter].tokenPrice;
        uint256 discountPercentage = tiers[uint256(tierIndex)].percent;
        
        uint256 tokensAmount = polvensAmount.mul(polvenPrice).div(tokenPrice.mul(oneHundredPercent.sub(discountPercentage)).div(oneHundredPercent));

        return (tokensAmount, discountPercentage);
    }
    
    function calculatePolvensAmount(address user, uint256 tokensAmount) public view returns(uint256, uint256) {

        require(counter > 0, "Proposal has not been created yet");
        int tierIndex = getAvailableTierIndex(user);
        require(tierIndex >= 0, "Not enough staked Polvens");
        
        uint256 tokenPrice = proposals[counter].tokenPrice;
        uint256 discountPercentage = tiers[uint256(tierIndex)].percent;
        
        uint256 polvensAmount = tokensAmount.mul(tokenPrice.mul(oneHundredPercent.sub(discountPercentage)).div(oneHundredPercent)).div(polvenPrice);

        return (polvensAmount, discountPercentage);
    }

    function getProposalByCounter(uint256 _counter) external view returns(uint256, IERC20, uint256, ProposalStatus) {

        return (proposals[_counter].expirationDate, proposals[_counter].token, proposals[_counter].tokenPrice, getProposalStatus(_counter));
    }
    
    function getLastProposal() external view returns(uint256, IERC20, uint256, ProposalStatus) {

        return (proposals[counter].expirationDate, proposals[counter].token, proposals[counter].tokenPrice, getProposalStatus(counter));
    }
    
    function getAvailableTierIndex(address user) public view returns(int) {

        require(tiers.length > 0, "No tiers available");

        uint256 stakingAmount = getStakingAmount(user);
        for (int i = int(tiers.length) - 1; i >= 0; i--) {
          if (stakingAmount >= tiers[uint(i)].amount) {
            return int(i);
          }
        }
        
        return -1;
    }
    
    function setPolvenPrice(uint256 _polvenPrice) public onlyOwner {

        require(_polvenPrice > 0, "Incorrect price");
        uint256 oldPolvenPrice = polvenPrice;
        polvenPrice = _polvenPrice;
        
        emit SetPolvenPrice(oldPolvenPrice, _polvenPrice);
    }
    
    function setTokenPrice(uint256 _tokenPrice) public onlyOwner {

        require(_tokenPrice > 0, "Incorrect price");
        require(counter > 0, "Proposal has not been created yet");
        uint256 oldTokenPrice = proposals[counter].tokenPrice;
        proposals[counter].tokenPrice = _tokenPrice;
        
        emit SetTokenPrice(oldTokenPrice, _tokenPrice);
    }
    
    function setPrices(uint256 _polvenPrice, uint256 _tokenPrice) external onlyOwner {

        setPolvenPrice(_polvenPrice);
        setTokenPrice(_tokenPrice);
    }
    
    function getTiers() external view returns(Tier[] memory) {

        return tiers;
    }
    
    function getTiersLength() external view returns(uint) {

        return tiers.length;
    }
    
    function getTierByIndex(uint index) external view returns(string memory title, uint percent, uint256 amount) {

        return (tiers[index].title, tiers[index].percent, tiers[index].amount);
    }
    
    function addTier(string memory title, uint256 percent, uint256 amount) public onlyOwner {

        require(percent > 0, "Percent must be greater than 0");
        require(amount > 0, "Amount must be greater than 0");
        
        if(tiers.length > 0) {
            require(percent > tiers[tiers.length - 1].percent, "Percent must be greater than the previous value");
            require(amount > tiers[tiers.length - 1].amount, "Amount must be greater than the previous value");
        }
        
        tiers.push(Tier(title, percent, amount));
        
        emit NewTier(title, percent, amount);
    }
    
    function deleteTier(uint index) public onlyOwner {

        require(index < tiers.length, "Incorrect index");
        
        Tier memory deletedTier = tiers[index];
        
        for (uint i = index; i < tiers.length - 1; i++){
            tiers[i] = tiers[i+1];
        }
        tiers.pop();
        
        emit DeleteTier(index, deletedTier.title, deletedTier.percent, deletedTier.amount);
    }
    
    function updateTier(uint index, string memory title, uint256 percent, uint256 amount) public onlyOwner {

        require(tiers.length > 0, "Array is empty");
        require(index < tiers.length, "Incorrect index");
        
        require(percent > 0, "Percent must be greater than 0");
        require(amount > 0, "Amount must be greater than 0");
        
        if(index == 0 && tiers.length > 1) {
            require(percent < tiers[1].percent, "Percent must be less than the next value");
            require(amount < tiers[1].amount, "Amount must be less than the next value");
        }
        
        if(index == tiers.length - 1 && tiers.length > 1) {
            require(percent > tiers[tiers.length - 2].percent, "Percent must be greater than the previous value");
            require(amount > tiers[tiers.length - 2].amount, "Amount must be greater than the previous value");
        }
        
        if(index > 0 && index < tiers.length - 1) {
            require(percent < tiers[index + 1].percent, "Percent must be less than the next value");
            require(amount < tiers[index + 1].amount, "Amount must be less than the next value");
            require(percent > tiers[index - 1].percent, "Percent must be greater than the previous value");
            require(amount > tiers[index - 1].amount, "Amount must be greater than the previous value");
        }
        
        Tier memory updatedTier = tiers[index];
        
        tiers[index].title = title;
        tiers[index].percent = percent;
        tiers[index].amount = amount;
        
        emit UpdateTier(index, updatedTier.title, updatedTier.percent, updatedTier.amount, title, percent, amount);
    }
    
    function transferStuckERC20(IERC20 _token, address _to, uint256 _amount) external onlyOwner {

        require(_token.transfer(_to, _amount), "Token: Transfer failed");
        
        emit TransferStuckERC20(_token, _to, _amount);
    }
    
    function closeLastProposal() external onlyOwner {

        proposals[counter].adminStatus = AdminStatus.CLOSED;
        
        emit CloseProposal(counter);
    }
    
    function getStakingAmount(address user) private view returns(uint256) {

        Stake memory userStakes = staking.userStakes(user);
        StakeTimeframe memory userStakesTimeframe = staking.userStakesTimeframe(user);
        return userStakes.amount + userStakesTimeframe.amount;
    }
    
    function getProposalStatus(uint256 _counter) private view returns(ProposalStatus) {

        if(proposals[_counter].adminStatus == AdminStatus.CLOSED) {
            return ProposalStatus.CLOSED;
        }
     
        if(proposals[_counter].expirationDate <= block.timestamp) {
            return ProposalStatus.CLOSED;
        }
     
        return ProposalStatus.OPEN;
    }
}