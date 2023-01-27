pragma solidity =0.7.6;

interface TokenFactoryInterfaceV1 {

    event UpdateOperator(address operator);
    event UpdateDonatee(address donatee);
    event UpdateCreatorFund(address creatorFund);
    event UpdateTreasuryVester(address treasuryVester);

    event CreateToken (
        address indexed token,
        address indexed creator
    );

    function updateOperator(address newOperator) external;


    function updateDonatee(address newDonatee) external;


    function updateCreatorFund(address newCreatorFund) external;


    function updateTreasuryVester(address treasuryVester) external;


    function createToken(
        string memory name,
        string memory symbol,
        uint256 donationRatio
    ) external;


    function createExclusiveToken(
        address creator,
        string memory name,
        string memory symbol,
        uint256 operationRatio,
        uint256 donationRatio,
        uint256 creatorFundRatio,
        uint256 vestingYears
    ) external;

}// GPL-3.0
pragma solidity =0.7.6;

interface TreasuryVesterInterfaceV1 {

    function addVesting(
        address token,
        address recipient,
        uint256 vestingYears
    ) external;


    function remainingAmountOf(address token) external view returns (uint256);


    function redeemableAmountOf(address token) external view returns (uint256);


    function redeem(address token) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
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

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
        return !Address.isContract(address(this));
    }
}// GPL-3.0

pragma solidity =0.7.6;


library SocialTokenConstants {
    uint256 public constant totalSupply = 10000000 ether;
    uint256 public constant hundredPercent = 10000;
    uint256 public constant distributionRatio = 2000;
    uint256 public constant vestingRatio = 8000;
}

contract SocialToken is Initializable, ERC20Burnable {
    using SafeMath for uint256;

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    constructor() ERC20("", "") {}

    function name() public override view virtual returns (string memory) {
        return _name;
    }

    function symbol() public override view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public override view virtual returns (uint8) {
        return _decimals;
    }

    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        address creator,
        address operator,
        address donatee,
        address treasuryVester,
        address creatorFund,
        uint256 operatorRatio,
        uint256 donateeRatio,
        uint256 creatorFundRatio
    ) public initializer {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = 18;

        if (operatorRatio == 0) {
            _mint(
                creator,
                SocialTokenConstants.totalSupply
                .mul(SocialTokenConstants.distributionRatio)
                .div(SocialTokenConstants.hundredPercent)
            );
        } else {
            _mint(
                creator,
                SocialTokenConstants.totalSupply
                .mul(SocialTokenConstants.distributionRatio.sub(operatorRatio))
                .div(SocialTokenConstants.hundredPercent)
            );
            _mint(
                operator,
                SocialTokenConstants.totalSupply
                .mul(operatorRatio)
                .div(SocialTokenConstants.hundredPercent)
            );
        }

        _mint(
            treasuryVester,
            SocialTokenConstants.totalSupply
            .mul(SocialTokenConstants.vestingRatio.sub(donateeRatio).sub(creatorFundRatio))
            .div(SocialTokenConstants.hundredPercent)
        );
        if (donateeRatio != 0) {
            _mint(
                donatee,
                SocialTokenConstants.totalSupply
                .mul(donateeRatio)
                .div(SocialTokenConstants.hundredPercent)
            );
        }
        if (SocialTokenConstants.totalSupply > totalSupply()) {
            _mint(
                creatorFund,
                SocialTokenConstants.totalSupply - totalSupply()
            );
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

pragma solidity >=0.6.0 <0.8.0;

library Clones {
    function clone(address master) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address master, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address master, bytes32 salt, address deployer) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address master, bytes32 salt) internal view returns (address predicted) {
        return predictDeterministicAddress(master, salt, address(this));
    }
}// GPL-3.0
pragma solidity =0.7.6;


contract TreasuryVester is TreasuryVesterInterfaceV1, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) public vestingTokens;
    mapping(address => uint256) public tokensVestingAmount;
    mapping(address => address) public tokensRecipient;
    mapping(address => uint256) public tokensVestingStart;
    mapping(address => uint256) public tokensVestingEnd;
    mapping(address => uint256) public tokensLastUpdate;

    function addVesting(
        address token,
        address recipient,
        uint256 vestingYears
    ) external override onlyOwner {
        require(vestingYears > 0, "Vesting years should be positive");

        require(!vestingTokens[token], "Token is already registered");
        vestingTokens[token] = true;
        tokensVestingAmount[token] = remainingAmountOf(token);
        tokensRecipient[token] = recipient;
        tokensVestingStart[token] = block.timestamp;
        tokensVestingEnd[token] = block.timestamp.add(vestingYears.mul(365 days));
        tokensLastUpdate[token] = block.timestamp;
    }

    function redeem(address token) external override {
        IERC20 socialToken = IERC20(token);
        uint256 amount = redeemableAmountOf(token);
        tokensLastUpdate[token] = block.timestamp;

        socialToken.transfer(tokensRecipient[token], amount);
    }

    function remainingAmountOf(address token) public override view returns (uint256) {
        IERC20 socialToken = IERC20(token);
        return socialToken.balanceOf(address(this));
    }

    function redeemableAmountOf(address token) public override view returns (uint256){
        uint256 amount;
        if (block.timestamp >= tokensVestingEnd[token]) {
            IERC20 socialToken = IERC20(token);
            amount = socialToken.balanceOf(address(this));
        } else {
            amount = tokensVestingAmount[token]
            .mul(block.timestamp.sub(tokensLastUpdate[token]))
            .div(tokensVestingEnd[token].sub(tokensVestingStart[token]));
        }

        return amount;
    }
}// GPL-3.0
pragma solidity =0.7.6;


contract TokenFactory is TokenFactoryInterfaceV1, Ownable {
    address private operator;
    address private donatee;
    address private creatorFund;
    address private treasuryVester;
    address private socialTokenImplementation;

    constructor(
        address _operator,
        address _donatee,
        address _creatorFund,
        address _treasuryVester
    ) {
        operator = _operator;
        donatee = _donatee;
        creatorFund = _creatorFund;
        treasuryVester = _treasuryVester;

        socialTokenImplementation = address(new SocialToken());
    }

    function updateOperator(address newOperator) public override onlyOwner {
        operator = newOperator;
        emit UpdateOperator(newOperator);
    }

    function updateDonatee(address newDonatee) public override onlyOwner {
        donatee = newDonatee;
        emit UpdateDonatee(newDonatee);
    }

    function updateCreatorFund(address newCreatorFund) public override onlyOwner {
        creatorFund = newCreatorFund;
        emit UpdateCreatorFund(newCreatorFund);
    }

    function updateTreasuryVester(address newTreasuryVester) public override onlyOwner {
        treasuryVester = newTreasuryVester;
        emit UpdateTreasuryVester(newTreasuryVester);
    }

    function createToken(
        string memory name,
        string memory symbol,
        uint256 donationRatio
    ) external override {
        createActualToken(
            msg.sender,
            name,
            symbol,
            0,
            donationRatio,
            donationRatio,
            3
        );
    }

    function createExclusiveToken(
        address creator,
        string memory name,
        string memory symbol,
        uint256 operatorRatio,
        uint256 donateeRatio,
        uint256 creatorFundRatio,
        uint256 vestingYears
    ) external override {
        createActualToken(
            creator,
            name,
            symbol,
            operatorRatio,
            donateeRatio,
            creatorFundRatio,
            vestingYears
        );
    }

    function createActualToken(
        address creator,
        string memory name,
        string memory symbol,
        uint256 operatorRatio,
        uint256 donateeRatio,
        uint256 creatorFundRatio,
        uint256 vestingYears
    ) private {
        address token = Clones.clone(socialTokenImplementation);
        SocialToken(token).initialize(
            name,
            symbol,
            creator,
            operator,
            donatee,
            treasuryVester,
            creatorFund,
            operatorRatio,
            donateeRatio,
            creatorFundRatio
        );

        TreasuryVester(treasuryVester).addVesting(
            token,
            creator,
            vestingYears
        );

        emit CreateToken(
            token,
            creator
        );
    }
}