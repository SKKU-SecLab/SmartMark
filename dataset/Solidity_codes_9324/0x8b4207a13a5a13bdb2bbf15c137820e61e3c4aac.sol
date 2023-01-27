
pragma solidity >=0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.7.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity >=0.7.0;

interface INFTGemMultiToken {

    function mint(
        address account,
        uint256 tokenHash,
        uint256 amount
    ) external;


    function burn(
        address account,
        uint256 tokenHash,
        uint256 amount
    ) external;


    function allHeldTokens(address holder, uint256 _idx) external view returns (uint256);


    function allHeldTokensLength(address holder) external view returns (uint256);


    function allTokenHolders(uint256 _token, uint256 _idx) external view returns (address);


    function allTokenHoldersLength(uint256 _token) external view returns (uint256);


    function totalBalances(uint256 _id) external view returns (uint256);


    function allProxyRegistries(uint256 _idx) external view returns (address);


    function allProxyRegistriesLength() external view returns (uint256);


    function addProxyRegistry(address registry) external;


    function removeProxyRegistryAt(uint256 index) external;


    function getRegistryManager() external view returns (address);


    function setRegistryManager(address newManager) external;


    function lock(uint256 token, uint256 timeframe) external;


    function unlockTime(address account, uint256 token) external view returns (uint256);

}// MIT

pragma solidity >=0.7.0;

interface INFTGemPoolFactory {

    event NFTGemPoolCreated(
        string gemSymbol,
        string gemName,
        uint256 ethPrice,
        uint256 mintTime,
        uint256 maxTime,
        uint256 diffstep,
        uint256 maxMint,
        address allowedToken
    );

    function getNFTGemPool(uint256 _symbolHash) external view returns (address);


    function allNFTGemPools(uint256 idx) external view returns (address);


    function allNFTGemPoolsLength() external view returns (uint256);


    function createNFTGemPool(
        string memory gemSymbol,
        string memory gemName,
        uint256 ethPrice,
        uint256 minTime,
        uint256 maxTime,
        uint256 diffstep,
        uint256 maxMint,
        address allowedToken
    ) external returns (address payable);

}// MIT
pragma solidity >=0.7.0;

interface IControllable {

    event ControllerAdded(address indexed contractAddress, address indexed controllerAddress);
    event ControllerRemoved(address indexed contractAddress, address indexed controllerAddress);

    function addController(address controller) external;


    function isController(address controller) external view returns (bool);


    function relinquishControl() external;

}// MIT

pragma solidity >=0.7.0;

interface INFTGemPool {


    event NFTGemClaimCreated(address account, address pool, uint256 claimHash, uint256 length, uint256 quantity, uint256 amountPaid);

    event NFTGemERC20ClaimCreated(
        address account,
        address pool,
        uint256 claimHash,
        uint256 length,
        address token,
        uint256 quantity,
        uint256 conversionRate
    );

    event NFTGemClaimRedeemed(
        address account,
        address pool,
        uint256 claimHash,
        uint256 amountPaid,
        uint256 feeAssessed
    );

    event NFTGemERC20ClaimRedeemed(
        address account,
        address pool,
        uint256 claimHash,
        address token,
        uint256 ethPrice,
        uint256 tokenAmount,
        uint256 feeAssessed
    );

    event NFTGemCreated(address account, address pool, uint256 claimHash, uint256 gemHash, uint256 quantity);

    function setMultiToken(address token) external;


    function setGovernor(address addr) external;


    function setFeeTracker(address addr) external;


    function setSwapHelper(address addr) external;


    function mintGenesisGems(address creator, address funder) external;


    function createClaim(uint256 timeframe) external payable;


    function createClaims(uint256 timeframe, uint256 count) external payable;


    function createERC20Claim(address erc20token, uint256 tokenAmount) external;


    function createERC20Claims(address erc20token, uint256 tokenAmount, uint256 count) external;


    function collectClaim(uint256 claimHash) external;


    function initialize(
        string memory,
        string memory,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        address
    ) external;

}// MIT

pragma solidity >=0.7.0;

interface IProposal {

    enum ProposalType {CREATE_POOL, FUND_PROJECT, CHANGE_FEE, UPDATE_ALLOWLIST}

    enum ProposalStatus {NOT_FUNDED, ACTIVE, PASSED, FAILED, EXECUTED, CLOSED}

    event ProposalCreated(address creator, address pool, uint256 proposalHash);

    event ProposalExecuted(uint256 proposalHash);

    event ProposalClosed(uint256 proposalHash);

    function creator() external view returns (address);


    function title() external view returns (string memory);


    function funder() external view returns (address);


    function expiration() external view returns (uint256);


    function status() external view returns (ProposalStatus);


    function proposalData() external view returns (address);


    function proposalType() external view returns (ProposalType);


    function setMultiToken(address token) external;


    function setGovernor(address gov) external;


    function fund() external payable;


    function execute() external;


    function close() external;


    function initialize(
        address,
        string memory,
        address,
        ProposalType
    ) external;

}// MIT
pragma solidity >=0.7.0;

interface ICreatePoolProposalData {

    function data()
        external
        view
        returns (
            string memory,
            string memory,

            uint256,
            uint256,
            uint256,
            uint256,
            uint256,

            address
        );

}

interface IChangeFeeProposalData {

    function data()
        external
        view
        returns (
            address,
            address,
            uint256
        );

}

interface IFundProjectProposalData {

    function data()
        external
        view
        returns (
            address,
            string memory,
            uint256
        );

}

interface IUpdateAllowlistProposalData {

    function data()
        external
        view
        returns (
            address,
            address,
            bool
        );

}// MIT
pragma solidity >=0.7.0;



library GovernanceLib {


    function addressOfPropoal(
        address factory,
        address submitter,
        string memory title
    ) public pure returns (address govAddress) {

        govAddress = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(submitter, title)),
                        hex"74f827a6bb3b7ed4cd86bd3c09b189a9496bc40d83635649e1e4df1c4e836ebf" // init code hash
                    )
                )
            )
        );
    }

    function createProposalVoteTokens(address multitoken, uint256 proposalHash) external {

        for (uint256 i = 0; i < INFTGemMultiToken(multitoken).allTokenHoldersLength(0); i++) {
            address holder = INFTGemMultiToken(multitoken).allTokenHolders(0, i);
            INFTGemMultiToken(multitoken).mint(holder, proposalHash,
                IERC1155(multitoken).balanceOf(holder, 0)
            );
        }
    }

    function destroyProposalVoteTokens(address multitoken, uint256 proposalHash) external {

        for (uint256 i = 0; i < INFTGemMultiToken(multitoken).allTokenHoldersLength(0); i++) {
            address holder = INFTGemMultiToken(multitoken).allTokenHolders(0, i);
            INFTGemMultiToken(multitoken).burn(holder, proposalHash,
                IERC1155(multitoken).balanceOf(holder, proposalHash)
            );
        }
    }

    function execute(
        address factory,
        address proposalAddress) public returns (address newPool) {


        address proposalData = IProposal(proposalAddress).proposalData();

        (
            string memory symbol,
            string memory name,

            uint256 ethPrice,
            uint256 minTime,
            uint256 maxTime,
            uint256 diffStep,
            uint256 maxClaims,

            address allowedToken
        ) = ICreatePoolProposalData(proposalData).data();

        newPool = createPool(
            factory,

            symbol,
            name,

            ethPrice,
            minTime,
            maxTime,
            diffStep,
            maxClaims,

            allowedToken
        );
    }

    function createPool(
        address factory,

        string memory symbol,
        string memory name,

        uint256 ethPrice,
        uint256 minTime,
        uint256 maxTime,
        uint256 diffstep,
        uint256 maxClaims,

        address allowedToken
    ) public returns (address pool) {

        pool = INFTGemPoolFactory(factory).createNFTGemPool(
            symbol,
            name,

            ethPrice,
            minTime,
            maxTime,
            diffstep,
            maxClaims,

            allowedToken
        );
    }

}