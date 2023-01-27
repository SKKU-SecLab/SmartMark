
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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

}// MIT

pragma solidity ^0.8.0;


interface IVault {
    function pricePerShare() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalAssets() external view returns (uint256);
    function decimals() external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;



interface IYRegistry {
    function numTokens() external view returns (uint256);
    function tokens(uint256 index) external view returns (address vault);
    function numVaults(address token) external view returns (uint256);
    function vaults(address token, uint256 index) external view returns (address vault);
}// MIT

pragma solidity ^0.8.0;


interface CurveToken {
    function get_virtual_price() external view returns (uint256);
    function minter() external view returns (address);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
}//Unlicense
pragma solidity ^0.8.0;


interface IENSResolver {
    function addr(bytes32 node) external view returns (address);
}//Unlicense
pragma solidity ^0.8.0;



interface IENS {
    function resolver(bytes32 node) external view returns (IENSResolver);
}// MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;





contract YearnVaultExplorer is Ownable {
    bytes32 private node = 0x15e1d52381c87881e27faf6f0123992c93652facf5eb0b6d063d5eef4ed9c32d; // v2.registry.ychad.eth
    IENS private ens = IENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    struct TokenInfo {
        address addr;
        string symbol;
        string name;
        uint decimals;
        uint numVaults;
        uint virtualPrice;
    }

    struct VaultInfo {
        address addr;
        string symbol;
        string name;
        uint decimals;
        uint totalAssets;
        uint pricePerShare;
    }

    function finalize() public onlyOwner {
        address payable receiver = payable(msg.sender);
        selfdestruct(receiver);
    }

    function resolveYearnRegistry() public view returns (IYRegistry) {
        return IYRegistry(ens.resolver(node).addr(node));
    }

    function getNumTokens() public view returns (uint) {
        return resolveYearnRegistry().numTokens();
    }

    function exploreByTokenIndex(uint from, uint count) public view
    returns(TokenInfo[] memory tokens, VaultInfo[] memory vaults) {
        IYRegistry registry = resolveYearnRegistry();

        uint numTokens = registry.numTokens();
        uint to = from + count;
        if (to > numTokens) {
            to = numTokens;
        }
        if (from > numTokens) {
            from = numTokens;
        }

        count = to - from;

        tokens = new TokenInfo[](count);
        uint totalVaults = 0;
        for (uint i = 0; i < count; ++i) {
            address token = registry.tokens(i + from);
            if (token == address(0)) {
                break;
            }

            tokens[i] = resolveToken(registry, token);
            totalVaults += tokens[i].numVaults;
        }

        vaults = resolveVaults(registry, tokens, totalVaults);
    }

    function exploreByTokenAddress(address[] memory inputTokens) public view
    returns (TokenInfo[] memory tokens, VaultInfo[] memory vaults) {
        IYRegistry registry = resolveYearnRegistry();

        uint numTokens = inputTokens.length;

        uint totalVaults = 0;
        tokens = new TokenInfo[](numTokens);
        for (uint i = 0; i < numTokens; ++i) {
            tokens[i] = resolveToken(registry, inputTokens[i]);
            totalVaults += tokens[i].numVaults;
        }

        vaults = resolveVaults(registry, tokens, totalVaults);
    }

    function resolveToken(IYRegistry registry, address addr) internal view returns (TokenInfo memory tokenInfo) {
        tokenInfo = TokenInfo(
            addr,
            ERC20(addr).symbol(),
            ERC20(addr).name(),
            ERC20(addr).decimals(),
            registry.numVaults(addr),
            0
        );

        if (stringStartsWith("Curve.fi", tokenInfo.name)) {
            tokenInfo.virtualPrice = getCurveTokenVirtualPrice(addr);
        }
    }

    function resolveVaults(IYRegistry registry, TokenInfo[] memory tokens, uint totalVaults) internal view
    returns (VaultInfo[] memory vaults) {
        vaults = new VaultInfo[](totalVaults);
        uint k = 0;
        for (uint i = 0; i < tokens.length; ++i) {
            uint numVaults = tokens[i].numVaults;
            for (uint j = 0; j < numVaults; ++j) {
                vaults[k++] = resolveVault(IVault(registry.vaults(tokens[i].addr, j)));
            }
        }
    }

    function resolveVault(IVault vault) internal view returns (VaultInfo memory vaultInfo) {
        vaultInfo = VaultInfo(
            address(vault),
            vault.symbol(),
            vault.name(),
            vault.decimals(),
            vault.totalAssets(),
            vault.pricePerShare()
        );
    }

    function getCurveTokenVirtualPrice(address token) internal view returns (uint) {
        try CurveToken(token).get_virtual_price() returns (uint virtualPrice) {
            return virtualPrice;
        } catch (bytes memory) {
            try CurveToken(token).minter() returns (address miner) {
                try CurveToken(miner).get_virtual_price() returns (uint minterVirtualPrice) {
                    return minterVirtualPrice;
                } catch (bytes memory) {}
            } catch (bytes memory) {}
        }

        return 0;
    }

    function stringStartsWith(string memory what, string memory where) private pure returns (bool result) {
        bytes memory whatBytes = bytes(what);
        bytes memory whereBytes = bytes(where);

        if (whatBytes.length > whereBytes.length) {
            return false;
        }

        if (whereBytes.length == 0) {
            return false;
        }

        uint i = 0;
        uint j = 0;

        for (; i < whatBytes.length;) {
            if (whatBytes[i] != whereBytes[j]) {
                return false;
            }

            i += 1;
            j += 1;
        }

        return true;
    }
}