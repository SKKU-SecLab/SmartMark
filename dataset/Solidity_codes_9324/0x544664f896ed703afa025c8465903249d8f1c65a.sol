
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}

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


pragma solidity 0.6.12;


interface IGoaldToken is IERC20 {

    function getBaseTokenURI() external view returns (string memory);


    function getGoaldCount() external view returns (uint256);


    function getGovernanceStage() external view returns (uint256);


    function getLatestDAO() external view returns (address);


    function goaldDeployed(address recipient, address goaldAddress) external returns (uint256);

}

contract GoaldDAO {

    uint8 private constant DECIMALS = 2;

    uint256 private constant REWARD_THRESHOLD = 10**uint256(DECIMALS);

    address public  _owner;

    address private _uniswapRouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address public  _goaldToken = 0x5Cd9207c3A81FB7A73c9D71CDd413B85b4a7D045;

    address private _intermediaryToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;


    mapping (address => bool) private _allowedDeployersMap;
    address[] private _allowedDeployersList;

    address[] private _deployedGoalds;

    address[] private _goaldOwners;

    uint256   private _idOffset;


    address   private _rewardToken = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    uint256   private _rewardHolders;

    uint256   private _reservedRewardBalance;

    uint256[] private _rewardHolderCounts;

    uint256[] private _rewardMultipliers;

    uint256[] private _rewardReserves;

    mapping (address => uint256) private _minimumRewardIndex;
    
    mapping (address => uint256) private _rewardBalance;

    uint256 private constant STAGE_INITIAL               = 0;
    uint256 private constant STAGE_ISSUANCE_CLAIMED      = 1;
    uint256 private constant STAGE_DAO_INITIATED         = 2;
    uint256 private constant STAGE_ALL_GOVERNANCE_ISSUED = 3;
    uint256 private _governanceStage;

    uint256 private constant RE_NOT_ENTERED = 1;
    uint256 private constant RE_ENTERED     = 2;
    uint256 private constant RE_FROZEN      = 3;
    uint256 private _status;

    uint256 private constant NOT_READY = 0;
    uint256 private constant READY = 1;
    uint256 private _ready;

    constructor(/* address goaldToken, address rewardToken, address intermediaryToken */) public {

        IGoaldToken token = IGoaldToken(/* goaldToken */ 0x5Cd9207c3A81FB7A73c9D71CDd413B85b4a7D045);
        _governanceStage = token.getGovernanceStage();

        if (_governanceStage < STAGE_DAO_INITIATED) {
            _owner = msg.sender;
        } else {
            _owner = _goaldToken;
        }

        _status = RE_NOT_ENTERED;
    }


    event RewardCreated(uint256 multiplier, string reason);


    function addAllowedDeployers(address[] calldata newDeployers) external {

        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner, "Not owner");

        uint256 count = newDeployers.length;
        uint256 index;
        address newDeployer;
        for (; index < count; index++) {
            newDeployer = newDeployers[index];

            if (!_allowedDeployersMap[newDeployer]) {
                _allowedDeployersMap[newDeployer] = true;
                _allowedDeployersList.push(newDeployer);
            }
        }
    }

    function freeze() external {

        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _owner, "Not owner");

        _status = RE_FROZEN;
    }

    function initializeDecreasesHolders() external {

        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _goaldToken, "Not GOALD token");
        require(_governanceStage == STAGE_ISSUANCE_CLAIMED, "Wrong governance stage");

        _rewardHolders --;
    }

    function issuanceIncreasesHolders() external {

        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _goaldToken, "Not GOALD token");
        require(_governanceStage == STAGE_INITIAL, "Wrong governance stage");

        _rewardHolders ++;
    }

    function makeReady(uint256 governanceStage, uint256 idOffset) external {

        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _goaldToken, "Not Goald token");
        require(_ready == NOT_READY,       "Already ready");

        _governanceStage = governanceStage;
        _idOffset = idOffset;
        _ready = READY;
        
        if (governanceStage >= STAGE_DAO_INITIATED) {
            _owner = _goaldToken;
        }
    }

    function removeAllowedDeployer(address deployerAddress, uint256 index) external {

        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,                 "Not owner");
        require(index < _allowedDeployersList.length, "Out of bounds");

        address indexAddress = _allowedDeployersList[index];
        require(indexAddress == deployerAddress,       "Address mismatch");
        require(_allowedDeployersMap[deployerAddress], "Already restricted");

        _allowedDeployersMap[deployerAddress] = false;
        _allowedDeployersList[index] = _allowedDeployersList[index - 1];
        _allowedDeployersList.pop();
    }

    function setGoaldToken(address newAddress) external {

        require(_status == RE_FROZEN);
        require(msg.sender == _owner,        "Not owner");
        require(newAddress != address(0),    "Can't be zero address");
        require(newAddress != address(this), "Can't be this address");

        if (_owner == _goaldToken) {
            _owner = newAddress;
        }

        _goaldToken = newAddress;
    }

    function setIntermediaryTokenAddress(address newAddress) external {

        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,     "Not owner");
        require(newAddress != address(0), "Can't be zero address");

        _intermediaryToken = newAddress;
    }

    function setOwner(address newOwner) external {

        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,   "Not owner");
        require(newOwner != address(0), "Can't be zero address");
        require(_owner != _goaldToken, "Already initialized");

        _owner = newOwner;
    }

    function setUniswapRouterAddress(address newAddress) external {

        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,     "Not owner");
        require(newAddress != address(0), "Can't be zero address");

        _uniswapRouterAddress = newAddress;
    }

    function unfreeze() external {

        require(_status == RE_FROZEN);
        require(msg.sender == _owner, "Not owner");

        _status = RE_NOT_ENTERED;
    }


    function getDeployerAt(uint256 index) external view returns (address) {

        return _allowedDeployersList[index];
    }

    function getDeployerCount() external view returns (uint256) {

        return _allowedDeployersList.length;
    }

    function getGoaldAt(uint256 index) external view returns (address[2] memory) {

        return [_deployedGoalds[index], _goaldOwners[index]];
    }

    function getGoaldCount() external view returns (uint256) {

        return _deployedGoalds.length;
    }

    function getIDOffset() external view returns (uint256) {

        return _idOffset;
    }

    function getIntermediaryToken() external view returns (address) {

        return _intermediaryToken;
    }

    function getNextGoaldId() external view returns (uint256) {

        return IGoaldToken(_goaldToken).getGoaldCount() + 1;
    }

    function getProxyAddress() external view returns (address) {

        return IGoaldToken(_goaldToken).getLatestDAO();
    }

    function getTokenURI(uint256 tokenId) external view returns (string memory) {


        uint256 temp = tokenId;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = tokenId;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }

        return string(abi.encodePacked(IGoaldToken(_goaldToken).getBaseTokenURI(), string(buffer)));
    }

    function getUniswapRouterAddress() external view returns (address) {

        return _uniswapRouterAddress;
    }

    function isAllowedDeployer(address deployer) external view returns (bool) {

        return _allowedDeployersMap[deployer];
    }

    function notifyGoaldCreated(address creator, address goaldAddress) external {

        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        require(_allowedDeployersMap[msg.sender], "Not allowed deployer");

        IGoaldToken goaldToken = IGoaldToken(_goaldToken);
        require(goaldToken.getLatestDAO() == address(this), "Not latest DAO");

        require(_ready == READY, "Not ready");

        if (_governanceStage == STAGE_ALL_GOVERNANCE_ISSUED) {
            goaldToken.goaldDeployed(creator, goaldAddress);

            _deployedGoalds.push(goaldAddress);
            _goaldOwners.push(creator);

            return;
        }

        bool increaseHolders;
        if (goaldToken.balanceOf(creator) < REWARD_THRESHOLD) {
            increaseHolders = true;
        }

        uint256 amount = goaldToken.goaldDeployed(creator, goaldAddress);

        if (amount > 0) {
            _checkRewardBalance(creator);

            if (increaseHolders) {
                _rewardHolders ++;
            }
        }

        else if (_governanceStage == STAGE_DAO_INITIATED) {
            _governanceStage = STAGE_ALL_GOVERNANCE_ISSUED;
        }

        _deployedGoalds.push(goaldAddress);
        _goaldOwners.push(creator);

        _status = RE_NOT_ENTERED;
    }

    function setGoaldOwner(uint256 id) external {

        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        uint256 index = id - _idOffset;
        require(index < _deployedGoalds.length, "Invalid id");

        address owner = IERC721(_deployedGoalds[index]).ownerOf(id);
        _goaldOwners[index] = owner;

        _status = RE_NOT_ENTERED;
    }


    function convertToken(address[] calldata path, uint256 deadline) external {

        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;
        require(msg.sender == _owner, "Not owner");
            
        IERC20 tokenContract = IERC20(path[0]);
        uint256 amount = tokenContract.balanceOf(address(this));
        require(amount > 0, "No balance for token");

        require(path[path.length - 1] == _rewardToken, "Last must be reward token");

        tokenContract.approve(_uniswapRouterAddress, amount);
        IUniswapV2Router02(_uniswapRouterAddress).swapExactTokensForTokens(amount, 1, path, address(this), deadline);

        _status = RE_NOT_ENTERED;
    }

    function convertTokens(address[] calldata tokenAddresses, bool isIndirect, uint256 deadline) external {

        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;
        require(msg.sender == _owner, "Not owner");

        address[] memory path;
        if (isIndirect) {
            path = new address[](3);
            path[1] = _intermediaryToken;
            path[2] = _rewardToken;
        } else {
            path = new address[](2);
            path[1] = _rewardToken;
        }
        IUniswapV2Router02 uniswap = IUniswapV2Router02(_uniswapRouterAddress);

        address tokenAddress;
        IERC20 tokenContract;
        
        uint256 amount;
        uint256 count = tokenAddresses.length;
        for (uint256 i; i < count; i ++) {
            tokenAddress = tokenAddresses[i];
            require(tokenAddress != address(0),    "Can't be zero address");
            require(tokenAddress != address(this), "Can't be this address");
            require(tokenAddress != _rewardToken,  "Can't be target address");
            
            tokenContract = IERC20(tokenAddress);
            amount = tokenContract.balanceOf(address(this));
            if (amount == 0) {
                continue;
            }

            tokenContract.approve(_uniswapRouterAddress, amount);
            path[0] = tokenAddress;
            uniswap.swapExactTokensForTokens(amount, 1, path, address(this), deadline);
        }

        _status = RE_NOT_ENTERED;
    }

    function getGovernanceStage() external view returns (uint256) {

        return _governanceStage;
    }

    function updateGovernanceStage() external {

        uint256 governanceStage = IGoaldToken(_goaldToken).getGovernanceStage();

        if (governanceStage >= STAGE_DAO_INITIATED && _owner != _goaldToken) {
            _owner = _goaldToken;
        }

        _governanceStage = governanceStage;
    }

    function setRewardToken(address newToken) external {

        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,        "Not owner");
        require(newToken != address(0),      "Can't be zero address");
        require(newToken != address(this),   "Can't be this address");
        require(_reservedRewardBalance == 0, "Have reserved balance");

        _rewardToken = newToken;
    }


    function _checkRewardBalance(address holder) internal {


        uint256 count = _rewardMultipliers.length;

        uint256 currentMinimumIndex = _minimumRewardIndex[holder];
        if (currentMinimumIndex == count) {
            return;
        }

        uint256 balance = IGoaldToken(_goaldToken).balanceOf(holder);
        if (balance < REWARD_THRESHOLD) {
            if (currentMinimumIndex < count) {
                _minimumRewardIndex[holder] = count;
            }

            return;
        }

        uint256 multiplier;
        uint256 totalMultiplier;
        for (; currentMinimumIndex < count; currentMinimumIndex ++) {
            multiplier = _rewardMultipliers[currentMinimumIndex];
            totalMultiplier += multiplier;

            if (_rewardHolderCounts[currentMinimumIndex] == 1) {
                _rewardHolderCounts[currentMinimumIndex] = 0;
                _rewardReserves[currentMinimumIndex] = 0;
            } else {
                _rewardHolderCounts[currentMinimumIndex]--;
                _rewardReserves[currentMinimumIndex] -= multiplier * balance;
            }
        }
        _minimumRewardIndex[holder] = count;

        uint256 currentBalance = _rewardBalance[holder];
        require(currentBalance + (totalMultiplier * balance) > currentBalance, "Balance overflow");
        _rewardBalance[holder] = currentBalance + (totalMultiplier * balance);
    }

    function createReward(uint256 multiplier, string calldata reason) external {

        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;
        require(msg.sender == _owner,                    "Not owner");
        require(_governanceStage >= STAGE_DAO_INITIATED, "DAO not initiated");
        require(multiplier > 0,                          "Multiplier must be > 0");

        uint256 reservedRewardBalance = _reservedRewardBalance;
        uint256 currentBalance = IERC20(_rewardToken).balanceOf(address(this));
        require(currentBalance >= reservedRewardBalance, "Current reserve insufficient");
        uint256 reserveIncrease = IGoaldToken(_goaldToken).totalSupply() * multiplier;
        require(reserveIncrease <= (currentBalance - reservedRewardBalance), "Multiplier too large");

        require((reservedRewardBalance + reserveIncrease) > reservedRewardBalance, "Reserved overflow error");
        _reservedRewardBalance += reserveIncrease;

        uint256 holders = _rewardHolders;
        require(holders > 0, "Must have a holder");
        _rewardHolderCounts.push(holders);
        _rewardMultipliers.push(multiplier);
        _rewardReserves.push(reserveIncrease);

        emit RewardCreated(multiplier, reason);

        _status = RE_NOT_ENTERED;
    }

    function getHolderRewardBalance(address holder) external view returns (uint256) {

        uint256 count = _rewardMultipliers.length;
        uint256 balance = IGoaldToken(_goaldToken).balanceOf(holder);
        uint256 rewardBalance = _rewardBalance[holder];
        uint256 currentMinimumIndex = _minimumRewardIndex[holder];
        for (; currentMinimumIndex < count; currentMinimumIndex ++) {
            rewardBalance += _rewardMultipliers[currentMinimumIndex] * balance;
        }

        return rewardBalance;
    }

    function getRewardDetails() external view returns (uint256[4] memory) {

        return [
            uint256(_rewardToken),
            _rewardReserves.length,
            _rewardHolders,
            _reservedRewardBalance
        ];
    }

    function getRewardDetailsAt(uint256 index) external view returns (uint256[3] memory) {

        return [
            _rewardMultipliers[index],
            _rewardHolderCounts[index],
            _rewardReserves[index]
        ];
    }

    function withdrawReward(address holder) external {

        require(_status == RE_NOT_ENTERED || (_status == RE_FROZEN && msg.sender == _owner));
        _status = RE_ENTERED;

        _checkRewardBalance(holder);

        uint256 balance = _rewardBalance[holder];
        require(balance > 0, "No reward balance");

        _rewardBalance[holder] = 0;
        require(_reservedRewardBalance - balance > 0, "Reserved balance underflow");
        _reservedRewardBalance -= balance;

        IERC20(_rewardToken).transfer(holder, balance);

        _status = RE_NOT_ENTERED;
    }


    function preTransfer(address sender, address recipient) external {

        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        require(msg.sender == _goaldToken, "Caller not Goald token");

        _checkRewardBalance(sender);
        _checkRewardBalance(recipient);

        _status = RE_NOT_ENTERED;
    }

    function postTransfer(address sender, uint256 senderBefore, uint256 senderAfter, uint256 recipientBefore, uint256 recipientAfter) external {

        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);

        require(msg.sender == _goaldToken, "Caller not Goald token");

        if        (senderBefore  < REWARD_THRESHOLD && senderAfter >= REWARD_THRESHOLD) {
            _rewardHolders ++;
        } else if (senderBefore >= REWARD_THRESHOLD && senderAfter  < REWARD_THRESHOLD) {
            _rewardHolders --;
        }
        if        (recipientBefore  < REWARD_THRESHOLD && recipientAfter >= REWARD_THRESHOLD) {
            _rewardHolders ++;
        } else if (recipientBefore >= REWARD_THRESHOLD && recipientAfter  < REWARD_THRESHOLD) {
            _rewardHolders --;
        }

        if (senderAfter == 0) {
            _minimumRewardIndex[sender] = 0;
        }
    }
}