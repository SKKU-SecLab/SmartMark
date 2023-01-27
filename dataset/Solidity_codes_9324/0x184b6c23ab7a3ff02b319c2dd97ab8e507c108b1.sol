
pragma solidity 0.6.12;

contract OwnableData {

    address public owner;
    address public pendingOwner;
}

contract Ownable is OwnableData {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(address newOwner, bool direct, bool renounce) public onlyOwner {

        if (direct) {
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        } else {
            pendingOwner = newOwner;
        }
    }

    function claimOwnership() public {

        address _pendingOwner = pendingOwner;

        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}pragma solidity >=0.4.24;

interface ISynth {

    function currencyKey() external view returns (bytes32);


    function transferableSynths(address account) external view returns (uint);


    function transferAndSettle(address to, uint value) external returns (bool);


    function transferFromAndSettle(
        address from,
        address to,
        uint value
    ) external returns (bool);


    function burn(address account, uint amount) external;


    function issue(address account, uint amount) external;

}pragma solidity >=0.4.24;


interface IVirtualSynth {

    function balanceOfUnderlying(address account) external view returns (uint);


    function rate() external view returns (uint);


    function readyToSettle() external view returns (bool);


    function secsLeftInWaitingPeriod() external view returns (uint);


    function settled() external view returns (bool);


    function synth() external view returns (ISynth);


    function settle(address account) external;

}pragma solidity >=0.4.24;


interface ISynthetix {

    function anySynthOrSNXRateIsInvalid() external view returns (bool anyRateInvalid);


    function availableCurrencyKeys() external view returns (bytes32[] memory);


    function availableSynthCount() external view returns (uint);


    function availableSynths(uint index) external view returns (ISynth);


    function collateral(address account) external view returns (uint);


    function collateralisationRatio(address issuer) external view returns (uint);


    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint);


    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool);


    function maxIssuableSynths(address issuer) external view returns (uint maxIssuable);


    function remainingIssuableSynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );


    function synths(bytes32 currencyKey) external view returns (ISynth);


    function synthsByAddress(address synthAddress) external view returns (bytes32);


    function totalIssuedSynths(bytes32 currencyKey) external view returns (uint);


    function totalIssuedSynthsExcludeEtherCollateral(bytes32 currencyKey) external view returns (uint);


    function transferableSynthetix(address account) external view returns (uint transferable);


    function burnSynths(uint amount) external;


    function burnSynthsOnBehalf(address burnForAddress, uint amount) external;


    function burnSynthsToTarget() external;


    function burnSynthsToTargetOnBehalf(address burnForAddress) external;


    function exchange(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);


    function exchangeOnBehalf(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);


    function exchangeWithTracking(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address originator,
        bytes32 trackingCode
    ) external returns (uint amountReceived);


    function exchangeOnBehalfWithTracking(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address originator,
        bytes32 trackingCode
    ) external returns (uint amountReceived);


    function exchangeWithVirtual(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        bytes32 trackingCode
    ) external returns (uint amountReceived, IVirtualSynth vSynth);


    function issueMaxSynths() external;


    function issueMaxSynthsOnBehalf(address issueForAddress) external;


    function issueSynths(uint amount) external;


    function issueSynthsOnBehalf(address issueForAddress, uint amount) external;


    function mint() external returns (bool);


    function settle(bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );


    function liquidateDelinquentAccount(address account, uint susdAmount) external returns (bool);



    function mintSecondary(address account, uint amount) external;


    function mintSecondaryRewards(uint amount) external;


    function burnSecondary(address account, uint amount) external;

}// MIT

pragma solidity 0.6.12;

interface IUni {

    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;

}// MIT

pragma solidity 0.6.12;

interface ICurve {

    function exchange(
        int128 from,
        int128 to,
        uint256 _from_amount,
        uint256 _min_to_amount
    ) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity 0.6.12;




contract StrategyTrader is Ownable {

    address public constant synthetix = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address public constant uni = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant curveEURS = 0x0Ce6a5fF5217e38315f87032CF90686C96627CAA;
    address public constant curveSUSD = 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;

    address public constant EURS = 0xdB25f211AB05b1c97D595516F45794528a807ad8; 
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant SUSD = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address public constant SEUR = 0xD71eCFF9342A5Ced620049e616c5035F1dB98620;

    bytes32 public constant SUSDkey = 0x7355534400000000000000000000000000000000000000000000000000000000;
    bytes32 public constant SEURkey = 0x7345555200000000000000000000000000000000000000000000000000000000;

    constructor() public {
        IERC20(SEUR).approve(curveEURS, type(uint256).max);
        IERC20(EURS).approve(uni, type(uint256).max);
        IERC20(USDC).approve(curveSUSD, type(uint256).max);
    }

    function execute(
        uint256 SEURtoTrade,
        uint256 minEURrate,
        uint256 minSEURout
    )
        external
        onlyOwner
    {

        uint256 initialSeurBalance = IERC20(SEUR).balanceOf(address(this));

        ICurve(curveEURS).exchange(1, 0, SEURtoTrade, 0); // SEUR => EURS
        address[] memory path = new address[](2);
        path[0] = EURS;
        path[1] = USDC;

        IUni(uni).swapExactTokensForTokens(IERC20(EURS).balanceOf(address(this)), minEURrate * IERC20(EURS).balanceOf(address(this)) / 100, path, address(this), 9999999999);
        ICurve(curveSUSD).exchange(1, 3, IERC20(USDC).balanceOf(address(this)), 0); // USDC => SUSD
        ISynthetix(synthetix).exchange(SUSDkey, IERC20(SUSD).balanceOf(address(this)), SEURkey);

        require(minSEURout <= initialSeurBalance - IERC20(SEUR).balanceOf(address(this)), "Not Enough");
    }

    function harvest(address to) external onlyOwner {

        IERC20(SEUR).transfer(to, IERC20(SEUR).balanceOf(address(this)));
    }
}