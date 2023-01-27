


pragma solidity ^0.6.2;

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
}




pragma solidity ^0.6.0;

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




pragma solidity ^0.6.0;




library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.6.0;



contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }
    
    function constructor1 (string memory name, string memory symbol) internal {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    
}




pragma solidity ^0.6.0;

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


pragma solidity ^0.6.7;


contract mTokens is ERC20 {

    address managerFactory;
    struct claimer {
        uint256 unlockBlock;
    }
    mapping(address => claimer) public locker;
    
    using SafeERC20 for IERC20;
    using SafeMath for uint32;
    using SafeMath for uint256;
    
    constructor(address factory) public ERC20("managerToken", "mToken") {
        managerFactory = factory;
    }
    
    function mintTokens(address depositor, uint256 amount) public {

        require(msg.sender == managerFactory);
        _mint(depositor, amount);
    }
    
    function burnTokens(uint256 amount) public {

        require(msg.sender == managerFactory);
        require(locker[msg.sender].unlockBlock < block.number);
        IERC20(address(this)).safeTransferFrom(msg.sender, address(this), amount);
        _burn(address(this), amount);
    }
    
    function claimAndLock(address _claimer) public returns (bool) {

        require(msg.sender == managerFactory);
        if (locker[_claimer].unlockBlock < block.number) {
            locker[_claimer].unlockBlock = block.number.add(91000);
            return true;
        } else {
            return false;
        }
    }
    
     function transfer(address _recipient, uint256 _amount) public override returns(bool) {    

        require(locker[msg.sender].unlockBlock < block.number);
        return super.transfer(_recipient, _amount);
    }
    
    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns(bool) {

        require(locker[_sender].unlockBlock < block.number);
        return super.transferFrom(_sender, _recipient, _amount);
    }
}


pragma solidity ^0.6.7;




contract Proxiable {


    function updateCodeAddress(address newAddress) internal {

        require(
            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }
    }
    function proxiableUUID() public pure returns (bytes32) {

        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

contract LibraryLockDataLayout {

  bool public initialized = false;
}

contract LibraryLock is LibraryLockDataLayout {


    modifier delegatedOnly() {

        require(initialized == true, "The library is locked. No direct 'call' is allowed");
        _;
    }
    function initialize() internal {

        initialized = true;
    }
}

contract ManagerDataLayout is LibraryLock {

    address public owner;
    address public nyanVoting;
    address[] public pools;
    struct eachManager {
        uint256 holdings;
        uint256 profits;
        uint32 ROI;
        uint256 lastCheckInBlock;
        bool isManager;
        address[] usedContracts;
        string name;
        uint256[] holdingsHistory;
        uint256[] profitHistory;
        address poolToken;
    }
    mapping(address => eachManager) public managerStruct;

    mapping(address => bool) public isPoolToken;
    
    using SafeERC20 for IERC20;
    using SafeMath for uint32;
    using SafeMath for uint256;
    
    address public fundContract;
    address public connectorContract;
    address public registry;
    address public rewardsContract;
    address public devContract;
    address public nyanManager;
    address public contractManager;
}


interface usedContract {

    function withdrawDeposit(uint256 amount, address depositor) external;

    function fundLog(address manager, string calldata reason, address recipient) external payable;

    function isFundManager(address manager) view external returns(bool);

}


contract Manager is Proxiable, ManagerDataLayout {

    constructor() public {
        
    }
    
    function updateCode(address newCode) public delegatedOnly  {

        if (owner == address(0)) {
            require(msg.sender == contractManager);
        } else {
            require(msg.sender == owner);
        }
        updateCodeAddress(newCode);
    }
    
    function managerInit(address _owner) public {

        require(!initialized);
        owner = _owner;
        initialize();
    }
    
    function setContracts(address _contractManager) public delegatedOnly {

        require(msg.sender == owner);
        contractManager = _contractManager;
        fundContract = 0x2c9728ad35C1CfB16E3C1B5045bC9BA30F37FAc5;
        connectorContract = 0x60d70dF1c783b1E5489721c443465684e2756555;
        registry = 0x66BFd3ed6618D9C62DcF1eF706D9Aacd5FdBCCD6;
        rewardsContract = 0x868f7622F57b62330Db8b282044d7EAf067fAcfe;
        devContract = 0xd66A9D2B706e225204F475c9e70A4c09eEa62199;
        nyanManager = 0x74A9ec513bC45Bd04769fDF7A502E9c2a39E2D0E;
    }
    
    event selfPoolCreated(address creator, address pool);
    function openPool(string memory _name) public payable delegatedOnly {

        require(msg.value >= 0.05 ether);
        require(!usedContract(nyanManager).isFundManager(msg.sender), "Fund Manager address cannot self manage");
        address newPoolToken = address(new mTokens(address(this)));
        pools.push(newPoolToken);
        managerStruct[msg.sender].poolToken = newPoolToken;
        managerStruct[msg.sender].name = _name;
        devContract.call{value: msg.value.div(10)}("");
        rewardsContract.call{value: msg.value.sub(msg.value.div(10))}("");
        
        emit selfPoolCreated(msg.sender, newPoolToken);
    }
    
    event ETHSwapForTokens(address depositor, address manager, address pool, uint256 ETH);
    function ETHForTokens(address manager, address pool) public payable delegatedOnly {

        require(managerStruct[manager].poolToken == pool);
        uint256 poolFee = msg.value.mul(1).div(100);
        devContract.call{value: poolFee.div(10)}("");
        rewardsContract.call{value: poolFee.sub(poolFee.div(10))}("");
        fundContract.call{value: msg.value.sub(poolFee)}("");
        usedContract(fundContract).fundLog(manager, "got an ETH deposit", fundContract);
        managerStruct[manager].holdings = managerStruct[manager].holdings.add(msg.value.sub(poolFee));
        managerStruct[manager].holdingsHistory.push(managerStruct[manager].holdings);
        mTokens(pool).mintTokens(msg.sender, msg.value.sub(poolFee));
        
        emit ETHSwapForTokens(msg.sender, manager, pool, msg.value);
    }
    
    function estimateTokensForETH(address manager, address pool, uint256 tokens) public view returns(uint256) {

        require(managerStruct[manager].poolToken == pool);
        uint256 claimedHoldings = managerStruct[manager].holdings
                                    .mul(tokens)
                                    .div(IERC20(pool).totalSupply());
        return claimedHoldings;
    }
    
    event tokenSwapForETH(address depositor, address manager, address pool, uint256 ETHClaimed);
    function tokensForETH(address manager, address pool, uint256 tokens) public delegatedOnly {

        require(managerStruct[manager].poolToken == pool);
        IERC20(pool).safeTransferFrom(msg.sender, address(this), tokens);
        uint256 claimedHoldings = managerStruct[manager].holdings
                                    .mul(tokens)
                                    .div(IERC20(pool).totalSupply());
        usedContract(connectorContract).withdrawDeposit(claimedHoldings, msg.sender);
        usedContract(fundContract).fundLog(manager, "ETH withdrawal", msg.sender);
        managerStruct[manager].holdings = managerStruct[manager].holdings.sub(claimedHoldings);
        managerStruct[manager].holdingsHistory.push(managerStruct[manager].holdings);
        IERC20(pool).approve(pool, tokens);
        mTokens(pool).burnTokens(tokens);
        
        emit tokenSwapForETH(msg.sender, manager, pool, claimedHoldings);
    }
    
    function checkManagerAllowance(address _manager, uint256 ETH) public returns(bool) {

        require(msg.sender == registry);
        require(managerStruct[_manager].holdings >= ETH, "Manager: Insufficient holdings");
        managerStruct[_manager].holdings = managerStruct[_manager].holdings.sub(ETH);
        managerStruct[_manager].holdingsHistory.push(managerStruct[_manager].holdings);
        return true;
    }
    
    function adjustManagerAllowance(address _manager, uint256 ETH, uint256 profit) public delegatedOnly {

        require(msg.sender == registry);
        managerStruct[_manager].holdings = managerStruct[_manager].holdings.add(ETH.sub(profit));
        managerStruct[_manager].holdingsHistory.push(managerStruct[_manager].holdings);
        managerStruct[_manager].profits = managerStruct[_manager].profits.add(profit);
        managerStruct[_manager].profitHistory.push(managerStruct[_manager].profits);
    }
    
    function estimatedProfit(address _manager, address pool) public view returns(uint256) {

        require(managerStruct[_manager].poolToken == pool);
        require(managerStruct[_manager].profits > 100);
        uint256 claimedProfit = IERC20(pool).balanceOf(msg.sender)
                                    .mul(managerStruct[_manager].profits)
                                    .div(IERC20(pool).totalSupply());
        return claimedProfit;
    }
    
    event profitClaimed(address depositor, address manager, address pool, uint256 profit);
    function claimProfit(address _manager, address pool) public delegatedOnly {

        require(managerStruct[_manager].poolToken == pool);
        require(mTokens(pool).claimAndLock(msg.sender), "Already claimed for now");
        require(managerStruct[_manager].profits > 100);
        uint256 claimedProfit = IERC20(pool).balanceOf(msg.sender)
                                    .mul(managerStruct[_manager].profits)
                                    .div(IERC20(pool).totalSupply());
        managerStruct[_manager].profits = managerStruct[_manager].profits.sub(claimedProfit);                           
        usedContract(connectorContract).withdrawDeposit(claimedProfit, msg.sender);
        usedContract(connectorContract).fundLog(_manager, "ETH profit withdrawal", msg.sender);
        
        emit profitClaimed(msg.sender, _manager, pool, claimedProfit);
    }
    
    
    
    function isSelfManager(address _manager) public view returns(bool) {

        if (managerStruct[_manager].poolToken == address(0)) {
            return false;
        } else {
            return true;
        }
    }
    
    receive() external payable {
        
    }
}