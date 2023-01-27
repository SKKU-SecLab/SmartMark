
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

        (bool success, ) = recipient.call{ value: amount }("");
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

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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



pragma solidity 0.6.12;




interface IGoaldProxy {
    function getProxyAddress() external view returns (address);
}

contract GoaldProxy is ERC20 {
    uint256 private constant REWARD_THRESHOLD = 10*2;

    address public  _owner = msg.sender;

    address private _uniswapRouterAddress;

    address private _proxyAddress = address(this);

    address private _intermediaryToken;

    string  private _baseTokenURI;


    mapping (address => bool) private _allowedDeployersMap;
    address[] private _allowedDeployersList;

    address[] private _deployedGoalds;

    address[] private _goaldOwners;


    address   private _rewardToken;

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

    constructor() ERC20("Goald", "GOALD") public {
        _setupDecimals(2);
        _status = RE_NOT_ENTERED;
        _proxyAddress = address(this);
    }


    event OwnerChanged(uint256 id, address owner);

    event RewardCreated(uint256 multiplier, string reason);


    function addAllowedDeployer(address newDeployer) external {
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,               "Not owner");
        require(!_allowedDeployersMap[newDeployer], "Already allowed");

        _allowedDeployersMap[newDeployer] = true;
        _allowedDeployersList.push(newDeployer);
    }

    function freeze() external {
        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _owner, "Not owner");

        _status = RE_FROZEN;
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

    function setBaseTokenURI(string calldata baseTokenURI) external {
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner, "Not owner");

        _baseTokenURI = baseTokenURI;
    }

    function setOwner(address newOwner) external {
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,   "Not owner");
        require(newOwner != address(0), "Can't be zero address");

        _owner = newOwner;
    }

    function setProxyAddress(address newAddress) external {
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,     "Not owner");
        require(newAddress != address(0), "Can't be zero address");
        require(IGoaldProxy(newAddress).getProxyAddress() == newAddress);

        _proxyAddress = newAddress;
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

    function getGoaldAt(uint256 index) external view returns (address[2] memory) {
        return [_deployedGoalds[index], _goaldOwners[index]];
    }

    function getIntermediaryToken() external view returns (address) {
        return _intermediaryToken;
    }

    function getNextGoaldId() external view returns (uint256) {
        return _deployedGoalds.length + 1;
    }

    function getProxyAddress() external view returns (address) {
        return _proxyAddress;
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

        return string(abi.encodePacked(_baseTokenURI, string(buffer)));
    }

    function getUniswapRouterAddress() external view returns (address) {
        return _uniswapRouterAddress;
    }

    function isAllowedDeployer(address deployer) external view returns (bool) {
        return _allowedDeployersMap[deployer];
    }

    function notifyGoaldCreated(address creator, address goaldAddress) external {
        require(_status == RE_NOT_ENTERED);
        require(_allowedDeployersMap[msg.sender], "Not allowed deployer");
        require(_proxyAddress == address(this),   "Not latest proxy");

        if (_governanceStage == STAGE_ALL_GOVERNANCE_ISSUED) {
            _deployedGoalds.push(goaldAddress);
            _goaldOwners.push(creator);
            return;
        }

        uint256 goaldsDeployed = _deployedGoalds.length;
        uint256 amount;
        if        (goaldsDeployed <   10) {
            amount = 100;
        } else if (goaldsDeployed <   20) {
            amount =  90;
        } else if (goaldsDeployed <   30) {
            amount =  80;
        } else if (goaldsDeployed <   40) {
            amount =  70;
        } else if (goaldsDeployed <   50) {
            amount =  60;
        } else if (goaldsDeployed <   60) {
            amount =  50;
        } else if (goaldsDeployed <   70) {
            amount =  40;
        } else if (goaldsDeployed <   80) {
            amount =  30;
        } else if (goaldsDeployed <   90) {
            amount =  20;
        } else if (goaldsDeployed <  100) {
            amount =  10;
        } else if (goaldsDeployed < 3600) {
            amount =   1;
        }

        if (amount > 0) {
            _checkRewardBalance(creator);

            if (balanceOf(creator) < REWARD_THRESHOLD) {
                _rewardHolders ++;
            }

            _mint(creator, amount * REWARD_THRESHOLD);
        }

        if (goaldsDeployed >= 3600 && _governanceStage == STAGE_DAO_INITIATED) {
            _governanceStage = STAGE_ALL_GOVERNANCE_ISSUED;
        }

        _deployedGoalds.push(goaldAddress);
        _goaldOwners.push(creator);
    }

    function setGoaldOwner(uint256 id) external {
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        id --;
        require(id < _deployedGoalds.length, "Invalid id");

        address owner = IERC721(_deployedGoalds[id]).ownerOf(id + 1);
        _goaldOwners[id] = owner;

        emit OwnerChanged(id + 1, owner);

        _status = RE_NOT_ENTERED;
    }


    function claimIssuance() external {
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,              "Not owner");
        require(_governanceStage == STAGE_INITIAL, "Already claimed");

        _mint(_owner, 12000 * REWARD_THRESHOLD);

        _governanceStage = STAGE_ISSUANCE_CLAIMED;
    }

    function convertToken(address[] calldata path, uint256 deadline) external {
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;
        require(msg.sender == _owner,                    "Not owner");
            
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
            path[1] = _intermediaryToken;
            path[2] = _rewardToken;
        } else {
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

    function initializeDAO() external {
        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _owner,                       "Not owner");
        require(_governanceStage == STAGE_ISSUANCE_CLAIMED, "Issuance unclaimed");

        _burn(_owner, 11000 * REWARD_THRESHOLD);

        _governanceStage = STAGE_DAO_INITIATED;
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

        uint256 balance = balanceOf(holder);
        if (balance < REWARD_THRESHOLD) {
            if (currentMinimumIndex < count) {
                _minimumRewardIndex[holder] = count;
            }

            return;
        }

        uint256 multiplier;
        uint256 reserveDecrease;
        for (; currentMinimumIndex < count; currentMinimumIndex ++) {
            multiplier += _rewardMultipliers[currentMinimumIndex];

            if (_rewardHolderCounts[currentMinimumIndex] == 1) {
                reserveDecrease += _rewardReserves[currentMinimumIndex] - (multiplier * balance);
                _rewardHolderCounts[currentMinimumIndex] = 0;
                _rewardReserves[currentMinimumIndex] = 0;
            } else {
                _rewardHolderCounts[currentMinimumIndex]--;
                _rewardReserves[currentMinimumIndex] -= multiplier * balance;
            }
        }
        _minimumRewardIndex[holder] = count;

        uint256 currentBalance = _rewardBalance[holder];
        require(currentBalance + (multiplier * balance) > currentBalance, "Balance overflow");
        _rewardBalance[holder] = currentBalance + (multiplier * balance);   

        if (reserveDecrease > 0) {
            _reservedRewardBalance -= reserveDecrease;
        }
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
        uint256 reserveIncrease = totalSupply() * multiplier;
        require(reserveIncrease <= currentBalance - reservedRewardBalance, "Multiplier too large");

        require(reservedRewardBalance + reserveIncrease > reservedRewardBalance, "Reserved overflow error");
        reservedRewardBalance += reserveIncrease;

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
        uint256 balance = balanceOf(holder);
        uint256 rewardBalance = _rewardBalance[holder];
        uint256 currentMinimumIndex = _minimumRewardIndex[holder];
        for (; currentMinimumIndex < count; currentMinimumIndex ++) {
            rewardBalance += _rewardMultipliers[currentMinimumIndex] * balance;
        }

        return rewardBalance;
    }

    function getHolderRewardDetailsAt(uint256 index) external view returns (uint256[3] memory) {
        return [
            _rewardMultipliers[index],
            _rewardHolderCounts[index],
            _rewardReserves[index]
        ];
    }

    function getRewardDetails() external view returns (uint256[3] memory) {
        return [
            uint256(_rewardToken),
            _rewardHolders,
            _reservedRewardBalance
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


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _checkRewardBalance(sender);
        _checkRewardBalance(recipient);

        uint256 senderBefore = balanceOf(sender);
        uint256 recipientBefore = balanceOf(recipient);

        super.transferFrom(sender, recipient, amount);

        uint256 senderAfter = balanceOf(sender);
        if        (senderBefore  < REWARD_THRESHOLD && senderAfter >= REWARD_THRESHOLD) {
            _rewardHolders ++;
        } else if (senderBefore >= REWARD_THRESHOLD && senderAfter  < REWARD_THRESHOLD) {
            _rewardHolders --;
        }
        uint256 recipientAfter = balanceOf(recipient);
        if        (recipientBefore  < REWARD_THRESHOLD && recipientAfter >= REWARD_THRESHOLD) {
            _rewardHolders ++;
        } else if (recipientBefore >= REWARD_THRESHOLD && recipientAfter  < REWARD_THRESHOLD) {
            _rewardHolders --;
        }

        if (senderAfter == 0) {
            _minimumRewardIndex[msg.sender] = 0;
        }

        return true;
    }
}