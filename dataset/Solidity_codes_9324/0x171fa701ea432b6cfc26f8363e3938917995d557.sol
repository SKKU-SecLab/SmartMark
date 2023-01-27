pragma solidity ^0.7.0;

library SafeMathTyped {

    function mul256(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "uint256 overflow");

        return c;
    }

    function div256(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "Can't divide by 0");
        uint256 c = a / b;

        return c;
    }

    function sub256(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "uint256 underflow");
        uint256 c = a - b;

        return c;
    }

    function add256(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "uint256 overflow");

        return c;
    }

    function mod256(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "Can't mod by 0");
        return a % b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint) {

        return a > b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint) {

        return a < b ? a : b;
    }
}// MIT
pragma solidity >=0.7.0;

interface Erc20
{

    function symbol() view external returns (string memory _symbol);

    function decimals() view external returns (uint8 _decimals);

    
    function balanceOf(address _owner) 
        view
        external
        returns (uint256 _balance);

        
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address _to, uint256 _amount) 
        external
        returns (bool _success);

    function transferFrom(address _from, address _to, uint256 _amount)
        external
        returns (bool _success);


    function approve(address _spender, uint256 _amount) 
        external
        returns (bool _success);

}// UNLICENSED
pragma solidity >=0.7.0;

interface Minter
{

    function mint(address _target, uint256 _amount) external;

}// UNLICENSED
pragma solidity >=0.7.0;

interface IPricer
{

    function currentPrice()
        view
        external
        returns (uint256 _currentPrice);

}// UNLICENSED
pragma solidity >=0.7.0;

interface ILiquidityEstablisher
{

    function isLiquidityEstablishedOrExpired()
        external
        view
        returns (bool _isEstablishedOrExpired);

}// UNLICENSED

pragma solidity >=0.7.0;

contract ScaleBuying is IPricer
{

    Erc20 public paymentAsset;
    Erc20 public boughtAsset;
    Minter public minter;
    uint64 public closingDate;
    address public treasury;
    ILiquidityEstablisher public liquidityEstablisher;
    uint256 public amountAwarded;
    uint256 public initialPrice;
    uint256 public priceIncrease;
    uint256 public tokensPerPriceBlock;
    uint256 public maxBlocks;

    mapping(address => uint256) public amountsClaimable;

    constructor (Erc20 _paymentAsset, Erc20 _boughtAsset, Minter _minter, address _treasury, uint256 _initialPrice, 
        uint256 _priceIncrease, uint256 _tokensPerPriceBlock, uint256 _maxBlocks, uint64 _closingDate)
    {
        paymentAsset = _paymentAsset;
        boughtAsset = _boughtAsset;
        minter = _minter;
        treasury = _treasury;
        amountAwarded = 0;
        initialPrice = _initialPrice;
        priceIncrease = _priceIncrease;
        tokensPerPriceBlock = _tokensPerPriceBlock;
        maxBlocks = _maxBlocks;
        closingDate = _closingDate;

        allocateTokensRaisedByAuction();
    }

    function allocateTokensRaisedByAuction() 
        private
    {

        uint256 price = initialPrice;
        
        uint256 buyerAAmount = 7165 ether;
        amountsClaimable[0xEE779e4b3e7b11454ed80cFE12Cf48ee3Ff4579E] = buyerAAmount;
        emit Bought(0xEE779e4b3e7b11454ed80cFE12Cf48ee3Ff4579E, buyerAAmount, price);
        
        uint256 buyerBAmount = 4065 ether;
        amountsClaimable[0x6C4f3Db0E743A9e8f44A756b6585192B358D7664] = buyerBAmount;
        emit Bought(0x6C4f3Db0E743A9e8f44A756b6585192B358D7664, buyerAAmount, price);

        uint256 buyerCAmount = 355 ether;
        amountsClaimable[0x0FB79E6C0F5447ffe36a0050221275Da487b0E09] = buyerCAmount;
        emit Bought(0x0FB79E6C0F5447ffe36a0050221275Da487b0E09, buyerAAmount, price);

        amountAwarded = buyerAAmount + buyerBAmount + buyerCAmount;
    }

    function setLiquidityEstablisher(ILiquidityEstablisher _liquidityEstablisher)
        external
    {

        require(address(liquidityEstablisher) == address(0), "ABQDAO/already-set");

        liquidityEstablisher = _liquidityEstablisher;
    }

    event Claimed(address indexed claimer, uint256 amount);
    function claim(address _target)
        external
    {

        require(liquidityEstablisher.isLiquidityEstablishedOrExpired(), "ABQDAO/cannot-claim-yet");

        uint256 amountClaimable = amountsClaimable[_target];
        if (amountClaimable > 0)
        {
            bool isSuccess = boughtAsset.transfer(_target, amountClaimable);
            require(isSuccess, "ABQDAO/could-not-transfer-claim");
            amountsClaimable[_target] = 0;
            emit Claimed(_target, amountClaimable);
        }
    }

    event Bought(address indexed buyer, uint256 amount, uint256 pricePerToken);
    function buy(uint256 _paymentAmount, address _target) 
        external
        returns (uint256 _paymentLeft)
    {

        require(block.timestamp <= closingDate, "ABQDAO/ico-concluded");

        (uint256 paymentLeft, uint256 paymentDue) = buyInBlock(_paymentAmount, _target);
        if (paymentDue > 0)
        {
            bool isSuccess = paymentAsset.transferFrom(msg.sender, treasury, paymentDue);
            require(isSuccess, "ABQDAO/could-not-pay");
        }
        return paymentLeft;
    }

    function buyInBlock(uint256 _paymentAmount, address _target)
        private
        returns (uint256 _paymentLeft, uint256 _paymentDue)
    {

        uint256 currentBlockIndex = currentBlock();
        uint256 tokensLeft = tokensLeftInBlock(currentBlockIndex);

        if (currentBlockIndex >= maxBlocks)
        {
            return (_paymentAmount, 0);
        }
        else
        {
            uint256 currentPriceLocal = currentPrice();
            uint256 tokensCanPayFor = _paymentAmount / currentPriceLocal;
            if (tokensCanPayFor == 0)
            {
                return (_paymentAmount, 0);
            }
            if (tokensCanPayFor > (tokensLeft / 1 ether))
            {
                tokensCanPayFor = tokensLeft / 1 ether;
            }

            uint256 paymentDue = SafeMathTyped.mul256(tokensCanPayFor, currentPriceLocal);
            tokensCanPayFor = SafeMathTyped.mul256(tokensCanPayFor, 1 ether);
            amountsClaimable[_target] = SafeMathTyped.add256(amountsClaimable[_target], tokensCanPayFor);
            amountAwarded = SafeMathTyped.add256(amountAwarded, tokensCanPayFor);
            minter.mint(address(this), tokensCanPayFor);
            emit Bought(_target, tokensCanPayFor, currentPriceLocal);
            uint256 paymentLeft = SafeMathTyped.sub256(_paymentAmount, paymentDue);
            
            if (paymentLeft <= currentPriceLocal)
            {
                return (paymentLeft, paymentDue);
            }
            else
            {
                (uint256 subcallPaymentLeft, uint256 subcallPaymentDue) = buyInBlock(paymentLeft, _target);
                paymentDue = SafeMathTyped.add256(paymentDue, subcallPaymentDue);
                return (subcallPaymentLeft, paymentDue);
            }
        }
    }

    function currentPrice()
        view
        public
        override
        returns (uint256 _currentPrice)
    {

        return SafeMathTyped.add256(initialPrice, SafeMathTyped.mul256(currentBlock(), priceIncrease));
    }

    function currentBlock() 
        view
        public
        returns (uint256 _currentBlock)
    {

        return amountAwarded / tokensPerPriceBlock;
    }

    function tokensLeftInBlock(uint256 _block)
        view
        public
        returns (uint256 _tokensLeft)
    {

        uint256 currentBlockIndex = currentBlock();

        if (_block > maxBlocks || _block < currentBlockIndex)
        {
            return 0;
        }

        if (_block == currentBlockIndex)
        {
            return SafeMathTyped.sub256(SafeMathTyped.mul256(SafeMathTyped.add256(currentBlockIndex, 1), tokensPerPriceBlock), amountAwarded);
        }
        else
        {
            return tokensPerPriceBlock;
        }
    }
}