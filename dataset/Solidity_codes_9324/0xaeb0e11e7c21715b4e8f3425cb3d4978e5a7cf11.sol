
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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
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
}// MIT

pragma solidity ^0.8.0;

interface IStaking {

  struct Stake {
    uint256 duration;
    uint256 balance;
    uint256 timestamp;
  }

  event Transfer(address indexed from, address indexed to, uint256 tokens);

  event ScheduleDurationChange(uint256 indexed unlockTimestamp);

  event CancelDurationChange();

  event CompleteDurationChange(uint256 indexed newDuration);

  event ProposeDelegate(address indexed delegate, address indexed account);

  event SetDelegate(address indexed delegate, address indexed account);

  function stake(uint256 amount) external;


  function unstake(uint256 amount) external;


  function getStakes(address account)
    external
    view
    returns (Stake memory accountStake);


  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function decimals() external view returns (uint8);


  function stakeFor(address account, uint256 amount) external;


  function available(address account) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IPool {

  event Withdraw(
    uint256 indexed nonce,
    uint256 indexed expiry,
    address indexed account,
    address token,
    uint256 amount,
    uint256 score
  );
  event SetScale(uint256 scale);
  event SetMax(uint256 max);
  event DrainTo(address[] tokens, address dest);

  function setScale(uint256 _scale) external;


  function setMax(uint256 _max) external;


  function addAdmin(address _admin) external;


  function removeAdmin(address _admin) external;


  function setStakingContract(address _stakingContract) external;


  function setStakingToken(address _stakingToken) external;


  function drainTo(address[] calldata tokens, address dest) external;


  function withdraw(
    address token,
    uint256 nonce,
    uint256 expiry,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;


  function withdrawWithRecipient(
    uint256 minimumAmount,
    address token,
    address recipient,
    uint256 nonce,
    uint256 expiry,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;


  function withdrawAndStake(
    uint256 minimumAmount,
    address token,
    uint256 nonce,
    uint256 expiry,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;


  function withdrawAndStakeFor(
    uint256 minimumAmount,
    address token,
    address account,
    uint256 nonce,
    uint256 expiry,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;


  function withdrawProtected(
    uint256 minimumAmount,
    address recipient,
    address token,
    uint256 nonce,
    uint256 expiry,
    address participant,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256);


  function calculate(uint256 score, address token)
    external
    view
    returns (uint256 amount);


  function verify(
    uint256 nonce,
    uint256 expiry,
    address participant,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external view returns (bool valid);


  function nonceUsed(address participant, uint256 nonce)
    external
    view
    returns (bool);

}// MIT

pragma solidity ^0.8.0;


contract Pool is IPool, Ownable {

  using SafeERC20 for IERC20;

  bytes32 public constant DOMAIN_TYPEHASH =
    keccak256(
      abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "uint256 chainId,",
        "address verifyingContract",
        ")"
      )
    );

  bytes32 public constant CLAIM_TYPEHASH =
    keccak256(
      abi.encodePacked(
        "Claim(",
        "uint256 nonce,",
        "uint256 expiry,",
        "address participant,",
        "uint256 score",
        ")"
      )
    );

  bytes32 public constant DOMAIN_NAME = keccak256("POOL");
  bytes32 public constant DOMAIN_VERSION = keccak256("1");
  uint256 public immutable DOMAIN_CHAIN_ID;
  bytes32 public immutable DOMAIN_SEPARATOR;

  uint256 internal constant MAX_PERCENTAGE = 100;
  uint256 internal constant MAX_SCALE = 77;

  uint256 public scale;

  uint256 public max;

  mapping(address => bool) public admins;

  mapping(address => mapping(uint256 => uint256)) internal noncesClaimed;

  address public stakingContract;

  address public stakingToken;

  constructor(
    uint256 _scale,
    uint256 _max,
    address _stakingContract,
    address _stakingToken
  ) {
    require(_max <= MAX_PERCENTAGE, "MAX_TOO_HIGH");
    require(_scale <= MAX_SCALE, "SCALE_TOO_HIGH");
    scale = _scale;
    max = _max;
    stakingContract = _stakingContract;
    stakingToken = _stakingToken;
    admins[msg.sender] = true;

    uint256 currentChainId = getChainId();
    DOMAIN_CHAIN_ID = currentChainId;
    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        DOMAIN_TYPEHASH,
        DOMAIN_NAME,
        DOMAIN_VERSION,
        currentChainId,
        this
      )
    );

    IERC20(stakingToken).safeApprove(stakingContract, 2**256 - 1);
  }

  function setScale(uint256 _scale) external override onlyOwner {

    require(_scale <= MAX_SCALE, "SCALE_TOO_HIGH");
    scale = _scale;
    emit SetScale(scale);
  }

  function setMax(uint256 _max) external override onlyOwner {

    require(_max <= MAX_PERCENTAGE, "MAX_TOO_HIGH");
    max = _max;
    emit SetMax(max);
  }

  function addAdmin(address _admin) external override onlyOwner {

    require(_admin != address(0), "INVALID_ADDRESS");
    admins[_admin] = true;
  }

  function removeAdmin(address _admin) external override onlyOwner {

    require(admins[_admin] == true, "ADMIN_NOT_SET");
    admins[_admin] = false;
  }

  function setStakingContract(address _stakingContract)
    external
    override
    onlyOwner
  {

    require(_stakingContract != address(0), "INVALID_ADDRESS");
    IERC20(stakingToken).safeApprove(stakingContract, 0);
    stakingContract = _stakingContract;
    IERC20(stakingToken).safeApprove(stakingContract, 2**256 - 1);
  }

  function setStakingToken(address _stakingToken) external override onlyOwner {

    require(_stakingToken != address(0), "INVALID_ADDRESS");
    IERC20(stakingToken).safeApprove(stakingContract, 0);
    stakingToken = _stakingToken;
    IERC20(stakingToken).safeApprove(stakingContract, 2**256 - 1);
  }

  function drainTo(address[] calldata tokens, address dest)
    external
    override
    onlyOwner
  {

    for (uint256 i = 0; i < tokens.length; i++) {
      uint256 bal = IERC20(tokens[i]).balanceOf(address(this));
      IERC20(tokens[i]).safeTransfer(dest, bal);
    }
    emit DrainTo(tokens, dest);
  }

  function withdraw(
    address token,
    uint256 nonce,
    uint256 expiry,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override {

    withdrawProtected(0, msg.sender, token, nonce, expiry, msg.sender, score, v, r, s);
  }

  function withdrawWithRecipient(
    uint256 minimumAmount,
    address token,
    address recipient,
    uint256 nonce,
    uint256 expiry,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override {

    withdrawProtected(
      minimumAmount,
      recipient,
      token,
      nonce,
      expiry,
      msg.sender,
      score,
      v,
      r,
      s
    );
  }

  function withdrawAndStake(
    uint256 minimumAmount,
    address token,
    uint256 nonce,
    uint256 expiry,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override {

    require(token == address(stakingToken), "INVALID_TOKEN");
    _checkValidClaim(nonce, expiry, msg.sender, score, v, r, s);
    uint256 amount = _withdrawCheck(score, token, minimumAmount);
    IStaking(stakingContract).stakeFor(msg.sender, amount);
    emit Withdraw(nonce, expiry, msg.sender, token, amount, score);
  }

  function withdrawAndStakeFor(
    uint256 minimumAmount,
    address token,
    address account,
    uint256 nonce,
    uint256 expiry,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override {

    require(token == address(stakingToken), "INVALID_TOKEN");
    _checkValidClaim(nonce, expiry, msg.sender, score, v, r, s);
    uint256 amount = _withdrawCheck(score, token, minimumAmount);
    IStaking(stakingContract).stakeFor(account, amount);
    emit Withdraw(nonce, expiry, msg.sender, token, amount, score);
  }

  function withdrawProtected(
    uint256 minimumAmount,
    address recipient,
    address token,
    uint256 nonce,
    uint256 expiry,
    address participant,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public override returns (uint256) {

    _checkValidClaim(nonce, expiry, participant, score, v, r, s);
    uint256 amount = _withdrawCheck(score, token, minimumAmount);
    IERC20(token).safeTransfer(recipient, amount);
    emit Withdraw(nonce, expiry, participant, token, amount, score);
    return amount;
  }

  function calculate(uint256 score, address token)
    public
    view
    override
    returns (uint256 amount)
  {

    uint256 balance = IERC20(token).balanceOf(address(this));
    uint256 divisor = (uint256(10)**scale) + score;
    return (max * score * balance) / divisor / 100;
  }

  function verify(
    uint256 nonce,
    uint256 expiry,
    address participant,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public view override returns (bool valid) {

    require(DOMAIN_CHAIN_ID == getChainId(), "CHAIN_ID_CHANGED");
    require(expiry > block.timestamp, "EXPIRY_PASSED");
    bytes32 claimHash = keccak256(
      abi.encode(CLAIM_TYPEHASH, nonce, expiry, participant, score)
    );
    address signatory = ecrecover(
      keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, claimHash)),
      v,
      r,
      s
    );
    admins[signatory] && !nonceUsed(participant, nonce)
      ? valid = true
      : valid = false;
  }

  function nonceUsed(address participant, uint256 nonce)
    public
    view
    override
    returns (bool)
  {

    uint256 groupKey = nonce / 256;
    uint256 indexInGroup = nonce % 256;
    return (noncesClaimed[participant][groupKey] >> indexInGroup) & 1 == 1;
  }

  function getChainId() public view returns (uint256 id) {

    assembly {
      id := chainid()
    }
  }

  function _checkValidClaim(
    uint256 nonce,
    uint256 expiry,
    address participant,
    uint256 score,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal {

    require(DOMAIN_CHAIN_ID == getChainId(), "CHAIN_ID_CHANGED");
    require(expiry > block.timestamp, "EXPIRY_PASSED");
    bytes32 claimHash = keccak256(
      abi.encode(CLAIM_TYPEHASH, nonce, expiry, participant, score)
    );
    address signatory = ecrecover(
      keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, claimHash)),
      v,
      r,
      s
    );
    require(admins[signatory], "UNAUTHORIZED");
    require(_markNonceAsUsed(participant, nonce), "NONCE_ALREADY_USED");
  }

  function _markNonceAsUsed(address participant, uint256 nonce)
    internal
    returns (bool)
  {

    uint256 groupKey = nonce / 256;
    uint256 indexInGroup = nonce % 256;
    uint256 group = noncesClaimed[participant][groupKey];

    if ((group >> indexInGroup) & 1 == 1) {
      return false;
    }

    noncesClaimed[participant][groupKey] = group | (uint256(1) << indexInGroup);

    return true;
  }

  function _withdrawCheck(
    uint256 score,
    address token,
    uint256 minimumAmount
  ) internal view returns (uint256) {

    require(score > 0, "SCORE_MUST_BE_PROVIDED");
    uint256 amount = calculate(score, token);
    require(amount >= minimumAmount, "INSUFFICIENT_AMOUNT");
    return amount;
  }
}