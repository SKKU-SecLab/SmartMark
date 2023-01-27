


pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";


contract AaveGovernanceAdapter {



    uint256 public constant VOTE_FOR = 1;

    uint256 public constant VOTE_AGAINST = 2;


    address public immutable aaveProtoGovernance;

    address public immutable aaveToken;


    constructor(address _aaveProtoGovernance, address _aaveToken) public {
        aaveProtoGovernance = _aaveProtoGovernance;
        aaveToken = _aaveToken;
    }


    function getVoteCalldata(uint256 _proposalId, bool _support, bytes memory _data) external view returns (address, uint256, bytes memory) {

        uint256 voteValue = _support ? VOTE_FOR : VOTE_AGAINST;
        address asset = _data.length == 0 ? aaveToken : abi.decode(_data, (address));

        bytes memory callData = abi.encodeWithSignature("submitVoteByVoter(uint256,uint256,address)", _proposalId, voteValue, asset);

        return (aaveProtoGovernance, 0, callData);
    }

    function getDelegateCalldata(address /* _delegatee */) external view returns (address, uint256, bytes memory) {

        revert("No delegation available in AAVE governance");
    }

    function getRegisterCalldata(address /* _setToken */) external view returns (address, uint256, bytes memory) {

        revert("No register available in AAVE governance");
    }

    function getRevokeCalldata() external view returns (address, uint256, bytes memory) {

        revert("No revoke available in AAVE governance");
    }

    function getProposeCalldata(bytes memory /* _proposalData */) external view returns (address, uint256, bytes memory) {

        revert("Creation of new proposal only available to AAVE genesis team");
    }
}