


pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
}

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

contract Ownable is Context, Initializable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function init(address sender) internal virtual initializer {

        _owner = sender;
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

interface Battle {

    function leave(address _user, uint256 _amount) external;

}

contract vEmpireGame is Ownable {

    using SafeMath for uint256;

    struct BattleInfo {
        address player1;
        address player2;
        uint256 poolAmount;
        uint256 riskPercent;
        string roomId;
        address winnerAddress;
        bool claimStatus;
    }

    struct UserInfo {
        address player2;
        string roomId;
        bool xsVempLockStatus;
    }

    mapping(string => BattleInfo) public battleInfo;

    mapping(string => mapping(address => UserInfo)) public userInfo;

    address public xsVemp;

    address public battleAddress;

    address public ddaoAddress;

    uint256 public daoPercent;

    uint256 public daoTokens;

    uint256 public minBattleTokens = 1000000000000000000;

    mapping(address => bool) public adminStatus;

    address[] private playersForAirdrop;

    address[] public winners;

    string[] public battleIds;

    mapping(string => address) public loser;

    function initialize(address owner_, address _xsVemp, address _battleAddress, uint256 _ddaoPercent, address _ddaoAddress) public initializer {        

        require(_xsVemp != address(0), "Invalid _xsVemp address");
        require(_battleAddress != address(0), "Invalid _battleAddress address");
        require(owner_ != address(0), "Invalid owner_ address");
        require(_ddaoAddress != address(0), "Invalid _ddaoAddress address");

        Ownable.init(owner_);
        xsVemp = _xsVemp;
        daoPercent = _ddaoPercent;
        battleAddress = _battleAddress;
        ddaoAddress = _ddaoAddress;
    }

    modifier onlyAdmin() {

        require(adminStatus[_msgSender()], "Caller is not admin");
        _;
    }

    function getPlayersForAirdrop()
        public
        view
        onlyAdmin
        returns (address[] memory)
    {

        return playersForAirdrop;
    }

    function battleLockTokens(
        uint256 _poolAmount,
        uint256 _riskPercent,
        string memory _roomId
    ) external {

        if (_poolAmount == 0 || _riskPercent == 0 || keccak256(bytes(_roomId)) == keccak256(bytes(""))) {
            revert("Invalid data");
        }
        require(
            _poolAmount >= minBattleTokens,
            "Pool amount can not less than min battle tokens"
        );

        BattleInfo storage battle = battleInfo[_roomId];
        UserInfo storage user = userInfo[_roomId][msg.sender];

        require(battle.winnerAddress == address(0), "Battle already ended");
        if (battle.player1 != address(0)) {
            require(
                keccak256(bytes(battle.roomId)) == keccak256(bytes(_roomId)) && battle.player2 == address(0),
                "Invalid room id data"
            );
            require(
                battle.riskPercent == _riskPercent &&
                    battle.poolAmount == _poolAmount,
                "Invalid risk and pool"
            );
            require(battle.player1 != msg.sender, "Room id already used");
            UserInfo storage user2 = userInfo[_roomId][battle.player1];
            battle.player2 = msg.sender;
            user2.player2 = msg.sender;
            user.player2 = battle.player1;
            user.roomId = _roomId;
            user.xsVempLockStatus = false;
            playersForAirdrop.push(msg.sender);
        } else {
            require(
                battle.player1 == address(0) && battle.player2 == address(0),
                "Room id already used"
            );
            battle.player1 = msg.sender;
            battle.player2 = address(0);
            battle.poolAmount = _poolAmount;
            battle.riskPercent = _riskPercent;
            battle.roomId = _roomId;
            battle.winnerAddress = address(0);

            user.player2 = address(0);
            user.roomId = _roomId;
            user.xsVempLockStatus = false;
            playersForAirdrop.push(msg.sender);
            battleIds.push(_roomId);
        }

        if (!user.xsVempLockStatus) {
            IERC20(xsVemp).transferFrom(msg.sender, address(this), _poolAmount);
            user.xsVempLockStatus = true;
        }
    }

    function updateWinnerAddress(address[] memory _winnerAddress, string[] memory _roomId)
        public
        onlyAdmin
    {

        require(_winnerAddress.length == _roomId.length, "Invalid data for winners");
        for(uint256 i=0; i<_winnerAddress.length; i++) {
            BattleInfo storage battle = battleInfo[_roomId[i]];
            UserInfo storage user1 = userInfo[_roomId[i]][battle.player1];
            UserInfo storage user2 = userInfo[_roomId[i]][battle.player2];

            require(_winnerAddress[i] != address(0) && (battle.player1 == _winnerAddress[i] || battle.player2 == _winnerAddress[i]), "Invalid Winner Address");
            require(battle.player1 != address(0) || battle.player2 != address(0), "Invalid players");
            require(
                user1.xsVempLockStatus != false || user2.xsVempLockStatus != false,
                "Invalid users lock status"
            );
            require(battle.winnerAddress == address(0), "Winner already declared");

            battle.winnerAddress = _winnerAddress[i];

            address _loser = _winnerAddress[i] == battle.player1
                ? battle.player2
                : battle.player1;
            if(_loser != address(0)) {
                playersForAirdrop.push(_loser);
            }
            loser[_roomId[i]] = _loser;
            winners.push(battle.winnerAddress);
        }
    }

    function claimBattleRewards(string memory _roomId) public {

        BattleInfo storage battle = battleInfo[_roomId];
        UserInfo storage user = userInfo[_roomId][msg.sender];

        require(
            battle.player1 != address(0) || battle.player2 != address(0),
            "Invalid players address"
        );
        require(battle.winnerAddress != address(0), "Battle result in pending");
        require(
            battle.winnerAddress == _msgSender(),
            "Only winner can call this method"
        );
        require(user.xsVempLockStatus != false, "Invalid users lock status");
        require(battle.claimStatus != true, "Already claimed");

        if(battle.player2 != address(0)) {
            uint256 winnerShare = 100;
            uint256 winnerAmount = battle.poolAmount.mul(2).mul(winnerShare.sub(daoPercent)).div(100);
            daoTokens = daoTokens.add((battle.poolAmount.mul(2).sub(winnerAmount)));
            IERC20(xsVemp).transfer(
                battle.winnerAddress,
                winnerAmount
            );
        } else {
            IERC20(xsVemp).transfer(
                battle.winnerAddress,
                battle.poolAmount
            );
        }
        battle.claimStatus = true;
    }

    function withdrawxsVempFeeTokensToVemp(uint256 _amount)
        public
        onlyOwner
    {

        require(daoTokens >= _amount, "Insufficiently amount");
        IERC20(xsVemp).approve(address(battleAddress), _amount);
        Battle(battleAddress).leave(ddaoAddress, _amount);
        daoTokens = daoTokens.sub(_amount);
    }

    function withdrawxsVempFeeTokens(address _to, uint256 _amount)
        public
        onlyOwner
    {

        require(_to != address(0), "Invalid to address");
        require(daoTokens >= _amount, "Insufficiently amount");
        IERC20(xsVemp).transfer(_to, _amount);
        daoTokens = daoTokens.sub(_amount);
    }

    function updateAdmin(address _admin, bool _status) public onlyOwner {

        require(adminStatus[_admin] != _status, "Already in same status");
        adminStatus[_admin] = _status;
    }

    function updateMinBattleTokens(uint256 _minBattleTokens) public onlyOwner {

        minBattleTokens = _minBattleTokens;
    }

    function updateDDAOPercent(uint256 _ddaoPercent) public onlyOwner {

        require(_ddaoPercent <= 100, "Invalid Dao Percent");
        daoPercent = _ddaoPercent;
    }

    function updateBattleAddress(address _battleAddress) public onlyOwner {

        require(_battleAddress != address(0), "Invalid _battleAddress address");
        battleAddress = _battleAddress;
    }

    function updateDDAOAddress(address _ddaoAddress) public onlyOwner {

        require(_ddaoAddress != address(0), "Invalid _ddaoAddress address");
        ddaoAddress = _ddaoAddress;
    }

    function emergencyWithdrawxsVempTokens(address _to, uint256 _amount)
        public
        onlyOwner
    {

        require(_to != address(0), "Invalid _to address");
        uint256 vempBal = IERC20(xsVemp).balanceOf(address(this));
        require(vempBal >= _amount, "Insufficiently amount");
        IERC20(xsVemp).transfer(_to, _amount);
    }

    function updateWinnerInEmergency(string memory _roomId, address _winnerAddress)
        public
        onlyOwner
    {

        BattleInfo storage battle = battleInfo[_roomId];
        UserInfo storage user1 = userInfo[_roomId][battle.player1];
        UserInfo storage user2 = userInfo[_roomId][battle.player2];

        require(_winnerAddress != address(0) && (battle.player1 == _winnerAddress || battle.player2 == _winnerAddress), "Invalid Winner Address");
        require(
            battle.player1 != address(0) || battle.player2 != address(0),
            "Invalid players"
        );
        require(
            user1.xsVempLockStatus != false || user2.xsVempLockStatus != false,
            "Invalid users lock status"
        );
        require(battle.claimStatus != true, "Already claimed");

        battle.winnerAddress = _winnerAddress;

        address _loser = _winnerAddress == battle.player1
            ? battle.player2
            : battle.player1;
        if(_loser != address(0)) {
            playersForAirdrop.push(_loser);
        }
        loser[_roomId] = _loser;
        winners.push(battle.winnerAddress);
    }
}