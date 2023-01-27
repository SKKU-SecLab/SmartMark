
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction underflow");
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

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

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

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


contract FeswSponsor { 


    using SafeMath for uint256;

    uint256 public constant TARGET_RAISING_ETH = 1_000e18;    

    uint256 public constant MIN_GUARANTEE_ETH = 1e18;    

    uint256 public constant INITIAL_FESW_RATE_PER_ETH = 100_000;    

    uint256 public constant FESW_CHANGE_RATE_VERSUS_ETH = 20; 

    uint256 public constant SPONSOR_DURATION = 30 * 24 * 3600;     

    address public FeswapToken;     

    address public FeswapFund;     

    address public FeswapBurner;     

    uint256 public TotalETHReceived;   

    uint256 public CurrentGiveRate;    

    uint64 public SponsorStartTime;

    uint64 public LastBlockTime;

    uint64 public SponsorFinalized;

    event EvtSponsorReceived(address indexed from, address indexed to, uint256 ethValue);

    event EvtSponsorFinalized(address indexed to, uint256 ethValue);
  
    constructor (address feswapToken, address feswapFund, address feswapBurner, uint256 sponsorStartTime ) 
    {
        FeswapToken         = feswapToken;
        FeswapFund          = feswapFund; 
        FeswapBurner        = feswapBurner; 
        SponsorStartTime    = uint64(sponsorStartTime);
    }

    function Sponsor(address feswapReceiver) external payable returns (uint256 sponsorAccepted) {

        require(block.timestamp >= SponsorStartTime, 'FESW: SPONSOR NOT STARTED');
        require(block.timestamp < (SponsorStartTime + SPONSOR_DURATION), 'FESW: SPONSOR ENDED');
        require(TotalETHReceived < TARGET_RAISING_ETH, 'FESW: SPONSOR COMPLETED');

        uint256 feswGiveRate;
        if(block.timestamp > LastBlockTime) {
            feswGiveRate = INITIAL_FESW_RATE_PER_ETH - TotalETHReceived.mul(FESW_CHANGE_RATE_VERSUS_ETH).div(1e18);
            CurrentGiveRate = feswGiveRate;
            LastBlockTime = uint64(block.timestamp);
        } else {
            feswGiveRate = CurrentGiveRate;
        }

        sponsorAccepted = TARGET_RAISING_ETH - TotalETHReceived;
        if(sponsorAccepted < MIN_GUARANTEE_ETH){
            sponsorAccepted = MIN_GUARANTEE_ETH;
        }
        if (msg.value < sponsorAccepted){
            sponsorAccepted = msg.value;          
        }                                                        

        TotalETHReceived += sponsorAccepted;                                                              

        uint256 feswapGiveaway = sponsorAccepted.mul(feswGiveRate);
        TransferHelper.safeTransfer(FeswapToken, feswapReceiver, feswapGiveaway);
 
        if(msg.value > sponsorAccepted){
            TransferHelper.safeTransferETH(msg.sender, msg.value - sponsorAccepted);
        }    
        
        emit EvtSponsorReceived(msg.sender, feswapReceiver, sponsorAccepted);
    }

    function finalizeSponsor() public {

        require(SponsorFinalized == 0, 'FESW: SPONSOR FINALIZED');
        require(msg.sender == FeswapFund, 'FESW: NOT ALLOWED');
        require( (block.timestamp >= (SponsorStartTime + SPONSOR_DURATION)) 
                    || (TotalETHReceived >= TARGET_RAISING_ETH), 'FESW: SPONSOR ONGOING');

        address to = FeswapBurner;

        if(TotalETHReceived < TARGET_RAISING_ETH) to = FeswapFund;

        uint256 feswLeft = IERC20(FeswapToken).balanceOf(address(this));
        TransferHelper.safeTransfer(FeswapToken, to, feswLeft);

        TransferHelper.safeTransferETH(FeswapFund, address(this).balance );
        SponsorFinalized = 0xA5;

        emit EvtSponsorFinalized(FeswapFund, TotalETHReceived);
    }
}