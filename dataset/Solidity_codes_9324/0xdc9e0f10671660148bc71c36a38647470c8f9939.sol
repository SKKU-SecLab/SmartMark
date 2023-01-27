



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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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




pragma solidity 0.8.12;

interface IBribeVault {

    function depositBribeERC20(
        bytes32 bribeIdentifier,
        bytes32 rewardIdentifier,
        address token,
        uint256 amount,
        address briber
    ) external;


    function getBribe(bytes32 bribeIdentifier)
        external
        view
        returns (address token, uint256 amount);


    function depositBribe(
        bytes32 bribeIdentifier,
        bytes32 rewardIdentifier,
        address briber
    ) external payable;

}




pragma solidity 0.8.12;



contract BribeBase is AccessControl, ReentrancyGuard {

    address public immutable BRIBE_VAULT;
    bytes32 public constant TEAM_ROLE = keccak256("TEAM_ROLE");

    bytes32 public immutable PROTOCOL;

    mapping(bytes32 => uint256) public proposalDeadlines;

    mapping(address => address) public rewardForwarding;

    mapping(address => uint256) public indexOfWhitelistedToken;
    address[] public allWhitelistedTokens;

    event GrantTeamRole(address teamMember);
    event RevokeTeamRole(address teamMember);
    event SetProposal(bytes32 indexed proposal, uint256 deadline);
    event DepositBribe(
        bytes32 indexed proposal,
        address indexed token,
        uint256 amount,
        bytes32 bribeIdentifier,
        bytes32 rewardIdentifier,
        address indexed briber
    );
    event SetRewardForwarding(address from, address to);
    event AddWhitelistTokens(address[] tokens);
    event RemoveWhitelistTokens(address[] tokens);

    constructor(address _BRIBE_VAULT, string memory _PROTOCOL) {
        require(_BRIBE_VAULT != address(0), "Invalid _BRIBE_VAULT");
        BRIBE_VAULT = _BRIBE_VAULT;

        require(bytes(_PROTOCOL).length != 0, "Invalid _PROTOCOL");
        PROTOCOL = keccak256(abi.encodePacked(_PROTOCOL));

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier onlyAuthorized() {

        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
                hasRole(TEAM_ROLE, msg.sender),
            "Not authorized"
        );
        _;
    }

    function grantTeamRole(address teamMember)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(teamMember != address(0), "Invalid teamMember");
        _grantRole(TEAM_ROLE, teamMember);

        emit GrantTeamRole(teamMember);
    }

    function revokeTeamRole(address teamMember)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(hasRole(TEAM_ROLE, teamMember), "Invalid teamMember");
        _revokeRole(TEAM_ROLE, teamMember);

        emit RevokeTeamRole(teamMember);
    }

    function getWhitelistedTokens() external view returns (address[] memory) {

        return allWhitelistedTokens;
    }

    function isWhitelistedToken(address token) public view returns (bool) {

        if (allWhitelistedTokens.length == 0) {
            return false;
        }

        return
            indexOfWhitelistedToken[token] != 0 ||
            allWhitelistedTokens[0] == token;
    }

    function addWhitelistTokens(address[] calldata tokens)
        external
        onlyAuthorized
    {

        for (uint256 i; i < tokens.length; ++i) {
            require(tokens[i] != address(0), "Invalid token");
            require(tokens[i] != BRIBE_VAULT, "Cannot whitelist BRIBE_VAULT");
            require(
                !isWhitelistedToken(tokens[i]),
                "Token already whitelisted"
            );

            allWhitelistedTokens.push(tokens[i]);
            indexOfWhitelistedToken[tokens[i]] =
                allWhitelistedTokens.length -
                1;
        }

        emit AddWhitelistTokens(tokens);
    }

    function removeWhitelistTokens(address[] calldata tokens)
        external
        onlyAuthorized
    {

        for (uint256 i; i < tokens.length; ++i) {
            require(isWhitelistedToken(tokens[i]), "Token not whitelisted");

            uint256 index = indexOfWhitelistedToken[tokens[i]];
            address tail = allWhitelistedTokens[
                allWhitelistedTokens.length - 1
            ];

            allWhitelistedTokens[index] = tail;
            indexOfWhitelistedToken[tail] = index;

            delete indexOfWhitelistedToken[tokens[i]];
            allWhitelistedTokens.pop();
        }

        emit RemoveWhitelistTokens(tokens);
    }

    function _setProposal(bytes32 proposal, uint256 deadline) internal {

        require(proposal != bytes32(0), "Invalid proposal");
        require(deadline > block.timestamp, "Deadline must be in the future");

        proposalDeadlines[proposal] = deadline;

        emit SetProposal(proposal, deadline);
    }

    function generateBribeVaultIdentifier(
        bytes32 proposal,
        uint256 proposalDeadline,
        address token
    ) public view returns (bytes32 identifier) {

        return
            keccak256(
                abi.encodePacked(PROTOCOL, proposal, proposalDeadline, token)
            );
    }

    function generateRewardIdentifier(uint256 proposalDeadline, address token)
        public
        view
        returns (bytes32 identifier)
    {

        return keccak256(abi.encodePacked(PROTOCOL, proposalDeadline, token));
    }

    function getBribe(
        bytes32 proposal,
        uint256 proposalDeadline,
        address token
    ) external view returns (address bribeToken, uint256 bribeAmount) {

        return
            IBribeVault(BRIBE_VAULT).getBribe(
                generateBribeVaultIdentifier(proposal, proposalDeadline, token)
            );
    }

    function depositBribeERC20(
        bytes32 proposal,
        address token,
        uint256 amount
    ) external nonReentrant {

        uint256 proposalDeadline = proposalDeadlines[proposal];
        require(
            proposalDeadlines[proposal] > block.timestamp,
            "Proposal deadline has passed"
        );
        require(token != address(0), "Invalid token");
        require(isWhitelistedToken(token), "Token is not whitelisted");
        require(amount != 0, "Bribe amount must be greater than 0");

        bytes32 bribeIdentifier = generateBribeVaultIdentifier(
            proposal,
            proposalDeadline,
            token
        );
        bytes32 rewardIdentifier = generateRewardIdentifier(
            proposalDeadline,
            token
        );

        IBribeVault(BRIBE_VAULT).depositBribeERC20(
            bribeIdentifier,
            rewardIdentifier,
            token,
            amount,
            msg.sender
        );

        emit DepositBribe(
            proposal,
            token,
            amount,
            bribeIdentifier,
            rewardIdentifier,
            msg.sender
        );
    }

    function depositBribe(bytes32 proposal) external payable nonReentrant {

        uint256 proposalDeadline = proposalDeadlines[proposal];
        require(
            proposalDeadlines[proposal] > block.timestamp,
            "Proposal deadline has passed"
        );
        require(msg.value != 0, "Bribe amount must be greater than 0");

        bytes32 bribeIdentifier = generateBribeVaultIdentifier(
            proposal,
            proposalDeadline,
            BRIBE_VAULT
        );
        bytes32 rewardIdentifier = generateRewardIdentifier(
            proposalDeadline,
            BRIBE_VAULT
        );

        IBribeVault(BRIBE_VAULT).depositBribe{value: msg.value}(
            bribeIdentifier,
            rewardIdentifier,
            msg.sender
        );

        emit DepositBribe(
            proposal,
            BRIBE_VAULT,
            msg.value,
            bribeIdentifier,
            rewardIdentifier,
            msg.sender
        );
    }

    function setRewardForwarding(address to) external {

        rewardForwarding[msg.sender] = to;

        emit SetRewardForwarding(msg.sender, to);
    }
}




pragma solidity 0.8.12;

contract RibbonBribe is BribeBase {

    address[] public gauges;
    uint256[] public voteIds;
    mapping(address => uint256) public indexOfGauge;
    mapping(uint256 => uint256) public indexOfVoteId;

    constructor(address _BRIBE_VAULT)
        BribeBase(_BRIBE_VAULT, "RIBBON_FINANCE")
    {}

    function setGaugeProposal(address gauge, uint256 deadline)
        public
        onlyAuthorized
    {

        require(gauge != address(0), "Invalid gauge");

        if (
            gauges.length == 0 ||
            (indexOfGauge[gauge] == 0 && gauges[0] != gauge)
        ) {
            gauges.push(gauge);
            indexOfGauge[gauge] = gauges.length - 1;
        }

        _setProposal(keccak256(abi.encodePacked(gauge)), deadline);
    }

    function setGaugeProposals(
        address[] calldata gauges_,
        uint256[] calldata deadlines
    ) external onlyAuthorized {

        uint256 gaugeLen = gauges_.length;
        require(gaugeLen != 0, "Invalid gauges_");
        require(gaugeLen == deadlines.length, "Arrays length mismatch");

        for (uint256 i; i < gaugeLen; ++i) {
            setGaugeProposal(gauges_[i], deadlines[i]);
        }
    }

    function setDaoProposal(uint256 voteId, uint256 deadline)
        external
        onlyAuthorized
    {

        if (
            voteIds.length == 0 ||
            (indexOfVoteId[voteId] == 0 && voteIds[0] != voteId)
        ) {
            voteIds.push(voteId);
            indexOfVoteId[voteId] = voteIds.length - 1;
        }

        _setProposal(keccak256(abi.encodePacked(voteId)), deadline);
    }

    function getGauges() external view returns (address[] memory) {

        return gauges;
    }

    function getVoteIds() external view returns (uint256[] memory) {

        return voteIds;
    }
}