
pragma solidity ^0.5.0;
contract UtilFSC {


    uint ethWei = 1 ether;
    function getLevel(uint value, uint _type) public view returns (uint) {

        if (value >= 1 * ethWei && value <= 3 * ethWei) return 1;
        if (value >= 4 * ethWei && value <= 6 * ethWei) return 2;
        if (_type == 1 && value >= 7 * ethWei) return 3;
        else if (_type == 2 && value >= 7 * ethWei && value <= 10 * ethWei) return 3;
        return 0;
    }
    function getScByLevel(uint level) public pure returns (uint) {

        if (level == 1) return 6;
        if (level == 2) return 8;
        if (level == 3) return 10;
        return 0;
    }
    function getFireScByLevel(uint level) public pure returns (uint) {

        if (level == 1) return 3;
        if (level == 2) return 6;
        if (level == 3) return 10;
        return 0;
    }

    function getRecommendScaleByLevelAndTim(uint level, uint times) public pure returns (uint){

        if (level == 1 && times == 1) return 100;
        if (level == 2 && times == 1) return 80;
        if (level == 2 && times == 2) return 30;
        if (level == 3) {
            if (times == 1) return 30;
            if (times == 2) return 20;
            if (times == 3) return 10;
            if (times >= 4 && times <= 10) return 5;
            if (times >= 11) return 1;
        }
        return 0;
    }

    function compareStr(string memory _str, string memory str) public pure returns (bool) {

        if (keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str))) return true;
        return false;
    }
}

contract Context {


    constructor() internal {}

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }
}

contract Ownable is Context {


    address private _owner;

    constructor () internal {
        _owner = _msgSender();
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }
}

library Roles {


    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract WhitelistAdminRole is Context, Ownable {


    using Roles for Roles.Role;

    Roles.Role private _whitelistAdmins;

    constructor () internal {
    }

    modifier onlyWhitelistAdmin() {

        require(isWhitelistAdmin(_msgSender()) || isOwner(), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account) || isOwner();
    }

    function addWhitelistAdmin(address account) public onlyOwner {

        _whitelistAdmins.add(account);
    }

    function removeWhitelistAdmin(address account) public onlyOwner {

        _whitelistAdmins.remove(account);
    }
}

contract FSC is UtilFSC, WhitelistAdminRole {


    using SafeMath for *;
    uint ethWei = 1 ether;
    address payable private devAddr = address(0x445042C0e21855cC7A32299302f7F1085a5d447C);
    address payable private comfortAddr = address(0xe0d2beD8fddcFC27962baa3450e77430163f37E7);
    address payable private feeAddr = address(0x68D1219A571466e2ab346A43A1dcA986201b4584);
    uint public currBalance = 0 ether;
    uint curr = 0 ether;
    uint _time = now;

    struct User {
        uint id;
        address userAddress;
        uint freeAmount;
        uint freezeAmount;
        uint lineAmount;
        uint inviteAmonut;
        uint dayBonusAmount;
        uint bonusAmount;
        uint level;
        uint lineLevel;
        uint resTime;
        uint investTimes;
        string inviteCode;
        string beCode;
        uint rewardIndex;
        uint lastRwTime;
        uint bigCycle;
    }

    struct UserGlobal {
        uint id;
        address userAddress;
        string inviteCode;
        string beCode;
        uint status;
    }

    struct AwardData {
        uint oneInvAmount;
        uint twoInvAmount;
        uint threeInvAmount;
    }

    uint lineStatus = 0;
    mapping(uint => uint) rInvestCount;
    mapping(uint => uint) rInvestMoney;
    uint period = 1 days;
    uint uid = 0;
    uint rid = 1;
    mapping(uint => uint[]) lineArrayMapping;
    mapping(uint => mapping(address => User)) userRoundMapping;
    mapping(address => UserGlobal) userMapping;
    mapping(string => address) addressMapping;
    mapping(uint => address) indexMapping;
    mapping(uint => mapping(address => mapping(uint => AwardData))) userAwardDataMapping;
    uint bonuslimit = 10 ether;
    uint sendLimit = 100 ether;
    uint withdrawLimit = 10 ether;
    uint canImport = 1;
    uint smallCycle = 5;

    uint jiangeTime = 12 hours;

    modifier isHuman() {

        address addr = msg.sender;
        uint codeLength;
        assembly {codeLength := extcodesize(addr)}
        require(codeLength == 0, "sorry humans only");
        require(tx.origin == msg.sender, "sorry, humans only");
        _;
    }

    constructor () public {
    }

    function() external payable {
    }

    function updateLine(uint line) external onlyWhitelistAdmin {

        lineStatus = line;
    }

    function isLine() private view returns (bool) {

        return lineStatus != 0;
    }

    function actAllLimit(uint bonusLi, uint sendLi, uint withdrawLi) external onlyOwner {

        require(bonusLi >= 15 ether && sendLi >= 100 ether && withdrawLi >= 15 ether, "invalid amount");
        bonuslimit = bonusLi;
        sendLimit = sendLi;
        withdrawLimit = withdrawLi;
    }

    function stopImport() external onlyOwner {

        canImport = 0;
    }

    function actUserStatus(address addr, uint status) external onlyWhitelistAdmin {

        require(status == 0 || status == 1 || status == 2, "bad parameter status");
        UserGlobal storage userGlobal = userMapping[addr];
        userGlobal.status = status;
    }
    function repeatPldge() public {


        User storage user = userRoundMapping[rid][msg.sender];
        require(user.investTimes >= smallCycle, "investTimes must more than 5");
        user.bigCycle += 1;
        require(user.id != 0, "user not exist");
        uint resultMoney = user.freeAmount + user.lineAmount;

        user.freeAmount = 0;
        user.lineAmount = 0;
        user.lineLevel = getLevel(user.freezeAmount, 1);

        require(resultMoney >= 1 * ethWei && resultMoney <= 10 * ethWei, "between 1 and 10");

        uint investAmout;
        uint lineAmount;
        if (isLine()) lineAmount = resultMoney;
        else investAmout = resultMoney;
        require(user.freezeAmount.add(user.lineAmount) == 0, "only once invest");
        user.freezeAmount = investAmout;
        user.lineAmount = lineAmount;
        user.level = getLevel(user.freezeAmount, 2);
        user.lineLevel = getLevel(user.freezeAmount.add(user.freeAmount).add(user.lineAmount), 1);

        rInvestCount[rid] = rInvestCount[rid].add(1);
        rInvestMoney[rid] = rInvestMoney[rid].add(resultMoney);
        if (!isLine()) {
            sendFeetoAdmin(resultMoney);
            countBonus(user.userAddress);
        } else lineArrayMapping[rid].push(user.id);


    }

    function exit(string memory inviteCode, string memory beCode) public isHuman() payable {


        require(msg.value >= 1 * ethWei && msg.value <= 10 * ethWei, "between 1 and 10");
        require(msg.value == msg.value.div(ethWei).mul(ethWei), "invalid msg value");

        UserGlobal storage userGlobal = userMapping[msg.sender];
        if (userGlobal.id == 0) {
            require(!compareStr(inviteCode, "") && bytes(inviteCode).length == 6, "invalid invite code");
            address beCodeAddr = addressMapping[beCode];
            require(isUsed(beCode), "beCode not exist");
            require(beCodeAddr != msg.sender, "beCodeAddr can't be self");
            require(!isUsed(inviteCode), "invite code is used");
            registerUser(msg.sender, inviteCode, beCode);
        }
        uint investAmout;
        uint lineAmount;
        if (isLine()) lineAmount = msg.value;
        else investAmout = msg.value;
        User storage user = userRoundMapping[rid][msg.sender];
        if (user.id != 0) {
            require(user.freezeAmount.add(user.lineAmount) == 0, "only once invest");
            user.freezeAmount = investAmout;
            user.lineAmount = lineAmount;
            user.level = getLevel(user.freezeAmount, 2);
            user.lineLevel = getLevel(user.freezeAmount.add(user.freeAmount).add(user.lineAmount), 1);
        } else {
            user.id = userGlobal.id;
            user.userAddress = msg.sender;
            user.freezeAmount = investAmout;
            user.level = getLevel(investAmout, 2);
            user.lineAmount = lineAmount;
            user.lineLevel = getLevel(user.freezeAmount.add(user.freeAmount).add(user.lineAmount), 1);
            user.inviteCode = userGlobal.inviteCode;
            user.beCode = userGlobal.beCode;
        }

        rInvestCount[rid] = rInvestCount[rid].add(1);
        rInvestMoney[rid] = rInvestMoney[rid].add(msg.value);
        if (!isLine()) {
            sendFeetoAdmin(msg.value);
            countBonus(user.userAddress);
        } else lineArrayMapping[rid].push(user.id);
    }

    function importGlobal(address addr, string calldata inviteCode, string calldata beCode) external onlyWhitelistAdmin {

        require(canImport == 1, "import stopped");
        UserGlobal storage user = userMapping[addr];
        require(user.id == 0, "user already exists");
        require(!compareStr(inviteCode, ""), "empty invite code");
        if (uid != 0) require(!compareStr(beCode, ""), "empty beCode");
        address beCodeAddr = addressMapping[beCode];
        require(beCodeAddr != addr, "beCodeAddr can't be self");
        require(!isUsed(inviteCode), "invite code is used");

        registerUser(addr, inviteCode, beCode);
    }

    function helloworld(uint start, uint end, uint isUser) external onlyWhitelistAdmin {

        for (uint i = start; i <= end; i++) {
            uint userId = 0;
            if (isUser == 0) userId = lineArrayMapping[rid][i];
            else userId = i;
            address userAddr = indexMapping[userId];
            User storage user = userRoundMapping[rid][userAddr];
            if (user.freezeAmount == 0 && user.lineAmount >= 1 ether && user.lineAmount <= 10 ether) {
                user.freezeAmount = user.lineAmount;
                user.level = getLevel(user.freezeAmount, 2);
                user.lineAmount = 0;
                sendFeetoAdmin(user.freezeAmount);
                countBonus(user.userAddress);
            }
        }
    }

    function countBonus(address userAddr) private {

        User storage user = userRoundMapping[rid][userAddr];
        if (user.id == 0) return;
        uint scale = getScByLevel(user.level);
        user.dayBonusAmount = user.freezeAmount.mul(scale).div(1000);
        user.investTimes = 0;
        UserGlobal memory userGlobal = userMapping[userAddr];
        if (user.freezeAmount >= 1 ether && user.freezeAmount <= bonuslimit && userGlobal.status == 0) getaway(user.beCode, user.freezeAmount, scale);

    }

    function getaway(string memory beCode, uint money, uint shareSc) private {

        string memory tmpReferrer = beCode;

        for (uint i = 1; i <= 25; i++) {
            if (compareStr(tmpReferrer, "")) break;
            address tmpUserAddr = addressMapping[tmpReferrer];
            UserGlobal storage userGlobal = userMapping[tmpUserAddr];
            User storage calUser = userRoundMapping[rid][tmpUserAddr];

            if (calUser.freezeAmount.add(calUser.freeAmount).add(calUser.lineAmount) == 0) {
                tmpReferrer = userGlobal.beCode;
                continue;
            }

            uint recommendSc = getRecommendScaleByLevelAndTim(3, i);
            uint moneyResult = 0;
            if (money <= 10 ether) moneyResult = money;
            else moneyResult = 10 ether;

            if (recommendSc != 0) {
                uint tmpDynamicAmount = moneyResult.mul(shareSc).mul(recommendSc);
                tmpDynamicAmount = tmpDynamicAmount.div(1000).div(100);
                earneth(userGlobal.userAddress, tmpDynamicAmount, calUser.rewardIndex, i);
            }
            tmpReferrer = userGlobal.beCode;
        }
    }

    function earneth(address userAddr, uint dayInvAmount, uint rewardIndex, uint times) private {

        for (uint i = 0; i < smallCycle; i++) {
            AwardData storage awData = userAwardDataMapping[rid][userAddr][rewardIndex.add(i)];
            if (times == 1) awData.oneInvAmount += dayInvAmount;
            if (times == 2) awData.twoInvAmount += dayInvAmount;
            awData.threeInvAmount += dayInvAmount;
        }
    }

    function happy() public isHuman() {


        User storage user = userRoundMapping[rid][msg.sender];
        require(user.id != 0, "user not exist");
        uint sendMoney = user.freeAmount + user.lineAmount;

        bool isEnough = false;
        uint resultMoney = 0;
        uint resultMoney1 = 0;
        (isEnough, resultMoney) = isEnoughBalance(sendMoney);
        if (user.bigCycle < 10) resultMoney1 = resultMoney.mul(9).div(10);
        if (resultMoney1 > 0 && resultMoney1 <= withdrawLimit) {
            sendMoneyToUser(msg.sender, resultMoney1);
            user.freeAmount = 0;
            user.lineAmount = 0;
            user.bigCycle = 0;
            user.lineLevel = getLevel(user.freezeAmount, 1);
        }
        if (user.bigCycle < 10) sendMoneyToUser(feeAddr, resultMoney.mul(1).div(10));
    }

    function christmas(uint start, uint end) external onlyWhitelistAdmin {


        if (_time - now > jiangeTime) {
            if (address(this).balance > curr) currBalance = address(this).balance.sub(curr);
            else currBalance = 0 ether;
            curr = address(this).balance;
        }
        for (uint i = start; i <= end; i++) {
            address userAddr = indexMapping[i];
            User storage user = userRoundMapping[rid][userAddr];
            UserGlobal memory userGlobal = userMapping[userAddr];
            if (now.sub(user.lastRwTime) <= jiangeTime) {
                continue;
            }
            uint bonusSend = 0;
            if (user.level > 2) {
                uint inviteSendQ = 0;
                if (user.bigCycle >= 10 && user.bigCycle < 20) inviteSendQ = currBalance.div(100);
                else if (user.bigCycle >= 20 && user.bigCycle < 30) inviteSendQ = currBalance.div(50);
                else if (user.bigCycle >= 30) inviteSendQ = currBalance.div(100).mul(3);


                bool isEnough = false;
                uint resultMoneyQ = 0;
                (isEnough, resultMoneyQ) = isEnoughBalance(bonusSend.add(inviteSendQ));
                if (resultMoneyQ > 0) {
                    address payable sendAddr = address(uint160(userAddr));
                    sendMoneyToUser(sendAddr, resultMoneyQ);
                }
            }
            user.lastRwTime = now;
            if (userGlobal.status == 1) {
                user.rewardIndex = user.rewardIndex.add(1);
                continue;
            }

            if (user.id != 0 && user.freezeAmount >= 1 ether && user.freezeAmount <= bonuslimit) {
                if (user.investTimes < smallCycle) {
                    bonusSend += user.dayBonusAmount;
                    user.bonusAmount = user.bonusAmount.add(bonusSend);
                    user.investTimes = user.investTimes.add(1);
                } else {
                    user.freeAmount = user.freeAmount.add(user.freezeAmount);
                    user.freezeAmount = 0;
                    user.dayBonusAmount = 0;
                    user.level = 0;
                }
            }
            uint lineAmount = user.freezeAmount.add(user.freeAmount).add(user.lineAmount);
            if (lineAmount < 1 ether || lineAmount > withdrawLimit) {
                user.rewardIndex = user.rewardIndex.add(1);
                continue;
            }
            uint inviteSend = 0;
            if (userGlobal.status == 0) {
                AwardData memory awData = userAwardDataMapping[rid][userAddr][user.rewardIndex];
                user.rewardIndex = user.rewardIndex.add(1);
                uint lineValue = lineAmount.div(ethWei);
                if (lineValue >= 15) {
                    inviteSend += awData.threeInvAmount;
                } else {
                    if (user.lineLevel == 1 && lineAmount >= 1 ether && awData.oneInvAmount > 0) inviteSend += awData.oneInvAmount.div(15).mul(lineValue).div(2);

                    if (user.lineLevel == 2 && lineAmount >= 6 ether && (awData.oneInvAmount > 0 || awData.twoInvAmount > 0)) {
                        inviteSend += awData.oneInvAmount.div(15).mul(lineValue).mul(7).div(10);
                        inviteSend += awData.twoInvAmount.div(15).mul(lineValue).mul(5).div(7);
                    }
                    if (user.lineLevel == 3 && lineAmount >= 11 ether && awData.threeInvAmount > 0) inviteSend += awData.threeInvAmount.div(15).mul(lineValue);

                    if (user.lineLevel < 3) {
                        uint fireSc = getFireScByLevel(user.lineLevel);
                        inviteSend = inviteSend.mul(fireSc).div(10);
                    }
                }
            } else if (userGlobal.status == 2) user.rewardIndex = user.rewardIndex.add(1);

            if (bonusSend.add(inviteSend) <= sendLimit) {
                user.inviteAmonut = user.inviteAmonut.add(inviteSend);
                bool isEnough = false;
                uint resultMoney = 0;
                (isEnough, resultMoney) = isEnoughBalance(bonusSend.add(inviteSend));
                if (resultMoney > 0) {
                    uint confortMoney = resultMoney.div(10);
                    sendMoneyToUser(comfortAddr, confortMoney);
                    resultMoney = resultMoney.sub(confortMoney);
                    address payable sendAddr = address(uint160(userAddr));
                    sendMoneyToUser(sendAddr, resultMoney);
                }
            }

        }

        _time = now;
    }

    function isEnoughBalance(uint sendMoney) private view returns (bool, uint){

        if (sendMoney >= address(this).balance) return (false, address(this).balance);
        else return (true, sendMoney);
    }
    function sendFeetoAdmin(uint amount) private {

        devAddr.transfer(amount.div(20));
    }
    function sendMoneyToUser(address payable userAddress, uint money) private {

        if (money > 0) userAddress.transfer(money);
    }

    function isUsed(string memory code) public view returns (bool) {

        address addr = addressMapping[code];
        return uint(addr) != 0;
    }

    function getUserAddressByCode(string memory code) public view returns (address) {

        require(isWhitelistAdmin(msg.sender), "Permission denied");
        return addressMapping[code];
    }

    function registerUser(address addr, string memory inviteCode, string memory beCode) private {

        UserGlobal storage userGlobal = userMapping[addr];
        uid++;
        userGlobal.id = uid;
        userGlobal.userAddress = addr;
        userGlobal.inviteCode = inviteCode;
        userGlobal.beCode = beCode;

        addressMapping[inviteCode] = addr;
        indexMapping[uid] = addr;
    }

    function donnottouch() public view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {

        return (
        rid,
        uid,
        now,
        rInvestCount[rid],
        rInvestMoney[rid],
        bonuslimit,
        sendLimit,
        withdrawLimit,
        canImport,
        lineStatus,
        lineArrayMapping[rid].length,
        1
        );
    }

    function getUserByAddress(address addr, uint roundId) public view returns (uint[15] memory info, string memory inviteCode, string memory beCode) {

        require(isWhitelistAdmin(msg.sender) || msg.sender == addr, "Permission denied for view user's privacy");

        if (roundId == 0) roundId = rid;

        UserGlobal memory userGlobal = userMapping[addr];
        User memory user = userRoundMapping[roundId][addr];
        info[0] = userGlobal.id;
        info[1] = user.lineAmount;
        info[2] = user.freeAmount;
        info[3] = user.freezeAmount;
        info[4] = user.inviteAmonut;
        info[5] = user.bonusAmount;
        info[6] = user.lineLevel;
        info[7] = user.dayBonusAmount;
        info[8] = user.rewardIndex;
        info[9] = user.investTimes;
        info[10] = user.level;
        uint grantAmount = 0;
        if (user.id > 0 && user.freezeAmount >= 1 ether && user.freezeAmount <= bonuslimit && user.investTimes < 7 && userGlobal.status != 1) grantAmount += user.dayBonusAmount;

        if (userGlobal.status == 0) {
            uint inviteSend = 0;
            AwardData memory awData = userAwardDataMapping[rid][user.userAddress][user.rewardIndex];
            uint lineAmount = user.freezeAmount.add(user.freeAmount).add(user.lineAmount);
            if (lineAmount >= 1 ether) {
                uint lineValue = lineAmount.div(ethWei);
                if (lineValue >= 15) inviteSend += awData.threeInvAmount;
                else {
                    if (user.lineLevel == 1 && lineAmount >= 1 ether && awData.oneInvAmount > 0) inviteSend += awData.oneInvAmount.div(15).mul(lineValue).div(2);

                    if (user.lineLevel == 2 && lineAmount >= 1 ether && (awData.oneInvAmount > 0 || awData.twoInvAmount > 0)) {
                        inviteSend += awData.oneInvAmount.div(15).mul(lineValue).mul(7).div(10);
                        inviteSend += awData.twoInvAmount.div(15).mul(lineValue).mul(5).div(7);
                    }
                    if (user.lineLevel == 3 && lineAmount >= 1 ether && awData.threeInvAmount > 0) inviteSend += awData.threeInvAmount.div(15).mul(lineValue);

                    if (user.lineLevel < 3) {
                        uint fireSc = getFireScByLevel(user.lineLevel);
                        inviteSend = inviteSend.mul(fireSc).div(10);
                    }
                }
                grantAmount += inviteSend;
            }
        }
        info[11] = grantAmount;
        info[12] = user.lastRwTime;
        info[13] = userGlobal.status;
        info[14] = user.bigCycle;

        return (info, userGlobal.inviteCode, userGlobal.beCode);
    }

    function getUserAddressById(uint id) public view returns (address) {

        require(isWhitelistAdmin(msg.sender), "Permission denied");
        return indexMapping[id];
    }

    function getLineUserId(uint index, uint rouId) public view returns (uint) {

        require(isWhitelistAdmin(msg.sender), "Permission denied");
        if (rouId == 0) rouId = rid;
        return lineArrayMapping[rid][index];
    }
}

library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;

        uint256 c = a * b;
        require(c / a == b, "mul overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "lower sub bigger");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "overflow");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "mod zero");
        return a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? b : a;
    }
}