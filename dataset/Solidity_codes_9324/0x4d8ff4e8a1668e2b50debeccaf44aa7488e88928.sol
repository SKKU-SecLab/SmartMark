

pragma solidity ^0.8.0;

interface ILookRevTree {

    function addLeafToOpenBranch(uint256 genesisBranch, uint256 tokenID) external returns (uint256);

    function addLeavesToOpenBranches(uint256[] calldata tokenIDs) external returns (uint256);

    function getTokenPubID(uint256 tokenID) external view returns (string memory);

    function updateNFTTokenPubID(uint256 tokenID, string calldata pubID) external;

}

interface LookRevLeafNFT {

    function getNFTTokenRecipient(uint256 tokenID) external view returns (address);

}

interface INextTree {

    function migrateTokens(uint256 branch, uint256[] calldata tokenIDs, address leafNFT) external;

}



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a && c >= b, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0 || b == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
                
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


library Strings {


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
}


contract LookRevTree is
    ILookRevTree
    {

    struct GenesisBranch {
        uint256 id;
        string name;
        uint256 maxLevel;
        uint256 openBranch;
        uint256 leavesCount;
        uint256 baseValue;
        uint8 state;
        uint256 harvestTime;
        string uri;
        uint256 createdAt;
    }

    struct Branch {
        uint256 id;
        uint256 level;
        uint256 genesisBranch;
        uint256 availableLeaves;
        uint256 createdAt;
    }
    
    struct Leaf {
        uint256 id;
        uint256 branchId;
        uint256 tokenID;
        uint256 createdAt;
    }
        
    mapping(uint256 => GenesisBranch) public genesisBranches;
    mapping(uint256 => Branch) public branches;
    mapping(uint256 => mapping(uint256 => uint256[])) public branchesAtLevel;

    mapping(uint256 => Leaf) public leaves;
    mapping(uint256 => uint256) public tokenIDToLeafID;

    mapping(uint256 => string) private tokenIDToPubID;
        
    mapping(uint256 => mapping(address => bool)) public operators;
    
    uint256 public nextGenesisBranchId = 1;
    uint256 public nextBranchId = 1;
    uint256 public nextLeafId = 1;
    uint256 public averageLeafCost = 5 * 10 ** 16;
    uint256 public treeMaxLevel = 1;
    uint256 public START_TIME;
    
    uint256 constant public MAX_SUPPLY = 10;

    uint256 public MIN_BASE_VALUE = 5 * 10 ** 16;
    uint256 public BRANCH_UNIT = 2;
        
    uint256 constant public FIRST_HARVEST_TIME = (86400 * 100);

    uint256 constant public HARVEST_START_COUNT = 1000;

    string public baseURI = "https://lookrev.com/branch/";
    
    uint8 public treeStatus;
    string public statusInfo;

    address public nextTree;
    address public lrLeaf;
    address[] private leafVersions;

    address private admin;
    address private ceo;
    address private cfo;

    event GenesisBranchCreated(
        uint256 indexed id,
        string indexed name,
        uint256 indexed firstAvailableBranch,
        uint256 count
    );
    
    event BranchCreated(
        uint256 indexed id,
        uint256 indexed genesisBranch,
        uint256 indexed level
    );
        
    event AddedLeaves(
        uint256 indexed branchID,
        uint256 indexed leafID,
        uint256 indexed tokenID,
        uint256 count
    );
        
    event HarvestTimeScheduled(
        uint256 indexed genesisBranchID,
        uint256 indexed openBranchID,
        uint256 leavesCount,
        uint256 indexed harvestTime
    );

    event OperatorUpdated(
        uint256 indexed branchID,
        address indexed operator,
        bool indexed approved
    );
    
    event VersionUpdated(
        string indexed str,
        address indexed newaddress
    );

    event RoleUpdated(
        string indexed str,
        address indexed newaddress
    );

    constructor() {
        admin = msg.sender;
        treeStatus = 0;
    }

    function createGenesisBranch(string[] calldata _names) public {

        require(msg.sender == admin, "LookRevTree: Not authorized");
        require(treeStatus == 0, "LookRevTree: Tree is currently not OPEN.");
        for (uint256 i = 0; i < _names.length; i++) {
            string memory _n = _names[i];
            genesisBranches[nextGenesisBranchId] = GenesisBranch(nextGenesisBranchId, _n, 1, nextBranchId, 0, MIN_BASE_VALUE, 0, 0, string(abi.encodePacked(baseURI, Strings.toString(nextGenesisBranchId))), block.timestamp);
            branches[nextBranchId] = Branch(nextBranchId, 1, nextGenesisBranchId, MAX_SUPPLY, block.timestamp);
            branchesAtLevel[nextGenesisBranchId][1].push(nextBranchId);
            nextGenesisBranchId += 1;
            nextBranchId += 1;
        }
        emit GenesisBranchCreated(nextGenesisBranchId - 1, _names[0], nextBranchId - 1, _names.length);
    }
    
    function _createBranch(uint256 branch) internal {

        require(genesisBranches[branch].state == 0, "LookRevTree: Branch is not OPEN");
        uint256 _maxLevel = genesisBranches[branch].maxLevel;
        uint256 _count = branchesAtLevel[branch][_maxLevel].length;
        if (_count < _maxLevel * BRANCH_UNIT) {
            _createNewBranch(branch, _maxLevel);
        } else {
            genesisBranches[branch].maxLevel += 1;
            _createNewBranch(branch, _maxLevel + 1);
        }
    }
    
    function _createNewBranch(uint256 branch, uint256 level) internal {

        require(treeStatus == 0, "LookRevTree: Tree is currently not OPEN.");
        branches[nextBranchId] = Branch(nextBranchId, level, branch, MAX_SUPPLY, block.timestamp);
        branchesAtLevel[branch][level].push(nextBranchId);

        genesisBranches[branch].baseValue = genesisBranches[branch].baseValue * 102 / 100;
        emit BranchCreated(nextBranchId, branch, level);
        nextBranchId += 1;
        if (level > treeMaxLevel) {
            treeMaxLevel = level;
        }
    }
        
    function _getAverageLeafCost() internal returns (uint256) {

        if (nextGenesisBranchId < 3) {
            averageLeafCost = genesisBranches[1].baseValue;
            return averageLeafCost;
        }
        uint256 _sum = 0;
        for (uint256 i = 1; i < nextGenesisBranchId; i++) {
            _sum = SafeMath.add(_sum, genesisBranches[i].baseValue);
        }
        averageLeafCost = SafeMath.div(_sum, nextGenesisBranchId - 1);
        return averageLeafCost;
    }

    function addLeafToOpenBranch(uint256 genesisBranch, uint256 tokenID) external override returns (uint256) {

        require(msg.sender == admin || msg.sender == lrLeaf, "LookRevTree: Not authorized");
        _addLeafToOpenBranch(genesisBranch, tokenID);
        return _getAverageLeafCost();
    }

    function _addLeafToOpenBranch(uint256 genesisBranch, uint256 tokenID) internal {

        require(genesisBranch > 0, "LookRevTree: Branch index is out of range");
        if (genesisBranch >= nextGenesisBranchId) {
            genesisBranch = nextGenesisBranchId - 1;
        }
        require(genesisBranches[genesisBranch].state == 0, "LookRevTree: Branch is not OPEN");
        uint256 _b = genesisBranches[genesisBranch].openBranch;
        if (branches[_b].availableLeaves < 1) {
            _updateBranchStatus(_b);
        }
        _addLeaf(genesisBranches[genesisBranch].openBranch, tokenID);
        emit AddedLeaves(genesisBranch, nextLeafId - 1, tokenID, 1);
    }

    function _getMinLeavesBranch() internal view returns (uint256) {

        uint256 minCount = 10000;
        uint256 b = nextBranchId - 1;
        for (uint256 i = 1; i < nextGenesisBranchId; i++) {
            if (genesisBranches[i].state == 0 && genesisBranches[i].leavesCount < minCount) {
                minCount = genesisBranches[i].leavesCount;
                b = genesisBranches[i].openBranch;
            }
        }
        return b;
    }

    function addLeavesToOpenBranches(uint256[] calldata tokenIDs) external override returns (uint256) {

        require(msg.sender == admin || msg.sender == lrLeaf, "LookRevTree: Not authorized.");
        require(tokenIDs.length > 0, "LookRevTree: tokenIDs can not be empty");
        require(tokenIDToLeafID[tokenIDs[0]] == 0, "LookRevTree: TokenID already registered");
        
        uint256 _branchid = _getMinLeavesBranch();
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            if (branches[_branchid].availableLeaves < 1) {
                _updateBranchStatus(_branchid);
                _branchid = _getMinLeavesBranch();
            }
            _addLeaf(_branchid, tokenIDs[i]);
        }
        emit AddedLeaves(_branchid, nextLeafId - 1, tokenIDs[0], tokenIDs.length);
        return _getAverageLeafCost();
    }
    
    function _addLeaf(uint256 branch, uint256 tokenID) internal {

        require(treeStatus == 0, "LookRevTree: Tree is currently not OPEN.");
        require(branch < nextBranchId && branch > 0, "LookRevTree: Branch index is out of range");
        require(tokenIDToLeafID[tokenID] == 0, "LookRevTree: TokenID already registered");
        tokenIDToLeafID[tokenID] = nextLeafId;
        
        leaves[nextLeafId] = Leaf(nextLeafId, branch, tokenID, block.timestamp);
        genesisBranches[branches[branch].genesisBranch].leavesCount += 1;
        branches[branch].availableLeaves -= 1;
        nextLeafId += 1;
    }
        
    function _updateBranchStatus(uint256 subbranch) internal {

        uint256 _g = branches[subbranch].genesisBranch;
        if (genesisBranches[_g].leavesCount >= HARVEST_START_COUNT) {
            _setFirstHarvestTime(_g);
        }
        _createBranch(_g);
        genesisBranches[_g].openBranch = nextBranchId - 1;
    }

        
    function getTokenPubID(uint256 tokenID) external view override returns (string memory) {

        address _owner = LookRevLeafNFT(lrLeaf).getNFTTokenRecipient(tokenID);
        require(_owner == msg.sender || msg.sender == admin, "LookRevTree: Require owner of the leafNFT");
        return tokenIDToPubID[tokenID];
    }
    
    function updateNFTTokenPubID(uint256 tokenID, string calldata pubID) external override {

        require(tokenIDToLeafID[tokenID] > 0, "LookRevTree: tokenID not found");
        require(bytes(pubID).length > 0, "LookRevTree: pubID can not be empty");
        address _owner = LookRevLeafNFT(lrLeaf).getNFTTokenRecipient(tokenID);
        require(_owner == msg.sender || msg.sender == admin, "LookRevTree: Require owner of the leafNFT");
        tokenIDToPubID[tokenID] = pubID;
    }
        
    function updateNFTTokenPubIDs(uint256[] calldata tokenIDs, string[] calldata pubIDs) public {

        require(msg.sender == admin, "LookRevTree: Require admin");
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            tokenIDToPubID[tokenIDs[i]] = pubIDs[i];
        }
    }

        
    function _setFirstHarvestTime(uint256 branch) internal {

        if (genesisBranches[branch].harvestTime != 0) {
            return;
        }
        genesisBranches[branch].harvestTime = block.timestamp + FIRST_HARVEST_TIME;
        emit HarvestTimeScheduled(branch, genesisBranches[branch].openBranch, genesisBranches[branch].leavesCount, genesisBranches[branch].harvestTime);
    }
    
    function updateBranchInfo(uint256 branch, string calldata newName, string calldata newURI, uint8 newState, uint256 timeToHarvest) public {

        require(msg.sender == admin || operators[branch][msg.sender] == true, "LookRevTree: Not authorized");
        require(branch < nextGenesisBranchId && branch > 0, "LookRevTree: Branch index is out of range");
        genesisBranches[branch].name = newName;
        genesisBranches[branch].uri = newURI;
        genesisBranches[branch].state = newState;
        genesisBranches[branch].harvestTime = block.timestamp + timeToHarvest;
    }

    
    function updateTreeStatus(string calldata str, uint8 _to) public {

        require(msg.sender == admin, "LookRevTree: Not authorized");
        statusInfo = str;
        treeStatus = _to;
    }
    
    function updateOperator(uint256[] calldata branch, address operator, bool approved) public {

        require(msg.sender == admin, "LookRevTree: Not authorized");
        require(operator != address(0), "LookRevTree: operator needs valid address");
        for (uint256 i = 0; i < branch.length; i++) {
            operators[branch[i]][operator] = approved;
        }
        emit OperatorUpdated(branch[0], operator, approved);
    }

    function adjustBaseValue(uint256 value) public {

        require(msg.sender == admin, "LookRevTree: Not authorized");
        require(value > MIN_BASE_VALUE, "LookRevTree: Can only increase base value");
        require(block.timestamp >= START_TIME + 100 days, "LooksCoin: Wait for 100 days after last update");
        MIN_BASE_VALUE = value;
        START_TIME = block.timestamp;
    }

    function updateLeafVersion(address _leaf) public {

        require(msg.sender == admin, "LookRevTree: Not authorized");
        lrLeaf = _leaf;
        leafVersions.push(_leaf);
        emit VersionUpdated("Leaf Version Updated", _leaf);
    }
    
    function getLeafVersions() public view returns (address[] memory) {

        require(msg.sender == admin, "LookRevTree: Not authorized");
        return leafVersions;
    }
    
    function updateNextContract(address _new) public {

        require(msg.sender == admin, "LookRevTree: Not authorized");
        nextTree = _new;
    }

    function updateRole(uint256 _role, address _new) public {

        require(msg.sender == admin || msg.sender == ceo || msg.sender == cfo, "LookRevTree: Not authorized");
        if (_role == 1) {
            admin = _new;
            emit RoleUpdated("admin", _new);
        } else if (_role == 2) {
            ceo = _new;
            emit RoleUpdated("ceo", _new);
        } else if (_role == 3) {
            cfo = _new;
            emit RoleUpdated("cfo", _new);
        }
    }

    function getRoles() public view returns (address[] memory) {

        require(msg.sender == admin || msg.sender == ceo || msg.sender == cfo, "LookRevTree: Not authorized");
        address[] memory _roles = new address[](3);
        _roles[0] = admin;
        _roles[1] = ceo;
        _roles[2] = cfo;
        return _roles;
    }

    function removeLeaf(uint256 leafID) public {

        require(msg.sender == admin, "LookRevTree: Not authorized");
        _removeLeaf(leafID);
    }

    function _removeLeaf(uint256 leafID) internal {

        if (leafID <= 0 || leafID >= nextLeafId) {
            return;
        }
        uint256 _tokenID = leaves[leafID].tokenID;
        if (_tokenID < 1) {
            return;
        }
        tokenIDToLeafID[_tokenID] = 0;
        delete leaves[leafID];
    }
    
    function migrateNFTTokens(uint256 newBranchID, uint256[] calldata tokenIDs) external {

        require(msg.sender == admin, "LookRevTree: Not authorized");
        require(nextTree != address(0), "LookRevTree: Need to set nextTree");
        
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            if (tokenIDs[i] > 0) {
                _removeLeaf(tokenIDToLeafID[tokenIDs[i]]);
            }
        }
        INextTree(nextTree).migrateTokens(newBranchID, tokenIDs, lrLeaf);
    }
}