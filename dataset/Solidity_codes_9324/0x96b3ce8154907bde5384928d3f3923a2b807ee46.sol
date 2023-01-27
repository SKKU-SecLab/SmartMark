
pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external;


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}

pragma solidity ^0.5.0;

contract Context {

    constructor () internal {}

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.5.0;

contract WhitelistAdminRole is Context {

    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(_msgSender());
    }

    modifier onlyWhitelistAdmin() {

        require(isWhitelistAdmin(_msgSender()), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(_msgSender());
    }

    function _addWhitelistAdmin(address account) internal {

        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {

        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

contract MithrilLottery is WhitelistAdminRole {

    using SafeMath for uint256;
    uint[] public LuckyNumbers = [1, 2, 3, 4, 5, 6];
    uint public SpecialNumber = 49;
    uint[] public LuckySpecialNumbersCandidate = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49];

    uint public LuckyNumberOpenedNum = 0;

    uint public BetNumber = 49;

    uint public ticketPrice = 50 ether;
    uint firstStageWinningPrice = 1000000 ether;

    struct Bet {
        uint id;
        uint8 winningStage;
        uint[] numbers;
    }
    mapping (address => Bet[]) userBets;

    mapping(uint => mapping(uint => bool)) betNumberDict;
    uint public totalBetNum = 0;

    address[] public users;
    mapping(address => bool) userAddressDict;

    mapping(address => uint8[]) public userWinningStages;

    IERC20 token;

    enum LotteryStatus {Opened, Executing, Closed}
    LotteryStatus public status;

    uint public currentRewardVolumn = 0;

    uint public remainingFirstVolumnBefore = 0;
    uint public remainingSecondtVolumnBefore = 0;
    uint public remainingThirdVolumnBefore = 0;
    uint public remainingFourthVolumnBefore = 0;

    mapping(address => uint) public rewardDict;
    address[] public rewardUsers;
    uint public rewardExecutedOffset = 0;
    uint public rewardUsersTotalLength = 0;

    address public teamWalletAddress;
    address public fundationWalletAddress;

    uint REWARD_BATCH_SIZE = 30;

    mapping(uint => address[]) public previousLuckyAddresses;

    bool winningStageSetFlag = false;

    uint RESET_LOTTERY_BATCH_SIZE = 10;
    uint public resetLotteryOffset = 0;

    uint public COUNT_WINNING_STAGE_BATCH_SIZE = 30;
    uint public countWinningStageUserOffset = 0;
    uint public countWinningStageUserBetOffset = 0;

    uint public COUNT_REWARD_BATCH_SIZE = 30;
    uint public countRewardFirstUserOffset = 0;
    uint public countRewardFirstUserBetOffset = 0;

    uint public countRewardSecondUserOffset = 0;
    uint public countRewardSecondUserBetOffset = 0;

    uint public totalPriceOfFiveToSeven = 0;
    uint public totalPriceOfEight = 0;
    uint public firstStageNumber = 0;
    uint public secondStageNumber = 0;
    uint public thirdStageNumber = 0;
    uint public fourthStageNumber = 0;
    uint public eightStageNumber = 0;

    uint public firstStagePricePerPerson = 0;
    uint public secondStagePricePerPerson = 0;
    uint public thirdStagePricePerPerson = 0;
    uint public fourthStagePricePerPerson = 0;

    uint public rewardTotalVolumn = 0;
    uint public totalBurnedVolumn = 0;

    constructor (IERC20 tokenAddress, address teamWallet, address fundationWallet) public {
        token = tokenAddress;
        teamWalletAddress = teamWallet;
        fundationWalletAddress = fundationWallet;
        status = LotteryStatus.Opened;
    }

    function resetPreviousLuckyAddresses() public onlyWhitelistAdmin {

        for (uint i = 0; i <= 8; i++) {
            delete previousLuckyAddresses[i];
        }
    }

    function getPreviousLuckyAddresses(uint index) public view returns (address[] memory addresses) {

        return previousLuckyAddresses[index];
    }

    function getTotalRemainingVolumnBefore() public view returns (uint total) {

        return remainingFirstVolumnBefore.add(remainingSecondtVolumnBefore).add(remainingThirdVolumnBefore).add(remainingFourthVolumnBefore);
    }

    function getTotalRemainingFirstVolumnBefore() public view returns (uint total) {

        return remainingFirstVolumnBefore;
    }

    function resetLuckySpecialNumbersCandidate() public onlyWhitelistAdmin {

        LuckySpecialNumbersCandidate.length = 49;
        for (uint item = 1; item <= BetNumber; item++) {
            LuckySpecialNumbersCandidate[item - 1] = item;
        }
    }

    function openLuckyNumber(uint number) public onlyWhitelistAdmin {

        require(status == LotteryStatus.Executing, "Lottery status not executing.");
        require(LuckyNumberOpenedNum < 7, "Lucky number already opened");
        uint betNumberIndex = uint(keccak256(abi.encodePacked(number, block.difficulty))).mod(LuckySpecialNumbersCandidate.length);
        uint betNumber = LuckySpecialNumbersCandidate[betNumberIndex];

        uint tmp = LuckySpecialNumbersCandidate[LuckySpecialNumbersCandidate.length - 1];
        LuckySpecialNumbersCandidate[LuckySpecialNumbersCandidate.length - 1] = LuckySpecialNumbersCandidate[betNumberIndex];
        LuckySpecialNumbersCandidate[betNumberIndex] = tmp;

        require(LuckySpecialNumbersCandidate.length != 0, "LuckySpecialNumbersCandidate not init.");

        LuckySpecialNumbersCandidate.pop();

        if (LuckyNumberOpenedNum == 6) {
            SpecialNumber = betNumber;
            LuckyNumberOpenedNum = 7;
        } else {
            LuckyNumbers[LuckyNumberOpenedNum] = betNumber;
            LuckyNumberOpenedNum += 1;
        }
    }

    function setLotteryStatus(LotteryStatus newStatus) public onlyWhitelistAdmin {

        status = newStatus;
    }

    function withdrawFirstRemainingPrice() public onlyWhitelistAdmin {

        require(teamWalletAddress != address(0), "Cold wallet address not set.");
        uint contractBalance = token.balanceOf(address(this));
        require(contractBalance >= remainingFirstVolumnBefore, "Contract balance not enough.");
        sendToken(teamWalletAddress, remainingFirstVolumnBefore);
        remainingFirstVolumnBefore = 0;
    }

    function withdrawPreviousDeposit() public onlyWhitelistAdmin {

        require(teamWalletAddress != address(0), "Cold wallet address not set.");
        require(status == LotteryStatus.Closed, "Lottery status not closed.");
        uint contractBalance = token.balanceOf(address(this));
        require(contractBalance > getTotalRemainingVolumnBefore(), "No more balance to withdraw.");
        uint withdrawAmount = contractBalance - getTotalRemainingVolumnBefore();
        sendToken(teamWalletAddress, withdrawAmount);
    }


    function resetLotteryBatch() public onlyWhitelistAdmin {

        require(rewardExecutedOffset == rewardUsersTotalLength, "Reward not completed yet.");
        require(resetLotteryOffset < users.length || users.length == 0, "Lottery already reset.");
        uint resetNumber = 0;
        if (users.length > RESET_LOTTERY_BATCH_SIZE + resetLotteryOffset) {
            resetNumber = RESET_LOTTERY_BATCH_SIZE;
        } else {
            resetNumber = users.length - resetLotteryOffset;
        }

        for (uint index = resetLotteryOffset; index < resetNumber; index++) {
            address userAddress = users[index];
            Bet[] storage bets = userBets[userAddress];
            bets.length = 0;

            userAddressDict[users[index]] = false;
            userWinningStages[users[index]].length = 0;
        }

        resetLotteryOffset += resetNumber;

        if (resetLotteryOffset == users.length) {
            resetLotteryOffset = 0;
            users.length = 0;

            LuckyNumberOpenedNum = 0;

            winningStageSetFlag = false;

            resetLuckySpecialNumbersCandidate();

            currentRewardVolumn = 0;
            rewardTotalVolumn = 0;

            totalBetNum = 0;

            rewardUsers.length = 0;
            rewardExecutedOffset = 0;
            rewardUsersTotalLength = 0;
            countWinningStageUserOffset = 0;
            countWinningStageUserBetOffset = 0;
            countRewardFirstUserOffset = 0;
            countRewardFirstUserBetOffset = 0;
            countRewardSecondUserOffset = 0;
            countRewardSecondUserBetOffset = 0;

            totalPriceOfFiveToSeven = 0;
            totalPriceOfEight = 0;
            firstStageNumber = 0;
            secondStageNumber = 0;
            thirdStageNumber = 0;
            fourthStageNumber = 0;
            eightStageNumber = 0;

            status = LotteryStatus.Opened;

        }
    }

    function pushReward(address userAddress, uint amount) private {

        if (amount > 0) {
            if (rewardDict[userAddress] == 0) {
                rewardUsers.push(userAddress);
            }
            rewardDict[userAddress] += amount;
            rewardTotalVolumn += amount;
        }
    }

    function setToken(IERC20 tokenAddress) private {

        token = tokenAddress;
    }

    function sendToken(address to, uint256 value) private {

        token.transfer(to, value);
    }

    function addFirstRemainingPrice(uint amount) public onlyWhitelistAdmin {

        uint allowanceValue = token.allowance(msg.sender, address(this));
        require(allowanceValue >= amount, "Allowance value not enough.");

        require(token.balanceOf(msg.sender) >= amount, "Admin token balance not enough.");

        token.transferFrom(msg.sender, address(this), amount);
        remainingFirstVolumnBefore += amount;
    }

    function setBets(uint[] memory numbers) public {

        require(numbers.length == 6, "Bet length not correct.");

        require(status == LotteryStatus.Opened, "Lottery not opened.");

        uint allowanceValue = token.allowance(msg.sender, address(this));
        require(allowanceValue >= ticketPrice, "Allowance value not enough.");

        require(token.balanceOf(msg.sender) >= ticketPrice, "User token balance not enough.");

        token.transferFrom(msg.sender, address(this), ticketPrice);

        currentRewardVolumn += ticketPrice * 40 / 100;

        sendToken(address(0x3893b9422Cd5D70a81eDeFfe3d5A1c6A978310BB), ticketPrice * 30 / 100);
        totalBurnedVolumn += ticketPrice * 30 / 100;

        sendToken(teamWalletAddress, ticketPrice * 5 / 100);
        sendToken(fundationWalletAddress, ticketPrice * 5 / 100);

        Bet memory bet;
        bet.id = totalBetNum;
        bet.numbers = numbers;
        totalBetNum += 1;

        Bet[] storage bets = userBets[msg.sender];
        bets.push(bet);

        for (uint index = 0; index < numbers.length; index++) {
            betNumberDict[bet.id][numbers[index]] = true;
        }

        if (userAddressDict[msg.sender] != true) {
            users.push(msg.sender);
            userAddressDict[msg.sender] = true;
        }
    }

    function getBet(address sender, uint betIndex) public view returns (uint[] memory numbers) {

        return userBets[sender][betIndex].numbers;
    }

    function getUserBets(address sender) public view returns (uint[][] memory numbers) {

        uint[][] memory bets = new uint[][](userBets[sender].length * 6);
        for (uint i = 0; i < userBets[sender].length; i++) {
            bets[i] = userBets[sender][i].numbers;
        }
        return bets;
    }

    function getLuckyNumber() public view returns (uint[] memory numbers) {

        return LuckyNumbers;
    }

    function getUsersLength()  public view returns (uint) {

        return users.length;
    }

    function countWinnings(address sender, uint betIndex) public view returns (uint8, uint8) {

        uint8 winningCount = 0;
        uint8 isSpecialNumber = 0;
        Bet storage bet = userBets[sender][betIndex];
        for (uint index = 0; index < LuckyNumbers.length; index++) {
            if (betNumberDict[bet.id][LuckyNumbers[index]] == true) {
                winningCount += 1;
            }
        }
        if (betNumberDict[bet.id][SpecialNumber] == true) {
            isSpecialNumber = 1;
        }
        return (winningCount, isSpecialNumber);
    }

    function getWinningStage(uint8 winningCount, uint8 isSpecialNumber) public pure returns (uint8) {

        if (winningCount == 6) {
            return 1;
        } else if (winningCount == 5) {
            if (isSpecialNumber == 1) {
                return 2;
            } else {
                return 3;
            }
        } else if (winningCount == 4) {
            if (isSpecialNumber == 1) {
                return 4;
            } else {
                return 5;
            }
        } else if (winningCount == 3) {
            if (isSpecialNumber == 1) {
                return 6;
            } else {
                return 8;
            }
        } else if (winningCount == 2 && isSpecialNumber == 1) {
                return 7;
        } else {
            return 0;
        }
    }

    function countAndSetWinningStageBatch() public onlyWhitelistAdmin {

        require(LuckyNumberOpenedNum == 7, "Lucky number not totally opened yet.");
        require(status == LotteryStatus.Executing, "Lottery status not executing.");
        require(countWinningStageUserOffset < users.length, "Winning Stage already count.");
        uint countSize = 0;
        for (uint i = countWinningStageUserOffset; i < users.length; i++) {
            address userAddress = users[i];
            Bet[] storage bets = userBets[userAddress];
            for (uint j = countWinningStageUserBetOffset; j < bets.length; j++) {
                (uint8 winningCount, uint8 isSpecialNumber) = countWinnings(userAddress, j);
                for (uint k = 0; k < bets[j].numbers.length; k++) {
                    betNumberDict[bets[j].id][bets[j].numbers[k]] = false;
                }

                uint8 winningStage = getWinningStage(winningCount, isSpecialNumber);
                bets[j].winningStage = winningStage;
                userWinningStages[userAddress].push(winningStage);
                countSize++;
                if (countSize >= COUNT_WINNING_STAGE_BATCH_SIZE) {
                    countWinningStageUserBetOffset = j + 1;
                    break;
                }
            }
            if (countSize >= COUNT_WINNING_STAGE_BATCH_SIZE) {
                if (countWinningStageUserBetOffset == bets.length) {
                    countWinningStageUserOffset = i + 1;
                    countWinningStageUserBetOffset = 0;
                } else {
                    countWinningStageUserOffset = i;
                }
                break;
            }

            countWinningStageUserBetOffset = 0;
        }

        if (countSize < COUNT_WINNING_STAGE_BATCH_SIZE || countWinningStageUserOffset == users.length) {
            countWinningStageUserOffset = users.length;
            winningStageSetFlag = true;
        }
    }

    function countRewardFirstBatch() public onlyWhitelistAdmin {

        require(status == LotteryStatus.Executing, "Lottery status not Executing.");
        require(LuckyNumberOpenedNum == 7, "Lucky number not totally opened yet.");
        require(winningStageSetFlag == true, "Winning stage not set.");
        require(countRewardFirstUserOffset < users.length, "Count reward first already done.");

        if (countRewardFirstUserOffset == 0 && countRewardFirstUserBetOffset == 0) {
            resetPreviousLuckyAddresses();

            totalPriceOfFiveToSeven = 0;
            totalPriceOfEight = 0;
            firstStageNumber = 0;
            secondStageNumber = 0;
            thirdStageNumber = 0;
            fourthStageNumber = 0;
            eightStageNumber = 0;
        }

        uint countSize = 0;
        for (uint i = countRewardFirstUserOffset; i < users.length; i++) {
            address userAddress = users[i];
            Bet[] storage bets = userBets[userAddress];
            for (uint j = countRewardFirstUserBetOffset; j < bets.length; j++) {
                if (bets[j].winningStage != 0) {
                    previousLuckyAddresses[bets[j].winningStage].push(userAddress);
                }

                if (bets[j].winningStage == 1) {
                    firstStageNumber += 1;
                } else if (bets[j].winningStage == 2) {
                    secondStageNumber += 1;
                } else if (bets[j].winningStage == 3) {
                    thirdStageNumber += 1;
                } else if (bets[j].winningStage == 4) {
                    fourthStageNumber += 1;
                } else if (bets[j].winningStage == 5) {
                    pushReward(userAddress, 2000 ether);
                    totalPriceOfFiveToSeven += 2000 ether;
                } else if (bets[j].winningStage == 6) {
                    pushReward(userAddress, 1000 ether);
                    totalPriceOfFiveToSeven += 1000 ether;
                } else if (bets[j].winningStage == 7) {
                    pushReward(userAddress, 400 ether);
                    totalPriceOfFiveToSeven += 400 ether;
                } else if (bets[j].winningStage == 8) {
                    totalPriceOfEight += 400 ether;
                    eightStageNumber += 1;
                }

                countSize++;
                if (countSize >= COUNT_REWARD_BATCH_SIZE) {
                    countRewardFirstUserBetOffset = j + 1;
                    break;
                }
            }

            if (countSize >= COUNT_REWARD_BATCH_SIZE) {
                if (countRewardFirstUserBetOffset == bets.length) {
                    countRewardFirstUserOffset = i + 1;
                    countRewardFirstUserBetOffset = 0;
                } else {
                    countRewardFirstUserOffset = i;
                }
                break;
            }

            countRewardFirstUserBetOffset = 0;
        }

        if (countSize < COUNT_WINNING_STAGE_BATCH_SIZE || countRewardFirstUserOffset == users.length) {
            countRewardFirstUserOffset = users.length;

            if (eightStageNumber > 0) {
                uint newEightTotalPrice;
                uint eightPricePerPerson;
                if (totalPriceOfFiveToSeven + totalPriceOfEight > currentRewardVolumn * 65 / 100) {
                    if ((currentRewardVolumn * 65 / 100) < totalPriceOfFiveToSeven) {
                        newEightTotalPrice = 0;
                    } else {
                        newEightTotalPrice = (currentRewardVolumn * 65 / 100) - totalPriceOfFiveToSeven;
                    }
                    eightPricePerPerson = newEightTotalPrice / eightStageNumber;
                } else {
                    eightPricePerPerson = 400 ether;
                }

                totalPriceOfEight = 0;
                if (eightPricePerPerson > 0) {
                    for (uint i = 0; i < users.length; i++) {
                        address userAddress = users[i];
                        Bet[] storage bets = userBets[userAddress];
                        for (uint j = 0; j < bets.length; j++) {
                            if (bets[j].winningStage == 8) {
                                    pushReward(userAddress, eightPricePerPerson);
                                    totalPriceOfEight += eightPricePerPerson;
                            }
                        }
                    }
                }
            }

            uint remainingPrice;
            if (currentRewardVolumn > (totalPriceOfFiveToSeven + totalPriceOfEight)) {
                remainingPrice = currentRewardVolumn - (totalPriceOfFiveToSeven + totalPriceOfEight);
            } else {
                remainingPrice = 0;
            }

            uint firstStageTotalPrice = (remainingPrice * 82 / 100) + remainingFirstVolumnBefore;
            uint secondStageTotalPrice = (remainingPrice * 65 / 1000) + remainingSecondtVolumnBefore;
            uint thirdStageTotalPrice = (remainingPrice * 7 / 100) + remainingThirdVolumnBefore;
            uint fourthStageTotalPrice = (remainingPrice * 45 / 1000) + remainingFourthVolumnBefore;
            firstStagePricePerPerson = 0;
            secondStagePricePerPerson = 0;
            thirdStagePricePerPerson = 0;
            fourthStagePricePerPerson = 0;
            if (firstStageNumber > 0) {
                firstStagePricePerPerson = firstStageTotalPrice.div(2).div(firstStageNumber);
                remainingFirstVolumnBefore = firstStageTotalPrice.div(2);
            } else {
                remainingFirstVolumnBefore = firstStageTotalPrice;
            }

            if (secondStageNumber > 0) {
                secondStagePricePerPerson = secondStageTotalPrice.div(secondStageNumber);
                remainingSecondtVolumnBefore = 0;
            } else {
                remainingSecondtVolumnBefore = secondStageTotalPrice;
            }

            if (thirdStageNumber > 0) {
                thirdStagePricePerPerson = thirdStageTotalPrice.div(thirdStageNumber);
                remainingThirdVolumnBefore = 0;
            } else {
                remainingThirdVolumnBefore = thirdStageTotalPrice;
            }

            if (fourthStageNumber > 0) {
                fourthStagePricePerPerson = fourthStageTotalPrice.div(fourthStageNumber);
                remainingFourthVolumnBefore = 0;
            } else {
                remainingFourthVolumnBefore = fourthStageTotalPrice;
            }
        }

    }

    function countRewardSecondBatch() public onlyWhitelistAdmin {

        require(status == LotteryStatus.Executing, "Lottery status not Executing.");
        require(LuckyNumberOpenedNum == 7, "Lucky number not totally opened yet.");
        require(winningStageSetFlag == true, "Winning stage not set.");
        require(countRewardFirstUserOffset == users.length, "Count reward first not done yet.");
        require(countRewardSecondUserOffset < users.length, "Count reward second already done.");

        uint countSize = 0;
        for (uint i = countRewardSecondUserOffset; i < users.length; i++) {
            address userAddress = users[i];
            Bet[] storage bets = userBets[userAddress];
            for (uint j = countRewardSecondUserBetOffset; j < bets.length; j++) {
                if (bets[j].winningStage == 1) {
                    pushReward(userAddress, firstStagePricePerPerson);
                } else if (bets[j].winningStage == 2) {
                    pushReward(userAddress, secondStagePricePerPerson);
                } else if (bets[j].winningStage == 3) {
                    pushReward(userAddress, thirdStagePricePerPerson);
                } else if (bets[j].winningStage == 4) {
                    pushReward(userAddress, fourthStagePricePerPerson);
                }

                countSize++;
                if (countSize >= COUNT_REWARD_BATCH_SIZE) {
                    countRewardSecondUserBetOffset = j + 1;
                    break;
                }
            }
            if (countSize >= COUNT_REWARD_BATCH_SIZE) {
                if (countRewardSecondUserBetOffset == bets.length) {
                    countRewardSecondUserOffset = i + 1;
                    countRewardSecondUserBetOffset = 0;
                } else {
                    countRewardSecondUserOffset = i;
                }
                break;
            }

            countRewardSecondUserBetOffset = 0;
        }

        if (countSize < COUNT_REWARD_BATCH_SIZE || countRewardSecondUserOffset == users.length) {
            countRewardSecondUserOffset = users.length;
            rewardUsersTotalLength = rewardUsers.length;
        }
    }

    function executeReward() public onlyWhitelistAdmin {

        require(status == LotteryStatus.Executing, "Lottery status not Executing.");
        require(countRewardSecondUserOffset == users.length, "Reward not counted yet.");
        uint contractBalance = token.balanceOf(address(this));
        uint totalRemainingVolumnBefore = getTotalRemainingVolumnBefore();
        require(contractBalance >= totalRemainingVolumnBefore + rewardTotalVolumn, "Contract balance not enough.");

        for (uint index = 0; index < rewardUsersTotalLength; index++) {
            require(index == rewardExecutedOffset, "Reward index incorrect.");
            address userAddress = rewardUsers[index];
            uint amount = rewardDict[userAddress];
            sendToken(userAddress, amount);

            rewardDict[userAddress] = 0;

            rewardExecutedOffset = index + 1;
        }

        if (rewardExecutedOffset == rewardUsersTotalLength) {
            status = LotteryStatus.Closed;
        }
    }

    function executeRewardBatch() public onlyWhitelistAdmin {

        require(status == LotteryStatus.Executing, "Lottery status not Executing.");
        require(countRewardSecondUserOffset == users.length, "Reward not counted yet.");
        uint contractBalance = token.balanceOf(address(this));
        uint totalRemainingVolumnBefore = getTotalRemainingVolumnBefore();
        require(contractBalance >= totalRemainingVolumnBefore + rewardTotalVolumn, "Contract balance not enough.");

        if (rewardUsersTotalLength <= REWARD_BATCH_SIZE + rewardExecutedOffset) {
            executeReward();
        } else {
            for (uint index = rewardExecutedOffset; index < rewardExecutedOffset + REWARD_BATCH_SIZE; index++) {
                require(rewardExecutedOffset < rewardUsersTotalLength, "No need to reward.");
                address userAddress = rewardUsers[index];
                uint amount = rewardDict[userAddress];
                sendToken(userAddress, amount);

                rewardDict[userAddress] = 0;

                rewardExecutedOffset = index + 1;
            }
        }

        if (rewardExecutedOffset == rewardUsersTotalLength) {
            status = LotteryStatus.Closed;
        }
    }
}