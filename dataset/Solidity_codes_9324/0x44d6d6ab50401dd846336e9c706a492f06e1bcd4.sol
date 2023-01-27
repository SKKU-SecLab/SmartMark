



pragma solidity 0.8.9;

contract OwnableDelegateProxy {}



pragma solidity 0.8.9;



contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}



pragma solidity 0.8.9;

library Roles {


    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view
        returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}





pragma solidity 0.8.9;

interface IERC1155TokenReceiver {


    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    )
        external returns (
            bytes4
        )
    ;


    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    )
        external returns (
            bytes4
        )
    ;


    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}


pragma solidity 0.8.9;

abstract contract ERC1155Metadata {

    function uri(uint256 _id) external view virtual returns (string memory);
}





pragma solidity 0.8.9;

interface IERC1155 {

    event TransferSingle(address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount);

    event TransferBatch(address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _amounts);

    event ApprovalForAll(address indexed _owner,
        address indexed _operator,
        bool _approved);

    event URI(string _uri, uint256 indexed _id);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    )
        external;


    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    )
        external;


    function balanceOf(address _owner, uint256 _id) external view
        returns (uint256);


    function balanceOfBatch(
        address[] calldata _owners,
        uint256[] calldata _ids
    )
        external
        view
        returns (
            uint256[] memory
        )
    ;


    function setApprovalForAll(address _operator, bool _approved) external;


    function isApprovedForAll(
        address _owner,
        address _operator
    )
        external
        view
        returns (
            bool isOperator
        )
    ;

}



pragma solidity 0.8.9;

interface IERC165 {


    function supportsInterface(bytes4 _interfaceId) external view
        returns (bool);

}


pragma solidity 0.8.9;

interface FundDistribution {

    function sendReward(address _fundAddress) external returns (bool);

}



pragma solidity 0.8.9;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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





pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}





pragma solidity 0.8.9;



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _transferOwnership(_msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity 0.8.9;




contract MinterRole is Context, Ownable {


    using Roles for Roles.Role;

    event MinterAdded(address indexed account);

    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    modifier onlyMinter() {

        require(
            isMinter(_msgSender()),
            "MinterRole: caller does not have the Minter role"
        );
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyOwner {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}



pragma solidity 0.8.9;

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





pragma solidity 0.8.9;







abstract contract ERC1155 is IERC1155, IERC165, ERC1155Metadata {
    using SafeMath for uint256;
    using Address for address;

    bytes4 internal constant ERC1155_RECEIVED_VALUE = 0xf23a6e61;
    bytes4 internal constant ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

    mapping(address => mapping(uint256 => uint256)) internal balances;

    mapping(address => mapping(address => bool)) internal operators;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    )
        public override virtual {
        require((
                msg.sender == _from
                )
            || _isApprovedForAll(_from, msg.sender), "ERC1155#safeTransferFrom: INVALID_OPERATOR");
        require(_to != address(0), "ERC1155#safeTransferFrom: INVALID_RECIPIENT");
        _safeTransferFrom(_from, _to, _id, _amount);
        _callonERC1155Received(_from, _to, _id, _amount, _data);
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    )
        public override virtual {
        require((
                msg.sender == _from
                )
            || _isApprovedForAll(_from, msg.sender), "ERC1155#safeBatchTransferFrom: INVALID_OPERATOR");
        require(_to != address(0), "ERC1155#safeBatchTransferFrom: INVALID_RECIPIENT");

        _safeBatchTransferFrom(_from, _to, _ids, _amounts);
        _callonERC1155BatchReceived(_from, _to, _ids, _amounts, _data);
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    )
        internal {
        balances[_from][_id] = balances[_from][_id].sub (
            _amount
            )
        ; // Subtract amount
        balances[_to][_id] = balances[_to][_id].add(_amount); // Add amount
        emit TransferSingle(msg.sender, _from, _to, _id, _amount);
    }

    function _callonERC1155Received(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    )
        internal {
        if (_to.isContract()) {
            try IERC1155TokenReceiver(_to).onERC1155Received(msg.sender, _from, _id, _amount, _data) returns (bytes4 response) {
                if (response != ERC1155_RECEIVED_VALUE) {
                    revert("ERC1155#_callonERC1155Received: INVALID_ON_RECEIVE_MESSAGE");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155#_callonERC1155Received: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts
    )
        internal {
        require (
            _ids.length == _amounts.length, "ERC1155#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH"
            )
        ;

        uint256 nTransfer = _ids.length;

        for (uint256 i = 0; i < nTransfer;i++) {
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_amounts[i]);
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
    }

    function _callonERC1155BatchReceived(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    )
        internal {
        if (_to.isContract()
        ) {
            try IERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender, _from, _ids, _amounts, _data) returns (bytes4 response) {
                if (response != ERC1155_BATCH_RECEIVED_VALUE) {
                    revert("ERC1155#_callonERC1155BatchReceived: INVALID_ON_RECEIVE_MESSAGE");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155#_callonERC1155BatchReceived: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function setApprovalForAll(address _operator, bool _approved) external override {
        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function _isApprovedForAll(
        address _owner,
        address _operator
    )
        internal
        view
        returns (bool isOperator) {
        return operators[_owner][_operator];
    }

    function balanceOf(address _owner, uint256 _id) override public view returns (uint256) {
        return balances[_owner][_id];
    }

    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
        override
        public
        view
        returns (uint256[] memory) {
        require(_owners.length == _ids.length, "ERC1155#balanceOfBatch: INVALID_ARRAY_LENGTH");

        uint256[] memory batchBalances = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length;i++) {
            batchBalances[i] = balances[_owners[i]][_ids[i]];
        }

        return batchBalances;
    }

    bytes4 private constant INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;

    bytes4 private constant INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;

    function supportsInterface(bytes4 _interfaceID) override external pure returns (bool) {
        if (_interfaceID == INTERFACE_SIGNATURE_ERC165 || _interfaceID == INTERFACE_SIGNATURE_ERC1155) {
            return true;
        }
        return false;
    }
}





pragma solidity 0.8.9;



abstract contract ERC1155MintBurn is ERC1155 {
    using SafeMath for uint256;

    function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data) internal {
        balances[_to][_id] = balances[_to][_id].add(_amount);

        emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

        _callonERC1155Received(address(0x0), _to, _id, _amount, _data);
    }

    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    )
        internal {
        require (
            _ids.length == _amounts.length, "ERC1155MintBurn#batchMint: INVALID_ARRAYS_LENGTH"
            )
        ;

        uint256 nMint = _ids.length;

        for (uint256 i = 0; i < nMint;i++) {
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
        }

        emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);

        _callonERC1155BatchReceived(address(0x0), _to, _ids, _amounts, _data);
    }

    function _burn(address _from, uint256 _id,
        uint256 _amount) internal {
        balances[_from][_id] = balances[_from][_id].sub(_amount);

        emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
    }

    function _batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _amounts
    )
        internal {
        require (
            _ids.length == _amounts.length, "ERC1155MintBurn#batchBurn: INVALID_ARRAYS_LENGTH"
            )
        ;

        uint256 nBurn = _ids.length;

        for (uint256 i = 0; i < nBurn;i++) {
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_amounts[i]);
        }

        emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
    }
}





pragma solidity 0.8.9;








abstract contract ERC1155Tradable is ERC1155MintBurn, Ownable, MinterRole {
    using SafeMath for uint256;
    using Address for address;

    address public proxyRegistryAddress;

    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => uint256) public tokenMaxSupply;
    mapping(uint256 => uint8) public tokenCityIndex;
    mapping(uint256 => uint8) public tokenType;

    string public name;

    string public symbol;

    string internal baseMetadataURI;

    uint256 internal _currentTokenID = 0;

    constructor (string memory _name, string memory _symbol, address _proxyRegistryAddress, string memory _baseMetadataURI) {
        name = _name;
        symbol = _symbol;
        proxyRegistryAddress = _proxyRegistryAddress;
        baseMetadataURI = _baseMetadataURI;
    }

    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(baseMetadataURI));
    }

    function uri(uint256 _id) override external view returns (string memory) {
        require(_exists(_id), "Deed NFT doesn't exists");
        return string(abi.encodePacked(baseMetadataURI, _uint2str(_id)));
    }

    function totalSupply(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

    function maxSupply(uint256 _id) public view returns (uint256) {
        return tokenMaxSupply[_id];
    }

    function cityIndex(uint256 _id) public view returns (uint256) {
        require(_exists(_id), "Deed NFT doesn't exists");
        return tokenCityIndex[_id];
    }

    function cardType(uint256 _id) public view returns (uint256) {
        require(_exists(_id), "Deed NFT doesn't exists");
        return tokenType[_id];
    }

    function create(
        address _initialOwner,
        uint256 _initialSupply,
        uint256 _maxSupply,
        uint8 _cityIndex,
        uint8 _type,
        bytes memory _data
    ) public onlyMinter returns (uint256) {
        require(_initialSupply <= _maxSupply, "_initialSupply > _maxSupply");
        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();
        creators[_id] = _initialOwner;

        if (_initialSupply != 0) {
            _mint(_initialOwner, _id, _initialSupply, _data);
        }
        tokenSupply[_id] = _initialSupply;
        tokenMaxSupply[_id] = _maxSupply;
        tokenCityIndex[_id] = _cityIndex;
        tokenType[_id] = _type;
        return _id;
    }

    function isApprovedForAll(address _owner, address _operator) override public view returns (bool isOperator) {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator) {
            return true;
        }

        return _isApprovedForAll(_owner, _operator);
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return creators[_id] != address(0);
    }

    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID.add(1);
    }

    function _incrementTokenTypeId() private {
        _currentTokenID++;
    }

    function _uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
            if (k > 0) {
                k--;
            }
        }
        return string(bstr);
    }

}


pragma solidity 0.8.9;

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





pragma solidity 0.8.9;





abstract contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory tokenName, string memory tokenSymbol) {
        _name = tokenName;
        _symbol = tokenSymbol;
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

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}



pragma solidity 0.8.9;








abstract contract XMeedsToken is ERC20("Staked MEED", "xMEED"), Ownable {
    using SafeMath for uint256;
    IERC20 public meed;
    FundDistribution public rewardDistribution;

    constructor(IERC20 _meed, FundDistribution _rewardDistribution) {
        meed = _meed;
        rewardDistribution = _rewardDistribution;
    }

    function _stake(uint256 _amount) internal {
        require(rewardDistribution.sendReward(address(this)) == true, "Error retrieving funds from reserve");

        uint256 totalMeed = meed.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        if (totalShares == 0 || totalMeed == 0) {
            _mint(_msgSender(), _amount);
        } else {
            uint256 what = _amount.mul(totalShares).div(totalMeed);
            _mint(_msgSender(), what);
        }
        meed.transferFrom(_msgSender(), address(this), _amount);
    }

    function _withdraw(uint256 _amount) internal {
        require(rewardDistribution.sendReward(address(this)) == true, "Error retrieving funds from reserve");

        uint256 totalMeed = meed.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        uint256 what = _amount.mul(totalMeed).div(totalShares);
        _burn(_msgSender(), _amount);
        meed.transfer(_msgSender(), what);
    }
}


pragma solidity 0.8.9;



contract MeedsPointsRewarding is XMeedsToken {

    using SafeMath for uint256;

    uint256 public startRewardsTime;

    mapping(address => uint256) internal points;
    mapping(address => uint256) internal pointsLastUpdateTime;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    modifier updateReward(address account) {

        if (account != address(0)) {
          if (block.timestamp < startRewardsTime) {
            points[account] = 0;
            pointsLastUpdateTime[account] = startRewardsTime;
          } else {
            points[account] = earned(account);
            pointsLastUpdateTime[account] = block.timestamp;
          }
        }
        _;
    }

    constructor (IERC20 _meed, FundDistribution _rewardDistribution, uint256 _startRewardsTime) XMeedsToken(_meed, _rewardDistribution) {
        startRewardsTime = _startRewardsTime;
    }

    function earned(address account) public view returns (uint256) {

        if (block.timestamp < startRewardsTime) {
          return 0;
        } else {
          uint256 timeDifference = block.timestamp.sub(pointsLastUpdateTime[account]);
          uint256 balance = balanceOf(account);
          uint256 decimals = 1e18;
          uint256 x = balance / decimals;
          uint256 ratePerSecond = decimals.mul(x).div(x.add(12000)).div(240);
          return points[account].add(ratePerSecond.mul(timeDifference));
        }
    }

    function stake(uint256 amount) public updateReward(msg.sender) {

        require(amount > 0, "Invalid amount");

        _stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {

        require(amount > 0, "Cannot withdraw 0");

        _withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        updateReward(msg.sender)
        updateReward(recipient)
        returns (bool) {

        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        public
        virtual
        override
        updateReward(sender)
        updateReward(recipient)
        returns (bool) {

        return super.transferFrom(sender, recipient, amount);
    }

}





pragma solidity 0.8.9;




contract XMeedsNFTRewarding is MeedsPointsRewarding {

    using SafeMath for uint256;

    struct CardTypeDetail {
        string name;
        uint8 cityIndex;
        uint8 cardType;
        uint32 supply;
        uint32 maxSupply;
        uint256 amount;
    }

    struct CityDetail {
        string name;
        uint32 population;
        uint32 maxPopulation;
        uint256 availability;
    }

    ERC1155Tradable public nft;

    CardTypeDetail[] public cardTypeInfo;
    CityDetail[] public cityInfo;
    uint8 public currentCityIndex = 0;
    uint256 public lastCityMintingCompleteDate = 0;

    event Redeemed(address indexed user, string city, string cardType, uint256 id);
    event NFTSet(ERC1155Tradable indexed newNFT);

    constructor (
        IERC20 _meed,
        FundDistribution _rewardDistribution,
        ERC1155Tradable _nftAddress,
        uint256 _startRewardsTime,
        string[] memory _cityNames,
        string[] memory _cardNames,
        uint256[] memory _cardPrices,
        uint32[] memory _cardSupply
    ) MeedsPointsRewarding(_meed, _rewardDistribution, _startRewardsTime) {
        nft = _nftAddress;
        lastCityMintingCompleteDate = block.timestamp;

        uint256 citiesLength = _cityNames.length;
        uint256 cardsLength = _cardNames.length;
        uint32 citiesCardsLength = uint32(citiesLength * cardsLength);
        require(uint32(_cardSupply.length) == citiesCardsLength, "Provided Supply list per card per city must equal to Card Type length");

        uint256 _month = 30 days;
        uint256 _index = 0;
        for (uint8 i = 0; i < citiesLength; i++) {
            uint32 _maxPopulation = 0;
            for (uint8 j = 0; j < cardsLength; j++) {
                string memory _cardName = _cardNames[j];
                uint256 _cardPrice = _cardPrices[j];
                uint32 _maxSupply = _cardSupply[_index];
                cardTypeInfo.push(CardTypeDetail({
                    name: _cardName,
                    cityIndex: i,
                    cardType: j,
                    amount: _cardPrice,
                    supply: 0,
                    maxSupply: _maxSupply
                }));
                _maxPopulation += _maxSupply;
                _index++;
            }

            uint256 _availability = i > 0 ? ((2 ** (i + 1)) * _month) : 0;
            string memory _cityName = _cityNames[i];
            cityInfo.push(CityDetail({
                name: _cityName,
                population: 0,
                maxPopulation: _maxPopulation,
                availability: _availability
            }));
        }
    }

    function setNFT(ERC1155Tradable _nftAddress) public onlyOwner {

        nft = _nftAddress;
        emit NFTSet(_nftAddress);
    }

    function isCurrentCityMintable() public view returns (bool) {

        return block.timestamp > cityMintingStartDate();
    }

    function cityMintingStartDate() public view returns (uint256) {

        CityDetail memory city = cityInfo[currentCityIndex];
        return city.availability.add(lastCityMintingCompleteDate);
    }

    function redeem(uint8 cardTypeId) public updateReward(msg.sender) returns (uint256 tokenId) {

        require(cardTypeId < cardTypeInfo.length, "Card Type doesn't exist");

        CardTypeDetail storage cardType = cardTypeInfo[cardTypeId];
        require(cardType.maxSupply > 0, "Card Type not available for minting");
        require(points[msg.sender] >= cardType.amount, "Not enough points to redeem for card");
        require(cardType.supply < cardType.maxSupply, "Max cards supply reached");
        require(cardType.cityIndex == currentCityIndex, "Designated city isn't available for minting yet");

        CityDetail storage city = cityInfo[cardType.cityIndex];
        require(block.timestamp > city.availability.add(lastCityMintingCompleteDate), "Designated city isn't available for minting yet");

        city.population = city.population + 1;
        cardType.supply = cardType.supply + 1;
        if (city.population >= city.maxPopulation) {
            currentCityIndex++;
            lastCityMintingCompleteDate = block.timestamp;
        }

        points[msg.sender] = points[msg.sender].sub(cardType.amount);
        uint256 _tokenId = nft.create(msg.sender, 1, 1, cardType.cityIndex, cardType.cardType, "");
        emit Redeemed(msg.sender, city.name, cardType.name, _tokenId);
        return _tokenId;
    }

}