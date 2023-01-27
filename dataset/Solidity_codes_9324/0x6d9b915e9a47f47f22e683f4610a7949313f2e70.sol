pragma solidity 0.6.10;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.6.0;

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
}// agpl-3.0
pragma solidity 0.6.10;

abstract contract VersionedInitializable {
    uint256 internal lastInitializedRevision = 0;

    modifier initializer() {
        uint256 revision = getRevision();
        require(revision > lastInitializedRevision, "Contract instance has already been initialized");

        lastInitializedRevision = revision;

        _;

    }

    function getRevision() internal pure virtual returns(uint256);


    uint256[50] private ______gap;
}// agpl-3.0
pragma solidity 0.6.10;



contract DigipharmToTerraMigrator is VersionedInitializable {

    using SafeMath for uint256;

    IERC20 public immutable DPH;
    uint256 public constant REVISION = 1;
    
    uint256 public _totalDPHMigrated;

    event DPHMigrated(address indexed sender, bytes32 indexed to, uint256 indexed amount);

    constructor(IERC20 dph) public {
        DPH = dph;
    }

    function initialize() public initializer {

    }

    function migrationStarted() external view returns(bool) {

        return lastInitializedRevision != 0;
    }


    function migrateFromETH(uint256 amount, bytes32 to) external {

        require(lastInitializedRevision != 0, "MIGRATION_NOT_STARTED");

        _totalDPHMigrated = _totalDPHMigrated.add(amount);
        DPH.transferFrom(msg.sender, address(this), amount);
        emit DPHMigrated(msg.sender, to, amount);
    }

    function getRevision() internal pure override returns (uint256) {

        return REVISION;
    }

}