
pragma solidity >=0.6.0;
interface IERC20 {

   
    function totalSupply() external view returns (uint256);


  
    function balanceOf(address account) external view returns (uint256);


    
    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferWithoutDeflationary(address recipient, uint256 amount) external returns (bool) ;

   
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

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



library ECDSA {

    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }
}

contract PolkabridgeLaunchPadV2 is Ownable, ReentrancyGuard {

    string public name = "PolkaBridge: LaunchPad V2";
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    address payable private ReceiveToken;
    uint256 MinimumStakeAmount;
    struct IDOPool {
        uint256 Id;
        uint256 Begin;
        uint256 End;
        uint256 Type; //1: comminity round, 2 stackers round, 3 whitelist, 4 guaranteed
        IERC20 IDOToken;
        uint256 MaxPurchaseTier1;
        uint256 MaxPurchaseTier2; //==comminity tier
        uint256 MaxPurchaseTier3;
        uint256 MaxSpecialPurchase;
        uint256 TotalCap;
        uint256 MinimumTokenSoldout;
        uint256 TotalToken; //total sale token for this pool
        uint256 RatePerETH;
        uint256 TotalSold; //total number of token sold
        
    }

    struct ClaimInfo {
        uint256 ClaimTime1;
        uint256 PercentClaim1;
        uint256 ClaimTime2;
        uint256 PercentClaim2;
        uint256 ClaimTime3;
        uint256 PercentClaim3;
        uint256 ClaimTime4;
        uint256 PercentClaim4;
        uint256 ClaimTime5;
        uint256 PercentClaim5;
         uint256 ClaimTime6;
        uint256 PercentClaim6;
         uint256 ClaimTime7;
        uint256 PercentClaim7;
    }

    struct User {
        uint256 Id;
        
        bool IsWhitelist;
        uint256 TotalTokenPurchase;
        uint256 TotalETHPurchase;
        uint256 PurchaseTime;
        uint256 LastClaimed;
        uint256 TotalPercentClaimed;
        uint256 NumberClaimed;
        
        uint256 PurchaseAllocation;
    }

    mapping(uint256 => mapping(address => User)) public users; //poolid - listuser

    IDOPool[] pools;

    mapping(uint256 => ClaimInfo) public claimInfos; //pid

    constructor(address payable receiveTokenAdd) public {
        ReceiveToken = receiveTokenAdd;
        MinimumStakeAmount=10000*1e18;
    }

    function addMulWhitelist(address[] memory user,uint256[] memory allocation, uint256 pid)///need pid in constantfile
        public
        onlyOwner
    {

        for (uint256 i = 0; i < user.length; i++) {
            users[pid][user[i]].Id = pid;
             users[pid][user[i]].PurchaseAllocation = allocation[i];
            users[pid][user[i]].IsWhitelist = true;
           
        }
    }

    function sign(address[] memory user, uint256 pid)///need pid in constantfile
        public
        onlyOwner
    {

        uint256 poolIndex = pid.sub(1);
        uint256 maxSpeical= pools[poolIndex].MaxSpecialPurchase;
        uint256 tokenAmount = maxSpeical.mul(pools[poolIndex].RatePerETH).div(1e18);

        for (uint256 i = 0; i < user.length; i++) {
          
            users[pid][user[i]].TotalTokenPurchase = tokenAmount;
            
        }
    }

    function updateWhitelist(
        address user,
        uint256 pid,
        bool isWhitelist
    ) public onlyOwner {

        users[pid][user].IsWhitelist = isWhitelist;
       
    }

    function updateMinimumStake(
       uint256 _minimum
    ) public onlyOwner {

        MinimumStakeAmount=_minimum;
       
    }

    function IsWhitelist(
        address user,
        uint256 pid,
        uint256 stackAmount
    ) public view returns (bool) {

        uint256 poolIndex = pid.sub(1);
        if (pools[poolIndex].Type == 1) // community round
        {
            return true;
        } else if (pools[poolIndex].Type == 2) // stakers round
        {
            if (stackAmount >= MinimumStakeAmount) return true;
            return false;
        } else if (pools[poolIndex].Type == 3 ) //special round  
        {
            if (users[pid][user].IsWhitelist) return true;
            return false;
        }
        else if (pools[poolIndex].Type ==4) //guaranteed round  
        {
            if (users[pid][user].IsWhitelist && stackAmount >= MinimumStakeAmount) return true;
            return false;
        } else {
            return false;
        }
    }

    function addPool(
        uint256 begin,
        uint256 end,
        uint256 _type,
        IERC20 idoToken,
        uint256 maxPurchaseTier1,
        uint256 maxPurchaseTier2,
        uint256 maxPurchaseTier3,
        uint256 maxSpecialPurchase,
        uint256 totalCap,
        uint256 totalToken,
        uint256 ratePerETH,
        uint256 minimumTokenSoldout
       
    ) public onlyOwner {

        uint256 id = pools.length.add(1);
        pools.push(
            IDOPool({
                Id: id,
                Begin: begin,
                End: end,
                Type: _type,
                IDOToken: idoToken,
                MaxPurchaseTier1: maxPurchaseTier1,
                MaxPurchaseTier2: maxPurchaseTier2,
                MaxPurchaseTier3: maxPurchaseTier3,
                MaxSpecialPurchase:maxSpecialPurchase,
                TotalCap: totalCap,
                TotalToken: totalToken,
                RatePerETH: ratePerETH,
                TotalSold: 0,
                MinimumTokenSoldout: minimumTokenSoldout
               
            })
        );
    }

    function addClaimInfo(
        uint256 percentClaim1,
        uint256 claimTime1,
        uint256 percentClaim2,
        uint256 claimTime2,
        uint256 percentClaim3,
        uint256 claimTime3,
         uint256 percentClaim4,
        uint256 claimTime4,
         uint256 percentClaim5,
        uint256 claimTime5,
         uint256 percentClaim6,
        uint256 claimTime6,
         uint256 percentClaim7,
        uint256 claimTime7,
        uint256 pid
    ) public onlyOwner {

        claimInfos[pid].ClaimTime1 = claimTime1;
        claimInfos[pid].PercentClaim1 = percentClaim1;
        claimInfos[pid].ClaimTime2 = claimTime2;
        claimInfos[pid].PercentClaim2 = percentClaim2;
        claimInfos[pid].ClaimTime3 = claimTime3;
        claimInfos[pid].PercentClaim3 = percentClaim3;
        claimInfos[pid].ClaimTime4 = claimTime4;
        claimInfos[pid].PercentClaim4 = percentClaim4;
        claimInfos[pid].ClaimTime5 = claimTime5;
        claimInfos[pid].PercentClaim5 = percentClaim5;
         claimInfos[pid].ClaimTime6 = claimTime6;
        claimInfos[pid].PercentClaim6 = percentClaim6;
         claimInfos[pid].ClaimTime7 = claimTime7;
        claimInfos[pid].PercentClaim7 = percentClaim7;
    }

    function updateClaimInfo(
        uint256 percentClaim1,
        uint256 claimTime1,
        uint256 percentClaim2,
        uint256 claimTime2,
        uint256 percentClaim3,
        uint256 claimTime3,
          uint256 percentClaim4,
        uint256 claimTime4,
          uint256 percentClaim5,
        uint256 claimTime5,
         uint256 percentClaim6,
        uint256 claimTime6,
         uint256 percentClaim7,
        uint256 claimTime7,
        uint256 pid
    ) public onlyOwner {

        if (claimTime1 > 0) {
            claimInfos[pid].ClaimTime1 = claimTime1;
        }

        if (percentClaim1 > 0) {
            claimInfos[pid].PercentClaim1 = percentClaim1;
        }
        if (claimTime2 > 0) {
            claimInfos[pid].ClaimTime2 = claimTime2;
        }

        if (percentClaim2 > 0) {
            claimInfos[pid].PercentClaim2 = percentClaim2;
        }

        if (claimTime3 > 0) {
            claimInfos[pid].ClaimTime3 = claimTime3;
        }

        if (percentClaim3 > 0) {
            claimInfos[pid].PercentClaim3 = percentClaim3;
        }

          if (claimTime4 > 0) {
            claimInfos[pid].ClaimTime4 = claimTime4;
        }

        if (percentClaim4 > 0) {
            claimInfos[pid].PercentClaim4 = percentClaim4;
        }

           if (claimTime5 > 0) {
            claimInfos[pid].ClaimTime5 = claimTime5;
        }

        if (percentClaim5 > 0) {
            claimInfos[pid].PercentClaim5 = percentClaim5;
        }

           if (claimTime6 > 0) {
            claimInfos[pid].ClaimTime6 = claimTime6;
        }

        if (percentClaim6 > 0) {
            claimInfos[pid].PercentClaim6 = percentClaim6;
        }

           if (claimTime7 > 0) {
            claimInfos[pid].ClaimTime7 = claimTime7;
        }

        if (percentClaim7 > 0) {
            claimInfos[pid].PercentClaim7 = percentClaim7;
        }
    }

    function updatePool(
        uint256 pid,
        uint256 begin,
        uint256 end,
        uint256 maxPurchaseTier1,
        uint256 maxPurchaseTier2,
        uint256 maxPurchaseTier3,
         uint256 maxSpecialPurchase,
        uint256 totalCap,
        uint256 totalToken,
        uint256 ratePerETH,
        IERC20 idoToken,
       
        uint256 pooltype
      
    ) public onlyOwner {

        uint256 poolIndex = pid.sub(1);
        if (begin > 0) {
            pools[poolIndex].Begin = begin;
        }
        if (end > 0) {
            pools[poolIndex].End = end;
        }

        if (maxPurchaseTier1 > 0) {
            pools[poolIndex].MaxPurchaseTier1 = maxPurchaseTier1;
        }
        if (maxPurchaseTier2 > 0) {
            pools[poolIndex].MaxPurchaseTier2 = maxPurchaseTier2;
        }
        if (maxPurchaseTier3 > 0) {
            pools[poolIndex].MaxPurchaseTier3 = maxPurchaseTier3;
        }
          if (maxSpecialPurchase > 0) {
            pools[poolIndex].MaxSpecialPurchase = maxSpecialPurchase;
        }
        if (totalCap > 0) {
            pools[poolIndex].TotalCap = totalCap;
        }
        if (totalToken > 0) {
            pools[poolIndex].TotalToken = totalToken;
        }
        if (ratePerETH > 0) {
            pools[poolIndex].RatePerETH = ratePerETH;
        }

       
      
        if (pooltype > 0) {
            pools[poolIndex].Type = pooltype;
        }
        pools[poolIndex].IDOToken = idoToken;
    }

    function withdrawErc20(IERC20 token) public onlyOwner {

        token.transfer(owner(), token.balanceOf(address(this)));
    }

    function withdrawPoolFund() public onlyOwner {

        uint256 balance = address(this).balance;
        require(balance > 0, "not enough fund");
        ReceiveToken.transfer(balance);
    }

    function purchaseIDO(
        uint256 stakeAmount,
        uint256 pid,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable nonReentrant {

        uint256 poolIndex = pid.sub(1);

        if (pools[poolIndex].Type == 2 || pools[poolIndex].Type == 4) {
            bytes32 _hash = keccak256(abi.encodePacked(msg.sender, stakeAmount));
            bytes32 messageHash = _hash.toEthSignedMessageHash();

            require(
                owner() == ecrecover(messageHash, v, r, s),
                "owner should sign purchase info"
            );
        }

        require(
            block.timestamp >= pools[poolIndex].Begin &&
                block.timestamp <= pools[poolIndex].End,
            "invalid time"
        );
        require(IsWhitelist(msg.sender, pid, stakeAmount), "invalid user");

        uint256 ethAmount = msg.value;
        users[pid][msg.sender].TotalETHPurchase = users[pid][msg.sender]
            .TotalETHPurchase
            .add(ethAmount);

        if (pools[poolIndex].Type == 2) {
            if (stakeAmount < 1500 * 1e18) {
                require(
                    users[pid][msg.sender].TotalETHPurchase <=
                        pools[poolIndex].MaxPurchaseTier1,
                    "invalid maximum purchase for tier1"
                );
            } else if (
                stakeAmount >= 1500 * 1e18 && stakeAmount < 3000 * 1e18
            ) {
                require(
                    users[pid][msg.sender].TotalETHPurchase <=
                        pools[poolIndex].MaxPurchaseTier2,
                    "invalid maximum purchase for tier2"
                );
            } else {
                require(
                    users[pid][msg.sender].TotalETHPurchase <=
                        pools[poolIndex].MaxPurchaseTier3,
                    "invalid maximum purchase for tier3"
                );
            }
        } else if (pools[poolIndex].Type == 1) {

            require(
                users[pid][msg.sender].TotalETHPurchase <=
                    pools[poolIndex].MaxPurchaseTier2,
                "invalid maximum contribute"
            );
        } else  if (pools[poolIndex].Type == 3){//special
            
            require(
                users[pid][msg.sender].TotalETHPurchase <=
                    pools[poolIndex].MaxSpecialPurchase,
                "invalid contribute"
            );
        }else{//4 guaranteed
            
            require(
                users[pid][msg.sender].TotalETHPurchase <=
                     users[pid][msg.sender].PurchaseAllocation,
                "invalid contribute"
            );
        }

        uint256 tokenAmount = ethAmount.mul(pools[poolIndex].RatePerETH).div(
            1e18
        );

        uint256 remainToken = getRemainIDOToken(pid);
        require(
            remainToken > pools[poolIndex].MinimumTokenSoldout,
            "IDO sold out"
        );
        require(remainToken >= tokenAmount, "IDO sold out");

        users[pid][msg.sender].TotalTokenPurchase = users[pid][msg.sender]
            .TotalTokenPurchase
            .add(tokenAmount);

        pools[poolIndex].TotalSold = pools[poolIndex].TotalSold.add(
            tokenAmount
        );
    }

    function claimToken(uint256 pid) public nonReentrant {

        require(
            users[pid][msg.sender].TotalPercentClaimed < 100,
            "you have claimed enough"
        );
        uint256 userBalance = getUserTotalPurchase(pid);
        require(userBalance > 0, "invalid claim");

        uint256 poolIndex = pid.sub(1);
        if (users[pid][msg.sender].NumberClaimed == 0) {
            require(
                block.timestamp >= claimInfos[poolIndex].ClaimTime1,
                "invalid time"
            );
            pools[poolIndex].IDOToken.safeTransfer(
                msg.sender,
                userBalance.mul(claimInfos[poolIndex].PercentClaim1).div(100)
            );
          users[pid][msg.sender].TotalPercentClaimed=  users[pid][msg.sender].TotalPercentClaimed.add(
                claimInfos[poolIndex].PercentClaim1
            );
        } else if (users[pid][msg.sender].NumberClaimed == 1) {
            require(
                block.timestamp >= claimInfos[poolIndex].ClaimTime2,
                "invalid time"
            );
            pools[poolIndex].IDOToken.safeTransfer(
                msg.sender,
                userBalance.mul(claimInfos[poolIndex].PercentClaim2).div(100)
            );
            users[pid][msg.sender].TotalPercentClaimed=users[pid][msg.sender].TotalPercentClaimed.add(
                claimInfos[poolIndex].PercentClaim2
            );
        } else if (users[pid][msg.sender].NumberClaimed == 2) {
            require(
                block.timestamp >= claimInfos[poolIndex].ClaimTime3,
                "invalid time"
            );
            pools[poolIndex].IDOToken.safeTransfer(
                msg.sender,
                userBalance.mul(claimInfos[poolIndex].PercentClaim3).div(100)
            );
           users[pid][msg.sender].TotalPercentClaimed= users[pid][msg.sender].TotalPercentClaimed.add(
                claimInfos[poolIndex].PercentClaim3
            );
        }

         else if (users[pid][msg.sender].NumberClaimed == 3) {
            require(
                block.timestamp >= claimInfos[poolIndex].ClaimTime4,
                "invalid time"
            );
            pools[poolIndex].IDOToken.safeTransfer(
                msg.sender,
                userBalance.mul(claimInfos[poolIndex].PercentClaim4).div(100)
            );
           users[pid][msg.sender].TotalPercentClaimed= users[pid][msg.sender].TotalPercentClaimed.add(
                claimInfos[poolIndex].PercentClaim4
            );
        }
         else if (users[pid][msg.sender].NumberClaimed == 4) {
            require(
                block.timestamp >= claimInfos[poolIndex].ClaimTime5,
                "invalid time"
            );
            pools[poolIndex].IDOToken.safeTransfer(
                msg.sender,
                userBalance.mul(claimInfos[poolIndex].PercentClaim5).div(100)
            );
           users[pid][msg.sender].TotalPercentClaimed= users[pid][msg.sender].TotalPercentClaimed.add(
                claimInfos[poolIndex].PercentClaim5
            );
        }
        else if (users[pid][msg.sender].NumberClaimed == 5) {
            require(
                block.timestamp >= claimInfos[poolIndex].ClaimTime6,
                "invalid time"
            );
            pools[poolIndex].IDOToken.safeTransfer(
                msg.sender,
                userBalance.mul(claimInfos[poolIndex].PercentClaim6).div(100)
            );
           users[pid][msg.sender].TotalPercentClaimed= users[pid][msg.sender].TotalPercentClaimed.add(
                claimInfos[poolIndex].PercentClaim6
            );
        }
        else if (users[pid][msg.sender].NumberClaimed == 6) {
            require(
                block.timestamp >= claimInfos[poolIndex].ClaimTime7,
                "invalid time"
            );
            pools[poolIndex].IDOToken.safeTransfer(
                msg.sender,
                userBalance.mul(claimInfos[poolIndex].PercentClaim7).div(100)
            );
           users[pid][msg.sender].TotalPercentClaimed= users[pid][msg.sender].TotalPercentClaimed.add(
                claimInfos[poolIndex].PercentClaim7
            );
        }

        users[pid][msg.sender].LastClaimed = block.timestamp;
        users[pid][msg.sender].NumberClaimed=users[pid][msg.sender].NumberClaimed.add(1);
    }

    function getUserTotalPurchase(uint256 pid) public view returns (uint256) {

        return users[pid][msg.sender].TotalTokenPurchase;
    }

    function getRemainIDOToken(uint256 pid) public view returns (uint256) {

        uint256 poolIndex = pid.sub(1);
        uint256 tokenBalance = getBalanceTokenByPoolId(pid);
        if (pools[poolIndex].TotalSold > tokenBalance) {
            return 0;
        }

        return tokenBalance.sub(pools[poolIndex].TotalSold);
    }

    function getBalanceTokenByPoolId(uint256 pid)
        public
        view
        returns (uint256)
    {

        uint256 poolIndex = pid.sub(1);

        return pools[poolIndex].TotalToken;
    }

    function getPoolInfo(uint256 pid)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
             uint256,
            IERC20
        )
    {

        uint256 poolIndex = pid.sub(1);
        return (
            pools[poolIndex].Begin,
            pools[poolIndex].End,
            pools[poolIndex].Type,
            pools[poolIndex].RatePerETH,
            pools[poolIndex].TotalSold,
            pools[poolIndex].TotalToken,
            pools[poolIndex].TotalCap,
            pools[poolIndex].IDOToken
        );
    }

    function getClaimInfo(uint256 pid)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        uint256 poolIndex = pid.sub(1);
        return (
            claimInfos[poolIndex].ClaimTime1,
            claimInfos[poolIndex].PercentClaim1,
            claimInfos[poolIndex].ClaimTime2,
            claimInfos[poolIndex].PercentClaim2,
            claimInfos[poolIndex].ClaimTime3,
            claimInfos[poolIndex].PercentClaim3
        );
    }

    function getPoolSoldInfo(uint256 pid) public view returns (uint256) {

        uint256 poolIndex = pid.sub(1);
        return (pools[poolIndex].TotalSold);
    }

    function getWhitelistfo(uint256 pid)
        public
        view
        returns (
          
            bool,
            uint256,
            uint256
        )
    {

        return (
           
            users[pid][msg.sender].IsWhitelist,
            users[pid][msg.sender].TotalTokenPurchase,
            users[pid][msg.sender].TotalETHPurchase
        );
    }

    function getUserInfo(uint256 pid, address user)
        public
        view
        returns (
            bool,
            uint256,
            uint256,
            uint256
        )
    {

        return (
            users[pid][user].IsWhitelist,
            users[pid][user].TotalTokenPurchase,
            users[pid][user].TotalETHPurchase,
            users[pid][user].TotalPercentClaimed
        );
    }

    function getUserPurchaseAllocation(uint256 pid, address user)
        public
        view
        returns (
            uint256
        )
    {

        return (
            users[pid][user].PurchaseAllocation
        );
    }
}