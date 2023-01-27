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
}pragma solidity ^0.8.0;




interface IVoting {

    enum VotingState {
        NOT_STARTED,
        TIE,
        PASS,
        NOT_PASS,
        IN_PROGRESS,
        GRACE_PERIOD
    }

    function getAdapterName() external pure returns (string memory);


    function startNewVotingForProposal(
        DaoRegistry dao,
        bytes32 proposalId,
        bytes calldata data
    ) external;


    function getSenderAddress(
        DaoRegistry dao,
        address actionId,
        bytes memory data,
        address sender
    ) external returns (address);


    function voteResult(DaoRegistry dao, bytes32 proposalId)
        external
        returns (VotingState state);

}pragma solidity ^0.8.0;


library FairShareHelper {

    function calc(
        uint256 balance,
        uint256 units,
        uint256 totalUnits
    ) internal pure returns (uint256) {

        require(totalUnits > 0, "totalUnits must be greater than 0");
        require(
            units <= totalUnits,
            "units must be less than or equal to totalUnits"
        );
        if (balance == 0) {
            return 0;
        }
        uint256 prod = balance * units;
        return prod / totalUnits;
    }
}pragma solidity ^0.8.0;




library GuildKickHelper {

    address internal constant TOTAL = address(0xbabe);
    address internal constant UNITS = address(0xFF1CE);
    address internal constant LOOT = address(0xB105F00D);

    bytes32 internal constant BANK = keccak256("bank");
    address internal constant GUILD = address(0xdead);

    function rageKick(DaoRegistry dao, address kickedMember) internal {

        BankExtension bank = BankExtension(dao.getExtensionAddress(BANK));
        uint256 nbTokens = bank.nbTokens();
        uint256 initialTotalUnitsAndLoot =
            bank.balanceOf(TOTAL, UNITS) + bank.balanceOf(TOTAL, LOOT);

        uint256 unitsToBurn = bank.balanceOf(kickedMember, UNITS);
        uint256 lootToBurn = bank.balanceOf(kickedMember, LOOT);
        uint256 unitsAndLootToBurn = unitsToBurn + lootToBurn;

        for (uint256 i = 0; i < nbTokens; i++) {
            address token = bank.getToken(i);
            uint256 amountToRagequit =
                FairShareHelper.calc(
                    bank.balanceOf(GUILD, token),
                    unitsAndLootToBurn,
                    initialTotalUnitsAndLoot
                );

            if (amountToRagequit > 0) {
                bank.internalTransfer(
                    GUILD,
                    kickedMember,
                    token,
                    amountToRagequit
                );
            }
        }

        bank.subtractFromBalance(kickedMember, UNITS, unitsToBurn);
        bank.subtractFromBalance(kickedMember, LOOT, lootToBurn);
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




contract VotingContract is IVoting, DaoConstants, MemberGuard, AdapterGuard {

    struct Voting {
        uint256 nbYes;
        uint256 nbNo;
        uint256 startingTime;
        uint256 blockNumber;
        mapping(address => uint256) votes;
    }

    bytes32 constant VotingPeriod = keccak256("voting.votingPeriod");
    bytes32 constant GracePeriod = keccak256("voting.gracePeriod");

    mapping(address => mapping(bytes32 => Voting)) public votes;

    string public constant ADAPTER_NAME = "VotingContract";

    function getAdapterName() external pure override returns (string memory) {

        return ADAPTER_NAME;
    }

    function configureDao(
        DaoRegistry dao,
        uint256 votingPeriod,
        uint256 gracePeriod
    ) external onlyAdapter(dao) {

        dao.setConfiguration(VotingPeriod, votingPeriod);
        dao.setConfiguration(GracePeriod, gracePeriod);
    }

    function startNewVotingForProposal(
        DaoRegistry dao,
        bytes32 proposalId,
        bytes calldata
    ) external override onlyAdapter(dao) {


        Voting storage vote = votes[address(dao)][proposalId];
        vote.startingTime = block.timestamp;
        vote.blockNumber = block.number;
    }

    function getSenderAddress(
        DaoRegistry,
        address,
        bytes memory,
        address sender
    ) external pure override returns (address) {

        return sender;
    }

    function submitVote(
        DaoRegistry dao,
        bytes32 proposalId,
        uint256 voteValue
    ) external onlyMember(dao) {

        require(
            dao.getProposalFlag(proposalId, DaoRegistry.ProposalFlag.SPONSORED),
            "the proposal has not been sponsored yet"
        );

        require(
            !dao.getProposalFlag(
                proposalId,
                DaoRegistry.ProposalFlag.PROCESSED
            ),
            "the proposal has already been processed"
        );

        require(
            voteValue < 3 && voteValue > 0,
            "only yes (1) and no (2) are possible values"
        );

        Voting storage vote = votes[address(dao)][proposalId];

        require(
            vote.startingTime > 0,
            "this proposalId has no vote going on at the moment"
        );
        require(
            block.timestamp <
                vote.startingTime + dao.getConfiguration(VotingPeriod),
            "vote has already ended"
        );

        address memberAddr = dao.getAddressIfDelegated(msg.sender);

        require(vote.votes[memberAddr] == 0, "member has already voted");
        BankExtension bank = BankExtension(dao.getExtensionAddress(BANK));
        uint256 correctWeight =
            bank.getPriorAmount(memberAddr, UNITS, vote.blockNumber);

        vote.votes[memberAddr] = voteValue;

        if (voteValue == 1) {
            vote.nbYes = vote.nbYes + correctWeight;
        } else if (voteValue == 2) {
            vote.nbNo = vote.nbNo + correctWeight;
        }
    }

    function voteResult(DaoRegistry dao, bytes32 proposalId)
        external
        view
        override
        returns (VotingState state)
    {

        Voting storage vote = votes[address(dao)][proposalId];
        if (vote.startingTime == 0) {
            return VotingState.NOT_STARTED;
        }

        if (
            block.timestamp <
            vote.startingTime + dao.getConfiguration(VotingPeriod)
        ) {
            return VotingState.IN_PROGRESS;
        }

        if (
            block.timestamp <
            vote.startingTime +
                dao.getConfiguration(VotingPeriod) +
                dao.getConfiguration(GracePeriod)
        ) {
            return VotingState.GRACE_PERIOD;
        }

        if (vote.nbYes > vote.nbNo) {
            return VotingState.PASS;
        } else if (vote.nbYes < vote.nbNo) {
            return VotingState.NOT_PASS;
        } else {
            return VotingState.TIE;
        }
    }
}pragma solidity ^0.8.0;




contract SnapshotProposalContract {

    string public constant EIP712_DOMAIN =
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,address actionId)";
    string public constant PROPOSAL_MESSAGE_TYPE =
        "Message(uint64 timestamp,bytes32 spaceHash,MessagePayload payload)MessagePayload(bytes32 nameHash,bytes32 bodyHash,string[] choices,uint64 start,uint64 end,string snapshot)";
    string public constant PROPOSAL_PAYLOAD_TYPE =
        "MessagePayload(bytes32 nameHash,bytes32 bodyHash,string[] choices,uint64 start,uint64 end,string snapshot)";
    string public constant VOTE_MESSAGE_TYPE =
        "Message(uint64 timestamp,MessagePayload payload)MessagePayload(uint32 choice,bytes32 proposalId)";
    string public constant VOTE_PAYLOAD_TYPE =
        "MessagePayload(uint32 choice,bytes32 proposalId)";

    bytes32 public constant EIP712_DOMAIN_TYPEHASH =
        keccak256(abi.encodePacked(EIP712_DOMAIN));
    bytes32 public constant PROPOSAL_MESSAGE_TYPEHASH =
        keccak256(abi.encodePacked(PROPOSAL_MESSAGE_TYPE));
    bytes32 public constant PROPOSAL_PAYLOAD_TYPEHASH =
        keccak256(abi.encodePacked(PROPOSAL_PAYLOAD_TYPE));
    bytes32 public constant VOTE_MESSAGE_TYPEHASH =
        keccak256(abi.encodePacked(VOTE_MESSAGE_TYPE));
    bytes32 public constant VOTE_PAYLOAD_TYPEHASH =
        keccak256(abi.encodePacked(VOTE_PAYLOAD_TYPE));

    uint256 public chainId;

    function DOMAIN_SEPARATOR(DaoRegistry dao, address actionId)
        public
        view
        returns (bytes32)
    {

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

    struct ProposalMessage {
        uint256 timestamp;
        bytes32 spaceHash;
        ProposalPayload payload;
        bytes sig;
    }

    struct ProposalPayload {
        bytes32 nameHash;
        bytes32 bodyHash;
        string[] choices;
        uint256 start;
        uint256 end;
        string snapshot;
    }

    struct VoteMessage {
        uint256 timestamp;
        VotePayload payload;
    }

    struct VotePayload {
        uint32 choice;
        bytes32 proposalId;
    }

    constructor(uint256 _chainId) {
        chainId = _chainId;
    }

    function hashMessage(
        DaoRegistry dao,
        address actionId,
        ProposalMessage memory message
    ) public view returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(dao, actionId),
                    hashProposalMessage(message)
                )
            );
    }

    function hashProposalMessage(ProposalMessage memory message)
        public
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    PROPOSAL_MESSAGE_TYPEHASH,
                    message.timestamp,
                    message.spaceHash,
                    hashProposalPayload(message.payload)
                )
            );
    }

    function hashProposalPayload(ProposalPayload memory payload)
        public
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    PROPOSAL_PAYLOAD_TYPEHASH,
                    payload.nameHash,
                    payload.bodyHash,
                    keccak256(abi.encodePacked(toHashArray(payload.choices))),
                    payload.start,
                    payload.end,
                    keccak256(abi.encodePacked(payload.snapshot))
                )
            );
    }

    function hashVote(
        DaoRegistry dao,
        address actionId,
        VoteMessage memory message
    ) public view returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(dao, actionId),
                    hashVoteInternal(message)
                )
            );
    }

    function hashVoteInternal(VoteMessage memory message)
        public
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    VOTE_MESSAGE_TYPEHASH,
                    message.timestamp,
                    hashVotePayload(message.payload)
                )
            );
    }

    function hashVotePayload(VotePayload memory payload)
        public
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    VOTE_PAYLOAD_TYPEHASH,
                    payload.choice,
                    payload.proposalId
                )
            );
    }

    function toHashArray(string[] memory arr)
        internal
        pure
        returns (bytes32[] memory result)
    {

        result = new bytes32[](arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result[i] = keccak256(abi.encodePacked(arr[i]));
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}pragma solidity ^0.8.0;




contract OffchainVotingContract is
    IVoting,
    DaoConstants,
    MemberGuard,
    AdapterGuard,
    Signatures,
    Ownable
{

    enum BadNodeError {
        OK,
        WRONG_PROPOSAL_ID,
        INVALID_CHOICE,
        AFTER_VOTING_PERIOD,
        BAD_SIGNATURE
    }

    struct ProposalChallenge {
        address reporter;
        uint256 units;
    }

    uint256 public constant NB_CHOICES = 2;

    SnapshotProposalContract private _snapshotContract;
    KickBadReporterAdapter private _handleBadReporterAdapter;

    string public constant VOTE_RESULT_NODE_TYPE =
        "Message(uint64 timestamp,uint88 nbYes,uint88 nbNo,uint32 index,uint32 choice,bytes32 proposalId)";

    string public constant ADAPTER_NAME = "OffchainVotingContract";
    string public constant VOTE_RESULT_ROOT_TYPE = "Message(bytes32 root)";
    bytes32 public constant VOTE_RESULT_NODE_TYPEHASH =
        keccak256(abi.encodePacked(VOTE_RESULT_NODE_TYPE));
    bytes32 public constant VOTE_RESULT_ROOT_TYPEHASH =
        keccak256(abi.encodePacked(VOTE_RESULT_ROOT_TYPE));

    bytes32 constant VotingPeriod = keccak256("offchainvoting.votingPeriod");
    bytes32 constant GracePeriod = keccak256("offchainvoting.gracePeriod");
    bytes32 constant FallbackThreshold =
        keccak256("offchainvoting.fallbackThreshold");

    struct VoteStepParams {
        uint256 previousYes;
        uint256 previousNo;
        bytes32 proposalId;
    }

    struct Voting {
        uint256 snapshot;
        address reporter;
        bytes32 resultRoot;
        uint256 nbYes;
        uint256 nbNo;
        uint256 startingTime;
        uint256 gracePeriodStartingTime;
        bool isChallenged;
        bool forceFailed;
        mapping(address => bool) fallbackVotes;
        uint256 fallbackVotesCount;
    }

    struct VoteResultNode {
        uint32 choice;
        uint64 index;
        uint64 timestamp;
        uint88 nbNo;
        uint88 nbYes;
        bytes sig;
        bytes32 proposalId;
        bytes32[] proof;
    }

    modifier onlyBadReporterAdapter() {

        require(msg.sender == address(_handleBadReporterAdapter), "only:hbra");
        _;
    }

    VotingContract public fallbackVoting;

    mapping(address => mapping(bytes32 => ProposalChallenge)) challengeProposals;
    mapping(address => mapping(bytes32 => Voting)) public votes;

    constructor(
        VotingContract _c,
        SnapshotProposalContract _spc,
        KickBadReporterAdapter _hbra,
        address _owner
    ) {
        require(address(_c) != address(0x0), "voting contract");
        require(address(_spc) != address(0x0), "snapshot proposal");
        require(address(_hbra) != address(0x0), "handle bad reporter");
        fallbackVoting = _c;
        _snapshotContract = _spc;
        _handleBadReporterAdapter = _hbra;
        Ownable(_owner);
    }

    function adminFailProposal(DaoRegistry dao, bytes32 proposalId)
        external
        onlyOwner
    {

        Voting storage vote = votes[address(dao)][proposalId];
        require(vote.startingTime > 0, "proposal has not started yet");

        vote.forceFailed = true;
    }

    function hashResultRoot(
        DaoRegistry dao,
        address actionId,
        bytes32 resultRoot
    ) public view returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    _snapshotContract.DOMAIN_SEPARATOR(dao, actionId),
                    keccak256(abi.encode(VOTE_RESULT_ROOT_TYPEHASH, resultRoot))
                )
            );
    }

    function getAdapterName() external pure override returns (string memory) {

        return ADAPTER_NAME;
    }

    function getChallengeDetails(DaoRegistry dao, bytes32 proposalId)
        external
        view
        returns (uint256, address)
    {

        return (
            challengeProposals[address(dao)][proposalId].units,
            challengeProposals[address(dao)][proposalId].reporter
        );
    }

    function hashVotingResultNode(VoteResultNode memory node)
        public
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    VOTE_RESULT_NODE_TYPEHASH,
                    node.timestamp,
                    node.nbYes,
                    node.nbNo,
                    node.index,
                    node.choice,
                    node.proposalId
                )
            );
    }

    function nodeHash(
        DaoRegistry dao,
        address actionId,
        VoteResultNode memory node
    ) public view returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    _snapshotContract.DOMAIN_SEPARATOR(dao, actionId),
                    hashVotingResultNode(node)
                )
            );
    }

    function configureDao(
        DaoRegistry dao,
        uint256 votingPeriod,
        uint256 gracePeriod,
        uint256 fallbackThreshold
    ) external onlyAdapter(dao) {

        dao.setConfiguration(VotingPeriod, votingPeriod);
        dao.setConfiguration(GracePeriod, gracePeriod);
        dao.setConfiguration(FallbackThreshold, fallbackThreshold);
    }


    function submitVoteResult(
        DaoRegistry dao,
        bytes32 proposalId,
        bytes32 resultRoot,
        VoteResultNode memory result,
        bytes memory rootSig
    ) external {

        Voting storage vote = votes[address(dao)][proposalId];
        require(vote.snapshot > 0, "vote:not started");

        if (vote.resultRoot == bytes32(0) || vote.isChallenged) {
            require(
                _readyToSubmitResult(dao, vote, result.nbYes, result.nbNo),
                "vote:notReadyToSubmitResult"
            );
        }

        (address adapterAddress, ) = dao.proposals(proposalId);
        address reporter =
            ECDSA.recover(
                hashResultRoot(dao, adapterAddress, resultRoot),
                rootSig
            );
        address memberAddr = dao.getAddressIfDelegated(reporter);
        require(isActiveMember(dao, memberAddr), "not active member");
        BankExtension bank = BankExtension(dao.getExtensionAddress(BANK));
        uint256 nbMembers =
            bank.getPriorAmount(TOTAL, MEMBER_COUNT, vote.snapshot);
        require(nbMembers - 1 == result.index, "index:member_count mismatch");
        require(
            getBadNodeError(
                dao,
                proposalId,
                true,
                resultRoot,
                vote.snapshot,
                vote.gracePeriodStartingTime,
                result
            ) == BadNodeError.OK,
            "bad result"
        );

        require(
            vote.nbYes + vote.nbNo < result.nbYes + result.nbNo,
            "result weight too low"
        );

        if (
            vote.gracePeriodStartingTime == 0 ||
            vote.nbNo > vote.nbYes != result.nbNo > result.nbYes // check whether the new result changes the outcome
        ) {
            vote.gracePeriodStartingTime = block.timestamp;
        }

        vote.nbNo = result.nbNo;
        vote.nbYes = result.nbYes;
        vote.resultRoot = resultRoot;
        vote.reporter = memberAddr;
        vote.isChallenged = false;
    }

    function _readyToSubmitResult(
        DaoRegistry dao,
        Voting storage vote,
        uint256 nbYes,
        uint256 nbNo
    ) internal view returns (bool) {

        if (vote.forceFailed) {
            return false;
        }
        BankExtension bank = BankExtension(dao.getExtensionAddress(BANK));
        uint256 totalWeight = bank.getPriorAmount(TOTAL, UNITS, vote.snapshot);
        uint256 unvotedWeights = totalWeight - nbYes - nbNo;

        uint256 diff;
        if (nbYes > nbNo) {
            diff = nbYes - nbNo;
        } else {
            diff = nbNo - nbYes;
        }

        if (diff > unvotedWeights) {
            return true;
        }

        uint256 votingPeriod = dao.getConfiguration(VotingPeriod);
        return vote.startingTime + votingPeriod <= block.timestamp;
    }

    function getSenderAddress(
        DaoRegistry dao,
        address actionId,
        bytes memory data,
        address
    ) external view override returns (address) {

        SnapshotProposalContract.ProposalMessage memory proposal =
            abi.decode(data, (SnapshotProposalContract.ProposalMessage));
        return
            ECDSA.recover(
                _snapshotContract.hashMessage(dao, actionId, proposal),
                proposal.sig
            );
    }

    function startNewVotingForProposal(
        DaoRegistry dao,
        bytes32 proposalId,
        bytes memory data
    ) public override onlyAdapter(dao) {

        SnapshotProposalContract.ProposalMessage memory proposal =
            abi.decode(data, (SnapshotProposalContract.ProposalMessage));
        (bool success, uint256 blockNumber) =
            _stringToUint(proposal.payload.snapshot);
        require(success, "snapshot conversion error");
        BankExtension bank = BankExtension(dao.getExtensionAddress(BANK));

        bytes32 proposalHash =
            _snapshotContract.hashMessage(dao, msg.sender, proposal);
        address addr = ECDSA.recover(proposalHash, proposal.sig);

        address memberAddr = dao.getAddressIfDelegated(addr);
        require(bank.balanceOf(memberAddr, UNITS) > 0, "noActiveMember");
        require(
            blockNumber <= block.number,
            "snapshot block number should not be in the future"
        );
        require(blockNumber > 0, "block number cannot be 0");

        votes[address(dao)][proposalId].startingTime = block.timestamp;
        votes[address(dao)][proposalId].snapshot = blockNumber;
    }

    function _fallbackVotingActivated(
        DaoRegistry dao,
        uint256 fallbackVotesCount
    ) internal view returns (bool) {

        return
            fallbackVotesCount >
            (dao.getNbMembers() * 100) /
                dao.getConfiguration(FallbackThreshold);
    }

    function voteResult(DaoRegistry dao, bytes32 proposalId)
        external
        view
        override
        returns (VotingState state)
    {

        Voting storage vote = votes[address(dao)][proposalId];
        if (vote.startingTime == 0) {
            return VotingState.NOT_STARTED;
        }

        if (vote.forceFailed) {
            return VotingState.NOT_PASS;
        }

        if (_fallbackVotingActivated(dao, vote.fallbackVotesCount)) {
            return fallbackVoting.voteResult(dao, proposalId);
        }

        if (vote.isChallenged) {
            return VotingState.IN_PROGRESS;
        }

        uint256 votingPeriod = dao.getConfiguration(VotingPeriod);

        if (block.timestamp < vote.startingTime + votingPeriod) {
            return VotingState.IN_PROGRESS;
        }

        uint256 gracePeriod = dao.getConfiguration(GracePeriod);

        if (
            vote.gracePeriodStartingTime == 0 &&
            block.timestamp < vote.startingTime + gracePeriod + votingPeriod
        ) {
            return VotingState.GRACE_PERIOD;
        }

        if (block.timestamp < vote.gracePeriodStartingTime + gracePeriod) {
            return VotingState.GRACE_PERIOD;
        }

        if (vote.nbYes > vote.nbNo) {
            return VotingState.PASS;
        }
        if (vote.nbYes < vote.nbNo) {
            return VotingState.NOT_PASS;
        }

        return VotingState.TIE;
    }

    function challengeBadFirstNode(
        DaoRegistry dao,
        bytes32 proposalId,
        VoteResultNode memory node
    ) external {

        require(node.index == 0, "only first node");
        Voting storage vote = votes[address(dao)][proposalId];
        (address adapterAddress, ) = dao.proposals(proposalId);
        require(vote.resultRoot != bytes32(0), "no result available yet!");
        bytes32 hashCurrent = nodeHash(dao, adapterAddress, node);
        require(
            MerkleProof.verify(node.proof, vote.resultRoot, hashCurrent),
            "proof:bad"
        );

        (address actionId, ) = dao.proposals(proposalId);

        if (_checkStep(dao, actionId, node, VoteStepParams(0, 0, proposalId))) {
            _challengeResult(dao, proposalId);
        }
    }

    function challengeBadNode(
        DaoRegistry dao,
        bytes32 proposalId,
        VoteResultNode memory node
    ) external {

        Voting storage vote = votes[address(dao)][proposalId];
        if (
            getBadNodeError(
                dao,
                proposalId,
                false,
                vote.resultRoot,
                vote.snapshot,
                vote.gracePeriodStartingTime,
                node
            ) != BadNodeError.OK
        ) {
            _challengeResult(dao, proposalId);
        }
    }

    function _isValidChoice(uint256 choice) internal pure returns (bool) {

        return choice > 0 && choice < NB_CHOICES + 1;
    }

    function getBadNodeError(
        DaoRegistry dao,
        bytes32 proposalId,
        bool submitNewVote,
        bytes32 resultRoot,
        uint256 blockNumber,
        uint256 gracePeriodStartingTime,
        VoteResultNode memory node
    ) public view returns (BadNodeError) {

        (address adapterAddress, ) = dao.proposals(proposalId);
        require(resultRoot != bytes32(0), "no result available yet!");
        bytes32 hashCurrent = nodeHash(dao, adapterAddress, node);
        require(
            MerkleProof.verify(node.proof, resultRoot, hashCurrent),
            "proof:bad"
        );
        address account = dao.getMemberAddress(node.index);
        address voter = dao.getPriorDelegateKey(account, blockNumber);

        (address actionId, ) = dao.proposals(proposalId);

        if (
            (node.sig.length == 0 && node.choice != 0) || // no vote
            (node.sig.length > 0 && !_isValidChoice(node.choice))
        ) {
            return BadNodeError.INVALID_CHOICE;
        }

        if (node.proposalId != proposalId) {
            return BadNodeError.WRONG_PROPOSAL_ID;
        }

        if (!submitNewVote && node.timestamp > gracePeriodStartingTime) {
            return BadNodeError.AFTER_VOTING_PERIOD;
        }

        if (
            node.sig.length > 0 && // a vote has happened
            !_hasVoted(
                dao,
                actionId,
                voter,
                node.timestamp,
                node.proposalId,
                node.choice,
                node.sig
            )
        ) {
            return BadNodeError.BAD_SIGNATURE;
        }

        return BadNodeError.OK;
    }

    function challengeBadStep(
        DaoRegistry dao,
        bytes32 proposalId,
        VoteResultNode memory nodePrevious,
        VoteResultNode memory nodeCurrent
    ) external {

        Voting storage vote = votes[address(dao)][proposalId];
        bytes32 resultRoot = vote.resultRoot;

        (address adapterAddress, ) = dao.proposals(proposalId);
        require(resultRoot != bytes32(0), "no result available yet!");
        bytes32 hashCurrent = nodeHash(dao, adapterAddress, nodeCurrent);
        bytes32 hashPrevious = nodeHash(dao, adapterAddress, nodePrevious);
        require(
            MerkleProof.verify(nodeCurrent.proof, resultRoot, hashCurrent),
            "proof check for current invalid for current node"
        );
        require(
            MerkleProof.verify(nodePrevious.proof, resultRoot, hashPrevious),
            "proof check for previous invalid for previous node"
        );

        require(
            nodeCurrent.index == nodePrevious.index + 1,
            "those nodes are not consecutive"
        );

        (address actionId, ) = dao.proposals(proposalId);
        VoteStepParams memory params =
            VoteStepParams(nodePrevious.nbYes, nodePrevious.nbNo, proposalId);
        if (_checkStep(dao, actionId, nodeCurrent, params)) {
            _challengeResult(dao, proposalId);
        }
    }

    function requestFallback(DaoRegistry dao, bytes32 proposalId)
        external
        onlyMember(dao)
    {

        require(
            votes[address(dao)][proposalId].fallbackVotes[msg.sender] == false,
            "the member has already voted for this vote to fallback"
        );
        votes[address(dao)][proposalId].fallbackVotes[msg.sender] = true;
        votes[address(dao)][proposalId].fallbackVotesCount += 1;

        if (
            _fallbackVotingActivated(
                dao,
                votes[address(dao)][proposalId].fallbackVotesCount
            )
        ) {
            fallbackVoting.startNewVotingForProposal(dao, proposalId, "");
        }
    }

    function _checkStep(
        DaoRegistry dao,
        address actionId,
        VoteResultNode memory node,
        VoteStepParams memory params
    ) internal view returns (bool) {

        Voting storage vote = votes[address(dao)][params.proposalId];
        address account = dao.getMemberAddress(node.index);
        address voter = dao.getPriorDelegateKey(account, vote.snapshot);
        BankExtension bank = BankExtension(dao.getExtensionAddress(BANK));
        uint256 weight = bank.getPriorAmount(account, UNITS, vote.snapshot);

        if (node.choice == 0) {
            if (params.previousYes != node.nbYes) {
                return true;
            } else if (params.previousNo != node.nbNo) {
                return true;
            }
        }

        if (
            _hasVoted(
                dao,
                actionId,
                voter,
                node.timestamp,
                node.proposalId,
                1,
                node.sig
            )
        ) {
            if (params.previousYes + weight != node.nbYes) {
                return true;
            } else if (params.previousNo != node.nbNo) {
                return true;
            }
        }
        if (
            _hasVoted(
                dao,
                actionId,
                voter,
                node.timestamp,
                node.proposalId,
                2,
                node.sig
            )
        ) {
            if (params.previousYes != node.nbYes) {
                return true;
            } else if (params.previousNo + weight != node.nbNo) {
                return true;
            }
        }

        return false;
    }

    function sponsorChallengeProposal(
        DaoRegistry dao,
        bytes32 proposalId,
        address sponsoredBy
    ) external onlyBadReporterAdapter {

        dao.sponsorProposal(proposalId, sponsoredBy, address(this));
    }

    function processChallengeProposal(DaoRegistry dao, bytes32 proposalId)
        external
        onlyBadReporterAdapter
    {

        dao.processProposal(proposalId);
    }

    function _challengeResult(DaoRegistry dao, bytes32 proposalId) internal {

        BankExtension bank = BankExtension(dao.getExtensionAddress(BANK));

        votes[address(dao)][proposalId].isChallenged = true;
        address challengedReporter = votes[address(dao)][proposalId].reporter;
        bytes32 challengeProposalId =
            keccak256(
                abi.encodePacked(
                    proposalId,
                    votes[address(dao)][proposalId].resultRoot
                )
            );

        dao.submitProposal(challengeProposalId);

        uint256 units = bank.balanceOf(challengedReporter, UNITS);

        challengeProposals[address(dao)][
            challengeProposalId
        ] = ProposalChallenge(challengedReporter, units);

        bank.subtractFromBalance(challengedReporter, UNITS, units);
        bank.addToBalance(challengedReporter, LOOT, units);
    }

    function _hasVoted(
        DaoRegistry dao,
        address actionId,
        address voter,
        uint64 timestamp,
        bytes32 proposalId,
        uint32 choiceIdx,
        bytes memory sig
    ) internal view returns (bool) {

        bytes32 voteHash =
            _snapshotContract.hashVote(
                dao,
                actionId,
                SnapshotProposalContract.VoteMessage(
                    timestamp,
                    SnapshotProposalContract.VotePayload(choiceIdx, proposalId)
                )
            );

        return ECDSA.recover(voteHash, sig) == voter;
    }

    function _stringToUint(string memory s)
        internal
        pure
        returns (bool success, uint256 result)
    {

        bytes memory b = bytes(s);
        result = 0;
        success = false;
        for (uint256 i = 0; i < b.length; i++) {
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
                success = true;
            } else {
                result = 0;
                success = false;
                break;
            }
        }
        return (success, result);
    }
}pragma solidity ^0.8.0;




contract KickBadReporterAdapter is DaoConstants, MemberGuard {

    receive() external payable {
        revert("fallback revert");
    }

    function sponsorProposal(
        DaoRegistry dao,
        bytes32 proposalId,
        bytes calldata data
    ) external {

        OffchainVotingContract votingContract =
            OffchainVotingContract(dao.getAdapterAddress(VOTING));
        address sponsoredBy =
            votingContract.getSenderAddress(
                dao,
                address(this),
                data,
                msg.sender
            );
        _sponsorProposal(dao, proposalId, data, sponsoredBy, votingContract);
    }

    function _sponsorProposal(
        DaoRegistry dao,
        bytes32 proposalId,
        bytes memory data,
        address sponsoredBy,
        OffchainVotingContract votingContract
    ) internal onlyMember2(dao, sponsoredBy) {

        votingContract.sponsorChallengeProposal(dao, proposalId, sponsoredBy);
        votingContract.startNewVotingForProposal(dao, proposalId, data);
    }

    function processProposal(DaoRegistry dao, bytes32 proposalId) external {

        OffchainVotingContract votingContract =
            OffchainVotingContract(dao.getAdapterAddress(VOTING));

        votingContract.processChallengeProposal(dao, proposalId);

        IVoting.VotingState votingState =
            votingContract.voteResult(dao, proposalId);
        if (votingState == IVoting.VotingState.PASS) {
            (, address challengeAddress) =
                votingContract.getChallengeDetails(dao, proposalId);
            GuildKickHelper.rageKick(dao, challengeAddress);
        } else if (
            votingState == IVoting.VotingState.NOT_PASS ||
            votingState == IVoting.VotingState.TIE
        ) {
            (uint256 units, address challengeAddress) =
                votingContract.getChallengeDetails(dao, proposalId);
            BankExtension bank = BankExtension(dao.getExtensionAddress(BANK));

            bank.subtractFromBalance(challengeAddress, LOOT, units);
            bank.addToBalance(challengeAddress, UNITS, units);
        } else {
            revert("vote not finished yet");
        }
    }
}