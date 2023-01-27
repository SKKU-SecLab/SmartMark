



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




pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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




pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}




pragma solidity >=0.6.0 <0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}




pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}




pragma solidity >=0.6.0 <0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}




pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}




pragma solidity >=0.6.2 <0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}




pragma solidity >=0.6.0 <0.8.0;








contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor (string memory uri_) public {
        _setURI(uri_);

        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256) external view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
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
    )
        public
        virtual
        override
    {

        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address account, uint256 id, uint256 amount) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
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
    )
        internal
        virtual
    { }


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
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
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
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
}




pragma solidity >=0.6.0 <0.7.0;







contract Dvision_1155dvi is ERC1155, Ownable 
{    

    using SafeMath for uint256;
    
    constructor(address _erc20, address payable _fee_addr, string memory _uri) 
    ERC1155("DVI 1155") Ownable() public 
    {
       currencyToken = IERC20(_erc20);
       fee_addr = _fee_addr;
       _setURI(_uri);
    }
    
    uint private _currentTokenId = 0;
    uint private _currentOrderId = 0;
    uint private _currentSaleAmount = 0;
    
    mapping(uint => bool) public _itemExists;
    mapping(address => mapping(uint => Item)) public _items;
    mapping(uint => Order) public _itemForSale;
    

    struct Item 
    { 
        uint256 supply;
        uint256 amount;
        uint256 orderId;
    }
    
    struct Order
    {
        address seller;
        uint256 tokenId;
        uint256 price;
        uint256 currency;
        uint256 sell_amount;
        bool forSale;
    }
    
    
    event ItemSelled(uint256 _tokenId);
    event mint_event(uint256 _tokenId);
    
    address payable fee_addr;
    uint256 fee_percent = 10;
    uint256 fee_on_mint = 0;
    
    
    IERC20 currencyToken;
    
    function Set_20Token(address _new) onlyOwner public 
    {

        currencyToken = IERC20(_new);
    }
    
    function Show_20Token() onlyOwner public view returns(address)
    {

        return address(currencyToken);
    }
    
    function Set_URI (string memory _new_uri) public onlyOwner {
       _setURI(_new_uri);
    }
    
    function Mint(uint256 _amount) public payable returns(uint256)
    {

        require(_amount > 0, "ERC1155 : Amount of token to create must be bigger than 0");
        require(msg.value >= fee_on_mint, "fee is not enough");
        
        Item memory _item = Item({
            supply : _amount,
            amount : _amount,
            orderId : 0
        });
        
        uint _id = _getNextTokenId();
        _mint(msg.sender, _id, _amount, "");
        
        _incrementTokenId();
        
        _items[msg.sender][_id] = _item;
        _itemExists[_id] = true;
        
        
        emit mint_event(_id);
        return (_id);
    }
    
    function MintTo(address _to, uint256 _amount) public onlyOwner returns(uint256)
    {

        require(_amount > 0, "ERC1155 : Amount of token to create must be bigger than 0");
        
        Item memory _item = Item({
            supply : _amount,
            amount : _amount,
            orderId : 0
        });
        
        uint _id = _getNextTokenId();
        _mint(_to, _id, _amount, "");
        
        _incrementTokenId();
        
        _items[_to][_id] = _item;
        _itemExists[_id] = true;

        
        emit mint_event(_id);
        return (_id);
    }
    
    
    function _getNextTokenId() private view returns (uint256) 
    {

        return _currentTokenId.add(1);
    }
    
    function _incrementTokenId() private 
    {

        _currentTokenId++;
    }
    
    function Sell_Item(address _marketaddress, uint256 _tokenId, uint256 _price, uint256 _currency, uint256 _sell_amount) public 
    {

        require(balanceOf(msg.sender, _tokenId) >= _sell_amount);
        
        if(_items[msg.sender][_tokenId].orderId > 0)
        {
            if(_itemForSale[_items[msg.sender][_tokenId].orderId].forSale == false) //selled many times
            {
                uint _orderId = _getNextOrderId();
                _items[msg.sender][_tokenId].orderId = _orderId;
                
                _itemForSale[_orderId].seller = msg.sender;
                _itemForSale[_orderId].tokenId = _tokenId;
                _itemForSale[_orderId].sell_amount = _sell_amount;
                _itemForSale[_orderId].price = _price;
                _itemForSale[_orderId].currency = _currency;
                _itemForSale[_orderId].forSale = true;
                
                setApprovalForAll(_marketaddress, true);
                
                _currentSaleAmount++;
                _incrementOrderId();
                
                emit ItemSelled(_tokenId);
            }
            else //renewed selling data
            {
                _itemForSale[_items[msg.sender][_tokenId].orderId].seller = msg.sender;
                _itemForSale[_items[msg.sender][_tokenId].orderId].tokenId = _tokenId;
                _itemForSale[_items[msg.sender][_tokenId].orderId].sell_amount = _sell_amount;
                _itemForSale[_items[msg.sender][_tokenId].orderId].price = _price;
                _itemForSale[_items[msg.sender][_tokenId].orderId].currency = _currency;
                _itemForSale[_items[msg.sender][_tokenId].orderId].forSale = true;
                
                setApprovalForAll(_marketaddress, true);
                
                emit ItemSelled(_tokenId);
            }
        }
        else // selled first time
        {
            uint _orderId = _getNextOrderId();
            _items[msg.sender][_tokenId].orderId = _orderId;
            
            _itemForSale[_orderId].seller = msg.sender;
            _itemForSale[_orderId].tokenId = _tokenId;
            _itemForSale[_orderId].sell_amount = _sell_amount;
            _itemForSale[_orderId].price = _price;
            _itemForSale[_orderId].currency = _currency;
            _itemForSale[_orderId].forSale = true;
            
            setApprovalForAll(_marketaddress, true);
            
            _currentSaleAmount++;
            _incrementOrderId();
            
            emit ItemSelled(_tokenId);
        }        
    }
    
    function Transaction_Item(address _from, address _to, uint256 _tokenId, uint256 _amount) external payable 
    { 

        address payable owner = address(uint160(_from));
        require(owner != msg.sender, "Owner can't buy their tokens.");
        require(owner != address(0), "Owner must not be zero address.");
        
        require(msg.value >= _itemForSale[_items[_from][_tokenId].orderId].price * _amount, "Not Enough Pays.");
        require(_itemForSale[_items[_from][_tokenId].orderId].sell_amount > 0, "Not For Sale.");
        require(_itemForSale[_items[_from][_tokenId].orderId].sell_amount >= _amount, "Not Enough Tokens.");
        require(_itemForSale[_items[_from][_tokenId].orderId].currency == 0, "This token can buy on ethereum.");
        
        owner.transfer(_itemForSale[_items[_from][_tokenId].orderId].price * _amount * (1 - fee_percent / 100));
        fee_addr.transfer(_itemForSale[_items[_from][_tokenId].orderId].price * _amount * (fee_percent / 100));
        
        safeTransferFrom(owner, _to, _tokenId, _amount, "");
        
        _itemForSale[_items[_from][_tokenId].orderId].sell_amount -= _amount;
        _items[_from][_tokenId].amount -= _amount;
        
        _items[_to][_tokenId].amount += _amount;
        
       
        if(_items[_from][_tokenId].amount == 0)
        {
            _itemForSale[_items[_from][_tokenId].orderId].forSale = false;
            
            if(_currentSaleAmount > 0)
            {
                _currentSaleAmount--;
            }
        }
    }
    
    function Transaction_Item_WithToken(address _from, address _to, uint256 _tokenId, uint256 _amount, uint256 _price) external 
    {

        address owner = address(uint160(_from));
        require(owner != msg.sender, "Owner can't buy their tokens.");
        require(owner != address(0), "Owner must not be zero address.");
    
        require(_price >= _itemForSale[_items[_from][_tokenId].orderId].price * _amount, "Not Enough Pays.");
        require(_itemForSale[_items[_from][_tokenId].orderId].sell_amount > 0, "Not For Sale.");
        require(_itemForSale[_items[_from][_tokenId].orderId].sell_amount >= _amount, "Not Enough Tokens");
        require(_itemForSale[_items[_from][_tokenId].orderId].currency == 1, "This token can buy on DVI token.");
        
        bool result = currencyToken.transferFrom(_to, owner, _price);
        require(result, "transfer token failed");
        
        safeTransferFrom(owner, _to, _tokenId, _amount, "");
        
        _itemForSale[_items[_from][_tokenId].orderId].sell_amount -= _amount;
        _items[_from][_tokenId].amount -= _amount;
        
        _items[_to][_tokenId].amount += _amount;
        
        if(_items[_from][_tokenId].amount == 0)
        {
            _itemForSale[_items[_from][_tokenId].orderId].forSale = false;
            
            if(_currentSaleAmount > 0)
            {
                _currentSaleAmount--;
            }
        }
    }
    
    function _getNextOrderId() private view returns (uint256) 
    {

        return _currentOrderId.add(1);
    }
    
    function _incrementOrderId() private 
    {

        _currentOrderId++;
    }
    
    
    function Get_Orders(address _seller, uint _tokenId) 
    public 
    view 
    returns(uint256 _id, uint256 _price, uint256 _currency, uint256 _amount, address _owner)
    {

        Order storage _order = _itemForSale[_items[_seller][_tokenId].orderId];
        
        _id = _tokenId;
        _price = _order.price;
        _currency = _order.currency;
        _amount = _order.sell_amount;
        _owner = _order.seller;
    }
    
    function TokensOfOwner(address _owner) public view returns(uint[] memory)
    {

        uint256 _balance = 0;
        
        uint256 _maxTokenId = _currentTokenId;
        uint256 _tokenId = 0;
        
        
        for(_tokenId = 1; _tokenId < _maxTokenId + 1; _tokenId++)
        {
            if(balanceOf(_owner, _tokenId) > 0)
            {
                _balance++;
            }
        }
        
        if(_balance == 0)
        {
            return new uint256[](0);
        }
        else
        {
            uint[] memory _result = new uint[](_balance);
            uint256 _idx = 0;
            
            for(_tokenId = 1; _tokenId < _maxTokenId + 1; _tokenId++)
            {
                if(balanceOf(_owner, _tokenId) > 0)
                {
                    _result[_idx] = _tokenId;
                    _idx++;
                }
            }
            
            return _result;
        }
    }
    
    function Get_SellingItems() 
    public
    view
    returns(uint[] memory, address[] memory, uint[] memory, uint[] memory, uint[] memory)
    {

        uint[] memory _result_Id = new uint[](_currentSaleAmount);
        address[] memory _result_Addr = new address[](_currentSaleAmount);
        uint[] memory _result_Price = new uint[](_currentSaleAmount); 
        uint[] memory _result_Currency = new uint[](_currentSaleAmount);
        uint[] memory _result_SellAmount = new uint[](_currentSaleAmount);

        uint256 _maxOrderId = _currentOrderId;
        uint256 _idx = 0;
        
        uint256 _orderId = 0;
        for(_orderId = 1; _orderId < _maxOrderId + 1; _orderId++)
        {
            if(_itemForSale[_orderId].forSale == true)
            {
                _result_Id[_idx] = _orderId;
                _result_Addr[_idx] = _itemForSale[_orderId].seller;
                _result_Price[_idx] = _itemForSale[_orderId].price;
                _result_Currency[_idx] = _itemForSale[_orderId].currency;
                _result_SellAmount[_idx] = _itemForSale[_orderId].sell_amount;
                _idx++;
            }
        }   
            
        return (_result_Id, _result_Addr, _result_Price, _result_Currency, _result_SellAmount);
    }
    
    function Change_Fee_Addr(address payable _addr) onlyOwner public returns(address)
    {

        fee_addr = _addr;
        
        return(fee_addr);
    }
    
    function Show_Fee_Addr() onlyOwner public view returns(address)
    {

        return(fee_addr);
    }
    
    function Change_Fee_Percent(uint256 _percent) onlyOwner public returns(uint256)
    {

        fee_percent = _percent;
        
        return(fee_percent);
    }
    
    function Show_Fee_Percent() public view returns(uint256){

        return(fee_percent);
    }
    
    function Change_Fee_On_Mint(uint256 _new) onlyOwner public returns(uint256)
    {

        fee_on_mint = _new;
        
        return(fee_on_mint);
    }
    
    function Show_Fee_On_Mint() public view returns(uint256)
    {

        return(fee_on_mint);
    }
    
    
    
    
    function Set_Base_URI(string memory _new) onlyOwner public returns(string memory)
    {

        _setURI(_new);
        return _new;
    }
    
}