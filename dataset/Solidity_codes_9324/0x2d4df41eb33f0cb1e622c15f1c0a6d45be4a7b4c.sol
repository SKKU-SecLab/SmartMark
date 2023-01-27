pragma solidity ^0.5.16;

interface WstEthInterface {

    function stEthPerToken() external view returns (uint256);

}pragma solidity ^0.5.16;

interface WstEthOracleInterface {

    function getPrice() external view returns (uint256);

}pragma solidity ^0.5.16;


contract WstEthDelayOracle is WstEthOracleInterface {

    address public admin;

    uint256 public lastUpdated;

    address public wstEth;

    uint256 private _candidate;

    uint256 private _price;

    bool private _paused;

    uint256 public constant PERIOD = 1 hours;

    event CandidateUpdated(uint256 oldCandidate, uint256 newCandidate, uint256 timestamp);

    event PriceUpdated(uint256 oldPrice, uint256 newPrice, uint256 timestamp);

    event Paused();

    event Unpaused();


    constructor(address admin_, address wstEth_) public {
        admin = admin_;
        wstEth = wstEth_;
        lastUpdated = getTimestamp();

        uint256 price = WstEthInterface(wstEth).stEthPerToken();
        _price = price;
        _candidate = price;
    }


    function update() external {

        require(!_paused, "paused");
        require(getTimestamp() - lastUpdated > PERIOD, "period not elapsed");

        uint256 price = WstEthInterface(wstEth).stEthPerToken();
        require(price > 0, "invalid price");

        if (_candidate > 0 && _price != _candidate) {
            uint256 oldPrice = _price;
            _price = _candidate;
            emit PriceUpdated(oldPrice, _price, getTimestamp());
        }

        if (_candidate != price) {
            uint256 oldCandidate = _candidate;
            _candidate = price;
            emit CandidateUpdated(oldCandidate, _candidate, getTimestamp());
        }

        lastUpdated = getTimestamp();
    }


    function revokeCandidate() external {

        require(msg.sender == admin, "unauthorized");

        uint256 oldCandidate = _candidate;
        _candidate = 0;
        emit CandidateUpdated(oldCandidate, _candidate, getTimestamp());
    }

    function revokePrice() external {

        require(msg.sender == admin, "unauthorized");

        uint256 oldPrice = _price;
        uint256 oldCandidate = _candidate;
        _price = 0;
        _candidate = 0;
        emit PriceUpdated(oldPrice, 0, getTimestamp());
        emit CandidateUpdated(oldCandidate, 0, getTimestamp());

        _paused = true;
        emit Paused();
    }

    function unpause() external {

        require(msg.sender == admin, "unauthorized");

        uint256 price = WstEthInterface(wstEth).stEthPerToken();
        _price = price;
        _candidate = price;
        emit PriceUpdated(0, _price, getTimestamp());
        emit CandidateUpdated(0, _candidate, getTimestamp());

        _paused = false;
        emit Unpaused();
    }


    function getPrice() external view returns (uint256) {

        return _price;
    }

    function getCandidatePrice() external view returns (uint256) {

        return _candidate;
    }

    function getTimestamp() public view returns (uint256) {

        return block.timestamp;
    }

    function paused() public view returns (bool) {

        return _paused;
    }
}