
pragma solidity ^0.5.15;

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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
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

        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
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



contract YAMGovernanceStorage {

    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;
}

contract YAMTokenStorage {


    using SafeMath for uint256;

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

    uint256 public yamsScalingFactor;

    mapping (address => uint256) internal _yamBalances;

    mapping (address => mapping (address => uint256)) internal _allowedFragments;

    uint256 public initSupply;


    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public DOMAIN_SEPARATOR;
}

contract YAMTokenInterface is YAMTokenStorage, YAMGovernanceStorage {


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

    event Burn(address from, uint256 amount);

    function transfer(address to, uint256 value) external returns(bool);

    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function balanceOf(address who) external view returns(uint256);

    function balanceOfUnderlying(address who) external view returns(uint256);

    function allowance(address owner_, address spender) external view returns(uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function maxScalingFactor() external view returns (uint256);

    function yamToFragment(uint256 yam) external view returns (uint256);

    function fragmentToYam(uint256 value) external view returns (uint256);


    function getPriorVotes(address account, uint blockNumber) external view returns (uint256);

    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external;

    function delegate(address delegatee) external;

    function delegates(address delegator) external view returns (address);

    function getCurrentVotes(address account) external view returns (uint256);


    function mint(address to, uint256 amount) external returns (bool);

    function burn(uint256 amount) external returns (bool);

    function rebase(uint256 epoch, uint256 indexDelta, bool positive) external returns (uint256);

    function _setRebaser(address rebaser_) external;

    function _setIncentivizer(address incentivizer_) external;

    function _setPendingGov(address pendingGov_) external;

    function _acceptGov() external;

}




contract YAMGovernanceToken is YAMTokenInterface {


    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    function delegates(address delegator)
        external
        view
        returns (address)
    {

        return _delegates[delegator];
    }

    function delegate(address delegatee) external {

        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "YAM::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "YAM::delegateBySig: invalid nonce");
        require(now <= expiry, "YAM::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {

        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {

        require(blockNumber < block.number, "YAM::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {

        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = _yamBalances[delegator]; // balance of underlying YAMs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {

        uint32 blockNumber = safe32(block.number, "YAM::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {

        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

contract YAMToken is YAMGovernanceToken {

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
        public
    {

        require(yamsScalingFactor == 0, "already initialized");
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

        return uint256(-1) / initSupply;
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

      if (msg.sender == migrator) {

        initSupply = initSupply.add(amount);

        uint256 scaledAmount = _yamToFragment(amount);

        totalSupply = totalSupply.add(scaledAmount);

        require(yamsScalingFactor <= _maxScalingFactor(), "max scaling factor too low");

        _yamBalances[to] = _yamBalances[to].add(amount);

        _moveDelegates(address(0), _delegates[to], amount);
        emit Mint(to, scaledAmount);
        emit Transfer(address(0), to, scaledAmount);
      } else {
        totalSupply = totalSupply.add(amount);

        uint256 yamValue = _fragmentToYam(amount);

        initSupply = initSupply.add(yamValue);

        require(yamsScalingFactor <= _maxScalingFactor(), "max scaling factor too low");

        _yamBalances[to] = _yamBalances[to].add(yamValue);

        _moveDelegates(address(0), _delegates[to], yamValue);
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
      }
    }


    function burn(uint256 amount)
        external
        returns (bool)
    {

        _burn(amount);
        return true;
    }

    function _burn(uint256 amount)
        internal
    {

        totalSupply = totalSupply.sub(amount);

        uint256 yamValue = _fragmentToYam(amount);

        initSupply = initSupply.sub(yamValue);

        _yamBalances[msg.sender] = _yamBalances[msg.sender].sub(yamValue);

        _moveDelegates(_delegates[msg.sender], address(0), yamValue);
        emit Burn(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
        }

    function mintUnderlying(address to, uint256 amount)
        external
        onlyMinter
        returns (bool)
    {

        _mintUnderlying(to, amount);
        return true;
    }

    function _mintUnderlying(address to, uint256 amount)
        internal
    {


        initSupply = initSupply.add(amount);

        uint256 scaledAmount = _yamToFragment(amount);

        totalSupply = totalSupply.add(scaledAmount);

        require(yamsScalingFactor <= _maxScalingFactor(), "max scaling factor too low");

        _yamBalances[to] = _yamBalances[to].add(amount);

        _moveDelegates(address(0), _delegates[to], amount);
        emit Mint(to, scaledAmount);
        emit Transfer(address(0), to, scaledAmount);
   
    }

    function transferUnderlying(address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {

        _yamBalances[msg.sender] = _yamBalances[msg.sender].sub(value);

        _yamBalances[to] = _yamBalances[to].add(value);
        emit Transfer(msg.sender, to, _yamToFragment(value));

        _moveDelegates(_delegates[msg.sender], _delegates[to], value);
        return true;
    }
    

    function transfer(address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {



        uint256 yamValue = _fragmentToYam(value);

        _yamBalances[msg.sender] = _yamBalances[msg.sender].sub(yamValue);

        _yamBalances[to] = _yamBalances[to].add(yamValue);
        emit Transfer(msg.sender, to, value);

        _moveDelegates(_delegates[msg.sender], _delegates[to], yamValue);
        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {

        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);

        uint256 yamValue = _fragmentToYam(value);

        _yamBalances[from] = _yamBalances[from].sub(yamValue);
        _yamBalances[to] = _yamBalances[to].add(yamValue);
        emit Transfer(from, to, value);

        _moveDelegates(_delegates[from], _delegates[to], yamValue);
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
        returns (bool)
    {

        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
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
        external
    {

        require(now <= deadline, "YAM/permit-expired");

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

    function assignSelfDelegate(address nonvotingContract)
        external
        onlyGov
    {

        address delegate = _delegates[nonvotingContract];
        require( delegate == address(0), "!address(0)" );
        _delegate(nonvotingContract, nonvotingContract);
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

contract YAMLogic3 is YAMToken {

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address initial_owner,
        uint256 initTotalSupply_
    )
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
                getChainId(),
                address(this)
            )
        );
    }
}



contract YAMDelegationStorage {

    address public implementation;
}

contract YAMDelegatorInterface is YAMDelegationStorage {

    event NewImplementation(address oldImplementation, address newImplementation);

    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public;

}

contract YAMDelegateInterface is YAMDelegationStorage {

    function _becomeImplementation(bytes memory data) public;


    function _resignImplementation() public;

}


contract YAMDelegate3 is YAMLogic3, YAMDelegateInterface {

    constructor() public {}

    function _becomeImplementation(bytes memory data) public {

        data;

        if (false) {
            implementation = address(0);
        }

        require(msg.sender == gov, "only the gov may call _becomeImplementation");
    }

    function _resignImplementation() public {

        if (false) {
            implementation = address(0);
        }

        require(msg.sender == gov, "only the gov may call _resignImplementation");
    }
}

contract VestingPool {

    using SafeMath for uint256;
    using SafeMath for uint128;

    struct Stream {
        address recipient;
        uint128 startTime;
        uint128 length;
        uint256 totalAmount;
        uint256 amountPaidOut;
    }

    address public gov;

    address public pendingGov;

    mapping(address => bool) public isSubGov;

    uint256 public totalUnclaimedInStreams;

    uint256 public streamCount;

    mapping(uint256 => Stream) public streams;

    YAMDelegate3 public yam;

    event SubGovModified(
        address account, 
        bool isSubGov
    );

    event StreamOpened(
        address indexed account,
        uint256 indexed streamId,
        uint256 length,
        uint256 totalAmount
    );

    event StreamClosed(uint256 indexed streamId);

    event Payout(
        uint256 indexed streamId,
        address indexed recipient,
        uint256 amount
    );

    event NewPendingGov(
        address oldPendingGov, 
        address newPendingGov
    );

    event NewGov(
        address oldGov, 
        address newGov
    );

    constructor(YAMDelegate3 _yam)
        public
    {
        gov = msg.sender;
        yam = _yam;
    }

    modifier onlyGov() {

        require(msg.sender == gov, "VestingPool::onlyGov: account is not gov");
        _;
    }

    modifier canManageStreams() {

        require(
            isSubGov[msg.sender] || (msg.sender == gov),
            "VestingPool::canManageStreams: account cannot manage streams"
        );
        _;
    }

    function setSubGov(address account, bool _isSubGov)
        public
        onlyGov
    {

        isSubGov[account] = _isSubGov;
        emit SubGovModified(account, _isSubGov);
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

    function openStream(
        address recipient,
        uint128 length,
        uint256 totalAmount
    )
        public
        canManageStreams
        returns (uint256 streamIndex)
    {

        streamIndex = streamCount++;
        streams[streamIndex] = Stream({
            recipient: recipient,
            length: length,
            startTime: uint128(block.timestamp),
            totalAmount: totalAmount,
            amountPaidOut: 0
        });
        totalUnclaimedInStreams = totalUnclaimedInStreams.add(totalAmount);
        require(
            totalUnclaimedInStreams <= yam.balanceOfUnderlying(address(this)),
            "VestingPool::payout: Total streaming is greater than pool's YAM balance"
        );
        emit StreamOpened(recipient, streamIndex, length, totalAmount);
    }

    function closeStream(uint256 streamId)
        public
        canManageStreams
    {

        payout(streamId);
        streams[streamId] = Stream(
            address(0x0000000000000000000000000000000000000000),
            0,
            0,
            0,
            0
        );
        emit StreamClosed(streamId);
    }

    function payout(uint256 streamId)
        public
        returns (uint256 paidOut)
    {

        uint128 currentTime = uint128(block.timestamp);
        Stream memory stream = streams[streamId];
        require(
            stream.startTime <= currentTime,
            "VestingPool::payout: Stream hasn't started yet"
        );
        uint256 claimableUnderlying = _claimable(stream);
        streams[streamId].amountPaidOut = stream.amountPaidOut.add(
            claimableUnderlying
        );

        totalUnclaimedInStreams = totalUnclaimedInStreams.sub(
            claimableUnderlying
        );

        yam.transferUnderlying(stream.recipient, claimableUnderlying);

        emit Payout(streamId, stream.recipient, claimableUnderlying);
        return claimableUnderlying;
    }


    function claimable(uint256 streamId)
        external
        view
        returns (uint256 claimableUnderlying)
    {

        Stream memory stream = streams[streamId];
        return _claimable(stream);
    }

    function _claimable(Stream memory stream)
        internal
        view
        returns (uint256 claimableUnderlying)
    {

        uint128 currentTime = uint128(block.timestamp);
        uint128 elapsedTime = currentTime - stream.startTime;
        if (currentTime >= stream.startTime + stream.length) {
            claimableUnderlying = stream.totalAmount - stream.amountPaidOut;
        } else {
            claimableUnderlying = elapsedTime
                .mul(stream.totalAmount)
                .div(stream.length)
                .sub(stream.amountPaidOut);
        }
    }

}

interface IBasicIssuanceModule {

    function redeem(
        IERC20 setToken,
        uint256 amount,
        address to
    ) external;

}

interface SushiBar {

    function enter(uint256 amount) external;

}

interface YVault {

    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

}

interface IUMAFarming {

    function _approveExit() external ;

    function _approveEnter() external ;

}

interface IIndexStaking {

    function _approveStakingFromReserves(bool isToken0Limited,
        uint256 amount) external;

}

contract Proposal18 {

    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;

    IERC20 internal constant SUSHI =
        IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    IERC20 internal constant XSUSHI =
        IERC20(0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272);

    IBasicIssuanceModule internal constant ISSUANCE_MODULE =
        IBasicIssuanceModule(0xd8EF3cACe8b4907117a45B0b125c68560532F94D);
    IERC20 internal constant SET_TOKEN =
        IERC20(0xD83dfE003E7c42077186D690DD3D24a0c965ca4e);

    IIndexStaking internal constant INDEX_STAKING =
        IIndexStaking(0x205Cc7463267861002b27021C7108Bc230603d0F);

    IUMAFarming internal constant UGAS_FARMING_JUN =
        IUMAFarming(0xd25b60D3180Ca217FDf1748c86247A81b1aa43d6);
    IUMAFarming internal constant UGAS_FARMING_SEPT =
        IUMAFarming(0x54837096585faB2E45B9a9b0b38B542136d136D5);

    IUMAFarming internal constant USTONKS_FARMING_SEPT_1 =
        IUMAFarming(0x9789204c43bbc03E9176F2114805B68D0320B31d);
    IUMAFarming internal constant USTONKS_FARMING_SEPT_2 =
        IUMAFarming(0xdb0742bdBd7876344046f0E7Ca8bC769e85Fdd01);

    IUMAFarming internal constant UPUNKS_FARMING_SEPT =
        IUMAFarming(0x0c9D03B5CDa39184f62C7b05e77408C06A963FE6);

    address internal constant TREASURY_MULTISIG = 0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1;
    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant USDC =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    VestingPool internal constant VESTING_POOL =
        VestingPool(0xDCf613db29E4d0B35e7e15e93BF6cc6315eB0b82);

    YAMTokenInterface internal constant YAM =
        YAMTokenInterface(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);

    YVault internal constant yUSDC =
        YVault(0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9);

    uint8 currentStep = 0;

    function executeStepOne() public {

        require(currentStep == 0);
        uint256 SUSHI_TO_WRAP = SUSHI.balanceOf(RESERVES);
        SUSHI.transferFrom(RESERVES, address(this), SUSHI_TO_WRAP);
        SUSHI.approve(address(XSUSHI), SUSHI_TO_WRAP);
        SushiBar(address(XSUSHI)).enter(SUSHI_TO_WRAP);
        XSUSHI.transfer(RESERVES, XSUSHI.balanceOf(address(this)));

        SET_TOKEN.transferFrom(RESERVES, address(this), 810000 * (10**18));
        ISSUANCE_MODULE.redeem(SET_TOKEN, 810000 * (10**18), RESERVES);

        UGAS_FARMING_JUN._approveExit();
        UGAS_FARMING_SEPT._approveEnter();

        USTONKS_FARMING_SEPT_1._approveExit();
        USTONKS_FARMING_SEPT_2._approveEnter();

        UPUNKS_FARMING_SEPT._approveEnter();

        INDEX_STAKING._approveStakingFromReserves(false, 119 * (10**18));

        WETH.transferFrom(RESERVES, TREASURY_MULTISIG, 26624383201800000000);

        USDC.transferFrom(RESERVES, TREASURY_MULTISIG, 355000 * (10**6));

        VESTING_POOL.payout(
            VESTING_POOL.openStream(
                TREASURY_MULTISIG,
                0,
                94185 * (10**24) // This is in BoU
            )
        );
        
        YAM.transferFrom(RESERVES, address(this), 20000000000 * (10**18));
        YAM.burn(20000000000 * (10**18));

        currentStep++;
    }

    function executeStepTwo() public {

        require(currentStep == 1);
        require(msg.sender == 0xEC3281124d4c2FCA8A88e3076C1E7749CfEcb7F2);
        uint256 usdcBalance = USDC.balanceOf(RESERVES);
        USDC.transferFrom(RESERVES, address(this), usdcBalance);
        USDC.approve(address(yUSDC), usdcBalance);
        yUSDC.deposit(usdcBalance, RESERVES);
        currentStep++;
    }
}