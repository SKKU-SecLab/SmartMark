
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

interface IInvestorRegistry {


    function addVerified(address addr, bytes32 hash) external;


    function updateVerified(address addr, bytes32 hash) external;


    function isVerified(address addr) external view returns (bool);



    function hasHash(address addr, bytes32 hash) external view returns (bool);


    function isSuperseded(address addr) external view returns (bool);


    function getCurrentFor(address addr) external view returns (address);


}

contract InvestorRegistry is IInvestorRegistry, Ownable {


    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    event VerifiedAddressAdded(
        address indexed addr,
        bytes32 hash,
        address indexed sender
    );

    event VerifiedAddressRemoved(address indexed addr, address indexed sender);

    event VerifiedAddressUpdated(
        address indexed addr,
        bytes32 oldHash,
        bytes32 hash,
        address indexed sender
    );

    event VerifiedAddressSuperseded(
        address indexed original,
        address indexed replacement,
        address indexed sender
    );

    mapping(address => bytes32) private verified;
    mapping(address => address) private cancellations;

    modifier isVerifiedAddress(address addr) {

        require(verified[addr] != ZERO_BYTES, 'not verified');
        _;
    }

    modifier isNotCancelledAddress(address addr) {

        require(cancellations[addr] == ZERO_ADDRESS, 'is cancelled');
        _;
    }

    function addVerified(address addr, bytes32 hash)
        public
        onlyOwner
        isNotCancelledAddress(addr)
    {

        require(addr != ZERO_ADDRESS, 'address is zero');
        require(hash != ZERO_BYTES, 'no hash provided');
        require(verified[addr] == ZERO_BYTES, 'address already present');
        verified[addr] = hash;
        emit VerifiedAddressAdded(addr, hash, msg.sender);
    }

    function removeVerified(address addr)
        public
        onlyOwner
    {

        if (verified[addr] != ZERO_BYTES) {
            verified[addr] = ZERO_BYTES;
            emit VerifiedAddressRemoved(addr, msg.sender);
        }
    }

    function updateVerified(address addr, bytes32 hash)
        public
        onlyOwner
        isVerifiedAddress(addr)
    {

        require(hash != ZERO_BYTES, 'no hash provided');
        bytes32 oldHash = verified[addr];
        if (oldHash != hash) {
            verified[addr] = hash;
            emit VerifiedAddressUpdated(addr, oldHash, hash, msg.sender);
        }
    }

    function isVerified(address addr)
        public
        view
        returns (bool)
    {

        return verified[addr] != ZERO_BYTES;
    }

    function hasHash(address addr, bytes32 hash)
        public
        view
        returns (bool)
    {

        if (addr == ZERO_ADDRESS) {
            return false;
        }
        return verified[addr] == hash;
    }

    function isSuperseded(address addr)
        public
        view
        onlyOwner
        returns (bool)
    {

        return cancellations[addr] != ZERO_ADDRESS;
    }

    function getCurrentFor(address addr)
        public
        view
        onlyOwner
        returns (address)
    {

        return findCurrentFor(addr);
    }

    function findCurrentFor(address addr)
        internal
        view
        returns (address)
    {

        address candidate = cancellations[addr];
        if (candidate == ZERO_ADDRESS) {
            return addr;
        }
        return findCurrentFor(candidate);
    }

}