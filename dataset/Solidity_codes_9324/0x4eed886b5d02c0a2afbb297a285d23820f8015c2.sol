pragma solidity ^0.8.0;

interface IIERC20Snapshot {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);



    function snapshot() external returns (uint256) ;


    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256) ;


    function totalSupplyAt(uint256 snapshotId) external view returns (uint256) ;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function transfer(address recipient, uint256 amount) external returns (bool);


}// Unlicense
pragma solidity ^0.8.0;


interface ITokenDividendPool {

    function claimBatch(address[] calldata _tokens) external;


    function claim(address _token) external;


    function claimUpTo(address _token, uint256 _endSnapshotIndex) external;


    function distribute(address _token, uint256 _amount) external;

    
    function getAvailableClaims(address _account) external view returns (address[] memory claimableTokens, uint256[] memory claimableAmounts);


    function claimable(address _token, address _account) external view returns (uint256);

    
    function claimableUpTo(address _token, address _account, uint256 _endSnapshotIndex) external view returns (uint256);


    function totalDistribution(address _token) external view returns (uint256);

}// Unlicense
pragma solidity ^0.8.0;


library LibTokenDividendPool {

    struct SnapshotInfo {
        uint256 id;
        uint256 totalDividendAmount;
        uint256 timestamp;
    }

    struct Distribution {
        bool exists;
        uint256 totalDistribution;
        uint256 lastBalance;
        mapping (uint256 => uint256) tokensPerWeek;
        mapping (address => uint256) nonClaimedSnapshotIndex;
        SnapshotInfo[] snapshots;
    }
}// MIT

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
}// MIT
pragma solidity ^0.8.0;

contract AccessRoleCommon {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER");
}// MIT
pragma solidity ^0.8.0;

contract AccessibleCommon is AccessRoleCommon, AccessControl {

    modifier onlyOwner() {

        require(isAdmin(msg.sender), "Accessible: Caller is not an admin");
        _;
    }

    function addAdmin(address account) public virtual onlyOwner {

        grantRole(ADMIN_ROLE, account);
    }

    function removeAdmin(address account) public virtual onlyOwner {

        renounceRole(ADMIN_ROLE, account);
    }

    function transferAdmin(address newAdmin) external virtual onlyOwner {

        require(newAdmin != address(0), "Accessible: zero address");
        require(msg.sender != newAdmin, "Accessible: same admin");

        grantRole(ADMIN_ROLE, newAdmin);
        renounceRole(ADMIN_ROLE, msg.sender);
    }

    function isAdmin(address account) public view virtual returns (bool) {

        return hasRole(ADMIN_ROLE, account);
    }
}// Unlicense
pragma solidity ^0.8.0;


contract TokenDividendPoolStorage {


    bool public pauseProxy;
    bool public migratedL2;

    address public erc20DividendAddress;
    mapping(address => LibTokenDividendPool.Distribution) public distributions;
    address[] public distributedTokens;
    uint256 internal free = 1;
}// Unlicense
pragma solidity >=0.8.0;





contract TokenDividendPool is
    TokenDividendPoolStorage,
    AccessibleCommon,
    ITokenDividendPool
{

    event Claim(address indexed token, uint256 amount, uint256 snapshotId);
    event Distribute(address indexed token, uint256 amount, uint256 snapshotId);

    modifier ifFree {

        require(free == 1, "LockId is already in use");
        free = 0;
        _;
        free = 1;
    }

    function claimBatch(address[] calldata _tokens) external override {

        for (uint i = 0; i < _tokens.length; ++i) {
            claim(_tokens[i]);
        }
    }

    function claim(address _token) public override {

        _claimUpTo(
            _token,
            msg.sender,
            distributions[_token].snapshots.length
        );
    }

    function claimUpTo(address _token, uint256 _endSnapshotId) public override {

        require(claimableUpTo(_token, msg.sender, _endSnapshotId) > 0, "Amount to be claimed is zero");

        (bool found, uint256 snapshotIndex) = _getSnapshotIndexForId(_token, _endSnapshotId);
        require(found, "No such snapshot ID is found");
        uint256 endSnapshotIndex = snapshotIndex + 1;
        _claimUpTo(_token, msg.sender, endSnapshotIndex);
    }

    function distribute(address _token, uint256 _amount)
        external
        override
        ifFree
    {

        require(
            IIERC20Snapshot(erc20DividendAddress).totalSupply() > 0,
            "Total Supply is zero"
        );

        LibTokenDividendPool.Distribution storage distr = distributions[_token];
        IIERC20Snapshot(_token).transferFrom(msg.sender, address(this), _amount);
        if (distr.exists == false) {
            distributedTokens.push(_token);
        }

        uint256 newBalance = IIERC20Snapshot(_token).balanceOf(address(this));
        uint256 increment = newBalance - distr.lastBalance;
        distr.exists = true;
        distr.lastBalance = newBalance;
        distr.totalDistribution = distr.totalDistribution + increment;

        uint256 snapshotId = IIERC20Snapshot(erc20DividendAddress).snapshot();
        distr.snapshots.push(
            LibTokenDividendPool.SnapshotInfo(snapshotId, increment, block.timestamp)
        );
        emit Distribute(_token, _amount, snapshotId);
    }

    function getAvailableClaims(address _account) public view override returns (address[] memory claimableTokens, uint256[] memory claimableAmounts) {

        uint256[] memory amounts = new uint256[](distributedTokens.length);
        uint256 claimableCount = 0;
        for (uint256 i = 0; i < distributedTokens.length; ++i) {
            amounts[i] = claimable(distributedTokens[i], _account);
            if (amounts[i] > 0) {
                claimableCount += 1;
            }
        }

        claimableAmounts = new uint256[](claimableCount);
        claimableTokens = new address[](claimableCount);
        uint256 j = 0;
        for (uint256 i = 0; i < distributedTokens.length; ++i) {
            if (amounts[i] > 0) {
                claimableAmounts[j] = amounts[i];
                claimableTokens[j] = distributedTokens[i];
                j++;
            }
        }
    }

    function claimable(address _token, address _account) public view override returns (uint256) {

        LibTokenDividendPool.Distribution storage distr = distributions[_token];
        uint256 startSnapshotIndex = distr.nonClaimedSnapshotIndex[_account];
        uint256 endSnapshotIndex = distr.snapshots.length;
        return _calculateClaim(
            _token,
            _account,
            startSnapshotIndex,
            endSnapshotIndex
        );
    }

    function claimableUpTo(
        address _token,
        address _account,
        uint256 _endSnapshotId
    ) public view override returns (uint256) {

        (bool found, uint256 snapshotIndex) = _getSnapshotIndexForId(_token, _endSnapshotId);
        require(found, "No such snapshot ID is found");
        uint256 endSnapshotIndex = snapshotIndex + 1;

        LibTokenDividendPool.Distribution storage distr = distributions[_token];
        uint256 startSnapshotIndex = distr.nonClaimedSnapshotIndex[_account];
        return _calculateClaim(
            _token,
            _account,
            startSnapshotIndex,
            endSnapshotIndex
        );
    }


    function totalDistribution(address _token) public view override returns (uint256) {

        LibTokenDividendPool.Distribution storage distr = distributions[_token];
        return distr.totalDistribution;
    }

    function _getSnapshotIndexForId(address _token, uint256 _snapshotId) view internal returns (bool found, uint256 index) {

        LibTokenDividendPool.SnapshotInfo[] storage snapshots = distributions[_token].snapshots;
        if (snapshots.length == 0) {
            return (false, 0);
        }

        index = snapshots.length - 1;
        while (true) {
            if (snapshots[index].id == _snapshotId) {
                return (true, index);
            }

            if (index == 0) break;
            index --;
        }
        return (false, 0);
    }

    function _claimUpTo(address _token, address _account, uint256 _endSnapshotIndex) internal ifFree {

        LibTokenDividendPool.Distribution storage distr = distributions[_token];
        uint256 startSnapshotIndex = distr.nonClaimedSnapshotIndex[_account];
        uint256 amountToClaim = _calculateClaim(
            _token,
            _account,
            startSnapshotIndex,
            _endSnapshotIndex
        );

        require(amountToClaim > 0, "Amount to be claimed is zero");
        IIERC20Snapshot(_token).transfer(msg.sender, amountToClaim);

        distr.nonClaimedSnapshotIndex[_account] = _endSnapshotIndex;
        distr.lastBalance -= amountToClaim;
        emit Claim(_token, amountToClaim, _endSnapshotIndex);
    }

    function _calculateClaim(
        address _token,
        address _account,
        uint256 _startSnapshotIndex,
        uint256 _endSnapshotIndex
    ) internal view returns (uint256) {

        LibTokenDividendPool.Distribution storage distr = distributions[_token];

        uint256 accumulated = 0;
        for (
            uint256 snapshotIndex = _startSnapshotIndex;
            snapshotIndex < _endSnapshotIndex;
            snapshotIndex = snapshotIndex + 1
        ) {
            uint256 snapshotId = distr.snapshots[snapshotIndex].id;
            uint256 totalDividendAmount = distr.snapshots[snapshotIndex].totalDividendAmount;
            accumulated +=  _calculateClaimPerSnapshot(
                                _account,
                                snapshotId,
                                totalDividendAmount
                            );
        }
        return accumulated;
    }

    function _calculateClaimPerSnapshot(
        address _account,
        uint256 _snapshotId,
        uint256 _totalDividendAmount
    ) internal view returns (uint256) {

        uint256 balance = IIERC20Snapshot(erc20DividendAddress).balanceOfAt(_account, _snapshotId);
        if (balance == 0) {
            return 0;
        }

        uint256 supply = IIERC20Snapshot(erc20DividendAddress).totalSupplyAt(_snapshotId);
        if (supply == 0) {
            return 0;
        }
        return _totalDividendAmount * balance / supply;
    }
}