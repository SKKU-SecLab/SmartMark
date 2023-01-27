




contract Storage {

    uint256[] marketingLevels;

    address[] accountList;

    mapping(address => address) referrals;

    mapping(address => bool) whitelistRoots;

    function getTotalAccount() public view returns(uint256) {

        return accountList.length;
    }

    function getAccountList() public view returns(address[] memory) {

        return accountList;
    }

    function getReferenceBy(address _child) public view returns(address) {

        return referrals[_child];
    }

    function getMarketingMaxLevel() public view returns(uint256) {

        return marketingLevels.length;
    }

    function getMarketingLevelValue(uint256 _level) public view returns(uint256) {

        return marketingLevels[_level];
    }

    function getReferenceParent(address _child, uint256 _level) public view returns(address) {

        uint i;
        address pointer = _child;

        while(i < marketingLevels.length) {
            pointer = referrals[pointer];

            if (i == _level) {
                return pointer;
            }

            i++;
        }

        return address(0);
    }

    function getWhiteListRoot(address _root) public view returns(bool) {

        return whitelistRoots[_root];
    }
}





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




pragma solidity 0.6.12;



contract Controller is Storage, Ownable {

    event LinkCreated(address indexed addr, address indexed refer);

    constructor() public {
        marketingLevels.push(25e6); // 25%
        marketingLevels.push(20e6);
        marketingLevels.push(15e6);
        marketingLevels.push(10e6);
        marketingLevels.push(10e6);
        marketingLevels.push(10e6);
        marketingLevels.push(5e6);
        marketingLevels.push(5e6);
    }

    function register(address _refer) public {

        require(msg.sender != _refer, "ERROR: address cannot refer itself");
        require(referrals[msg.sender] == address(0), "ERROR: already set refer address");

        if (_refer != owner() && !getWhiteListRoot(_refer)) {
            require(referrals[_refer] != address(0), "ERROR: invalid refer address");
        }

        referrals[msg.sender] = _refer;

        emit LinkCreated(msg.sender, _refer);
    }

    function updateMarketingLevelValue(uint256 _level, uint256 _value) public onlyOwner {

        marketingLevels[_level] = _value;
    }

    function addWhiteListRoot(address _root) public onlyOwner {

        whitelistRoots[_root] = true;
    }
}