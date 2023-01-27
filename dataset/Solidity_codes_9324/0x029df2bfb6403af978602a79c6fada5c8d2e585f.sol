pragma solidity ^0.8.0;



abstract contract DaoConstants {
    bytes32 internal constant VOTING = keccak256("voting");
    bytes32 internal constant ONBOARDING = keccak256("onboarding");
    bytes32 internal constant NONVOTING_ONBOARDING =
        keccak256("nonvoting-onboarding");
    bytes32 internal constant TRIBUTE = keccak256("tribute");
    bytes32 internal constant FINANCING = keccak256("financing");
    bytes32 internal constant MANAGING = keccak256("managing");
    bytes32 internal constant RAGEQUIT = keccak256("ragequit");
    bytes32 internal constant GUILDKICK = keccak256("guildkick");
    bytes32 internal constant EXECUTION = keccak256("execution");
    bytes32 internal constant CONFIGURATION = keccak256("configuration");
    bytes32 internal constant DISTRIBUTE = keccak256("distribute");
    bytes32 internal constant TRIBUTE_NFT = keccak256("tribute-nft");

    bytes32 internal constant BANK = keccak256("bank");
    bytes32 internal constant NFT = keccak256("nft");
    bytes32 internal constant ERC20_EXT = keccak256("erc20-ext");

    address internal constant GUILD = address(0xdead);
    address internal constant TOTAL = address(0xbabe);
    address internal constant ESCROW = address(0x4bec);
    address internal constant UNITS = address(0xFF1CE);
    address internal constant LOOT = address(0xB105F00D);
    address internal constant ETH_TOKEN = address(0x0);
    address internal constant MEMBER_COUNT = address(0xDECAFBAD);

    uint8 internal constant MAX_TOKENS_GUILD_BANK = 200;

    function getFlag(uint256 flags, uint256 flag) public pure returns (bool) {
        return (flags >> uint8(flag)) % 2 == 1;
    }

    function setFlag(
        uint256 flags,
        uint256 flag,
        bool value
    ) public pure returns (uint256) {
        if (getFlag(flags, flag) != value) {
            if (value) {
                return flags + 2**flag;
            } else {
                return flags - 2**flag;
            }
        } else {
            return flags;
        }
    }

    function isNotReservedAddress(address addr) public pure returns (bool) {
        return addr != GUILD && addr != TOTAL && addr != ESCROW;
    }

    function isNotZeroAddress(address addr) public pure returns (bool) {
        return addr != address(0x0);
    }
}pragma solidity ^0.8.0;



interface IExtension {

    function initialize(DaoRegistry dao, address creator) external;

}pragma solidity ^0.8.0;



abstract contract AdapterGuard {
    modifier onlyAdapter(DaoRegistry dao) {
        require(
            (dao.state() == DaoRegistry.DaoState.CREATION &&
                creationModeCheck(dao)) || dao.isAdapter(msg.sender),
            "onlyAdapter"
        );
        _;
    }

    modifier reentrancyGuard(DaoRegistry dao) {
        require(dao.lockedAt() != block.number, "reentrancy guard");
        dao.lockSession();
        _;
        dao.unlockSession();
    }

    modifier hasAccess(DaoRegistry dao, DaoRegistry.AclFlag flag) {
        require(
            (dao.state() == DaoRegistry.DaoState.CREATION &&
                creationModeCheck(dao)) ||
                dao.hasAdapterAccess(msg.sender, flag),
            "accessDenied"
        );
        _;
    }

    function creationModeCheck(DaoRegistry dao) internal view returns (bool) {
        return
            dao.getNbMembers() == 0 ||
            dao.isMember(msg.sender) ||
            dao.isAdapter(msg.sender);
    }
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
}pragma solidity ^0.8.0;




contract BankExtension is DaoConstants, AdapterGuard, IExtension {

    using Address for address payable;
    using SafeERC20 for IERC20;

    uint8 public maxExternalTokens; // the maximum number of external tokens that can be stored in the bank

    bool public initialized = false; // internally tracks deployment under eip-1167 proxy pattern
    DaoRegistry public dao;

    enum AclFlag {
        ADD_TO_BALANCE,
        SUB_FROM_BALANCE,
        INTERNAL_TRANSFER,
        WITHDRAW,
        EXECUTE,
        REGISTER_NEW_TOKEN,
        REGISTER_NEW_INTERNAL_TOKEN,
        UPDATE_TOKEN
    }

    modifier noProposal {

        require(dao.lockedAt() < block.number, "proposal lock");
        _;
    }

    event NewBalance(address member, address tokenAddr, uint160 amount);

    event Withdraw(address account, address tokenAddr, uint160 amount);


    struct Checkpoint {
        uint96 fromBlock;
        uint160 amount;
    }

    address[] public tokens;
    address[] public internalTokens;
    mapping(address => bool) public availableTokens;
    mapping(address => bool) public availableInternalTokens;
    mapping(address => mapping(address => mapping(uint32 => Checkpoint)))
        public checkpoints;
    mapping(address => mapping(address => uint32)) public numCheckpoints;


    modifier hasExtensionAccess(AclFlag flag) {

        require(
            address(this) == msg.sender ||
                address(dao) == msg.sender ||
                dao.state() == DaoRegistry.DaoState.CREATION ||
                dao.hasAdapterAccessToExtension(
                    msg.sender,
                    address(this),
                    uint8(flag)
                ),
            "bank::accessDenied"
        );
        _;
    }

    function initialize(DaoRegistry _dao, address creator) external override {

        require(!initialized, "bank already initialized");
        require(_dao.isMember(creator), "bank::not member");
        dao = _dao;
        initialized = true;

        availableInternalTokens[UNITS] = true;
        internalTokens.push(UNITS);

        availableInternalTokens[MEMBER_COUNT] = true;
        internalTokens.push(MEMBER_COUNT);
        uint256 nbMembers = _dao.getNbMembers();
        for (uint256 i = 0; i < nbMembers; i++) {
            addToBalance(_dao.getMemberAddress(i), MEMBER_COUNT, 1);
        }

        _createNewAmountCheckpoint(creator, UNITS, 1);
        _createNewAmountCheckpoint(TOTAL, UNITS, 1);
    }

    function withdraw(
        address payable member,
        address tokenAddr,
        uint256 amount
    ) external hasExtensionAccess(AclFlag.WITHDRAW) {

        require(
            balanceOf(member, tokenAddr) >= amount,
            "bank::withdraw::not enough funds"
        );
        subtractFromBalance(member, tokenAddr, amount);
        if (tokenAddr == ETH_TOKEN) {
            member.sendValue(amount);
        } else {
            IERC20 erc20 = IERC20(tokenAddr);
            erc20.safeTransfer(member, amount);
        }

        emit Withdraw(member, tokenAddr, uint160(amount));
    }

    function isInternalToken(address token) external view returns (bool) {

        return availableInternalTokens[token];
    }

    function isTokenAllowed(address token) public view returns (bool) {

        return availableTokens[token];
    }

    function setMaxExternalTokens(uint8 maxTokens) external {

        require(!initialized, "bank already initialized");
        require(
            maxTokens > 0 && maxTokens <= MAX_TOKENS_GUILD_BANK,
            "max number of external tokens should be (0,200)"
        );
        maxExternalTokens = maxTokens;
    }


    function registerPotentialNewToken(address token)
        external
        hasExtensionAccess(AclFlag.REGISTER_NEW_TOKEN)
    {

        require(isNotReservedAddress(token), "reservedToken");
        require(!availableInternalTokens[token], "internalToken");
        require(
            tokens.length <= maxExternalTokens,
            "exceeds the maximum tokens allowed"
        );

        if (!availableTokens[token]) {
            availableTokens[token] = true;
            tokens.push(token);
        }
    }

    function registerPotentialNewInternalToken(address token)
        external
        hasExtensionAccess(AclFlag.REGISTER_NEW_INTERNAL_TOKEN)
    {

        require(isNotReservedAddress(token), "reservedToken");
        require(!availableTokens[token], "availableToken");

        if (!availableInternalTokens[token]) {
            availableInternalTokens[token] = true;
            internalTokens.push(token);
        }
    }

    function updateToken(address tokenAddr)
        external
        hasExtensionAccess(AclFlag.UPDATE_TOKEN)
    {

        require(isTokenAllowed(tokenAddr), "token not allowed");
        uint256 totalBalance = balanceOf(TOTAL, tokenAddr);

        uint256 realBalance;

        if (tokenAddr == ETH_TOKEN) {
            realBalance = address(this).balance;
        } else {
            IERC20 erc20 = IERC20(tokenAddr);
            realBalance = erc20.balanceOf(address(this));
        }

        if (totalBalance < realBalance) {
            addToBalance(GUILD, tokenAddr, realBalance - totalBalance);
        } else if (totalBalance > realBalance) {
            uint256 tokensToRemove = totalBalance - realBalance;
            uint256 guildBalance = balanceOf(GUILD, tokenAddr);
            if (guildBalance > tokensToRemove) {
                subtractFromBalance(GUILD, tokenAddr, tokensToRemove);
            } else {
                subtractFromBalance(GUILD, tokenAddr, guildBalance);
            }
        }
    }



    function getToken(uint256 index) external view returns (address) {

        return tokens[index];
    }

    function nbTokens() external view returns (uint256) {

        return tokens.length;
    }

    function getTokens() external view returns (address[] memory) {

        return tokens;
    }

    function getInternalToken(uint256 index) external view returns (address) {

        return internalTokens[index];
    }

    function nbInternalTokens() external view returns (uint256) {

        return internalTokens.length;
    }

    function addToBalance(
        address member,
        address token,
        uint256 amount
    ) public payable hasExtensionAccess(AclFlag.ADD_TO_BALANCE) {

        require(
            availableTokens[token] || availableInternalTokens[token],
            "unknown token address"
        );
        uint256 newAmount = balanceOf(member, token) + amount;
        uint256 newTotalAmount = balanceOf(TOTAL, token) + amount;

        _createNewAmountCheckpoint(member, token, newAmount);
        _createNewAmountCheckpoint(TOTAL, token, newTotalAmount);
    }

    function subtractFromBalance(
        address member,
        address token,
        uint256 amount
    ) public hasExtensionAccess(AclFlag.SUB_FROM_BALANCE) {

        uint256 newAmount = balanceOf(member, token) - amount;
        uint256 newTotalAmount = balanceOf(TOTAL, token) - amount;

        _createNewAmountCheckpoint(member, token, newAmount);
        _createNewAmountCheckpoint(TOTAL, token, newTotalAmount);
    }

    function internalTransfer(
        address from,
        address to,
        address token,
        uint256 amount
    ) public hasExtensionAccess(AclFlag.INTERNAL_TRANSFER) {

        uint256 newAmount = balanceOf(from, token) - amount;
        uint256 newAmount2 = balanceOf(to, token) + amount;

        _createNewAmountCheckpoint(from, token, newAmount);
        _createNewAmountCheckpoint(to, token, newAmount2);
    }

    function balanceOf(address member, address tokenAddr)
        public
        view
        returns (uint160)
    {

        uint32 nCheckpoints = numCheckpoints[tokenAddr][member];
        return
            nCheckpoints > 0
                ? checkpoints[tokenAddr][member][nCheckpoints - 1].amount
                : 0;
    }

    function getPriorAmount(
        address account,
        address tokenAddr,
        uint256 blockNumber
    ) external view returns (uint256) {

        require(
            blockNumber < block.number,
            "Uni::getPriorAmount: not yet determined"
        );

        uint32 nCheckpoints = numCheckpoints[tokenAddr][account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (
            checkpoints[tokenAddr][account][nCheckpoints - 1].fromBlock <=
            blockNumber
        ) {
            return checkpoints[tokenAddr][account][nCheckpoints - 1].amount;
        }

        if (checkpoints[tokenAddr][account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[tokenAddr][account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.amount;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[tokenAddr][account][lower].amount;
    }

    function _createNewAmountCheckpoint(
        address member,
        address token,
        uint256 amount
    ) internal {

        bool isValidToken = false;
        if (availableInternalTokens[token]) {
            require(
                amount < type(uint88).max,
                "token amount exceeds the maximum limit for internal tokens"
            );
            isValidToken = true;
        } else if (availableTokens[token]) {
            require(
                amount < type(uint160).max,
                "token amount exceeds the maximum limit for external tokens"
            );
            isValidToken = true;
        }
        uint160 newAmount = uint160(amount);

        require(isValidToken, "token not registered");

        uint32 nCheckpoints = numCheckpoints[token][member];
        if (
            nCheckpoints > 0 &&
            checkpoints[token][member][nCheckpoints - 1].fromBlock ==
            block.number
        ) {
            checkpoints[token][member][nCheckpoints - 1].amount = newAmount;
        } else {
            checkpoints[token][member][nCheckpoints] = Checkpoint(
                uint96(block.number),
                newAmount
            );
            numCheckpoints[token][member] = nCheckpoints + 1;
        }
        emit NewBalance(member, token, newAmount);
    }
}pragma solidity ^0.8.0;



abstract contract MemberGuard is DaoConstants {
    modifier onlyMember(DaoRegistry dao) {
        _onlyMember(dao, msg.sender);
        _;
    }

    modifier onlyMember2(DaoRegistry dao, address _addr) {
        _onlyMember(dao, _addr);
        _;
    }

    function _onlyMember(DaoRegistry dao, address _addr) internal view {
        require(isActiveMember(dao, _addr), "onlyMember");
    }

    function isActiveMember(DaoRegistry dao, address _addr)
        public
        view
        returns (bool)
    {
        address bankAddress = dao.extensions(BANK);
        if (bankAddress != address(0x0)) {
            address memberAddr = dao.getAddressIfDelegated(_addr);
            return BankExtension(bankAddress).balanceOf(memberAddr, UNITS) > 0;
        }

        return dao.isMember(_addr);
    }
}pragma solidity ^0.8.0;




contract DaoRegistry is MemberGuard, AdapterGuard {

    bool public initialized = false; // internally tracks deployment under eip-1167 proxy pattern

    enum DaoState {CREATION, READY}

    event SubmittedProposal(bytes32 proposalId, uint256 flags);
    event SponsoredProposal(
        bytes32 proposalId,
        uint256 flags,
        address votingAdapter
    );
    event ProcessedProposal(bytes32 proposalId, uint256 flags);
    event AdapterAdded(
        bytes32 adapterId,
        address adapterAddress,
        uint256 flags
    );
    event AdapterRemoved(bytes32 adapterId);

    event ExtensionAdded(bytes32 extensionId, address extensionAddress);
    event ExtensionRemoved(bytes32 extensionId);

    event UpdateDelegateKey(address memberAddress, address newDelegateKey);
    event ConfigurationUpdated(bytes32 key, uint256 value);
    event AddressConfigurationUpdated(bytes32 key, address value);

    enum MemberFlag {EXISTS}

    enum ProposalFlag {EXISTS, SPONSORED, PROCESSED}

    enum AclFlag {
        REPLACE_ADAPTER,
        SUBMIT_PROPOSAL,
        UPDATE_DELEGATE_KEY,
        SET_CONFIGURATION,
        ADD_EXTENSION,
        REMOVE_EXTENSION,
        NEW_MEMBER
    }

    struct Proposal {
        address adapterAddress; // the adapter address that called the functions to change the DAO state
        uint256 flags; // flags to track the state of the proposal: exist, sponsored, processed, canceled, etc.
    }

    struct Member {
        uint256 flags; // flags to track the state of the member: exists, etc
    }

    struct Checkpoint {
        uint96 fromBlock;
        uint160 amount;
    }

    struct DelegateCheckpoint {
        uint96 fromBlock;
        address delegateKey;
    }

    struct AdapterEntry {
        bytes32 id;
        uint256 acl;
    }

    struct ExtensionEntry {
        bytes32 id;
        mapping(address => uint256) acl;
    }

    mapping(address => Member) public members; // the map to track all members of the DAO
    address[] private _members;

    mapping(address => address) public memberAddressesByDelegatedKey;

    mapping(address => mapping(uint32 => DelegateCheckpoint)) checkpoints;
    mapping(address => uint32) numCheckpoints;

    DaoState public state;

    mapping(bytes32 => Proposal) public proposals;
    mapping(bytes32 => address) public votingAdapter;
    mapping(bytes32 => address) public adapters;
    mapping(address => AdapterEntry) public inverseAdapters;
    mapping(bytes32 => address) public extensions;
    mapping(address => ExtensionEntry) public inverseExtensions;
    mapping(bytes32 => uint256) public mainConfiguration;
    mapping(bytes32 => address) public addressConfiguration;

    uint256 public lockedAt;


    function initialize(address creator, address payer) external {

        require(!initialized, "dao already initialized");
        potentialNewMember(msg.sender);
        potentialNewMember(payer);
        potentialNewMember(creator);

        initialized = true;
    }

    receive() external payable {
        revert("you cannot send money back directly");
    }

    function finalizeDao() external {

        state = DaoState.READY;
    }

    function lockSession() external {

        if (isAdapter(msg.sender) || isExtension(msg.sender)) {
            lockedAt = block.number;
        }
    }

    function unlockSession() external {

        if (isAdapter(msg.sender) || isExtension(msg.sender)) {
            lockedAt = 0;
        }
    }

    function setConfiguration(bytes32 key, uint256 value)
        external
        hasAccess(this, AclFlag.SET_CONFIGURATION)
    {

        mainConfiguration[key] = value;

        emit ConfigurationUpdated(key, value);
    }

    function potentialNewMember(address memberAddress)
        public
        hasAccess(this, AclFlag.NEW_MEMBER)
    {

        require(memberAddress != address(0x0), "invalid member address");

        Member storage member = members[memberAddress];
        if (!getFlag(member.flags, uint8(MemberFlag.EXISTS))) {
            require(
                memberAddressesByDelegatedKey[memberAddress] == address(0x0),
                "member address already taken as delegated key"
            );
            member.flags = setFlag(
                member.flags,
                uint8(MemberFlag.EXISTS),
                true
            );
            memberAddressesByDelegatedKey[memberAddress] = memberAddress;
            _members.push(memberAddress);
        }

        address bankAddress = extensions[BANK];
        if (bankAddress != address(0x0)) {
            BankExtension bank = BankExtension(bankAddress);
            if (bank.balanceOf(memberAddress, MEMBER_COUNT) == 0) {
                bank.addToBalance(memberAddress, MEMBER_COUNT, 1);
            }
        }
    }

    function setAddressConfiguration(bytes32 key, address value)
        external
        hasAccess(this, AclFlag.SET_CONFIGURATION)
    {

        addressConfiguration[key] = value;

        emit AddressConfigurationUpdated(key, value);
    }

    function getConfiguration(bytes32 key) external view returns (uint256) {

        return mainConfiguration[key];
    }

    function getAddressConfiguration(bytes32 key)
        external
        view
        returns (address)
    {

        return addressConfiguration[key];
    }

    function addExtension(
        bytes32 extensionId,
        IExtension extension,
        address creator
    ) external hasAccess(this, AclFlag.ADD_EXTENSION) {

        require(extensionId != bytes32(0), "extension id must not be empty");
        require(
            extensions[extensionId] == address(0x0),
            "extension Id already in use"
        );
        extensions[extensionId] = address(extension);
        inverseExtensions[address(extension)].id = extensionId;
        extension.initialize(this, creator);
        emit ExtensionAdded(extensionId, address(extension));
    }

    function setAclToExtensionForAdapter(
        address extensionAddress,
        address adapterAddress,
        uint256 acl
    ) external hasAccess(this, AclFlag.ADD_EXTENSION) {

        require(isAdapter(adapterAddress), "not an adapter");
        require(isExtension(extensionAddress), "not an extension");
        inverseExtensions[extensionAddress].acl[adapterAddress] = acl;
    }

    function replaceAdapter(
        bytes32 adapterId,
        address adapterAddress,
        uint128 acl,
        bytes32[] calldata keys,
        uint256[] calldata values
    ) external hasAccess(this, AclFlag.REPLACE_ADAPTER) {

        require(adapterId != bytes32(0), "adapterId must not be empty");

        address currentAdapterAddr = adapters[adapterId];
        if (currentAdapterAddr != address(0x0)) {
            delete inverseAdapters[currentAdapterAddr];
            delete adapters[adapterId];
            emit AdapterRemoved(adapterId);
        }

        for (uint256 i = 0; i < keys.length; i++) {
            bytes32 key = keys[i];
            uint256 value = values[i];
            mainConfiguration[key] = value;
            emit ConfigurationUpdated(key, value);
        }

        if (adapterAddress != address(0x0)) {
            require(
                inverseAdapters[adapterAddress].id == bytes32(0),
                "adapterAddress already in use"
            );
            adapters[adapterId] = adapterAddress;
            inverseAdapters[adapterAddress].id = adapterId;
            inverseAdapters[adapterAddress].acl = acl;
            emit AdapterAdded(adapterId, adapterAddress, acl);
        }
    }

    function removeExtension(bytes32 extensionId)
        external
        hasAccess(this, AclFlag.REMOVE_EXTENSION)
    {

        require(extensionId != bytes32(0), "extensionId must not be empty");
        require(
            extensions[extensionId] != address(0x0),
            "extensionId not registered"
        );
        delete inverseExtensions[extensions[extensionId]];
        delete extensions[extensionId];
        emit ExtensionRemoved(extensionId);
    }

    function isExtension(address extensionAddr) public view returns (bool) {

        return inverseExtensions[extensionAddr].id != bytes32(0);
    }

    function isAdapter(address adapterAddress) public view returns (bool) {

        return inverseAdapters[adapterAddress].id != bytes32(0);
    }

    function hasAdapterAccess(address adapterAddress, AclFlag flag)
        public
        view
        returns (bool)
    {

        return getFlag(inverseAdapters[adapterAddress].acl, uint8(flag));
    }

    function hasAdapterAccessToExtension(
        address adapterAddress,
        address extensionAddress,
        uint8 flag
    ) public view returns (bool) {

        return
            isAdapter(adapterAddress) &&
            getFlag(
                inverseExtensions[extensionAddress].acl[adapterAddress],
                uint8(flag)
            );
    }

    function getAdapterAddress(bytes32 adapterId)
        external
        view
        returns (address)
    {

        require(adapters[adapterId] != address(0), "adapter not found");
        return adapters[adapterId];
    }

    function getExtensionAddress(bytes32 extensionId)
        external
        view
        returns (address)
    {

        require(extensions[extensionId] != address(0), "extension not found");
        return extensions[extensionId];
    }

    function submitProposal(bytes32 proposalId)
        public
        hasAccess(this, AclFlag.SUBMIT_PROPOSAL)
    {

        require(proposalId != bytes32(0), "invalid proposalId");
        require(
            !getProposalFlag(proposalId, ProposalFlag.EXISTS),
            "proposalId must be unique"
        );
        proposals[proposalId] = Proposal(msg.sender, 1); // 1 means that only the first flag is being set i.e. EXISTS
        emit SubmittedProposal(proposalId, 1);
    }

    function sponsorProposal(
        bytes32 proposalId,
        address sponsoringMember,
        address votingAdapterAddr
    ) external onlyMember2(this, sponsoringMember) {

        Proposal storage proposal =
            _setProposalFlag(proposalId, ProposalFlag.SPONSORED);

        uint256 flags = proposal.flags;

        require(
            proposal.adapterAddress == msg.sender,
            "only the adapter that submitted the proposal can process it"
        );

        require(
            !getFlag(flags, uint8(ProposalFlag.PROCESSED)),
            "proposal already processed"
        );
        votingAdapter[proposalId] = votingAdapterAddr;
        emit SponsoredProposal(proposalId, flags, votingAdapterAddr);
    }

    function processProposal(bytes32 proposalId) external {

        Proposal storage proposal =
            _setProposalFlag(proposalId, ProposalFlag.PROCESSED);

        require(proposal.adapterAddress == msg.sender, "err::adapter mismatch");
        uint256 flags = proposal.flags;

        emit ProcessedProposal(proposalId, flags);
    }

    function _setProposalFlag(bytes32 proposalId, ProposalFlag flag)
        internal
        returns (Proposal storage)
    {

        Proposal storage proposal = proposals[proposalId];

        uint256 flags = proposal.flags;
        require(
            getFlag(flags, uint8(ProposalFlag.EXISTS)),
            "proposal does not exist for this dao"
        );

        require(
            proposal.adapterAddress == msg.sender,
            "only the adapter that submitted the proposal can set its flag"
        );

        require(!getFlag(flags, uint8(flag)), "flag already set");

        flags = setFlag(flags, uint8(flag), true);
        proposals[proposalId].flags = flags;

        return proposals[proposalId];
    }


    function isMember(address addr) public view returns (bool) {

        address memberAddress = memberAddressesByDelegatedKey[addr];
        return getMemberFlag(memberAddress, MemberFlag.EXISTS);
    }

    function getProposalFlag(bytes32 proposalId, ProposalFlag flag)
        public
        view
        returns (bool)
    {

        return getFlag(proposals[proposalId].flags, uint8(flag));
    }

    function getMemberFlag(address memberAddress, MemberFlag flag)
        public
        view
        returns (bool)
    {

        return getFlag(members[memberAddress].flags, uint8(flag));
    }

    function getNbMembers() public view returns (uint256) {

        return _members.length;
    }

    function getMemberAddress(uint256 index) public view returns (address) {

        return _members[index];
    }

    function updateDelegateKey(address memberAddr, address newDelegateKey)
        external
        hasAccess(this, AclFlag.UPDATE_DELEGATE_KEY)
    {

        require(newDelegateKey != address(0x0), "newDelegateKey cannot be 0");

        if (newDelegateKey != memberAddr) {
            require(
                memberAddressesByDelegatedKey[newDelegateKey] == address(0x0),
                "cannot overwrite existing delegated keys"
            );
        } else {
            require(
                memberAddressesByDelegatedKey[memberAddr] == address(0x0),
                "address already taken as delegated key"
            );
        }

        Member storage member = members[memberAddr];
        require(
            getFlag(member.flags, uint8(MemberFlag.EXISTS)),
            "member does not exist"
        );

        memberAddressesByDelegatedKey[
            getCurrentDelegateKey(memberAddr)
        ] = address(0x0);

        memberAddressesByDelegatedKey[newDelegateKey] = memberAddr;

        _createNewDelegateCheckpoint(memberAddr, newDelegateKey);
        emit UpdateDelegateKey(memberAddr, newDelegateKey);
    }


    function getAddressIfDelegated(address checkAddr)
        public
        view
        returns (address)
    {

        address delegatedKey = memberAddressesByDelegatedKey[checkAddr];
        return delegatedKey == address(0x0) ? checkAddr : delegatedKey;
    }

    function getCurrentDelegateKey(address memberAddr)
        public
        view
        returns (address)
    {

        uint32 nCheckpoints = numCheckpoints[memberAddr];
        return
            nCheckpoints > 0
                ? checkpoints[memberAddr][nCheckpoints - 1].delegateKey
                : memberAddr;
    }

    function getPreviousDelegateKey(address memberAddr)
        public
        view
        returns (address)
    {

        uint32 nCheckpoints = numCheckpoints[memberAddr];
        return
            nCheckpoints > 1
                ? checkpoints[memberAddr][nCheckpoints - 2].delegateKey
                : memberAddr;
    }

    function getPriorDelegateKey(address memberAddr, uint256 blockNumber)
        external
        view
        returns (address)
    {

        require(
            blockNumber < block.number,
            "Uni::getPriorDelegateKey: not yet determined"
        );

        uint32 nCheckpoints = numCheckpoints[memberAddr];
        if (nCheckpoints == 0) {
            return memberAddr;
        }

        if (
            checkpoints[memberAddr][nCheckpoints - 1].fromBlock <= blockNumber
        ) {
            return checkpoints[memberAddr][nCheckpoints - 1].delegateKey;
        }

        if (checkpoints[memberAddr][0].fromBlock > blockNumber) {
            return memberAddr;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            DelegateCheckpoint memory cp = checkpoints[memberAddr][center];
            if (cp.fromBlock == blockNumber) {
                return cp.delegateKey;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[memberAddr][lower].delegateKey;
    }

    function _createNewDelegateCheckpoint(
        address member,
        address newDelegateKey
    ) internal {

        uint32 nCheckpoints = numCheckpoints[member];
        if (
            nCheckpoints > 0 &&
            checkpoints[member][nCheckpoints - 1].fromBlock == block.number
        ) {
            checkpoints[member][nCheckpoints - 1].delegateKey = newDelegateKey;
        } else {
            checkpoints[member][nCheckpoints] = DelegateCheckpoint(
                uint96(block.number),
                newDelegateKey
            );
            numCheckpoints[member] = nCheckpoints + 1;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;




abstract contract Signatures {
    string public constant EIP712_DOMAIN =
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,address actionId)";

    bytes32 public constant EIP712_DOMAIN_TYPEHASH =
        keccak256(abi.encodePacked(EIP712_DOMAIN));

    function hashMessage(
        DaoRegistry dao,
        uint256 chainId,
        address actionId,
        bytes32 message
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domainSeparator(dao, chainId, actionId),
                    message
                )
            );
    }

    function domainSeparator(
        DaoRegistry dao,
        uint256 chainId,
        address actionId
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN_TYPEHASH,
                    keccak256("Snapshot Message"), // string name
                    keccak256("4"), // string version
                    chainId, // uint256 chainId
                    address(dao), // address verifyingContract,
                    actionId
                )
            );
    }

    function recover(bytes32 hash, bytes memory sig)
        public
        pure
        returns (address)
    {
        return ECDSA.recover(hash, sig);
    }
}pragma solidity ^0.8.0;



abstract contract PotentialNewMember {
    address internal constant _MEMBER_COUNT = address(0xDECAFBAD);

    function potentialNewMember(
        address memberAddress,
        DaoRegistry dao,
        BankExtension bank
    ) internal {
        dao.potentialNewMember(memberAddress);
        require(memberAddress != address(0x0), "invalid member address");
        if (address(bank) != address(0x0)) {
            if (bank.balanceOf(memberAddress, _MEMBER_COUNT) == 0) {
                bank.addToBalance(memberAddress, _MEMBER_COUNT, 1);
            }
        }
    }
}//WETH-03.24.2020.sol
pragma solidity ^0.8.0;

contract WETH {

    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    receive() external payable {
        deposit();
    }

    function deposit() public payable {

        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) public {

        require(balanceOf[msg.sender] >= wad, "not enough WETH to withdraw");
        require(address(this).balance >= wad, "not enough ETH in the contract");
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint256) {

        return address(this).balance;
    }

    function approve(address guy, uint256 wad) public returns (bool) {

        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {

        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public returns (bool) {

        require(balanceOf[src] >= wad, "insufficient fund");

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint256).max
        ) {
            require(
                allowance[src][msg.sender] >= wad,
                "not allowed to transfer from"
            );
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}pragma solidity ^0.8.0;





contract KycOnboardingContract is
    DaoConstants,
    AdapterGuard,
    Signatures,
    PotentialNewMember
{

    using Address for address payable;
    using SafeERC20 for IERC20;

    event Onboarded(DaoRegistry dao, address member, uint256 units);

    struct Coupon {
        address kycedMember;
    }

    string public constant COUPON_MESSAGE_TYPE = "Message(address kycedMember)";
    bytes32 public constant COUPON_MESSAGE_TYPEHASH =
        keccak256(abi.encodePacked(COUPON_MESSAGE_TYPE));

    bytes32 constant SignerAddressConfig =
        keccak256("kyc-onboarding.signerAddress");

    bytes32 constant ChunkSize = keccak256("kyc-onboarding.chunkSize");
    bytes32 constant UnitsPerChunk = keccak256("kyc-onboarding.unitsPerChunk");
    bytes32 constant MaximumChunks = keccak256("kyc-onboarding.maximumChunks");
    bytes32 constant MaximumUnits = keccak256("kyc-onboarding.maximumTotalUnits");
    bytes32 constant MaxMembers = keccak256("kyc-onboarding.maxMembers");
    bytes32 constant FundTargetAddress =
        keccak256("kyc-onboarding.fundTargetAddress");

    uint256 private _chainId;
    WETH private _weth;
    IERC20 private _weth20;

    event CouponRedeemed(
        address daoAddress,
        uint256 nonce,
        address authorizedMember,
        uint256 amount
    );

    struct OnboardingDetails {
        uint88 chunkSize;
        uint88 numberOfChunks;
        uint88 unitsPerChunk;
        uint88 unitsRequested;
        uint88 maximumTotalUnits;
        uint160 amount;
    }

    mapping(DaoRegistry => uint256) public totalUnits;

    constructor(uint256 chainId, address payable weth) {
        _chainId = chainId;
        _weth = WETH(weth);
        _weth20 = IERC20(weth);
    }

    receive() external payable {
        revert("fallback revert");
    }

    function configureDao(
        DaoRegistry dao,
        address signerAddress,
        uint256 chunkSize,
        uint256 unitsPerChunk,
        uint256 maximumChunks,
        uint256 maxUnits,
        uint256 maxMembers,
        address fundTargetAddress
    ) external onlyAdapter(dao) {

        require(
            chunkSize > 0 && chunkSize < type(uint88).max,
            "chunkSize::invalid"
        );
        require(
            maxMembers > 0 && maxMembers < type(uint88).max,
            "maxMembers::invalid"
        );
        require(
            maximumChunks > 0 && maximumChunks < type(uint88).max,
            "maximumChunks::invalid"
        );
        require(
            maxUnits > 0 && maxUnits < type(uint88).max,
            "maxUnits::invalid"
        );
        require(
            unitsPerChunk > 0 && unitsPerChunk < type(uint88).max,
            "unitsPerChunk::invalid"
        );
        require(
            maximumChunks * unitsPerChunk < type(uint88).max,
            "potential overflow"
        );

        require(signerAddress != address(0x0), "signer address is nil!");

        dao.setAddressConfiguration(SignerAddressConfig, signerAddress);
        dao.setAddressConfiguration(FundTargetAddress, fundTargetAddress);
        dao.setConfiguration(ChunkSize, chunkSize);
        dao.setConfiguration(UnitsPerChunk, unitsPerChunk);
        dao.setConfiguration(MaximumChunks, maximumChunks);
        dao.setConfiguration(MaximumUnits, maxUnits);
        dao.setConfiguration(MaxMembers, maxMembers);

        BankExtension bank = BankExtension(dao.getExtensionAddress(BANK));
        bank.registerPotentialNewInternalToken(UNITS);
    }

    function hashCouponMessage(DaoRegistry dao, Coupon memory coupon)
        public
        view
        returns (bytes32)
    {

        bytes32 message =
            keccak256(abi.encode(COUPON_MESSAGE_TYPEHASH, coupon.kycedMember));

        return hashMessage(dao, _chainId, address(this), message);
    }

    function _checkKycCoupon(
        DaoRegistry dao,
        address kycedMember,
        bytes memory signature
    ) internal view {

        require(
            ECDSA.recover(
                hashCouponMessage(dao, Coupon(kycedMember)),
                signature
            ) == dao.getAddressConfiguration(SignerAddressConfig),
            "invalid sig"
        );
    }

    function onboard(
        DaoRegistry dao,
        address kycedMember,
        bytes memory signature
    ) external payable reentrancyGuard(dao) {

        require(!dao.isActiveMember(dao, kycedMember), "already member");
        require(
            dao.getNbMembers() < dao.getConfiguration(MaxMembers),
            "the DAO is full"
        );
        _checkKycCoupon(dao, kycedMember, signature);
        OnboardingDetails memory details = _checkData(dao);

        BankExtension bank = BankExtension(dao.getExtensionAddress(BANK));
        potentialNewMember(kycedMember, dao, bank);
        totalUnits[dao] += details.unitsRequested;
        address payable multisigAddress =
            payable(dao.getAddressConfiguration(FundTargetAddress));
        if (multisigAddress == address(0x0)) {
            bank.addToBalance{value: details.amount}(
                GUILD,
                ETH_TOKEN,
                details.amount
            );
        } else {
            _weth.deposit{value: details.amount}();
            _weth20.safeTransferFrom(
                address(this),
                multisigAddress,
                details.amount
            );
        }

        bank.addToBalance(kycedMember, UNITS, details.unitsRequested);

        if (msg.value > details.amount) {
            payable(msg.sender).sendValue(msg.value - details.amount);
        }

        emit Onboarded(dao, kycedMember, details.unitsRequested);
    }

    function _checkData(DaoRegistry dao)
        internal
        view
        returns (OnboardingDetails memory details)
    {

        details.chunkSize = uint88(dao.getConfiguration(ChunkSize));
        require(details.chunkSize > 0, "config chunkSize missing");
        details.numberOfChunks = uint88(msg.value / details.chunkSize);
        require(details.numberOfChunks > 0, "insufficient funds");
        require(
            details.numberOfChunks <= dao.getConfiguration(MaximumChunks),
            "too much funds"
        );

        details.unitsPerChunk = uint88(dao.getConfiguration(UnitsPerChunk));

        require(details.unitsPerChunk > 0, "config unitsPerChunk missing");
        details.amount = details.numberOfChunks * details.chunkSize;
        details.unitsRequested = details.numberOfChunks * details.unitsPerChunk;
        details.maximumTotalUnits = uint88(dao.getConfiguration(MaximumUnits));

        require(details.unitsRequested + totalUnits[dao] <= details.maximumTotalUnits, "over max total units");
    }
}