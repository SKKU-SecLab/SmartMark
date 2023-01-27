
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
}// MIT
pragma solidity 0.8.13;

interface iNFT {
	function getMintingRate(address _address) external view returns(uint256);
}// MIT
pragma solidity 0.8.13;



contract SpaceMilk is ERC20, Ownable {
    struct CollectionInfo {
        string name;
        address contractAddress;
        uint128 boostCap;
        uint128 remainingBoost;
        uint128 hardCap;
        uint128 remainingSupply;
    }
    mapping(uint256 => CollectionInfo) public collectionInfo;

    struct UserInfo {
        uint128 waitingRewards;
        uint128 rewards;
    }
    mapping(address => mapping(uint256 => UserInfo)) public userInfo;
    mapping(address => mapping(uint256 => uint256)) public lastUpdate;

    uint256 public startTimer;

    event RewardPaid(address indexed user, uint256 collection, uint256 reward);
    event BurnedTokens(address indexed user, uint256 collection, uint256 amount);

    constructor(string memory _name, string memory _symbol, uint256 _timer)
    ERC20(_name, _symbol) {
        startTimer = _timer;

        _mint(msg.sender, 6182917500000000000000000);
    }

    function setCollectionInfo(uint256 _collectionIndex, string memory _name, uint128 _boostCap, uint128 _hardCap, address _contract) external onlyOwner {
        collectionInfo[_collectionIndex] = CollectionInfo(_name, _contract, _boostCap, _boostCap, _hardCap, _hardCap);
    }
    
    function setStartTimer(uint256 _newTimer) external onlyOwner {
        startTimer = _newTimer;
    }

    function updateUserTimer(address _user, uint256 _collection, uint256 _newTimer) external onlyOwner {
        lastUpdate[_user][_collection] = _newTimer;
    }

    function fullRewardUpdate(address _user, uint256 _rate, uint256 _collection) external {
        require(msg.sender == address(collectionInfo[_collection].contractAddress), "Can't call direct");
        setRewards(_user, _rate, _collection);
    }

    function updateReward(address _from, uint256 _fromRate, address _to, uint256 _toRate, uint256 _collection)
    external {
        require(msg.sender == address(collectionInfo[_collection].contractAddress), "Can't call direct");
        uint256 timestamp = block.timestamp;
        if (_from != address(0)) {
            getPendingReward(_from, _fromRate, timestamp, _collection);
            lastUpdate[_from][_collection] = timestamp;
        }

        if (_to != address(0)) {
            if (_toRate != 0) {
                getPendingReward(_to, _toRate, timestamp, _collection);
                lastUpdate[_to][_collection] = timestamp;
            } else {
                lastUpdate[_to][_collection] = timestamp;
            }
        }
    }

    function getReward(address _to, uint256 _collection)
    external {
        require(msg.sender == address(collectionInfo[_collection].contractAddress), "Can't call direct");
        UserInfo memory _info = userInfo[_to][_collection];
        require(_info.rewards > 0, "No rewards to claim");

        _mint(_to, _info.rewards);
        emit RewardPaid(_to, _collection, _info.rewards);
        userInfo[_to][_collection] = UserInfo(_info.waitingRewards, 0);
	}

    function burn(address _from, uint256 _collection, uint256 _amount)
    external {
        require(msg.sender == address(collectionInfo[_collection].contractAddress), "Can't call direct");
		_burn(_from, _amount);
        emit BurnedTokens(_from, _collection, _amount);
	}

    function getTotalClaimable(address _user, uint256 _collection) external view returns(uint256) {
        CollectionInfo memory _collectionInfo = collectionInfo[_collection];

        require(_collectionInfo.remainingSupply > 0, "Supply is fully minted");
        UserInfo memory _info = userInfo[_user][_collection];
        uint256 _userTimer = lastUpdate[_user][_collection];

        uint256 userTimer = (block.timestamp - (_userTimer > startTimer - 1 ? _userTimer : startTimer));
        require(userTimer > 0, "Pending reward timer is more than 0");

        iNFT _c = iNFT(_collectionInfo.contractAddress);
        uint256 pendingMintingRate = _c.getMintingRate(_user);
        uint256 pendingRewards = pendingMintingRate * userTimer / 86400;
        pendingRewards += uint256(_info.waitingRewards);
        (uint128 newpendingRewards,) = calculateRewards(uint128(pendingRewards), _collectionInfo.remainingBoost, _collectionInfo.remainingSupply);

		return _info.rewards + newpendingRewards;
	}

    function calculateRewards(uint128 _mintingAmount, uint128 remainingBoost, uint128 remainingSupply) internal pure returns (uint128, uint128) {
        uint128 boostRewards;
        uint128 finalMintingReward;
        uint128 removedBoost;

        unchecked {
            if (remainingBoost > _mintingAmount * 2) {
                boostRewards = _mintingAmount * 2;
                removedBoost = boostRewards;
            } else if (remainingBoost > 0) {
                boostRewards = _mintingAmount + remainingBoost;
                removedBoost = remainingBoost;
            } else {
                boostRewards = _mintingAmount;
                removedBoost = 0;
            }

            if (remainingSupply < _mintingAmount) {
                finalMintingReward = remainingSupply;
            } else {
                if (remainingSupply < boostRewards) {
                    finalMintingReward = remainingSupply;
                } else {
                    finalMintingReward = boostRewards;
                }
            }
        }

        return (finalMintingReward, removedBoost);
    }

    function setRewards(address _user, uint256 _rate, uint256 _collection) internal {
        CollectionInfo memory _collectionInfo = collectionInfo[_collection];

        if (_collectionInfo.remainingSupply > 0) {
            UserInfo memory _info = userInfo[_user][_collection];
            uint256 _timestamp = block.timestamp;
            uint256 _userTimer = lastUpdate[_user][_collection];

            uint256 userTimer = (_timestamp - (_userTimer > startTimer - 1 ? _userTimer : startTimer));

            uint256 mintingReward = _rate * userTimer / 86400;
            mintingReward += uint256(_info.waitingRewards);
            (uint128 finalReward, uint128 boostSupply) = calculateRewards(uint128(mintingReward), _collectionInfo.remainingBoost, _collectionInfo.remainingSupply);

            collectionInfo[_collection] = CollectionInfo(
                _collectionInfo.name,
                _collectionInfo.contractAddress,
                _collectionInfo.boostCap,
                _collectionInfo.remainingBoost - boostSupply,
                _collectionInfo.hardCap,
                _collectionInfo.remainingSupply - finalReward
            );
            userInfo[_user][_collection] = UserInfo(0, _info.rewards + finalReward);
            lastUpdate[_user][_collection] = _timestamp;
        }
    }

    function getPendingReward(address _user, uint256 _rate, uint256 _timestamp, uint256 _collection) internal {
        UserInfo memory _info = userInfo[_user][_collection];
        uint256 userTimer = lastUpdate[_user][_collection];

        unchecked {
            uint256 _startTimer = startTimer;
            uint256 _timer = (_timestamp - (userTimer > _startTimer - 1 ? userTimer : _startTimer));
            uint256 _newRate = _rate * _timer / 86400;

            userInfo[_user][_collection] = UserInfo(_info.waitingRewards + uint128(_newRate), _info.rewards);
        }
    }
}