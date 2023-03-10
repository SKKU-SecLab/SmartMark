
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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

        _beforeTokenTransfer(account, burnAddress(), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
          _balances[account] = accountBalance - amount;
          _balances[burnAddress()] = _balances[burnAddress()] + amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, burnAddress(), amount);

        _afterTokenTransfer(account, burnAddress(), amount);
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

    function burnAddress() public virtual returns (address) {

      return address(0);
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

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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
pragma solidity ^0.8.6;



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


contract Saja is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _isExcludedFromRewards;
    mapping(address => bool) private _holdersExist;
    mapping(address => bool) private _isTctHolders;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _blockNumberByAddress;
    address[] private _tctHolders;
    address[] private _holders;
    address[] private alphaRewardAddresses;
    address[] private lionRewardAddresses;
    address[] private lionessRewardAddresses;
    address[] private cubRewardAddresses;
    address[] private defaultRewardAddresses;
    address private _nonBotAddress;
    uint256 private _alphaLionRewardRate = 350;  //3.5%
    uint256 private _lionRewardRate = 275;  //2.75%
    uint256 private _lionessRewardRate = 250;  //2.5%
    uint256 private _cubRewardRate = 225;  //2.25%
    uint256 private _defaultRate = 200;  //2%
    uint256 private _promotionRate = 1500;  //15% in base points for non TCT holders reward
    bool private _doPromotion = true;
    bool private _botDetectorEnabled = true;
    uint256 private _tctCubTier = 25000000000000000000000000000;
    uint256 private _tctLionessTier = 100000000000000000000000000000;
    uint256 private _tctLionTier = 300000000000000000000000000000;
    uint256 private _tctAlphaTier = 500000000000000000000000000000;
    uint256 private constant _tTotal = 1000000000000 * 10 ** 6 * 10 ** 9;
    uint256 private _maxTxAmount = 1000000000000 * 10 ** 6 * 10 ** 9;
    string private _name = 'Saja';
    string private _symbol = 'SAJA';
    uint8 private _decimals = 9;
    address private _deadAddress = 0x000000000000000000000000000000000000dEaD;
    ERC20 private tctToken;

    constructor () {
        tctToken = ERC20(0x84155b2be780C8eCEdFe06CDaD341f295858579D);
        _isExcludedFromRewards[owner()] = true;
        _isExcludedFromRewards[address(this)] = true;
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function burnAddress() public view returns (address) {
        return _deadAddress;
    }

    function getTctTokenBalance(address addr) public view returns (uint256) {
        return tctToken.balanceOf(addr);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
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

    function getTctTierSettings() public view returns (uint256, uint256, uint256, uint256)  {
        return (_tctCubTier, _tctLionessTier, _tctLionTier, _tctAlphaTier);
    }

    function getTctRateSettings() public view returns (uint256, uint256, uint256, uint256)  {
        return (_cubRewardRate, _lionessRewardRate, _lionRewardRate, _alphaLionRewardRate);
    }

    function getDefaultReflectionRate() public view returns (uint256)  {
        return _defaultRate;
    }

    function getPromotionSettings() public view returns (bool, uint256)  {
        return (_doPromotion, _promotionRate);
    }

    function isBotDectorEnabled() public view returns (bool) {
        return _botDetectorEnabled;
    }

    function setBotDector(bool enableOnDisable) external onlyOwner() {
        _botDetectorEnabled = enableOnDisable;
    }

    function setRewardRates(uint256 defaultRate, uint256 cubRate, uint256 lionessRate, uint256 lionRate, uint256 alphaLionRate) external onlyOwner() {
        _defaultRate = defaultRate;
        _cubRewardRate = cubRate;
        _lionessRewardRate = lionessRate;
        _lionRewardRate = lionRate;
        _alphaLionRewardRate = alphaLionRate;
    }

    function setTctRewardTier(uint256 cubTier, uint256 LionessTier, uint256 lionTier, uint256 alphaTier) external onlyOwner() {
        _tctCubTier = cubTier;
        _tctLionessTier = LionessTier;
        _tctLionTier = lionTier;
        _tctAlphaTier = alphaTier;
    }

    function setPromotion(uint256 promotionRate, bool doPromotion) external onlyOwner() {
        _doPromotion = doPromotion;
        _promotionRate = promotionRate;
    }

    function initTctContract(address contractAddress) external onlyOwner() {
        tctToken = ERC20(contractAddress);
    }

    function taxFreeTransfers(address[] memory addresses, uint256[] memory amounts) external onlyOwner() {
        for (uint256 i = 0; i < addresses.length; i++) {
            address recipient = addresses[i];
            uint256 amount = amounts[i];
            uint256 senderBalance = _balances[msg.sender].sub(amount);
            _balances[msg.sender] = senderBalance;
            _balances[recipient] = _balances[recipient].add(amount);
            addUpdateHolder(recipient);
            emit Transfer(msg.sender, recipient, amount);
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (sender != owner() && recipient != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        if (_isExcludedFromRewards[sender] && !_isExcludedFromRewards[recipient]) {
            _transferTaxFree(sender, recipient, amount);
        } else if (!_isExcludedFromRewards[sender] && _isExcludedFromRewards[recipient]) {
            _transferTaxFree(sender, recipient, amount);
        } else if (!_isExcludedFromRewards[sender] && !_isExcludedFromRewards[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcludedFromRewards[sender] && _isExcludedFromRewards[recipient]) {
            _transferTaxFree(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

    }

    function _transferTaxFree(address sender, address recipient, uint256 amount) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function getValidTransferAddress(address sender, address recipient) internal virtual returns (address) {
        require(!Address.isContract(sender) || !Address.isContract(recipient), 'Bots are not allowed');
        if (Address.isContract(sender)) return recipient;
        else return sender;
    }

    function verifyOneTxPerBlock(address nonBotAdress) internal virtual {
        bool isNewBlock = _blockNumberByAddress[nonBotAdress] == 0 || _blockNumberByAddress[nonBotAdress] < block.number;
        require(isNewBlock, 'Only one transaction per block is allowed');
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {

        if (_botDetectorEnabled) {
            _nonBotAddress = getValidTransferAddress(sender, recipient);
            verifyOneTxPerBlock(_nonBotAddress);
        }
        uint256 alphaLionRewardAmount = amount.div(_alphaLionRewardRate);
        uint256 lionRewarAmount = amount.div(_lionRewardRate);
        uint256 lionessRewardAmount = amount.div(_lionessRewardRate);
        uint256 cubRewardAmount = amount.div(_cubRewardRate);
        uint256 defaultRewardAmount = amount.div(_defaultRate);
        uint256 firstTimeHolderIncentiveAmount = 0;
        uint256 taxTotal = alphaLionRewardAmount.add(lionRewarAmount).add(lionessRewardAmount).add(cubRewardAmount).add(defaultRewardAmount);
        if (_doPromotion && !_holdersExist[recipient] && _isExcludedFromRewards[sender]) {
            firstTimeHolderIncentiveAmount = amount.div(_promotionRate);
            taxTotal = taxTotal.add(firstTimeHolderIncentiveAmount);
        }
        addUpdateHolder(recipient);
        uint256 amountToRecipient = amount.sub(taxTotal).add(firstTimeHolderIncentiveAmount);
        _balances[sender] = _balances[sender].sub(amount);
        _balances[sender] = _balances[sender].sub(firstTimeHolderIncentiveAmount);
        _balances[recipient] = _balances[recipient].add(amountToRecipient);
        distributeTokens(defaultRewardAmount, cubRewardAmount, lionessRewardAmount, lionRewarAmount, alphaLionRewardAmount);
        emit Transfer(sender, recipient, amountToRecipient);

        if (_botDetectorEnabled) {
            _blockNumberByAddress[_nonBotAddress] = block.number;
        }
    }

    function addUpdateHolder(address recipient) private {
        if (!_holdersExist[recipient]) {
            _holders.push(recipient);
            _holdersExist[recipient] = true;
        }
    }

    function distributeTokens(uint256 defaultAmount, uint256 cubAmount, uint256 lionessAmount, uint256 lionAmount, uint256 alphaLionAmount) private {
        clearRewardAddresses();
        uint256 unusedRewards = 0;
        for (uint256 i = 0; i < _holders.length; i++) {
            address holderAddress = _holders[i];
            if (_isExcludedFromRewards[holderAddress]) {
                continue;
            }
            uint256 tctBalance = getTctTokenBalance(holderAddress);
            if (holderAddress != _deadAddress) {
                if (tctBalance >= _tctAlphaTier) {
                    alphaRewardAddresses.push(holderAddress);
                }
                if (tctBalance >= _tctLionTier) {
                    lionRewardAddresses.push(holderAddress);
                }
                if (tctBalance >= _tctLionessTier) {
                    lionessRewardAddresses.push(holderAddress);
                }
                if (tctBalance >= _tctCubTier) {
                    cubRewardAddresses.push(holderAddress);
                }
            }
            defaultRewardAddresses.push(holderAddress);
        }
        unusedRewards = unusedRewards.add(addTokensToAddresses(alphaRewardAddresses, alphaLionAmount));
        unusedRewards = unusedRewards.add(addTokensToAddresses(lionRewardAddresses, lionAmount));
        unusedRewards = unusedRewards.add(addTokensToAddresses(lionessRewardAddresses, lionessAmount));
        unusedRewards = unusedRewards.add(addTokensToAddresses(cubRewardAddresses, cubAmount));
        defaultAmount = defaultAmount.add(unusedRewards);
        addTokensToAddresses(defaultRewardAddresses, defaultAmount);
    }

    function _transferExcludeReflection(address sender, address recipient, uint256 amount) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function addTokensToAddresses(address[] memory addresses, uint256 amountToDistribute) private returns (uint256) {
        if (addresses.length > 0) {
            uint256 distAmount = amountToDistribute.div(addresses.length);

            for (uint256 i = 0; i < addresses.length; i++) {
                address holderAddress = addresses[i];
                _balances[holderAddress] = _balances[holderAddress].add(distAmount);
            }
            return 0;
        } else {
            return amountToDistribute;
        }
    }

    function clearRewardAddresses() private {
        delete alphaRewardAddresses;
        delete lionRewardAddresses;
        delete lionessRewardAddresses;
        delete cubRewardAddresses;
        delete defaultRewardAddresses;
    }

    function includeAccountsForRewards(address[] memory addresses) external onlyOwner() {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            delete _isExcludedFromRewards[addr];
        }
    }

    function excludeAccountsFromRewards(address[] memory accounts) external onlyOwner() {

        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromRewards[accounts[i]] = true;
        }
    }
}
