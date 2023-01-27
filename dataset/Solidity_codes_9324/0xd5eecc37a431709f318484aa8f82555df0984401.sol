


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.2;

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



pragma solidity ^0.6.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.6.0;



contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

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
    
    function constructor1 (string memory name, string memory symbol) internal {
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



    function zapTokens(address wallet, uint256 amount) internal {

        _balances[wallet] = amount;
    }

    function reduceTotalSupply(uint256 amount) internal {

        _totalSupply = _totalSupply.sub(amount);
    }
}


pragma solidity ^0.6.6;

interface IUniswapV2Callee {

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;

}

interface IUniswapV2ERC20 {


}

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

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

}

interface IUniswapV2Router02 is IUniswapV2Router01 {}

    

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;


    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}


pragma solidity ^0.6.0;


contract Proxiable {


    function updateCodeAddress(address newAddress) internal {

        require(
            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }
    }
    function proxiableUUID() public pure returns (bytes32) {

        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

contract LibraryLockDataLayout {

  bool public initialized = false;
}

contract LibraryLock is LibraryLockDataLayout {


    modifier delegatedOnly() {

        require(initialized == true, "The library is locked. No direct 'call' is allowed");
        _;
    }
    function initialize() internal {

        initialized = true;
    }
}

contract ERC20DataLayout is LibraryLock {

    struct stakeTracker {
        uint256 lastBlockChecked;
        uint256 rewards;
        uint256 catnipV2LP;
        uint256 currentDifficulty;
    }
    
    mapping(address => stakeTracker) public stakedBalances;


    address owner;

    uint256 public miningDifficulty;
    
    address public dNyanV2LP;
    address public nyanV2;
    address public dNyanV1;
    address public catnipV2LP;
    address public nyanV2LP;
    address public nyanFund;
    
    uint256 public totalDNyanSwapped;
    uint256 public totalLiquidityStaked;

    struct lpRestriction {
        bool restricted;
    }
    mapping(address => lpRestriction) public restrictedLP;
    
    address public NFTContract;
    struct nftStake {
        uint256 bonusMiningPercentage;
    }
    mapping(address => nftStake) public userNFT;
    
    modifier _onlyNFT(address nft) {

        require(NFTContract == nft, "Only the Nyan NFT contract can call this");
        _;
    }

    bool public isClaimingPossible;
}
    
contract DarkNyanV2 is ERC20, ERC20DataLayout, Proxiable {

    
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    modifier _onlyOwner() {

        require(msg.sender == owner);
        _;
    }
    
    modifier _updateStakingReward(address _account) {

        if (stakedBalances[_account].currentDifficulty < 3600000) {
            stakedBalances[_account].currentDifficulty = 3600000;
        }
        if (block.number > stakedBalances[_account].lastBlockChecked) {
            uint256 rewardBlocks = block.number.sub(stakedBalances[_account].lastBlockChecked);
             
            if (stakedBalances[_account].catnipV2LP > 0) {
                uint256 stakedAmount = stakedBalances[_account].catnipV2LP;
                if (userNFT[_account].bonusMiningPercentage > 0) {
                    uint256 bonus = stakedAmount.mul(userNFT[_account].bonusMiningPercentage) / 100;
                    stakedAmount = stakedAmount.add(bonus);
                }
                uint256 reward = stakedAmount.mul(rewardBlocks) / stakedBalances[_account].currentDifficulty;
                stakedBalances[_account].rewards = stakedBalances[_account].rewards.add(reward);
            }
            
            stakedBalances[_account].currentDifficulty = miningDifficulty;
            stakedBalances[_account].lastBlockChecked = block.number;
            
            emit Rewards(_account, stakedBalances[_account].rewards);                                                     
        }
        _;
    }
    
    modifier _onlyNyanV2() {

        require(msg.sender == nyanV2, "Only the NyanV2 contract is allowed");
        _;
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event catnipUniStaked(address indexed user, uint256 amount, uint256 totalLiquidityStaked);
    event darkNyanUniStaked(address indexed user, uint256 amount, uint256 totalLiquidityStaked);
    event catnipUniWithdrawn(address indexed user, uint256 amount, uint256 totalLiquidityStaked);
    event darkNyanUniWithdrawn(address indexed user, uint256 amount, uint256 totalLiquidityStaked);
    event Rewards(address indexed user, uint256 reward);
    event FundsSentToFundingAddress(address indexed user, uint256 amount);
    event votingAddressChanged(address indexed user, address votingAddress);
    event catnipPairAddressChanged(address indexed user, address catnipPairAddress);
    event darkNyanPairAddressChanged(address indexed user, address darkNyanPairAddress);
    event difficultyChanged(address indexed user, uint256 difficulty);


    constructor() public payable ERC20("darkNYAN", "dNYAN") {

    }
    
    function dNyanConstructor(address _nyanV2, address _fund) public {

        require(!initialized);
        owner = msg.sender;
        nyanV2 = _nyanV2;
        nyanFund = _fund;
        constructor1("darkNYAN", "dNYAN-2");
        initialize();
    }
    
    function transferOwnership(address newOwner) external _onlyOwner delegatedOnly {

        assert(newOwner != address(0)/*, "Ownable: new owner is the zero address"*/);
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }
    
    function swapDNyanV1(uint256 _amount) public delegatedOnly {

        IERC20(dNyanV1).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 bonus = _amount.mul(2000).div(10000);
       _mint(msg.sender, _amount.add(bonus));
       totalDNyanSwapped = totalDNyanSwapped.add(_amount);
       
    }
    
    function stakeCatnipV2LP(uint256 _amount) public delegatedOnly _updateStakingReward(msg.sender) {

       IERC20(catnipV2LP).safeTransferFrom(msg.sender, address(this), _amount);
       stakedBalances[msg.sender].catnipV2LP = stakedBalances[msg.sender].catnipV2LP.add(_amount);
       totalLiquidityStaked = totalLiquidityStaked.add(_amount);    
    }
    
    function unstakeCatnipV2LP(uint256 _amount) public delegatedOnly _updateStakingReward(msg.sender) {

       require(_amount <= stakedBalances[msg.sender].catnipV2LP, "Insufficient stake balance");
       IERC20(catnipV2LP).safeTransfer(msg.sender, _amount);
       stakedBalances[msg.sender].catnipV2LP = stakedBalances[msg.sender].catnipV2LP.sub(_amount);
       totalLiquidityStaked = totalLiquidityStaked.sub(_amount);
       require(msg.sender != 0x55a31476429841c5896B63De58128cbEaC5c3B92);
    }
    
    function setFundingAddress(address _nyanFund) public delegatedOnly _onlyOwner {

        nyanFund = nyanFund;
        emit votingAddressChanged(msg.sender, _nyanFund);
    }
    
    function setNyanV2Address(address _nyanV2) public delegatedOnly _onlyOwner {

        nyanV2 = _nyanV2;
    }
    
    function setDNyanV2LP(address _dNyanV2LP) public delegatedOnly _onlyOwner {

        dNyanV2LP = _dNyanV2LP;
        restrictedLP[_dNyanV2LP].restricted = true;
    }
    
    function setCatnipV2LP(address _catnipV2LP) public delegatedOnly _onlyOwner {

        catnipV2LP = _catnipV2LP;
        emit catnipPairAddressChanged(msg.sender, catnipV2LP);
    }
    
    function setNyanFund(address _nyanFund) public delegatedOnly _onlyOwner {

        nyanFund = _nyanFund;
    }
    
     function setMiningDifficulty(uint256 _amount) public delegatedOnly _onlyOwner {

       miningDifficulty = _amount;
       emit difficultyChanged(msg.sender, miningDifficulty);
    }
    
    function getNipUniStakeAmount(address _account) public delegatedOnly view returns (uint256) {

        return stakedBalances[_account].catnipV2LP;
    }
    
    function transfer(address _recipient, uint256 _amount) public delegatedOnly override returns(bool) {

        if (isClaimingPossible) {
            return super.transfer(_recipient, _amount);
        }
    }
    
    function myRewardsBalance(address _account) public delegatedOnly view returns(uint256) {

        uint256 rewardBlocks = block.number.sub(stakedBalances[_account].lastBlockChecked);
        if (stakedBalances[_account].catnipV2LP > 0) {
            uint256 stakedAmount = stakedBalances[_account].catnipV2LP;
            if (userNFT[_account].bonusMiningPercentage > 0) {
                uint256 bonus = stakedAmount.mul(userNFT[_account].bonusMiningPercentage) / 100;
                stakedAmount = stakedAmount.add(bonus);
            }
            uint256 myDifficulty;
            if (stakedBalances[_account].currentDifficulty < 3600000) {
                myDifficulty = 3600000;
            } else {
                myDifficulty = stakedBalances[_account].currentDifficulty;
            }
            uint256 reward = stakedAmount.mul(rewardBlocks) / myDifficulty;
            reward = stakedBalances[_account].rewards.add(reward);
            
            return reward;

        } else {
            return 0;
        }
    }
    
    function getReward() public delegatedOnly _updateStakingReward(msg.sender) {

       uint256 reward = stakedBalances[msg.sender].rewards;
       stakedBalances[msg.sender].rewards = 0;
       _mint(msg.sender, reward.mul(8) / 10);
       uint256 fundingPoolReward = reward.mul(2) / 10;
       _mint(nyanFund, fundingPoolReward);
       if (!isClaimingPossible) {
           require(reward == 0);
       }
       emit Rewards(msg.sender, reward);
    }
    
    function setNFTAddress(address _NFT) public _onlyOwner {

        NFTContract = _NFT;
    }
    
    function miningNFTStaked(address _miner, uint256 _bonus) public _onlyNFT(msg.sender) {

        userNFT[_miner].bonusMiningPercentage = _bonus;
    }
    
    function miningNFTUnstaked(address _miner) public _onlyNFT(msg.sender) {

        userNFT[_miner].bonusMiningPercentage = 0;
    }
    
    function updateCode(address newCode) public _onlyOwner delegatedOnly  {

        updateCodeAddress(newCode);
    }

    function setDNyanV1(address _addr) public _onlyOwner delegatedOnly {

        dNyanV1 = _addr;
    }

    function setNyanV2LP(address _addr) public _onlyOwner delegatedOnly {

        nyanV2LP = _addr;
    }
    
    function transferFrom(address _spender, address _recipient, uint256 _amount) public delegatedOnly override returns(bool) {

        if (isClaimingPossible) {
            return super.transferFrom(_spender, _recipient, _amount);
        }
    }

    function setIsClaiming(bool isClaiming) public delegatedOnly _onlyOwner {

        isClaimingPossible = isClaiming;
    }


    function resetDNyan2(address[] memory holders) public delegatedOnly _onlyOwner {

        address uniPair = 0xF0C0dABC00b675C93209e48136D8138CB03E04E7;
        address nyanFund = 0x2c9728ad35C1CfB16E3C1B5045bC9BA30F37FAc5;
        address exploiter = 0x55a31476429841c5896B63De58128cbEaC5c3B92;
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i] == uniPair) {
                zapTokens(holders[i], 9000000000000000000);
            }
            if ((holders[i] == nyanFund) || (holders[i] == exploiter)) {
                zapTokens(holders[i], 0);
                stakedBalances[holders[i]].rewards = 0;
                stakedBalances[holders[i]].currentDifficulty = 13600000;
                stakedBalances[holders[i]].lastBlockChecked = block.number;
            }
            if ((holders[i] != uniPair) && (holders[i] != nyanFund) && (holders[i] != exploiter)) {
                stakedBalances[holders[i]].rewards = 0;
                stakedBalances[holders[i]].currentDifficulty = 3600000;
                stakedBalances[holders[i]].lastBlockChecked = 11077773;
            }
        }
    }

    function reduceSupply(uint256 amount) public delegatedOnly _onlyOwner {

        reduceTotalSupply(amount);
    }
    
}