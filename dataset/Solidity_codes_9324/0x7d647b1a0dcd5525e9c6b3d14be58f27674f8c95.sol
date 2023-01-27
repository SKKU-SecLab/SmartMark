
pragma solidity ^0.8.0;


interface ICitizen {

	function getRewardRate(address _user) external view returns(uint256);


    function getRewardsRateForTokenId(uint256) external view returns(uint256);


    function getCurrentOrFinalTime() external view returns(uint256);


    function reduceRewards(uint256, address) external;


    function increaseRewards(uint256, address) external;


    function getEnd() external returns(uint256);

}

interface IIdentity {

    function ownerOf(uint256 tokenId) external view returns (address owner);

}

interface IVaultBox {

	function getCredits(uint256 tokenId) external view returns (string memory);

    function ownerOf(uint256 tokenId) external view returns (address owner);

}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


contract BYTESContract is Ownable, ERC20("BYTES", "BYTES") {
	using SafeMath for uint256;

    uint256 maxRewardableCitizens;

	mapping(address => uint256) public rewards;
	mapping(address => uint256) public lastUpdate;
    mapping(address => bool) public adminContracts;

    mapping(uint256 => uint256) public identityBoxOpened;
    mapping(uint256 => uint256) public vaultBoxOpenedByIdentity;

	ICitizen public citizenContract;
    IIdentity public identityContract;
    IIdentity public boughtIdentityContract;
    IVaultBox public vaultBoxContract;

	event RewardPaid(address indexed user, uint256 reward);

	constructor() {
        identityContract = IIdentity(0x86357A19E5537A8Fba9A004E555713BC943a66C0);
        vaultBoxContract = IVaultBox(0xab0b0dD7e4EaB0F9e31a539074a03f1C1Be80879);
        maxRewardableCitizens = 2501;
	}

    function openVaultBox(uint256 identityTokenId, uint256 vaultBoxTokenId) public 
    {
        require(identityBoxOpened[identityTokenId] == 0, "That identity has already opened a box");
        require(vaultBoxOpenedByIdentity[vaultBoxTokenId] == 0, "That box has already been opened");
        require(validateIdentity(identityTokenId), "You don't own that identity");
        require(vaultBoxContract.ownerOf(vaultBoxTokenId) == msg.sender, "You don't own that vault box");

        uint credits;
        bool valueReturned; 
        (credits, valueReturned) = strToUint(vaultBoxContract.getCredits(vaultBoxTokenId));

        uint payout = credits * 10 ** 18;

        if(valueReturned)
        {
            _mint(msg.sender, payout);
            identityBoxOpened[identityTokenId] = vaultBoxTokenId;
            vaultBoxOpenedByIdentity[vaultBoxTokenId] = identityTokenId;
        }
    }

    function hasVaultBoxBeenOpened(uint256 tokenId) public view returns(bool)
    {
        if(vaultBoxOpenedByIdentity[tokenId] == 0)
        {
            return false;
        }

        return true;
    }

    function hasIdentityOpenedABox(uint256 tokenId) public view returns(bool)
    {
        if(identityBoxOpened[tokenId] == 0)
        {
            return false;
        }

        return true;
    }

    function updateMaxRewardableTokens(uint256 _amount) public onlyOwner
    {
        maxRewardableCitizens = _amount;
    }

    function addAdminContractAddress(address _address) public onlyOwner
    {
        adminContracts[_address] = true;
    }

    function removeAdminContactAddress(address _address) public onlyOwner
    {
        adminContracts[_address] = false;
    }

    function validateIdentity(uint256 tokenId) internal view returns(bool)
    {
        if(tokenId < 2300)
        {
            if(identityContract.ownerOf(tokenId) == msg.sender)
            {
                return true;
            }
        }
        else
        {
            if(boughtIdentityContract.ownerOf(tokenId) == msg.sender)
            {
                return true;
            }
        }

        return false;

    }

    function setIdentityContract(address _address) public onlyOwner {
        identityContract = IIdentity(_address);
    }

    function setBoughtIdentityContract(address _address) public onlyOwner {
        boughtIdentityContract = IIdentity(_address);
    }

    function setVaultBoxContract(address _address) public onlyOwner {
        vaultBoxContract = IVaultBox(_address);
    }

    function setCitizenContract(address _address) public onlyOwner {
        adminContracts[_address] = true;
        citizenContract = ICitizen(_address);
    }

	function updateRewardOnMint(address _user, uint256 tokenId) external {
		require(msg.sender == address(citizenContract), "Can't call this");
		uint256 time;
		uint256 timerUser = lastUpdate[_user];

        time = citizenContract.getCurrentOrFinalTime();


		if (timerUser > 0)
        {
            rewards[_user] = rewards[_user].add(citizenContract.getRewardRate(_user).mul((time.sub(timerUser))).div(86400));
        }

        uint256 rateDelta = citizenContract.getRewardsRateForTokenId(tokenId);

        citizenContract.increaseRewards(rateDelta, _user);

		lastUpdate[_user] = time;
	}

	function updateReward(address _from, address _to, uint256 _tokenId) external {
		require(msg.sender == address(citizenContract));
		if (_tokenId < maxRewardableCitizens) {
			uint256 time;
			uint256 timerFrom = lastUpdate[_from];

            uint256 END = citizenContract.getEnd();

            time = citizenContract.getCurrentOrFinalTime();

            uint256 rateDelta = citizenContract.getRewardsRateForTokenId(_tokenId);

			if (timerFrom > 0)
            {
                rewards[_from] += citizenContract.getRewardRate(_from).mul((time.sub(timerFrom))).div(86400);
            }
			if (timerFrom != END)
            {
				lastUpdate[_from] = time;
            }
			if (_to != address(0)) {
				uint256 timerTo = lastUpdate[_to];
				if (timerTo > 0)
                {
                    rewards[_to] += citizenContract.getRewardRate(_to).mul((time.sub(timerTo))).div(86400);
                }
				if (timerTo != END)
                {
					lastUpdate[_to] = time;
                }
			}

            citizenContract.reduceRewards(rateDelta, _from);
            citizenContract.increaseRewards(rateDelta, _to);
		}
	}

	function getReward(address _to) external {
		require(msg.sender == address(citizenContract));
		uint256 reward = rewards[_to];
		if (reward > 0) {
			rewards[_to] = 0;
			_mint(_to, reward * 10 ** 18);
			emit RewardPaid(_to, reward);
		}
	}

	function burn(address _from, uint256 _amount) external {
		require(adminContracts[msg.sender], "You are not approved to burn tokens");
		_burn(_from, _amount);
	}

	function getTotalClaimable(address _user) external view returns(uint256) {
		
        uint256 time = citizenContract.getCurrentOrFinalTime();

        uint256 pending = citizenContract.getRewardRate(_user).mul((time.sub(lastUpdate[_user]))).div(86400);
		return rewards[_user] + pending;
	}

    function strToUint(string memory _str) public pure returns(uint256 res, bool err) {
    for (uint256 i = 0; i < bytes(_str).length; i++) {
        if ((uint8(bytes(_str)[i]) - 48) < 0 || (uint8(bytes(_str)[i]) - 48) > 9) {
            return (0, false);
        }
        res += (uint8(bytes(_str)[i]) - 48) * 10**(bytes(_str).length - i - 1);
    }
    
    return (res, true);
}
}