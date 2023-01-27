pragma solidity 0.8.4;

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
}//MIT
pragma solidity 0.8.4;


library Address {


    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

}// GPL-3.0

pragma solidity 0.8.4;

contract Ownable {


    address private owner;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier onlyOwner() {

        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address newOwner) public onlyOwner {

        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {

        return owner;
    }
}//MIT
pragma solidity 0.8.4;

interface IERC20 {


    function totalSupply() external view returns (uint256);

    
    function symbol() external view returns(string memory);

    
    function name() external view returns(string memory);


    function balanceOf(address account) external view returns (uint256);

    
    function decimals() external view returns (uint8);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//MIT
pragma solidity 0.8.4;


interface IXSurge is IERC20 {

    function exchange(address tokenIn, address tokenOut, uint256 amountTokenIn, address destination) external;

    function burn(uint256 amount) external;

    function mintWithNative(address recipient, uint256 minOut) external payable returns (uint256);

    function mintWithBacking(address backingToken, uint256 numTokens, address recipient) external returns (uint256);

    function requestPromiseTokens(address stable, uint256 amount) external returns (uint256);

    function sell(uint256 tokenAmount) external returns (address, uint256);

    function calculatePrice() external view returns (uint256);

    function getValueOfHoldings(address holder) external view returns(uint256);

    function isUnderlyingAsset(address token) external view returns (bool);

    function getUnderlyingAssets() external view returns(address[] memory);

    function requestFlashLoan(address stable, address stableToRepay, uint256 amount) external returns (bool);

    function resourceCollector() external view returns (address);

}

interface ITokenFetcher {

    function ethToStable(address stable, uint256 minOut) external payable;

    function chooseStable() external view returns (address);

}

interface IPromiseUSD {

    function mint(uint256 amount) external;

    function setApprovedContract(address Contract, bool _isApproved) external;

}

interface ILoanProvider {

    function fulfillFlashLoanRequest() external returns (bool);

}

contract XUSD is IXSurge, Ownable {

    
    using SafeMath for uint256;
    using Address for address;

    string private constant _name = "XUSD";
    string private constant _symbol = "XUSD";
    uint8 private constant _decimals = 18;
    uint256 private constant precision = 10**18;
    
    uint256 private _totalSupply = 10**18; 
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    uint256 public mintFee        = 99250;            // 0.75% mint fee
    uint256 public sellFee        = 99750;            // 0.25% redeem fee 
    uint256 public transferFee    = 99750;            // 0.25% transfer fee
    uint256 public constant feeDenominator = 10**5;
    
    struct StableAsset {
        bool isApproved;
        bool mintDisabled;
        uint8 index;
    }
    address[] public stables;
    mapping ( address => StableAsset ) public stableAssets;
    
    mapping ( address => bool ) public isTransferFeeExempt;

    address public immutable PROMISE_USD;
    address public immutable TokenProposalContract;

    address public xSwapRouter;
    address private _resourceCollector;
    address public flashLoanProvider;
    ITokenFetcher public TokenFetcher;
    
    uint256 public resourceAllocationPercentage;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    modifier nonReentrant() {

        require(_status != _ENTERED, "Reentrancy Guard call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier notEntered() {

        require(_status != _ENTERED, "Reentrant call");
        _;
    }

    constructor (
        address PromiseUSD,
        address NewTokenProposal
    ) {
        require(
            PromiseUSD != address(0) &&
            NewTokenProposal != address(0)
        );

        PROMISE_USD = PromiseUSD;
        TokenProposalContract = NewTokenProposal;

        _status = _NOT_ENTERED;

        resourceAllocationPercentage = 50;

        address BUSD = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
        stables.push(BUSD);
        stableAssets[BUSD].isApproved = true;
        stableAssets[BUSD].index = 0;

        address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        stables.push(USDC);
        stableAssets[USDC].isApproved = true;
        stableAssets[USDC].index = 1;
        
        isTransferFeeExempt[0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45] = true;
        isTransferFeeExempt[PromiseUSD]                                 = true;
        isTransferFeeExempt[_resourceCollector]                         = true;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { 

        return _totalSupply; 
    }

    function balanceOf(address account) public view override returns (uint256) { 

        return _balances[account]; 
    }

    function allowance(address holder, address spender) external view override returns (uint256) { 

        return _allowances[holder][spender]; 
    }
    
    function name() public pure override returns (string memory) {

        return _name;
    }

    function symbol() public pure override returns (string memory) {

        return _symbol;
    }

    function decimals() public pure override returns (uint8) {

        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
  
    function transfer(address recipient, uint256 amount) external override returns (bool) {

        if (recipient == msg.sender) {
            require(_status != _ENTERED, "Reentrant call");
            _sell(msg.sender, expectedTokenToReceive(amount), amount, recipient);
            return true;
        } else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, 'Insufficient Allowance');
        return _transferFrom(sender, recipient, amount);
    }
    
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        require(recipient != address(0) && sender != address(0), "Transfer To Zero");
        require(amount > 0, "Transfer Amt Zero");
        uint256 oldPrice = _calculatePrice();
        bool isExempt = isTransferFeeExempt[sender] || isTransferFeeExempt[recipient];
        uint256 tAmount = isExempt ? amount : amount.mul(transferFee).div(feeDenominator);
        uint256 tax = amount.sub(tAmount);
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        if (shouldAllocateResources(isExempt, sender, recipient)) {
            _allocateResources(tax);
        }

        _balances[recipient] = _balances[recipient].add(tAmount);

        if (tax > 0) {
            _totalSupply = _totalSupply.sub(tax);
            emit Transfer(sender, address(0), tax);
        }
        
        _requirePriceRises(oldPrice);
        emit Transfer(sender, recipient, tAmount);
        return true;
    }

    function mintWithNative(address recipient, uint256 minOut) external override payable returns (uint256) {

        _checkGarbageCollector(address(this));
        return _mintWithNative(recipient, minOut);
    }
    
    function mintWithBacking(address backingToken, uint256 numTokens) external nonReentrant returns (uint256) {

        _checkGarbageCollector(address(this));
        return _mintWithBacking(backingToken, numTokens, msg.sender);
    }

    function mintWithBacking(address backingToken, uint256 numTokens, address recipient) external override nonReentrant returns (uint256) {

        _checkGarbageCollector(address(this));
        return _mintWithBacking(backingToken, numTokens, recipient);
    }

    function sell(uint256 tokenAmount) external override notEntered returns (address, uint256) {

        address tokenToSend = expectedTokenToReceive(tokenAmount);
        return _sell(msg.sender, tokenToSend, tokenAmount, msg.sender);
    }
    
    function sell(uint256 tokenAmount, address desiredToken) external notEntered returns (address, uint256) {

        return _sell(msg.sender, desiredToken, tokenAmount, msg.sender);
    }
    
    function sell(uint256 tokenAmount, address desiredToken, address recipient) external notEntered returns (address, uint256) {

        return _sell(msg.sender, desiredToken, tokenAmount, recipient);
    }

    function exchange(address tokenIn, address tokenOut, uint256 tokenInAmount, address recipient) external override nonReentrant {

        require(
            tokenIn != address(0) && 
            tokenOut != address(0) && 
            recipient != address(0) &&
            tokenIn != tokenOut &&
            tokenInAmount > 0,
            'Invalid Params'
        );
        require(
            !stableAssets[tokenIn].mintDisabled,
            'TokenIn Disabled'
        );
        require(
            stableAssets[tokenIn].isApproved &&
            stableAssets[tokenOut].isApproved,
            'Not Approved'
        );
        require(
            IERC20(tokenIn).decimals() == IERC20(tokenOut).decimals(),
            'Decimal Mismatch'
        );
        require(
            msg.sender == xSwapRouter,
            'Only Router'
        );
        _swapStables(tokenIn, tokenOut, tokenInAmount, recipient);
    }
    
    function burn(uint256 amount) external override notEntered {

        uint256 bal = _balances[msg.sender];
        require(bal >= amount && bal > 0, 'Zero Holdings');
        uint256 oldPrice = _calculatePrice();
        _burn(msg.sender, amount);
        _requirePriceRises(oldPrice);
        emit Burn(msg.sender, amount);
    }

    function requestPromiseTokens(address stable, uint256 amount) external override nonReentrant returns (uint256) {

        require(msg.sender == PROMISE_USD, 'Only Promise');
        require(stableAssets[stable].isApproved, 'Non Approved Stable');

        uint256 oldPrice = _calculatePrice();

        uint256 amountUnderlyingToDeliver = amountOut(amount);
        require(
            amountUnderlyingToDeliver > 0 &&
            amountUnderlyingToDeliver <= IERC20(stable).balanceOf(address(this)),
            'Invalid Amount'
        );

        bool successful = IERC20(stable).transfer(PROMISE_USD, amountUnderlyingToDeliver);
        require(successful, 'Transfer Failure');

        IPromiseUSD(PROMISE_USD).mint(amountUnderlyingToDeliver);

        _requirePriceRises(oldPrice);

        emit PromiseTokens(amount, amountUnderlyingToDeliver);

        return amountUnderlyingToDeliver;
    }

    function requestFlashLoan(address stable, address stableToRepay, uint256 amount) external override nonReentrant returns (bool) {

        require(
            msg.sender == flashLoanProvider,
            'Only Flash Loan Provider'
        );
        require(
            stableAssets[stable].isApproved,
            'Not Approved'
        );
        require(
            stableAssets[stableToRepay].isApproved &&
            !stableAssets[stableToRepay].mintDisabled,
            'Repayment Stable Not Approved'
        );
        require(
            amount <= IERC20(stable).balanceOf(address(this)),
            "Insufficient Balance"
        );

        uint256 oldLiquidity = liquidityInStableCoinSwap();

        uint256 oldPrice = _calculatePrice();

        uint256 oldBacking = calculateBacking();

        IERC20(stable).transfer(flashLoanProvider, amount);

        require(
            ILoanProvider(flashLoanProvider).fulfillFlashLoanRequest(),
            'Fulfilment Request Failed'
        );
        
        uint256 newLiquidity = liquidityInStableCoinSwap();

        require(
            newLiquidity >= oldLiquidity &&
            calculateBacking() >= oldBacking, 
            "Flash loan not paid back"
        );

        _requirePriceRises(oldPrice);

        emit FlashLoaned(stable, stableToRepay, amount, newLiquidity - oldLiquidity + amount);
        return true;
    }



    
    function _mintWithNative(address recipient, uint256 minOut) internal nonReentrant returns (uint256) {        

        require(msg.value > 0, 'Zero Value');
        require(recipient != address(0));
        
        uint256 oldPrice = _calculatePrice();
        
        uint256 previousBacking = calculateBacking();
        
        uint256 received = _swapForStable(minOut);

        uint256 relevantBacking = previousBacking == 0 ? calculateBacking() : previousBacking;

        return _mintTo(recipient, received, relevantBacking, oldPrice);
    }
    
    function _mintWithBacking(address token, uint256 numTokens, address recipient) internal returns (uint256) {

        require(stableAssets[token].isApproved && token != address(0), 'Token Not Approved');
        uint256 userTokenBalance = IERC20(token).balanceOf(msg.sender);
        require(userTokenBalance > 0 && numTokens <= userTokenBalance, 'Insufficient Balance');
        require(!stableAssets[token].mintDisabled, 'Mint Is Disabled With This Token');

        uint256 oldPrice = _calculatePrice();

        uint256 previousBacking = calculateBacking();

        uint256 received = _transferIn(token, numTokens);

        uint256 relevantBacking = previousBacking == 0 ? received : previousBacking;

        return _mintTo(recipient, received, relevantBacking, oldPrice);
    }
    
    function _sell(address seller, address desiredToken, uint256 tokenAmount, address recipient) internal nonReentrant returns (address, uint256) {

        require(tokenAmount > 0 && _balances[seller] >= tokenAmount);
        require(seller != address(0) && recipient != address(0));
        
        uint256 oldPrice = _calculatePrice();
        
        uint256 tokensToSwap = isTransferFeeExempt[seller] ? 
            tokenAmount.sub(10, 'Minimum Exemption') :
            tokenAmount.mul(sellFee).div(feeDenominator);

        uint256 amountUnderlyingAsset = amountOut(tokensToSwap);
        require(_validToSend(desiredToken, amountUnderlyingAsset), 'Invalid Token');

        _burn(seller, tokenAmount);
        
        if (shouldAllocateResources(isTransferFeeExempt[seller], seller, recipient)) {
            _allocateResources(tokenAmount.sub(tokensToSwap));
        }

        bool successful = IERC20(desiredToken).transfer(recipient, amountUnderlyingAsset);

        require(successful, 'Transfer Failure');

        _requirePriceRises(oldPrice);
        emit Redeemed(seller, tokenAmount, amountUnderlyingAsset);
        return (desiredToken, amountUnderlyingAsset);
    }

    function _mintTo(address recipient, uint256 received, uint256 totalBacking, uint256 oldPrice) private returns(uint256) {

        
        uint256 calculatedSupply = _totalSupply == 0 ? 10**18 : _totalSupply;
        uint256 tokensToMintNoTax = calculatedSupply.mul(received).div(totalBacking);
        
        uint256 tokensToMint = isTransferFeeExempt[msg.sender] ? 
                tokensToMintNoTax.sub(10, 'Minimum Exemption') :
                tokensToMintNoTax.mul(mintFee).div(feeDenominator);
        require(tokensToMint > 0, 'Zero Amount');
        
        if (shouldAllocateResources(isTransferFeeExempt[msg.sender], msg.sender, recipient)) {
            _allocateResources(tokensToMintNoTax.sub(tokensToMint));
        }
        
        _mint(recipient, tokensToMint);
        _requirePriceRises(oldPrice);
        emit Minted(recipient, tokensToMint);
        return tokensToMint;
    }

    function _swapForStable(uint256 minOut) internal returns (uint256) {


        address stable = TokenFetcher.chooseStable();
        require(stableAssets[stable].isApproved && !stableAssets[stable].mintDisabled);

        uint256 prevTokenAmount = IERC20(stable).balanceOf(address(this));

        TokenFetcher.ethToStable{value: address(this).balance}(stable, minOut);

        uint256 currentTokenAmount = IERC20(stable).balanceOf(address(this));
        require(currentTokenAmount > prevTokenAmount);
        return currentTokenAmount - prevTokenAmount;
    }

    function _swapStables(address tokenIn, address tokenOut, uint256 tokenInAmount, address recipient) internal {


        uint256 oldPrice = _calculatePrice();

        uint256 received = _transferIn(tokenIn, tokenInAmount);

        require(
            received <= tokenInAmount && received > 0,
            'SC'
        );
        require(
            IERC20(tokenOut).balanceOf(address(this)) >= received,
            'Insufficient Balance'
        );

        bool s = IERC20(tokenOut).transfer(recipient, received);
        require(s, 'Transfer Fail');

        _requirePriceRises(oldPrice);

        emit ExchangeStables(tokenIn, tokenOut, tokenInAmount, received, recipient);
    }

    function _requirePriceRises(uint256 oldPrice) internal {

        uint256 newPrice = _calculatePrice();
        require(newPrice >= oldPrice, 'Price Cannot Fall');
        emit PriceChange(oldPrice, newPrice, _totalSupply);
    }

    function _transferIn(address token, uint256 desiredAmount) internal returns (uint256) {

        uint256 balBefore = IERC20(token).balanceOf(address(this));
        bool s = IERC20(token).transferFrom(msg.sender, address(this), desiredAmount);
        uint256 received = IERC20(token).balanceOf(address(this)) - balBefore;
        require(s && received > 0 && received <= desiredAmount);
        return received;
    }
    
    function _allocateResources(uint256 tax) private {

        uint256 allocation = tax.mul(resourceAllocationPercentage).div(100);
        if (allocation > 0) {
            _mint(_resourceCollector, allocation);
        }
    }
    
    function _mint(address receiver, uint amount) private {

        _balances[receiver] = _balances[receiver].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), receiver, amount);
    }
    
    function _burn(address account, uint amount) private {

        _balances[account] = _balances[account].sub(amount, 'Insufficient Balance');
        _totalSupply = _totalSupply.sub(amount, 'Negative Supply');
        emit Transfer(account, address(0), amount);
    }

    function _checkGarbageCollector(address burnLocation) internal {

        uint256 bal = _balances[burnLocation];
        if (bal > 0) {
            uint256 oldPrice = _calculatePrice();
            _burn(burnLocation, bal);
            emit GarbageCollected(bal);
            emit PriceChange(oldPrice, _calculatePrice(), _totalSupply);
        }
    }
    
    

    function calculatePrice() external view override returns (uint256) {

        return _calculatePrice();
    }
    
    function _calculatePrice() internal view returns (uint256) {

        uint256 totalShares = _totalSupply == 0 ? 1 : _totalSupply;
        uint256 backingValue = calculateBacking();
        return (backingValue.mul(precision)).div(totalShares);
    }

    function amountOut(uint256 numTokens) public view returns (uint256) {

        return _calculatePrice().mul(numTokens).div(precision);
    }

    function getValueOfHoldings(address holder) public view override returns(uint256) {

        return amountOut(_balances[holder]);
    }

    function isUnderlyingAsset(address token) external view override returns (bool) {

        return stableAssets[token].isApproved;
    }

    function getUnderlyingAssets() external override view returns(address[] memory) {

        return stables;
    }

    function calculateBacking() public view returns (uint256) {

        uint total = liquidityInStableCoinSwap();
        return total + IERC20(PROMISE_USD).totalSupply();
    }

    function liquidityInStableCoinSwap() public view returns (uint256 total) {

        for (uint i = 0; i < stables.length; i++) {
            total += IERC20(stables[i]).balanceOf(address(this));
        }
    }

    function expectedTokenToReceive(uint256 amount) public view returns (address) {

        uint MAX = 0;
        address tokenToReceive;
        uint bal;
        for (uint i = 0; i < stables.length; i++) {
            bal = IERC20(stables[i]).balanceOf(address(this));
            if (bal > MAX) {
                tokenToReceive = stables[i];
                MAX = bal;
            }
        }
        return _validToSend(tokenToReceive, amountOut(amount)) ? tokenToReceive : address(0);
    }

    function resourceCollector() external view override returns (address) {

        return _resourceCollector;
    }

    function shouldAllocateResources(bool feeExempt, address caller, address recipient) internal view returns (bool) {

        return 
            !feeExempt
            && caller != _resourceCollector
            && recipient != _resourceCollector
            && resourceAllocationPercentage > 0;
    }
    
    function _validToSend(address stable, uint256 amount) internal view returns (bool) {

        return 
            stable != address(0) && 
            stableAssets[stable].isApproved && 
            amount > 0 &&
            IERC20(stable).balanceOf(address(this)) >= amount;
    }
    

    function upgradeFlashLoanProvider(address flashLoanProvider_) external onlyOwner {

        require(flashLoanProvider_ != address(0));
        flashLoanProvider = flashLoanProvider_;
        emit SetFlashLoanProvider(flashLoanProvider_);
    }

    function upgradeTokenFetcher(ITokenFetcher tokenFetcher) external onlyOwner {

        require(address(tokenFetcher) != address(0));
        TokenFetcher = tokenFetcher;
        emit SetTokenFetcher(address(tokenFetcher));
    }

    function upgradeXSwapRouter(address _newRouter) external onlyOwner {

        require(_newRouter != address(0));
        xSwapRouter = _newRouter;
        emit SetXSwapRouter(_newRouter);
    }

    function upgradeResourceCollector(address newCollector, uint256 _allocationPercentage) external onlyOwner {

        require(newCollector != address(0));
        require(_allocationPercentage <= 90);
        if (!isTransferFeeExempt[newCollector]) {
            isTransferFeeExempt[newCollector] = true;
        }
        _resourceCollector = newCollector;
        resourceAllocationPercentage = _allocationPercentage;
        emit SetResourceCollector(newCollector, _allocationPercentage);
    }

    function disableMintForStable(address stable, bool isDisabled) external onlyOwner {

        require(stable != address(0));
        require(stableAssets[stable].isApproved);
        stableAssets[stable].mintDisabled = isDisabled;
    }

    function addStable(address newStable) external {

        require(msg.sender == TokenProposalContract);
        require(!stableAssets[newStable].isApproved);
        require(newStable != address(0));
        require(IERC20(newStable).decimals() == 18);

        stableAssets[newStable].isApproved = true;
        stableAssets[newStable].index = uint8(stables.length);
        stables.push(newStable);
    }

    function removeStable(address stable, address stableToSwapWith) external nonReentrant onlyOwner {

        require(stableAssets[stable].isApproved);
        require(stableAssets[stableToSwapWith].isApproved);
        require(stableToSwapWith != stable, 'Matching Swap');
        require(stableToSwapWith != PROMISE_USD && stable != PROMISE_USD, 'Promise');

        uint256 oldPrice = _calculatePrice();

        stableAssets[
            stables[stables.length - 1]
        ].index = stableAssets[stable].index;

        stables[
            stableAssets[stable].index
        ] = stables[stables.length - 1];

        stables.pop();
        delete stableAssets[stable];
        
        uint256 bal = IERC20(stable).balanceOf(address(this));
        uint256 received = _transferIn(stableToSwapWith, bal);
        
        require(
            IERC20(stable).transfer(msg.sender, received),
            'Failure Transfer Out'
        );

        _requirePriceRises(oldPrice);
    }

    function withdrawNonStableToken(address token) external onlyOwner {

        require(!stableAssets[token].isApproved);
        require(token != address(0) && token != PROMISE_USD);
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function redeemForLostAccount(address account, uint256 amount) external onlyOwner {

        require(account != address(0));
        require(account != PROMISE_USD);
        require(_balances[account] > 0 && _balances[account] >= amount);

        isTransferFeeExempt[account] = true;
        _sell(
            account, 
            expectedTokenToReceive(amount),
            amount == 0 ? _balances[account] : amount, 
            account
        );
        isTransferFeeExempt[account] = false;
    }

    function setFees(uint256 _mintFee, uint256 _transferFee, uint256 _sellFee) external onlyOwner {

        require(_mintFee >= 98000);      // capped at 2% fee
        require(_transferFee >= 98000);  // capped at 2% fee
        require(_sellFee >= 98000);      // capped at 2% fee
        
        mintFee = _mintFee;
        transferFee = _transferFee;
        sellFee = _sellFee;
        emit SetFees(_mintFee, _transferFee, _sellFee);
    }
    
    function setPermissions(address Contract, bool transferFeeExempt) external onlyOwner {

        require(Contract != address(0) && Contract != PROMISE_USD);
        isTransferFeeExempt[Contract] = transferFeeExempt;
        emit SetPermissions(Contract, transferFeeExempt);
    }

    function setApprovedPromiseUSDContract(address Contract, bool isApprovedForPromiseUSD) external onlyOwner {

        require(Contract != address(0));
        IPromiseUSD(PROMISE_USD).setApprovedContract(Contract, isApprovedForPromiseUSD);
    }
    
    receive() external payable {
        _mintWithNative(msg.sender, 0);
        _checkGarbageCollector(address(this));
    }
    
    
    
    event PriceChange(uint256 previousPrice, uint256 currentPrice, uint256 totalSupply);
    event TokenActivated(uint blockNo);

    event Burn(address from, uint256 amountTokensErased);
    event GarbageCollected(uint256 amountTokensErased);
    event Redeemed(address seller, uint256 amountxUSD, uint256 assetsRedeemed);
    event Minted(address recipient, uint256 numTokens);

    event SetFlashLoanProvider(address newFlashProvider);
    event SetTokenFetcher(address newTokenFetcher);
    event SetXSwapRouter(address newRouter);
    event SetResourceCollector(address newCollector, uint256 allocation);

    event PromiseTokens(uint256 tokensLocked, uint256 assetsGhosted);
    event FlashLoaned(address token, address repaymentToken, uint256 amountLent, uint256 amountReceived);
    event ExchangeStables(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut, address recipient);

    event TransferOwnership(address newOwner);
    event SetPermissions(address Contract, bool feeExempt);
    event SetFees(uint mintFee, uint transferFee, uint sellFee);
}