

pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
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

interface PriceOracle {

    function getPrice(address token0, address token1)
        external view
        returns (uint256 price, uint256 lastUpdate);

}


pragma solidity 0.5.16;



contract SimplePriceOracle is Ownable, PriceOracle {

    event PriceUpdate(address indexed token0, address indexed token1, uint256 price);

    struct PriceData {
        uint192 price;
        uint64 lastUpdate;
    }

    mapping (address => mapping (address => PriceData)) public store;

    function setPrices(
        address[] calldata token0s,
        address[] calldata token1s,
        uint256[] calldata prices
    )
        external
        onlyOwner
    {

        uint256 len = token0s.length;
        require(token1s.length == len, "bad token1s length");
        require(prices.length == len, "bad prices length");
        for (uint256 idx = 0; idx < len; idx++) {
            address token0 = token0s[idx];
            address token1 = token1s[idx];
            uint256 price = prices[idx];
            store[token0][token1] = PriceData({
                price: uint192(price),
                lastUpdate: uint64(now)
            });
            emit PriceUpdate(token0, token1, price);
        }
    }

    function getPrice(address token0, address token1)
        external view
        returns (uint256 price, uint256 lastUpdate)
    {

        PriceData memory data = store[token0][token1];
        price = uint256(data.price);
        lastUpdate = uint256(data.lastUpdate);
        require(price != 0 && lastUpdate != 0, "bad price data");
        return (price, lastUpdate);
    }
}