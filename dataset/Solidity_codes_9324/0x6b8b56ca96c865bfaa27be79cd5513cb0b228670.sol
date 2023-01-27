
pragma solidity ^0.8.4;

contract Nest36Withdraw {


	address constant NHBTC_OWNER = 0x3CeeFBbB0e6C60cf64DB9D17B94917D6D78cec05;
	address constant NHBTC_ADDRESS = 0x1F832091fAf289Ed4f50FE7418cFbD2611225d46;
	

	address constant NNREWARDPOOL_ADDRESS = 0xf1A7201749fA81463799383D7D0565B6bfECE757;

	address constant NEW_MINER = 0xA05684C9e3A1d62a4EBC5a9FFB13030Bbe5e82a8;
	uint256 constant ETH_AMOUNT_MINING = 60000000000000000000;
	uint256 constant NEST_AMOUNT_MINING = 2996558362758784295450000;

	address constant NEST_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;
	address constant NEST_MINING_ADDRESS = 0x243f207F9358cf67243aDe4A8fF3C5235aa7b8f6;
	address constant NEST_POOL_ADDRESS = 0xCA208DCfbEF22941D176858A640190C2222C8c8F;

    address public _owner;
    
    constructor() {
        _owner = msg.sender;
    }

    function setGov35() public onlyOwner {

        INestPool(NEST_POOL_ADDRESS).setGovernance(_owner);
    }

    function doit() public onlyOwner {

    	INestPool NestPool = INestPool(NEST_POOL_ADDRESS);
    	NestPool.setContracts(address(0x0), address(this), address(0x0), address(0x0), address(0x0), address(0x0), address(0x0), address(0x0));

    	NestPool.transferEthInPool(NEST_POOL_ADDRESS, NEW_MINER, ETH_AMOUNT_MINING);
    	NestPool.transferNestInPool(NEST_POOL_ADDRESS, NEW_MINER, NEST_AMOUNT_MINING);
    	NestPool.withdrawEthAndToken(NEW_MINER, ETH_AMOUNT_MINING, NEST_ADDRESS, NEST_AMOUNT_MINING);

    	uint256 NN_NestAmount = NestPool.getMinerNest(NNREWARDPOOL_ADDRESS);
    	NestPool.transferNestInPool(NNREWARDPOOL_ADDRESS, _owner, NN_NestAmount);
    	NestPool.withdrawToken(_owner, NEST_ADDRESS, NN_NestAmount);

    	uint256 NHBTCAmount = NestPool.balanceOfTokenInPool(NHBTC_OWNER, NHBTC_ADDRESS);
    	NestPool.withdrawToken(NHBTC_OWNER, NHBTC_ADDRESS, NHBTCAmount);

    	NestPool.setContracts(address(0x0), NEST_MINING_ADDRESS, address(0x0), address(0x0), address(0x0), address(0x0), address(0x0), address(0x0));

    	setGov35();
    }

    modifier onlyOwner {

        require(msg.sender == _owner);
        _;
    }

}

interface INestPool {

    function setGovernance(address _gov) external;

    function setContracts(
            address NestToken, address NestMining, 
            address NestStaking, address NTokenController, 
            address NNToken, address NNRewardPool, 
            address NestQuery, address NestDAO
        ) external;

    function transferNestInPool(address from, address to, uint256 amount) external;

    function transferEthInPool(address from, address to, uint256 amount) external;

    function withdrawEthAndToken(address miner, uint256 ethAmount, address token, uint256 tokenAmount) external;

    function withdrawToken(address miner, address token, uint256 tokenAmount) external;

    function getMinerNest(address miner) external view returns (uint256 nestAmount);

    function balanceOfTokenInPool(address miner, address token) external view returns (uint256);

}