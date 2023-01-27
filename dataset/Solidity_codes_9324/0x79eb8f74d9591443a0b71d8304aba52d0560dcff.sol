



pragma solidity ^0.8.6;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}




pragma solidity ^0.8.6;

interface INestBatchPriceView {

    
    function triggeredPrice(uint channelId, uint pairIndex) external view returns (uint blockNumber, uint price);


    function triggeredPriceInfo(uint channelId, uint pairIndex) external view returns (
        uint blockNumber,
        uint price,
        uint avgPrice,
        uint sigmaSQ
    );


    function findPrice(
        uint channelId, 
        uint pairIndex,
        uint height
    ) external view returns (uint blockNumber, uint price);


    function lastPriceList(uint channelId, uint pairIndex, uint count) external view returns (uint[] memory);


    function lastPriceListAndTriggeredPriceInfo(uint channelId, uint pairIndex, uint count) external view 
    returns (
        uint[] memory prices,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );

}




pragma solidity ^0.8.6;

interface INestBatchPrice2 {


    function triggeredPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        address payback
    ) external payable returns (uint[] memory prices);


    function triggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        address payback
    ) external payable returns (uint[] memory prices);


    function findPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        uint height, 
        address payback
    ) external payable returns (uint[] memory prices);


    function lastPriceList(
        uint channelId, 
        uint[] calldata pairIndices, 
        uint count, 
        address payback
    ) external payable returns (uint[] memory prices);


    function lastPriceListAndTriggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        uint count, 
        address payback
    ) external payable returns (uint[] memory prices);

}




pragma solidity ^0.8.6;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.8.6;

interface INestBatchMining {

    
    event Open(uint channelId, address token0, uint unit, address reward);

    event Post(uint channelId, uint pairIndex, address miner, uint index, uint scale, uint price);

    
    struct Config {
        
        uint8 maxBiteNestedLevel;
        
        uint16 priceEffectSpan;

        uint16 pledgeNest;
    }

    struct PriceSheetView {
        
        uint32 index;

        address miner;

        uint32 height;

        uint32 remainNum;

        uint32 ethNumBal;

        uint32 tokenNumBal;

        uint24 nestNum1k;

        uint8 level;

        uint8 shares;

        uint152 price;
    }

    struct ChannelConfig {
        address token0;
        uint96 unit;

        address reward;
        uint96 rewardPerBlock;


        uint16 postFeeUnit;
        uint16 singleFee;
        uint16 reductionRate;

        address[] tokens;
    }

    struct PairView {
        address target;
        uint96 sheetCount;
    }

    struct PriceChannelView {
        
        uint channelId;

        address token0;
        uint96 unit;

        address reward;
        uint96 rewardPerBlock;

        uint128 vault;
        uint96 rewards;
        uint16 postFeeUnit;
        uint16 count;

        address governance;
        uint32 genesisBlock;
        uint16 singleFee;
        uint16 reductionRate;
        
        PairView[] pairs;
    }


    function setConfig(Config calldata config) external;


    function getConfig() external view returns (Config memory);

    
    function open(ChannelConfig calldata config) external;


    function increase(uint channelId, uint128 vault) external payable;


    function decrease(uint channelId, uint128 vault) external;


    function getChannelInfo(uint channelId) external view returns (PriceChannelView memory);


    function post(uint channelId, uint scale, uint[] calldata equivalents) external payable;


    function take(uint channelId, uint pairIndex, uint index, uint takeNum, uint newEquivalent) external payable;


    function list(
        uint channelId, 
        uint pairIndex, 
        uint offset, 
        uint count, 
        uint order
    ) external view returns (PriceSheetView[] memory);


    function close(uint channelId, uint[][] calldata indices) external;


    function balanceOf(address tokenAddress, address addr) external view returns (uint);


    function withdraw(address tokenAddress, uint value) external;


    function estimate(uint channelId) external view returns (uint);


    function getMinedBlocks(
        uint channelId,
        uint index
    ) external view returns (uint minedBlocks, uint totalShares);


    function totalETHRewards(uint channelId) external view returns (uint);


    function pay(uint channelId, address to, uint value) external;


    function donate(uint channelId, uint value) external;

}




pragma solidity ^0.8.6;

interface INestLedger {


    event ApplicationChanged(address addr, uint flag);
    
    function setApplication(address addr, uint flag) external;


    function checkApplication(address addr) external view returns (uint);


    function addETHReward(uint channelId) external payable;


    function totalETHRewards(uint channelId) external view returns (uint);


    function pay(uint channelId, address tokenAddress, address to, uint value) external;

}




pragma solidity ^0.8.6;

interface INToken {

        
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function increaseTotal(uint256 value) external;


    function checkBlockInfo() external view returns(uint256 createBlock, uint256 recentlyUsedBlock);


    function checkBidder() external view returns(address);

    
    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256); 


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);

}




pragma solidity ^0.8.6;

interface INestMapping {


    function setBuiltinAddress(
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    ) external;


    function getBuiltinAddress() external view returns (
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    );


    function getNestTokenAddress() external view returns (address);


    function getNestNodeAddress() external view returns (address);


    function getNestLedgerAddress() external view returns (address);


    function getNestMiningAddress() external view returns (address);


    function getNTokenMiningAddress() external view returns (address);


    function getNestPriceFacadeAddress() external view returns (address);


    function getNestVoteAddress() external view returns (address);


    function getNestQueryAddress() external view returns (address);


    function getNnIncomeAddress() external view returns (address);


    function getNTokenControllerAddress() external view returns (address);


    function registerAddress(string memory key, address addr) external;


    function checkAddress(string memory key) external view returns (address);

}




pragma solidity ^0.8.6;
interface INestGovernance is INestMapping {


    function setGovernance(address addr, uint flag) external;


    function getGovernance(address addr) external view returns (uint);


    function checkGovernance(address addr, uint flag) external view returns (bool);

}




pragma solidity ^0.8.6;
contract NestBase {


    address constant NEST_TOKEN_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;
    

    function initialize(address nestGovernanceAddress) public virtual {

        require(_governance == address(0), "NEST:!initialize");
        _governance = nestGovernanceAddress;
    }

    address public _governance;

    function update(address nestGovernanceAddress) public virtual {


        address governance = _governance;
        require(governance == msg.sender || INestGovernance(governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _governance = nestGovernanceAddress;
    }




    modifier onlyGovernance() {

        require(INestGovernance(_governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _;
    }

    modifier noContract() {

        require(msg.sender == tx.origin, "NEST:!contract");
        _;
    }
}




pragma solidity ^0.8.6;
contract NestBatchMining is NestBase, INestBatchMining {


    function initialize(address nestGovernanceAddress) public override {

        super.initialize(nestGovernanceAddress);
        _accounts.push();
    }

    struct PriceSheet {
        
        uint32 miner;

        uint32 height;

        uint32 remainNum;

        uint32 ethNumBal;

        uint32 tokenNumBal;

        uint24 nestNum1k;

        uint8 level;

        uint8 shares;

        uint56 priceFloat;
    }

    struct PriceInfo {

        uint32 index;

        uint32 height;

        uint32 remainNum;

        uint56 priceFloat;

        uint56 avgFloat;

        uint48 sigmaSQ;
    }

    struct PricePair {
        address target;
        PriceInfo price;
        PriceSheet[] sheets;    
    }

    struct PriceChannel {

        address token0;
        uint96 unit;

        address reward;        
        uint96 rewardPerBlock;

        uint128 vault;        
        uint96 rewards;
        uint16 postFeeUnit;
        uint16 count;

        address governance;
        uint32 genesisBlock;
        uint16 singleFee;
        uint16 reductionRate;
        
        PricePair[0xFFFF] pairs;
    }

    struct UINT {
        uint value;
    }

    struct Account {
        
        address addr;

        mapping(address=>UINT) balances;
    }

    Config _config;

    Account[] _accounts;

    mapping(address=>uint) _accountMapping;


    PriceChannel[] _channels;

    uint constant DIMI_ETHER = 0.0001 ether;

    uint constant ETHEREUM_BLOCK_TIMESPAN = 14;

    uint constant NEST_REDUCTION_SPAN = 2400000;
    uint constant NEST_REDUCTION_LIMIT = 24000000; //NEST_REDUCTION_SPAN * 10;
    uint constant NEST_REDUCTION_STEPS = 0x280035004300530068008300A300CC010001400190;


    function setConfig(Config calldata config) external override onlyGovernance {

        _config = config;
    }

    function getConfig() external view override returns (Config memory) {

        return _config;
    }

    function open(ChannelConfig calldata config) external override {


        address token0 = config.token0;
        address reward = config.reward;

        emit Open(_channels.length, token0, config.unit, reward);
        
        PriceChannel storage channel = _channels.push();

        channel.token0 = token0;
        channel.unit = config.unit;

        channel.reward = reward;
        channel.rewardPerBlock = config.rewardPerBlock;

        channel.vault = uint128(0);
        channel.rewards = uint96(0);
        channel.postFeeUnit = config.postFeeUnit;
        channel.count = uint16(config.tokens.length);
        
        channel.governance = msg.sender;
        channel.genesisBlock = uint32(block.number);
        channel.singleFee = config.singleFee;
        channel.reductionRate = config.reductionRate;

        for (uint i = 0; i < config.tokens.length; ++i) {
            require(token0 != config.tokens[i], "NOM:token can't equal token0");
            for (uint j = 0; j < i; ++j) {
                require(config.tokens[i] != config.tokens[j], "NOM:token reiterated");
            }
            channel.pairs[i].target = config.tokens[i];
        }
    }

    function addPair(uint channelId, address target) external {

        PriceChannel storage channel = _channels[channelId];
        require(channel.governance == msg.sender, "NOM:not governance");
        require(channel.token0 != target, "NOM:token can't equal token0");
        uint count = uint(channel.count);
        for (uint j = 0; j < count; ++j) {
            require(channel.pairs[j].target != target, "NOM:token reiterated");
        }
        channel.pairs[count].target = target;
        ++channel.count;
    }

    function increase(uint channelId, uint128 vault) external payable override {

        PriceChannel storage channel = _channels[channelId];
        address reward = channel.reward;
        if (reward == address(0)) {
            require(msg.value == uint(vault), "NOM:vault error");
        } else {
            TransferHelper.safeTransferFrom(reward, msg.sender, address(this), uint(vault));
        }
        channel.vault += vault;
    }

    function decrease(uint channelId, uint128 vault) external override {

        PriceChannel storage channel = _channels[channelId];
        require(channel.governance == msg.sender, "NOM:not governance");
        address reward = channel.reward;
        channel.vault -= vault;
        if (reward == address(0)) {
            payable(msg.sender).transfer(uint(vault));
        } else {
            TransferHelper.safeTransfer(reward, msg.sender, uint(vault));
        }
    }

    function changeGovernance(uint channelId, address newGovernance) external {

        PriceChannel storage channel = _channels[channelId];
        require(channel.governance == msg.sender, "NOM:not governance");
        channel.governance = newGovernance;
    }

    function getChannelInfo(uint channelId) external view override returns (PriceChannelView memory) {

        PriceChannel storage channel = _channels[channelId];

        uint count = uint(channel.count);
        PairView[] memory pairs = new PairView[](count);
        for (uint i = 0; i < count; ++i) {
            PricePair storage pair = channel.pairs[i];
            pairs[i] = PairView(pair.target, uint96(pair.sheets.length));
        }

        return PriceChannelView (
            channelId,

            channel.token0,
            channel.unit,

            channel.reward,
            channel.rewardPerBlock,

            channel.vault,
            channel.rewards,
            channel.postFeeUnit,
            channel.count,

            channel.governance,
            channel.genesisBlock,
            channel.singleFee,
            channel.reductionRate,

            pairs
        );
    }


    function post(uint channelId, uint scale, uint[] calldata equivalents) external payable override {


        Config memory config = _config;

        require(scale == 1, "NOM:!scale");

        PriceChannel storage channel = _channels[channelId];

        uint accountIndex = _addressIndex(msg.sender);
        mapping(address=>UINT) storage balances = _accounts[accountIndex].balances;

        uint cn = uint(channel.count);
        uint fee = msg.value;

        fee = _freeze(balances, NEST_TOKEN_ADDRESS, cn * uint(config.pledgeNest) * 1000 ether, fee);
    
        fee = _freeze(balances, channel.token0, cn * uint(channel.unit) * scale, fee);

        while (cn > 0) {
            PricePair storage pair = channel.pairs[--cn];
            uint equivalent = equivalents[cn];
            require(equivalent > 0, "NOM:!equivalent");
            fee = _freeze(balances, pair.target, scale * equivalent, fee);

            _stat(config, pair);
            
            emit Post(channelId, cn, msg.sender, pair.sheets.length, scale, equivalent);
            _create(pair.sheets, accountIndex, uint32(scale), uint(config.pledgeNest), cn == 0 ? 1 : 0, equivalent);
        }

        uint postFeeUnit = uint(channel.postFeeUnit);
        if (postFeeUnit > 0) {
            require(fee >= postFeeUnit * DIMI_ETHER + tx.gasprice * 400000, "NM:!fee");
        }
        if (fee > 0) {
            channel.rewards += _toUInt96(fee);
        }
    }

    function take(
        uint channelId, 
        uint pairIndex, 
        uint index, 
        uint takeNum, 
        uint newEquivalent
    ) external payable override {


        Config memory config = _config;

        require(takeNum > 0, "NM:!takeNum");
        require(newEquivalent > 0, "NM:!price");

        PriceChannel storage channel = _channels[channelId];
        PricePair storage pair = channel.pairs[pairIndex < 0x10000 ? pairIndex : pairIndex - 0x10000];
        PriceSheet memory sheet = pair.sheets[index];

        require(uint(sheet.height) + uint(config.priceEffectSpan) >= block.number, "NM:!state");
        sheet.remainNum = uint32(uint(sheet.remainNum) - takeNum);

        uint accountIndex = _addressIndex(msg.sender);
        uint needNest1k = (takeNum << 2) * uint(sheet.nestNum1k) / (uint(sheet.ethNumBal) + uint(sheet.tokenNumBal));

        uint needEthNum = takeNum;
        uint level = uint(sheet.level);
        if (level < 255) {
            if (level < uint(config.maxBiteNestedLevel)) {
                needEthNum <<= 1;
            }
            ++level;
        }

        {
            mapping(address=>UINT) storage balances = _accounts[accountIndex].balances;
            uint fee = msg.value;

            if (pairIndex < 0x10000) {
                sheet.ethNumBal = uint32(uint(sheet.ethNumBal) - takeNum);
                sheet.tokenNumBal = uint32(uint(sheet.tokenNumBal) + takeNum);
                pair.sheets[index] = sheet;

                fee = _freeze(balances, channel.token0, (needEthNum - takeNum) * uint(channel.unit), fee);
                fee = _freeze(
                    balances, 
                    pair.target, 
                    needEthNum * newEquivalent + _decodeFloat(sheet.priceFloat) * takeNum, 
                    fee
                );
            } 
            else {
                pairIndex -= 0x10000;
                sheet.ethNumBal = uint32(uint(sheet.ethNumBal) + takeNum);
                sheet.tokenNumBal = uint32(uint(sheet.tokenNumBal) - takeNum);
                pair.sheets[index] = sheet;

                fee = _freeze(balances, channel.token0, (needEthNum + takeNum) * uint(channel.unit), fee);
                uint backTokenValue = _decodeFloat(sheet.priceFloat) * takeNum;
                if (needEthNum * newEquivalent > backTokenValue) {
                    fee = _freeze(balances, pair.target, needEthNum * newEquivalent - backTokenValue, fee);
                } else {
                    _unfreeze(balances, pair.target, backTokenValue - needEthNum * newEquivalent, msg.sender);
                }
            }
                
            fee = _freeze(balances, NEST_TOKEN_ADDRESS, needNest1k * 1000 ether, fee);

            require(fee == 0, "NOM:!fee");
        }
            
        _stat(config, pair);

        emit Post(channelId, pairIndex, msg.sender, pair.sheets.length, needEthNum, newEquivalent);
        _create(pair.sheets, accountIndex, uint32(needEthNum), needNest1k, level << 8, newEquivalent);
    }

    function list(
        uint channelId,
        uint pairIndex,
        uint offset,
        uint count,
        uint order
    ) external view override noContract returns (PriceSheetView[] memory) {


        PriceSheet[] storage sheets = _channels[channelId].pairs[pairIndex].sheets;
        PriceSheetView[] memory result = new PriceSheetView[](count);
        uint length = sheets.length;
        uint i = 0;

        if (order == 0) {

            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                --index;
                result[i++] = _toPriceSheetView(sheets[index], index);
            }
        } 
        else {

            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                result[i++] = _toPriceSheetView(sheets[index], index);
                ++index;
            }
        }
        return result;
    }

    function close(uint channelId, uint[][] calldata indices) external override {

        
        Config memory config = _config;
        PriceChannel storage channel = _channels[channelId];
        
        uint accountIndex = 0;
        uint reward = 0;
        uint nestNum1k = 0;
        uint ethNum = 0;

        mapping(address=>UINT) storage balances = _accounts[0/*accountIndex*/].balances;
        uint[3] memory vars = [
            uint(channel.rewardPerBlock), 
            uint(channel.genesisBlock), 
            uint(channel.reductionRate)
        ];

        for (uint j = indices.length; j > 0;) {
            PricePair storage pair = channel.pairs[--j];


            uint tokenValue = 0;

            for (uint i = indices[j].length; i > 0;) {

                uint index = indices[j][--i];
                PriceSheet memory sheet = pair.sheets[index];
                
                if (accountIndex == 0) {
                    accountIndex = uint(sheet.miner);
                    balances = _accounts[accountIndex].balances;
                } else {
                    require(accountIndex == uint(sheet.miner), "NM:!miner");
                }

                if (accountIndex > 0 && (uint(sheet.height) + uint(config.priceEffectSpan) < block.number)) {

                    if (j == 0) {
                        uint shares = uint(sheet.shares);
                        if (shares > 0) {

                            (uint mined, uint totalShares) = _calcMinedBlocks(pair.sheets, index, sheet);
                            
                            reward += (
                                mined
                                * shares
                                * _reduction(uint(sheet.height) - vars[1], vars[2])
                                * vars[0]
                                / totalShares / 400
                            );
                        }
                    }

                    nestNum1k += uint(sheet.nestNum1k);
                    ethNum += uint(sheet.ethNumBal);
                    tokenValue += _decodeFloat(sheet.priceFloat) * uint(sheet.tokenNumBal);

                    sheet.miner = uint32(0);
                    sheet.ethNumBal = uint32(0);
                    sheet.tokenNumBal = uint32(0);
                    pair.sheets[index] = sheet;
                }

            }

            _stat(config, pair);

            _unfreeze(balances, pair.target, tokenValue, accountIndex);
        }

        _unfreeze(balances, channel.token0, ethNum * uint(channel.unit), accountIndex);
        
        _unfreeze(balances, NEST_TOKEN_ADDRESS, nestNum1k * 1000 ether, accountIndex);

        uint vault = uint(channel.vault);
        if (reward > vault) {
            reward = vault;
        }
        channel.vault = uint96(vault - reward);
        
        _unfreeze(balances, channel.reward, reward, accountIndex);
    }

    function balanceOf(address tokenAddress, address addr) external view override returns (uint) {

        return _accounts[_accountMapping[addr]].balances[tokenAddress].value;
    }

    function withdraw(address tokenAddress, uint value) external override {


        UINT storage balance = _accounts[_accountMapping[msg.sender]].balances[tokenAddress];
        balance.value -= value;

        TransferHelper.safeTransfer(tokenAddress, msg.sender, value);
    }

    function estimate(uint channelId) external view override returns (uint) {


        PriceChannel storage channel = _channels[channelId];
        PriceSheet[] storage sheets = channel.pairs[0].sheets;
        uint index = sheets.length;
        uint blocks = 10;
        while (index > 0) {

            PriceSheet memory sheet = sheets[--index];
            if (uint(sheet.shares) > 0) {
                blocks = block.number - uint(sheet.height);
                break;
            }
        }

        return 
            blocks
            * uint(channel.rewardPerBlock) 
            * _reduction(block.number - uint(channel.genesisBlock), uint(channel.reductionRate))
            / 400;
    }

    function getMinedBlocks(
        uint channelId,
        uint index
    ) external view override returns (uint minedBlocks, uint totalShares) {


        PriceSheet[] storage sheets = _channels[channelId].pairs[0].sheets;
        PriceSheet memory sheet = sheets[index];

        if (uint(sheet.shares) == 0) {
            return (0, 0);
        }

        return _calcMinedBlocks(sheets, index, sheet);
    }

    function totalETHRewards(uint channelId) external view override returns (uint) {

        return uint(_channels[channelId].rewards);
    }

    function pay(uint channelId, address to, uint value) external override {


        PriceChannel storage channel = _channels[channelId];
        require(channel.governance == msg.sender, "NOM:!governance");
        channel.rewards -= _toUInt96(value);
        payable(to).transfer(value);
    }

    function donate(uint channelId, uint value) external override {


        PriceChannel storage channel = _channels[channelId];
        require(channel.governance == msg.sender, "NOM:!governance");
        channel.rewards -= _toUInt96(value);
        INestLedger(INestMapping(_governance).getNestLedgerAddress()).addETHReward { value: value } (channelId);
    }

    function indexAddress(uint index) public view returns (address) {

        return _accounts[index].addr;
    }

    function getAccountIndex(address addr) external view returns (uint) {

        return _accountMapping[addr];
    }

    function getAccountCount() external view returns (uint) {

        return _accounts.length;
    }

    function _toPriceSheetView(PriceSheet memory sheet, uint index) private view returns (PriceSheetView memory) {


        return PriceSheetView(
            uint32(index),
            indexAddress(sheet.miner),
            sheet.height,
            sheet.remainNum,
            sheet.ethNumBal,
            sheet.tokenNumBal,
            sheet.nestNum1k,
            sheet.level,
            sheet.shares,
            uint152(_decodeFloat(sheet.priceFloat))
        );
    }

    function _create(
        PriceSheet[] storage sheets,
        uint accountIndex,
        uint32 ethNum,
        uint nestNum1k,
        uint level_shares,
        uint equivalent
    ) private {


        sheets.push(PriceSheet(
            uint32(accountIndex),                       // uint32 miner;
            uint32(block.number),                       // uint32 height;
            ethNum,                                     // uint32 remainNum;
            ethNum,                                     // uint32 ethNumBal;
            ethNum,                                     // uint32 tokenNumBal;
            uint24(nestNum1k),                          // uint32 nestNum1k;
            uint8(level_shares >> 8),                   // uint8 level;
            uint8(level_shares & 0xFF),
            _encodeFloat(equivalent)
        ));
    }

    function _stat(Config memory config, PricePair storage pair) private {

        
        PriceSheet[] storage sheets = pair.sheets;
        PriceInfo memory p0 = pair.price;

        uint length = sheets.length;
        uint index = uint(p0.index);
        uint prev = uint(p0.height);
        uint totalEthNum = 0; 
        uint totalTokenValue = 0; 
        uint height = 0;

        PriceSheet memory sheet;
        for (; ; ++index) {


            bool flag = index >= length
                || (height = uint((sheet = sheets[index]).height)) + uint(config.priceEffectSpan) >= block.number;

            if (flag || prev != height) {

                if (totalEthNum > 0) {

                    uint tmp = _decodeFloat(p0.priceFloat);
                    uint price = totalTokenValue / totalEthNum;
                    p0.remainNum = uint32(totalEthNum);
                    p0.priceFloat = _encodeFloat(price);
                    totalEthNum = 0;
                    totalTokenValue = 0;

                    if (tmp > 0) {
                        p0.avgFloat = _encodeFloat((_decodeFloat(p0.avgFloat) * 9 + price) / 10);

                        tmp = (price << 48) / tmp;
                        if (tmp > 0x1000000000000) {
                            tmp = tmp - 0x1000000000000;
                        } else {
                            tmp = 0x1000000000000 - tmp;
                        }

                        tmp = (
                            uint(p0.sigmaSQ) * 9 + 
                            ((tmp * tmp / ETHEREUM_BLOCK_TIMESPAN / (prev - uint(p0.height))) >> 48)
                        ) / 10;

                        if (tmp > 0xFFFFFFFFFFFF) {
                            tmp = 0xFFFFFFFFFFFF;
                        }
                        p0.sigmaSQ = uint48(tmp);
                    }
                    else {
                        p0.avgFloat = p0.priceFloat;

                        p0.sigmaSQ = uint48(0);
                    }

                    p0.height = uint32(prev);
                }

                prev = height;
            }

            if (flag) {
                break;
            }

            totalEthNum += uint(sheet.remainNum);
            totalTokenValue += _decodeFloat(sheet.priceFloat) * uint(sheet.remainNum);
        }

        if (index > uint(p0.index)) {
            p0.index = uint32(index);
            pair.price = p0;
        }
    }

    function _calcMinedBlocks(
        PriceSheet[] storage sheets,
        uint index,
        PriceSheet memory sheet
    ) private view returns (uint minedBlocks, uint totalShares) {


        uint length = sheets.length;
        uint height = uint(sheet.height);
        totalShares = uint(sheet.shares);

        for (uint i = index; ++i < length && uint(sheets[i].height) == height;) {
            
            totalShares += uint(sheets[i].shares);
        }

        uint prev = height;
        while (index > 0 && uint(prev = sheets[--index].height) == height) {

            totalShares += uint(sheets[index].shares);
        }

        if (index > 0 || height > prev) {
            minedBlocks = height - prev;
        } else {
            minedBlocks = 10;
        }
    }

    function _freeze(
        mapping(address=>UINT) storage balances, 
        address tokenAddress, 
        uint tokenValue,
        uint value
    ) private returns (uint) {

        if (tokenAddress == address(0)) {
            return value - tokenValue;
        } else {
            UINT storage balance = balances[tokenAddress];
            uint balanceValue = balance.value;
            if (balanceValue < tokenValue) {
                balance.value = 0;
                TransferHelper.safeTransferFrom(tokenAddress, msg.sender, address(this), tokenValue - balanceValue);
            } else {
                balance.value = balanceValue - tokenValue;
            }
            return value;
        }
    }

    function _unfreeze(
        mapping(address=>UINT) storage balances, 
        address tokenAddress, 
        uint tokenValue,
        uint accountIndex
    ) private {

        if (tokenValue > 0) {
            if (tokenAddress == address(0)) {
                payable(indexAddress(accountIndex)).transfer(tokenValue);
            } else {
                balances[tokenAddress].value += tokenValue;
            }
        }
    }

    function _unfreeze(
        mapping(address=>UINT) storage balances, 
        address tokenAddress, 
        uint tokenValue,
        address owner
    ) private {

        if (tokenValue > 0) {
            if (tokenAddress == address(0)) {
                payable(owner).transfer(tokenValue);
            } else {
                balances[tokenAddress].value += tokenValue;
            }
        }
    }

    function _addressIndex(address addr) private returns (uint) {


        uint index = _accountMapping[addr];
        if (index == 0) {
            require((_accountMapping[addr] = index = _accounts.length) < 0x100000000, "NM:!accounts");
            _accounts.push().addr = addr;
        }

        return index;
    }



    function _reduction(uint delta, uint reductionRate) private pure returns (uint) {

        if (delta < NEST_REDUCTION_LIMIT) {
            uint n = delta / NEST_REDUCTION_SPAN;
            return 400 * reductionRate ** n / 10000 ** n;
        }
        return 400 * reductionRate ** 10 / 10000 ** 10;
    }


    function _encodeFloat(uint value) private pure returns (uint56) {


        uint exponent = 0; 
        while (value > 0x3FFFFFFFFFFFF) {
            value >>= 4;
            ++exponent;
        }
        return uint56((value << 6) | exponent);
    }

    function _decodeFloat(uint56 floatValue) private pure returns (uint) {

        return (uint(floatValue) >> 6) << ((uint(floatValue) & 0x3F) << 2);
    }

    function _toUInt96(uint value) internal pure returns (uint96) {

        require(value < 1000000000000000000000000);
        return uint96(value);
    }

    
    function _triggeredPrice(PricePair storage pair) internal view returns (uint blockNumber, uint price) {


        PriceInfo memory priceInfo = pair.price;

        if (uint(priceInfo.remainNum) > 0) {
            return (uint(priceInfo.height) + uint(_config.priceEffectSpan), _decodeFloat(priceInfo.priceFloat));
        }
        
        return (0, 0);
    }

    function _triggeredPriceInfo(PricePair storage pair) internal view returns (
        uint blockNumber,
        uint price,
        uint avgPrice,
        uint sigmaSQ
    ) {


        PriceInfo memory priceInfo = pair.price;

        if (uint(priceInfo.remainNum) > 0) {
            return (
                uint(priceInfo.height) + uint(_config.priceEffectSpan),
                _decodeFloat(priceInfo.priceFloat),
                _decodeFloat(priceInfo.avgFloat),
                (uint(priceInfo.sigmaSQ) * 1 ether) >> 48
            );
        }

        return (0, 0, 0, 0);
    }

    function _findPrice(
        PricePair storage pair,
        uint height
    ) internal view returns (uint blockNumber, uint price) {


        PriceSheet[] storage sheets = pair.sheets;
        uint priceEffectSpan = uint(_config.priceEffectSpan);

        uint length = sheets.length;
        uint index = 0;
        uint sheetHeight;
        height -= priceEffectSpan;
        {
            uint right = length - 1;
            uint left = 0;
            while (left < right) {

                index = (left + right) >> 1;
                sheetHeight = uint(sheets[index].height);
                if (height > sheetHeight) {
                    left = ++index;
                } else if (height < sheetHeight) {
                    right = --index;
                } else {
                    break;
                }
            }
        }

        uint totalEthNum = 0;
        uint totalTokenValue = 0;
        uint h = 0;
        uint remainNum;
        PriceSheet memory sheet;

        for (uint i = index; i < length;) {

            sheet = sheets[i++];
            sheetHeight = uint(sheet.height);
            if (height < sheetHeight) {
                break;
            }
            remainNum = uint(sheet.remainNum);
            if (remainNum > 0) {
                if (h == 0) {
                    h = sheetHeight;
                } else if (h != sheetHeight) {
                    break;
                }
                totalEthNum += remainNum;
                totalTokenValue += _decodeFloat(sheet.priceFloat) * remainNum;
            }
        }

        while (index > 0) {

            sheet = sheets[--index];
            remainNum = uint(sheet.remainNum);
            if (remainNum > 0) {
                sheetHeight = uint(sheet.height);
                if (h == 0) {
                    h = sheetHeight;
                } else if (h != sheetHeight) {
                    break;
                }
                totalEthNum += remainNum;
                totalTokenValue += _decodeFloat(sheet.priceFloat) * remainNum;
            }
        }

        if (totalEthNum > 0) {
            return (h + priceEffectSpan, totalTokenValue / totalEthNum);
        }
        return (0, 0);
    }

    function _lastPriceList(PricePair storage pair, uint count) internal view returns (uint[] memory) {


        PriceSheet[] storage sheets = pair.sheets;
        PriceSheet memory sheet;
        uint[] memory array = new uint[](count <<= 1);

        uint priceEffectSpan = uint(_config.priceEffectSpan);
        uint index = sheets.length;
        uint totalEthNum = 0;
        uint totalTokenValue = 0;
        uint height = 0;

        for (uint i = 0; i < count;) {

            bool flag = index == 0;
            if (flag || height != uint((sheet = sheets[--index]).height)) {
                if (totalEthNum > 0 && height + priceEffectSpan < block.number) {
                    array[i++] = height + priceEffectSpan;
                    array[i++] = totalTokenValue / totalEthNum;
                }
                if (flag) {
                    break;
                }
                totalEthNum = 0;
                totalTokenValue = 0;
                height = uint(sheet.height);
            }

            uint remainNum = uint(sheet.remainNum);
            totalEthNum += remainNum;
            totalTokenValue += _decodeFloat(sheet.priceFloat) * remainNum;
        }

        return array;
    }
}




pragma solidity ^0.8.6;
contract NestBatchPlatform2 is NestBatchMining, INestBatchPriceView, INestBatchPrice2 {



    function triggeredPrice(uint channelId, uint pairIndex) external view override noContract returns (uint blockNumber, uint price) {

        return _triggeredPrice(_channels[channelId].pairs[pairIndex]);
    }

    function triggeredPriceInfo(uint channelId, uint pairIndex) external view override noContract returns (
        uint blockNumber,
        uint price,
        uint avgPrice,
        uint sigmaSQ
    ) {

        return _triggeredPriceInfo(_channels[channelId].pairs[pairIndex]);
    }

    function findPrice(
        uint channelId,
        uint pairIndex,
        uint height
    ) external view override noContract returns (uint blockNumber, uint price) {

        return _findPrice(_channels[channelId].pairs[pairIndex], height);
    }


    function lastPriceList(uint channelId, uint pairIndex, uint count) external view override noContract returns (uint[] memory) {

        return _lastPriceList(_channels[channelId].pairs[pairIndex], count);
    } 

    function lastPriceListAndTriggeredPriceInfo(uint channelId, uint pairIndex, uint count) external view override noContract
    returns (
        uint[] memory prices,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    ) {

        PricePair storage pair = _channels[channelId].pairs[pairIndex];
        prices = _lastPriceList(pair, count);
        (
            triggeredPriceBlockNumber, 
            triggeredPriceValue, 
            triggeredAvgPrice, 
            triggeredSigmaSQ
        ) = _triggeredPriceInfo(pair);
    }


    function triggeredPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        address payback
    ) external payable override returns (uint[] memory prices) {

        PricePair[0xFFFF] storage pairs = _pay(channelId, payback).pairs;

        uint n = pairIndices.length << 1;
        prices = new uint[](n);
        while (n > 0) {
            n -= 2;
            (prices[n], prices[n + 1]) = _triggeredPrice(pairs[pairIndices[n >> 1]]);
        }
    }

    function triggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        address payback
    ) external payable override returns (uint[] memory prices) {

        PricePair[0xFFFF] storage pairs = _pay(channelId, payback).pairs;

        uint n = pairIndices.length << 2;
        prices = new uint[](n);
        while (n > 0) {
            n -= 4;
            (prices[n], prices[n + 1], prices[n + 2], prices[n + 3]) = _triggeredPriceInfo(pairs[pairIndices[n >> 2]]);
        }
    }

    function findPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        uint height, 
        address payback
    ) external payable override returns (uint[] memory prices) {

        PricePair[0xFFFF] storage pairs = _pay(channelId, payback).pairs;

        uint n = pairIndices.length << 1;
        prices = new uint[](n);
        while (n > 0) {
            n -= 2;
            (prices[n], prices[n + 1]) = _findPrice(pairs[pairIndices[n >> 1]], height);
        }
    }



    function lastPriceList(
        uint channelId, 
        uint[] calldata pairIndices, 
        uint count, 
        address payback
    ) external payable override returns (uint[] memory prices) {

        PricePair[0xFFFF] storage pairs = _pay(channelId, payback).pairs;

        uint row = count << 1;
        uint n = pairIndices.length * row;
        prices = new uint[](n);
        while (n > 0) {
            n -= row;
            uint[] memory pi = _lastPriceList(pairs[pairIndices[n / row]], count);
            for (uint i = 0; i < row; ++i) {
                prices[n + i] = pi[i];
            }
        }
    }

    function lastPriceListAndTriggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        uint count, 
        address payback
    ) external payable override returns (uint[] memory prices) {

        PricePair[0xFFFF] storage pairs = _pay(channelId, payback).pairs;

        uint row = (count << 1) + 4;
        uint n = pairIndices.length * row;
        prices = new uint[](n);
        while (n > 0) {
            n -= row;

            PricePair storage pair = pairs[pairIndices[n / row]];
            uint[] memory pi = _lastPriceList(pair, count);
            for (uint i = 0; i + 4 < row; ++i) {
                prices[n + i] = pi[i];
            }
            uint j = n + row - 4;
            (
                prices[j],
                prices[j + 1],
                prices[j + 2],
                prices[j + 3]
            ) = _triggeredPriceInfo(pair);
        }
    }

    function _pay(uint channelId, address payback) private returns (PriceChannel storage channel) {


        channel = _channels[channelId];
        uint fee = uint(channel.singleFee) * DIMI_ETHER;
        if (msg.value > fee) {
            payable(payback).transfer(msg.value - fee);
        } else {
            require(msg.value == fee, "NOP:!fee");
        }

        channel.rewards += _toUInt96(fee);
    }
}