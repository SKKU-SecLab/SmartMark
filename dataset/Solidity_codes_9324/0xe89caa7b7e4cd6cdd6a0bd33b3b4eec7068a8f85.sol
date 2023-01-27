pragma solidity ^0.8.0;

interface IHEX {

    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address account) external view returns (uint256);


    function currentDay() external view returns (uint256);


    function stakeCount(address stakerAddr) external view returns (uint256);


    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external;


    function stakeLists(address, uint256)
        external
        view
        returns (
            uint40 stakeId,
            uint72 stakedHearts,
            uint72 stakeShares,
            uint16 lockedDay,
            uint16 stakedDays,
            uint16 unlockedDay,
            bool isAutoStake
        );


    function stakeStart(uint256 newStakedHearts, uint256 newStakedDays) external;


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool[] memory) {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        bytes memory encodedParams = abi.encodeWithSelector(IERC165(account).supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}// MIT
pragma solidity >=0.4.0;

library FullMath {

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);


        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        uint256 twos = (type(uint256).max - denominator + 1) & denominator;
        assembly {
            denominator := div(denominator, twos)
        }

        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        result = prod0 * inv;
        return result;
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.0;


abstract contract MinterReceiver is ERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(MinterReceiver).interfaceId || super.supportsInterface(interfaceId);
    }

    function onSharesMinted(
        uint40 stakeId,
        address supplier,
        uint72 stakedHearts,
        uint72 stakeShares
    ) external virtual;

    function onEarningsMinted(uint40 stakeId, uint72 heartsEarned) external virtual;
}// GPL-3.0-or-later
pragma solidity ^0.8.0;


contract ShareMinter {

    IHEX public hexContract;

    uint256 private constant GRACE_PERIOD_DAYS = 10;
    uint256 private constant FEE_SCALE = 1000;

    struct Stake {
        uint16 shareRatePremium;
        uint16 lockedDay;
        uint16 stakedDays;
        address minter;
        MinterReceiver receiver;
    }
    mapping(uint40 => Stake) public stakes;

    mapping(address => uint256) public minterHeartsOwed;

    event MintShares(
        uint40 indexed stakeId,
        address indexed minter,
        MinterReceiver indexed receiver,
        uint256 data0 //total shares | staked hearts << 72
    );
    event MintEarnings(uint40 indexed stakeId, address indexed caller, MinterReceiver indexed receiver, uint72 hearts);
    event MinterWithdraw(address indexed minter, uint256 heartsWithdrawn);

    uint256 private unlocked = 1;
    modifier lock() {

        require(unlocked == 1, "LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(IHEX _hex) {
        hexContract = _hex;
    }

    function mintShares(
        uint16 shareRatePremium,
        MinterReceiver receiver,
        address supplier,
        uint256 newStakedHearts,
        uint256 newStakedDays
    ) external lock {

        require(shareRatePremium < FEE_SCALE, "PREMIUM_TOO_HIGH");
        require(
            ERC165Checker.supportsInterface(address(receiver), type(MinterReceiver).interfaceId),
            "UNSUPPORTED_RECEIVER"
        );

        hexContract.transferFrom(msg.sender, address(this), newStakedHearts);

        (uint40 stakeId, uint72 stakedHearts, uint72 stakeShares, uint16 lockedDay, uint16 stakedDays) =
            _startStake(newStakedHearts, newStakedDays);

        uint256 minterShares = FullMath.mulDiv(shareRatePremium, stakeShares, FEE_SCALE);
        uint256 receiverShares = stakeShares - minterShares;

        receiver.onSharesMinted(stakeId, supplier, stakedHearts, uint72(receiverShares));
        stakes[stakeId] = Stake(shareRatePremium, lockedDay, stakedDays, msg.sender, receiver);

        emit MintShares(
            stakeId,
            msg.sender,
            receiver,
            uint256(uint72(stakeShares)) | (uint256(uint72(stakedHearts)) << 72)
        );
    }

    function _startStake(uint256 newStakedHearts, uint256 newStakedDays)
        internal
        returns (
            uint40 stakeId,
            uint72 stakedHearts,
            uint72 stakeShares,
            uint16 lockedDay,
            uint16 stakedDays
        )
    {

        hexContract.stakeStart(newStakedHearts, newStakedDays);
        uint256 stakeCount = hexContract.stakeCount(address(this));
        (uint40 _stakeId, uint72 _stakedHearts, uint72 _stakeShares, uint16 _lockedDay, uint16 _stakedDays, , ) =
            hexContract.stakeLists(address(this), stakeCount - 1);
        return (_stakeId, _stakedHearts, _stakeShares, _lockedDay, _stakedDays);
    }

    function mintEarnings(uint256 stakeIndex, uint40 stakeId) external lock {

        Stake memory stake = stakes[stakeId];
        require(stake.stakedDays != 0, "STAKE_NOT_FOUND");
        uint256 currentDay = hexContract.currentDay();
        uint256 lockedDay = uint256(stake.lockedDay);
        uint256 servedDays = currentDay > lockedDay ? currentDay - lockedDay : 0;
        uint256 stakedDays = uint256(stake.stakedDays);
        require(servedDays >= stakedDays, "STAKE_NOT_MATURE");

        uint256 heartsEarned = _endStake(stakeIndex, stakeId);
        uint256 minterEarnings = FullMath.mulDiv(stake.shareRatePremium, heartsEarned, FEE_SCALE);
        uint256 receiverEarnings = heartsEarned - minterEarnings;

        MinterReceiver receiver = stake.receiver;
        hexContract.transfer(address(receiver), receiverEarnings);
        receiver.onEarningsMinted(stakeId, uint72(receiverEarnings));

        _payMinterEarnings(servedDays - stakedDays, stake.minter, minterEarnings);

        emit MintEarnings(stakeId, msg.sender, receiver, uint72(heartsEarned));

        delete stakes[stakeId];
    }

    function _endStake(uint256 stakeIndex, uint40 stakeId) internal returns (uint256 heartsEarned) {

        uint256 prevHearts = hexContract.balanceOf(address(this));
        hexContract.stakeEnd(stakeIndex, stakeId);
        uint256 newHearts = hexContract.balanceOf(address(this));
        heartsEarned = newHearts - prevHearts;
    }

    function _payMinterEarnings(
        uint256 lateDays,
        address minter,
        uint256 minterEarnings
    ) internal {

        if (msg.sender != minter && lateDays <= GRACE_PERIOD_DAYS) {
            minterHeartsOwed[minter] += minterEarnings;
        } else {
            hexContract.transfer(msg.sender, minterEarnings);
        }
    }

    function minterWithdraw() external lock {

        uint256 heartsOwed = minterHeartsOwed[msg.sender];
        require(heartsOwed != 0, "NO_HEARTS_OWED");

        minterHeartsOwed[msg.sender] = 0;
        hexContract.transfer(msg.sender, heartsOwed);

        emit MinterWithdraw(msg.sender, heartsOwed);
    }
}