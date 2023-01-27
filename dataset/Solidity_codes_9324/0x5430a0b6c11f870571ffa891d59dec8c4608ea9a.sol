
pragma solidity 0.8.7;

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

pragma solidity 0.8.7;


contract TokenStorage {


    using SafeMath for uint256;

    mapping (address => uint) public nonces;


    bool internal _notEntered;

    string public name;

    string public symbol;

    uint8 public decimals;

    address public gov;

    address public pendingGov;

    address public rebaser;

    address public migrator;

    address public incentivizer;

    uint256 public totalSupply;

    uint256 public constant internalDecimals = 10**24;

    uint256 public constant BASE = 10**18;

    uint256 public yamsScalingFactor = BASE;

    mapping (address => uint256) internal _yamBalances;

    mapping (address => mapping (address => uint256)) internal _allowedFragments;

    uint256 public initSupply;

    bool public frozen;


    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

}

pragma solidity 0.8.7;

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

pragma solidity 0.8.7;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
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

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value:weiValue}(data);
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
}

pragma solidity 0.8.7;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity 0.8.7;


contract ThunderPOKT is TokenStorage {

    using SafeMath for uint256;


    constructor() {
    rebaser = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    gov = msg.sender;
    }

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    event Rebase(uint256 epoch, uint256 prevYamsScalingFactor, uint256 newYamsScalingFactor);

    event NewPendingGov(address oldPendingGov, address newPendingGov);

    event NewGov(address oldGov, address newGov);

    event NewRebaser(address oldRebaser, address newRebaser);

    event NewMigrator(address oldMigrator, address newMigrator);

    event NewIncentivizer(address oldIncentivizer, address newIncentivizer);


    event Transfer(address indexed from, address indexed to, uint amount);

    event Approval(address indexed owner, address indexed spender, uint amount);

    event Mint(address to, uint256 amount);

    event Burn(address from, uint256 amount, address pokt_address);

    modifier onlyGov() {

        require(msg.sender == gov);
        _;
    }

    modifier onlyRebaser() {

        require(msg.sender == rebaser);
        _;
    }

    modifier onlyMinter() {

        require(
            msg.sender == rebaser
            || msg.sender == gov
            || msg.sender == incentivizer
            || msg.sender == migrator,
            "not minter"
        );
        _;
    }

    modifier notFrozen() {

        require(frozen==false, "frozen");
        _;
    }

    modifier validRecipient(address to) {

        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    )
        onlyGov
        public
    {

        require(yamsScalingFactor == BASE, "already initialized");
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }


    function maxScalingFactor()
        external
        view
        returns (uint256)
    {

        return _maxScalingFactor();
    }

    function _maxScalingFactor()
        internal
        view
        returns (uint256)
    {

        return type(uint).max / initSupply;
    }

    function freeze(bool status)
        external
        onlyGov
        returns (bool)
        {

            frozen = status;
            return true;
        }

    function mint(address to, uint256 amount)
        external
        onlyMinter
        returns (bool)
    {

        _mint(to, amount);
        return true;
    }

    function _mint(address to, uint256 amount)
        internal
    {

        totalSupply = totalSupply.add(amount);

        uint256 yamValue = _fragmentToYam(amount);

        initSupply = initSupply.add(yamValue);

        require(yamsScalingFactor <= _maxScalingFactor(), "max scaling factor too low");

        _yamBalances[to] = _yamBalances[to].add(yamValue);

        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);

    }


    function transfer(address to, uint256 value)
        external
        validRecipient(to)
        notFrozen
        returns (bool)
    {



        uint256 yamValue = _fragmentToYam(value);

        _yamBalances[msg.sender] = _yamBalances[msg.sender].sub(yamValue);

        _yamBalances[to] = _yamBalances[to].add(yamValue);
        emit Transfer(msg.sender, to, value);

        return true;
    }

    function burn(uint256 value, address pokt_address)
        external
        notFrozen
        returns (bool)
    {

        _burn(value,pokt_address);
        return true;
    }

    function _burn(uint256 value, address pokt_address)
        internal
    {



      totalSupply = totalSupply.sub(value);

      uint256 yamValue = _fragmentToYam(value);

      initSupply = initSupply.sub(yamValue);


      require(yamsScalingFactor <= _maxScalingFactor(), "max scaling factor too low");

      _yamBalances[msg.sender] = _yamBalances[msg.sender].sub(yamValue);

      emit Burn(msg.sender, value, pokt_address);
      emit Transfer(msg.sender, address(0), value);

    }
    function transferFrom(address from, address to, uint256 value)
        external
        validRecipient(to)
        notFrozen
        returns (bool)
    {

        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);


        uint256 yamValue = _fragmentToYam(value);

        _yamBalances[from] = _yamBalances[from].sub(yamValue);
        _yamBalances[to] = _yamBalances[to].add(yamValue);
        emit Transfer(from, to, value);

        return true;
    }

    function govTransferFrom(address from, address to, uint256 value)
        external
        validRecipient(to)
        onlyGov
        returns (bool)
    {


        uint256 yamValue = _fragmentToYam(value);

        _yamBalances[from] = _yamBalances[from].sub(yamValue);
        _yamBalances[to] = _yamBalances[to].add(yamValue);
        emit Transfer(from, to, value);

        return true;
    }

    function balanceOf(address who)
      external
      view
      returns (uint256)
    {

      return _yamToFragment(_yamBalances[who]);
    }

    function balanceOfUnderlying(address who)
      external
      view
      returns (uint256)
    {

      return _yamBalances[who];
    }

    function allowance(address owner_, address spender)
        external
        view
        returns (uint256)
    {

        return _allowedFragments[owner_][spender];
    }

    function approve(address spender, uint256 value)
        external
        returns (bool)
    {

        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        notFrozen
        returns (bool)
    {

        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        notFrozen
        returns (bool)
    {

        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        notFrozen
        external
    {

        require(block.timestamp <= deadline, "YAM/permit-expired");

        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            );

        require(owner != address(0), "YAM/invalid-address-0");
        require(owner == ecrecover(digest, v, r, s), "YAM/invalid-permit");
        _allowedFragments[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


    function _setRebaser(address rebaser_)
        external
        onlyGov
    {

        address oldRebaser = rebaser;
        rebaser = rebaser_;
        emit NewRebaser(oldRebaser, rebaser_);
    }

    function _setMigrator(address migrator_)
        external
        onlyGov
    {

        address oldMigrator = migrator_;
        migrator = migrator_;
        emit NewMigrator(oldMigrator, migrator_);
    }

    function _setIncentivizer(address incentivizer_)
        external
        onlyGov
    {

        address oldIncentivizer = incentivizer;
        incentivizer = incentivizer_;
        emit NewIncentivizer(oldIncentivizer, incentivizer_);
    }

    function _setPendingGov(address pendingGov_)
        external
        onlyGov
    {

        address oldPendingGov = pendingGov;
        pendingGov = pendingGov_;
        emit NewPendingGov(oldPendingGov, pendingGov_);
    }

    function _acceptGov()
        external
    {

        require(msg.sender == pendingGov, "!pending");
        address oldGov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldGov, gov);
    }


    function rebase(
        uint256 epoch,
        uint256 indexDelta,
        bool positive
    )
        external
        onlyRebaser
        returns (uint256)
    {

        if (indexDelta == 0) {
          emit Rebase(epoch, yamsScalingFactor, yamsScalingFactor);
          return totalSupply;
        }

        uint256 prevYamsScalingFactor = yamsScalingFactor;


        if (!positive) {
            yamsScalingFactor = yamsScalingFactor.mul(BASE.sub(indexDelta)).div(BASE);
        } else {
            uint256 newScalingFactor = yamsScalingFactor.mul(BASE.add(indexDelta)).div(BASE);
            if (newScalingFactor < _maxScalingFactor()) {
                yamsScalingFactor = newScalingFactor;
            } else {
                yamsScalingFactor = _maxScalingFactor();
            }
        }

        totalSupply = _yamToFragment(initSupply);

        emit Rebase(epoch, prevYamsScalingFactor, yamsScalingFactor);
        return totalSupply;
    }

    function setRebase(
        uint256 epoch,
        uint256 value
    )
        external
        onlyRebaser
        returns (uint256)
    {

        if (value == yamsScalingFactor) {
          emit Rebase(epoch, yamsScalingFactor, yamsScalingFactor);
          return totalSupply;
        }

        uint256 prevYamsScalingFactor = yamsScalingFactor;



        uint256 newScalingFactor = value;
        if (newScalingFactor < _maxScalingFactor()) {
            yamsScalingFactor = value;
        } else {
            yamsScalingFactor = _maxScalingFactor();
        }

        totalSupply = _yamToFragment(initSupply);

        emit Rebase(epoch, prevYamsScalingFactor, yamsScalingFactor);
        return totalSupply;
    }

    function yamToFragment(uint256 yam)
        external
        view
        returns (uint256)
    {

        return _yamToFragment(yam);
    }

    function fragmentToYam(uint256 value)
        external
        view
        returns (uint256)
    {

        return _fragmentToYam(value);
    }

    function _yamToFragment(uint256 yam)
        internal
        view
        returns (uint256)
    {

        return yam.mul(yamsScalingFactor).div(internalDecimals);
    }

    function _fragmentToYam(uint256 value)
        internal
        view
        returns (uint256)
    {

        return value.mul(internalDecimals).div(yamsScalingFactor);
    }

    function rescueTokens(
        address token,
        address to,
        uint256 amount
    )
        external
        onlyGov
        returns (bool)
    {

        SafeERC20.safeTransfer(IERC20(token), to, amount);
        return true;
    }
}

contract tPokt is ThunderPOKT {

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address initial_owner,
        uint256 initTotalSupply_
    )
        onlyGov
        public
    {

        super.initialize(name_, symbol_, decimals_);

        yamsScalingFactor = BASE;
        initSupply = _fragmentToYam(initTotalSupply_);
        totalSupply = initTotalSupply_;
        _yamBalances[initial_owner] = initSupply;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                3,
                address(this)
            )
        );
    }
}
