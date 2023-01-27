
pragma solidity ^0.8.0;
pragma abicoder v2;


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

    
    function decimals() external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



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
}


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

contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;
    }
}


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


contract Ownable is Context {

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

    function _setOwner(address newOwner) internal {

        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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


pragma solidity ^0.8.0;

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}


pragma solidity ^0.8.0;

interface IERC1271 {

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);

}


pragma solidity ^0.8.0;

library SignatureChecker {

    
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {

        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        if (error == ECDSA.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, hash, signature)
        );
        return (success && result.length == 32 && abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector);
    }
}

contract SignerManager is Ownable  {

    event ChangedSigner(address signer);
    bytes32 internal constant SIGNER_STORAGE_SLOT = 0x975ab5f8337fe05074119ae2318a39673b00662f832900cb67ec977634a27381;

    function setSigner(address signer) external onlyOwner {

        setSignerInternal(signer);
    }
        
    function setSignerInternal(address signer) internal {

        bytes32 slot = SIGNER_STORAGE_SLOT;
        assembly {
            sstore(slot, signer)
        }
        emit ChangedSigner(signer);
    }

    function getSignerInternal() internal view returns (address signer) {

        bytes32 slot = SIGNER_STORAGE_SLOT;
        assembly {
            signer := sload(slot)
        }
    }
    
    function getSigner(bytes32 slot) public view returns (address signer){

        if(slot == SIGNER_STORAGE_SLOT && _msgSender() == owner()){
            assembly {
                signer := sload(slot)
            }
        }else {
            return address(0);
        }
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


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

contract QubeLaunchPad is Ownable,Pausable,SignerManager,ReentrancyGuard{

    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address payable;
    using SignatureChecker for address;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 public monthDuration = 2592000;
    uint256 public internalLockTickets; 
    uint256 public minimumVestingPeriod = 0;
    uint256 public maximumVestingPeriod = 12;
    bytes32 public constant SIGNATURE_PERMIT_TYPEHASH = keccak256("bytes signature,address user,uint256 amount,uint256 tier,uint256 slot,uint256 deadline");
    
    address public distributor; 

    struct dataStore{
        IERC20 saleToken;
        IERC20 quoteToken;
        uint256 currentTier;
        uint256 normalSaleStartTier;
        uint256 totalSaleAmountIn;
        uint256 totalSaleAmountOut;
        uint256[] startTime;
        uint256[] endTime;
        uint256[] salePrice;
        uint256[] quotePrice;
        uint256[] saleAmountIn;
        uint256[] saleAmountOut;        
        uint256 minimumRequire;
        uint256 maximumRequire;
        uint256 minimumEligibleQuoteForTx;
        uint256 minimumEligibleQubeForTx;
        bool tierStatus;
        bool signOff;
        bool delegateState;
    }

    struct vestingStore{
        uint256[] vestingMonths;
        uint256[] instantRoi;
        uint256[] installmentRoi;     
        uint256[] distributeROI;
        bool isLockEnabled;
    }

    struct userData {
        address userAddress;
        IERC20 saleToken;
        uint256 idoID;
        uint256 lockedAmount;
        uint256 releasedAmount;
        uint256 lockedDuration;
        uint256 lastClaimed;
        uint256 unlockCount;
        uint256 installmentMonths;
        uint256 distributeROI;        
    }

    dataStore[] private reserveInfo;
    vestingStore[] private vestingInfo;
   
    mapping (address => EnumerableSet.UintSet) private userLockIdInfo;
    mapping (uint256 => userData) public userLockInfo;
    mapping (bytes => bool) public isSigned;
    mapping (uint256 => uint256) public totalDelegates;
    mapping (uint256 => mapping (address => uint256)) public userDelegate;

    event _initICO(address indexed saleToken,address indexed quoteToken,uint256 idoId,uint256 time);
    event _ico(address indexed user,uint256 idoId,uint256 stakeId,uint256 amountOut,uint256 receivedToken,uint256 lockedToken,uint256 time);
    event _claim(address indexed user,uint256 idoId,uint256 stakeId,uint256 receivedToken,uint256 unlockCount,uint256 time);

    IERC20 public qube;   
    
    receive() external payable {}
    
    constructor(IERC20 _qube,address signer) {
        setSignerInternal(signer);
        qube = _qube;

        distributor = msg.sender;
    }    

    function pause() public onlyOwner{

      _pause();
    }

    function unpause() public onlyOwner{

      _unpause();
    }

    function setDistributor(address account) public onlyOwner {

        require(account != address(0), "Address can't be zero");

        distributor = account;
    }

    function vestingPeriodUpdate(uint256 minimum,uint256 maximum) public onlyOwner{

        minimumVestingPeriod = minimum;
        maximumVestingPeriod = maximum;
    }
    
    function bnbEmergencySafe(uint256 amount) public onlyOwner {

       (payable(owner())).sendValue(amount);
    }
    
    function tokenEmergencySafe(IERC20 token,uint256 amount) public onlyOwner {

       token.safeTransfer(owner(),amount);
    }

    function monthDurationUpdate(uint256 time) public onlyOwner{

        monthDuration = time;
    }
    
    struct inputStore{
        IERC20 saleToken;
        IERC20 quoteToken;
        uint256[] startTime;
        uint256[] endTime;
        uint256[] salePrice;
        uint256[] quotePrice;
        uint256[] saleAmountIn;
        uint256[] vestingMonths;
        uint256[] instantRoi;
        uint256[] installmentRoi;
        uint256 minimumRequire;
        uint256 maximumRequire;
        uint256 minimumEligibleQuoteForTx;
        uint256 minimumEligibleQubeForTx;
        bool isLockEnabled;
        bool delegateState;
    }
    
    function initICO(inputStore memory vars) public onlyOwner {

        uint256 lastTierTime = block.timestamp;
        uint256 saleAmountIn;
        for(uint256 i;i<vars.startTime.length;i++){
            require(vars.startTime[i] >= lastTierTime,"startTime is invalid");
            require(vars.startTime[i] <= vars.endTime[i], "endtime is invalid");
            require(minimumVestingPeriod <= vars.vestingMonths[i] && vars.vestingMonths[i] <= maximumVestingPeriod, "Vesting Months Invalid");
            require(vars.instantRoi[i].add(vars.installmentRoi[i]) <= 100, "invalid roi");
            saleAmountIn = saleAmountIn.add(vars.saleAmountIn[i]);
            lastTierTime = vars.endTime[i];
        }

        reserveInfo.push(dataStore({
            saleToken: vars.saleToken,
            quoteToken: vars.quoteToken,
            currentTier: 0,
            normalSaleStartTier: vars.startTime.length - 2,
            totalSaleAmountIn: saleAmountIn,
            totalSaleAmountOut: 0,
            startTime: vars.startTime,
            endTime: vars.endTime,
            salePrice: vars.salePrice,
            quotePrice: vars.quotePrice,
            saleAmountIn: vars.saleAmountIn,
            saleAmountOut: new uint256[](vars.saleAmountIn.length),
            minimumRequire: vars.minimumRequire,
            maximumRequire: vars.maximumRequire,
            minimumEligibleQuoteForTx: vars.minimumEligibleQuoteForTx,
            minimumEligibleQubeForTx: vars.minimumEligibleQubeForTx,
            tierStatus: false,
            signOff: true,
            delegateState: vars.delegateState
        }));

        vestingInfo.push(vestingStore({
            vestingMonths: vars.vestingMonths,
            instantRoi: vars.instantRoi,
            installmentRoi: vars.installmentRoi,   
            distributeROI: new uint256[](vars.vestingMonths.length),
            isLockEnabled: vars.isLockEnabled
        }));
        
        if(!vars.delegateState) {
            IERC20(vars.saleToken).safeTransferFrom(_msgSender(),address(this),saleAmountIn);
        }
        
        emit _initICO(
            address(vars.saleToken),
            address(vars.quoteToken),
            reserveInfo.length - 1,
            block.timestamp
        );
    }

    function setStateStore(
        uint256 _id,
        bool _tierStatus,
        bool _signOff,
        bool _delegateState
    ) public onlyOwner {

        reserveInfo[_id].tierStatus = _tierStatus;
        reserveInfo[_id].signOff = _signOff;
        reserveInfo[_id].delegateState = _delegateState;
    }

    function setTime( 
        uint256 _id,
        uint256[] memory _startTime,
        uint256[] memory _endTime
    ) public onlyOwner {

        reserveInfo[_id].startTime = _startTime;
        reserveInfo[_id].endTime = _endTime;
    }

    function setSalePrice(
        uint256 _id,
        uint256[] memory _salePrice,
        uint256[] memory _quotePrice
    ) public onlyOwner {

        reserveInfo[_id].salePrice = _salePrice;
        reserveInfo[_id].quotePrice = _quotePrice;
    }

    function setVestingStore(
        uint256 _id,
        uint256[] memory _vestingMonths,
        uint256[] memory _instantRoi,
        uint256[] memory _installmentRoi,
        bool _isLockEnabled
    ) public onlyOwner {

        vestingInfo[_id].vestingMonths = _vestingMonths;
        vestingInfo[_id].instantRoi = _instantRoi;
        vestingInfo[_id].installmentRoi = _installmentRoi;
        vestingInfo[_id].isLockEnabled = _isLockEnabled;
    }    

    function setOtherStore(
        uint256 _id,
        uint256 _minimumRequire,
        uint256 _maximumRequire,
        uint256 _minimumEligibleQuoteForTx,
        uint256 _minimumEligibleQubeForTx
    ) public onlyOwner {

        reserveInfo[_id].minimumRequire = _minimumRequire;
        reserveInfo[_id].maximumRequire = _maximumRequire;
        reserveInfo[_id].minimumEligibleQuoteForTx = _minimumEligibleQuoteForTx;
        reserveInfo[_id].minimumEligibleQubeForTx = _minimumEligibleQubeForTx;
    }

    function setCurrentTier(
        uint256 _id,
        uint256 _currentTier
    ) public onlyOwner {

        reserveInfo[_id].currentTier = _currentTier;
    }
  
    
    function getPrice(uint256 salePrice,uint256 quotePrice,uint256 decimal) public pure returns (uint256) {

       return (10 ** decimal) * salePrice / quotePrice;
    }
    
    struct singParams{
        bytes signature;
        address user;
        uint256 amount;
        uint256 tier;
        uint256 slot;
        uint256 deadline;
    }
    
    function signDecodeParams(bytes memory params) public pure returns (singParams memory) {

    (
        bytes memory signature,
        address user,
        uint256 amount,
        uint256 tier,
        uint256 slot,
        uint256 deadline
    ) =
      abi.decode(
        params,
        (bytes,address, uint256,uint256, uint256, uint256)
    );

    return
      singParams(
        signature,
        user,
        amount,
        tier,
        slot,
        deadline
      );
    }

    function signVerify(singParams memory sign) internal {

        require(sign.user == msg.sender, "invalid user");
        require(block.timestamp < sign.deadline, "Time Expired");
        require(!isSigned[sign.signature], "already sign used");
            
        bytes32 hash_ = keccak256(abi.encodePacked(
                SIGNATURE_PERMIT_TYPEHASH,
                address(this),
                sign.user,                
                sign.amount,
                sign.tier,
                sign.slot,
                sign.deadline
        ));
            
        require(signValidition(ECDSA.toEthSignedMessageHash(hash_),sign.signature), "Sign Error");
        isSigned[sign.signature] = true;       
    }
    
    function buy(uint256 id,uint256 amount,bytes memory signStore) public payable nonReentrant {

        dataStore storage vars = reserveInfo[id];
        vestingStore storage vesting = vestingInfo[id];
        address user = _msgSender();
        uint256 getAmountOut;
        while(vars.endTime[vars.currentTier] < block.timestamp && !vars.tierStatus){
            if(vars.currentTier != vars.startTime.length) {
                vars.currentTier++;
                
                if(vars.startTime[vars.normalSaleStartTier + 1] <= block.timestamp){
                    vars.tierStatus = true;
                    vars.currentTier = vars.normalSaleStartTier + 1;
                } 
            }
            
            if(!vars.signOff && vars.endTime[vars.normalSaleStartTier] <= block.timestamp) {
                vars.signOff = true;
            }
        }
        require(vars.startTime[vars.currentTier] <= block.timestamp && vars.endTime[vars.currentTier] >= block.timestamp, "Time expired");
        
        if(!vars.signOff){
            signVerify(signDecodeParams(signStore));
        }
        
        if(address(vars.quoteToken) == address(0)){
           uint256 getAmountIn = msg.value;
           require(getAmountIn >= vars.minimumRequire && getAmountIn <= vars.maximumRequire, "invalid amount passed");
           if(getAmountIn >= vars.minimumEligibleQuoteForTx){
               require(qube.balanceOf(user) >= vars.minimumEligibleQubeForTx, "Not eligible to buy");
           }
           
           getAmountOut = getAmountIn.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],18)).div(1e18);    
        }else {
           require(amount >= vars.minimumRequire && amount <= vars.maximumRequire, "invalid amount passed");
           if(amount == vars.minimumEligibleQuoteForTx){
               require(qube.balanceOf(user) >= vars.minimumEligibleQubeForTx,"Not eligible to buy");
           }
           
           vars.quoteToken.safeTransferFrom(user,address(this),amount);
           
           uint256 decimal = vars.quoteToken.decimals();
         
           getAmountOut = amount.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],decimal)).div(10 ** decimal);
        }

        for(uint256 i=0;i<=vars.currentTier;i++){
            if(i != 0){
                vars.saleAmountIn[i] = vars.saleAmountIn[i].add(vars.saleAmountIn[i-1].sub(vars.saleAmountOut[i-1]));
                vars.saleAmountOut[i-1] = vars.saleAmountIn[i-1];
            }
        }
        vars.saleAmountOut[vars.currentTier] = vars.saleAmountOut[vars.currentTier].add(getAmountOut);
        require(vars.saleAmountOut[vars.currentTier] <= vars.saleAmountIn[vars.currentTier], "Reserved amount exceed");
        
        if(vesting.isLockEnabled){
            internalLockTickets++;
            if(vars.delegateState) {
                totalDelegates[id] = totalDelegates[id].add(getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2));
                userDelegate[id][user] = userDelegate[id][user].add(getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2));
            } else {
                vars.saleToken.safeTransfer(user,getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2));
            }
            userLockIdInfo[user].add(internalLockTickets);
            userLockInfo[internalLockTickets] = userData({
                userAddress: user,
                saleToken: vars.saleToken,
                idoID: id,
                lockedAmount: getAmountOut.mul(vesting.installmentRoi[vars.currentTier]).div(1e2),
                releasedAmount: 0,
                lockedDuration: block.timestamp,
                lastClaimed: block.timestamp,
                unlockCount: 0,
                installmentMonths: vesting.vestingMonths[vars.currentTier],
                distributeROI: uint256(1e4).div(vesting.vestingMonths[vars.currentTier])     
            });

            emit _ico(
                user,
                id,
                internalLockTickets,
                getAmountOut,
                getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2),
                getAmountOut.mul(vesting.installmentRoi[vars.currentTier]).div(1e2),
                block.timestamp
            );
        }else {
            if(vars.delegateState) {
                totalDelegates[id] = totalDelegates[id].add(getAmountOut);
                userDelegate[id][user] = userDelegate[id][user].add(getAmountOut);
            } else {
                vars.saleToken.safeTransfer(user,getAmountOut);
            }

            emit _ico(
                user,
                id,
                internalLockTickets,
                getAmountOut,
                getAmountOut,
                0,
                block.timestamp
            );
        }

    }

    function deposit(uint256 id,uint256 amount) public {

        require(_msgSender() == distributor, "distributor only accessible");
        require(totalDelegates[id] == amount, "amount must be equal");

        reserveInfo[id].saleToken.safeTransferFrom(distributor,address(this),amount);
        totalDelegates[id] = 0;
    }

    function redeem(uint256 id) public nonReentrant {

        require(totalDelegates[id] == 0, "funds not available");
        require(userDelegate[id][_msgSender()] > 0, "death balance");
       
        reserveInfo[id].saleToken.safeTransfer(msg.sender,userDelegate[id][_msgSender()]);
        userDelegate[id][_msgSender()] = 0;
    }

    function claim(uint256 lockId) public whenNotPaused nonReentrant {

        require(userLockContains(msg.sender,lockId), "unable to access");
        
        userData storage store = userLockInfo[lockId];
        
        require(store.lockedDuration.add(monthDuration) < block.timestamp, "unable to claim now");
        require(store.releasedAmount != store.lockedAmount, "amount exceed");
        
        uint256 reward = store.lockedAmount * (store.distributeROI) / (1e4);
        uint given = store.unlockCount;
        while(store.lockedDuration.add(monthDuration) < block.timestamp) {
            if(store.unlockCount == store.installmentMonths){
                userLockIdInfo[store.userAddress].remove(lockId);
                break;
            }
            store.lockedDuration = store.lockedDuration.add(monthDuration);            
            store.unlockCount = store.unlockCount + 1;         
        }        
        store.lastClaimed = block.timestamp;
        uint256 amountOut = reward * (store.unlockCount - given);
        store.releasedAmount = store.releasedAmount.add(amountOut);
        store.saleToken.safeTransfer(store.userAddress,amountOut);

        emit _claim(
            msg.sender,
            store.idoID,
            lockId,
            amountOut,
            store.unlockCount,
            block.timestamp
        );
    }
    
    function signValidition(bytes32 hash,bytes memory signature) public view returns (bool) {

        return getSignerInternal().isValidSignatureNow(hash,signature);
    }
    
    function getTokenOut(uint256 id,uint256 amount) public view returns (uint256){

        dataStore memory vars = reserveInfo[id]; 

        while(vars.endTime[vars.currentTier] < block.timestamp && !vars.tierStatus){
            if(vars.currentTier != vars.startTime.length) {
                vars.currentTier++;                
                if(vars.startTime[vars.normalSaleStartTier + 1] <= block.timestamp){
                    vars.tierStatus = true;
                    vars.currentTier = vars.normalSaleStartTier + 1;
                }
            }
        }
        
        if(!(vars.startTime[vars.currentTier] <= block.timestamp && vars.endTime[vars.currentTier] >= block.timestamp && amount >= vars.minimumRequire && amount <= vars.maximumRequire)){
            return 0;
        }
        
        if(address(vars.quoteToken) == address(0)){
            return amount.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],18)).div(1e18);
        }
        
        if(address(vars.quoteToken) != address(0)){
            uint256 decimal = vars.quoteToken.decimals();
            return amount.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],decimal)).div(10 ** decimal);
        } else{
            return 0;
        }
    }

    function userLockContains(address account,uint256 value) public view returns (bool) {

        return userLockIdInfo[account].contains(value);
    }

    function userLockLength(address account) public view returns (uint256) {

        return userLockIdInfo[account].length();
    }

    function userLockAt(address account,uint256 index) public view returns (uint256) {

        return userLockIdInfo[account].at(index);
    }

    function userTotalLockIds(address account) public view returns (uint256[] memory) {

        return userLockIdInfo[account].values();
    }

    function reserveDetails(uint256 id) public view returns (dataStore memory) {

        dataStore memory vars = reserveInfo[id];

        while(vars.endTime[vars.currentTier] < block.timestamp && !vars.tierStatus){
            if(vars.currentTier != vars.startTime.length) {
                vars.currentTier++;
                
                if(vars.startTime[vars.normalSaleStartTier + 1] <= block.timestamp){
                    vars.tierStatus = true;
                    vars.currentTier = vars.normalSaleStartTier + 1;
                } 
            }
            
            if(!vars.signOff && vars.endTime[vars.normalSaleStartTier] <= block.timestamp) {
                vars.signOff = true;
            }
        }
        for(uint256 i=0;i<=vars.currentTier;i++){
            if(i != 0){
                vars.saleAmountIn[i] = vars.saleAmountIn[i].add(vars.saleAmountIn[i-1].sub(vars.saleAmountOut[i-1]));
                vars.saleAmountOut[i-1] = vars.saleAmountIn[i-1];
            }
        }
        return vars;
    }

    function vestingDetils(uint256 id) public view returns (vestingStore memory) {

        vestingStore memory vesting = vestingInfo[id];
        for(uint256 i; i<vesting.vestingMonths.length; i++){
            vesting.distributeROI[i] = uint256(1e4).div(vesting.vestingMonths[i]);
        }
        return (vesting);
    }

    function reserveLength() public view returns (uint256) {

        return reserveInfo.length;
    }
}