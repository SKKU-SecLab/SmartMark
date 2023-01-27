



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;




contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}



pragma solidity ^0.8.9;


contract ERC20POC is ERC20 {
  uint256 constant INIT_SUPPLY_POC = 1000000000;  // 1,000,000,000
    
  address _owner;
  uint256 _locked_POC_total;
  uint256 _fee_rate;
  uint256 _submit_daily_limit_total;
  uint256 _submit_daily_limit_personal;
  
  struct bridge_staff {
    address user;
    uint256 quota;
  }
  bridge_staff[] private arr_staff;
  
  enum Submit_state {submit, cancel, complete}
  struct pegin_data {
    uint256 reg_date;
    bytes32 id;
    address user;
    uint256 amount;
    uint256 fee;
    Submit_state state;
  }
  mapping (bytes32 => pegin_data) private arr_pegin_submit;
  mapping (uint256 => bytes32) private arr_pegin_submit_key;
  uint256 arr_pegin_submit_key_start = 1;
  uint256 arr_pegin_submit_key_last = 0;
  
  enum Reserve_state {reserve, cancel, complete}
  struct pegout_data {
    uint256 reg_date;
    bytes32 id;
    address user;
    uint256 amount;
	address staff;
    Reserve_state state;
  }
  mapping (bytes32 => pegout_data) private arr_pegout_reserve;  
  mapping (uint256 => bytes32) private arr_pegout_reserve_key;
  uint256 arr_pegout_reserve_key_start = 1;
  uint256 arr_pegout_reserve_key_last = 0;
  
  constructor(uint256 fee_rate, uint256 locking_POC, address new_staff, uint256 new_staff_locked_POC,
                uint256 new_submit_daily_limit_total, uint256 new_submit_daily_limit_personal) ERC20("PocketArena", "POC") {
    _owner = msg.sender;
    _mint(_owner, (INIT_SUPPLY_POC * (10 ** uint256(decimals()))));
    _locked_POC_total = locking_POC;
    staff_add(new_staff, new_staff_locked_POC);
    _fee_rate_set(fee_rate);
    _submit_daily_limit_total = new_submit_daily_limit_total;
    _submit_daily_limit_personal = new_submit_daily_limit_personal;
  }
  
  modifier onlyOwner() {
    require(msg.sender == _owner, "only owner is possible");
    _;
  }
  modifier onlyStaff() {
    (bool is_staff, uint256 quota) = staff_check(msg.sender);
    require(is_staff, "only staff is possible");
    _;
  }
  

  
  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    if (msg.sender == _owner) {
      require(balanceOf(_owner) - (_locked_POC_total - staff_quota_total()) >= amount, "sendable POC is not enough");
    }
    else {
      (bool is_staff, ) = staff_check(msg.sender);
      if (is_staff) {
        require(recipient == _owner, "staff can transfer POC to the owner only");
      }
      else {
        (is_staff, ) = staff_check(recipient);
        require(!is_staff, "you can't transfer POC to the staff");
      }
    }
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  
  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    if (sender == _owner) {
      require(balanceOf(_owner) - (_locked_POC_total - staff_quota_total()) >= amount, "sendable POC is not enough");
    }
    else {
      (bool is_staff, uint256 quota) = staff_check(msg.sender);
      if (is_staff) {
        require(quota >= amount, "staff can transferFrom POC within quota");
      }
    }
    _transfer(sender, recipient, amount);
    uint256 currentAllowance = allowance(sender, _msgSender());
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
      _approve(sender, _msgSender(), currentAllowance - amount);
    }
    return true;
  }
  
  
  
  function staff_list() onlyOwner external view returns (bridge_staff[] memory) {
    return arr_staff;
  }
  
  function staff_add(address new_staff, uint256 new_staff_locked_POC) onlyOwner public returns (bool) {
    require(arr_staff.length < 5, "it allows max 5 staffs only");
    require(new_staff != _owner, "owner can't be staff");
    (bool is_staff, ) = staff_check(new_staff);
    require(!is_staff, "it's already added as staff");
    transfer(new_staff, new_staff_locked_POC);
    arr_staff.push(bridge_staff(new_staff, new_staff_locked_POC));
    return true;
  }
     
  event evt_staff_del(bool result);
  function staff_del() onlyStaff external {
    uint256 del_index = arr_staff.length + 1;
    for (uint256 i=0; i<arr_staff.length; i++) {
      if (arr_staff[i].user == msg.sender) {
        transfer(_owner, balanceOf(msg.sender));
        delete arr_staff[i];
        del_index = i;
        break;
      }
    }
    if (del_index >= (arr_staff.length + 1)) {
      emit evt_staff_del(false);
    }
    else {
      for (uint256 i=del_index; i<arr_staff.length-1; i++){
        arr_staff[i] = arr_staff[i+1];
      }
      arr_staff.pop();
      emit evt_staff_del(true);
    }
  }
   
  function staff_check(address user) public view returns (bool, uint256) {
    bool is_staff = false;
    uint256 quota = 0;
    for (uint256 i=0; i<arr_staff.length; i++) {
      if (arr_staff[i].user == user) {
        is_staff = true;
        quota = arr_staff[i].quota;
        break;
      }
    }
    return (is_staff, quota);
  }
  
  event evt_staff_quota_add(bool result);
  function staff_quota_add(address staff, uint256 increased) onlyOwner external {
    (bool is_staff, ) = staff_check(staff);
    require(is_staff, "you can add quota for existed staff only");
    require(_locked_POC_total - staff_quota_total() > increased, "you can add within your locked_POC");
    for (uint256 i=0; i<arr_staff.length; i++) {
      if (arr_staff[i].user == staff) {
        _transfer(msg.sender, staff, increased);
        arr_staff[i].quota += increased;
        break;
      }
    }
    emit evt_staff_quota_add(true);
  }
  
  event evt_staff_quota_minus(bool result);
  function staff_quota_minus(uint256 decreased) onlyStaff external {
    (, uint256 quota) = staff_check(msg.sender);
    require(quota >= decreased, "you can minus within your locked_POC");
    for (uint256 i=0; i<arr_staff.length; i++) {
      if (arr_staff[i].user == msg.sender) {
        transfer(_owner, decreased);
        arr_staff[i].quota -= decreased;
        break;
      }
    }
    emit evt_staff_quota_minus(true);
  }
  
  function staff_quota_total() onlyOwner public view returns (uint256) {
    uint256 total = 0;
    for (uint256 i=0; i<arr_staff.length; i++) {
      total += arr_staff[i].quota;  
    }
    return total;
  }

  
  
  function _fee_rate_get() onlyOwner external view returns (uint256) {
    return _fee_rate;
  }
  
  event evt_fee_rate_set(uint256 _fee_rate);
  function _fee_rate_set(uint256 new_fee_rate) onlyOwner public {
    require(new_fee_rate <= 10000 * 100, "rate should be 1000000 or less");
    _fee_rate = new_fee_rate;
    emit evt_fee_rate_set(_fee_rate);
  }
  
  function fee_get(uint256 amount) public view returns (uint256) {
    return amount * _fee_rate / 10000 / 100;
  }
  
  
  
  function locked_POC_total() external view returns (uint256) {
    return _locked_POC_total;
  }
  
  event evt_locked_POC_total_add(uint256 _locked_POC_total);
  function locked_POC_total_add(uint256 amount) onlyOwner external {
    require((balanceOf(_owner) - _locked_POC_total) >= amount, "lockable POC is not enough");
    _locked_POC_total += amount;
    emit evt_locked_POC_total_add(_locked_POC_total);
  }
  
  event evt_locked_POC_total_minus(uint256 _locked_POC_total);
  function locked_POC_total_minus(uint256 amount) onlyOwner external {
    require((_locked_POC_total - staff_quota_total()) >= amount, "lockable POC is not enough");
    _locked_POC_total -= amount;
    emit evt_locked_POC_total_minus(_locked_POC_total);
  }
  
  
   
  function _submit_daily_limit_total_get() onlyOwner external view returns (uint256) {
    return _submit_daily_limit_total;
  }
  
  event evt_submit_daily_limit_total_set(uint256 _submit_daily_limit_total);
  function _submit_daily_limit_total_set(uint256 new_submit_daily_limit_total) onlyOwner external {
    _submit_daily_limit_total = new_submit_daily_limit_total;
    emit evt_submit_daily_limit_total_set(_submit_daily_limit_total);
  }
  
  function _submit_daily_limit_personal_get() onlyOwner external view returns (uint256) {
    return _submit_daily_limit_personal;
  }
  
  event evt_submit_daily_limit_personal_set(uint256 _submit_daily_limit_personal);
  function _submit_daily_limit_personal_set(uint256 new_submit_daily_limit_personal) onlyOwner external {
    _submit_daily_limit_personal = new_submit_daily_limit_personal;
    emit evt_submit_daily_limit_personal_set(_submit_daily_limit_personal);
  }
  

  function arr_pegin_submit_key_last_get() onlyOwner external view returns (uint256) {
    return arr_pegin_submit_key_last;
  }  
  
  function arr_pegin_submit_key_start_get() onlyOwner external view returns (uint256) {
    return arr_pegin_submit_key_start;
  }
  
  event evt_arr_pegin_submit_key_start_set(uint256 arr_pegin_submit_key_start);
  function arr_pegin_submit_key_start_set(uint256 new_arr_pegin_submit_key_start) onlyOwner external {
    arr_pegin_submit_key_start = new_arr_pegin_submit_key_start;
    emit evt_arr_pegin_submit_key_start_set(arr_pegin_submit_key_start);
  }
  
  function arr_pegout_reserve_key_last_get() onlyOwner external view returns (uint256) {
    return arr_pegout_reserve_key_last;
  }
  
  function arr_pegout_reserve_key_start_get() onlyOwner external view returns (uint256) {
    return arr_pegout_reserve_key_start;
  }
  event evt_arr_pegout_reserve_key_start_set(uint256 arr_pegout_reserve_ey_start);
  function arr_pegout_reserve_key_start_set(uint256 new_arr_pegout_reserve_key_start) onlyOwner external {
    arr_pegout_reserve_key_start = new_arr_pegout_reserve_key_start;
    emit evt_arr_pegout_reserve_key_start_set(arr_pegout_reserve_key_start);
  }
  
  
  
  event evt_pegin_submit(pegin_data temp);
  function pegin_submit(uint256 amount) external {
    uint256 calc_fee = fee_get(amount);
    require(balanceOf(msg.sender) >= (amount + calc_fee), "your balance is not enough");
    uint256 daily_total = 0;
    uint256 daily_personal = 0;
    for (uint256 i=arr_pegin_submit_key_last; i>=arr_pegin_submit_key_start; i--) {
      if ((block.timestamp - arr_pegin_submit[arr_pegin_submit_key[i]].reg_date) < 86400) {
        daily_total += 1;
        require(daily_total < _submit_daily_limit_total, "we dont't get the submit anymore today");
        if (arr_pegin_submit[arr_pegin_submit_key[i]].user == msg.sender) {
          daily_personal += 1;
          require(daily_personal < _submit_daily_limit_personal, "you can't submit anymore today");
        }
      }
      else {
        break;
      }
    }
    transfer(_owner, (amount + calc_fee));
    _locked_POC_total += (amount + calc_fee);
    bytes32 temp_key = keccak256(abi.encodePacked(block.timestamp, msg.sender));
    pegin_data memory temp = pegin_data(block.timestamp, temp_key, msg.sender, amount, calc_fee, Submit_state.submit);
    arr_pegin_submit[temp_key] = temp;
    arr_pegin_submit_key_last += 1;
    arr_pegin_submit_key[arr_pegin_submit_key_last] = temp_key;
    emit evt_pegin_submit(temp);
  }
    
  function pegin_submit_list(bytes32 id) external view returns (pegin_data memory) {
      return arr_pegin_submit[id];
  }  
  
  function pegin_submit_list(uint256 count_per_page, uint256 current_page) external view returns (pegin_data[] memory) {
    uint256 new_arr_pegin_submit_key_last;
    uint256 new_arr_pegin_submit_key_start;
    if (current_page == 0) { 
      current_page = 1;
    }
    if (current_page == 1) {
      new_arr_pegin_submit_key_last = arr_pegin_submit_key_last;
    }
    else
    {
      uint256 key_position = count_per_page * (current_page - 1);
      if (arr_pegin_submit_key_last <= key_position) {
        new_arr_pegin_submit_key_last = 0;
      }
      else {
        new_arr_pegin_submit_key_last = arr_pegin_submit_key_last - key_position;
      }
    }
    if (new_arr_pegin_submit_key_last < count_per_page) {
      new_arr_pegin_submit_key_start = arr_pegin_submit_key_start;
    }
    else {
      if ( new_arr_pegin_submit_key_last < (arr_pegin_submit_key_start + count_per_page) ) {
        new_arr_pegin_submit_key_start = arr_pegin_submit_key_start;
      }
      else {
        new_arr_pegin_submit_key_start = new_arr_pegin_submit_key_last - count_per_page + 1;
      }
    }
    uint256 temp_size = 0;
    if (new_arr_pegin_submit_key_start < (new_arr_pegin_submit_key_last + 1) ) {
      temp_size = new_arr_pegin_submit_key_last - new_arr_pegin_submit_key_start + 1;
    }
    pegin_data[] memory arr_temp = new pegin_data[](temp_size);
    uint256 index = 0;
    for (uint256 i=new_arr_pegin_submit_key_last; i>=new_arr_pegin_submit_key_start; i--) {
      arr_temp[index] = arr_pegin_submit[arr_pegin_submit_key[i]];
      index += 1;
    }
    return arr_temp;
  }
  
  event evt_pegin_submit_complete(bool result);
  function pegin_submit_complete(bytes32[] memory complete_id) onlyStaff external {
    uint256 len = complete_id.length;
    for (uint256 i=0; i<len; i++) {
      if (arr_pegin_submit[complete_id[i]].reg_date > 0) {
        arr_pegin_submit[complete_id[i]].state = Submit_state.complete;
      }
    }
    emit evt_pegin_submit_complete(true);
  }
  
  event evt_pegin_submit_cancel(bool result);
  function pegin_submit_cancel(bytes32[] memory del_id) onlyStaff external {
    uint256 len = del_id.length;
    for (uint256 i=0; i<len; i++) {
      if (arr_pegin_submit[del_id[i]].reg_date > 0) {
        if (arr_pegin_submit[del_id[i]].state == Submit_state.submit) {
          transfer(arr_pegin_submit[del_id[i]].user, (arr_pegin_submit[del_id[i]].amount + arr_pegin_submit[del_id[i]].fee));
          _locked_POC_total -= (arr_pegin_submit[del_id[i]].amount + arr_pegin_submit[del_id[i]].fee);
          arr_pegin_submit[del_id[i]].state = Submit_state.cancel;
        }
      }
    }
    emit evt_pegin_submit_cancel(false);
  }
  
  
  
  event evt_pegout_reserve(bool result);
  function pegout_reserve(uint256[] memory reg_date, bytes32[] memory id, address[] memory user, uint256[] memory amount) onlyStaff external {
    uint256 len = reg_date.length;
    require(len == id.length, "2nd parameter is missed");
    require(len == user.length, "3rd parameter is missed");
    require(len == amount.length, "4th parameter is missed");
    (, uint256 quota) = staff_check(msg.sender);
    uint256 total_amount = 0;
    for (uint256 i=0; i<len; i++) {
      require(arr_pegout_reserve[id[i]].reg_date == 0, "there is an already reserved data");
      total_amount += amount[i];
    }
    require(quota >= total_amount, "your unlocked_POC balance is not enough");
    for (uint256 i=0; i<len; i++) {
      increaseAllowance(user[i], amount[i]);
      arr_pegout_reserve[id[i]] = pegout_data(reg_date[i], id[i], user[i], amount[i], msg.sender, Reserve_state.reserve);
      arr_pegout_reserve_key_last += 1;
      arr_pegout_reserve_key[arr_pegout_reserve_key_last] = id[i];
    }
    emit evt_pegout_reserve(true);
  }
  
  function pegout_reserve_list(bytes32 id) external view returns (pegout_data memory) {
      return arr_pegout_reserve[id];
  }
    
  function pegout_reserve_list(uint256 count_per_page, uint256 current_page) external view returns (pegout_data[] memory) {
    uint256 new_arr_pegout_reserve_key_last;
    uint256 new_arr_pegout_reserve_key_start;
    if (current_page == 0) { 
      current_page = 1;
    }
    if (current_page == 1) {
      new_arr_pegout_reserve_key_last = arr_pegout_reserve_key_last;
    }
    else
    {
      uint256 key_position = count_per_page * (current_page - 1);
      if (arr_pegout_reserve_key_last <= key_position) {
        new_arr_pegout_reserve_key_last = 0;
      }
      else {
        new_arr_pegout_reserve_key_last = arr_pegout_reserve_key_last - key_position;
      }
    }
    if (new_arr_pegout_reserve_key_last < count_per_page) {
      new_arr_pegout_reserve_key_start = arr_pegout_reserve_key_start;
    }
    else {
      if ( new_arr_pegout_reserve_key_last < (arr_pegout_reserve_key_start + count_per_page) ) {
        new_arr_pegout_reserve_key_start = arr_pegout_reserve_key_start;
      }
      else {
        new_arr_pegout_reserve_key_start = new_arr_pegout_reserve_key_last - count_per_page + 1;
      }
    }
    uint256 temp_size = 0;
    if (new_arr_pegout_reserve_key_start < (new_arr_pegout_reserve_key_last + 1) ) {
      temp_size = new_arr_pegout_reserve_key_last - new_arr_pegout_reserve_key_start + 1;
    }
    pegout_data[] memory arr_temp = new pegout_data[](temp_size);
    uint256 index = 0;
    for (uint256 i=new_arr_pegout_reserve_key_last; i>=new_arr_pegout_reserve_key_start; i--) {
      arr_temp[index] = arr_pegout_reserve[arr_pegout_reserve_key[i]];
      index += 1;
    }
    return arr_temp;
  }
  
  event evt_pegout_run(bytes32[] arr_temp);
  function pegout_run(bytes32[] memory id) external {
    uint256 len = id.length;
    bytes32[] memory arr_temp = new bytes32[](len);
    uint256 temp_index = 0;
    for (uint256 i=0; i<len; i++) {
      if (arr_pegout_reserve[id[i]].reg_date > 0) {
        if ( (arr_pegout_reserve[id[i]].user == msg.sender) && (arr_pegout_reserve[id[i]].state == Reserve_state.reserve) ) {
          bool result = transferFrom(arr_pegout_reserve[id[i]].staff, msg.sender, arr_pegout_reserve[id[i]].amount);
          if (result) {
            arr_pegout_reserve[id[i]].state = Reserve_state.complete;
            _locked_POC_total -= arr_pegout_reserve[id[i]].amount;
			arr_temp[temp_index] = id[i];
			temp_index += 1;
          }
        
        }
      }
    }
    emit evt_pegout_run(arr_temp);
  }
  
  event evt_pegout_reserve_cancel(bool result);
  function pegout_reserve_cancel(bytes32[] memory del_id) onlyStaff external {
    uint256 len = del_id.length;
    for (uint256 i=0; i<len; i++) {
      if (arr_pegout_reserve[del_id[i]].reg_date > 0) {
        if (arr_pegout_reserve[del_id[i]].staff == msg.sender) {
          decreaseAllowance(arr_pegout_reserve[del_id[i]].user, arr_pegout_reserve[del_id[i]].amount);
          arr_pegout_reserve[del_id[i]].state = Reserve_state.cancel;
        }
      }
    }
    emit evt_pegout_reserve_cancel(true);
  } 
}