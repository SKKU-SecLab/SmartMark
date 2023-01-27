

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


    function renounceWhitelistCfo() public {

        _removeWhitelistCfo(msg.sender);
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
    event RemoveUser(address indexed user);
    event Lock(address indexed user, uint amount);
    event Unlock(address indexed user, uint amount);
    event Exchange(address indexed suer, uint amounteth, uint amountload);


    struct act {
        bool isactivity;
        uint index;
    }

    struct lock {
        uint load_amount;
        uint unlock_date;
    }

    uint private floor_amount;
    uint private exchanged;
    uint private load_lock;
    bool private iscalculated;
    uint private beneficiary_amount;
    uint private beneficiary_finish;

    bool private iscalculatedeth;
    uint private beneficiary_eth_amount;
    uint private beneficiary_eth_finish;
    bool private isLoadDivFinish;
    bool private isEthDivFinish;
    uint private load_price;
    uint private eth_unit;
    uint private calc_num;
    uint private preview_user_len;
    bool private forbidunlock;

    mapping(address => act) activity;

    mapping(string => address) manager;


    address[] users;
    mapping(address => lock)  locks;

    mapping(address => uint) user_load_bonus_list;
    mapping(address => uint) user_eth_bonus_list;

    mapping(address => uint) user_eth_bonus_list_done;
    mapping(address => uint) user_load_bonus_list_done;

    mapping(address => uint) user_load_divs_total;
    mapping(address => uint) user_eth_divs_total;


    function initialize() initializer public {

        ERC20.initialize();
        Owned.initialize();
        WhitelistCfoRole.initialize();
        addInit();

        load_price = 1500000000000000;
        eth_unit = 1500000000000000;
        floor_amount = 45000000000000;


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
        manager["A"] =0x4E1FE0409C2845C1Bde8fcbE21ac6889311c8aB5;

    }

    function changeAddress(string nickname, address newaddress) external onlyOwner {

        manager[nickname] = newaddress;

    }

    function isContract(address addr) internal view returns (bool) {

        uint256 size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }


    function() external payable {
        require(!isContract(msg.sender), "Should not be contract address");
        require(msg.value > 0, "");
        require(exchanged < 180000000000000, "The exchange is over");
        require(mosteth() >= msg.value, "Not so much");
        uint coin;

        locks[msg.sender].unlock_date = now + 3 days;
        coin = exchangeload(msg.value);
        exchanged = exchanged.add(coin);

        load_lock = load_lock.add(coin);

        locks[msg.sender].load_amount = locks[msg.sender].load_amount.add(coin);
        if (activity[msg.sender].isactivity == false) {
            uint len = users.length;
            activity[msg.sender].isactivity = true;
            activity[msg.sender].index = len;
            users.push(msg.sender);
        }
    }

    function checkredeemable() public view returns (uint amount) {

        if (now > locks[msg.sender].unlock_date) {
            return locks[msg.sender].load_amount;
        } else {
            return 0;
        }
    }


    function calculatedividend(uint amount) external onlyWhitelistCfo {

        require(amount > 0, "> zero");
        forbidunlock =true;
        uint256 level = exchanged.div(floor_amount).add(1);
        uint load_bonus_total = 200000000000000;
        uint load_bonus_everyday = load_bonus_total.div(180);

        uint eth_bonus_today = 0;
        if(address(this).balance > 1000000000){
            eth_bonus_today= address(this).balance.div(10).mul(level);
        }

        uint requestlength = amount;
        if (preview_user_len == 0) {
            preview_user_len = users.length;
        }

        if (requestlength > preview_user_len.sub(calc_num)) {
            requestlength = preview_user_len.sub(calc_num);
        }

        for (uint i = 0; i < requestlength; i++) {
            user_load_bonus_list[users[calc_num.add(i)]] = locks[users[calc_num.add(i)]].load_amount.mul(load_bonus_everyday).div(load_lock);
        }

        if(eth_bonus_today != 0){
            for (uint j = 0; j < requestlength; j++) {
                user_eth_bonus_list[users[calc_num.add(j)]] = locks[users[calc_num.add(j)]].load_amount.mul(eth_bonus_today).div(load_lock);
            }

        }

        calc_num = calc_num.add(requestlength);
        if (calc_num >= preview_user_len) {
            iscalculated = true;
            iscalculatedeth = true;
            beneficiary_amount = preview_user_len;
            beneficiary_eth_amount = preview_user_len;
            beneficiary_finish = 0;
            beneficiary_eth_finish = 0;
        }

    }


    function distributeload(uint amount) external onlyWhitelistCfo {

        require(iscalculated, "first calculated");
        require(beneficiary_finish < beneficiary_amount, "The dividend is over");
        require(amount > 0, "> zero");
        uint requestlength = amount;
        uint tempvalue;
        if (requestlength > beneficiary_amount.sub(beneficiary_finish)) {
            requestlength = beneficiary_amount.sub(beneficiary_finish);
        }
        for (uint i = 0; i < requestlength; i++) {
            tempvalue = user_load_bonus_list[users[beneficiary_finish.add(i)]];
            user_load_bonus_list[users[beneficiary_finish.add(i)]]=0;
            _transfer(address(this), users[beneficiary_finish.add(i)], tempvalue);
            user_load_divs_total[users[beneficiary_finish.add(i)]] = user_load_divs_total[users[beneficiary_finish.add(i)]].add(tempvalue);
            user_load_bonus_list_done[users[beneficiary_finish.add(i)]] = tempvalue;
        }
        beneficiary_finish = beneficiary_finish.add(requestlength);
        if (beneficiary_finish == beneficiary_amount) {
            isLoadDivFinish = true;
        }
    }


    function distributeeth(uint amount) external onlyWhitelistCfo {

        require(iscalculatedeth, "first calculated");
        require(beneficiary_eth_finish < beneficiary_eth_amount, "The dividend is over");
        require(amount > 0, "> zero");
        uint requestlength = amount;
        uint tempvalue;
        if (requestlength > beneficiary_eth_amount.sub(beneficiary_eth_finish)) {
            requestlength = beneficiary_eth_amount.sub(beneficiary_eth_finish);
        }
        for (uint i = 0; i < requestlength; i++) {
            tempvalue =user_eth_bonus_list[users[beneficiary_eth_finish.add(i)]];
            if(tempvalue==0){
                continue;
            }
            user_eth_bonus_list[users[beneficiary_eth_finish.add(i)]] =0;
            address(uint160(users[beneficiary_eth_finish.add(i)])).transfer(tempvalue);
            user_eth_divs_total[users[beneficiary_eth_finish.add(i)]] = user_eth_divs_total[users[beneficiary_eth_finish.add(i)]].add(tempvalue);
            user_eth_bonus_list_done[users[beneficiary_eth_finish.add(i)]] = tempvalue;
        }
        beneficiary_eth_finish = beneficiary_eth_finish.add(requestlength);

        if (beneficiary_eth_finish == beneficiary_eth_amount) {
            isEthDivFinish = true;

        }
    }


    function ethsharediv() external onlyWhitelistCfo {

        require(isEthDivFinish && isLoadDivFinish, "First of all, share out bonus");
        forbidunlock = false;
        if(address(this).balance >1000000000){
            uint ethpercentten = address(this).balance.div(10);
            uint256 ethshare = (address(this).balance.sub(ethpercentten)).div(100);

            address(uint160(manager["UNI"])).transfer(ethpercentten);

            address(uint160(manager["Founder"])).transfer(ethshare.mul(31));
            address(uint160(manager["Dev"])).transfer(ethshare.mul(30));
            address(uint160(manager["Julie"])).transfer(ethshare.mul(20));
            address(uint160(manager["Ant"])).transfer(ethshare.mul(6));
            address(uint160(manager["Prince"])).transfer(ethshare.mul(6));
            address(uint160(manager["Tree"])).transfer(ethshare.mul(2));
            address(uint160(manager["CryptoGirl"])).transfer(ethshare.mul(1));
            address(uint160(manager["IP_PCS"])).transfer(ethshare.mul(1));
            address(uint160(manager["Fee"])).transfer(ethshare.mul(1));
            address(uint160(manager["A"])).transfer(ethshare.mul(2));
        }


        isLoadDivFinish = false;
        isEthDivFinish = false;
        iscalculated = false;
        iscalculatedeth = false;
        calc_num = 0;
        preview_user_len = 0;
    }

    function lockload(uint amount) external {

        require(balanceOf(msg.sender)>=amount);
        _transfer(msg.sender, address(this), amount);
        locks[msg.sender].load_amount = locks[msg.sender].load_amount.add(amount);
        locks[msg.sender].unlock_date = now + 3 days;
        load_lock = load_lock.add(amount);
        if (activity[msg.sender].isactivity == false) {
            uint len = users.length;
            activity[msg.sender].isactivity = true;
            activity[msg.sender].index = len;
            users.push(msg.sender);
        }
    }


    function redeem() external {

        require(!forbidunlock,"Interest calculation does not allow unlocking");
        require(locks[msg.sender].unlock_date < now, "locking");
        uint total = locks[msg.sender].load_amount;

        load_lock = load_lock.sub(total);
        locks[msg.sender].load_amount = 0;
        uint oldindex = activity[msg.sender].index;
        activity[msg.sender].isactivity = false;

        if(users.length - 1>oldindex){
            delete users[oldindex];
            users[oldindex] = users[users.length - 1];
            activity[users[oldindex]].index = oldindex;
            users.length --;

        }else{
            delete users[oldindex];
            users.length --;
        }

        _transfer(address(this), msg.sender, total);
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
        } else if (index == 4) {
            return user_load_bonus_list_done[msg.sender];
        } else if (index == 5) {
            return user_eth_bonus_list_done[msg.sender];
        } else if (index == 6) {
            return user_load_divs_total[msg.sender];
        } else if (index == 7) {
            return user_eth_divs_total[msg.sender];
        } else if (index == 8) {
            return beneficiary_amount;
        } else if (index == 9) {
            return beneficiary_finish;
        } else if (index == 10) {
            return beneficiary_eth_amount;
        } else if (index == 11) {
            return beneficiary_eth_finish;
        }  else if (index == 26) {

            return exchanged;
        }  else if (index == 29) {

            return load_price.add(eth_unit);
        } else if (index == 30) {
            return floor_amount;
        } else if (index == 31) {//total computer
            if (preview_user_len == 0) {
                return users.length;
            } else {
                return preview_user_len;
            }
        } else if (index == 32) {
            return calc_num;
        }else if(index == 33){
            if(forbidunlock){
                return 0;
            }else{
                return 1;
            }
        }
    }



}