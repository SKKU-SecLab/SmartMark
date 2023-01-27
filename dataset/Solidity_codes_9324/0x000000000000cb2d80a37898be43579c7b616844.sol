



pragma solidity >=0.6.0 <0.8.0;

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
}


pragma solidity 0.7.5;

interface IReduxToken {


    function freeUpTo(uint256 value) external returns (uint256 freed);


    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);


    function mint(uint256 value) external;

}


pragma solidity 0.7.5;





contract ReduxToken is IERC20, IReduxToken {

    using SafeMath for uint256;

    string constant public name = "REDUX";
    string constant public symbol = "REDUX";
    uint8 constant public decimals = 0;

    mapping(address => uint256) private s_balances;
    mapping(address => mapping(address => uint256)) private s_allowances;

    uint256 public totalReduxMinted;
    uint256 public totalReduxBurned;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    mapping (address => uint) public nonces;

    function totalSupply() external view override returns(uint256) {

        return totalReduxMinted.sub(totalReduxBurned);
    }

    function mint(uint256 value) external override {

        uint256 offset = totalReduxMinted;

        assembly {


            let end := add(offset, value)
            mstore(callvalue(), 0x746dcb2d80a37898be43579c7b6168563318565b33ff6000526015600bf30000)

            for {let i := div(value, 32)} i {i := sub(i, 1)} {
                pop(create2(callvalue(), callvalue(), 30, add(offset, 0))) pop(create2(callvalue(), callvalue(), 30, add(offset, 1)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 2))) pop(create2(callvalue(), callvalue(), 30, add(offset, 3)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 4))) pop(create2(callvalue(), callvalue(), 30, add(offset, 5)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 6))) pop(create2(callvalue(), callvalue(), 30, add(offset, 7)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 8))) pop(create2(callvalue(), callvalue(), 30, add(offset, 9)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 10))) pop(create2(callvalue(), callvalue(), 30, add(offset, 11)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 12))) pop(create2(callvalue(), callvalue(), 30, add(offset, 13)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 14))) pop(create2(callvalue(), callvalue(), 30, add(offset, 15)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 16))) pop(create2(callvalue(), callvalue(), 30, add(offset, 17)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 18))) pop(create2(callvalue(), callvalue(), 30, add(offset, 19)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 20))) pop(create2(callvalue(), callvalue(), 30, add(offset, 21)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 22))) pop(create2(callvalue(), callvalue(), 30, add(offset, 23)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 24))) pop(create2(callvalue(), callvalue(), 30, add(offset, 25)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 26))) pop(create2(callvalue(), callvalue(), 30, add(offset, 27)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 28))) pop(create2(callvalue(), callvalue(), 30, add(offset, 29)))
                pop(create2(callvalue(), callvalue(), 30, add(offset, 30))) pop(create2(callvalue(), callvalue(), 30, add(offset, 31)))
                offset := add(offset, 32)
            }

            for { } lt(offset, end) { offset := add(offset, 1) } {
                pop(create2(callvalue(), callvalue(), 30, offset))
            }
        }

        _mint(msg.sender, value);
        totalReduxMinted = offset;
    }

    function free(uint256 value) external {
        _burn(msg.sender, value);
        _destroyChildren(value);
    }

    function freeUpTo(uint256 value) external override returns (uint256) {
        uint256 fromBalance = s_balances[msg.sender];
        if (value > fromBalance) {
            value = fromBalance;
        }
        _burn(msg.sender, value);
        _destroyChildren(value);

        return value;
    }

    function freeFromUpTo(address from, uint256 value) external override returns (uint256) {
        uint256 fromBalance = s_balances[from];
        if (value > fromBalance) {
            value = fromBalance;
        }

        uint256 userAllowance = s_allowances[from][msg.sender];
        if (value > userAllowance) {
            value = userAllowance;
        }
        _burnFrom(from, value);
        _destroyChildren(value);

        return value;
    }

    function freeFrom(address from, uint256 value) external {
        _burnFrom(from, value);
        _destroyChildren(value);
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return s_allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, s_allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "permit: invalid signature");
        require(signatory == owner, "permit: unauthorized");
        require(block.timestamp <= deadline, "permit: signature expired");

        _approve(owner, spender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return s_balances[account];
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        s_balances[sender] = s_balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        s_balances[recipient] = s_balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        s_allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) private {
        s_balances[account] = s_balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) private {
        s_balances[account] = s_balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint256 amount) private {
        _burn(account, amount);
        _approve(account, msg.sender, s_allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    function computeAddress2(uint256 salt) public pure returns (address child) {
        assembly {
            let data := mload(0x40)
            mstore(data, 0xff000000000000cb2d80a37898be43579c7b6168440000000000000000000000)
            mstore(add(data, 21), salt)
            mstore(add(data, 53), 0xe4135d085e66541f164ddfd4dd9d622a50176c98e7bcdbbc6634d80cd31e9421)
            child := and(keccak256(data, 85), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        }
    }

    function _destroyChildren(uint256 value) internal {
        assembly {
            let i := sload(totalReduxBurned.slot)
            let end := add(i, value)
            sstore(totalReduxBurned.slot, end)

            let data := mload(0x40)
            mstore(data, 0xff000000000000cb2d80a37898be43579c7b6168440000000000000000000000)
            mstore(add(data, 53), 0xe4135d085e66541f164ddfd4dd9d622a50176c98e7bcdbbc6634d80cd31e9421)
            let ptr := add(data, 21)
            for { } lt(i, end) { i := add(i, 1) } {
                mstore(ptr, i)
                pop(call(gas(), keccak256(data, 85), callvalue(), callvalue(), callvalue(), callvalue(), callvalue()))
            }
        }
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}