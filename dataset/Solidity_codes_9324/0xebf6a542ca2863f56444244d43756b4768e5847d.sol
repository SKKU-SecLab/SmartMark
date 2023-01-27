
pragma solidity 0.8.6;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}


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
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

interface IController {

    function getClusterAmountFromEth(uint256 _ethAmount, address _cluster) external view returns (uint256);


    function addClusterToRegister(address indexAddr) external;


    function getDHVPriceInETH(address _cluster) external view returns (uint256);


    function getUnderlyingsInfo(address _cluster, uint256 _ethAmount)
        external
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256,
            uint256
        );


    function getUnderlyingsAmountsFromClusterAmount(uint256 _clusterAmount, address _clusterAddress) external view returns (uint256[] memory);


    function getEthAmountFromUnderlyingsAmounts(uint256[] memory _underlyingsAmounts, address _cluster) external view returns (uint256);


    function adapters(address _cluster) external view returns (address);


    function dhvTokenInstance() external view returns (address);


    function getDepositComission(address _cluster, uint256 _ethValue) external view returns (uint256);


    function getRedeemComission(address _cluster, uint256 _ethValue) external view returns (uint256);


    function getClusterPrice(address _cluster) external view returns (uint256);

}


interface IClusterToken {

    function assemble(uint256 clusterAmount, bool coverDhvWithEth) external payable returns (uint256);


    function disassemble(uint256 indexAmount, bool coverDhvWithEth) external;


    function withdrawToAccumulation(uint256 _clusterAmount) external;


    function refundFromAccumulation(uint256 _clusterAmount) external;


    function returnDebtFromAccumulation(uint256[] calldata _amounts, uint256 _clusterAmount) external;


    function optimizeProportion(uint256[] memory updatedShares) external returns (uint256[] memory debt);


    function getUnderlyingInCluster() external view returns (uint256[] calldata);


    function getUnderlyings() external view returns (address[] calldata);


    function getUnderlyingBalance(address _underlying) external view returns (uint256);


    function getUnderlyingsAmountsFromClusterAmount(uint256 _clusterAmount) external view returns (uint256[] calldata);


    function clusterTokenLock() external view returns (uint256);


    function clusterLock(address _token) external view returns (uint256);


    function controllerChange(address) external;


    function assembleByAdapter(uint256 _clusterAmount) external;


    function disassembleByAdapter(uint256 _clusterAmount) external;

}

interface IDexAdapter {

    function swapETHToUnderlying(address underlying, uint256 underlyingAmount) external payable;


    function swapUnderlyingsToETH(uint256[] memory underlyingAmounts, address[] memory underlyings) external;


    function swapTokenToToken(
        uint256 _amountToSwap,
        address _tokenToSwap,
        address _tokenToReceive
    ) external returns (uint256);


    function getUnderlyingAmount(
        uint256 _amount,
        address _tokenToSwap,
        address _tokenToReceive
    ) external view returns (uint256);


    function getPath(address _tokenToSwap, address _tokenToReceive) external view returns (address[] memory);


    function getTokensPrices(address[] memory _tokens) external view returns (uint256[] memory);


    function getEthPrice() external view returns (uint256);


    function getDHVPriceInETH(address _dhvToken) external view returns (uint256);


    function WETH() external view returns (address);


    function getEthAmountWithSlippage(uint256 _amount, address _tokenToSwap) external view returns (uint256);

}

contract Controller is OwnableUpgradeable, IController {

    uint256 public constant SHARES_DECIMALS = 10**6;
    uint256 public constant CLUSTER_TOKEN_DECIMALS = 10**18;

    address public override dhvTokenInstance;
    address public clusterFactoryAddress;
    address[] public clusterRegister;
    mapping(address => address) public override adapters;

    mapping(address => uint256) public depositComission;

    mapping(address => uint256) public redeemComission;

    modifier onlyClusterFactory() {

        require(_msgSender() == owner() || _msgSender() == clusterFactoryAddress);
        _;
    }

    function initialize(address _dhvTokenAddress) external initializer {

        require(_dhvTokenAddress != address(0), "Zero address");
        dhvTokenInstance = _dhvTokenAddress;

        __Ownable_init();
    }


    function setDepositComission(address _cluster, uint256 _comission) external onlyOwner {

        require(_comission < SHARES_DECIMALS, "Incorrect number");
        depositComission[_cluster] = _comission;
    }

    function setRedeemComission(address _cluster, uint256 _comission) external onlyOwner {

        require(_comission < SHARES_DECIMALS, "Incorrect number");
        redeemComission[_cluster] = _comission;
    }

    function setClusterFactoryAddress(address _clusterFactoryAddress) external onlyOwner {

        require(_clusterFactoryAddress != address(0), "Zero address");
        clusterFactoryAddress = _clusterFactoryAddress;
    }

    function setAdapterForCluster(address _cluster, address _adapter) external onlyOwner {

        require(_cluster != address(0) && _adapter != address(0), "Zero address");
        adapters[_cluster] = _adapter;
    }

    function addClusterToRegister(address clusterAddr) external override onlyClusterFactory {

        require(clusterAddr != address(0), "Zero address");
        for (uint256 i = 0; i < clusterRegister.length; i++) {
            if (clusterRegister[i] == clusterAddr) {
                revert("Cluster is registered");
            }
        }
        clusterRegister.push(clusterAddr);
    }

    function controllerChange(address _cluster, address _controller) external onlyOwner {

        for (uint256 i = 0; i < clusterRegister.length; i++) {
            if (clusterRegister[i] == _cluster) {
                clusterRegister[i] = clusterRegister[clusterRegister.length - 1];
                clusterRegister.pop();
                break;
            }
        }
        IClusterToken(_cluster).controllerChange(_controller);
    }


    function getIndicesList() external view returns (address[] memory) {

        return clusterRegister;
    }

    function getClusterAmountFromEth(uint256 _ethAmount, address _cluster) external view override returns (uint256) {

        address adapter = adapters[_cluster];

        address[] memory _underlyings = IClusterToken(_cluster).getUnderlyings();
        uint256[] memory _shares = IClusterToken(_cluster).getUnderlyingInCluster();

        uint256[] memory prices = IDexAdapter(adapter).getTokensPrices(_underlyings);
        (, uint256 proportionDenominator) = _getTokensProportions(_shares, prices);
        return (_ethAmount * 10**18) / proportionDenominator;
    }

    function getUnderlyingsAmountsFromClusterAmount(uint256 _clusterAmount, address _clusterAddress)
        external
        view
        override
        returns (uint256[] memory)
    {

        uint256 totalCluster = IERC20(_clusterAddress).totalSupply();
        uint256 clusterShare = (_clusterAmount * CLUSTER_TOKEN_DECIMALS) / totalCluster;

        address[] memory _underlyings = IClusterToken(_clusterAddress).getUnderlyings();
        uint256[] memory underlyingsAmount = new uint256[](_underlyings.length);

        for (uint256 i = 0; i < _underlyings.length; i++) {
            uint256 amount = IClusterToken(_clusterAddress).getUnderlyingBalance(_underlyings[i]);
            underlyingsAmount[i] = (amount * clusterShare) / CLUSTER_TOKEN_DECIMALS;
        }

        return underlyingsAmount;
    }

    function getEthAmountFromUnderlyingsAmounts(uint256[] memory _underlyingsAmounts, address _cluster)
        external
        view
        override
        returns (uint256)
    {

        address[] memory _underlyings = IClusterToken(_cluster).getUnderlyings();
        uint256 ethAmount = 0;
        address weth = IDexAdapter(adapters[_cluster]).WETH();
        for (uint256 i = 0; i < _underlyings.length; i++) {
            ethAmount += IDexAdapter(adapters[_cluster]).getUnderlyingAmount(_underlyingsAmounts[i], _underlyings[i], weth);
        }
        return ethAmount;
    }

    function getUnderlyingsInfo(address _cluster, uint256 _clusterAmount)
        external
        view
        override
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256,
            uint256
        )
    {

        address adapter = adapters[_cluster];
        address[] memory _underlyings = IClusterToken(_cluster).getUnderlyings();
        uint256[] memory _shares = IClusterToken(_cluster).getUnderlyingInCluster();

        (, uint256 proportionDenominator) = _getTokensProportions(_shares, IDexAdapter(adapter).getTokensPrices(_underlyings));

        uint256[] memory underlyingsAmounts = new uint256[](_underlyings.length);
        uint256[] memory ethPortions = new uint256[](_underlyings.length);

        uint256 ethAmount = 0;
        for (uint256 i = 0; i < _underlyings.length; i++) {
            underlyingsAmounts[i] = (_clusterAmount * _shares[i]) / SHARES_DECIMALS;
            uint8 decimals = IERC20Metadata(_underlyings[i]).decimals();
            if (decimals < 18) {
                underlyingsAmounts[i] /= 10**(18 - decimals);
            }

            ethPortions[i] = IDexAdapter(adapter).getEthAmountWithSlippage(underlyingsAmounts[i], _underlyings[i]);
            ethAmount += ethPortions[i];
        }

        return (underlyingsAmounts, ethPortions, proportionDenominator, ethAmount);
    }

    function getDHVPriceInETH(address _cluster) external view override returns (uint256) {

        return IDexAdapter(adapters[_cluster]).getDHVPriceInETH(dhvTokenInstance);
    }

    function getClusterPrice(address _cluster) external view override returns (uint256) {

        address adapter = adapters[_cluster];
        address[] memory _underlyings = IClusterToken(_cluster).getUnderlyings();
        uint256[] memory _shares = IClusterToken(_cluster).getUnderlyingInCluster();

        uint256[] memory prices = IDexAdapter(adapter).getTokensPrices(_underlyings);
        (, uint256 proportionDenominator) = _getTokensProportions(_shares, prices);

        return proportionDenominator;
    }

    function _getTokensProportions(uint256[] memory _shares, uint256[] memory _prices) internal pure returns (uint256[] memory, uint256) {

        uint256[] memory proportions = new uint256[](_shares.length);
        uint256 proportionDenominator = 0;
        for (uint256 i = 0; i < _shares.length; i++) {
            proportions[i] = (_shares[i] * _prices[i]) / SHARES_DECIMALS;
            proportionDenominator += proportions[i];
        }
        return (proportions, proportionDenominator);
    }

    function getDepositComission(address _cluster, uint256 _ethValue) external view override returns (uint256) {

        return (_ethValue * depositComission[_cluster]) / SHARES_DECIMALS;
    }

    function getRedeemComission(address _cluster, uint256 _ethValue) external view override returns (uint256) {

        return (_ethValue * redeemComission[_cluster]) / SHARES_DECIMALS;
    }
}