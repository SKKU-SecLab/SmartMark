



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
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}




pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}




pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}




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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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




pragma solidity ^0.8.1;









interface IERC20 {

  function totalSupply() external view returns (uint256);


  function decimals() external view returns (uint8);


  function symbol() external view returns (string memory);


  function name() external view returns (string memory);


  function getOwner() external view returns (address);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address _owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeERC20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeERC20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, 'SafeERC20: low-level call failed');
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
        }
    }
}

contract MBTLotteryPool is ReentrancyGuard,  Ownable{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC721Enumerable public nftContractAddress;
    IERC20  public mbtTokenAddress;
    address public ownerAddress;

    uint256 public lotteryStartDate;
    uint256 public circleOfLottery;
    uint256 public rewardPrize;
    uint256 public ticketPrice;
    bool public initialized;

    struct lotteryinfo{
        uint256 _startDate;
        uint256 _closeDate;
        uint256 _ticketPrice;
        uint256 _winNumber;
        address _winnerAddress;
        uint256 _reward;
        address[] _playerList;
        bool _paid;
        uint256 _winnerReward;
        uint256 _fee;
        uint256 _remainPrice;
    }

    lotteryinfo[] public allLotteryInfo;

    event deposit(uint256 _amount);
    event claimReward(uint256 lotteryId, uint256 _amount, uint256 _fee);
    event adminTokenRecovery(address tokenRecovered, uint256 amount);
    
    constructor(
        uint256 _rewardStartPrize,
        uint256 _ticketPriceStartLottery,
        uint256 _lotteryStartDate,
        IERC721Enumerable _nftAddress,
        IERC20 _mbtAddress,
        uint256 _circleOfLottery
    ){
        lotteryStartDate = _lotteryStartDate;
        rewardPrize = _rewardStartPrize;
        ticketPrice = _ticketPriceStartLottery;
        nftContractAddress = _nftAddress;
        mbtTokenAddress = _mbtAddress;
        circleOfLottery = _circleOfLottery;
        ownerAddress = msg.sender;
        initialized = false;
    }
    function Initialize() external onlyOwner{

        require(!initialized, "Can't do anymore");
        lotteryinfo memory temp;
        temp._startDate = lotteryStartDate;
        temp._ticketPrice = ticketPrice;
        temp._reward = rewardPrize;
        allLotteryInfo.push(temp);
        initialized = true;
    }


    function CheckNFTholder(address _msgSender) internal view returns(bool){

        uint256 balanceNFT = nftContractAddress.balanceOf(_msgSender);
        return balanceNFT > 0 ? true : false;
    }

   

    function Deposit(uint256 _amount) external nonReentrant{

        require(CheckNFTholder(msg.sender),'You are not NFT holder');
        mbtTokenAddress.safeTransferFrom(msg.sender, address(this), _amount);
        emit deposit(_amount);
    }

    function CheckWinner(uint256 _lotteryId, address _msgSender) internal view returns(bool){

        for(uint256 i = 0; i < allLotteryInfo[_lotteryId]._playerList.length; i++){
            if(allLotteryInfo[_lotteryId]._playerList[i] == _msgSender){
                
                return true;
            }
        }
        
        return false;
    }
    function RandomGenerator() internal view returns(uint256){

        uint256 random = uint256(keccak256(
            abi.encodePacked(
                ownerAddress,
                block.coinbase,
                block.difficulty,
                block.gaslimit,
                block.timestamp
            )
        )) % 10000 + 1;        
        return random;
    }

    function ClaimReward(uint256 _lotteryId, uint256 _reward, uint256 _fee) external nonReentrant{

        require(CheckNFTholder(msg.sender),'You are not NFT holder');
        require(CheckWinner(_lotteryId, msg.sender), "You are not Winner");
        require(!allLotteryInfo[_lotteryId]._paid, "Paid already");
        require(allLotteryInfo[_lotteryId]._winnerReward.add(allLotteryInfo[_lotteryId]._fee) >= _reward.add(_fee),"influence fund");
        allLotteryInfo[_lotteryId]._reward = _reward;
        allLotteryInfo[_lotteryId]._winnerAddress = msg.sender;
        allLotteryInfo[_lotteryId]._paid = true;
        mbtTokenAddress.safeTransfer( msg.sender, _reward);
        mbtTokenAddress.safeTransfer(ownerAddress, _fee);
        emit claimReward(_lotteryId, _reward, _fee);
    }

    function CloseLottery(address[] memory _playerlist) external onlyOwner{

        uint256 lotteryid = allLotteryInfo.length.sub(1);
        lotteryinfo memory curr_lottery = allLotteryInfo[lotteryid];

        require(curr_lottery._startDate + circleOfLottery <= block.timestamp,"Can't close yet");

        uint256 prev_remain_price = 0;
        if(lotteryid == 0) {
            prev_remain_price = 0;
        }
        else {
            prev_remain_price = allLotteryInfo[lotteryid - 1]._remainPrice;
        }
        
        uint256 winNumber = RandomGenerator();
        curr_lottery._winNumber = winNumber;
        address winnerAddress = address(0);
        
        curr_lottery._closeDate = block.timestamp;
        uint256 remainPrice;

        bool isWinner = false;
        if(winNumber <= nftContractAddress.totalSupply()){
            winnerAddress = nftContractAddress.ownerOf(winNumber);
        }
        curr_lottery._winnerAddress = winnerAddress;
        curr_lottery._playerList = _playerlist;

        for(uint256 i = 0; i < _playerlist.length; i++){
            if(_playerlist[i] == winnerAddress){
                isWinner = true;                
            }
        }
        remainPrice = prev_remain_price + curr_lottery._ticketPrice * _playerlist.length;
        
        if(!isWinner){
            curr_lottery._remainPrice = remainPrice;
            curr_lottery._winnerReward = 0;
            curr_lottery._fee = 0;
        }
        else {
            curr_lottery._remainPrice = 0;
            curr_lottery._winnerReward = curr_lottery._reward + remainPrice * 3 /4;
            curr_lottery._fee = remainPrice * 1 / 4;
        }

        allLotteryInfo[lotteryid] = curr_lottery;

        lotteryinfo memory temp;
        temp._startDate = block.timestamp;
        temp._ticketPrice = ticketPrice;
        temp._reward = rewardPrize;

        allLotteryInfo.push(temp);
    }
    function adjustRewardPrize(uint256 _rewardPrize) external onlyOwner{

        rewardPrize = _rewardPrize;
    }
    function adjustTicketPrice(uint256 _ticketPrice) external onlyOwner{

        ticketPrice = _ticketPrice;
    }
    function ReadAllLotteryInfo() external view returns(lotteryinfo[] memory){

        return allLotteryInfo;
    }
    function GetOwnerAddress() external view returns(address){

        return ownerAddress;
    }
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {

        mbtTokenAddress.safeTransfer(address(msg.sender), _amount);        
    }
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {

        require(_tokenAddress != address(mbtTokenAddress), 'Cannot be staked token');
        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
    }
}