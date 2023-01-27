
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}//MIT
pragma solidity 0.7.5;


contract Royalties is Ownable {

    using SafeMath for uint256;

    mapping(address => uint256) internal royalties_;
    mapping(address => address) internal addressForwarding_;

    event DepositReceived(
        address indexed depositor,
        address indexed receiver,
        uint256 amount
    );

    event Withdraw(address indexed withdrawer, uint256 amount);

    event AddressUpdated(
        address indexed originalCreatorAddress,
        address indexed oldAddress,
        address indexed newAddress
    );

    constructor() Ownable() {}

    function getBalance(address _user) external view returns (uint256) {

        if (addressForwarding_[_user] != address(0)) {
            return royalties_[addressForwarding_[_user]];
        } else {
            return royalties_[_user];
        }
    }

    function init() external view returns (bool) {

        return true;
    }

    function deposit(address _to, uint256 _amount) external payable {

        require(msg.value >= _amount, "ROY: Fatal: Value mismatch");
        if (addressForwarding_[_to] != address(0)) {
            royalties_[addressForwarding_[_to]] = royalties_[
                addressForwarding_[_to]
            ]
            .add(_amount);
        } else {
            royalties_[_to] = royalties_[_to].add(_amount);
        }

        emit DepositReceived(msg.sender, _to, _amount);
    }

    function withdraw(uint256 _amount) external {

        require(royalties_[msg.sender] >= _amount, "Amount more than balance");
        royalties_[msg.sender] = royalties_[msg.sender].sub(_amount);
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed.");

        emit Withdraw(msg.sender, _amount);
    }

    function withdrawSystem(uint256 _amount) external onlyOwner() {

        require(royalties_[address(0)] >= _amount, "Amount more than balance");
        royalties_[address(0)] = royalties_[address(0)].sub(_amount);
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed.");

        emit Withdraw(msg.sender, _amount);
    }

    function updateAddress(
        address _originalCreatorAddress,
        address _oldAddress,
        address _newAddress
    ) external onlyOwner() {

        uint256 existingRoyalties = royalties_[_newAddress];
        if (_oldAddress == address(0)) {
            addressForwarding_[_originalCreatorAddress] = _newAddress;
            royalties_[_newAddress] = royalties_[_originalCreatorAddress];
            if (existingRoyalties != 0) {
                royalties_[_newAddress] = royalties_[_newAddress].add(
                    existingRoyalties
                );
            }
            delete royalties_[_originalCreatorAddress];
        } else {
            addressForwarding_[_originalCreatorAddress] = _newAddress;
            addressForwarding_[_oldAddress] = _newAddress;
            royalties_[_newAddress] = royalties_[_oldAddress];
            if (existingRoyalties != 0) {
                royalties_[_newAddress] = royalties_[_newAddress].add(
                    existingRoyalties
                );
            }
            delete royalties_[_oldAddress];
        }

        emit AddressUpdated(_originalCreatorAddress, _oldAddress, _newAddress);
    }
}