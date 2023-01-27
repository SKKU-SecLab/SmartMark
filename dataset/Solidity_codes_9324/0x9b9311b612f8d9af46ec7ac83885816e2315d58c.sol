
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

}// UNLICENSED

pragma solidity ^0.8.0;


abstract contract BridgeToken is ERC20 {
}// MIT

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
}// MIT

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
}// UNLICENSED

pragma solidity ^0.8.0;


contract EthBank {
    using SafeERC20 for BridgeToken;

    uint256 public lockBurnNonce;
    struct RefundData {
        bool isRefunded;
        uint256 nonce;
        address sender;
        address tokenAddress;
        uint256 amount;
    }
    struct UnlockData {
        bool isUnlocked;
        address operator;
        address recipient;
        address tokenAddress;
        uint256 amount;
    }
    mapping(uint256 => RefundData) internal refundCompleted;
    mapping(bytes32 => UnlockData) internal unlockCompleted;

    event LogLock(
        address _from,
        address _to,
        address _token,
        string _symbol,
        uint256 _value,
        uint256 _nonce,
        string _chainName
    );

    event LogUnlock(
        address _to,
        address _token,
        string _symbol,
        uint256 _value,
        bytes32 _interchainTX
    );

    event LogRefund(
        address _to,
        address _token,
        string _symbol,
        uint256 _value,
        uint256 _nonce
    );


    modifier availableNonce() {
        require(lockBurnNonce + 1 > lockBurnNonce, "No available nonces.");
        _;
    }
    function getLockedFunds(address _token) public view returns (uint256) {

        if (_token == address(0)) {
            return address(this).balance;
        }
        return BridgeToken(_token).balanceOf(address(this));
    }

    function lockFunds(
        address payable _sender,
        address _recipient,
        address _token,
        string memory _symbol,
        uint256 _amount,
        string memory _chainName
    ) internal {
        lockBurnNonce++;

        refundCompleted[lockBurnNonce] = RefundData(
            false,
            lockBurnNonce,
            _sender,
            _token,
            _amount
        );

        emit LogLock(
            _sender,
            _recipient,
            _token,
            _symbol,
            _amount,
            lockBurnNonce,
            _chainName
        );
    }
    function unlockFunds(
        address payable _recipient,
        address _token,
        string memory _symbol,
        uint256 _amount,
        bytes32 _interchainTX
    ) internal {
        if (_token == address(0)) {
            _recipient.transfer(_amount);
        } else {
            BridgeToken(_token).safeTransfer(_recipient, _amount);
        }
        unlockCompleted[_interchainTX] = UnlockData(
            true,
            address(this),
            _recipient,
            _token,
            _amount
        );

        emit LogUnlock(_recipient, _token, _symbol, _amount, _interchainTX);
    }

    function refunds(
        address payable _recipient,
        address _tokenAddress,
        string memory _symbol,
        uint256 _amount,
        uint256 _nonce
    ) internal {
        if (_tokenAddress == address(0)) {
            _recipient.transfer(_amount);
        } else {
            BridgeToken(_tokenAddress).safeTransfer(_recipient, _amount);
        }
        refundCompleted[_nonce].isRefunded = true;
        emit LogRefund(_recipient, _tokenAddress, _symbol, _amount, _nonce);

    }   
}// UNLICENSED

pragma solidity ^0.8.0;


abstract contract BridgeBankPausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool internal _paused;

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "BridgeBank is paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "BridgeBank is not paused");
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
}// UNLICENSED

pragma solidity ^0.8.0;

contract Ownable {

    address public owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    function getOnwer() public view returns (address) {
        return owner;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Must be the owner of the contract.");
        _;
    }

    function transferOwnership(address newOwner) public isOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}// UNLICENSED
pragma solidity ^0.8.0;

contract LockTimer is Ownable{

    bytes32 private constant pausedAtPosition = bytes32(uint256(keccak256('pausedAt')));
    bytes32 private constant delayTimePosition = bytes32(uint256(keccak256('delayTime')));

    event SetDelayTime(uint256 delayTime);

    modifier isAbleToWithdraw(){
        uint256 delayTime = _getDelayTime();
        uint256 pausedAt = _getPausedAt();
        if (delayTime == 0) {
            delayTime = 1800;
        }
        require(block.timestamp - pausedAt >= delayTime, "Must wait for certain amount of time");
        _;
    }
    
    function _getPausedAt() internal view returns(uint256 time) {
        bytes32 position = pausedAtPosition;

        assembly{
            time:=sload(position)
        }
    }    

    function _setPausedAt() internal{
         bytes32 current = bytes32(block.timestamp);
         bytes32 position = pausedAtPosition;
         assembly {
            sstore(position, current)
        } 
    }

    function _getDelayTime() internal view returns(uint256 time) {
        bytes32 position = delayTimePosition;

        assembly{
            time:=sload(position)
        }
    }
    
    function _setDelayTime(uint256 delayInSecs) internal{
        require(delayInSecs >= 600, "Please set it more than 10 mins");
        require(delayInSecs <= 3600 * 24 * 7 , "Please set it less than 1 week");
        bytes32 position = delayTimePosition;
        assembly {
            sstore(position, delayInSecs)
        }
        emit SetDelayTime(delayInSecs);
    }

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// UNLICENSED

pragma solidity ^0.8.0;


contract BridgeBank is Initializable, EthBank, BridgeBankPausable, Ownable, LockTimer{
    using SafeERC20 for BridgeToken;
    
    address public operator;
    
    function initialize(
        address _operatorAddress
    ) public payable initializer {
        operator = _operatorAddress;
        owner = msg.sender;
        lockBurnNonce = 0;
        _paused = false;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Must be BridgeBank operator.");
        _;
    }
    function changeOperator(address _newOperator)
        public
        isOwner
    {
        operator = _newOperator;
    }

    fallback () external payable { }

    function pause() public isOwner {
        _pause();

        _setPausedAt();
    }


    function unpause() public isOwner {
        _unpause();
    }
    
    function lock(
        address _recipient,
        address _token,
        uint256 _amount,
        string memory _chainName
    ) public payable availableNonce whenNotPaused {
        string memory symbol;

        if (msg.value > 0) {
            require(
                _token == address(0),
                "Ethereum deposits require the 'token' address to be the null address"
            );
            require(
                msg.value == _amount,
                "The transactions value must be equal the specified amount (in wei)"
            );
            symbol = "ETH";

            lockFunds(
            payable(msg.sender),
            _recipient,
            _token,
            symbol,
            _amount,
            _chainName
            );

        }// ERC20 deposit
        else {
            
            uint beforeLock = BridgeToken(_token).balanceOf(address(this));

            BridgeToken(_token).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );

            uint afterLock = BridgeToken(_token).balanceOf(address(this));

            symbol = BridgeToken(_token).symbol();

            lockFunds(
            payable(msg.sender),
            _recipient,
            _token,
            symbol,
            afterLock - beforeLock,
            _chainName
            );
        }
    }

    function unlock(
        address payable _recipient,
        address tokenAddress,
        string memory _symbol,
        uint256 _amount,
        bytes32 _interchainTX
    ) public onlyOperator whenNotPaused {

        require(
            unlockCompleted[_interchainTX].isUnlocked == false,
            "Transactions has been processed before"
        );

        if (tokenAddress == address(0)) {
            address thisadd = address(this);
            require(
                thisadd.balance >= _amount,
                "Insufficient ethereum balance for delivery."
            );
        } else {
            require(
                BridgeToken(tokenAddress).balanceOf(address(this)) >= _amount,
                "Insufficient ERC20 token balance for delivery."
            );
        }
        unlockFunds(_recipient, tokenAddress, _symbol, _amount, _interchainTX);
    }

    function emergencyWithdraw(
        address tokenAddress,
        uint256 _amount
    ) public onlyOperator whenPaused isAbleToWithdraw{

        if (tokenAddress == address(0)) {
            address thisadd = address(this);
            require(
                thisadd.balance >= _amount,
                "Insufficient ethereum balance for delivery."
            );
            payable(msg.sender).transfer(_amount);
        } else {
            require(
                BridgeToken(tokenAddress).balanceOf(address(this)) >= _amount,
                "Insufficient ERC20 token balance for delivery."
            );
            BridgeToken(tokenAddress).safeTransfer(owner, _amount);
        }
        
    }

    function refund(
        address payable _recipient,
        address _tokenAddress,
        string memory _symbol,
        uint256 _amount,
        uint256 _nonce
    ) public onlyOperator whenNotPaused {
        require(
            refundCompleted[_nonce].isRefunded == false,
            "This refunds has been processed before"
        );
        require(
            refundCompleted[_nonce].tokenAddress == _tokenAddress,
            "This refunds has been processed before"
        );
        require(
            refundCompleted[_nonce].sender == _recipient,
            "This refunds has been processed before"
        );


        if (_tokenAddress == address(0)) {
            address thisadd = address(this);
            require(
                thisadd.balance >= _amount,
                "Insufficient ethereum balance for delivery."
            );
        } else {
            require(
                BridgeToken(_tokenAddress).balanceOf(address(this)) >= _amount,
                "Insufficient ERC20 token balance for delivery."
            );
        }
        refunds(_recipient, _tokenAddress, _symbol, _amount, _nonce);
    }




    function checkIsUnlocked(bytes32 _interchainTX) public view
        returns (bool)
    {
        UnlockData memory _unlock = unlockCompleted[_interchainTX];
        return _unlock.isUnlocked;

    }

    function checkIsRefunded(uint256 _id) public view
        returns (bool)
    {
        RefundData memory _refund = refundCompleted[_id];
        return _refund.isRefunded;
    }

    function setEmergencyWithdrawDelayTime(uint delayInSecs) public isOwner{
        _setDelayTime(delayInSecs);
    }

    function getDelayTime() public view returns (uint256){
        return _getDelayTime();
    }
    
    function getPausedAt() public view returns (uint256){
        return _getPausedAt();
    }
}