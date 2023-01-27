
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

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

library SafeMathUpgradeable {

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20CappedUpgradeable is Initializable, ERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    uint256 private _cap;

    function __ERC20Capped_init(uint256 cap_) internal initializer {
        __Context_init_unchained();
        __ERC20Capped_init_unchained(cap_);
    }

    function __ERC20Capped_init_unchained(uint256 cap_) internal initializer {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { // When minting tokens
            require(totalSupply().add(amount) <= cap(), "ERC20Capped: cap exceeded");
        }
    }
    uint256[49] private __gap;
}/*-
 * MIT
 *
 * Copyright (c) 2021, Fearless Legends Pte Ltd
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 *
 * PLEASE READ THE TERMS SET OUT HEREIN CAREFULLY AND VERIFY ALL INFORMATION TO BE
 * CORRECT. THE AUTHORS OR COPYRIGHT HOLDERS SHALL NOT BE LIABLE FOR ANY INCORRECT
 * INFORMATION CONTAINED HEREIN.
 *
 * FXF TOKENS ARE NOT INTENDED TO CONSTITUTE SECURITIES OF ANY FORM, UNITS IN A
 * COLLECTIVE INVESTMENT SCHEME OR ANY OTHER FORM OF INVESTMENT IN ANY
 * JURISDICTION. THIS AGREEMENT DOES NOT CONSTITUTE A PROSPECTUS OR OFFER DOCUMENT
 * OF ANY SORT AND IS NOT INTENDED TO CONSTITUTE AN OFFER OF SECURITIES OF ANY
 * FORM, UNITS IN A COLLECTIVE INVESTMENT SCHEME OR ANY OTHER FORM OF INVESTMENT,
 * OR A SOLICITATION FOR ANY FORM OF INVESTMENT IN ANY JURISDICTION. NO REGULATORY
 * AUTHORITY HAS EXAMINED OR APPROVED THIS AGREEMENT, AND NO ACTION HAS BEEN OR
 * WILL BE TAKEN IN RESPECT OF OBTAINING SUCH APPROVAL UNDER THE LAWS, REGULATORY
 * REQUIREMENTS OR RULES OF ANY JURISDICTION.
 *
 * PLEASE NOTE THAT THE AUTHORS OR COPYRIGHT HOLDERS WILL NOT OFFER OR SELL TO
 * YOU, AND YOU ARE NOT ELIGIBLE TO PURCHASE ANY FXF TOKENS IF SUCH PURCHASE IS
 * PROHIBITED, RESTRICTED  OR UNAUTHORISED IN ANY FORM OR MANNER WHETHER IN FULL
 * OR IN PART UNDER THE LAWS, REGULATORY REQUIREMENTS OR RULES IN THE JURISDICTION
 * IN WHICH YOU ARE LOCATED OR SUBJECT TO.
 *
 * The Monetary Authority of Singapore (MAS) requires us to provide this risk
 * warning to you as a customer of a digital payment token (DPT) service provider.
 * Before you pay your DPT service provider any money or DPT, you should be aware
 * of the following.1.Your DPT service provider is exempted by MAS from holding a
 * license to provide DPT services. Please note that you may not be able to
 * recover all the money or DPTs you paid to your DPT service provider if your DPT
 * service provider’s business fails. 2.You should not transact in the DPT if you
 * are not familiar with this DPT. Transacting in DPTs may not be suitable for you
 * if you are not familiar with the technology that DPT services are
 * provided.3.You should be aware that the value of DPTs may fluctuate greatly.
 * You should buy DPTs only if you are prepared to accept the risk of losing all
 * of the money you put into such tokens.
 */

pragma solidity >=0.7.6 <0.8.0;
pragma abicoder v2;




contract FXF is Initializable, ERC20Upgradeable, ERC20CappedUpgradeable {


    using SafeMathUpgradeable for uint256;

    address _governance;
    uint256 _version;


    function initialize(string memory name, string memory symbol) public virtual initializer {

        __ERC20_init(name, symbol);
        __ERC20Capped_init(150 * 10**6 * 10**18);
        _mint(_msgSender(), 150 * 10**6 * 10**18);
        _governance = _msgSender();
        _version = 1;
    }


    struct LockInfo {
        address account;
        uint256 initialLockedTokens;
        uint256 lockedTokens;
        uint256[] amounts;
        uint256[] milestones;
        bool[] isClaimed;
        bool isLocked;
    }


    mapping (address => LockInfo) locks;

    event Lock(address account, uint256 amount);

    event Unlock(address account, uint256 amount);


    function lockInfo(address account) public view returns (LockInfo memory) {

        return locks[account];
    }

    function isLocked(address account) public view returns (bool) {

        return locks[account].isLocked;
    }

    function lockedTokens(address account) public view returns (uint256) {

        return locks[account].lockedTokens;
    }

    function setGovernance(address governance_) public {

        require(_msgSender() == _governance, "!governance");
        require(governance_ != address(0), "governance can not be zero address");
        _governance = governance_;
    }

    function unlockTokens() public {

        require(isLocked(_msgSender()) == true, "Your wallet is not locked");

        LockInfo storage lock = locks[_msgSender()];

        uint256 unlockedTokens = 0;
        for (uint8 i = 0; i < lock.amounts.length; i++) {
            if (block.timestamp >= lock.milestones[i] && lock.isClaimed[i] == false) {
                unlockedTokens += lock.amounts[i];
                lock.isClaimed[i] = true;
            }
        }

        lock.lockedTokens = lock.lockedTokens.sub(unlockedTokens);

        if(lock.lockedTokens == 0)
            lock.isLocked = false;

        emit Unlock(_msgSender(), unlockedTokens);
    }

    function transferLock(address recipient, uint256 amount, uint256[] memory amounts, uint256[] memory milestones) public {

        require(_msgSender() == _governance, "!governance");

        require(isLocked(recipient) == false, "Already Locked");

        require(recipient != address(0), "The recipient's address cannot be 0");

        require(amount > 0, "Amount has to be greater than 0");

        require(amounts.length == milestones.length, "Length of amounts & length of milestones must be equal");

        require(_sum(amounts) == amount, "Sum of amounts must equals to transfered amount");

        bool[] memory isClaimed = _initArrayBool(milestones.length, false);

        locks[recipient] = LockInfo(recipient, amount, amount, amounts, milestones, isClaimed, true);

        transfer(recipient, amount);

        emit Lock(recipient, amount);
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override (ERC20Upgradeable, ERC20CappedUpgradeable){

        super._beforeTokenTransfer(from, to, amount);

        require(_canTransfer(from, amount) == true, "Can not transfer locked tokens");
    }

    function _canTransfer(address from, uint256 amount) private view returns (bool) {

        if (isLocked(from) == true) {
            uint256 transferable = balanceOf(from).sub(lockedTokens(from));
            return (transferable >= amount);
        }
        return true;
    }

    function _initArrayBool(uint256 size, bool value) private pure returns (bool[] memory isClaimed) {

        isClaimed = new bool[](size);
        for (uint256 i = 0; i < size; i++) {
            isClaimed[i] = value;
        }
        return isClaimed;
    }

    function _sum(uint256[] memory array) private pure returns (uint256 sum) {

        sum = 0;
        for (uint8 i = 0; i < array.length; i++) {
            sum += array[i];
        }
        return sum;
    }
}