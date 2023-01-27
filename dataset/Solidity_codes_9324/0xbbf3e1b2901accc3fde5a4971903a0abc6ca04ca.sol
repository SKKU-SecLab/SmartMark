


pragma solidity ^0.8.3;

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


interface INestMining {

    
    event Post(address tokenAddress, address miner, uint index, uint ethNum, uint price);

    
    struct Config {
        
        uint32 postEthUnit;

        uint16 postFeeUnit;

        uint16 minerNestReward;
        
        uint16 minerNTokenReward;

        uint32 doublePostThreshold;
        
        uint16 ntokenMinedBlockLimit;

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


    function setConfig(Config memory config) external;


    function getConfig() external view returns (Config memory);


    function setNTokenAddress(address tokenAddress, address ntokenAddress) external;


    function getNTokenAddress(address tokenAddress) external view returns (address);



    function post(address tokenAddress, uint ethNum, uint tokenAmountPerEth) external payable;


    function post2(address tokenAddress, uint ethNum, uint tokenAmountPerEth, uint ntokenAmountPerEth) external payable;


    function takeToken(address tokenAddress, uint index, uint takeNum, uint newTokenAmountPerEth) external payable;


    function takeEth(address tokenAddress, uint index, uint takeNum, uint newTokenAmountPerEth) external payable;

    
    function close(address tokenAddress, uint index) external;


    function closeList(address tokenAddress, uint[] memory indices) external;


    function closeList2(address tokenAddress, uint[] memory tokenIndices, uint[] memory ntokenIndices) external;


    function stat(address tokenAddress) external;


    function settle(address tokenAddress) external;


    function list(address tokenAddress, uint offset, uint count, uint order) external view returns (PriceSheetView[] memory);


    function estimate(address tokenAddress) external view returns (uint);


    function getMinedBlocks(address tokenAddress, uint index) external view returns (uint minedBlocks, uint totalShares);



    function withdraw(address tokenAddress, uint value) external;


    function balanceOf(address tokenAddress, address addr) external view returns (uint);


    function indexAddress(uint index) external view returns (address);

    
    function getAccountIndex(address addr) external view returns (uint);


    function getAccountCount() external view returns (uint);

}


interface INestVote {


    event NIPSubmitted(address proposer, address contractAddress, uint index);

    event NIPVote(address voter, uint index, uint amount);

    event NIPExecute(address executor, uint index);

    struct Config {

        uint32 acceptance;

        uint64 voteDuration;

        uint96 proposalStaking;
    }

    struct ProposalView {

        uint index;
        

        string brief;

        address contractAddress;

        uint48 startTime;

        uint48 stopTime;

        address proposer;

        uint96 staked;


        uint96 gainValue;

        uint32 state;  // 0: proposed | 1: accepted | 2: cancelled

        address executor;


        uint96 nestCirculation;
    }
    
    function setConfig(Config memory config) external;


    function getConfig() external view returns (Config memory);


    
    function propose(address contractAddress, string memory brief) external;


    function vote(uint index, uint value) external;


    function withdraw(uint index) external;


    function execute(uint index) external;


    function cancel(uint index) external;


    function getProposeInfo(uint index) external view returns (ProposalView memory);


    function getProposeCount() external view returns (uint);


    function list(uint offset, uint count, uint order) external view returns (ProposalView[] memory);


    function getNestCirculation() external view returns (uint);


    function upgradeProxy(address proxyAdmin, address proxy, address implementation) external;


    function transferUpgradeAuthority(address proxyAdmin, address newOwner) external;

}


interface IVotePropose {


    function run() external;

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


interface IProxyAdmin {


    function upgrade(address proxy, address implementation) external;


    function transferOwnership(address newOwner) external;

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


interface INestLedger {


    event ApplicationChanged(address addr, uint flag);
    
    struct Config {
        
        uint16 nestRewardScale;

    }
    
    function setConfig(Config memory config) external;


    function getConfig() external view returns (Config memory);


    function setApplication(address addr, uint flag) external;


    function checkApplication(address addr) external view returns (uint);


    function carveETHReward(address ntokenAddress) external payable;


    function addETHReward(address ntokenAddress) external payable;


    function totalETHRewards(address ntokenAddress) external view returns (uint);


    function pay(address ntokenAddress, address tokenAddress, address to, uint value) external;


    function settle(address ntokenAddress, address tokenAddress, address to, uint value) external payable;

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


contract NestVote is NestBase, INestVote {

    

    struct UINT {
        uint value;
    }

    struct Proposal {


        string brief;

        address contractAddress;

        uint48 startTime;

        uint48 stopTime;

        address proposer;

        uint96 staked;


        uint96 gainValue;

        uint32 state;

        address executor;

    }
    
    Config _config;

    Proposal[] public _proposalList;

    mapping(uint =>mapping(address =>UINT)) public _stakedLedger;
    
    address _nestLedgerAddress;
    address _nestMiningAddress;
    address _nnIncomeAddress;

    uint32 constant PROPOSAL_STATE_PROPOSED = 0;
    uint32 constant PROPOSAL_STATE_ACCEPTED = 1;
    uint32 constant PROPOSAL_STATE_CANCELLED = 2;

    uint constant NEST_TOTAL_SUPPLY = 10000000000 ether;

    function update(address nestGovernanceAddress) override public {

        super.update(nestGovernanceAddress);

        (
            ,//_nestTokenAddress, 
            ,
            _nestLedgerAddress, 
            _nestMiningAddress, 
            ,
            ,
            ,
            ,
            _nnIncomeAddress, 
              
        ) = INestGovernance(nestGovernanceAddress).getBuiltinAddress();
    }

    function setConfig(Config memory config) override external onlyGovernance {

        require(uint(config.acceptance) <= 10000, "NestVote:!value");
        _config = config;
    }

    function getConfig() override external view returns (Config memory) {

        return _config;
    }

    
    function propose(address contractAddress, string memory brief) override external noContract
    {

        require(!INestGovernance(_governance).checkGovernance(contractAddress, 0), "NestVote:!governance");
     
        Config memory config = _config;
        uint index = _proposalList.length;

        _proposalList.push(Proposal(
        
            brief,

            contractAddress,

            uint48(block.timestamp),

            uint48(block.timestamp + uint(config.voteDuration)),

            msg.sender,

            config.proposalStaking,

            uint96(0), 
            
            PROPOSAL_STATE_PROPOSED, 

            address(0)
        ));

        IERC20(NEST_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), uint(config.proposalStaking));

        emit NIPSubmitted(msg.sender, contractAddress, index);
    }

    function vote(uint index, uint value) override external noContract
    {

        Proposal memory p = _proposalList[index];

        require(block.timestamp >= uint(p.startTime) && block.timestamp < uint(p.stopTime), "NestVote:!time");
        require(p.state == PROPOSAL_STATE_PROPOSED, "NestVote:!state");

        UINT storage balance = _stakedLedger[index][msg.sender];
        balance.value += value;

        _proposalList[index].gainValue = uint96(uint(p.gainValue) + value);

        IERC20(NEST_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), value);

        emit NIPVote(msg.sender, index, value);
    }

    function withdraw(uint index) override external noContract
    {

        UINT storage balance = _stakedLedger[index][msg.sender];
        uint balanceValue = balance.value;
        balance.value = 0;

        if (_proposalList[index].state == PROPOSAL_STATE_PROPOSED) {
            _proposalList[index].gainValue = uint96(uint(_proposalList[index].gainValue) - balanceValue);
        }

        IERC20(NEST_TOKEN_ADDRESS).transfer(msg.sender, balanceValue);
    }

    function execute(uint index) override external noContract
    {

        Config memory config = _config;

        Proposal memory p = _proposalList[index];

        require(p.state == PROPOSAL_STATE_PROPOSED, "NestVote:!state");
        require(block.timestamp < uint(p.stopTime), "NestVote:!time");
        address governance = _governance;
        require(!INestGovernance(governance).checkGovernance(p.contractAddress, 0), "NestVote:!governance");

        IERC20 nest = IERC20(NEST_TOKEN_ADDRESS);

        uint nestCirculation = _getNestCirculation(nest);
        require(uint(p.gainValue) * 10000 >= nestCirculation * uint(config.acceptance), "NestVote:!gainValue");

        INestGovernance(governance).setGovernance(p.contractAddress, 1);

        _proposalList[index].state = PROPOSAL_STATE_ACCEPTED;
        _proposalList[index].executor = msg.sender;
        IVotePropose(p.contractAddress).run();

        INestGovernance(governance).setGovernance(p.contractAddress, 0);
        
        nest.transfer(p.proposer, uint(p.staked));

        emit NIPExecute(msg.sender, index);
    }

    function cancel(uint index) override external noContract {


        Proposal memory p = _proposalList[index];

        require(p.state == PROPOSAL_STATE_PROPOSED, "NestVote:!state");
        require(block.timestamp >= uint(p.stopTime), "NestVote:!time");

        _proposalList[index].state = PROPOSAL_STATE_CANCELLED;

        IERC20(NEST_TOKEN_ADDRESS).transfer(p.proposer, uint(p.staked));
    }

    function _toProposalView(Proposal memory proposal, uint index, uint nestCirculation) private pure returns (ProposalView memory) {


        return ProposalView(
            index,
            proposal.brief,
            proposal.contractAddress,
            proposal.startTime,
            proposal.stopTime,
            proposal.proposer,
            proposal.staked,
            proposal.gainValue,
            proposal.state,
            proposal.executor,

            uint96(nestCirculation)
        );
    }

    function getProposeInfo(uint index) override external view returns (ProposalView memory) {

        return _toProposalView(_proposalList[index], index, getNestCirculation());
    }

    function getProposeCount() override external view returns (uint) {

        return _proposalList.length;
    }

    function list(uint offset, uint count, uint order) override external view returns (ProposalView[] memory) {

        
        Proposal[] storage proposalList = _proposalList;
        ProposalView[] memory result = new ProposalView[](count);
        uint nestCirculation = getNestCirculation();
        uint length = proposalList.length;
        uint i = 0;

        if (order == 0) {

            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                --index;
                result[i++] = _toProposalView(proposalList[index], index, nestCirculation);
            }
        } 
        else {
            
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                result[i++] = _toProposalView(proposalList[index], index, nestCirculation);
                ++index;
            }
        }

        return result;
    }

    function _getNestCirculation(IERC20 nest) private view returns (uint) {


        return NEST_TOTAL_SUPPLY 
            - nest.balanceOf(_nestMiningAddress)
            - nest.balanceOf(_nnIncomeAddress)
            - nest.balanceOf(_nestLedgerAddress)
            - nest.balanceOf(address(0x1));
    }

    function getNestCirculation() override public view returns (uint) {

        return _getNestCirculation(IERC20(NEST_TOKEN_ADDRESS));
    }

    function upgradeProxy(address proxyAdmin, address proxy, address implementation) override external onlyGovernance {

        IProxyAdmin(proxyAdmin).upgrade(proxy, implementation);
    }

    function transferUpgradeAuthority(address proxyAdmin, address newOwner) override external onlyGovernance {

        IProxyAdmin(proxyAdmin).transferOwnership(newOwner);
    }
}