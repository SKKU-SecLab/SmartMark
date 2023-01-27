
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}/*

██████╗░██████╗░██╗███╗░░░███╗███████╗██████╗░░█████╗░░█████╗░
██╔══██╗██╔══██╗██║████╗░████║██╔════╝██╔══██╗██╔══██╗██╔══██╗
██████╔╝██████╔╝██║██╔████╔██║█████╗░░██║░░██║███████║██║░░██║
██╔═══╝░██╔══██╗██║██║╚██╔╝██║██╔══╝░░██║░░██║██╔══██║██║░░██║
██║░░░░░██║░░██║██║██║░╚═╝░██║███████╗██████╔╝██║░░██║╚█████╔╝
╚═╝░░░░░╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝░╚════╝░

*/


pragma solidity 0.8.9;


interface ILBPFactory {

    function create(
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory weights,
        uint256 swapFeePercentage,
        address owner,
        bool swapEnabledOnStart
    ) external returns (address);

}/*

██████╗░██████╗░██╗███╗░░░███╗███████╗██████╗░░█████╗░░█████╗░
██╔══██╗██╔══██╗██║████╗░████║██╔════╝██╔══██╗██╔══██╗██╔══██╗
██████╔╝██████╔╝██║██╔████╔██║█████╗░░██║░░██║███████║██║░░██║
██╔═══╝░██╔══██╗██║██║╚██╔╝██║██╔══╝░░██║░░██║██╔══██║██║░░██║
██║░░░░░██║░░██║██║██║░╚═╝░██║███████╗██████╔╝██║░░██║╚█████╔╝
╚═╝░░░░░╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝░╚════╝░

*/


pragma solidity 0.8.9;


interface IVault {

    struct JoinPoolRequest {
        IERC20[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    struct ExitPoolRequest {
        IERC20[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;


    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external;

}/*

██████╗░██████╗░██╗███╗░░░███╗███████╗██████╗░░█████╗░░█████╗░
██╔══██╗██╔══██╗██║████╗░████║██╔════╝██╔══██╗██╔══██╗██╔══██╗
██████╔╝██████╔╝██║██╔████╔██║█████╗░░██║░░██║███████║██║░░██║
██╔═══╝░██╔══██╗██║██║╚██╔╝██║██╔══╝░░██║░░██║██╔══██║██║░░██║
██║░░░░░██║░░██║██║██║░╚═╝░██║███████╗██████╔╝██║░░██║╚█████╔╝
╚═╝░░░░░╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝░╚════╝░

*/



pragma solidity 0.8.9;

interface ILBP is IERC20 {

    function updateWeightsGradually(
        uint256 startTime,
        uint256 endTime,
        uint256[] memory endWeights
    ) external;


    function getGradualWeightUpdateParams()
        external
        view
        returns (
            uint256 startTime,
            uint256 endTime,
            uint256[] memory endWeights
        );


    function getPoolId() external view returns (bytes32);


    function getVault() external view returns (IVault);


    function setSwapEnabled(bool swapEnabled) external;


    function getSwapEnabled() external view returns (bool);


    function getSwapFeePercentage() external view returns (uint256);

}/*
██████╗░██████╗░██╗███╗░░░███╗███████╗██████╗░░█████╗░░█████╗░
██╔══██╗██╔══██╗██║████╗░████║██╔════╝██╔══██╗██╔══██╗██╔══██╗
██████╔╝██████╔╝██║██╔████╔██║█████╗░░██║░░██║███████║██║░░██║
██╔═══╝░██╔══██╗██║██║╚██╔╝██║██╔══╝░░██║░░██║██╔══██║██║░░██║
██║░░░░░██║░░██║██║██║░╚═╝░██║███████╗██████╔╝██║░░██║╚█████╔╝
╚═╝░░░░░╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝░╚════╝░
*/


pragma solidity 0.8.9;


contract LBPManager {

    uint256 private constant HUNDRED_PERCENT = 1e18; // Used in calculating the fee.

    string public symbol; // Symbol of the LBP.
    string public name; // Name of the LBP.
    address public admin; // Address of the admin of this contract.
    address public beneficiary; // Address that recieves fees.
    uint256 public feePercentage; // Fee expressed as a % (e.g. 10**18 = 100% fee, toWei('1') = 100%, 1e18)
    uint256 public swapFeePercentage; // Percentage of fee paid for every swap in the LBP.
    IERC20[] public tokenList; // Tokens that are used in the LBP, sorted by address in numerical order (ascending).
    uint256[] public amounts; // Amount of tokens to be added as liquidity in LBP.
    uint256[] public startWeights; // Array containing the startWeights for the project & funding token.
    uint256[] public endWeights; // Array containing the endWeights for the project & funding token.
    uint256[] public startTimeEndTime; // Array containing the startTime and endTime for the LBP.
    ILBP public lbp; // Address of LBP that is managed by this contract.
    bytes public metadata; // IPFS Hash of the LBP creation wizard information.
    uint8 public projectTokenIndex; // Index repesenting the project token in the tokenList.
    address public lbpFactory; // Address of Balancers LBP factory.

    bool public poolFunded; // true:- LBP is funded; false:- LBP is not funded.
    bool public initialized; // true:- LBPManager initialized; false:- LBPManager not initialized. Makes sure, only initialized once.

    event LBPManagerAdminChanged(
        address indexed oldAdmin,
        address indexed newAdmin
    );
    event FeeTransferred(
        address indexed beneficiary,
        address tokenAddress,
        uint256 amount
    );
    event PoolTokensWithdrawn(address indexed lbpAddress, uint256 amount);
    event MetadataUpdated(bytes indexed metadata);

    modifier onlyAdmin() {

        require(msg.sender == admin, "LBPManager: caller is not admin");
        _;
    }

    function transferAdminRights(address _newAdmin) external onlyAdmin {

        require(_newAdmin != address(0), "LBPManager: new admin is zero");

        emit LBPManagerAdminChanged(admin, _newAdmin);
        admin = _newAdmin;
    }

    function initializeLBPManager(
        address _lbpFactory,
        address _beneficiary,
        string memory _name,
        string memory _symbol,
        IERC20[] memory _tokenList,
        uint256[] memory _amounts,
        uint256[] memory _startWeights,
        uint256[] memory _startTimeEndTime,
        uint256[] memory _endWeights,
        uint256[] memory _fees,
        bytes memory _metadata
    ) external {

        require(!initialized, "LBPManager: already initialized");
        require(_beneficiary != address(0), "LBPManager: _beneficiary is zero");
        require(_fees[0] >= 1e12, "LBPManager: swapFeePercentage to low"); // 0.0001%
        require(_fees[0] <= 1e17, "LBPManager: swapFeePercentage to high"); // 10%
        require(
            _tokenList.length == 2 &&
                _amounts.length == 2 &&
                _startWeights.length == 2 &&
                _startTimeEndTime.length == 2 &&
                _endWeights.length == 2 &&
                _fees.length == 2,
            "LBPManager: arrays wrong size"
        );
        require(
            _tokenList[0] != _tokenList[1],
            "LBPManager: tokens can't be same"
        );
        require(
            _startTimeEndTime[0] < _startTimeEndTime[1],
            "LBPManager: startTime > endTime"
        );

        initialized = true;
        admin = msg.sender;
        swapFeePercentage = _fees[0];
        feePercentage = _fees[1];
        beneficiary = _beneficiary;
        metadata = _metadata;
        startTimeEndTime = _startTimeEndTime;
        name = _name;
        symbol = _symbol;
        lbpFactory = _lbpFactory;

        if (address(_tokenList[0]) > address(_tokenList[1])) {
            projectTokenIndex = 1;
            tokenList.push(_tokenList[1]);
            tokenList.push(_tokenList[0]);

            amounts.push(_amounts[1]);
            amounts.push(_amounts[0]);

            startWeights.push(_startWeights[1]);
            startWeights.push(_startWeights[0]);

            endWeights.push(_endWeights[1]);
            endWeights.push(_endWeights[0]);
        } else {
            projectTokenIndex = 0;
            tokenList = _tokenList;
            amounts = _amounts;
            startWeights = _startWeights;
            endWeights = _endWeights;
        }
    }

    function initializeLBP(address _sender) external onlyAdmin {

        require(initialized == true, "LBPManager: LBPManager not initialized");
        require(!poolFunded, "LBPManager: pool already funded");
        poolFunded = true;

        lbp = ILBP(
            ILBPFactory(lbpFactory).create(
                name,
                symbol,
                tokenList,
                startWeights,
                swapFeePercentage,
                address(this),
                false // SwapEnabled is set to false at pool creation.
            )
        );

        lbp.updateWeightsGradually(
            startTimeEndTime[0],
            startTimeEndTime[1],
            endWeights
        );

        IVault vault = lbp.getVault();

        if (feePercentage != 0) {
            uint256 feeAmountRequired = _feeAmountRequired();
            tokenList[projectTokenIndex].transferFrom(
                _sender,
                beneficiary,
                feeAmountRequired
            );
            emit FeeTransferred(
                beneficiary,
                address(tokenList[projectTokenIndex]),
                feeAmountRequired
            );
        }

        for (uint8 i; i < tokenList.length; i++) {
            tokenList[i].transferFrom(_sender, address(this), amounts[i]);
            tokenList[i].approve(address(vault), amounts[i]);
        }

        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest({
            maxAmountsIn: amounts,
            userData: abi.encode(0, amounts), // JOIN_KIND_INIT = 0, used when adding liquidity for the first time.
            fromInternalBalance: false, // It is not possible to add liquidity through the internal Vault balance.
            assets: tokenList
        });

        vault.joinPool(lbp.getPoolId(), address(this), address(this), request);
    }

    function removeLiquidity(address _receiver) external onlyAdmin {

        require(_receiver != address(0), "LBPManager: receiver is zero");
        require(
            lbp.balanceOf(address(this)) > 0,
            "LBPManager: no BPT token balance"
        );

        uint256 endTime = startTimeEndTime[1];
        require(block.timestamp >= endTime, "LBPManager: endtime not reached");

        IVault vault = lbp.getVault();

        IVault.ExitPoolRequest memory request = IVault.ExitPoolRequest({
            minAmountsOut: new uint256[](tokenList.length), // To remove all funding from the pool. Initializes to [0, 0]
            userData: abi.encode(1, lbp.balanceOf(address(this))),
            toInternalBalance: false,
            assets: tokenList
        });

        vault.exitPool(
            lbp.getPoolId(),
            address(this),
            payable(_receiver),
            request
        );
    }

    function withdrawPoolTokens(address _receiver) external onlyAdmin {

        require(_receiver != address(0), "LBPManager: receiver is zero");

        uint256 endTime = startTimeEndTime[1];
        require(block.timestamp >= endTime, "LBPManager: endtime not reached");

        require(
            lbp.balanceOf(address(this)) > 0,
            "LBPManager: no BPT token balance"
        );

        emit PoolTokensWithdrawn(address(lbp), lbp.balanceOf(address(this)));
        lbp.transfer(_receiver, lbp.balanceOf(address(this)));
    }

    function setSwapEnabled(bool _swapEnabled) external onlyAdmin {

        lbp.setSwapEnabled(_swapEnabled);
    }

    function getSwapEnabled() external view returns (bool) {

        require(poolFunded, "LBPManager: LBP not initialized.");
        return lbp.getSwapEnabled();
    }

    function projectTokensRequired()
        external
        view
        returns (uint256 projectTokenAmounts)
    {

        projectTokenAmounts = amounts[projectTokenIndex] + _feeAmountRequired();
    }

    function updateMetadata(bytes memory _metadata) external onlyAdmin {

        metadata = _metadata;
        emit MetadataUpdated(_metadata);
    }

    function _feeAmountRequired() internal view returns (uint256 feeAmount) {

        feeAmount =
            (amounts[projectTokenIndex] * feePercentage) /
            HUNDRED_PERCENT;
    }
}