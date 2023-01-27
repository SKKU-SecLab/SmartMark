



pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.7.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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


pragma solidity ^0.7.0;

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


pragma solidity ^0.7.0;

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


pragma solidity ^0.7.0;

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


pragma solidity ^0.7.0;




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


pragma solidity ^0.7.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}


pragma solidity 0.7.5;





abstract contract Pacemaker {

    using SafeMath for uint256;
    uint256 constant public HEART_BEAT_START_TIME = 1607212800;// 2020-12-06 00:00:00 UTC (UTC +00:00)
    uint256 constant public EPOCH_PERIOD = 8 hours;

    function epochFromTimestamp(uint256 timestamp) public pure returns (uint256) {
        if (timestamp > HEART_BEAT_START_TIME) {
            return timestamp.sub(HEART_BEAT_START_TIME).div(EPOCH_PERIOD).add(1);
        }
        return 0;
    }

    function epochStartTimeFromTimestamp(uint256 timestamp) public pure returns (uint256) {
        if (timestamp <= HEART_BEAT_START_TIME) {
            return HEART_BEAT_START_TIME;
        } else {
            return HEART_BEAT_START_TIME.add((epochFromTimestamp(timestamp).sub(1)).mul(EPOCH_PERIOD));
        }
    }

    function epochEndTimeFromTimestamp(uint256 timestamp) public pure returns (uint256) {
        if (timestamp < HEART_BEAT_START_TIME) {
            return HEART_BEAT_START_TIME;
        } else if (timestamp == HEART_BEAT_START_TIME) {
            return HEART_BEAT_START_TIME.add(EPOCH_PERIOD);
        } else {
            return epochStartTimeFromTimestamp(timestamp).add(EPOCH_PERIOD);
        }
    }

    function currentEpoch() public view returns (uint256) {
        return epochFromTimestamp(block.timestamp);// solhint-disable-line not-rely-on-time
    }

}


pragma solidity 0.7.5;



interface IToken0 is IERC20 {

    function mint(address account, uint256 amount) external;


    function burn(uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;

}


pragma solidity 0.7.5;
pragma abicoder v2;


interface IVault {

    function lockVault() external;


    function unlockVault() external;


    function safeAddAsset(address[] calldata tokenAddresses, uint256[] calldata tokenIds,
            string[] calldata categories) external;


    function safeTransferAsset(uint256[] calldata assetIds) external;


    function escapeHatchERC721(address tokenAddress, uint256 tokenId) external;


    function setDecentralandOperator(address registryAddress, address operatorAddress,
        uint256 assetId) external;


    function transferOwnership(address newOwner) external;


    function totalAssetSlots() external view returns (uint256);


    function onERC721Received(address, uint256, bytes memory) external pure returns (bytes4);


}


pragma solidity 0.7.5;


contract SimpleBuyout is Ownable, Pacemaker, Pausable {

    using SafeERC20 for IERC20;
    using SafeERC20 for IToken0;
    using SafeMath for uint256;
    using Address for address;

    enum BuyoutStatus { ENABLED, ACTIVE, REVOKED, ENDED }

    BuyoutStatus public status;
    IToken0 public token0;
    IERC20 public token2;
    uint256 public startThreshold;
    uint256[4] public epochs;// [startEpoch, endEpoch, durationInEpochs, bidIntervalInEpochs]
    IVault public vault;
    uint256 public stopThresholdPercent;
    uint256 public currentBidToken0Staked;
    mapping (address => uint256) public token0Staked;
    address public highestBidder;
    uint256[3] public highestBidValues;// [highestBid, highestToken0Bid, highestToken2Bid]
    uint256 public currentBidId;
    mapping (address => uint256) public lastVetoedBidId;
    uint256 public redeemToken2Amount;
    mapping (address => uint256) public lastVetoedBlockNumber;

    uint256 constant public MINIMUM_BID_PERCENTAGE_INCREASE_ON_VETO = 108;
    uint256 constant public MINIMUM_BID_TOKEN0_PERCENTAGE_REQUIRED = 1;

    event HighestBidIncreased(address bidder, uint256 amount);
    event BuyoutStarted(address bidder, uint256 amount);
    event BuyoutRevoked(uint256 amount);
    event BuyoutEnded(address bidder, uint256 amount);

    constructor(address token0Address, address token2Address, address vaultAddress, uint256[4] memory uint256Values) {
        require(token0Address.isContract(), "{enableBuyout} : invalid token0Address");
        require(token2Address.isContract(), "{enableBuyout} : invalid token2Address");
        require(vaultAddress.isContract(), "{enableBuyout} : invalid vaultAddress");
        require(uint256Values[0] > 0, "{enableBuyout} : startThreshold cannot be zero");
        require(uint256Values[1] > 0, "{enableBuyout} : durationInEpochs cannot be zero");
        require(uint256Values[3] > 0 && uint256Values[3] <= 100,
            "{enableBuyout} : stopThresholdPercent should be between 1 and 100");
        token0 = IToken0(token0Address);
        token2 = IERC20(token2Address);
        vault = IVault(vaultAddress);
        startThreshold = uint256Values[0];
        epochs[2] = uint256Values[1];
        epochs[3] = uint256Values[2];
        stopThresholdPercent = uint256Values[3];
        status = BuyoutStatus.ENABLED;
    }

    function togglePause(bool pause) external onlyOwner {

        if (pause) {
            _pause();
        } else {
            _unpause();
        }
    }

    function transferVaultOwnership(address newOwner) external onlyOwner whenPaused {

        require(newOwner != address(0), "{transferVaultOwnership} : invalid newOwner");
        vault.transferOwnership(newOwner);
    }

    function placeBid(uint256 totalBidAmount, uint256 token2Amount) external whenNotPaused {

        require(status != BuyoutStatus.ENDED, "{placeBid} : buyout has ended");
        require(totalBidAmount > startThreshold, "{placeBid} : totalBidAmount does not meet minimum threshold");
        require(token2.balanceOf(msg.sender) >= token2Amount, "{placeBid} : insufficient token2 balance");
        require(totalBidAmount > highestBidValues[0], "{placeBid} : there already is a higher bid");
        uint256 token0Amount = requiredToken0ToBid(totalBidAmount, token2Amount);
        require(token0.balanceOf(msg.sender) >= token0Amount, "{placeBid} : insufficient token0 balance");
        require(token0Amount >= token0.totalSupply().mul(MINIMUM_BID_TOKEN0_PERCENTAGE_REQUIRED).div(100),
            "{placeBid} : token0Amount should be at least 5% of token0 totalSupply");
        currentBidId = currentBidId.add(1);
        currentBidToken0Staked = 0;
        if (status == BuyoutStatus.ACTIVE) {
            require(currentEpoch() <= epochs[1], "{placeBid} : buyout end epoch has been surpassed");
            epochs[1] = currentEpoch().add(epochs[3]);
        } else {
            status = BuyoutStatus.ACTIVE;
            epochs[1] = currentEpoch().add(epochs[2]);
        }
        epochs[0] = currentEpoch();
        if (highestBidValues[1] > 0) {
            token0.safeTransfer(highestBidder, highestBidValues[1]);
        }
        if (highestBidValues[2] > 0) {
            token2.safeTransfer(highestBidder, highestBidValues[2]);
        }
        highestBidder = msg.sender;
        highestBidValues[0] = totalBidAmount;
        highestBidValues[1] = token0Amount;
        highestBidValues[2] = token2Amount;
        token0.safeTransferFrom(msg.sender, address(this), token0Amount);
        token2.safeTransferFrom(msg.sender, address(this), token2Amount);
        emit HighestBidIncreased(msg.sender, totalBidAmount);
    }

    function veto(uint256 token0Amount) external whenNotPaused {

        require(token0Amount > 0, "{veto} : token0Amount cannot be zero");
        token0Staked[msg.sender] = token0Staked[msg.sender].add(token0Amount);
        uint256 vetoAmount = lastVetoedBidId[msg.sender] == currentBidId ? token0Amount : token0Staked[msg.sender];
        _veto(msg.sender, vetoAmount);
        token0.safeTransferFrom(msg.sender, address(this), token0Amount);
    }

    function extendVeto() external whenNotPaused {

        uint256 token0Amount = token0Staked[msg.sender];
        require(token0Amount > 0, "{extendVeto} : no staked token0Amount");
        require(lastVetoedBidId[msg.sender] != currentBidId, "{extendVeto} : already vetoed");
        _veto(msg.sender, token0Amount);
    }

    function withdrawStakedToken0(uint256 token0Amount) external {

        require(lastVetoedBlockNumber[msg.sender] < block.number, "{withdrawStakedToken0} : Flash attack!");
        require(token0Amount > 0, "{withdrawStakedToken0} : token0Amount cannot be zero");
        require(token0Staked[msg.sender] >= token0Amount,
            "{withdrawStakedToken0} : token0Amount cannot exceed staked amount");
        if ((status == BuyoutStatus.ACTIVE) && (currentEpoch() <= epochs[1])) {
            require(lastVetoedBidId[msg.sender] != currentBidId,
                "{withdrawStakedToken0} : cannot unstake until veto on current bid expires");
        }
        token0Staked[msg.sender] = token0Staked[msg.sender].sub(token0Amount);
        token0.safeTransfer(msg.sender, token0Amount);
    }

    function endBuyout() external whenNotPaused {

        require(currentEpoch() > epochs[1], "{endBuyout} : end epoch has not yet been reached");
        require(status != BuyoutStatus.ENDED, "{endBuyout} : buyout has already ended");
        require(highestBidder != address(0), "{endBuyout} : buyout does not have highestBidder");
        require(((highestBidValues[1] > 0) || (highestBidValues[2] > 0)),
            "{endBuyout} : highestBidder deposits cannot be 0");
        status = BuyoutStatus.ENDED;
        redeemToken2Amount = highestBidValues[2];
        highestBidValues[2] = 0;
        if (highestBidValues[1] > 0) {
            token0.burn(highestBidValues[1]);
        }
        vault.transferOwnership(highestBidder);

        emit BuyoutEnded(highestBidder, highestBidValues[0]);
    }

    function withdrawBid() external whenPaused {

        require(highestBidder == msg.sender, "{withdrawBid} : sender is not highestBidder");
        _resetHighestBidDetails();

    }

    function redeem(uint256 token0Amount) external {

        require(status == BuyoutStatus.ENDED, "{redeem} : redeem has not yet been enabled");
        require(token0.balanceOf(msg.sender) >= token0Amount, "{redeem} : insufficient token0 amount");
        require(token0Amount > 0, "{redeem} : token0 amount cannot be zero");
        uint256 token2Amount = token2AmountRedeemable(token0Amount);
        redeemToken2Amount = redeemToken2Amount.sub(token2Amount);
        token0.burnFrom(msg.sender, token0Amount);
        token2.safeTransfer(msg.sender, token2Amount);
    }

    function token2AmountRedeemable(uint256 token0Amount) public view returns (uint256) {

        return token0Amount.mul(redeemToken2Amount).div(token0.totalSupply());
    }

    function requiredToken0ToBid(uint256 totalBidAmount, uint256 token2Amount) public view returns (uint256) {

        uint256 token0Supply = token0.totalSupply();
        require(token2Amount <= totalBidAmount, "{requiredToken0ToBid} : token2Amount cannot exceed totalBidAmount");
        return token0Supply
            .mul(
                totalBidAmount
                .sub(token2Amount)
            ).div(totalBidAmount);
    }

    function _resetHighestBidDetails() internal {

        uint256 token0Amount = highestBidValues[1];
        uint256 token2Amount = highestBidValues[2];
        if (token0Amount > 0) {
            token0.safeTransfer(highestBidder, token0Amount);
        }
        if (token2Amount > 0) {
            token2.safeTransfer(highestBidder, token2Amount);
        }
        highestBidder = address(0);
        highestBidValues[0] = 0;
        highestBidValues[1] = 0;
        highestBidValues[2] = 0;
    }

    function _veto(address sender, uint256 token0Amount) internal {

        require((
            (status == BuyoutStatus.ACTIVE) && (currentEpoch() >= epochs[0]) && (currentEpoch() <= epochs[1])
        ), "{_veto} : buyout is not active");
        lastVetoedBlockNumber[sender] = block.number;
        lastVetoedBidId[sender] = currentBidId;
        uint256 updatedCurrentBidToken0Staked = currentBidToken0Staked.add(token0Amount);
        if (updatedCurrentBidToken0Staked < stopThresholdPercent.mul(token0.totalSupply().div(100))) {
            currentBidToken0Staked = updatedCurrentBidToken0Staked;
        } else {
            currentBidToken0Staked = 0;
            startThreshold = highestBidValues[0].mul(MINIMUM_BID_PERCENTAGE_INCREASE_ON_VETO).div(100);
            epochs[1] = 0;
            status = BuyoutStatus.REVOKED;
            _resetHighestBidDetails();
            emit BuyoutRevoked(updatedCurrentBidToken0Staked);
        }
    }

}