




pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

interface ICreditLine {

  function borrower() external view returns (address);


  function limit() external view returns (uint256);


  function maxLimit() external view returns (uint256);


  function interestApr() external view returns (uint256);


  function paymentPeriodInDays() external view returns (uint256);


  function principalGracePeriodInDays() external view returns (uint256);


  function termInDays() external view returns (uint256);


  function lateFeeApr() external view returns (uint256);


  function isLate() external view returns (bool);


  function withinPrincipalGracePeriod() external view returns (bool);


  function balance() external view returns (uint256);


  function interestOwed() external view returns (uint256);


  function principalOwed() external view returns (uint256);


  function termEndTime() external view returns (uint256);


  function nextDueTime() external view returns (uint256);


  function interestAccruedAsOf() external view returns (uint256);


  function lastFullPaymentTime() external view returns (uint256);

}



pragma solidity ^0.8.7;


abstract contract IV2CreditLine is ICreditLine {
  function principal() external view virtual returns (uint256);

  function totalInterestAccrued() external view virtual returns (uint256);

  function termStartTime() external view virtual returns (uint256);

  function setLimit(uint256 newAmount) external virtual;

  function setMaxLimit(uint256 newAmount) external virtual;

  function setBalance(uint256 newBalance) external virtual;

  function setPrincipal(uint256 _principal) external virtual;

  function setTotalInterestAccrued(uint256 _interestAccrued) external virtual;

  function drawdown(uint256 amount) external virtual;

  function assess()
    external
    virtual
    returns (
      uint256,
      uint256,
      uint256
    );

  function initialize(
    address _config,
    address owner,
    address _borrower,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr,
    uint256 _principalGracePeriodInDays
  ) public virtual;

  function setTermEndTime(uint256 newTermEndTime) external virtual;

  function setNextDueTime(uint256 newNextDueTime) external virtual;

  function setInterestOwed(uint256 newInterestOwed) external virtual;

  function setPrincipalOwed(uint256 newPrincipalOwed) external virtual;

  function setInterestAccruedAsOf(uint256 newInterestAccruedAsOf) external virtual;

  function setWritedownAmount(uint256 newWritedownAmount) external virtual;

  function setLastFullPaymentTime(uint256 newLastFullPaymentTime) external virtual;

  function setLateFeeApr(uint256 newLateFeeApr) external virtual;

  function updateGoldfinchConfig() external virtual;
}



pragma solidity ^0.8.7;


abstract contract ITranchedPool {
  IV2CreditLine public creditLine;
  uint256 public createdAt;

  enum Tranches {
    Reserved,
    Senior,
    Junior
  }

  struct TrancheInfo {
    uint256 id;
    uint256 principalDeposited;
    uint256 principalSharePrice;
    uint256 interestSharePrice;
    uint256 lockedUntil;
  }

  struct PoolSlice {
    TrancheInfo seniorTranche;
    TrancheInfo juniorTranche;
    uint256 totalInterestAccrued;
    uint256 principalDeployed;
  }

  struct SliceInfo {
    uint256 reserveFeePercent;
    uint256 interestAccrued;
    uint256 principalAccrued;
  }

  struct ApplyResult {
    uint256 interestRemaining;
    uint256 principalRemaining;
    uint256 reserveDeduction;
    uint256 oldInterestSharePrice;
    uint256 oldPrincipalSharePrice;
  }

  function initialize(
    address _config,
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr,
    uint256 _principalGracePeriodInDays,
    uint256 _fundableAt,
    uint256[] calldata _allowedUIDTypes
  ) public virtual;

  function getTranche(uint256 tranche) external view virtual returns (TrancheInfo memory);

  function pay(uint256 amount) external virtual;

  function lockJuniorCapital() external virtual;

  function lockPool() external virtual;

  function initializeNextSlice(uint256 _fundableAt) external virtual;

  function totalJuniorDeposits() external view virtual returns (uint256);

  function drawdown(uint256 amount) external virtual;

  function setFundableAt(uint256 timestamp) external virtual;

  function deposit(uint256 tranche, uint256 amount) external virtual returns (uint256 tokenId);

  function assess() external virtual;

  function depositWithPermit(
    uint256 tranche,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external virtual returns (uint256 tokenId);

  function availableToWithdraw(uint256 tokenId)
    external
    view
    virtual
    returns (uint256 interestRedeemable, uint256 principalRedeemable);

  function withdraw(uint256 tokenId, uint256 amount)
    external
    virtual
    returns (uint256 interestWithdrawn, uint256 principalWithdrawn);

  function withdrawMax(uint256 tokenId)
    external
    virtual
    returns (uint256 interestWithdrawn, uint256 principalWithdrawn);

  function withdrawMultiple(uint256[] calldata tokenIds, uint256[] calldata amounts)
    external
    virtual;
}



pragma solidity ^0.8.7;


abstract contract ISeniorPool {
  uint256 public sharePrice;
  uint256 public totalLoansOutstanding;
  uint256 public totalWritedowns;

  function deposit(uint256 amount) external virtual returns (uint256 depositShares);

  function depositWithPermit(
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external virtual returns (uint256 depositShares);

  function withdraw(uint256 usdcAmount) external virtual returns (uint256 amount);

  function withdrawInFidu(uint256 fiduAmount) external virtual returns (uint256 amount);

  function sweepToCompound() public virtual;

  function sweepFromCompound() public virtual;

  function invest(ITranchedPool pool) public virtual;

  function estimateInvestment(ITranchedPool pool) public view virtual returns (uint256);

  function redeem(uint256 tokenId) public virtual;

  function writedown(uint256 tokenId) public virtual;

  function calculateWritedown(uint256 tokenId)
    public
    view
    virtual
    returns (uint256 writedownAmount);

  function assets() public view virtual returns (uint256);

  function getNumShares(uint256 amount) public view virtual returns (uint256);
}




pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}




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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}




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
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}




pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}



pragma solidity ^0.8.7;



interface IPoolTokens is IERC721, IERC721Enumerable {

  event TokenMinted(
    address indexed owner,
    address indexed pool,
    uint256 indexed tokenId,
    uint256 amount,
    uint256 tranche
  );

  event TokenRedeemed(
    address indexed owner,
    address indexed pool,
    uint256 indexed tokenId,
    uint256 principalRedeemed,
    uint256 interestRedeemed,
    uint256 tranche
  );
  event TokenBurned(address indexed owner, address indexed pool, uint256 indexed tokenId);

  struct TokenInfo {
    address pool;
    uint256 tranche;
    uint256 principalAmount;
    uint256 principalRedeemed;
    uint256 interestRedeemed;
  }

  struct MintParams {
    uint256 principalAmount;
    uint256 tranche;
  }

  function mint(MintParams calldata params, address to) external returns (uint256);


  function redeem(
    uint256 tokenId,
    uint256 principalRedeemed,
    uint256 interestRedeemed
  ) external;


  function burn(uint256 tokenId) external;


  function onPoolCreated(address newPool) external;


  function getTokenInfo(uint256 tokenId) external view returns (TokenInfo memory);


  function validPool(address sender) external view returns (bool);


  function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);

}




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
}




pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
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

}



pragma solidity ^0.8.2;



contract AlloyxTokenCRWN is ERC20, Ownable {
  constructor() ERC20("Crown Gold", "CRWN") {}

  function mint(address _account, uint256 _amount) external onlyOwner returns (bool) {
    _mint(_account, _amount);
    return true;
  }

  function burn(address _account, uint256 _amount) external onlyOwner returns (bool) {
    _burn(_account, _amount);
    return true;
  }

  function contractName() external pure returns (string memory) {
    return "AlloyxTokenCRWN";
  }
}



pragma solidity ^0.8.2;



contract AlloyxTokenDURA is ERC20, Ownable {
  constructor() ERC20("Duralumin", "DURA") {}

  function mint(address _account, uint256 _amount) external onlyOwner returns (bool) {
    _mint(_account, _amount);
    return true;
  }

  function burn(address _account, uint256 _amount) external onlyOwner returns (bool) {
    _burn(_account, _amount);
    return true;
  }

  function contractName() external pure returns (string memory) {
    return "AlloyxTokenDura";
  }
}




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
}



pragma solidity ^0.8.7;









interface IGoldfinchDelegacy {
  function getGoldfinchDelegacyBalanceInUSDC() external view returns (uint256);

  function claimReward(
    address _rewardee,
    uint256 _amount,
    uint256 _totalSupply,
    uint256 _percentageFee
  ) external;

  function getRewardAmount(
    uint256 _amount,
    uint256 _totalSupply,
    uint256 _percentageFee
  ) external view returns (uint256);

  function purchaseJuniorToken(
    uint256 _amount,
    address _poolAddress,
    uint256 _tranche
  ) external;

  function sellJuniorToken(
    uint256 _tokenId,
    uint256 _amount,
    address _poolAddress,
    uint256 _percentageBronzeRepayment
  ) external;

  function purchaseSeniorTokens(uint256 _amount) external;

  function sellSeniorTokens(uint256 _amount, uint256 _percentageBronzeRepayment) external;

  function getJuniorTokenValue(uint256 _tokenID) external view returns (uint256);

  function isValidPool(uint256 _tokenID) external view returns (bool);
  function validatesTokenToDepositAndGetPurchasePrice(
    address _tokenAddress,
    address _depositor,
    uint256 _tokenID
  ) external returns (uint256);

  function payUsdc(address _to, uint256 _amount) external;

  function approve(
    address _tokenAddress,
    address _account,
    uint256 _amount
  ) external;
}



pragma solidity ^0.8.7;












contract AlloyxVault is ERC721Holder, Ownable, Pausable {
  using SafeERC20 for IERC20;
  using SafeERC20 for AlloyxTokenDURA;
  using SafeMath for uint256;
  struct StakeInfo {
    uint256 amount;
    uint256 since;
  }
  bool private vaultStarted;
  IERC20 private usdcCoin;
  AlloyxTokenDURA private alloyxTokenDURA;
  AlloyxTokenCRWN private alloyxTokenCRWN;
  IGoldfinchDelegacy private goldfinchDelegacy;
  mapping(address => bool) private stakeholderMap;
  mapping(address => StakeInfo) private stakesMapping;
  mapping(address => uint256) private pastRedeemableReward;
  mapping(address => bool) whitelistedAddresses;
  uint256 public percentageRewardPerYear = 2;
  uint256 public percentageDURARedemption = 1;
  uint256 public percentageDURARepayment = 2;
  uint256 public percentageCRWNEarning = 10;
  uint256 public redemptionFee = 0;
  StakeInfo totalActiveStake;
  uint256 totalPastRedeemableReward;

  event DepositStable(address _tokenAddress, address _tokenSender, uint256 _tokenAmount);
  event DepositNFT(address _tokenAddress, address _tokenSender, uint256 _tokenID);
  event DepositAlloyx(address _tokenAddress, address _tokenSender, uint256 _tokenAmount);
  event PurchaseSenior(uint256 amount);
  event SellSenior(uint256 amount);
  event PurchaseJunior(uint256 amount);
  event SellJunior(uint256 amount);
  event Mint(address _tokenReceiver, uint256 _tokenAmount);
  event Burn(address _tokenReceiver, uint256 _tokenAmount);
  event Reward(address _tokenReceiver, uint256 _tokenAmount);
  event Claim(address _tokenReceiver, uint256 _tokenAmount);
  event Stake(address _staker, uint256 _amount);
  event Unstake(address _unstaker, uint256 _amount);
  event SetField(string _field, uint256 _value);
  event ChangeAddress(string _field, address _address);
  event DepositNftForDura(address _tokenAddress, address _tokenSender, uint256 _tokenID);

  constructor(
    address _alloyxDURAAddress,
    address _alloyxCRWNAddress,
    address _usdcCoinAddress,
    address _goldfinchDelegacy
  ) {
    alloyxTokenDURA = AlloyxTokenDURA(_alloyxDURAAddress);
    alloyxTokenCRWN = AlloyxTokenCRWN(_alloyxCRWNAddress);
    usdcCoin = IERC20(_usdcCoinAddress);
    goldfinchDelegacy = IGoldfinchDelegacy(_goldfinchDelegacy);
    vaultStarted = false;
  }

  modifier whenVaultStarted() {
    require(vaultStarted, "Vault has not start accepting deposits");
    _;
  }

  modifier whenVaultNotStarted() {
    require(!vaultStarted, "Vault has already start accepting deposits");
    _;
  }

  modifier isWhitelisted(address _address) {
    require(whitelistedAddresses[_address], "You need to be whitelisted");
    _;
  }

  modifier notWhitelisted(address _address) {
    require(!whitelistedAddresses[_address], "You are whitelisted");
    _;
  }

  function startVaultOperation() external onlyOwner whenVaultNotStarted returns (bool) {
    uint256 totalBalanceInUSDC = getAlloyxDURATokenBalanceInUSDC();
    require(totalBalanceInUSDC > 0, "Vault must have positive value before start");
    alloyxTokenDURA.mint(
      address(this),
      totalBalanceInUSDC.mul(alloyMantissa()).div(usdcMantissa())
    );
    vaultStarted = true;
    return true;
  }

  function pause() external onlyOwner whenNotPaused {
    _pause();
  }

  function unpause() external onlyOwner whenPaused {
    _unpause();
  }

  function addWhitelistedUser(address _addressToWhitelist)
    public
    onlyOwner
    notWhitelisted(_addressToWhitelist)
  {
    whitelistedAddresses[_addressToWhitelist] = true;
  }

  function removeWhitelistedUser(address _addressToDeWhitelist)
    public
    onlyOwner
    isWhitelisted(_addressToDeWhitelist)
  {
    whitelistedAddresses[_addressToDeWhitelist] = false;
  }

  function isUserWhitelisted(address _whitelistedAddress) public view returns (bool) {
    return whitelistedAddresses[_whitelistedAddress];
  }

  function isStakeholder(address _address) public view returns (bool) {
    return stakeholderMap[_address];
  }

  function addStakeholder(address _stakeholder) internal {
    stakeholderMap[_stakeholder] = true;
  }

  function removeStakeholder(address _stakeholder) internal {
    stakeholderMap[_stakeholder] = false;
  }

  function stakeOf(address _stakeholder) public view returns (StakeInfo memory) {
    return stakesMapping[_stakeholder];
  }

  function resetStakeTimestamp() internal {
    if (stakesMapping[msg.sender].amount == 0) addStakeholder(msg.sender);
    addPastRedeemableReward(msg.sender, stakesMapping[msg.sender]);
    stakesMapping[msg.sender] = StakeInfo(stakesMapping[msg.sender].amount, block.timestamp);
  }

  function addStake(address _staker, uint256 _stake) internal {
    if (stakesMapping[_staker].amount == 0) addStakeholder(_staker);
    addPastRedeemableReward(_staker, stakesMapping[_staker]);
    stakesMapping[_staker] = StakeInfo(stakesMapping[_staker].amount.add(_stake), block.timestamp);
    updateTotalStakeInfoAndPastRedeemable(_stake, 0, 0, 0);
  }

  function removeStake(address _staker, uint256 _stake) internal {
    require(stakeOf(_staker).amount >= _stake, "User has insufficient dura coin staked");
    if (stakesMapping[_staker].amount == 0) addStakeholder(_staker);
    addPastRedeemableReward(_staker, stakesMapping[_staker]);
    stakesMapping[_staker] = StakeInfo(stakesMapping[_staker].amount.sub(_stake), block.timestamp);
    updateTotalStakeInfoAndPastRedeemable(0, _stake, 0, 0);
  }

  function addPastRedeemableReward(address _staker, StakeInfo storage _stake) internal {
    uint256 additionalPastRedeemableReward = calculateRewardFromStake(_stake);
    pastRedeemableReward[_staker] = pastRedeemableReward[_staker].add(
      additionalPastRedeemableReward
    );
  }

  function stake(uint256 _amount) external whenNotPaused whenVaultStarted returns (bool) {
    addStake(msg.sender, _amount);
    alloyxTokenDURA.safeTransferFrom(msg.sender, address(this), _amount);
    emit Stake(msg.sender, _amount);
    return true;
  }

  function unstake(uint256 _amount) external whenNotPaused whenVaultStarted returns (bool) {
    removeStake(msg.sender, _amount);
    alloyxTokenDURA.safeTransfer(msg.sender, _amount);
    emit Unstake(msg.sender, _amount);
    return true;
  }

  function updateTotalStakeInfoAndPastRedeemable(
    uint256 increaseInStake,
    uint256 decreaseInStake,
    uint256 increaseInPastRedeemable,
    uint256 decreaseInPastRedeemable
  ) internal {
    uint256 additionalPastRedeemableReward = calculateRewardFromStake(totalActiveStake);
    totalPastRedeemableReward = totalPastRedeemableReward.add(additionalPastRedeemableReward);
    totalPastRedeemableReward = totalPastRedeemableReward.add(increaseInPastRedeemable).sub(
      decreaseInPastRedeemable
    );
    totalActiveStake = StakeInfo(
      totalActiveStake.amount.add(increaseInStake).sub(decreaseInStake),
      block.timestamp
    );
  }

  function resetStakeTimestampWithRewardLeft(uint256 _reward) internal {
    resetStakeTimestamp();
    adjustTotalStakeWithRewardLeft(_reward);
    pastRedeemableReward[msg.sender] = _reward;
  }

  function adjustTotalStakeWithRewardLeft(uint256 _reward) internal {
    uint256 increaseInPastReward = 0;
    uint256 decreaseInPastReward = 0;
    if (pastRedeemableReward[msg.sender] >= _reward) {
      decreaseInPastReward = pastRedeemableReward[msg.sender].sub(_reward);
    } else {
      increaseInPastReward = _reward.sub(pastRedeemableReward[msg.sender]);
    }
    updateTotalStakeInfoAndPastRedeemable(0, 0, increaseInPastReward, decreaseInPastReward);
  }

  function calculateRewardFromStake(StakeInfo memory _stake) internal view returns (uint256) {
    return
      _stake
        .amount
        .mul(block.timestamp.sub(_stake.since))
        .mul(percentageRewardPerYear)
        .div(100)
        .div(365 days);
  }

  function claimableCRWNToken(address _receiver) public view returns (uint256) {
    StakeInfo memory stakeValue = stakeOf(_receiver);
    return pastRedeemableReward[_receiver] + calculateRewardFromStake(stakeValue);
  }

  function totalClaimableCRWNToken() public view returns (uint256) {
    return calculateRewardFromStake(totalActiveStake) + totalPastRedeemableReward;
  }

  function totalClaimableAndClaimedCRWNToken() public view returns (uint256) {
    return totalClaimableCRWNToken().add(alloyxTokenCRWN.totalSupply());
  }

  function claimAllAlloyxCRWN() external whenNotPaused whenVaultStarted returns (bool) {
    uint256 reward = claimableCRWNToken(msg.sender);
    alloyxTokenCRWN.mint(msg.sender, reward);
    resetStakeTimestampWithRewardLeft(0);
    emit Claim(msg.sender, reward);
    return true;
  }

  function claimAlloyxCRWN(uint256 _amount) external whenNotPaused whenVaultStarted returns (bool) {
    uint256 allReward = claimableCRWNToken(msg.sender);
    require(allReward >= _amount, "User has claimed more than he's entitled");
    alloyxTokenCRWN.mint(msg.sender, _amount);
    resetStakeTimestampWithRewardLeft(allReward.sub(_amount));
    emit Claim(msg.sender, _amount);
    return true;
  }

  function claimReward(uint256 _amount) external whenNotPaused whenVaultStarted returns (bool) {
    require(
      alloyxTokenCRWN.balanceOf(address(msg.sender)) >= _amount,
      "Balance of crown coin must be larger than the amount to claim"
    );
    goldfinchDelegacy.claimReward(
      msg.sender,
      _amount,
      totalClaimableAndClaimedCRWNToken(),
      percentageCRWNEarning
    );
    alloyxTokenCRWN.burn(msg.sender, _amount);
    emit Reward(msg.sender, _amount);
    return true;
  }

  function getRewardTokenCount(uint256 _amount) external view returns (uint256) {
    return
      goldfinchDelegacy.getRewardAmount(
        _amount,
        totalClaimableAndClaimedCRWNToken(),
        percentageCRWNEarning
      );
  }

  function approveDelegacy(
    address _tokenAddress,
    address _account,
    uint256 _amount
  ) external onlyOwner {
    goldfinchDelegacy.approve(_tokenAddress, _account, _amount);
  }

  function getAlloyxDURATokenBalanceInUSDC() public view returns (uint256) {
    uint256 totalValue = getUSDCBalance().add(
      goldfinchDelegacy.getGoldfinchDelegacyBalanceInUSDC()
    );
    require(
      totalValue > redemptionFee,
      "the value of vault is not larger than redemption fee, something went wrong"
    );
    return
      getUSDCBalance().add(goldfinchDelegacy.getGoldfinchDelegacyBalanceInUSDC()).sub(
        redemptionFee
      );
  }

  function getUSDCBalance() internal view returns (uint256) {
    return usdcCoin.balanceOf(address(this));
  }

  function alloyxDURAToUSDC(uint256 _amount) public view returns (uint256) {
    uint256 alloyDURATotalSupply = alloyxTokenDURA.totalSupply();
    uint256 totalVaultAlloyxDURAValueInUSDC = getAlloyxDURATokenBalanceInUSDC();
    return _amount.mul(totalVaultAlloyxDURAValueInUSDC).div(alloyDURATotalSupply);
  }

  function usdcToAlloyxDURA(uint256 _amount) public view returns (uint256) {
    uint256 alloyDURATotalSupply = alloyxTokenDURA.totalSupply();
    uint256 totalVaultAlloyxDURAValueInUSDC = getAlloyxDURATokenBalanceInUSDC();
    return _amount.mul(alloyDURATotalSupply).div(totalVaultAlloyxDURAValueInUSDC);
  }

  function setPercentageRewardPerYear(uint256 _percentageRewardPerYear) external onlyOwner {
    percentageRewardPerYear = _percentageRewardPerYear;
    emit SetField("percentageRewardPerYear", _percentageRewardPerYear);
  }

  function setPercentageDURARedemption(uint256 _percentageDURARedemption) external onlyOwner {
    percentageDURARedemption = _percentageDURARedemption;
    emit SetField("percentageDURARedemption", _percentageDURARedemption);
  }

  function setPercentageDURARepayment(uint256 _percentageDURARepayment) external onlyOwner {
    percentageDURARepayment = _percentageDURARepayment;
    emit SetField("percentageDURARepayment", _percentageDURARepayment);
  }

  function setPercentageCRWNEarning(uint256 _percentageCRWNEarning) external onlyOwner {
    percentageCRWNEarning = _percentageCRWNEarning;
    emit SetField("percentageCRWNEarning", _percentageCRWNEarning);
  }

  function alloyMantissa() internal pure returns (uint256) {
    return uint256(10)**uint256(18);
  }

  function usdcMantissa() internal pure returns (uint256) {
    return uint256(10)**uint256(6);
  }

  function changeAlloyxDURAAddress(address _alloyxAddress) external onlyOwner {
    alloyxTokenDURA = AlloyxTokenDURA(_alloyxAddress);
    emit ChangeAddress("alloyxTokenDURA", _alloyxAddress);
  }

  function changeAlloyxCRWNAddress(address _alloyxAddress) external onlyOwner {
    alloyxTokenCRWN = AlloyxTokenCRWN(_alloyxAddress);
    emit ChangeAddress("alloyxTokenCRWN", _alloyxAddress);
  }

  function changeGoldfinchDelegacyAddress(address _goldfinchDelegacy) external onlyOwner {
    goldfinchDelegacy = IGoldfinchDelegacy(_goldfinchDelegacy);
    emit ChangeAddress("goldfinchDelegacy", _goldfinchDelegacy);
  }

  function changeUSDCAddress(address _usdcAddress) external onlyOwner {
    usdcCoin = IERC20(_usdcAddress);
    emit ChangeAddress("usdcCoin", _usdcAddress);
  }

  function depositAlloyxDURATokens(uint256 _tokenAmount)
    external
    whenNotPaused
    whenVaultStarted
    isWhitelisted(msg.sender)
    returns (bool)
  {
    require(
      alloyxTokenDURA.balanceOf(msg.sender) >= _tokenAmount,
      "User has insufficient alloyx coin."
    );
    require(
      alloyxTokenDURA.allowance(msg.sender, address(this)) >= _tokenAmount,
      "User has not approved the vault for sufficient alloyx coin"
    );
    uint256 amountToWithdraw = alloyxDURAToUSDC(_tokenAmount);
    uint256 withdrawalFee = amountToWithdraw.mul(percentageDURARedemption).div(100);
    require(amountToWithdraw > 0, "The amount of stable coin to get is not larger than 0");
    require(
      usdcCoin.balanceOf(address(this)) >= amountToWithdraw,
      "The vault does not have sufficient stable coin"
    );
    alloyxTokenDURA.burn(msg.sender, _tokenAmount);
    usdcCoin.safeTransfer(msg.sender, amountToWithdraw.sub(withdrawalFee));
    redemptionFee = redemptionFee.add(withdrawalFee);
    emit DepositAlloyx(address(alloyxTokenDURA), msg.sender, _tokenAmount);
    emit Burn(msg.sender, _tokenAmount);
    return true;
  }

  function depositUSDCCoin(uint256 _tokenAmount)
    external
    whenNotPaused
    whenVaultStarted
    isWhitelisted(msg.sender)
    returns (bool)
  {
    require(usdcCoin.balanceOf(msg.sender) >= _tokenAmount, "User has insufficient stable coin");
    require(
      usdcCoin.allowance(msg.sender, address(this)) >= _tokenAmount,
      "User has not approved the vault for sufficient stable coin"
    );
    uint256 amountToMint = usdcToAlloyxDURA(_tokenAmount);
    require(amountToMint > 0, "The amount of alloyx DURA coin to get is not larger than 0");
    usdcCoin.safeTransferFrom(msg.sender, address(goldfinchDelegacy), _tokenAmount);
    alloyxTokenDURA.mint(msg.sender, amountToMint);
    emit DepositStable(address(usdcCoin), msg.sender, amountToMint);
    emit Mint(msg.sender, amountToMint);
    return true;
  }

  function depositUSDCCoinWithStake(uint256 _tokenAmount)
    external
    whenNotPaused
    whenVaultStarted
    isWhitelisted(msg.sender)
    returns (bool)
  {
    require(usdcCoin.balanceOf(msg.sender) >= _tokenAmount, "User has insufficient stable coin");
    require(
      usdcCoin.allowance(msg.sender, address(this)) >= _tokenAmount,
      "User has not approved the vault for sufficient stable coin"
    );
    uint256 amountToMint = usdcToAlloyxDURA(_tokenAmount);
    require(amountToMint > 0, "The amount of alloyx DURA coin to get is not larger than 0");
    usdcCoin.safeTransferFrom(msg.sender, address(this), _tokenAmount);
    alloyxTokenDURA.mint(address(this), amountToMint);
    addStake(msg.sender, amountToMint);
    emit DepositStable(address(usdcCoin), msg.sender, amountToMint);
    emit Mint(address(this), amountToMint);
    emit Stake(msg.sender, amountToMint);
    return true;
  }

  function depositNFTToken(address _tokenAddress, uint256 _tokenID)
    external
    whenNotPaused
    whenVaultStarted
    isWhitelisted(msg.sender)
    returns (bool)
  {
    uint256 purchasePrice = goldfinchDelegacy.validatesTokenToDepositAndGetPurchasePrice(
      _tokenAddress,
      msg.sender,
      _tokenID
    );
    IERC721(_tokenAddress).safeTransferFrom(msg.sender, address(goldfinchDelegacy), _tokenID);
    goldfinchDelegacy.payUsdc(msg.sender, purchasePrice);
    emit DepositNFT(_tokenAddress, msg.sender, _tokenID);
    return true;
  }

  function depositNFTTokenForDura(address _tokenAddress, uint256 _tokenID)
    external
    whenNotPaused
    whenVaultStarted
    isWhitelisted(msg.sender)
    returns (bool)
  {
    require(goldfinchDelegacy.isValidPool(_tokenID) == true, "Not a valid pool");
    require(IERC721(_tokenAddress).ownerOf(_tokenID) == msg.sender, "User does not own this token");
    require(
      IERC721(_tokenAddress).getApproved(_tokenID) == msg.sender,
      "User has not approved the vault for this token"
    );
    uint256 purchasePrice = goldfinchDelegacy.getJuniorTokenValue(_tokenID);
    uint256 amountToMint = usdcToAlloyxDURA(purchasePrice);
    require(amountToMint > 0, "The amount of alloyx DURA coin to get is not larger than 0");
    IERC721(_tokenAddress).safeTransferFrom(msg.sender, address(goldfinchDelegacy), _tokenID);
    alloyxTokenDURA.mint(msg.sender, amountToMint);
    emit Mint(msg.sender, amountToMint);
    emit DepositNftForDura(_tokenAddress, msg.sender, _tokenID);
    return true;
  }

  function depositNFTTokenForDuraWithStake(address _tokenAddress, uint256 _tokenID)
    external
    whenNotPaused
    whenVaultStarted
    isWhitelisted(msg.sender)
    returns (bool)
  {
    require(goldfinchDelegacy.isValidPool(_tokenID) == true, "Not a valid pool");
    require(IERC721(_tokenAddress).ownerOf(_tokenID) == msg.sender, "User does not own this token");
    require(
      IERC721(_tokenAddress).getApproved(_tokenID) == msg.sender,
      "User has not approved the vault for this token"
    );
    uint256 purchasePrice = goldfinchDelegacy.getJuniorTokenValue(_tokenID);
    uint256 amountToMint = usdcToAlloyxDURA(purchasePrice);
    require(amountToMint > 0, "The amount of alloyx DURA coin to get is not larger than 0");
    IERC721(_tokenAddress).safeTransferFrom(msg.sender, address(goldfinchDelegacy), _tokenID);
    alloyxTokenDURA.mint(address(this), amountToMint);
    addStake(msg.sender, amountToMint);
    emit Mint(address(this), amountToMint);
    emit DepositNftForDura(_tokenAddress, msg.sender, _tokenID);
    emit Stake(msg.sender, amountToMint);
    return true;
  }

  function purchaseJuniorToken(
    uint256 _amount,
    address _poolAddress,
    uint256 _tranche
  ) external onlyOwner {
    require(_amount > 0, "Must deposit more than zero");
    goldfinchDelegacy.purchaseJuniorToken(_amount, _poolAddress, _tranche);
    emit PurchaseJunior(_amount);
  }

  function sellJuniorToken(
    uint256 _tokenId,
    uint256 _amount,
    address _poolAddress
  ) external onlyOwner {
    require(_amount > 0, "Must sell more than zero");
    goldfinchDelegacy.sellJuniorToken(_tokenId, _amount, _poolAddress, percentageDURARepayment);
    emit SellSenior(_amount);
  }

  function purchaseSeniorTokens(uint256 _amount) external onlyOwner {
    require(_amount > 0, "Must deposit more than zero");
    goldfinchDelegacy.purchaseSeniorTokens(_amount);
    emit PurchaseSenior(_amount);
  }

  function sellSeniorTokens(uint256 _amount) external onlyOwner {
    require(_amount > 0, "Must sell more than zero");
    goldfinchDelegacy.sellSeniorTokens(_amount, percentageDURARepayment);
    emit SellSenior(_amount);
  }

  function migrateERC20(address _tokenAddress, address _to) external onlyOwner whenPaused {
    uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
    IERC20(_tokenAddress).safeTransfer(_to, balance);
  }

  function transferRedemptionFee(address _to) external onlyOwner whenNotPaused {
    usdcCoin.safeTransfer(_to, redemptionFee);
    redemptionFee = 0;
  }

  function transferAlloyxOwnership(address _to) external onlyOwner whenPaused {
    alloyxTokenDURA.transferOwnership(_to);
    alloyxTokenCRWN.transferOwnership(_to);
  }
}