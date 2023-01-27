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
}pragma solidity 0.5.16;

interface StationConfig {

    function minDebtSize() external view returns (uint256);


    function getInterestRate(uint256 debt, uint256 floating) external view returns (uint256);


    function getStarGateBps() external view returns (uint256);


    function getTerminateBps() external view returns (uint256);


    function isOrbit(address orbit) external view returns (bool);


    function acceptDebt(address orbit) external view returns (bool);


    function launcher(address orbit, uint256 debt) external view returns (uint256);


    function terminator(address orbit, uint256 debt) external view returns (uint256);

}pragma solidity 0.5.16;

contract SimpleStationConfig is StationConfig, Ownable {

    struct OrbitConfig {
        bool isOrbit;
        bool acceptDebt;
        uint256 launcher;
        uint256 terminator;
    }

    uint256 public minDebtSize;
    uint256 public interestRate;
    uint256 public getStarGateBps;
    uint256 public getTerminateBps;
    mapping (address => OrbitConfig) public orbits;

    constructor(
        uint256 _minDebtSize,
        uint256 _interestRate,
        uint256 _reserveGateBps,
        uint256 _terminateBps
    ) public {
        setParams(_minDebtSize, _interestRate, _reserveGateBps, _terminateBps);
    }

    function setParams(
        uint256 _minDebtSize,
        uint256 _interestRate,
        uint256 _reserveGateBps,
        uint256 _terminateBps
    ) public onlyOwner {

        minDebtSize = _minDebtSize;
        interestRate = _interestRate;
        getStarGateBps = _reserveGateBps;
        getTerminateBps = _terminateBps;
    }

    function setOrbit(
        address orbit,
        bool _isOrbit,
        bool _acceptDebt,
        uint256 _launcher,
        uint256 _terminator
    ) public onlyOwner {

        orbits[orbit] = OrbitConfig({
            isOrbit: _isOrbit,
            acceptDebt: _acceptDebt,
            launcher: _launcher,
            terminator: _terminator
        });
    }

    function getInterestRate(uint256 /* debt */, uint256 /* floating */) external view returns (uint256) {

        return interestRate;
    }

    function isOrbit(address orbit) external view returns (bool) {

        return orbits[orbit].isOrbit;
    }

    function acceptDebt(address orbit) external view returns (bool) {

        require(orbits[orbit].isOrbit, "!orbit");
        return orbits[orbit].acceptDebt;
    }

    function launcher(address orbit, uint256 /* debt */) external view returns (uint256) {

        require(orbits[orbit].isOrbit, "!orbit");
        return orbits[orbit].launcher;
    }

    function terminator(address orbit, uint256 /* debt */) external view returns (uint256) {

        require(orbits[orbit].isOrbit, "!orbit");
        return orbits[orbit].terminator;
    }
}