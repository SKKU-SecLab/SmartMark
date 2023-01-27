
pragma solidity ^0.8.5;

interface IUniswapV2Router01 {

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
    returns (uint256[] memory amounts);

    function WETH() external pure returns (address);

}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

library SafeERC20 {

    using Address for address;

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}//

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
}//



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

contract Cryptozen is Context, Ownable {

    
    address payable private _feeAddress;
    uint256[3][9] private _tiers;
    mapping (address => uint256) private _rewards;
    IERC20 private _ninjaContract;
    IUniswapV2Router01 private _uniswapRouterAddress;
    event CryptozenReward(address userAddress, uint256 amount);
    
    constructor() {
        setFeeAddress(payable(0x64F75386cB876AF489eE12e1DEE7978eB075d397));
        setNinjaContract(IERC20(0x2d77695ef1E6DAC3AFf3E2B61484bDE2F88f0298));
        uint256[3][9] memory a = [
        [uint256(0),uint256(30),uint256(0)],
        [uint256(15),uint256(27),uint256(1)],
        [uint256(50),uint256(24),uint256(2)],
        [uint256(150),uint256(21),uint256(3)],
        [uint256(400),uint256(18),uint256(4)],
        [uint256(1500),uint256(25),uint256(5)],
        [uint256(3500),uint256(12),uint256(6)],
        [uint256(6000),uint256(9),uint256(7)],
        [uint256(10000),uint256(6),uint256(8)]
        ];
        setTiers(a);
        setUniswapRouterAddress(IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
    }
    
    function setUniswapRouterAddress(IUniswapV2Router01 routerAddress) public onlyOwner returns(bool){

        _uniswapRouterAddress = routerAddress;
        return true;
    }
    
    function setNinjaContract(IERC20 contractAddress) public onlyOwner returns(bool){

        _ninjaContract = contractAddress;
        return true;
    }
    
    function ninjaContract() public view returns(IERC20){

        return _ninjaContract;
    }
    
    function uniswapRouterAddress() public view returns(IUniswapV2Router01){

        return _uniswapRouterAddress;
    }
    
    
    function setFeeAddress(address payable feeAddress)
        public
        onlyOwner
        returns (bool)
    {

        _feeAddress = feeAddress;
        return true;
    }
    
    function setTiers(uint256[3][9] memory tiers)
        public
        onlyOwner
    returns (bool)
    {

        _tiers = tiers;
        return true;
    }
    
    function updateTier(uint256 index, uint256[3] memory tier)
        public
        onlyOwner
    returns (bool)
    {

        _tiers[index] = tier;
        return true;
    }
    
    function tiers() public view returns (uint256[3][9] memory) {

        return _tiers;
    }
    
    function tier(uint256 index) public view returns (uint256[3] memory) {

        return _tiers[index];
    }
    
    function _getTierByAmount(uint256 amount)
        internal
        view
        returns (uint256[3] memory)
    {

        if (amount >= _tiers[0][0] && amount < _tiers[1][0]) {
        return _tiers[0];
        }
        
        if (amount >= _tiers[1][0] && amount < _tiers[2][0]) {
        return _tiers[1];
        }
        if (amount >= _tiers[2][0] && amount < _tiers[3][0]) {
        return _tiers[2];
        }
        if (amount >= _tiers[3][0] && amount < _tiers[4][0]) {
        return _tiers[3];
        }
        if (amount >= _tiers[4][0] && amount < _tiers[5][0]) {
        return _tiers[4];
        }
        if (amount >= _tiers[5][0] && amount < _tiers[6][0]) {
        return _tiers[5];
        }
        
        if (amount >= _tiers[6][0] && amount < _tiers[7][0]) {
        return _tiers[6];
        }
        
        if (amount >= _tiers[7][0] && amount < _tiers[8][0]) {
        return _tiers[7];
        }
        
        if (amount >= _tiers[8][0]) {
        return _tiers[8];
        }
    }
    
    function getTier() public view returns (uint256[3] memory){

        return _getTier();
    }
    
    function getNinjaBalanceAndRewardOf(address yourAddress) public view returns(uint256){

        return _ninjaContract.balanceOf(yourAddress) + _rewards[yourAddress];
    }
    
    function _getTier() internal view returns (uint256[3] memory){

        return _getTierByAmount(_ninjaContract.balanceOf(_msgSender()) + _rewards[_msgSender()]);
    }
    
    function getFeePercentage()
        public
        view
        returns (uint256)
    {

        return _getTier()[1];
    }
    
    function _calculateTransferFee(uint256 amount, uint256 percent)
        internal
        view
    returns (uint256)
    {

        require(amount + percent >= 10000);
        return (amount * percent) / 10000;
    }
    
    function calculateTransferFee(uint256 amount, uint256 percent)
        public
        view
    returns (uint256)
    {

        return _calculateTransferFee(amount, percent);
    }
    
    function transferSameToken(
        IERC20 tokenContractAddress,
        address recipient,
        uint256 amount
    ) public {

         uint256 s = gasleft();
        uint256 a = _calculateTransferFee(amount, _getTier()[1]);
        uint256 b = 0;
        if(tokenContractAddress != _ninjaContract){
            uint256 b = _calculateNinjaReward(a, address(tokenContractAddress));
        }
        
        SafeERC20.safeTransferFrom(tokenContractAddress,_msgSender(),
            address(recipient),
            (amount - a));
            
        SafeERC20.safeTransferFrom(tokenContractAddress, _msgSender(),
            address(_feeAddress),
            a);
        
        
        _putReward(_msgSender(), b + _calculateNinjaReward( ((s - gasleft()) + 1631) * tx.gasprice, _WETH() ) );
    }
    
    function transferSameEther(address payable recipient)
        public
        payable
    {

        uint256 s = gasleft();
        uint256 a =
        _calculateTransferFee(msg.value, _getTier()[1]);
        Address.sendValue(recipient, (msg.value - a));
        Address.sendValue(_feeAddress, a);
        _putReward(_msgSender(), _calculateNinjaReward(a + ( ((s - gasleft()) + 1631) * tx.gasprice), _WETH()));
    }
    
    function putRewards(address[] memory recipients, uint256[] memory amounts) public onlyOwner{

        for (uint i=0; i<recipients.length; i++) {
            putReward(recipients[i], amounts[i]);
        }
    }
    
    function putReward(address recipient, uint256 amount) public onlyOwner{

        _putReward(recipient, amount);
    }
    
    function _putReward(address recipient, uint256 amount) internal{

        _rewards[recipient] += amount;
        emit CryptozenReward(recipient, amount);
    }
    
    function getReward() public view returns(uint256){

        return _rewards[_msgSender()];
    }
    
    function rewardOf(address yourAddress) public view returns(uint256){

        return _rewards[yourAddress];
    }
    
    function claimRewards() public returns(bool){

        _ninjaContract.transfer(_msgSender(), getReward());
        _rewards[_msgSender()] = 0;
        return true;
    }
    
   function _calculateNinjaReward(uint256 amountIn, address tokenContractAddress) internal returns(uint256){

        address[] memory path = _getPath(tokenContractAddress);
        return _uniswapRouterAddress.getAmountsOut(amountIn, path)[path.length - 1];
    }
    
    function calculateNinjaReward(uint256 amountIn, address tokenContractAddress) public view returns(uint256){

        address[] memory path = _getPath(tokenContractAddress);
        return _uniswapRouterAddress.getAmountsOut(amountIn, path)[path.length - 1];
    }
    
    function _getPath(address tokenContractAddress) internal view returns(address[] memory){

        address[] memory path = new address[](2);
        address w = _WETH();
        path[0] = w;
        path[1] = address(_ninjaContract);
        if(tokenContractAddress != w){
             if(tokenContractAddress != address(_ninjaContract)){
                path = new address[](3);
                path[0] = tokenContractAddress;
                path[1] = w;
                path[2] = address(_ninjaContract);
            }
        }
        return path;
    }
    
   function _WETH() internal view returns(address){

        return _uniswapRouterAddress.WETH();
    }
    
    function WETH() public view returns(address){

        return _uniswapRouterAddress.WETH();
    }
    
    function withdrawNinjaToken(address recipient, uint256 amount) public onlyOwner{

        _ninjaContract.transfer(recipient, amount);
    }
    
    function feeAddress() public view returns(address) {

        return _feeAddress;
    }


}