
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
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


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
}// GPL-3.0

pragma solidity 0.8.10; 


abstract contract TOracle is Pausable, AccessControl {
    enum Vote {No, Yes}
    enum ProposalStatus {Inactive, Active, Passed, Executed, Cancelled}
    struct Proposal {
        ProposalStatus _status;
        bytes32 _dataHash;
        address[] _yesVotes;
        uint256 _proposedBlock;
    }


    event VoteThresholdChanged(uint256 indexed newThreshold);
    event OracleAdded(address indexed oracle);
    event OracleRemoved(address indexed oracle);
    event ProposalEvent(
        uint32 indexed proposalNumber,
        ProposalStatus indexed status,
        bytes32 dataHash
    );
    event ProposalVote(
        uint32 indexed proposalNumber,
        ProposalStatus indexed status
    );


    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    uint256 public _voteThreshold; //number of votes required to pass a proposal
    uint256 public _expiry; //blocks after which to expire proposals
    uint256 public _totalOracles; //number of oracles
    uint256 public _executedCount;

    mapping(uint32 => mapping(bytes32 => Proposal)) public _proposals;
    mapping(uint32 => mapping(bytes32 => mapping(address => bool))) public _hasVotedOnProposal;

    uint256[50] private ______gap; //leave space for upgrades;


    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }
    modifier onlyAdminOrOracle() {
        _onlyAdminOrOracle();
        _;
    }
    modifier onlyOracles() {
        _onlyOracles();
        _;
    }
    modifier onlySelf(){
        _onlySelf();
        _;
    }

    function _onlyAdminOrOracle() private view {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(ORACLE_ROLE, msg.sender),
            "sender is not oracle or admin"
        );
    }
    function _onlyAdmin() private view {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "sender doesn't have admin role");
    }
    function _onlyOracles() private view {
        require(hasRole(ORACLE_ROLE, msg.sender), "sender doesn't have oracle role");
    }
    function _onlySelf() private view {
        require(msg.sender == address(this), "Only self can call");
    }

    constructor(
        uint256 initialVoteThreshold,
        uint256 expiry,
        address[] memory initialOracles        
    ){
        _voteThreshold = initialVoteThreshold;
        _expiry = expiry;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(ORACLE_ROLE, DEFAULT_ADMIN_ROLE);
        for (uint256 i; i < initialOracles.length; i++){
            grantRole(ORACLE_ROLE, initialOracles[i]);
        }
        _totalOracles = initialOracles.length;
    }

    function isOracle(address checkAddress) external view returns (bool) {
        return hasRole(ORACLE_ROLE, checkAddress);
    }

    function renounceAdmin(address newAdmin) external onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function adminPause() external onlyAdmin {
        _pause();
    }

    function adminUnpause() external onlyAdmin {
        _unpause();
    }

    function adminChangeVoteThreshold(uint256 newThreshold) external onlyAdmin {
        _voteThreshold = newThreshold;
        emit VoteThresholdChanged(newThreshold);
    }

    function adminAddOracle(address oracleAddress) external onlyAdmin {
        require(!hasRole(ORACLE_ROLE, oracleAddress), "addr already has oracle role!");
        grantRole(ORACLE_ROLE, oracleAddress);
        emit OracleAdded(oracleAddress);
        _totalOracles++;
    }

    function adminRemoveOracle(address oracleAddress) external onlyAdmin {
        require(hasRole(ORACLE_ROLE, oracleAddress), "addr doesn't have oracle role!");
        revokeRole(ORACLE_ROLE, oracleAddress);
        emit OracleRemoved(oracleAddress);
        _totalOracles--;
    }
    
    function getProposal(
        uint32 proposalNumber,
        bytes32 dataHash
    ) external view returns (Proposal memory) {
        return _proposals[proposalNumber][dataHash];
    }

    function voteProposal(uint32 proposalNumber, bytes32 dataHash) external onlyOracles whenNotPaused {
        Proposal storage proposal = _proposals[proposalNumber][dataHash];

        if (proposal._status > ProposalStatus.Active) return;
        
        require(!_hasVotedOnProposal[proposalNumber][dataHash][msg.sender], "oracle already voted");

        if (proposal._status == ProposalStatus.Inactive) {
            _proposals[proposalNumber][dataHash] = Proposal({
                _dataHash: dataHash,
                _yesVotes: new address[](1),
                _status: ProposalStatus.Active,
                _proposedBlock: block.number
            });
            proposal._yesVotes[0] = msg.sender;
            emit ProposalEvent(proposalNumber, ProposalStatus.Active, dataHash);
        } else {
            if (block.number - proposal._proposedBlock > _expiry) {
                proposal._status = ProposalStatus.Cancelled;
                emit ProposalEvent(
                    proposalNumber,
                    ProposalStatus.Cancelled,
                    dataHash
                );
            } else {
                require(dataHash == proposal._dataHash, "datahash mismatch");
                proposal._yesVotes.push(msg.sender);
            }
        }
        if (proposal._status != ProposalStatus.Cancelled) {
            _hasVotedOnProposal[proposalNumber][dataHash][msg.sender] = true;
            emit ProposalVote(proposalNumber, proposal._status);

            if (_voteThreshold <= 1 || proposal._yesVotes.length >= _voteThreshold) {
                proposal._status = ProposalStatus.Passed;
                emit ProposalEvent(
                    proposalNumber,
                    ProposalStatus.Passed,
                    dataHash
                );
            }
        }
    }

    function cancelProposal(
        uint32 proposalNumber,
        bytes32 dataHash
    ) public onlyAdminOrOracle {
        Proposal storage proposal = _proposals[proposalNumber][dataHash];

        require(proposal._status != ProposalStatus.Cancelled, "Proposal already cancelled");
        require(
            block.number - proposal._proposedBlock > _expiry,
            "Proposal not at expiry threshold"
        );

        proposal._status = ProposalStatus.Cancelled;
        emit ProposalEvent(
            proposalNumber,
            ProposalStatus.Cancelled,
            proposal._dataHash
        );
    }

    function executeProposal(
        uint32 proposalNumber,
        bytes calldata data
    ) external onlyOracles whenNotPaused {
        bytes32 dataHash = keccak256(data);
        Proposal storage proposal = _proposals[proposalNumber][dataHash];

        require(proposal._status != ProposalStatus.Inactive, "proposal is not active");
        require(proposal._status == ProposalStatus.Passed, "proposal already executed, cancelled, or not yet passed");
        require(dataHash == proposal._dataHash, "data doesn't match datahash");

        require(proposalNumber == uint32(bytes4(data[:4])), "proposalNumber<>data mismatch");

        proposal._status = ProposalStatus.Executed;
        ++_executedCount;
        onExecute(data[4:]);

        emit ProposalEvent(
            proposalNumber,
            ProposalStatus.Executed,
            dataHash
        );
    }

    function onExecute(bytes calldata data) internal virtual;
    
    function transferFunds(address payable[] calldata addrs, uint256[] calldata amounts)
        external
        onlyAdmin
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            addrs[i].transfer(amounts[i]);
        }
    }
}// GPL-3.0

pragma solidity 0.8.10; 


interface IOracle {

    function getData() external view returns (uint256, bool);

}

contract TBillPriceOracle is TOracle, IOracle {

    event UpdatedAvgPrice(
        uint256 price,
        bool valid
    );
    
    uint256 private constant VALIDITY_MASK = 2**(256-1);
    uint256 private constant PRICE_MASK = VALIDITY_MASK-1;
    uint8 public constant decimals = 18;

    uint256 private _tbillAvgPriceAndValidity; //1 bit validity then 255 bit price; updated ONLY daily. for more up-to-date info, view PriceRecords

    constructor(
        uint256 initialTbillPrice, 
        uint256 initialVoteThreshold, uint256 expiry, address[] memory initialOracles
    )
    TOracle(initialVoteThreshold, expiry, initialOracles)
    {
        _tbillAvgPriceAndValidity = initialTbillPrice;        
    }    

    function getData() external view returns (uint256 price, bool valid) {

        price = _tbillAvgPriceAndValidity & PRICE_MASK;
        valid = _tbillAvgPriceAndValidity & VALIDITY_MASK > 0;
    }
    function getTBillLastPrice() external view returns (uint256 price) {

        price = _tbillAvgPriceAndValidity & PRICE_MASK;
    }
    function getTBillLastPriceValid() external view returns (bool valid) {

        valid = _tbillAvgPriceAndValidity & VALIDITY_MASK > 0;
    }

    function onExecute(bytes calldata data) internal override {

        uint256 tbillAvgPriceAndValidity = uint256(bytes32(data[:32]));
        uint256 price = tbillAvgPriceAndValidity & PRICE_MASK;
        bool valid = tbillAvgPriceAndValidity & VALIDITY_MASK > 0;
        _tbillAvgPriceAndValidity = tbillAvgPriceAndValidity;
        emit UpdatedAvgPrice(price, valid);
    }    
}