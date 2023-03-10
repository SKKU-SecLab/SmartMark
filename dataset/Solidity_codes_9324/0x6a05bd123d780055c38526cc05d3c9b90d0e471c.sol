
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IEIP20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256 balance);


    function transfer(address dst, uint256 amount) external returns (bool success);


    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);


    function approve(address spender, uint256 amount) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

interface IEIP20NonStandard {


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256 balance);



    function transfer(address dst, uint256 amount) external;



    function transferFrom(address src, address dst, uint256 amount) external;


    function approve(address spender, uint256 amount) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface PriceOracleInterface {

    function getUnderlyingPrice(address _pToken) external view returns (uint);

}

interface ComptrollerLensInterface {


    function getAllMarkets() external view returns (PTokenLensInterface[] memory);


    function markets(address) external view returns (bool, uint);


    function oracle() external view returns (PriceOracleInterface);


    function getAccountLiquidity(address) external view returns (uint, uint, uint);


    function getAssetsIn(address) external view returns (PTokenLensInterface[] memory);


    function mintCaps(address) external view returns (uint256);


    function borrowCaps(address) external view returns (uint256);

}

interface PTokenLensInterface {


    function interestRateModel() external view returns (address);


    function exchangeRateStored() external view returns (uint256);


    function comptroller() external view returns (address);


    function supplyRatePerBlock() external view returns (uint256);


    function borrowRatePerBlock() external view returns (uint256);


    function reserveFactorMantissa() external view returns (uint256);


    function totalBorrows() external view returns (uint256);


    function totalReserves() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function getCash() external view returns (uint256);


    function borrowIndex() external view returns (uint256);


    function accrualBlockNumber() external view returns (uint256);


    function underlying() external view returns (address);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function allowance(address owner, address spender) external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function getAccountSnapshot(address account) external virtual view returns (uint256, uint256, uint256, uint256);

}

interface PiggyDistributionInterface {

    function wpcSpeeds(address) external view returns (uint256);

}

interface InterestRateModelInterface {

    function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint);


    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view returns (uint);


    function blocksPerYear() external view returns (uint);


    function multiplierPerBlock() external view returns (uint);


    function baseRatePerBlock() external view returns (uint);


    function jumpMultiplierPerBlock() external view returns (uint);


    function kink() external view returns (uint);

}

contract WePiggyLensV2 {


    using SafeMath for uint256;

    ComptrollerLensInterface public comptroller;
    PiggyDistributionInterface public distribution;
    string  public pNativeToken;
    string public nativeToken;
    string public nativeName;
    address public owner;

    constructor(ComptrollerLensInterface _comptroller, PiggyDistributionInterface _distribution,
        string  memory _pNativeToken, string  memory _nativeToken, string memory _nativeName) public {
        comptroller = _comptroller;
        distribution = _distribution;
        pNativeToken = _pNativeToken;
        nativeToken = _nativeToken;
        nativeName = _nativeName;

        owner = msg.sender;
    }

    function updateProperties(ComptrollerLensInterface _comptroller, PiggyDistributionInterface _distribution,
        string  memory _pNativeToken, string  memory _nativeToken, string memory _nativeName) public {


        require(msg.sender == owner, "sender is not owner");

        comptroller = _comptroller;
        distribution = _distribution;
        pNativeToken = _pNativeToken;
        nativeToken = _nativeToken;
        nativeName = _nativeName;
    }

    struct PTokenMetadata {
        address pTokenAddress;
        uint pTokenDecimals;
        address underlyingAddress;
        uint underlyingDecimals;
        string underlyingSymbol;
        string underlyingName;
        uint exchangeRateCurrent;
        uint supplyRatePerBlock;
        uint borrowRatePerBlock;
        uint reserveFactorMantissa;
        uint collateralFactorMantissa;
        uint totalBorrows;
        uint totalReserves;
        uint totalSupply;
        uint totalCash;
        uint price;
        uint mintCap;
        uint borrowCap;
        bool isListed;
        uint blockNumber;
        uint accrualBlockNumber;
        uint borrowIndex;
    }

    function pTokenMetadata(PTokenLensInterface pToken) public view returns (PTokenMetadata memory){


        (bool isListed, uint collateralFactorMantissa) = comptroller.markets(address(pToken));

        uint mintCap = comptroller.mintCaps(address(pToken));
        uint borrowCap = comptroller.borrowCaps(address(pToken));

        address underlyingAddress;
        uint underlyingDecimals;
        string memory underlyingSymbol;
        string memory underlyingName;
        if (compareStrings(pToken.symbol(), pNativeToken)) {
            underlyingAddress = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
            underlyingDecimals = 18;
            underlyingSymbol = nativeToken;
            underlyingName = nativeName;
        } else {
            PTokenLensInterface pErc20 = PTokenLensInterface(address(pToken));
            underlyingAddress = pErc20.underlying();
            underlyingDecimals = IEIP20(pErc20.underlying()).decimals();
            underlyingSymbol = IEIP20(pErc20.underlying()).symbol();
            underlyingName = IEIP20(pErc20.underlying()).name();
        }

        uint price = PriceOracleInterface(comptroller.oracle()).getUnderlyingPrice(address(pToken));

        return PTokenMetadata({
        pTokenAddress : address(pToken),
        pTokenDecimals : pToken.decimals(),
        underlyingAddress : underlyingAddress,
        underlyingDecimals : underlyingDecimals,
        underlyingSymbol : underlyingSymbol,
        underlyingName : underlyingName,
        exchangeRateCurrent : pToken.exchangeRateStored(),
        supplyRatePerBlock : pToken.supplyRatePerBlock(),
        borrowRatePerBlock : pToken.borrowRatePerBlock(),
        reserveFactorMantissa : pToken.reserveFactorMantissa(),
        collateralFactorMantissa : collateralFactorMantissa,
        totalBorrows : pToken.totalBorrows(),
        totalReserves : pToken.totalReserves(),
        totalSupply : pToken.totalSupply(),
        totalCash : pToken.getCash(),
        price : price,
        mintCap : mintCap,
        borrowCap : borrowCap,
        isListed : isListed,
        blockNumber : block.number,
        accrualBlockNumber : pToken.accrualBlockNumber(),
        borrowIndex : pToken.borrowIndex()
        });

    }

    function pTokenMetadataAll(PTokenLensInterface[] memory pTokens) public view returns (PTokenMetadata[] memory) {

        uint pTokenCount = pTokens.length;
        PTokenMetadata[] memory res = new PTokenMetadata[](pTokenCount);
        for (uint i = 0; i < pTokenCount; i++) {
            res[i] = pTokenMetadata(pTokens[i]);
        }
        return res;
    }

    struct PTokenBalances {
        address pToken;
        uint balance;
        uint borrowBalance; //???????????????
        uint exchangeRateMantissa;
    }

    function pTokenBalances(PTokenLensInterface pToken, address payable account) public view returns (PTokenBalances memory) {


        (, uint tokenBalance, uint borrowBalance, uint exchangeRateMantissa) = pToken.getAccountSnapshot(account);

        return PTokenBalances({
        pToken : address(pToken),
        balance : tokenBalance,
        borrowBalance : borrowBalance,
        exchangeRateMantissa : exchangeRateMantissa
        });

    }

    function pTokenBalancesAll(PTokenLensInterface[] memory pTokens, address payable account) public view returns (PTokenBalances[] memory) {

        uint pTokenCount = pTokens.length;
        PTokenBalances[] memory res = new PTokenBalances[](pTokenCount);
        for (uint i = 0; i < pTokenCount; i++) {
            res[i] = pTokenBalances(pTokens[i], account);
        }
        return res;
    }

    struct AccountLimits {
        PTokenLensInterface[] markets;
        uint liquidity;
        uint shortfall;
    }


    function getAccountLimits(address payable account) public view returns (AccountLimits memory) {

        (uint errorCode, uint liquidity, uint shortfall) = comptroller.getAccountLiquidity(account);
        require(errorCode == 0);

        return AccountLimits({
        markets : comptroller.getAssetsIn(account),
        liquidity : liquidity,
        shortfall : shortfall
        });
    }

    struct PTokenWpcSpeed {
        PTokenLensInterface market;
        uint wpcSpeed;
    }

    function getWpcSpeed(PTokenLensInterface pToken) public view returns (PTokenWpcSpeed memory){

        uint wpcSpeed = distribution.wpcSpeeds(address(pToken));
        return PTokenWpcSpeed({
        market : pToken,
        wpcSpeed : wpcSpeed
        });
    }

    function getWpcSpeeds(PTokenLensInterface[] memory pTokens) public view returns (PTokenWpcSpeed[] memory){

        uint pTokenCount = pTokens.length;
        PTokenWpcSpeed[] memory res = new PTokenWpcSpeed[](pTokenCount);
        for (uint i = 0; i < pTokenCount; i++) {
            res[i] = getWpcSpeed(pTokens[i]);
        }
        return res;
    }


    struct InterestRateModel {
        PTokenLensInterface market;
        uint blocksPerYear;
        uint multiplierPerBlock;
        uint baseRatePerBlock;
        uint jumpMultiplierPerBlock;
        uint kink;
    }

    function getInterestRateModel(PTokenLensInterface pToken) public view returns (InterestRateModel memory){

        InterestRateModelInterface interestRateModel = InterestRateModelInterface(pToken.interestRateModel());

        return InterestRateModel({
        market : pToken,
        blocksPerYear : interestRateModel.blocksPerYear(),
        multiplierPerBlock : interestRateModel.multiplierPerBlock(),
        baseRatePerBlock : interestRateModel.baseRatePerBlock(),
        jumpMultiplierPerBlock : interestRateModel.jumpMultiplierPerBlock(),
        kink : interestRateModel.kink()
        });
    }

    function getInterestRateModels(PTokenLensInterface[] memory pTokens) public view returns (InterestRateModel[] memory){

        uint pTokenCount = pTokens.length;
        InterestRateModel[] memory res = new InterestRateModel[](pTokenCount);
        for (uint i = 0; i < pTokenCount; i++) {
            res[i] = getInterestRateModel(pTokens[i]);
        }
        return res;
    }


    function all() external view returns (PTokenMetadata[] memory, InterestRateModel[] memory, PTokenWpcSpeed[] memory){


        PTokenLensInterface[] memory pTokens = comptroller.getAllMarkets();
        PTokenMetadata[] memory metaData = pTokenMetadataAll(pTokens);
        InterestRateModel[] memory rateModels = getInterestRateModels(pTokens);
        PTokenWpcSpeed[] memory wpcSpeeds = getWpcSpeeds(pTokens);

        return (metaData, rateModels, wpcSpeeds);
    }


    function allForAccount(address payable account) external view returns (AccountLimits memory, PTokenBalances[] memory, PTokenMetadata[] memory, InterestRateModel[] memory){


        AccountLimits memory accountLimits = getAccountLimits(account);

        PTokenLensInterface[] memory pTokens = comptroller.getAllMarkets();
        PTokenBalances[] memory balances = pTokenBalancesAll(pTokens, account);
        PTokenMetadata[] memory metaData = pTokenMetadataAll(pTokens);
        InterestRateModel[] memory rateModels = getInterestRateModels(pTokens);

        return (accountLimits, balances, metaData, rateModels);
    }


    function compareStrings(string memory a, string memory b) internal pure returns (bool) {

        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}