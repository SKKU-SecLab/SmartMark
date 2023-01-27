

pragma solidity ^0.5.16;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.16;

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


pragma solidity ^0.5.16;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.16;

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


pragma solidity ^0.5.16;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}


pragma solidity ^0.5.16;


library PrivateSaleKeeper {



    struct PrivateData {
        mapping (address => uint256[22]) privateAddresses;
    }

    function insert(PrivateData storage self, address key, uint256 _amount, uint _phase) internal returns (bool success) {

        require(_amount > 0, "PrivateSaleKeeper: Amount equals to 0");

        uint256[22] memory record;
        if(contains(self, key) == false) {

            record[_phase] = _amount; 
        } else {
            record = self.privateAddresses[key];
            record[_phase] += _amount;
        }
        
        self.privateAddresses[key] = record;
        success = true;
    }

    function get(PrivateData storage self, address key) internal view returns (uint256[22] memory) {

        uint256[22] memory record;
        if(contains(self, key)) {
            record =  self.privateAddresses[key];
        }

        return record;
    }

    function contains(PrivateData storage self, address key) internal view returns (bool){


        uint256[22] memory record = self.privateAddresses[key];

        for (uint i=1; i<record.length+1; i++) {
            if(record[i-1] > 0)
            {  
                return true;
            }
        }

        return false;
    }
}


pragma solidity ^0.5.16;

contract DateTime {

        

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }



        function isLeapYear(uint16 year) public pure returns (bool) {

                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) public pure returns (uint) {

                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {

                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {

                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                dt.hour = getHour(timestamp);

                dt.minute = getMinute(timestamp);

                dt.second = getSecond(timestamp);

                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) public pure returns (uint16) {

                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) public pure returns (uint8) {

                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) public pure returns (uint8) {

                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) public pure returns (uint8) {

                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) public pure returns (uint8) {

                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) public pure returns (uint8) {

                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) public pure returns (uint8) {

                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {

                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {

                return toTimestamp(year, month, day, hour, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {

                return toTimestamp(year, month, day, hour, minute, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {

                uint16 i;

                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }

                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;

                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }

                timestamp += DAY_IN_SECONDS * (day - 1);

                timestamp += HOUR_IN_SECONDS * (hour);

                timestamp += MINUTE_IN_SECONDS * (minute);

                timestamp += second;

                return timestamp;
        }
}


pragma solidity ^0.5.16;






contract ERC20 is IERC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    uint16[19] allLockupPeriods = [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360, 400, 450, 480, 540, 600, 720];

    uint256 private _totalSupply;
    uint256 private _vestingMinAmount = 1000000;

    PrivateSaleKeeper.PrivateData salesKeeper;
    using PrivateSaleKeeper for PrivateSaleKeeper.PrivateData;

    DateTime d = new DateTime();

    uint private startDay = d.toTimestamp(2021, 9, 30);

    function setLockupPeriod(uint _phase) private pure returns (uint) {

        if(_phase == 1) {
             return 240 days;
        } else if (_phase == 2) {
             return 180 days;
        } else if (_phase == 3) {
             return 180 days;
        } else {
             return (_phase * 1 days);
        }     
    }

    function getAllLockupPeriods() public view returns (uint16[19] memory) {

        return allLockupPeriods;
    }
    
    function getAmounts(address account) public view returns (uint256[22] memory) {

        require(account == _msgSender() || isOwner(), "You dont have right to use this function");
        return salesKeeper.get(account);
    }

    function getPrivateSaleAmount(address account, uint phase) public view returns (uint256) {

        require(account == _msgSender(), "You dont have right to use this function");
        return getAmounts(account)[phase-1];
    }

    function savePrivateSaleRecord(address _to, uint256 _amount, uint256 _phase) internal {


        require(contains(_phase), "Invalid phase number (1 - 3 or see getALockupPeriods for the allowed lockup days)");

        uint256 _phasee = _phase;
        if(_phase == 0 || _phase > 3) {
            for (uint i = 0; i < allLockupPeriods.length; i++) {
                if(_phase == allLockupPeriods[i]){
                    _phasee = i + 4;
                }
            }
        }

        salesKeeper.insert(_to, _amount, _phasee-1);
    }

    function _vestingTransfer(address recipient, uint256 amount, uint256[] memory lockupDays, uint256[] memory percents) internal {

        require(lockupDays.length + 1 == percents.length, "Invalid number of parameters (number of parameters of percents must be one more than the number of parameters of lockupDays)");
        require(arraySum(percents) == 100, "The sum of vesting percentages does not add up to 100");
        for (uint i=0; i<lockupDays.length; i++) {
            if(!contains(lockupDays[i]))
            {  
                revert("Invalid lockup day number (see getALockupPeriods for the allowed lockup days)");
            }
        }

        uint256 _phase = 0;
        uint256 _vestedAmount = amount.mul(percents[0]).div(100);
        savePrivateSaleRecord(recipient, _vestedAmount, _phase);

        for (uint i=1; i<percents.length; i++) {
            _phase = lockupDays[i-1];
            _vestedAmount = amount.mul(percents[i]).div(100);
            savePrivateSaleRecord(recipient, _vestedAmount, _phase);
        }

    }

    function getStartDay() public view returns(uint256, uint8, uint8) {

        return (d.getYear(startDay), d.getMonth(startDay), d.getDay(startDay));
    }
  
    function changeStartDate(uint16 year, uint8 month, uint8 day) public onlyOwner {

        startDay = d.toTimestamp(year, month, day);
    }


    function getReleaseTimeStamp(uint phase) internal view returns(uint) {

        if(phase <= 3) {
            return startDay + setLockupPeriod(phase);
        } else {
            return startDay + setLockupPeriod(allLockupPeriods[phase-4]);
        }
    }

    function getReleaseTimeStampForDays(uint numDays) internal view returns (uint) {

        return startDay + (numDays * 1 days);
    }

    function getReleaseDate(uint phase) public view returns(uint256, uint8, uint8) {

        require(phase > 0 && phase <= 3, "Invalid phase number");
        return getDate(getReleaseTimeStamp(phase));
    }

    function getDate(uint day) internal view returns (uint256, uint8, uint8) {

        return (d.getYear(day), d.getMonth(day), d.getDay(day));
    }

    function availableForTransfer(address account) public view returns (uint256) {

        require(account == _msgSender() || _msgSender() == address(this), "You don't have right to use this function");

        uint256 presaleAmountNotAvailable = totalLocked(account);

        uint256 tokensUnlocked = balanceOf(account) - presaleAmountNotAvailable;

        return tokensUnlocked;
    }

    function totalLocked(address account) public view returns (uint256) {

        uint256 presaleAmountNotAvailable = 0;
        uint256[22] memory records = getAmounts(account);

        for (uint i=1; i<records.length+1; i++) {
            if (now < getReleaseTimeStamp(i)) { // Private Transfer in LockupPeriod
                presaleAmountNotAvailable += getPrivateSaleAmount(account, i);
            } 
        }

        return presaleAmountNotAvailable;
    }

    function contains(uint _phase) internal view returns (bool){


        if(_phase == 1 || _phase == 2 || _phase == 3) {
            return true;
        }

        for (uint i=0; i<allLockupPeriods.length; i++) {
            if(allLockupPeriods[i] == _phase)
            {  
                return true;
            }
        }

        return false;
    }

    function arraySum(uint256[] memory _array) private pure returns (uint256 _sum) 
    {

        _sum = 0;
        for (uint i = 0; i < _array.length; i++) {
            _sum += _array[i];
        }
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public returns (bool) {


        if(availableForTransfer(_msgSender()) >= amount) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        } else {
            revert("Attempt to transfer more tokens than what is allowed at this time");
        }
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {


         _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Amount not greater than zero");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.16;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.16;



contract MinterRole is Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


pragma solidity ^0.5.16;



contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}


pragma solidity ^0.5.16;



contract PauserRole is Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


pragma solidity ^0.5.16;



contract Pausable is Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}


pragma solidity ^0.5.16;



contract ERC20Pausable is ERC20, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {

        return super.decreaseAllowance(spender, subtractedValue);
    }
}


pragma solidity ^0.5.16;



contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }
}


pragma solidity ^0.5.16;





contract XPLL is ERC20Mintable, ERC20Detailed, ERC20Pausable, ERC20Burnable {


    uint _privateSaleStatus; // open: 1 and 0: close
    
    constructor (string memory tokenName, string memory tokenSymbol, uint8 decimal, uint initialSupply) public ERC20Detailed(tokenName, tokenSymbol, decimal) {

        _privateSaleStatus = 1;

        uint256 tokenAmount = initialSupply * (10 ** uint256(decimals()));
        _mint(_msgSender(), tokenAmount);
    }

    function privateTransfer(address recipient, uint256 amount, uint256 phase) public onlyOwner {

        require(_privateSaleStatus == 1, "Private sale is closed");
        require(recipient != _msgSender(), "Private sale recipient is owner");
        
        savePrivateSaleRecord(recipient, amount, phase);

        transfer(recipient, amount);

        emit PrivateSale(recipient, amount, phase, now);
    }

    function vestingTransfer(address recipient, uint256 amount, uint256[] memory lockupDays, uint256[] memory percents) public onlyOwner {

        _vestingTransfer(recipient, amount, lockupDays, percents);
        transfer(recipient, amount);
        emit VestingTransfer(recipient, amount, lockupDays, percents, now);
    }

    function openPrivateSale() public onlyOwner {

        require(_privateSaleStatus != 1, "Private sale is currently opened");
        _privateSaleStatus = 1;
    }

    function closePrivateSale() public onlyOwner {

        require(_privateSaleStatus == 1, "Private sale is currently not opened");
        _privateSaleStatus = 0;
    }

    function isPrivateSale() view public returns (string memory) {

        if(_privateSaleStatus == 1) {
            return "opened";
        } else {
            return "closed";
        }
    }

    event PrivateSale(address recipient, uint256 amount, uint phase, uint time);
    event VestingTransfer(address recipient, uint256 amount, uint256[] lockupDays, uint256[] percents, uint time);
}