

pragma solidity >=0.8.7;

library SafeMath {


    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory  errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory  errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (bytes32 );

    function symbol() external pure returns (bytes32 );

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}



interface ERC20 {

    function totalSupply() external view returns (uint);

    function balanceOf(address tokenOwner) external view returns (uint balance);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

    function transfer(address to, uint tokens) external returns (bool success);

    function approve(address spender, uint tokens) external returns (bool success);

    function transferFrom(address from, address to, uint tokens) external returns (bool success);


    function symbol() external view returns (bytes32 );

    function name() external view returns (bytes32 );

    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


    interface IVC_Plugin {

        function exists() external view returns (bool success);      

        function svt_plugin_initialize() external view returns (bool, uint256[] memory, bytes32[] memory);

        function svt_method_call_id(uint256 mid) external returns (bool, bytes32 );  

        function svt_method_call_name(bytes32  mname) external returns (bool, bytes32 );  

  }


  interface IVC_Pair_Adding {

      function create_svt_pair_existing(uint256 orig_qty1, uint256 orig_qty2,  address to_bridge, address to_pair, uint256 qty_1, uint256 qty_2) external returns(bool);

      function create_svt_pair_from_eth_existing(uint256 orig_qty1, uint256 orig_qty2, address to_bridge, uint256 qty_1, uint256 qty_2) external returns(bool);

  }

contract Kaiba_IVC {


    using SafeMath for uint256;

    IVC_Pair_Adding pair_adder;
    bool create_svt_pair_existing_enabled;

    uint256 tax_multiplier = 995; //0.05%
    uint256 taxes_eth_total;
    mapping(address => uint256) taxes_token_total;
    mapping (uint256 => uint256) taxes_native_total;
    address kaiba_address = 0x8BB048845Ee0d75BE8e07954b2e1E5b51B64b442;
    address owner;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant ZERO = 0x000000000000000000000000000000000000dEaD;
    ERC20 kaiba = ERC20(kaiba_address);

    constructor () {
        is_team[msg.sender] = true;
        owner = msg.sender;
        is_locked[841] = true;
        SVT_address[0].deployed = true;
        SVT_address[0].tokenOwner = owner;
        SVT_address[0].totalSupply = 0;
        SVT_address[0].circulatingSupply = 0;
        SVT_address[0].fees.push(10000000000000000);
        SVT_address[0].name = "Kaiba Virtual ETH";
        SVT_address[0].ticker = "WETH";
        SVT_address[0].isBridged = true;
        SVT_address[0].original_token = WETH; 
        SVT_address[0].SVT_Liquidity_storage = 0;
        SVT_Liquidity_index[0].deployed = true;
        SVT_Liquidity_index[0].active = true;
        SVT_Liquidity_index[0].liq_mode = 4;
        SVT_Liquidity_index[0].token_1 = ERC20(SVT_address[0].original_token);
        SVT_Liquidity_index[0].SVT_token_id = 0;
    }


    mapping (address => bool) is_team;

    struct auth_control {
        mapping(address => bool) is_auth;
    }

    mapping(address => auth_control) bridge_is_auth;

    mapping(uint256 => bool) is_locked;

    bool internal locked;
    bool internal open_bridge;

    modifier safe() {

        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier Unlocked(uint256 name) {

        require(!is_locked[name]);
        _;
    }

    modifier onlyAuth(address to_bridge) {

        require(bridge_is_auth[msg.sender].is_auth[to_bridge] ||  msg.sender==owner || open_bridge, "Not authorized");
        _;
    }

    modifier onlyTeam {

        require(is_team[msg.sender]);
        _;
    }

    modifier onlyOwner {

        require(owner==msg.sender);
        _;
    }

    function acl_add_team(address addy) public onlyTeam {

        is_team[addy] = true;
    }

    function acl_remove_team(address addy) public onlyTeam {

        is_team[addy] = false;
    }

    function acl_locked_function(uint256 name, bool booly) public onlyTeam {

        is_locked[name] = booly;
    }

    function acl_open_bridge(bool booly) public onlyTeam {

        open_bridge = booly;
    }

    function acl_set_kaiba(address addy) public onlyTeam {

        kaiba_address = addy;
    }
    
    function acl_set_tax_multiplier(uint256 multiplier) public onlyTeam {

        tax_multiplier = multiplier;
    }


    struct SVTLiquidity {  // This struct defines the types of liquidity and the relative properties
        bool active;
        bool deployed;
        bool native_pair;
        ERC20 token_1; // Always the native or the paired
        ERC20 token_2; // Always the SVT token
        uint256 token_1_qty; 
        uint256 token_2_qty;
        uint256 SVT_token_id;
        uint256 liq_mode; // 1: Direct pair, 2: LP token (on token_1), 3: Synthetic, 4: WETH
        IUniswapV2Factory factory; // Needed in mode 2, 3
        IUniswapV2Pair pair; // Needed in mode 2, 3
    }

    mapping (uint256 => SVTLiquidity) SVT_Liquidity_index;
    uint256 svt_liquidity_last_id = 0;

    struct SVT { // This struct defines a typical SVT token
        bool deployed;
        address tokenOwner;
        uint256 totalSupply;
        uint256 circulatingSupply;
        mapping (address => uint256) balance;
        uint256[] fees;
        mapping(uint256 => uint256) fees_storage;
        bytes32 name;
        bytes32 ticker;
        bool isBridged;
        address original_token;
        uint256 SVT_Liquidity_storage;
    }

    mapping (uint256 => SVT) SVT_address;
    uint256 svt_last_id = 0;

    struct SVNFT { // And this one defines a NFT on IVC (aka SVNFT)
        uint256 totalSupply;
        uint256 circulatingSupply;
        mapping (address => uint256[]) owned_ids;
        mapping(uint256 => address) id_owner;
        uint256[] ids;
    }

    mapping (address => bool) imported;
    mapping (address => uint256) imported_id;

    uint256 IVC_native_decimals = 18;
    mapping (address => uint256) IVC_native_balance;
    uint256 IVC_native_balance_total;


    function get_svt_pools() external view returns (uint256) {

        return svt_last_id;
    }

    function get_svt_id(address addy) external  view returns(bool, uint256) {

        if(imported[addy]) {
            return (true, imported_id[addy]);
        } else {
            return (false, 0);
        }
    }


    function get_svt_liquidity(uint256 svt_id) external  view returns (bool, bool, address, address, uint256, uint256, uint256, address, address, bool) {

        require(SVT_address[svt_id].deployed, "SVT Token does not exist");
        uint256 liq_index = SVT_address[svt_id].SVT_Liquidity_storage;
        require(SVT_Liquidity_index[liq_index].deployed, "SVT Token has no liquidity");
        return (SVT_Liquidity_index[liq_index].active,
                SVT_Liquidity_index[liq_index].deployed,
                address(SVT_Liquidity_index[liq_index].token_1),
                address(SVT_Liquidity_index[liq_index].token_2),
                SVT_Liquidity_index[liq_index].token_1_qty,
                SVT_Liquidity_index[liq_index].token_2_qty,
                SVT_Liquidity_index[liq_index].liq_mode,
                address(SVT_Liquidity_index[liq_index].factory),
                address(SVT_Liquidity_index[liq_index].pair),
                SVT_Liquidity_index[liq_index].native_pair); 
    }



    function get_token_price(address pairAddress, uint amount) external  view returns(uint)
    {

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        address token1_frompair = pair.token1();
        ERC20 token1 = ERC20(token1_frompair);
        (uint Res0, uint Res1,) = pair.getReserves();

        uint res0 = Res0*(10**token1.decimals());
        return((amount*res0)/Res1); // return amount of token0 needed to buy token1
    }


    function get_svt_address_balance(address addy, uint256 svt_id) public  view returns(uint256) {

        require(SVT_address[svt_id].deployed, "This token does not exists");
        return SVT_address[svt_id].balance[addy];
    }

    function get_ivc_balance(address addy) external  view returns(uint256) {

        return(IVC_native_balance[addy]);
    }

    function get_ivc_stats() external  view returns(uint256) {

        return(IVC_native_balance_total);
    }


    function get_svt(uint256 addy) external  view returns (address, uint256, uint256, uint256[] memory, bytes32 , bytes32 ) {

        require(SVT_address[addy].deployed, "Token not deployed");
        address tokenOwner = SVT_address[addy].tokenOwner;
        uint256 supply = SVT_address[addy].totalSupply;
        uint256 circulatingSupply = SVT_address[addy].circulatingSupply;
        uint256[] memory fees = SVT_address[addy].fees;
        bytes32  name = SVT_address[addy].name;
        bytes32  ticker = SVT_address[addy].ticker;
        return (tokenOwner, supply, circulatingSupply, fees, name, ticker);

    }


    function get_svt_bridge_status(uint256 addy) external  view returns (bool, address) {

        return(_isBridged(addy), _originalToken(addy));
    }

    

    function get_svt_kveth_balance(address addy) external  view returns (uint256) {

        return(IVC_native_balance[addy]);
    }


    function operate_svt_to_native(uint256 svt_id, uint256 qty, address receiver, bool simulation) public 
        returns (uint256, uint256, uint256, uint256) {

        require(SVT_address[svt_id].deployed, "SVT token does not exist");
        uint256 liq_index = SVT_address[svt_id].SVT_Liquidity_storage;
        require(SVT_Liquidity_index[liq_index].active, "SVT liquidity does not exist");
        require(get_svt_address_balance(msg.sender, svt_id) >= qty, "Balance is too low");
        uint256 local_whole_tax = calculate_taxes(svt_id, qty);
        require(local_whole_tax<qty, "Taxes too high");
        qty -= local_whole_tax;
        uint256 to_withdraw_liq = SVT_Liquidity_index[liq_index].token_1_qty;
        uint256 to_deposit_liq = SVT_Liquidity_index[liq_index].token_2_qty;
        uint256 amount_out = operate_ivc_get_amount_out(qty, to_deposit_liq, to_withdraw_liq);
        if (!simulation) {
            SVT_Liquidity_index[liq_index].token_2_qty += amount_out;
            SVT_address[svt_id].balance[receiver] -= amount_out;
            SVT_Liquidity_index[liq_index].token_1_qty -= qty;
            IVC_native_balance[msg.sender] += qty;
            IVC_native_balance_total += qty;
        }
        return (amount_out,
                SVT_address[svt_id].balance[receiver],
                IVC_native_balance[msg.sender], svt_id);

    }
    
    function operate_native_to_svt(uint256 svt_id, address receiver, uint256 qty, bool simulation) public 
    returns (uint256, uint256, uint256, uint256){

        require(SVT_address[svt_id].deployed, "SVT token does not exist");
        uint256 liq_index = SVT_address[svt_id].SVT_Liquidity_storage;
        require(SVT_Liquidity_index[liq_index].active, "SVT liquidity does not exist");
        require(IVC_native_balance[msg.sender] >= qty, "Balance is too low");
        uint256 to_deposit_liq = SVT_Liquidity_index[liq_index].token_1_qty;
        uint256 to_withdraw_liq = SVT_Liquidity_index[liq_index].token_2_qty;
        uint256 amount_out = operate_ivc_get_amount_out(qty, to_deposit_liq, to_withdraw_liq);
        uint256 local_whole_tax = calculate_taxes(svt_id, amount_out);
        require(local_whole_tax<amount_out, "Taxes too high");
        amount_out -= local_whole_tax;
        if (!simulation) {
            SVT_Liquidity_index[liq_index].token_2_qty -= amount_out;
            SVT_address[svt_id].balance[receiver] += amount_out;
            SVT_Liquidity_index[liq_index].token_1_qty += amount_out;
            IVC_native_balance[msg.sender] -= qty;
            IVC_native_balance_total -= qty;
        }
        return (amount_out,
                SVT_address[svt_id].balance[receiver],
                IVC_native_balance[msg.sender],svt_id);
    }

    


    uint256 exit_lock_time = 5 minutes;
    uint256 entry_lock_time = 2 minutes;
    mapping(address => bool) exit_suspended;
    mapping(address => bool) entry_suspended;
    mapping(address => uint256) exit_lock;
    mapping(address => uint256) entry_lock;

    function entry_from_eth() public payable safe returns (uint256){

        require(msg.value >= 10000000000000000, "Unpayable");
        require(!entry_suspended[msg.sender], "Suspended");
        require(entry_lock[msg.sender] + entry_lock_time < block.timestamp, "Please wait");
        uint256 qty_to_credit = msg.value;
        SVT_address[0].balance[msg.sender] += taxes_include_fee(qty_to_credit);
        IVC_native_balance[msg.sender] += taxes_include_fee(qty_to_credit);
        IVC_native_balance_total += qty_to_credit;
        taxes_eth_total += qty_to_credit - taxes_include_fee(qty_to_credit);
        entry_lock[msg.sender] = block.timestamp;
        return qty_to_credit;
    }

    function exit_to_eth(uint256 qty, address recv) public safe returns (uint256) {

        require(address(this).balance > qty, "Unpayable: No liq?");
        require(IVC_native_balance[msg.sender] >= qty, "No KVETH");
        require(SVT_address[0].balance[msg.sender] >= qty, "No KVETH");
        require(!exit_suspended[msg.sender], "Suspended");
        require(!exit_suspended[recv], "Suspended");
        require(exit_lock[msg.sender] + exit_lock_time < block.timestamp, "Please wait");
        require(exit_lock[recv] + exit_lock_time < block.timestamp, "Please wait");
        exit_lock[msg.sender] = block.timestamp;
        IVC_native_balance[msg.sender] -= qty;
        IVC_native_balance_total -= taxes_include_fee(qty);
        SVT_address[0].balance[msg.sender] -= qty;
        payable(recv).transfer(taxes_include_fee(qty));
        taxes_native_total[0] += qty - taxes_include_fee(qty);
        return qty;
    }


    function exit_to_token(address token, uint256 qty) public safe {

        ERC20 from_token = ERC20(token);
        require(imported[token], "This token is not imported");
        uint256 unbridge_id = imported_id[token];
        require(SVT_address[unbridge_id].balance[msg.sender] >= qty, "You don't have enough tokens");
        require(from_token.balanceOf(address(this)) >= qty, "There aren't enough tokens");
        from_token.transfer(msg.sender, taxes_include_fee(qty));
        if (SVT_address[unbridge_id].circulatingSupply < 0) {
            SVT_address[unbridge_id].circulatingSupply = 0;
        }
        SVT_address[unbridge_id].balance[msg.sender] -= qty;
        taxes_native_total[unbridge_id] += qty - taxes_include_fee(qty);
    }


    function operate_transfer_svt(uint256 svt_id, address sender, address receiver, uint256 qty) public {

        require(SVT_address[svt_id].deployed, "This token does not exists");
        require(SVT_address[svt_id].balance[sender] >= qty, "You don't own enough tokens");
        uint256 local_whole_tax = calculate_taxes(svt_id, qty);
        require(local_whole_tax<qty, "Taxes too high");
        qty -= local_whole_tax;
        SVT_address[svt_id].balance[sender] -= taxes_include_fee(qty) ;
        delete sender;
        SVT_address[svt_id].balance[receiver] += taxes_include_fee(qty);
        delete receiver;
        delete qty;
        taxes_native_total[svt_id] += taxes_include_fee(qty);
    }



    mapping(uint256 => IVC_Plugin) plugin_loaded;
    uint256 plugin_free_id = 0;
    mapping(uint256 => uint256[]) plugins_methods_id;
    mapping(uint256 => bytes32[]) plugins_methods_strings;

    function pair_adder_implementation(bool booly, address addy) public onlyTeam {

        pair_adder = IVC_Pair_Adding(addy);
        create_svt_pair_existing_enabled = booly;
    }

    function add_svt_plugin(address plugin_address) public onlyTeam returns (uint256){

        plugin_loaded[plugin_free_id] = IVC_Plugin(plugin_address);
        plugin_free_id += 1;
        return (plugin_free_id -1);
    }


    function initialize_ivc_plugin(uint256 plugin_id) public view onlyTeam returns (bool, uint256[] memory, bytes32[] memory) {

        require(plugin_loaded[plugin_id].exists(), "Plugin not loaded or not existant");
        return plugin_loaded[plugin_id].svt_plugin_initialize();
    }



    function check_ivc_plugin_method_id(uint256 plugin, uint256 id) public view onlyTeam returns (bool) {

        require(plugin_loaded[plugin].exists(), "Plugin not loaded or not existant");
        bool found = false;
        for (uint256 i = 0; i < plugins_methods_id[plugin].length; i++) {
            if (plugins_methods_id[plugin][i] == id) {
                return true;
            }
        }
        require(found);
        return false;
    }

    function check_ivc_plugin_method_name(uint256 plugin, bytes32 name) public view onlyTeam returns (bool) {

        require(plugin_loaded[plugin].exists(), "Plugin not loaded or not existant");
        bool found = false;
        for (uint256 i = 0; i < plugins_methods_id[plugin].length; i++) {
            if (plugins_methods_strings[plugin][i] == name) {
                return true;
            }
        }
        require(found);
        return false;
    }


    function execute_ivc_plugin_method_id(uint256 plugin, uint256 id) public onlyTeam returns (bool, bytes32 ) {

        require(check_ivc_plugin_method_id(plugin, id), "Error in verifying method");
        return plugin_loaded[plugin].svt_method_call_id(id);
    }

    function execute_ivc_plugin_method_id(uint256 plugin, bytes32  name) public onlyTeam returns (bool, bytes32 ) {

        require(check_ivc_plugin_method_name(plugin, name), "Error in verifying method");
        return plugin_loaded[plugin].svt_method_call_name(name);
    }



    function taxes_include_fee(uint256 initial) private view returns (uint256) {

        return( (initial*tax_multiplier) / 1000 );
    }

    function calculate_taxes(uint256 svt_id, uint256 qty) private returns (uint256) {

        uint256 local_whole_tax = 0;
        for(uint i=0; i<SVT_address[svt_id].fees.length; i++) {
            SVT_address[svt_id].fees_storage[i] += (qty * SVT_address[svt_id].fees[i])/100;
            local_whole_tax += (qty * SVT_address[svt_id].fees[i])/100;
        }
        return local_whole_tax;
    }

    function operate_ivc_get_amount_out(uint256 to_deposit, uint256 to_deposit_liq, uint256 to_withdraw_liq) public pure returns (uint256 out_qty) {

        require(to_deposit > 0, 'KaibaSwap: INSUFFICIENT_INPUT_AMOUNT');
        require(to_deposit_liq > 0 && to_withdraw_liq > 0, 'KaibaSwap: INSUFFICIENT_LIQUIDITY');
        uint to_deposit_with_fee = to_deposit.mul(997);
        uint numerator = to_deposit_with_fee.mul(to_withdraw_liq);
        uint denominator = to_deposit_liq.mul(1000).add(to_deposit_with_fee);
        out_qty = numerator / denominator;
        return out_qty;
    }

    function authorize_on_token(address to_authorize, address to_bridge) public onlyTeam {

        bridge_is_auth[to_authorize].is_auth[to_bridge] = true;
    }


    function issue_native_svt(
        bytes32  name,
        bytes32  ticker,
        uint256 max_supply,
        uint256[] calldata fees) 
    public Unlocked(1553) safe {

        uint256 thisAddress = svt_last_id+1;
        SVT_address[thisAddress].deployed = true;
        SVT_address[thisAddress].circulatingSupply = max_supply;
        SVT_address[thisAddress].totalSupply = max_supply;
        SVT_address[thisAddress].fees = fees;
        SVT_address[thisAddress].name = name;
        SVT_address[thisAddress].ticker = ticker;
        SVT_address[thisAddress].isBridged = true;
        SVT_address[thisAddress].original_token = ZERO;
        SVT_address[thisAddress].balance[msg.sender] = taxes_include_fee(max_supply);
        SVT_address[thisAddress].SVT_Liquidity_storage = svt_liquidity_last_id + 1;
        svt_liquidity_last_id += 1;
        taxes_native_total[thisAddress] += max_supply - taxes_include_fee(max_supply);
    }

    function native_add_liq(uint256 svt_id, uint256 qty) payable public safe { 

        require(msg.value > 10000000000000000, "Too low");
        require(SVT_address[svt_id].deployed, "SVT does not exists");
        uint256 thisLiquidity = SVT_address[svt_id].SVT_Liquidity_storage;
        require(!SVT_Liquidity_index[thisLiquidity].active, "Pair is already alive");
        SVT_Liquidity_index[thisLiquidity].active = true;
        SVT_Liquidity_index[thisLiquidity].deployed = true;
        SVT_Liquidity_index[thisLiquidity].token_1 = ERC20(WETH);
        SVT_Liquidity_index[thisLiquidity].token_2 = ERC20(ZERO);
        SVT_Liquidity_index[thisLiquidity].token_1_qty += msg.value;
        SVT_Liquidity_index[thisLiquidity].token_2_qty += qty;
        SVT_Liquidity_index[thisLiquidity].SVT_token_id = svt_id;
        SVT_Liquidity_index[thisLiquidity].liq_mode = 1;
    }

    function get_taxes_for_address(uint256 token) public  view returns(uint256) {

        require(SVT_address[token].deployed, "Non existant");
        if (SVT_address[token].fees.length == 0) {
            return 0;
        } else {
            uint256 total_taxes;
            for (uint256 i = 0; i < SVT_address[token].fees.length; i++) {
                total_taxes += SVT_address[token].fees[i];
            }
            return total_taxes;
        }
    }


    function create_svt_pair(address to_bridge, address to_pair,  uint256 qty_1, uint256 qty_2) public Unlocked(841) safe onlyAuth(to_bridge) {

        ERC20 from_token = ERC20(to_bridge);
        ERC20 from_pair = ERC20(to_pair);
        delete to_bridge;
        delete to_pair;
        require(from_token.balanceOf(msg.sender) >= qty_1, "You don't have enough tokens (1)");
        require(from_pair.balanceOf(msg.sender) >= qty_2, "You don't have enough tokens (2)");
        from_token.transferFrom(msg.sender, address(this), qty_1);
        from_pair.transferFrom(msg.sender, address(this), qty_2);
        uint256 thisAddress;
        uint256 thisLiquidity;
        if (imported[to_bridge]) {
            require(create_svt_pair_existing_enabled, "Not yet enabled (pair adding)");
            bool success;
            thisAddress = imported_id[to_bridge];
            thisLiquidity = SVT_address[thisAddress].SVT_Liquidity_storage;
            require(to_pair==address(SVT_Liquidity_index[thisLiquidity].token_2), "Wrong pair");
            success = pair_adder.create_svt_pair_existing(SVT_Liquidity_index[thisLiquidity].token_1_qty, SVT_Liquidity_index[thisLiquidity].token_2_qty, to_bridge, to_pair, qty_1, qty_2);
            require(success, "Failed pairing");
            delete success;
        } else {
            svt_last_id +=1;
            svt_liquidity_last_id += 1;
            thisAddress = svt_last_id;
            thisLiquidity = svt_liquidity_last_id;
        }

        if (to_pair == WETH) { 
            SVT_Liquidity_index[thisLiquidity].native_pair = true;
        }
        SVT_Liquidity_index[thisLiquidity].active = true;
        SVT_Liquidity_index[thisLiquidity].deployed = true;
        SVT_Liquidity_index[thisLiquidity].token_1 = ERC20(to_bridge);
        SVT_Liquidity_index[thisLiquidity].token_2 = ERC20(to_pair);
        delete to_pair;
        SVT_Liquidity_index[thisLiquidity].token_1_qty += taxes_include_fee(qty_1);
        SVT_Liquidity_index[thisLiquidity].token_2_qty += taxes_include_fee(qty_2);
        SVT_Liquidity_index[thisLiquidity].SVT_token_id = thisAddress;
        SVT_Liquidity_index[thisLiquidity].liq_mode = 1;

        SVT_address[thisAddress].deployed = true;
        SVT_address[thisAddress].circulatingSupply += qty_1;
        SVT_address[thisAddress].totalSupply = from_token.totalSupply();
        SVT_address[thisAddress].name = from_token.name();
        SVT_address[thisAddress].ticker = from_token.symbol();
        SVT_address[thisAddress].isBridged = true;
        SVT_address[thisAddress].original_token = to_bridge;
        SVT_address[thisAddress].SVT_Liquidity_storage = thisLiquidity;
        taxes_token_total[to_bridge] += ( qty_1 - taxes_include_fee(qty_1) );
        taxes_token_total[to_pair] += ( qty_2 - taxes_include_fee(qty_2) );

    }

    function create_svt_pair_from_eth(address to_bridge, uint256 qty_1) public safe payable onlyAuth(to_bridge) {

        ERC20 from_token = ERC20(to_bridge);
        ERC20 from_pair = ERC20(WETH);
        require(from_token.balanceOf(msg.sender) >= qty_1, "You don't have enough tokens (1)");
        from_token.transferFrom(msg.sender, address(this), qty_1);
        uint256 thisAddress;
        uint256 thisLiquidity;
        if (imported[to_bridge]) {
            require(create_svt_pair_existing_enabled, "Not yet enabled (pair adding)");
            bool success;
            thisAddress = imported_id[to_bridge];
            thisLiquidity = SVT_address[thisAddress].SVT_Liquidity_storage;
            require(WETH==address(SVT_Liquidity_index[thisLiquidity].token_2), "Wrong pair");
            success = pair_adder.create_svt_pair_from_eth_existing(SVT_Liquidity_index[thisLiquidity].token_1_qty, SVT_Liquidity_index[thisLiquidity].token_2_qty, to_bridge, qty_1, msg.value);
            require(success, "Failed pairing");
            delete success;
        } else {
            svt_last_id +=1;
            svt_liquidity_last_id += 1;
            thisAddress = svt_last_id;
            thisLiquidity = svt_liquidity_last_id;
        }

        SVT_Liquidity_index[thisLiquidity].native_pair = true;
        SVT_Liquidity_index[thisLiquidity].active = true;
        SVT_Liquidity_index[thisLiquidity].deployed = true;
        SVT_Liquidity_index[thisLiquidity].token_1 = from_token;
        SVT_Liquidity_index[thisLiquidity].token_2 = from_pair;
        SVT_Liquidity_index[thisLiquidity].token_1_qty += taxes_include_fee(qty_1);
        SVT_Liquidity_index[thisLiquidity].token_2_qty += taxes_include_fee(msg.value);
        SVT_Liquidity_index[thisLiquidity].SVT_token_id = thisAddress;
        SVT_Liquidity_index[thisLiquidity].liq_mode = 1;

        SVT_address[thisAddress].deployed = true;
        SVT_address[thisAddress].circulatingSupply += qty_1;
        SVT_address[thisAddress].totalSupply = from_token.totalSupply();
        SVT_address[thisAddress].name = from_token.name();
        SVT_address[thisAddress].ticker = from_token.symbol();
        SVT_address[thisAddress].isBridged = true;
        SVT_address[thisAddress].original_token = to_bridge;
        SVT_address[thisAddress].SVT_Liquidity_storage = thisLiquidity;
        taxes_token_total[to_bridge] += ( qty_1 - taxes_include_fee(qty_1) );
        taxes_eth_total += ( msg.value - taxes_include_fee(msg.value) );

    }

    function collect_taxes_eth() public onlyTeam {

        if (address(this).balance < taxes_eth_total) {
            payable(owner).transfer(address(this).balance);
        } else {
            payable(owner).transfer(taxes_eth_total);
        }
        taxes_eth_total = 0;
    }

    function collect_taxes_token(address addy) public onlyTeam {

        ERC20 token_erc = ERC20(addy);
        if (token_erc.balanceOf(address(this)) < taxes_token_total[addy]) {
            token_erc.transfer(owner, token_erc.balanceOf(address(this)));
        } else {
            token_erc.transfer(owner, taxes_token_total[addy]);
        }
        taxes_token_total[addy] = 0;
    }

    function collect_taxes_native(uint256 svt_id) public onlyTeam {

        require(SVT_address[svt_id].deployed, "Not a valid token");
        SVT_address[svt_id].balance[owner] += taxes_native_total[svt_id];
        taxes_native_total[svt_id] = 0;
    }


    function _isBridged(uint256 addy) private view returns (bool) {

        return SVT_address[addy].isBridged;
    }

    function _originalToken(uint256 addy) private view returns (address) {

        return SVT_address[addy].original_token;
    }

}