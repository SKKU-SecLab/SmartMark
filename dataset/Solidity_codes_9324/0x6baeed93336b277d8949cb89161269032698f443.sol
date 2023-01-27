
pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

interface IRockstar {

  function safeMint(address recipient, string memory metadata) external returns (bool);


  function renounceOwnership() external;

}

contract BatchMintNFT {


  constructor() public {}

  function produceNFTs(address token, address[] memory recipients, string[] memory metadatas, uint8 startpos, uint8 num) public {

    require(recipients.length == 100, "BatchDeploy::batchDeployNFTs: Needs exact 100 recipients");
    require(recipients.length == metadatas.length, "BatchDeploy::batchDeployNFTs: recipients and metaddata count mismatch");

    IRockstar rockstar = IRockstar(token);

    for (uint i=startpos; i<num; i++) {
      rockstar.safeMint(recipients[i], metadatas[i]);
    }
  }

  function revokeOwnership(address token) external {

    IRockstar rockstar = IRockstar(token);
    rockstar.renounceOwnership();
  }
}