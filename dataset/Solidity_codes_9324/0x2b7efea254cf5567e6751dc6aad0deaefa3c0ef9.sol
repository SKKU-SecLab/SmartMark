pragma solidity 0.8.11;

abstract contract VersionedInitializable {
  uint256 private lastInitializedRevision = 0;

  bool private initializing;

  modifier initializer() {
    uint256 revision = getRevision();
    require(
      initializing || isConstructor() || revision > lastInitializedRevision,
      'Contract instance has already been initialized'
    );

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      lastInitializedRevision = revision;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function getRevision() internal pure virtual returns (uint256);

  function isConstructor() private view returns (bool) {
    uint256 cs;
    assembly {
      cs := extcodesize(address())
    }
    return cs == 0;
  }

  uint256[50] private ______gap;
}// MIT

pragma solidity ^0.8.0;

interface INFTXEligibility {

    function name() external pure returns (string memory);

    function finalized() external view returns (bool);

    function targetAsset() external pure returns (address);

    function checkAllEligible(uint256[] calldata tokenIds)
        external
        view
        returns (bool);

    function checkEligible(uint256[] calldata tokenIds)
        external
        view
        returns (bool[] memory);

    function checkAllIneligible(uint256[] calldata tokenIds)
        external
        view
        returns (bool);

    function checkIsEligible(uint256 tokenId) external view returns (bool);


    function __NFTXEligibility_init_bytes(bytes calldata configData) external;

    function beforeMintHook(uint256[] calldata tokenIds) external;

    function afterMintHook(uint256[] calldata tokenIds) external;

    function beforeRedeemHook(uint256[] calldata tokenIds) external;

    function afterRedeemHook(uint256[] calldata tokenIds) external;

    function afterLiquidationHook(uint256[] calldata tokenIds, uint256[] calldata amounts) external;

}// MIT

pragma solidity ^0.8.0;


abstract contract NFTXEligibility is INFTXEligibility, VersionedInitializable {

  function name() public pure override virtual returns (string memory);
  function finalized() public view override virtual returns (bool);
  function targetAsset() public pure override virtual returns (address);
  
  function __NFTXEligibility_init_bytes(bytes memory initData) public override virtual;

  function checkIsEligible(uint256 tokenId) external view override virtual returns (bool) {
      return _checkIfEligible(tokenId);
  }

  function checkEligible(uint256[] calldata tokenIds) external override virtual view returns (bool[] memory) {
      bool[] memory eligibile = new bool[](tokenIds.length);
      for (uint256 i = 0; i < tokenIds.length; i++) {
          eligibile[i] = _checkIfEligible(tokenIds[i]);
      }
      return eligibile;
  }

  function checkAllEligible(uint256[] calldata tokenIds) external override virtual view returns (bool) {
      for (uint256 i = 0; i < tokenIds.length; i++) {
          if (!_checkIfEligible(tokenIds[i])) {
              return false;
          }
      }
      return true;
  }

  function checkAllIneligible(uint256[] calldata tokenIds) external override virtual view returns (bool) {
      for (uint256 i = 0; i < tokenIds.length; i++) {
          if (_checkIfEligible(tokenIds[i])) {
              return false;
          }
      }
      return true;
  }

  function beforeMintHook(uint256[] calldata tokenIds) external override virtual {}
  function afterMintHook(uint256[] calldata tokenIds) external override virtual {}
  function beforeRedeemHook(uint256[] calldata tokenIds) external override virtual {}
  function afterRedeemHook(uint256[] calldata tokenIds) external override virtual {}
  function afterLiquidationHook(uint256[] calldata tokenIds, uint256[] calldata amounts) external override virtual {}

  function _checkIfEligible(uint256 _tokenId) internal view virtual returns (bool);
}// MIT

pragma solidity ^0.8.0;


contract NFTXAllowAllEligibility is NFTXEligibility {


    uint256 public constant ALLOW_ALL_ELIGIBILITY_REVISION = 0x1;

    function getRevision() internal pure override virtual returns (uint256) {

        return ALLOW_ALL_ELIGIBILITY_REVISION;
    }

    function name() public pure override virtual returns (string memory) {    

        return "AllowAll";
    }

    function finalized() public view override virtual returns (bool) {    

        return true;
    }

    function targetAsset() public pure override virtual returns (address) {

        return address(0);
    }

    event NFTXEligibilityInit();

    function __NFTXEligibility_init_bytes(
        bytes memory configData
    ) public override virtual initializer {

        __NFTXEligibility_init();
    }

    function __NFTXEligibility_init(
    ) public initializer {

        emit NFTXEligibilityInit();
    }

    function _checkIfEligible(
        uint256 _tokenId
    ) internal view override virtual returns (bool) {

        return true;
    }
}