



pragma solidity ^0.8.0;

interface IERC734 {


    event Approved(uint256 indexed executionId, bool approved);

    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    event ExecutionFailed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    event KeysRequiredChanged(uint256 purpose, uint256 number);


    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) external returns (bool success);


    function approve(uint256 _id, bool _approve) external returns (bool success);


    function execute(address _to, uint256 _value, bytes calldata _data) external payable returns (uint256 executionId);


    function getKey(bytes32 _key) external view returns (uint256[] memory purposes, uint256 keyType, bytes32 key);


    function getKeyPurposes(bytes32 _key) external view returns(uint256[] memory _purposes);


    function getKeysByPurpose(uint256 _purpose) external view returns (bytes32[] memory keys);


    function keyHasPurpose(bytes32 _key, uint256 _purpose) external view returns (bool exists);


    function removeKey(bytes32 _key, uint256 _purpose) external returns (bool success);

}


interface IERC735 {


    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    event ClaimAdded(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    event ClaimChanged(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    function getClaim(bytes32 _claimId) external view returns(uint256 topic, uint256 scheme, address issuer, bytes memory signature, bytes memory data, string memory uri);


    function getClaimIdsByTopic(uint256 _topic) external view returns(bytes32[] memory claimIds);


    function addClaim(uint256 _topic, uint256 _scheme, address issuer, bytes calldata _signature, bytes calldata _data, string calldata _uri) external returns (bytes32 claimRequestId);


    function removeClaim(bytes32 _claimId) external returns (bool success);

}



interface IIdentity is IERC734, IERC735 {}




interface IClaimIssuer is IIdentity {

    function revokeClaim(bytes32 _claimId, address _identity) external returns(bool);

    function getRecoveredAddress(bytes calldata sig, bytes32 dataHash) external pure returns (address);

    function isClaimRevoked(bytes calldata _sig) external view returns (bool);

    function isClaimValid(IIdentity _identity, uint256 claimTopic, bytes calldata sig, bytes calldata data) external view returns (bool);

}



interface ITrustedIssuersRegistry {

    event TrustedIssuerAdded(IClaimIssuer indexed trustedIssuer, uint256[] claimTopics);

    event TrustedIssuerRemoved(IClaimIssuer indexed trustedIssuer);

    event ClaimTopicsUpdated(IClaimIssuer indexed trustedIssuer, uint256[] claimTopics);

    function addTrustedIssuer(IClaimIssuer _trustedIssuer, uint256[] calldata _claimTopics) external;


    function removeTrustedIssuer(IClaimIssuer _trustedIssuer) external;


    function updateIssuerClaimTopics(IClaimIssuer _trustedIssuer, uint256[] calldata _claimTopics) external;


    function getTrustedIssuers() external view returns (IClaimIssuer[] memory);


    function isTrustedIssuer(address _issuer) external view returns (bool);


    function getTrustedIssuerClaimTopics(IClaimIssuer _trustedIssuer) external view returns (uint256[] memory);


    function hasClaimTopic(address _issuer, uint256 _claimTopic) external view returns (bool);


    function transferOwnershipOnIssuersRegistryContract(address _newOwner) external;

}



pragma solidity ^0.8.0;

interface IClaimTopicsRegistry {

    event ClaimTopicAdded(uint256 indexed claimTopic);

    event ClaimTopicRemoved(uint256 indexed claimTopic);

    function addClaimTopic(uint256 _claimTopic) external;


    function removeClaimTopic(uint256 _claimTopic) external;


    function getClaimTopics() external view returns (uint256[] memory);


    function transferOwnershipOnClaimTopicsRegistryContract(address _newOwner) external;

}




interface IIdentityRegistryStorage {

    event IdentityStored(address indexed investorAddress, IIdentity indexed identity);

    event IdentityUnstored(address indexed investorAddress, IIdentity indexed identity);

    event IdentityModified(IIdentity indexed oldIdentity, IIdentity indexed newIdentity);

    event CountryModified(address indexed investorAddress, uint16 indexed country);

    event IdentityRegistryBound(address indexed identityRegistry);

    event IdentityRegistryUnbound(address indexed identityRegistry);

    function linkedIdentityRegistries() external view returns (address[] memory);


    function storedIdentity(address _userAddress) external view returns (IIdentity);


    function storedInvestorCountry(address _userAddress) external view returns (uint16);


    function addIdentityToStorage(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) external;


    function removeIdentityFromStorage(address _userAddress) external;


    function modifyStoredInvestorCountry(address _userAddress, uint16 _country) external;


    function modifyStoredIdentity(address _userAddress, IIdentity _identity) external;


    function transferOwnershipOnIdentityRegistryStorage(address _newOwner) external;


    function bindIdentityRegistry(address _identityRegistry) external;


    function unbindIdentityRegistry(address _identityRegistry) external;

}








interface IIdentityRegistry {

    event ClaimTopicsRegistrySet(address indexed claimTopicsRegistry);

    event IdentityStorageSet(address indexed identityStorage);

    event TrustedIssuersRegistrySet(address indexed trustedIssuersRegistry);

    event IdentityRegistered(address indexed investorAddress, IIdentity indexed identity);

    event IdentityRemoved(address indexed investorAddress, IIdentity indexed identity);

    event IdentityUpdated(IIdentity indexed oldIdentity, IIdentity indexed newIdentity);

    event CountryUpdated(address indexed investorAddress, uint16 indexed country);

    function registerIdentity(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) external;


    function deleteIdentity(address _userAddress) external;


    function setIdentityRegistryStorage(address _identityRegistryStorage) external;


    function setClaimTopicsRegistry(address _claimTopicsRegistry) external;


    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external;


    function updateCountry(address _userAddress, uint16 _country) external;


    function updateIdentity(address _userAddress, IIdentity _identity) external;


    function batchRegisterIdentity(
        address[] calldata _userAddresses,
        IIdentity[] calldata _identities,
        uint16[] calldata _countries
    ) external;


    function contains(address _userAddress) external view returns (bool);


    function isVerified(address _userAddress) external view returns (bool);


    function identity(address _userAddress) external view returns (IIdentity);


    function investorCountry(address _userAddress) external view returns (uint16);


    function identityStorage() external view returns (IIdentityRegistryStorage);


    function issuersRegistry() external view returns (ITrustedIssuersRegistry);


    function topicsRegistry() external view returns (IClaimTopicsRegistry);


    function transferOwnershipOnIdentityRegistryContract(address _newOwner) external;


    function addAgentOnIdentityRegistryContract(address _agent) external;


    function removeAgentOnIdentityRegistryContract(address _agent) external;

}



interface ICompliance {

    event TokenAgentAdded(address _agentAddress);

    event TokenAgentRemoved(address _agentAddress);

    event TokenBound(address _token);

    event TokenUnbound(address _token);

    function isTokenAgent(address _agentAddress) external view returns (bool);


    function isTokenBound(address _token) external view returns (bool);


    function addTokenAgent(address _agentAddress) external;


    function removeTokenAgent(address _agentAddress) external;


    function bindToken(address _token) external;


    function unbindToken(address _token) external;


    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool);


    function transferred(
        address _from,
        address _to,
        uint256 _amount
    ) external;


    function created(address _to, uint256 _amount) external;


    function destroyed(address _from, uint256 _amount) external;


    function transferOwnershipOnComplianceContract(address newOwner) external;

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






interface IToken is IERC20 {

    event UpdatedTokenInformation(string _newName, string _newSymbol, uint8 _newDecimals, string _newVersion, address _newOnchainID);

    event IdentityRegistryAdded(address indexed _identityRegistry);

    event ComplianceAdded(address indexed _compliance);

    event RecoverySuccess(address _lostWallet, address _newWallet, address _investorOnchainID);

    event AddressFrozen(address indexed _userAddress, bool indexed _isFrozen, address indexed _owner);

    event TokensFrozen(address indexed _userAddress, uint256 _amount);

    event TokensUnfrozen(address indexed _userAddress, uint256 _amount);

    event Paused(address _userAddress);

    event Unpaused(address _userAddress);

    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function onchainID() external view returns (address);


    function symbol() external view returns (string memory);


    function version() external view returns (string memory);


    function identityRegistry() external view returns (IIdentityRegistry);


    function compliance() external view returns (ICompliance);


    function paused() external view returns (bool);


    function isFrozen(address _userAddress) external view returns (bool);


    function getFrozenTokens(address _userAddress) external view returns (uint256);


    function setName(string calldata _name) external;


    function setSymbol(string calldata _symbol) external;


    function setOnchainID(address _onchainID) external;


    function pause() external;


    function unpause() external;


    function setAddressFrozen(address _userAddress, bool _freeze) external;


    function freezePartialTokens(address _userAddress, uint256 _amount) external;


    function unfreezePartialTokens(address _userAddress, uint256 _amount) external;


    function setIdentityRegistry(address _identityRegistry) external;


    function setCompliance(address _compliance) external;


    function forcedTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);


    function mint(address _to, uint256 _amount) external;


    function burn(address _userAddress, uint256 _amount) external;


    function recoveryAddress(
        address _lostWallet,
        address _newWallet,
        address _investorOnchainID
    ) external returns (bool);


    function batchTransfer(address[] calldata _toList, uint256[] calldata _amounts) external;


    function batchForcedTransfer(
        address[] calldata _fromList,
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external;


    function batchMint(address[] calldata _toList, uint256[] calldata _amounts) external;


    function batchBurn(address[] calldata _userAddresses, uint256[] calldata _amounts) external;


    function batchSetAddressFrozen(address[] calldata _userAddresses, bool[] calldata _freeze) external;


    function batchFreezePartialTokens(address[] calldata _userAddresses, uint256[] calldata _amounts) external;


    function batchUnfreezePartialTokens(address[] calldata _userAddresses, uint256[] calldata _amounts) external;


    function transferOwnershipOnTokenContract(address _newOwner) external;


    function addAgentOnTokenContract(address _agent) external;


    function removeAgentOnTokenContract(address _agent) external;

}




contract TokenStorage {

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply;

    string internal tokenName;
    string internal tokenSymbol;
    uint8 internal tokenDecimals;
    address internal tokenOnchainID;
    string internal constant TOKEN_VERSION = '3.4.0';

    mapping(address => bool) internal frozen;
    mapping(address => uint256) internal frozenTokens;

    bool internal tokenPaused = false;

    IIdentityRegistry internal tokenIdentityRegistry;

    ICompliance internal tokenCompliance;
}



library AddressUpgradeable {

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
}




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
}




abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}




abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}


library Roles {

    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), 'Roles: account already has role');
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), 'Roles: account does not have role');
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), 'Roles: account is the zero address');
        return role.bearer[account];
    }
}




contract AgentRoleUpgradeable is OwnableUpgradeable {

    using Roles for Roles.Role;

    event AgentAdded(address indexed _agent);
    event AgentRemoved(address indexed _agent);

    Roles.Role private _agents;

    modifier onlyAgent() {

        require(isAgent(msg.sender), 'AgentRole: caller does not have the Agent role');
        _;
    }

    function isAgent(address _agent) public view returns (bool) {

        return _agents.has(_agent);
    }

    function addAgent(address _agent) public onlyOwner {

        _agents.add(_agent);
        emit AgentAdded(_agent);
    }

    function removeAgent(address _agent) public onlyOwner {

        _agents.remove(_agent);
        emit AgentRemoved(_agent);
    }
}











contract Token is IToken, AgentRoleUpgradeable, TokenStorage {


    function init(
        address _identityRegistry,
        address _compliance,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _onchainID
    ) public initializer {

        tokenName = _name;
        tokenSymbol = _symbol;
        tokenDecimals = _decimals;
        tokenOnchainID = _onchainID;
        tokenIdentityRegistry = IIdentityRegistry(_identityRegistry);
        emit IdentityRegistryAdded(_identityRegistry);
        tokenCompliance = ICompliance(_compliance);
        emit ComplianceAdded(_compliance);
        emit UpdatedTokenInformation(tokenName, tokenSymbol, tokenDecimals, TOKEN_VERSION, tokenOnchainID);
        __Ownable_init();
    }

    modifier whenNotPaused() {

        require(!tokenPaused, 'Pausable: paused');
        _;
    }

    modifier whenPaused() {

        require(tokenPaused, 'Pausable: not paused');
        _;
    }

    function totalSupply() external view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address _userAddress) public view override returns (uint256) {

        return _balances[_userAddress];
    }

    function allowance(address _owner, address _spender) external view virtual override returns (uint256) {

        return _allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) external virtual override returns (bool) {

        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) external virtual returns (bool) {

        _approve(msg.sender, _spender, _allowances[msg.sender][_spender] + (_addedValue));
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) external virtual returns (bool) {

        _approve(msg.sender, _spender, _allowances[msg.sender][_spender] - _subtractedValue);
        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual {

        require(_from != address(0), 'ERC20: transfer from the zero address');
        require(_to != address(0), 'ERC20: transfer to the zero address');

        _beforeTokenTransfer(_from, _to, _amount);

        _balances[_from] = _balances[_from] - _amount;
        _balances[_to] = _balances[_to] + _amount;
        emit Transfer(_from, _to, _amount);
    }

    function _mint(address _userAddress, uint256 _amount) internal virtual {

        require(_userAddress != address(0), 'ERC20: mint to the zero address');

        _beforeTokenTransfer(address(0), _userAddress, _amount);

        _totalSupply = _totalSupply + _amount;
        _balances[_userAddress] = _balances[_userAddress] + _amount;
        emit Transfer(address(0), _userAddress, _amount);
    }

    function _burn(address _userAddress, uint256 _amount) internal virtual {

        require(_userAddress != address(0), 'ERC20: burn from the zero address');

        _beforeTokenTransfer(_userAddress, address(0), _amount);

        _balances[_userAddress] = _balances[_userAddress] - _amount;
        _totalSupply = _totalSupply - _amount;
        emit Transfer(_userAddress, address(0), _amount);
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal virtual {

        require(_owner != address(0), 'ERC20: approve from the zero address');
        require(_spender != address(0), 'ERC20: approve to the zero address');

        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual {}


    function decimals() external view override returns (uint8) {

        return tokenDecimals;
    }

    function name() external view override returns (string memory) {

        return tokenName;
    }

    function onchainID() external view override returns (address) {

        return tokenOnchainID;
    }

    function symbol() external view override returns (string memory) {

        return tokenSymbol;
    }

    function version() external view override returns (string memory) {

        return TOKEN_VERSION;
    }

    function setName(string calldata _name) external override onlyOwner {

        tokenName = _name;
        emit UpdatedTokenInformation(tokenName, tokenSymbol, tokenDecimals, TOKEN_VERSION, tokenOnchainID);
    }

    function setSymbol(string calldata _symbol) external override onlyOwner {

        tokenSymbol = _symbol;
        emit UpdatedTokenInformation(tokenName, tokenSymbol, tokenDecimals, TOKEN_VERSION, tokenOnchainID);
    }

    function setOnchainID(address _onchainID) external override onlyOwner {

        tokenOnchainID = _onchainID;
        emit UpdatedTokenInformation(tokenName, tokenSymbol, tokenDecimals, TOKEN_VERSION, tokenOnchainID);
    }

    function paused() external view override returns (bool) {

        return tokenPaused;
    }

    function isFrozen(address _userAddress) external view override returns (bool) {

        return frozen[_userAddress];
    }

    function getFrozenTokens(address _userAddress) external view override returns (uint256) {

        return frozenTokens[_userAddress];
    }

    function transfer(address _to, uint256 _amount) public override whenNotPaused returns (bool) {

        require(!frozen[_to] && !frozen[msg.sender], 'wallet is frozen');
        require(_amount <= balanceOf(msg.sender) - (frozenTokens[msg.sender]), 'Insufficient Balance');
        if (tokenIdentityRegistry.isVerified(_to) && tokenCompliance.canTransfer(msg.sender, _to, _amount)) {
            tokenCompliance.transferred(msg.sender, _to, _amount);
            _transfer(msg.sender, _to, _amount);
            return true;
        }
        revert('Transfer not possible');
    }

    function pause() external override onlyAgent whenNotPaused {

        tokenPaused = true;
        emit Paused(msg.sender);
    }

    function unpause() external override onlyAgent whenPaused {

        tokenPaused = false;
        emit Unpaused(msg.sender);
    }

    function identityRegistry() external view override returns (IIdentityRegistry) {

        return tokenIdentityRegistry;
    }

    function compliance() external view override returns (ICompliance) {

        return tokenCompliance;
    }

    function batchTransfer(address[] calldata _toList, uint256[] calldata _amounts) external override {

        for (uint256 i = 0; i < _toList.length; i++) {
            transfer(_toList[i], _amounts[i]);
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external override whenNotPaused returns (bool) {

        require(!frozen[_to] && !frozen[_from], 'wallet is frozen');
        require(_amount <= balanceOf(_from) - (frozenTokens[_from]), 'Insufficient Balance');
        if (tokenIdentityRegistry.isVerified(_to) && tokenCompliance.canTransfer(_from, _to, _amount)) {
            tokenCompliance.transferred(_from, _to, _amount);
            _transfer(_from, _to, _amount);
            _approve(_from, msg.sender, _allowances[_from][msg.sender] - (_amount));
            return true;
        }

        revert('Transfer not possible');
    }

    function forcedTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public override onlyAgent returns (bool) {

        uint256 freeBalance = balanceOf(_from) - (frozenTokens[_from]);
        if (_amount > freeBalance) {
            uint256 tokensToUnfreeze = _amount - (freeBalance);
            frozenTokens[_from] = frozenTokens[_from] - (tokensToUnfreeze);
            emit TokensUnfrozen(_from, tokensToUnfreeze);
        }
        if (tokenIdentityRegistry.isVerified(_to)) {
            tokenCompliance.transferred(_from, _to, _amount);
            _transfer(_from, _to, _amount);
            return true;
        }
        revert('Transfer not possible');
    }

    function batchForcedTransfer(
        address[] calldata _fromList,
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external override {

        for (uint256 i = 0; i < _fromList.length; i++) {
            forcedTransfer(_fromList[i], _toList[i], _amounts[i]);
        }
    }

    function mint(address _to, uint256 _amount) public override onlyAgent {

        require(tokenIdentityRegistry.isVerified(_to), 'Identity is not verified.');
        require(tokenCompliance.canTransfer(msg.sender, _to, _amount), 'Compliance not followed');
        _mint(_to, _amount);
        tokenCompliance.created(_to, _amount);
    }

    function batchMint(address[] calldata _toList, uint256[] calldata _amounts) external override {

        for (uint256 i = 0; i < _toList.length; i++) {
            mint(_toList[i], _amounts[i]);
        }
    }

    function burn(address _userAddress, uint256 _amount) public override onlyAgent {

        uint256 freeBalance = balanceOf(_userAddress) - frozenTokens[_userAddress];
        if (_amount > freeBalance) {
            uint256 tokensToUnfreeze = _amount - (freeBalance);
            frozenTokens[_userAddress] = frozenTokens[_userAddress] - (tokensToUnfreeze);
            emit TokensUnfrozen(_userAddress, tokensToUnfreeze);
        }
        _burn(_userAddress, _amount);
        tokenCompliance.destroyed(_userAddress, _amount);
    }

    function batchBurn(address[] calldata _userAddresses, uint256[] calldata _amounts) external override {

        for (uint256 i = 0; i < _userAddresses.length; i++) {
            burn(_userAddresses[i], _amounts[i]);
        }
    }

    function setAddressFrozen(address _userAddress, bool _freeze) public override onlyAgent {

        frozen[_userAddress] = _freeze;

        emit AddressFrozen(_userAddress, _freeze, msg.sender);
    }

    function batchSetAddressFrozen(address[] calldata _userAddresses, bool[] calldata _freeze) external override {

        for (uint256 i = 0; i < _userAddresses.length; i++) {
            setAddressFrozen(_userAddresses[i], _freeze[i]);
        }
    }

    function freezePartialTokens(address _userAddress, uint256 _amount) public override onlyAgent {

        uint256 balance = balanceOf(_userAddress);
        require(balance >= frozenTokens[_userAddress] + _amount, 'Amount exceeds available balance');
        frozenTokens[_userAddress] = frozenTokens[_userAddress] + (_amount);
        emit TokensFrozen(_userAddress, _amount);
    }

    function batchFreezePartialTokens(address[] calldata _userAddresses, uint256[] calldata _amounts) external override {

        for (uint256 i = 0; i < _userAddresses.length; i++) {
            freezePartialTokens(_userAddresses[i], _amounts[i]);
        }
    }

    function unfreezePartialTokens(address _userAddress, uint256 _amount) public override onlyAgent {

        require(frozenTokens[_userAddress] >= _amount, 'Amount should be less than or equal to frozen tokens');
        frozenTokens[_userAddress] = frozenTokens[_userAddress] - (_amount);
        emit TokensUnfrozen(_userAddress, _amount);
    }

    function batchUnfreezePartialTokens(address[] calldata _userAddresses, uint256[] calldata _amounts) external override {

        for (uint256 i = 0; i < _userAddresses.length; i++) {
            unfreezePartialTokens(_userAddresses[i], _amounts[i]);
        }
    }

    function setIdentityRegistry(address _identityRegistry) external override onlyOwner {

        tokenIdentityRegistry = IIdentityRegistry(_identityRegistry);
        emit IdentityRegistryAdded(_identityRegistry);
    }

    function setCompliance(address _compliance) external override onlyOwner {

        tokenCompliance = ICompliance(_compliance);
        emit ComplianceAdded(_compliance);
    }

    function recoveryAddress(
        address _lostWallet,
        address _newWallet,
        address _investorOnchainID
    ) external override onlyAgent returns (bool) {

        require(balanceOf(_lostWallet) != 0, 'no tokens to recover');
        IIdentity _onchainID = IIdentity(_investorOnchainID);
        bytes32 _key = keccak256(abi.encode(_newWallet));
        if (_onchainID.keyHasPurpose(_key, 1)) {
            uint256 investorTokens = balanceOf(_lostWallet);
            uint256 _frozenTokens = frozenTokens[_lostWallet];
            tokenIdentityRegistry.registerIdentity(_newWallet, _onchainID, tokenIdentityRegistry.investorCountry(_lostWallet));
            tokenIdentityRegistry.deleteIdentity(_lostWallet);
            forcedTransfer(_lostWallet, _newWallet, investorTokens);
            if (_frozenTokens > 0) {
                freezePartialTokens(_newWallet, _frozenTokens);
            }
            if (frozen[_lostWallet] == true) {
                setAddressFrozen(_newWallet, true);
            }
            emit RecoverySuccess(_lostWallet, _newWallet, _investorOnchainID);
            return true;
        }
        revert('Recovery not possible');
    }

    function transferOwnershipOnTokenContract(address _newOwner) external override onlyOwner {

        transferOwnership(_newOwner);
    }

    function addAgentOnTokenContract(address _agent) external override {

        addAgent(_agent);
    }

    function removeAgentOnTokenContract(address _agent) external override {

        removeAgent(_agent);
    }
}