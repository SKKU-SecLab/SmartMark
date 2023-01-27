


pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}


pragma solidity ^0.6.0;

interface IRegistry {

    function handlers(address) external view returns (bytes32);

    function callers(address) external view returns (bytes32);

    function bannedAgents(address) external view returns (uint256);

    function fHalt() external view returns (bool);

    function isValidHandler(address handler) external view returns (bool);

    function isValidCaller(address handler) external view returns (bool);

}


pragma solidity ^0.6.0;



contract Registry is IRegistry, Ownable {

    mapping(address => bytes32) public override handlers;
    mapping(address => bytes32) public override callers;
    mapping(address => uint256) public override bannedAgents;
    bool public override fHalt;

    bytes32 public constant DEPRECATED = bytes10(0x64657072656361746564);

    event Registered(address indexed registration, bytes32 info);
    event Unregistered(address indexed registration);
    event CallerRegistered(address indexed registration, bytes32 info);
    event CallerUnregistered(address indexed registration);
    event Banned(address indexed agent);
    event Unbanned(address indexed agent);
    event Halted();
    event Unhalted();

    modifier isNotHalted() {

        require(fHalt == false, "Halted");
        _;
    }

    modifier isHalted() {

        require(fHalt, "Not halted");
        _;
    }

    modifier isNotBanned(address agent) {

        require(bannedAgents[agent] == 0, "Banned");
        _;
    }

    modifier isBanned(address agent) {

        require(bannedAgents[agent] != 0, "Not banned");
        _;
    }

    function register(address registration, bytes32 info) external onlyOwner {

        require(registration != address(0), "zero address");
        require(info != DEPRECATED, "unregistered info");
        require(handlers[registration] != DEPRECATED, "unregistered");
        handlers[registration] = info;
        emit Registered(registration, info);
    }

    function unregister(address registration) external onlyOwner {

        require(registration != address(0), "zero address");
        require(handlers[registration] != bytes32(0), "no registration");
        require(handlers[registration] != DEPRECATED, "unregistered");
        handlers[registration] = DEPRECATED;
        emit Unregistered(registration);
    }

    function registerCaller(address registration, bytes32 info)
        external
        onlyOwner
    {

        require(registration != address(0), "zero address");
        require(info != DEPRECATED, "unregistered info");
        require(callers[registration] != DEPRECATED, "unregistered");
        callers[registration] = info;
        emit CallerRegistered(registration, info);
    }

    function unregisterCaller(address registration) external onlyOwner {

        require(registration != address(0), "zero address");
        require(callers[registration] != bytes32(0), "no registration");
        require(callers[registration] != DEPRECATED, "unregistered");
        callers[registration] = DEPRECATED;
        emit CallerUnregistered(registration);
    }

    function ban(address agent) external isNotBanned(agent) onlyOwner {

        bannedAgents[agent] = 1;
        emit Banned(agent);
    }

    function unban(address agent) external isBanned(agent) onlyOwner {

        bannedAgents[agent] = 0;
        emit Unbanned(agent);
    }

    function isValidHandler(address handler)
        external
        view
        override
        returns (bool)
    {

        return handlers[handler] != 0 && handlers[handler] != DEPRECATED;
    }

    function isValidCaller(address caller)
        external
        view
        override
        returns (bool)
    {

        return callers[caller] != 0 && callers[caller] != DEPRECATED;
    }

    function halt() external isNotHalted onlyOwner {

        fHalt = true;
        emit Halted();
    }

    function unhalt() external isHalted onlyOwner {

        fHalt = false;
        emit Unhalted();
    }
}