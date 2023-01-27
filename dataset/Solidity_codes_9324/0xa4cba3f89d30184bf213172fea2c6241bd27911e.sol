

pragma solidity ^0.5.0;


contract TokenUpgrader {

    uint public originalSupply;

    function isTokenUpgrader() external pure returns (bool) {

        return true;
    }

    function upgradeFrom(address _from, uint256 _value) public;

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

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;



contract AgentRole is Ownable {

    using Roles for Roles.Role;

    event AgentAdded(address indexed account);
    event AgentRemoved(address indexed account);

    Roles.Role private _agents;

    modifier onlyAgent() {

        require(isAgent(msg.sender), "AgentRole: caller does not have the Agent role");
        _;
    }

    function isAgent(address account) public view returns (bool) {

        return _agents.has(account);
    }

    function addAgent(address account) public onlyOwner {

        _addAgent(account);
    }

    function removeAgent(address account) public onlyOwner {

        _removeAgent(account);
    }

    function _addAgent(address account) internal {

        _agents.add(account);
        emit AgentAdded(account);
    }

    function _removeAgent(address account) internal {

        _agents.remove(account);
        emit AgentRemoved(account);
    }
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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.10;

interface ICompliance {

    function canTransfer(address _from, address _to, uint256 value) external returns (bool);

}


pragma solidity ^0.5.10;


contract IClaimIssuer{

    uint public issuedClaimCount;

    mapping (bytes => bool) revokedClaims;
    mapping (bytes32 => address) identityAddresses;

    event ClaimValid(Identity _identity, uint256 claimTopic);
    event ClaimInvalid(Identity _identity, uint256 claimTopic);

    function revokeClaim(bytes32 _claimId, address _identity) public returns(bool);

    function isClaimRevoked(bytes memory _sig) public view returns(bool result);

    function isClaimValid(Identity _identity, bytes32 _claimId, uint256 claimTopic, bytes memory sig, bytes memory data)
    public
    view
    returns (bool claimValid);


}


pragma solidity ^0.5.10;


interface ITrustedIssuersRegistry {

    event TrustedIssuerAdded(uint indexed index, ClaimIssuer indexed trustedIssuer, uint[] claimTopics);
    event TrustedIssuerRemoved(uint indexed index, ClaimIssuer indexed trustedIssuer);
    event TrustedIssuerUpdated(uint indexed index, ClaimIssuer indexed oldTrustedIssuer, ClaimIssuer indexed newTrustedIssuer, uint[] claimTopics);

    function getTrustedIssuer(uint index) external view returns (ClaimIssuer);

    function getTrustedIssuerClaimTopics(uint index) external view returns(uint[] memory);

    function getTrustedIssuers() external view returns (uint[] memory);

    function hasClaimTopic(address issuer, uint claimTopic) external view returns(bool);

    function isTrustedIssuer(address issuer) external view returns(bool);


    function addTrustedIssuer(ClaimIssuer _trustedIssuer, uint index, uint[] calldata claimTopics) external;

    function removeTrustedIssuer(uint index) external;

    function updateIssuerContract(uint index, ClaimIssuer _newTrustedIssuer, uint[] calldata claimTopics) external;

}


pragma solidity ^0.5.10;





interface IIdentityRegistry {

    event ClaimTopicsRegistrySet(address indexed _claimTopicsRegistry);
    event CountryUpdated(address indexed investorAddress, uint16 indexed country);
    event IdentityRegistered(address indexed investorAddress, Identity indexed identity);
    event IdentityRemoved(address indexed investorAddress, Identity indexed identity);
    event IdentityUpdated(Identity indexed old_identity, Identity indexed new_identity);
    event TrustedIssuersRegistrySet(address indexed _trustedIssuersRegistry);

    function deleteIdentity(address _user) external;

    function registerIdentity(address _user, Identity _identity, uint16 _country) external;

    function setClaimTopicsRegistry(address _claimTopicsRegistry) external;

    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external;

    function updateCountry(address _user, uint16 _country) external;

    function updateIdentity(address _user, Identity _identity) external;


    function contains(address _wallet) external view returns (bool);

    function isVerified(address _userAddress) external view returns (bool);


    function identity(address _wallet) external view returns (Identity);

    function investorCountry(address _wallet) external view returns (uint16);

    function issuersRegistry() external view returns (ITrustedIssuersRegistry);

    function topicsRegistry() external view returns (IClaimTopicsRegistry);

}


pragma solidity ^0.5.10;

interface IClaimTopicsRegistry{

    event ClaimTopicAdded(uint256 indexed claimTopic);
    event ClaimTopicRemoved(uint256 indexed claimTopic);

    function addClaimTopic(uint256 claimTopic) external;

    function removeClaimTopic(uint256 claimTopic) external;


    function getClaimTopics() external view returns (uint256[] memory);

}


pragma solidity ^0.5.10;

interface IERC735 {


    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    event ClaimAdded(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    event ClaimChanged(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    struct Claim {
        uint256 topic;
        uint256 scheme;
        address issuer;
        bytes signature;
        bytes data;
        string uri;
    }

    function getClaim(bytes32 _claimId) external view returns(uint256 topic, uint256 scheme, address issuer, bytes memory signature, bytes memory data, string memory uri);


    function getClaimIdsByTopic(uint256 _topic) external view returns(bytes32[] memory claimIds);


    function addClaim(uint256 _topic, uint256 _scheme, address issuer, bytes calldata _signature, bytes calldata _data, string calldata _uri) external returns (bytes32 claimRequestId);


    function removeClaim(bytes32 _claimId) external returns (bool success);

}


pragma solidity ^0.5.10;

interface IERC734 {

    struct Key {
        uint256[] purposes;
        uint256 keyType;
        bytes32 key;
    }

    event Approved(uint256 indexed executionId, bool approved);

    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    event KeysRequiredChanged(uint256 purpose, uint256 number);


    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) external returns (bool success);


    function approve(uint256 _id, bool _approve) external returns (bool success);


    function changeKeysRequired(uint256 purpose, uint256 number) external;


    function execute(address _to, uint256 _value, bytes calldata _data) external payable returns (uint256 executionId);


    function getKey(bytes32 _key) external view returns (uint256[] memory purposes, uint256 keyType, bytes32 key);


    function getKeyPurposes(bytes32 _key) external view returns(uint256[] memory _purposes);


    function getKeysByPurpose(uint256 _purpose) external view returns (bytes32[] memory keys);


    function getKeysRequired(uint256 purpose) external view returns (uint256);


    function keyHasPurpose(bytes32 _key, uint256 _purpose) external view returns (bool exists);


    function removeKey(bytes32 _key, uint256 _purpose) external returns (bool success);

}


pragma solidity ^0.5.10;


contract ERC734 is IERC734 {

    uint256 public constant MANAGEMENT_KEY = 1;
    uint256 public constant ACTION_KEY = 2;
    uint256 public constant CLAIM_SIGNER_KEY = 3;
    uint256 public constant ENCRYPTION_KEY = 4;

    uint256 private executionNonce;

    struct Execution {
        address to;
        uint256 value;
        bytes data;
        bool approved;
        bool executed;
    }

    mapping (bytes32 => Key) private keys;
    mapping (uint256 => bytes32[]) private keysByPurpose;
    mapping (uint256 => Execution) private executions;

    event ExecutionFailed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    constructor() public {
        bytes32 _key = keccak256(abi.encode(msg.sender));

        keys[_key].key = _key;
        keys[_key].purposes = [1];
        keys[_key].keyType = 1;

        keysByPurpose[1].push(_key);

        emit KeyAdded(_key, 1, 1);
    }

    function getKey(bytes32 _key)
    public
    view
    returns(uint256[] memory purposes, uint256 keyType, bytes32 key)
    {

        return (keys[_key].purposes, keys[_key].keyType, keys[_key].key);
    }

    function getKeyPurposes(bytes32 _key)
    public
    view
    returns(uint256[] memory _purposes)
    {

        return (keys[_key].purposes);
    }

    function getKeysByPurpose(uint256 _purpose)
    public
    view
    returns(bytes32[] memory _keys)
    {

        return keysByPurpose[_purpose];
    }


    function addKey(bytes32 _key, uint256 _purpose, uint256 _type)
    public
    returns (bool success)
    {

        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 1), "Permissions: Sender does not have management key");
        }

        if (keys[_key].key == _key) {
            for (uint keyPurposeIndex = 0; keyPurposeIndex < keys[_key].purposes.length; keyPurposeIndex++) {
                uint256 purpose = keys[_key].purposes[keyPurposeIndex];

                if (purpose == _purpose) {
                    revert("Conflict: Key already has purpose");
                }
            }

            keys[_key].purposes.push(_purpose);
        } else {
            keys[_key].key = _key;
            keys[_key].purposes = [_purpose];
            keys[_key].keyType = _type;
        }

        keysByPurpose[_purpose].push(_key);

        emit KeyAdded(_key, _purpose, _type);

        return true;
    }

    function approve(uint256 _id, bool _approve)
    public
    returns (bool success)
    {

        require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 2), "Sender does not have action key");

        emit Approved(_id, _approve);

        if (_approve == true) {
            executions[_id].approved = true;

            (success,) = executions[_id].to.call.value(executions[_id].value)(abi.encode(executions[_id].data, 0));

            if (success) {
                executions[_id].executed = true;

                emit Executed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );

                return true;
            } else {
                emit ExecutionFailed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );

                return false;
            }
        } else {
            executions[_id].approved = false;
        }
        return true;
    }

    function execute(address _to, uint256 _value, bytes memory _data)
    public
    payable
    returns (uint256 executionId)
    {

        require(!executions[executionNonce].executed, "Already executed");
        executions[executionNonce].to = _to;
        executions[executionNonce].value = _value;
        executions[executionNonce].data = _data;

        emit ExecutionRequested(executionNonce, _to, _value, _data);

        if (keyHasPurpose(keccak256(abi.encode(msg.sender)), 2)) {
            approve(executionNonce, true);
        }

        executionNonce++;
        return executionNonce-1;
    }

    function removeKey(bytes32 _key, uint256 _purpose)
    public
    returns (bool success)
    {

        require(keys[_key].key == _key, "NonExisting: Key isn't registered");

        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 1), "Permissions: Sender does not have management key"); // Sender has MANAGEMENT_KEY
        }

        require(keys[_key].purposes.length > 0, "NonExisting: Key doesn't have such purpose");

        uint purposeIndex = 0;
        while (keys[_key].purposes[purposeIndex] != _purpose) {
            purposeIndex++;

            if (purposeIndex >= keys[_key].purposes.length) {
                break;
            }
        }

        require(purposeIndex < keys[_key].purposes.length, "NonExisting: Key doesn't have such purpose");

        keys[_key].purposes[purposeIndex] = keys[_key].purposes[keys[_key].purposes.length - 1];
        keys[_key].purposes.pop();

        uint keyIndex = 0;

        while (keysByPurpose[_purpose][keyIndex] != _key) {
            keyIndex++;
        }

        keysByPurpose[_purpose][keyIndex] = keysByPurpose[_purpose][keysByPurpose[_purpose].length - 1];
        keysByPurpose[_purpose].pop();

        uint keyType = keys[_key].keyType;

        if (keys[_key].purposes.length == 0) {
            delete keys[_key];
        }

        emit KeyRemoved(_key, _purpose, keyType);

        return true;
    }

    function changeKeysRequired(uint256 purpose, uint256 number) external
    {

        revert();
    }

    function getKeysRequired(uint256 purpose) external view returns(uint256 number)
    {

        revert();
    }

    function keyHasPurpose(bytes32 _key, uint256 _purpose)
    public
    view
    returns(bool result)
    {

        Key memory key = keys[_key];
        if (key.key == 0) return false;

        for (uint keyPurposeIndex = 0; keyPurposeIndex < key.purposes.length; keyPurposeIndex++) {
            uint256 purpose = key.purposes[keyPurposeIndex];

            if (purpose == MANAGEMENT_KEY || purpose == _purpose) return true;
        }

        return false;
    }
}


pragma solidity ^0.5.10;



contract Identity is ERC734, IERC735 {


    mapping (bytes32 => Claim) private claims;
    mapping (uint256 => bytes32[]) private claimsByTopic;


    function addClaim(
        uint256 _topic,
        uint256 _scheme,
        address _issuer,
        bytes memory _signature,
        bytes memory _data,
        string memory _uri
    )
    public
    returns (bytes32 claimRequestId)
    {

        bytes32 claimId = keccak256(abi.encode(_issuer, _topic));

        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 3), "Permissions: Sender does not have claim signer key");
        }

        if (claims[claimId].issuer != _issuer) {
            claimsByTopic[_topic].push(claimId);
            claims[claimId].topic = _topic;
            claims[claimId].scheme = _scheme;
            claims[claimId].issuer = _issuer;
            claims[claimId].signature = _signature;
            claims[claimId].data = _data;
            claims[claimId].uri = _uri;

            emit ClaimAdded(
                claimId,
                _topic,
                _scheme,
                _issuer,
                _signature,
                _data,
                _uri
            );
        } else {
            claims[claimId].topic = _topic;
            claims[claimId].scheme = _scheme;
            claims[claimId].issuer = _issuer;
            claims[claimId].signature = _signature;
            claims[claimId].data = _data;
            claims[claimId].uri = _uri;

            emit ClaimChanged(
                claimId,
                _topic,
                _scheme,
                _issuer,
                _signature,
                _data,
                _uri
            );
        }

        return claimId;
    }


    function removeClaim(bytes32 _claimId) public returns (bool success) {

        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 1), "Permissions: Sender does not have CLAIM key");
        }

        if (claims[_claimId].topic == 0) {
            revert("NonExisting: There is no claim with this ID");
        }

        uint claimIndex = 0;
        while (claimsByTopic[claims[_claimId].topic][claimIndex] != _claimId) {
            claimIndex++;
        }

        claimsByTopic[claims[_claimId].topic][claimIndex] = claimsByTopic[claims[_claimId].topic][claimsByTopic[claims[_claimId].topic].length - 1];
        claimsByTopic[claims[_claimId].topic].pop();

        emit ClaimRemoved(
            _claimId,
            claims[_claimId].topic,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );

        delete claims[_claimId];

        return true;
    }


    function getClaim(bytes32 _claimId)
    public
    view
    returns(
        uint256 topic,
        uint256 scheme,
        address issuer,
        bytes memory signature,
        bytes memory data,
        string memory uri
    )
    {

        return (
            claims[_claimId].topic,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );
    }


    function getClaimIdsByTopic(uint256 _topic)
    public
    view
    returns(bytes32[] memory claimIds)
    {

        return claimsByTopic[_topic];
    }
}


pragma solidity ^0.5.10;



contract ClaimIssuer is IClaimIssuer, Identity {

    function revokeClaim(bytes32 _claimId, address _identity) public returns(bool) {

        uint256 foundClaimTopic;
        uint256 scheme;
        address issuer;
        bytes memory  sig;
        bytes  memory data;

		if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 1), "Permissions: Sender does not have management key");
        }
		
        ( foundClaimTopic, scheme, issuer, sig, data, ) = Identity(_identity).getClaim(_claimId);

        revokedClaims[sig] = true;
        identityAddresses[_claimId] = _identity;
        return true;
    }

    function isClaimRevoked(bytes memory _sig) public view returns (bool) {

        if(revokedClaims[_sig]) {
            return true;
        }

        return false;
    }

    function isClaimValid(Identity _identity, bytes32 _claimId, uint256 claimTopic, bytes memory sig, bytes memory data)
    public
    view
    returns (bool claimValid)
    {

        bytes32 dataHash = keccak256(abi.encode(_identity, claimTopic, data));
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash));

        address recovered = getRecoveredAddress(sig, prefixedHash);

        bytes32 hashedAddr = keccak256(abi.encode(recovered));

        if (keyHasPurpose(hashedAddr, 3) && (isClaimRevoked(sig) == false)) {
            return true;
        }

        return false;
    }

    function getRecoveredAddress(bytes memory sig, bytes32 dataHash)
        public
        pure
        returns (address addr)
    {

        bytes32 ra;
        bytes32 sa;
        uint8 va;

        if (sig.length != 65) {
            return address(0);
        }

        assembly {
          ra := mload(add(sig, 32))
          sa := mload(add(sig, 64))
          va := byte(0, mload(add(sig, 96)))
        }

        if (va < 27) {
            va += 27;
        }

        address recoveredAddress = ecrecover(dataHash, va, ra, sa);

        return (recoveredAddress);
    }
}


pragma solidity ^0.5.10;









contract Pausable is AgentRole, ERC20 {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyAgent whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyAgent whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }
}


contract TransferManager is Pausable {


    mapping(address => uint256) private holderIndices;
    mapping(address => address) private cancellations;
    mapping (address => bool) frozen;
    mapping (address => Identity)  _identity;
    mapping (address => uint256) public freezedTokens;

    mapping(uint16 => uint256) countryShareHolders;
	
    address[] private shareholders;
    bytes32[] public claimsNotInNewAddress;

    IIdentityRegistry public identityRegistry;

    ICompliance public compliance;

    event IdentityRegistryAdded(address indexed _identityRegistry);

    event ComplianceAdded(address indexed _compliance);

    event VerifiedAddressSuperseded(
        address indexed original,
        address indexed replacement,
        address indexed sender
    );

    event AddressFrozen(
        address indexed addr,
        bool indexed isFrozen,
        address indexed owner
    );

    event recoverySuccess(
        address wallet_lostAddress,
        address wallet_newAddress,
        address onchainID
    );

    event recoveryFails(
        address wallet_lostAddress,
        address wallet_newAddress,
        address onchainID
    );

    event TokensFreezed(address indexed addr, uint256 amount);
    
    event TokensUnfreezed(address indexed addr, uint256 amount);
    
    constructor (
        address _identityRegistry,
        address _compliance
    ) public {
        identityRegistry = IIdentityRegistry(_identityRegistry);
        emit IdentityRegistryAdded(_identityRegistry);
        compliance = ICompliance(_compliance);
        emit ComplianceAdded(_compliance);
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {

        require(!frozen[_to] && !frozen[msg.sender]);
        require(_value <=  balanceOf(msg.sender).sub(freezedTokens[msg.sender]), "Insufficient Balance" );
        if(identityRegistry.isVerified(_to) && compliance.canTransfer(msg.sender, _to, _value)){
            updateShareholders(_to);
            pruneShareholders(msg.sender, _value);
            return super.transfer(_to, _value);
        }

        revert("Transfer not possible");
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {

        require(!frozen[_to] && !frozen[_from]);
        require(_value <=  balanceOf(_from).sub(freezedTokens[_from]), "Insufficient Balance" );
        if(identityRegistry.isVerified(_to) && compliance.canTransfer(_from, _to, _value)){
            updateShareholders(_to);
            pruneShareholders(_from, _value);
            return super.transferFrom(_from, _to, _value);
        }

        revert("Transfer not possible");
    }

    function holderCount()
        public
        view
        returns (uint)
    {

        return shareholders.length;
    }

    function holderAt(uint256 index)
        public
        onlyOwner
        view
        returns (address)
    {

        require(index < shareholders.length);
        return shareholders[index];
    }


    function updateShareholders(address addr)
        internal
    {

        if (holderIndices[addr] == 0) {
            holderIndices[addr] = shareholders.push(addr);
            uint16 country = identityRegistry.investorCountry(addr);
            countryShareHolders[country]++;
        }
    }

    function pruneShareholders(address addr, uint256 value)
        internal
    {

        uint256 balance = balanceOf(addr) - value;
        if (balance > 0) {
            return;
        }
        uint256 holderIndex = holderIndices[addr] - 1;
        uint256 lastIndex = shareholders.length - 1;
        address lastHolder = shareholders[lastIndex];
        shareholders[holderIndex] = lastHolder;
        holderIndices[lastHolder] = holderIndices[addr];
        shareholders.length--;
        holderIndices[addr] = 0;
        uint16 country = identityRegistry.investorCountry(addr);
        countryShareHolders[country]--;
    }

    function getShareholderCountByCountry(uint16 index) public view returns (uint) {

        return countryShareHolders[index];
    }

    function isSuperseded(address addr)
        public
        view
        onlyOwner
        returns (bool)
    {

        return cancellations[addr] != address(0);
    }

    function getCurrentFor(address addr)
        public
        view
        onlyOwner
        returns (address)
    {

        return findCurrentFor(addr);
    }

    function findCurrentFor(address addr)
        internal
        view
        returns (address)
    {

        address candidate = cancellations[addr];
        if (candidate == address(0)) {
            return addr;
        }
        return findCurrentFor(candidate);
    }

    function setAddressFrozen(address addr, bool freeze)
    external
    onlyAgent {

        frozen[addr] = freeze;

        emit AddressFrozen(addr, freeze, msg.sender);
    }

    function freezePartialTokens(address addr, uint256 amount)
        onlyAgent
        external
    {

        uint256 balance = balanceOf(addr);
        require(balance >= freezedTokens[addr]+amount, 'Amount exceeds available balance');
        freezedTokens[addr] += amount;
        emit TokensFreezed(addr, amount);
    }
    
    function unfreezePartialTokens(address addr, uint256 amount)
        onlyAgent
        external
    {

        require(freezedTokens[addr] >= amount, 'Amount should be less than or equal to freezed tokens');
        freezedTokens[addr] -= amount;
        emit TokensUnfreezed(addr, amount);
    }

    function setIdentityRegistry(address _identityRegistry) public onlyOwner {

        identityRegistry = IIdentityRegistry(_identityRegistry);
        emit IdentityRegistryAdded(_identityRegistry);
    }

    function setCompliance(address _compliance) public onlyOwner {

        compliance = ICompliance(_compliance);
        emit ComplianceAdded(_compliance);
    }

    uint256[]  claimTopics;
    bytes32[]  lostAddressClaimIds;
    bytes32[]  newAddressClaimIds;
    uint256 foundClaimTopic;
    uint256 scheme;
    address issuer;
    bytes  sig;
    bytes  data;

    function recoveryAddress(address wallet_lostAddress, address wallet_newAddress, address onchainID) public onlyAgent {

        require(holderIndices[wallet_lostAddress] != 0 && holderIndices[wallet_newAddress] == 0);
        require(identityRegistry.contains(wallet_lostAddress), "wallet should be in the registry");

        Identity _onchainID = Identity(onchainID);

        bytes32 _key = keccak256(abi.encode(msg.sender));

        if(_onchainID.keyHasPurpose(_key, 1)) {
            uint investorTokens = balanceOf(wallet_lostAddress);
            _burn(wallet_lostAddress, investorTokens);

            bytes32 lostWalletkey = keccak256(abi.encode(wallet_lostAddress));
            if (_onchainID.keyHasPurpose(lostWalletkey, 1)) {
                uint256[] memory purposes = _onchainID.getKeyPurposes(lostWalletkey);
                for(uint _purpose = 0; _purpose <= purposes.length; _purpose++){
                    if(_purpose != 0)
                        _onchainID.removeKey(lostWalletkey, _purpose);
                }
            }

            identityRegistry.registerIdentity(wallet_newAddress, _onchainID, identityRegistry.investorCountry(wallet_lostAddress));

            identityRegistry.deleteIdentity(wallet_lostAddress);

            cancellations[wallet_lostAddress] = wallet_newAddress;
        	uint256 holderIndex = holderIndices[wallet_lostAddress] - 1;
        	shareholders[holderIndex] = wallet_newAddress;
        	holderIndices[wallet_newAddress] = holderIndices[wallet_lostAddress];
        	holderIndices[wallet_lostAddress] = 0;

            _mint(wallet_newAddress, investorTokens);

            emit recoverySuccess(wallet_lostAddress, wallet_newAddress, onchainID);

        }
        else {
            emit recoveryFails(wallet_lostAddress, wallet_newAddress, onchainID);
        }
    }
}


pragma solidity ^0.5.10;



contract MintableAndBurnable is TransferManager {



    function mint(address _to, uint256 _amount)
        external
        onlyAgent {

        require(identityRegistry.isVerified(_to), "Identity is not verified.");
        _mint(_to, _amount);
        updateShareholders(_to);
    }

    function burn(address account, uint256 value)
        public
        onlyAgent {

        _burn(account, value);
    }
}


pragma solidity ^0.5.0;





contract UpgradeableToken is MintableAndBurnable {

    address public upgradeMaster;
    
    bool private upgradesAllowed;

    TokenUpgrader public tokenUpgrader;

    uint public totalUpgraded;

    enum UpgradeState { NotAllowed, Waiting, ReadyToUpgrade, Upgrading }

    event Upgrade(address indexed _from, address indexed _to, uint256 _value);

    event TokenUpgraderIsSet(address _newToken);

    modifier onlyUpgradeMaster {

        require(msg.sender == upgradeMaster);
        _;
    }

    modifier notInUpgradingState {

        require(getUpgradeState() != UpgradeState.Upgrading);
        _;
    }

    constructor(address _upgradeMaster) public {
        upgradeMaster = _upgradeMaster;
    }

    function setTokenUpgrader(address _newToken)
        external
        onlyUpgradeMaster
        notInUpgradingState
    {

        require(canUpgrade());
        require(_newToken != address(0));


        tokenUpgrader = TokenUpgrader(_newToken);

        require(tokenUpgrader.isTokenUpgrader());

        require(tokenUpgrader.originalSupply() == totalSupply());
    
        emit TokenUpgraderIsSet(address(tokenUpgrader));
    }

    function upgrade(uint _value) external {

        UpgradeState state = getUpgradeState();
        
        require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading);
        require(_value != 0);

        _burn(msg.sender, _value);   //defined in erc20

        totalUpgraded = totalUpgraded.add(_value);

        tokenUpgrader.upgradeFrom(msg.sender, _value);
        emit Upgrade(msg.sender, address(tokenUpgrader), _value);
    }

    function setUpgradeMaster(address _newMaster) external onlyUpgradeMaster {

        require(_newMaster != address(0));
        upgradeMaster = _newMaster;
    }

    function allowUpgrades() external onlyUpgradeMaster () {

        upgradesAllowed = true;
    }

    function rejectUpgrades() external onlyUpgradeMaster () {

        require(!(totalUpgraded > 0));
        upgradesAllowed = false;
    }

    function getUpgradeState() public view returns(UpgradeState) {

        if (!canUpgrade()) return UpgradeState.NotAllowed;
        else if (address(tokenUpgrader) == address(0)) return UpgradeState.Waiting;
        else if (totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
        else return UpgradeState.Upgrading;
    }

    function canUpgrade() public view returns(bool) {

        return upgradesAllowed;
    }
}


pragma solidity ^0.5.10;



contract Token is UpgradeableToken {

    string public name = "FLYT TOKEN";
    string public symbol = "FLYT";
    uint8 public decimals = 0;
    string public version = "1.2";
    address public onchainID = 0x0000000000000000000000000000000000000000;
    
    event UpdatedTokenInformation(
		string newName,
		string newSymbol,
		uint8 newDecimals,
		string newVersion,
		address newOnchainID
	);

    constructor(
        address _identityRegistry,
        address _compliance,
        address _upgradeMaster
		)
        public
		TransferManager(_identityRegistry, _compliance)
		UpgradeableToken(_upgradeMaster)
    {}

    function setTokenInformation(
		string calldata _name,
		string calldata _symbol,
		uint8 _decimals,
		string calldata _version,
		address _onchainID
		) external onlyOwner {


        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        version = _version;
		onchainID = _onchainID;

        emit UpdatedTokenInformation(name, symbol, decimals, version, onchainID);
    }
}