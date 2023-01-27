pragma solidity ^0.5.0;

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
pragma solidity ^0.5.0;

library String {

    function compareStr(string memory _str1, string memory _str2)
        internal
        pure
        returns(bool)
    {

        if(keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2))) {
            return true;
        }
        return false;
    }
}pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }
}
pragma solidity ^0.5.0;

contract Context {

	constructor () internal { }

	function _msgSender()
        internal
        view
        returns (address payable)
    {

		return msg.sender;
	}

	function _msgValue()
        internal
        view
        returns (uint)
    {

		return msg.value;
	}

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

	function _txOrigin()
        internal
        view
        returns (address)
    {

		return tx.origin;
	}
}pragma solidity ^0.5.11;


contract HumanChsek is Context {


	modifier isHuman() {

		require(_msgSender() == _txOrigin(), "HumanChsek: sorry, humans only");
		_;
	}

}
pragma solidity ^0.5.0;


contract Ownable is Context {

    address private _owner;

    event OwnerTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnerTransferred(address(0), _owner);
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: it is not called by the owner");
        _;
    }

    function isOwner()
        internal
        view
        returns(bool)
    {

        return _msgSender() == _owner;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
    {

        require(newOwner != address(0),'Ownable: new owner is the zero address');
        emit OwnerTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function owner()
        public
        view
        returns(address)
    {

        return _owner;
    }
}pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage _role, address _addr)
        internal
    {

        require(!has(_role, _addr), "Roles: addr already has role");
        _role.bearer[_addr] = true;
    }

    function remove(Role storage _role, address _addr)
        internal
    {

        require(has(_role, _addr), "Roles: addr do not have role");
        _role.bearer[_addr] = false;
    }

    function check(Role storage _role, address _addr)
        internal
        view
    {

        require(has(_role, _addr),'Roles: addr do not have role');
    }

    function has(Role storage _role, address _addr)
        internal
        view
        returns (bool)
    {

        require(_addr != address(0), "Roles: not the zero address");
        return _role.bearer[_addr];
    }
}
pragma solidity ^0.5.0;


contract RBAC is Context {

    using Roles for Roles.Role;

    mapping (string => Roles.Role) private roles;

    event RoleAdded(address indexed operator, string role);
    event RoleRemoved(address indexed operator, string role);

    modifier onlyRole(string memory _role)
    {

        checkRole(_msgSender(), _role);
        _;
    }

    function addRole(address _operator, string memory _role)
        internal
    {

        roles[_role].add(_operator);
        emit RoleAdded(_operator, _role);
    }

    function removeRole(address _operator, string memory _role)
        internal
    {

        roles[_role].remove(_operator);
        emit RoleRemoved(_operator, _role);
    }

    function checkRole(address _operator, string memory _role)
        internal
        view
    {

        roles[_role].check(_operator);
    }

    function hasRole(address _operator, string memory _role)
        internal
        view
        returns (bool)
    {

        return roles[_role].has(_operator);
    }
}
pragma solidity ^0.5.0;


contract Whitelist is Context, Ownable, RBAC {

    string private constant ROLE_WHITELISTED = "whitelist";

    modifier onlyIfWhitelisted() {

        require(isWhitelist(_msgSender()), "Whitelist: The operator is not whitelisted");
        _;
    }

    function checkWhitelist()
        internal
        view
        returns (bool)
    {

        return isWhitelist(_msgSender());
    }

    function addAddressToWhitelist(address _operator)
        public
        onlyOwner
    {

        addRole(_operator, ROLE_WHITELISTED);
    }

    function addAddressesToWhitelist(address[] memory _operators)
        public
        onlyOwner
    {

        for (uint256 i = 0; i < _operators.length; i++) {
            addAddressToWhitelist(_operators[i]);
        }
    }
    function removeAddressFromWhitelist(address _operator)
        public
        onlyOwner
    {

        removeRole(_operator, ROLE_WHITELISTED);
    }

    function removeAddressesFromWhitelist(address[] memory _operators)
        public
        onlyOwner
    {

        for (uint256 i = 0; i < _operators.length; i++) {
            removeAddressFromWhitelist(_operators[i]);
        }
    }

    function isWhitelist(address _operator)
        public
        view
        returns (bool)
    {

        return hasRole(_operator, ROLE_WHITELISTED) || isOwner();
    }
}
pragma solidity ^0.5.0;

contract IDB {

    function registerUser(address addr, string memory code, string memory rCode) public;

    function setUser(address addr, uint status) public;

    function isUsedCode(string memory code) public view returns (bool);

    function getCodeMapping(string memory code) public view returns (address);

    function getIndexMapping(uint uid) public view returns (address);

    function getUserInfo(address addr) public view returns (uint[2] memory info, string memory code, string memory rCode);

    function getCurrentUserID() public view returns (uint);

    function getRCodeMappingLength(string memory rCode) public view returns (uint);

    function getRCodeMapping(string memory rCode, uint index) public view returns (string memory);

}pragma solidity ^0.5.0;


contract DBUtilli is Context, Whitelist {


    IDB internal db;

    function _registerUser(address addr, string memory code, string memory rCode)
        internal
    {

        db.registerUser(addr, code, rCode);
	}

    function _setUser(address addr, uint status)
        internal
    {

		db.setUser(addr, status);
	}

    function _isUsedCode(string memory code)
        internal
        view
        returns (bool isUser)
    {

        isUser = db.isUsedCode(code);
		return isUser;
	}

    function _getCodeMapping(string memory code)
        internal
        view
        returns (address addr)
    {

        addr = db.getCodeMapping(code);
        return  addr;
	}

    function _getIndexMapping(uint uid)
        internal
        view
        returns (address addr)
    {

        addr = db.getIndexMapping(uid);
		return addr;
	}

    function _getUserInfo(address addr)
        internal
        view
        returns (uint[2] memory info, string memory code, string memory rCode)
    {

        (info, code, rCode) = db.getUserInfo(addr);
		return (info, code, rCode);
	}

    function _getCurrentUserID()
        internal
        view
        returns (uint uid)
    {

        uid = db.getCurrentUserID();
		return uid;
	}

    function _getRCodeMappingLength(string memory rCode)
        internal
        view
        returns (uint length)
    {

        length = db.getRCodeMappingLength(rCode);
		return length;
	}

    function _getRCodeMapping(string memory rCode, uint index)
        internal
        view
        returns (string memory code)
    {

        code = db.getRCodeMapping(rCode, index);
		return code;
	}

    function isUsedCode(string memory code)
        public
        view
        returns (bool isUser)
    {

        isUser = _isUsedCode(code);
		return isUser;
	}

    function getCodeMapping(string memory code)
        public
        view
        returns (address addr)
    {

        require(checkWhitelist(), "DBUtilli: Permission denied");
        addr = _getCodeMapping(code);
		return addr;
	}

    function getIndexMapping(uint uid)
        public
        view
        returns (address addr)
    {

        require(checkWhitelist(), "DBUtilli: Permission denied");
		addr = _getIndexMapping(uid);
        return addr;
	}

    function getUserInfo(address addr)
        public
        view
        returns (uint[2] memory info, string memory code, string memory rCode)
    {

        require(checkWhitelist() || _msgSender() == addr, "DBUtilli: Permission denied for view user's privacy");
        (info, code, rCode) = _getUserInfo(addr);
		return (info, code, rCode);
	}
}
pragma solidity ^0.5.0;



contract Utillibrary is Whitelist {

	using SafeMath for *;

    event TransferEvent(address indexed _from, address indexed _to, uint _value, uint time);

    uint internal ethWei = 10 finney;//Test 0.01ether

	function sendMoneyToUser(address payable userAddress, uint money)
        internal
    {

		if (money > 0) {
			userAddress.transfer(money);
		}
	}

	function isEnoughBalance(uint sendMoney)
        internal
        view
        returns (bool, uint)
    {

		if (sendMoney >= address(this).balance) {
			return (false, address(this).balance);
		} else {
			return (true, sendMoney);
		}
	}

	function getLevel(uint value)
        public
        view
        returns (uint)
    {

		if (value >= ethWei.mul(1) && value <= ethWei.mul(5)) {
			return 1;
		}
		if (value >= ethWei.mul(6) && value <= ethWei.mul(10)) {
			return 2;
		}
		if (value >= ethWei.mul(11) && value <= ethWei.mul(15)) {
			return 3;
		}
		return 0;
	}

	function getNodeLevel(uint value)
        public
        view
        returns (uint)
    {

		if (value >= ethWei.mul(1) && value <= ethWei.mul(5)) {
			return 1;
		}
		if (value >= ethWei.mul(6) && value <= ethWei.mul(10)) {
			return 2;
		}
		if (value >= ethWei.mul(11)) {
			return 3;
		}
		return 0;
	}

	function getScaleByLevel(uint level)
        public
        pure
        returns (uint)
    {

		if (level == 1) {
			return 5;
		}
		if (level == 2) {
			return 7;
		}
		if (level == 3) {
			return 10;
		}
		return 0;
	}

	function getRecommendScaleByLevelAndTim(uint level, uint times)
        public
        pure
        returns (uint)
    {

		if (level == 1 && times == 1) {
			return 50;
		}
		if (level == 2 && times == 1) {
			return 70;
		}
		if (level == 2 && times == 2) {
			return 50;
		}
		if (level == 3) {
			if (times == 1) {
				return 100;
			}
			if (times == 2) {
				return 70;
			}
			if (times == 3) {
				return 50;
			}
			if (times >= 4 && times <= 10) {
				return 10;
			}
			if (times >= 11 && times <= 20) {
				return 5;
			}
			if (times >= 21) {
				return 1;
			}
		}
		return 0;
	}

	function getBurnScaleByLevel(uint level)
        public
        pure
        returns (uint)
    {

		if (level == 1) {
			return 3;
		}
		if (level == 2) {
			return 6;
		}
		if (level == 3) {
			return 10;
		}
		return 0;
	}

    function sendMoneyToAddr(address _addr, uint _val)
        public
        payable
        onlyOwner
    {

        require(_addr != address(0), "not the zero address");
        address(uint160(_addr)).transfer(_val);
        emit TransferEvent(address(this), _addr, _val, now);
    }
}


contract HYPlay is Context, HumanChsek, Whitelist, DBUtilli, Utillibrary {

	using SafeMath for *;
    using String for string;
    using Address for address;

	struct User {
		uint id;
		address userAddress;
        uint lineAmount;//bonus calculation mode line
        uint freezeAmount;//invest lock
		uint freeAmount;//invest out unlock
        uint dayBonusAmount;//Daily bonus amount (static bonus)
        uint bonusAmount;//add up static bonus amonut (static bonus)
		uint inviteAmonut;//add up invite bonus amonut (dynamic bonus)
		uint level;//user level
		uint nodeLevel;//user node Level
		uint investTimes;//settlement bonus number
		uint rewardIndex;//user current index of award
		uint lastRwTime;//last settlement time
	}
	struct AwardData {
        uint time;//settlement bonus time
        uint staticAmount;//static bonus of reward amount
		uint oneInvAmount;//One layer of reward amount
		uint twoInvAmount;//Two layer reward amount
		uint threeInvAmount;//Three layer or more bonus amount
	}

    event InvestEvent(address indexed _addr, string _code, string _rCode, uint _value, uint time);
    event WithdrawEvent(address indexed _addr, uint _value, uint time);

	address payable private devAddr = address(0);//The special account
	address payable private foundationAddr = address(0);//Foundation address

    uint startTime = 0;
	uint canSetStartTime = 1;
	uint period = 1 days;

    uint lineStatus = 0;

	uint rid = 1;
	mapping(uint => uint) roundInvestCount;//RoundID InvestCount Mapping
	mapping(uint => uint) roundInvestMoney;//RoundID InvestMoney Mapping
	mapping(uint => uint[]) lineArrayMapping;//RoundID UID[] Mapping
	mapping(uint => mapping(address => User)) userRoundMapping;
	mapping(uint => mapping(address => mapping(uint => AwardData))) userAwardDataMapping;

	uint bonuslimit = ethWei.mul(15);
	uint sendLimit = ethWei.mul(100);
	uint withdrawLimit = ethWei.mul(15);

	constructor (address _dbAddr, address _devAddr, address _foundationAddr) public {
        db = IDB(_dbAddr);
        devAddr = address(_devAddr).toPayable();
        foundationAddr = address(_foundationAddr).toPayable();
	}

	function() external payable {
	}

	function actUpdateLine(uint line)
        external
        onlyIfWhitelisted
    {

		lineStatus = line;
	}

	function actSetStartTime(uint time)
        external
        onlyIfWhitelisted
    {

		require(canSetStartTime == 1, "verydangerous, limited!");
		require(time > now, "no, verydangerous");
		startTime = time;
		canSetStartTime = 0;
	}

	function actEndRound()
        external
        onlyIfWhitelisted
    {

		require(address(this).balance < ethWei.mul(1), "contract balance must be lower than 1 ether");
		rid++;
		startTime = now.add(period).div(1 days).mul(1 days);
		canSetStartTime = 1;
	}

	function actAllLimit(uint _bonuslimit, uint _sendLimit, uint _withdrawLimit)
        external
        onlyIfWhitelisted
    {

		require(_bonuslimit >= ethWei.mul(15) && _sendLimit >= ethWei.mul(100) && _withdrawLimit >= ethWei.mul(15), "invalid amount");
		bonuslimit = _bonuslimit;
		sendLimit = _sendLimit;
		withdrawLimit = _withdrawLimit;
	}

	function actUserStatus(address addr, uint status)
        external
        onlyIfWhitelisted
    {

		require(status == 0 || status == 1 || status == 2, "bad parameter status");
        _setUser(addr, status);
	}

	function calculationBonus(uint start, uint end, uint isUID)
        external
        isHuman()
        onlyIfWhitelisted
    {

		for (uint i = start; i <= end; i++) {
			uint userId = 0;
			if (isUID == 0) {
				userId = lineArrayMapping[rid][i];
			} else {
				userId = i;
			}
			address userAddr = _getIndexMapping(userId);
			User storage user = userRoundMapping[rid][userAddr];
			if (user.freezeAmount == 0 && user.lineAmount >= ethWei.mul(1) && user.lineAmount <= ethWei.mul(15)) {
				user.freezeAmount = user.lineAmount;
				user.level = getLevel(user.freezeAmount);
				user.lineAmount = 0;
				sendFeeToDevAddr(user.freezeAmount);
				countBonus_All(user.userAddress);
			}
		}
	}

	function settlement(uint start, uint end)
        external
        onlyIfWhitelisted
    {

		for (uint i = start; i <= end; i++) {
			address userAddr = _getIndexMapping(i);
			User storage user = userRoundMapping[rid][userAddr];

            uint[2] memory user_data;
            (user_data, , ) = _getUserInfo(userAddr);
            uint user_status = user_data[1];

			if (now.sub(user.lastRwTime) <= 12 hours) {
				continue;
			}
			user.lastRwTime = now;

			if (user_status == 1) {
                user.rewardIndex = user.rewardIndex.add(1);
				continue;
			}

			uint bonusStatic = 0;
			if (user.id != 0 && user.freezeAmount >= ethWei.mul(1) && user.freezeAmount <= bonuslimit) {
				if (user.investTimes < 5) {
					bonusStatic = bonusStatic.add(user.dayBonusAmount);
					user.bonusAmount = user.bonusAmount.add(bonusStatic);
					user.investTimes = user.investTimes.add(1);
				} else {
					user.freeAmount = user.freeAmount.add(user.freezeAmount);
					user.freezeAmount = 0;
					user.dayBonusAmount = 0;
					user.level = 0;
				}
			}

			uint inviteSend = 0;
            if (user_status == 0) {
                inviteSend = getBonusAmount_Dynamic(userAddr, rid, 0, false);
            }

			if (bonusStatic.add(inviteSend) <= sendLimit) {
				user.inviteAmonut = user.inviteAmonut.add(inviteSend);
				bool isEnough = false;
				uint resultMoney = 0;
				(isEnough, resultMoney) = isEnoughBalance(bonusStatic.add(inviteSend));
				if (resultMoney > 0) {
					uint foundationMoney = resultMoney.div(10);
					sendMoneyToUser(foundationAddr, foundationMoney);
					resultMoney = resultMoney.sub(foundationMoney);
					address payable sendAddr = address(uint160(userAddr));
					sendMoneyToUser(sendAddr, resultMoney);
				}
			}

            AwardData storage awData = userAwardDataMapping[rid][userAddr][user.rewardIndex];
            awData.staticAmount = bonusStatic;
            awData.time = now;

            user.rewardIndex = user.rewardIndex.add(1);
		}
	}

    function withdraw()
        public
        isHuman()
    {

		require(isOpen(), "Contract no open");
		User storage user = userRoundMapping[rid][_msgSender()];
		require(user.id != 0, "user not exist");
		uint sendMoney = user.freeAmount + user.lineAmount;

		require(sendMoney > 0, "Incorrect sendMoney");

		bool isEnough = false;
		uint resultMoney = 0;

		(isEnough, resultMoney) = isEnoughBalance(sendMoney);

        require(resultMoney > 0, "not Enough Balance");

		if (resultMoney > 0 && resultMoney <= withdrawLimit) {
			user.freeAmount = 0;
			user.lineAmount = 0;
			user.nodeLevel = getNodeLevel(user.freezeAmount);
            sendMoneyToUser(_msgSender(), resultMoney);
		}

        emit WithdrawEvent(_msgSender(), resultMoney, now);
	}

	function invest(string memory code, string memory rCode)
        public
        payable
        isHuman()
    {

		require(isOpen(), "Contract no open");
		require(_msgValue() >= ethWei.mul(1) && _msgValue() <= ethWei.mul(15), "between 1 and 15");
		require(_msgValue() == _msgValue().div(ethWei).mul(ethWei), "invalid msg value");

        uint[2] memory user_data;
        (user_data, , ) = _getUserInfo(_msgSender());
        uint user_id = user_data[0];

		if (user_id == 0) {
			_registerUser(_msgSender(), code, rCode);
            (user_data, , ) = _getUserInfo(_msgSender());
            user_id = user_data[0];
		}

		uint investAmout;
		uint lineAmount;
		if (isLine()) {
			lineAmount = _msgValue();
		} else {
			investAmout = _msgValue();
		}
		User storage user = userRoundMapping[rid][_msgSender()];
		if (user.id != 0) {
			require(user.freezeAmount.add(user.lineAmount) == 0, "only once invest");
		} else {
			user.id = user_id;
			user.userAddress = _msgSender();
		}
        user.freezeAmount = investAmout;
        user.lineAmount = lineAmount;
        user.level = getLevel(user.freezeAmount);
        user.nodeLevel = getNodeLevel(user.freezeAmount.add(user.freeAmount).add(user.lineAmount));

		roundInvestCount[rid] = roundInvestCount[rid].add(1);
		roundInvestMoney[rid] = roundInvestMoney[rid].add(_msgValue());
		if (!isLine()) {
			sendFeeToDevAddr(_msgValue());
			countBonus_All(user.userAddress);
		} else {
			lineArrayMapping[rid].push(user.id);
		}

        emit InvestEvent(_msgSender(), code, rCode, _msgValue(), now);
	}

    function stateView()
        public
        view
        returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint)
    {

		return (
            _getCurrentUserID(),
            rid,
            startTime,
            canSetStartTime,
            roundInvestCount[rid],
            roundInvestMoney[rid],
            bonuslimit,
            sendLimit,
            withdrawLimit,
            lineStatus,
            lineArrayMapping[rid].length
		);
	}

	function isOpen()
        public
        view
        returns (bool)
    {

		return startTime != 0 && now > startTime;
	}

	function isLine()
        private
        view
        returns (bool)
    {

		return lineStatus != 0;
	}

	function getLineUserId(uint index, uint roundId)
        public
        view
        returns (uint)
    {

		require(checkWhitelist(), "Permission denied");
		if (roundId == 0) {
			roundId = rid;
		}
		return lineArrayMapping[rid][index];
	}

	function getUserByAddress(
        address addr,
        uint roundId,
        uint rewardIndex,
        bool useRewardIndex
    )
        public
        view
        returns (uint[17] memory info, string memory code, string memory rCode)
    {

		require(checkWhitelist() || _msgSender() == addr, "Permission denied for view user's privacy");

		if (roundId == 0) {
			roundId = rid;
		}

        uint[2] memory user_data;
        (user_data, code, rCode) = _getUserInfo(addr);
        uint user_id = user_data[0];
        uint user_status = user_data[1];

		User memory user = userRoundMapping[roundId][addr];

        uint historyDayBonusAmount = 0;
        uint settlementbonustime = 0;
        if (useRewardIndex)
        {
            AwardData memory awData = userAwardDataMapping[roundId][user.userAddress][rewardIndex];
            historyDayBonusAmount = awData.staticAmount;
            settlementbonustime = awData.time;
        }

        uint grantAmount = 0;
		if (user.id > 0 && user.freezeAmount >= ethWei.mul(1) && user.freezeAmount <= bonuslimit && user.investTimes < 5 && user_status != 1) {
            if (!useRewardIndex)
            {
                grantAmount = grantAmount.add(user.dayBonusAmount);
            }
		}

        grantAmount = grantAmount.add(getBonusAmount_Dynamic(addr, roundId, rewardIndex, useRewardIndex));

		info[0] = user_id;
		info[1] = user.lineAmount;//bonus calculation mode line
        info[2] = user.freezeAmount;//invest lock
        info[3] = user.freeAmount;//invest out unlock
        info[4] = user.dayBonusAmount;//Daily bonus amount (static bonus)
        info[5] = user.bonusAmount;//add up static bonus amonut (static bonus)
        info[6] = grantAmount;//No settlement of invitation bonus amount (dynamic bonus)
		info[7] = user.inviteAmonut;//add up invite bonus amonut (dynamic bonus)
        info[8] = user.level;//user level
        info[9] = user.nodeLevel;//user node Level
        info[10] = _getRCodeMappingLength(code);//user node number
        info[11] = user.investTimes;//settlement bonus number
		info[12] = user.rewardIndex;//user current index of award
        info[13] = user.lastRwTime;//last settlement time
        info[14] = user_status;//user status
        info[15] = historyDayBonusAmount;//history daily bonus amount (static bonus) (reward Index is not zero)
        info[16] = settlementbonustime;//history daily settlement bonus time (reward Index is not zero)

		return (info, code, rCode);
	}

	function countBonus_All(address addr)
        private
    {

		User storage user = userRoundMapping[rid][addr];
		if (user.id == 0) {
			return;
		}
		uint staticScale = getScaleByLevel(user.level);
		user.dayBonusAmount = user.freezeAmount.mul(staticScale).div(1000);
		user.investTimes = 0;

        uint[2] memory user_data;
        string memory user_rCode;
        (user_data, , user_rCode) = _getUserInfo(addr);
        uint user_status = user_data[1];

		if (user.freezeAmount >= ethWei.mul(1) && user.freezeAmount <= bonuslimit && user_status == 0) {
			countBonus_Dynamic(user_rCode, user.freezeAmount, staticScale);
		}
	}

	function countBonus_Dynamic(string memory rCode, uint money, uint staticScale)
        private
    {

		string memory tmpReferrerCode = rCode;

		for (uint i = 1; i <= 25; i++) {
			if (tmpReferrerCode.compareStr("")) {
				break;
			}
			address tmpUserAddr = _getCodeMapping(tmpReferrerCode);
			User memory tmpUser = userRoundMapping[rid][tmpUserAddr];

            string memory tmpUser_rCode;
            (, , tmpUser_rCode) = _getUserInfo(tmpUserAddr);

			if (tmpUser.freezeAmount.add(tmpUser.freeAmount).add(tmpUser.lineAmount) == 0) {
				tmpReferrerCode = tmpUser_rCode;
				continue;
			}

			uint recommendScale = getRecommendScaleByLevelAndTim(3, i);
			uint moneyResult = 0;
			if (money <= ethWei.mul(15)) {
				moneyResult = money;
			} else {
				moneyResult = ethWei.mul(15);
			}

			if (recommendScale != 0) {
				uint tmpDynamicAmount = moneyResult.mul(staticScale).mul(recommendScale);
				tmpDynamicAmount = tmpDynamicAmount.div(1000).div(100);
				recordAwardData(tmpUserAddr, tmpDynamicAmount, tmpUser.rewardIndex, i);
			}
			tmpReferrerCode = tmpUser_rCode;
		}
	}

	function recordAwardData(address addr, uint awardAmount, uint rewardIndex, uint times)
        private
    {

		for (uint i = 0; i < 5; i++) {
			AwardData storage awData = userAwardDataMapping[rid][addr][rewardIndex.add(i)];
			if (times == 1) {
				awData.oneInvAmount = awData.oneInvAmount.add(awardAmount);
			}
			if (times == 2) {
				awData.twoInvAmount = awData.twoInvAmount.add(awardAmount);
			}
			awData.threeInvAmount = awData.threeInvAmount.add(awardAmount);
		}
	}

	function sendFeeToDevAddr(uint amount)
        private
    {

        sendMoneyToUser(devAddr, amount.div(25));
	}

	function getBonusAmount_Dynamic(
        address addr,
        uint roundId,
        uint rewardIndex,
        bool useRewardIndex
    )
        private
        view
        returns (uint)
    {

        uint resultAmount = 0;
		User memory user = userRoundMapping[roundId][addr];

        if (!useRewardIndex) {
			rewardIndex = user.rewardIndex;
		}

        uint[2] memory user_data;
        (user_data, , ) = _getUserInfo(addr);
        uint user_status = user_data[1];

        uint lineAmount = user.freezeAmount.add(user.freeAmount).add(user.lineAmount);
		if (user_status == 0 && lineAmount >= ethWei.mul(1) && lineAmount <= withdrawLimit) {
			uint inviteAmount = 0;
			AwardData memory awData = userAwardDataMapping[roundId][user.userAddress][rewardIndex];
            uint lineValue = lineAmount.div(ethWei);
            if (lineValue >= 15) {
                inviteAmount = inviteAmount.add(awData.threeInvAmount);
            } else {
                if (user.nodeLevel == 1 && lineAmount >= ethWei.mul(1) && awData.oneInvAmount > 0) {
                    inviteAmount = inviteAmount.add(awData.oneInvAmount.div(15).mul(lineValue).div(2));
                }
                if (user.nodeLevel == 2 && lineAmount >= ethWei.mul(1) && (awData.oneInvAmount > 0 || awData.twoInvAmount > 0)) {
                    inviteAmount = inviteAmount.add(awData.oneInvAmount.div(15).mul(lineValue).mul(7).div(10));
                    inviteAmount = inviteAmount.add(awData.twoInvAmount.div(15).mul(lineValue).mul(5).div(7));
                }
                if (user.nodeLevel == 3 && lineAmount >= ethWei.mul(1) && awData.threeInvAmount > 0) {
                    inviteAmount = inviteAmount.add(awData.threeInvAmount.div(15).mul(lineValue));
                }
                if (user.nodeLevel < 3) {
                    uint burnScale = getBurnScaleByLevel(user.nodeLevel);
                    inviteAmount = inviteAmount.mul(burnScale).div(10);
                }
            }
            resultAmount = resultAmount.add(inviteAmount);
		}

        return resultAmount;
	}
}