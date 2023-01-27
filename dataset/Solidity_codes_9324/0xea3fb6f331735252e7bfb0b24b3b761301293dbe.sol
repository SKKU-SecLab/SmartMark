
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT AND AGPL-3.0-or-later

pragma solidity =0.8.9;

abstract contract ProtocolConstants {

    address internal constant _ZERO_ADDRESS = address(0);

    uint256 internal constant _ONE_YEAR = 365 days;

    uint256 internal constant _MAX_BASIS_POINTS = 100_00;


    uint256 internal constant _INITIAL_VADER_SUPPLY = 25_000_000_000 * 1 ether;

    uint256 internal constant _VETH_ALLOCATION = 7_500_000_000 * 1 ether;

    uint256 internal constant _TEAM_ALLOCATION = 2_500_000_000 * 1 ether;

    uint256 internal constant _ECOSYSTEM_GROWTH = 2_500_000_000 * 1 ether;

    uint256 internal constant _GRANT_ALLOCATION = 12_500_000_000 * 1 ether;

    uint256 internal constant _EMISSION_ERA = 24 hours;

    uint256 internal constant _INITIAL_EMISSION_CURVE = 5;

    uint256 internal constant _MAX_FEE_BASIS_POINTS = 1_00;


    uint256 internal constant _MAX_LOCK_DURATION = 30 days;


    uint256 internal constant _VESTING_DURATION = 2 * _ONE_YEAR;


    uint256 internal constant _VADER_VETHER_CONVERSION_RATE = 10_000;

    address internal constant _BURN =
        0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD;


    address internal constant _FAST_GAS_ORACLE =
        0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C;


    uint256 internal constant _GRANT_DELAY = 30 days;

    uint256 internal constant _MAX_GRANT_BASIS_POINTS = 10_00;
}// MIT AND AGPL-3.0-or-later

pragma solidity =0.8.9;


interface IERC20Extended is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;
}// MIT AND AGPL-3.0-or-later

pragma solidity =0.8.9;

interface IUSDV {

    enum LockTypes {
        USDV,
        VADER
    }


    struct Lock {
        LockTypes token;
        uint256 amount;
        uint256 release;
    }


    function mint(
        address account,
        uint256 vAmount,
        uint256 uAmount,
        uint256 exchangeFee,
        uint256 window
    ) external returns (uint256);

    function burn(
        address account,
        uint256 uAmount,
        uint256 vAmount,
        uint256 exchangeFee,
        uint256 window
    ) external returns (uint256);


    event ExchangeFeeChanged(uint256 previousExchangeFee, uint256 exchangeFee);
    event DailyLimitChanged(uint256 previousDailyLimit, uint256 dailyLimit);
    event LockClaimed(
        address user,
        LockTypes lockType,
        uint256 lockAmount,
        uint256 lockRelease
    );
    event LockCreated(
        address user,
        LockTypes lockType,
        uint256 lockAmount,
        uint256 lockRelease
    );
    event ValidatorSet(address previous, address current);
    event GuardianSet(address previous, address current);
    event LockStatusSet(bool status);
    event MinterSet(address minter);
}// MIT AND AGPL-3.0-or-later

pragma solidity =0.8.9;


interface IUnlockValidator {
    function isValid(
        address user,
        uint256 amount,
        IUSDV.LockTypes lockType
    ) external view returns (bool);

    event Invalidate(address account);
    event Validate(address account);
}// MIT AND AGPL-3.0-or-later

pragma solidity =0.8.9;




contract USDV is IUSDV, ProtocolConstants, ERC20, Ownable {

    using SafeERC20 for IERC20Extended;


    IERC20Extended public immutable vader;

    mapping(address => Lock[]) public locks;

    address public guardian;

    bool public isLocked;

    address public minter;

    IUnlockValidator public validator;


    constructor(IERC20Extended _vader) ERC20("Vader USD", "USDV") {
        require(
            _vader != IERC20Extended(_ZERO_ADDRESS),
            "USDV::constructor: Improper Configuration"
        );
        vader = _vader;
    }

    function getLockCount(address account) external view returns (uint256) {
        return locks[account].length;
    }


    function mint(
        address account,
        uint256 vAmount,
        uint256 uAmount,
        uint256 exchangeFee,
        uint256 window
    ) external onlyWhenNotLocked onlyMinter returns (uint256) {
        require(
            vAmount != 0 && uAmount != 0,
            "USDV::mint: Zero Input / Output"
        );
        require(
            window <= _MAX_LOCK_DURATION,
            "USDV::mint: Window > max lock duration"
        );

        vader.transferFrom(account, address(this), vAmount);
        vader.burn(vAmount);

        if (exchangeFee != 0) {
            uint256 fee = (uAmount * exchangeFee) / _MAX_BASIS_POINTS;
            uAmount = uAmount - fee;
            _mint(owner(), fee);
        }

        _mint(address(this), uAmount);

        _createLock(LockTypes.USDV, uAmount, account, window);

        return uAmount;
    }

    function burn(
        address account,
        uint256 uAmount,
        uint256 vAmount,
        uint256 exchangeFee,
        uint256 window
    ) external onlyWhenNotLocked onlyMinter returns (uint256) {
        require(
            uAmount != 0 && vAmount != 0,
            "USDV::burn: Zero Input / Output"
        );
        require(
            window <= _MAX_LOCK_DURATION,
            "USDV::burn: Window > max lock duration"
        );

        _burn(account, uAmount);

        if (exchangeFee != 0) {
            uint256 fee = (vAmount * exchangeFee) / _MAX_BASIS_POINTS;
            vAmount = vAmount - fee;
            vader.mint(owner(), fee);
        }

        vader.mint(address(this), vAmount);

        _createLock(LockTypes.VADER, vAmount, account, window);

        return vAmount;
    }

    function claim(uint256 i) external onlyWhenNotLocked returns (uint256) {
        Lock[] storage userLocks = locks[msg.sender];
        Lock memory lock = userLocks[i];

        require(lock.release <= block.timestamp, "USDV::claim: Vesting");
        require(
            validator.isValid(msg.sender, lock.amount, lock.token),
            "USDV::claim: Prohibited Claim"
        );

        uint256 last = userLocks.length - 1;
        if (i != last) {
            userLocks[i] = userLocks[last];
        }

        userLocks.pop();

        if (lock.token == LockTypes.USDV)
            _transfer(address(this), msg.sender, lock.amount);
        else vader.transfer(msg.sender, lock.amount);

        emit LockClaimed(msg.sender, lock.token, lock.amount, lock.release);

        return lock.amount;
    }

    function claimAll()
        external
        onlyWhenNotLocked
        returns (uint256 usdvAmount, uint256 vaderAmount)
    {
        Lock[] memory userLocks = locks[msg.sender];
        delete locks[msg.sender];

        for (uint256 i = 0; i < userLocks.length; i++) {
            Lock memory lock = userLocks[i];

            require(lock.release <= block.timestamp, "USDV::claimAll: Vesting");
            require(
                validator.isValid(msg.sender, lock.amount, lock.token),
                "USDV::claimAll: Prohibited Claim"
            );

            if (lock.token == LockTypes.USDV) {
                _transfer(address(this), msg.sender, lock.amount);
                usdvAmount += lock.amount;
            } else {
                vader.transfer(msg.sender, lock.amount);
                vaderAmount += lock.amount;
            }

            emit LockClaimed(msg.sender, lock.token, lock.amount, lock.release);
        }
    }


    function setValidator(IUnlockValidator _validator) external onlyOwner {
        require(
            _validator != IUnlockValidator(_ZERO_ADDRESS),
            "USDV::setValidator: Improper Configuration"
        );
        emit ValidatorSet(address(validator), address(_validator));
        validator = _validator;
    }

    function setGuardian(address _guardian) external onlyOwner {
        require(_guardian != address(0), "USDV::setGuardian: Zero Address");
        emit GuardianSet(guardian, _guardian);
        guardian = _guardian;
    }

    function setLock(bool _lock) external {
        require(
            msg.sender == owner() || msg.sender == guardian,
            "USDV::setLock: Insufficient Privileges"
        );
        emit LockStatusSet(_lock);
        isLocked = _lock;
    }

    function setMinter(address _minter) external onlyOwner {
        require(_minter != address(0), "USDV::setMinter: Zero address");
        emit MinterSet(_minter);
        minter = _minter;
    }



    function _createLock(
        LockTypes lockType,
        uint256 amount,
        address account,
        uint256 window
    ) private {
        if (window != 0) {
            uint256 release = block.timestamp + window;

            locks[account].push(Lock(lockType, amount, release));

            emit LockCreated(account, lockType, amount, release);
        } else if (lockType == LockTypes.USDV)
            _transfer(address(this), account, amount);
        else vader.transfer(account, amount);
    }

    modifier onlyWhenNotLocked() {
        require(!isLocked, "USDV::onlyWhenNotLocked: System is Locked");
        _;
    }

    modifier onlyMinter() {
        require(
            msg.sender == minter,
            "USDV::onlyMinter: Insufficient Privileges"
        );
        _;
    }
}