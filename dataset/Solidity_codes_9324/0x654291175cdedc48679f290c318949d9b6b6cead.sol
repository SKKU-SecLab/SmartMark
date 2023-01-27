



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
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



pragma solidity 0.6.8;





interface IERC20Transfers {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

struct ParticipantData {
        uint256 timestamp;
        uint256 amount;
    }

contract TimeTrialEliteLeague is Context, Pausable, Ownable {

    using SafeMath for uint256;
    event ParticipationUpdated(address participant, bytes32 tierId, uint256 deposit);

    IERC20Transfers public immutable gamingToken;
    uint256 public immutable lockingPeriod;
    mapping(bytes32 => uint256) public tiers; // tierId => minimumAmountToEscrow
    mapping(address => mapping(bytes32 => ParticipantData)) public participants; // participant => tierId => ParticipantData
    constructor(
        IERC20Transfers gamingToken_,
        uint256 lockingPeriod_,
        bytes32[] memory tierIds,
        uint256[] memory amounts
    ) public {
        require(gamingToken_ != IERC20Transfers(0), "Leagues: zero address");
        require(lockingPeriod_ != 0, "Leagues: zero lock");
        gamingToken = gamingToken_;
        lockingPeriod = lockingPeriod_;

        uint256 length = tierIds.length;
        require(length == amounts.length, "Leagues: inconsistent arrays");
        for (uint256 i = 0; i < length; ++i) {
            uint256 amount = amounts[i];
            require(amount != 0, "Leagues: zero amount");
            tiers[tierIds[i]] = amount;
        }
    }

    function increaseDeposit(bytes32 tierId, uint256 amount) whenNotPaused public {

        address sender = _msgSender();
        require(tiers[tierId] != 0, "Leagues: tier not found");
        ParticipantData memory pd = participants[sender][tierId];
        require(pd.timestamp != 0, "Leagues: non participant");
        uint256 newAmount = amount.add(pd.amount);
        participants[sender][tierId] = ParticipantData(block.timestamp,newAmount);
        require(
            gamingToken.transferFrom(sender, address(this), amount),
            "Leagues: transfer in failed"
        );
        emit ParticipationUpdated(sender, tierId, newAmount);
    }

    function enterTier(bytes32 tierId, uint256 deposit) whenNotPaused public {

        address sender = _msgSender();
        uint256 minDeposit = tiers[tierId];
        require(minDeposit != 0, "Leagues: tier not found");
        require(minDeposit <= deposit, "Leagues: insufficient amount");
        require(participants[sender][tierId].timestamp == 0, "Leagues: already participant");
        participants[sender][tierId] = ParticipantData(block.timestamp,deposit);
        require(
            gamingToken.transferFrom(sender, address(this), deposit),
            "Leagues: transfer in failed"
        );
        emit ParticipationUpdated(sender, tierId, deposit);
    }

    function exitTier(bytes32 tierId) public {

        address sender = _msgSender();
        ParticipantData memory pd = participants[sender][tierId];
        require(pd.timestamp != 0, "Leagues: non-participant");
        
        require(block.timestamp - pd.timestamp > lockingPeriod, "Leagues: time-locked");
        participants[sender][tierId] = ParticipantData(0,0);
        emit ParticipationUpdated(sender, tierId, 0);
        require(
            gamingToken.transfer(sender, pd.amount),
            "Leagues: transfer out failed"
        );
    }

    function participantStatus(address participant, bytes32[] calldata tierIds)
        external
        view
        returns (uint256[] memory timestamps)
    {

        uint256 length = tierIds.length;
        timestamps = new uint256[](length);
        for (uint256 i = 0; i < length; ++i) {
            timestamps[i] = participants[participant][tierIds[i]].timestamp;
        }
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

}