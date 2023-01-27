
pragma solidity ^0.8.0;

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
}// MIT

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

        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

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

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface ITreasury {

    function deposit(
        address _principalToken,
        uint _principalAmount,
        uint _payoutAmount
    ) external;


    function valueOfToken(address _principalToken, uint _amount) external view returns (uint value);

}// AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface ISafelyOwnable {

    function nominateNewOwner(address _owner) external;

    function acceptOwnership() external;

}// AGPL-3.0-or-later
pragma solidity ^0.8.4;


interface IVaderBond is ISafelyOwnable {

    function deposit(uint _amount, uint _maxPrice, address _depositor) external returns (uint);

    function initialize(
        uint _controlVariable,
        uint _vestingTerm,
        uint _minPrice,
        uint _maxPayout,
        uint _maxDebt,
        uint _initialDebt
    ) external;

}// AGPL-3.0-or-later
pragma solidity ^0.8.4;


contract SafelyOwnable is ISafelyOwnable {

    event OwnerNominated(address newOwner);
    event OwnerChanged(address newOwner);

    address public owner;
    address public nominatedOwner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "not owner");
        _;
    }

    function nominateNewOwner(address _owner) external override onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external override {

        require(msg.sender == nominatedOwner, "not nominated");

        owner = msg.sender;
        nominatedOwner = address(0);

        emit OwnerChanged(msg.sender);
    }
}// AGPL-3.0-or-later
pragma solidity ^0.8.4;


contract VaderBond is IVaderBond, SafelyOwnable, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint;

    enum PARAMETER {
        VESTING,
        PAYOUT,
        DEBT,
        MIN_PRICE
    }

    event Initialize(
        uint controlVariable,
        uint vestingTerm,
        uint minPrice,
        uint maxPayout,
        uint maxDebt,
        uint inititalDebt,
        uint lastDecay
    );
    event SetBondTerms(PARAMETER indexed param, uint input);
    event SetAdjustment(bool add, uint rate, uint target, uint buffer);
    event BondCreated(uint deposit, uint payout, uint expires);
    event BondRedeemed(address indexed recipient, uint payout, uint remaining);
    event BondPriceChanged(uint price, uint debtRatio);
    event ControlVariableAdjustment(
        uint initialBCV,
        uint newBCV,
        uint adjustment,
        bool addition
    );
    event TreasuryChanged(address treasury);

    uint8 private immutable PRINCIPAL_TOKEN_DECIMALS;
    uint8 private constant PAYOUT_TOKEN_DECIMALS = 18; // Vader has 18 decimals
    uint private constant MIN_PAYOUT = 10**PAYOUT_TOKEN_DECIMALS / 100; // 0.01
    uint private constant MAX_PERCENT_VESTED = 1e4; // 1 = 0.01%, 10000 = 100%
    uint private constant MAX_PAYOUT_DENOM = 1e5; // 100 = 0.1%, 100000 = 100%
    uint private constant MIN_VESTING_TERMS = 10000;

    IERC20 public immutable payoutToken; // token paid for principal
    IERC20 public immutable principalToken; // inflow token
    ITreasury public treasury; // pays for and receives principal

    Terms public terms; // stores terms for new bonds
    Adjust public adjustment; // stores adjustment to BCV data

    mapping(address => Bond) public bondInfo; // stores bond information for depositors

    uint public totalDebt; // total value of outstanding bonds
    uint public lastDecay; // reference block for debt decay

    struct Terms {
        uint controlVariable; // scaling variable for price
        uint vestingTerm; // in blocks
        uint minPrice; // vs principal value
        uint maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint maxDebt; // max debt, same decimals with payout token
    }
    struct Bond {
        uint payout; // payout token remaining to be paid
        uint vesting; // Blocks left to vest
        uint lastBlock; // Last interaction
    }
    struct Adjust {
        bool add; // addition or subtraction
        uint rate; // increment
        uint target; // BCV when adjustment finished
        uint buffer; // minimum length (in blocks) between adjustments
        uint lastBlock; // block when last adjustment made
    }

    constructor(
        address _treasury,
        address _payoutToken,
        address _principalToken
    ) {
        require(_treasury != address(0), "treasury = zero");
        treasury = ITreasury(_treasury);
        require(_payoutToken != address(0), "payout token = zero");
        payoutToken = IERC20(_payoutToken);
        require(_principalToken != address(0), "principal token = zero");
        principalToken = IERC20(_principalToken);

        PRINCIPAL_TOKEN_DECIMALS = IERC20Metadata(_principalToken).decimals();

        terms.vestingTerm = MIN_VESTING_TERMS;
    }

    function initialize(
        uint _controlVariable,
        uint _vestingTerm,
        uint _minPrice,
        uint _maxPayout,
        uint _maxDebt,
        uint _initialDebt
    ) external override onlyOwner {

        require(currentDebt() == 0, "debt > 0");

        require(_controlVariable > 0, "cv = 0");
        require(_vestingTerm >= MIN_VESTING_TERMS, "vesting < min");
        require(_maxPayout <= MAX_PAYOUT_DENOM / 100, "max payout > 1%");

        terms = Terms({
            controlVariable: _controlVariable,
            vestingTerm: _vestingTerm,
            minPrice: _minPrice,
            maxPayout: _maxPayout,
            maxDebt: _maxDebt
        });

        totalDebt = _initialDebt;
        lastDecay = block.number;

        emit Initialize(
            _controlVariable,
            _vestingTerm,
            _minPrice,
            _maxPayout,
            _maxDebt,
            _initialDebt,
            block.number
        );
    }

    function setBondTerms(PARAMETER _param, uint _input) external onlyOwner {

        if (_param == PARAMETER.VESTING) {
            require(_input >= MIN_VESTING_TERMS, "vesting < min");
            terms.vestingTerm = _input;
        } else if (_param == PARAMETER.PAYOUT) {
            require(_input <= MAX_PAYOUT_DENOM / 100, "max payout > 1%");
            terms.maxPayout = _input;
        } else if (_param == PARAMETER.DEBT) {
            terms.maxDebt = _input;
        } else if (_param == PARAMETER.MIN_PRICE) {
            terms.minPrice = _input;
        }
        emit SetBondTerms(_param, _input);
    }

    function setAdjustment(
        bool _add,
        uint _rate,
        uint _target,
        uint _buffer
    ) external onlyOwner {

        require(_rate <= terms.controlVariable.mul(3) / 100, "rate > 3%");

        if (_add) {
            require(_target >= terms.controlVariable, "target < cv");
        } else {
            require(_target <= terms.controlVariable, "target > cv");
        }
        adjustment = Adjust({
            add: _add,
            rate: _rate,
            target: _target,
            buffer: _buffer,
            lastBlock: block.number
        });
        emit SetAdjustment(_add, _rate, _target, _buffer);
    }

    function debtDecay() public view returns (uint decay) {

        uint blocksSinceLast = block.number.sub(lastDecay);
        decay = totalDebt.mul(blocksSinceLast).div(terms.vestingTerm);
        if (decay > totalDebt) {
            decay = totalDebt;
        }
    }

    function decayDebt() private {

        totalDebt = totalDebt.sub(debtDecay());
        lastDecay = block.number;
    }

    function currentDebt() public view returns (uint) {

        return totalDebt.sub(debtDecay());
    }

    function debtRatio() public view returns (uint) {

        return currentDebt().mul(1e18).div(payoutToken.totalSupply());
    }

    function bondPrice() public view returns (uint price) {

        price = terms.controlVariable.mul(debtRatio()) / 1e18;
        if (price < terms.minPrice) {
            price = terms.minPrice;
        }
    }

    function maxPayout() public view returns (uint) {

        return
            payoutToken.totalSupply().mul(terms.maxPayout) / MAX_PAYOUT_DENOM;
    }

    function payoutFor(uint _value) public view returns (uint) {

        return _value.mul(10**PRINCIPAL_TOKEN_DECIMALS).div(bondPrice());
    }

    function min(uint x, uint y) private returns (uint) {

        return x <= y ? x : y;
    }

    function max(uint x, uint y) private returns (uint) {

        return x >= y ? x : y;
    }

    function adjust() private {

        uint blockCanAdjust = adjustment.lastBlock.add(adjustment.buffer);
        if (adjustment.rate > 0 && block.number >= blockCanAdjust) {
            uint cv = terms.controlVariable;
            uint target = adjustment.target;
            if (adjustment.add) {
                terms.controlVariable = min(cv.add(adjustment.rate), target);
                if (terms.controlVariable >= target) {
                    adjustment.rate = 0;
                }
            } else {
                terms.controlVariable = max(cv.sub(adjustment.rate), target);
                if (terms.controlVariable <= target) {
                    adjustment.rate = 0;
                }
            }
            adjustment.lastBlock = block.number;
            emit ControlVariableAdjustment(
                cv,
                terms.controlVariable,
                adjustment.rate,
                adjustment.add
            );
        }
    }

    function deposit(
        uint _amount,
        uint _maxPrice,
        address _depositor
    ) external override nonReentrant returns (uint) {

        require(_depositor != address(0), "depositor = zero");
        require(_amount > 0, "amount = 0");

        decayDebt();
        require(totalDebt <= terms.maxDebt, "max debt");
        require(_maxPrice >= bondPrice(), "bond price > max");

        uint value = treasury.valueOfToken(address(principalToken), _amount);
        uint payout = payoutFor(value);

        require(payout >= MIN_PAYOUT, "payout < min");
        require(payout <= maxPayout(), "payout > max");

        principalToken.safeTransferFrom(msg.sender, address(this), _amount);
        principalToken.approve(address(treasury), _amount);
        treasury.deposit(address(principalToken), _amount, payout);

        totalDebt = totalDebt.add(value);

        bondInfo[_depositor] = Bond({
            payout: bondInfo[_depositor].payout.add(payout),
            vesting: terms.vestingTerm,
            lastBlock: block.number
        });

        emit BondCreated(_amount, payout, block.number.add(terms.vestingTerm));

        uint price = bondPrice();
        if (price > terms.minPrice && terms.minPrice > 0) {
            terms.minPrice = 0;
        }

        emit BondPriceChanged(price, debtRatio());

        adjust();
        return payout;
    }

    function percentVestedFor(address _depositor)
        public
        view
        returns (uint percentVested)
    {

        Bond memory bond = bondInfo[_depositor];
        uint blocksSinceLast = block.number.sub(bond.lastBlock);
        uint vesting = bond.vesting;
        if (vesting > 0) {
            percentVested = blocksSinceLast.mul(MAX_PERCENT_VESTED).div(
                vesting
            );
        }
    }

    function pendingPayoutFor(address _depositor) external view returns (uint) {

        uint percentVested = percentVestedFor(_depositor);
        uint payout = bondInfo[_depositor].payout;
        if (percentVested >= MAX_PERCENT_VESTED) {
            return payout;
        } else {
            return payout.mul(percentVested) / MAX_PERCENT_VESTED;
        }
    }

    function redeem(address _depositor) external nonReentrant returns (uint) {

        Bond memory info = bondInfo[_depositor];
        uint percentVested = percentVestedFor(_depositor);

        if (percentVested >= MAX_PERCENT_VESTED) {
            delete bondInfo[_depositor];
            emit BondRedeemed(_depositor, info.payout, 0);
            payoutToken.transfer(_depositor, info.payout);
            return info.payout;
        } else {
            uint payout = info.payout.mul(percentVested) / MAX_PERCENT_VESTED;

            bondInfo[_depositor] = Bond({
                payout: info.payout.sub(payout),
                vesting: info.vesting.sub(block.number.sub(info.lastBlock)),
                lastBlock: block.number
            });

            emit BondRedeemed(_depositor, payout, bondInfo[_depositor].payout);
            payoutToken.transfer(_depositor, payout);
            return payout;
        }
    }

    function setTreasury(address _treasury) external onlyOwner {

        require(_treasury != address(treasury), "no change");
        treasury = ITreasury(_treasury);
        emit TreasuryChanged(_treasury);
    }

    function recover(address _token) external onlyOwner {

        require(_token != address(payoutToken), "protected");
        IERC20(_token).safeTransfer(
            msg.sender,
            IERC20(_token).balanceOf(address(this))
        );
    }
}