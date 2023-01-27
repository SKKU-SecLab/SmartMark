
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    
    function decimals()  external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


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
}pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;


contract V3Contract is Ownable{


    using SafeMath for uint;
    using SafeERC20 for IERC20;
    
    IERC20 public v3Token = IERC20(0x0);
    
    address public adminAddr;
    
    mapping(address => uint256) map_userTokens;
    address[] array_users;
    
    uint256 public exchange_ratio = 80;
    uint256 public invite_reward_v3_ratio = 10;
    string public ico_flag = "pre-sale";
    bool public lock = true;
    uint256 public v3Token_decimals = 6;
    bool public active_ico = false;
    uint256 public min_amount_of_eth_transfer = 500;
    
    event receive_pay(address sender_, uint256 amount_);
    event fallback_pay(address sender_,uint256 amount_);
    event withdraw_eth(address target_,uint256 amount_);
    event join_presale_invite(string flag_,address sender_,uint256 eth_amount,uint256 v3_amount,address invite_addr_,uint256 v3_reward_amount_);
    event join_presale(string flag_,address sender_,uint256 eth_amount,uint256 v3_amount);
    
    constructor(address v3_token_address) public{
        adminAddr = msg.sender;
        v3Token = IERC20(v3_token_address);
    }
    
    fallback() external payable {
        emit fallback_pay(msg.sender, msg.value);
    }
    
    
    receive() external payable {
        emit receive_pay(msg.sender, msg.value);
    }
    
    
    function set_status(bool active_) public isAdmin{

        active_ico = active_;
    }
    
    function change(bool v_) public isAdmin{

        lock = v_;
    }
    
    function set_v3Token_decimals(uint256 v3Token_decimals_) public isAdmin{

        v3Token_decimals = v3Token_decimals_;
    }
      
    function set_exchange_ratio(uint256 ratio_) public isAdmin{

        
        require(ratio_ >= 1,"invaild exchange_ratio");
        exchange_ratio = ratio_;
    }
    
    function set_min_amount_of_eth_transfer(uint256 min_amount_of_eth_transfer_) public isAdmin{

        min_amount_of_eth_transfer = min_amount_of_eth_transfer_;
    }
    
    function set_invite_reward_v3_amount(uint256 invite_reward_v3_ratio_) public isAdmin{

        
        invite_reward_v3_ratio = invite_reward_v3_ratio_;
    }
    
    function set_flag_for_current_ico(string memory flag_) public isAdmin{

       
        ico_flag = flag_;
    }
    
    function fetchUserTokenSize() public view returns(uint256){

        return array_users.length;
    }
    
    function fetchUserTokenDatas(uint256 cursor, uint256 length_) public view returns (address[] memory,uint256[] memory, uint256)
    {

        uint256 length = length_;
        if (length > array_users.length - cursor) {
            length = array_users.length - cursor;
        }

        address[]memory addrs = new address[](length);
        uint256[] memory tokens = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            address addr = array_users[cursor + i];
            addrs[i] = addr;
            tokens[i] = map_userTokens[addr];
        }
        
        
        return (addrs, tokens,cursor + length);
    }
    
    
    function test_addToken_eth(address addr_,uint256 eth_) public isAdmin returns(uint256,uint256){

        uint256 v3_amount;
        uint256 v3_reward;
        uint256 eth_amount;
        (eth_amount,v3_amount,v3_reward) = calcV3WithETH(eth_);
        map_userTokens[addr_] += v3_amount;
        return (v3_amount,v3_reward);
    }
    
    function calcV3WithETH(uint256 eth_) public view returns (uint256,uint256,uint256){

        uint256 v3_amount = eth_ * exchange_ratio * 10 ** v3Token_decimals/(10**18);
        uint256 v3_reward = v3_amount * invite_reward_v3_ratio / 100 ;
        return (eth_,v3_amount,v3_reward);
    }
    
    function joinPreSale_invite(uint256 eth_,address invite_addr_) public{

        
        require(msg.sender!=invite_addr_,"cant not invited by yourself");
        joinPreSale(eth_);
        uint256 v3_amount;
        uint256 v3_reward;
        uint256 eth_amount;
        (eth_amount,v3_amount,v3_reward) = calcV3WithETH(eth_);
        
        if(invite_addr_ == address(invite_addr_)&&v3_reward>0){
            
            map_userTokens[invite_addr_] +=v3_reward;
            
            if(map_userTokens[invite_addr_] == 0x0){
                array_users.push(invite_addr_);
            }
        }
        emit join_presale_invite(ico_flag,msg.sender,eth_,v3_amount,invite_addr_,v3_reward);
    }
    
    function joinPreSale(uint256 eth_) public {

        
        require(active_ico,"The Pre-sale is pending.");
        
        uint256 v3_amount;
        uint256 v3_reward;
        uint256 eth_amount;
        (eth_amount,v3_amount,v3_reward) = calcV3WithETH(eth_);
        
        if(v3_amount > 0x0){
            if(map_userTokens[msg.sender] == 0x0){
                array_users.push(msg.sender);
            }
            map_userTokens[msg.sender] += v3_amount;
        }
        
        emit join_presale(ico_flag,msg.sender,eth_,v3_amount);
        
    }
    
    function setToken(address tokenAddress_) public onlyOwner {

        v3Token = IERC20(tokenAddress_);
    }
    
    modifier isAdmin() {

        require(msg.sender == adminAddr);
        _;
    }

    function setAdmin(address _newAdmin) external onlyOwner {

        require(_newAdmin != address(0),"invaild admin address");
        adminAddr = _newAdmin;
    }
    
    function withdrawToken(uint256 amount_) public {

        require(!lock,"The pre-sale is not over, you can't withdraw");
        uint256 balance = map_userTokens[msg.sender];
        require(balance >= amount_,"not enough v3 token");
        v3Token.safeTransfer(msg.sender,amount_);
        map_userTokens[msg.sender] = balance - amount_;
    }
    
    function transferToken(address receiver_,uint256 amount_) public isAdmin{

        v3Token.safeTransfer(receiver_,amount_);
    }
    
    function amountOfTokenCanWithdraw(address addr_) public view returns (uint256) {

        return map_userTokens[addr_];
    }
    
    function transferETH(address payable receiver_) public payable isAdmin{

        receiver_.transfer(msg.value);
    }
    
    function balanceOfETH() public view returns (uint256){

       return address(this).balance;
    }
    
    
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view override returns (uint8) {

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