

pragma solidity 0.5.7;

contract IBurnRateTable {


    struct TokenData {
        uint    tier;
        uint    validUntil;
    }

    mapping(address => TokenData) public tokens;

    uint public constant YEAR_TO_SECONDS = 31556952;

    uint8 public constant TIER_4 = 0;
    uint8 public constant TIER_3 = 1;
    uint8 public constant TIER_2 = 2;
    uint8 public constant TIER_1 = 3;

    uint16 public constant BURN_BASE_PERCENTAGE           =                 100 * 10; // 100%

    uint16 public constant TIER_UPGRADE_COST_PERCENTAGE   =                        1; // 0.1%

    uint16 public constant BURN_MATCHING_TIER1            =                       25; // 2.5%
    uint16 public constant BURN_MATCHING_TIER2            =                  15 * 10; //  15%
    uint16 public constant BURN_MATCHING_TIER3            =                  30 * 10; //  30%
    uint16 public constant BURN_MATCHING_TIER4            =                  50 * 10; //  50%
    uint16 public constant BURN_P2P_TIER1                 =                       25; // 2.5%
    uint16 public constant BURN_P2P_TIER2                 =                  15 * 10; //  15%
    uint16 public constant BURN_P2P_TIER3                 =                  30 * 10; //  30%
    uint16 public constant BURN_P2P_TIER4                 =                  50 * 10; //  50%

    event TokenTierUpgraded(
        address indexed addr,
        uint            tier
    );

    function getBurnRate(
        address token
        )
        external
        view
        returns (uint32 burnRate);


    function getTokenTier(
        address token
        )
        public
        view
        returns (uint);


    function upgradeTokenTier(
        address token
        )
        external
        returns (bool);


}




contract ERC20 {

    function totalSupply()
        public
        view
        returns (uint256);


    function balanceOf(
        address who
        )
        public
        view
        returns (uint256);


    function allowance(
        address owner,
        address spender
        )
        public
        view
        returns (uint256);


    function transfer(
        address to,
        uint256 value
        )
        public
        returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
        )
        public
        returns (bool);


    function approve(
        address spender,
        uint256 value
        )
        public
        returns (bool);

}




library ERC20SafeTransfer {


    function safeTransfer(
        address token,
        address to,
        uint256 value)
        internal
        returns (bool success)
    {


        bytes memory callData = abi.encodeWithSelector(
            bytes4(0xa9059cbb),
            to,
            value
        );
        (success, ) = token.call(callData);
        return checkReturnValue(success);
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value)
        internal
        returns (bool success)
    {


        bytes memory callData = abi.encodeWithSelector(
            bytes4(0x23b872dd),
            from,
            to,
            value
        );
        (success, ) = token.call(callData);
        return checkReturnValue(success);
    }

    function checkReturnValue(
        bool success
        )
        internal
        pure
        returns (bool)
    {

        if (success) {
            assembly {
                switch returndatasize()
                case 0 {
                    success := 1
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
                default {
                    success := 0
                }
            }
        }
        return success;
    }

}




library MathUint {


    function mul(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {

        c = a * b;
        require(a == 0 || c / a == b, "INVALID_VALUE");
    }

    function sub(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint)
    {

        require(b <= a, "INVALID_VALUE");
        return a - b;
    }

    function add(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {

        c = a + b;
        require(c >= a, "INVALID_VALUE");
    }

    function hasRoundingError(
        uint value,
        uint numerator,
        uint denominator
        )
        internal
        pure
        returns (bool)
    {

        uint multiplied = mul(value, numerator);
        uint remainder = multiplied % denominator;
        return mul(remainder, 100) > multiplied;
    }
}




contract Errors {

    string constant ZERO_VALUE                 = "ZERO_VALUE";
    string constant ZERO_ADDRESS               = "ZERO_ADDRESS";
    string constant INVALID_VALUE              = "INVALID_VALUE";
    string constant INVALID_ADDRESS            = "INVALID_ADDRESS";
    string constant INVALID_SIZE               = "INVALID_SIZE";
    string constant INVALID_SIG                = "INVALID_SIG";
    string constant INVALID_STATE              = "INVALID_STATE";
    string constant NOT_FOUND                  = "NOT_FOUND";
    string constant ALREADY_EXIST              = "ALREADY_EXIST";
    string constant REENTRY                    = "REENTRY";
    string constant UNAUTHORIZED               = "UNAUTHORIZED";
    string constant UNIMPLEMENTED              = "UNIMPLEMENTED";
    string constant UNSUPPORTED                = "UNSUPPORTED";
    string constant TRANSFER_FAILURE           = "TRANSFER_FAILURE";
    string constant WITHDRAWAL_FAILURE         = "WITHDRAWAL_FAILURE";
    string constant BURN_FAILURE               = "BURN_FAILURE";
    string constant BURN_RATE_FROZEN           = "BURN_RATE_FROZEN";
    string constant BURN_RATE_MINIMIZED        = "BURN_RATE_MINIMIZED";
    string constant UNAUTHORIZED_ONCHAIN_ORDER = "UNAUTHORIZED_ONCHAIN_ORDER";
    string constant INVALID_CANDIDATE          = "INVALID_CANDIDATE";
    string constant ALREADY_VOTED              = "ALREADY_VOTED";
    string constant NOT_OWNER                  = "NOT_OWNER";
}





contract NoDefaultFunc is Errors {

    function ()
        external
        payable
    {
        revert(UNSUPPORTED);
    }
}










contract BurnRateTable is IBurnRateTable, NoDefaultFunc {

    using MathUint for uint;
    using ERC20SafeTransfer for address;

    address public lrcAddress = address(0x0);

    constructor(
        address _lrcAddress,
        address _wethAddress
        )
        public
    {
        require(_lrcAddress != address(0x0), ZERO_ADDRESS);
        lrcAddress = _lrcAddress;

        setFixedTokenTier(lrcAddress, TIER_1);
    }

    function setFixedTokenTier(
        address token,
        uint tier
        )
        internal
    {

        TokenData storage tokenData = tokens[token];
        tokenData.validUntil = ~uint(0);
        tokenData.tier = tier;
    }

    function getBurnRate(
        address token
        )
        external
        view
        returns (uint32 burnRate)
    {

        uint tier = getTokenTier(token);
        if (tier == TIER_1) {
            burnRate = uint32(BURN_P2P_TIER1) * 0x10000 + BURN_MATCHING_TIER1;
        } else if (tier == TIER_2) {
            burnRate = uint32(BURN_P2P_TIER2) * 0x10000 + BURN_MATCHING_TIER2;
        } else if (tier == TIER_3) {
            burnRate = uint32(BURN_P2P_TIER3) * 0x10000 + BURN_MATCHING_TIER3;
        } else {
            burnRate = uint32(BURN_P2P_TIER4) * 0x10000 + BURN_MATCHING_TIER4;
        }
    }

    function upgradeTokenTier(
        address token
        )
        external
        returns (bool)
    {

        require(token != address(0x0), ZERO_ADDRESS);
        require(token != lrcAddress, BURN_RATE_FROZEN);

        uint currentTier = getTokenTier(token);

        require(currentTier != TIER_1, BURN_RATE_MINIMIZED);

        ERC20 LRC = ERC20(lrcAddress);
        uint totalSupply = LRC.totalSupply() - LRC.balanceOf(address(0x0));
        uint amount = totalSupply.mul(TIER_UPGRADE_COST_PERCENTAGE) / BURN_BASE_PERCENTAGE;
        require(
            lrcAddress.safeTransferFrom(
                msg.sender,
                address(0x0),
                amount
            ),
            BURN_FAILURE
        );

        TokenData storage tokenData = tokens[token];
        tokenData.validUntil = now.add(YEAR_TO_SECONDS);
        tokenData.tier = currentTier + 1;

        emit TokenTierUpgraded(token, tokenData.tier);

        return true;
    }

    function getTokenTier(
        address token
        )
        public
        view
        returns (uint tier)
    {

        TokenData storage tokenData = tokens[token];
        tier = (now > tokenData.validUntil) ? TIER_1 : tokenData.tier;
    }

}