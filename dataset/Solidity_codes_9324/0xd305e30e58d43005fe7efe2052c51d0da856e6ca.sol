
pragma solidity ^0.8.0;


library BokkyPooBahsDateTimeLibrary {


    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {

        require(year >= 1970, "BP01");
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {

        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {

        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {

        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {

        (uint year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {

        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {

        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {

        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {

        (uint year, uint month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {

        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {

        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {

        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {

        (,month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {

        (,,day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {

        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {

        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {

        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp, "BP02");
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp, "BP02");
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp, "BP02");
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp, "BP02");
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp, "BP02");
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp, "BP02");
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp, "BP03");
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp, "BP03");
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp, "BP03");
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp, 'BP03');
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp, 'BP03');
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp, 'BP03');
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {

        require(fromTimestamp <= toTimestamp, 'BP03');
        (uint fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {

        require(fromTimestamp <= toTimestamp, 'BP03');
        (uint fromYear, uint fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear, uint toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {

        require(fromTimestamp <= toTimestamp, 'BP03');
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {

        require(fromTimestamp <= toTimestamp, 'BP03');
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {

        require(fromTimestamp <= toTimestamp, 'BP03');
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {

        require(fromTimestamp <= toTimestamp, 'BP03');
        _seconds = toTimestamp - fromTimestamp;
    }
}// MIT

pragma solidity ^0.8.0;



contract MultiSig {


    event setupEvent(address[] signers, uint256 threshold);
    event ApproveHash(bytes32 indexed approvedHash, address indexed owner);
    event ExecutionFailure(bytes32 txHash);
    event ExecutionSuccess(bytes32 txHash);
    event signerAddEvent(address signer);
    event signerRemoveEvent(address signer);
    event signerChangedEvent(address oldSigner, address newSigner);
    event thresholdEvent(uint256 threshold);
    event eventAlreadySigned(address indexed signed);


    address[] private _signers;

    mapping(address => mapping(bytes32 => uint256)) public approvedHashes;

    uint256 internal _threshold;
    uint256 public _nonce;
    bytes32 public _currentHash;

    modifier onlyMultiSig() {

        require(msg.sender == address(this), "Only Multisig contract can run this method");
        _;
    }

    constructor () {

    }

    function setupMultiSig(
        address[] memory signers,
        uint256 threshold
    ) internal {

        require(_threshold == 0, "MS11");
        require(threshold <= signers.length, "MS01");
        require(threshold > 1, "MS02");

        address signer;
        for (uint256 i = 0; i < signers.length; i++) {
            signer = signers[i];
            require(!existSigner(signer), "MS03");
            require(signer != address(0), "MS04");
            require(signer != address(this), "MS05");

            _signers.push(signer);
        }

        _threshold = threshold;
        emit setupEvent(_signers, _threshold);
    }

    function execTransaction(
        bytes calldata data
    ) external returns (bool success) {

        bytes32 txHash;
        {
            bytes memory txHashData =
            encodeTransactionData(
                data,
                _nonce
            );
            _nonce++;
            _currentHash = 0x0;
            txHash = keccak256(txHashData);
            checkSignatures(txHash);
        }
        {            
            success = execute(data);
            if (success) emit ExecutionSuccess(txHash);
            else emit ExecutionFailure(txHash);
        }
    }

    
    function getNonce() external view returns (uint256){

        return _nonce;
    }


    function execute(
        bytes memory data
    ) internal returns (bool success) {

        address to = address (this);
        uint256 gasToCall = gasleft() - 2500;
        assembly {
            success := call(gasToCall, to, 0, add(data, 0x20), mload(data), 0, 0)
        }
    }

    
    function checkSignatures(bytes32 dataHash) public view {

        uint256 threshold = _threshold;
        require(threshold > 1, "MS02");
        address[] memory alreadySigned = getSignersOfHash(dataHash);

        require(alreadySigned.length >= threshold, "MS06");
    }

    
    function getSignersOfHash(
        bytes32 hash
    ) public view returns (address[] memory) {

        uint256 j = 0;
        address[] memory doneSignersTemp = new address[](_signers.length);

        uint256 i;
        address currentSigner;
        for (i = 0; i < _signers.length; i++) {
            currentSigner = _signers[i];
            if (approvedHashes[currentSigner][hash] == 1) {
                doneSignersTemp[j] = currentSigner;
                j++;
            }
        }
        address[] memory doneSigners = new address[](j);
        for (i=0; i < j; i++){
            doneSigners[i] = doneSignersTemp[i];
        }
        return doneSigners;
    }

    function approveHash(
        bytes calldata data
    ) external {

        require(existSigner(msg.sender), "MS07");

        bytes32 hashToApprove = getTransactionHash(data, _nonce);
        bytes32 hashToCancel = getCancelTransactionHash(_nonce);
        
        if(_currentHash == 0x0) {
            require(hashToApprove != hashToCancel, "MS12");
            _currentHash = hashToApprove;
        }
        else {
            require(_currentHash == hashToApprove || hashToApprove == hashToCancel, "MS13");
        }
        
        approvedHashes[msg.sender][hashToApprove] = 1;
        emit ApproveHash(hashToApprove, msg.sender);
    }


    function encodeTransactionData(
        bytes calldata data,
        uint256 nonce
    ) public pure returns (bytes memory) {

        bytes32 safeTxHash =
        keccak256(
            abi.encode(
                keccak256(data),
                nonce
            )
        );
        return abi.encodePacked(safeTxHash);
    }

    function encodeCancelTransactionData(
        uint256 nonce
    ) public pure returns (bytes memory) {

        bytes32 safeTxHash =
        keccak256(
            abi.encode(
                keccak256(""),
                nonce
            )
        );
        return abi.encodePacked(safeTxHash);
    }

    function getTransactionHash(
        bytes calldata data,
        uint256 nonce
    ) public pure returns (bytes32) {

        return keccak256(encodeTransactionData(data, nonce));
    }

    function getCancelTransactionHash(
        uint256 nonce
    ) public pure returns (bytes32) {

        return keccak256(encodeCancelTransactionData(nonce));
    }

    
    function existSigner(
        address signer
    ) public view returns (bool) {

        for (uint256 i = 0; i < _signers.length; i++) {
            address signerI = _signers[i];
            if (signerI == signer) {
                return true;
            }
        }
        return false;
    }

    
    function getSigners() external view returns (address[] memory ) {

        address[] memory ret = new address[](_signers.length) ;
        for (uint256 i = 0; i < _signers.length; i++) {
            ret[i] = _signers[i];
        }
        return ret;
    }

    
    function setThreshold(
        uint256 threshold
    ) public onlyMultiSig{

        require(threshold <= _signers.length, "MS01");
        require(threshold > 1, "MS02");
        _threshold = threshold;
        emit thresholdEvent(threshold);
    }

    
    function getThreshold() external view returns(uint256) {

        return _threshold;
    }

    
    function addSigner(
        address signer,
        uint256 threshold
    ) external onlyMultiSig{

        require(!existSigner(signer), "MS03");
        require(signer != address(0), "MS04");
        require(signer != address(this), "MS05");
        _signers.push(signer);
        emit signerAddEvent(signer);
        setThreshold(threshold);
    }


    function removeSigner(
        address signer,
        uint256 threshold
    ) external onlyMultiSig{

        require(existSigner(signer), "MS07");
        require(_signers.length - 1 > 1, "MS09");
        require(_signers.length - 1 >= threshold, "MS10");
        require(signer != address(0), "MS04");
 
        for (uint256 i = 0; i < _signers.length - 1; i++) {
            if (_signers[i] == signer) {
                _signers[i] = _signers[_signers.length - 1];
                break;
            }
        }
        
        _signers.pop();
        emit signerRemoveEvent(signer);
        setThreshold(threshold);
    }

    
    function changeSigner(
        address oldSigner,
        address newSigner
    ) external onlyMultiSig{

        require(existSigner(oldSigner), "MS07");
        require(!existSigner(newSigner), "MS03");
        require(newSigner != address(0), "MS04");
        require(newSigner != address(this), "MS05");
        
        for (uint256 i = 0; i < _signers.length; i++) {
            if (_signers[i] == oldSigner) {
                _signers[i] = newSigner;
                break;
            }
        }

        emit signerChangedEvent(oldSigner, newSigner);
    }

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;




contract Ownable {

    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == _owner, "onlyOwner");
        _;
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function pendingOwner() external view returns (address) {

        return _pendingOwner;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        _pendingOwner = newOwner;
    }

    function claimOwnership() external {

        require(msg.sender == _pendingOwner, "onlyPendingOwner");
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }
}

contract TokenVestingFactory is Ownable, MultiSig {



    event TokenVestingCreated(address tokenVesting);


    struct BeneficiaryIndex {
        address tokenVesting;
        uint256 vestingType;
        bool isExist;
    }

    mapping(address => BeneficiaryIndex) private _beneficiaryIndex;
    address[] private _beneficiaries;
    address private _tokenAddr;
    uint256 private _decimal;

    constructor (address tokenAddr, uint256 decimal, address[] memory owners, uint256 threshold) {
        require(tokenAddr != address(0), "TokenVestingFactory: token address must not be zero");

        _tokenAddr = tokenAddr;
        _decimal = decimal;
        setupMultiSig(owners, threshold);
    }

    function create(address beneficiary, uint256 start, uint256 cliff, uint256 initialShare, uint256 periodicShare, bool revocable, uint256 vestingType) onlyOwner external {

        require(!_beneficiaryIndex[beneficiary].isExist, "TokenVestingFactory: benficiery exists");
        require(vestingType != 0, "TokenVestingFactory: vestingType 0 is reserved");

        address tokenVesting = address(new TokenVesting(_tokenAddr, beneficiary, start, cliff, initialShare, periodicShare, _decimal, revocable));

        _beneficiaries.push(beneficiary);
        _beneficiaryIndex[beneficiary].tokenVesting = tokenVesting;
        _beneficiaryIndex[beneficiary].vestingType = vestingType;
        _beneficiaryIndex[beneficiary].isExist = true;

        emit TokenVestingCreated(tokenVesting);
    }

    function initialize(address tokenVesting, address from, uint256 amount) external onlyOwner {

        TokenVesting(tokenVesting).initialize(from, amount);
    }

    function update(address tokenVesting, uint256 start, uint256 cliff, uint256 initialShare, uint256 periodicShare, bool revocable) external onlyOwner {

        TokenVesting(tokenVesting).update(start, cliff, initialShare, periodicShare, revocable);
    }


    function getBeneficiaries(uint256 vestingType) external view returns (address[] memory) {

        uint256 j = 0;
        address[] memory beneficiaries = new address[](_beneficiaries.length);

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            address beneficiary = _beneficiaries[i];
            if (_beneficiaryIndex[beneficiary].vestingType == vestingType || vestingType == 0) {
                beneficiaries[j] = beneficiary;
                j++;
            }
        }
        return beneficiaries;
    }

    function getVestingType(address beneficiary) external view returns (uint256) {

        require(_beneficiaryIndex[beneficiary].isExist, "TokenVestingFactory: benficiery does not exist");
        return _beneficiaryIndex[beneficiary].vestingType;
    }

    function getTokenVesting(address beneficiary) external view returns (address) {

        require(_beneficiaryIndex[beneficiary].isExist, "TokenVestingFactory: benficiery does not exist");
        return _beneficiaryIndex[beneficiary].tokenVesting;
    }

    function getTokenAddress() external view returns (address) {

        return _tokenAddr;
    }

    function getDecimal() external view returns (uint256) {

        return _decimal;
    }

    function revoke(address tokenVesting) external onlyMultiSig{

        TokenVesting(tokenVesting).revoke(owner());
    }

}

contract TokenVesting is Ownable {    

    using SafeERC20 for IERC20;

    event TokenVestingUpdated(uint256 start, uint256 cliff, uint256 initialShare, uint256 periodicShare, bool revocable);
    event TokensReleased(address beneficiary, uint256 amount);
    event TokenVestingRevoked(address refundAddress, uint256 amount);
    event TokenVestingInitialized(address from, uint256 amount);

    enum Status {NotInitialized, Initialized, Revoked}

    address private _beneficiary;

    uint256 private _cliff;
    uint256 private _start;
    address private _tokenAddr;
    uint256 private _initialShare;
    uint256 private _periodicShare;
    uint256 private _decimal;
    uint256 private _released;

    bool private _revocable;
    Status private _status;

    constructor(
        address tokenAddr,
        address beneficiary,
        uint256 start,
        uint256 cliff,
        uint256 initialShare,
        uint256 periodicShare,
        uint256 decimal,
        bool revocable
    )

    {
        require(beneficiary != address(0), "TokenVesting: beneficiary address must not be zero");

        _tokenAddr = tokenAddr;
        _beneficiary = beneficiary;
        _revocable = revocable;
        _cliff = start + cliff;
        _start = start;
        _initialShare = initialShare;
        _periodicShare = periodicShare;
        _decimal = decimal;
        _status = Status.NotInitialized;

    }

    function getDetails() external view returns (address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256) {

        uint256 _total = IERC20(_tokenAddr).balanceOf(address(this)) + _released;
        uint256 _vested = _vestedAmount();
        uint256 _releasable = _vestedAmount() - _released;
        return (_beneficiary, _initialShare, _periodicShare, _start, _cliff, _total, _vested, _released, _releasable, _revocable, uint256(_status));
    }


    function getInitialShare() external view returns (uint256) {

        return _initialShare;
    }


    function getPeriodicShare() external view returns (uint256) {

        return _periodicShare;
    }


    function getBeneficiary() external view returns (address) {

        return _beneficiary;
    }

    function getStart() external view returns (uint256) {

        return _start;
    }

    function getCliff() external view returns (uint256) {

        return _cliff;
    }

    function getTotal() external view returns (uint256) {

        return IERC20(_tokenAddr).balanceOf(address(this)) + _released;
    }

    function getVested() external view returns (uint256) {

        return _vestedAmount();
    }

    function getReleased() external view returns (uint256) {

        return _released;
    }

    function getReleasable() public view returns (uint256) {

        return _vestedAmount() - _released;
    }

    function isRevocable() external view returns (bool) {

        return _revocable;
    }

    function isRevoked() external view returns (bool) {

        if (_status == Status.Revoked) {
            return true;
        } else {
            return false;
        }
    }

    function getStatus() external view returns (uint256) {

        return uint256(_status);
    }

    function initialize(address from, uint256 amount) public onlyOwner {


        require(_status == Status.NotInitialized, "TokenVesting: status must be NotInitialized");

        _status = Status.Initialized;

        emit TokenVestingInitialized(address(from), amount);

        IERC20(_tokenAddr).safeTransferFrom(from, address(this), amount);

    }

    function update(
        uint256 start,
        uint256 cliff,
        uint256 initialShare,
        uint256 periodicShare,
        bool revocable

    ) external onlyOwner {


        require(_status == Status.NotInitialized, "TokenVesting: status must be NotInitialized");

        _start = start;
        _cliff = start + cliff;
        _initialShare = initialShare;
        _periodicShare = periodicShare;
        _revocable = revocable;

        emit TokenVestingUpdated(_start, _cliff, _initialShare, _periodicShare, _revocable);

    }

    function release() external {

        require(_status != Status.NotInitialized, "TokenVesting: status is NotInitialized");
        uint256 unreleased = getReleasable();

        require(unreleased > 0, "TokenVesting: releasable amount is zero");

        _released = _released + unreleased;

        emit TokensReleased(address(_beneficiary), unreleased);

        IERC20(_tokenAddr).safeTransfer(_beneficiary, unreleased);
    }

    function revoke(address refundAddress) external onlyOwner {

        require(_revocable, "TokenVesting: contract is not revocable");
        require(_status != Status.Revoked, "TokenVesting: status is Revoked");

        uint256 balance = IERC20(_tokenAddr).balanceOf(address(this));

        uint256 unreleased = getReleasable();
        uint256 refund = balance - unreleased;

        _status = Status.Revoked;

        emit TokenVestingRevoked(address(refundAddress), refund);
        
        IERC20(_tokenAddr).safeTransfer(refundAddress, refund);

    }


    function _vestedAmount() private view returns (uint256) {

        uint256 currentBalance = IERC20(_tokenAddr).balanceOf(address(this));
        uint256 totalBalance = currentBalance + _released;
        uint256 initialRelease = (totalBalance * _initialShare) / ((10 ** _decimal) * 100) ;

        if (block.timestamp < _start)
            return 0;

        if (_status == Status.Revoked)
            return totalBalance;

        if (block.timestamp < _cliff)
            return initialRelease;

        uint256 monthlyRelease = (totalBalance * _periodicShare) / ((10 ** _decimal) * 100);
        uint256 _months = BokkyPooBahsDateTimeLibrary.diffMonths(_cliff, block.timestamp);

        if (initialRelease + (monthlyRelease * (_months + 1)) >= totalBalance) {
            return totalBalance;
        } else {
            return initialRelease + (monthlyRelease * (_months + 1));
        }
    }
}