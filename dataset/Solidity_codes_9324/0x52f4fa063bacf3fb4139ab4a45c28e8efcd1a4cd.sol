
pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(),"Not Owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0),"Zero address not allowed");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IGatewayVault {

    function vaultTransfer(address token, address recipient, uint256 amount) external returns (bool);

    function vaultApprove(address token, address spender, uint256 amount) external returns (bool);

}

interface IDegen {

    enum OrderType {EthForTokens, TokensForEth, TokensForTokens}
    function callbackCrossExchange(OrderType orderType, address[] memory path, uint256 assetInOffered, address user, uint256 dexId, uint256[] memory distribution, uint256 deadline)
    external returns(bool);

}

interface IBEP20 {

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address to, uint256 amount) external returns (bool);

    function burnFrom(address account, uint256 amount) external returns(bool);

}

contract DegenBridge is Ownable {

    
    address public USDT = address(0);

    uint256 _nonce = 0;
    mapping(uint256 => bool) public nonceProcessed;
    
    mapping(uint256 => IDegen.OrderType) private _orderType;

    address public system;  // system address may change fee amount
    bool public paused;
    address public gatewayVault; // GatewayVault contract
    address public degenContract;
    
    event SwapRequest(
        address indexed tokenA, 
        address indexed tokenB, 
        address indexed user, 
        uint256 amount,
        uint256 crossOrderType, 
        uint256 nonce,
        uint256 dexId,
        uint256[] distribution,
        uint256 deadline
    );

    event ClaimApprove(
        address indexed tokenA, 
        address indexed tokenB, 
        address indexed user, 
        uint256 amount, 
        uint256 crossOrderType,
        uint256 dexId,
        uint256[] distribution,
        uint256 deadline
    );

    modifier notPaused() {

        require(!paused,"Swap paused");
        _;
    }

    modifier onlySystem() {

        require(msg.sender == system || owner() == msg.sender,"Caller is not the system");
        _;
    }

    constructor (address _system, address _gatewayVault, address _usdt) {
        system = _system;
        gatewayVault = _gatewayVault;
        USDT = _usdt;
        _orderType[0] = IDegen.OrderType.TokensForTokens;
        _orderType[1] = IDegen.OrderType.TokensForEth;
        _orderType[2] = IDegen.OrderType.TokensForTokens;
        _orderType[3] = IDegen.OrderType.TokensForEth;
    }


    function setDegenContract(address _degenContract) external onlyOwner returns(bool) {

        degenContract = _degenContract;
        return true;
    }

    function setSystem(address _system) external onlyOwner returns(bool) {

        system = _system;
        return true;
    }
    
    function setUSDT(address _usdt) external onlyOwner returns(bool) {

        USDT = _usdt;
        return true;
    }
    
    function setPause(bool pause) external onlyOwner returns(bool) {

        paused = pause;
        return true;
    }

    function getTransactionStatus(uint256 nonce) external view returns (bool){

      return nonceProcessed[nonce];
    }


    function swap(address tokenA, address tokenB, uint256 amount, address user, uint256 crossOrderType, uint256 dexId, uint256[] memory distribution, uint256 deadline) 
    external payable notPaused returns (bool) {

        require(msg.sender == degenContract, "Only Degen");
        require(amount != 0, "Zero amount");
        require(gatewayVault != address(0), "No vault address");
        require(deadline >= block.timestamp, "EXPIRED: Deadline for bridge transaction already passed.");
        IBEP20(tokenA).transferFrom(msg.sender, gatewayVault, amount);
        _nonce = _nonce+1;
        emit SwapRequest(tokenA, tokenB, user, amount, crossOrderType, _nonce, dexId, distribution, deadline);
        return true;
    }

   
    function claimTokenBehalf(address[] memory path, address user, uint256 amount, uint256 crossOrderType, uint256 nonce, uint256 dexId, uint256[] memory distribution, uint256 deadline)
    external onlySystem notPaused returns (bool) {

        require(!nonceProcessed[nonce], "Exchange already processed");
        
        _claim(path, user, amount, crossOrderType, dexId, distribution, deadline);
        nonceProcessed[nonce] = true;
        return true;
    }


    function _claim (address[] memory path, address user, uint256 amount, uint256 crossOrderType, uint256 dexId, uint256[] memory distribution, uint256 deadline) 
    internal returns(bool) {
        require(deadline >= block.timestamp, "EXPIRED: Deadline for claim transaction already passed.");
        if(path[path.length-1] == USDT) {
            IGatewayVault(gatewayVault).vaultTransfer(USDT, user, amount); 
        } 
        else {
            IGatewayVault(gatewayVault).vaultTransfer(USDT, degenContract, amount); 
            IDegen(degenContract).callbackCrossExchange(_orderType[crossOrderType], path, amount, user, dexId, distribution, deadline);
        }
        emit ClaimApprove(path[0], path[path.length-1], user, amount, crossOrderType, dexId, distribution, deadline);
        return true;
    }
}