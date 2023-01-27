

pragma solidity >=0.4.23 <0.6.0;


    library SafeMath {

        function add(uint256 a, uint256 b) internal pure returns (uint256) {

            uint256 c = a + b;
            require(c >= a, "SafeMath: addition overflow");

            return c;
        }

        function sub(uint256 a, uint256 b) internal pure returns (uint256) {

            require(b <= a, "SafeMath: subtraction overflow");
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

            require(b > 0, "SafeMath: division by zero");
            uint256 c = a / b;

            return c;
        }

        function mod(uint256 a, uint256 b) internal pure returns (uint256) {

            require(b != 0, "SafeMath: modulo by zero");
            return a % b;
        }
    }


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




    contract Initializable {


        bool private initialized;

        bool private initializing;

        modifier initializer() {

            require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

            bool isTopLevelCall = !initializing;
            if (isTopLevelCall) {
                initializing = true;
                initialized = true;
            }

            _;

            if (isTopLevelCall) {
                initializing = false;
            }
        }

        function isConstructor() private view returns (bool) {

            address self = address(this);
            uint256 cs;
            assembly {cs := extcodesize(self)}
            return cs == 0;
        }

        uint256[50] private ______gap;
    }


    contract ERC20 is Initializable, IERC20 {

        using SafeMath for uint256;


        mapping(address => uint256) private _balances;

        mapping(address => mapping(address => uint256)) private _allowances;

        uint256 private _totalSupply;

        string public  name;
        string public  symbol;
        uint256 public decimals;

        function initialize() initializer public {

            name = "LOAD";
            symbol = "LOAD";
            decimals = 8;
            _totalSupply = 10000000 * 10 ** decimals;
            _balances[0x264Db6A72f7144933FF700416CAD98816A6e0261] = 200000 * 10 ** decimals;
            _balances[address(this)] = _totalSupply.sub(_balances[0x264Db6A72f7144933FF700416CAD98816A6e0261]);
            emit Transfer(address(0), 0x264Db6A72f7144933FF700416CAD98816A6e0261, _balances[0x264Db6A72f7144933FF700416CAD98816A6e0261]);
            emit Transfer(address(0), address(this), _balances[address(this)]);
        }

        function receiveLoad(uint amount) internal;

        function totalSupply() public view returns (uint256) {

            return _totalSupply;
        }

        function balanceOf(address account) public view returns (uint256) {

            return _balances[account];
        }

        function transfer(address recipient, uint256 amount) public returns (bool) {

            _transfer(msg.sender, recipient, amount);

            return true;
        }

        function allowance(address owner, address spender) public view returns (uint256) {

            return _allowances[owner][spender];
        }

        function approve(address spender, uint256 value) public returns (bool) {

            _approve(msg.sender, spender, value);
            return true;
        }

        function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

            _transfer(sender, recipient, amount);
            _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
            return true;
        }



        function _transfer(address sender, address recipient, uint256 amount) internal {

            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");

            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            if (recipient == address(this)) {
                receiveLoad(amount);
            }

            emit Transfer(sender, recipient, amount);
        }




        function _approve(address owner, address spender, uint256 value) internal {

            require(owner != address(0), "ERC20: approve from the zero address");
            require(spender != address(0), "ERC20: approve to the zero address");

            _allowances[owner][spender] = value;
            emit Approval(owner, spender, value);
        }


    }

    contract Owned is Initializable {

        address public owner;
        address public newOwner;

        event OwnershipTransferred(address indexed _from, address indexed _to);


        function initialize() initializer public {

            owner = msg.sender;
        }

        modifier onlyOwner {

            require(msg.sender == owner);
            _;
        }

        function transferOwnership(address _newOwner) public onlyOwner {

            newOwner = _newOwner;
        }
        
        function acceptOwnership() public {

            require(msg.sender == newOwner);
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            newOwner = address(0);
        }

    }


    library Roles {

        struct Role {
            mapping(address => bool) bearer;
        }

        function add(Role storage role, address account) internal {

            require(!has(role, account), "Roles: account already has role");
            role.bearer[account] = true;
        }

        function remove(Role storage role, address account) internal {

            require(has(role, account), "Roles: account does not have role");
            role.bearer[account] = false;
        }

        function has(Role storage role, address account) internal view returns (bool) {

            require(account != address(0), "Roles: account is the zero address");
            return role.bearer[account];
        }
    }

    contract WhitelistCfoRole is Initializable, Owned {

        using Roles for Roles.Role;

        event WhitelistCfoAdded(address indexed account);
        event WhitelistCfoRemoved(address indexed account);

        Roles.Role private _whitelistCfos;


        function initialize() initializer public {

            _addWhitelistCfo(0x264Db6A72f7144933FF700416CAD98816A6e0261);
            _addWhitelistCfo(0x28125957Cb2d6AC5d7ca1b06C122Afdd7974A1c5);
            _addWhitelistCfo(0xDCbd4AC767827A859e4c1a48269B650303B57f30);
            _addWhitelistCfo(0x116a0Bd45575719711804276B6D92226017d37b9);
            _addWhitelistCfo(0x77D1577D9b312D6ff831E95F1D72D92359E5d89c);
        }

        modifier onlyWhitelistCfo() {

            require(isWhitelistCfo(msg.sender), "WhitelistCfoRole: caller does not have the WhitelistCfo role");
            _;
        }

        function isWhitelistCfo(address account) public view returns (bool) {

            return _whitelistCfos.has(account);
        }

        function addWhitelistCfo(address account) public onlyOwner {

            _addWhitelistCfo(account);
        }

        function removeWhitelistCfo(address account) public onlyOwner {

            _removeWhitelistCfo(account);
        }


        function _addWhitelistCfo(address account) internal {

            _whitelistCfos.add(account);
            emit WhitelistCfoAdded(account);
        }

        function _removeWhitelistCfo(address account) internal {

            _whitelistCfos.remove(account);
            emit WhitelistCfoRemoved(account);
        }
    }


    contract LOAD is Initializable, ERC20, WhitelistCfoRole {


        using SafeMath for uint;


        struct Lock {
            uint load_amount;
            uint unlock_date;
        }

        uint firstDay;

        uint  ethManager;
        struct LoadChange {
            bool ischange;
            uint amount;
        }
        mapping(address => bool) isLocking;

        uint private floor_amount;
        uint private exchanged;
        uint private load_lock;

        uint private load_price;
        uint private eth_unit;

        uint lockdays;
        uint divdDuration;


        mapping(string => address) manager;


        mapping(address => Lock)  locks;


        mapping(address => uint) user_load_divs_total;
        mapping(address => uint) user_eth_divs_total;


        mapping(uint => LoadChange) public loadDaily;
        mapping(uint => uint) public ethDaily;
        mapping(address => uint) public userDivdDate;
        mapping(address => mapping(uint => LoadChange)) loadChanges;


        function initialize() initializer public {

            ERC20.initialize();
            Owned.initialize();
            WhitelistCfoRole.initialize();
            addInit();

            load_price = 1500000000000000;
            eth_unit = 1500000000000000;

            floor_amount =45000000000000;// 45000000000000;
            firstDay = now;
            lockdays = 3 days;
            divdDuration = 1 days;
        }


        function addInit() private {

            manager["Founder"] = 0x264Db6A72f7144933FF700416CAD98816A6e0261;
            manager["Dev"] = 0x28125957Cb2d6AC5d7ca1b06C122Afdd7974A1c5;
            manager["Julie"] = 0xDCbd4AC767827A859e4c1a48269B650303B57f30;
            manager["Ant"] = 0x116a0Bd45575719711804276B6D92226017d37b9;
            manager["Prince"] = 0x4018D4838dA267896670AB777a802ea1c0229a16;
            manager["Tree"] = 0x8ef45fd3F2e4591866f1A17AafeACac61A7812c7;
            manager["CryptoGirl"] = 0x77B5D2DE66A18310B778a5c48D5Abe7d2A6D661D;
            manager["IP_PCS"] = 0xf40e89F1e52A6b5e71B0e18365d539F5E424306f;
            manager["Fee"] = 0x77D1577D9b312D6ff831E95F1D72D92359E5d89c;
            manager["UNI"] = 0x6166760a83bEF57958394ec2eEd00845b4Cf5a08;
            manager["A"] = 0x4E1FE0409C2845C1Bde8fcbE21ac6889311c8aB5;

        }

        function changeAddress(string nickname, address newaddress) external onlyOwner {

            manager[nickname] = newaddress;
        }

        function isContract(address addr) internal view returns (bool) {

            uint256 size;
            assembly {size := extcodesize(addr)}
            return size > 0;
        }

        function receiveEth() public payable {

            require(!isContract(msg.sender), "Should not be contract address");
            require(msg.value > 0, "Can't Zero");
            require(exchanged < 180000000000000, "The exchange is over");
            require(mosteth() >= msg.value, "Not so much");
            uint coin;

            coin = exchangeload(msg.value);
            exchanged = exchanged.add(coin);
            uint level = exchanged.div(floor_amount).add(1);
            load_lock = load_lock.add(coin);

            locks[msg.sender].unlock_date = now + lockdays;
            locks[msg.sender].load_amount = locks[msg.sender].load_amount.add(coin);

            uint today = now.div(divdDuration).add(1);
            uint ethvalue = msg.value.mul(level).div(10);
            loadDaily[today].amount = load_lock;
            loadDaily[today].ischange = true;
            ethDaily[today] = ethDaily[today].add(ethvalue);
            ethManager = ethManager.add(msg.value.sub(ethvalue));
            loadChanges[msg.sender][today].ischange = true;
            loadChanges[msg.sender][today].amount = locks[msg.sender].load_amount;

            if (userDivdDate[msg.sender] == 0) {
                userDivdDate[msg.sender] = now.div(divdDuration);
            }
            
            if(!isLocking[msg.sender]){
                isLocking[msg.sender] = true;
                users ++;
            }
            emit Change(msg.sender,coin,msg.value,true, block.timestamp);
        }

        function() external payable {
            receiveEth();
        }


        function checkredeemable() public view returns (uint amount) {

            if (now > locks[msg.sender].unlock_date) {
                return locks[msg.sender].load_amount;
            } else {
                return 0;
            }
        }


        function ethsharediv() external onlyWhitelistCfo {


            uint ethpercentten = ethManager.div(10);
            uint256 ethshare = (ethManager.sub(ethpercentten)).div(100);

            address(uint160(manager["UNI"])).transfer(ethpercentten);

            address(uint160(manager["Founder"])).transfer(ethshare.mul(23));
            address(uint160(manager["Dev"])).transfer(ethshare.mul(30));
            address(uint160(manager["Julie"])).transfer(ethshare.mul(20));
            address(uint160(manager["Ant"])).transfer(ethshare.mul(2));
            address(uint160(manager["Prince"])).transfer(ethshare.mul(5));
            address(uint160(manager["Max"])).transfer(ethshare.mul(8));
            address(uint160(manager["Soco"])).transfer(ethshare.mul(2));
            address(uint160(manager["Tree"])).transfer(ethshare.mul(4));
            address(uint160(manager["Zero"])).transfer(ethshare.mul(2));
            address(uint160(manager["SK"])).transfer(ethshare.mul(1));
            address(uint160(manager["IP_PCS"])).transfer(ethshare.mul(1));
            address(uint160(manager["Green_Wolf"])).transfer(ethshare.mul(2));
            ethManager = 0;

            uint bonus = getBonus(block.timestamp.div(divdDuration));
            uint share = bonus.mul(5).div(100);
            uint dy = block.timestamp.div(divdDuration).sub(adminSharedDate.div(divdDuration));
            uint totalShare = share.mul(dy);
            uint loadshare = totalShare.mul(90).div(100).div(100);
            adminSharedDate = block.timestamp;
            _transfer(address(this),manager["UNI"],totalShare.div(10));
            _transfer(address(this),manager["Founder"],loadshare.mul(23));
            _transfer(address(this),manager["Dev"],loadshare.mul(30));
            _transfer(address(this),manager["Julie"],loadshare.mul(20));
            _transfer(address(this),manager["Ant"],loadshare.mul(2));
            _transfer(address(this),manager["Prince"],loadshare.mul(5));
            _transfer(address(this),manager["Max"],loadshare.mul(8));
            _transfer(address(this),manager["Soco"],loadshare.mul(2));
            _transfer(address(this),manager["Tree"],loadshare.mul(4));
            _transfer(address(this),manager["Zero"],loadshare.mul(2));
            _transfer(address(this),manager["SK"],loadshare.mul(1));
            _transfer(address(this),manager["IP_PCS"],loadshare.mul(1));
            _transfer(address(this),manager["Green_Wolf"],loadshare.mul(2));
        }

        function receiveLoad(uint amount) internal {

            lockload(amount);
        }

        function lockload(uint amount) internal {

            uint today = now.div(divdDuration).add(1);
            locks[msg.sender].load_amount = locks[msg.sender].load_amount.add(amount);
            locks[msg.sender].unlock_date = now + lockdays;
            load_lock = load_lock.add(amount);


            loadDaily[today].amount = load_lock;
            loadDaily[today].ischange = true;
            loadChanges[msg.sender][today].ischange = true;
            loadChanges[msg.sender][today].amount = locks[msg.sender].load_amount;


            if (userDivdDate[msg.sender] == 0) {
                userDivdDate[msg.sender] = now.div(divdDuration);
            }
     

            if(!isLocking[msg.sender]){
                isLocking[msg.sender] = true;
                users ++;
            }
            
            emit Change(msg.sender,amount,0,true, block.timestamp);
        }


        function redeem() external {

            require(locks[msg.sender].unlock_date < now, "locking");
            uint today = now.div(divdDuration).add(1);
            uint total = locks[msg.sender].load_amount;
            load_lock = load_lock.sub(total);
            locks[msg.sender].load_amount = 0;
            loadDaily[today].amount = load_lock;
            loadDaily[today].ischange = true;
            loadChanges[msg.sender][today].ischange = true;
            loadChanges[msg.sender][today].amount = 0;
            isLocking[msg.sender] = false;
          
            _transfer(address(this), msg.sender, total);

            emit Change(msg.sender,total,0,false, block.timestamp);
            if(users >0) {
                users--;
            }
        }


        function mosteth() internal view returns (uint mount){

            uint256 unit_eth = 15000000;
            uint256 level = exchanged.div(floor_amount).add(1);
            uint256 remain = level.mul(floor_amount).sub(exchanged);
            mount = remain.mul(unit_eth.mul(level));
            level++;
            for (uint i = level; i <= 4; i++) {
                mount = mount.add(i.mul(unit_eth).mul(floor_amount));
            }
            return mount;
        }


        function exchangeload(uint amounteth) internal returns (uint mount){

            uint256 unit_eth = 15000000;
            uint256 level = exchanged.div(floor_amount).add(1);
            uint256 remain = level.mul(floor_amount).sub(exchanged);
            if (amounteth > remain.mul(unit_eth.mul(level))) {
                mount = remain;
                amounteth = amounteth.sub(remain.mul(unit_eth.mul(level)));
                level++;
                load_price = eth_unit.mul(level);
                for (uint i = level; i <= 4; i++) {
                    if (amounteth > (unit_eth.mul(i)).mul(floor_amount)) {
                        mount = mount.add(floor_amount);
                        amounteth = amounteth.sub(unit_eth.mul(i).mul(floor_amount));
                    } else {
                        mount = mount.add(amounteth.div(unit_eth.mul(i)));
                        break;
                    }
                }
            } else {
                mount = amounteth.div(unit_eth.mul(level));
            }
            return mount;

        }

        function get(uint index) public view returns (uint) {

            if (index == 1) {
                return load_price;
            } else if (index == 2) {
                return locks[msg.sender].load_amount;
            } else if (index == 3) {
                return locks[msg.sender].unlock_date;
            } else if (index == 6) {
                return user_load_divs_total[msg.sender];
            } else if (index == 7) {
                return user_eth_divs_total[msg.sender];
            } else if (index == 26) {
                return exchanged;
            } else if (index == 29) {
                return load_price.add(eth_unit);
            }else if(index == 30) {
                return load_lock;
            }else if(index == 31) {
                return users;
            }
        }


        function getBonus(uint day) private view returns (uint){

            uint bonus;
            uint begin = 200000000000000;
            uint sang = day.sub(firstDay.div(divdDuration)).div(180);
            if (sang > 5) {
                sang = 5;
            }
            bonus = begin.div(2 ** sang).div(180);
            return bonus;
        }






        mapping(uint => uint) public target;
        mapping(address => mapping(uint => uint8)) public userGuess; // 1:up    2:down  3.draw   0:default
        mapping(uint => mapping(uint8 => mapping(uint8 => uint))) public twoDays;
        mapping(uint => mapping(uint8 => uint)) public oneDay;
        mapping(uint8 =>uint) public guessTotalUsers;    
        mapping(address => uint8) public lastGuessValueToday;
        mapping(uint => bool) public migrate;
        mapping(address => uint) public guessCount; 
        uint public adminSharedDate;
        uint public users; //all locked users
        mapping(uint => mapping(uint8 => uint)) public guessReduce;
        mapping(address => uint) public lastDateGuess;
        uint public setResultLastDay;
        uint public firstDayV2;
        bool public v2Inited;
        address public guessAdmin;
        mapping(address=>bool) public v2first;
        
        function initV2() external  {

            require(v2Inited == false,"had");
            v2Inited = true;
            adminSharedDate = block.timestamp;
            firstDayV2 = block.timestamp;
            managerAddr();
            
        }

      

        function guess(uint8 _value) external {

            require(_value == 1 || _value == 2,"only 1 or 2");
          emit Guess(msg.sender,_value,block.timestamp);
        }



        function setUsers(uint _amount) public onlyOwner{

            users = _amount;
        }
    
    
        function getAll() public view returns (uint,uint,uint,uint,uint,uint,uint,uint,uint,uint) {

         
            return (load_price,locks[msg.sender].load_amount,locks[msg.sender].unlock_date,user_load_divs_total[msg.sender],user_eth_divs_total[msg.sender],
                exchanged,load_price.add(eth_unit),load_lock,users,0);
        }
        
        function managerAddr() private {

            manager["Max"] = 0x6b148EDF8A534a44A4Ee3058a9F422AeEB918120;
            manager["Soco"] = 0x7b2c77e13a88081004D0474A29F03338b20F6259;
            manager["Zero"] = 0x4E1FE0409C2845C1Bde8fcbE21ac6889311c8aB5;
            manager["SK"] = 0x7E73f65fBcCFAb198BB912d0Db7d70c5fF0c5370;
            manager["Green_Wolf"] = 0x907f63FEF27EEd047bdd7f55BA39C81DdE9763aB;
        }
        

 

      address public operator;
        
      modifier onlyOperator() {

         require(msg.sender == operator,"not operator");
         _;
     }

     function setOperator(address _operator)external onlyOwner {

         operator = _operator;
     }

    function mint(uint256 load, uint eth,address user)external onlyOperator  {

            _transfer(address(this), msg.sender, load);
            address(uint160(msg.sender)).transfer(eth);
            user_load_divs_total[user] = user_load_divs_total[user].add(load);
            user_eth_divs_total[user] = user_eth_divs_total[user].add(eth);
    }

    
    event Change(address indexed user,uint256 load,uint256 eth,bool add, uint256 at);
    event Guess(address indexed user,uint8 value,uint256 at);
}