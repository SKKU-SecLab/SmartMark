

pragma experimental ABIEncoderV2;
pragma solidity ^0.6.0;
pragma solidity ^0.6.0;
pragma solidity ^0.6.0;
pragma solidity ^0.6.2;
pragma solidity ^0.6.0;
pragma solidity ^0.6.0;
pragma solidity ^0.6.0;
pragma solidity ^0.6.0;
pragma solidity ^0.6.0;
pragma solidity ^0.6.0;
pragma solidity ^0.6.0;
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

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

contract HrsToken is ERC20, Ownable {
    address private _hodlerPool;

    constructor() public ERC20("Hodler Rewards System Token", "HRST") {
        _mint(msg.sender, 1700000000000000000000);
    }




    modifier onlyMinter() {
        require(_hodlerPool == _msgSender(), "Ownable: caller is not the Minter");
        
        
        _;
    }

    function setHodlerPool(address hodlerPool) external onlyOwner
    {
        _hodlerPool = hodlerPool;
    }

    function mint(address _to, uint256 _amount) external onlyMinter returns (bool) 
    {
        _mint(_to, _amount);
        return true;
    }




    function burn(address account, uint256 amount) external onlyMinter {
        _burn(account, amount);
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Queue {
    mapping(uint256 => address) private queue;
    uint256 private _first = 1;
    uint256 private _last = 0;
    uint256 private _count = 0;

    function enqueue(address data) external {
        _last += 1;
        queue[_last] = data;
        _count += 1;
    }

    function dequeue() external returns (address data) {
        require(_last >= _first);  // non-empty queue
        data = queue[_first];
        delete queue[_first];
        _first += 1;
        _count -= 1;
    }

    function count() external view returns (uint256) {
        return _count;
    }

    function getItem(uint256 index) external view returns (address) {
        uint256 correctedIndex = index + _first - 1;
        return queue[correctedIndex];
    }
}

library Library {
  struct staker {
     uint256 sinceBlockNumber;
     uint256 stakingBalance;
     uint256 rewardsBalance; // should only be used to know how much the staker got paid already (while staking)!
     bool exists;
     bool isTopStaker;
   }
}

abstract contract BaseHodlerPool is Ownable {
    using SafeMath for uint256;
    

    function char(byte b) internal  pure returns (byte c) {
        if (uint8(b) < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }

    function addressToString(address x) internal  pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return strConcat("0x", string(s), "", "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function getElementPositionInArray(address[] memory array, address account) internal pure returns(uint) {    
        bool foundElement = false;
        uint index = 0;
        for (uint i = 0; i <= array.length-1; i++){
            if (array[i] == account) {
                index = i;
                foundElement = true;
            }
        }
        require(foundElement == true);
        return index;
    }      

    function getRandomNumber(bool includeMaxNumber, uint256 maxNumber, address acct) internal view returns (uint256) {
       uint256 randomNumber = uint256(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, acct)))%maxNumber);
       if (includeMaxNumber) return randomNumber.add(1);
       else return randomNumber;
    }

}

contract HodlerPool is BaseHodlerPool {
    using SafeMath for uint256;
    using SafeERC20 for HrsToken;
    using Library for Library.staker;

    string public name = "Hodler Pool";
    address private rewardTokenAddress; // HRS Token address
    HrsToken private stakingToken;
    address private devFundAccount;
    uint private stakerLevelNULL = 999999;

    uint256 private totalStakingBalance = 0; // this is the total staking balance
    uint256[] private first40BlockNumbers = new uint256[](0);
    address[] private first40Addresses = new address[](0);
    uint private maxTopStakersByTime = 40;
    Queue private followers = new Queue();
    mapping(address => Library.staker) private _allStakers;

    uint256 private blockStart;
    uint256 private periodFinish; 
    uint256 private penaltyPercentage = 20;

    uint256 private duration;
    uint256 private startTime; //= 1597172400; // 2020-08-11 19:00:00 (UTC UTC +00:00)
    uint256 private rewardsPerTokenStakedPerBlock = 1000000; //0.000001

    event Staked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward, string message);
    event RewardAdded(uint256 reward);
    event Withdrawn(address indexed user, uint256 amount);
    event Log(string message);
    event TokenTransferred(address indexed user, uint256 amount, string message);
    event BurntTokens(address indexed user, uint256 amount);

    constructor(address _rewardTokenAddress, address _devFundAddress) public {
        rewardTokenAddress = _rewardTokenAddress;
        stakingToken = HrsToken(_rewardTokenAddress);
        devFundAccount = _devFundAddress;
        blockStart = block.number;
        startTime = block.timestamp;
        periodFinish = startTime + 26 weeks; // Pool valid for 26 weeks (6 months) since contract is deployed
    }    

    function removeElementFromArray(uint index) private {
        require (index < first40BlockNumbers.length);
        require (index < first40Addresses.length);
        for (uint i = index; i<first40BlockNumbers.length-1; i++){
            first40BlockNumbers[i] = first40BlockNumbers[i+1];
        }
        for (uint i = index; i<first40Addresses.length-1; i++){
            first40Addresses[i] = first40Addresses[i+1];
        }
        first40BlockNumbers.pop();
        first40Addresses.pop();
    }  

    function getFirst40Addresses() external view returns(address  [] memory){
        return first40Addresses;
    }

    function isFollower(address account) external view returns(bool){
        if (_allStakers[account].exists) {
            if (isTopStaker(account)) 
                return false;
            else
                return true;
        } else {
            return false;
        }
    }

    function isTopStaker(address account) public view returns (bool){


        return _allStakers[account].isTopStaker;
    }

    function getStakerLevel(address account) public view returns (uint) {
        uint stakerLevel = 0;
        if (isTopStaker(account)) {
            uint index = getElementPositionInArray(first40Addresses, account);
            stakerLevel = getStakerLevelByIndex(index);
        }
        return stakerLevel;
    }


    function getFollowersCount() external view returns (uint256){
        return followers.count();
    }

    function stake(uint256 amount) external checkStart {
        require(amount > 0, "Cannot stake 0");
        require(block.timestamp < periodFinish, "Pool has expired!");
        totalStakingBalance = totalStakingBalance.add(amount);
        emit Log(strConcat("stake - msg.sender: ", addressToString(msg.sender),"","",""));
        emit Log(strConcat("stake - block.number: ", uint2str(block.number),"","",""));
        _allStakers[msg.sender].sinceBlockNumber = block.number;
        emit Log(strConcat("stake - _allStakers[msg.sender].sinceBlockNumber: ", uint2str(_allStakers[msg.sender].sinceBlockNumber),"","",""));
        _allStakers[msg.sender].stakingBalance = _allStakers[msg.sender].stakingBalance.add(amount);
        _allStakers[msg.sender].rewardsBalance = 0;
        _allStakers[msg.sender].exists = true;
        if (first40BlockNumbers.length < maxTopStakersByTime) {
            first40BlockNumbers.push(block.number);
            first40Addresses.push(msg.sender);
            _allStakers[msg.sender].isTopStaker = true;
        }
        else {
            followers.enqueue(msg.sender);
            _allStakers[msg.sender].isTopStaker = false;
        }
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function getStartTime() external view returns (uint256) {
        return startTime;
    }

    function getPeriodFinish() external view returns (uint256) {
        return periodFinish;
    }

    function getTotalStakingBalance() external view returns (uint256) {
        return totalStakingBalance;
    }

    function stakingBalanceOf(address account) public view returns (uint256) {
        return _allStakers[account].stakingBalance;
    }

    function rewardsBalanceOf(address account) external view returns (uint256) {
        return _allStakers[account].rewardsBalance;
    }


    function getDevFundAccount() external view returns (address) {
        return devFundAccount;
    }

    function exit() external {
        emit Log(strConcat("exit - block.number: ", uint2str(block.number),"","",""));
        emit Log(strConcat("earned: ", uint2str(earned(msg.sender)),"","","")); // 12.48
        uint stakerLevel = getStakerLevel(msg.sender);
        unstake();
        Library.staker memory staker = _allStakers[msg.sender];        
        emit Log(strConcat("staker.stakingBalance: ", uint2str(staker.stakingBalance),"","",""));// 1
        emit Log(strConcat("earned(msg.sender): ", uint2str(earned(msg.sender)),"","",""));// 12.9792
        withdraw(staker.stakingBalance, earned(msg.sender), stakerLevel);
        delete _allStakers[msg.sender]; // delete account from mapping
        
    }

    function unstake() private  {
        bool _isTopStaker = isTopStaker(msg.sender);
        if (_isTopStaker) {
            removeStaker(_isTopStaker, msg.sender);
            _allStakers[msg.sender].isTopStaker = false;
            _allStakers[msg.sender].exists = false;
            if (followers.count() > 0) {
                address follower;
                bool foundOne = false;
                for (uint i = 0; i < 10; i++){
                    follower = followers.dequeue();
                    if (_allStakers[follower].exists) {
                        foundOne = true;
                        break;
                    }
                }
                if (foundOne) {
                    first40BlockNumbers.push(_allStakers[follower].sinceBlockNumber);
                    first40Addresses.push(follower);
                    _allStakers[follower].isTopStaker = true;
                }
                else {
                }
            }
        }
        else {
            followers.dequeue();
        }
    }

    function removeStaker(bool _isTopStaker, address account) private {
        if (_isTopStaker) {
            uint index = getElementPositionInArray(first40Addresses, account);
            removeElementFromArray(index);
        }
    }

    function withdraw(uint256 stakingAmount, uint256 rewardsAmount, uint stakerLevel) private {
        require(stakingAmount > 0, "staking amount has to be > 0");
        stakingToken.mint(address(this), rewardsAmount);
        emit RewardPaid(msg.sender, rewardsAmount, "reward paid/minted (before tax)"); // 0.7436
        uint256 totalAmount = stakingAmount.add(rewardsAmount); // 1.7436
        emit Log(strConcat("totalAmount: ", uint2str(totalAmount),"","",""));
        uint256 taxPercentageBasedOnStakerLevel = getTaxPercentage(stakerLevel);
        emit Log(strConcat("taxPercentageBasedOnStakerLevel: ", uint2str(taxPercentageBasedOnStakerLevel),"","",""));
        uint256 taxedAmount = totalAmount.mul(taxPercentageBasedOnStakerLevel).div(100);
        uint256 actualAmount = totalAmount.sub(taxedAmount); 
        emit Log(strConcat("actualAmount: ", uint2str(actualAmount),"","",""));
        emit Log(strConcat("taxedAmount: ", uint2str(taxedAmount),"","",""));
        manageTaxCollected(taxedAmount); // 0.17436
        totalStakingBalance = totalStakingBalance.sub(stakingAmount);
        _allStakers[msg.sender].stakingBalance = 0;
        _allStakers[msg.sender].rewardsBalance = 0;
        stakingToken.safeTransfer(msg.sender, actualAmount); // this is when the actual staker gets paid (after tax)
        emit Withdrawn(msg.sender, actualAmount);
    }

    function manageTaxCollected(uint256 taxedAmount) private returns (uint256) {

        uint256 tokensForTopStakers = 0;
        uint256 tokensForRandomFollower = 0;
        emit Log(strConcat("followers.count(): ", uint2str(followers.count()),"","",""));
        if (followers.count() > 9) {
            tokensForTopStakers = taxedAmount.mul(90).div(100);
            tokensForRandomFollower = taxedAmount.mul(10).div(100);
            emit Log("Sending 10% of tokens from tax to a random follower, and the rest (90%) to top stakers,");
        }
        else {
            tokensForTopStakers = taxedAmount;
            emit Log("All tokens from tax sent to top stakers");
        }
        
        emit Log(strConcat("taxedAmount: ", uint2str(taxedAmount),"","","")); // 0.34872
        emit Log(strConcat("tokensForTopStakers: ", uint2str(tokensForTopStakers),"","","")); // 0.244104
        emit Log(strConcat("tokensForRandomFollower: ", uint2str(tokensForRandomFollower),"","","")); // 0.069744
        require (taxedAmount == tokensForTopStakers.add(tokensForRandomFollower), "wrong distribution of tax collected");
        distributeTokensToTopStakers(tokensForTopStakers);
        if (tokensForRandomFollower > 0)
            sendTokensToRandomFollower(tokensForRandomFollower);
            
    }

    function distributeTokensToTopStakers(uint256 tokensAmount) private {
        uint256 tokensAmountLeft = tokensAmount;
        for (uint8 i = 0; i < first40Addresses.length; i++) {
            if (tokensAmountLeft > 0) {
                uint256 rewardsForStakingAmount = getRewardsBasedOnStakingAmountScore(tokensAmount, _allStakers[first40Addresses[i]].stakingBalance);
                stakingToken.safeTransfer(first40Addresses[i], rewardsForStakingAmount);
                _allStakers[first40Addresses[i]].rewardsBalance = _allStakers[first40Addresses[i]].rewardsBalance.add(rewardsForStakingAmount);
                tokensAmountLeft = tokensAmountLeft.sub(rewardsForStakingAmount);
                emit RewardPaid(first40Addresses[i], rewardsForStakingAmount, "reward paid from distributeTokensToTopStakers");
            }
            else {
                break;
            }
        }
        if (tokensAmountLeft > 0) {
            sendTokensToDevFund(tokensAmountLeft);
        }
    }

    function getTopStaker() private view returns (address){
        return first40Addresses[0];
    }
    
    function getRandomNumber(uint256 maxNumber, address someAddress) public view returns (uint256) { 
        return getRandomNumber(true, maxNumber, someAddress);
    }

    function getFollower(uint index) external returns (address) { 
        address follower = followers.getItem(index);
        emit Log(strConcat("follower: ", addressToString(follower),"","",""));
        return follower;
    }

    function getRandomFollower() public returns (address) { 
        uint256 randomNumber = getRandomNumber(followers.count(), getTopStaker());
        emit Log(strConcat("followers.count(): ", uint2str(followers.count()),"","",""));
        emit Log(strConcat("randomNumber: ", uint2str(randomNumber),"","",""));
        address randomFollower = followers.getItem(randomNumber);
        emit Log(strConcat("randomFollower: ", addressToString(randomFollower),"","",""));
        return randomFollower;
    }

    function sendTokensToRandomFollower(uint256 tokensAmount) private{
        address randomFollower = getRandomFollower();
        stakingToken.safeTransfer(randomFollower, tokensAmount);
        _allStakers[randomFollower].rewardsBalance = _allStakers[randomFollower].rewardsBalance.add(tokensAmount);
        emit TokenTransferred(randomFollower, tokensAmount, "tokens sent to random follower");
    }

    function burnTokens(uint256 tokensAmount) private{
        stakingToken.burn(address(this), tokensAmount);
        emit BurntTokens(address(this), tokensAmount);
    }

    function sendTokensToDevFund(uint256 tokensAmount) private{
        stakingToken.safeTransfer(devFundAccount, tokensAmount);
        emit TokenTransferred(devFundAccount, tokensAmount, "tokens sent to dev fund");
    }

    function getRewardsBasedOnStakingAmountScore(uint256 totalRewardsBasedOnAmount, uint256 stakerStakingBalance) private view returns (uint256) {

        uint256 stakingPercentage = stakerStakingBalance
                                        .mul(100)
                                        .div(totalStakingBalance);

        uint256 rewardsBasedOnStakingAmountScore = stakingPercentage
                                                        .mul(totalRewardsBasedOnAmount)
                                                        .div(100);

        return rewardsBasedOnStakingAmountScore;
    }

    

    function getStakerLevelByIndex(uint index) private pure returns (uint) {
        uint stakerLevel;
        if (index < 10) {
            stakerLevel = 4; // max level
        }
        else if (index < 20) {
            stakerLevel = 3; // second best level
        }
        else if (index < 30) {
            stakerLevel = 2;
        }
        else {
            stakerLevel = 1;
        }
        return stakerLevel;
    }

    function getPosition(address account) external view returns (uint256)  {
        if (isTopStaker(account)) 
            return (getElementPositionInArray(first40Addresses, account) + 1);
        else {
            return 404;
        }
    }

    function getTotalNumberOfStakers() external view returns (uint256)  {
        return first40Addresses.length + followers.count();
    }

    function poolHasExpired() public view returns (bool)  {
        if (block.timestamp > periodFinish)
            return true;
        else
            return false;
    }

    modifier checkStart(){
        require(block.timestamp >= startTime,"not started");
        _;
    }

    function earned(address account) public view returns (uint256) {
        uint256 earnedBeforeTax;
        if (poolHasExpired()) {
            earnedBeforeTax = 0;
        }
        else {
            earnedBeforeTax = stakingBalanceOf(account)
                .mul(getNumberOfBlocksStaking(account))
                .div(rewardsPerTokenStakedPerBlock);
        }
        return earnedBeforeTax;
    }

    function amountToGetIfUnstaking(address account, uint stakerLevel) public view returns (uint256) {
        if (stakerLevel == stakerLevelNULL)
            stakerLevel = getStakerLevel(account);
        uint256 amountBeforeTax = stakingBalanceOf(account).add(earned(account));
        uint256 taxPercentageBasedOnStakerLevel = getTaxPercentage(stakerLevel);
        uint256 taxToPay = amountBeforeTax.mul(taxPercentageBasedOnStakerLevel).div(100);
        return amountBeforeTax.sub(taxToPay);
    }

    function getTaxPercentage(uint stakerLevel) public view returns (uint256) {
        return penaltyPercentage.sub(stakerLevel.mul(4));
    }

    function getNumberOfBlocksStaking(address account) public view returns (uint256) {
        return block.number.sub(_allStakers[account].sinceBlockNumber);
    }
    
    function skipBlockNumber() external {
        emit Log(strConcat("this block.number: ", uint2str(block.number),"","",""));
    }
}