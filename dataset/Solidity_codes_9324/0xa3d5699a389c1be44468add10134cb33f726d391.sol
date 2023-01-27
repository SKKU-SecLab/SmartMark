pragma solidity 0.8.0;

library SafeMath256 {

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

pragma solidity 0.8.0;

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

pragma solidity 0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// MIT

pragma solidity 0.8.0;

library SignMessage {

    function transferMessage(address wallet, uint256 chainID, address tokenAddress, address to, uint256 value, bytes32 salt) internal pure returns (bytes32) {

        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, tokenAddress, to, value, salt));
        return messageToSign(message);
    }

    function executeWithDataMessage(address wallet, uint256 chainID, address contractAddress, uint256 value, bytes32 salt, bytes memory data) internal pure returns (bytes32) {

        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, contractAddress, value, salt, data));
        return messageToSign(message);
    }

    function batchTransferMessage(address wallet, uint256 chainID, address tokenAddress, address[] memory recipients, uint256[] memory amounts, bytes32 salt) internal pure returns (bytes32) {

        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, tokenAddress, recipients, amounts, salt));
        return messageToSign(message);
    }

    function ownerReplaceMessage(address wallet, uint256 chainID, address[] memory _oldOwners, address[] memory _newOwners, uint256 _required, bytes32 salt) internal pure returns (bytes32) {

        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, _oldOwners, _newOwners, _required, salt));
        return messageToSign(message);
    }

    function ownerModifyMessage(address wallet, uint256 chainID, address[] memory _owners, uint256 _required, bytes32 salt) internal pure returns (bytes32) {

        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, _owners, _required, salt));
        return messageToSign(message);
    }

    function ownerRequiredMessage(address wallet, uint256 chainID, uint256 _required, bytes32 salt) internal pure returns (bytes32) {

        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, _required, salt));
        return messageToSign(message);
    }

    function securitySwitchMessage(address wallet, uint256 chainID, bool swithOn, uint256 _deactivatedInterval, bytes32 salt) internal pure returns (bytes32) {

        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, swithOn, _deactivatedInterval, salt));
        return messageToSign(message);
    }

    function modifyExceptionTokenMessage(address wallet, uint256 chainID, address[] memory _tokens, bytes32 salt) internal pure returns (bytes32) {

        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, _tokens, salt));
        return messageToSign(message);
    }

    function messageToSign(bytes32 message) internal pure returns (bytes32) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, message));
    }
}// MIT

pragma solidity 0.8.0;


contract WalletOwner {

    uint16  constant MIN_REQUIRED = 1;
    uint256 required;
    mapping(address => uint256) activeOwners;
    address[] owners;
    mapping(address => uint256) exceptionTokens;

    event OwnerRemoval(address indexed owner);
    event OwnerAddition(address indexed owner);
    event SignRequirementChanged(uint256 required);

    function getOwners() public view returns (address[] memory) {

        return owners;
    }

    function getOwnerRequiredParam() public view returns (uint256) {

        return required;
    }

    function isOwner(address addr) public view returns (bool) {

        return activeOwners[addr] > 0;
    }
}

contract WalletSecurity {

    uint256 constant MIN_INACTIVE_INTERVAL = 3 days; // 3days;
    uint256 constant securityInterval = 3 days;
    bool initialized;
    bool securitySwitch = false;
    uint256 deactivatedInterval = 0;
    uint256 lastActivatedTime = 0;

    mapping(bytes32 => uint256) transactions;
    event SecuritySwitchChange(bool swithOn, uint256 interval);

    modifier onlyNotInitialized() {

        require(!initialized, "the wallet already initialized");
        _;
        initialized = true;
    }

    modifier onlyInitialized() {

        require(initialized, "the wallet not init yet");
        _;
    }

    function isSecuritySwitchOn() public view returns (bool) {

        return securitySwitch;
    }

    function getDeactivatedInterval() public view returns (uint256) {

        return deactivatedInterval;
    }

    function getLastActivatedTime() public view returns (uint256) {

        return lastActivatedTime;
    }

}

contract MultiSignWallet is WalletOwner, WalletSecurity {

    using SafeMath256 for uint256;

    event Deposit(address indexed from, uint256 value);
    event Transfer(address indexed token, address indexed to, uint256 value);
    event ExecuteWithData(address indexed token, uint256 value);
    event ExceptionTokenRemove(address indexed token);
    event ExceptionTokenAdd(address indexed token);

    modifier ensure(uint deadline) {

        require(deadline >= block.timestamp, "the wallet operation is expired");
        _;
    }

    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    function initialize(address[] memory _owners, uint256 _required, bool _switchOn, uint256 _deactivatedInterval, address[] memory _exceptionTokens) external onlyNotInitialized returns(bool) {

        require(_required >= MIN_REQUIRED, "the signed owner count must than 1");
        if (_switchOn) {
            require(_deactivatedInterval >= MIN_INACTIVE_INTERVAL, "inactive interval must more than 3days");
            securitySwitch = _switchOn;
            deactivatedInterval = _deactivatedInterval;
            emit SecuritySwitchChange(securitySwitch, deactivatedInterval);
        }

        for (uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == address(0x0)) {
                revert("the address can't be 0x");
            }

            if (activeOwners[_owners[i]] > 0 ) {
                revert("the owners must be distinct");
            }

            activeOwners[_owners[i]] = block.timestamp;
            emit OwnerAddition(_owners[i]);
        }

        require(_owners.length >= _required, "wallet owners must more than the required.");
        required = _required;
        emit SignRequirementChanged(required);
        owners = _owners;
        _updateActivatedTime();

        if (_exceptionTokens.length > 0) {
            return _addExceptionToken(_exceptionTokens);
        }

        return true;
    }

    function addOwner(address[] memory _newOwners, uint256 _required, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {

        require(_validOwnerAddParams(_newOwners, _required), "invalid params");
        bytes32 message = SignMessage.ownerModifyMessage(address(this), getChainID(), _newOwners, _required, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        address[] memory _oldOwners;
        return _updateOwners(_oldOwners, _newOwners, _required);
    }

    function removeOwner(address[] memory _oldOwners, uint256 _required, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {

        require(_validOwnerRemoveParams(_oldOwners, _required), "invalid params");
        bytes32 message = SignMessage.ownerModifyMessage(address(this), getChainID(), _oldOwners, _required, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.timestamp;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        address[] memory _newOwners;
        return _updateOwners(_oldOwners, _newOwners, _required);
    }

    function replaceOwner(address[] memory _oldOwners, address[] memory _newOwners, uint256 _required, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {

        require(_validOwnerReplaceParams(_oldOwners, _newOwners, _required), "invalid params");
        bytes32 message = SignMessage.ownerReplaceMessage(address(this), getChainID(), _oldOwners, _newOwners, _required, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        return _updateOwners(_oldOwners, _newOwners, _required);
    }

    function changeOwnerRequirement(uint256 _required, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {

        require(_required >= MIN_REQUIRED, "the signed owner count must than 1");
        require(owners.length >= _required, "the owners must more than the required");
        bytes32 message = SignMessage.ownerRequiredMessage(address(this), getChainID(), _required, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        required = _required;
        emit SignRequirementChanged(required);

        return true;
    }

    function changeSecurityParams(bool _switchOn, uint256 _deactivatedInterval, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {

        bytes32 message = SignMessage.securitySwitchMessage(address(this), getChainID(), _switchOn, _deactivatedInterval, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");

        if (_switchOn) {
            securitySwitch = true;
            require(_deactivatedInterval >= MIN_INACTIVE_INTERVAL, "inactive interval must more than 3days");
            deactivatedInterval = _deactivatedInterval;
        } else {
            securitySwitch = false;
            deactivatedInterval = 0;
        }

        emit SecuritySwitchChange(_switchOn, deactivatedInterval);

        return true;
    }

    function transfer(address tokenAddress, address payable to, uint256 value, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {

        if(tokenAddress == address(0x0)) {
            return _transferNativeToken(to, value, salt, vs, rs, ss);
        }
        return _transferContractToken(tokenAddress, to, value, salt, vs, rs, ss);
    }

    function execute(address contractAddress, uint256 value, bytes memory data, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {

        require(contractAddress != address(this), "not allow transfer to yourself");
        bytes32 message = SignMessage.executeWithDataMessage(address(this), getChainID(), contractAddress, value, salt, data);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        (bool success,) = contractAddress.call{value: value}(data);
        require(success, "contract execution Failed");
        emit ExecuteWithData(contractAddress, value);
        return true;
    }

    function batchTransfer(address tokenAddress, address[] memory recipients, uint256[] memory amounts, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {

        require(recipients.length > 0 && recipients.length == amounts.length, "parameters invalid");
        bytes32 message = SignMessage.batchTransferMessage(address(this), getChainID(), tokenAddress, recipients, amounts, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");

        for(uint256 i = 0; i < recipients.length; i++) {
            _transfer(tokenAddress, recipients[i], amounts[i]);
            emit Transfer(tokenAddress, recipients[i], amounts[i]);
        }
        return true;
    }

    function addExceptionToken(address[] memory tokens, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {

        require(tokens.length > 0, "input tokens empty");
        bytes32 message = SignMessage.modifyExceptionTokenMessage(address(this), getChainID(), tokens, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");

        return _addExceptionToken(tokens);
    }

    function removeExceptionToken(address[] memory tokens, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {

        require(tokens.length > 0, "input tokens empty");
        bytes32 message = SignMessage.modifyExceptionTokenMessage(address(this), getChainID(), tokens, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");

        return _removeExceptionToken(tokens);
    }

    function getChainID() public view returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function getRequired() public view returns (uint256) {

        if(!securitySwitch) {
            return required;
        }

        uint256 _deactivate = block.timestamp;
        if (_deactivate <= lastActivatedTime + deactivatedInterval) {
            return required;
        }

        _deactivate = _deactivate.sub(lastActivatedTime).sub(deactivatedInterval).div(securityInterval);
        if (required > _deactivate) {
            return required.sub(_deactivate);
        }

        return MIN_REQUIRED;
    }

    function getTransactionMessage(bytes32 message) public view returns (uint256) {

        return transactions[message];
    }

    function isExceptionToken(address token) public view returns (bool) {

        return exceptionTokens[token] != 0;
    }

    function _transferContractToken(address tokenAddress, address to, uint256 value, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss) internal returns (bool) {

        require(to != address(this), "not allow transfer to yourself");
        require(value > 0, "transfer value must more than 0");
        bytes32 message = SignMessage.transferMessage(address(this), getChainID(), tokenAddress, to, value, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        _safeTransfer(tokenAddress, to, value);
        emit Transfer(tokenAddress, to, value);
        return true;
    }

    function _transferNativeToken(address payable to, uint256 value, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss) internal returns (bool) {

        require(to != address(this), "not allow transfer to yourself");
        require(value > 0, "transfer value must more than 0");
        require(address(this).balance >= value, "balance not enough");
        bytes32 message = SignMessage.transferMessage(address(this), getChainID(), address(0x0), to, value, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        _safeTransferNative(to, value);
        emit Transfer(address(0x0), to, value);
        return true;
    }

    function _transfer(address tokenAddress, address recipient, uint256 value) internal {

        require(value > 0, "transfer value must more than 0");
        require(recipient != address(this), "not allow transfer to yourself");
        if (tokenAddress == address(0x0)) {
            _safeTransferNative(recipient, value);
            return;
        }
        _safeTransfer(tokenAddress, recipient, value);
    }

    function _updateActivatedTime() internal {

        lastActivatedTime = block.timestamp;
    }

    function _addExceptionToken(address[] memory tokens) internal returns(bool) {

        for(uint256 i = 0; i < tokens.length; i++) {
            if(!isExceptionToken(tokens[i])) {
                require(tokens[i] != address(0x0), "the token address can't be 0x");
                exceptionTokens[tokens[i]] = block.number;
                emit ExceptionTokenAdd(tokens[i]);
            }
        }
        return true;
    }

    function _removeExceptionToken(address[] memory tokens) internal returns(bool) {

        for(uint256 i = 0; i < tokens.length; i++) {
            if(isExceptionToken(tokens[i])) {
                require(tokens[i] != address(0x0), "the token address can't be 0x");
                exceptionTokens[tokens[i]] = 0;
                emit ExceptionTokenRemove(tokens[i]);
            }
        }
        return true;
    }

    function _validOwnerAddParams(address[] memory _owners, uint256 _required) private view returns (bool) {

        require(_owners.length > 0, "the new owners list can't be emtpy");
        require(_required >= MIN_REQUIRED, "the signed owner count must than 1");
        uint256 ownerCount = _owners.length;
        ownerCount = ownerCount.add(owners.length);
        require(ownerCount >= _required, "the owner count must more than the required");
        return _distinctAddOwners(_owners);
    }

    function _validOwnerRemoveParams(address[] memory _owners, uint256 _required) private view returns (bool) {

        require(_owners.length > 0 && _required >= MIN_REQUIRED, "invalid parameters");
        uint256 ownerCount = owners.length;
        ownerCount = ownerCount.sub(_owners.length);
        require(ownerCount >= _required, "the owners must more than the required");
        return _distinctRemoveOwners(_owners);
    }

    function _validOwnerReplaceParams(address[] memory _oldOwners, address[] memory _newOwners, uint256 _required) private view returns (bool) {

        require(_oldOwners.length >0 || _newOwners.length > 0, "the two input owner list can't both be empty");
        require(_required >= MIN_REQUIRED, "the signed owner's count must than 1");
        _distinctRemoveOwners(_oldOwners);
        _distinctAddOwners(_newOwners);
        uint256 ownerCount = owners.length;
        ownerCount = ownerCount.add(_newOwners.length).sub(_oldOwners.length);
        require(ownerCount >= _required, "the owner's count must more than the required");
        return true;
    }

    function _distinctRemoveOwners(address[] memory _owners) private view returns (bool) {

        for(uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == address(0x0)) {
                revert("the remove address can't be 0x.");
            }

            if(activeOwners[_owners[i]] == 0) {
                revert("the remove address must be a owner.");
            }

            for(uint256 j = 0; j < i; j++) {
                if(_owners[j] == _owners[i]) {
                    revert("the remove address must be distinct");
                }
            }
        }
        return true;
    }

    function _distinctAddOwners(address[] memory _owners) private view returns (bool) {

        for(uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == address(0x0)) {
                revert("the new address can't be 0x.");
            }

            if (activeOwners[_owners[i]] != 0) {
                revert("the new address is already a owner");
            }

            for(uint256 j = 0; j < i; j++) {
                if(_owners[j] == _owners[i]) {
                    revert("the new address must be distinct");
                }
            }
        }
        return true;
    }

    function _validSignature(bytes32 recoverMsg, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss) private returns (bool) {

        require(vs.length == rs.length);
        require(rs.length == ss.length);
        require(vs.length <= owners.length);
        require(vs.length >= getRequired());

        address[] memory signedAddresses = new address[](vs.length);
        for (uint256 i = 0; i < vs.length; i++) {
            signedAddresses[i] = ecrecover(recoverMsg, vs[i]+27, rs[i], ss[i]);
        }

        require(_distinctSignedOwners(signedAddresses), "signed owner must be distinct");
        _updateActiveOwners(signedAddresses);
        _updateActivatedTime();
        return true;
    }

    function _updateOwners(address[] memory _oldOwners, address[] memory _newOwners, uint256 _required) private returns (bool) {

        for(uint256 i = 0; i < _oldOwners.length; i++) {
            for (uint256 j = 0; j < owners.length; j++) {
                if (owners[j] == _oldOwners[i]) {
                    activeOwners[owners[j]] = 0;
                    owners[j] = owners[owners.length - 1];
                    owners.pop();
                    emit OwnerRemoval(_oldOwners[i]);
                    break;
                }
            }
        }

        for(uint256 i = 0; i < _newOwners.length; i++) {
            owners.push(_newOwners[i]);
            activeOwners[_newOwners[i]] = block.timestamp;
            emit OwnerAddition(_newOwners[i]);
        }

        require(owners.length >= _required, "the owners must more than the required");
        required = _required;
        emit SignRequirementChanged(required);

        return true;
    }

    function _updateActiveOwners(address[] memory _owners) private returns (bool){

        for (uint256 i = 0; i < _owners.length; i++) {
            activeOwners[_owners[i]] = block.timestamp;
        }
        return true;
    }

    function _distinctSignedOwners(address[] memory _owners) private view returns (bool) {

        if (_owners.length > owners.length) {
            return false;
        }

        for (uint256 i = 0; i < _owners.length; i++) {
            if(activeOwners[_owners[i]] == 0) {
                return false;
            }

            for (uint256 j = 0; j < i; j++) {
                if(_owners[j] == _owners[i]) {
                    return false;
                }
            }
        }
        return true;
    }

    function _safeTransfer(address token, address recipient, uint256 value) internal {

        if(isExceptionToken(token)) {
            (bool success, ) = token.call(abi.encodeWithSelector(IERC20(token).transfer.selector, recipient, value));
            require(success, "ERC20 transfer failed");
            return;
        }
        SafeERC20.safeTransfer(IERC20(token), recipient, value);
    }

    function _safeTransferNative(address recipient, uint256 value) internal {

        (bool success,) = recipient.call{value:value}(new bytes(0));
        require(success, "transfer native failed");
    }
}// MIT

pragma solidity 0.8.0;

interface IMultiSignWalletFactory {

    function getWalletImpl() external view returns(address) ;

}// MIT

pragma solidity 0.8.0;


contract MultiSignWalletProxy {

    address immutable private walletFactory;

    constructor() {
        walletFactory = msg.sender;
    }

    receive() external payable {}

    fallback() external {
        address impl = IMultiSignWalletFactory(walletFactory).getWalletImpl();
        assembly {
            let ptr := mload(0x40)
            let size := calldatasize()
            calldatacopy(ptr, 0, size)
            let result := delegatecall(gas(), impl, ptr, size, 0, 0)
            size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }
}// MIT

pragma solidity 0.8.0;



contract MultiSignWalletFactory is IMultiSignWalletFactory {

    address payable immutable private walletImpl;
    event NewWallet(address indexed wallet);
    bytes4 internal constant _INITIALIZE = bytes4(keccak256(bytes("initialize(address[],uint256,bool,uint256,address[])")));
    constructor(address payable _walletImpl) {
        walletImpl = _walletImpl;
    }

    function create(address[] calldata _owners, uint _required, bytes32 salt, bool _securitySwitch, uint _inactiveInterval, address[] calldata _execptionTokens) public returns (address) {

        MultiSignWalletProxy wallet = new MultiSignWalletProxy{salt: salt}();
        (bool success, bytes memory data) = address(wallet).call(abi.encodeWithSelector(_INITIALIZE, _owners, _required, _securitySwitch, _inactiveInterval, _execptionTokens));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "create wallet failed");
        emit NewWallet(address(wallet));
        return address(wallet);
    }

    function getWalletImpl() external override view returns(address) {

        return walletImpl;
    }
}
