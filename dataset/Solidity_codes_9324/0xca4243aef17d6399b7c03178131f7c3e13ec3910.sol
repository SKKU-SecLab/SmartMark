
pragma solidity ^0.5.0;

library StakeSet {


    struct Item {
        uint id;
        uint createTime;
        uint power;
        uint aTokenAmount;
        uint payTokenAmount;
        uint stakeType;
        uint coinType;
        address useraddress;

    }

    struct Set {
        Item[] _values;
        mapping (uint => uint) _indexes;
    }

    function add(Set storage set, Item memory value) internal returns (bool) {

        if (!contains(set, value.id)) {
            set._values.push(value);
            set._indexes[value.id] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(Set storage set, Item memory value) internal returns (bool) {

        uint256 valueIndex = set._indexes[value.id];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            Item memory lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue.id] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value.id];

            return true;
        } else {
            return false;
        }
    }

    function contains(Set storage set, uint valueId) internal view returns (bool) {

        return set._indexes[valueId] != 0;
    }

    function length(Set storage set) internal view returns (uint256) {

        return set._values.length;
    }

    function at(Set storage set, uint256 index) internal view returns (Item memory) {

        require(set._values.length > index, "StakeSet: index out of bounds");
        return set._values[index];
    }

    function idAt(Set storage set, uint256 valueId) internal view returns (Item memory) {

        require(set._indexes[valueId] != 0, "StakeSet: set._indexes[valueId] != 0");
        uint index = set._indexes[valueId] - 1;
        require(set._values.length > index, "StakeSet: index out of bounds");
        return set._values[index];
    }

}
pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    function burnFrom(address sender, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.0;

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
pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;
    
    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    
    function safeBurnFrom(IERC20 token, address from, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.burnFrom.selector, from,value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;



contract StakePool is Ownable{

    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using StakeSet for StakeSet.Set;



    uint[4] STAKE_PER = [20, 30, 50, 100];
    uint[4] STAKE_POWER_RATE = [100, 120, 150, 200];

    address constant wethToken = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public payToken =address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address public aToken = address(0x9e2a3340D92d7f24E78a061614b3042422944d75);
    address public secretSigner;

    uint private _totalStakeToken;
    uint private _totalStakeEth;
    uint private _totalStakeUsdt;
    bool private _isOnlyToken;
    uint public currentId;
    uint private _totalOrders;
    uint private _totalWeight;
    mapping(address => uint) private _userOrders;
    mapping(address => uint) private _weights;
    mapping(address => uint) private _withdrawalAmount;
    mapping (address => uint256) private _bypass;
    mapping(address => StakeSet.Set) private _stakeOf;
    mapping(uint => bool) public withdrawRewardIdOf;
    

    mapping(address => address) public lpAddress;


    event Stake(address indexed user, uint indexed stakeType, uint indexed stakeId, uint payTokenAmount, uint amount);
    event Withdraw(address indexed user, uint indexed stakeId, uint payTokenAmount, uint amount);
    event WithdrawReward(address indexed _to, uint amount);

    
    function totalStakeUsdt() public view returns (uint) {

        return _totalStakeUsdt;
    }

    function totalStakeToken() public view returns (uint) {

        return _totalStakeToken;
    }
    
    function totalStakeEth() public view returns (uint) {

        return _totalStakeEth;
    }
    
    function userOrders(address account) public view returns (uint) {

        return _userOrders[account];
    }
    
    function isOnlyToken() public view returns (bool) {

        return _isOnlyToken;
    }
    
    function totalOrders() public view returns (uint) {

        return _totalOrders;
    }
    
    function withdrawalAmount(address account) public view returns (uint) {

        return _withdrawalAmount[account];
    }
    
    function bypass(address user) public view returns (uint) {

        return _bypass[user];
    }

    function setPayToken(address _payToken) external onlyOwner returns (bool) {

        payToken = _payToken;
        return true;
    }

    function setAToken(address _aToken) external onlyOwner returns (bool) {

        aToken = _aToken;
        return true;
    }
    
    function setIsOnlyToken(bool _IsOnly) external onlyOwner returns (bool) {

        _isOnlyToken = _IsOnly;
        return true;
    }
    
    function setBypass(address user ,uint256 mode) public onlyOwner returns (bool) {

        _bypass[user]=mode;
        return true;
    }

    function setLpAddress(address _token, address _lp) external onlyOwner returns (bool) {

        lpAddress[_token] = _lp;
        return true;
    }

    function totalWeight() public view returns (uint) {

        return _totalWeight;
    }
    

    function weightOf(address account) public view returns (uint) {

        return _weights[account];
    }
    
    function setSecretSigner(address _secretSigner) onlyOwner external {

        require(_secretSigner != address(0), "address invalid");
        secretSigner = _secretSigner;
    }

    function getStakeOf(address _account, uint _index) external view returns (StakeSet.Item memory) {

        require(_stakeOf[_account].length() > _index, "getStakeOf: _stakeOf[_account].length() > _index");
        return _stakeOf[_account].at(_index);
    }

    function getStakes(address _account, uint _index, uint _offset) external view returns (StakeSet.Item[] memory items) {

        uint totalSize = userOrders(_account);
        require(0 < totalSize && totalSize > _index, "getStakes: 0 < totalSize && totalSize > _index");
        uint offset = _offset;
        if (totalSize < _index + offset) {
            offset = totalSize - _index;
        }

        items = new StakeSet.Item[](offset);
        for (uint i = 0; i < offset; i++) {
            items[i] = _stakeOf[_account].at(_index + i);
        }
    }
    
    

    function stake(uint _stakeType, uint _amount) external payable {

        require(0 < _stakeType && _stakeType <= 4, "stake: 0 < _stakeType && _stakeType <= 4");
        require(0 < _amount, "stake: 0 < _amount");
        uint256 tokenprice = getUSDTPrice(aToken);
        uint256 ethprice;
        uint256 tokenAmount;
        uint256 coinType;
        if(_stakeType==4){
            if(!_isOnlyToken){
                require(_bypass[msg.sender]==1, "stake: Temporarily not opened");
                IERC20(aToken).safeTransferFrom(msg.sender, address(this), _amount);
            }else{
                IERC20(aToken).safeTransferFrom(msg.sender, address(this), _amount);
            }
            tokenAmount=_amount;
            _totalStakeToken = _totalStakeToken.add(_amount);
        }else{
            ethprice = getUSDTPrice(wethToken);
            if (0 < msg.value) { // pay with ETH  25
            require(msg.value>=(10**12)*4,"stake: msg.value>=(10**12)*4");
            tokenAmount = ethprice.mul(msg.value).mul(STAKE_PER[_stakeType - 1]).div(uint(100).sub(STAKE_PER[_stakeType - 1])).div(tokenprice).div(10**12);
            IERC20(aToken).safeTransferFrom(msg.sender, address(this), tokenAmount);
            coinType =1;
            _totalStakeEth = _totalStakeEth.add(msg.value);
            _totalStakeToken = _totalStakeToken.add(tokenAmount);
            } else { // pay with USDT
                require(4 <= _amount, "stake: 4 <= _amount");
                tokenAmount = _amount.mul(10**6).mul(STAKE_PER[_stakeType - 1]).div(uint(100).sub(STAKE_PER[_stakeType - 1])).div(tokenprice);
                IERC20(payToken).safeTransferFrom(msg.sender, address(this), _amount);
                IERC20(aToken).safeTransferFrom(msg.sender, address(this), tokenAmount);
                coinType =2;
                _totalStakeUsdt = _totalStakeUsdt.add(_amount);
                _totalStakeToken = _totalStakeToken.add(tokenAmount);
            }
        }
        StakeSet.Item memory item;
        uint aTokenValue = tokenprice.mul(tokenAmount).div(10**6);
        uint payTokenValue;
        if(coinType==2){
            payTokenValue = _amount;
            item.payTokenAmount = _amount;
        }else if(coinType==1){
            payTokenValue = ethprice.mul(msg.value).div(10**18);
            item.payTokenAmount = msg.value;
        }else{
            item.payTokenAmount = 0;
        }
        uint power = (aTokenValue.add(payTokenValue)).mul(STAKE_POWER_RATE[_stakeType - 1]).div(100);

        _totalOrders = _totalOrders.add(1);
        _userOrders[msg.sender] = _userOrders[msg.sender].add(1);
        _userOrders[address(0)] = _userOrders[address(0)].add(1);
        _totalWeight = _totalWeight.add(power);
        _weights[msg.sender] = _weights[msg.sender].add(power);

        item.id = ++currentId;
        item.createTime = block.timestamp;
        item.aTokenAmount = tokenAmount;
        item.useraddress = msg.sender;
        item.power = power;
        item.stakeType = _stakeType;
        item.coinType=coinType;


        _stakeOf[msg.sender].add(item);
        _stakeOf[address(0)].add(item);

        emit Stake(msg.sender, _stakeType, item.id, item.payTokenAmount, _amount);
    }

    function withdraw(uint _stakeId) external {

        require(currentId >= _stakeId, "withdraw: currentId >= _stakeId");

        StakeSet.Item memory item = _stakeOf[msg.sender].idAt(_stakeId);
        uint aTokenAmount = item.aTokenAmount;
        uint payTokenAmount = item.payTokenAmount;
        uint _totalToken;
        uint _totalEth;
        uint _totalUsdt;
        if (15 minutes > block.timestamp - item.createTime) {
            aTokenAmount = aTokenAmount.mul(95).div(100);
            payTokenAmount = payTokenAmount.mul(95).div(100);
            _totalToken = _totalToken.add(item.aTokenAmount.mul(5).div(100));
            if (1 == item.coinType){
                _totalEth = _totalEth.add(item.payTokenAmount.mul(5).div(100));
            }else{
                _totalUsdt = _totalUsdt.add(item.payTokenAmount.mul(5).div(100));
            }
        }
        if (1 == item.coinType) { // pay with ETH
            msg.sender.transfer(payTokenAmount);
            IERC20(aToken).safeTransfer(msg.sender, aTokenAmount);
            _totalStakeEth = _totalStakeEth.sub(item.payTokenAmount);
            _totalStakeToken = _totalStakeToken.sub(item.aTokenAmount);
        } else if (2 == item.coinType){ // pay with USDT
            IERC20(payToken).safeTransfer(msg.sender, payTokenAmount);
            IERC20(aToken).safeTransfer(msg.sender, aTokenAmount);
            _totalStakeUsdt = _totalStakeUsdt.sub(item.payTokenAmount);
            _totalStakeToken = _totalStakeToken.sub(item.aTokenAmount);
        }else{
            IERC20(aToken).safeTransfer(msg.sender, aTokenAmount);
            _totalStakeToken = _totalStakeToken.sub(item.aTokenAmount);
        }
        if(_totalToken>0){
            IERC20(aToken).safeTransfer(owner(), _totalToken);
        }
        if(_totalUsdt>0){
            IERC20(payToken).safeTransfer(owner(), _totalUsdt);
        }
        if(_totalEth>0){
            address(uint160(owner())).transfer(_totalEth);
        }
        
        _totalOrders = _totalOrders.sub(1);
        _userOrders[msg.sender] = _userOrders[msg.sender].sub(1);
        _userOrders[address(0)] = _userOrders[address(0)].sub(1);
        _totalWeight = _totalWeight.sub(item.power);
        _weights[msg.sender] = _weights[msg.sender].sub(item.power);

        _stakeOf[msg.sender].remove(item);
        _stakeOf[address(0)].remove(item);
        emit Withdraw(msg.sender, _stakeId, payTokenAmount, aTokenAmount);
    }
    
    function withdrawReward(uint _withdrawRewardId, address _to, uint _amount, uint8 _v, bytes32 _r, bytes32 _s) public {

        require(_userOrders[_to]>0,"withdrawReward : orders >0");
        require(!withdrawRewardIdOf[_withdrawRewardId], "withdrawReward: invalid withdrawRewardId");
        require(address(0) != _to, "withdrawReward: address(0) != _to");
        require(0 < _amount, "withdrawReward: 0 < _amount");
        require(address(0) != secretSigner, "withdrawReward: address(0) != secretSigner");
        bytes32 msgHash = keccak256(abi.encodePacked(_withdrawRewardId, _to, _amount));
        require(ecrecover(msgHash, _v, _r, _s) == secretSigner, "withdrawReward: incorrect signer");
        require(_withdrawal_balances.sub(_amount)>0,"withdrawReward: Withdrawal is beyond");
        _withdrawal_balances = _withdrawal_balances.sub(_amount);
        IERC20(aToken).safeTransfer(_to, _amount.mul(97).div(100));
        IERC20(aToken).safeTransfer(owner(), _amount.mul(3).div(100));
        withdrawRewardIdOf[_withdrawRewardId] = true;
        _withdrawalAmount[_to]=_withdrawalAmount[_to].add(_amount);
        emit WithdrawReward(_to, _amount);
    }


    function getUSDTPrice(address _token) public view returns (uint) {


        if (payToken == _token) {return 1 ether;}
        (bool success, bytes memory returnData) = lpAddress[_token].staticcall(abi.encodeWithSignature("getReserves()"));
        if (success) {
            (uint112 reserve0, uint112 reserve1, ) = abi.decode(returnData, (uint112, uint112, uint32));
            uint DECIMALS = 10**18;
            if(_token==aToken){
                DECIMALS = 10**6;
            }
            return uint(reserve1).mul(DECIMALS).div(uint(reserve0));
        }

        return 0;
    }


    function () external payable {}
    
    
    mapping (address => address) private _referees;
    mapping (address => address[]) private _mygeneration;
    mapping (address => uint256) private _vip;
    uint256 private _withdrawal_balances=14400000000;
    uint256 private _lastUpdated = now;

    function fiveMinutesHavePassed() public view returns (bool) {

      return (now >= (_lastUpdated + 1 days));
    }
    
  
    function getReferees(address user) public view returns (address) {

        return _referees[user];
    }
    
    
    function mygeneration(address user) public view returns (address[] memory) {

        return _mygeneration[user];
    }
    
    function getVip(address account) public view returns (uint256) {

        return _vip[account];
        
    }
    
    
    function getWithdrawalBalances() public view returns (uint256) {

        return _withdrawal_balances;
    }
    
    
    function addWithdrawalBalances() public  returns (bool) {

        require(fiveMinutesHavePassed(),"addWithdrawalBalances:It can only be added once a day");
        uint256 amounnt;
        if(_totalWeight<=1000000*10**6&&_totalWeight>0){
            amounnt = 1440*10**6;
        }else if(_totalWeight>1000000*10**6&&_totalWeight<10000000*10**6){
            amounnt = _totalWeight.mul(1440).div(100000000);
        }else if(_totalWeight>=10000000*10**6){
            amounnt = 14400*10**6;
        }
         _lastUpdated = now;
        _withdrawal_balances = _withdrawal_balances.add(amounnt);
        return true;
    }
    
    
    
    function isSetRef(address my,address myreferees) public view returns (bool) {

        if(myreferees == address(0) || myreferees==my){
            return false; 
        }
        if(_referees[my]!=address(0)){
            return false; 
        }
        if(_mygeneration[my].length>0){
            return false; 
        }
        return true;
    }
    
    
    function setReferees(address myreferees) public  returns (bool) {

        require(myreferees != address(0)&&myreferees!=_msgSender(), "ERC20: myreferees from the zero address or Not for myself");
        require(_referees[_msgSender()]==address(0), "ERC20: References have been given");
        require(_mygeneration[_msgSender()].length==0, "ERC20: Recommended to each other");
        _referees[_msgSender()] = myreferees;
        address[] storage arr=_mygeneration[myreferees];
        arr.push(_msgSender());
        return true; 
    }
    
    
    
    
    function levelCostU(uint256 value,uint256 vip) public pure returns(uint256 u) {

        require(value<=6&&value>vip, "levelCostU: vip false");
            if(value==1){
                u=100;
            }else if(value==2){
                if(vip==0){
                    u=300;
                }else{
                    u=200;
                }
            }else if(value==3){
                if(vip==0){
                    u=500;
                }else if(vip==1){
                    u=400;
                }else{
                    u=200;
                }
            }else if(value==4){
                if(vip==0){
                    u=700;
                }else if(vip==1){
                    u=600;
                }else if(vip==2){
                    u=400;
                }else{
                    u=200;
                }
            }else if(value==5){
                if(vip==0){
                    u=1000;
                }else if(vip==1){
                    u=900;
                }else if(vip==2){
                    u=700;
                }else if(vip==3){
                    u=500;
                }else{
                    u=300;
                }
            }else{
                if(vip==0){
                    u=1500;
                }else if(vip==1){
                    u=1400;
                }else if(vip==2){
                    u=1200;
                }else if(vip==3){
                    u=1000;
                }else if(vip==4){
                    u=800;
                }else{
                     u=500;
                }
            }
    }
    
    function user_burn(uint256 value) public  returns(bool) {

        require(value<=6&&value>_vip[_msgSender()], "user_burn: vip false");
        uint256 u = levelCostU(value,_vip[_msgSender()]);
        uint256 price = getUSDTPrice(aToken);
        require(price>=0, "user_burn: need token price");
        uint256 burnTokenAmount = u.mul(10**12).div(price);
        IERC20(aToken).safeBurnFrom(_msgSender(), burnTokenAmount);
         _vip[_msgSender()]=value;
      return true;
    }
   
}