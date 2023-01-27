
pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

struct VestingWallet {
    address wallet;
    uint256 totalAmount;
    uint256 dayAmount;
    uint256 startDay;
    uint256 afterDays;
    bool nonlinear;
    bool advisory;
}


struct VestingType {
    uint256 dailyRate;
    uint256 afterDays;
    bool nonlinear;
    bool advisory;
}

contract PNLToken is Ownable, ERC20Burnable {
    using SafeMath for uint256;

    mapping(address => VestingWallet) public vestingWallets;
    VestingType[] public vestingTypes;

    mapping(address => bool) public freezeList;

    uint256 public constant PRECISION = 1e18;
    uint256 public constant ONE_HUNDRED_PERCENT = PRECISION * 100;

    uint256[][] public nonLinearUnlock = [
        [10000000000000000000, 1], //10% during the first day
        [1000000000000000000, 40], //1% for the next 40 days
        [250000000000000000, 200] // then 0.25% per 200 days
    ];

    uint256[][] public advisoryNonLinearUnlock = [
        [uint256(20000000000000000000), 1], //20% during the first day
        [uint256(666666666666666666), 121] //0,66% daily after
    ];


    constructor() ERC20("PNLToken", "PNL") {
        vestingTypes.push(
            VestingType(92592592000000000, 360 days, false, false)
        );

        vestingTypes.push(VestingType(100000000000000000, 0, false, false));

        vestingTypes.push(VestingType(0, 0, true, false));

        vestingTypes.push(VestingType(0, 0, true, true));

        vestingTypes.push(VestingType(100000000000000000000, 0, false, false));

        vestingTypes.push(
            VestingType(166666666666666666, 360 days, false, false)
        );

        vestingTypes.push(VestingType(138888888888888888, 0, false, false));

        _mint(address(0xB1537209C77C42d5fe33B56FD2bA3a7434c5Acb8), 1500000e18);

        _mint(address(0xB1537209C77C42d5fe33B56FD2bA3a7434c5Acb8), 3400000e18);
    }

    function getListingTime() public pure returns (uint256) {
        return 1621357200;
    }

    function getMaxTotalSupply() public pure returns (uint256) {
        return PRECISION * 1e8; // 100 million tokens with 18 decimals
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) private pure returns (uint256) {
        return x.mul(y).div(z);
    }

    function freeze(address user) external onlyOwner {
        freezeList[user] = true;
    }

    function unfreeze(address user) external onlyOwner {
        freezeList[user] = false;
    }

    function addAllocations(
        address[] memory addresses,
        uint256[] memory totalAmounts,
        uint256 vestingTypeIndex
    ) external onlyOwner returns (bool) {
        require(
            addresses.length == totalAmounts.length,
            "Address and totalAmounts length must be same"
        );
        require(
            vestingTypeIndex < vestingTypes.length,
            "Vesting type isnt found"
        );

        VestingType memory vestingType = vestingTypes[vestingTypeIndex];
        uint256 addressesLength = addresses.length;

        for (uint256 i = 0; i < addressesLength; i++) {
            address _address = addresses[i];
            uint256 totalAmount = totalAmounts[i];
            uint256 dayAmount =
                mulDiv(
                    totalAmounts[i],
                    vestingType.dailyRate,
                    ONE_HUNDRED_PERCENT
                );
            uint256 afterDay = vestingType.afterDays;
            bool nonlinear = vestingType.nonlinear;
            bool advisory = vestingType.advisory;

            addVestingWallet(
                _address,
                totalAmount,
                dayAmount,
                afterDay,
                nonlinear,
                advisory
            );
        }

        return true;
    }

    function _mint(address account, uint256 amount) internal override {
        uint256 totalSupply = super.totalSupply();
        require(
            getMaxTotalSupply() >= totalSupply.add(amount),
            "Maximum supply exceeded!"
        );
        super._mint(account, amount);
    }

    function addVestingWallet(
        address wallet,
        uint256 totalAmount,
        uint256 dayAmount,
        uint256 afterDays,
        bool nonlinear,
        bool advisory
    ) internal {
        require(
            vestingWallets[wallet].totalAmount == 0,
            "Vesting wallet already created for this address"
        );

        uint256 releaseTime = getListingTime();

        VestingWallet memory vestingWallet =
            VestingWallet(
                wallet,
                totalAmount,
                dayAmount,
                releaseTime.add(afterDays),
                afterDays,
                nonlinear,
                advisory
            );

        vestingWallets[wallet] = vestingWallet;
        _mint(wallet, totalAmount);
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp;
    }


    function getDays(uint256 afterDays) public view returns (uint256) {
        uint256 releaseTime = getListingTime();
        uint256 time = releaseTime.add(afterDays);

        if (block.timestamp < time) {
            return 0;
        }

        uint256 diff = block.timestamp.sub(time);
        uint256 ds = diff.div(1 days).add(1);

        return ds;
    }

    function isStarted(uint256 startDay) public view returns (bool) {
        uint256 releaseTime = getListingTime();

        if (block.timestamp < releaseTime || block.timestamp < startDay) {
            return false;
        }

        return true;
    }

    function calculateNonLinear(uint256 _days, uint256 amount)
        public
        view
        returns (uint256)
    {
        if (_days > 360) {
            return amount;
        }

        uint256 unlocked = 0;
        uint256 _days_remainder = 0;

        for (uint256 i = 0; i < nonLinearUnlock.length; i++) {
            if (_days <= _days_remainder) break;

            if (_days.sub(_days_remainder) >= nonLinearUnlock[i][1]) {
                unlocked = unlocked.add(
                    mulDiv(amount, nonLinearUnlock[i][0], ONE_HUNDRED_PERCENT)
                        .mul(nonLinearUnlock[i][1])
                );
            }

            if (_days.sub(_days_remainder) < nonLinearUnlock[i][1]) {
                unlocked = unlocked.add(
                    mulDiv(amount, nonLinearUnlock[i][0], ONE_HUNDRED_PERCENT)
                        .mul(_days.sub(_days_remainder))
                );
            }

            _days_remainder += nonLinearUnlock[i][1];
        }

        if (unlocked > amount) {
            unlocked = amount;
        }

        return unlocked;
    }

    function calculateNonLinearAdvisory(uint256 _days, uint256 amount)
        public
        view
        returns (uint256)
    {
        if (_days > 360) {
            return amount;
        }

        uint256 unlocked = 0;
        uint256 _days_remainder = 0;

        for (uint256 i = 0; i < advisoryNonLinearUnlock.length; i++) {
            if (_days <= _days_remainder) break;

            if (_days.sub(_days_remainder) >= advisoryNonLinearUnlock[i][1]) {
                unlocked = unlocked.add(
                    mulDiv(
                        amount,
                        advisoryNonLinearUnlock[i][0],
                        ONE_HUNDRED_PERCENT
                    )
                        .mul(advisoryNonLinearUnlock[i][1])
                );
            }

            if (_days.sub(_days_remainder) < advisoryNonLinearUnlock[i][1]) {
                unlocked = unlocked.add(
                    mulDiv(
                        amount,
                        advisoryNonLinearUnlock[i][0],
                        ONE_HUNDRED_PERCENT
                    )
                        .mul(_days.sub(_days_remainder))
                );
            }

            _days_remainder += advisoryNonLinearUnlock[i][1];
        }

        if (unlocked > amount) {
            unlocked = amount;
        }

        return unlocked;
    }

    function getUnlockedVestingAmount(address sender)
        public
        view
        returns (uint256)
    {
        if (vestingWallets[sender].totalAmount == 0) {
            return 0;
        }

        if (!isStarted(0)) {
            return 0;
        }

        uint256 dailyTransferableAmount = 0;
        uint256 trueDays = getDays(vestingWallets[sender].afterDays);

        if (vestingWallets[sender].nonlinear == true) {
            if (vestingWallets[sender].advisory == false) {
                dailyTransferableAmount = calculateNonLinear(
                    trueDays,
                    vestingWallets[sender].totalAmount
                );
            } else {
                dailyTransferableAmount = calculateNonLinearAdvisory(
                    trueDays,
                    vestingWallets[sender].totalAmount
                );
            }
        } else {
            dailyTransferableAmount = vestingWallets[sender].dayAmount.mul(
                trueDays
            );
        }

        if (dailyTransferableAmount > vestingWallets[sender].totalAmount) {
            return vestingWallets[sender].totalAmount;
        }

        return dailyTransferableAmount;
    }

    function getRestAmount(address sender) public view returns (uint256) {
        uint256 transferableAmount = getUnlockedVestingAmount(sender);
        uint256 restAmount =
            vestingWallets[sender].totalAmount.sub(transferableAmount);

        return restAmount;
    }

    function isFrozen(address sender) public view returns (bool) {
        if (freezeList[sender] == true) return false;
        return true;
    }

    function canTransfer(address sender, uint256 amount)
        public
        view
        returns (bool)
    {
        if (vestingWallets[sender].totalAmount == 0) {
            return true;
        }

        uint256 balance = balanceOf(sender);
        uint256 restAmount = getRestAmount(sender);

        if (
            balance > vestingWallets[sender].totalAmount &&
            balance.sub(vestingWallets[sender].totalAmount) >= amount
        ) {
            return true;
        }

        if (
            !isStarted(vestingWallets[sender].startDay) ||
            balance.sub(amount) < restAmount
        ) {
            return false;
        }

        return true;
    }

    function _beforeTokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override(ERC20) {
        require(isFrozen(sender), "The account is frozen");
        require(
            canTransfer(sender, amount),
            "Unable to transfer, not unlocked yet."
        );
        super._beforeTokenTransfer(sender, recipient, amount);
    }
}