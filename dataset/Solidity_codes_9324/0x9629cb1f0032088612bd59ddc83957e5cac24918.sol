


pragma solidity 0.6.7;

abstract contract ESMThresholdSetter {
    function recomputeThreshold() virtual public;
}

abstract contract TokenLike {
    function totalSupply() virtual public view returns (uint256);
    function balanceOf(address) virtual public view returns (uint256);
    function transfer(address, uint256) virtual public returns (bool);
    function transferFrom(address, address, uint256) virtual public returns (bool);
}

abstract contract GlobalSettlementLike {
    function shutdownSystem() virtual public;
}

contract ESM {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) public isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) public isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "esm/account-not-authorized");
        _;
    }

    TokenLike            public protocolToken;      // collateral
    GlobalSettlementLike public globalSettlement;   // shutdown module
    ESMThresholdSetter   public thresholdSetter;    // threshold setter

    address              public tokenBurner;        // burner
    uint256              public triggerThreshold;   // threshold
    uint256              public settled;            // flag that indicates whether the shutdown module has been called/triggered

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(bytes32 parameter, uint256 wad);
    event ModifyParameters(bytes32 parameter, address account);
    event Shutdown();
    event FailRecomputeThreshold(bytes revertReason);

    constructor(
      address protocolToken_,
      address globalSettlement_,
      address tokenBurner_,
      address thresholdSetter_,
      uint256 triggerThreshold_
    ) public {
        require(both(triggerThreshold_ > 0, triggerThreshold_ < TokenLike(protocolToken_).totalSupply()), "esm/threshold-not-within-bounds");

        authorizedAccounts[msg.sender] = 1;

        protocolToken    = TokenLike(protocolToken_);
        globalSettlement = GlobalSettlementLike(globalSettlement_);
        thresholdSetter  = ESMThresholdSetter(thresholdSetter_);
        tokenBurner      = tokenBurner_;
        triggerThreshold = triggerThreshold_;

        emit AddAuthorization(msg.sender);
        emit ModifyParameters(bytes32("triggerThreshold"), triggerThreshold_);
        emit ModifyParameters(bytes32("thresholdSetter"), thresholdSetter_);
    }

    function addition(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x + y;
        require(z >= x);
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }
    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }

    function modifyParameters(bytes32 parameter, uint256 wad) external {

        require(settled == 0, "esm/already-settled");
        require(either(address(thresholdSetter) == msg.sender, authorizedAccounts[msg.sender] == 1), "esm/account-not-authorized");
        if (parameter == "triggerThreshold") {
          require(both(wad > 0, wad < protocolToken.totalSupply()), "esm/threshold-not-within-bounds");
          triggerThreshold = wad;
        }
        else revert("esm/modify-unrecognized-param");
        emit ModifyParameters(parameter, wad);
    }
    function modifyParameters(bytes32 parameter, address account) external isAuthorized {

        require(settled == 0, "esm/already-settled");
        if (parameter == "thresholdSetter") {
          thresholdSetter = ESMThresholdSetter(account);
          thresholdSetter.recomputeThreshold();
        }
        else revert("esm/modify-unrecognized-param");
        emit ModifyParameters(parameter, account);
    }

    function recomputeThreshold() internal {

        if (address(thresholdSetter) != address(0)) {
          try thresholdSetter.recomputeThreshold() {}
          catch(bytes memory revertReason) {
            emit FailRecomputeThreshold(revertReason);
          }
        }
    }
    function shutdown() external {

        require(settled == 0, "esm/already-settled");
        recomputeThreshold();
        settled = 1;
        require(protocolToken.transferFrom(msg.sender, tokenBurner, triggerThreshold), "esm/transfer-failed");
        emit Shutdown();
        globalSettlement.shutdownSystem();
    }
}