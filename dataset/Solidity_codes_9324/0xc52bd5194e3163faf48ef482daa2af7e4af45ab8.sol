



pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}




pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}




pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}



pragma solidity ^0.8.0;

library IterableMapping {

  struct Map {
    address[] keys;
    mapping(address => uint256) values;
    mapping(address => uint256) indexOf;
    mapping(address => bool) inserted;
  }

  function get(Map storage map, address key) public view returns (uint256) {

    return map.values[key];
  }

  function getIndexOfKey(Map storage map, address key)
    public
    view
    returns (int256)
  {

    if (!map.inserted[key]) {
      return -1;
    }
    return int256(map.indexOf[key]);
  }

  function getKeyAtIndex(Map storage map, uint256 index)
    public
    view
    returns (address)
  {

    return map.keys[index];
  }

  function size(Map storage map) public view returns (uint256) {

    return map.keys.length;
  }

  function set(
    Map storage map,
    address key,
    uint256 val
  ) public {

    if (map.inserted[key]) {
      map.values[key] = val;
    } else {
      map.inserted[key] = true;
      map.values[key] = val;
      map.indexOf[key] = map.keys.length;
      map.keys.push(key);
    }
  }

  function remove(Map storage map, address key) public {

    if (!map.inserted[key]) {
      return;
    }

    delete map.inserted[key];
    delete map.values[key];

    uint256 index = map.indexOf[key];
    uint256 lastIndex = map.keys.length - 1;
    address lastKey = map.keys[lastIndex];

    map.indexOf[lastKey] = index;
    delete map.indexOf[key];

    map.keys[index] = lastKey;
    map.keys.pop();
  }
}




pragma solidity >=0.5.0;

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


pragma solidity ^0.8.0;

interface INodeManager {

  struct NodeEntity {
    string name;
    uint256 creationTime;
    uint256 lastClaimTime;
    uint256 amount;
    uint256 tier;
    uint256 totalClaimed;
  }

  function getNodePrice(uint256 _tierIndex) external view returns (uint256);


  function createNode(
    address account,
    string memory nodeName,
    uint256 tier
  ) external;


  function getNodeReward(address account, uint256 _creationTime)
    external
    view
    returns (uint256);


  function getAllNodesRewards(address account) external view returns (uint256);


  function cashoutNodeReward(address account, uint256 _creationTime) external;


  function cashoutAllNodesRewards(address account) external;


  function getAllNodes(address account)
    external
    view
    returns (NodeEntity[] memory);


  function getNodeFee(
    address account,
    uint256 _creationTime,
    uint256 _rewardAmount
  ) external returns (uint256);


  function getAllNodesFee(address account, uint256 _rewardAmount)
    external
    returns (uint256);

}



pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}



pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}



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
}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




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








contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}




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
}




pragma solidity ^0.8.0;




contract PaymentSplitter is Context {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    mapping(IERC20 => uint256) private _erc20TotalReleased;
    mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    function totalReleased(IERC20 token) public view returns (uint256) {
        return _erc20TotalReleased[token];
    }

    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    function released(IERC20 token, address account) public view returns (uint256) {
        return _erc20Released[token][account];
    }

    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    function release(address payable account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(account, totalReceived, released(account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    function release(IERC20 token, address account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);
        uint256 payment = _pendingPayment(account, totalReceived, released(token, account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _erc20Released[token][account] += payment;
        _erc20TotalReleased[token] += payment;

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }

    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {
        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }
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




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




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
}




pragma solidity ^0.8.4;


library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}


pragma solidity >=0.8.0;









contract Molecules is ERC721, Ownable {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    address private _owner;
    address private _royaltiesAddr; // royality receiver
    uint256 public royaltyPercentage; // royalty based on sales price
    mapping(address => bool) public excludedList; // list of people who dont have to pay fee

    uint256 public mintFeeAmount;

    string public baseURL;

    uint256 public unbondingTime = 604800;

    uint256 public constant maxSupply = 1000;

    bool public openForPublic;

    struct Molecule {
        uint256 tokenId;
        address mintedBy;
        address currentOwner;
        uint256 previousPrice;
        uint256 price;
        uint256 numberOfTransfers;
        bool forSale;
        bool bonded;
        uint256 kind;
        uint256 level;
        uint256 lastUpgradeTime;
        uint256 bondedTime;
    }

    

    mapping(uint256 => Molecule) public allMolecules;

    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;


    event SaleToggle(uint256 moleculeNumber, bool isForSale, uint256 price);
    event PurchaseEvent(uint256 moleculeNumber, address from, address to, uint256 price);
    event moleculeBonded(uint256 moleculeNumber, address owner, uint256 NodeCreationTime);
    event moleculeUnbonded(uint256 moleculeNumber, address owner, uint256 NodeCreationTime);   
    event moleculeGrown(uint256 moleculeNumber, uint256 newLevel); 

    constructor(
        address _contractOwner,
        address _royaltyReceiver,
        uint256 _royaltyPercentage,
        uint256 _mintFeeAmount,
        string memory _baseURL,
        bool _openForPublic
    ) ERC721("Molecules","M") Ownable() {
        royaltyPercentage = _royaltyPercentage;
        _owner = _contractOwner;
        _royaltiesAddr = _royaltyReceiver;
        mintFeeAmount = _mintFeeAmount.mul(1e18);
        excludedList[_contractOwner] = true; // add owner to exclude list
        excludedList[_royaltyReceiver] = true; // add artist to exclude list
        baseURL = _baseURL;
        openForPublic = _openForPublic;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(uint256 numberOfToken) public payable {
        require(openForPublic == true, "not open");
        require(msg.sender != address(0));
        require(
            _allTokens.length + numberOfToken <= maxSupply,
            "max supply"
        );
        require(numberOfToken > 0, "Min 1");
        require(numberOfToken <= 3, "Max 3");
        uint256 price = 0;
        if (excludedList[msg.sender] == false) {
            price = mintFeeAmount * numberOfToken;
            require(msg.value >= price, "Not enough fee");
            payable(_royaltiesAddr).transfer(msg.value);
        } else {
            payable(msg.sender).transfer(msg.value);
        }
        uint256 newPrice = mintFeeAmount;

        for (uint256 i = 1; i <= numberOfToken; i++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _safeMint(msg.sender, newItemId);
            Molecule memory newMolecule = Molecule(
                newItemId,
                msg.sender,
                msg.sender,
                mintFeeAmount,
                0,
                0,
                false,
                false,
                0,
                1,
                0,
                0
            );
            allMolecules[newItemId] = newMolecule;
            if (newItemId%200 == 0){
                uint256 addPrice = 5;
                newPrice += addPrice.mul(1e17);
            }
        }
        mintFeeAmount = newPrice;
    }

    function changeUrl(string memory url) external onlyOwner {
        baseURL = url;
    }

    function setMoleculeKind(uint256[] memory _tokens, uint256[] memory _kinds) external onlyOwner{
        require(_tokens.length > 0, "lists can't be empty");
        require(_tokens.length == _kinds.length, "both lists should have same length");
        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_exists(_tokens[i]), "token not found");
            Molecule memory mol = allMolecules[_tokens[i]];
            mol.kind = _kinds[i];
            allMolecules[_tokens[i]] = mol;
        }
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }


    function setPriceForSale(
        uint256 _tokenId,
        uint256 _newPrice,
        bool isForSale
    ) external {
        require(_exists(_tokenId), "token not found");
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == msg.sender, "not owner");
        Molecule memory mol = allMolecules[_tokenId];
        require(mol.bonded == false);
        mol.price = _newPrice;
        mol.forSale = isForSale;
        allMolecules[_tokenId] = mol;
        emit SaleToggle(_tokenId, isForSale, _newPrice);
    }

    function getAllSaleTokens() public view returns (uint256[] memory) {
        uint256 _totalSupply = totalSupply();
        uint256[] memory _tokenForSales = new uint256[](_totalSupply);
        uint256 counter = 0;
        for (uint256 i = 1; i <= _totalSupply; i++) {
            if (allMolecules[i].forSale == true) {
                _tokenForSales[counter] = allMolecules[i].tokenId;
                counter++;
            }
        }
        return _tokenForSales;
    }

    function buyToken(uint256 _tokenId) public payable {
        require(_exists(_tokenId));
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner != address(0));
        require(tokenOwner != msg.sender);
        Molecule memory mol = allMolecules[_tokenId];
        require(msg.value >= mol.price);
        require(mol.forSale);
        uint256 amount = msg.value;
        uint256 _royaltiesAmount = amount.mul(royaltyPercentage).div(100);
        uint256 payOwnerAmount = amount.sub(_royaltiesAmount);
        payable(_royaltiesAddr).transfer(_royaltiesAmount);
        payable(mol.currentOwner).transfer(payOwnerAmount);
        require(mol.bonded == false, "Molecule is Bonded");
        mol.previousPrice = mol.price;
        mol.bonded = false;
        mol.numberOfTransfers += 1;
        mol.price = 0;
        mol.forSale = false;
        allMolecules[_tokenId] = mol;
        _transfer(tokenOwner, msg.sender, _tokenId);
        emit PurchaseEvent(_tokenId, mol.currentOwner, msg.sender, mol.price);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        returns (uint256)
    {
        require(index < balanceOf(owner), "out of bounds");
        return _ownedTokens[owner][index];
    }

    function _baseURI()
        internal
        view
        virtual
        override(ERC721)
        returns (string memory)
    {
        return baseURL;
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721) {
        super._beforeTokenTransfer(from, to, tokenId);
        Molecule memory mol = allMolecules[tokenId];
        require(mol.bonded == false,"Molecule is bonded!");
        mol.currentOwner = to;
        mol.numberOfTransfers += 1;
        mol.forSale = false;
        allMolecules[tokenId] = mol;
        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {
        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }


    mapping(address => bool) public authorized;

    modifier onlyAuthorized() {
        require(authorized[msg.sender] ||  msg.sender == _owner , "Not authorized");
        _;
    }

    function addAuthorized(address _toAdd) public {
        require(msg.sender == _owner, 'Not owner');
        require(_toAdd != address(0));
        authorized[_toAdd] = true;
    }

    function removeAuthorized(address _toRemove) public {
        require(msg.sender == _owner, 'Not owner');
        require(_toRemove != address(0));
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;
    }


    function bondMolecule(address account,uint256 _tokenId, uint256 nodeCreationTime) external onlyAuthorized {
        require(_exists(_tokenId), "token not found");
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == account, "not owner");
        Molecule memory mol = allMolecules[_tokenId];
        require(mol.bonded == false, "Molecule already bonded");
        mol.bonded = true;
        allMolecules[_tokenId] = mol;
        emit moleculeBonded(_tokenId, account, nodeCreationTime);
    }

    function unbondMolecule(address account,uint256 _tokenId, uint256 nodeCreationTime) external onlyAuthorized {
        require(_exists(_tokenId), "token not found");
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == account, "not owner");
        Molecule memory mol = allMolecules[_tokenId];
        require(mol.bonded == true, "Molecule not bonded");
        require(mol.bondedTime + unbondingTime > block.timestamp, "You have to wait 7 days from bonding to unbond");
        mol.bonded = false;
        allMolecules[_tokenId] = mol;
        emit moleculeUnbonded(_tokenId, account, nodeCreationTime);
    }

    function growMolecule(uint256 _tokenId) external onlyAuthorized {
        require(_exists(_tokenId), "token not found");
        Molecule memory mol = allMolecules[_tokenId];
        mol.level += 1;
        allMolecules[_tokenId] = mol;
        emit moleculeGrown(_tokenId, mol.level);
    }

    function getMoleculeLevel(uint256 _tokenId) public view returns(uint256){
        Molecule memory mol = allMolecules[_tokenId];
        return mol.level;
    }

    function getMoleculeKind(uint256 _tokenId) public view returns(uint256) {
        Molecule memory mol = allMolecules[_tokenId];
        return mol.kind;
    }





}


pragma solidity ^0.8.4;






contract NodeManager is Ownable, Pausable {
  using SafeMath for uint256;
  using IterableMapping for IterableMapping.Map;

  struct NodeEntity {
    string name;
    uint256 creationTime;
    uint256 lastClaimTime;
    uint256 amount;
    uint256 tier;
    uint256 totalClaimed;
    uint256 borrowedRewards;
    uint256[3] bondedMolecules; // tokenId of bonded molecules
    uint256 bondedMols; //number of molecules bonded
  }

  IterableMapping.Map private nodeOwners;
  mapping(address => NodeEntity[]) private _nodesOfUser;

  Molecules public molecules;

  address public token;
  uint256 public totalNodesCreated = 0;
  uint256 public totalStaked = 0;
  uint256 public totalClaimed = 0;

  uint256 public levelMultiplier = 250; // bps 250 = 2.5%

  uint256[] public _tiersPrice = [1, 6, 20, 50, 150];
  uint256[] public _tiersRewards = [1250,8000,30000,87500,300000]; // 10000 => 1 OXG
  uint256[] public _boostMultipliers = [102, 105, 110, 130, 200]; // %
  uint256[] public _boostRequiredDays = [35, 56, 84, 183, 365]; // days
  uint256[] public _paperHandsTaxes = [150, 100, 40, 0]; // %; 10 => 1
  uint256[] public _paperHandsWeeks = [1, 2, 3, 4]; // weeks
  uint256[] public _claimTaxFees = [8, 8, 8, 8, 8]; // %, match with tiers



  event NodeCreated(
    address indexed account,
    uint256 indexed blockTime,
    uint256 indexed amount
  );

  event NodeBondedToMolecule(
    address account,
    uint256 tokenID,
    uint256 nodeCreationTime
  );

  event NodeUnbondedToMolecule(
    address account,
    uint256 tokenID,
    uint256 nodeCreationTime
  );

  modifier onlyGuard() {
    require(owner() == _msgSender() || token == _msgSender(), "NOT_GUARD");
    _;
  }

  constructor() {}



  function _isNameAvailable(address account, string memory nodeName)
    private
    view
    returns (bool)
  {
    NodeEntity[] memory nodes = _nodesOfUser[account];
    for (uint256 i = 0; i < nodes.length; i++) {
      if (keccak256(bytes(nodes[i].name)) == keccak256(bytes(nodeName))) {
        return false;
      }
    }
    return true;
  }

  function _getNodeWithCreatime(
    NodeEntity[] storage nodes,
    uint256 _creationTime
  ) private view returns (NodeEntity storage) {
    uint256 numberOfNodes = nodes.length;
    require(
      numberOfNodes > 0,
      "CASHOUT ERROR: You don't have nodes to cash-out"
    );
    bool found = false;
    int256 index = _binarySearch(nodes, 0, numberOfNodes, _creationTime);
    uint256 validIndex;
    if (index >= 0) {
      found = true;
      validIndex = uint256(index);
    }
    require(found, "NODE SEARCH: No NODE Found with this blocktime");
    return nodes[validIndex];
  }

  function _binarySearch(
    NodeEntity[] memory arr,
    uint256 low,
    uint256 high,
    uint256 x
  ) private view returns (int256) {
    if (high >= low) {
      uint256 mid = (high + low).div(2);
      if (arr[mid].creationTime == x) {
        return int256(mid);
      } else if (arr[mid].creationTime > x) {
        return _binarySearch(arr, low, mid - 1, x);
      } else {
        return _binarySearch(arr, mid + 1, high, x);
      }
    } else {
      return -1;
    }
  }

  
  function _uint2str(uint256 _i)
    private
    pure
    returns (string memory _uintAsString)
  {
    if (_i == 0) {
      return "0";
    }
    uint256 j = _i;
    uint256 len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len;
    while (_i != 0) {
      k = k - 1;
      uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
      bytes1 b1 = bytes1(temp);
      bstr[k] = b1;
      _i /= 10;
    }
    return string(bstr);
  }

  function _calculateNodeRewards(
    uint256 _lastClaimTime,
    uint256 _tier
  ) private view returns (uint256 rewards) {
    uint256 elapsedTime_ = (block.timestamp - _lastClaimTime);
    uint256 boostMultiplier = _calculateBoost(elapsedTime_);
    uint256 rewardPerMonth = _tiersRewards[_tier];
    return
      rewardPerMonth.mul(1e18).div(2628000).mul(elapsedTime_).mul(boostMultiplier).div(100).div(10000);
  }

  function _calculateBoost(uint256 elapsedTime_)
    internal
    view
    returns (uint256)
  {
    uint256 elapsedTimeInDays_ = elapsedTime_ / 1 days;

    if (elapsedTimeInDays_ >= _boostRequiredDays[4]) {
      return _boostMultipliers[4];
    } else if (elapsedTimeInDays_ >= _boostRequiredDays[3]) {
      return _boostMultipliers[3];
    } else if (elapsedTimeInDays_ >= _boostRequiredDays[2]) {
      return _boostMultipliers[2];
    } else if (elapsedTimeInDays_ >= _boostRequiredDays[1]) {
      return _boostMultipliers[1];
    } else if (elapsedTimeInDays_ >= _boostRequiredDays[0]) {
      return _boostMultipliers[0];
    } else {
      return 100;
    }
  }


   function upgradeNode(address account, uint256 blocktime) 
    external
    onlyGuard
    whenNotPaused
    {
        require(blocktime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        require(
            nodes.length > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
            );
        NodeEntity storage node = _getNodeWithCreatime(nodes, blocktime);
        node.tier += 1;
    }

    function borrowRewards(address account, uint256 blocktime, uint256 amount)
    external
    onlyGuard
    whenNotPaused
    {
        require(blocktime > 0, "NODE: blocktime must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        require(
            nodes.length > 0,
            "You don't have any nodes"
        );
        NodeEntity storage node = _getNodeWithCreatime(nodes, blocktime);
        uint256 rewardsAvailable = _calculateNodeRewards(node.lastClaimTime, node.tier).sub(node.borrowedRewards);
        require(rewardsAvailable >= amount,"You do not have enough rewards available");
        node.borrowedRewards += amount;
    }

  function createNode(
    address account,
    string memory nodeName,
    uint256 _tier
  ) external onlyGuard whenNotPaused {
    require(_isNameAvailable(account, nodeName), "Name not available");
    NodeEntity[] storage _nodes = _nodesOfUser[account];
    require(_nodes.length <= 100, "Max nodes exceeded");
    uint256 amount = getNodePrice(_tier);
    _nodes.push(
      NodeEntity({
        name: nodeName,
        creationTime: block.timestamp,
        lastClaimTime: block.timestamp,
        amount: amount,
        tier: _tier,
        totalClaimed: 0,
        borrowedRewards: 0,
        bondedMolecules: [uint256(0),0,0],
        bondedMols: 0
      })
    );
    nodeOwners.set(account, _nodesOfUser[account].length);
    emit NodeCreated(account, block.timestamp, amount);
    totalNodesCreated++;
    totalStaked += amount;
  }

  function getNodeReward(address account, uint256 _creationTime)
    public
    view
    returns (uint256)
  {
    require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    require(
      nodes.length > 0,
      "CASHOUT ERROR: You don't have nodes to cash-out"
    );
    NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
    return _calculateNodeRewards(node.lastClaimTime, node.tier).mul(getNodeAPRIncrease(account, _creationTime)).div(10000).sub(node.borrowedRewards);
  }

  function getAllNodesRewards(address account) external view returns (uint256[2] memory) {
    NodeEntity[] storage nodes = _nodesOfUser[account];
    uint256 nodesCount = nodes.length;
    require(nodesCount > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity storage _node;
    uint256 rewardsTotal = 0;
    uint256 taxTotal = 0;
    for (uint256 i = 0; i < nodesCount; i++) {
      _node = nodes[i];
      uint256 nodeReward =  _calculateNodeRewards(
        _node.lastClaimTime,
        _node.tier
      ).sub(_node.borrowedRewards);
      nodeReward = nodeReward;
      taxTotal += getNodeFee(account, _node.creationTime, nodeReward);
      rewardsTotal += nodeReward;
    }
    return [rewardsTotal, taxTotal];
  }

  function cashoutNodeReward(address account, uint256 _creationTime)
    external
    onlyGuard
    whenNotPaused
  {
    require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    require(
      nodes.length > 0,
      "CASHOUT ERROR: You don't have nodes to cash-out"
    );
    NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
    uint256 toClaim = _calculateNodeRewards(
      node.lastClaimTime,
      node.tier
    ).sub(node.borrowedRewards);
    node.totalClaimed += toClaim;
    node.lastClaimTime = block.timestamp;
    node.borrowedRewards = 0;
  }

  function cashoutAllNodesRewards(address account)
    external
    onlyGuard
    whenNotPaused 
  {
    NodeEntity[] storage nodes = _nodesOfUser[account];
    uint256 nodesCount = nodes.length;
    require(nodesCount > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity storage _node;
    for (uint256 i = 0; i < nodesCount; i++) {
      _node = nodes[i];  
      uint256 toClaim = _calculateNodeRewards(
        _node.lastClaimTime,
        _node.tier
      ).sub(_node.borrowedRewards);
      _node.totalClaimed += toClaim;
      _node.lastClaimTime = block.timestamp;
      _node.borrowedRewards = 0;
    }
  }

  function setMoleculeAddress(address _moleculesAddress) external onlyOwner {
      molecules = Molecules(_moleculesAddress);
    }



  function bondNFT(uint256 _creationTime, uint256 _tokenId) external {
    address account = _msgSender();
    require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    require(
      nodes.length > 0,
      "You don't own any nodes"
    );
    NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
    require(node.bondedMols < 3,"Already bonded to enough molecules");
    molecules.bondMolecule(account, _tokenId, node.creationTime);
    node.bondedMolecules[node.bondedMols] = _tokenId;
    node.bondedMols += 1;
    emit NodeBondedToMolecule(account, _tokenId, _creationTime);
  }


  function unbondNFT(uint256 _creationTime, uint256 _tokenId) external {
    address account = _msgSender();
    require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    require(
      nodes.length > 0,
      "You don't own any nodes"
    );
    NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
    require(node.bondedMols > 0,"No Molecules Bonded");
    molecules.unbondMolecule(account, _tokenId, node.creationTime);
    uint256[3] memory newArray = [uint256(0),0,0];
    for (uint256 i = 0 ; i < node.bondedMols; i++) {
        if (node.bondedMolecules[i] != _tokenId) {
          newArray[i] = node.bondedMolecules[i];
        }
    }
    node.bondedMolecules = newArray;
    node.bondedMols -= 1;
    emit NodeUnbondedToMolecule(account, _tokenId, _creationTime);
  }

  function getNodesNames(address account) public view returns (string memory) {
    NodeEntity[] memory nodes = _nodesOfUser[account];
    uint256 nodesCount = nodes.length;
    NodeEntity memory _node;
    string memory names = nodes[0].name;
    string memory separator = "#";
    for (uint256 i = 1; i < nodesCount; i++) {
      _node = nodes[i];
      names = string(abi.encodePacked(names, separator, _node.name));
    }
    return names;
  }

  function getNodesRewards(address account) public view returns (string memory) {
    NodeEntity[] memory nodes = _nodesOfUser[account];
    uint256 nodesCount = nodes.length;
    NodeEntity memory _node;
    string memory rewards = _uint2str(_calculateNodeRewards(nodes[0].lastClaimTime, nodes[0].tier).mul(getNodeAPRIncrease(account, nodes[0].creationTime)).div(10000).sub(nodes[0].borrowedRewards));
    string memory separator = "#";
    for (uint256 i = 1; i < nodesCount; i++) {
      _node = nodes[i];
      string memory _rewardStr = _uint2str(_calculateNodeRewards(_node.lastClaimTime, _node.tier).mul(getNodeAPRIncrease(account, _node.creationTime)).div(10000).sub(_node.borrowedRewards));
      rewards = string(abi.encodePacked(rewards, separator, _rewardStr));
    }
    return rewards;
  }

  function getNodesCreationTime(address account)
    public
    view
    returns (string memory)
  {
    NodeEntity[] memory nodes = _nodesOfUser[account];
    uint256 nodesCount = nodes.length;
    NodeEntity memory _node;
    string memory _creationTimes = _uint2str(nodes[0].creationTime);
    string memory separator = "#";

    for (uint256 i = 1; i < nodesCount; i++) {
      _node = nodes[i];

      _creationTimes = string(
        abi.encodePacked(
          _creationTimes,
          separator,
          _uint2str(_node.creationTime)
        )
      );
    }
    return _creationTimes;
  }

  function getNodeAPRIncrease(address account, uint256 _creationTime) public view returns (uint256){
    require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    require(
      nodes.length > 0,
      "You don't own any nodes"
    );
    NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
    if (node.bondedMols == 0){
      uint256 totalApyBenefit = 10000;
      return totalApyBenefit;
    }
    else {
      uint256 totalApyBenefit = 0;
      for (uint256 i = 0; i < node.bondedMols; i++) {
        if (molecules.getMoleculeKind(node.bondedMolecules[i]) == 2 || molecules.getMoleculeKind(node.bondedMolecules[i]) == 3) {
          uint256 APYBenefit = molecules.getMoleculeLevel(node.bondedMolecules[i]).mul(levelMultiplier).add(250);
          totalApyBenefit += APYBenefit;
        }
      }
      totalApyBenefit += 10000;
      return totalApyBenefit;
    }
  }

  
  function getNodeTaxDecrease(address account, uint256 _creationTime) public view returns (uint256){
    require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    require(
      nodes.length > 0,
      "You don't own any nodes"
    );
    NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
    if (node.bondedMols == 0){
      uint256 totalTaxDecrease = 0;
      return totalTaxDecrease;
    }
    else {
      uint256 totalTaxDecrease = 0;
      for (uint256 i = 0; i < node.bondedMols; i++) {
        if (molecules.getMoleculeKind(node.bondedMolecules[i]) == 1 || molecules.getMoleculeKind(node.bondedMolecules[i]) == 3) {
          uint256 APYBenefit = molecules.getMoleculeLevel(node.bondedMolecules[i]).mul(levelMultiplier).add(250);
          totalTaxDecrease += APYBenefit;
        }
      }
      if (totalTaxDecrease > 10000) {
        totalTaxDecrease = 10000;
      }
      return totalTaxDecrease;
    }
  }


  function getNodesLastClaimTime(address account)
    public
    view
    returns (string memory)
  {
    NodeEntity[] memory nodes = _nodesOfUser[account];
    uint256 nodesCount = nodes.length;
    NodeEntity memory _node;
    string memory _lastClaimTimes = _uint2str(nodes[0].lastClaimTime);
    string memory separator = "#";

    for (uint256 i = 1; i < nodesCount; i++) {
      _node = nodes[i];

      _lastClaimTimes = string(
        abi.encodePacked(
          _lastClaimTimes,
          separator,
          _uint2str(_node.lastClaimTime)
        )
      );
    }
    return _lastClaimTimes;
  }

  function getNodeFee(
    address account,
    uint256 _creationTime,
    uint256 _rewardsAmount
  ) public view returns (uint256) {
    require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    require(
      nodes.length > 0,
      "CASHOUT ERROR: You don't have nodes to cash-out"
    );
    NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);

    uint256 paperHandsTax = 0;
    uint256 claimTx = _rewardsAmount.mul(_claimTaxFees[node.tier]).div(100);

    uint256 elapsedSeconds = block.timestamp - node.lastClaimTime;

    if (elapsedSeconds >= _paperHandsWeeks[3].mul(86400).mul(7)) {
      paperHandsTax = _rewardsAmount.mul(_paperHandsTaxes[3]).div(1000);
    } else if (elapsedSeconds >= _paperHandsWeeks[2].mul(86400).mul(7)) {
      paperHandsTax = _rewardsAmount.mul(_paperHandsTaxes[2]).div(1000);
    } else if (elapsedSeconds >= _paperHandsWeeks[1].mul(86400).mul(7)) {
      paperHandsTax = _rewardsAmount.mul(_paperHandsTaxes[1]).div(1000);
    } else if (elapsedSeconds >= _paperHandsWeeks[0].mul(86400).mul(7)) {
      paperHandsTax = _rewardsAmount.mul(_paperHandsTaxes[0]).div(1000);
    } else {
      paperHandsTax = _rewardsAmount.mul(200).div(1000);
    }
    uint256 totalTax = claimTx.add(paperHandsTax);
    uint256 taxRebate = totalTax.mul(getNodeTaxDecrease(account,_creationTime)).div(10000);

    return totalTax.sub(taxRebate);
  }

  function updateToken(address newToken) external onlyOwner {
    token = newToken;
  }

  function updateTiersRewards(uint256[] memory newVal) external onlyOwner {
    require(newVal.length == 5, "Wrong length");
    _tiersRewards = newVal;
  }

  function updateTiersPrice(uint256[] memory newVal) external onlyOwner {
    require(newVal.length == 5, "Wrong length");
    _tiersPrice = newVal;
  }

  function updateBoostMultipliers(uint8[] calldata newVal) external onlyOwner {
    require(newVal.length == 5, "Wrong length");
    _boostMultipliers = newVal;
  }

  function updateBoostRequiredDays(uint8[] calldata newVal) external onlyOwner {
    require(newVal.length == 5, "Wrong length");
    _boostRequiredDays = newVal;
  }

  function getNodeTier(address account, uint256 blocktime) public view returns (uint256) {
    require(blocktime > 0, "Creation Time has to be higher than 0");
    require(isNodeOwner(account), "NOT NODE OWNER");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    uint256 numberOfNodes = nodes.length;
    require(
        numberOfNodes > 0,
        "You don't own any nodes."
    );
    NodeEntity storage node = _getNodeWithCreatime(nodes, blocktime);
    return node.tier;
  }

  function getNodePrice(uint256 _tierIndex) public view returns (uint256) {
    return _tiersPrice[_tierIndex];
  }

  function getNodeNumberOf(address account) external view returns (uint256) {
    return nodeOwners.get(account);
  }

  function isNodeOwner(address account) public view returns (bool) {
    return nodeOwners.get(account) > 0;
  }

  function getNodeMolecules(address account, uint256 blocktime) public view returns (uint256[3] memory) {
    require(blocktime > 0, "Creation Time has to be higher than 0");
    require(isNodeOwner(account), "NOT NODE OWNER");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    uint256 numberOfNodes = nodes.length;
    require(
        numberOfNodes > 0,
        "You don't own any nodes."
    );
    NodeEntity storage node = _getNodeWithCreatime(nodes, blocktime);
    return node.bondedMolecules;
  }

  function getAllNodes(address account)
    external
    view
    returns (NodeEntity[] memory)
  {
    return _nodesOfUser[account];
  }

  function getIndexOfKey(address account)
    external
    view
    onlyOwner
    returns (int256)
  {
    require(account != address(0));
    return nodeOwners.getIndexOfKey(account);
  }

  function burn(uint256 index) external onlyOwner {
    require(index < nodeOwners.size());
    nodeOwners.remove(nodeOwners.getKeyAtIndex(index));
  }


  function changeNodeName(uint256 _creationTime, string memory newName) 
    public 
    {
        address sender = msg.sender;
        require(isNodeOwner(sender), "NOT NODE OWNER");
        NodeEntity[] storage nodes = _nodesOfUser[sender];
        uint256 numberOfNodes = nodes.length;
        require(
            numberOfNodes > 0,
            "You don't own any nodes."
        );
        NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
        node.name = newName;
    }



  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }
}



pragma solidity ^0.8.4;











contract OXG is ERC20, Ownable, PaymentSplitter {
    using SafeMath for uint256;

    NodeManager public nodeManager;
    Molecules public molecules;


    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;
    address public teamPool;
    address public distributionPool;
    address public devPool;
    address public advisorPool;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 public rewardsFee;
    uint256 public liquidityPoolFee;
    uint256 public futurFee;
    uint256 public totalFees;

    uint256 public sellTax = 10;


    uint256 public cashoutFee;

    uint256 private rwSwap;
    uint256 private devShare = 20;
    uint256 private advisorShare = 40;
    bool private swapping = false;
    bool private swapLiquify = true;
    uint256 public swapTokensAmount;
    uint256 public growMultiplier = 2e18; //multiplier for growing molecules e.g. level 1 molecule needs 2 OXG to become a level 2, level 2 needs 4 OXG to become level 3

    bool private tradingOpen = false;
    bool public nodeEnforced = true;
    uint256 private _openTradingBlock = 0;
    uint256 private maxTx = 375;

    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(
        address indexed newLiquidityWallet,
        address indexed oldLiquidityWallet
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor(
        address[] memory payees,
        uint256[] memory shares,
        address uniV2Router
    ) ERC20("Oxy-Fi", "OXY") PaymentSplitter(payees, shares) {

        teamPool = 0xaf4a303E107b47f11F2e744c547885b8A9A4E2F7;
        distributionPool = 0xAD2ea18F968a23a35580CF6Aca562d9F7b380644;
        devPool = 0x1feffA18be68B22A5882f76E180c1666EF667E15;
        advisorPool = 0x457276267e0f0C86a6Ddf3674Cc4f36e067C42e0;

        require(uniV2Router != address(0), "ROUTER CANNOT BE ZERO");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniV2Router);

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        futurFee = 13;
        rewardsFee = 80;
        liquidityPoolFee = 7;
        rwSwap = 25;

        totalFees = rewardsFee.add(liquidityPoolFee).add(futurFee);


        _mint(_msgSender(), 300000e18);

        require(totalSupply() == 300000e18, "CONSTR: totalSupply must equal 300,000");
        swapTokensAmount = 100 * (10**18);
    }

    function setNodeManagement(address nodeManagement) external onlyOwner {
        nodeManager = NodeManager(nodeManagement);
    }

    function setMolecules(address moleculesAddress) external onlyOwner {
        molecules = Molecules(moleculesAddress);
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "TKN: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function updateSwapTokensAmount(uint256 newVal) external onlyOwner {
        swapTokensAmount = newVal;
    }

    function updateFuturWall(address payable wall) external onlyOwner {
        teamPool = wall;
    }

    function updateDevWall(address payable wall) external onlyOwner {
        devPool = wall;
    }

    function updateRewardsWall(address payable wall) external onlyOwner {
        distributionPool = wall;
    }

    function updateRewardsFee(uint256 value) external onlyOwner {
        rewardsFee = value;
        totalFees = rewardsFee.add(liquidityPoolFee).add(futurFee);
    }

    function updateLiquidityFee(uint256 value) external onlyOwner {
        liquidityPoolFee = value;
        totalFees = rewardsFee.add(liquidityPoolFee).add(futurFee);
    }

    function updateFuturFee(uint256 value) external onlyOwner {
        futurFee = value;
        totalFees = rewardsFee.add(liquidityPoolFee).add(futurFee);
    }

    function updateCashoutFee(uint256 value) external onlyOwner {
        cashoutFee = value;
    }

    function updateRwSwapFee(uint256 value) external onlyOwner {
        rwSwap = value;
    }

    function updateSellTax(uint256 value) external onlyOwner {
        sellTax = value;
    }


    function setAutomatedMarketMakerPair(address pair, bool value)
    public
    onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "TKN: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function blacklistMalicious(address account, bool value)
    external
    onlyOwner
    {
        _isBlacklisted[account] = value;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "TKN: Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(
            !_isBlacklisted[from] && !_isBlacklisted[to],
            "Blacklisted address"
        );
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (to == address(uniswapV2Pair) && (from != address(this) && from != owner()) && nodeEnforced){
            require(nodeManager.isNodeOwner(from), "You need to own a node to be able to sell");
            uint256 sellTaxAmount = amount.mul(sellTax).div(100);
            super._transfer(from,address(this), sellTaxAmount);
            amount = amount.sub(sellTaxAmount);
            
        }
        uint256 amount2 = amount;
        if (from != owner() && to != uniswapV2Pair && to != address(uniswapV2Router) && to != address(this) && from != address(this) ) {
            
            if (!tradingOpen) {
                amount2 = amount.div(100);
                super._transfer(from,address(this),amount.sub(amount2));

            }

            if (to != teamPool && to != distributionPool && to != devPool && from != teamPool && from != distributionPool && from != devPool) {
                uint256 walletBalance = balanceOf(address(to));
                require(
                    amount2.add(walletBalance) <= maxTx.mul(1e18), 
                    "STOP TRYING TO BECOME A WHALE. WE KNOW WHO YOU ARE.")
                ;
            }
        }
        super._transfer(from, to, amount2);
    }


    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            distributionPool,
            block.timestamp
        );
    }

    function createNodeWithTokens(string memory name, uint256  tier) public {
        require(
            bytes(name).length > 3 && bytes(name).length < 32,
            "NODE CREATION: NAME SIZE INVALID"
        );
        address sender = _msgSender();
        require(
            sender != address(0),
            "NODE CREATION:  creation from the zero address"
        );
        require(!_isBlacklisted[sender], "NODE CREATION: Blacklisted address");
        require(
            sender != distributionPool,
            "NODE CREATION: futur, dev and rewardsPool cannot create node"
        );
    
        uint256 nodePrice = nodeManager._tiersPrice(tier);
        require(
            balanceOf(sender) >= nodePrice.mul(1e18),
            "NODE CREATION: Balance too low for creation. Try lower tier."
        );
        uint256 contractTokenBalance = balanceOf(address(this));
        bool swapAmountOk = contractTokenBalance >= swapTokensAmount;
        if (
            swapAmountOk &&
            swapLiquify &&
            !swapping &&
            sender != owner() &&
            !automatedMarketMakerPairs[sender]
        ) {
            swapping = true;

            uint256 fdTokens = contractTokenBalance.mul(futurFee).div(100);
            uint256 devTokens = fdTokens.mul(devShare).div(100);
            uint256 advTokens = fdTokens.mul(advisorShare).div(100);
            uint256 teamTokens = fdTokens.sub(devTokens).sub(advTokens);


            uint256 rewardsPoolTokens = contractTokenBalance.mul(rewardsFee).div(100);

            uint256 rewardsTokenstoSwap = rewardsPoolTokens.mul(rwSwap).div(
                100
            );
            
            super._transfer(address(this),distributionPool,rewardsPoolTokens.sub(rewardsTokenstoSwap));

            uint256 swapTokens = contractTokenBalance.mul(liquidityPoolFee).div(100);
            swapAndLiquify(swapTokens);
            swapTokensForEth(balanceOf(address(this)));
            uint256 totalTaxTokens = devTokens.add(teamTokens).add(rewardsTokenstoSwap).add(advTokens);
            
            uint256 ETHBalance = address(this).balance;

            payable(devPool).transfer(ETHBalance.mul(devTokens).div(totalTaxTokens));
            payable(teamPool).transfer(ETHBalance.mul(teamTokens).div(totalTaxTokens));
            payable(advisorPool).transfer(ETHBalance.mul(advTokens).div(totalTaxTokens));
            distributionPool.call{value: balanceOf(address(this))}("");
         
            swapping = false;
        }
        super._transfer(sender, address(this), nodePrice.mul(1e18));
        nodeManager.createNode(sender, name, tier);
    }

    function createNodeWithRewards(uint256 blocktime, string memory name, uint256 tier) public {
        require(
            bytes(name).length > 3 && bytes(name).length < 32,
            "NODE CREATION: NAME SIZE INVALID"
        );
        address sender = _msgSender();
        require(
            sender != address(0),
            "NODE CREATION:  creation from the zero address"
        );
        require(!_isBlacklisted[sender], "NODE CREATION: Blacklisted address");
        require(
            sender != distributionPool,
            "NODE CREATION: rewardsPool cannot create node"
        );
        uint256 nodePrice = nodeManager._tiersPrice(tier);
        uint256 rewardOf = nodeManager.getNodeReward(sender, blocktime);
        require(
            rewardOf >= nodePrice.mul(1e18),
            "NODE CREATION: Reward Balance too low for creation."
        );
        nodeManager.borrowRewards(sender, blocktime, nodeManager.getNodePrice(tier).mul(1e18));
        nodeManager.createNode(sender, name, tier);
        super._transfer(distributionPool, address(this), nodePrice.mul(1e18));
    }


    function upgradeNode(uint256 blocktime) public {
        address sender = _msgSender();
        require(sender != address(0), "Zero address not permitted");
        require(!_isBlacklisted[sender], "MANIA CSHT: Blacklisted address");
        require(
            sender != distributionPool,
            "Cannot upgrade nodes"
        );
        uint256 currentTier = nodeManager.getNodeTier(sender, blocktime);
        require(currentTier < 4, "Your Node is already at max level");
        uint256 nextTier = currentTier.add(1);
        uint256 currentPrice = nodeManager.getNodePrice(currentTier);
        uint256 newPrice = nodeManager.getNodePrice(nextTier);
        uint256 priceDiff = (newPrice.sub(currentPrice)).mul(1e18);
        uint256 rewardOf = nodeManager.getNodeReward(sender, blocktime);
        if (rewardOf > priceDiff) {
            upgradeNodeCashout(sender, blocktime, rewardOf.sub(priceDiff));
            super._transfer(distributionPool, address(this), priceDiff);
            nodeManager.cashoutNodeReward(sender, blocktime);

        }
        else if (rewardOf < priceDiff) {
            upgradeNodeAddOn(sender, blocktime, priceDiff.sub(rewardOf));
            super._transfer(distributionPool, address(this), rewardOf);
            nodeManager.cashoutNodeReward(sender, blocktime);
        }
        
    }

    function upgradeNodeCashout(address account, uint256 blocktime, uint256 cashOutAmount) internal {
        uint256 taxAmount = nodeManager.getNodeFee(account, blocktime,cashOutAmount);
        super._transfer(distributionPool, account, cashOutAmount.sub(taxAmount)); 
        super._transfer(distributionPool, address(this), taxAmount);
        nodeManager.upgradeNode(account, blocktime);
    }

    function upgradeNodeAddOn(address account, uint256 blocktime, uint256 AddAmount) internal {
        super._transfer(account, address(this), AddAmount);
        nodeManager.upgradeNode(account, blocktime);
    }

    function growMolecule(uint256 _tokenId) external {
        address sender = _msgSender();
        uint256 molLevel = molecules.getMoleculeLevel(_tokenId);
        uint256 growPrice = molLevel.mul(growMultiplier);
        require(balanceOf(sender) > growPrice, "Not enough OXG to grow your Molecule");
        super._transfer(sender, address(this), growPrice);
        molecules.growMolecule(_tokenId);
    }


    function cashoutReward(uint256 blocktime) public {
        address sender = _msgSender();
        require(sender != address(0), "CSHT:  can't from the zero address");
        require(!_isBlacklisted[sender], "MANIA CSHT: Blacklisted address");
        require(
            sender != teamPool && sender != distributionPool,
            "CSHT: futur and rewardsPool cannot cashout rewards"
        );
        uint256 rewardAmount = nodeManager.getNodeReward(
            sender,
            blocktime
        );
        require(
            rewardAmount > 0,
            "CSHT: You don't have enough reward to cash out"
        );

        uint256 taxAmount = nodeManager.getNodeFee(sender, blocktime,rewardAmount);
        super._transfer(distributionPool, sender, rewardAmount.sub(taxAmount));
        super._transfer(distributionPool, address(this), taxAmount);
        nodeManager.cashoutNodeReward(sender, blocktime);
    }

    function cashoutAll() public {
        address sender = _msgSender();
        require(
            sender != address(0),
            "MANIA CSHT:  creation from the zero address"
        );
        require(!_isBlacklisted[sender], "MANIA CSHT: Blacklisted address");
        require(
            sender != teamPool && sender != distributionPool,
            "MANIA CSHT: futur and rewardsPool cannot cashout rewards"
        );
        uint256[2] memory rewardTax = nodeManager.getAllNodesRewards(sender);
        uint256 rewardAmount = rewardTax[0];
        uint256 taxAmount = rewardTax[1];
        require(
            rewardAmount > 0,
            "MANIA CSHT: You don't have enough reward to cash out"
        );
        super._transfer(distributionPool, sender, rewardAmount);
        super._transfer(distributionPool, address(this), taxAmount);
        nodeManager.cashoutAllNodesRewards(sender);
    }

    function rescueFunds(uint amount) public onlyOwner {
        if (amount > address(this).balance) amount = address(this).balance;
        payable(owner()).transfer(amount);
    }


    function changeSwapLiquify(bool newVal) public onlyOwner {
        swapLiquify = newVal;
    }

    function getNodeNumberOf(address account) public view returns (uint256) {
        return nodeManager.getNodeNumberOf(account);
    }

    function getRewardAmountOf(address account)
    public
    view
    onlyOwner
    returns (uint256[2] memory)
    {
        return nodeManager.getAllNodesRewards(account);
    }

    function getRewardAmount() public view returns (uint256[2] memory) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        require(
            nodeManager.isNodeOwner(_msgSender()),
            "NO NODE OWNER"
        );
        return nodeManager.getAllNodesRewards(_msgSender());
    }

    function updateTiersRewards(uint256[] memory newVal) external onlyOwner {
        require(newVal.length == 5, "Wrong length");
        nodeManager.updateTiersRewards(newVal);
  }

    function getNodesNames() public view returns (string memory) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        require(
            nodeManager.isNodeOwner(_msgSender()),
            "NO NODE OWNER"
        );
        return nodeManager.getNodesNames(_msgSender());
    }

    function getNodesCreatime() public view returns (string memory) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        require(
            nodeManager.isNodeOwner(_msgSender()),
            "NO NODE OWNER"
        );
        return nodeManager.getNodesCreationTime(_msgSender());
    }

    function getNodesRewards() public view returns (string memory) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        require(
            nodeManager.isNodeOwner(_msgSender()),
            "NO NODE OWNER"
        );
        return nodeManager.getNodesRewards(_msgSender());
    }

    function getNodesLastClaims() public view returns (string memory) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        require(
            nodeManager.isNodeOwner(_msgSender()),
            "NO NODE OWNER"
        );
        return nodeManager.getNodesLastClaimTime(_msgSender());
    }


    function getTotalStakedReward() public view returns (uint256) {
        return nodeManager.totalStaked();
    }

    function getTotalCreatedNodes() public view returns (uint256) {
        return nodeManager.totalNodesCreated();
    }


    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        tradingOpen = true;
        _openTradingBlock = block.number;
    }

    function nodeEnforcement(bool val) external onlyOwner() {
        nodeEnforced = val;
    }

    function updateMaxTxAmount(uint256 newVal) public onlyOwner {
        maxTx = newVal;
    }
}