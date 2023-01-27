

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


pragma solidity 0.5.16;

interface IReferrerBook {

    function affirmReferrer(address user, address referrer) external returns (bool);

    function getUserReferrer(address user) external view returns (address);

    function getUserTopNode(address user) external view returns (address);

    function getUserNormalNode(address user) external view returns (address);

}


pragma solidity 0.5.16;




contract ReferrerBook is IReferrerBook, Ownable {

    using SafeMath for uint256;

    event ReferrerUpdated(
        address indexed user,
        address indexed referrer,
        uint256 timestampSec
    );

    mapping(address => address) public userReferrers;
    mapping(address => address) public userTopNodes;
    mapping(address => address) public userNormalNodes;

    mapping(address => uint256) public topNodes;
    mapping(address => uint256) public normalNodes;

    mapping(address => uint256) public providers;

    address public nodeSetter;

    bool public canUpdateReferrer;
    bool public canMakeupReferrer;

    address constant ZERO_ADDRESS = address(0);

    modifier onlyBookWriter() {

        require(
            providers[msg.sender] != uint256(0) || msg.sender == owner(),
            "Book writer must be owner or provider"
        );
        _;
    }

    modifier onlyNodeSetter() {

        require(msg.sender == nodeSetter, "Node setter wrong");
        _;
    }

    constructor() public {
        canUpdateReferrer = false;
        canMakeupReferrer = true;
        nodeSetter = msg.sender;
    }

    function affirmUserNode(
        address user,
        address referrer,
        mapping(address => uint256) storage nodes,
        mapping(address => address) storage userNodes
    ) internal returns (bool) {

        address node = userNodes[user];

        if (node != ZERO_ADDRESS && nodes[node] != uint256(0)) {
            return false;
        }

        if (nodes[referrer] != uint256(0)) {
            node = referrer;
        }

        if (node == ZERO_ADDRESS && userNodes[referrer] != ZERO_ADDRESS) {
            node = userNodes[referrer];
        }

        if (node != ZERO_ADDRESS) {
            userNodes[user] = node;
            return true;
        }

        return false;
    }

    function affirmReferrer(address user, address referrer)
        external
        onlyBookWriter
        returns (bool)
    {

        require(user != ZERO_ADDRESS, "User address == 0");
        require(referrer != ZERO_ADDRESS, "Referrer address == 0");
        require(user != referrer, "referrer cannot be oneself");

        bool updated = false;
        if (userReferrers[user] == ZERO_ADDRESS || canUpdateReferrer) {
            userReferrers[user] = referrer;
            affirmUserNode(user, referrer, topNodes, userTopNodes);
            affirmUserNode(user, referrer, normalNodes, userNormalNodes);
            emit ReferrerUpdated(user, referrer, now);
            updated = true;
        }

        return updated;
    }

    function getUserReferrer(address user) external view returns (address) {

        return userReferrers[user];
    }

    function getUserTopNode(address user) external view returns (address) {

        address node = userTopNodes[user];
        if (node != ZERO_ADDRESS && topNodes[node] == uint256(0)) {
            return ZERO_ADDRESS;
        }
        return node;
    }

    function getUserNormalNode(address user) external view returns (address) {

        address node = userNormalNodes[user];
        if (node != ZERO_ADDRESS && normalNodes[node] == uint256(0)) {
            return ZERO_ADDRESS;
        }
        return node;
    }

    function addTopNode(address addr) external onlyNodeSetter {

        require(
            topNodes[addr] == uint256(0) && normalNodes[addr] == uint256(0),
            "Node alreay added"
        );

        topNodes[addr] = now;
    }

    function removeTopNode(address addr) external onlyNodeSetter {

        delete topNodes[addr];
    }

    function isTopNode(address addr) external view returns (bool) {

        return topNodes[addr] != uint256(0);
    }

    function addNormalNode(address addr) external onlyNodeSetter {

        require(
            topNodes[addr] == uint256(0) && normalNodes[addr] == uint256(0),
            "Node alreay added"
        );

        normalNodes[addr] = now;
    }

    function removeNormalNode(address addr) external onlyNodeSetter {

        delete normalNodes[addr];
    }

    function isNormalNode(address addr) external view returns (bool) {

        return normalNodes[addr] != uint256(0);
    }

    function setCanUpdateReferrer(bool canUpdate) external onlyOwner {

        canUpdateReferrer = canUpdate;
    }

    function setCanMakeupReferrer(bool canMakeup) external onlyOwner {

        canMakeupReferrer = canMakeup;
    }

    function setNodeSetter(address addr) external onlyOwner {

        nodeSetter = addr;
    }

    function addProvider(address addr) external onlyOwner {

        require(providers[addr] == uint256(0), "Provider alreay added");

        providers[addr] = now;
    }

    function removeProvider(address addr) external onlyOwner {

        delete providers[addr];
    }

    function isProvider(address addr) external view returns (bool) {

        return providers[addr] != uint256(0);
    }

    function makeupReferrer(address referrer) external {

        require(canMakeupReferrer, "cannot makeup referrer now");
        require(referrer != ZERO_ADDRESS, "referrer address == 0");

        address user = msg.sender;

        require(user != referrer, "referrer cannot be oneself");

        require(
            userReferrers[user] == ZERO_ADDRESS,
            "User already as referrer"
        );

        userReferrers[user] = referrer;

        affirmUserNode(user, referrer, topNodes, userTopNodes);
        affirmUserNode(user, referrer, normalNodes, userNormalNodes);

        emit ReferrerUpdated(user, referrer, now);
    }
}