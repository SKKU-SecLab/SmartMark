




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
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}




pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}



pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;



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




pragma solidity ^0.8.7;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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











contract GoldfinchDelegacy is IGoldfinchDelegacy, ERC721Holder, Ownable {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  IERC20 private usdcCoin;
  IERC20 private gfiCoin;
  IERC20 private fiduCoin;
  IPoolTokens private poolToken;
  ISeniorPool private seniorPool;
  address private coreVaultAddress;
  uint256 public earningGfiFee = 0;
  uint256 public repaymentFee = 0;

  constructor(
    address _usdcCoinAddress,
    address _fiduCoinAddress,
    address _gfiCoinAddress,
    address _poolTokenAddress,
    address _seniorPoolAddress,
    address _coreVaultAddress
  ) {
    usdcCoin = IERC20(_usdcCoinAddress);
    gfiCoin = IERC20(_gfiCoinAddress);
    fiduCoin = IERC20(_fiduCoinAddress);
    poolToken = IPoolTokens(_poolTokenAddress);
    seniorPool = ISeniorPool(_seniorPoolAddress);
    coreVaultAddress = _coreVaultAddress;
  }

  modifier fromVault() {

    require(coreVaultAddress == msg.sender, "The function must be called from vault");
    _;
  }

  function approve(
    address _tokenAddress,
    address _account,
    uint256 _amount
  ) external override fromVault {

    IERC20(_tokenAddress).approve(_account, _amount);
  }

  function getFiduBalanceInUSDC() internal view returns (uint256) {

    return
      fiduToUSDC(
        fiduCoin.balanceOf(address(this)).mul(seniorPool.sharePrice()).div(fiduMantissa())
      );
  }

  function getUSDCBalance() public view returns (uint256) {

    return usdcCoin.balanceOf(address(this));
  }

  function getGFIBalance() public view returns (uint256) {

    return gfiCoin.balanceOf(address(this));
  }

  function getGoldfinchDelegacyBalanceInUSDC() public view override returns (uint256) {

    uint256 delegacyValue = getFiduBalanceInUSDC().add(getUSDCBalance()).add(
      getGoldFinchPoolTokenBalanceInUSDC()
    );
    require(delegacyValue >= repaymentFee, "Vault value is less than the repayment fee collected");
    return delegacyValue.sub(repaymentFee);
  }

  function fiduToUSDC(uint256 amount) internal pure returns (uint256) {

    return amount.div(fiduMantissa().div(usdcMantissa()));
  }

  function fiduMantissa() internal pure returns (uint256) {

    return uint256(10)**uint256(18);
  }

  function usdcMantissa() internal pure returns (uint256) {

    return uint256(10)**uint256(6);
  }

  function changeSeniorPoolAddress(address _seniorPool) external onlyOwner {

    seniorPool = ISeniorPool(_seniorPool);
  }

  function changePoolTokenAddress(address _poolToken) external onlyOwner {

    poolToken = IPoolTokens(_poolToken);
  }

  function changeVaultAddress(address _vaultAddress) external onlyOwner {

    coreVaultAddress = _vaultAddress;
  }

  function getGoldFinchPoolTokenBalanceInUSDC() internal view returns (uint256) {

    uint256 total = 0;
    uint256 balance = poolToken.balanceOf(address(this));
    for (uint256 i = 0; i < balance; i++) {
      total = total.add(getJuniorTokenValue(poolToken.tokenOfOwnerByIndex(address(this), i)));
    }
    return total;
  }

  function getJuniorTokenValue(uint256 _tokenID) public view returns (uint256) {

    IPoolTokens.TokenInfo memory tokenInfo = poolToken.getTokenInfo(_tokenID);
    uint256 principalAmount = tokenInfo.principalAmount;
    uint256 totalRedeemed = tokenInfo.principalRedeemed.add(tokenInfo.interestRedeemed);

    address tranchedPoolAddress = tokenInfo.pool;
    ITranchedPool tranchedTokenContract = ITranchedPool(tranchedPoolAddress);
    (uint256 interestRedeemable, uint256 principalRedeemable) = tranchedTokenContract
      .availableToWithdraw(_tokenID);
    uint256 totalRedeemable = interestRedeemable;
    if (principalRedeemable < principalAmount) {
      totalRedeemable.add(principalRedeemable);
    }
    return principalAmount.sub(totalRedeemed).add(totalRedeemable);
  }

  function purchaseJuniorToken(
    uint256 _amount,
    address _poolAddress,
    uint256 _tranche
  ) external override fromVault {

    require(usdcCoin.balanceOf(address(this)) >= _amount, "Vault has insufficent stable coin");
    require(_amount > 0, "Must deposit more than zero");
    ITranchedPool juniorPool = ITranchedPool(_poolAddress);
    juniorPool.deposit(_amount, _tranche);
  }

  function sellJuniorToken(
    uint256 _tokenId,
    uint256 _amount,
    address _poolAddress,
    uint256 _percentageBronzeRepayment
  ) external override fromVault {

    require(fiduCoin.balanceOf(address(this)) >= _amount, "Vault has insufficent fidu coin");
    require(_amount > 0, "Must deposit more than zero");
    ITranchedPool juniorPool = ITranchedPool(_poolAddress);
    (uint256 principal, uint256 interest) = juniorPool.withdraw(_tokenId, _amount);
    uint256 fee = principal.add(interest).mul(_percentageBronzeRepayment).div(100);
    repaymentFee = repaymentFee.add(fee);
  }

  function purchaseSeniorTokens(uint256 _amount) external override fromVault {

    require(usdcCoin.balanceOf(address(this)) >= _amount, "Vault has insufficent stable coin");
    require(_amount > 0, "Must deposit more than zero");
    seniorPool.deposit(_amount);
  }

  function sellSeniorTokens(uint256 _amount, uint256 _percentageBronzeRepayment)
    external
    override
    fromVault
  {

    require(fiduCoin.balanceOf(address(this)) >= _amount, "Vault has insufficent fidu coin");
    require(_amount > 0, "Must deposit more than zero");
    uint256 usdcAmount = seniorPool.withdrawInFidu(_amount);
    uint256 fee = usdcAmount.mul(_percentageBronzeRepayment).div(100);
    repaymentFee = repaymentFee.add(fee);
  }

  function claimReward(
    address _rewardee,
    uint256 _amount,
    uint256 _totalSupply,
    uint256 _percentageFee
  ) external override fromVault {

    require(
      getGFIBalance() >= earningGfiFee,
      "The GFI in the delegacy is less than the GFI fee collected"
    );
    uint256 amountToReward = _amount.mul(getGFIBalance().sub(earningGfiFee)).div(_totalSupply);
    uint256 fee = amountToReward.mul(_percentageFee).div(100);
    gfiCoin.safeTransfer(_rewardee, amountToReward.sub(fee));
    earningGfiFee = earningGfiFee.add(fee);
  }

  function getRewardAmount(
    uint256 _amount,
    uint256 _totalSupply,
    uint256 _percentageFee
  ) external view override fromVault returns (uint256) {

    uint256 amountToReward = _amount.mul(getGFIBalance().sub(earningGfiFee)).div(_totalSupply);
    uint256 fee = amountToReward.mul(_percentageFee).div(100);
    return amountToReward.sub(fee);
  }

  function validatesTokenToDepositAndGetPurchasePrice(
    address _tokenAddress,
    address _depositor,
    uint256 _tokenID
  ) external override fromVault returns (uint256) {

    require(_tokenAddress == address(poolToken), "Not Goldfinch Pool Token");
    require(isValidPool(_tokenID) == true, "Not a valid pool");
    require(IERC721(_tokenAddress).ownerOf(_tokenID) == _depositor, "User does not own this token");
    require(
      poolToken.getApproved(_tokenID) == msg.sender,
      "User has not approved the vault for this token"
    );
    uint256 purchasePrice = getJuniorTokenValue(_tokenID);
    require(purchasePrice > 0, "The amount of stable coin to get is not larger than 0");
    require(
      usdcCoin.balanceOf(address(this)) >= purchasePrice,
      "The vault does not have sufficient stable coin"
    );
    return purchasePrice;
  }

  function payUsdc(address _to, uint256 _amount) external override fromVault {

    usdcCoin.safeTransfer(_to, _amount);
  }

  function isValidPool(uint256 _tokenID) public view returns (bool) {

    IPoolTokens.TokenInfo memory tokenInfo = poolToken.getTokenInfo(_tokenID);
    address tranchedPool = tokenInfo.pool;
    return poolToken.validPool(tranchedPool);
  }

  function destroy() external onlyOwner {

    require(usdcCoin.balanceOf(address(this)) == 0, "Balance of stable coin must be 0");
    require(fiduCoin.balanceOf(address(this)) == 0, "Balance of Fidu coin must be 0");
    require(gfiCoin.balanceOf(address(this)) == 0, "Balance of GFI coin must be 0");
    require(poolToken.balanceOf(address(this)) == 0, "Pool token balance must be 0");

    address payable addr = payable(address(owner()));
    selfdestruct(addr);
  }

  function getGoldfinchTokenIdsOf(address _owner) internal view returns (uint256[] memory) {

    uint256 count = poolToken.balanceOf(_owner);
    uint256[] memory ids = new uint256[](count);
    for (uint256 i = 0; i < count; i++) {
      ids[i] = poolToken.tokenOfOwnerByIndex(_owner, i);
    }
    return ids;
  }

  function migrateGoldfinchPoolTokens(address _toAddress, uint256 _tokenId) public onlyOwner {

    poolToken.safeTransferFrom(address(this), _toAddress, _tokenId);
  }

  function migrateAllGoldfinchPoolTokens(address _toAddress) external onlyOwner {

    uint256[] memory tokenIds = getGoldfinchTokenIdsOf(address(this));
    for (uint256 i = 0; i < tokenIds.length; i++) {
      migrateGoldfinchPoolTokens(_toAddress, tokenIds[i]);
    }
  }

  function migrateERC20(address _tokenAddress, address _to) external onlyOwner {

    uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
    IERC20(_tokenAddress).safeTransfer(_to, balance);
  }

  function transferRepaymentFee(address _to) external onlyOwner {

    usdcCoin.safeTransfer(_to, repaymentFee);
    repaymentFee = 0;
  }

  function transferEarningGfiFee(address _to) external onlyOwner {

    gfiCoin.safeTransfer(_to, earningGfiFee);
    earningGfiFee = 0;
  }
}