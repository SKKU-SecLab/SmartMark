


pragma solidity =0.8.10 >=0.8.0 <0.9.0 >=0.8.1 <0.9.0;
pragma experimental ABIEncoderV2;



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}




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
}




contract YAMGovernanceStorage {

    mapping(address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => uint) public nonces;
}



contract YAMTokenStorage {

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



abstract contract YAMTokenInterface is YAMTokenStorage, YAMGovernanceStorage {

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

    function transfer(address to, uint256 value) virtual external returns(bool);
    function transferFrom(address from, address to, uint256 value) virtual external returns(bool);
    function balanceOf(address who) virtual external view returns(uint256);
    function balanceOfUnderlying(address who) virtual external view returns(uint256);
    function allowance(address owner_, address spender) virtual external view returns(uint256);
    function approve(address spender, uint256 value) virtual external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) virtual external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) virtual external returns (bool);
    function maxScalingFactor() virtual external view returns (uint256);
    function yamToFragment(uint256 yam) virtual external view returns (uint256);
    function fragmentToYam(uint256 value) virtual external view returns (uint256);

    function getPriorVotes(address account, uint blockNumber) virtual external view returns (uint256);
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) virtual external;
    function delegate(address delegatee) virtual external;
    function delegates(address delegator) virtual external view returns (address);
    function getCurrentVotes(address account) virtual external view returns (uint256);

    function mint(address to, uint256 amount) virtual external returns (bool);
    function burn(uint256 amount) virtual external returns (bool);
    function rebase(uint256 epoch, uint256 indexDelta, bool positive) virtual external returns (uint256);
    function _setRebaser(address rebaser_) virtual external;
    function _setIncentivizer(address incentivizer_) virtual external;
    function _setPendingGov(address pendingGov_) virtual external;
    function _acceptGov() virtual external;
}






abstract contract YAMGovernanceToken is YAMTokenInterface {
    function delegates(address delegator)
        override
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) override external {
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
        override 
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
        require(block.timestamp <= expiry, "YAM::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        override
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        override
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
                uint256 srcRepNew = srcRepOld - amount;
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld + amount;
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

    function getChainId() internal view returns (uint) {
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
        override
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

        return type(uint256).max / initSupply;
    }

    function mint(address to, uint256 amount)
        override
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

        initSupply = initSupply + amount;

        uint256 scaledAmount = _yamToFragment(amount);

        totalSupply = totalSupply + scaledAmount;

        require(yamsScalingFactor <= _maxScalingFactor(), "max scaling factor too low");

        _yamBalances[to] = _yamBalances[to] + amount;

        _moveDelegates(address(0), _delegates[to], amount);
        emit Mint(to, scaledAmount);
        emit Transfer(address(0), to, scaledAmount);
      } else {
        totalSupply = totalSupply + amount;

        uint256 yamValue = _fragmentToYam(amount);

        initSupply = initSupply + yamValue;

        require(yamsScalingFactor <= _maxScalingFactor(), "max scaling factor too low");

        _yamBalances[to] = _yamBalances[to] + yamValue;

        _moveDelegates(address(0), _delegates[to], yamValue);
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
      }
    }


    function burn(uint256 amount)
        override
        external
        returns (bool)
    {

        _burn(amount);
        return true;
    }

    function _burn(uint256 amount)
        internal
    {

        totalSupply = totalSupply - amount;

        uint256 yamValue = _fragmentToYam(amount);

        initSupply = initSupply - yamValue;

        _yamBalances[msg.sender] = _yamBalances[msg.sender] - yamValue;

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


        initSupply = initSupply + amount;

        uint256 scaledAmount = _yamToFragment(amount);

        totalSupply = totalSupply + scaledAmount;

        require(yamsScalingFactor <= _maxScalingFactor(), "max scaling factor too low");

        _yamBalances[to] = _yamBalances[to] + amount;

        _moveDelegates(address(0), _delegates[to], amount);
        emit Mint(to, scaledAmount);
        emit Transfer(address(0), to, scaledAmount);
   
    }

    function transferUnderlying(address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {

        _yamBalances[msg.sender] = _yamBalances[msg.sender] - value;

        _yamBalances[to] = _yamBalances[to] + value;
        emit Transfer(msg.sender, to, _yamToFragment(value));

        _moveDelegates(_delegates[msg.sender], _delegates[to], value);
        return true;
    }
    

    function transfer(address to, uint256 value)
        override
        external
        validRecipient(to)
        returns (bool)
    {



        uint256 yamValue = _fragmentToYam(value);

        _yamBalances[msg.sender] = _yamBalances[msg.sender] - yamValue;

        _yamBalances[to] = _yamBalances[to] + yamValue;
        emit Transfer(msg.sender, to, value);

        _moveDelegates(_delegates[msg.sender], _delegates[to], yamValue);
        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        override
        external
        validRecipient(to)
        returns (bool)
    {

        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender] - value;

        uint256 yamValue = _fragmentToYam(value);

        _yamBalances[from] = _yamBalances[from] - yamValue;
        _yamBalances[to] = _yamBalances[to] + yamValue;
        emit Transfer(from, to, value);

        _moveDelegates(_delegates[from], _delegates[to], yamValue);
        return true;
    }

    function balanceOf(address who)
      override
      external
      view
      returns (uint256)
    {

      return _yamToFragment(_yamBalances[who]);
    }

    function balanceOfUnderlying(address who)
      override
      external
      view
      returns (uint256)
    {

      return _yamBalances[who];
    }

    function allowance(address owner_, address spender)
        override
        external
        view
        returns (uint256)
    {

        return _allowedFragments[owner_][spender];
    }

    function approve(address spender, uint256 value)
        override
        external
        returns (bool)
    {

        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        override
        external
        returns (bool)
    {

        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender] + addedValue;
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        override
        external
        returns (bool)
    {

        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue - subtractedValue;
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
        override
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
        override
        external
        onlyGov
    {

        address oldIncentivizer = incentivizer;
        incentivizer = incentivizer_;
        emit NewIncentivizer(oldIncentivizer, incentivizer_);
    }

    function _setPendingGov(address pendingGov_)
        override
        external
        onlyGov
    {

        address oldPendingGov = pendingGov;
        pendingGov = pendingGov_;
        emit NewPendingGov(oldPendingGov, pendingGov_);
    }

    function _acceptGov()
        override
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
        override
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
            yamsScalingFactor = (yamsScalingFactor * (BASE - indexDelta)) / BASE;
        } else {
            uint256 newScalingFactor = (yamsScalingFactor * (BASE + indexDelta)) / BASE;
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
        override
        external
        view
        returns (uint256)
    {

        return _yamToFragment(yam);
    }

    function fragmentToYam(uint256 value)
        override
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

        return (yam * yamsScalingFactor) / internalDecimals;
    }

    function _fragmentToYam(uint256 value)
        internal
        view
        returns (uint256)
    {

        return (value * internalDecimals) / yamsScalingFactor;
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

abstract contract YAMDelegatorInterface is YAMDelegationStorage {
    event NewImplementation(address oldImplementation, address newImplementation);

    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) virtual public;
}

abstract contract YAMDelegateInterface is YAMDelegationStorage {
    function _becomeImplementation(bytes memory data) virtual public;

    function _resignImplementation() virtual public;
}


contract YAMDelegate3 is YAMLogic3, YAMDelegateInterface {

    constructor() {}

    function _becomeImplementation(bytes memory data) override public {

        data;

        if (false) {
            implementation = address(0);
        }

        require(msg.sender == gov, "only the gov may call _becomeImplementation");
    }

    function _resignImplementation() override public {

        if (false) {
            implementation = address(0);
        }

        require(msg.sender == gov, "only the gov may call _resignImplementation");
    }
}



contract VestingPool {

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

    event SubGovModified(address account, bool isSubGov);

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

    event NewPendingGov(address oldPendingGov, address newPendingGov);

    event NewGov(address oldGov, address newGov);

    constructor(YAMDelegate3 _yam) {
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

    function setSubGov(address account, bool _isSubGov) public onlyGov {

        isSubGov[account] = _isSubGov;
        emit SubGovModified(account, _isSubGov);
    }

    function _setPendingGov(address pendingGov_) external onlyGov {

        address oldPendingGov = pendingGov;
        pendingGov = pendingGov_;
        emit NewPendingGov(oldPendingGov, pendingGov_);
    }

    function _acceptGov() external {

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
    ) public canManageStreams returns (uint256 streamIndex) {

        streamIndex = streamCount++;
        streams[streamIndex] = Stream({
            recipient: recipient,
            length: length,
            startTime: uint128(block.timestamp),
            totalAmount: totalAmount,
            amountPaidOut: 0
        });
        totalUnclaimedInStreams = totalUnclaimedInStreams + totalAmount;
        require(
            totalUnclaimedInStreams <= yam.balanceOfUnderlying(address(this)),
            "VestingPool::payout: Total streaming is greater than pool's YAM balance"
        );
        emit StreamOpened(recipient, streamIndex, length, totalAmount);
    }

    function closeStream(uint256 streamId) public canManageStreams {

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

    function payout(uint256 streamId) public returns (uint256 paidOut) {

        uint128 currentTime = uint128(block.timestamp);
        Stream memory stream = streams[streamId];
        require(
            stream.startTime <= currentTime,
            "VestingPool::payout: Stream hasn't started yet"
        );
        uint256 claimableUnderlying = _claimable(stream);
        streams[streamId].amountPaidOut =
            stream.amountPaidOut +
            claimableUnderlying;

        totalUnclaimedInStreams = totalUnclaimedInStreams - claimableUnderlying;

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
            claimableUnderlying =
                ((elapsedTime * stream.totalAmount) / stream.length) -
                stream.amountPaidOut;
        }
    }
}

/* pragma experimental ABIEncoderV2; */


interface IYVault {

    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);


    function withdraw(uint256 amount) external returns (uint256);

}

interface IYYCRVVault {

    function deposit(uint256 _amount) external;

    function withdraw(uint256 shares) external;

}

interface IYCRVVault {

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_uamount,
        bool donate_dust
    ) external;

}

interface IWETH {

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function balanceOf(address) external view returns (uint256);

}

interface IYSTETHPool {

    function deposit(uint256 _amount) external returns (uint256);

}

interface ILidoPool {

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256);


    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount)
        external
        payable
        returns (uint256);

}

contract Proposal24 {

    IERC20 internal constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant UMA =
        IERC20(0x04Fa0d235C4abf4BcF4787aF4CF447DE572eF828);
    IYVault internal constant yUSDCV2 =
        IYVault(0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9);
    IYVault internal constant yUSDC =
        IYVault(0xa354F35829Ae975e850e23e9615b11Da1B3dC4DE);
    IERC20 internal constant USDC =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 internal constant SUSHI =
        IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    VestingPool internal constant pool =
        VestingPool(0xDCf613db29E4d0B35e7e15e93BF6cc6315eB0b82);
    address internal constant RESERVES =
        0x97990B693835da58A281636296D2Bf02787DEa17;
    address internal constant MULTISIG =
        0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1;
    address internal constant yyCRV = 0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c;
    address internal constant yCRV = 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8;
    address internal constant yCRVVault =
        0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3;
    ILidoPool internal constant lidoPool =
        ILidoPool(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022);
    address internal constant crvstETH =
        0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address internal constant steCRV = 0x06325440D014e39736583c165C2963BA99fAf14E;
    IERC20 internal constant ystETH =
        IERC20(0xdCD90C7f6324cfa40d7169ef80b12031770B4325);

    uint8 executeStep = 0;

    function execute() public {

        require(executeStep == 0);

        IERC20(address(yyCRV)).transferFrom(
            RESERVES,
            address(this),
            IERC20(address(yyCRV)).balanceOf(RESERVES)
        );

        IERC20(yyCRV).approve(address(this), type(uint256).max);
        uint256 yyCRVBalance = IERC20(yyCRV).balanceOf(address(this));
        IYYCRVVault(yyCRV).withdraw(yyCRVBalance);
        IERC20(yCRV).approve(yCRVVault, type(uint256).max);
        IYCRVVault(yCRVVault).remove_liquidity_one_coin(
            IERC20(yCRV).balanceOf(address(this)),
            1,
            260000000000,
            true
        );


        USDC.transfer(
            0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
            yearlyToMonthlyUSD(119004, 1)
        );

        USDC.transfer(
            0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
            yearlyToMonthlyUSD(93800, 1)
        );

        USDC.transfer(
            0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C,
            yearlyToMonthlyUSD(92400, 1)
        );

        USDC.transfer(
            0x88c868B1024ECAefDc648eb152e91C57DeA984d0,
            yearlyToMonthlyUSD(84000, 1)
        );

        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.approve(address(yUSDC), usdcBalance);
        yUSDC.deposit(usdcBalance, RESERVES);


        pool.closeStream(12);
        pool.closeStream(15);
        pool.closeStream(16);
        pool.closeStream(55);
        pool.closeStream(83);
        pool.closeStream(85);
        pool.closeStream(87);
        pool.closeStream(88);
        pool.closeStream(89);
        pool.closeStream(90);
        pool.closeStream(91);
        pool.closeStream(92);
        pool.closeStream(94);
        pool.closeStream(100);

        executeStep++;
    }

    function executeStep2() public {

        require(executeStep == 1);
        require(msg.sender == 0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f);

        IERC20(address(WETH)).transferFrom(
            RESERVES,
            address(this),
            139000000000000000000
        );
        IWETH(address(WETH)).withdraw(139000000000000000000);

        lidoPool.add_liquidity{value: 139000000000000000000}(
            [uint256(139000000000000000000), uint256(0)],
            uint256(130000000000000000000)
        );

        IERC20(steCRV).approve(address(ystETH), type(uint256).max);
        uint256 steCRVBalance = IERC20(steCRV).balanceOf(address(this));
        IYSTETHPool(address(ystETH)).deposit(steCRVBalance);

        ystETH.transfer(RESERVES, IERC20(ystETH).balanceOf(address(this)));

        executeStep++;
    }

    fallback() external payable {}

    function yearlyToMonthlyUSD(uint256 yearlyUSD, uint256 months)
        internal
        pure
        returns (uint256)
    {

        return (((yearlyUSD * (10**6)) / uint256(12)) * months);
    }
}