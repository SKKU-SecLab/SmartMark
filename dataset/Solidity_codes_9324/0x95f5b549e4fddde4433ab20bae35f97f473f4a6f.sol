
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


abstract contract TaxCollectorLike {
    function modifyParameters(
        bytes32 collateralType,
        bytes32 parameter,
        uint256 data
    ) virtual external;
    function taxSingle(bytes32) virtual public returns (uint256);
}
contract MinimalTaxCollectorOverlay is GebAuth {

    mapping(bytes32 => Bounds) public stabilityFeeBounds;
    TaxCollectorLike           public taxCollector;

    struct Bounds {
        uint256 upperBound;  // [ray]
        uint256 lowerBound;  // [ray]
    }

    constructor(
      address taxCollector_,
      bytes32[] memory collateralTypes,
      uint256[] memory lowerBounds,
      uint256[] memory upperBounds
    ) public {
        require(taxCollector_ != address(0), "MinimalTaxCollectorOverlay/null-address");
        require(both(collateralTypes.length == lowerBounds.length, lowerBounds.length == upperBounds.length), "MinimalTaxCollectorOverlay/invalid-array-lengths");
        require(collateralTypes.length > 0, "MinimalTaxCollectorOverlay/null-array-lengths");

        taxCollector = TaxCollectorLike(taxCollector_);

        for (uint i = 0; i < collateralTypes.length; i++) {
            require(
              both(stabilityFeeBounds[collateralTypes[i]].upperBound == 0, stabilityFeeBounds[collateralTypes[i]].lowerBound == 0),
              "MinimalTaxCollectorOverlay/bounds/already-set"
            );
            require(both(lowerBounds[i] >= RAY, upperBounds[i] >= lowerBounds[i]), "MinimalTaxCollectorOverlay/invalid-bounds");
            stabilityFeeBounds[collateralTypes[i]] = Bounds(upperBounds[i], lowerBounds[i]);
        }
    }

    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }

    uint256 public constant RAY = 10 ** 27;

    function modifyParameters(
        bytes32 collateralType,
        bytes32 parameter,
        uint256 data
    ) external isAuthorized {

        uint256 lowerBound = stabilityFeeBounds[collateralType].lowerBound;
        uint256 upperBound = stabilityFeeBounds[collateralType].upperBound;
        require(
          both(upperBound >= lowerBound, lowerBound >= RAY),
          "MinimalTaxCollectorOverlay/bounds-improperly-set"
        );
        require(both(data <= upperBound, data >= lowerBound), "MinimalTaxCollectorOverlay/fee-exceeds-bounds");
        require(parameter == "stabilityFee", "MinimalTaxCollectorOverlay/invalid-parameter");
        taxCollector.taxSingle(collateralType);
        taxCollector.modifyParameters(collateralType, parameter, data);
    }
}