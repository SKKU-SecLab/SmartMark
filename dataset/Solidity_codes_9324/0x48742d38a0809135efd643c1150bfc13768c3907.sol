
pragma solidity ^0.8.0;

interface IGenArt721CoreContractV1 {

    event Mint(
        address indexed _to,
        uint256 indexed _tokenId,
        uint256 indexed _projectId
    );

    function admin() external view returns (address);


    function nextProjectId() external view returns (uint256);


    function tokenIdToProjectId(uint256 tokenId)
        external
        view
        returns (uint256 projectId);


    function isWhitelisted(address sender) external view returns (bool);


    function isMintWhitelisted(address minter) external view returns (bool);


    function projectIdToArtistAddress(uint256 _projectId)
        external
        view
        returns (address payable);


    function projectIdToAdditionalPayee(uint256 _projectId)
        external
        view
        returns (address payable);


    function projectIdToAdditionalPayeePercentage(uint256 _projectId)
        external
        view
        returns (uint256);


    function projectTokenInfo(uint256 _projectId)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            bool,
            address,
            uint256,
            string memory,
            address
        );


    function artblocksAddress() external view returns (address payable);


    function artblocksPercentage() external view returns (uint256);


    function mint(
        address _to,
        uint256 _projectId,
        address _by
    ) external returns (uint256 tokenId);


    function getRoyaltyData(uint256 _tokenId)
        external
        view
        returns (
            address artistAddress,
            address additionalPayee,
            uint256 additionalPayeePercentage,
            uint256 royaltyFeeByID
        );

}// LGPL-3.0-only

pragma solidity ^0.8.0;

interface IMinterFilterV0 {

    event MinterApproved(address indexed _minterAddress, string _minterType);

    event MinterRevoked(address indexed _minterAddress);

    event ProjectMinterRegistered(
        uint256 indexed _projectId,
        address indexed _minterAddress,
        string _minterType
    );

    event ProjectMinterRemoved(uint256 indexed _projectId);

    function genArt721CoreAddress() external returns (address);


    function setMinterForProject(uint256, address) external;


    function removeMinterForProject(uint256) external;


    function mint(
        address _to,
        uint256 _projectId,
        address sender
    ) external returns (uint256);


    function getMinterForProject(uint256) external view returns (address);


    function projectHasMinter(uint256) external view returns (bool);

}// LGPL-3.0-only

pragma solidity ^0.8.0;

interface IFilteredMinterV0 {

    event PricePerTokenInWeiUpdated(
        uint256 indexed _projectId,
        uint256 indexed _pricePerTokenInWei
    );

    event ProjectCurrencyInfoUpdated(
        uint256 indexed _projectId,
        address indexed _currencyAddress,
        string _currencySymbol
    );

    event PurchaseToDisabledUpdated(
        uint256 indexed _projectId,
        bool _purchaseToDisabled
    );

    function minterType() external view returns (string memory);


    function genArt721CoreAddress() external returns (address);


    function minterFilterAddress() external returns (address);


    function purchase(uint256 _projectId)
        external
        payable
        returns (uint256 tokenId);


    function purchaseTo(address _to, uint256 _projectId)
        external
        payable
        returns (uint256 tokenId);


    function togglePurchaseToDisabled(uint256 _projectId) external;


    function setProjectMaxInvocations(uint256 _projectId) external;


    function getPriceInfo(uint256 _projectId)
        external
        view
        returns (
            bool isConfigured,
            uint256 tokenPriceInWei,
            string memory currencySymbol,
            address currencyAddress
        );

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// LGPL-3.0-only



pragma solidity 0.8.9;

contract MinterSetPriceERC20V0 is ReentrancyGuard, IFilteredMinterV0 {

    address public immutable genArt721CoreAddress;

    IGenArt721CoreContractV1 private immutable genArtCoreContract;

    address public immutable minterFilterAddress;

    IMinterFilterV0 private immutable minterFilter;

    string public constant minterType = "MinterSetPriceERC20V0";

    uint256 constant ONE_MILLION = 1_000_000;

    mapping(uint256 => bool) public contractMintable;
    mapping(uint256 => bool) public purchaseToDisabled;
    mapping(address => mapping(uint256 => uint256)) public projectMintCounter;
    mapping(uint256 => uint256) public projectMintLimit;
    mapping(uint256 => bool) public projectMaxHasBeenInvoked;
    mapping(uint256 => uint256) public projectMaxInvocations;
    mapping(uint256 => uint256) private projectIdToPricePerTokenInWei;
    mapping(uint256 => bool) private projectIdToPriceIsConfigured;
    mapping(uint256 => string) private projectIdToCurrencySymbol;
    mapping(uint256 => address) private projectIdToCurrencyAddress;

    modifier onlyCoreWhitelisted() {

        require(
            genArtCoreContract.isWhitelisted(msg.sender),
            "Only Core whitelisted"
        );
        _;
    }

    modifier onlyArtist(uint256 _projectId) {

        require(
            msg.sender ==
                genArtCoreContract.projectIdToArtistAddress(_projectId),
            "Only Artist"
        );
        _;
    }

    constructor(address _genArt721Address, address _minterFilter)
        ReentrancyGuard()
    {
        genArt721CoreAddress = _genArt721Address;
        genArtCoreContract = IGenArt721CoreContractV1(_genArt721Address);
        minterFilterAddress = _minterFilter;
        minterFilter = IMinterFilterV0(_minterFilter);
        require(
            minterFilter.genArt721CoreAddress() == _genArt721Address,
            "Illegal contract pairing"
        );
    }

    function getYourBalanceOfProjectERC20(uint256 _projectId)
        external
        view
        returns (uint256 balance)
    {

        balance = IERC20(projectIdToCurrencyAddress[_projectId]).balanceOf(
            msg.sender
        );
        return balance;
    }

    function checkYourAllowanceOfProjectERC20(uint256 _projectId)
        external
        view
        returns (uint256 remaining)
    {

        remaining = IERC20(projectIdToCurrencyAddress[_projectId]).allowance(
            msg.sender,
            address(this)
        );
        return remaining;
    }

    function setProjectMintLimit(uint256 _projectId, uint8 _limit)
        external
        onlyCoreWhitelisted
    {

        projectMintLimit[_projectId] = _limit;
    }

    function setProjectMaxInvocations(uint256 _projectId)
        external
        onlyCoreWhitelisted
    {

        uint256 invocations;
        uint256 maxInvocations;
        (, , invocations, maxInvocations, , , , , ) = genArtCoreContract
            .projectTokenInfo(_projectId);
        projectMaxInvocations[_projectId] = maxInvocations;
        if (invocations < maxInvocations) {
            projectMaxHasBeenInvoked[_projectId] = false;
        }
    }

    function toggleContractMintable(uint256 _projectId)
        external
        onlyCoreWhitelisted
    {

        contractMintable[_projectId] = !contractMintable[_projectId];
    }

    function togglePurchaseToDisabled(uint256 _projectId)
        external
        onlyCoreWhitelisted
    {

        purchaseToDisabled[_projectId] = !purchaseToDisabled[_projectId];
        emit PurchaseToDisabledUpdated(
            _projectId,
            purchaseToDisabled[_projectId]
        );
    }

    function updatePricePerTokenInWei(
        uint256 _projectId,
        uint256 _pricePerTokenInWei
    ) external onlyArtist(_projectId) {

        projectIdToPricePerTokenInWei[_projectId] = _pricePerTokenInWei;
        projectIdToPriceIsConfigured[_projectId] = true;
        emit PricePerTokenInWeiUpdated(_projectId, _pricePerTokenInWei);
    }

    function updateProjectCurrencyInfo(
        uint256 _projectId,
        string memory _currencySymbol,
        address _currencyAddress
    ) external onlyArtist(_projectId) {

        require(
            (keccak256(abi.encodePacked(_currencySymbol)) ==
                keccak256(abi.encodePacked("ETH"))) ==
                (_currencyAddress == address(0)),
            "ETH is only null address"
        );
        projectIdToCurrencySymbol[_projectId] = _currencySymbol;
        projectIdToCurrencyAddress[_projectId] = _currencyAddress;
        emit ProjectCurrencyInfoUpdated(
            _projectId,
            _currencyAddress,
            _currencySymbol
        );
    }

    function purchase(uint256 _projectId)
        external
        payable
        returns (uint256 tokenId)
    {

        tokenId = purchaseTo(msg.sender, _projectId);
        return tokenId;
    }

    function purchaseTo(address _to, uint256 _projectId)
        public
        payable
        nonReentrant
        returns (uint256 tokenId)
    {

        require(
            !projectMaxHasBeenInvoked[_projectId],
            "Maximum number of invocations reached"
        );

        require(
            projectIdToPriceIsConfigured[_projectId],
            "Price not configured"
        );

        if (!contractMintable[_projectId]) {
            require(msg.sender == tx.origin, "No Contract Buys");
        }

        if (purchaseToDisabled[_projectId]) {
            require(msg.sender == _to, "No `purchaseTo` Allowed");
        }

        if (projectMintLimit[_projectId] > 0) {
            require(
                projectMintCounter[msg.sender][_projectId] <
                    projectMintLimit[_projectId],
                "Reached minting limit"
            );
            projectMintCounter[msg.sender][_projectId]++;
        }

        tokenId = minterFilter.mint(_to, _projectId, msg.sender);
        if (
            projectMaxInvocations[_projectId] > 0 &&
            tokenId % ONE_MILLION == projectMaxInvocations[_projectId] - 1
        ) {
            projectMaxHasBeenInvoked[_projectId] = true;
        }

        if (projectIdToCurrencyAddress[_projectId] != address(0)) {
            require(
                msg.value == 0,
                "this project accepts a different currency and cannot accept ETH"
            );
            require(
                IERC20(projectIdToCurrencyAddress[_projectId]).allowance(
                    msg.sender,
                    address(this)
                ) >= projectIdToPricePerTokenInWei[_projectId],
                "Insufficient Funds Approved for TX"
            );
            require(
                IERC20(projectIdToCurrencyAddress[_projectId]).balanceOf(
                    msg.sender
                ) >= projectIdToPricePerTokenInWei[_projectId],
                "Insufficient balance."
            );
            _splitFundsERC20(_projectId);
        } else {
            require(
                msg.value >= projectIdToPricePerTokenInWei[_projectId],
                "Must send minimum value to mint!"
            );
            _splitFundsETH(_projectId);
        }

        return tokenId;
    }

    function _splitFundsETH(uint256 _projectId) internal {

        if (msg.value > 0) {
            uint256 pricePerTokenInWei = projectIdToPricePerTokenInWei[
                _projectId
            ];
            uint256 refund = msg.value - pricePerTokenInWei;
            if (refund > 0) {
                (bool success_, ) = msg.sender.call{value: refund}("");
                require(success_, "Refund failed");
            }
            uint256 foundationAmount = (pricePerTokenInWei *
                genArtCoreContract.artblocksPercentage()) / 100;
            if (foundationAmount > 0) {
                (bool success_, ) = genArtCoreContract.artblocksAddress().call{
                    value: foundationAmount
                }("");
                require(success_, "Foundation payment failed");
            }
            uint256 projectFunds = pricePerTokenInWei - foundationAmount;
            uint256 additionalPayeeAmount;
            if (
                genArtCoreContract.projectIdToAdditionalPayeePercentage(
                    _projectId
                ) > 0
            ) {
                additionalPayeeAmount =
                    (projectFunds *
                        genArtCoreContract.projectIdToAdditionalPayeePercentage(
                            _projectId
                        )) /
                    100;
                if (additionalPayeeAmount > 0) {
                    (bool success_, ) = genArtCoreContract
                        .projectIdToAdditionalPayee(_projectId)
                        .call{value: additionalPayeeAmount}("");
                    require(success_, "Additional payment failed");
                }
            }
            uint256 creatorFunds = projectFunds - additionalPayeeAmount;
            if (creatorFunds > 0) {
                (bool success_, ) = genArtCoreContract
                    .projectIdToArtistAddress(_projectId)
                    .call{value: creatorFunds}("");
                require(success_, "Artist payment failed");
            }
        }
    }

    function _splitFundsERC20(uint256 _projectId) internal {

        uint256 pricePerTokenInWei = projectIdToPricePerTokenInWei[_projectId];
        uint256 foundationAmount = (pricePerTokenInWei *
            genArtCoreContract.artblocksPercentage()) / 100;
        if (foundationAmount > 0) {
            IERC20(projectIdToCurrencyAddress[_projectId]).transferFrom(
                msg.sender,
                genArtCoreContract.artblocksAddress(),
                foundationAmount
            );
        }
        uint256 projectFunds = pricePerTokenInWei - foundationAmount;
        uint256 additionalPayeeAmount;
        if (
            genArtCoreContract.projectIdToAdditionalPayeePercentage(
                _projectId
            ) > 0
        ) {
            additionalPayeeAmount =
                (projectFunds *
                    genArtCoreContract.projectIdToAdditionalPayeePercentage(
                        _projectId
                    )) /
                100;
            if (additionalPayeeAmount > 0) {
                IERC20(projectIdToCurrencyAddress[_projectId]).transferFrom(
                    msg.sender,
                    genArtCoreContract.projectIdToAdditionalPayee(_projectId),
                    additionalPayeeAmount
                );
            }
        }
        uint256 creatorFunds = projectFunds - additionalPayeeAmount;
        if (creatorFunds > 0) {
            IERC20(projectIdToCurrencyAddress[_projectId]).transferFrom(
                msg.sender,
                genArtCoreContract.projectIdToArtistAddress(_projectId),
                creatorFunds
            );
        }
    }

    function getPriceInfo(uint256 _projectId)
        external
        view
        returns (
            bool isConfigured,
            uint256 tokenPriceInWei,
            string memory currencySymbol,
            address currencyAddress
        )
    {

        isConfigured = projectIdToPriceIsConfigured[_projectId];
        tokenPriceInWei = projectIdToPricePerTokenInWei[_projectId];
        currencyAddress = projectIdToCurrencyAddress[_projectId];
        if (currencyAddress == address(0)) {
            currencySymbol = "ETH";
        } else {
            currencySymbol = projectIdToCurrencySymbol[_projectId];
        }
    }
}