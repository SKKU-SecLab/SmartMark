

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

contract RTK_SwapContract {
    
    address private owner;
    mapping(uint256 => address) private _Token_RTKL;
    mapping(uint256 => uint256) private _RTKLX_ExtCirculation;
    mapping(uint256 => uint256) private _RTKLX_InitialSupply;
    address private _Token_AMMO;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier OwnerOnly() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor(address RTK, address RTKL2, address RTKL3, address RTKL4, address RTKL5, address AMMO) public {
        owner = msg.sender;
        _Token_RTKL[0] = RTK;
        _Token_RTKL[1] = RTKL2;
        _Token_RTKL[2] = RTKL3;
        _Token_RTKL[3] = RTKL4;
        _Token_RTKL[4] = RTKL5;
        _Token_AMMO = AMMO;
        _RTKLX_ExtCirculation[0] = ERC20(RTK).totalSupply();
        _RTKLX_ExtCirculation[1] = 0;
        _RTKLX_ExtCirculation[2] = 0;
        _RTKLX_ExtCirculation[3] = 0;
        _RTKLX_ExtCirculation[4] = 0;
        _RTKLX_InitialSupply[1] = 999999900000000000000000000;
        _RTKLX_InitialSupply[2] = 1000000000000000000000000000;
        _RTKLX_InitialSupply[3] = 1000000000000000000000000000;
        _RTKLX_InitialSupply[4] = 1000000000000000000000000000;
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address newOwner) public OwnerOnly {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
    
    function changeTokenAddresses(address RTK, address RTKL2, address RTKL3, address RTKL4, address RTKL5, address AMMO) public OwnerOnly {
        _Token_RTKL[0] = RTK;
        _Token_RTKL[1] = RTKL2;
        _Token_RTKL[2] = RTKL3;
        _Token_RTKL[3] = RTKL4;
        _Token_RTKL[4] = RTKL5;
        _Token_AMMO = AMMO;
    }
    
    function getMinimumRequiredAMMOAmount() public view returns (uint256) {
        uint256 netUnburntExtCirculation = 0;
        uint256 amountOfTokensBurnt;
        for(uint i = 1; i <= 4; i++) {
            amountOfTokensBurnt = _RTKLX_InitialSupply[i] - ERC20(_Token_RTKL[i]).totalSupply();
            if(amountOfTokensBurnt <= _RTKLX_ExtCirculation[i]) {
                netUnburntExtCirculation += (_RTKLX_ExtCirculation[i] - amountOfTokensBurnt)*(i);
            }
        }
        
        return netUnburntExtCirculation;
    }
    
    function getMinimumRequiredRTKAmount() public view returns (uint256) {
        uint256 netUnburntExtCirculation = 0;
        uint256 amountOfTokensBurnt;
        for(uint i = 1; i <= 4; i++) {
            amountOfTokensBurnt = _RTKLX_InitialSupply[i] - ERC20(_Token_RTKL[i]).totalSupply();
            if(amountOfTokensBurnt <= _RTKLX_ExtCirculation[i]) {
                netUnburntExtCirculation += (_RTKLX_ExtCirculation[i] - amountOfTokensBurnt);
            }
        }
        
        return netUnburntExtCirculation;
    }
    
    function pullOutExcessAMMO(address to, uint256 amount) public OwnerOnly returns (bool) {
        ERC20 AMMOToken = ERC20(_Token_AMMO);
        
        require (
            amount > 0,
            "Cannot pull out 0"
        );
        
        require (
            AMMOToken.balanceOf(address(this)) >= amount,
            "Insufficient AMMO balance in the contract"
        );
        
        require (
            AMMOToken.balanceOf(address(this)) - amount >= getMinimumRequiredAMMOAmount(),
            "Cannot withdraw an amount that leaves swap contract deficient of minimum required AMMO"
        );
        
        return AMMOToken.transfer(to, amount);
    }
    
    function pullOutExcessRTK(address to, uint256 amount) public OwnerOnly returns (bool) {
        ERC20 RTKToken = ERC20(_Token_RTKL[0]);
        
        require (
            amount > 0,
            "Cannot pull out 0"
        );
        
        require (
            RTKToken.balanceOf(address(this)) >= amount,
            "Insufficient RTK balance in the contract"
        );
        
        require (
            (RTKToken.balanceOf(address(this)) - amount) >= getMinimumRequiredRTKAmount(),
            "Cannot withdraw an amount that leaves swap contract deficient of minimum required RTK"
        );
        
        return RTKToken.transfer(to, amount);
    }

    function convertRTKIntoRTKLX(address to, uint256 amount, uint256 X) public returns (bool) {
        require (
            (X >= 2 && X <= 5), 
            "Invalid value of X. X can only be 2, 3, 4, 5"
        );
        
        require (
            amount > 0,
            "Cannot convert 0"
        );
        
        ERC20 AMMOToken = ERC20(_Token_AMMO);
        ERC20 RTKToken = ERC20(_Token_RTKL[0]);
        ERC20 RTKLXToken = ERC20(_Token_RTKL[X-1]);
        
        require (
            RTKLXToken.balanceOf(address(this)) >= amount,
            "Insufficeint RTKLX Token balance in the contract for the given value of X"
        );
        
        require (
            RTKToken.allowance(msg.sender, address(this)) >= amount,
            "Allowance Lower than required for RTKToken"
        );
        
        require (
            AMMOToken.allowance(msg.sender, address(this)) >= ((X-1)*amount),
            "Allowance Lower than required for bulletToken"
        );
        
    
        if(AMMOToken.transferFrom(msg.sender, address(this), ((X-1)*amount))) {
            if(RTKToken.transferFrom(msg.sender, address(this), amount)) {
                if(RTKLXToken.transfer(to, amount)) {
                    _RTKLX_ExtCirculation[X-1] += amount;
                    return true;
                } else {
                    return false;
                }
            } else {
                AMMOToken.transfer(msg.sender, (X-1)*amount);
                return false;
            }
        } else {
            return false;
        }
    }
    
    function convertRTKLXIntoRTK(address to, uint256 amount, uint256 X) public returns (bool) {
        require (
            (X >= 2 && X <= 5), 
            "Invalid value of X. X can only be 2, 3, 4, 5"
        );
        
        require (
            amount > 0,
            "Cannot convert 0"
        );
        
        ERC20 RTKToken = ERC20(_Token_RTKL[0]);
        ERC20 AMMOToken = ERC20 (_Token_AMMO);
        ERC20 RTKLXToken = ERC20(_Token_RTKL[X-1]);
            
        require (
            RTKToken.balanceOf(address(this)) >= amount,
            "Insufficeint RTK Token balance in the contract"
        );
        
        require (
            AMMOToken.balanceOf(address(this)) >= amount*(X-1),
            "insufficient AMMO token balance in the contract"
            );
        
        require (
            RTKLXToken.allowance(msg.sender, address(this)) >= amount,
            "Allowance Lower than required for RTKToken"
        );
        
        if(RTKLXToken.transferFrom(msg.sender, address(this), amount)) {
            if(_RTKLX_ExtCirculation[X-1] >= amount) {
                _RTKLX_ExtCirculation[X-1] -= amount;
            } else {
                _RTKLX_ExtCirculation[X-1] = 0;
            }
            if(RTKToken.transfer(to, amount)) {
                return AMMOToken.transfer(to, (X-1)*amount);
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
}