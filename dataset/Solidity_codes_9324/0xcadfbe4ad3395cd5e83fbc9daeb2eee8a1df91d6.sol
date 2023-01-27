
pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

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
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}// SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;

interface ERC20Permit {
    function approve(address usr, uint wad) external returns (bool);
    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}// MIT
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;



contract ImpactPayment is Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    uint public total_transactions = 0;
    Counters.Counter private _campaignIds;
    Counters.Counter private _campaignsCompleted;
    
    struct ImpactCampaign {
        uint256 id;
        address campaignOwner;
        string campaignName;
        string ownerName;
        bool complete;
    }

    struct Donation {
        address donor;
        uint256 donationAmount;
    }

    mapping(address => bool) public tokens_allowed;
    address private _baseTokenAddress;
    address private _wETH9Address;
    address private immutable swapRouter;
    uint24 private constant poolFee = 3000;
    uint32 private constant tickWindow = 100;
    
    mapping(address => uint256) public deposits; // total deposited funds for a user

    mapping(uint256 => mapping(address => uint256)) public campaignDeposits; // total deposited funds for a user
    mapping(uint256 => uint256) public campaignFunds; // total funds of a campaign
    mapping(uint256 => ImpactCampaign) public idToImpactCampaign; // impact campaigns that are launched
    mapping(address => uint256[]) public userToImpactCampaignIds;
    mapping(uint256 => address[]) public impactCampaignIdsToUsers;

    event CampaignCreated(uint256 indexed id, address campaignOwner, string campaignName, string ownerName);
    event Deposit(address indexed sender, uint256 amount, uint256 campaignId);
    event Withdraw(address indexed recipient, uint256 amount, uint256 campaignId);
    
    constructor(address[] memory tokenAddresses, address baseTokenAddress, address wETH9Address, address swapRouterAddress) {
        for(uint256 i = 0; i < tokenAddresses.length; i++) {
            tokens_allowed[tokenAddresses[i]] = true;
        }
        _baseTokenAddress = baseTokenAddress;
        _wETH9Address = wETH9Address;
        swapRouter = swapRouterAddress;
    }
    
    function getCampaignFunds(uint256 campaignId) public view returns (uint256) {
        return campaignFunds[campaignId];
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint256) {
        return deposits[userAddress];
    }

    function getUserCampaignDeposits(uint256 campaignId, address userAddress) public view returns (uint256) {
        return campaignDeposits[campaignId][userAddress];
    }

    function getUserDonatedCampaigns(address userAddress) public view returns (ImpactCampaign[] memory) {
        uint256[] memory userDonatedCampaignIds = userToImpactCampaignIds[userAddress];
        ImpactCampaign[] memory userDonatedCampaigns = new ImpactCampaign[](userDonatedCampaignIds.length);
        for(uint256 i = 0; i < userDonatedCampaignIds.length; i++) {
            userDonatedCampaigns[i] = idToImpactCampaign[userDonatedCampaignIds[i]];
        }
        return userDonatedCampaigns;
    }

    function getUserDonationsToCampaign(uint256 campaignId) public view returns (Donation[] memory) {
        address[] memory usersThatDonatedToCampaign = impactCampaignIdsToUsers[campaignId];
        Donation[] memory userDonations = new Donation[](usersThatDonatedToCampaign.length);
        for (uint256 i = 0; i < usersThatDonatedToCampaign.length; i++) {
            userDonations[i] = Donation(
                usersThatDonatedToCampaign[i],
                campaignDeposits[campaignId][usersThatDonatedToCampaign[i]]
            );
        }
        return userDonations;
    }

    function getCampaigns() public view returns (ImpactCampaign[] memory) {
        uint256 campaignCount = _campaignIds.current();
        ImpactCampaign[] memory impactCampaigns = new ImpactCampaign[](campaignCount);
        for(uint256 i = 0; i < campaignCount; i++) {
            impactCampaigns[i] = idToImpactCampaign[i+1];
        }
        return impactCampaigns;
    }
    
    function getActiveCampaigns() public view returns (ImpactCampaign[] memory) {
        uint256 campaignCount = _campaignIds.current() - _campaignsCompleted.current();
        ImpactCampaign[] memory impactCampaigns = new ImpactCampaign[](campaignCount);
        for(uint256 i = 0; i < campaignCount; i++) {
            if (!idToImpactCampaign[i+1].complete) {
                impactCampaigns[i] = idToImpactCampaign[i+1];
            }
        }
        return impactCampaigns;
    }
    
    function getCompletedCampaigns() public view returns (ImpactCampaign[] memory) {
        uint256 campaignCount = _campaignsCompleted.current();
        ImpactCampaign[] memory impactCampaigns = new ImpactCampaign[](campaignCount);
        for(uint256 i = 0; i < campaignCount; i++) {
            if (idToImpactCampaign[i+1].complete) {
                impactCampaigns[i] = idToImpactCampaign[i+1];
            }
        }
        return impactCampaigns;
    }
    
    function createCampaign(address campaignOwner, string memory campaignName, string memory ownerName) public onlyOwner {
        _campaignIds.increment();
        uint256 campaignId = _campaignIds.current();
        idToImpactCampaign[campaignId] = ImpactCampaign(
            campaignId,
            campaignOwner,
            campaignName,
            ownerName,
            false
        );
        emit CampaignCreated(campaignId, campaignOwner, campaignName, ownerName);
    }

    function endCampaign(uint256 campaignId) public onlyOwner {
        require(campaignId < _campaignIds.current(), "Invalid campaign id");
        ImpactCampaign storage currCampaign = idToImpactCampaign[campaignId];
        currCampaign.complete = true;
        _campaignsCompleted.increment();
    }

    function withdrawFunds(uint256 campaignId, uint256 amount) public onlyOwner {
        require(ERC20(_baseTokenAddress).balanceOf(address(this)) >= amount,
                "There are not sufficient funds for this withdrawal");
        require(campaignFunds[campaignId] >= amount,
                "This campaign does not have sufficient funds for this withdrawal");
        address campaignOwner = idToImpactCampaign[campaignId].campaignOwner;
        ERC20(_baseTokenAddress).transfer(campaignOwner, amount);
        campaignFunds[campaignId] -= amount;
        emit Withdraw(campaignOwner, amount, campaignId);
    }

    function withdrawFundsETH(uint256 campaignId, uint256 amount) public onlyOwner {
        require(campaignFunds[campaignId] >= amount, 
                "This campaign does not have sufficient funds for this withdrawal");
        require(address(this).balance >= amount, 
                "This campaign does not have sufficient ETH for this withdrawal");
        address campaignOwner = idToImpactCampaign[campaignId].campaignOwner;
        payable(campaignOwner).transfer(amount);
        emit Withdraw(campaignOwner, amount, campaignId);
    }

    function depositFunds(address tokenAddress, uint256 amount, uint256 campaignId) public {
        require(tokens_allowed[tokenAddress], "We do not accept deposits of this ERC20 token");
        require(ERC20(tokenAddress).balanceOf(msg.sender) >= amount, 
                "You do not have sufficient funds to make this purchase");
        ERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        uint256 amountOut = amount;
        deposits[msg.sender] += amountOut;
        userToImpactCampaignIds[msg.sender].push(campaignId);
        impactCampaignIdsToUsers[campaignId].push(msg.sender);
        campaignDeposits[campaignId][msg.sender] += amountOut;
        campaignFunds[campaignId] += amountOut;
        total_transactions++;
        emit Deposit(msg.sender, amountOut, campaignId);
    }
    
    function depositFundsETH(uint256 campaignId) public payable {
        uint256 amountOut = msg.value;
        deposits[msg.sender] += amountOut;
        userToImpactCampaignIds[msg.sender].push(campaignId);
        impactCampaignIdsToUsers[campaignId].push(msg.sender);
        campaignDeposits[campaignId][msg.sender] += amountOut;
        campaignFunds[campaignId] += amountOut;
        total_transactions++;
        emit Deposit(msg.sender, amountOut, campaignId);
    }
    
    function allowTokenDeposits(address tokenAddress) public onlyOwner {
        tokens_allowed[tokenAddress] = true;
    }
}