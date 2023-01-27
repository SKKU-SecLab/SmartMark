
pragma solidity ^0.8.0;

contract OwnableData {

    address public owner;
    address public pendingOwner;
}

contract Ownable is OwnableData {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(address newOwner, bool direct, bool renounce) public onlyOwner {

        if (direct) {
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        } else {
            pendingOwner = newOwner;
        }
    }

    function claimOwnership() public {

        address _pendingOwner = pendingOwner;

        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
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


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    function mint(address to, uint256 amount) external returns(bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library TransferHelper {

    function safeApprove(address token, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface CustomExchange{

    enum OrderType {EthForTokens, TokensForEth, TokensForTokens}
    function getBestQuotation(uint orderType, address[] memory path, uint256 amountIn) external view returns (uint256);

    function executeSwapping(uint orderType, address[] memory path, uint256 assetInOffered, uint256 assetOutExpected, address to, uint256 deadline) external payable returns(uint[] memory);

}




contract MainSwap is Ownable {

    event Received(address, uint);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    enum OrderType {EthForTokens, TokensForEth, TokensForTokens}
    using SafeMath for uint256;
    uint256 public fees = 1000000;            // 6 decimal places added
    mapping (uint=>address) public exchangeList;
    mapping (address=>bool) public whitelistedToken;
    uint public totalExchanges = 0;
    
    constructor() {
    }
    
    
    function addExchange(address _exchangeAddress) external onlyOwner {

        exchangeList[totalExchanges] = _exchangeAddress;
        totalExchanges = totalExchanges + 1;
    }
    
    function updateExchange(address _exchangeAddress, uint _dexId) external onlyOwner {

        exchangeList[_dexId] = _exchangeAddress;
    }
    
    function setWhiteListToken(address _tokenAddress, bool _flag) external onlyOwner {

        whitelistedToken[_tokenAddress] = _flag;
    }
    
    function updateFees(uint256 _newFees) external onlyOwner {

        fees = _newFees;
    }
    
    function getFeesAmount(uint256 temp) internal view returns (uint256){

        return (temp.mul(fees).div(100000000));
    }
    
    function getBestQuote(uint orderType, address[] memory path, uint256 amountIn) public view returns (uint, uint256) {

        require((orderType==0)||(orderType==1)||(orderType==2),"Invalid orderType");
        uint256 bestAmountOut = 0;
        uint dexId = 0;
        uint256 amountInFin = amountIn;
        bool feeAfterSwap;
        if(OrderType(orderType) == OrderType.EthForTokens){
            amountInFin = amountIn.sub(getFeesAmount(amountIn));
        }
        if (OrderType(orderType) == OrderType.TokensForEth){
            feeAfterSwap = true;
        }
        if (OrderType(orderType) == OrderType.TokensForTokens){
            if(whitelistedToken[path[path.length-1]]){
                feeAfterSwap = true;
            }else{
                amountInFin = amountIn.sub(getFeesAmount(amountIn));
            }
        }
        for(uint i=0;i<totalExchanges;i++){
            if(exchangeList[i] == address(0)){
                continue;
            }
            CustomExchange ExInstance = CustomExchange(exchangeList[i]);
            uint256 amountOut;
            try
                ExInstance.getBestQuotation(orderType, path,amountInFin) returns(uint256 _amountOut){
                    if(feeAfterSwap){
                        amountOut = _amountOut.sub(getFeesAmount(_amountOut));
                    }else{
                        amountOut = _amountOut; 
                    }
                    
                if(bestAmountOut<amountOut){
                bestAmountOut = amountOut;
                dexId = i;
                }
            }catch{}
            
        }
        return (dexId, bestAmountOut);
    }
    
    function executeSwap(uint dexId, uint orderType, address[] memory path, uint256 assetInOffered, uint256 assetOutExpected, uint256 deadline) external payable{
        uint[] memory swapResult;
        uint256 amountInFees;
        CustomExchange ExInstance = CustomExchange(exchangeList[dexId]);
        if(OrderType(orderType) == OrderType.EthForTokens){
            require(msg.value >= assetInOffered, "amount send is less than mentioned");
            amountInFees = getFeesAmount(assetInOffered);
            TransferHelper.safeTransferETH(owner, amountInFees);
            ExInstance.executeSwapping{value:assetInOffered.sub(amountInFees)}(orderType, path, assetInOffered.sub(amountInFees), assetOutExpected, msg.sender, deadline);
        } else if(OrderType(orderType) == OrderType.TokensForEth) {
            TransferHelper.safeTransferFrom(path[0], msg.sender, exchangeList[dexId], assetInOffered);
            swapResult = ExInstance.executeSwapping(orderType, path, assetInOffered, assetOutExpected, address(this), deadline);
            amountInFees = getFeesAmount(uint256(swapResult[1]));
            TransferHelper.safeTransferETH(owner, amountInFees);
            TransferHelper.safeTransferETH(msg.sender, swapResult[1].sub(amountInFees));
        }else if (OrderType(orderType) == OrderType.TokensForTokens){
            if(whitelistedToken[path[path.length-1]]){
                TransferHelper.safeTransferFrom(path[0], msg.sender, exchangeList[dexId], assetInOffered);
                swapResult = ExInstance.executeSwapping(orderType, path, assetInOffered, assetOutExpected, address(this), deadline);
                amountInFees = getFeesAmount(swapResult[1]);
                TransferHelper.safeTransfer(path[path.length-1], owner, amountInFees);
                TransferHelper.safeTransfer(path[path.length-1], msg.sender, swapResult[1].sub(amountInFees));
            }else{
                amountInFees = getFeesAmount(assetInOffered);
                TransferHelper.safeTransferFrom(path[0], msg.sender, owner, amountInFees);
                TransferHelper.safeTransferFrom(path[0], msg.sender, exchangeList[dexId], assetInOffered.sub(amountInFees));
                swapResult = ExInstance.executeSwapping(orderType, path, assetInOffered.sub(amountInFees), assetOutExpected, msg.sender, deadline);
            }
        } else {
            revert("Invalid order type");
        }
    }
    
    function feesWithdraw(address payable _to) external onlyOwner{
        uint256 amount = (address(this)).balance;
        require(_to.send(amount), "Fee Transfer to Owner failed.");
    }

}