
pragma solidity >=0.6.0 <0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

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

}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}// MIT

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

}// MIT

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
}// MIT

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
}// MIT

pragma solidity ^0.6.0;


contract ERC20 is  IERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public override totalSupply;

    string public name;
    string public symbol;
    uint8 public decimals;

    constructor() public {}


    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
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

        _approve(msg.sender, spender, amount);
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
            msg.sender,
            _allowances[sender][msg.sender].sub(
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
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
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

        totalSupply = totalSupply.add(amount);
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
        totalSupply = totalSupply.sub(amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}



    function burn(uint256 amount) public virtual {

        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {

        uint256 decreasedAllowance =
            allowance(account, msg.sender).sub(
                amount,
                "ERC20: burn amount exceeds allowance"
            );

        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}pragma solidity ^0.6.0;





interface IFactory {

    function fee() external view returns (uint256);


    function sellTokens() external;


    function flashLoansEnabled() external view returns (bool);

}

interface IFlashLoanReceiver {

    function executeOperation(
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        address initiator,
        bytes calldata params
    ) external returns (bool);

}

contract NFT20Pair is ERC20, IERC721Receiver, ERC1155Receiver {

    address public factory;
    address public nftAddress;
    uint256 public nftType;
    uint256 public nftValue;

    mapping(uint256 => uint256) public track1155;

    using EnumerableSet for EnumerableSet.UintSet;
    EnumerableSet.UintSet lockedNfts;

    event Withdraw(uint256[] indexed _tokenIds, uint256[] indexed amounts);

    constructor() public {}

    function init(
        string memory _name,
        string memory _symbol,
        address _nftAddress,
        uint256 _nftType
    ) public payable {

        require(factory == address(0));
        factory = msg.sender;
        nftType = _nftType;
        name = _name;
        symbol = _symbol;
        decimals = 18;
        nftAddress = _nftAddress;
        nftValue = 100 * 10**18;
    }

    modifier flashloansEnabled() {

        require(
            IFactory(factory).flashLoansEnabled(),
            "flashloans not allowed"
        );
        _;
    }

    function getInfos()
        public
        view
        returns (
            uint256 _type,
            string memory _name,
            string memory _symbol,
            uint256 _supply
        )
    {

        _type = nftType;
        _name = name;
        _symbol = symbol;
        _supply = totalSupply.div(nftValue);
    }

    function withdraw(
        uint256[] calldata _tokenIds,
        uint256[] calldata amounts,
        address recipient
    ) external {

        if (nftType == 1155) {
            if (_tokenIds.length == 1) {
                _burn(msg.sender, nftValue.mul(amounts[0]));
                _withdraw1155(
                    address(this),
                    recipient,
                    _tokenIds[0],
                    amounts[0]
                );
            } else {
                _batchWithdraw1155(
                    address(this),
                    recipient,
                    _tokenIds,
                    amounts
                );
            }
        } else if (nftType == 721) {
            _burn(msg.sender, nftValue.mul(_tokenIds.length));
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                _withdraw721(address(this), recipient, _tokenIds[i]);
            }
        }

        emit Withdraw(_tokenIds, amounts);
    }

    function _withdraw1155(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 value
    ) internal {

        IERC1155(nftAddress).safeTransferFrom(_from, _to, _tokenId, value, "");
    }

    function _batchWithdraw1155(
        address _from,
        address _to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {

        uint256 qty = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            qty = qty + amounts[i];
        }
        _burn(msg.sender, nftValue.mul(qty));

        IERC1155(nftAddress).safeBatchTransferFrom(
            _from,
            _to,
            ids,
            amounts,
            "0x0"
        );
    }

    function multi721Deposit(uint256[] memory _ids, address _referral) public {

        uint256 fee = IFactory(factory).fee();

        for (uint256 i = 0; i < _ids.length; i++) {
            IERC721(nftAddress).transferFrom(
                msg.sender,
                address(this),
                _ids[i]
            );
        }

        address referral = _referral == address(0x0) ? factory : _referral;

        if (
            referral != factory &&
            referral != 0xA42f6cADa809Bcf417DeefbdD69C5C5A909249C0
        ) {
            _mint(factory, (nftValue.mul(_ids.length)).mul(3).div(100));
            _mint(referral, (nftValue.mul(_ids.length)).mul(2).div(100));
        } else {
            _mint(referral, (nftValue.mul(_ids.length)).mul(fee).div(100));
        }

        _mint(
            msg.sender,
            (nftValue.mul(_ids.length)).mul(uint256(100).sub(fee)).div(100)
        );
    }

    function swap721(uint256 _in, uint256 _out) external {

        IFactory(factory).sellTokens();

        IERC721(nftAddress).transferFrom(msg.sender, address(this), _in);
        IERC721(nftAddress).safeTransferFrom(address(this), msg.sender, _out);
    }

    function swap1155(
        uint256[] calldata in_ids,
        uint256[] calldata in_amounts,
        uint256[] calldata out_ids,
        uint256[] calldata out_amounts
    ) external {

        IFactory(factory).sellTokens();

        uint256 ins;
        uint256 outs;

        for (uint256 i = 0; i < out_ids.length; i++) {
            ins = ins.add(in_amounts[i]);
            outs = outs.add(out_amounts[i]);
        }

        require(ins == outs, "Need to swap same amount of NFTs");

        IERC1155(nftAddress).safeBatchTransferFrom(
            address(this),
            msg.sender,
            out_ids,
            out_amounts,
            "0x0"
        );
        IERC1155(nftAddress).safeBatchTransferFrom(
            msg.sender,
            address(this),
            in_ids,
            in_amounts,
            "INTERNAL"
        );
    }

    function _withdraw721(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {

        IERC721(nftAddress).safeTransferFrom(_from, _to, _tokenId);
    }

    function onERC721Received(
        address operator,
        address,
        uint256,
        bytes memory data
    ) public virtual override returns (bytes4) {

        require(nftAddress == msg.sender, "forbidden");
        uint256 fee = IFactory(factory).fee();

        address referral = bytesToAddress(data) == address(0x0)
            ? factory
            : bytesToAddress(data);

        if (
            referral != factory &&
            referral != 0xA42f6cADa809Bcf417DeefbdD69C5C5A909249C0
        ) {
            _mint(factory, nftValue.mul(3).div(100));
            _mint(referral, nftValue.mul(2).div(100));
        } else {
            _mint(referral, nftValue.mul(fee).div(100));
        }

        _mint(operator, nftValue.mul(uint256(100).sub(fee)).div(100));
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address operator,
        address,
        uint256,
        uint256 value,
        bytes memory data
    ) public virtual override returns (bytes4) {

        require(nftAddress == msg.sender, "forbidden");
        if (keccak256(data) != keccak256("INTERNAL")) {
            uint256 fee = IFactory(factory).fee();

            address referral = bytesToAddress(data) == address(0x0)
                ? factory
                : bytesToAddress(data);

            if (
                referral != factory &&
                referral != 0xA42f6cADa809Bcf417DeefbdD69C5C5A909249C0
            ) {
                _mint(factory, (nftValue.mul(value)).mul(3).div(100));
                _mint(referral, (nftValue.mul(value)).mul(2).div(100));
            } else {
                _mint(referral, (nftValue.mul(value)).mul(fee).div(100));
            }

            _mint(
                operator,
                (nftValue.mul(value)).mul(uint256(100).sub(fee)).div(100)
            );
        }
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override returns (bytes4) {

        require(nftAddress == msg.sender, "forbidden");
        if (keccak256(data) != keccak256("INTERNAL")) {
            uint256 qty = 0;

            for (uint256 i = 0; i < ids.length; i++) {
                qty = qty + values[i];
            }
            uint256 fee = IFactory(factory).fee();

            address referral = bytesToAddress(data) == address(0x0)
                ? factory
                : bytesToAddress(data);

            if (
                referral != factory &&
                referral != 0xA42f6cADa809Bcf417DeefbdD69C5C5A909249C0
            ) {
                _mint(factory, (nftValue.mul(qty)).mul(3).div(100));
                _mint(referral, (nftValue.mul(qty)).mul(2).div(100));
            } else {
                _mint(referral, (nftValue.mul(qty)).mul(fee).div(100));
            }

            _mint(
                operator,
                (nftValue.mul(qty)).mul(uint256(100).sub(fee)).div(100)
            );
        }
        return this.onERC1155BatchReceived.selector;
    }

    function setParams(
        uint256 _nftType,
        string calldata _name,
        string calldata _symbol,
        uint256 _nftValue
    ) external {

        require(msg.sender == factory, "!authorized");
        nftType = _nftType;
        name = _name;
        symbol = _symbol;
        nftValue = _nftValue;
    }

    function bytesToAddress(bytes memory b) public view returns (address) {

        uint256 result = 0;
        for (uint256 i = b.length - 1; i + 1 > 0; i--) {
            uint256 c = uint256(uint8(b[i]));

            uint256 to_inc = c * (16**((b.length - i - 1) * 2));
            result += to_inc;
        }
        return address(result);
    }

    function flashLoan(
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        address _operator,
        bytes calldata _params
    ) external flashloansEnabled() {

        require(_ids.length < 80, "To many NFTs");

        if (nftType == 1155) {
            IERC1155(nftAddress).safeBatchTransferFrom(
                address(this),
                _operator,
                _ids,
                _amounts,
                "0x0"
            );
        } else {
            for (uint8 index; index < _ids.length; index++) {
                IERC721(nftAddress).safeTransferFrom(
                    address(this),
                    _operator,
                    _ids[index]
                );
            }
        }
        require(
            IFlashLoanReceiver(_operator).executeOperation(
                _ids,
                _amounts,
                msg.sender,
                _params
            ),
            "Execution Failed"
        );

        if (nftType == 1155) {
            IERC1155(nftAddress).safeBatchTransferFrom(
                _operator,
                address(this),
                _ids,
                _amounts,
                "INTERNAL"
            );
        } else {
            for (uint8 index; index < _ids.length; index++) {
                IERC721(nftAddress).transferFrom(
                    _operator,
                    address(this),
                    _ids[index]
                );
            }
        }
    }
}