pragma solidity 0.5.10;

library LibInteger
{    

    function mul(uint a, uint b) internal pure returns (uint)
    {

        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint)
    {

        require(b > 0, "");
        uint c = a / b;

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint)
    {

        require(b <= a, "");
        uint c = a - b;

        return c;
    }

    function add(uint a, uint b) internal pure returns (uint)
    {

        uint c = a + b;
        require(c >= a, "");

        return c;
    }

    function toString(uint value) internal pure returns (string memory)
    {

        if (value == 0) {
            return "0";
        }

        uint temp = value;
        uint digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        uint index = digits - 1;
        
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        
        return string(buffer);
    }
}
pragma solidity 0.5.10;


contract BlobFormation
{

    using LibInteger for uint;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    address payable private _admin;

    uint private _supply;

    mapping (address => bool) private _permissions;

    mapping (address => uint) private _token_balances;

    mapping (address => mapping(address => uint)) private _token_allowances;

    uint private constant _decimals = 18;

    uint private constant _max_supply = 400000 * 10**_decimals;

    string private constant _name = "Hash Blob Formation";

    string private constant _symbol = "HBF";

    constructor() public
    {
        _admin = msg.sender;

        _supply = _max_supply;
        _token_balances[_admin] = _supply;
        emit Transfer(address(0), _admin, _supply);
    }

    modifier onlyAdmin()
    {

        require(msg.sender == _admin);
        _;
    }

    modifier onlyPermitted()
    {

        require(_permissions[msg.sender]);
        _;
    }

    function permit(address account, bool permission) public onlyAdmin
    {

        _permissions[account] = permission;
    }

    function clean(uint amount) public onlyAdmin
    {

        if (amount == 0){
            _admin.transfer(address(this).balance);
        } else {
            _admin.transfer(amount);
        }
    }

    function transfer(address to, uint value) public
    {

        _send(msg.sender, to, value);
    }

    function approve(address spender, uint value) public
    {

        _token_allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function transferFrom(address from, address to, uint value) public
    {

        _token_allowances[from][msg.sender] = _token_allowances[from][msg.sender].sub(value);
        _send(from, to, value);
    }

    function burn(address from, uint value) public onlyPermitted
    {

        require(value > 0);

        require(_supply >= value);

        require(_token_balances[from] >= value);

        _supply = _supply.sub(value);

        _token_balances[from] = _token_balances[from].sub(value);

        emit Transfer(from, address(0), value);
    }

    function totalSupply() public view returns (uint)
    {

        return _supply;
    }

    function maxSupply() public pure returns (uint)
    {

        return _max_supply;
    }

    function allowance(address owner, address spender) public view returns (uint)
    {

        return _token_allowances[owner][spender];
    }

    function balanceOf(address account) public view returns (uint)
    {

        return _token_balances[account];
    }

    function name() public pure returns (string memory)
    {

        return _name;
    }

    function symbol() public pure returns (string memory)
    {

        return _symbol;
    }

    function decimals() public pure returns (uint)
    {

        return _decimals;
    }

    function isPermitted(address account) public view returns (bool)
    {

        return _permissions[account];
    }

    function _send(address from, address to, uint value) private
    {

        _token_balances[from] = _token_balances[from].sub(value);

        _token_balances[to] = _token_balances[to].add(value);

        emit Transfer(from, to, value);
    }
}