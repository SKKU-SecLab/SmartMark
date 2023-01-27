
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

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

contract MWT_interests is Ownable, ReentrancyGuard {


    using SafeMath for uint256;

    bytes32 midId; // mid term partition identifier
    bytes32 lngId; // long term partition identifier
    bytes32 perId; // perpetual partition identifier

    struct Balance {
        uint256 previousBalance;
        uint256 currentBalance;
        uint256 previousHolding;
        uint256 currentHolding;
        uint256 refereeBalance;
        uint256 customInterestRate;
    }

    struct Info {
        uint256 balanceInterests;        
        Balance mid;
        Balance lng;
        Balance per;
    }

    mapping (address => Info) investors;

    uint256 FLOAT_FACTOR = 100000000000000; // 10^14

    constructor(
        bytes32 _midId,
        bytes32 _lngId,
        bytes32 _perId
    )
    public
    {
        midId = _midId;
        lngId = _lngId;
        perId = _perId;
    }



    event Refered (
        address referer,
        address referee,
        uint256 midAmount,
        uint256 lngAmount,
        uint256 perAmount
    );

    event ModifiedReferee (
        address investor,
        bytes32 partitionId,
        uint256 amount
    );
    event ModifiedInterests (
        address investor,
        uint256 value
    );
    event UpdatedInterests (
        address investor,
        uint256 interests
    );
    event CustomizedInterests (
        address investor,
        uint256 midRate,
        uint256 lngRate,
        uint256 perRate
    );



    function interestsOf (address investor) external view returns (uint256) {
        return (investors[investor].balanceInterests);
    }

    function midtermBondInfosOf (address investor) external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            investors[investor].mid.previousBalance,
            investors[investor].mid.currentBalance,
            investors[investor].mid.previousHolding,
            investors[investor].mid.currentHolding,
            investors[investor].mid.refereeBalance,
            investors[investor].mid.customInterestRate
        );
    }

    function longtermBondInfosOf (address investor) external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            investors[investor].lng.previousBalance,
            investors[investor].lng.currentBalance,
            investors[investor].lng.previousHolding,
            investors[investor].lng.currentHolding,
            investors[investor].lng.refereeBalance,
            investors[investor].lng.customInterestRate
        );
    }

    function perpetualBondInfosOf (address investor) external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            investors[investor].per.previousBalance,
            investors[investor].per.currentBalance,
            investors[investor].per.previousHolding,
            investors[investor].per.currentHolding,
            investors[investor].per.refereeBalance,
            investors[investor].per.customInterestRate

        );
    }


    function setInterests (address investor, uint256 value) external onlyOwner nonReentrant {
        investors[investor].balanceInterests = value * FLOAT_FACTOR * 10000;

        emit ModifiedInterests (investor, value);
    }

    function setCustomInterestRate (address investor, uint256 midRate, uint256 lngRate, uint256 perRate) external onlyOwner {
        require(midRate <= 100 && lngRate <= 100 && perRate <= 100, "The rate is not a percentage");

        investors[investor].mid.customInterestRate = midRate * 100 * FLOAT_FACTOR;
        investors[investor].lng.customInterestRate = lngRate * 100 * FLOAT_FACTOR;
        investors[investor].per.customInterestRate = perRate * 100 * FLOAT_FACTOR;

        emit CustomizedInterests (investor, midRate, lngRate, perRate);
    }

    function updateReferralInfos (
        address referer,
        address referee,
        uint256 percent,
        uint256 midAmount,
        uint256 lngAmount,
        uint256 perAmount
    ) external onlyOwner {
        require (referer != referee && referer != address(0) && referee != address(0),
                 "Referee and/or referer address(es) is(/are) not valid.");
        require (percent >= 1 && percent <= 100, "The given percent parameter is not a valid percentage.");

        investors[referer].balanceInterests = investors[referer].balanceInterests.add(midAmount * percent * 100 * FLOAT_FACTOR);
        investors[referer].balanceInterests = investors[referer].balanceInterests.add(lngAmount * percent * 100 * FLOAT_FACTOR);
        investors[referer].balanceInterests = investors[referer].balanceInterests.add(perAmount * percent * 100 * FLOAT_FACTOR);

        investors[referee].mid.refereeBalance = investors[referee].mid.refereeBalance.add(midAmount);
        investors[referee].lng.refereeBalance = investors[referee].lng.refereeBalance.add(lngAmount);
        investors[referee].per.refereeBalance = investors[referee].per.refereeBalance.add(perAmount);

        emit Refered (referer, referee, midAmount, lngAmount, perAmount);
    }

    function setRefereeAmountByPartition (
        address investor,
        bytes32 partitionId,
        uint256 amount
    ) external onlyOwner {
        if ( partitionId == midId ) {
            investors[investor].mid.refereeBalance = amount;
        } else if ( partitionId == lngId ) {
            investors[investor].lng.refereeBalance = amount;
        } else if ( partitionId == perId ) {
            investors[investor].per.refereeBalance = amount;
        } else {
            revert("The partition identifier passed as parameter is not a valid one.");
        }

        emit ModifiedReferee (investor, partitionId, amount);
    }

    function updateInterests (address investor, uint256 midBalance, uint256 lngBalance, uint256 perBalance) external onlyOwner nonReentrant {
        investors[investor].mid.currentBalance = midBalance;
        investors[investor].lng.currentBalance = lngBalance;
        investors[investor].per.currentBalance = perBalance;

        if (investors[investor].mid.currentBalance > 0) {
            investors[investor].mid.currentHolding = investors[investor].mid.currentHolding.add(1000);
        }
        if (investors[investor].lng.currentBalance > 0) {
            if (investors[investor].lng.currentBalance > investors[investor].lng.previousBalance &&
                investors[investor].lng.previousBalance > 0) {
                uint256 adjustmentRate = (
                    (
                        investors[investor].lng.currentBalance.sub(investors[investor].lng.previousBalance)
                    ).mul(
                      FLOAT_FACTOR.div(
                        investors[investor].lng.currentBalance
                      )
                    )
                );
                investors[investor].lng.currentHolding = (
                  FLOAT_FACTOR.sub(adjustmentRate)
                ).mul(
                  (
                    investors[investor].lng.previousHolding.add(1000)
                  ).div(FLOAT_FACTOR)
                );
            }
            else {
                investors[investor].lng.currentHolding = investors[investor].lng.currentHolding.add(1000);
            }
        }
        if (investors[investor].per.currentBalance > 0) {
            if (investors[investor].per.currentBalance > investors[investor].per.previousBalance &&
                investors[investor].per.previousBalance > 0) {
                uint256 adjustmentRate = (
                    (
                        investors[investor].per.currentBalance.sub(investors[investor].per.previousBalance)
                    ).mul(FLOAT_FACTOR.div(investors[investor].per.currentBalance))
                );
                investors[investor].per.currentHolding = (
                  (
                    FLOAT_FACTOR.sub(adjustmentRate)
                  ).mul(
                    investors[investor].per.previousHolding.add(1000)
                  ).div(FLOAT_FACTOR)
                );
            }
            else {
                investors[investor].per.currentHolding = investors[investor].per.currentHolding.add(1000);
            }
        }

        if (investors[investor].mid.customInterestRate > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                investors[investor].mid.customInterestRate.mul(investors[investor].mid.currentBalance)
              ).div(12)
            );
        }
        if (investors[investor].lng.customInterestRate > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                investors[investor].lng.customInterestRate.mul(investors[investor].lng.currentBalance)
              ).div(12)
            );
        }
        if (investors[investor].per.customInterestRate > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                investors[investor].per.customInterestRate.mul(investors[investor].per.currentBalance)
              ).div(12)
            );
        }
        if (investors[investor].mid.customInterestRate == 0 &&
            investors[investor].lng.customInterestRate == 0 &&
            investors[investor].per.customInterestRate == 0) {
          _minterest(investor);
        }

        investors[investor].per.previousHolding = investors[investor].per.currentHolding;
        investors[investor].lng.previousHolding = investors[investor].lng.currentHolding;

        investors[investor].per.previousBalance = investors[investor].per.currentBalance;
        investors[investor].mid.previousBalance = investors[investor].mid.currentBalance;
        investors[investor].lng.previousBalance = investors[investor].lng.currentBalance;

        emit UpdatedInterests (investor, investors[investor].balanceInterests);
    }



    function _minterest (address investor) internal {
        uint256 midRate = FLOAT_FACTOR.mul(575);

        uint256 lngRate = 0;
        if (investors[investor].lng.currentBalance > 0) {
            if (investors[investor].lng.currentHolding < 12000) {
                if (investors[investor].lng.currentBalance < 800) {
                    lngRate = FLOAT_FACTOR.mul(700);
                }
                else if (investors[investor].lng.currentBalance < 2400) {
                    lngRate = FLOAT_FACTOR.mul(730);
                }
                else if (investors[investor].lng.currentBalance < 7200) {
                    lngRate = FLOAT_FACTOR.mul(749);
                }
                else {
                    lngRate = FLOAT_FACTOR.mul(760);
                }
            }
            else if (investors[investor].lng.currentHolding < 36000) {
                if (investors[investor].lng.currentBalance < 800) {
                    lngRate = FLOAT_FACTOR.mul(730);
                }
                else if (investors[investor].lng.currentBalance < 2400) {
                    lngRate = FLOAT_FACTOR.mul(745);
                }
                else if (investors[investor].lng.currentBalance < 7200) {
                    lngRate = FLOAT_FACTOR.mul(756);
                }
                else {
                    lngRate = FLOAT_FACTOR.mul(764);
                }
            }
            else if (investors[investor].lng.currentHolding < 72000) {
                if (investors[investor].lng.currentBalance < 800) {
                    lngRate = FLOAT_FACTOR.mul(749);
                }
                else if (investors[investor].lng.currentBalance < 2400) {
                    lngRate = FLOAT_FACTOR.mul(757);
                }
                else if (investors[investor].lng.currentBalance < 7200) {
                    lngRate = FLOAT_FACTOR.mul(763);
                }
                else {
                    lngRate = FLOAT_FACTOR.mul(767);
                }
            }
            else if (investors[investor].lng.currentHolding >= 72000) {
                if (investors[investor].lng.currentBalance < 800) {
                    lngRate = FLOAT_FACTOR.mul(760);
                }
                else if (investors[investor].lng.currentBalance < 2400) {
                    lngRate = FLOAT_FACTOR.mul(764);
                }
                else if (investors[investor].lng.currentBalance < 7200) {
                    lngRate = FLOAT_FACTOR.mul(767);
                }
                else if (investors[investor].lng.currentBalance >= 7200) {
                    lngRate = FLOAT_FACTOR.mul(770);
                }
            }
            assert(lngRate != 0);
        }

        uint256 perRate = 0;
        if (investors[investor].per.currentBalance > 0) {
            if (investors[investor].per.currentHolding < 12000) {
                if (investors[investor].per.currentBalance < 800) {
                    perRate = FLOAT_FACTOR.mul(850);
                }
                else if (investors[investor].per.currentBalance < 2400) {
                    perRate = FLOAT_FACTOR.mul(888);
                }
                else if (investors[investor].per.currentBalance < 7200) {
                    perRate = FLOAT_FACTOR.mul(911);
                }
                else if (investors[investor].per.currentBalance >= 7200) {
                    perRate = FLOAT_FACTOR.mul(925);
                }
            }
            else if (investors[investor].per.currentHolding < 36000) {
                if (investors[investor].per.currentBalance < 800) {
                    perRate = FLOAT_FACTOR.mul(888);
                }
                else if (investors[investor].per.currentBalance < 2400) {
                    perRate = FLOAT_FACTOR.mul(906);
                }
                else if (investors[investor].per.currentBalance < 7200) {
                    perRate = FLOAT_FACTOR.mul(919);
                }
                else if (investors[investor].per.currentBalance >= 7200) {
                    perRate = FLOAT_FACTOR.mul(930);
                }
            }
            else if (investors[investor].per.currentHolding < 72000) {
                if (investors[investor].per.currentBalance < 800) {
                    perRate = FLOAT_FACTOR.mul(911);
                }
                else if (investors[investor].per.currentBalance < 2400) {
                    perRate = FLOAT_FACTOR.mul(919);
                }
                else if (investors[investor].per.currentBalance < 7200) {
                    perRate = FLOAT_FACTOR.mul(927);
                }
                else if (investors[investor].per.currentBalance >= 7200) {
                    perRate = FLOAT_FACTOR.mul(934);
                }
            }
            else if (investors[investor].per.currentHolding >= 72000) {
                if (investors[investor].per.currentBalance < 800) {
                    perRate = FLOAT_FACTOR.mul(925);
                }
                else if (investors[investor].per.currentBalance < 2400) {
                    perRate = FLOAT_FACTOR.mul(930);
                }
                else if (investors[investor].per.currentBalance < 7200) {
                    perRate = FLOAT_FACTOR.mul(934);
                }
                else if (investors[investor].per.currentBalance >= 7200) {
                    perRate = FLOAT_FACTOR.mul(937);
                }
            }
            assert(perRate != 0);
        }

        if (investors[investor].mid.refereeBalance > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  midRate.mul(102)
                ).mul(investors[investor].mid.refereeBalance)
              ).div(1200)
            );
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  investors[investor].mid.currentBalance.sub(investors[investor].mid.refereeBalance)
                ).mul(midRate)
              ).div(12)
            );
        } else {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                investors[investor].mid.currentBalance.mul(midRate)
              ).div(12)
            );
        }

        if (investors[investor].lng.refereeBalance > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  lngRate.mul(102)
                ).mul(investors[investor].lng.refereeBalance)
              ).div(1200)
            );
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  investors[investor].lng.currentBalance.sub(investors[investor].lng.refereeBalance)
                ).mul(lngRate)
              ).div(12)
            );
        } else {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                lngRate.mul(investors[investor].lng.currentBalance)
              ).div(12)
            );
        }    

        if (investors[investor].per.refereeBalance > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  perRate.mul(investors[investor].per.refereeBalance)
                ).mul(102)
              ).div(1200)
            );
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  investors[investor].per.currentBalance.sub(investors[investor].per.refereeBalance)
                ).mul(perRate)
              ).div(12)
            );
        } else {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                perRate.mul(investors[investor].per.currentBalance)
              ).div(12)
            );
        }
    }
}