pragma solidity ^0.8.0;

interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);


  function approve(address spender, uint256 value) external returns (bool success);


  function balanceOf(address owner) external view returns (uint256 balance);


  function decimals() external view returns (uint8 decimalPlaces);


  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);


  function increaseApproval(address spender, uint256 subtractedValue) external;


  function name() external view returns (string memory tokenName);


  function symbol() external view returns (string memory tokenSymbol);


  function totalSupply() external view returns (uint256 totalTokensIssued);


  function transfer(address to, uint256 value) external returns (bool success);


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);


  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);

}// MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {

  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );


  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);


  function createSubscription() external returns (uint64 subId);


  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );


  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;


  function acceptSubscriptionOwnerTransfer(uint64 subId) external;


  function addConsumer(uint64 subId, address consumer) external;


  function removeConsumer(uint64 subId, address consumer) external;


  function cancelSubscription(uint64 subId, address to) external;

}// MIT
pragma solidity ^0.8.0;

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.1;

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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
pragma solidity ^0.8.7;



contract Random is VRFConsumerBaseV2 {

  using SafeERC20 for ERC20;

  VRFCoordinatorV2Interface public COORDINATOR;
  LinkTokenInterface public LINKTOKEN;

  uint64 s_subscriptionId;

  ERC20 public usdt;

  uint public gameDuration;

  uint public startTime;

  uint public ticketSize = 1 * 10 ** 6;

  uint public percentagePrecision = 10 ** 2;

  uint public linkFeePercent = 20 * percentagePrecision;

  uint public houseFeePercent = 5 * percentagePrecision; // 5%

  uint public feePercentage = linkFeePercent + houseFeePercent; // 25%

  uint public revenueSplitPercentage = 20 * percentagePrecision; // 20%

  uint public revenueSplitRollThreshold = 60 * 10 ** 4; // 600k

  uint public revenue;

  uint public totalRevenueSplitShares;

  mapping(address => uint) public revenueSplitSharesPerUser;

  mapping (address => uint) public revenueSplitCollectedPerUser;

  uint public feesCollected;

  uint public bootstrapWinnings;

  bool public isBootstrapped;

  DiceRoll public currentWinner;

  DiceRoll public winner;

  uint public winningNumber = 888888;

  mapping (uint => address) public rollRequests;

  uint public rollCount;

  mapping (uint => DiceRoll) public diceRolls;

  address public vrfCoordinator;

  address public link = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
  bytes32 public keyHash = 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef;
  
  uint32 public callbackGasLimit = 600000;

  uint16 public requestConfirmations = 3;

  bool public isSingleRollEnabled = false;

  address owner;

  struct DiceRoll {
    uint roll;
    address roller;
  }

  event LogNewRollRequest(uint requestId, address indexed roller);
  event LogOnRollResult(uint requestId, uint rollId, uint roll, address indexed roller);
  event LogNewCurrentWinner(uint requestId, uint rollId, uint roll, address indexed roller);
  event LogDiscardedRollResult(uint requestId, uint rollId, address indexed roller);
  event LogGameOver(address indexed winner, uint winnings); 
  event LogOnCollectRevenueSplit(address indexed user, uint split);
  event LogAddToRevenue(uint amount);
  event LogToggleEnableSingleRoll(bool enabled);

  constructor(
    uint64 subscriptionId,
    address _usdt,
    address _vrfCoordinator,
    uint _gameDuration
  ) VRFConsumerBaseV2(_vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
    LINKTOKEN = LinkTokenInterface(link);
    owner = msg.sender;
    s_subscriptionId = subscriptionId;
    vrfCoordinator = _vrfCoordinator;
    usdt = ERC20(_usdt);
    gameDuration = _gameDuration;
  }

  function setCoordinator(address _coordinator) 
  public
  onlyOwner 
  returns (bool) {
    require(!isBootstrapped, "Contract is already bootstrapped");
    vrfCoordinator = _coordinator;
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    return true;
  }

  function bootstrap(
    uint _bootstrapWinnings
  )
  public
  onlyOwner
  returns (bool) {
    require(!isBootstrapped, "Game already bootstrapped");
    bootstrapWinnings = _bootstrapWinnings;
    revenue += _bootstrapWinnings;
    isBootstrapped = true;
    startTime = block.timestamp;
    usdt.safeTransferFrom(msg.sender, address(this), _bootstrapWinnings);
    return true;
  }

  function collectFees() 
  public
  returns (bool) {
    uint fees = getFees();
    feesCollected += fees;
    usdt.safeTransfer(owner, fees);
    return true;
  }

  function fulfillRandomWords(
    uint256 requestId, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    for (uint i = 0; i < randomWords.length; i++) {
      diceRolls[++rollCount].roll = getFormattedNumber(randomWords[i]);
      diceRolls[rollCount].roller = rollRequests[requestId];

      if (!isGameOver()) {
        if (diceRolls[rollCount].roll == winningNumber || rollCount == 2) {
          winner = diceRolls[rollCount];
          collectFees();
          uint revenueSplit = getRevenueSplit();
          uint winnings = revenue - feesCollected - revenueSplit;
          usdt.safeTransfer(winner.roller, winnings);
          emit LogGameOver(winner.roller, winnings);
        } else if (diceRolls[rollCount].roll >= revenueSplitRollThreshold) {
          totalRevenueSplitShares += 1;
          revenueSplitSharesPerUser[diceRolls[rollCount].roller] += 1;
        }

        if (diceRolls[rollCount].roll != winningNumber) {
          int diff = getDiff(diceRolls[rollCount].roll, winningNumber);
          int currentWinnerDiff = getDiff(currentWinner.roll, winningNumber);

          if (diff <= currentWinnerDiff)  {
            currentWinner = diceRolls[rollCount];
            emit LogNewCurrentWinner(requestId, rollCount, diceRolls[rollCount].roll, diceRolls[rollCount].roller);
          }
        }
      } else
        emit LogDiscardedRollResult(requestId, rollCount, diceRolls[rollCount].roller);

      emit LogOnRollResult(requestId, rollCount, diceRolls[rollCount].roll, diceRolls[rollCount].roller);
    }
  }

  function getDiff(uint a, uint b) private pure returns (int) {
    unchecked {
      int x = int(a-b);
      return x >= 0 ? x : -x;
    }
  }

  function endGame()
  public
  returns (bool) {
    require(
      hasGameDurationElapsed() && winner.roller == address(0), 
      "Game duration hasn't elapsed without a winner"
    );
    winner = currentWinner;
    collectFees();
    uint revenueSplit = getRevenueSplit();
    uint winnings = revenue - feesCollected - revenueSplit;
    usdt.safeTransfer(winner.roller, winnings);
    emit LogGameOver(winner.roller, winnings);
    return true;
  }

  function collectRevenueSplit() external {
    require(isGameOver(), "Game isn't over");
    require(revenueSplitSharesPerUser[msg.sender] > 0, "User does not have any revenue split shares");
    require(revenueSplitCollectedPerUser[msg.sender] == 0, "User has already collected revenue split");
    uint revenueSplit = getRevenueSplit();
    uint userRevenueSplit = revenueSplit * revenueSplitSharesPerUser[msg.sender] / totalRevenueSplitShares; 
    revenueSplitCollectedPerUser[msg.sender] = userRevenueSplit;
    usdt.safeTransfer(msg.sender, userRevenueSplit);
    emit LogOnCollectRevenueSplit(msg.sender, userRevenueSplit);
  }

  function rollDice() external {
    require(isSingleRollEnabled, "Single rolls are not currently enabled");
    require(isBootstrapped, "Game is not bootstrapped");
    require(!isGameOver(), "Game is over");
    revenue += ticketSize;
    usdt.safeTransferFrom(msg.sender, address(this), ticketSize);
    
    uint requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      1
    );
    rollRequests[requestId] = msg.sender;

    emit LogNewRollRequest(requestId, msg.sender);
  }

  function rollMultipleDice(uint32 times) external {
    require(isBootstrapped, "Game is not bootstrapped");
    require(!isGameOver(), "Game is over");
    require(times > 1 && times <= 5, "Should be >=1 and <=5 rolls in 1 txn");
    uint total = ticketSize * times;
    revenue += total;
    usdt.safeTransferFrom(msg.sender, address(this), total);
    
    uint requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      times
    );
    rollRequests[requestId] = msg.sender;
    emit LogNewRollRequest(requestId, msg.sender);
  }

  function getFees()
  public
  view
  returns (uint) {
    return ((revenue * feePercentage) / (100 * percentagePrecision)) - feesCollected;
  }

  function getRevenueSplit()
  public
  view
  returns (uint) {
    return ((revenue * revenueSplitPercentage) / (100 * percentagePrecision));
  }

  function getFormattedNumber(
    uint number
  )
  public
  pure
  returns (uint) {
    return number % 1000000 + 1;
  }

  function isGameOver()
  public
  view
  returns (bool) {
    return winner.roller != address(0) || hasGameDurationElapsed();
  }

  function hasGameDurationElapsed()
  public
  view
  returns (bool) {
    return block.timestamp > startTime + gameDuration;
  }

  function updateCallbackGasLimit(uint32 limit)
  public
  onlyOwner returns (bool) {
    require(limit >= 500000, "Limit must be >=500000");
    callbackGasLimit = limit;
    return true;
  }

  function addToRevenue(uint amount)
  public
  onlyOwner returns (bool) {
    revenue += amount;
    usdt.safeTransferFrom(msg.sender, address(this), amount);
    emit LogAddToRevenue(amount);
    return true;
  }

  function toggleEnableSingleRoll(bool enabled)
  public
  onlyOwner
  returns (bool) {
    isSingleRollEnabled = enabled;
    emit LogToggleEnableSingleRoll(enabled);
    return true;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}