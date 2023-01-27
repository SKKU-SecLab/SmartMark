






pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




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
}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




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

}



pragma solidity ^0.8.0;

interface iSkellies {
    function balanceOf(address _user) external view returns(uint256);
    function ownerOf(uint256 _tokenId) external view returns(address);
    function totalSupply() external view returns (uint256);
}

contract BonesOfficial is ERC20("Bones", "BONES"), Ownable {
    struct ContractSettings {
        uint256 baseRate;
        uint256 initIssuance;
        uint256 start;
        uint256 end;
    }

    mapping(address => ContractSettings) public contractSettings;
    mapping(address => bool) public trustedContracts;

    uint256 constant public MAX_BASE_RATE = 10 ether;
    uint256 constant public MAX_INITIAL_ISSUANCE = 70 ether;

    bool public isLocked = false;
    mapping(bytes32 => uint256) public lastClaim;
    
    event RewardPaid(address indexed user, uint256 reward);

    constructor() {}

    function addContract(address _contractAddress, uint256 _baseRate, uint256 _initIssuance) public onlyOwner {
        require(_baseRate <= MAX_BASE_RATE && _initIssuance <= MAX_INITIAL_ISSUANCE, "baseRate or initIssuance exceeds max value.");
        require(!isLocked, "Cannot add any more contracts.");

        trustedContracts[_contractAddress] = true;

        contractSettings[_contractAddress] = ContractSettings({ 
            baseRate: _baseRate,
            initIssuance: _initIssuance,
            start: block.timestamp,
            end: type(uint256).max
        });
    }

    function setEndDateForContract(address _contractAddress, uint256 _endTime) public onlyOwner {
        require(!isLocked, "Cannot modify end dates after lock");
        require(trustedContracts[_contractAddress], "Not a trusted contract");
        
        contractSettings[_contractAddress].end = _endTime;
    }

    function claimReward(address _contractAddress, uint256 _tokenId) public returns (uint256) {
        require(trustedContracts[_contractAddress], "Not a trusted contract.");
        require(contractSettings[_contractAddress].end > block.timestamp, "Time for claiming on that contract has expired.");
        require(iSkellies(_contractAddress).ownerOf(_tokenId) == msg.sender, "Caller does not own the token being claimed for.");

        uint256 unclaimedReward = computeUnclaimedReward(_contractAddress, _tokenId);

        bytes32 lastClaimKey = keccak256(abi.encode(_contractAddress, _tokenId));
        lastClaim[lastClaimKey] = block.timestamp;

        _mint(msg.sender, unclaimedReward);
        emit RewardPaid(msg.sender, unclaimedReward);

        return unclaimedReward;
    }

    function claimRewards(address _contractAddress, uint256[] calldata _tokenIds) public returns (uint256) {
        require(trustedContracts[_contractAddress], "Not a trusted contract.");
        require(contractSettings[_contractAddress].end > block.timestamp, "Time for claiming has expired");

        uint256 totalUnclaimedRewards = 0;

        for(uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _tokenId = _tokenIds[i];

            require(iSkellies(_contractAddress).ownerOf(_tokenId) == msg.sender, "Caller does not own the token being claimed for.");

            uint256 unclaimedReward = computeUnclaimedReward(_contractAddress, _tokenId);
            totalUnclaimedRewards = totalUnclaimedRewards + unclaimedReward;

            bytes32 lastClaimKey = keccak256(abi.encode(_contractAddress, _tokenId));
            lastClaim[lastClaimKey] = block.timestamp;
        }

        _mint(msg.sender, totalUnclaimedRewards);
        emit RewardPaid(msg.sender, totalUnclaimedRewards);

        return totalUnclaimedRewards;
    }

    function permanentlyLock() public onlyOwner {
        isLocked = true;
    }

    function getUnclaimedRewardAmount(address _contractAddress, uint256 _tokenId) public view returns (uint256) {
        require(trustedContracts[_contractAddress], "Not a trusted contract");

        uint256 unclaimedReward  = computeUnclaimedReward(_contractAddress, _tokenId);
        return unclaimedReward;
    }

    function getUnclaimedRewardsAmount(address _contractAddress, uint256[] calldata _tokenIds) public view returns (uint256) {
        require(trustedContracts[_contractAddress], "Not a trusted contract");

        uint256 totalUnclaimedRewards = 0;

        for(uint256 i = 0; i < _tokenIds.length; i++) {
            totalUnclaimedRewards += computeUnclaimedReward(_contractAddress, _tokenIds[i]);
        }

        return totalUnclaimedRewards;
    }

    function getTotalUnclaimedRewardsForContract(address _contractAddress) public view returns (uint256) {
        require(trustedContracts[_contractAddress], "Not a trusted contract");

        uint256 totalUnclaimedRewards = 0;
        uint256 totalSupply = iSkellies(_contractAddress).totalSupply();

        for(uint256 i = 0; i < totalSupply; i++) {
            totalUnclaimedRewards += computeUnclaimedReward(_contractAddress, i);
        }

        return totalUnclaimedRewards;
    }

    function getLastClaimedTime(address _contractAddress, uint256 _tokenId) public view returns (uint256) {
        require(trustedContracts[_contractAddress], "Not a trusted contract");

        bytes32 lastClaimKey = keccak256(abi.encode(_contractAddress, _tokenId));

        return lastClaim[lastClaimKey];
    }

    function computeAccumulatedReward(uint256 _lastClaimDate, uint256 _baseRate, uint256 currentTime) internal pure returns (uint256) {
        require(currentTime > _lastClaimDate, "Last claim date must be smaller than block timestamp");

        uint256 secondsElapsed = currentTime - _lastClaimDate;
        uint256 accumulatedReward = secondsElapsed * _baseRate / 1 days;

        return accumulatedReward;
    }
    function TokensOfOwner(address _contractAddress, address address_) public view returns (uint[] memory) {
        require(trustedContracts[_contractAddress], "Not a trusted contract"); 
        uint _balance = iSkellies(_contractAddress).balanceOf(address_); // get balance of address
        uint contractMaxToken = iSkellies(_contractAddress).totalSupply(); //total supply of contract
        uint[] memory _tokens = new uint[](_balance); // initialize array 
        uint _index;
            for (uint id = 1; id <= contractMaxToken; id++) {
                if (address_ == iSkellies(_contractAddress).ownerOf(id)) { _tokens[_index] = id; _index++;}
            }
        return _tokens; 
    }
    

    function computeUnclaimedReward(address _contractAddress, uint256 _tokenId) internal view returns (uint256) {
        require(trustedContracts[_contractAddress], "Not a trusted contract");
        
        iSkellies(_contractAddress).ownerOf(_tokenId);

        bytes32 lastClaimKey = keccak256(abi.encode(_contractAddress, _tokenId));
        uint256 lastClaimDate = lastClaim[lastClaimKey];
        uint256 baseRate = contractSettings[_contractAddress].baseRate;

        if (lastClaimDate != uint256(0)) {
            return computeAccumulatedReward(lastClaimDate, baseRate, block.timestamp);
        } 
        else {
            uint256 totalReward = computeAccumulatedReward(contractSettings[_contractAddress].start, baseRate, block.timestamp) + contractSettings[_contractAddress].initIssuance;

            return totalReward;
        }
    }
}