

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IERC20 {


    function decimals() external view returns (uint8);


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

    
    function mint(address user,uint256 amount) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct AddressSet {
        Set _inner;
    }

    function insert(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function insert(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
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

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IQubeStakeFactory {

    function owner() external view returns (address);

    function qube() external view returns (address);

    function distributeReward(address to,uint256 amount) external;

}

pragma solidity ^0.8.0;

contract QubeStake is Pausable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    IERC20 public stakeToken;
    IERC20 public rewardToken;
    IQubeStakeFactory public qubeFactory;
    
    uint256 public startTime;
    uint256 public endTime;
    uint256 public rewardRoi;
    
    struct userData {
        address user;
        uint256 stakeTime;
        uint256 deadLine;
        uint256 claimTime;
        uint256 stakeAmount;
        uint256 totalRewards;
    }

    uint256 private internalTicket;
    uint256 public yieldDuration = 31536000; 
    bool public rewardState;
    uint256 private stakeDecimal;
    uint256 private rewardDecimal;

    mapping (uint256 => userData) public userInfo;
    mapping (address => EnumerableSet.UintSet) private userTicketInfo;

    event stakeEvent(address indexed user,uint256 stakeamount,uint256 time);
    event unstakeEvent(address indexed user,uint256 unstakeamount,uint256 time);
    event rewardEvent(address indexed user,uint256 rewardAmount,uint256 time);

    constructor(
        address _stakeToken,
        address _rewardToken,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _roi){
        stakeToken = IERC20(_stakeToken);
        rewardToken = IERC20(_rewardToken);
        startTime = _startTime;
        endTime = _endTime; 
        rewardState = true;
        rewardRoi = _roi;

        qubeFactory = IQubeStakeFactory(msg.sender);
        stakeDecimal = stakeToken.decimals();
        rewardDecimal = rewardToken.decimals();
    }
    
    receive() external payable {}

    modifier onlyOwner {

        require(qubeFactory.owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function pause() public onlyOwner {

        _pause();
    }

    function unpause() public onlyOwner {

        _unpause();
    }

    function setYieldDuration(uint256 newDuration) public onlyOwner {

        yieldDuration = newDuration;
    }

    function setRewardStatus(bool status) public onlyOwner {

        rewardState = status;
    }

    function rewardTokenDeposit(uint256 amount) public onlyOwner{

        require(address(rewardToken) != qubeFactory.qube(), "Unable to deposit qube Token");
        rewardToken.safeTransferFrom(_msgSender(),address(this),amount);
    }

    function roiUpdate(uint256 newRoi) public onlyOwner {

        rewardRoi = newRoi;
    }

    function timeUpdate(uint256 _startTime,uint256 _endTime) public onlyOwner {

        startTime = _startTime;
        endTime =_endTime;
    }
    
    function pendingReward(uint256 sid) public view returns (uint256 getAmountOut){        

        return decimalFactor((userInfo[sid].stakeAmount.mul(
                block.timestamp.sub(userInfo[sid].claimTime)).mul(
                    rewardRoi)).div(100 * yieldDuration));
    }

    function stake(uint256 amount) public whenNotPaused {

        require(startTime <= block.timestamp && endTime >= block.timestamp, "Stake Expired");
        internalTicket++;
        userTicketInfo[_msgSender()].insert(internalTicket);        
        stakeToken.safeTransferFrom(_msgSender(),address(this),amount);
        userInfo[internalTicket] = userData(_msgSender(),block.timestamp,block.timestamp.add(yieldDuration),block.timestamp,amount,0);

        emit stakeEvent(_msgSender(),amount,block.timestamp);
    }
    
    function unStake(uint256 sid,uint256 amount) public whenNotPaused {

        userData storage userStore = userInfo[sid];
        require(userTicketInfo[_msgSender()].contains(sid), "Invalid Stake id");
        require(userStore.stakeAmount >= amount, "invalid amount");             

        if(rewardState) {
            uint256 currTime = userStore.deadLine < block.timestamp ? userStore.deadLine : block.timestamp;
            uint256 getAmountOut = (userStore.stakeAmount.mul(
                currTime.sub(userStore.claimTime)).mul(
                    rewardRoi)).div(100 * yieldDuration);

            if(getAmountOut > 0){
                getAmountOut = decimalFactor(getAmountOut);
                if(address(rewardToken) == qubeFactory.qube()){
                    qubeFactory.distributeReward(userStore.user,getAmountOut); 
                }else {
                    rewardToken.safeTransfer(userStore.user,getAmountOut); 
                }
                userStore.totalRewards = userStore.totalRewards.add(getAmountOut);
                emit rewardEvent(userStore.user,getAmountOut,block.timestamp);
            } 
            userStore.claimTime = currTime;
        }
        
        if(amount != 0) {
            stakeToken.safeTransfer(userStore.user,amount);
            userStore.stakeAmount = userStore.stakeAmount.sub(amount);

            emit unstakeEvent(userStore.user,amount,block.timestamp);
        }
    }

    function decimalFactor(uint256 amount) public view returns (uint256) {

        return amount.mul(10 ** rewardDecimal).div(10 ** stakeDecimal);
    }

    function adminEmergency(address addr,address account,uint256 amount) public onlyOwner {

        if(addr == address(0)){
            payable(account).transfer(amount);
        }else {
            IERC20(addr).safeTransfer(account,amount);
        }
    }

    function userTicketLength(address user) public view returns (uint256) {

         return userTicketInfo[user].length();
    }
    
    function userTicketAt(address user,uint256 index) public view returns (uint256) {

        return userTicketInfo[user].at(index);
    }

    function userTickets(address user) public view returns (uint256[] memory) {

        return userTicketInfo[user].values();
    }
    
    function userTicketContains(address user,uint256 ticket) public view returns (bool) {

        return userTicketInfo[user].contains(ticket);
    }
}

contract QubeStakeFactory is Ownable{       

    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    
    EnumerableSet.AddressSet private farms;
    address private qubeToken;
    bool public qubeMintState;

    constructor(address _qube) {
        qubeToken = _qube;
        qubeMintState = true;
    }

    function createPool(
        address _stakeToken,
        address _rewardToken,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _roi,
        uint256 _amount
    ) public onlyOwner {

        QubeStake newQube = new QubeStake(
            _stakeToken,
            _rewardToken,
            _startTime,
            _endTime,
            _roi
        );

        if(_amount > 0) {
            IERC20(_rewardToken).safeTransferFrom(_msgSender(),address(newQube),_amount);
        }

        farms.insert(address(newQube));
    }

    function setQubeMintState(bool status) public onlyOwner {

        qubeMintState = status;
    }
    
    function distributeReward(address to,uint256 amount) external {

        require(qubeMintState, "qube mint option disabled");
        require(farmContains(msg.sender), "Unable to access");

        IERC20(qubeToken).mint(to,amount);
    } 

    function farmRemove(address farm) public onlyOwner {

        farms.remove(farm);
    }

    function qube() external view returns (address) {

        return qubeToken;
    }

    function farmLength() public view returns (uint256) {

        return farms.length();
    }

    function farmAt(uint256 index) public view returns (address) {

        return farms.at(index);
    }

    function totalFarms() public view returns (address[] memory) {

        return farms.values();
    }
    
    function farmContains(address _farm) public view returns (bool) {

        return farms.contains(_farm);
    }
}