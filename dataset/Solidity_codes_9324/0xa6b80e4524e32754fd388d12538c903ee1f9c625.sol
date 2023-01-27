pragma solidity 0.8.13;


contract MasterCopy  {

    event ChangedMasterCopy(address masterCopy);

    modifier authorized() {

        require(
            msg.sender == address(this),
            "Method can only be called from this contract"
        );
        _;
    }
    address private masterCopy;

    function changeMasterCopy(address _masterCopy) public authorized {

        require(
            _masterCopy != address(0),
            "Invalid master copy address provided"
        );
        masterCopy = _masterCopy;
        emit ChangedMasterCopy(_masterCopy);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT
pragma solidity ^0.8.1;

contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function setupToken(string memory __name, string memory __symbol) internal {

        require(
            keccak256(abi.encodePacked((_name))) ==
                keccak256(abi.encodePacked((""))),
            "Token Name already assigned"
        );
        require(
            keccak256(abi.encodePacked((_symbol))) ==
                keccak256(abi.encodePacked((""))),
            "Token Symbol already assigned"
        );

        _name = __name;
        _symbol = __symbol;
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

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = msg.sender;
        uint256 currentAllowance = allowance(from, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(from, spender, currentAllowance - amount);
            }
        }

        _transfer(from, to, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = msg.sender;
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

pragma solidity ^0.8.0;


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.1;

contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }

    function onERC1155Received (
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) override
    external
    virtual
    returns(bytes4)
    {
   
    }

    function onERC1155BatchReceived (
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) override
    external
    returns(bytes4)
    {
 
    }
}// MIT
pragma solidity 0.8.13;

interface IAPContract {
    

    function getUSDPrice(address) external view returns (uint256);
    function stringUtils() external view returns (address);
    function yieldsterGOD() external view returns (address);
    function emergencyVault() external view returns (address);
    function whitelistModule() external view returns (address);
    function addVault(address,uint256[] calldata) external;
    function setVaultSlippage(uint256) external;
    function setVaultAssets(address[] calldata,address[] calldata,address[] calldata,address[] calldata) external;
    function changeVaultAdmin(address _vaultAdmin) external;
    function yieldsterDAO() external view returns (address);
    function exchangeRegistry() external view returns (address);
    function getVaultSlippage() external view returns (uint256);
    function _isVaultAsset(address) external view returns (bool);
    function yieldsterTreasury() external view returns (address);
    function setVaultStatus(address) external;
    function setVaultSmartStrategy(address, uint256) external;
    function getWithdrawStrategy() external returns (address);
    function getDepositStrategy() external returns (address);
    function isDepositAsset(address) external view returns (bool);
    function isWithdrawalAsset(address) external view returns (bool);
    function getVaultManagementFee() external returns (address[] memory);
    function safeMinter() external returns (address);
    function safeUtils() external returns (address);
    function getStrategyFromMinter(address) external view returns (address);
    function sdkContract() external returns (address);
    function getWETH()external view returns(address);
    function calculateSlippage(address ,address, uint256, uint256)external view returns(uint256);
    function vaultsCount(address) external view returns(uint256);
    function getPlatformFeeStorage() external view returns(address);
    function checkWalletAddress(address _walletAddress) external view returns(bool);
}// MIT
pragma solidity 0.8.13;

interface IHexUtils {
    function fromHex(bytes calldata) external pure returns (bytes memory);

    function toDecimals(address, uint256) external view returns (uint256);

    function fromDecimals(address, uint256) external view returns (uint256);
}// MIT
pragma solidity 0.8.13;

interface IWhitelist {
    function isMember(uint256, address) external view returns (bool);
}// MIT
pragma solidity 0.8.13;

contract TokenBalanceStorage {

    uint256 public blockNumber;
    uint256 public lastTransactionNAV;
    address private owner;
    mapping(address=>uint256) tokenBalance;

    constructor(){
        owner = msg.sender;
    }

    function setTokenBalance(address _tokenAddress, uint256 _balance) public {
        require(msg.sender == owner, "only Owner");
        tokenBalance[_tokenAddress] = _balance;
    }
    
   function getTokenBalance(address _token) public view returns (uint256) {
        return tokenBalance[_token];
    }

    function setLastTransactionBlockNumber() public{
        require(msg.sender==owner,"not authorized");
        blockNumber = block.number;
    }

    function setLastTransactionNAV(uint256 _nav) public{
        require(msg.sender==owner,"not authorized");
        lastTransactionNAV = _nav;
    }
    
    function getLastTransactionBlockNumber() public view returns (uint256) {
        return blockNumber;
    }

    function getLastTransactionNav() public view returns (uint256) {
        return lastTransactionNAV;
    }


}// MIT
pragma solidity 0.8.13;

interface IExchangeRegistry {
    function getPair(address, address) external returns (address);
}// MIT
pragma solidity 0.8.13;

interface IExchange {
    function swap(
        address, //from
        address, //to
        uint256, //amount
        uint256 //minAmount
    ) external returns (uint256);
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity 0.8.13;


contract VaultStorage is MasterCopy, ERC20Detailed, ERC1155Receiver, Pausable,ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 constant arrSize = 200;
    uint8 public emergencyConditions;
    bool internal vaultSetupCompleted;
    bool internal vaultRegistrationCompleted;
    address public APContract;
    address public owner;
    address public vaultAdmin;
    uint256[] internal whiteListGroups;
    mapping(uint256 => bool) isWhiteListGroupPresent;
    address[] public assetList;
    mapping(address => bool) internal isAssetPresent;
    address public strategyBeneficiary;
    uint256 public strategyPercentage;
    uint256 public threshold;
    address public eth;
    mapping(address=>uint256) userEtherBalance;
    address[] public etherDepositors;
    address public emergencyVault;
    TokenBalanceStorage tokenBalances;

    function revertDelegate(bool _delegateStatus) internal pure {
        if (!_delegateStatus) {
            assembly {
                let ptr := mload(0x40)
                let size := returndatasize()
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }
    }

    function getTokenBalance(address _tokenAddress)
        external
        view
        returns (uint256)
    {
        return tokenBalances.getTokenBalance(_tokenAddress);
    }

    function addToAssetList(address _asset) internal {
        require(_asset != address(0), "invalid asset address");
        if (!isAssetPresent[_asset]) {
            checkLength(1);
            assetList.push(_asset);
            isAssetPresent[_asset] = true;
        }
    }

    function getVaultNAV() public view returns (uint256) {
        uint256 nav = 0;
        address wEth = IAPContract(APContract).getWETH();
        for (uint256 i = 0; i < assetList.length; i++) {
            if (tokenBalances.getTokenBalance(assetList[i]) > 0) {
                uint256 tokenUSD = IAPContract(APContract).getUSDPrice(
                    assetList[i]
                );
                if (assetList[i] == eth) {
                    nav += IHexUtils(IAPContract(APContract).stringUtils())
                        .toDecimals(
                            wEth,
                            tokenBalances.getTokenBalance(assetList[i])
                        )
                        .mul(tokenUSD);
                } else {
                    nav += IHexUtils(IAPContract(APContract).stringUtils())
                        .toDecimals(
                            assetList[i],
                            tokenBalances.getTokenBalance(assetList[i])
                        )
                        .mul(tokenUSD);
                }
            }
        }
        return nav.div(1e18);
    }

    function _approveToken(
        address _token,
        address _spender,
        uint256 _amount
    ) internal {
        if (IERC20(_token).allowance(address(this), _spender) > 0) {
            IERC20(_token).safeApprove(_spender, 0);
            IERC20(_token).safeApprove(_spender, _amount);
        } else IERC20(_token).safeApprove(_spender, _amount);
    }

    function getDepositNAV(address _tokenAddress, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        uint256 tokenUSD = IAPContract(APContract).getUSDPrice(_tokenAddress);
        address tokenAddress = _tokenAddress;
        if (tokenAddress == eth)
            tokenAddress = IAPContract(APContract).getWETH();
        return
            (
                IHexUtils(IAPContract(APContract).stringUtils())
                    .toDecimals(tokenAddress, _amount)
                    .mul(tokenUSD)
            ).div(1e18);
    }

    function getMintValue(uint256 depositNAV) internal view returns (uint256) {
        return (depositNAV.mul(totalSupply())).div(getVaultNAV());
    }

    function tokenValueInUSD() public view returns (uint256) {
        if (getVaultNAV() == 0 || totalSupply() == 0) {
            return 0;
        } else {
            return (getVaultNAV().mul(1e18)).div(totalSupply());
        }
    }

    function updateTokenBalance(
        address tokenAddress,
        uint256 tokenAmount,
        bool isAddition
    ) internal {
        if (isAddition) {
            tokenBalances.setTokenBalance(
                tokenAddress,
                tokenBalances.getTokenBalance(tokenAddress).add(tokenAmount)
            );
        } else {
            tokenBalances.setTokenBalance(
                tokenAddress,
                tokenBalances.getTokenBalance(tokenAddress).sub(tokenAmount)
            );
        }
    }

    function checkLength(uint256 _increments) internal view {
        require(
            assetList.length + _increments <= arrSize,
            "Exceeds safe assetList length"
        );
    }

    function getEtherDepositor(address _address) external view returns(uint256){
        return userEtherBalance[_address];
    }
}// MIT
pragma solidity 0.8.13;

contract YieldsterVault is VaultStorage {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    event Response(address feeAddress, string message);
    event CallStatus(string message);

    function upgradeMasterCopy(address _mastercopy) external {
        _isYieldsterGOD();
        (bool result, ) = address(this).call(
            abi.encodeWithSignature("changeMasterCopy(address)", _mastercopy)
        );
        revertDelegate(result);
    }

    function setAPS(address _APContract) external {
        _isYieldsterGOD();
        APContract = _APContract;
    }

    function toggleEmergencyBreak() external {
        _isYieldsterGOD();
        if (emergencyConditions == 1) emergencyConditions = 0;
        else if (emergencyConditions == 0) emergencyConditions = 1;
    }

    function enableEmergencyExit() external {
        _isYieldsterGOD();
        emergencyConditions = 2;
        for (uint256 i = 0; i < assetList.length; i++) {
            if (assetList[i] == eth) {
                uint256 tokenBalance = address(this).balance;
                if (tokenBalance > 0) {
                    address payable to = payable(
                        emergencyVault
                    );
                    (bool success, ) = to.call{value: tokenBalance}("");
                    if (success == false) {
                        emit CallStatus("call failed");
                    }
                }
            } else {
                IERC20 token = IERC20(assetList[i]);
                uint256 tokenBalance = token.balanceOf(address(this));
                if (tokenBalance > 0) {
                    token.safeTransfer(
                        emergencyVault,
                        tokenBalance
                    );
                }
            }
        }
    }

    function _isWhiteListed() private view {
        if (whiteListGroups.length == 0) {
            return;
        } else {
            for (uint256 i = 0; i < whiteListGroups.length; i++) {
                if (isWhiteListGroupPresent[whiteListGroups[i]]) {
                    if (
                        IWhitelist(IAPContract(APContract).whitelistModule())
                            .isMember(whiteListGroups[i], msg.sender)
                    ) {
                        return;
                    }
                }
            }
            revert("Only Whitelisted");
        }
    }

    function registerVaultWithAPS() external onlyNormalMode {
        require(msg.sender == owner, "unauthorized");
        require(!vaultRegistrationCompleted, "Vault is already registered");
        vaultRegistrationCompleted = true;
        IAPContract(APContract).addVault(vaultAdmin, whiteListGroups);
    }

    function setup(address _APContract, address _vaultAdmin,address _emergencyVault) external {
        require(!vaultSetupCompleted, "Vault is already setup");
        vaultSetupCompleted = true;
        vaultAdmin = _vaultAdmin;
        APContract = _APContract;
        owner = _vaultAdmin;
        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        emergencyVault=_emergencyVault;
        tokenBalances = new TokenBalanceStorage();
    }

    function transferOwnership(address _owner) external {
        require(msg.sender == owner, "unauthorized");
        owner = _owner;
    }

    function addWhiteListGroups(uint256[] memory _whiteListGroups) external {
        _isVaultAdmin();
        for (uint256 i = 0; i < _whiteListGroups.length; i++) {
            if (!isWhiteListGroupPresent[_whiteListGroups[i]]) {
                whiteListGroups.push(_whiteListGroups[i]);
                isWhiteListGroupPresent[_whiteListGroups[i]] = true;
            }
        }
    }

    function removeWhiteListGroups(uint256[] memory _whiteListGroups) external {
        _isVaultAdmin();
        for (uint256 i = 0; i < _whiteListGroups.length; i++) {
            isWhiteListGroupPresent[_whiteListGroups[i]] = false;
        }
    }

    function setTokenDetails(string memory _tokenName, string memory _symbol)
        external
    {
        require(msg.sender == owner, "unauthorized");
        setupToken(_tokenName, _symbol);
    }

    function setVaultSlippage(uint256 _slippage) external onlyNormalMode {
        require(msg.sender == vaultAdmin, "unauthorized");
        IAPContract(APContract).setVaultSlippage(_slippage);
    }

    function setVaultAssets(
        address[] calldata _enabledDepositAsset,
        address[] calldata _enabledWithdrawalAsset,
        address[] calldata _disabledDepositAsset,
        address[] calldata _disabledWithdrawalAsset
    ) external onlyNormalMode {
        require(msg.sender == vaultAdmin, "unauthorized");
        IAPContract(APContract).setVaultAssets(
            _enabledDepositAsset,
            _enabledWithdrawalAsset,
            _disabledDepositAsset,
            _disabledWithdrawalAsset
        );
    }

    function changeVaultAdmin(address _vaultAdmin) external onlyNormalMode {
        require(
            IAPContract(APContract).yieldsterDAO() == msg.sender ||
                vaultAdmin == msg.sender,
            "unauthorized"
        );
        vaultAdmin = _vaultAdmin;
        IAPContract(APContract).changeVaultAdmin(_vaultAdmin);
    }

    function setVaultSmartStrategy(address _smartStrategyAddress, uint256 _type)
        public
    {
        _isVaultAdmin();
        IAPContract(APContract).setVaultSmartStrategy(
            _smartStrategyAddress,
            _type
        );
    }

    function setThreshold(uint256 _threshold) external {
        _isVaultAdmin();
        threshold = _threshold;
    }

    function deposit(address _tokenAddress, uint256 _amount)
        external
        payable
        onlyNormalMode
        whenNotPaused
    {
        _isWhiteListed();
        require(
            IAPContract(APContract).isDepositAsset(_tokenAddress),
            "Not an approved deposit asset"
        );

        if (_tokenAddress == eth) {
            require(_amount == msg.value, "incorrect value");
        }

        managementFeeCleanUp(_tokenAddress);

        (bool result, ) = IAPContract(APContract)
            .getDepositStrategy()
            .delegatecall(
                abi.encodeWithSignature(
                    "deposit(address,uint256)",
                    _tokenAddress,
                    _amount
                )
            );
        revertDelegate(result);
    }

    function withdraw(address _tokenAddress, uint256 _shares)
        external
        onlyNormalMode
        whenNotPaused
    {
        _isWhiteListed();
        require(
            IAPContract(APContract).isWithdrawalAsset(_tokenAddress),
            "Not an approved Withdrawal asset"
        );
        require(
            balanceOf(msg.sender) >= _shares,
            "You don't have enough shares"
        );

        managementFeeCleanUp(_tokenAddress);

        (bool result, ) = IAPContract(APContract)
            .getWithdrawStrategy()
            .delegatecall(
                abi.encodeWithSignature(
                    "withdraw(address,uint256)",
                    _tokenAddress,
                    _shares
                )
            );
        revertDelegate(result);
    }

    function setBeneficiaryAndPercentage(
        address _beneficiary,
        uint256 _percentage
    ) external onlyNormalMode {
        _isVaultAdmin();
        strategyBeneficiary = _beneficiary;
        strategyPercentage = _percentage;
    }

    function returnBalance(address _token) internal view returns (uint256) {
        uint256 amount;
        if (_token == eth) {
            amount = address(this).balance;
        } else if (_token != address(0)) {
            amount = IERC20(_token).balanceOf(address(this));
        }

        return amount;
    }

    function protocolInteraction(
        address _poolAddress,
        bytes calldata _instruction,
        uint256[] calldata _amount,
        address[] calldata _fromToken,
        address[] calldata _returnToken
    ) external onlyNormalMode whenPaused {
        require(
            IAPContract(APContract).sdkContract() == msg.sender,
            "only through sdk"
        );
        bool operationSatisfied;

        if (_instruction.length > 0) operationSatisfied = true;
        else if (_poolAddress == IAPContract(APContract).sdkContract())
            operationSatisfied = true;
        else operationSatisfied = false;

        require(operationSatisfied, "Not supported operation");

        uint256[] memory returnTokenBalance = new uint256[](
            _returnToken.length
        );

        if (_returnToken.length > 0) {
            for (uint256 i = 0; i < _returnToken.length; i++) {
                returnTokenBalance[i] = returnBalance(_returnToken[i]);
                if (_returnToken[i] != address(0))
                    addToAssetList(_returnToken[i]);
            }
        }

        uint256 fromTokenEthAmount;

        if (_fromToken.length > 0) {
            require(_fromToken.length == _amount.length, "require same");
            for (uint256 i = 0; i < _fromToken.length; i++) {
                require(
                    _amount[i] <= tokenBalances.getTokenBalance(_fromToken[i]),
                    "Not enough token present"
                );
                if (_fromToken[i] != eth)
                    _approveToken(_fromToken[i], _poolAddress, _amount[i]);
                else if (_fromToken[i] == eth)
                    fromTokenEthAmount = fromTokenEthAmount.add(_amount[i]);
            }
        }

        bool result;

        if (fromTokenEthAmount != 0) {
            (result, ) = _poolAddress.call{value: fromTokenEthAmount}(
                _instruction
            );
        } else if (_fromToken.length > 0) {
            if (_instruction.length > 0)
                (result, ) = _poolAddress.call(_instruction);
            else result = true;
        } else {
            (result, ) = _poolAddress.call(_instruction);
        }

        if (_fromToken.length > 0) {
            for (uint256 i; i < _fromToken.length; i++) {
                if (_fromToken[i] != address(0))
                    tokenBalances.setTokenBalance(
                        _fromToken[i],
                        tokenBalances.getTokenBalance(_fromToken[i]).sub(
                            _amount[i]
                        )
                    );
            }
        }

        if (_returnToken.length > 0)
            for (uint256 i = 0; i < _returnToken.length; i++) {
                if (_returnToken[i] != address(0)) {
                    uint256 returnTokenAmountAfter = returnBalance(
                        _returnToken[i]
                    );
                    tokenBalances.setTokenBalance(
                        _returnToken[i],
                        tokenBalances.getTokenBalance(_returnToken[i]).add(
                            returnTokenAmountAfter.sub(returnTokenBalance[i])
                        )
                    );
                }
            }

        revertDelegate(result);
    }

    function getAssetList() public view returns (address[] memory) {
        return assetList;
    }

    function exchangeToken(
        address _fromToken,
        address _toToken,
        uint256 _amount,
        uint256 _slippageSwap
    ) public whenPaused returns (uint256) {
        require(
            _amount <= tokenBalances.getTokenBalance(_fromToken),
            "Not enough token present"
        );
        require(
            IAPContract(APContract).sdkContract() == msg.sender,
            "only through sdk"
        );
        uint256 exchangeReturn;
        IExchangeRegistry exchangeRegistry = IExchangeRegistry(
            IAPContract(APContract).exchangeRegistry()
        );
        address exchange = exchangeRegistry.getPair(_fromToken, _toToken);
        require(exchange != address(0), "Exchange pair not present");
        addToAssetList(_toToken);
        uint256 minReturn = IAPContract(APContract).calculateSlippage(
            _fromToken,
            _toToken,
            _amount,
            _slippageSwap
        );

        _approveToken(_fromToken, exchange, _amount);
        exchangeReturn = IExchange(exchange).swap(
            _fromToken,
            _toToken,
            _amount,
            minReturn
        );
        tokenBalances.setTokenBalance(
            _fromToken,
            tokenBalances.getTokenBalance(_fromToken).sub(_amount)
        );

        tokenBalances.setTokenBalance(
            _toToken,
            tokenBalances.getTokenBalance(_toToken).add(exchangeReturn)
        );
        return exchangeReturn;
    }

    function managementFeeCleanUp(address _tokenAddress) public {
        address[] memory managementFeeStrategies = IAPContract(APContract)
            .getVaultManagementFee();
        for (uint256 i = 0; i < managementFeeStrategies.length; i++) {
            (bool result, ) = managementFeeStrategies[i].delegatecall(
                abi.encodeWithSignature(
                    "executeSafeCleanUp(address)",
                    _tokenAddress
                )
            );
            if (result == false) {
                emit Response(
                    managementFeeStrategies[i],
                    "Failed in managementFeeCleanUp"
                );
            }
        }
    }

    modifier onlyNormalMode() {
        _onlyNormalMode();
        _;
    }

    function _isVaultAdmin() private view {
        require(msg.sender == vaultAdmin, "not vaultAdmin");
    }

    function _isYieldsterGOD() private view {
        require(
            msg.sender == IAPContract(APContract).yieldsterGOD(),
            "unauthorized"
        );
    }

    function _onlyNormalMode() private view {
        if (emergencyConditions == 1) {
            _isYieldsterGOD();
        } else if (emergencyConditions == 2) {
            revert("safe inactive");
        }
    }

    receive() external payable {
        etherDepositors.push(msg.sender);
        userEtherBalance[msg.sender] = userEtherBalance[msg.sender] + msg.value;
    }

    function onERC1155Received(
        address,
        address,
        uint256 id,
        uint256,
        bytes calldata data
    ) external virtual override onlyNormalMode returns (bytes4) {
        if (id == 0) {
            require(
                IAPContract(APContract).safeMinter() == msg.sender,
                "Only Safe Minter"
            );
            (bool success, ) = IAPContract(APContract).safeUtils().delegatecall(
                data
            );
            revertDelegate(success);
        } else if (id == 2 || id == 3) {
            require(
                (IAPContract(APContract).getStrategyFromMinter(msg.sender) ==
                    IAPContract(APContract).getDepositStrategy()) ||
                    (IAPContract(APContract).getStrategyFromMinter(
                        msg.sender
                    ) == IAPContract(APContract).getWithdrawStrategy()),
                "Neither Deposit nor Withdraw strategy"
            );
            (bool success, ) = IAPContract(APContract)
                .getStrategyFromMinter(msg.sender)
                .delegatecall(data);
            revertDelegate(success);
        }

        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function toPause() external {
        require(
            msg.sender == vaultAdmin ||
                IAPContract(APContract).checkWalletAddress(msg.sender),
            "Unauthorized"
        );
        _pause();
    }

    function unPause() external {
        require(
            msg.sender == vaultAdmin ||
                IAPContract(APContract).checkWalletAddress(msg.sender),
            "Unauthorized"
        );
        _unpause();
    }

    function getVaultSlippage() external view returns (uint256) {
        return IAPContract(APContract).getVaultSlippage();
    }

    function changeEmergencyVault(address _emergencyVault) public {
        _isVaultAdmin();
        emergencyVault = _emergencyVault;
    }

}