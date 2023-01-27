pragma solidity >=0.4.25 <0.6.0;

contract ERC20 {

    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}pragma solidity >=0.4.25 <0.6.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
pragma solidity >=0.4.25 <0.6.0;


contract HolderLockStrategy {

    using SafeMath for uint256;
    string public name;
    uint256 private _lockedBalance;
    address private _lockedAddress;
    address private _admin;
    uint[] private _unlockDates;
    uint[] private _unlockPercents;
    bool private _initialized;
    address private _token;
    uint private _withdrawed;

    function init(string memory title, uint[] memory unlockDates,
                uint[] memory unlockPercents, address lockedAddress, uint lockedBalance, address token) internal {

        require(!_initialized);
        _initialized = true;
        name = title;
        require(unlockDates.length == unlockPercents.length);
        
        for (uint i = 0; i < unlockPercents.length; ++i) {
            _unlockDates.push(unlockDates[i]);
            _unlockPercents.push(unlockPercents[i]);
        }
        
        _lockedAddress = lockedAddress;
        _lockedBalance = lockedBalance;
        _token = token;

        _admin = msg.sender;
    }

    function getDate() private
        view
        returns (uint256) {

        return now;
    }

    function calculatePhase() public view returns (uint256) {

        uint idx = 0;
        uint today = getDate();
        for (; idx < _unlockDates.length; ++idx) {
            if (today < _unlockDates[idx])  break;
        } 

        return idx;
    }

    function calculateUnlockedAmount() public view returns (uint256) {

        uint idx = calculatePhase();

        if (idx == 0) {
            return 0;
        } else if (idx >= _unlockDates.length) {
            return _lockedBalance;
        } else {
            uint unlock = _unlockPercents[idx - 1];
            if (unlock > 100) 
                unlock = 100;
            return _lockedBalance.mul(unlock).div(100);
        }
    }

    function withdraw(address _to) public returns (bool) {

        require(msg.sender == _admin);
        uint256 available = availableBalance();
        if (available > 0) {
            ERC20 token = ERC20(_token);
            require(token.transfer(_to, available));
            _withdrawed = _withdrawed.add(available);
            return true;
        } else {
            return false;
        }
    }

    function availableBalance() public
        view 
        returns (uint256) {

        uint unlockable = calculateUnlockedAmount();
        return unlockable.sub(_withdrawed);
    }

    function checkBalance(address _holder) public view returns (uint256) {

        ERC20 token = ERC20(_token);
        return token.balanceOf(_holder);
    }
}pragma solidity >=0.4.25 <0.6.0;


contract SwapTeamMemberLockContract is HolderLockStrategy {

    constructor() public {
        uint[] memory unlockDate = new uint[](6);
        unlockDate[0] = uint(1558828800);     // 2019-5-26 08:00:00 AM 北京时间
        unlockDate[1] = uint(1588262400);     // 2020-5-1 12:00:00 AM 北京时间
        unlockDate[2] = uint(1604160000);     // 2020-11-1 12:00:00 AM 北京时间
        unlockDate[3] = uint(1619798400);     // 2021-5-1 12:00:00 AM 北京时间
        unlockDate[4] = uint(1635696000);     // 2021-11-1 12:00:00 AM 北京时间
        unlockDate[5] = uint(1651334400);     // 2022-5-1 12:00:00 AM 北京时间

        uint[] memory unlockPercents = new uint[](6);
        for (uint i = 1; i < unlockPercents.length; ++i) {
            unlockPercents[i] = 20 * i;
        }
        
        init(
            'Team',             // 团队
            unlockDate,
            unlockPercents,
            0x622F7546Ea541d56d9781160b2ffde89832a9DB4,
            310000000 * 10 ** 18,
            0x9603f8Ca8Ff73493676946cf6eF26B4C4c1Fa198);
    }
}