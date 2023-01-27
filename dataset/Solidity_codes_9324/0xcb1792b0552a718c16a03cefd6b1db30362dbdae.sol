

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


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity 0.5.16;

interface BankConfig {

    function minDebtSize() external view returns (uint256);


    function getInterestRate(uint256 debt, uint256 floating) external view returns (uint256);


    function getReservePoolBps() external view returns (uint256);


    function getKillBps() external view returns (uint256);


    function isGoblin(address goblin) external view returns (bool);


    function acceptDebt(address goblin) external view returns (bool);


    function workFactor(address goblin, uint256 debt) external view returns (uint256);


    function killFactor(address goblin, uint256 debt) external view returns (uint256);

}

contract TripleSlopeModel {

    using SafeMath for uint256;

    function getInterestRate(uint256 debt, uint256 floating) external pure returns (uint256) {

        uint256 total = debt.add(floating);
        uint256 utilization = debt.mul(100e18).div(total);
        if (utilization < 80e18) {
            return utilization.mul(10e16).div(80e18) / 365 days;
        } else if (utilization < 90e18) {
            return uint256(10e16) / 365 days;
        } else if (utilization < 100e18) {
            return (10e16 + utilization.sub(90e18).mul(40e16).div(10e18)) / 365 days;
        } else {
            return uint256(50e16) / 365 days;
        }
    }
}