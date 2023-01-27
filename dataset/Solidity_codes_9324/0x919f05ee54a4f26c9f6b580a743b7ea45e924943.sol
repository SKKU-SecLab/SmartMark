
pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
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

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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


interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}// MIT

pragma solidity ^0.8.0;

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
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


contract Governable is Initializable {
    address public governor;

    event GovernorshipTransferred(address indexed previousGovernor, address indexed newGovernor);

    function initialize(address governor_) virtual public initializer {
        governor = governor_;
        emit GovernorshipTransferred(address(0), governor);
    }

    modifier governance() {
        require(msg.sender == governor);
        _;
    }

    function renounceGovernorship() public governance {
        emit GovernorshipTransferred(governor, address(0));
        governor = address(0);
    }

    function transferGovernorship(address newGovernor) public governance {
        _transferGovernorship(newGovernor);
    }

    function _transferGovernorship(address newGovernor) internal {
        require(newGovernor != address(0));
        emit GovernorshipTransferred(governor, newGovernor);
        governor = newGovernor;
    }
}pragma solidity >=0.4.24;


interface IStakingRewards {
    function lastTimeRewardApplicable(uint256 _id) external view returns (uint256);

    function rewardPerToken(uint256 _id) external view returns (uint256);

    function earned(uint256 _id, address account) external view returns (uint256);

    function getRewardForDuration(uint256 _id) external view returns (uint256);

    function totalSupply(uint256 _id) external view returns (uint256);

    function balanceOf(uint256 _id, address account) external view returns (uint256);


    function stake(uint256 _id, uint256 amount) external;

    function withdraw(uint256 _id, uint256 amount) external;

    function getReward(uint256 _id) external;
    
    function initPool(uint256 _id) external;
}// UNLICENSED
pragma solidity ^0.8.0;



contract DeFineStakingPool is IERC1155Receiver, IStakingRewards, ReentrancyGuard, Governable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private _counter;
    
    struct Badge {
        address tokenAddress;
        uint256 tokenId;
        uint256 _type; //1155 for 1155;
        uint256 multiplier;
    }

    struct Pool {
        bool isInitialized;
        uint256 id;
        uint256 periodStart;
        uint256 periodFinish;
        uint256 rewardsDuration;
        uint256 rewardRate;
        uint256 totalReward;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        uint256 _totalSupply;
        uint256 _weightedTotalSupply;
        uint256 maxCount;
        uint256 maxCountPerUser;
        IERC20 rewardsToken;
        IERC20 stakingToken;
        mapping(address => uint256) _balances;
        mapping(address => uint256) _weightedBalances;
        mapping(address => uint256) userRewardPerTokenPaid;
        mapping(address => uint256) rewards;
        mapping(address => Badge[]) stakedBadges;
        mapping(address => uint256) userMultiplier;
    }
    
    mapping(uint256 => Pool) private Pools; // poolId -> Pool
    mapping(uint256 => mapping(address => mapping(uint256 => Badge))) private Badges; //poolid => token address => tokenId => Badge

    constructor(){
        super.initialize(msg.sender);
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external override pure returns(bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
    
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override pure returns (bytes4) {
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == this.supportsInterface.selector;
    }
    
    function createPool(
        uint256 periodStart,
        uint256 periodFinish,
        address rewardsToken,
        address stakingToken,
        uint256 totalReward,
        uint256 maxCount,
        uint256 maxCountPerUser) external governance returns (uint256) {
            require(periodStart < periodFinish, "Start time past.");
            _counter++;
            Pool storage pool = Pools[_counter];
            
            pool.id = _counter;
            pool.isInitialized = false;
            pool.periodStart = periodStart;
            pool.periodFinish = periodFinish;
            pool.rewardsDuration = periodFinish.sub(periodStart);

            pool.lastUpdateTime = periodStart;
            pool.totalReward = totalReward;

            pool.maxCount = maxCount;
            pool.maxCountPerUser = maxCountPerUser;

            pool.rewardsToken = IERC20(rewardsToken);
            pool.stakingToken = IERC20(stakingToken);
            
            emit PoolCreated(pool.id, periodStart, periodFinish, totalReward, maxCount, maxCountPerUser, rewardsToken, stakingToken);
            return _counter;
        }
        
    function initBadge(
        uint256 _id,
        address tokenAddress,
        uint256 tokenId,
        uint256 _type, // 1155 for ERC1155
        uint256 multiplier
        ) external governance poolNotInitialized(_id) returns (bool) {
            require(_type == 1155, "Invalid Badge Type");
            require((Badges[_id][tokenAddress][tokenId].tokenAddress != tokenAddress) && (Badges[_id][tokenAddress][tokenId].tokenId != tokenId), "ERC1155 Duplicated");

            Badge memory badge = Badge(
                tokenAddress,
                tokenId,
                _type,
                multiplier);
            
            Badges[_id][tokenAddress][tokenId] = badge;
            
            emit BadgeAdded(_id, badge);
            return true;
        }
        
    function initPool(uint256 _id) override governance external poolNotInitialized (_id) {
        if (Pools[_id].periodStart < block.timestamp) {
            Pools[_id].periodStart = block.timestamp;
            Pools[_id].lastUpdateTime = block.timestamp;
            Pools[_id].rewardsDuration = Pools[_id].periodFinish - Pools[_id].periodStart;
        }
        Pools[_id].rewardRate = Pools[_id].totalReward.div(Pools[_id].rewardsDuration);
        Pools[_id].isInitialized = true;
        Pools[_id].rewardsToken.safeTransferFrom(msg.sender, address(this), Pools[_id].totalReward);
    }
    

    function totalSupply(uint256 _id) external override view returns (uint256) {
        return Pools[_id]._totalSupply;
    }

    function balanceOf(uint256 _id, address account) external override view returns (uint256) {
        return Pools[_id]._balances[account];
    }

    function lastTimeRewardApplicable(uint256 _id) public override view returns (uint256) {
        return Math.min(block.timestamp, Pools[_id].periodFinish);
    }

    function rewardPerToken(uint256 _id) public override view returns (uint256) {
        if (Pools[_id]._totalSupply == 0) {
            return Pools[_id].rewardPerTokenStored;
        }
        return
            Pools[_id].rewardPerTokenStored.add(
                lastTimeRewardApplicable(_id).sub(Pools[_id].lastUpdateTime).mul(Pools[_id].rewardRate).mul(1e18).div(Pools[_id]._weightedTotalSupply)
            );
    }

    function earned(uint256 _id, address account) public override view returns (uint256) {
        return Pools[_id]._weightedBalances[account].mul(rewardPerToken(_id).sub(Pools[_id].userRewardPerTokenPaid[account])).div(1e18).add(Pools[_id].rewards[account]);
    }

    function getRewardForDuration(uint256 _id) external override view returns (uint256) {
        return Pools[_id].rewardRate.mul(Pools[_id].rewardsDuration);
    }
    
    function whetherToStake(uint256 _id, Badge memory _badge) public view returns (bool) { // stakingBadge: badges going to be staked
        Badge[] memory badge = Pools[_id].stakedBadges[msg.sender]; // already staked badges
        if (badge.length > 0) {
            for (uint256 i = 0; i < badge.length; i++) {
                if ((badge[i].tokenAddress == _badge.tokenAddress && badge[i].tokenId == _badge.tokenId)) {
                    return false;
                }
            }
        }
        return true;
    }
    
    function setPoolStartTime(uint256 _id, uint256 _time) external governance payable poolNotInitialized(_id) returns (bool) {
        Pools[_id].periodStart = _time;
        Pools[_id].rewardsDuration = Pools[_id].periodFinish - Pools[_id].periodStart;
        return true;
    }
    
    function setPoolEndTime(uint256 _id, uint256 _time) external governance payable poolNotInitialized(_id) returns (bool) {
        Pools[_id].periodFinish = _time;
        Pools[_id].rewardsDuration = Pools[_id].periodFinish - Pools[_id].periodStart;
        return true;
    }
    
    function setRewardsToken(uint256 _id, address _address) external governance payable poolNotInitialized(_id) returns (bool) {
        Pools[_id].rewardsToken = IERC20(_address);
        return true;
    }
    
    function setStakingToken(uint256 _id, address _address) external governance payable poolNotInitialized(_id) returns (bool) {
        Pools[_id].stakingToken = IERC20(_address);
        return true;
    }

    function stake(uint256 _id, uint256 amount) override external nonReentrant poolInitialized (_id) poolIsNotFinished(_id) updateReward(msg.sender, _id) {
        require(amount > 0, "Cant stake 0");
        if (Pools[_id].userMultiplier[msg.sender] == 0) {
            Pools[_id].userMultiplier[msg.sender] = 1;
        }

        Pools[_id]._totalSupply = Pools[_id]._totalSupply.add(amount);
        require(Pools[_id]._totalSupply < Pools[_id].maxCount, "Pool is full");

        Pools[_id]._weightedTotalSupply = Pools[_id]._weightedTotalSupply.add(amount.mul(Pools[_id].userMultiplier[msg.sender]));
        
        require(Pools[_id]._balances[msg.sender].add(amount) <= Pools[_id].maxCountPerUser, "user max count reached");
        Pools[_id]._balances[msg.sender] = Pools[_id]._balances[msg.sender].add(amount);
        Pools[_id]._weightedBalances[msg.sender] = Pools[_id]._weightedBalances[msg.sender].add(amount.mul(Pools[_id].userMultiplier[msg.sender]));
        
        Pools[_id].stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, _id, amount);
    }

    function withdraw(uint256 _id, uint256 amount) override public nonReentrant poolInitialized (_id) updateReward(msg.sender, _id) {
        require(amount > 0, "Cant withdraw 0");
        uint256 weightedAmount = amount.mul(Pools[_id].userMultiplier[msg.sender]);

        Pools[_id]._totalSupply = Pools[_id]._totalSupply.sub(amount);
        Pools[_id]._weightedTotalSupply = Pools[_id]._weightedTotalSupply.sub(weightedAmount);
         
        Pools[_id]._balances[msg.sender] = Pools[_id]._balances[msg.sender].sub(amount);
        Pools[_id]._weightedBalances[msg.sender] = Pools[_id]._weightedBalances[msg.sender].sub(weightedAmount);
        
        Pools[_id].stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, _id, amount);
    }

    function getReward(uint256 _id) override public nonReentrant poolInitialized (_id) updateReward(msg.sender, _id) {
        uint256 reward = Pools[_id].rewards[msg.sender];
        if (reward > 0) {
            Pools[_id].rewards[msg.sender] = 0;
            Pools[_id].rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, _id, reward);
        }
    }
    
    function stakeBadge(uint256 _id, address _badge, uint256 _tokenId, uint256 _type) public nonReentrant poolIsNotFinished(_id) updateReward(msg.sender, _id) {
        require(_type == 1155, "illegal type.");
        
        uint256 multiplier = Badges[_id][_badge][_tokenId].multiplier;
        require(multiplier > 0, "Badge illegal");
        Badge memory badge = Badge(_badge, _tokenId, _type, multiplier);
        require(whetherToStake(_id, badge) == true, "Badge Duplicated");
        
        IERC1155(_badge).safeTransferFrom(msg.sender, address(this), _tokenId, 1, "");
        Pools[_id].stakedBadges[msg.sender].push(badge);
        
        if (Pools[_id].userMultiplier[msg.sender] == 1) {
            Pools[_id].userMultiplier[msg.sender] = multiplier;
        } else {
            Pools[_id].userMultiplier[msg.sender] = Pools[_id].userMultiplier[msg.sender].add(multiplier);
        }
        
        uint256 newWeightedBalance = Pools[_id]._balances[msg.sender].mul(Pools[_id].userMultiplier[msg.sender]);
        Pools[_id]._weightedTotalSupply = Pools[_id]._weightedTotalSupply.sub(Pools[_id]._weightedBalances[msg.sender]).add(newWeightedBalance);
        Pools[_id]._weightedBalances[msg.sender] = newWeightedBalance;

        emit BadgeStaked(msg.sender, _id, badge);
    }
    
    function unstakeBadge(uint256 _id, address _badge, uint256 _tokenId, uint256 _type) public nonReentrant updateReward(msg.sender, _id) {
        require(_type == 1155, "illegal type");
        
        require(Pools[_id].stakedBadges[msg.sender].length > 0, "Not staked");
        Badge[] memory stakedBadges = Pools[_id].stakedBadges[msg.sender];
        Badge memory badge = Badge(_badge, _tokenId, _type, Badges[_id][_badge][_tokenId].multiplier);
        bool badgeUnstaked = false;
        
        for (uint256 i = 0; i < stakedBadges.length; i++) {
            if (stakedBadges[i].tokenAddress == _badge && stakedBadges[i].tokenId == _tokenId) {
                IERC1155(_badge).safeTransferFrom(address(this), msg.sender, _tokenId, 1, "");
                badgeUnstaked = true;
                delete Pools[_id].stakedBadges[msg.sender][i];
                break;
            }
        }
        
        require(badgeUnstaked == true, "Badge not staked.");

        if (Pools[_id].userMultiplier[msg.sender] != 1) {
            Pools[_id].userMultiplier[msg.sender] = Pools[_id].userMultiplier[msg.sender].sub((Badges[_id][_badge][_tokenId].multiplier));
            if (Pools[_id].userMultiplier[msg.sender] == 0) {
                Pools[_id].userMultiplier[msg.sender] = 1;
            }
        }
        
        uint256 newWeightedBalance = Pools[_id]._balances[msg.sender].mul(Pools[_id].userMultiplier[msg.sender]);
        
        Pools[_id]._weightedTotalSupply = Pools[_id]._weightedTotalSupply.sub(Pools[_id]._weightedBalances[msg.sender]).add(newWeightedBalance);
        Pools[_id]._weightedBalances[msg.sender] = newWeightedBalance;
        
        emit BadgeUnstaked(msg.sender, _id, badge);
    }

    modifier updateReward(address account, uint256 _id) {
        if (block.timestamp >= Pools[_id].periodStart) {
             Pools[_id].rewardPerTokenStored = rewardPerToken(_id);
            Pools[_id].lastUpdateTime = lastTimeRewardApplicable(_id);
            if (account != address(0)) {
                Pools[_id].rewards[account] = earned(_id, account);
                Pools[_id].userRewardPerTokenPaid[account] = Pools[_id].rewardPerTokenStored;
            }
        }
        _;
    }

    modifier poolNotInitialized(uint256 _id) {
        require(_id <= _counter && _id > 0, "Invalid pool id");
        require(Pools[_id].isInitialized == false, 'Pool inited.');
        _;
    }

    modifier poolInitialized(uint256 _id) {
        require(_id <= _counter && _id > 0, "Invalid pool id");
        require(Pools[_id].isInitialized == true, 'Not inited.');
        _;
    }
    
    modifier poolIsNotFinished(uint256 _id) {
        require(Pools[_id].periodFinish > block.timestamp, "Pool finished.");
        _;
    }

    event PoolCreated(uint256 _id, uint256 _periodStart, uint256 _periodFinish, uint256 _totalReward, uint256 _maxCount, uint256 _maxCountPerUser, address _rewardsToken, address _stakingToken);
    event BadgeAdded(uint256 id, Badge badge);
    event PoolInitialized(uint256 _id);
    event Staked(address indexed user, uint256 id, uint256 amount);
    event Withdrawn(address indexed user, uint256 id, uint256 amount);
    event RewardPaid(address indexed user, uint256 id, uint256 reward);
    event BadgeStaked(address indexed user, uint256 id, Badge badge);
    event BadgeUnstaked(address indexed user, uint256 id, Badge badge);
}