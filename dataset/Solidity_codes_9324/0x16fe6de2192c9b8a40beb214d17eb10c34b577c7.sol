
pragma solidity ^0.6.0;

interface ISTVKE {

    function viewTreasury() external view returns(address);

    function viewSTVrequirement() external view returns(uint256);

    function viewPrice() external view returns(uint256);

    function viewBypassPrice() external view returns(uint256);

    function balanceOf(address account) external view returns (uint256);

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

pragma solidity ^0.6.2;

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
}


contract Context {


    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}

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


interface UniswapV2Router02 {

    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) 
    external 
    payable 
    returns (uint amountToken, uint amountETH, uint liquidity);

    
    function WETH() external pure returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
  uint amountOutMin,
  address[] calldata path,
  address to,
  uint deadline
) external payable;

}

contract IDO20_base is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public HARDCAP;
    
    uint256 public SOFTCAP;

    uint256 public TOKENS_PER_ETH;

    uint256 public startTime;

    uint256 public duration;

    uint256 public endTime;

    uint256 public percentToUniswap;
    
    bool public finalized = false;

    mapping(address => bool) public whitelists;

    mapping(address => uint256) public contributions;


    uint256 public minContribution;

    uint256 public maxContribution;

    uint256 public weiRaised;

    bool public burnLeftover;

    bool public whitelisting;

    uint256 public fcfs;

    IERC20 public token;

    UniswapV2Router02 internal constant uniswap = UniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    constructor(IERC20 _token,
    uint256 _startTime, uint256 _duration,
    uint256 _hardcap, uint256 _softcap,
    uint256 _tokensPerEth, uint256 _percentToUniswap,
    uint256 _minContribution, uint256 _maxContribution,
    bool _burnLeftover, bool _whitelisting, uint256 _fcfs, address __owner)
    public
    Ownable()
    {
        require(_percentToUniswap <= 100 && _percentToUniswap >= 0);
        token = _token;
        startTime = _startTime;
        duration = _duration;
        HARDCAP = _hardcap.mul(1e18);
        SOFTCAP = _softcap.mul(1e18);
        endTime = startTime + duration;
        TOKENS_PER_ETH = _tokensPerEth;
        percentToUniswap = _percentToUniswap;
        minContribution = _minContribution;
        maxContribution = _maxContribution;
        burnLeftover = _burnLeftover;
        whitelisting = _whitelisting;
        if (_fcfs == 0) { 
            fcfs = startTime.add(duration);
        } else {
        fcfs = startTime.add(_fcfs);
        }
        transferOwnership(__owner);
    }

    receive() payable external {
        _buyTokens(msg.sender);
    }

    function _buyTokens(address _beneficiary) internal {

        uint256 weiToHardcap = HARDCAP.sub(weiRaised);
        uint256 weiAmount = weiToHardcap < msg.value ? weiToHardcap : msg.value;

        _buyTokens(_beneficiary, weiAmount);

        uint256 refund = msg.value.sub(weiAmount);
        if (refund > 0) {
            payable(_beneficiary).transfer(refund);
        }
    }

    function _buyTokens(address _beneficiary, uint256 _amount) internal {

        require(isOpen(), "Sale is not open.");
        require(!hasEnded(), "Sale has ended.");
        require(contributions[_beneficiary].add(_amount) <= maxContribution || maxContribution == 0, "You have sent more than the max contribution.");
        require(_amount >= minContribution || weiRaised.add(_amount) == HARDCAP || minContribution == 0, "You have sent less than the min contribution.");
        require(now >= fcfs || !whitelisting || whitelists[_beneficiary], "The sale requires you to be whitelisted, or FCFS has not yet started.");

        weiRaised = weiRaised.add(_amount);
        contributions[_beneficiary] = contributions[_beneficiary].add(_amount);
    }
    
    function claim() public {

        require(hasEnded(), "Sale has not ended.");
        require(finalized, "Sale not finalized.");
        if (weiRaised >= SOFTCAP) { 
            uint256 tokenAmount = contributions[_msgSender()].mul(TOKENS_PER_ETH);
            contributions[_msgSender()] = 0;
            token.safeTransfer(_msgSender(), tokenAmount);
        } else {
            uint256 contribution = contributions[_msgSender()];
            contributions[_msgSender()] = 0;
            payable(_msgSender()).transfer(contribution);
        }
    }

    function isOpen() public view returns (bool) {

        return block.timestamp >= startTime;
    }

    function hasEnded() public view returns (bool) {

        return block.timestamp >= endTime || weiRaised >= HARDCAP;
    }

    function addWhitelists(address[] calldata _addresses) external onlyOwner {

        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelists[_addresses[i]] = true;
        }
    }

    function finalize() external virtual onlyOwner {

        require(hasEnded(), "Sale has not ended.");
        if (weiRaised > SOFTCAP) {

        uint256 liquidityETH = weiRaised.mul(percentToUniswap).div(100);
        uint256 remainingETH = weiRaised.sub(liquidityETH);
        uint256 liquidityTokens = token.balanceOf(address(this));

        uint256 tokensPerEth = TOKENS_PER_ETH;

        uint256 tokensToBurn = HARDCAP.sub(weiRaised).mul(tokensPerEth);
            if (tokensToBurn > 0 && burnLeftover == true) {
                liquidityTokens = liquidityETH.mul(tokensPerEth);
                tokensToBurn = tokensToBurn.add(HARDCAP.mul(percentToUniswap).div(100).mul(tokensPerEth).sub(liquidityTokens));

                token.approve(0x000000000000000000000000000000000000dEaD, tokensToBurn);
                token.safeTransfer(0x000000000000000000000000000000000000dEaD, tokensToBurn);
            } else if (tokensToBurn > 0 && burnLeftover == false) {
                liquidityTokens = liquidityETH.mul(tokensPerEth);
                tokensToBurn = tokensToBurn.add(HARDCAP.mul(percentToUniswap).div(100).mul(tokensPerEth).sub(liquidityTokens));
                token.approve(owner(), tokensToBurn);
                token.safeTransfer(owner(), tokensToBurn);
            }

            token.approve(address(uniswap), liquidityTokens);
            uniswap.addLiquidityETH
            { value: liquidityETH }
            (
                address(token),
                liquidityTokens,
                liquidityTokens,
                liquidityETH,
                address(0),
                block.timestamp
            );
            payable(owner()).transfer(remainingETH);
        } else {
            token.approve(address(owner()), token.balanceOf(address(this)));
            token.safeTransfer(owner(), token.balanceOf(address(this)));
        }
        finalized = true;
    }    

}// WHO GIVES A FUCK ANYWAY??

pragma solidity ^0.6.6;


contract STVKE_IDO {


    using SafeMath for uint256;
    
    UniswapV2Router02 internal constant uniswap = UniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    ISTVKE internal constant stvke = ISTVKE(0x226e390751A2e22449D611bAC83bD267F2A2CAfF);
    
    event SaleGenerated(address account, uint256 hardcap, uint256 startTime, uint256 duration, uint256 tokensPerEth, uint256 percentToUniswap);
    event SendForBuyBack(uint ethAmount);

    
    constructor() public
    {

    }
    
    
    function createIDO(IERC20 _token,
    uint256 _startTime, uint256 _duration,
    uint256 _hardcap, uint256 _softcap,
    uint256 _tokensPerEth, uint256 _percentToUniswap,
    uint256 _minContribution, uint256 _maxContribution,
    bool _burnLeftover, bool _whitelisting, uint256 _fcfs, address __owner) public payable {

         require(stvke.balanceOf(msg.sender) >= stvke.viewSTVrequirement());
         require(stvke.balanceOf(msg.sender) >= stvke.viewBypassPrice() || msg.value >= stvke.viewPrice());
        
        
        address saleAddress = address(new IDO20_base(_token,
                _startTime, _duration,
                _hardcap, _softcap,
                _tokensPerEth, _percentToUniswap,
                _minContribution, _maxContribution,
                _burnLeftover, _whitelisting, _fcfs, __owner));
                
                
        emit SaleGenerated(saleAddress, _hardcap, _startTime, _duration, _tokensPerEth, _percentToUniswap);
                
    sendForBuyBack();
                
    }
    
    function sendForBuyBack() internal {

        if (address(this).balance > 0.5 ether) {
            uint amountIn = address(this).balance.sub(0.2 ether);
            emit SendForBuyBack(amountIn);
            payable(0x226e390751A2e22449D611bAC83bD267F2A2CAfF).transfer(amountIn);
        }   
    }
}

