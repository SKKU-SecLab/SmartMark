

pragma solidity 0.7.5;





abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
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

library AddrSet {

    struct Data {
        mapping(address => bool) flags;
    }

    function insert(Data storage self, address value) internal returns (bool) {

        if (self.flags[value]) {
            return false; // already there
        }
        self.flags[value] = true;
        return true;
    }

    function remove(Data storage self, address value) internal returns (bool) {

        if (!self.flags[value]) {
            return false; // not there
        }
        self.flags[value] = false;
        return true;
    }

    function contains(Data storage self, address value)
        internal
        view
        returns (bool)
    {

        return self.flags[value];
    }
}


interface IBaseSecurityToken {

    function attachDocument(
        bytes32 _name,
        string calldata _uri,
        bytes32 _contentHash
    ) external;


    function lookupDocument(bytes32 _name)
        external
        view
        returns (string memory, bytes32);


    function checkTransferAllowed(
        address from,
        address to,
        uint256 value
    ) external view returns (byte);


    function checkTransferFromAllowed(
        address from,
        address to,
        uint256 value
    ) external view returns (byte);


    function checkMintAllowed(address to, uint256 value)
        external
        view
        returns (byte);


    function checkBurnAllowed(address from, uint256 value)
        external
        view
        returns (byte);

}


interface IRegulatorService {

    function check(
        address _token,
        address _spender,
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (byte);

}

contract RegulatorServicePrototype is IRegulatorService, Ownable {

    enum Status {
        Unknown,
        Approved,
        Suspended
    }

    event ProviderAdded(address indexed addr);
    event ProviderRemoved(address indexed addr);
    event AddrApproved(address indexed addr, address indexed by);
    event AddrSuspended(address indexed addr, address indexed by);

    byte private constant DISALLOWED = 0x10;
    byte private constant ALLOWED = 0x11;

    AddrSet.Data private kycProviders;
    mapping(address => Status) public kycStatus;

    constructor() Ownable() {
    }

    function registerProvider(address addr) public onlyOwner {

        require(AddrSet.insert(kycProviders, addr), "already registered");
        emit ProviderAdded(addr);
    }

    function removeProvider(address addr) public onlyOwner {

        require(AddrSet.remove(kycProviders, addr), "not registered");
        emit ProviderRemoved(addr);
    }

    function isProvider(address addr) public view returns (bool) {

        return addr == owner() || AddrSet.contains(kycProviders, addr);
    }

    function getStatus(address addr) public view returns (Status) {

        return kycStatus[addr];
    }

    function approveAddr(address addr) public onlyAuthorized {

        Status status = kycStatus[addr];
        require(status != Status.Approved, "already approved");
        kycStatus[addr] = Status.Approved;
        emit AddrApproved(addr, msg.sender);
    }

    function suspendAddr(address addr) public onlyAuthorized {

        Status status = kycStatus[addr];
        require(status != Status.Suspended, "already suspended");
        kycStatus[addr] = Status.Suspended;
        emit AddrSuspended(addr, msg.sender);
    }

    function check(
        address _token,
        address _spender,
        address _from,
        address _to,
        uint256 /*_amount*/
    )
        external
        override
        view
        returns (byte)
    {

        require(_token != address(0), "token address is empty");
        require(_spender != address(0), "spender address is empty");
        require(_from != address(0) || _to != address(0), "undefined account addresses");

        if (getStatus(_spender) != Status.Approved) {
            return DISALLOWED;
        }

        if (_from != address(0)) {
            Status status = getStatus(_from);
            if (_to == address(0)) {
                if (status != Status.Suspended) {
                    return DISALLOWED;
                }

                return ALLOWED;
            }

            if (status != Status.Approved) {
                return DISALLOWED;
            }
        }

        if (getStatus(_to) != Status.Approved) {
            return DISALLOWED;
        }

        return ALLOWED;
    }

    modifier onlyAuthorized() {

        require(
            msg.sender == owner() || AddrSet.contains(kycProviders, msg.sender),
            "onlyAuthorized can do"
        );
        _;
    }
}