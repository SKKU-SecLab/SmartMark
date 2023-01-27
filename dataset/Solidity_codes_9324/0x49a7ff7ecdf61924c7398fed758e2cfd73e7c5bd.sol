


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.8.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize() internal {

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



pragma solidity ^0.8.0;



contract ExternalStub is Ownable {

    bool private initialized;

    address public ValueHolder;

    address public enterToken; //= DAI_ADDRESS;
    uint256 private PoolValue;

    event LogValueHolderUpdated(address Manager);


    function init(address _enterToken) external {

        require(!initialized, "Initialized");
        initialized = true;
        Ownable.initialize(); // Do not forget this call!
        _init(_enterToken);
    }

    function _init(address _enterToken) internal {

        enterToken = _enterToken;
        ValueHolder = msg.sender;
    }

    function reInit(address _enterToken) external onlyOwner {

        _init(_enterToken);
    }

    modifier onlyValueHolder() {

        require(msg.sender == ValueHolder, "Not Value Holder");
        _;
    }

    function setValueHolder(address _ValueHolder) external onlyOwner {

        ValueHolder = _ValueHolder;
        emit LogValueHolderUpdated(_ValueHolder);
    }

    function addPosition() external pure {

        revert("Stub");
    }

    function exitPosition(uint256) external pure {

        revert("Stub");
    }

    function getTokenStaked() external view returns (uint256) {

        return (PoolValue);
    }


    function getPoolValue(address) external view returns (uint256 totalValue) {

        return (PoolValue);
    }


    function setPoolValue(uint256 _PoolValue) external onlyValueHolder {

        PoolValue = _PoolValue;
    }

    function claimValue() external pure {

        revert("Stub");
    }
}