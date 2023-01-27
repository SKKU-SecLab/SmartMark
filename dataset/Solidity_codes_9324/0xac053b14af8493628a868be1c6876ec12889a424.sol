
pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.8.6;

library LibHidingVault {

    bytes32 constant HIDING_VAULT_STORAGE_POSITION = 0x9b85f6ce841a6faee042a2e67df9613579f746ca80e5eb1163b287041381d23c;
    
    struct State {
        NFTLike nft;
        mapping(address => bool) recoverableTokensBlacklist;
    }

    function state() internal pure returns (State storage s) {

        bytes32 position = HIDING_VAULT_STORAGE_POSITION;
        assembly {
            s.slot := position
        } 
    }
}

interface NFTLike {

    function ownerOf(uint256 _tokenID) view external returns (address);

    function implementations(bytes4 _sig) view external returns (address);

}// BSD-3-Clause

pragma solidity 0.8.6;


contract CTokenStorage {

    string public name;

    string public symbol;

    uint8 public decimals;

    address public comptroller;

    uint public totalSupply;
}

abstract contract CToken is CTokenStorage {
    bool public constant isCToken = true;

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approval(address indexed owner, address indexed spender, uint amount);

    event Failure(uint error, uint info, uint detail);



    function transfer(address dst, uint amount) external virtual returns (bool);
    function transferFrom(address src, address dst, uint amount) external virtual returns (bool);
    function approve(address spender, uint amount) external virtual returns (bool);
    function allowance(address owner, address spender) external virtual view returns (uint);
    function balanceOf(address owner) external virtual view returns (uint);
    function balanceOfUnderlying(address owner) external virtual returns (uint);
    function getAccountSnapshot(address account) external virtual view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() external virtual view returns (uint);
    function supplyRatePerBlock() external virtual view returns (uint);
    function totalBorrowsCurrent() external virtual returns (uint);
    function borrowBalanceCurrent(address account) external virtual returns (uint);
    function borrowBalanceStored(address account) external virtual view returns (uint);
    function exchangeRateCurrent() external virtual returns (uint);
    function exchangeRateStored() external virtual view returns (uint);
    function getCash() external virtual view returns (uint);
    function accrueInterest() external virtual returns (uint);
    function seize(address liquidator, address borrower, uint seizeTokens) external virtual returns (uint);
}

abstract contract CErc20 is CToken {
    function underlying() external virtual view returns (address);
    function mint(uint mintAmount) external virtual returns (uint);
    function repayBorrow(uint repayAmount) external virtual returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external virtual returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, CToken cTokenCollateral) external virtual returns (uint);
    function redeem(uint redeemTokens) external virtual returns (uint);
    function redeemUnderlying(uint redeemAmount) external virtual returns (uint);
    function borrow(uint borrowAmount) external virtual returns (uint);
}

abstract contract CEther is CToken {
    function mint() external virtual payable;
    function repayBorrow() external virtual payable;
    function repayBorrowBehalf(address borrower) external virtual payable;
    function liquidateBorrow(address borrower, CToken cTokenCollateral) external virtual payable;
    function redeem(uint redeemTokens) external virtual returns (uint);
    function redeemUnderlying(uint redeemAmount) external virtual returns (uint);
    function borrow(uint borrowAmount) external virtual returns (uint);
}

abstract contract PriceOracle {
    function getUnderlyingPrice(CToken cToken) external virtual view returns (uint);
}

abstract contract Comptroller {
    uint public closeFactorMantissa;

    CToken[] public allMarkets;

    PriceOracle public oracle;

    struct Market {
        bool isListed;

        
        uint collateralFactorMantissa;

        mapping(address => bool) accountMembership;

        bool isComped;
    }

    mapping(address => Market) public markets;


    function enterMarkets(address[] calldata cTokens) external virtual returns (uint[] memory);
    function exitMarket(address cToken) external virtual returns (uint);
    function checkMembership(address account, CToken cToken) external virtual view returns (bool);


    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint repayAmount) external virtual view returns (uint, uint);

    function getAssetsIn(address account) external virtual view returns (address[] memory);

    function getHypotheticalAccountLiquidity(
        address account,
        address cTokenModify,
        uint redeemTokens,
        uint borrowAmount) external virtual view returns (uint, uint, uint);

    function _setPriceOracle(PriceOracle newOracle) external virtual returns (uint);
}

contract SimplePriceOracle is PriceOracle {

    mapping(address => uint) prices;
    uint256 ethPrice;
    event PricePosted(address asset, uint previousPriceMantissa, uint requestedPriceMantissa, uint newPriceMantissa);

    function getUnderlyingPrice(CToken cToken) public override view returns (uint) {

        if (compareStrings(cToken.symbol(), "cETH")) {
            return ethPrice;
        } else {
            return prices[address(CErc20(address(cToken)).underlying())];
        }
    }

    function setUnderlyingPrice(CToken cToken, uint underlyingPriceMantissa) public {

         if (compareStrings(cToken.symbol(), "cETH")) {
            ethPrice = underlyingPriceMantissa;
        } else {
            address asset = address(CErc20(address(cToken)).underlying());
            emit PricePosted(asset, prices[asset], underlyingPriceMantissa, underlyingPriceMantissa);
            prices[asset] = underlyingPriceMantissa;
        }   
    }

    function setDirectPrice(address asset, uint price) public {

        emit PricePosted(asset, prices[asset], price, price);
        prices[asset] = price;
    }

    function assetPrices(address asset) external view returns (uint) {

        return prices[asset];
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {

        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}// LGPL-3.0-or-later
pragma solidity 0.8.6;


interface IKCompound {

    function compound_balanceOf(CToken _cToken) external returns (uint256);

    
    function compound_balanceOfUnderlying(CToken _cToken) external returns (uint256);

    
    function compound_unhealth() external view returns (uint256);


    function compound_isUnderwritten() external view returns (bool);



    function compound_deposit(CToken _cToken, uint256 _amount) external payable;


    function compound_repay(CToken _cToken, uint256 _amount) external payable;


    function compound_withdraw(address payable _to, CToken _cToken, uint256 _amount) external;


    function compound_borrow(address payable _to, CToken _cToken, uint256 _amount) external;


    function compound_enterMarkets(address[] memory _cTokens) external;


    function compound_exitMarket(address _market) external;



    function compound_migrate(
        address account, 
        uint256 _amount, 
        address[] memory _collateralMarkets, 
        address[] memory _debtMarkets
    ) external;


    function compound_preempt(
        address _liquidator, 
        CToken _cTokenRepay, 
        uint _repayAmount, 
        CToken _cTokenCollateral
    ) external payable returns (uint256);


    function compound_underwrite(CToken _cToken, uint256 _tokens) external payable;


    function compound_reclaim() external; 

}// LGPL-3.0-or-later
pragma solidity 0.8.6;


library LibCToken {

    using SafeERC20 for IERC20;

    Comptroller constant COMPTROLLER = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    CEther constant CETHER = CEther(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);

    function isListed(CToken _cToken) internal view returns (bool listed) {

        (listed, , ) = COMPTROLLER.markets(address(_cToken));
    }

    function underlying(CToken _cToken) internal view returns (address) {

        if (address(_cToken) == address(CETHER)) {
            return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else {
            return CErc20(address(_cToken)).underlying();
        }
    }

    function redeemUnderlying(CToken _cToken, uint _amount) internal {

        if (address(_cToken) == address(CETHER)) {
            require(CETHER.redeemUnderlying(_amount) == 0, "failed to redeem ether");
        } else {
            require(CErc20(address(_cToken)).redeemUnderlying(_amount) == 0, "failed to redeem ERC20");
        }
    }

    function borrow(CToken _cToken, uint _amount) internal {

        if (address(_cToken) == address(CETHER)) {
            require(CETHER.borrow(_amount) == 0, "failed to borrow ether");
        } else {
            require(CErc20(address(_cToken)).borrow(_amount) == 0, "failed to borrow ERC20");
        }
    }

    function mint(CToken _cToken, uint _amount) internal {

        if (address(_cToken) == address(CETHER)) {
            CETHER.mint{ value: _amount }();
        } else {

            require(CErc20(address(_cToken)).mint(_amount) == 0, "failed to mint cERC20");
        }
    }

    function repayBorrow(CToken _cToken, uint _amount) internal {

        if (address(_cToken) == address(CETHER)) {
            CETHER.repayBorrow{ value: _amount }();
        } else {
            require(CErc20(address(_cToken)).repayBorrow(_amount) == 0, "failed to mint cERC20");
        }
    }

    function repayBorrowBehalf(CToken _cToken, address _borrower, uint _amount) internal {

        if (address(_cToken) == address(CETHER)) {
            CETHER.repayBorrowBehalf{ value: _amount }(_borrower);
        } else {
            require(CErc20(address(_cToken)).repayBorrowBehalf(_borrower, _amount) == 0, "failed to mint cERC20");
        }
    }

    function transferUnderlying(CToken _cToken, address payable _to, uint256 _amount) internal {

        if (address(_cToken) == address(CETHER)) {
            (bool success,) = _to.call{ value: _amount }("");
            require(success, "Transfer Failed");
        } else {
            IERC20(CErc20(address(_cToken)).underlying()).safeTransfer(_to, _amount);
        }
    }

    function approveUnderlying(CToken _cToken, address _spender, uint256 _amount) internal {

        if (address(_cToken) != address(CETHER)) {
            IERC20 token = IERC20(CErc20(address(_cToken)).underlying());
            token.safeIncreaseAllowance(_spender, _amount);
        } 
    }

    function pullAndApproveUnderlying(CToken _cToken, address _from, address _to, uint256 _amount) internal {

        if (address(_cToken) == address(CETHER)) {
            require(msg.value == _amount, "failed to mint CETHER");
        } else {
            IERC20 token = IERC20(CErc20(address(_cToken)).underlying());
            token.safeTransferFrom(_from, address(this), _amount);
            token.safeIncreaseAllowance(_to, _amount);
        }
    }
}// LGPL-3.0-or-later
pragma solidity 0.8.6;


library LibCompound {

    using LibCToken for CToken;

    bytes32 constant KCOMPOUND_STORAGE_POSITION = 0x4f39ec42b5bbf77786567b02cbf043f85f0f917cbaa97d8df56931d77a999205;

    struct State {
        uint256 bufferAmount;
        CToken bufferToken;
    }

    function state() internal pure returns (State storage s) {

        bytes32 position = KCOMPOUND_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function migrate(
        address _account, 
        uint256 _tokens, 
        address[] memory _collateralMarkets, 
        address[] memory _debtMarkets
    ) internal {

        enterMarkets(_collateralMarkets);

        if (_debtMarkets.length != 0) migrateLoans(_debtMarkets, _account);

        if (_collateralMarkets.length != 0) migrateFunds(_collateralMarkets, _account);
        
        require(
            CToken(_collateralMarkets[0]).transfer(msg.sender, _tokens), 
            "LibCompound: failed to return funds during migration"
        );
    }

    function migrateLoans(address[] memory _cTokens, address _account) private {

        for (uint32 i = 0; i < _cTokens.length; i++) {
            CToken cToken = CToken(_cTokens[i]);
            uint256 borrowBalance = cToken.borrowBalanceCurrent(_account);
            cToken.borrow(borrowBalance);
            cToken.approveUnderlying(address(cToken), borrowBalance);
            cToken.repayBorrowBehalf(_account, borrowBalance);
        }
    }

    function migrateFunds(address[] memory _cTokens, address _account) private {

        for (uint32 i = 0; i < _cTokens.length; i++) {
            CToken cToken = CToken(_cTokens[i]);
            require(cToken.transferFrom(
                _account, 
                address(this), 
                cToken.balanceOf(_account)
            ), "LibCompound: failed to transfer CETHER");       
        }
    }

    function preempt(
        CToken _cTokenRepaid,
        address _liquidator,
        uint _repayAmount, 
        CToken _cTokenCollateral
    ) internal returns (uint256) {

        uint seizeTokens = seizeTokenAmount(
            address(_cTokenRepaid), 
            address(_cTokenCollateral), 
            _repayAmount
        );

        _cTokenRepaid.pullAndApproveUnderlying(_liquidator, address(_cTokenRepaid), _repayAmount);
        _cTokenRepaid.repayBorrow(_repayAmount);
        require(_cTokenCollateral.transfer(_liquidator, seizeTokens), "LibCompound: failed to transfer cTokens");
        return seizeTokens;
    }

    function underwrite(CToken _cToken, uint256 _tokens) internal { 

        require(_tokens * 3 <= _cToken.balanceOf(address(this)), 
            "LibCompound: underwrite pre-conditions not met");
        State storage s = state();
        s.bufferToken = _cToken;
        s.bufferAmount = _tokens;
        blacklistCTokens();
    }

    function reclaim() internal {

        State storage s = state();
        require(s.bufferToken.transfer(msg.sender, s.bufferAmount), "LibCompound: failed to return cTokens");
        s.bufferToken = CToken(address(0));
        s.bufferAmount = 0;
        whitelistCTokens();
    }

    function blacklistCTokens() internal {

        address[] memory cTokens = LibCToken.COMPTROLLER.getAssetsIn(address(this));
        for (uint32 i = 0; i < cTokens.length; i++) {
            LibHidingVault.state().recoverableTokensBlacklist[cTokens[i]] = true;
        }
    }

    function whitelistCTokens() internal {

        address[] memory cTokens = LibCToken.COMPTROLLER.getAssetsIn(address(this));
        for (uint32 i = 0; i < cTokens.length; i++) {
            LibHidingVault.state().recoverableTokensBlacklist[cTokens[i]] = false;
        }
    }

    function seizeTokenAmount(
        address cTokenRepaid,
        address cTokenSeized,
        uint repayAmount
    ) internal returns (uint) {

        State storage s = state();

        require(CToken(cTokenRepaid).accrueInterest() == 0, "LibCompound: failed to accrue interest on cTokenRepaid");
        require(CToken(cTokenSeized).accrueInterest() == 0, "LibCompound: failed to accrue interest on cTokenSeized");

        (uint err, , uint shortfall) = LibCToken.COMPTROLLER.getHypotheticalAccountLiquidity(address(this), address(s.bufferToken), s.bufferAmount, 0);
        require(err == 0, "LibCompound: failed to get account liquidity");
        require(shortfall != 0, "LibCompound: insufficient shortfall to liquidate");

        uint borrowBalance = CToken(cTokenRepaid).borrowBalanceStored(address(this));
        uint maxClose = mulScalarTruncate(LibCToken.COMPTROLLER.closeFactorMantissa(), borrowBalance);
        require(repayAmount <= maxClose, "LibCompound: repay amount cannot exceed the max close amount");

        (uint errCode2, uint seizeTokens) = LibCToken.COMPTROLLER
            .liquidateCalculateSeizeTokens(cTokenRepaid, cTokenSeized, repayAmount);
        require(errCode2 == 0, "LibCompound: failed to calculate seize token amount");

        uint256 seizeTokenCollateral = CToken(cTokenSeized).balanceOf(address(this));
        if (cTokenSeized == address(s.bufferToken)) {
            seizeTokenCollateral = seizeTokenCollateral - s.bufferAmount;
        }
        require(seizeTokenCollateral >= seizeTokens, "LibCompound: insufficient liquidity");

        return seizeTokens;
    }

    function collateralValueInUSD(CToken _cToken, uint256 _tokens) internal view returns (uint256) {

        uint256 exchangeRate = _cToken.exchangeRateStored();

        (, uint256 collateralFactor, ) = LibCToken.COMPTROLLER.markets(address(_cToken));

        uint256 oraclePrice = LibCToken.COMPTROLLER.oracle().getUnderlyingPrice(_cToken);
        require(oraclePrice != 0, "LibCompound: failed to get underlying price from the oracle");

        return mulExp3AndScalarTruncate(collateralFactor, exchangeRate, oraclePrice, _tokens);
    }

    function balanceOfUnderlying(CToken _cToken) internal returns (uint256) {

        return mulScalarTruncate(_cToken.exchangeRateCurrent(), balanceOf(_cToken));
    } 

    function balanceOf(CToken _cToken) internal view returns (uint256) {

        State storage s = state();
        uint256 cTokenBalance = _cToken.balanceOf(address(this));
        if (s.bufferToken == _cToken) {
            cTokenBalance -= s.bufferAmount;
        }
        return cTokenBalance;
    } 

    function enterMarkets(address[] memory _cTokens) internal {

        uint[] memory retVals = LibCToken.COMPTROLLER.enterMarkets(_cTokens);
        for (uint i; i < retVals.length; i++) {
            require(retVals[i] == 0, "LibCompound: failed to enter market");
        }
    }

    function exitMarket(address _cToken) internal {

        require(
            LibCToken.COMPTROLLER.exitMarket(_cToken) == 0, 
            "LibCompound: failed to exit a market"
        );
    }

    function unhealth() internal view returns (uint256) {

        uint256 totalCollateralValue;
        State storage s = state();

        address[] memory cTokens = LibCToken.COMPTROLLER.getAssetsIn(address(this));
        for (uint i = 0; i < cTokens.length; i++) {
            totalCollateralValue = totalCollateralValue + collateralValue(CToken(cTokens[i]));
        }
        if (totalCollateralValue > 0) {
            uint256 totalBorrowValue;

            (uint err, uint256 liquidity, uint256 shortFall) = 
                LibCToken.COMPTROLLER.getHypotheticalAccountLiquidity(
                    address(this),
                    address(s.bufferToken),
                    s.bufferAmount,
                    0
                );
            require(err == 0, "LibCompound: failed to calculate account liquidity");

            if (liquidity == 0) {
                totalBorrowValue = totalCollateralValue + shortFall;
            } else {
                totalBorrowValue = totalCollateralValue - liquidity;
            }

            return (totalBorrowValue * 100) / totalCollateralValue;
        }
        return 0;
    }

    function collateralValue(CToken cToken) internal view returns (uint256) {

        State storage s = state();
        uint256 bufferAmount;
        if (s.bufferToken == cToken) {
            bufferAmount = s.bufferAmount;
        }
        return collateralValueInUSD(
            cToken, 
            cToken.balanceOf(address(this)) - bufferAmount
        );
    }

    function isUnderwritten() internal view returns (bool) {

        State storage s = state();
        return (s.bufferAmount != 0 && s.bufferToken != CToken(address(0)));
    }

    function owner() internal view returns (address) {

        return LibHidingVault.state().nft.ownerOf(uint256(uint160(address(this))));
    }

    function mulExp3AndScalarTruncate(uint256 a, uint256 b, uint256 c, uint256 d) internal pure returns (uint256) {

        return mulScalarTruncate(mulExp(mulExp(a, b), c), d);
    }

    function mulExp(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return (_a * _b + 5e17) / 1e18;
    }

    function mulScalarTruncate(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return (_a * _b) / 1e18;
    }
}

interface Weth {

    function balanceOf(address owner) external view returns (uint);

    function deposit() external payable;

    function withdraw(uint256 _amount) external;

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address spender, uint256 amount) external returns (bool);

}

interface NFT {

    function jitu() external view returns (address);

    function ownerOf(uint256 _tokenID) external view returns (address);

}// LGPL-3.0-or-later
pragma solidity 0.8.6;


contract KCompound is IKCompound {

    using LibCToken for CToken;

    address constant JITU = 0x9e43efD070D8E3F8427862A760a37D6325821288;

    modifier onlyJITU() {

        require(msg.sender == JITU, "KCompoundPosition: caller is not the MEV protector");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == LibCompound.owner(), "KCompoundPosition: caller is not the owner");
        _;
    }
    
    modifier whenNotUnderwritten() {

        require(!compound_isUnderwritten(), "LibCompound: operation not allowed when underwritten");
        _;
    }

    modifier whenUnderwritten() {

        require(compound_isUnderwritten(), "LibCompound: operation not allowed when underwritten");
        _;
    }

    function compound_deposit(CToken _cToken, uint256 _amount) external payable override {

        require(_cToken.isListed(), "KCompound: unsupported cToken address");
        _cToken.pullAndApproveUnderlying(msg.sender, address(_cToken), _amount);
        _cToken.mint(_amount);
    }

    function compound_withdraw(address payable _to, CToken _cToken, uint256 _amount) external override onlyOwner whenNotUnderwritten {

        require(_cToken.isListed(), "KCompound: unsupported cToken address");
        _cToken.redeemUnderlying(_amount);
        _cToken.transferUnderlying(_to, _amount);
    }

    function compound_borrow(address payable _to, CToken _cToken, uint256 _amount) external override onlyOwner whenNotUnderwritten {

        require(_cToken.isListed(), "KCompound: unsupported cToken address");
        _cToken.borrow(_amount);
        _cToken.transferUnderlying(_to, _amount);
    }

    function compound_repay(CToken _cToken, uint256 _amount) external payable override {

        require(_cToken.isListed(), "KCompound: unsupported cToken address");
        _cToken.pullAndApproveUnderlying(msg.sender, address(_cToken), _amount);
        _cToken.repayBorrow(_amount);
    }

    function compound_preempt(
        address _liquidator,
        CToken _cTokenRepay,
        uint _repayAmount, 
        CToken _cTokenCollateral
    ) external payable override onlyJITU returns (uint256) {

        return LibCompound.preempt(_cTokenRepay, _liquidator, _repayAmount, _cTokenCollateral);
    }

    function compound_migrate(
        address _account, 
        uint256 _amount, 
        address[] memory _collateralMarkets, 
        address[] memory _debtMarkets
    ) external override onlyJITU {

        LibCompound.migrate(
            _account,
            _amount,
            _collateralMarkets,
            _debtMarkets
        );
    }

    function compound_underwrite(CToken _cToken, uint256 _tokens) external payable override onlyJITU whenNotUnderwritten {    

        LibCompound.underwrite(_cToken, _tokens);
    }

    function compound_reclaim() external override onlyJITU whenUnderwritten {

        LibCompound.reclaim();
    }

    function compound_enterMarkets(address[] memory _markets) external override onlyOwner {

        LibCompound.enterMarkets(_markets);
    }

    function compound_exitMarket(address _market) external override onlyOwner whenNotUnderwritten {

        LibCompound.exitMarket(_market);
    }

    function compound_balanceOfUnderlying(CToken _cToken) external override returns (uint256) {

        return LibCompound.balanceOfUnderlying(_cToken);
    }

    function compound_balanceOf(CToken _cToken) external view override returns (uint256) {

        return LibCompound.balanceOf(_cToken);
    }

    function compound_unhealth() external override view returns (uint256) {

        return LibCompound.unhealth();
    }

    function compound_isUnderwritten() public override view returns (bool) {

        return LibCompound.isUnderwritten();
    }
}