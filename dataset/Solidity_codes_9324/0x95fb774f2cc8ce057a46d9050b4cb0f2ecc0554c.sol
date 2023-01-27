
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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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

interface AggregatorV3Interface {


  function decimals()
    external
    view
    returns (
      uint8
    );


  function description()
    external
    view
    returns (
      string memory
    );


  function version()
    external
    view
    returns (
      uint256
    );


  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}// MIT;

pragma solidity >=0.8.0;


contract ICO is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint;

    struct ICOStateSchema {
        uint256 currentIteration;
        uint256 currentPrice;
        uint256 ICOAllocatedTokensAmount;
        uint256 tokensLeft;
    }

    uint256 public oneIterationTokenAmount = 10 * 10 ** 6 * 10 ** 10;

    bool public icoCompleted;
    uint256 public icoStartTime;
    uint256 public icoEndTime;
    address public tokenAddress;
    uint256 public currentIterationOfICO;
    uint256 public current_allocatedTokens;
    uint256 public minLimit = 1 * 10 ** 10;
    uint256 public maxLimit = 1 * 10 ** 8 * 10 ** 10;
    uint256 private referralBonus = 20;
    uint256 private commission = 8 * 10 ** 15;
    uint256 private maxRoundICO = 200;

    AggregatorV3Interface private priceFeed;
    uint256 public usdPrice;
    uint256 private startPriceInUSD = 5; // since this value is 0.0005 . Multiplying it by 10000
    uint256 private stepPriceInUSD;

    mapping(address => bool) allowedInvestors;

    event Allocated(uint256 amount);
    event WithdrawedETH(address user, uint256 amount);
    event MinLimitUpdated(uint256 newLimit);
    event MaxLimitUpdated(uint256 newLimit);
    event Bought(address buyer, uint256 amount, uint256 usdPrice);

    modifier allowedInvestor {

        require(allowedInvestors[msg.sender], "Your address not allowed. Please contact with owner.");
        _;
    }

    modifier whenIcoStart {

        require(!icoCompleted, 'ICO completed');
        require(icoStartTime != 0, 'ICO has not started yet');
        _;
    }

    constructor(address _tokenAddress, address owner){
        require(_tokenAddress != address(0) && owner != address(0), "Incorrect addresses");
        tokenAddress = _tokenAddress;
        transferOwnership(owner);
        allowedInvestors[owner] = true;
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    function startICO() public onlyOwner {

        require(icoStartTime == 0, "ICO was started before");
        _allocate();
        icoStartTime = block.timestamp;
    }

    function setMinLimit(uint256 newLimit) public onlyOwner {

        minLimit = newLimit;
        emit MinLimitUpdated(maxLimit);
    }

    function setMaxLimit(uint256 newLimit) public onlyOwner {

        maxLimit = newLimit;
        emit MaxLimitUpdated(maxLimit);
    }

    function setReferralBonus(uint256 _bonus) external onlyOwner {

        require(_bonus <= 100, 'Referral bonus should not be more than 100%');
        referralBonus = _bonus;
    }

    function getReferralBonus() external view returns (uint256) {

        return referralBonus;
    }

    function setCommission(uint256 _commission) external onlyOwner {

        commission = _commission;
    }

    function getCommission() external view returns (uint256) {

        return commission;
    }

    function addAddressToAllowed(address client) public onlyOwner {

        allowedInvestors[client] = true;
    }

    function removeAddressFromAllowed(address client) public onlyOwner {

        allowedInvestors[client] = false;
    }

    function _allocate() private {

        require(currentIterationOfICO <= maxRoundICO, 'Funding cycle ended');
        if (icoStartTime == 0) {
            usdPrice = startPriceInUSD;
        } else if (currentIterationOfICO == 0) {
            oneIterationTokenAmount = 19 * 10 ** 5 * 10 ** 10;
            usdPrice = 10;
            stepPriceInUSD = 1;
            currentIterationOfICO++;
        } else if (currentIterationOfICO > 0 && currentIterationOfICO < 100) {
            usdPrice = usdPrice.add(stepPriceInUSD);
            currentIterationOfICO++;
        } else if (currentIterationOfICO == 100) {
            oneIterationTokenAmount = 8 * 10 ** 6 * 10 ** 10;
            usdPrice = 110;
            stepPriceInUSD = 10;
            currentIterationOfICO++;
        } else if (currentIterationOfICO > 100 && currentIterationOfICO <= maxRoundICO) {
            usdPrice = usdPrice.add(stepPriceInUSD);
            currentIterationOfICO++;
        }
        current_allocatedTokens = current_allocatedTokens.add(oneIterationTokenAmount);
        emit Allocated(current_allocatedTokens);
    }

    receive() external payable {
        buy();
    }

    function _getAmountForETH(uint amountETH) private view returns (uint256){

        (
        ,
        int rate,
        ,
        ,
        ) = priceFeed.latestRoundData();
        uint256 usdAmount = amountETH.mul(uint256(rate)).div(10 ** 8);
        uint256 amountTokens = usdAmount.div(usdPrice).div(10 ** 14).mul(10 ** 10);
        if (amountTokens > current_allocatedTokens) {
            uint256 tokenPrice = usdPrice;
            uint256 current_allocated = current_allocatedTokens;
            uint256 icoRound = currentIterationOfICO;
            amountTokens = 0;
            while (usdAmount > 0) {
                uint256 amount = usdAmount.div(tokenPrice).div(10 ** 4);
                if (amount > current_allocated) {
                    amountTokens = amountTokens.add(current_allocated);
                    uint256 ethForAllocated = getCost(current_allocated);
                    uint256 usdForAllocated = ethForAllocated.mul(uint256(rate)).div(10 ** 8);
                    usdAmount = usdAmount.sub(usdForAllocated);
                    if (currentIterationOfICO < maxRoundICO) {
                        icoRound++;
                    }
                    (uint256 roundPrice, uint256 stepPrice) = getTokenPrice(icoRound);
                    tokenPrice = roundPrice.add(stepPrice);
                    amount = usdAmount.div(tokenPrice).div(10 ** 4);
                    current_allocated = getTokensPerIteration(icoRound);
                } else if (amount <= current_allocated) {
                    amountTokens = amountTokens.add(amount);
                    usdAmount = 0;
                }
            }
        }
        return amountTokens;
    }

    function getCost(uint amount) public view returns (uint256){

        uint256 usdCost;
        uint256 ethCost;
        int exchangeRate = getLatestPrice();
        if (amount <= current_allocatedTokens) {
            usdCost = amount.mul(usdPrice).div(10 ** 4);
            ethCost = getPriceInETH(usdCost, exchangeRate);
        } else {
            uint256 price = usdPrice;
            uint256 stepPrice;
            uint256 current_allocated = current_allocatedTokens;
            uint256 icoRound = currentIterationOfICO;
            uint256 iterationAmount;
            while (amount > 0) {
                if (current_allocated > 0) {
                    amount = amount.sub(current_allocated);
                    usdCost = current_allocated.div(10 ** 4).mul(price).add(usdCost);
                    current_allocated = 0;
                    icoRound++;
                    (price, stepPrice) = getTokenPrice(icoRound);
                    price = price.add(stepPrice);
                }
                iterationAmount = getTokensPerIteration(icoRound);
                if (amount > iterationAmount) {
                    amount = amount.sub(iterationAmount);
                    usdCost = iterationAmount.div(10 ** 4).mul(price).add(usdCost);
                    icoRound++;
                    (price, stepPrice) = getTokenPrice(icoRound);
                    price = price.add(stepPrice);
                }
                iterationAmount = getTokensPerIteration(icoRound);
                if (amount <= getTokensPerIteration(icoRound)) {
                    usdCost = amount.div(10 ** 4).mul(price).add(usdCost);
                    amount = 0;
                }
            }
            ethCost = getPriceInETH(usdCost, exchangeRate);
        }
        return ethCost;
    }

    function _changeCurrentAllocatedTokens(uint256 amount, uint256 ethForTokens) private {

        if (amount <= current_allocatedTokens) {
            current_allocatedTokens = current_allocatedTokens.sub(amount);
        } else {
            uint256 amountForLoop = amount;
            while (amountForLoop > 0) {
                if (amountForLoop > current_allocatedTokens) {
                    amountForLoop = amountForLoop.sub(current_allocatedTokens);
                    uint256 ethForStep = getCost(current_allocatedTokens);
                    ethForTokens = ethForTokens.sub(ethForStep);
                    current_allocatedTokens = 0;
                    _allocate();
                    amountForLoop = _getAmountForETH(ethForTokens);
                } else if (amountForLoop <= current_allocatedTokens) {
                    current_allocatedTokens = current_allocatedTokens.sub(amountForLoop);
                    amountForLoop = 0;
                }
            }
        }
    }

    function _completeICO() private {

        if (current_allocatedTokens < minLimit && currentIterationOfICO >= maxRoundICO) {
            icoEndTime = block.timestamp;
            icoCompleted = true;
        } else if (current_allocatedTokens == 0) {
            _allocate();
        }
    }

    function _sendTokens(address client, uint256 amountToken) private nonReentrant {

        IERC20(tokenAddress).transfer(client, amountToken);
        emit Bought(client, amountToken, usdPrice);
    }

    function withdrawReward() public nonReentrant onlyOwner {

        uint256 amount = address(this).balance;
        require(amount > 0, 'Not enough reward for withdraw');
        (bool success,) = address(msg.sender).call{value : amount}("");
        require(success, 'Transfer failed');
        emit WithdrawedETH(msg.sender, amount);
    }

    function getCurrentICOState() public view returns (ICOStateSchema memory currentState) {

        require(icoStartTime != 0, 'ICO was not started can not _allocate new tokens');
        currentState.currentIteration = currentIterationOfICO;
        currentState.currentPrice = usdPrice;
        currentState.ICOAllocatedTokensAmount = oneIterationTokenAmount;
        currentState.tokensLeft = current_allocatedTokens;
    }

    function buy() public payable whenIcoStart allowedInvestor {

        require(msg.value > commission, 'Amount of ETH smaller than commission');
        uint256 ethForTokens = msg.value.sub(commission);
        uint256 amount = _getAmountForETH(ethForTokens);
        require(amount >= minLimit, 'Amount for one purchase is too low');
        require(amount <= maxLimit, 'Limit for one purchase is reached');
        _changeCurrentAllocatedTokens(amount, ethForTokens);
        _sendTokens(msg.sender, amount);
        _completeICO();
    }

    function buyWithReferral(address payable referral) external payable
    allowedInvestor whenIcoStart {

        require(referral != address(0), 'Referral address should not be empty');
        require(referral != msg.sender, 'Referral address should not be equal buyer address');
        require(msg.value > commission, 'Amount of ETH smaller than commission');
        uint256 bonusAmount = (msg.value.sub(commission)).mul(referralBonus).div(100);
        buy();
        (bool success,) = referral.call{value : bonusAmount}("");
        require(success);
    }

    function buyFor(address buyer) public payable onlyOwner whenIcoStart {

        uint256 amount = _getAmountForETH(msg.value);
        require(amount >= minLimit, 'Amount for one purchase is too low');
        require(amount <= maxLimit, 'Limit for one purchase is reached');
        require(buyer != address(0), 'Buyer address should not be empty');
        _changeCurrentAllocatedTokens(amount, msg.value);
        IERC20(tokenAddress).transfer(buyer, amount);
        emit Bought(buyer, amount, usdPrice);
        _completeICO();
    }

    function buyForWithReferral(address buyer, address payable referral) external payable
    onlyOwner whenIcoStart {

        require(referral != address(0), 'Referral address should not be empty');
        require(referral != msg.sender, 'Referral address should not be equal buyer address');
        require(referral != buyer, 'Referral address should not be equal buyer address');
        uint256 bonusAmount = (msg.value).mul(referralBonus).div(100);
        buyFor(buyer);
        (bool success,) = referral.call{value : bonusAmount}("");
        require(success);
    }

    function getLatestPrice() public view returns (int) {

        (
        ,
        int price,
        ,
        ,
        ) = priceFeed.latestRoundData();
        return 1 ether / (price / (10 ** 8));
    }

    function getPriceInETH(uint256 amount, int exchangeRate) public pure returns (uint256) {

        return amount.mul(uint256(exchangeRate)).div(10 ** 10);
    }

    function getTokenPrice(uint256 icoIteration) public view returns (uint256, uint256) {

        require(icoIteration <= maxRoundICO, 'Incorrect ICO round');
        uint256 price;
        uint256 stepPrice;
        if (icoIteration == 0) {
            price = startPriceInUSD;
        } else if (icoIteration == 1) {
            price = 10;
            stepPrice = 0;
        } else if (icoIteration > 1 && icoIteration <= 100) {
            price = 10;
            stepPrice = icoIteration.sub(1);
        } else if (icoIteration == 101) {
            price = 110;
            stepPrice = 0;
        } else {
            price = 110;
            stepPrice = icoIteration.sub(101).mul(10);
        }
        return (price, stepPrice);
    }

    function getTokensPerIteration(uint256 icoIteration) public view returns (uint256) {

        require(icoIteration <= maxRoundICO, 'Incorrect ICO round');
        uint256 amount;
        if (icoIteration == 0) {
            amount = 10 * 10 ** 6 * 10 ** 10;
        } else if (icoIteration > 0 && icoIteration <= 100) {
            amount = 19 * 10 ** 5 * 10 ** 10;
        } else {
            amount = 8 * 10 ** 6 * 10 ** 10;
        }
        return amount;
    }
}