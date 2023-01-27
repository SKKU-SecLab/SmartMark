




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



pragma solidity  ^0.6.2;

library SafeMathUint {

  function toInt256Safe(uint256 a) internal pure returns (int256) {

    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}


pragma solidity ^0.6.2;

library SafeMathInt {

  function mul(int256 a, int256 b) internal pure returns (int256) {

    require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));

    int256 c = a * b;
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {

    require(!(a == - 2**255 && b == -1) && (b > 0));

    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {

    require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));

    return a - b;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {

    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function toUint256Safe(int256 a) internal pure returns (uint256) {

    require(a >= 0);
    return uint256(a);
  }
}





pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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




pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

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

contract Ownable is Context {
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
}


pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;







contract NewHonestTreeGame  is ERC20, ReentrancyGuard, Ownable{
    
    using SafeMath for uint256;
	using SafeMathUint for uint256;
	using SafeMathInt for int256;
	
	uint256 constant internal pointsMultiplier = 2**128;
	uint256 internal pointsPerShare;
	mapping(address => int256) private pointsCorrection;

    uint32 public sum_players;
    uint32 public sum_paid_players; //Playes who their fee has been distributed (not first child, for example, not ambassador)
    uint32 public sum_premium_players;
    
    uint256 public distributed_passive_rewards;
    
    mapping(address => uint32) public first_num; // Numer of children in the first down level for a given player
    mapping(address => uint32) public second_num; // Numer of children in the first down level for a given player
    mapping(address => uint32) public third_num; // Numer of children in the first down level for a given player
    mapping(address => uint32) public lost_pm; //Number of children lost for not being premium yet :O for a given player
    mapping(address => uint32) public id; // The id of the player
    mapping(address => address) public parent; // The parent of a given player
    mapping(address => bool) public is_premium; // Is the player Premium?
    mapping(address => string[]) private my_aliases;
    mapping(address => uint32) public first_num_dummy;
    mapping(address => uint256) public premium_rewards; 
    
    
    mapping(address => uint256) private withdrawnActive; //Active Income Already Withdrawn
	mapping(address => uint256) private withdrawnPassive;// Passive Income Already Withdrawn
    
    
    mapping(uint => address) private ids; // For default referals links
    mapping(string => address) private aliases; // For customized referals links
    
    uint32 private DAY_IN_SECONDS;
    uint32 public ambassadors;
    uint32 public free_premium;

    uint256 public last_withdraw_date;
    
    uint256 public current_pool;
    uint256 public current_bounty;
    address private root_node;
    address public marketing_add;
    address public pool_contest_add;
    
    constructor(address _root_node) ERC20("Honest Tree Token", "HTT") public{

        DAY_IN_SECONDS=86400;
        root_node=_root_node;
        parent[_root_node]=_root_node;
        is_premium[_root_node]=true;
        ids[0]=_root_node;
        sum_players=1;
        free_premium=1;
        ambassadors=1;
        
        
        makeChildAndPremium(address(0x6eD1D033DA42915c71ed15C017De01A85871e08B),0);
        makeChildAndPremium(address(0xBF58963A18F72A543297Db986f46F2812174912D),0);
        makeChildAndPremium(address(0xA5AE4546BbE1Acb7D8BD705701BFcd6863Aa8960),0);
        makeChildAndPremium(address(0x9dd57A187E14d721A577557eA887B5BD866D6F15),0);
        makeChildAndPremium(address(0xB381d36b010ce051b787d534314a523e0E8e34b4),0);
        makeChildAndPremium(address(0x2910e50149D12cC6Cf43997710d1E6aee774935C),0);
        makeChildAndPremium(address(0x5E2De5c56C55D78CE6F165dD8a073DE773bE5911),0);
        makeChildAndPremium(address(0xA2307ecE34057c1534fE08773Fe47ffec03eDa9C),5);
        makeChildAndPremium(address(0xa2c76ea5052fa30Aaf48842B58228e62B3648D14),0);
        makeChildAndPremium(address(0x4c3ACaaCebd8518b993Dfce93D0C6A1bE54FF080),5);
        makeChildAndPremium(address(0xCd93F61b9360aDF6d603002E1f5D951edde03300),6);
        makeChildAndPremium(address(0x3d03F8Ec826df6cEf898AdD75E0bba67737C2375),0);
        makeChildAndPremium(address(0x8B66f7E62646dD934Cc1E249178eF3f24bCeD70F),0);
        makeChildAndPremium(address(0x801a8B12c6A6bd62DAd7f2a8B3D8496C8D0857aF),0);
        makeChildAndPremium(address(0x93A42C361d206597D87c7907522A8478FDd49149),2);
        makeChildAndPremium(address(0xC8Ba2DB40C74883e7a81a529ea0CE304e61b1bC9),15);
        makeChildAndPremium(address(0x859719a70f7c97AF39f5b522446fccA77E5c3f90),4);
        makeChildAndPremium(address(0x9B91Ba5906ADc511a9449bab9a06ACb5036d6dD6),6);
        makeChildAndPremium(address(0xA96d9EdC30d6d028599154618ce46aeDD9Ebe455),5); //Fastfurious
        makeChildAndPremium(address(0x1Ed445e7e3fEF20c8AE673C559c2672B28bbc158),2); 
        makeChildAndPremium(address(0xE30CD951E03eac1c5Bc4FB7c1AcB1baE5D09270B),2); 
        makeChildAndPremium(address(0xD5b0a304e6a0a74A3Eb6dAfc6c6c19044f9D1203),0);
        makeChildAndPremium(address(0xB4527d7d6E433A6c4EA6C93c4a4A997F9bfD9df2),2); 
        makeChildAndPremium(address(0xA4F264e466754fa99198034Ed257C939d0264965),5); //Fastfurious
        makeChildAndPremium(address(0xd98aDeaF9b197bDFA36F6B427c21d24dd1bB538a),2); 
        
        makeTeamName(address(0x3d03F8Ec826df6cEf898AdD75E0bba67737C2375),'HonestTree');
        makeTeamName(address(0xD5b0a304e6a0a74A3Eb6dAfc6c6c19044f9D1203),'GoldTree');
        makeTeamName(address(0x2910e50149D12cC6Cf43997710d1E6aee774935C),'unlimited');
        makeTeamName(address(0xB381d36b010ce051b787d534314a523e0E8e34b4),'Fastfurious');
        
        marketing_add=address(0x418B94436d773DFC3e17157484553a6546205013);
        pool_contest_add=address(0xc4c90cA6aeAcf6c879c25443a6468C786A0C364e);
    }
    
    modifier correctFee() {require(msg.value >= 40 finney ,'Please send at leat 0.4 ETH'); _; }
    modifier newPlayer() {require(!isAddressAlreadyPlayer(msg.sender),'You aready exist'); _; }
    function isAddressAlreadyPlayer(address _address) public view returns (bool){
        return !(parent[_address]==address(0x0)); 
    }
    
    
    function participateWithID(uint _parent_id) correctFee newPlayer public payable{
        if (_parent_id < sum_players){participate(ids[_parent_id]);} //int comparison is more gass efficient
        else{participate(root_node);}
    }
    
    function participateWithAlias(string memory _parent_alias) correctFee newPlayer public payable{
        if (!(aliases[_parent_alias]==address(0x0))){participate(aliases[_parent_alias]);}
        else{participate(root_node);}
        
    }
    
    
    function participate(address _parent) private {
        ids[sum_players]=msg.sender; // id -> address
        id[msg.sender]=sum_players; // address -> id
        parent[msg.sender]=_parent; // what is my parent?
        sum_players+=1;
        if ((first_num[_parent]+first_num_dummy[_parent])==0){
            first_num[_parent]+=1;
            _mint(_parent,1000* 10**18); // Your first children is in chage to mint your tokens for Passive Fund Distribution
        }
        else{
            sum_paid_players+=1;
            first_num[_parent]+=1;
            second_num[parent[_parent]]+=1;
            address third_parent=parent[parent[_parent]];
             if (is_premium[third_parent]) {third_num[third_parent]+=1;} 
             else {
                 third_num[root_node]+=1;
                 lost_pm[third_parent]+=1;} // We register how many third level children you have lost for not being premium
         }
     }
     
     function totalPassiveIncomeOfTheTree() public view returns(uint256) {
    		return (uint256(sum_paid_players)*8 finney); // ambassadors did not pay fee, so we take them out for the calculation
    }
    
    function withdrawablePassiveIncomeOfTheTree() public view returns(uint256) {
		return totalPassiveIncomeOfTheTree().sub(distributed_passive_rewards);
	}
     function distributePassiveIncome() public nonReentrant {
         uint256 _amount = withdrawablePassiveIncomeOfTheTree();
         distributed_passive_rewards = distributed_passive_rewards.add(_amount);
         _distributeFunds(_amount); // See ERC2222 function down.
         emit PassiveIncomeDistributed(_amount);
     }
     
     event PassiveIncomeDistributed(uint256 _amount);


    
	
     
    function totalActiveIncomeOf(address _player) public view returns (uint256){
        if (first_num[_player]==0){
            return 0;
        }
        else if (first_num_dummy[_player]>0){
            return ( uint256(first_num[_player])*16 finney +
                    uint256(second_num[_player])*10 finney +
                    uint256(third_num[_player])*6 finney +
                    uint256(premium_rewards[_player]));    
        }
        else {
        return ((40 finney) + //first children
                uint256((first_num[_player]-1))*16 finney +
                uint256(second_num[_player])*10 finney +
                uint256(third_num[_player])*6 finney +
                uint256(premium_rewards[_player]));
        }
    }
    
    function withdrawableActiveIncomeOf(address _player) public view returns (uint256){
        return totalActiveIncomeOf(_player).sub(withdrawnActive[_player]);
    }
    
	function totalPassiveIncomeOf(address _player) public view returns(uint256) {
		return pointsPerShare.mul(balanceOf(_player)).toInt256Safe()
			.add(pointsCorrection[_player]).toUint256Safe() / pointsMultiplier;
	}
    
    function withdrawablePassiveIncomeOf(address _player) public view returns(uint256) {
		return totalPassiveIncomeOf(_player).sub(withdrawnPassive[_player]);
	}
    
    
    
     
     function withdrawPlayer() nonReentrant public {
        require(last_withdraw_date<now); // Reentrancy Guard
        last_withdraw_date=now;
        uint256 _active = withdrawableActiveIncomeOf(msg.sender);
        uint256 _passive = withdrawablePassiveIncomeOf(msg.sender);
        require((_active+_passive)>0, 'You have nothing to Withdraw!');
        
        withdrawnActive[msg.sender]  = withdrawnActive[msg.sender].add(_active);
        withdrawnPassive[msg.sender] = withdrawnPassive[msg.sender].add(_passive);
        
        (bool success, ) = msg.sender.call{value: (_active+_passive)}("");
        require(success, "Transfer failed.");
        
        emit FundsWithdrawn(msg.sender, _active, _passive);
    }
    
    event FundsWithdrawn(address _player, uint256 activeIncomeWithdrawn, uint256 passiveIncomeWithdrawn);
    
    
    function becomePremium() public payable {
        require(msg.value >= 500 finney ,'Please send at least 0.5 ETH');
        is_premium[msg.sender]=true;
        sum_premium_players+=1;
        emit NewPremiumPlayer(msg.sender, parent[msg.sender]);
        
        
        address _parent = parent[msg.sender];
        if(is_premium[_parent]){premium_rewards[_parent]+= 125 finney;} 
        else{premium_rewards[root_node]+=125 finney;}
        
        _parent = parent[_parent]; //Parent of my parent
        if(is_premium[_parent]){premium_rewards[_parent]+= 50 finney;} // 10%
        else{premium_rewards[root_node]+=50 finney;}
        
        current_pool+= 125 finney;
        current_bounty+= 200 finney;
    }
    event NewPremiumPlayer(address _player, address _parent);
    
    function givePremium(address _player) public onlyOwner {
        is_premium[_player]=true;
        free_premium+=1;
    }
    
    
    
    function airDrop(address account, uint256 value) public onlyOwner {
	    _mint(account, value);
	}
	
    function isTeamNameAvailable(string memory _new_team_name) public view returns (bool){
        return (aliases[_new_team_name]==address(0x0));
    }
    
    function sumbitNewTeamName(string memory _new_team_name) public {
        require(!(parent[msg.sender]==address(0x0)),'You are not participant yet');
        require(isTeamNameAvailable(_new_team_name), "Alias not available!" );
        require(my_aliases[msg.sender].length<5,"You have already created your 5 alias!");
        my_aliases[msg.sender].push(_new_team_name);
        aliases[_new_team_name]=msg.sender;
    }
    
    fallback() external payable {
        if(msg.value>= (40 finney) ){participate(root_node);}
    }
    receive() external payable {
        if(msg.value>=(40 finney)){
            participate(root_node);
        }
    }
    
    
    function getTotalNumberOfChildrenOf(address _player) public view returns(uint32){
        return  first_num[_player]+second_num[_player]+third_num[_player]+first_num_dummy[_player];
    }
    
    function getTotalWithdrawnOf(address _player) public view returns(uint256){
        return  withdrawnActive[_player] + withdrawnPassive[_player];
    }
    
    
    function getTotalWithdrawableOf(address _player) public view returns(uint256){
        return  withdrawableActiveIncomeOf(_player) + withdrawablePassiveIncomeOf(_player);
    }
    
    function getPremiumEarningsOf(address _player) public view returns(uint256){
        return  premium_rewards[_player] + (uint256(third_num[_player])*6 finney);
    }
    
    function getPlayerAliases(address _player) public view returns(string[] memory){
        return  my_aliases[_player];
    }
    
    function getContractTotalInvestment() public view returns(uint256){
        return uint256(sum_players-ambassadors)*40 finney + uint256(sum_premium_players)*500 finney;
    }
    
    function withdrawMarketing() public onlyOwner {
        uint256 _value = current_bounty;
        current_bounty = 0 ;
        (bool success, ) = marketing_add.call{value: _value}("");
        require(success, "Transfer failed.");
    }
    
    function withdrawPool() public onlyOwner {
        uint256 _value = current_pool;
        current_pool = 0 ;
        (bool success, ) = pool_contest_add.call{value: _value}("");
        require(success, "Transfer failed.");
    }
    
    
    function closeGame () public onlyOwner{
        require(now>last_withdraw_date);
        require((now-last_withdraw_date)>180*DAY_IN_SECONDS);
        (bool success, ) = root_node.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
        emit GameIsClosed();
    }
    
    event GameIsClosed();
    
    
    function giveAmbassador(address _player) public onlyOwner{
        ids[sum_players]=_player;
        id[_player]=sum_players;
        parent[_player]=root_node;
        sum_players+=1;
        ambassadors+=1;
     }
     
     
     
     
     function makeChildAndPremium(address _player, uint32 _parentID) internal {
        ids[sum_players]=_player;
        id[_player]=sum_players;
        parent[_player]=ids[_parentID];
        sum_players+=1;
        ambassadors+=1;
        is_premium[_player]=true;
        free_premium+=1;
        first_num_dummy[ids[_parentID]]+=1;
     }
     
     
     function makeTeamName(address _player, string memory _new_team_name) internal {
        my_aliases[_player].push(_new_team_name);
        aliases[_new_team_name]=_player;
     }
     
     
     
    
     


	function distributeFunds() external payable returns(bool) {
	    require(msg.value > 0, 'No value in message');
	    _distributeFunds(msg.value);
		emit FundsDistributed(msg.sender, msg.value);
        return true;
	}
	event FundsDistributed(address _sender, uint256 _fundsDistributed);
	
	
	function _distributeFunds(uint256 value) internal {
		require(totalSupply() > 0, "Token._distributeFunds: SUPPLY_IS_ZERO");
		if (value > 0) {
			pointsPerShare = pointsPerShare.add(
				value.mul(pointsMultiplier) / totalSupply()
			);
		}
	}


	function _transfer(address from, address to, uint256 value) internal override {
		super._transfer(from, to, value);
		int256 _magCorrection = pointsPerShare.mul(value).toInt256Safe();
		pointsCorrection[from] = pointsCorrection[from].add(_magCorrection);
		pointsCorrection[to] = pointsCorrection[to].sub(_magCorrection);
	}

	function _mint(address account, uint256 value) internal override {
		super._mint(account, value);

		pointsCorrection[account] = pointsCorrection[account]
			.sub( (pointsPerShare.mul(value)).toInt256Safe() );
	}
	
	
	function _burn(address account, uint256 value) internal override {
		super._burn(account, value);

		pointsCorrection[account] = pointsCorrection[account]
			.add( (pointsPerShare.mul(value)).toInt256Safe() );
	}
    



}