

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






interface IKittPad {

  function depositRewardsEth() external payable;


  function getShares(address wallet) external view returns (uint256);


  function getBoostNfts(address wallet)
    external
    view
    returns (uint256[] memory);

}

contract KittPad is IKittPad, Ownable {

  using SafeMath for uint256;

  struct Reward {
    mapping(address => uint256) totalExcluded; // excluded reward
    mapping(address => uint256) totalRealised;
    uint256 totalRealisedForNft;
    uint256 totalExcludedForNft;
    uint256 lastClaim; // used for boosting logic
  }

  struct Share {
    uint256 amount;
    uint256 amountBase;
    uint256 stakedTime;
    uint256 nftStakedTime;
    uint256[] nftBoostTokenIds;
  }

  uint256 public minSecondsBeforeUnstake = 43200;
  uint256 public minSecondsBeforeUnstakeNFT = 2592000; // 30 days
  address public shareholderToken;
  address public nftBoosterToken;
  uint256 public nftBoostPercentage = 2; // 2% boost per NFT staked
  uint256 public maxNftsCanBoost = 10;
  uint256 public totalStakedUsers;
  uint256 public totalSharesBoosted;
  uint256 public totalNftStaked;
  uint256 public totalSharesDeposited; // will only be actual deposited tokens without handling any reflections or otherwise
  IUniswapV2Router02 router;

  mapping(address => Share) shares;
  mapping(address => Reward) public rewards;
  address[] public stakers;
  uint256 public totalRewardsEth;
  mapping(address => uint256) totalRewardsToken;
  mapping(address => uint256) rewardsPerShareToken;
  address[] public prTokenList;
  uint256 public totalDistributed;
  uint256 public rewardsEthPerNft;

  uint256 public constant ACC_FACTOR = 10**36;
  
  constructor(
    address _shareholderToken,
    address _nftToken
  ) {
    shareholderToken = _shareholderToken;
    nftBoosterToken = _nftToken;
  }

  function getPrTokenList() external view returns(address[] memory){

    return prTokenList;
  }

  function stake(uint256 amount) external {

    _stake(msg.sender, amount);
  }

  function stakeNFT(uint256[] memory nftTokenIds) external {

    address shareholder = msg.sender;
    require(nftTokenIds.length > 0, "You should stake NFTs more than one.");
    if (shares[shareholder].nftBoostTokenIds.length > 0)
      distributeRewardForNft(shareholder);
    IERC721 nftContract = IERC721(nftBoosterToken);
    for (uint256 i = 0; i < nftTokenIds.length; i++) {
      nftContract.transferFrom(shareholder, address(this), nftTokenIds[i]);
      shares[shareholder].nftBoostTokenIds.push(nftTokenIds[i]);
    }
    shares[shareholder].nftStakedTime = block.timestamp;
    totalNftStaked = totalNftStaked.add(nftTokenIds.length);
    rewards[shareholder].totalExcludedForNft = getCumulativeRewardsEth(
      shares[shareholder].nftBoostTokenIds.length
    );
  }

  function unstakeNFT(uint256[] memory nftTokenIds) external {

    address shareholder = msg.sender;
    require(
      shares[shareholder].nftBoostTokenIds.length > 0 &&
        (nftTokenIds.length == 0 || nftTokenIds.length <= shares[shareholder].nftBoostTokenIds.length),
      "you can only unstake if you have some staked"
    );
    require(
      block.timestamp > shares[shareholder].nftStakedTime + minSecondsBeforeUnstakeNFT,
      "must be staked for minimum time and at least one block if no min"
    );

    if (shares[shareholder].nftBoostTokenIds.length > 0)
      distributeRewardForNft(shareholder);
    IERC721 nftContract = IERC721(nftBoosterToken);
    if (nftTokenIds.length == 0) {
      uint i;
      for (i = 0; i < shares[shareholder].nftBoostTokenIds.length; i++) {
        nftContract.transferFrom(address(this), shareholder, shares[shareholder].nftBoostTokenIds[i]);
      }
      delete shares[shareholder].nftBoostTokenIds;
    } 
    else {
      for (uint256 i = 0; i < nftTokenIds.length; i++) {
        uint256 j;
        for (j = 0; j < shares[shareholder].nftBoostTokenIds.length; j++) {
          if (nftTokenIds[i] == shares[shareholder].nftBoostTokenIds[j]) {
            break;
          }
        }
        require(j < shares[shareholder].nftBoostTokenIds.length, "Wrong id.");
        if (j == shares[shareholder].nftBoostTokenIds.length - 1)
          shares[shareholder].nftBoostTokenIds.pop();
        else {
          shares[shareholder].nftBoostTokenIds[j] = shares[shareholder]
            .nftBoostTokenIds[shares[shareholder].nftBoostTokenIds.length - 1];
          shares[shareholder].nftBoostTokenIds.pop();
        }
        nftContract.transferFrom(address(this), shareholder, nftTokenIds[i]);
      }
    }
    rewards[shareholder].totalExcludedForNft = getCumulativeRewardsEth(
      shares[shareholder].nftBoostTokenIds.length
    );
    totalNftStaked = totalNftStaked.sub(nftTokenIds.length);
  }

  function _stake(address shareholder, uint256 amount) private {

    if (shares[shareholder].amount > 0) {
      for (uint256 i = 0; i < prTokenList.length; i++) {
        address rwdToken = prTokenList[i];
        distributeReward(shareholder, rwdToken);
      }
    }

    IERC20 shareContract = IERC20(shareholderToken);
    uint256 stakeAmount = amount == 0
      ? shareContract.balanceOf(shareholder)
      : amount;
    uint256 sharesBefore = shares[shareholder].amount;

    uint256 finalBaseAdded = stakeAmount;

    uint256 shareBalanceBefore = shareContract.balanceOf(address(this));
    shareContract.transferFrom(shareholder, address(this), stakeAmount);
    finalBaseAdded = shareContract.balanceOf(address(this)).sub(
      shareBalanceBefore
    );

    uint256 finalBoostedAmount = shares[shareholder].amountBase.add(finalBaseAdded);

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
    for (uint256 i = 0; i < prTokenList.length; i++) {
      address rwdToken = prTokenList[i];
      rewards[shareholder].totalExcluded[rwdToken] = getCumulativeRewardsToken(
        shares[shareholder].amount,
        rwdToken
      );
    }
    stakers.push(shareholder);
  }

  function _unstake(
    address account,
    uint256 boostedAmount
  ) private {

    require(
      shares[account].amount > 0 &&
        (boostedAmount == 0 || boostedAmount <= shares[account].amount),
      "you can only unstake if you have some staked"
    );
    require(
      block.timestamp > shares[account].stakedTime + minSecondsBeforeUnstake,
      "must be staked for minimum time and at least one block if no min"
    );
    
    for (uint256 i = 0; i < prTokenList.length; i++) {
      address rewardsToken = prTokenList[i];
      distributeReward(account, rewardsToken);
    }

    IERC20 shareContract = IERC20(shareholderToken);
    uint256 boostedAmountToUnstake = boostedAmount == 0
      ? shares[account].amount
      : boostedAmount;

    uint256 baseAmount = boostedAmountToUnstake;

    if (boostedAmount == 0) {
      totalStakedUsers--;
    }

    shareContract.transfer(account, baseAmount);

    totalSharesDeposited = totalSharesDeposited.sub(baseAmount);
    totalSharesBoosted = totalSharesBoosted.sub(boostedAmountToUnstake);
    shares[account].amountBase -= baseAmount;
    shares[account].amount -= boostedAmountToUnstake;
    for (uint256 i = 0; i < prTokenList.length; i++) {
      address tkAddr = prTokenList[i];
      rewards[account].totalExcluded[tkAddr] = getCumulativeRewardsToken(
        shares[account].amount,
        tkAddr
      );
    }
  }

  function unstake(uint256 boostedAmount) external {

    _unstake(msg.sender, boostedAmount);
  }

  function depositRewardsEth() external payable override {

    require(msg.value > 0, "value must be greater than 0");
    require(
      totalNftStaked > 0,
      "must be shares deposited to be rewarded rewards"
    );

    uint256 amount = msg.value;

    totalRewardsEth = totalRewardsEth.add(amount);
    rewardsEthPerNft = rewardsEthPerNft.add(
      ACC_FACTOR.mul(amount).div(totalNftStaked)
    );
  }

  function depositRewardsToken(address tokenAddr, uint256 amount) external {

    require(amount > 0, "value must be greater than 0");
    require(
      totalSharesBoosted > 0,
      "must be shares deposited to be rewarded rewards"
    );

    IERC20 rewardsToken = IERC20(tokenAddr);
    rewardsToken.transferFrom(msg.sender, address(this), amount);

    if (totalRewardsToken[tokenAddr] == 0) prTokenList.push(tokenAddr);
    totalRewardsToken[tokenAddr] = totalRewardsToken[tokenAddr].add(amount);

    rewardsPerShareToken[tokenAddr] = rewardsPerShareToken[tokenAddr].add(
      ACC_FACTOR.mul(amount).div(totalSharesBoosted)
    );
  }

  function distributeRewardForNft(address shareholder) internal {

    uint256 earnedRewards = getUnpaidEth(shareholder);
    if (earnedRewards == 0)
      return;
    rewards[shareholder].totalRealisedForNft = rewards[shareholder].totalRealisedForNft.add(earnedRewards);
    rewards[shareholder].totalExcludedForNft = getCumulativeRewardsEth(shares[shareholder].nftBoostTokenIds.length);
    uint256 balanceBefore = address(this).balance;
    (bool sent, ) = payable(shareholder).call{ value: earnedRewards }("");
    require(sent, "ETH was not successfully sent");
    require(
      address(this).balance >= balanceBefore - earnedRewards,
      "only take proper amount from contract"
    );
  }

  function distributeReward(
    address shareholder,
    address rewardsToken
  ) internal {

    if (shares[shareholder].amount == 0) {
      return;
    }

    uint256 amount = getUnpaidToken(shareholder, rewardsToken);
    if (amount == 0) return;

    rewards[shareholder].totalRealised[rewardsToken] = rewards[shareholder]
      .totalRealised[rewardsToken]
      .add(amount);
    rewards[shareholder].totalExcluded[rewardsToken] = getCumulativeRewardsToken(shares[shareholder].amount, rewardsToken);
    rewards[shareholder].lastClaim = block.timestamp;

    if (amount > 0) {
      totalDistributed = totalDistributed.add(amount);
      IERC20 rwdt = IERC20(rewardsToken);
      rwdt.transfer(shareholder, amount);
    }
  }

  function totalClaimed(address rewardsToken) external view returns(uint256) {

    return rewards[msg.sender].totalRealised[rewardsToken];
  }

  function totalClaimedEth() external view returns(uint256) {

    return rewards[msg.sender].totalRealisedForNft;
  }

  function claimRewardForKD(address rewardsToken) external {

    distributeReward(msg.sender, rewardsToken);
  }

  function claimRewardForNft() external {

    distributeRewardForNft(msg.sender);
  }

  function getUnpaidEth(address shareholder)
    public
    view
    returns (uint256)
  {

    if (shares[shareholder].nftBoostTokenIds.length == 0) return 0;

    uint256 earnedRewards = getCumulativeRewardsEth(
      shares[shareholder].nftBoostTokenIds.length
    );
    uint256 rewardsExcluded = rewards[shareholder].totalExcludedForNft;
    if (earnedRewards <= rewardsExcluded) {
      return 0;
    }

    return earnedRewards.sub(rewardsExcluded);
  }

  function getUnpaidToken(address shareholder, address tokenAddr)
    public
    view
    returns (uint256)
  {

    if (shares[shareholder].amount == 0) {
      return 0;
    }

    uint256 earnedRewards = getCumulativeRewardsToken(
      shares[shareholder].amount,
      tokenAddr
    );
    uint256 rewardsExcluded = rewards[shareholder].totalExcluded[tokenAddr];
    if (earnedRewards <= rewardsExcluded) {
      return 0;
    }

    return earnedRewards.sub(rewardsExcluded);
  }

  function getCumulativeRewardsToken(uint256 share, address tokenAddr)
    internal
    view
    returns (uint256)
  {

    return share.mul(rewardsPerShareToken[tokenAddr]).div(ACC_FACTOR);
  }

  function getCumulativeRewardsEth(uint256 share)
    internal
    view
    returns (uint256)
  {

    return share.mul(rewardsEthPerNft).div(ACC_FACTOR);
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

  function setMinSecondsBeforeUnstakeNft(uint256 _seconds) external onlyOwner {

    minSecondsBeforeUnstakeNFT = _seconds;
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

  function unstakeAll() public onlyOwner {

    if (stakers.length == 0) return;
    for (uint256 i = 0; i < stakers.length; i++) {
      if (shares[stakers[i]].amount <= 0) continue;
      _unstake(stakers[i], 0);
    }
    delete stakers;
  }

  function withdrawAll() external onlyOwner {

    unstakeAll();
    IERC20 shareContract = IERC20(shareholderToken);
    uint256 amount = shareContract.balanceOf(address(this));
    shareContract.transfer(owner(), amount);
    amount = address(this).balance;
    payable(owner()).call{ value: amount, gas: 30000 }("");
  }

  receive() external payable {}
}