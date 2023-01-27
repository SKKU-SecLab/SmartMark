pragma solidity ^0.7.0;

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

}// MIT
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
}// UNLICENSED

pragma solidity ^0.7.0;

struct Bid
{
    uint128 pricePerToken;
    uint128 amountOfTokens;
    address bidder;
}

struct LeafNode
{
    uint256 amountOfTokens;
    uint256 startIndex;
    Bid[] bids;
}

contract RollingAuction
{

    uint128 public firstTokenAmountToAllocate;
    uint128 constant public minAmount = 100;
    uint128 constant public maxAmount = 999;
    uint128 constant public minTokensPerBid = 100;
    uint128 public tokensPerTimeslice;
    uint256 constant public bidAssetScaling = 10000000000000000;
    uint256 constant public allocatingAssetDecimalsScaling = 1000000000000000000;
    uint128 public tokensLeftForCurrentTimeslice = 0;
    uint128 public amountLeft;
    uint128 public amountUnallocated = 0;
    Erc20 public allocationAsset;
    Erc20 public bidAsset;
    address public fundAddress;
    address public unallocatedAddress;
    uint256 public startDate;
    uint256 public timeWindow;
    uint256 public lastAllocatedTimeslice;
    uint256 constant public outrightBuyId = type(uint256).max;
    

    mapping(address => uint128) public allocations;
    mapping(uint256 => uint256) public level1;  // X.00
    mapping(uint256 => mapping(uint256 => uint256)) public level2;  // 0.X0
    mapping(uint256 => mapping(uint256 => mapping(uint256 => LeafNode))) public level3; // 0.0X

    constructor(
        uint128 _amountLeft, 
        Erc20 _allocationAsset, 
        Erc20 _bidAsset, 
        address _fundAddress, 
        address _unallocatedAddress, 
        uint256 _startDate, 
        uint256 _timeWindow, 
        uint128 _firstTokenAmountToAllocate, 
        uint128 _tokensPerTimeslice)
    {
        amountLeft = _amountLeft;
        allocationAsset = _allocationAsset;
        bidAsset = _bidAsset;
        fundAddress = _fundAddress;
        unallocatedAddress = _unallocatedAddress;
        startDate = _startDate;
        timeWindow = _timeWindow;
        firstTokenAmountToAllocate = _firstTokenAmountToAllocate;
        tokensPerTimeslice = _tokensPerTimeslice;
    }

    function topBid()
        external
        view
        returns (uint128 _pricePerToken)
    {

        for (uint128 level1Index = 9; level1Index < 10; level1Index -= 1)
        {
            uint256 level1Amount = level1[level1Index];
            if (level1Amount > 0)
            {
                for (uint128 level2Index = 9; level2Index < 10; level2Index -= 1)
                {
                    uint256 level2Amount = level2[level1Index][level2Index];
                    if (level2Amount > 0)
                    {
                        for (uint128 level3Index = 9; level3Index < 10; level3Index -= 1)
                        {
                            LeafNode storage node = level3[level1Index][level2Index][level3Index];
                            if (node.amountOfTokens > 0)
                            {
                                return uint128((level1Index * 100) + (level2Index * 10) + level3Index);
                            }

                            if (level3Index == 0)
                            {
                                break;
                            }
                        }
                    }

                    if (level2Index == 0)
                    {
                        break;
                    }
                }
            }

            if (level1Index == 0)
            {
                break;
            }
        }
    }

    function getTokensAmountForBid(uint128 _pricePerToken)
        external
        view
        returns (uint256 _amountOfTokens)
    {

        uint256 level1Index = getLevel1Index(_pricePerToken);
        uint256 level2Index = getLevel2Index(_pricePerToken);
        uint256 level3Index = getLevel3Index(_pricePerToken);
        
        LeafNode storage node = level3[level1Index][level2Index][level3Index];
        return node.amountOfTokens;
    }

    function getBidForTokenDepth(uint128 _amountOfTokens)
        external
        view
        returns (uint128 _pricePerToken)
    {

        for (uint256 level1Index = 9; level1Index < 10; level1Index -= 1)
        {
            uint256 level1Amount = level1[level1Index];
            if (level1Amount > 0 && level1Amount >= _amountOfTokens)
            {
                for (uint256 level2Index = 9; level2Index < 10; level2Index -= 1)
                {
                    uint256 level2Amount = level2[level1Index][level2Index];
                    if (level2Amount > 0 && level2Amount >= _amountOfTokens)
                    {
                        for (uint256 level3Index = 9; level3Index < 10; level3Index -= 1)
                        {
                            LeafNode storage node = level3[level1Index][level2Index][level3Index];
                            if (node.amountOfTokens > 0 && node.amountOfTokens >= _amountOfTokens)
                            {
                                _pricePerToken = uint128((level1Index * 100) + (level2Index * 10) + level3Index);
                                _amountOfTokens = 0;
                            }
                            else
                            {
                                _amountOfTokens = _amountOfTokens - uint128(node.amountOfTokens);
                            }

                            if (level3Index == 0 || _amountOfTokens == 0)
                            {
                                break;
                            }
                        }
                    }
                    else
                    {
                        _amountOfTokens = _amountOfTokens - uint128(level2Amount);
                    }

                    if (level2Index == 0 || _amountOfTokens == 0)
                    {
                        break;
                    }
                }
            }
            else
            {
                _amountOfTokens = _amountOfTokens - uint128(level1Amount);
            }

            if (level1Index == 0 || _amountOfTokens == 0)
            {
                break;
            }
        }
    }

    function claimAll()
        public
    {

        uint256 allocation = SafeMathTyped.mul256(allocations[msg.sender], allocatingAssetDecimalsScaling);
        allocations[msg.sender] = 0;
        bool wasTransfered = allocationAsset.transfer(msg.sender, allocation);
        require(wasTransfered, "ABQDAO/could-not-transfer-allocatoin");
    }

    function refund(uint256 _bidId, uint128 _pricePerToken)
        external
    {

        require(amountLeft == 0, "ABQDAO/auction-not-yet-completed");
        require(_pricePerToken < 1000, "ABQDAO/price-per-token-invalid");

        uint256 level1Index = getLevel1Index(_pricePerToken);
        uint256 level2Index = getLevel2Index(_pricePerToken);
        uint256 level3Index = getLevel3Index(_pricePerToken);
        
        LeafNode storage node = level3[level1Index][level2Index][level3Index];
        
        require(_bidId < node.bids.length, "ABQDAO/bidId-does-not-exist");

        Bid storage bid = node.bids[_bidId];
        require(bid.bidder == msg.sender, "ABQDAO/only-bidder-may-request-refund");

        if (bid.amountOfTokens > 0)
        {
            uint256 refundTotal = SafeMathTyped.mul256(SafeMathTyped.mul256(bid.pricePerToken, bid.amountOfTokens), bidAssetScaling);
            bid.amountOfTokens = 0;
            bool couldTransfer = bidAsset.transfer(msg.sender, refundTotal);
            require(couldTransfer, "ABQDAO/could-not-trasfer");
        }
    }

    event BidPlaced(address indexed bidder, uint128 pricePerToken, uint128 amountOfTokens, uint256 bidId, bool isIncrease);

    function placeBid(uint128 _pricePerToken, uint128 _amountOfTokens)
        external
        returns (uint256 _bidId)
    {

        require(amountLeft > 0, "ABQDAO/already-concluded-distribution");
        require(_amountOfTokens >= minTokensPerBid, "ABQDAO/too-few-tokens");
        require(_pricePerToken >= minAmount, "ABQDAO/bid-too-small");

        if (_pricePerToken > maxAmount)
        {
            (_bidId, ) = outrightBuy(uint128(0), _pricePerToken, _amountOfTokens);
            return _bidId;
        }

        uint256 totalToTransfer = SafeMathTyped.mul256(SafeMathTyped.mul256(_pricePerToken, _amountOfTokens), bidAssetScaling);
        bool couldClaimFunds = bidAsset.transferFrom(msg.sender, address(this), totalToTransfer);
        require(couldClaimFunds, "ABQDAO/could-not-claim-bid-funds");

        uint256 level1Index = getLevel1Index(_pricePerToken);
        uint256 level2Index = getLevel2Index(_pricePerToken);
        uint256 level3Index = getLevel3Index(_pricePerToken);

        level1[level1Index] = SafeMathTyped.add256(level1[level1Index], _amountOfTokens);
        level2[level1Index][level2Index] = SafeMathTyped.add256(level2[level1Index][level2Index], _amountOfTokens);
        LeafNode storage node = level3[level1Index][level2Index][level3Index];
        node.amountOfTokens = SafeMathTyped.add256(node.amountOfTokens, _amountOfTokens);

        _bidId = node.bids.length;
        node.bids.push(Bid(_pricePerToken, _amountOfTokens, msg.sender));
        emit BidPlaced(msg.sender, _pricePerToken, _amountOfTokens, _bidId, false);
    }

    function getLevel1Index(uint128 _pricePerToken)
        public
        pure
        returns (uint256 _index)
    {

        return _pricePerToken / 100;
    }

    function getLevel2Index(uint128 _pricePerToken)
        public
        pure
        returns (uint256 _index)
    {

        return (_pricePerToken % 100) / 10;
    }

    function getLevel3Index(uint128 _pricePerToken)
        public
        pure
        returns (uint256 _index)
    {

        return _pricePerToken % 10;
    }

    function getBid(uint256 _bidId, uint128 _pricePerToken)
        external
        view
        returns (address _bidder, uint128 _amountOfTokensOutstanding)
    {

        uint256 level1Index = getLevel1Index(_pricePerToken);
        uint256 level2Index = getLevel2Index(_pricePerToken);
        uint256 level3Index = getLevel3Index(_pricePerToken);
        
        LeafNode storage node = level3[level1Index][level2Index][level3Index];
        Bid storage bid = node.bids[_bidId];

        _bidder = bid.bidder;
        _amountOfTokensOutstanding = bid.amountOfTokens;
    }

    function increaseBid(uint256 _bidId, uint128 _oldPricePerToken, uint128 _newPricePerToken)
        external
        returns (uint256 _newBidId)
    {

        require(amountLeft > 0, "ABQDAO/already-concluded-distribution");
        require(_newPricePerToken > _oldPricePerToken, "ABQDAO/bid-too-small");
        require(_oldPricePerToken <= maxAmount, "ABQDAO/invalid-old-bid");
        require(_newPricePerToken <= maxAmount, "ABQDAO/new-bid-too-large");

        uint256 level1Index = getLevel1Index(_oldPricePerToken);
        uint256 level2Index = getLevel2Index(_oldPricePerToken);
        uint256 level3Index = getLevel3Index(_oldPricePerToken);

        LeafNode storage oldNode = level3[level1Index][level2Index][level3Index];

        require(_bidId < oldNode.bids.length, "ABQDAO/bidId-does-not-exist");

        Bid storage oldBid = oldNode.bids[_bidId];
        require(oldBid.bidder == msg.sender, "ABQDAO/not-the-bidder");
        require(oldBid.amountOfTokens > 0, "ABQDAO/bid-already-fully-processed");

        uint128 tokenAmount = oldBid.amountOfTokens;
        level1[level1Index] = SafeMathTyped.sub256(level1[level1Index], tokenAmount);
        level2[level1Index][level2Index] = SafeMathTyped.sub256(level2[level1Index][level2Index], tokenAmount);
        oldNode.amountOfTokens == SafeMathTyped.sub256(oldNode.amountOfTokens, tokenAmount);
        oldBid.amountOfTokens = 0;

        uint256 fundsToAddTotal = SafeMathTyped.mul256(SafeMathTyped.mul256(SafeMathTyped.sub256(_newPricePerToken, _oldPricePerToken), tokenAmount), bidAssetScaling);
        bool couldTransfer = bidAsset.transferFrom(msg.sender, address(this), fundsToAddTotal);
        require(couldTransfer, "ABQDAO/could-not-trasfer-funds");

        level1Index = getLevel1Index(_newPricePerToken);
        level2Index = getLevel2Index(_newPricePerToken);
        level3Index = getLevel3Index(_newPricePerToken);
        LeafNode storage node = level3[level1Index][level2Index][level3Index];

        level1[level1Index] = SafeMathTyped.add256(level1[level1Index], tokenAmount);
        level2[level1Index][level2Index] = SafeMathTyped.add256(level2[level1Index][level2Index], tokenAmount);
        node.amountOfTokens = SafeMathTyped.add256(node.amountOfTokens, tokenAmount);

        _newBidId = node.bids.length;
        node.bids.push(Bid(_newPricePerToken, tokenAmount, msg.sender));
        emit BidPlaced(msg.sender, _newPricePerToken, tokenAmount, _newBidId, true);
    }

    function outrightBuy(uint128 _oldPricePerToken, uint128 _pricePerToken, uint128 _amount)
        private
        returns (uint256 _bidId, uint128 _actualAmount)
    {

        if (_amount > amountLeft)
        {
            _amount = amountLeft;
        }

        uint256 bidFundsAdded = SafeMathTyped.mul256(SafeMathTyped.mul256(SafeMathTyped.sub256(_pricePerToken, _oldPricePerToken), _amount), bidAssetScaling);
        bool couldTransfer = bidAsset.transferFrom(msg.sender, address(this), bidFundsAdded);
        require(couldTransfer, "ABQDAO/could-not-pay-bid");
        uint256 bidFundsTotal = SafeMathTyped.mul256(SafeMathTyped.mul256(_pricePerToken, _amount), bidAssetScaling);
        couldTransfer = bidAsset.transfer(fundAddress, bidFundsTotal);
        require(couldTransfer, "ABQDAO/could-not-transfer-to-fund");

        emit BidPlaced(msg.sender, _pricePerToken, _amount, outrightBuyId, false);
        emit TokensAwarded(msg.sender, _amount);

        allocations[msg.sender] = allocations[msg.sender] + _amount;
        _bidId = outrightBuyId;
        _actualAmount = _amount;
        amountLeft = uint128(SafeMathTyped.sub256(amountLeft, _amount));
    }

    function distributeTimeslice(uint128 _maxNodesCount)
        external
    {

        require(_maxNodesCount > 0, "ABQDAO/max-nodes-count-may-not-be-zero");
        require(amountLeft > 0, "ABQDAO/auction-concluded");
        require(startDate <= block.timestamp, "ABQDAO/not-started-yet");

        if (tokensLeftForCurrentTimeslice == 0)
        {
            if (lastAllocatedTimeslice == 0)
            {
                lastAllocatedTimeslice = startDate;
                tokensLeftForCurrentTimeslice = firstTokenAmountToAllocate;
            }
            else
            {
                lastAllocatedTimeslice = SafeMathTyped.add256(lastAllocatedTimeslice, timeWindow);
                if (amountLeft > tokensPerTimeslice)
                {
                    tokensLeftForCurrentTimeslice = tokensPerTimeslice;
                }
                else
                {
                    tokensLeftForCurrentTimeslice = tokensPerTimeslice;
                }
            }
        }

        if (tokensLeftForCurrentTimeslice > amountLeft)
        {
            tokensLeftForCurrentTimeslice = amountLeft;
        }

        require(block.timestamp >= lastAllocatedTimeslice, "ABQDAO/cannot-distribute-timeslice-yet");
        require(tokensLeftForCurrentTimeslice > 0, "ABQDAO/no-tokens-to-distribute");

        uint256 amountDistributed = 0;
        uint256 priceTotal = 0;
        uint128 maxAmountToDistribute = tokensLeftForCurrentTimeslice;
        bool hasValue = false;
        for (uint128 level1Index = 9; level1Index < 10; level1Index -= 1)
        {
            uint256 level1Amount = level1[level1Index];
            if (level1Amount > 0)
            {
                hasValue = true;
                uint128 nodeAmountDistributed;
                uint256 priceAllocated;
                (_maxNodesCount, nodeAmountDistributed, priceAllocated) = distributeTimesliceForLevel1(level1Index, _maxNodesCount, maxAmountToDistribute);
                maxAmountToDistribute = uint128(SafeMathTyped.sub256(maxAmountToDistribute, nodeAmountDistributed));
                amountDistributed = amountDistributed + nodeAmountDistributed;
                priceTotal = SafeMathTyped.add256(priceTotal, priceAllocated);
            }

            if (level1Index == 0 || _maxNodesCount == 0 || maxAmountToDistribute == 0)
            {
                break;
            }
        }

        if (!hasValue)
        {

            amountLeft = uint128(SafeMathTyped.sub256(amountLeft, maxAmountToDistribute));
            amountUnallocated = amountUnallocated + maxAmountToDistribute;
            bool wasTransfered = allocationAsset.transfer(unallocatedAddress, SafeMathTyped.mul256(maxAmountToDistribute, allocatingAssetDecimalsScaling));
            require(wasTransfered, "ABQDAO/could-not-transfer-unallocated");
            tokensLeftForCurrentTimeslice = 0;
        }
        else
        {
            amountLeft = uint128(SafeMathTyped.sub256(amountLeft, amountDistributed));
            tokensLeftForCurrentTimeslice = maxAmountToDistribute;
            priceTotal = SafeMathTyped.mul256(priceTotal, bidAssetScaling);
            bool wasTransfered = bidAsset.transfer(fundAddress, priceTotal);
            require(wasTransfered, "ABQDAO/could-not-transfer-funds");
        }
    }

    function distributeTimesliceForLevel1(uint128 _level1Index, uint128 _nodesCount, uint128 _maxAmountToDistribute)
        private
        returns (uint128 _nodesCountLeft, uint128 _amountDistributed, uint256 _priceTotal)
    {

        _nodesCountLeft = _nodesCount;
        for (uint128 level2Index = 9; level2Index < 10; level2Index -= 1)
        {
            uint256 level2Amount = level2[_level1Index][level2Index];
            if (level2Amount > 0)
            {
                uint128 nodeAmountDistributed;
                uint256 priceAllocated;
                (_nodesCountLeft, nodeAmountDistributed, priceAllocated) = distributeTimesliceForLevel2(_level1Index, level2Index, _nodesCountLeft, _maxAmountToDistribute);
                _maxAmountToDistribute = uint128(SafeMathTyped.sub256(_maxAmountToDistribute, nodeAmountDistributed));
                _amountDistributed = _amountDistributed + nodeAmountDistributed;
                _priceTotal = SafeMathTyped.add256(_priceTotal, priceAllocated);
            }

            if (level2Index == 0 || _nodesCountLeft == 0 || _maxAmountToDistribute == 0)
            {
                break;
            }
        }

        level1[_level1Index] = SafeMathTyped.sub256(level1[_level1Index], _amountDistributed);
    }

    function distributeTimesliceForLevel2(uint128 _level1Index, uint128 _level2Index, uint128 _nodesCount, uint128 _maxAmountToDistribute)
        private
        returns (uint128 _nodesCountLeft, uint128 _amountDistributed, uint256 _priceTotal)
    {

        _nodesCountLeft = _nodesCount;
        for (uint128 level3Index = 9; level3Index < 10; level3Index -= 1)
        {
            LeafNode storage node = level3[_level1Index][_level2Index][level3Index];
            if (node.amountOfTokens > 0)
            {
                uint128 nodeAmountDistributed;
                uint256 priceAllocated;
                (_nodesCountLeft, nodeAmountDistributed, priceAllocated) = distributeTimesliceForLevel3(node, _nodesCountLeft, _maxAmountToDistribute);
                _maxAmountToDistribute = uint128(SafeMathTyped.sub256(_maxAmountToDistribute, nodeAmountDistributed));
                _amountDistributed = _amountDistributed + nodeAmountDistributed;
                _priceTotal = SafeMathTyped.add256(_priceTotal, priceAllocated);
            }

            if (level3Index == 0 || _nodesCountLeft == 0 || _maxAmountToDistribute == 0)
            {
                break;
            }
        }

        level2[_level1Index][_level2Index] = SafeMathTyped.sub256(level2[_level1Index][_level2Index], _amountDistributed);
    }

    function distributeTimesliceForLevel3(LeafNode storage _node, uint128 _nodesCount, uint128 _maxAmountToDistribute)
        private
        returns (uint128 _nodesCountLeft, uint128 _amountDistributed, uint256 _priceTotal)
    {

        _nodesCountLeft = _nodesCount;
        if (_node.amountOfTokens > 0)
        {
            uint256 currentIndex = _node.startIndex;
            while (_nodesCountLeft > 0 && currentIndex < _node.bids.length)
            {
                uint128 distributionLeft = uint128(SafeMathTyped.sub256(uint256(_maxAmountToDistribute), uint256(_amountDistributed)));
                Bid storage currentBid = _node.bids[currentIndex];
                if (currentBid.amountOfTokens == 0)
                {

                    currentIndex = SafeMathTyped.add256(currentIndex, 1);
                    _nodesCountLeft = _nodesCountLeft - 1;
                }
                else if (currentBid.amountOfTokens < distributionLeft)
                {

                    _amountDistributed = uint128(_amountDistributed + currentBid.amountOfTokens);
                    _priceTotal = SafeMathTyped.add256(_priceTotal, SafeMathTyped.mul256(currentBid.pricePerToken, currentBid.amountOfTokens));
                    allocateToBid(currentBid, currentBid.amountOfTokens);
                    
                    currentIndex = SafeMathTyped.add256(currentIndex, 1);
                    _nodesCountLeft = _nodesCountLeft - 1;
                }
                else if (currentBid.amountOfTokens == distributionLeft)
                {

                    _amountDistributed = uint128(_amountDistributed + currentBid.amountOfTokens);
                    _priceTotal = SafeMathTyped.add256(_priceTotal, SafeMathTyped.mul256(currentBid.pricePerToken, currentBid.amountOfTokens));
                    allocateToBid(currentBid, currentBid.amountOfTokens);

                    currentIndex = SafeMathTyped.add256(currentIndex, 1);
                    _nodesCountLeft = 0;
                }
                else if (currentBid.amountOfTokens > distributionLeft)
                {
                    _amountDistributed = uint128(SafeMathTyped.add256(_amountDistributed, distributionLeft));
                    _priceTotal = SafeMathTyped.add256(_priceTotal, SafeMathTyped.mul256(currentBid.pricePerToken, distributionLeft));
                    allocateToBid(currentBid, distributionLeft);

                    _nodesCountLeft = 0;
                }
            }
            _node.startIndex = currentIndex;
            _node.amountOfTokens = SafeMathTyped.sub256(_node.amountOfTokens, uint256(_amountDistributed));
        }
    }

    event TokensAwarded(address indexed bidder, uint128 amountOfTokens);
    function allocateToBid(Bid storage _bid, uint128 _amount)
        private
    {

        emit TokensAwarded(_bid.bidder, _amount);
        _bid.amountOfTokens = uint128(SafeMathTyped.sub256(_bid.amountOfTokens, _amount));
        allocations[_bid.bidder] = allocations[_bid.bidder] + _amount;
    }

    function totalTokensBiddedOn()
        public
        view
        returns (uint256 _total)
    {

        _total = level1[0];
        _total = SafeMathTyped.add256(_total, level1[1]);
        _total = SafeMathTyped.add256(_total, level1[2]);
        _total = SafeMathTyped.add256(_total, level1[3]);
        _total = SafeMathTyped.add256(_total, level1[4]);
        _total = SafeMathTyped.add256(_total, level1[5]);
        _total = SafeMathTyped.add256(_total, level1[6]);
        _total = SafeMathTyped.add256(_total, level1[7]);
        _total = SafeMathTyped.add256(_total, level1[8]);
        _total = SafeMathTyped.add256(_total, level1[9]);
    }
}