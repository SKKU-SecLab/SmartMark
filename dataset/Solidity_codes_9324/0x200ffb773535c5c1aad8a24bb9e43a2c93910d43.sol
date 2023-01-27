


pragma solidity ^0.8.6;

interface INestPriceFacade {

    
    struct Config {

        uint16 singleFee;

        uint16 doubleFee;

        uint8 normalFlag;
    }

    function setConfig(Config calldata config) external;


    function getConfig() external view returns (Config memory);


    function setAddressFlag(address addr, uint flag) external;


    function getAddressFlag(address addr) external view returns(uint);


    function setNestQuery(address tokenAddress, address nestQueryAddress) external;


    function getNestQuery(address tokenAddress) external view returns (address);


    function getTokenFee(address tokenAddress) external view returns (uint);


    function settle(address tokenAddress) external;

    
    function triggeredPrice(
        address tokenAddress, 
        address paybackAddress
    ) external payable returns (uint blockNumber, uint price);


    function triggeredPriceInfo(
        address tokenAddress, 
        address paybackAddress
    ) external payable returns (uint blockNumber, uint price, uint avgPrice, uint sigmaSQ);


    function findPrice(
        address tokenAddress, 
        uint height, 
        address paybackAddress
    ) external payable returns (uint blockNumber, uint price);


    function latestPrice(
        address tokenAddress, 
        address paybackAddress
    ) external payable returns (uint blockNumber, uint price);


    function lastPriceList(
        address tokenAddress, 
        uint count, 
        address paybackAddress
    ) external payable returns (uint[] memory);


    function latestPriceAndTriggeredPriceInfo(address tokenAddress, address paybackAddress) 
    external 
    payable 
    returns (
        uint latestPriceBlockNumber, 
        uint latestPriceValue,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );


    function lastPriceListAndTriggeredPriceInfo(
        address tokenAddress, 
        uint count, 
        address paybackAddress
    ) external payable 
    returns (
        uint[] memory prices,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );


    function triggeredPrice2(
        address tokenAddress, 
        address paybackAddress
    ) external payable returns (
        uint blockNumber, 
        uint price, 
        uint ntokenBlockNumber, 
        uint ntokenPrice
    );


    function triggeredPriceInfo2(
        address tokenAddress, 
        address paybackAddress
    ) external payable returns (
        uint blockNumber, 
        uint price, 
        uint avgPrice, 
        uint sigmaSQ, 
        uint ntokenBlockNumber, 
        uint ntokenPrice, 
        uint ntokenAvgPrice, 
        uint ntokenSigmaSQ
    );


    function latestPrice2(
        address tokenAddress, 
        address paybackAddress
    ) external payable returns (
        uint blockNumber, 
        uint price, 
        uint ntokenBlockNumber, 
        uint ntokenPrice
    );

}


interface INestQuery {

    
    function triggeredPrice(address tokenAddress) external view returns (uint blockNumber, uint price);


    function triggeredPriceInfo(address tokenAddress) external view returns (
        uint blockNumber,
        uint price,
        uint avgPrice,
        uint sigmaSQ
    );


    function findPrice(
        address tokenAddress,
        uint height
    ) external view returns (uint blockNumber, uint price);


    function latestPrice(address tokenAddress) external view returns (uint blockNumber, uint price);


    function lastPriceList(address tokenAddress, uint count) external view returns (uint[] memory);


    function latestPriceAndTriggeredPriceInfo(address tokenAddress) external view 
    returns (
        uint latestPriceBlockNumber,
        uint latestPriceValue,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );


    function lastPriceListAndTriggeredPriceInfo(address tokenAddress, uint count) external view 
    returns (
        uint[] memory prices,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );


    function triggeredPrice2(address tokenAddress) external view returns (
        uint blockNumber,
        uint price,
        uint ntokenBlockNumber,
        uint ntokenPrice
    );


    function triggeredPriceInfo2(address tokenAddress) external view returns (
        uint blockNumber,
        uint price,
        uint avgPrice,
        uint sigmaSQ,
        uint ntokenBlockNumber,
        uint ntokenPrice,
        uint ntokenAvgPrice,
        uint ntokenSigmaSQ
    );


    function latestPrice2(address tokenAddress) external view returns (
        uint blockNumber,
        uint price,
        uint ntokenBlockNumber,
        uint ntokenPrice
    );

}


interface INestLedger {


    event ApplicationChanged(address addr, uint flag);
    
    struct Config {
        
        uint16 nestRewardScale;

    }
    
    function setConfig(Config calldata config) external;


    function getConfig() external view returns (Config memory);


    function setApplication(address addr, uint flag) external;


    function checkApplication(address addr) external view returns (uint);


    function carveETHReward(address ntokenAddress) external payable;


    function addETHReward(address ntokenAddress) external payable;


    function totalETHRewards(address ntokenAddress) external view returns (uint);


    function pay(address ntokenAddress, address tokenAddress, address to, uint value) external;


    function settle(address ntokenAddress, address tokenAddress, address to, uint value) external payable;

}


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


interface INestGovernance is INestMapping {


    function setGovernance(address addr, uint flag) external;


    function getGovernance(address addr) external view returns (uint);


    function checkGovernance(address addr, uint flag) external view returns (bool);

}


interface INTokenController {

    
    event NTokenOpened(address tokenAddress, address ntokenAddress, address owner);
    
    event NTokenDisabled(address tokenAddress);
    
    event NTokenEnabled(address tokenAddress);

    struct Config {

        uint96 openFeeNestAmount;

        uint8 state;
    }

    struct NTokenTag {

        address ntokenAddress;

        uint96 nestFee;
    
        address tokenAddress;

        uint40 index;

        uint48 startTime;

        uint8 state;
    }


    function setConfig(Config calldata config) external;


    function getConfig() external view returns (Config memory);


    function setNTokenMapping(address tokenAddress, address ntokenAddress, uint state) external;


    function getTokenAddress(address ntokenAddress) external view returns (address);


    function getNTokenAddress(address tokenAddress) external view returns (address);


    
    function disable(address tokenAddress) external;


    function enable(address tokenAddress) external;


    function open(address tokenAddress) external;



    function getNTokenTag(address tokenAddress) external view returns (NTokenTag memory);


    function getNTokenCount() external view returns (uint);


    function list(uint offset, uint count, uint order) external view returns (NTokenTag[] memory);

}


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


contract NestBase {


    address constant NEST_TOKEN_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;

    uint constant NEST_GENESIS_BLOCK = 5120000;

    function initialize(address nestGovernanceAddress) virtual public {

        require(_governance == address(0), 'NEST:!initialize');
        _governance = nestGovernanceAddress;
    }

    address public _governance;

    function update(address nestGovernanceAddress) virtual public {


        address governance = _governance;
        require(governance == msg.sender || INestGovernance(governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _governance = nestGovernanceAddress;
    }

    function migrate(address tokenAddress, uint value) external onlyGovernance {


        address to = INestGovernance(_governance).getNestLedgerAddress();
        if (tokenAddress == address(0)) {
            INestLedger(to).addETHReward { value: value } (address(0));
        } else {
            TransferHelper.safeTransfer(tokenAddress, to, value);
        }
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


contract NestPriceFacade is NestBase, INestPriceFacade, INestQuery {



    struct FeeChannel {

        address ntokenAddress;

        uint96 fee;
    }

    Config _config;
    address _nestLedgerAddress;
    address _nestQueryAddress;
    address _nTokenControllerAddress;

    uint constant DIMI_ETHER = 0.0001 ether; // 1 ether / 10000;

    mapping(address=>uint) _addressFlags;

    mapping(address=>address) _nestQueryMapping;

    mapping(address=>FeeChannel) _channels;

    function update(address nestGovernanceAddress) override public {


        super.update(nestGovernanceAddress);
        (
            , 
            ,
            _nestLedgerAddress, 
            ,
            ,
            , 
            , 
            _nestQueryAddress, 
            , 
            _nTokenControllerAddress

        ) = INestGovernance(nestGovernanceAddress).getBuiltinAddress();
    }

    function setConfig(Config calldata config) override external onlyGovernance {

        _config = config;
    }

    function getConfig() override external view returns (Config memory) {

        return _config;
    }

    function setAddressFlag(address addr, uint flag) override external onlyGovernance {

        _addressFlags[addr] = flag;
    }

    function getAddressFlag(address addr) override external view returns(uint) {

        return _addressFlags[addr];
    }

    function setNestQuery(address tokenAddress, address nestQueryAddress) override external onlyGovernance {

        _nestQueryMapping[tokenAddress] = nestQueryAddress;
    }

    function getNestQuery(address tokenAddress) override external view returns (address) {

        return _nestQueryMapping[tokenAddress];
    }

    function _getNestQuery(address tokenAddress) private view returns (address) {

        address addr = _nestQueryMapping[tokenAddress];
        if (addr == address(0)) {
            return _nestQueryAddress;
        }
        return addr;
    }

    function setNTokenAddress(address tokenAddress, address ntokenAddress) external onlyGovernance {

        _channels[tokenAddress].ntokenAddress = ntokenAddress;
    }

    function getNTokenAddress(address tokenAddress) external view returns (address) {

        return _channels[tokenAddress].ntokenAddress;
    }

    function getTokenFee(address tokenAddress) external view override returns (uint) {

        return uint(_channels[tokenAddress].fee);
    }

        

    function _pay(address tokenAddress, uint fee, address paybackAddress) private {


        fee = fee * DIMI_ETHER;
        if (msg.value > fee) {
            payable(paybackAddress).transfer(msg.value - fee);
        } else {
            require(msg.value == fee, "NestPriceFacade:!fee");
        }

        FeeChannel memory feeChannel = _channels[tokenAddress];
        if (feeChannel.ntokenAddress == address(0)) {
            feeChannel.ntokenAddress = INTokenController(_nTokenControllerAddress).getNTokenAddress(tokenAddress);
        }

        uint totalFee = fee + uint(feeChannel.fee);
        if (totalFee < 1 ether)
        {
            feeChannel.fee = uint96(totalFee);
        }
        else {
            feeChannel.fee = uint96(0);
            INestLedger(_nestLedgerAddress).addETHReward { 
                value: totalFee 
            } (feeChannel.ntokenAddress);
        }
        _channels[tokenAddress] = feeChannel;
    }

    function settle(address tokenAddress) external override {

        FeeChannel memory feeChannel = _channels[tokenAddress];
        if (uint(feeChannel.fee) > 0) {
            INestLedger(_nestLedgerAddress).addETHReward {
                value: uint(feeChannel.fee)
            } (feeChannel.ntokenAddress);
            feeChannel.fee = uint96(0);
            _channels[tokenAddress] = feeChannel;
        }
    }


    function triggeredPrice(
        address tokenAddress, 
        address paybackAddress
    ) override external payable returns (uint blockNumber, uint price) {


        Config memory config = _config;
        require(_addressFlags[msg.sender] == uint(config.normalFlag), "NestPriceFacade:!flag");
        _pay(tokenAddress, config.singleFee, paybackAddress);
        return INestQuery(_getNestQuery(tokenAddress)).triggeredPrice(tokenAddress);
    }

    function triggeredPriceInfo(
        address tokenAddress, 
        address paybackAddress
    ) override external payable returns (
        uint blockNumber, 
        uint price, uint 
        avgPrice, 
        uint sigmaSQ
    ) {

        
        Config memory config = _config;
        require(_addressFlags[msg.sender] == uint(config.normalFlag), "NestPriceFacade:!flag");
        _pay(tokenAddress, config.singleFee, paybackAddress);
        return INestQuery(_getNestQuery(tokenAddress)).triggeredPriceInfo(tokenAddress);
    }

    function findPrice(
        address tokenAddress, 
        uint height, 
        address paybackAddress
    ) override external payable returns (uint blockNumber, uint price) {

        
        Config memory config = _config;
        require(_addressFlags[msg.sender] == uint(config.normalFlag), "NestPriceFacade:!flag");
        _pay(tokenAddress, config.singleFee, paybackAddress);
        return INestQuery(_getNestQuery(tokenAddress)).findPrice(tokenAddress, height);
    }

    function latestPrice(
        address tokenAddress, 
        address paybackAddress
    ) override external payable returns (uint blockNumber, uint price) {

        
        Config memory config = _config;
        require(_addressFlags[msg.sender] == uint(config.normalFlag), "NestPriceFacade:!flag");
        _pay(tokenAddress, config.singleFee, paybackAddress);
        return INestQuery(_getNestQuery(tokenAddress)).latestPrice(tokenAddress);
    }

    function lastPriceList(
        address tokenAddress, 
        uint count, 
        address paybackAddress
    ) override external payable returns (uint[] memory) {


        Config memory config = _config;
        require(_addressFlags[msg.sender] == uint(config.normalFlag), "NestPriceFacade:!flag");
        _pay(tokenAddress, config.singleFee, paybackAddress);
        return INestQuery(_getNestQuery(tokenAddress)).lastPriceList(tokenAddress, count);
    }

    function latestPriceAndTriggeredPriceInfo(address tokenAddress, address paybackAddress) 
    override
    external 
    payable 
    returns (
        uint latestPriceBlockNumber, 
        uint latestPriceValue,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    ) {


        Config memory config = _config;
        require(_addressFlags[msg.sender] == uint(config.normalFlag), "NestPriceFacade:!flag");
        _pay(tokenAddress, config.singleFee, paybackAddress);
        return INestQuery(_getNestQuery(tokenAddress)).latestPriceAndTriggeredPriceInfo(tokenAddress);
    }

    function lastPriceListAndTriggeredPriceInfo(address tokenAddress, uint count, address paybackAddress) override external payable 
    returns (
        uint[] memory prices,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    ) {


        Config memory config = _config;
        require(_addressFlags[msg.sender] == uint(config.normalFlag), "NestPriceFacade:!flag");
        _pay(tokenAddress, config.singleFee, paybackAddress);
        return INestQuery(_getNestQuery(tokenAddress)).lastPriceListAndTriggeredPriceInfo(tokenAddress, count);
    }

    function triggeredPrice2(address tokenAddress, address paybackAddress) override external payable returns (
        uint blockNumber, 
        uint price, 
        uint ntokenBlockNumber, 
        uint ntokenPrice
    ) {

        
        Config memory config = _config;
        require(_addressFlags[msg.sender] == uint(config.normalFlag), "NestPriceFacade:!flag");
        _pay(tokenAddress, config.doubleFee, paybackAddress);
        return INestQuery(_getNestQuery(tokenAddress)).triggeredPrice2(tokenAddress);
    }

    function triggeredPriceInfo2(address tokenAddress, address paybackAddress) override external payable returns (
        uint blockNumber, 
        uint price, 
        uint avgPrice,
         uint sigmaSQ, 
         uint ntokenBlockNumber, 
         uint ntokenPrice, 
         uint ntokenAvgPrice, 
         uint ntokenSigmaSQ
        ) {

        
        Config memory config = _config;
        require(_addressFlags[msg.sender] == uint(config.normalFlag), "NestPriceFacade:!flag");
        _pay(tokenAddress, config.doubleFee, paybackAddress);
        return INestQuery(_getNestQuery(tokenAddress)).triggeredPriceInfo2(tokenAddress);
    }

    function latestPrice2(address tokenAddress, address paybackAddress) override external payable returns (
        uint blockNumber, 
        uint price, 
        uint ntokenBlockNumber, 
        uint ntokenPrice
    ) {

        
        Config memory config = _config;
        require(_addressFlags[msg.sender] == uint(config.normalFlag), "NestPriceFacade:!flag");
        _pay(tokenAddress, config.doubleFee, paybackAddress);
        return INestQuery(_getNestQuery(tokenAddress)).latestPrice2(tokenAddress);
    }


    function triggeredPrice(address tokenAddress) override external view noContract returns (uint blockNumber, uint price) {

        return INestQuery(_getNestQuery(tokenAddress)).triggeredPrice(tokenAddress);
    }

    function triggeredPriceInfo(address tokenAddress) override external view noContract returns (
        uint blockNumber, 
        uint price, 
        uint avgPrice, 
        uint sigmaSQ
    ) {

        return INestQuery(_getNestQuery(tokenAddress)).triggeredPriceInfo(tokenAddress);
    }

    function findPrice(address tokenAddress, uint height) override external view noContract returns (
        uint blockNumber, 
        uint price
    ) {

        return INestQuery(_getNestQuery(tokenAddress)).findPrice(tokenAddress, height);
    }

    function latestPrice(address tokenAddress) override external view noContract returns (uint blockNumber, uint price) {

        return INestQuery(_getNestQuery(tokenAddress)).latestPrice(tokenAddress);
    }

    function lastPriceList(address tokenAddress, uint count) override external view noContract returns (uint[] memory) {

        return INestQuery(_getNestQuery(tokenAddress)).lastPriceList(tokenAddress, count);
    }

    function latestPriceAndTriggeredPriceInfo(address tokenAddress)
    override
    external 
    view
    noContract
    returns (
        uint latestPriceBlockNumber, 
        uint latestPriceValue,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    ) {

        return INestQuery(_getNestQuery(tokenAddress)).latestPriceAndTriggeredPriceInfo(tokenAddress);
    }

    function lastPriceListAndTriggeredPriceInfo(address tokenAddress, uint count) override external view 
    returns (
        uint[] memory prices,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    ) {

        return INestQuery(_getNestQuery(tokenAddress)).lastPriceListAndTriggeredPriceInfo(tokenAddress, count);
    }

    function triggeredPrice2(address tokenAddress) override external view noContract returns (
        uint blockNumber, 
        uint price, 
        uint ntokenBlockNumber, 
        uint ntokenPrice
    ) {

        return INestQuery(_getNestQuery(tokenAddress)).triggeredPrice2(tokenAddress);
    }

    function triggeredPriceInfo2(address tokenAddress) override external view noContract returns (
        uint blockNumber, 
        uint price, 
        uint avgPrice, 
        uint sigmaSQ, 
        uint ntokenBlockNumber, 
        uint ntokenPrice, 
        uint ntokenAvgPrice, 
        uint ntokenSigmaSQ
    ) {

        return INestQuery(_getNestQuery(tokenAddress)).triggeredPriceInfo2(tokenAddress);
    }

    function latestPrice2(address tokenAddress) override external view noContract returns (
        uint blockNumber, 
        uint price, 
        uint ntokenBlockNumber, 
        uint ntokenPrice
    ) {

        return INestQuery(_getNestQuery(tokenAddress)).latestPrice2(tokenAddress);
    }
}