


pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

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


pragma solidity 0.6.6;

interface PriceOracleInterface {

    function isWorking() external returns (bool);


    function latestId() external returns (uint256);


    function latestPrice() external returns (uint256);


    function latestTimestamp() external returns (uint256);


    function getPrice(uint256 id) external returns (uint256);


    function getTimestamp(uint256 id) external returns (uint256);

}


pragma solidity 0.6.6;




contract TrustedPriceOracle is Ownable, PriceOracleInterface {

    using SafeMath for uint256;

    uint256 private constant SECONDS_IN_DAY = 60 * 60 * 24;
    uint256 private _latestId;

    struct Record {
        uint128 price;
        uint128 timestamp;
    }

    mapping(uint256 => Record) private records;

    event PriceRegistered(
        uint256 indexed id,
        uint128 timestamp,
        uint128 price
    );

    modifier validId(uint256 id) {

        require(id != 0 && id <= _latestId, "invalid id");
        _;
    }

    modifier hasRecord() {

        require(_latestId != 0, "no records found");
        _;
    }

    function registerPrice(uint128 price) external onlyOwner {

        uint256 latestId = _latestId;
        require(
            now > records[latestId].timestamp,
            "multiple registration in one block"
        );
        require(price != 0, "0 is invalid as price");
        uint256 newId = latestId + 1;
        uint128 timestamp = uint128(now);
        _latestId = newId;
        records[newId] = Record(price, timestamp);
        emit PriceRegistered(newId, timestamp, price);
    }


    function isWorking() external override returns (bool) {

        return now.sub(_latestTimestamp()) < SECONDS_IN_DAY;
    }

    function latestId() external override hasRecord returns (uint256) {

        return _latestId;
    }

    function latestPrice() external override hasRecord returns (uint256) {

        return records[_latestId].price;
    }

    function latestTimestamp() external override returns (uint256) {

        return _latestTimestamp();
    }

    function getPrice(uint256 id)
        external
        override
        validId(id)
        returns (uint256)
    {

        return records[id].price;
    }

    function getTimestamp(uint256 id)
        external
        override
        validId(id)
        returns (uint256)
    {

        return records[id].timestamp;
    }

    function _latestTimestamp() private view hasRecord returns (uint256) {

        return records[_latestId].timestamp;
    }
}