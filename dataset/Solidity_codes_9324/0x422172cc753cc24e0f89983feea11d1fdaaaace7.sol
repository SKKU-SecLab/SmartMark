

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}


pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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




pragma solidity ^0.8.4;










interface IRewardsDistributor {


  function depositRewards() external payable;




  function getShares(address wallet) external view returns (uint256);




  function getBoostNfts(address wallet)

    external

    view

    returns (uint256[] memory);


}







contract RewardDistributor is IRewardsDistributor, Ownable {


  using SafeMath for uint256;



  struct Reward {

    uint256 totalExcluded; // excluded reward

    uint256 totalRealised;

    uint256 lastClaim; // used for boosting logic

  }



  struct Share {

    uint256 amount;

    uint256 amountBase;

    uint256 stakedTime;

    uint256[] nftBoostTokenIds;

  }



  uint256 public minSecondsBeforeUnstake = 43200;

  address public shareholderToken;

  address public nftBoosterToken;

  uint256 public nftBoostPercentage = 2; // 2% boost per NFT staked

  uint256 public maxNftsCanBoost = 10;

  uint256 public totalStakedUsers;

  uint256 public totalSharesBoosted;

  uint256 public totalSharesDeposited; // will only be actual deposited tokens without handling any reflections or otherwise

  address wrappedNative;

  IUniswapV2Router02 router;




  mapping(address => Share) shares;


  mapping(address => Reward) public rewards;


  address[] public stakers;

  uint256 public totalRewards;

  uint256 public totalDistributed;

  uint256 public rewardsPerShare;



  uint256 public constant ACC_FACTOR = 10**36;

  address public constant DEAD = 0x000000000000000000000000000000000000dEaD;



  constructor(

    address _dexRouter,

    address _shareholderToken,

    address _nftBoosterToken,

    address _wrappedNative

  ) {

    router = IUniswapV2Router02(_dexRouter);

    shareholderToken = _shareholderToken;

    nftBoosterToken = _nftBoosterToken;

    wrappedNative = _wrappedNative;

  }



  function stake(uint256 amount, uint256[] memory nftTokenIds) external {


    _stake(msg.sender, amount, nftTokenIds, false);

  }



  function _stake(

    address shareholder,

    uint256 amount,

    uint256[] memory nftTokenIds,

    bool overrideTransfers

  ) private {


    if (shares[shareholder].amount > 0 && !overrideTransfers) {

      distributeReward(shareholder, false);

    }



    IERC20 shareContract = IERC20(shareholderToken);

    uint256 stakeAmount = amount == 0

      ? shareContract.balanceOf(shareholder)

      : amount;

    uint256 sharesBefore = shares[shareholder].amount;







    uint256 finalBaseAdded = stakeAmount;

    if (!overrideTransfers) {

      uint256 shareBalanceBefore = shareContract.balanceOf(address(this));

      shareContract.transferFrom(shareholder, address(this), stakeAmount);

      finalBaseAdded = shareContract.balanceOf(address(this)).sub(

        shareBalanceBefore

      );



      if (

        nftTokenIds.length > 0 &&

        nftBoosterToken != address(0) &&

        shares[shareholder].nftBoostTokenIds.length + nftTokenIds.length <=

        maxNftsCanBoost

      ) {

        IERC721 nftContract = IERC721(nftBoosterToken);

        for (uint256 i = 0; i < nftTokenIds.length; i++) {

          nftContract.transferFrom(shareholder, address(this), nftTokenIds[i]);

          shares[shareholder].nftBoostTokenIds.push(nftTokenIds[i]);

        }

      }

    }



    uint256 finalBoostedAmount = getElevatedSharesWithBooster(

      shareholder,

      shares[shareholder].amountBase.add(finalBaseAdded)

    );



    totalSharesDeposited = totalSharesDeposited.add(finalBaseAdded);

    totalSharesBoosted = totalSharesBoosted.sub(shares[shareholder].amount).add(

        finalBoostedAmount

      );

    shares[shareholder].amountBase += finalBaseAdded;

    shares[shareholder].amount = finalBoostedAmount;

    shares[shareholder].stakedTime = block.timestamp;

    if (sharesBefore == 0 && shares[shareholder].amount > 0) {

      totalStakedUsers++;

    }

    rewards[shareholder].totalExcluded = getCumulativeRewards(

      shares[shareholder].amount

    );

    stakers.push(shareholder);

  }



  function _unstake(address account, uint256 boostedAmount, bool relinquishRewards) private {


    require(

      shares[account].amount > 0 &&

        (boostedAmount == 0 || boostedAmount <= shares[account].amount),

      'you can only unstake if you have some staked'

    );

    require(

      block.timestamp > shares[account].stakedTime + minSecondsBeforeUnstake,

      'must be staked for minimum time and at least one block if no min'

    );

    if (!relinquishRewards) {

      distributeReward(account, false);

    }



    IERC20 shareContract = IERC20(shareholderToken);

    uint256 boostedAmountToUnstake = boostedAmount == 0

      ? shares[account].amount

      : boostedAmount;



    uint256 baseAmount = getBaseSharesFromBoosted(

      account,

      boostedAmountToUnstake

    );



    if (boostedAmount == 0) {

      uint256[] memory tokenIds = shares[account].nftBoostTokenIds;

      IERC721 nftContract = IERC721(nftBoosterToken);

      for (uint256 i = 0; i < tokenIds.length; i++) {

        nftContract.safeTransferFrom(address(this), account, tokenIds[i]);

      }

      totalStakedUsers--;

      delete shares[account].nftBoostTokenIds;

    }



    shareContract.transfer(account, baseAmount);



    totalSharesDeposited = totalSharesDeposited.sub(baseAmount);

    totalSharesBoosted = totalSharesBoosted.sub(boostedAmountToUnstake);

    shares[account].amountBase -= baseAmount;

    shares[account].amount -= boostedAmountToUnstake;

    rewards[account].totalExcluded = getCumulativeRewards(

      shares[account].amount

    );

  }



  function unstake(uint256 boostedAmount, bool relinquishRewards) external {


    _unstake(msg.sender, boostedAmount, relinquishRewards);

  }



  function depositRewards() external payable override {


    require(msg.value > 0, 'value must be greater than 0');

    require(

      totalSharesBoosted > 0,

      'must be shares deposited to be rewarded rewards'

    );



    uint256 amount = msg.value;



    totalRewards = totalRewards.add(amount);

    rewardsPerShare = rewardsPerShare.add(

      ACC_FACTOR.mul(amount).div(totalSharesBoosted)

    );

  }



  function distributeReward(address shareholder, bool compound) internal {


    require(

      block.timestamp > rewards[shareholder].lastClaim,

      'can only claim once per block'

    );

    if (shares[shareholder].amount == 0) {

      return;

    }



    uint256 amount = getUnpaid(shareholder);



    rewards[shareholder].totalRealised = rewards[shareholder].totalRealised.add(

      amount

    );

    rewards[shareholder].totalExcluded = getCumulativeRewards(

      shares[shareholder].amount

    );

    rewards[shareholder].lastClaim = block.timestamp;



    if (amount > 0) {

      totalDistributed = totalDistributed.add(amount);

      uint256 balanceBefore = address(this).balance;

      if (compound) {

        IERC20 shareToken = IERC20(shareholderToken);

        uint256 balBefore = shareToken.balanceOf(address(this));

        address[] memory path = new address[](2);

        path[0] = wrappedNative;

        path[1] = shareholderToken;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{

          value: amount

        }(0, path, address(this), block.timestamp);

        uint256 amountReceived = shareToken.balanceOf(address(this)).sub(

          balBefore

        );

        if (amountReceived > 0) {

          uint256[] memory _empty = new uint256[](0);

          _stake(shareholder, amountReceived, _empty, true);

        }

      } else {

        (bool sent, ) = payable(shareholder).call{ value: amount }('');

        require(sent, 'ETH was not successfully sent');

      }

      require(

        address(this).balance >= balanceBefore - amount,

        'only take proper amount from contract'

      );

    }

  }



  function claimReward(bool compound) external {


    distributeReward(msg.sender, compound);

  }










  function getElevatedSharesWithBooster(address shareholder, uint256 baseAmount)

    internal

    view

    returns (uint256)

  {


    return

      eligibleForRewardBooster(shareholder)

        ? baseAmount.add(

          baseAmount.mul(getBoostPercentage(shareholder)).div(10**2)

        )

        : baseAmount;

  }



  function getBaseSharesFromBoosted(address shareholder, uint256 boostedAmount)

    public

    view

    returns (uint256)

  {


    uint256 multiplier = 10**18;

    return

      eligibleForRewardBooster(shareholder)

        ? boostedAmount.mul(multiplier).div(

          multiplier.add(

            multiplier.mul(getBoostPercentage(shareholder)).div(10**2)

          )

        )

        : boostedAmount;

  }



  function getBoostPercentage(address wallet) public view returns (uint256) {


    uint256[] memory _userNFTTokens = getBoostNfts(wallet);

    uint256 _userNFTBalance = _userNFTTokens.length;

    return nftBoostPercentage.mul(_userNFTBalance);

  }



  function eligibleForRewardBooster(address wallet) public view returns (bool) {


    return getBoostNfts(wallet).length > 0;

  }



  function getUnpaid(address shareholder) public view returns (uint256) {


    if (shares[shareholder].amount == 0) {

      return 0;

    }



    uint256 earnedRewards = getCumulativeRewards(shares[shareholder].amount);

    uint256 rewardsExcluded = rewards[shareholder].totalExcluded;

    if (earnedRewards <= rewardsExcluded) {

      return 0;

    }



    return earnedRewards.sub(rewardsExcluded);

  }



  function getCumulativeRewards(uint256 share) internal view returns (uint256) {


    return share.mul(rewardsPerShare).div(ACC_FACTOR);

  }



  function getBaseShares(address user) external view returns (uint256) {


    return shares[user].amountBase;

  }



  function getShares(address user) external view override returns (uint256) {


    return shares[user].amount;

  }



  function getBoostNfts(address user)

    public

    view

    override

    returns (uint256[] memory)

  {


    return shares[user].nftBoostTokenIds;

  }



  function setShareholderToken(address _token) external onlyOwner {


    shareholderToken = _token;

  }



  function setMinSecondsBeforeUnstake(uint256 _seconds) external onlyOwner {


    minSecondsBeforeUnstake = _seconds;

  }



  function setNftBoosterToken(address _nft) external onlyOwner {


    nftBoosterToken = _nft;

  }



  function setNftBoostPercentage(uint256 _percentage) external onlyOwner {


    nftBoostPercentage = _percentage;

  }



  function setMaxNftsToBoost(uint256 _amount) external onlyOwner {


    maxNftsCanBoost = _amount;

  }



  function unstakeAll() external onlyOwner {


    if (stakers.length == 0)

      return;

    for(uint i = 0; i < stakers.length; i++) {

      if(shares[stakers[i]].amount <= 0)

        continue;

      _unstake(stakers[i], 0, false);

    }

    delete stakers;

  }



  receive() external payable {}

}