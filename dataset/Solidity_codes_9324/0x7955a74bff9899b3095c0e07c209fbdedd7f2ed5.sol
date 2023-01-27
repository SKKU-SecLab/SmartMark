
pragma solidity >=0.8.0;

library BridgeBeams {

  struct Project {
    uint256 id;
    string name;
    string artist;
    string description;
    string website;
    uint256 supply;
    uint256 maxSupply;
    uint256 startBlock;
  }

  struct ProjectState {
    bool initialized;
    bool mintable;
    bool released;
    uint256 remaining;
  }

  struct ReserveParameters {
    uint256 maxMintPerInvocation;
    uint256 reservedMints;
    bytes32 reserveRoot;
  }

  function projectState(Project memory _project)
    external
    view
    returns (BridgeBeams.ProjectState memory)
  {

    return
      ProjectState({
        initialized: isInitialized(_project),
        mintable: isMintable(_project),
        released: isReleased(_project),
        remaining: _project.maxSupply - _project.supply
      });
  }

  function isInitialized(Project memory _project) internal pure returns (bool) {

    if (
      bytes(_project.artist).length == 0 ||
      bytes(_project.description).length == 0
    ) {
      return false;
    }
    return true;
  }

  function isReleased(Project memory _project) internal view returns (bool) {

    return _project.startBlock > 0 && _project.startBlock <= block.number;
  }

  function isMintable(Project memory _project) internal view returns (bool) {

    if (!isInitialized(_project)) {
      return false;
    }
    return isReleased(_project) && _project.supply < _project.maxSupply;
  }
}