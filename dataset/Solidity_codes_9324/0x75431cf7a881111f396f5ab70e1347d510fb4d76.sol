


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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


pragma solidity >=0.4.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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


pragma solidity ^0.8.0;

library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}


pragma solidity ^0.8.4;

interface IRandomNumberGenerator {

    function getRandomNumber(uint256 _seed) external;


    function viewLatestLotteryId() external view returns (uint256);


    function viewRandomResult() external view returns (uint256);

}


pragma solidity ^0.8.4;

interface ICliffRaffle {

    function buyTickets(uint256 _lotteryId, uint256 _ticketCount) external;


    function claimTickets(uint256 _lotteryId, uint256[] calldata _ticketIds)
        external;


    function closeLottery(uint256 _lotteryId) external;


    function drawFinalNumberAndMakeLotteryClaimable(
        uint256 _lotteryId
    ) external;


    function injectFunds(uint256 _lotteryId, uint256 _amount) external;


    function startLottery(
        uint256 _priceTicketInCliff,
        uint256 _discountDivisor,
        uint256[5] calldata _rewardsBreakdown
    ) external;


    function viewCurrentLotteryId() external returns (uint256);

}


pragma solidity ^0.8.4;
pragma abicoder v2;

contract CliffRaffle is ReentrancyGuard, ICliffRaffle, Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public injectorAddress;
    address public operatorAddress;
    address public treasuryAddress;

    uint256 public currentLotteryId;
    uint256 public currentTicketId;

    uint256 public maxNumberTicketsPerBuyOrClaim = 100;

    uint256 public maxPriceTicketInCliff = 50 ether;
    uint256 public minPriceTicketInCliff = 0.005 ether;

    uint256 public pendingInjectionNextLottery;

    uint256 public constant MIN_DISCOUNT_DIVISOR = 300;
    uint256 public constant MAX_TREASURY_FEE = 5000; // 50%

    IERC20 public cliffToken;
    IRandomNumberGenerator public randomGenerator;

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct Lottery {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 priceTicketInCliff;
        uint256 discountDivisor;
        uint256[5] rewardsBreakdown; // [0-2] for winners, [3] for burn pool, [4] for roll over
        uint256[3] winTicketIds;
        uint8 winnerCount;
        uint256 firstTicketId;
        uint256 firstTicketIdNextLottery;
        uint256 amountCollectedInCliff;
        uint256 finalNumber;
    }

    struct Ticket {
        uint256 ticketId;
        address owner;
    }

    mapping(uint256 => Lottery) private _lotteries;
    mapping(uint256 => Ticket) private _tickets;

    mapping(address => mapping(uint256 => uint256[]))
        private _userTicketIdsPerLotteryId;

    modifier notContract() {

        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    modifier onlyOperator() {

        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    modifier onlyOwnerOrInjector() {

        require(
            (msg.sender == owner()) || (msg.sender == injectorAddress),
            "Not owner or injector"
        );
        _;
    }

    event AdminTokenRecovery(address token, uint256 amount);
    event LotteryClose(
        uint256 indexed lotteryId,
        uint256 firstTicketIdNextLottery
    );
    event LotteryInjection(uint256 indexed lotteryId, uint256 injectedAmount);
    event LotteryOpen(
        uint256 indexed lotteryId,
        uint256 startTime,
        uint256 priceTicketInCliff,
        uint256 firstTicketId,
        uint256 injectedAmount
    );
    event LotteryNumberDrawn(
        uint256 indexed lotteryId,
        uint256 finalNumber,
        uint8 winnerCount,
        uint256 winTicketId1,
        uint256 winTicketId2,
        uint256 winTicketId3
    );
    event NewOperatorAndTreasuryAndInjectorAddresses(
        address operator,
        address treasury,
        address injector
    );
    event NewRandomGenerator(address indexed randomGenerator);
    event TicketsPurchase(
        address indexed buyer,
        uint256 indexed lotteryId,
        uint256 numberTickets
    );
    event TicketsClaim(
        address indexed claimer,
        uint256 amount,
        uint256 indexed lotteryId,
        uint256 numberTickets
    );

    constructor(address _cliffTokenAddress, address _randomGeneratorAddress) {
        cliffToken = IERC20(_cliffTokenAddress);
        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);

        maxPriceTicketInCliff = 50 * 10**uint256(cliffToken.decimals());
        minPriceTicketInCliff = 5 * 10**(uint256(cliffToken.decimals()).sub(3));
    }

    function buyTickets(uint256 _lotteryId, uint256 _ticketCount)
        external
        override
        notContract
        nonReentrant
    {

        require(_ticketCount != 0, "No ticket specified");
        require(
            _ticketCount <= maxNumberTicketsPerBuyOrClaim,
            "Too many tickets"
        );
        require(
            _lotteries[_lotteryId].status == Status.Open,
            "Lottery is not open"
        );

        uint256 amountCliffToTransfer = _calculateTotalPriceForBulkTickets(
            _lotteries[_lotteryId].discountDivisor,
            _lotteries[_lotteryId].priceTicketInCliff,
            _ticketCount
        );

        uint256 balanceBefore = cliffToken.balanceOf(address(this));
        cliffToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            amountCliffToTransfer
        );
        amountCliffToTransfer = cliffToken.balanceOf(address(this)).sub(
            balanceBefore
        );

        _lotteries[_lotteryId].amountCollectedInCliff = _lotteries[_lotteryId]
            .amountCollectedInCliff
            .add(amountCliffToTransfer);

        for (uint256 i = 0; i < _ticketCount; i++) {
            _userTicketIdsPerLotteryId[msg.sender][_lotteryId].push(
                currentTicketId
            );

            _tickets[currentTicketId] = Ticket({
                ticketId: currentTicketId,
                owner: msg.sender
            });

            currentTicketId++;
        }

        emit TicketsPurchase(msg.sender, _lotteryId, _ticketCount);
    }

    function claimTickets(uint256 _lotteryId, uint256[] calldata _ticketIds)
        external
        override
        notContract
        nonReentrant
    {

        require(_ticketIds.length != 0, "Length must be >0");
        require(
            _ticketIds.length <= maxNumberTicketsPerBuyOrClaim,
            "Too many tickets"
        );
        require(
            _lotteries[_lotteryId].status == Status.Claimable,
            "Lottery not claimable"
        );

        uint256 rewardInCliffToTransfer;

        for (uint256 i = 0; i < _ticketIds.length; i++) {
            uint256 thisTicketId = _ticketIds[i];

            require(
                _lotteries[_lotteryId].firstTicketIdNextLottery > thisTicketId,
                "TicketId too high"
            );
            require(
                _lotteries[_lotteryId].firstTicketId <= thisTicketId,
                "TicketId too low"
            );
            require(
                msg.sender == _tickets[thisTicketId].owner,
                "Not the owner"
            );

            _tickets[thisTicketId].owner = address(0);

            uint256 rewardForTicketId = _calculateRewardsForTicketId(
                _lotteryId,
                thisTicketId
            );

            rewardInCliffToTransfer = rewardInCliffToTransfer.add(
                rewardForTicketId
            );
        }

        cliffToken.safeTransfer(msg.sender, rewardInCliffToTransfer);

        emit TicketsClaim(
            msg.sender,
            rewardInCliffToTransfer,
            _lotteryId,
            _ticketIds.length
        );
    }

    function closeLottery(uint256 _lotteryId)
        external
        override
        onlyOperator
        nonReentrant
    {

        require(
            _lotteries[_lotteryId].status == Status.Open,
            "Lottery not open"
        );
        _lotteries[_lotteryId].endTime = block.timestamp;
        _lotteries[_lotteryId].firstTicketIdNextLottery = currentTicketId;

        randomGenerator.getRandomNumber(
            uint256(keccak256(abi.encodePacked(_lotteryId, currentTicketId)))
        );

        _lotteries[_lotteryId].status = Status.Close;

        emit LotteryClose(_lotteryId, currentTicketId);
    }

    function determineWinTicketIdsAndCount(
        uint256 _lotteryId,
        uint256 _randomNumber
    )
        internal
        view
        returns (
            uint8 winnerCount,
            uint256 winTicketId1,
            uint256 winTicketId2,
            uint256 winTicketId3
        )
    {

        uint256 ticketCount;
        if (_lotteryId == 0) {
            ticketCount = currentTicketId;
        } else {
            ticketCount = _lotteries[_lotteryId].firstTicketIdNextLottery.sub(
                _lotteries[_lotteryId.sub(1)].firstTicketIdNextLottery
            );
        }

        if (ticketCount >= 3) {
            uint256 step = _randomNumber % (ticketCount.sub(1));
            if (step == 0) {
                step = 1;
            }
            uint256 firstWinIndex = _randomNumber % ticketCount;
            uint256 secondWinIndex = (firstWinIndex.add(step)) % ticketCount;
            if (secondWinIndex == firstWinIndex) {
                secondWinIndex = firstWinIndex.add(1) % ticketCount;
            }
            uint256 thirdWinIndex = (secondWinIndex.add(step)) % ticketCount;
            if (thirdWinIndex == firstWinIndex) {
                thirdWinIndex = firstWinIndex.add(1) % ticketCount;
            }
            if (thirdWinIndex == secondWinIndex) {
                thirdWinIndex = secondWinIndex.add(1) % ticketCount;
            }
            if (thirdWinIndex == firstWinIndex) {
                thirdWinIndex = firstWinIndex.add(1) % ticketCount;
            }
            winnerCount = 3;
            winTicketId1 = _lotteries[_lotteryId].firstTicketId.add(
                firstWinIndex
            );
            winTicketId2 = _lotteries[_lotteryId].firstTicketId.add(
                secondWinIndex
            );
            winTicketId3 = _lotteries[_lotteryId].firstTicketId.add(
                thirdWinIndex
            );
        } else if (ticketCount == 2) {
            uint256 firstWinIndex = _randomNumber % 2;
            uint256 secondWinIndex = firstWinIndex == 0 ? 1 : 0;
            winnerCount = 2;
            winTicketId1 = _lotteries[_lotteryId].firstTicketId.add(
                firstWinIndex
            );
            winTicketId2 = _lotteries[_lotteryId].firstTicketId.add(
                secondWinIndex
            );
        } else if (ticketCount == 1) {
            uint256 firstWinIndex = 1;
            winnerCount = 1;
            winTicketId1 = _lotteries[_lotteryId].firstTicketId.add(
                firstWinIndex
            );
        }
    }

    function processTreasuryFeeAndPendingFunds(
        uint256 _lotteryId,
        uint8 _winnerCount
    ) internal {

        if (_winnerCount == 2) {
            pendingInjectionNextLottery = _lotteries[_lotteryId]
                .amountCollectedInCliff
                .mul(_lotteries[_lotteryId].rewardsBreakdown[2])
                .div(10000);
        } else if (_winnerCount == 1) {
            pendingInjectionNextLottery = _lotteries[_lotteryId]
                .amountCollectedInCliff
                .mul(
                    _lotteries[_lotteryId].rewardsBreakdown[1].add(
                        _lotteries[_lotteryId].rewardsBreakdown[2]
                    )
                )
                .div(10000);
        }

        pendingInjectionNextLottery = pendingInjectionNextLottery.add(
            _lotteries[_lotteryId]
                .amountCollectedInCliff
                .mul(_lotteries[_lotteryId].rewardsBreakdown[4])
                .div(10000)
        );

        uint256 amountToWithdrawToTreasury = _lotteries[_lotteryId]
            .amountCollectedInCliff
            .mul(_lotteries[_lotteryId].rewardsBreakdown[3])
            .div(10000);

        if (amountToWithdrawToTreasury > 0) {
            cliffToken.safeTransfer(
                treasuryAddress,
                amountToWithdrawToTreasury
            );
        }
    }

    function drawFinalNumberAndMakeLotteryClaimable(uint256 _lotteryId)
        external
        override
        onlyOperator
        nonReentrant
    {

        require(
            _lotteries[_lotteryId].status == Status.Close,
            "Lottery not close"
        );
        require(
            _lotteryId == randomGenerator.viewLatestLotteryId(),
            "Numbers not drawn"
        );

        uint256 finalNumber = randomGenerator.viewRandomResult();
        (
            uint8 winnerCount,
            uint256 winTicketId1,
            uint256 winTicketId2,
            uint256 winTicketId3
        ) = determineWinTicketIdsAndCount(_lotteryId, finalNumber);

        processTreasuryFeeAndPendingFunds(_lotteryId, winnerCount);

        _lotteries[_lotteryId].winnerCount = winnerCount;
        _lotteries[_lotteryId].winTicketIds[0] = winTicketId1;
        _lotteries[_lotteryId].winTicketIds[1] = winTicketId2;
        _lotteries[_lotteryId].winTicketIds[2] = winTicketId3;
        _lotteries[_lotteryId].finalNumber = finalNumber;
        _lotteries[_lotteryId].status = Status.Claimable;

        emit LotteryNumberDrawn(
            currentLotteryId,
            finalNumber,
            winnerCount,
            winTicketId1,
            winTicketId2,
            winTicketId3
        );
    }

    function changeRandomGenerator(address _randomGeneratorAddress)
        external
        onlyOwner
    {

        require(
            _lotteries[currentLotteryId].status == Status.Claimable,
            "Lottery not in claimable"
        );

        IRandomNumberGenerator(_randomGeneratorAddress).getRandomNumber(
            uint256(
                keccak256(abi.encodePacked(currentLotteryId, currentTicketId))
            )
        );

        IRandomNumberGenerator(_randomGeneratorAddress).viewRandomResult();

        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);

        emit NewRandomGenerator(_randomGeneratorAddress);
    }

    function injectFunds(uint256 _lotteryId, uint256 _amount)
        external
        override
        onlyOwnerOrInjector
    {

        require(
            _lotteries[_lotteryId].status == Status.Open,
            "Lottery not open"
        );

        uint256 balanceBefore = cliffToken.balanceOf(address(this));
        cliffToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        _amount = cliffToken.balanceOf(address(this)).sub(balanceBefore);
        _lotteries[_lotteryId].amountCollectedInCliff = _lotteries[_lotteryId]
            .amountCollectedInCliff
            .add(_amount);
        emit LotteryInjection(_lotteryId, _amount);
    }

    function startLottery(
        uint256 _priceTicketInCliff,
        uint256 _discountDivisor,
        uint256[5] calldata _rewardsBreakdown
    ) external override onlyOperator {

        require(
            (currentLotteryId == 0) ||
                (_lotteries[currentLotteryId].status == Status.Claimable),
            "Not time to start lottery"
        );

        require(
            (_priceTicketInCliff >= minPriceTicketInCliff) &&
                (_priceTicketInCliff <= maxPriceTicketInCliff),
            "Outside of limits"
        );

        require(
            _discountDivisor >= MIN_DISCOUNT_DIVISOR,
            "Discount divisor too low"
        );
        require(
            _rewardsBreakdown[3] <= MAX_TREASURY_FEE,
            "Treasury fee too high"
        );

        require(
            (_rewardsBreakdown[0] +
                _rewardsBreakdown[1] +
                _rewardsBreakdown[2] +
                _rewardsBreakdown[3] +
                _rewardsBreakdown[4]) == 10000,
            "Rewards must equal 10000"
        );

        currentLotteryId++;

        _lotteries[currentLotteryId] = Lottery({
            status: Status.Open,
            startTime: block.timestamp,
            endTime: block.timestamp,
            priceTicketInCliff: _priceTicketInCliff,
            discountDivisor: _discountDivisor,
            rewardsBreakdown: _rewardsBreakdown,
            winTicketIds: [uint256(0), uint256(0), uint256(0)],
            winnerCount: 0,
            firstTicketId: currentTicketId,
            firstTicketIdNextLottery: currentTicketId,
            amountCollectedInCliff: pendingInjectionNextLottery,
            finalNumber: 0
        });

        emit LotteryOpen(
            currentLotteryId,
            block.timestamp,
            _priceTicketInCliff,
            currentTicketId,
            pendingInjectionNextLottery
        );

        pendingInjectionNextLottery = 0;
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {

        require(_tokenAddress != address(cliffToken), "Cannot be CLIFF token");

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    function setMinAndMaxTicketPriceInCliff(
        uint256 _minPriceTicketInCliff,
        uint256 _maxPriceTicketInCliff
    ) external onlyOwner {

        require(
            _minPriceTicketInCliff <= _maxPriceTicketInCliff,
            "minPrice must be < maxPrice"
        );

        minPriceTicketInCliff = _minPriceTicketInCliff;
        maxPriceTicketInCliff = _maxPriceTicketInCliff;
    }

    function setMaxNumberTicketsPerBuy(uint256 _maxNumberTicketsPerBuy)
        external
        onlyOwner
    {

        require(_maxNumberTicketsPerBuy != 0, "Must be > 0");
        maxNumberTicketsPerBuyOrClaim = _maxNumberTicketsPerBuy;
    }

    function setOperatorAndTreasuryAndInjectorAddresses(
        address _operatorAddress,
        address _treasuryAddress,
        address _injectorAddress
    ) external onlyOwner {

        require(_operatorAddress != address(0), "Cannot be zero address");
        require(_treasuryAddress != address(0), "Cannot be zero address");
        require(_injectorAddress != address(0), "Cannot be zero address");

        operatorAddress = _operatorAddress;
        treasuryAddress = _treasuryAddress;
        injectorAddress = _injectorAddress;

        emit NewOperatorAndTreasuryAndInjectorAddresses(
            _operatorAddress,
            _treasuryAddress,
            _injectorAddress
        );
    }

    function calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) external pure returns (uint256) {

        require(
            _discountDivisor >= MIN_DISCOUNT_DIVISOR,
            "Must be >= MIN_DISCOUNT_DIVISOR"
        );
        require(_numberTickets != 0, "Number of tickets must be > 0");

        return
            _calculateTotalPriceForBulkTickets(
                _discountDivisor,
                _priceTicket,
                _numberTickets
            );
    }

    function viewCurrentLotteryId() external view override returns (uint256) {

        return currentLotteryId;
    }

    function viewLottery(uint256 _lotteryId)
        external
        view
        returns (Lottery memory)
    {

        return _lotteries[_lotteryId];
    }

    function viewStatusesForTicketIds(uint256[] calldata _ticketIds)
        external
        view
        returns (bool[] memory)
    {

        uint256 length = _ticketIds.length;
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            if (_tickets[_ticketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                ticketStatuses[i] = false;
            }
        }

        return ticketStatuses;
    }

    function viewRewardsForTicketId(uint256 _lotteryId, uint256 _ticketId)
        external
        view
        returns (uint256)
    {

        if (_lotteries[_lotteryId].status != Status.Claimable) {
            return 0;
        }

        if (
            (_lotteries[_lotteryId].firstTicketIdNextLottery < _ticketId) &&
            (_lotteries[_lotteryId].firstTicketId >= _ticketId)
        ) {
            return 0;
        }

        return _calculateRewardsForTicketId(_lotteryId, _ticketId);
    }

    function viewUserInfoForLotteryId(
        address _user,
        uint256 _lotteryId,
        uint256 _cursor,
        uint256 _size
    )
        external
        view
        returns (
            uint256[] memory,
            bool[] memory,
            uint256
        )
    {

        uint256 length = _size;
        uint256 numberTicketsBoughtAtLotteryId = _userTicketIdsPerLotteryId[
            _user
        ][_lotteryId].length;

        if (length > (numberTicketsBoughtAtLotteryId - _cursor)) {
            length = numberTicketsBoughtAtLotteryId - _cursor;
        }

        uint256[] memory lotteryTicketIds = new uint256[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            lotteryTicketIds[i] = _userTicketIdsPerLotteryId[_user][_lotteryId][
                i + _cursor
            ];

            if (_tickets[lotteryTicketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                ticketStatuses[i] = false;
            }
        }

        return (lotteryTicketIds, ticketStatuses, _cursor + length);
    }

    function _calculateRewardsForTicketId(uint256 _lotteryId, uint256 _ticketId)
        internal
        view
        returns (uint256)
    {

        if (
            _lotteries[_lotteryId].winnerCount >= 3 &&
            _ticketId == _lotteries[_lotteryId].winTicketIds[2]
        ) {
            return
                _lotteries[_lotteryId]
                    .amountCollectedInCliff
                    .mul(_lotteries[_lotteryId].rewardsBreakdown[2])
                    .div(10000);
        } else if (
            _lotteries[_lotteryId].winnerCount >= 2 &&
            _ticketId == _lotteries[_lotteryId].winTicketIds[1]
        ) {
            return
                _lotteries[_lotteryId]
                    .amountCollectedInCliff
                    .mul(_lotteries[_lotteryId].rewardsBreakdown[1])
                    .div(10000);
        } else if (
            _lotteries[_lotteryId].winnerCount >= 1 &&
            _ticketId == _lotteries[_lotteryId].winTicketIds[0]
        ) {
            return
                _lotteries[_lotteryId]
                    .amountCollectedInCliff
                    .mul(_lotteries[_lotteryId].rewardsBreakdown[0])
                    .div(10000);
        } else {
            return 0;
        }
    }

    function _calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) internal pure returns (uint256) {

        return
            (_priceTicket *
                _numberTickets *
                (_discountDivisor + 1 - _numberTickets)) / _discountDivisor;
    }

    function _isContract(address _addr) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}