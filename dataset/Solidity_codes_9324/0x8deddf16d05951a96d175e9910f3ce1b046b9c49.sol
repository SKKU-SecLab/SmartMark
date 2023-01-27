
pragma solidity 0.6.7;

contract GebAuth {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "GebAuth/account-not-authorized");
        _;
    }

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);

    constructor () public {
        authorizedAccounts[msg.sender] = 1;
        emit AddAuthorization(msg.sender);
    }
}

abstract contract TokenLike {
    function transfer(address, uint256) external virtual;
}

contract GebDaoMinimalTreasury is GebAuth {

    TokenLike immutable public token;
    address public treasuryDelegate;
    uint256 public epochLength;
    uint256 public delegateAllowance;
    uint256 internal delegateLeftoverToSpend_;
    uint256 public epochStart;

    constructor(
        address _token,
        address _delegate,
        uint256 _epochLength,
        uint256 _delegateAllowance
    ) public {
        require(_epochLength > 0, "GebDAOMinimalTreasury/invalid-epoch");
        require(_token != address(0), "GebDAOMinimalTreasury/invalid-epoch");
        token = TokenLike(_token);
        treasuryDelegate = _delegate;
        epochLength = _epochLength;
        delegateAllowance = _delegateAllowance;
        epochStart = now;
        delegateLeftoverToSpend_ = _delegateAllowance;
    }

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "GebDAOMinimalTreasury/add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "GebDAOMinimalTreasury/sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "GebDAOMinimalTreasury/mul-overflow");
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    function modifyParameters(bytes32 parameter, uint256 val) external isAuthorized {

        if (parameter == "epochLength") {
          require(val > 0, "GebDAOMinimalTreasury/invalid-epochLength");
          epochLength = val;
        }
        else if (parameter == "delegateAllowance") {
          delegateAllowance = val;
          if (val < delegateLeftoverToSpend_)
            delegateLeftoverToSpend_ = val;
        }
        else revert("GebDAOMinimalTreasury/modify-unrecognized-param");
    }

    function modifyParameters(bytes32 parameter, address val) external isAuthorized {

        if (parameter == "treasuryDelegate") {
          treasuryDelegate = val;
        }
        else revert("GebDAOMinimalTreasury/modify-unrecognized-param");
    }

    modifier updateEpoch() {

        uint256 epochFinish = add(epochStart, epochLength);
        if (now > epochFinish) {
            delegateLeftoverToSpend_ = delegateAllowance;
            if (now - epochFinish > epochLength) {
                uint256 epochsElapsed = sub(now, epochFinish) / epochLength;
                epochStart = add(mul(epochsElapsed, epochLength), epochFinish);
            } else
                epochStart = epochFinish;
        }
        _;
    }

    function delegateTransferERC20(address dst, uint256 amount) external updateEpoch {

        require(msg.sender == treasuryDelegate, "GebDAOMinimalTreasury/unauthorized");
        delegateLeftoverToSpend_ = sub(delegateLeftoverToSpend_, amount); // reverts if lower allowance
        token.transfer(dst, amount);
    }

    function transferERC20(address _token, address dst, uint256 amount) external isAuthorized {

        TokenLike(_token).transfer(dst, amount);
    }

    function delegateLeftoverToSpend() external view returns (uint256) {

        uint256 epochFinish = add(epochStart, epochLength);
        if (now > epochFinish)
            return delegateAllowance;
        else
            return delegateLeftoverToSpend_;
    }
}