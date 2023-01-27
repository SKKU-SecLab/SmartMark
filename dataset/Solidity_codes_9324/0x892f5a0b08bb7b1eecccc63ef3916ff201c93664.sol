



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



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



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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



pragma solidity ^0.6.0;





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


        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {



        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {



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


pragma solidity ^0.6.2;


contract ERC20TransferBurn is ERC20 {
    using SafeMath for uint256;

    constructor (string memory name, string memory symbol) ERC20(name, symbol) public {}

    uint256 private _burnDivisor = 100;

    function burnDivisor() public view virtual returns (uint256) {
        return _burnDivisor;
    }

    function _setBurnDivisor(uint256 burnDivisor) internal virtual {
        require(burnDivisor > 0, "_setBurnDivisor burnDivisor must be bigger than 0");
        _burnDivisor = burnDivisor;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 burnAmount = amount.div(_burnDivisor);
        burn(msg.sender, burnAmount);
        return super.transfer(recipient, amount.sub(burnAmount));
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 burnAmount = amount.div(_burnDivisor);
        burn(sender, burnAmount);
        return super.transferFrom(sender, recipient, amount.sub(burnAmount));
    }

    uint256 private _totalSupplyBurned;

    function totalSupplyBurned() public view virtual returns (uint256) {
        return _totalSupplyBurned;
    }

    function burn(address account, uint256 amount) private {
        _burn(account, amount);
        _totalSupplyBurned = _totalSupplyBurned.add(amount);
    }
}



pragma solidity ^0.6.0;


contract ERC20ElasticTransferBurn is ERC20TransferBurn {
    using SafeMath for uint256;

    constructor (string memory name, string memory symbol) ERC20TransferBurn(name, symbol) public {}

    uint256 private _elasticMultiplier = 100;

    function elasticMultiplier() public view virtual returns (uint256) {
        return _elasticMultiplier;
    }

    function _setElasticMultiplier(uint256 elasticMultiplier) internal virtual {
        require(elasticMultiplier > 0, "_setElasticMultiplier elasticMultiplier must be bigger than 0");
        _elasticMultiplier = elasticMultiplier;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return super.balanceOf(account).mul(_elasticMultiplier);
    }

    function totalSupplyElastic() public view virtual returns (uint256) {
        return super.totalSupply().mul(_elasticMultiplier);
    }

    function balanceOfRaw(address account) public view virtual returns (uint256) {
        return super.balanceOf(account);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        return super.transfer(recipient, amount.div(_elasticMultiplier));
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        return super.transferFrom(sender, recipient, amount.div(_elasticMultiplier));
    }
}



pragma solidity ^0.6.0;

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.6.2;



contract BloodyToken is ERC20ElasticTransferBurn("BloodyToken", "BLOODY"), Ownable {
    using SafeMath for uint256;

    uint256 public transferVolumeNowBucket;
    uint256 public transferVolume1HourAgoBucket;

    uint256 public transferVolumeNowBucketTimestamp;

    constructor() public {
        _setBurnDivisor(100);
        _setElasticMultiplier(10);

        transferAfterRebaseFreezeTime = 5 minutes;

        transferVolumeNowBucketTimestamp = getTransferVolumeNowBucketTimestamp();
    }

    function getTransferVolumeNowBucketTimestamp() public view returns (uint256) {
        return block.timestamp - (block.timestamp % 3600);
    }

    event Rebase(
        uint256 indexed transferVolumeNowBucketTimestamp, uint256 burnDivisor, uint256 elasticMultiplier, 
        uint256 transferVolume1HourAgoBucket, uint256 transferVolume2HoursAgoBucket
    );

    uint256 public lastRebaseTimestamp;
    uint256 public transferAfterRebaseFreezeTime;

    function rebase() public {
        require(requiresRebase() == true, "someone else called rebase already");

        uint256 transferVolume2HoursAgoBucket = transferVolume1HourAgoBucket;
        transferVolume1HourAgoBucket = transferVolumeNowBucket;
        transferVolumeNowBucket = 0;

        transferVolumeNowBucketTimestamp = getTransferVolumeNowBucketTimestamp();

        uint256 uniswapPairReward = transferVolume1HourAgoBucket.div(burnDivisor()).div(2);
        mintToUniswapPairs(uniswapPairReward);

        uint256 newBurnDivisor = calculateBurnDivisor(burnDivisor(), transferVolume1HourAgoBucket, transferVolume2HoursAgoBucket);
        uint256 newElasticMultiplier = uint256(1000).div(newBurnDivisor);
        _setBurnDivisor(newBurnDivisor);
        _setElasticMultiplier(newElasticMultiplier);
        emit Rebase(transferVolumeNowBucketTimestamp, newBurnDivisor, newElasticMultiplier, transferVolume1HourAgoBucket, transferVolume2HoursAgoBucket);

        syncUniswapPairs();

        setRequiresRebase(false);
        lastRebaseTimestamp = block.timestamp;
    }

    uint256 public constant minBurnPercent = 1;
    uint256 public constant maxBurnPercent = 12;
    uint256 public constant minBurnDivisor = 100 / maxBurnPercent;
    uint256 public constant maxBurnDivisor = 100 / minBurnPercent;

    function calculateBurnDivisor(uint256 _previousBurnDivisor, uint256 _transferVolume1HourAgoBucket, uint256 _transferVolume2HoursAgoBucket) public view returns (uint256) {
        int256 divisionPrecision = 10000;
        int256 preciseMinBurnPercent = int256(minBurnPercent) * divisionPrecision;
        int256 preciseMaxBurnPercent = int256(maxBurnPercent) * divisionPrecision;
        if (_previousBurnDivisor == 0) {
            return minBurnDivisor;
        }
        int256 precisePreviousBurnPercent = (100 * divisionPrecision) / int256(_previousBurnDivisor);

        if (_transferVolume1HourAgoBucket == _transferVolume2HoursAgoBucket) {
            if (precisePreviousBurnPercent < preciseMinBurnPercent) {
                return maxBurnDivisor;
            }
            else if (precisePreviousBurnPercent > preciseMaxBurnPercent) {
                return minBurnDivisor;
            }
            else {
                return _previousBurnDivisor;
            }
        }

        bool volumeHasIncreased = _transferVolume1HourAgoBucket > _transferVolume2HoursAgoBucket;

        if (volumeHasIncreased) {
            if (precisePreviousBurnPercent >= preciseMaxBurnPercent) {
                return minBurnDivisor;
            }
        }
        else {
            if (precisePreviousBurnPercent <= preciseMinBurnPercent) {
                return maxBurnDivisor;
            }
        }

        int256 transferVolumeRatio;
        if (_transferVolume1HourAgoBucket == 0) {
            transferVolumeRatio = -int256(_transferVolume2HoursAgoBucket + 1);
        }
        else if (_transferVolume2HoursAgoBucket == 0) {
            transferVolumeRatio = int256(_transferVolume1HourAgoBucket + 1);
        }
        else if (volumeHasIncreased) {
            transferVolumeRatio = int256(_transferVolume1HourAgoBucket / _transferVolume2HoursAgoBucket);
        }
        else {
            transferVolumeRatio = -int256(_transferVolume2HoursAgoBucket / _transferVolume1HourAgoBucket);
        }

        int256 preciseNewBurnPercent = calculateBurnPercentFromTransferVolumeRatio(
            precisePreviousBurnPercent,
            transferVolumeRatio * divisionPrecision, 
            preciseMinBurnPercent, 
            preciseMaxBurnPercent
        );

        return uint256((100 * divisionPrecision) / preciseNewBurnPercent);
    }

    function calculateBurnPercentFromTransferVolumeRatio(int256 _previousBurnPercent, int256 _transferVolumeRatio, int256 _minBurnPercent, int256 _maxBurnPercent) public pure returns (int256) {

        if (_previousBurnPercent < _minBurnPercent) {
            _previousBurnPercent = _minBurnPercent;
        }
        else if (_previousBurnPercent > _maxBurnPercent) {
            _previousBurnPercent = _maxBurnPercent;
        }

        int256 burnPercentModifier = _transferVolumeRatio;
        int8 maxAttempt = 5;
        while (true) {
            int256 newBurnPercent = _previousBurnPercent + burnPercentModifier;
            if (newBurnPercent < _maxBurnPercent && newBurnPercent > _minBurnPercent) {
                return _previousBurnPercent + burnPercentModifier;
            }

            if (maxAttempt-- == 0) {
                if (_transferVolumeRatio > 0) {
                    return _maxBurnPercent;
                }
                else {
                    return _minBurnPercent;
                }
            }

            burnPercentModifier = burnPercentModifier / 2;
        }
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(requiresRebase() == false, "transfers are frozen until someone calls rebase");
        require(transfersAreFrozenAfterRebase() == false, "transfers are frozen for a few minutes after rebase");
        super.transfer(recipient, amount);
        updateTransferVolume(amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(requiresRebase() == false, "transfers are frozen until someone calls rebase");
        require(transfersAreFrozenAfterRebase() == false, "transfers are frozen for a few minutes after rebase");
        super.transferFrom(sender, recipient, amount);
        updateTransferVolume(amount);
        return true;
    }

    function updateTransferVolume(uint256 volume) internal virtual {
        transferVolumeNowBucket = transferVolumeNowBucket.add(volume.div(elasticMultiplier()));

        if (transferVolumeNowBucketTimestamp != getTransferVolumeNowBucketTimestamp()) {
            setRequiresRebase(true);
        }
    }

    function transfersAreFrozenAfterRebase() public view returns (bool) {
        if (lastRebaseTimestamp + transferAfterRebaseFreezeTime < block.timestamp) {
            return false;
        }
        return true;
    }

    bool private _requiresRebase = false;
    uint256 private lastSetRequiresRebaseTimestamp;

    function requiresRebase() public view returns (bool) {
        if (_requiresRebase) {
            if (lastSetRequiresRebaseTimestamp < block.timestamp) {
                return true;
            }
        }
        return false;
    }

    function setRequiresRebase (bool value) internal {
        _requiresRebase = value;
        lastSetRequiresRebaseTimestamp = block.timestamp;
    }

    address public bloodyEthUniswapPair;
    address public bloodyNiceUniswapPair;
    address public bloodyRotUniswapPair;

    function setUniswapPairs(address _bloodyEthUniswapPair, address _bloodyNiceUniswapPair, address _bloodyRotUniswapPair) public virtual onlyOwner {
        bloodyEthUniswapPair = _bloodyEthUniswapPair;
        bloodyNiceUniswapPair = _bloodyNiceUniswapPair;
        bloodyRotUniswapPair = _bloodyRotUniswapPair;
    }

    function mintToUniswapPairs(uint256 uniswapPairRewardAmount) internal {
        if (uniswapPairRewardAmount == 0) {
            return;
        }
        uint256 amountPerPair = uniswapPairRewardAmount.div(3);
        if (uniswapPairRewardAmount == 0) {
            return;
        }
        if (bloodyEthUniswapPair != address(0)) {
            _mint(bloodyEthUniswapPair, amountPerPair);
        }
        if (bloodyNiceUniswapPair != address(0)) {
            _mint(bloodyNiceUniswapPair, amountPerPair);
        }
        if (bloodyRotUniswapPair != address(0)) {
            _mint(bloodyRotUniswapPair, amountPerPair);
        }
    }

    function syncUniswapPairs() internal {
        if (bloodyEthUniswapPair != address(0)) {
            IUniswapV2Pair(bloodyEthUniswapPair).sync();
        }
        if (bloodyNiceUniswapPair != address(0)) {
            IUniswapV2Pair(bloodyNiceUniswapPair).sync();
        }
        if (bloodyRotUniswapPair != address(0)) {
            IUniswapV2Pair(bloodyRotUniswapPair).sync();
        }
    }

    function airdrop(address[] memory recipients, uint256[] memory amounts) public onlyOwner {
        for (uint i = 0; i < recipients.length; i++) {
            _mint(recipients[i], amounts[i]);
        }
    }

    function totalSupplyBurnedElastic() external view returns (uint256) {
        return totalSupplyBurned().mul(elasticMultiplier());
    }

    function totalSupplyBurnedMinusRewards() public view returns (uint256) {
        return totalSupplyBurned().div(2);
    }

    function timeUntilNextRebase() external view returns (uint256) {
        uint256 rebaseTime = transferVolumeNowBucketTimestamp + 3600;
        if (rebaseTime <= block.timestamp) {
            return 0;
        }
        return rebaseTime - block.timestamp;
    }

    function nextRebaseTimestamp() external view returns (uint256) {
        return transferVolumeNowBucketTimestamp + 3600;
    }

    function transfersAreFrozen() external view returns (bool) {
        if (transfersAreFrozenAfterRebase() || requiresRebase()) {
            return true;
        }
        return false;
    }

    function transfersAreFrozenRequiresRebase() external view returns (bool) {
        return requiresRebase();
    }

    function timeUntilNextTransferAfterRebaseUnfreeze() external view virtual returns (uint256) {
        uint256 unfreezeTime = lastRebaseTimestamp + transferAfterRebaseFreezeTime;
        if (unfreezeTime <= block.timestamp) {
            return 0;
        }
        return unfreezeTime - block.timestamp;
    }

    function nextTransferAfterRebaseUnfreezeTimestamp() external view virtual returns (uint256) {
        return lastRebaseTimestamp + transferAfterRebaseFreezeTime;
    }

    function balanceInUniswapPair(address user, address uniswapPair) public view returns (uint256) {
        if (uniswapPair == address(0)) {
            return 0;
        }
        uint256 pairBloodyBalance = balanceOf(uniswapPair);
        if (pairBloodyBalance == 0) {
            return 0;
        }
        uint256 userLpBalance = IUniswapV2Pair(uniswapPair).balanceOf(user);
        if (userLpBalance == 0) {
            return 0;
        }
        uint256 lpTotalSupply = IUniswapV2Pair(uniswapPair).totalSupply();
        uint256 divisionPrecision = 1e12;
        uint256 userLpTotalOwnershipRatio = userLpBalance.mul(divisionPrecision).div(lpTotalSupply);
        return pairBloodyBalance.mul(userLpTotalOwnershipRatio).div(divisionPrecision);
    }

    function balanceInUniswapPairs(address user) public view returns (uint256) {
        return balanceInUniswapPair(user, bloodyEthUniswapPair)
            .add(balanceInUniswapPair(user, bloodyNiceUniswapPair))
            .add(balanceInUniswapPair(user, bloodyRotUniswapPair));
    }

    function balanceIncludingUniswapPairs(address user) external view returns (uint256) {
        return balanceOf(user).add(balanceInUniswapPairs(user));
    }
}

interface IUniswapV2Pair {
    function sync() external;
    function balanceOf(address owner) external view returns (uint);
    function totalSupply() external view returns (uint);
}