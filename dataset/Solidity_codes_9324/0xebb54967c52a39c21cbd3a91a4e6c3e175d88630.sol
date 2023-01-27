

pragma solidity 0.6.12;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


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
}

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
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

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ReentrancyGuard {


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

library Babylonian {

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

abstract contract Context {
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

    constructor() internal {
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

contract Operator is Context, Ownable {

    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor() internal {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {

        return _operator;
    }

    modifier onlyOperator() {

        require(_operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {

        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {

        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {

        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}

contract ContractGuard {

    mapping(uint256 => mapping(address => bool)) private _status;

    function checkSameOriginReentranted() internal view returns (bool) {

        return _status[block.number][tx.origin];
    }

    function checkSameSenderReentranted() internal view returns (bool) {

        return _status[block.number][msg.sender];
    }

    modifier onlyOneBlock() {

        require(!checkSameOriginReentranted(), "ContractGuard: one block, one function");
        require(!checkSameSenderReentranted(), "ContractGuard: one block, one function");

        _;

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;
    }
}

interface IBasisAsset {

    function mint(address recipient, uint256 amount) external returns (bool);


    function burn(uint256 amount) external;


    function burnFrom(address from, uint256 amount) external;


    function isOperator() external returns (bool);


    function operator() external view returns (address);

}

interface IOracle {

    function updateCumulative() external;


    function update() external;


    function consult(address token, uint256 _amountIn) external view returns (uint144 _amountOut);


    function twap(uint256 _amountIn) external view returns (uint144 _amountOut);

}

interface IBoardroom {

    function balanceOf(address _director) external view returns (uint256);


    function earned(address _director) external view returns (uint256);


    function canWithdraw(address _director) external view returns (bool);


    function canClaimReward(address _director) external view returns (bool);


    function setOperator(address _operator) external;


    function setLockUp(uint256 _withdrawLockupEpochs, uint256 _rewardLockupEpochs) external;


    function stake(uint256 _amount) external;


    function withdraw(uint256 _amount) external;


    function exit() external;


    function claimReward() external;


    function allocateSeigniorage(uint256 _amount) external;


    function governanceRecoverUnsupported(
        address _token,
        uint256 _amount,
        address _to
    ) external;

}

contract Treasury is ContractGuard {

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;


    uint256 public constant PERIOD = 12 hours;


    address public operator;

    bool public migrated = false;
    bool public initialized = false;

    uint256 public startTime;
    uint256 public epoch = 0;
    uint256 public epochSupplyContractionLeft = 0;

    address public dollar = address(0x003e0af2916e598Fa5eA5Cb2Da4EDfdA9aEd9Fde);
    address public bond = address(0x9f48b2f14517770F2d238c787356F3b961a6616F);
    address public share = address(0xE7C9C188138f7D70945D420d75F8Ca7d8ab9c700);

    address public boardroom;
    address public dollarOracle;

    uint256 public dollarPriceOne;
    uint256 public dollarPriceCeiling;

    uint256 public seigniorageSaved;

    uint256 public maxSupplyExpansionPercent;
    uint256 public bondDepletionFloorPercent;
    uint256 public seigniorageExpansionFloorPercent;
    uint256 public maxSupplyContractionPercent;
    uint256 public maxDeptRatioPercent;


    uint256 public bdip01SharedIncentiveForLpEpochs;
    uint256 public bdip01SharedIncentiveForLpPercent;
    address[] public bdip01LiquidityPools;

    uint256 public bdip02BootstrapEpochs;
    uint256 public bdip02BootstrapSupplyExpansionPercent;

    uint256 public allocateSeigniorageSalary;


    event Initialized(address indexed executor, uint256 at);
    event Migration(address indexed target);
    event RedeemedBonds(address indexed from, uint256 amount);
    event BoughtBonds(address indexed from, uint256 amount);
    event TreasuryFunded(uint256 timestamp, uint256 seigniorage);
    event BoardroomFunded(uint256 timestamp, uint256 seigniorage);


    modifier onlyOperator() {

        require(operator == msg.sender, "Treasury: caller is not the operator");
        _;
    }

    modifier checkCondition {

        require(!migrated, "Treasury: migrated");
        require(now >= startTime, "Treasury: not started yet");

        _;
    }

    modifier checkEpoch {

        require(now >= nextEpochPoint(), "Treasury: not opened yet");

        _;

        epoch = epoch.add(1);
        epochSupplyContractionLeft = (getDollarUpdatedPrice() > dollarPriceOne)
            ? 0
            : IERC20(dollar).totalSupply().mul(maxSupplyContractionPercent).div(10000).add(1);
    }

    modifier checkOperator {

        require(
            IBasisAsset(dollar).operator() == address(this) &&
                IBasisAsset(bond).operator() == address(this) &&
                IBasisAsset(share).operator() == address(this) &&
                Operator(boardroom).operator() == address(this),
            "Treasury: need more permission"
        );

        _;
    }

    modifier notInitialized {

        require(!initialized, "Treasury: already initialized");

        _;
    }


    function isMigrated() public view returns (bool) {

        return migrated;
    }

    function isInitialized() public view returns (bool) {

        return initialized;
    }

    function nextEpochPoint() public view returns (uint256) {

        return startTime.add(epoch.mul(PERIOD));
    }

    function getDollarPrice() public view returns (uint256 _dollarPrice) {

        try IOracle(dollarOracle).consult(dollar, 1e18) returns (uint144 price) {
            return uint256(price);
        } catch {
            revert("Treasury: failed to consult dollar price from the oracle");
        }
    }

    function getDollarUpdatedPrice() public view returns (uint256 _dollarPrice) {

        try IOracle(dollarOracle).twap(1e18) returns (uint144 price) {
            return uint256(price);
        } catch {
            revert("Treasury: failed to consult dollar price from the oracle");
        }
    }

    function getReserve() public view returns (uint256) {

        return seigniorageSaved;
    }

    function getBurnableDollarLeft() public view returns (uint256 _burnableDollarLeft) {

        uint256 _dollarPrice = getDollarUpdatedPrice();
        if (_dollarPrice <= dollarPriceOne) {
            uint256 _dollarSupply = IERC20(dollar).totalSupply();
            uint256 _bondMaxSupply = _dollarSupply.mul(maxDeptRatioPercent).div(10000);
            uint256 _bondSupply = IERC20(bond).totalSupply();
            if (_bondMaxSupply > _bondSupply) {
                uint256 _maxMintableBond = _bondMaxSupply.sub(_bondSupply);
                uint256 _maxBurnableDollar = _maxMintableBond.mul(_dollarPrice).div(1e18);
                uint256 _epochSupplyContractionLeft =
                    (epochSupplyContractionLeft > 0)
                        ? epochSupplyContractionLeft.sub(1)
                        : IERC20(dollar).totalSupply().mul(maxSupplyContractionPercent).div(10000);
                _burnableDollarLeft = Math.min(_epochSupplyContractionLeft, _maxBurnableDollar);
            }
        }
    }


    function initialize(
        address _dollar,
        address _bond,
        address _share,
        uint256 _startTime
    ) public notInitialized {

        dollar = _dollar;
        bond = _bond;
        share = _share;
        startTime = _startTime;

        dollarPriceOne = 10**18;
        dollarPriceCeiling = dollarPriceOne.mul(105).div(100);

        maxSupplyExpansionPercent = 450; // Upto 4.5% supply for expansion
        bondDepletionFloorPercent = 10000; // 100% of Bond supply for depletion floor
        seigniorageExpansionFloorPercent = 3500; // At least 35% of expansion reserved for boardroom
        maxSupplyContractionPercent = 450; // Upto 4.5% supply for contraction (to burn BSD and mint BSDB)
        maxDeptRatioPercent = 3500; // Upto 35% supply of BSDB to purchase

        bdip01SharedIncentiveForLpEpochs = 14;
        bdip01SharedIncentiveForLpPercent = 2500;
        bdip01LiquidityPools = [
            address(0x71661297e9784f08fd5d840D4340C02e52550cd9), // DAI/BSD
            address(0x9E7a4f7e4211c0CE4809cE06B9dDA6b95254BaaC), // USDC/BSD
            address(0xc259bf15BaD4D870dFf1FE1AAB450794eB33f8e8), // DAI/BSDS
            address(0xE0e7F7EB27CEbCDB2F1DA5F893c429d0e5954468) // USDC/BSDS
        ];

        bdip02BootstrapEpochs = 14;
        bdip02BootstrapSupplyExpansionPercent = 900;

        seigniorageSaved = IERC20(dollar).balanceOf(address(this));

        initialized = true;
        operator = msg.sender;
        emit Initialized(msg.sender, block.number);
    }

    function setOperator(address _operator) external onlyOperator {

        operator = _operator;
    }

    function setBoardroom(address _boardroom) external onlyOperator {

        boardroom = _boardroom;
    }

    function setDollarOracle(address _dollarOracle) external onlyOperator {

        dollarOracle = _dollarOracle;
    }

    function setDollarPriceCeiling(uint256 _dollarPriceCeiling) external onlyOperator {

        require(_dollarPriceCeiling >= dollarPriceOne && _dollarPriceCeiling <= dollarPriceOne.mul(120).div(100), "out of range"); // [$1.0, $1.2]
        dollarPriceCeiling = _dollarPriceCeiling;
    }

    function setMaxSupplyExpansionPercent(uint256 _maxSupplyExpansionPercent) external onlyOperator {

        require(_maxSupplyExpansionPercent >= 10 && _maxSupplyExpansionPercent <= 1500, "out of range"); // [0.1%, 15%]
        maxSupplyExpansionPercent = _maxSupplyExpansionPercent;
    }

    function setBondDepletionFloorPercent(uint256 _bondDepletionFloorPercent) external onlyOperator {

        require(_bondDepletionFloorPercent >= 500 && _bondDepletionFloorPercent <= 10000, "out of range"); // [5%, 100%]
        bondDepletionFloorPercent = _bondDepletionFloorPercent;
    }

    function setMaxSupplyContractionPercent(uint256 _maxSupplyContractionPercent) external onlyOperator {

        require(_maxSupplyContractionPercent >= 100 && _maxSupplyContractionPercent <= 1500, "out of range"); // [0.1%, 15%]
        maxSupplyContractionPercent = _maxSupplyContractionPercent;
    }

    function setMaxDeptRatioPercent(uint256 _maxDeptRatioPercent) external onlyOperator {

        require(_maxDeptRatioPercent >= 1000 && _maxDeptRatioPercent <= 10000, "out of range"); // [10%, 100%]
        maxDeptRatioPercent = _maxDeptRatioPercent;
    }

    function setBDIP01(
        uint256 _bdip01SharedIncentiveForLpEpochs,
        uint256 _bdip01SharedIncentiveForLpPercent,
        address[] memory _bdip01LiquidityPools
    ) external onlyOperator {

        require(_bdip01SharedIncentiveForLpEpochs <= 730, "_bdip01SharedIncentiveForLpEpochs: out of range"); // <= 1 year
        require(_bdip01SharedIncentiveForLpPercent <= 10000, "_bdip01SharedIncentiveForLpPercent: out of range"); // [0%, 100%]
        bdip01SharedIncentiveForLpEpochs = _bdip01SharedIncentiveForLpEpochs;
        bdip01SharedIncentiveForLpPercent = _bdip01SharedIncentiveForLpPercent;
        bdip01LiquidityPools = _bdip01LiquidityPools;
    }

    function setBDIP02(uint256 _bdip02BootstrapEpochs, uint256 _bdip02BootstrapSupplyExpansionPercent) external onlyOperator {

        require(_bdip02BootstrapEpochs <= 60, "_bdip02BootstrapEpochs: out of range"); // <= 1 month
        require(
            _bdip02BootstrapSupplyExpansionPercent >= 100 && _bdip02BootstrapSupplyExpansionPercent <= 1500,
            "_bdip02BootstrapSupplyExpansionPercent: out of range"
        ); // [1%, 15%]
        bdip02BootstrapEpochs = _bdip02BootstrapEpochs;
        bdip02BootstrapSupplyExpansionPercent = _bdip02BootstrapSupplyExpansionPercent;
    }

    function migrate(address target) external onlyOperator checkOperator {

        require(!migrated, "Treasury: migrated");

        Operator(dollar).transferOperator(target);
        Operator(dollar).transferOwnership(target);
        IERC20(dollar).transfer(target, IERC20(dollar).balanceOf(address(this)));

        Operator(bond).transferOperator(target);
        Operator(bond).transferOwnership(target);
        IERC20(bond).transfer(target, IERC20(bond).balanceOf(address(this)));

        Operator(share).transferOperator(target);
        Operator(share).transferOwnership(target);
        IERC20(share).transfer(target, IERC20(share).balanceOf(address(this)));

        migrated = true;
        emit Migration(target);
    }


    function _updateDollarPrice() internal {

        try IOracle(dollarOracle).update() {} catch {}
    }

    function _updateDollarPriceCumulative() internal {

        try IOracle(dollarOracle).updateCumulative() {} catch {}
    }

    function buyBonds(uint256 amount, uint256 targetPrice) external onlyOneBlock checkCondition checkOperator {

        require(amount > 0, "Treasury: cannot purchase bonds with zero amount");

        uint256 dollarPrice = getDollarUpdatedPrice();
        require(dollarPrice == targetPrice, "Treasury: dollar price moved");
        require(
            dollarPrice < dollarPriceOne, // price < $1
            "Treasury: dollarPrice not eligible for bond purchase"
        );

        if (epochSupplyContractionLeft == 0) {
            epochSupplyContractionLeft = IERC20(dollar).totalSupply().mul(maxSupplyContractionPercent).div(10000).add(1);
        }

        require(amount < epochSupplyContractionLeft, "Treasury: not enough bond left to purchase");

        uint256 _boughtBond = amount.mul(1e18).div(dollarPrice);
        uint256 dollarSupply = IERC20(dollar).totalSupply();
        uint256 newBondSupply = IERC20(bond).totalSupply().add(_boughtBond);
        require(newBondSupply <= dollarSupply.mul(maxDeptRatioPercent).div(10000), "over max debt ratio");

        IBasisAsset(dollar).burnFrom(msg.sender, amount);
        IBasisAsset(bond).mint(msg.sender, _boughtBond);

        epochSupplyContractionLeft = epochSupplyContractionLeft.sub(amount);
        _updateDollarPriceCumulative();

        emit BoughtBonds(msg.sender, amount);
    }

    function redeemBonds(uint256 amount, uint256 targetPrice) external onlyOneBlock checkCondition checkOperator {

        require(amount > 0, "Treasury: cannot redeem bonds with zero amount");

        uint256 dollarPrice = getDollarUpdatedPrice();
        require(dollarPrice == targetPrice, "Treasury: dollar price moved");
        require(
            dollarPrice > dollarPriceCeiling, // price > $1.01
            "Treasury: dollarPrice not eligible for bond purchase"
        );
        require(IERC20(dollar).balanceOf(address(this)) >= amount, "Treasury: treasury has no more budget");

        seigniorageSaved = seigniorageSaved.sub(Math.min(seigniorageSaved, amount));

        IBasisAsset(bond).burnFrom(msg.sender, amount);
        IERC20(dollar).safeTransfer(msg.sender, amount);

        _updateDollarPriceCumulative();

        emit RedeemedBonds(msg.sender, amount);
    }

    function _sendToBoardRoom(uint256 _amount) internal {

        IBasisAsset(dollar).mint(address(this), _amount);
        if (epoch < bdip01SharedIncentiveForLpEpochs) {
            uint256 _addedPoolReward = _amount.mul(bdip01SharedIncentiveForLpPercent).div(40000);
            for (uint256 i = 0; i < 4; i++) {
                IERC20(dollar).transfer(bdip01LiquidityPools[i], _addedPoolReward);
                _amount = _amount.sub(_addedPoolReward);
            }
        }
        IERC20(dollar).safeApprove(boardroom, _amount);
        IBoardroom(boardroom).allocateSeigniorage(_amount);
        emit BoardroomFunded(now, _amount);
    }

    function allocateSeigniorage() external onlyOneBlock checkCondition checkEpoch checkOperator {

        _updateDollarPrice();
        uint256 dollarSupply = IERC20(dollar).totalSupply().sub(seigniorageSaved);
        if (epoch < bdip02BootstrapEpochs) {
            _sendToBoardRoom(dollarSupply.mul(bdip02BootstrapSupplyExpansionPercent).div(10000));
        } else {
            uint256 dollarPrice = getDollarPrice();
            if (dollarPrice > dollarPriceCeiling) {
                uint256 bondSupply = IERC20(bond).totalSupply();
                uint256 _percentage = dollarPrice.sub(dollarPriceOne);
                uint256 _savedForBond;
                uint256 _savedForBoardRoom;
                if (seigniorageSaved >= bondSupply.mul(bondDepletionFloorPercent).div(10000)) {
                    uint256 _mse = maxSupplyExpansionPercent.mul(1e14);
                    if (_percentage > _mse) {
                        _percentage = _mse;
                    }
                    _savedForBoardRoom = dollarSupply.mul(_percentage).div(1e18);
                } else {
                    uint256 _mse = maxSupplyExpansionPercent.mul(2e14);
                    if (_percentage > _mse) {
                        _percentage = _mse;
                    }
                    uint256 _seigniorage = dollarSupply.mul(_percentage).div(1e18);
                    _savedForBoardRoom = _seigniorage.mul(seigniorageExpansionFloorPercent).div(10000);
                    _savedForBond = _seigniorage.sub(_savedForBoardRoom);
                }
                if (_savedForBoardRoom > 0) {
                    _sendToBoardRoom(_savedForBoardRoom);
                }
                if (_savedForBond > 0) {
                    seigniorageSaved = seigniorageSaved.add(_savedForBond);
                    IBasisAsset(dollar).mint(address(this), _savedForBond);
                    emit TreasuryFunded(now, _savedForBond);
                }
            }
        }
        if (allocateSeigniorageSalary > 0) {
            IBasisAsset(dollar).mint(address(msg.sender), allocateSeigniorageSalary);
        }
    }

    function setAllocateSeigniorageSalary(uint256 _allocateSeigniorageSalary) external onlyOperator {

        require(_allocateSeigniorageSalary < 100 ether, "Treasury: dont pay too much");
        allocateSeigniorageSalary = _allocateSeigniorageSalary;
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {

        require(address(_token) != address(dollar), "dollar");
        require(address(_token) != address(bond), "bond");
        require(address(_token) != address(share), "share");
        _token.safeTransfer(_to, _amount);
    }


    function boardroomSetOperator(address _operator) external onlyOperator {

        IBoardroom(boardroom).setOperator(_operator);
    }

    function boardroomSetLockUp(uint256 _withdrawLockupEpochs, uint256 _rewardLockupEpochs) external onlyOperator {

        IBoardroom(boardroom).setLockUp(_withdrawLockupEpochs, _rewardLockupEpochs);
    }

    function boardroomAllocateSeigniorage(uint256 amount) external onlyOperator {

        IBoardroom(boardroom).allocateSeigniorage(amount);
    }

    function boardroomGovernanceRecoverUnsupported(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {

        IBoardroom(boardroom).governanceRecoverUnsupported(_token, _amount, _to);
    }
}