

pragma solidity ^0.8.0;
pragma abicoder v2;



interface IMinionFactory {

    function summonMinionAndSafe(
        address,
        string memory,
        uint256,
        uint256
    ) external returns (address);

}

interface IMolochFactory {

    function summonMoloch(
        address,
        address,
        address[] memory,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) external returns (address);

}

interface IMOLOCH {


    function depositToken() external view returns (address);


    function tokenWhitelist(address token) external view returns (bool);


    function totalShares() external view returns (uint256);


    function getProposalFlags(uint256 proposalId)
        external
        view
        returns (bool[6] memory);


    function getUserTokenBalance(address user, address token)
        external
        view
        returns (uint256);


    function members(address user)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            bool,
            uint256,
            uint256
        );


    function memberAddressByDelegateKey(address user)
        external
        view
        returns (address);


    function userTokenBalances(address user, address token)
        external
        view
        returns (uint256);


    function cancelProposal(uint256 proposalId) external;


    function submitProposal(
        address applicant,
        uint256 sharesRequested,
        uint256 lootRequested,
        uint256 tributeOffered,
        address tributeToken,
        uint256 paymentRequested,
        address paymentToken,
        string calldata details
    ) external returns (uint256);


    function withdrawBalance(address token, uint256 amount) external;


    struct Proposal {
        address applicant; // the applicant who wishes to become a member - this key will be used for withdrawals (doubles as guild kick target for gkick proposals)
        address proposer; // the account that submitted the proposal (can be non-member)
        address sponsor; // the member that sponsored the proposal (moving it into the queue)
        uint256 sharesRequested; // the # of shares the applicant is requesting
        uint256 lootRequested; // the amount of loot the applicant is requesting
        uint256 tributeOffered; // amount of tokens offered as tribute
        address tributeToken; // tribute token contract reference
        uint256 paymentRequested; // amount of tokens requested as payment
        address paymentToken; // payment token contract reference
        uint256 startingPeriod; // the period in which voting can start for this proposal
        uint256 yesVotes; // the total number of YES votes for this proposal
        uint256 noVotes; // the total number of NO votes for this proposal
        bool[6] flags; // [sponsored, processed, didPass, cancelled, whitelist, guildkick]
        string details; // proposal details - could be IPFS hash, plaintext, or JSON
        uint256 maxTotalSharesAndLootAtYesVote; // the maximum # of total shares encountered at a yes vote on this proposal
    }

    function proposals(uint256 proposalId)
        external
        view
        returns (
            address,
            address,
            address,
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            address,
            uint256,
            uint256,
            uint256
        );


    function setSharesLoot(
        address[] calldata,
        uint256[] calldata,
        uint256[] calldata,
        bool mint
    ) external;


    function setSingleSharesLoot(
        address,
        uint256,
        uint256,
        bool
    ) external;


    function setShaman(address, bool) external;

}

interface IMINION {

    function avatar() external view returns (address);

}

contract DaoSafeMinionSummoner {

    IMinionFactory public minionSummoner;
    IMolochFactory public daoSummoner;

    struct DSM {
        address summoner;
        address moloch;
        address minion;
        address avatar;
        bool initialized;
    }

    mapping(uint256 => DSM) public daos;
    uint256 public daoIdx = 0;

    event SummonComplete(
        address summoner,
        address indexed moloch,
        address minion,
        address avatar,
        string details
    );

    event SetupComplete(
        address indexed moloch,
        address shaman,
        address[] extraShamans,
        address[] summoners,
        uint256[] summonerShares,
        uint256[] summonerLoot
    );

    constructor(address _minionSummoner, address _daoSummoner) {
        minionSummoner = IMinionFactory(_minionSummoner);
        daoSummoner = IMolochFactory(_daoSummoner);
    }

    function summonDaoMinionAndSafe(
        uint256 _saltNonce,
        uint256 _periodDuration,
        uint256 _votingPeriodLength,
        uint256 _gracePeriodLength,
        address[] calldata _approvedTokens, // TODO: should this just be the native wrapper
        string calldata details
    ) external returns (address _moloch, address _minion) {


        _moloch = daoSummoner.summonMoloch(
            msg.sender, // summoner TODO: do we still need this
            address(this), // _shaman,
            _approvedTokens,
            _periodDuration,
            _votingPeriodLength,
            _gracePeriodLength,
            0, // deposit
            3, // dillution bound
            0 // reward
        );

        _minion = minionSummoner.summonMinionAndSafe(
            _moloch,
            details,
            0,
            _saltNonce
        );

        IMINION minionContract = IMINION(_minion);

        daoIdx = daoIdx + 1;
        daos[daoIdx] = DSM(
            msg.sender,
            _moloch,
            _minion,
            minionContract.avatar(),
            false
        );

        emit SummonComplete(
            msg.sender,
            _moloch,
            _minion,
            minionContract.avatar(),
            details
        );
    }

    function setUpDaoMinionAndSafe(
        uint256 id,
        address[] memory _summoners,
        uint256[] memory _summonerShares,
        uint256[] memory _summonerLoot,
        address[] memory _shamans 
    ) public {

        DSM memory dsm = daos[id];
        require(dsm.summoner == msg.sender, "!summoner");
        require(!dsm.initialized, "already initialized");

        IMOLOCH molochContract = IMOLOCH(dsm.moloch);
        daos[id].initialized = true;

        molochContract.setSingleSharesLoot(
            dsm.summoner,
            1,
            0,
            true
        );
        molochContract.setSharesLoot(
            _summoners,
            _summonerShares,
            _summonerLoot,
            true
        );
        
        molochContract.setShaman(dsm.avatar, true);
        for (uint256 i = 0; i < _shamans.length; i++) {
            molochContract.setShaman(_shamans[i], true);
        }
        molochContract.setShaman(address(this), false);
        emit SetupComplete(
            dsm.moloch,
            dsm.avatar,
            _shamans,
            _summoners,
            _summonerShares,
            _summonerLoot
        );
    }
}