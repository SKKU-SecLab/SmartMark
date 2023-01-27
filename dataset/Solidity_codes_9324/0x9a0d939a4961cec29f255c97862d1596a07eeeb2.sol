


pragma solidity 0.7.5;

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

    function sqrrt(uint256 a) internal pure returns (uint256 c) {

        if (a > 3) {
            c = a;
            uint256 b = add(div(a, 2), 1);
            while (b < c) {
                c = b;
                b = div(add(div(a, b), b), 2);
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}


pragma solidity 0.7.5;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
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

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

    function addressToString(address _address)
        internal
        pure
        returns (string memory)
    {

        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = "0";
        _addr[1] = "x";

        for (uint256 i = 0; i < 20; i++) {
            _addr[2 + i * 2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3 + i * 2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);
    }
}


pragma solidity 0.7.5;

interface IERC20 {

    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


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


pragma solidity 0.7.5;

library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
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

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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


pragma solidity 0.7.5;

library FullMath {

    function fullMul(uint256 x, uint256 y)
        private
        pure
        returns (uint256 l, uint256 h)
    {

        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {

        uint256 pow2 = d & -d;
        d /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {

        (uint256 l, uint256 h) = fullMul(x, y);
        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        require(h < d, "FullMath::mulDiv: overflow");
        return fullDiv(l, h, d);
    }
}


pragma solidity 0.7.5;

library Babylonian {

    function sqrt(uint256 x) internal pure returns (uint256) {

        if (x == 0) return 0;

        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}

library BitMath {

    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {

        require(x > 0, "BitMath::mostSignificantBit: zero");

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }
}

library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = 0x10000000000000000000000000000;
    uint256 private constant Q224 =
        0x100000000000000000000000000000000000000000000000000000000;
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);
    }

    function decode112with18(uq112x112 memory self)
        internal
        pure
        returns (uint256)
    {

        return uint256(self._x) / 5192296858534827;
    }

    function fraction(uint256 numerator, uint256 denominator)
        internal
        pure
        returns (uq112x112 memory)
    {

        require(denominator > 0, "FixedPoint::fraction: division by zero");
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= uint144(-1)) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= uint224(-1), "FixedPoint::fraction: overflow");
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= uint224(-1), "FixedPoint::fraction: overflow");
            return uq112x112(uint224(result));
        }
    }

    function sqrt(uq112x112 memory self)
        internal
        pure
        returns (uq112x112 memory)
    {

        if (self._x <= uint144(-1)) {
            return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << 112)));
        }

        uint8 safeShiftBits = 255 - BitMath.mostSignificantBit(self._x);
        safeShiftBits -= safeShiftBits % 2;
        return
            uq112x112(
                uint224(
                    Babylonian.sqrt(uint256(self._x) << safeShiftBits) <<
                        ((112 - safeShiftBits) / 2)
                )
            );
    }
}


pragma solidity 0.7.5;

contract Ownable {

    address public policy;

    constructor() {
        policy = msg.sender;
    }

    modifier onlyPolicy() {

        require(policy == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferManagment(address _newOwner) external onlyPolicy {

        require(_newOwner != address(0));
        policy = _newOwner;
    }
}


pragma solidity 0.7.5;

interface ITreasury {

    function deposit(
        address _principleTokenAddress,
        uint256 _amountPrincipleToken,
        uint256 _amountPayoutToken
    ) external;


    function valueOfToken(address _principalTokenAddress, uint256 _amount)
        external
        view
        returns (uint256 value_);


    function payoutToken() external view returns (address);

}

contract CustomGOSHBond is Ownable {

    using FixedPoint for *;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    event BondCreated(uint256 deposit, uint256 payout, uint256 expires);
    event BondRedeemed(address recipient, uint256 payout, uint256 remaining);
    event BondPriceChanged(uint256 internalPrice, uint256 debtRatio);
    event ControlVariableAdjustment(
        uint256 initialBCV,
        uint256 newBCV,
        uint256 adjustment,
        bool addition
    );


    IERC20 immutable payoutToken; // token paid for principal
    IERC20 immutable principalToken; // inflow token
    ITreasury immutable customTreasury; // pays for and receives principal
    address immutable olympusDAO;
    address olympusTreasury; // receives fee
    address immutable subsidyRouter; // pays subsidy in OHM to custom treasury

    uint256 public totalPrincipalBonded;
    uint256 public totalPayoutGiven;
    uint256 public totalDebt; // total value of outstanding bonds; used for pricing
    uint256 public lastDecay; // reference block for debt decay
    uint256 payoutSinceLastSubsidy; // principal accrued since subsidy paid

    Terms public terms; // stores terms for new bonds
    Adjust public adjustment; // stores adjustment to BCV data
    FeeTiers[] private feeTiers; // stores fee tiers

    bool private immutable feeInPayout;

    mapping(address => Bond) public bondInfo; // stores bond information for depositors


    struct FeeTiers {
        uint256 tierCeilings; // principal bonded till next tier
        uint256 fees; // in ten-thousandths (i.e. 33300 = 3.33%)
    }

    struct Terms {
        uint256 controlVariable; // scaling variable for price
        uint256 vestingTerm; // in blocks
        uint256 minimumPrice; // vs principal value
        uint256 maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint256 maxDebt; // payout token decimal debt ratio, max % total supply created as debt
    }

    struct Bond {
        uint256 payout; // payout token remaining to be paid
        uint256 vesting; // Blocks left to vest
        uint256 lastBlock; // Last interaction
        uint256 truePricePaid; // Price paid (principal tokens per payout token) in ten-millionths - 4000000 = 0.4
    }

    struct Adjust {
        bool add; // addition or subtraction
        uint256 rate; // increment
        uint256 target; // BCV when adjustment finished
        uint256 buffer; // minimum length (in blocks) between adjustments
        uint256 lastBlock; // block when last adjustment made
    }


    constructor(
        address _customTreasury,
        address _principalToken,
        address _olympusTreasury,
        address _subsidyRouter,
        address _initialOwner,
        address _olympusDAO,
        uint256[] memory _tierCeilings,
        uint256[] memory _fees,
        bool _feeInPayout
    ) {
        require(_customTreasury != address(0));
        customTreasury = ITreasury(_customTreasury);
        payoutToken = IERC20(ITreasury(_customTreasury).payoutToken());
        require(_principalToken != address(0));
        principalToken = IERC20(_principalToken);
        require(_olympusTreasury != address(0));
        olympusTreasury = _olympusTreasury;
        require(_subsidyRouter != address(0));
        subsidyRouter = _subsidyRouter;
        require(_initialOwner != address(0));
        policy = _initialOwner;
        require(_olympusDAO != address(0));
        olympusDAO = _olympusDAO;
        require(
            _tierCeilings.length == _fees.length,
            "tier length and fee length not the same"
        );

        for (uint256 i; i < _tierCeilings.length; i++) {
            feeTiers.push(
                FeeTiers({tierCeilings: _tierCeilings[i], fees: _fees[i]})
            );
        }

        feeInPayout = _feeInPayout;
    }


    function initializeBond(
        uint256 _controlVariable,
        uint256 _vestingTerm,
        uint256 _minimumPrice,
        uint256 _maxPayout,
        uint256 _maxDebt,
        uint256 _initialDebt
    ) external onlyPolicy {

        require(currentDebt() == 0, "Debt must be 0 for initialization");
        terms = Terms({
            controlVariable: _controlVariable,
            vestingTerm: _vestingTerm,
            minimumPrice: _minimumPrice,
            maxPayout: _maxPayout,
            maxDebt: _maxDebt
        });
        totalDebt = _initialDebt;
        lastDecay = block.number;
    }


    enum PARAMETER {
        VESTING,
        PAYOUT,
        DEBT
    }

    function setBondTerms(PARAMETER _parameter, uint256 _input)
        external
        onlyPolicy
    {

        if (_parameter == PARAMETER.VESTING) {
            require(_input >= 10000, "Vesting must be longer than 36 hours");
            terms.vestingTerm = _input;
        } else if (_parameter == PARAMETER.PAYOUT) {
            require(_input <= 1000, "Payout cannot be above 1 percent");
            terms.maxPayout = _input;
        } else if (_parameter == PARAMETER.DEBT) {
            terms.maxDebt = _input;
        }
    }

    function setAdjustment(
        bool _addition,
        uint256 _increment,
        uint256 _target,
        uint256 _buffer
    ) external onlyPolicy {

        require(
            _increment <= terms.controlVariable.mul(30).div(1000),
            "Increment too large"
        );

        adjustment = Adjust({
            add: _addition,
            rate: _increment,
            target: _target,
            buffer: _buffer,
            lastBlock: block.number
        });
    }

    function changeOlympusTreasury(address _olympusTreasury) external {

        require(msg.sender == olympusDAO, "Only Olympus DAO");
        olympusTreasury = _olympusTreasury;
    }

    function paySubsidy() external returns (uint256 payoutSinceLastSubsidy_) {

        require(msg.sender == subsidyRouter, "Only subsidy controller");

        payoutSinceLastSubsidy_ = payoutSinceLastSubsidy;
        payoutSinceLastSubsidy = 0;
    }


    function deposit(
        uint256 _amount,
        uint256 _maxPrice,
        address _depositor
    ) external returns (uint256) {

        require(_depositor != address(0), "Invalid address");
        decayDebt();
        uint256 nativePrice = trueBondPrice();
        require(
            _maxPrice >= nativePrice,
            "Slippage limit: more than max price"
        ); // slippage protection

        uint256 value = customTreasury.valueOfToken(
            address(principalToken),
            _amount
        );

        uint256 payout;
        uint256 fee;
        if (feeInPayout) {
            (payout, fee) = payoutFor(value); // payout to bonder is computed
        } else {
            (payout, fee) = payoutFor(_amount); // payout to bonder is computed
            _amount = _amount.sub(fee); 
        }

        require(payout >= 10**payoutToken.decimals() / 100, "Bond too small"); // must be > 0.01 payout token ( underflow protection )
        require(payout <= maxPayout(), "Bond too large"); // size protection because there is no slippage

        totalDebt = totalDebt.add(value);
        require(totalDebt <= terms.maxDebt, "Max capacity reached");

        bondInfo[_depositor] = Bond({
            payout: bondInfo[_depositor].payout.add(payout),
            vesting: terms.vestingTerm,
            lastBlock: block.number,
            truePricePaid: trueBondPrice()
        });

        totalPrincipalBonded = totalPrincipalBonded.add(_amount); // total bonded increased
        totalPayoutGiven = totalPayoutGiven.add(payout); // total payout increased
        payoutSinceLastSubsidy = payoutSinceLastSubsidy.add(payout); // subsidy counter increased

        principalToken.approve(address(customTreasury), _amount);
        if (feeInPayout) {
            principalToken.safeTransferFrom(msg.sender, address(this), _amount);
            customTreasury.deposit(
                address(principalToken),
                _amount,
                payout.add(fee)
            );
        } else {
            principalToken.safeTransferFrom(
                msg.sender,
                address(this),
                _amount.add(fee) 
            );
            customTreasury.deposit(address(principalToken), _amount, payout);
        }
        if (fee != 0) {
            if (feeInPayout) {
                payoutToken.safeTransfer(olympusTreasury, fee);
            } else {
                principalToken.safeTransfer(olympusTreasury, fee);
            }
        }

        emit BondCreated(_amount, payout, block.number.add(terms.vestingTerm));
        emit BondPriceChanged(_bondPrice(), debtRatio());

        adjust(); // control variable is adjusted
        return payout;
    }

    function redeem(address _depositor) external returns (uint256) {

        Bond memory info = bondInfo[_depositor];
        uint256 percentVested = percentVestedFor(_depositor); // (blocks since last interaction / vesting term remaining)

        if (percentVested >= 10000) {
            delete bondInfo[_depositor]; // delete user info
            emit BondRedeemed(_depositor, info.payout, 0); // emit bond data
            payoutToken.safeTransfer(_depositor, info.payout);
            return info.payout;
        } else {
            uint256 payout = info.payout.mul(percentVested).div(10000);

            bondInfo[_depositor] = Bond({
                payout: info.payout.sub(payout),
                vesting: info.vesting.sub(block.number.sub(info.lastBlock)),
                lastBlock: block.number,
                truePricePaid: info.truePricePaid
            });

            emit BondRedeemed(_depositor, payout, bondInfo[_depositor].payout);
            payoutToken.safeTransfer(_depositor, payout);
            return payout;
        }
    }


    function adjust() internal {

        uint256 blockCanAdjust = adjustment.lastBlock.add(adjustment.buffer);
        if (adjustment.rate != 0 && block.number >= blockCanAdjust) {
            uint256 initial = terms.controlVariable;
            if (adjustment.add) {
                terms.controlVariable = terms.controlVariable.add(
                    adjustment.rate
                );
                if (terms.controlVariable >= adjustment.target) {
                    adjustment.rate = 0;
                }
            } else {
                terms.controlVariable = terms.controlVariable.sub(
                    adjustment.rate
                );
                if (terms.controlVariable <= adjustment.target) {
                    adjustment.rate = 0;
                }
            }
            adjustment.lastBlock = block.number;
            emit ControlVariableAdjustment(
                initial,
                terms.controlVariable,
                adjustment.rate,
                adjustment.add
            );
        }
    }

    function decayDebt() internal {

        totalDebt = totalDebt.sub(debtDecay());
        lastDecay = block.number;
    }

    function _bondPrice() internal returns (uint256 price_) {

        price_ = terms.controlVariable.mul(debtRatio()).div(
            10**(uint256(payoutToken.decimals()).sub(5))
        );
        if (price_ < terms.minimumPrice) {
            price_ = terms.minimumPrice;
        } else if (terms.minimumPrice != 0) {
            terms.minimumPrice = 0;
        }
    }


    function bondPrice() public view returns (uint256 price_) {

        price_ = terms.controlVariable.mul(debtRatio()).div(
            10**(uint256(payoutToken.decimals()).sub(5))
        );
        if (price_ < terms.minimumPrice) {
            price_ = terms.minimumPrice;
        }
    }

    function trueBondPrice() public view returns (uint256 price_) {

        price_ = bondPrice().add(bondPrice().mul(currentOlympusFee()).div(1e6));
    }

    function maxPayout() public view returns (uint256) {

        return payoutToken.totalSupply().mul(terms.maxPayout).div(100000);
    }

    function payoutFor(uint256 _value)
        public
        view
        returns (uint256 _payout, uint256 _fee)
    {

        if (!feeInPayout) {
            _fee = _value.mul(currentOlympusFee()).div(1e6);
            _payout = FixedPoint
                .fraction(
                    customTreasury.valueOfToken(
                        address(principalToken),
                        _value.sub(_fee)
                    ),
                    bondPrice()
                )
                .decode112with18()
                .div(1e11);
        } else {
            uint256 total = FixedPoint
                .fraction(_value, bondPrice())
                .decode112with18()
                .div(1e11);
            _payout = total.sub(total.mul(currentOlympusFee()).div(1e6));
            _fee = total.mul(currentOlympusFee()).div(1e6);
        }
    }

    function debtRatio() public view returns (uint256 debtRatio_) {

        debtRatio_ = FixedPoint
            .fraction(
                currentDebt().mul(10**payoutToken.decimals()),
                payoutToken.totalSupply()
            )
            .decode112with18()
            .div(1e18);
    }

    function currentDebt() public view returns (uint256) {

        return totalDebt.sub(debtDecay());
    }

    function debtDecay() public view returns (uint256 decay_) {

        uint256 blocksSinceLast = block.number.sub(lastDecay);
        decay_ = totalDebt.mul(blocksSinceLast).div(terms.vestingTerm);
        if (decay_ > totalDebt) {
            decay_ = totalDebt;
        }
    }

    function percentVestedFor(address _depositor)
        public
        view
        returns (uint256 percentVested_)
    {

        Bond memory bond = bondInfo[_depositor];
        uint256 blocksSinceLast = block.number.sub(bond.lastBlock);
        uint256 vesting = bond.vesting;

        if (vesting > 0) {
            percentVested_ = blocksSinceLast.mul(10000).div(vesting);
        } else {
            percentVested_ = 0;
        }
    }

    function pendingPayoutFor(address _depositor)
        external
        view
        returns (uint256 pendingPayout_)
    {

        uint256 percentVested = percentVestedFor(_depositor);
        uint256 payout = bondInfo[_depositor].payout;

        if (percentVested >= 10000) {
            pendingPayout_ = payout;
        } else {
            pendingPayout_ = payout.mul(percentVested).div(10000);
        }
    }

    function currentOlympusFee() public view returns (uint256 currentFee_) {

        uint256 tierLength = feeTiers.length;
        for (uint256 i; i < tierLength; i++) {
            if (
                totalPrincipalBonded < feeTiers[i].tierCeilings ||
                i == tierLength - 1
            ) {
                return feeTiers[i].fees;
            }
        }
    }
}