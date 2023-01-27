
            
pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}




            
pragma solidity ^0.5.0;

contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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




            
pragma solidity ^0.5.0;

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




            
pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


contract MPondLogic is Initializable {

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply; // 10k MPond
    uint256 public bridgeSupply; // 3k MPond

    address public dropBridge;
    mapping(address => mapping(address => uint96)) internal allowances;

    mapping(address => uint96) internal balances;

    mapping(address => mapping(address => uint96)) public delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    bytes32 public DOMAIN_TYPEHASH;

    bytes32 public DELEGATION_TYPEHASH;

    bytes32 public UNDELEGATION_TYPEHASH;

    mapping(address => uint256) public nonces;

    address public admin;
    mapping(address => bool) public isWhiteListed;
    bool public enableAllTranfers;

    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    function initialize(
        address account,
        address bridge,
        address dropBridgeAddress
    ) public initializer {

        createConstants();
        require(
            account != bridge,
            "Bridge and account should not be the same address"
        );
        balances[bridge] = uint96(bridgeSupply);
        delegates[bridge][address(0)] = uint96(bridgeSupply);
        isWhiteListed[bridge] = true;
        emit Transfer(address(0), bridge, bridgeSupply);

        uint96 remainingSupply = sub96(
            uint96(totalSupply),
            uint96(bridgeSupply),
            "MPond: Subtraction overflow in the constructor"
        );
        balances[account] = remainingSupply;
        delegates[account][address(0)] = remainingSupply;
        isWhiteListed[account] = true;
        dropBridge = dropBridgeAddress;
        emit Transfer(address(0), account, uint256(remainingSupply));
    }

    function createConstants() internal {

        name = "Marlin";
        symbol = "MPond";
        decimals = 18;
        totalSupply = 10000e18;
        bridgeSupply = 7000e18;
        DOMAIN_TYPEHASH = keccak256(
            "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
        );
        DELEGATION_TYPEHASH = keccak256(
            "Delegation(address delegatee,uint256 nonce,uint256 expiry,uint96 amount)"
        );
        UNDELEGATION_TYPEHASH = keccak256(
            "Unelegation(address delegatee,uint256 nonce,uint256 expiry,uint96 amount)"
        );
        admin = msg.sender;
    }

    function addWhiteListAddress(address _address)
        external
        onlyAdmin("Only admin can whitelist")
        returns (bool)
    {

        isWhiteListed[_address] = true;
        return true;
    }

    function removeWhiteListAddress(address _address)
        external
        onlyAdmin("Only admin can remove from whitelist")
        returns (bool)
    {

        isWhiteListed[_address] = false;
        return true;
    }

    function enableAllTransfers()
        external
        onlyAdmin("Only admin can enable all transfers")
        returns (bool)
    {

        enableAllTranfers = true;
        return true;
    }

    function disableAllTransfers()
        external
        onlyAdmin("Only admin can disable all transfers")
        returns (bool)
    {

        enableAllTranfers = false;
        return true;
    }

    function changeDropBridge(address _updatedBridge)
        public
        onlyAdmin("Only admin can change drop bridge")
    {

        dropBridge = _updatedBridge;
    }

    function isWhiteListedTransfer(address _address1, address _address2)
        public
        view
        returns (bool)
    {

        if (
            enableAllTranfers ||
            isWhiteListed[_address1] ||
            isWhiteListed[_address2]
        ) {
            return true;
        } else if (_address1 == dropBridge) {
            return true;
        }
        return false;
    }

    function allowance(address account, address spender)
        external
        view
        returns (uint256)
    {

        return allowances[account][spender];
    }

    function approve(address spender, uint256 rawAmount)
        external
        returns (bool)
    {

        uint96 amount;
        if (rawAmount == uint256(-1)) {
            amount = uint96(-1);
        } else {
            amount = safe96(
                rawAmount,
                "MPond::approve: amount exceeds 96 bits"
            );
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedAmount)
        external
        returns (bool)
    {

        uint96 amount;
        if (addedAmount == uint256(-1)) {
            amount = uint96(-1);
        } else {
            amount = safe96(
                addedAmount,
                "MPond::approve: addedAmount exceeds 96 bits"
            );
        }

        allowances[msg.sender][spender] = add96(
            allowances[msg.sender][spender],
            amount,
            "MPond: increaseAllowance allowance value overflows"
        );
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 removedAmount)
        external
        returns (bool)
    {

        uint96 amount;
        if (removedAmount == uint256(-1)) {
            amount = uint96(-1);
        } else {
            amount = safe96(
                removedAmount,
                "MPond::approve: removedAmount exceeds 96 bits"
            );
        }

        allowances[msg.sender][spender] = sub96(
            allowances[msg.sender][spender],
            amount,
            "MPond: decreaseAllowance allowance value underflows"
        );
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {

        return balances[account];
    }

    function transfer(address dst, uint256 rawAmount) external returns (bool) {

        require(
            isWhiteListedTransfer(msg.sender, dst),
            "Atleast one of the address (src or dst) should be whitelisted or all transfers must be enabled via enableAllTransfers()"
        );
        uint96 amount = safe96(
            rawAmount,
            "MPond::transfer: amount exceeds 96 bits"
        );
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(
        address src,
        address dst,
        uint256 rawAmount
    ) external returns (bool) {

        require(
            isWhiteListedTransfer(src, dst),
            "Atleast one of the address (src or dst) should be whitelisted or all transfers must be enabled via enableAllTransfers()"
        );
        address spender = msg.sender;
        uint96 spenderAllowance = allowances[src][spender];
        uint96 amount = safe96(
            rawAmount,
            "MPond::approve: amount exceeds 96 bits"
        );

        if (spender != src && spenderAllowance != uint96(-1)) {
            uint96 newAllowance = sub96(
                spenderAllowance,
                amount,
                "MPond::transferFrom: transfer amount exceeds spender allowance"
            );
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function delegate(address delegatee, uint96 amount) public {

        return _delegate(msg.sender, delegatee, amount);
    }

    function undelegate(address delegatee, uint96 amount) public {

        return _undelegate(msg.sender, delegatee, amount);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint96 amount
    ) public {

        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                getChainId(),
                address(this)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry, amount)
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );
        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "MPond::delegateBySig: invalid signature"
        );
        require(
            nonce == nonces[signatory]++,
            "MPond::delegateBySig: invalid nonce"
        );
        require(now <= expiry, "MPond::delegateBySig: signature expired");
        return _delegate(signatory, delegatee, amount);
    }

    function undelegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint96 amount
    ) public {

        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                getChainId(),
                address(this)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(UNDELEGATION_TYPEHASH, delegatee, nonce, expiry, amount)
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );
        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "MPond::undelegateBySig: invalid signature"
        );
        require(
            nonce == nonces[signatory]++,
            "MPond::undelegateBySig: invalid nonce"
        );
        require(now <= expiry, "MPond::undelegateBySig: signature expired");
        return _undelegate(signatory, delegatee, amount);
    }

    function getCurrentVotes(address account) external view returns (uint96) {

        uint32 nCheckpoints = numCheckpoints[account];
        return
            nCheckpoints != 0
                ? checkpoints[account][nCheckpoints - 1].votes
                : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber)
        public
        view
        returns (uint96)
    {

        require(
            blockNumber < block.number,
            "MPond::getPriorVotes: not yet determined"
        );

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

    function _delegate(
        address delegator,
        address delegatee,
        uint96 amount
    ) internal {

        delegates[delegator][address(0)] = sub96(
            delegates[delegator][address(0)],
            amount,
            "MPond: delegates underflow"
        );
        delegates[delegator][delegatee] = add96(
            delegates[delegator][delegatee],
            amount,
            "MPond: delegates overflow"
        );

        emit DelegateChanged(delegator, address(0), delegatee);

        _moveDelegates(address(0), delegatee, amount);
    }

    function _undelegate(
        address delegator,
        address delegatee,
        uint96 amount
    ) internal {

        delegates[delegator][delegatee] = sub96(
            delegates[delegator][delegatee],
            amount,
            "MPond: undelegates underflow"
        );
        delegates[delegator][address(0)] = add96(
            delegates[delegator][address(0)],
            amount,
            "MPond: delegates underflow"
        );
        emit DelegateChanged(delegator, delegatee, address(0));
        _moveDelegates(delegatee, address(0), amount);
    }

    function _transferTokens(
        address src,
        address dst,
        uint96 amount
    ) internal {

        require(
            src != address(0),
            "MPond::_transferTokens: cannot transfer from the zero address"
        );
        require(
            delegates[src][address(0)] >= amount,
            "MPond: _transferTokens: undelegated amount should be greater than transfer amount"
        );
        require(
            dst != address(0),
            "MPond::_transferTokens: cannot transfer to the zero address"
        );

        balances[src] = sub96(
            balances[src],
            amount,
            "MPond::_transferTokens: transfer amount exceeds balance"
        );
        delegates[src][address(0)] = sub96(
            delegates[src][address(0)],
            amount,
            "MPond: _tranferTokens: undelegate subtraction error"
        );

        balances[dst] = add96(
            balances[dst],
            amount,
            "MPond::_transferTokens: transfer amount overflows"
        );
        delegates[dst][address(0)] = add96(
            delegates[dst][address(0)],
            amount,
            "MPond: _transferTokens: undelegate addition error"
        );
        emit Transfer(src, dst, amount);

    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint96 amount
    ) internal {

        if (srcRep != dstRep && amount != 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum != 0
                    ? checkpoints[srcRep][srcRepNum - 1].votes
                    : 0;
                uint96 srcRepNew = sub96(
                    srcRepOld,
                    amount,
                    "MPond::_moveVotes: vote amount underflows"
                );
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum != 0
                    ? checkpoints[dstRep][dstRepNum - 1].votes
                    : 0;
                uint96 dstRepNew = add96(
                    dstRepOld,
                    amount,
                    "MPond::_moveVotes: vote amount overflows"
                );
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint96 oldVotes,
        uint96 newVotes
    ) internal {

        uint32 blockNumber = safe32(
            block.number,
            "MPond::_writeCheckpoint: block number exceeds 32 bits"
        );

        if (
            nCheckpoints != 0 &&
            checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(
                blockNumber,
                newVotes
            );
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint32)
    {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint96)
    {

        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal pure returns (uint256) {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    modifier onlyAdmin(string memory _error) {

        require(msg.sender == admin, _error);
        _;
    }
}




            
pragma solidity ^0.5.17;

interface IRewardDelegators {

    function undelegationWaitTime() external returns(uint256);

    function minMPONDStake() external returns(uint256);

    function MPONDTokenId() external returns(bytes32);

    function updateMPONDTokenId(bytes32 _updatedMPONDTokenId) external;

    function addRewardFactor(bytes32 _tokenId, uint256 _rewardFactor) external;

    function removeRewardFactor(bytes32 _tokenId) external;

    function updateRewardFactor(bytes32 _tokenId, uint256 _updatedRewardFactor) external;

    function _updateRewards(address _cluster) external;

    function delegate(
        address _delegator,
        address _cluster,
        bytes32[] calldata _tokens,
        uint256[] calldata _amounts
    ) external;

    function undelegate(
        address _delegator,
        address _cluster,
        bytes32[] calldata _tokens,
        uint256[] calldata _amounts
    ) external;

    function withdrawRewards(address _delegator, address _cluster) external returns(uint256);

    function isClusterActive(address _cluster) external returns(bool);

    function getClusterDelegation(address _cluster, bytes32 _tokenId) external view returns(uint256);

    function getDelegation(address _cluster, address _delegator, bytes32 _tokenId) external view returns(uint256);

    function updateUndelegationWaitTime(uint256 _undelegationWaitTime) external;

    function updateMinMPONDStake(uint256 _minMPONDStake) external;

    function updateStakeAddress(address _updatedStakeAddress) external;

    function updateClusterRewards(address _updatedClusterRewards) external;

    function updateClusterRegistry(address _updatedClusterRegistry) external;

    function updatePONDAddress(address _updatedPOND) external;

    function getFullTokenList() external view returns (bytes32[] memory);

    function getAccRewardPerShare(address _cluster, bytes32 _tokenId) external view returns(uint256);

}



            
pragma solidity ^0.5.0;


contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
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

    uint256[50] private ______gap;
}




            
pragma solidity ^0.5.0;


contract ERC20 is Initializable, Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
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

    uint256[50] private ______gap;
}



pragma solidity >=0.4.21 <0.7.0;



interface Inbox {

    function createRetryableTicket(
        address destAddr,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) external payable returns (uint256);

}

interface TokenGateway {

    function transferL2(
        address _to,
        uint256 _amount,
        uint256 _maxSubmissionCost,
        uint256 _maxGas,
        uint256 _gasPriceBid
    ) external payable returns (uint256);

}

contract StakeManager is Initializable, Ownable {


    using SafeMath for uint256;

    struct Stash {
        address staker;
        address delegatedCluster;
        mapping(bytes32 => uint256) amount;   // name is not intuitive
        uint256 undelegatesAt;
    }

    struct Token {
        address addr;
        bool isActive;
    }
    mapping(bytes32 => Stash) public stashes;
    uint256 public stashIndex;
    mapping(bytes32 => Token) tokenAddresses;
    MPondLogic MPOND;
    MPondLogic prevMPOND;
    address _unused_1;
    IRewardDelegators public rewardDelegators;
    struct Lock {
        uint256 unlockBlock;
        uint256 iValue;
    }

    mapping(bytes32 => Lock) public locks;
    mapping(bytes32 => uint256) public lockWaitTime;
    bytes32 constant REDELEGATION_LOCK_SELECTOR = keccak256("REDELEGATION_LOCK");
    uint256 public undelegationWaitTime;

    uint256[50] __gap;
    mapping(bytes32 => bool) public isStashBridged;
    address public inbox;
    address public gatewayL2;
    address public stakeManagerL2;
    mapping(bytes32 => uint256) public amountBridged;
    mapping(bytes32 => address) public tokenGateways;

    event StashCreated(
        address indexed creator,
        bytes32 stashId,
        uint256 stashIndex,
        bytes32[] tokens,
        uint256[] amounts
    );
    event StashDelegated(bytes32 stashId, address delegatedCluster);
    event StashUndelegated(bytes32 stashId, address undelegatedCluster, uint256 undelegatesAt);
    event StashWithdrawn(bytes32 stashId, bytes32[] tokens, uint256[] amounts);
    event StashClosed(bytes32 stashId, address indexed staker);
    event AddedToStash(bytes32 stashId, address delegatedCluster, bytes32[] tokens, uint256[] amounts);
    event TokenAdded(bytes32 tokenId, address tokenAddress);
    event TokenRemoved(bytes32 tokenId);
    event TokenUpdated(bytes32 tokenId, address tokenAddress);
    event RedelegationRequested(bytes32 stashId, address currentCluster, address updatedCluster, uint256 redelegatesAt);
    event Redelegated(bytes32 stashId, address updatedCluster);
    event LockTimeUpdated(bytes32 selector, uint256 prevLockTime, uint256 updatedLockTime);
    event StashSplit(
        bytes32 _newStashId,
        bytes32 _stashId,
        uint256 _stashIndex,
        bytes32[] _splitTokens,
        uint256[] _splitAmounts
    );
    event StashesMerged(bytes32 _stashId1, bytes32 _stashId2);
    event StashUndelegationCancelled(bytes32 _stashId);
    event UndelegationWaitTimeUpdated(uint256 undelegationWaitTime);
    event RedelegationCancelled(bytes32 indexed _stashId);
    event StashesBridged(uint256 indexed _ticketId, bytes32[] _stashIds);

    function initialize(
        bytes32[] memory _tokenIds,
        address[] memory _tokenAddresses,
        address _MPONDTokenAddress,
        address _rewardDelegatorsAddress,
        address _owner,
        uint256 _undelegationWaitTime)
        initializer
        public
    {

        require(
            _tokenIds.length == _tokenAddresses.length
        );
        for(uint256 i=0; i < _tokenIds.length; i++) {
            tokenAddresses[_tokenIds[i]] = Token(_tokenAddresses[i], true);
            emit TokenAdded(_tokenIds[i], _tokenAddresses[i]);
        }
        MPOND = MPondLogic(_MPONDTokenAddress);
        rewardDelegators = IRewardDelegators(_rewardDelegatorsAddress);
        undelegationWaitTime = _undelegationWaitTime;
        super.initialize(_owner);
    }

    function updateLockWaitTime(bytes32 _selector, uint256 _updatedWaitTime) external onlyOwner {

        emit LockTimeUpdated(_selector, lockWaitTime[_selector], _updatedWaitTime);
        lockWaitTime[_selector] = _updatedWaitTime;
    }

    function changeMPONDTokenAddress(
        address _MPONDTokenAddress
    ) external onlyOwner {

        prevMPOND = MPOND;
        MPOND = MPondLogic(_MPONDTokenAddress);
        emit TokenUpdated(keccak256("MPOND"), _MPONDTokenAddress);
    }

    function updateRewardDelegators(
        address _updatedRewardDelegator
    ) external onlyOwner {

        require(
            _updatedRewardDelegator != address(0)
        );
        rewardDelegators = IRewardDelegators(_updatedRewardDelegator);
    }

    function updateInbox(
        address _inbox
    ) external onlyOwner {

        require(
            _inbox != address(0)
        );
        inbox = _inbox;
    }

    function updateGatewayL2(
        address _gatewayL2
    ) external onlyOwner {

        require(
            _gatewayL2 != address(0)
        );
        gatewayL2 = _gatewayL2;
    }

    function updateStakeManagerL2(
        address _stakeManagerL2
    ) external onlyOwner {

        require(
            _stakeManagerL2 != address(0)
        );
        stakeManagerL2 = _stakeManagerL2;
    }

    function setAmountBridged(
        bytes32[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) external onlyOwner {

        require(_tokenIds.length == _amounts.length);
        for(uint256 i = 0; i < _tokenIds.length; i++) {
            amountBridged[_tokenIds[i]] = _amounts[i];
        }
    }

    function setTokenGateway(
        bytes32[] calldata _tokenIds,
        address[] calldata _gateways
    ) external onlyOwner {

        require(_tokenIds.length == _gateways.length);
        for(uint256 i = 0; i < _tokenIds.length; i++) {
            tokenGateways[_tokenIds[i]] = _gateways[i];
        }
    }

    function bridgeStash(
        bytes32 _stashId
    ) external onlyOwner {

        isStashBridged[_stashId] = true;
    }

    function unbridgeStash(
        bytes32 _stashId
    ) external onlyOwner {

        isStashBridged[_stashId] = false;
    }

    function updateUndelegationWaitTime(
        uint256 _undelegationWaitTime
    ) external onlyOwner {

        undelegationWaitTime = _undelegationWaitTime;
        emit UndelegationWaitTimeUpdated(_undelegationWaitTime);
    }

    function enableToken(
        bytes32 _tokenId,
        address _address
    ) external onlyOwner {

        require(
            !tokenAddresses[_tokenId].isActive
        );
        require(_address != address(0));
        tokenAddresses[_tokenId] = Token(_address, true);
        emit TokenAdded(_tokenId, _address);
    }

    function disableToken(
        bytes32 _tokenId
    ) external onlyOwner {

        require(
            tokenAddresses[_tokenId].isActive
        );
        tokenAddresses[_tokenId].isActive = false;
        emit TokenRemoved(_tokenId);
    }

    function createStashAndDelegate(
        bytes32[] memory _tokens,
        uint256[] memory _amounts,
        address _delegatedCluster
    ) public {

        bytes32 stashId = createStash(_tokens, _amounts);
        delegateStash(stashId, _delegatedCluster);
    }

    function createStash(
        bytes32[] memory _tokens,
        uint256[] memory _amounts
    ) public returns(bytes32) {

        require(
            _tokens.length == _amounts.length,
            "CS1"
        );
        require(
            _tokens.length != 0,
            "CS2"
        );
        uint256 _stashIndex = stashIndex;
        bytes32 _stashId = keccak256(abi.encodePacked(_stashIndex));
        for(uint256 _index=0; _index < _tokens.length; _index++) {
            bytes32 _tokenId = _tokens[_index];
            uint256 _amount = _amounts[_index];
            require(
                tokenAddresses[_tokenId].isActive,
                "CS3"
            );
            require(
                stashes[_stashId].amount[_tokenId] == 0,
                "CS4"
            );
            require(
                _amount != 0,
                "CS5"
            );
            stashes[_stashId].amount[_tokenId] = _amount;
            _lockTokens(_tokenId, _amount, msg.sender);
        }
        stashes[_stashId].staker = msg.sender;
        emit StashCreated(msg.sender, _stashId, _stashIndex, _tokens, _amounts);
        stashIndex = _stashIndex + 1;  // Can't overflow
        return _stashId;
    }

    function addToStash(
        bytes32 _stashId,
        bytes32[] calldata _tokens,
        uint256[] calldata _amounts
    ) external {

        require(isStashBridged[_stashId] == false, "AS0");

        Stash memory _stash = stashes[_stashId];
        require(
            _stash.staker == msg.sender,
            "AS1"
        );
        require(
            _stash.undelegatesAt <= block.number,
            "AS2"
        );
        require(
            _tokens.length == _amounts.length,
            "AS3"
        );
        if(
            _stash.delegatedCluster != address(0)
        ) {
            rewardDelegators.delegate(msg.sender, _stash.delegatedCluster, _tokens, _amounts);
        }
        for(uint256 i = 0; i < _tokens.length; i++) {
            bytes32 _tokenId = _tokens[i];
            require(
                tokenAddresses[_tokenId].isActive,
                "AS4"
            );
            if(_amounts[i] != 0) {
                stashes[_stashId].amount[_tokenId] = stashes[_stashId].amount[_tokenId].add(_amounts[i]);
                _lockTokens(_tokenId, _amounts[i], msg.sender);
            }
        }

        emit AddedToStash(_stashId, _stash.delegatedCluster, _tokens, _amounts);
    }

    function delegateStash(bytes32 _stashId, address _delegatedCluster) public {

        require(isStashBridged[_stashId] == false, "DS0");

        Stash memory _stash = stashes[_stashId];
        require(
            _stash.staker == msg.sender,
            "DS1"
        );
        require(
            _delegatedCluster != address(0),
            "DS2"
        );
        require(
            _stash.delegatedCluster == address(0),
            "DS3"
        );
        require(
            _stash.undelegatesAt <= block.number,
            "DS4"
        );
        stashes[_stashId].delegatedCluster = _delegatedCluster;
        delete stashes[_stashId].undelegatesAt;
        bytes32[] memory _tokens = rewardDelegators.getFullTokenList();
        uint256[] memory _amounts = new uint256[](_tokens.length);
        for(uint256 i = 0; i < _tokens.length; i++) {
            _amounts[i] = stashes[_stashId].amount[_tokens[i]];
        }
        rewardDelegators.delegate(msg.sender, _delegatedCluster, _tokens, _amounts);
        emit StashDelegated(_stashId, _delegatedCluster);
    }

    function requestStashRedelegation(bytes32 _stashId, address _newCluster) public {

        require(isStashBridged[_stashId] == false, "RSR0");

        Stash memory _stash = stashes[_stashId];
        require(
            _stash.staker == msg.sender,
            "RSR1"
        );
        require(
            _stash.delegatedCluster != address(0),
            "RSR2"
        );
        require(
            _newCluster != address(0),
            "RSR3"
        );
        uint256 _redelegationBlock = _requestStashRedelegation(_stashId, _newCluster);
        emit RedelegationRequested(_stashId, _stash.delegatedCluster, _newCluster, _redelegationBlock);
    }

    function _requestStashRedelegation(bytes32 _stashId, address _newCluster) internal returns(uint256) {

        require(isStashBridged[_stashId] == false, "_RSR0");

        bytes32 _lockId = keccak256(abi.encodePacked(REDELEGATION_LOCK_SELECTOR, _stashId));
        uint256 _unlockBlock = locks[_lockId].unlockBlock;
        require(
            _unlockBlock == 0,
            "IRSR1"
        );
        uint256 _redelegationBlock = block.number.add(lockWaitTime[REDELEGATION_LOCK_SELECTOR]);
        locks[_lockId] = Lock(_redelegationBlock, uint256(_newCluster));
        return _redelegationBlock;
    }

    function requestStashRedelegations(bytes32[] memory _stashIds, address[] memory _newClusters) public {

        require(_stashIds.length == _newClusters.length, "SM:RSRs - Invalid input data");
        for(uint256 i=0; i < _stashIds.length; i++) {
            requestStashRedelegation(_stashIds[i], _newClusters[i]);
        }
    }

    function redelegateStash(bytes32 _stashId) public {

        require(isStashBridged[_stashId] == false, "RS0");

        Stash memory _stash = stashes[_stashId];
        require(
            _stash.delegatedCluster != address(0),
            "RS1"
        );
        bytes32 _lockId = keccak256(abi.encodePacked(REDELEGATION_LOCK_SELECTOR, _stashId));
        uint256 _unlockBlock = locks[_lockId].unlockBlock;
        require(
            _unlockBlock != 0 && _unlockBlock <= block.number,
            "RS2"
        );
        address _updatedCluster = address(locks[_lockId].iValue);
        _redelegateStash(_stashId, _stash.staker, _stash.delegatedCluster, _updatedCluster);
        delete locks[_lockId];
    }

    function _redelegateStash(
        bytes32 _stashId,
        address _staker,
        address _delegatedCluster,
        address _updatedCluster
    ) internal {

        require(isStashBridged[_stashId] == false, "_RS0");

        bytes32[] memory _tokens = rewardDelegators.getFullTokenList();
        uint256[] memory _amounts = new uint256[](_tokens.length);
        for(uint256 i=0; i < _tokens.length; i++) {
            _amounts[i] = stashes[_stashId].amount[_tokens[i]];
        }
        if(_delegatedCluster != address(0)) {
            rewardDelegators.undelegate(_staker, _delegatedCluster, _tokens, _amounts);
        }
        rewardDelegators.delegate(_staker, _updatedCluster, _tokens, _amounts);
        stashes[_stashId].delegatedCluster = _updatedCluster;
        emit Redelegated(_stashId, _updatedCluster);
    }

    function splitStash(bytes32 _stashId, bytes32[] calldata _tokens, uint256[] calldata _amounts) external {

        require(isStashBridged[_stashId] == false, "SS0");

        Stash memory _stash = stashes[_stashId];
        require(
            _stash.staker == msg.sender,
            "SS1"
        );
        require(
            _tokens.length != 0,
            "SS2"
        );
        require(
            _tokens.length == _amounts.length,
            "SS3"
        );
        uint256 _stashIndex = stashIndex;
        bytes32 _newStashId = keccak256(abi.encodePacked(_stashIndex));
        for(uint256 _index=0; _index < _tokens.length; _index++) {
            bytes32 _tokenId = _tokens[_index];
            uint256 _amount = _amounts[_index];
            require(
                stashes[_newStashId].amount[_tokenId] == 0,
                "SS4"
            );
            require(
                _amount != 0,
                "SS5"
            );
            stashes[_stashId].amount[_tokenId] = stashes[_stashId].amount[_tokenId].sub(
                _amount,
                "SS6"
            );
            stashes[_newStashId].amount[_tokenId] = _amount;
        }
        stashes[_newStashId].staker = msg.sender;
        stashes[_newStashId].delegatedCluster = _stash.delegatedCluster;
        stashes[_newStashId].undelegatesAt = _stash.undelegatesAt;
        emit StashSplit(_newStashId, _stashId, _stashIndex, _tokens, _amounts);
        stashIndex = _stashIndex + 1;
    }

    function mergeStash(bytes32 _stashId1, bytes32 _stashId2) external {

        require(isStashBridged[_stashId1] == false, "MS01");
        require(isStashBridged[_stashId2] == false, "MS02");

        require(_stashId1 != _stashId2, "MS1");
        Stash memory _stash1 = stashes[_stashId1];
        Stash memory _stash2 = stashes[_stashId2];
        require(
            _stash1.staker == msg.sender && _stash2.staker == msg.sender,
            "MS2"
        );
        require(
            _stash1.delegatedCluster == _stash2.delegatedCluster,
            "MS3"
        );
        require(
            (_stash1.undelegatesAt <= block.number) &&
            (_stash2.undelegatesAt <= block.number),
            "MS4"
        );
        bytes32 _lockId1 = keccak256(abi.encodePacked(REDELEGATION_LOCK_SELECTOR, _stashId1));
        uint256 _unlockBlock1 = locks[_lockId1].unlockBlock;
        bytes32 _lockId2 = keccak256(abi.encodePacked(REDELEGATION_LOCK_SELECTOR, _stashId2));
        uint256 _unlockBlock2 = locks[_lockId2].unlockBlock;
        require(
            _unlockBlock1 == 0 && _unlockBlock2 == 0,
            "MS5"
        );
        bytes32[] memory _tokens = rewardDelegators.getFullTokenList();
        for(uint256 i=0; i < _tokens.length; i++) {
            uint256 _amount = stashes[_stashId2].amount[_tokens[i]];
            if(_amount == 0) {
                continue;
            }
            delete stashes[_stashId2].amount[_tokens[i]];
            stashes[_stashId1].amount[_tokens[i]] = stashes[_stashId1].amount[_tokens[i]].add(_amount);
        }
        delete stashes[_stashId2];
        emit StashesMerged(_stashId1, _stashId2);
    }

    function redelegateStashes(bytes32[] memory _stashIds) public {

        for(uint256 i=0; i < _stashIds.length; i++) {
            redelegateStash(_stashIds[i]);
        }
    }

    function cancelRedelegation(bytes32 _stashId) public {

        require(isStashBridged[_stashId] == false, "CR0");

        require(
            msg.sender == stashes[_stashId].staker,
            "CR1"
        );
        require(_cancelRedelegation(_stashId), "CR2");
    }

    function _cancelRedelegation(bytes32 _stashId) internal returns(bool) {

        require(isStashBridged[_stashId] == false, "_CR0");

        bytes32 _lockId = keccak256(abi.encodePacked(REDELEGATION_LOCK_SELECTOR, _stashId));
        if(locks[_lockId].unlockBlock != 0) {
            delete locks[_lockId];
            emit RedelegationCancelled(_stashId);
            return true;
        }
        return false;
    }

    function undelegateStash(bytes32 _stashId) public {

        require(isStashBridged[_stashId] == false, "US0");

        Stash memory _stash = stashes[_stashId];
        require(
            _stash.staker == msg.sender,
            "US1"
        );
        require(
            _stash.delegatedCluster != address(0),
            "US2"
        );
        uint256 _waitTime = undelegationWaitTime;
        uint256 _undelegationBlock = block.number.add(_waitTime);
        stashes[_stashId].undelegatesAt = _undelegationBlock;
        delete stashes[_stashId].delegatedCluster;
        _cancelRedelegation(_stashId);
        bytes32[] memory _tokens = rewardDelegators.getFullTokenList();
        uint256[] memory _amounts = new uint256[](_tokens.length);
        for(uint256 i=0; i < _tokens.length; i++) {
            _amounts[i] = stashes[_stashId].amount[_tokens[i]];
        }
        rewardDelegators.undelegate(msg.sender, _stash.delegatedCluster, _tokens, _amounts);
        emit StashUndelegated(_stashId, _stash.delegatedCluster, _undelegationBlock);
    }

    function undelegateStashes(bytes32[] memory _stashIds) public {

        for(uint256 i=0; i < _stashIds.length; i++) {
            undelegateStash(_stashIds[i]);
        }
    }

    function cancelUndelegation(bytes32 _stashId, address _delegatedCluster) public {

        require(isStashBridged[_stashId] == false, "CU0");

        address _staker = stashes[_stashId].staker;
        uint256 _undelegatesAt = stashes[_stashId].undelegatesAt;
        require(
            _staker == msg.sender,
            "CU1"
        );
        require(
            _undelegatesAt > block.number,
            "CU2"
        );
        require(
            _undelegatesAt < block.number
                            .add(undelegationWaitTime)
                            .sub(lockWaitTime[REDELEGATION_LOCK_SELECTOR]),
            "CU3"
        );
        delete stashes[_stashId].undelegatesAt;
        emit StashUndelegationCancelled(_stashId);
        _redelegateStash(_stashId, _staker, address(0), _delegatedCluster);
    }

    function withdrawStash(bytes32 _stashId) external {

        require(isStashBridged[_stashId] == false, "WS0");

        Stash memory _stash = stashes[_stashId];
        require(
            _stash.staker == msg.sender,
            "WS1"
        );
        require(
            _stash.delegatedCluster == address(0),
            "WS2"
        );
        require(
            _stash.undelegatesAt <= block.number,
            "WS3"
        );
        bytes32[] memory _tokens = rewardDelegators.getFullTokenList();
        uint256[] memory _amounts = new uint256[](_tokens.length);
        for(uint256 i=0; i < _tokens.length; i++) {
            _amounts[i] = stashes[_stashId].amount[_tokens[i]];
            if(_amounts[i] == 0) continue;
            delete stashes[_stashId].amount[_tokens[i]];
            _unlockTokens(_tokens[i], _amounts[i], msg.sender);
        }
        delete stashes[_stashId].staker;
        delete stashes[_stashId].undelegatesAt;
        emit StashWithdrawn(_stashId, _tokens, _amounts);
        emit StashClosed(_stashId, msg.sender);
    }

    function withdrawStash(
        bytes32 _stashId,
        bytes32[] calldata _tokens,
        uint256[] calldata _amounts
    ) external {

        require(isStashBridged[_stashId] == false, "WS0");

        Stash memory _stash = stashes[_stashId];
        require(
            _stash.staker == msg.sender,
            "WSC1"
        );
        require(
            _stash.delegatedCluster == address(0),
            "WSC2"
        );
        require(
            _stash.undelegatesAt <= block.number,
            "WSC3"
        );
        require(
            _tokens.length == _amounts.length,
            "WSC4"
        );
        for(uint256 i=0; i < _tokens.length; i++) {
            uint256 _balance = stashes[_stashId].amount[_tokens[i]];
            require(
                _balance >= _amounts[i],
                "WSC5"
            );
            if(_balance == _amounts[i]) {
                delete stashes[_stashId].amount[_tokens[i]];
            } else {
                stashes[_stashId].amount[_tokens[i]] = _balance.sub(_amounts[i]);
            }
            _unlockTokens(_tokens[i], _amounts[i], msg.sender);
        }
        emit StashWithdrawn(_stashId, _tokens, _amounts);
    }

    function _lockTokens(bytes32 _tokenId, uint256 _amount, address _delegator) internal {

        if(_amount == 0) {
            return;
        }
        address tokenAddress = tokenAddresses[_tokenId].addr;
        require(
            ERC20(tokenAddress).transferFrom(
                _delegator,
                address(this),
                _amount
            ), "LT1"
        );
        if (tokenAddress == address(MPOND)) {
            MPOND.delegate(
                _delegator,
                uint96(_amount)
            );
        }
    }

    function _unlockTokens(bytes32 _tokenId, uint256 _amount, address _delegator) internal {

        if(_amount == 0) {
            return;
        }
        address tokenAddress = tokenAddresses[_tokenId].addr;
        if(tokenAddress == address(MPOND)) {
            MPOND.undelegate(
                _delegator,
                uint96(_amount)
            );
        } else if(tokenAddress == address(prevMPOND)) {
            prevMPOND.undelegate(
                _delegator,
                uint96(_amount)
            );
        }
        require(
            ERC20(tokenAddress).transfer(
                _delegator,
                _amount
            ), "UT1"
        );
    }

    function getTokenAmountInStash(bytes32 _stashId, bytes32 _tokenId) external view returns(uint256) {

        return stashes[_stashId].amount[_tokenId];
    }

    function transferStashL2(
        address _to,
        bytes32[] calldata _stashIds,
        uint256 _maxGas,
        uint256 _gasPriceBid
    ) external payable returns (uint256) {

        bytes32[] memory _tokens = rewardDelegators.getFullTokenList();
        uint256[] memory _amounts = new uint256[](_tokens.length * _stashIds.length);
        address[] memory _delegatedClusters = new address[](_stashIds.length);

        for(uint256 idx = 0; idx < _stashIds.length; idx++) {
            bytes32 _stashId = _stashIds[idx];
            address _staker = stashes[_stashId].staker;
            address _delegatedCluster = stashes[_stashId].delegatedCluster;
            uint256 _undelegatesAt = stashes[_stashId].undelegatesAt;

            require(isStashBridged[_stashId] == false, "TL20");
            isStashBridged[_stashId] = true;

            require(_staker == msg.sender, "TL21");

            require(_delegatedCluster != address(0), "TL22");

            require(_undelegatesAt < block.number, "TL23");

            _delegatedClusters[idx] = _delegatedCluster;

            for(uint256 i=0; i < _tokens.length; i++) {
                uint256 _amount = stashes[_stashId].amount[_tokens[i]];
                if(_amount == 0) {
                    continue;
                }

                amountBridged[_tokens[i]] += _amount;

                address tokenAddress = tokenAddresses[_tokens[i]].addr;
                if(tokenAddress == address(MPOND)) {
                    MPOND.undelegate(
                        _staker,
                        uint96(_amount)
                    );
                } else if(tokenAddress == address(prevMPOND)) {
                    prevMPOND.undelegate(
                        _staker,
                        uint96(_amount)
                    );
                }

                _amounts[idx * _tokens.length + i] = _amount;
            }
        }

        bytes memory _data = abi.encodeWithSignature(
            "transferL2(address,bytes32[],uint256[],address[])",
            _to, _tokens, _amounts, _delegatedClusters
        );

        bytes memory callAbi = abi.encodeWithSignature(
            "createRetryableTicket(address,uint256,uint256,address,address,uint256,uint256,bytes)",
            gatewayL2,
            0,
            msg.value - _maxGas * _gasPriceBid,
            _to,
            _to,
            _maxGas,
            _gasPriceBid,
            _data
        );

        (bool success, bytes memory returnValue) = inbox.call.value(msg.value)(callAbi);
        require(success, "InboxCall");
        (uint256 _ticketId) = abi.decode(returnValue, (uint256));

        emit StashesBridged(
            _ticketId,
            _stashIds
        );

        return _ticketId;
    }

    function transferTokenL2(
        bytes32 _tokenId,
        uint256 _maxGas,
        uint256 _gasPriceBid
    ) external onlyOwner payable returns (uint256) {

        address _tokenAddress = tokenAddresses[_tokenId].addr;
        address _tokenGateway = tokenGateways[_tokenId];
        uint256 _amount = amountBridged[_tokenId];
        amountBridged[_tokenId] = 0;

        ERC20(_tokenAddress).approve(
            _tokenGateway,
            _amount
        );

        bytes memory callAbi = abi.encodeWithSignature(
            "transferL2(address,uint256,uint256,uint256)",
            stakeManagerL2,
            _amount,
            _maxGas,
            _gasPriceBid
        );

        (bool success, bytes memory returnValue) = _tokenGateway.call.value(msg.value)(callAbi);
        require(success, "TGCall");
        (uint256 _ticketId) = abi.decode(returnValue, (uint256));

        return _ticketId;
    }
}