
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

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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
 



abstract contract ERC1132 {
    mapping(address => bytes32[]) public lockReason;

    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    mapping(address => mapping(bytes32 => lockToken)) public locked;

    event Locked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount,
        uint256 _validity
    );

    event Unlocked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount
    );
    
    function lock(string memory _reason, uint256 _amount, uint256 _time)
        public virtual returns (bool);
  
    function tokensLocked(address _of, string memory _reason)
        public virtual view returns (uint256 amount);
    
    function tokensLockedAtTime(address _of, string memory _reason, uint256 _time)
        public virtual view returns (uint256 amount);
    
    function totalBalanceOf(address _of)
        public virtual view returns (uint256 amount);
    
    function extendLock(string memory _reason, uint256 _time)
        public virtual returns (bool);
    
    function increaseLockAmount(string memory _reason, uint256 _amount)
        public virtual returns (bool);

    function tokensUnlockable(address _of, string memory _reason)
        public virtual view returns (uint256 amount);
 
    function unlock(address _of)
        public virtual returns (uint256 unlockableTokens);

    function getUnlockableTokens(address _of)
        public virtual view returns (uint256 unlockableTokens);

}

interface IRevoTokenContract{

  function balanceOf(address account) external view returns (uint256);

  function totalSupply() external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

}



contract LockRevoTokenContract is ERC1132, Ownable {

    using SafeMath for uint;
    string internal constant ALREADY_LOCKED = 'Tokens already locked';
    string internal constant NOT_LOCKED = 'No tokens locked';
    string internal constant AMOUNT_ZERO = 'Amount can not be 0';
    IRevoTokenContract private token;

    constructor(address revoTokenAddress) public {
        token = IRevoTokenContract(revoTokenAddress);
    }

    function lock(string memory _reason, uint256 _amount, uint256 _time)
        public override onlyOwner
        returns (bool)
    {

        bytes32 reason = stringToBytes32(_reason);
        uint256 validUntil = now.add(_time); //solhint-disable-line

        require(tokensLocked(msg.sender, bytes32ToString(reason)) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        if (locked[msg.sender][reason].amount == 0)
            lockReason[msg.sender].push(reason);

        token.transferFrom(msg.sender, address(this), _amount);

        locked[msg.sender][reason] = lockToken(_amount, validUntil, false);

        emit Locked(msg.sender, reason, _amount, validUntil);
        return true;
    }
    
    function transferWithLock(address _to, string memory _reason, uint256 _amount, uint256 _time)
        public onlyOwner
        returns (bool)
    {

        bytes32 reason = stringToBytes32(_reason);
        uint256 validUntil = now.add(_time); //solhint-disable-line

        require(tokensLocked(_to, _reason) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        if (locked[_to][reason].amount == 0)
            lockReason[_to].push(reason);

        token.transferFrom(msg.sender, address(this), _amount);

        locked[_to][reason] = lockToken(_amount, validUntil, false);
        
        emit Locked(_to, reason, _amount, validUntil);
        return true;
    }

    function tokensLocked(address _of, string memory _reason)
        public override
        view
        returns (uint256 amount)
    {

        bytes32 reason = stringToBytes32(_reason);
        if (!locked[_of][reason].claimed)
            amount = locked[_of][reason].amount;
    }
    
    function tokensLockedAtTime(address _of, string memory _reason, uint256 _time)
        public override
        view
        returns (uint256 amount)
    {

        bytes32 reason = stringToBytes32(_reason);
        if (locked[_of][reason].validity > _time)
            amount = locked[_of][reason].amount;
    }

    function totalBalanceOf(address _of)
        public override
        view
        returns (uint256 amount)
    {

        amount = token.balanceOf(_of);

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            amount = amount.add(tokensLocked(_of, bytes32ToString(lockReason[_of][i])));
        }   
    }    
    
    function extendLock(string memory _reason, uint256 _time)
        public override onlyOwner
        returns (bool)
    {

        bytes32 reason = stringToBytes32(_reason);
        require(tokensLocked(msg.sender, _reason) > 0, NOT_LOCKED);

        locked[msg.sender][reason].validity = locked[msg.sender][reason].validity.add(_time);

        emit Locked(msg.sender, reason, locked[msg.sender][reason].amount, locked[msg.sender][reason].validity);
        return true;
    }
    
    function increaseLockAmount(string memory _reason, uint256 _amount)
        public override onlyOwner
        returns (bool)
    {

        bytes32 reason = stringToBytes32(_reason);
        require(tokensLocked(msg.sender, _reason) > 0, NOT_LOCKED);
        token.transfer(address(this), _amount);

        locked[msg.sender][reason].amount = locked[msg.sender][reason].amount.add(_amount);

        emit Locked(msg.sender, reason, locked[msg.sender][reason].amount, locked[msg.sender][reason].validity);
        return true;
    }

    function tokensUnlockable(address _of, string memory _reason)
        public override
        view
        returns (uint256 amount)
    {

        bytes32 reason = stringToBytes32(_reason);
        if (locked[_of][reason].validity <= now && !locked[_of][reason].claimed) //solhint-disable-line
            amount = locked[_of][reason].amount;
    }

    function unlock(address _of)
        public override onlyOwner
        returns (uint256 unlockableTokens)
    {

        uint256 lockedTokens;

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            lockedTokens = tokensUnlockable(_of, bytes32ToString(lockReason[_of][i]));
            if (lockedTokens > 0) {
                unlockableTokens = unlockableTokens.add(lockedTokens);
                locked[_of][lockReason[_of][i]].claimed = true;
                emit Unlocked(_of, lockReason[_of][i], lockedTokens);
            }
        }  

        if (unlockableTokens > 0)
            token.transfer(_of, unlockableTokens);
    }

    function getUnlockableTokens(address _of)
        public override
        view
        returns (uint256 unlockableTokens)
    {

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            unlockableTokens = unlockableTokens.add(tokensUnlockable(_of, bytes32ToString(lockReason[_of][i])));
        }  
    }
    
    function getremainingLockTime(address _of, string memory _reason) public view returns (uint256 remainingTime) {

        bytes32 reason = stringToBytes32(_reason);
        if (locked[_of][reason].validity > now && !locked[_of][reason].claimed) //solhint-disable-line
            remainingTime = locked[_of][reason].validity.sub(now);
    }
    
    function getremainingLockDays(address _of, string memory _reason) public view returns (uint256 remainingDays) {

        bytes32 reason = stringToBytes32(_reason);
        if (locked[_of][reason].validity > now && !locked[_of][reason].claimed) //solhint-disable-line
            remainingDays = (locked[_of][reason].validity.sub(now)) / 86400;
    }
    
    
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {

        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function bytes32ToString(bytes32 x) public pure returns (string memory) {

        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}