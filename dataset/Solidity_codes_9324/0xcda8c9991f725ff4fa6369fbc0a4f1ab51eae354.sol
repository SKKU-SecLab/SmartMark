

pragma solidity ^0.8.7;

contract SignVerifier {


    struct Message {
        uint256 networkId;
        address token;
        address from;
        address to;
        uint256 amount;
        uint256 nonce;
        bytes signature;
        address signer;
    }

    struct NativeMessage {
        uint256 networkId;
        address from;
        address to;
        uint256 amount;
        uint256 nonce;
        bytes signature;
        address signer;
    }

    function getMessageHash(
        uint256 networkId, 
        address token, 
        address from, 
        address to, 
        uint256 amount, 
        uint256 nonce
    )
        public pure returns (bytes32)
    {

        return keccak256(abi.encodePacked(networkId,token,from,to,amount,nonce));
    }

    function getNativeMessageHash(
        uint256 networkId,
        address from,
        address to,
        uint256 amount,
        uint256 nonce
    )
        public pure returns (bytes32)
    {

        return keccak256(abi.encodePacked(networkId,from,to,amount,nonce));
    }

    function getEthSignedMessageHash(bytes32 messageHash) public pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }
    
    function verify(
        Message memory finalizeMessage
    )
        public pure returns (bool)
    {

        bytes32 messageHash_ = getMessageHash(
            finalizeMessage.networkId,
            finalizeMessage.token,
            finalizeMessage.from,
            finalizeMessage.to,
            finalizeMessage.amount,
            finalizeMessage.nonce);
        bytes32 ethSignedMessageHash_ = getEthSignedMessageHash(messageHash_);

        return recoverSigner(ethSignedMessageHash_, finalizeMessage.signature) == finalizeMessage.signer;
    }

    function verifyNative(
        NativeMessage memory finalizeMessage
    )
        public pure returns (bool)
    {

        bytes32 messageHash_ = getNativeMessageHash(
            finalizeMessage.networkId,
            finalizeMessage.from,
            finalizeMessage.to,
            finalizeMessage.amount,
            finalizeMessage.nonce
        );
        bytes32 ethSignedMessageHash_ = getEthSignedMessageHash(messageHash_);

        return recoverSigner(ethSignedMessageHash_,finalizeMessage.signature) == finalizeMessage.signer;
    }

    function recoverSigner(bytes32 ethSignedMessageHash, bytes memory signature)
        public pure returns (address)
    {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);

        return ecrecover(ethSignedMessageHash, v, r, s);
    }




    function splitSignature(bytes memory sig)
        public pure returns (bytes32 r, bytes32 s, uint8 v)
    {

        require(sig.length == 65, "SignVerifier: invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

    }

}




pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;





abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}




pragma solidity ^0.8.7;



abstract contract Guarded is AccessControl{

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    address private _owner;
    bool private _paused;

    modifier onlyOwner ()
    {
        require(_owner == _msgSender(), "Guard: not owner");
        _;
    }

    modifier onlyAdmin ()
    {
        require(hasRole(ADMIN_ROLE, _msgSender()), "Guard: not admin");
        _;
    }

    modifier onlyMinter () {
        require(hasRole(MINTER_ROLE, _msgSender()), "Guard: not minter");
        _;
    }

    modifier nonPaused () {
        require(!_paused, "Guard: contract paused");
        _;
    }

    modifier paused () {
        require(_paused, "Guard: contract is not paused");
        _;
    }

    constructor()
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
        _owner = _msgSender();
        _paused = false;
    }

    function pause() public onlyAdmin nonPaused returns (bool) {
        _paused = true;
        emit ContractPaused(block.number,_msgSender());
        return true;
    }

    function unpause() public onlyAdmin paused returns (bool) {
        _paused = false;
        emit ContractUnpaused(block.number,_msgSender());
        return true;
    }

    function isPaused() public view returns (bool) {
        return _paused;
    }

    function transferOwner (address owner) public onlyOwner returns (bool) {
        grantRole(DEFAULT_ADMIN_ROLE, owner);
        grantRole(ADMIN_ROLE, owner);

        revokeRole(DEFAULT_ADMIN_ROLE,_owner);
        revokeRole(ADMIN_ROLE,_owner);

        emit OwnerChanged(_owner,owner);

        _owner = owner;

        return true;
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) public onlyOwner {
        _setRoleAdmin(role,adminRole);
    }
    
    event ContractPaused(uint256 blockHeight, address admin);
    event ContractUnpaused(uint256 blockHeight, address admin);
    event OwnerChanged(address previousOwner, address currentOwner);

}




pragma solidity ^0.8.7;



abstract contract Blacklistable is Guarded {

    address public _blacklister;

    mapping(address => bool) internal _blacklisted;

    modifier onlyBlacklister() {
        require(_blacklister == _msgSender(),"Blacklistable: account is not blacklister");
        _;
    }

    modifier notBlacklisted(address account) {
        require(!_blacklisted[account],"Blacklistable: account is blacklisted");
        _;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklisted[account];
    }

    function blacklist(address account) public onlyBlacklister {
        _blacklisted[account] = true;
        emit Blacklisted(account);
    }

    function unBlacklist(address account) public onlyBlacklister {
        _blacklisted[account] = false;
        emit UnBlacklisted(account);
    }

    function updateBlacklister(address newBlacklister) external onlyOwner {
        require(
            newBlacklister != address(0),
            "Blacklistable: new blacklister is the zero address"
        );
        _blacklister = newBlacklister;
        emit BlacklisterChanged(newBlacklister);
    }

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event BlacklisterChanged(address indexed newBlacklister);
}




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


    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.8.7;



abstract contract TokenRecover is Guarded {

    using SafeERC20 for IERC20;

    function recoverERC20(address token, address recipient, uint256 amount) public onlyOwner() returns (bool)
    {
        IERC20(token).safeTransfer(recipient,amount);
        emit ERC20Recovered(token,recipient,amount);
        return true;
    }

    event ERC20Recovered(address token, address recipient, uint256 amount);
}



pragma solidity ^0.8.7;





contract Fiber is Guarded, Blacklistable, TokenRecover {


    mapping(address => bool) public _supportedTokens;
    mapping(address => bool) public _isLinkToken;

    mapping (address => bool) internal _verifiedSigners;

    bool private _isSupportedNative = false;

    modifier onlySupportedToken(address contractAddress) {

        require(isSupportedToken(contractAddress),"Fiber: token not supported");
        _;
    }

    modifier onlyVerifiedSigner(address signer) {

        require(_verifiedSigners[signer] == true,"Tracked:signer is not verified");
        _;
    }

    modifier isSupportedNative() {

        require(_isSupportedNative,"Fiber: Native not supported");
        _;
    }

    function isVerifiedSigner (address signer) public view returns (bool){
        return _verifiedSigners[signer];
    }

    function isSupportedToken (address contractAddress) public view returns (bool)
    {
        return _supportedTokens[contractAddress];
    }

    function addVerifiedSigner (address signer) public onlyOwner() returns (bool)
    {
        _verifiedSigners[signer] = true;
        return true;
    }

    function removeVerifiedSigner (address signer) public onlyOwner() returns (bool) {
        _verifiedSigners[signer] = false;
        return true;
    }

    function isLinkToken (address contractAddress) public view returns (bool) {
        return _isLinkToken[contractAddress];
    }

    function addSupportedToken (address contractAddress, bool isLToken) public onlyOwner returns (bool)
    {
        emit SupportedTokenAdded(contractAddress,isLToken, msg.sender);
        return _addSupportedToken(contractAddress,isLToken);
    }

    function removeSupportedToken (address contractAddress) public onlyOwner returns (bool)
    {
        emit SupportedTokenRemoved(contractAddress, msg.sender);
        return _removeSupportedToken (contractAddress);
    }

    function _addSupportedToken (address contractAddress,bool isLToken) internal virtual returns (bool)
    {
        _supportedTokens[contractAddress] = true;
        _isLinkToken[contractAddress] = isLToken;
        return true;
    }

    function _removeSupportedToken (address contractAddress) internal virtual returns (bool)
    {
        _supportedTokens[contractAddress] = false;
        _isLinkToken[contractAddress] = false;
        return true;
    }

    function changeNativeSupport(bool newValue) public onlyOwner() returns (bool)
    {

        _isSupportedNative = newValue;
        return true;
    }

    event SupportedTokenAdded(address contractAddress, bool isLToken, address admin);
    event SupportedTokenRemoved(address contractAddress, address admin);

}




pragma solidity ^0.8.7;

contract Tracked {


    struct nonceDataStruct {
        bool _isUsed;
        uint256 _inBlock;
    }

    struct contractTrackerStruct {
        uint256 _biggestWithdrawNonce;
        uint256 _depositNonce;
        mapping (uint256 => nonceDataStruct) _nonces;
    }

    mapping (address => contractTrackerStruct) internal _tracker;

    contractTrackerStruct _nativeTracker;


    modifier nonUsedNonce(address token, uint nonce) {

        require(_tracker[token]._nonces[nonce]._isUsed == false, "Tracker: nonce already used");
        _;
    }

    modifier nonUsedNativeNonce(uint nonce) {

        require(_nativeTracker._nonces[nonce]._isUsed == false,"Tracker: native nonce already used");
        _;
    }

    function useNonce(address token, uint nonce) internal nonUsedNonce(token,nonce) {

        _tracker[token]._nonces[nonce]._isUsed = true;
        _tracker[token]._nonces[nonce]._inBlock = block.number;

        if(nonce > _tracker[token]._biggestWithdrawNonce) {
            _tracker[token]._biggestWithdrawNonce = nonce;
        }

        emit NonceUsed(token,nonce,block.number);
    }

    function getNonceData(address token, uint256 nonce) public view returns (bool,uint256) {

        return(_tracker[token]._nonces[nonce]._isUsed,_tracker[token]._nonces[nonce]._inBlock);
    }

    function isUsedNonce(address token, uint256 nonce) public view returns (bool) {

        return(_tracker[token]._nonces[nonce]._isUsed);
    }

    function depositNonce(address token) internal {

        _tracker[token]._depositNonce+=1;
    }

    function getDepositNonce (address token) public view returns (uint256) {
        return _tracker[token]._depositNonce;
    }

    function nativeDepositNonce() internal {

        _nativeTracker._depositNonce+=1;
    }

    function getNativeDepositNonce() public view returns (uint256) {

        return _nativeTracker._depositNonce;
    }

    function isUsedNativeNonce(uint256 nonce) public view returns (bool) {

        return(_nativeTracker._nonces[nonce]._isUsed);
    }

    function useNativeNonce(uint nonce) internal nonUsedNativeNonce(nonce) {

        _nativeTracker._nonces[nonce]._isUsed = true;
        _nativeTracker._nonces[nonce]._inBlock = block.number;

        if(nonce > _nativeTracker._biggestWithdrawNonce) {
            _nativeTracker._biggestWithdrawNonce = nonce;
        }

        emit NativeNonceUsed(nonce,block.number);
    }

    event NonceUsed(address token, uint256 nonce, uint256 blockNumber);
    event NativeNonceUsed(uint256 nonce, uint256 blockNumber);
}



pragma solidity ^0.8.7;








interface ERC20Tokens {

    function burnFrom(address account, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mintTo(address account, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

}

contract OmLink is Fiber, SignVerifier, Tracked
{


    using SafeERC20 for IERC20;

    uint256 public _chainId;

    struct finalizer {
        uint256 toChain;
        address from;
        address to;
        uint256 amount;
        address tokenAddress;
        uint256 nonce;
        address signer;
        bytes signature;
    }

    constructor(uint256 chainId) {
        _chainId = chainId;
    }


    function deposit(
        uint256 toChain,
        address token,
        address to,
        uint256 amount
    ) public 
        onlySupportedToken(token) 
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        nonPaused()
        returns (bool) {


            if(isLinkToken(token)) {
                require(ERC20Tokens(token).burnFrom(msg.sender,amount),"omLink: cannot burn tokens");
            } else {
                IERC20(token).safeTransferFrom(msg.sender,address(this),amount);
            }

            depositNonce(token);


            emit LinkStarted(toChain,token,msg.sender,to,amount,getDepositNonce(token));

            return true;
    }

    function depositNative(
        uint256 toChain,
        address to,
        uint256 amount
    ) payable public 
        isSupportedNative()
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        nonPaused()
        returns (bool) {

            require(msg.value == amount,"omLink: wrong native amount");

            nativeDepositNonce();

            emit LinkStarted(toChain,address(0),msg.sender,to,amount,getNativeDepositNonce());

            return true;
    }

    function finalize(
        uint256 toChain,
        address token,
        address from,
        address to,
        uint256 amount,
        uint256 nonce,
        bytes memory signature,
        address signer
    ) public 
        onlySupportedToken(token) 
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        nonPaused()
        onlyVerifiedSigner(signer)
        returns (bool) {



            require(_chainId == toChain,"omLink:incorrect chain");
            require(!isUsedNonce(token,nonce),"Tracked:used nonce");

            
            Message memory messageStruct_;

            messageStruct_.networkId = toChain;
            messageStruct_.token = token;
            messageStruct_.from = from;
            messageStruct_.to = to;
            messageStruct_.amount = amount;
            messageStruct_.nonce = nonce;
            messageStruct_.signature = signature;
            messageStruct_.signer = signer;

            require(verify(messageStruct_),"omLink: signature cant be verified");


            useNonce(token,nonce);

            if( isLinkToken(token) ) {
                ERC20Tokens(token).mintTo(to,amount);
            } else {
                IERC20(token).safeTransfer(to,amount);
            }

            emit LinkFinalized(
                messageStruct_.networkId,
                messageStruct_.token,
                messageStruct_.from,
                messageStruct_.to,
                messageStruct_.amount,
                messageStruct_.nonce,
                messageStruct_.signer);

            return true;
    }

    function finalizeNative(
        uint256 toChain,
        address from,
        address to,
        uint256 amount,
        uint256 nonce,
        bytes memory signature,
        address signer
    ) public 
        isSupportedNative()
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        nonPaused()
        onlyVerifiedSigner(signer)
        returns (bool) {

            require(_chainId == toChain,"omLink:incorrect chain");
            require(!isUsedNativeNonce(nonce),"Tracked:used nonce");

            NativeMessage memory messageStruct_;

            messageStruct_.networkId = toChain;
            messageStruct_.from = from;
            messageStruct_.to = to;
            messageStruct_.amount = amount;
            messageStruct_.nonce = nonce;
            messageStruct_.signature = signature;
            messageStruct_.signer = signer;

            require(verifyNative(messageStruct_),"omLink: message cant be verified");
            require(address(this).balance >= amount,"omLink: not enough native");

            useNativeNonce(nonce);

            address payable receiver = payable(to);
            receiver.transfer(amount);

            emit LinkFinalized(
                messageStruct_.networkId,
                address(0),
                messageStruct_.from,
                messageStruct_.to,
                messageStruct_.amount,
                messageStruct_.nonce,
                messageStruct_.signer
            );

            return true;

        }

    function invalidateNonce(address token, uint256 nonce) public onlyOwner returns (bool) {

        
        require(!isUsedNonce(token,nonce),"Tracked:used nonce");
        useNonce(token,nonce);

        emit NonceInvalidated(_chainId,token,msg.sender,nonce,block.number);
        return true;
    }

    function invalidateNative(uint256 nonce) public onlyOwner returns (bool) {

        require(!isUsedNativeNonce(nonce),"Tracked:used nonce");
        useNativeNonce(nonce);

        emit NativeNonceInvalidated(_chainId,msg.sender,nonce,block.number);
        return true;
    }


    event LinkStarted(uint256 toChain, address tokenAddress, address from, address to, uint256 amount, uint256 indexed depositNonce);
    event LinkFinalized(uint256 chainId, address tokenAddress, address from, address to, uint256 amount, uint256 indexed nonce, address signer);
    
    event NonceInvalidated(uint256 chainId, address tokenAddress, address owner, uint256 indexed nonce, uint atBlock);
    event NativeNonceInvalidated(uint256 chainId, address owner, uint256 indexed nonce, uint atBlock);

}