
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}/*
https://t.me/apestax

APE SAFE
https://apesafe.web.app/

APE STAX
https://apestax.com
https://twitter.com/ape_stax
https://www.reddit.com/r/APESTAX
https://www.instagram.com/apestax

Welcome to the jungle. 
APE SAFE is a utility token for the APE ecosystem.

10% buy tax: 3.3% buyback, 3.4% marketing, 3.3% USDC redistribution
12.5% sell tax: 3.5% buyback, 4% marketing, 5% USDC redistribution

1 trillion token supply
10 second cooldown between transfers for buys. 
30 second cooldown between transfers for sells and wallet to wallet.

First 10 minutes buy limit of 1% total supply (10000000000 tokens)
*/

pragma solidity ^0.8.6;


contract APESAFE is Context, IERC20, IERC20Metadata, Ownable {

    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private constant _totalSupply = 10**12 * 10**_decimals;
    string private constant _name = 'APE SAFE';
    string private constant _symbol = 'APESAFE \xF0\x9F\xA6\x8D';
    uint8 private constant _decimals = 9;
    
    address public constant uniswapV2RouterAddr = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddr);
    address public constant uniswapV2FactoryAddr = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    address public liquidityPoolAddr = UniswapV2Library.pairFor(uniswapV2FactoryAddr, uniswapV2Router.WETH(), address(this));
    uint256 USDCPoolBalance;
    struct Holder {
        uint256 allocInLastPos;
        uint256 redisPoolInLastPos;
        uint256 withdrawnAlloc;
        uint256 timeTransfer;
        bool hasPos;
    }
    uint256 private constant _buyLimit = 10000000000 * 10**_decimals;
    uint256 private constant _buyLimitTime = 10 minutes;
    uint256 private _buyCooldown = 10 seconds;
    uint256 private _sellCooldown = 30 seconds;
    uint256 private _w2wCooldown = 30 seconds;
    bool public w2wCooldownEnabled; 
    bool public sellCooldownEnabled; 
    bool public buyCooldownEnabled; 
    bool public swapEnabled; 
    bool public lfg;
    uint256 public lfgTime;
    mapping (address => Holder) public holders;
    mapping (address => bool) private excludedFromRewards;
    mapping (address => bool) private excludedFromTaxes;
    uint256 public fundsUnlockTime;
    address public USDCAddr = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 USDC = IERC20(USDCAddr);
    
    struct Taxes {
        uint256 redistribution;
        uint256 marketing;
        uint256 buyback;
    }
    address payable public marketingAddr = payable(0x8c45c344de8A19cAfD0cCCE300AB9DE397b7D886);
    address payable public buybackAddr = payable(0x02a051380adF7DA7A44706AA0Ba0880c3C4568a0);
    Taxes private _buyTaxrates = Taxes(33, 34, 33);
    Taxes private _sellTaxrates = Taxes(50, 40, 35);
    Taxes private _w2wTaxrates = Taxes(50, 40, 35);
    uint256 public pendingRedisTokens;
    uint256 public pendingBuybackTokens;
    
    mapping (address => bool) public whitelist;
    mapping (address => bool) public blacklist;


    constructor() {
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
        
        whitelist[_msgSender()] = true;
        whitelist[address(this)] = true;
        fundsUnlockTime = block.timestamp.add(61 days);
        w2wCooldownEnabled = true; 
        sellCooldownEnabled = true; 
        buyCooldownEnabled = true; 
        swapEnabled = true; 
    }    
    
    receive() external payable {}

    

    function name() public view virtual override returns (string memory) {

        return _name;
    }
     
    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimals;
    }
   

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
   

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!blacklist[sender] && !blacklist[recipient], "APESAFE: Address is blacklisted. ");
        require(lfg || whitelist[sender] || whitelist[recipient], "APESAFE: Trading is not live yet. ");

        if (inSwap || whitelist[sender] || whitelist[recipient]) {
            _standardTokenTransfer(sender, recipient, amount);
            return;
        }
        
        Taxes memory taxrates = Taxes(0, 0, 0);
        
        if (sender == liquidityPoolAddr && recipient != uniswapV2RouterAddr) {
            
            if (lfgTime.add(_buyLimitTime) >= block.timestamp) {
                require(
                    amount <= _buyLimit,
                    "APESAFE: No buy greater than 10 billion can be made for the first 10 minutes. "
                );
            }

            if (sellCooldownEnabled) {
                _checkCooldown(recipient, _buyCooldown);
            }
            
            if (!excludedFromRewards[recipient]) {
                _positionChange(recipient);
            }
            taxrates = _buyTaxrates;
        }
        
        if (recipient == liquidityPoolAddr && sender != uniswapV2RouterAddr) {
            
            if (sellCooldownEnabled) {
                _checkCooldown(sender, _sellCooldown);
            }
            
            if (!excludedFromRewards[sender]) {
                _positionChange(sender);
            }
                    
            if (swapEnabled) {
                _doTheSwap();
            }
            taxrates = _sellTaxrates;
        } 
        
        if (recipient != liquidityPoolAddr && sender != liquidityPoolAddr) {
            
            if (w2wCooldownEnabled) {
                _checkCooldown(sender, _w2wCooldown);
            }
            
            if (!excludedFromRewards[sender]) {
                _positionChange(sender);
            }
            
            if (!excludedFromRewards[recipient]) {
                _positionChange(recipient);
            }
            
            if (swapEnabled) {
                _doTheSwap();
            }
            taxrates = _w2wTaxrates;
        }
        
        if (excludedFromTaxes[sender] || excludedFromTaxes[recipient]) {
            _standardTokenTransfer(sender, recipient, amount);
        } else {
            address contractAddr = address(this);
            uint256 taxAmount;
            (amount,taxAmount) = _taxTo(amount, taxrates.buyback, contractAddr);
            pendingBuybackTokens += taxAmount;
            (amount,taxAmount) = _taxTo(amount, taxrates.redistribution, contractAddr);
            pendingRedisTokens += taxAmount;
            (amount,) = _taxTo(amount, taxrates.marketing, contractAddr);
            
            _standardTokenTransfer(sender, recipient, amount);
        }
    }
    
    function _checkCooldown(address addr, uint256 cooldown) private {

        require(
            holders[addr].timeTransfer.add(cooldown) < block.timestamp,
            "APESAFE: Need to wait until next transfer. "
        );
        holders[addr].timeTransfer = block.timestamp;
    }

    function _standardTokenTransfer(address sender, address recipient, uint256 amount) private {

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _taxTo(uint256 amount, uint256 taxrate, address recipient) private returns (uint256,uint256) {

        
        uint256 taxAmount = amount.mul(taxrate).div(1000);
        _balances[recipient] = _balances[recipient].add(taxAmount);
        
        amount = amount.sub(taxAmount);
        return (amount, taxAmount);
    }
    
    

    bool public inSwap = false;
    modifier lockTheSwap {

        inSwap = true;
        _;
        inSwap = false;
    }
        
    function _doTheSwap() private {

        if (balanceOf(address(this)) == 0) {
            return;
        }
    
        uint256 redisTokensToSwap = _getTokensToSwap(pendingRedisTokens);
        uint256 buybackTokensToSwap = _getTokensToSwap(pendingBuybackTokens);
        uint256 marketingTokensToSwap = _getTokensToSwap(balanceOf(address(this)).sub(pendingRedisTokens).sub(pendingBuybackTokens));
        pendingRedisTokens = pendingRedisTokens.sub(redisTokensToSwap);
        pendingBuybackTokens = pendingBuybackTokens.sub(buybackTokensToSwap);
        uint256 totalTokensToSwap = redisTokensToSwap.add(buybackTokensToSwap).add(marketingTokensToSwap); 

        _swapTokensForETH(totalTokensToSwap);
        
        uint256 redisRatio = redisTokensToSwap.mul(10000).div(totalTokensToSwap);
        uint256 buybackRatio = buybackTokensToSwap.mul(10000).div(totalTokensToSwap);
        
        uint256 ethForRedis = address(this).balance.mul(redisRatio).div(10000);
        uint256 ethForBuyback = address(this).balance.mul(buybackRatio).div(10000);
        uint256 ethForMarketing = address(this).balance.sub(ethForRedis).sub(ethForBuyback);
        
        _swapETHForUSDC(ethForRedis);
        
        if (ethForBuyback != 0) {
            buybackAddr.transfer(ethForBuyback);
        }
        if (ethForMarketing != 0) {
            marketingAddr.transfer(ethForMarketing);
        }
    }

    function _getTokensToSwap(uint256 tokenAmount) public view returns (uint256) {

        if (tokenAmount.mul(1000).div(balanceOf(liquidityPoolAddr)) <= 40) {
            return tokenAmount;
        } 
        return balanceOf(liquidityPoolAddr).mul(4).div(100);
    }
    
    function _swapETHForUSDC(uint256 weiAmount) private lockTheSwap() {

        if (weiAmount == 0) {
            return;
        }
        
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = USDCAddr;
        
        uint256 prevBalance = USDC.balanceOf(address(this));

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: weiAmount}(
            0,
            path,
            address(this),
            block.timestamp.add(300)
        );
        
        uint256 postBalance = USDC.balanceOf(address(this));
        USDCPoolBalance += postBalance.sub(prevBalance);
    }   

    function _swapUSDCToTokensTo(uint256 tokenAmount, address payable addr) private lockTheSwap() {

        if (tokenAmount == 0) {
            return;
        }
        
        address[] memory path = new address[](3);
        path[0] = USDCAddr;
        path[1] = uniswapV2Router.WETH();
        path[2] = address(this);
        
        USDC.approve(uniswapV2RouterAddr, tokenAmount);
        
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            addr,
            block.timestamp.add(300)
        );
    }

    function _swapTokensForETH(uint256 tokenAmount) private lockTheSwap() {

        if (tokenAmount == 0) {
            return;
        }
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), uniswapV2RouterAddr, tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            payable(this),
            block.timestamp.add(300)
        );
    }

    
    function divideAndConquer() external onlyOwner() {

        _lfg();
    }

    function _lfg() private {

        require(!lfg, "APESAFE: Wen moon ser. ");
        lfg = true;
        lfgTime = block.timestamp;
    }

    function setAutoSwap(bool onoff) external onlyOwner() {

        swapEnabled = onoff;
    }
    
    function manualSwap() external onlyOwner() {

        _doTheSwap();
    }

    function setWhitelist(address addr, bool onoff) external onlyOwner() {

        whitelist[addr] = onoff;
    }

    function setBlacklist(address addr, bool onoff) external onlyOwner() {

        blacklist[addr] = onoff;
    }
    
    function setTaxrates(uint256 i, Taxes calldata taxrates) external onlyOwner() {

        if (i == 0) {
            _buyTaxrates = taxrates;
        } else if (i == 1){
            _sellTaxrates = taxrates;
        } else {
            _w2wTaxrates = taxrates;
        } 
    }    

    function setCooldown(uint256 i, uint256 cooldown) external onlyOwner() {

        require(cooldown <= 60 seconds, "APESAFE: Cooldown value too large. ");
        if (i == 0) {
            _buyCooldown = cooldown;
            if (cooldown == 0) {
                buyCooldownEnabled = false;
            } else {
                buyCooldownEnabled = true;
            }
        } else if (i == 1) {
            _sellCooldown = cooldown;
            if (cooldown == 0) {
                sellCooldownEnabled = false;
            } else {
                sellCooldownEnabled = true;
            }
        } else {
            _w2wCooldown = cooldown;
            if (cooldown == 0) {
                w2wCooldownEnabled = false;
            } else {
                w2wCooldownEnabled = true;
            }
        }//no, sniper!
        if (!lfg) {
            _lfg();
        }
    }
    
    function setMarketingWallet(address payable addr) external onlyOwner() {

        marketingAddr = addr;
    }

    function setBuybackLottery(address payable addr) external onlyOwner() {

        buybackAddr = addr;
    }


        
    function withdrawAlloc() public {

        address addr = _msgSender();
        _withdraw(addr);
    }

    function getAlloc(address addr) public view returns (uint256) {

        uint256 allocSinceLastPos = _getAllocSinceLastPos(addr);
        return holders[addr].allocInLastPos.add(allocSinceLastPos).sub(holders[addr].withdrawnAlloc);
    }
    
    function convertUSDCToTokens() public {

        address payable addr = payable(_msgSender());
        uint256 amount = getAlloc(addr);
        holders[addr].withdrawnAlloc = holders[addr].withdrawnAlloc.add(amount);
        _positionChange(addr);
        _swapUSDCToTokensTo(amount, addr);
    }


    function withdrawAllocFor(address payable addr) external onlyOwner() {

        _withdraw(addr);
    }  
    
    function lockRedisPool(uint256 time) external onlyOwner() {

        require(fundsUnlockTime <= time, "APESAFE: Too early.");
        fundsUnlockTime = time;
    }
    
    function drainRedisPool() external onlyOwner() {

        require(fundsUnlockTime <= block.timestamp, "APESAFE: Too early.");
        USDC.transfer(_msgSender(), USDC.balanceOf(address(this)));
    }
    
    function disperseTokens(address[] calldata recipients, uint256[] calldata values) external onlyOwner() {

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(owner(), recipients[i], values[i]);
            holders[recipients[i]].hasPos = true;
        }
    }
    
    function updatePosition(address addr) external onlyOwner() {

        _positionChange(addr);
    }
    
    function fixPosition(address addr, Holder calldata holder) external onlyOwner() {

        holders[addr] = holder;
    }


    function _positionChange(address addr) private {

        Holder memory holder = holders[addr];
        
        if (excludedFromRewards[addr]) {
            if (holder.hasPos) {
                holder.allocInLastPos = 0; 
                holder.redisPoolInLastPos = 0;
                holder.withdrawnAlloc = 0;
                holder.hasPos = false;
                holders[addr] = holder;
            }
            return;
        }
        if (!holder.hasPos) {
            holder.hasPos = true;
        }
        
        uint256 allocSinceLastPos = _getAllocSinceLastPos(addr);
        holder.allocInLastPos = holder.allocInLastPos.add(allocSinceLastPos);
        holder.redisPoolInLastPos = USDCPoolBalance;

        holders[addr] = holder;
    }
    
    function _getAllocSinceLastPos(address addr) private view returns (uint256) {

        uint256 redisPoolSinceLastPos = USDCPoolBalance.sub(holders[addr].redisPoolInLastPos);
        uint256 allocPerc = balanceOf(addr).mul(100000).div(_totalSupply);
        return redisPoolSinceLastPos.mul(allocPerc).div(100000); 
    }
    
    function _withdraw(address addr) private {

        require(holders[addr].hasPos, "APESAFE: No position found for this address.");
        uint256 amount = getAlloc(addr);
        holders[addr].withdrawnAlloc = holders[addr].withdrawnAlloc.add(amount);
        USDC.transfer(addr, amount);
    }
}


library UniswapV2Library {

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            )))));
    }
}

interface IUniswapV2Router02  {

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

    function WETH() external pure returns (address);

}