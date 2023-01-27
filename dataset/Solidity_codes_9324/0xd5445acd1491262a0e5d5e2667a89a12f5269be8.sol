pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract IERC1155 is IERC165 {

    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);

    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    event URI(string _value, uint256 indexed _id);

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;


    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;


    function balanceOf(address _owner, uint256 _id) external view returns (uint256);


    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);


    function setApprovalForAll(address _operator, bool _approved) external;


    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}

library UintLibrary {

    function toString(uint256 _i) internal pure returns (string memory) {

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
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}

library StringLibrary {

    using UintLibrary for uint256;

    function append(string memory _a, string memory _b) internal pure returns (string memory) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory bab = new bytes(_ba.length + _bb.length);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
        return string(bab);
    }

    function append(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory bbb = new bytes(_ba.length + _bb.length + _bc.length);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bbb[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bbb[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) bbb[k++] = _bc[i];
        return string(bbb);
    }

    function recover(string memory message, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        bytes memory msgBytes = bytes(message);
        bytes memory fullMessage = concat(
            bytes("\x19Ethereum Signed Message:\n"),
            bytes(msgBytes.length.toString()),
            msgBytes,
            new bytes(0), new bytes(0), new bytes(0), new bytes(0)
        );
        return ecrecover(keccak256(fullMessage), v, r, s);
    }

    function concat(bytes memory _ba, bytes memory _bb, bytes memory _bc, bytes memory _bd, bytes memory _be, bytes memory _bf, bytes memory _bg) internal pure returns (bytes memory) {

        bytes memory resultBytes = new bytes(_ba.length + _bb.length + _bc.length + _bd.length + _be.length + _bf.length + _bg.length);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) resultBytes[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) resultBytes[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) resultBytes[k++] = _bc[i];
        for (uint i = 0; i < _bd.length; i++) resultBytes[k++] = _bd[i];
        for (uint i = 0; i < _be.length; i++) resultBytes[k++] = _be[i];
        for (uint i = 0; i < _bf.length; i++) resultBytes[k++] = _bf[i];
        for (uint i = 0; i < _bg.length; i++) resultBytes[k++] = _bg[i];
        return resultBytes;
    }
}

library AddressLibrary {

    function toString(address _addr) internal pure returns (string memory) {

        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract HasSecondarySaleFees is ERC165 {


    event SecondarySaleFees(uint256 tokenId, address[] recipients, uint[] bps);

    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;

    constructor() public {
        _registerInterface(_INTERFACE_ID_FEES);
    }

    function getFeeRecipients(uint256 id) public view returns (address payable[] memory);

    function getFeeBps(uint256 id) public view returns (uint[] memory);

}

contract AbstractSale is Ownable {

    using UintLibrary for uint256;
    using AddressLibrary for address;
    using StringLibrary for string;
    using SafeMath for uint256;

    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;
    uint private constant maxBuyerFeePercentage = 10000;

    uint public buyerFee = 0;
    address payable public beneficiary;

    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    constructor(address payable _beneficiary) public {
        beneficiary = _beneficiary;
    }

    function setBuyerFee(uint256 _buyerFee) public onlyOwner {

        require(_buyerFee <= maxBuyerFeePercentage, "max buyer percentage can't be more than 10000");
        buyerFee = _buyerFee;
    }

    function setBeneficiary(address payable _beneficiary) public onlyOwner {

        beneficiary = _beneficiary;
    }

    function prepareMessage(address token, uint256 tokenId, uint256 price, uint256 fee, uint256 nonce) internal pure returns (string memory) {

        string memory result = string(strConcat(
                bytes(token.toString()),
                bytes(". tokenId: "),
                bytes(tokenId.toString()),
                bytes(". price: "),
                bytes(price.toString()),
                bytes(". nonce: "),
                bytes(nonce.toString())
            ));
        if (fee != 0) {
            return result.append(". fee: ", fee.toString());
        } else {
            return result;
        }
    }

    function strConcat(bytes memory _ba, bytes memory _bb, bytes memory _bc, bytes memory _bd, bytes memory _be, bytes memory _bf, bytes memory _bg) internal pure returns (bytes memory) {

        bytes memory resultBytes = new bytes(_ba.length + _bb.length + _bc.length + _bd.length + _be.length + _bf.length + _bg.length);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) resultBytes[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) resultBytes[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) resultBytes[k++] = _bc[i];
        for (uint i = 0; i < _bd.length; i++) resultBytes[k++] = _bd[i];
        for (uint i = 0; i < _be.length; i++) resultBytes[k++] = _be[i];
        for (uint i = 0; i < _bf.length; i++) resultBytes[k++] = _bf[i];
        for (uint i = 0; i < _bg.length; i++) resultBytes[k++] = _bg[i];
        return resultBytes;
    }

    function transferEther(IERC165 token, uint256 tokenId, address payable owner, uint256 total, uint256 sellerFee) internal {

        uint value = transferFeeToBeneficiary(total, sellerFee);
        if (token.supportsInterface(_INTERFACE_ID_FEES)) {
            HasSecondarySaleFees withFees = HasSecondarySaleFees(address(token));
            address payable[] memory recipients = withFees.getFeeRecipients(tokenId);
            uint[] memory fees = withFees.getFeeBps(tokenId);
            require(fees.length == recipients.length);
            for (uint256 i = 0; i < fees.length; i++) {
                (uint newValue, uint current) = subFee(value, total.mul(fees[i]).div(maxBuyerFeePercentage));
                value = newValue;
                recipients[i].transfer(current);
            }
        }
        owner.transfer(value);
    }

    function transferFeeToBeneficiary(uint total, uint sellerFee) internal returns (uint) {

        (uint value, uint sellerFeeValue) = subFee(total, total.mul(sellerFee).div(maxBuyerFeePercentage));
        uint buyerFeeValue = total.mul(buyerFee).div(maxBuyerFeePercentage);
        uint beneficiaryFee = buyerFeeValue.add(sellerFeeValue);
        if (beneficiaryFee > 0) {
            beneficiary.transfer(beneficiaryFee);
        }
        return value;
    }

    function subFee(uint value, uint fee) internal pure returns (uint newValue, uint realFee) {

        if (value > fee) {
            newValue = value - fee;
            realFee = fee;
        } else {
            newValue = 0;
            realFee = value;
        }
    }
}

contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract OperatorRole is Context {

    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private _operators;

    constructor () internal {

    }

    modifier onlyOperator() {

        require(isOperator(_msgSender()), "OperatorRole: caller does not have the Operator role");
        _;
    }

    function isOperator(address account) public view returns (bool) {

        return _operators.has(account);
    }

    function _addOperator(address account) internal {

        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {

        _operators.remove(account);
        emit OperatorRemoved(account);
    }
}

contract OwnableOperatorRole is Ownable, OperatorRole {

    function addOperator(address account) public onlyOwner {

        _addOperator(account);
    }

    function removeOperator(address account) public onlyOwner {

        _removeOperator(account);
    }
}

contract TransferProxy is OwnableOperatorRole {


    function erc721safeTransferFrom(IERC721 token, address from, address to, uint256 tokenId) external onlyOperator {

        token.safeTransferFrom(from, to, tokenId);
    }

    function erc1155safeTransferFrom(IERC1155 token, address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external onlyOperator {

        token.safeTransferFrom(_from, _to, _id, _value, _data);
    }
}

contract ERC1155SaleNonceHolder is OwnableOperatorRole {

    mapping(bytes32 => uint256) public nonces;

    mapping(bytes32 => uint256) public completed;

    function getNonce(address token, uint256 tokenId, address owner) view public returns (uint256) {

        return nonces[getNonceKey(token, tokenId, owner)];
    }

    function setNonce(address token, uint256 tokenId, address owner, uint256 nonce) public onlyOperator {

        nonces[getNonceKey(token, tokenId, owner)] = nonce;
    }

    function getNonceKey(address token, uint256 tokenId, address owner) pure public returns (bytes32) {

        return keccak256(abi.encodePacked(token, tokenId, owner));
    }

    function getCompleted(address token, uint256 tokenId, address owner, uint256 nonce) view public returns (uint256) {

        return completed[getCompletedKey(token, tokenId, owner, nonce)];
    }

    function setCompleted(address token, uint256 tokenId, address owner, uint256 nonce, uint256 _completed) public onlyOperator {

        completed[getCompletedKey(token, tokenId, owner, nonce)] = _completed;
    }

    function getCompletedKey(address token, uint256 tokenId, address owner, uint256 nonce) pure public returns (bytes32) {

        return keccak256(abi.encodePacked(token, tokenId, owner, nonce));
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

contract ERC20TransferProxy is OwnableOperatorRole {

    function erc20safeTransferFrom(IERC20 token, address from, address to, uint256 value) external onlyOperator {

        require(token.transferFrom(from, to, value), "failure while transferring");
    }
    
    function userBalance(IERC20 token, address user) external view returns(uint256) {

        return token.balanceOf(user);
    }
}

interface ERC1155TokenInterface {

  function getFeeBps(uint256) external view returns (uint256[] memory);

  function getFeeRecipients(uint256) external view returns (address[] memory);

}

contract ERC1155SaleV3 is Ownable, AbstractSale {

    using StringLibrary for string;

    event CloseOrder(address indexed token, uint256 indexed tokenId, address owner, uint256 nonce);
    event Buy(address indexed token, uint256 indexed tokenId, address owner, uint256 price, address buyer, uint256 value);
    uint private constant maxBuyerFeePercentage = 10000;
    
    event CloseOrderERC20(address indexed token, uint256 indexed tokenId, address owner, uint256 nonce, address erc20);
    event BuyERC20(address indexed token, uint256 indexed tokenId, address owner, uint256 price, address buyer, uint256 value, address erc20);

    bytes constant EMPTY = "";
    
    struct Asset {
        IERC1155 token;
        uint256 tokenId;
        address erc20;
        uint256 selling;
        uint256 buying;
        uint256 price;   
    }

    TransferProxy public transferProxy;
    ERC1155SaleNonceHolder public nonceHolder;
    ERC20TransferProxy public erc20TransferProxy;

    constructor(TransferProxy _transferProxy, ERC20TransferProxy _erc20TransferProxy, ERC1155SaleNonceHolder _nonceHolder,  address payable beneficiary) AbstractSale(beneficiary) public {
        transferProxy = _transferProxy;
        nonceHolder = _nonceHolder;
        erc20TransferProxy = _erc20TransferProxy;
    }

    function buy(IERC1155 token, uint256 tokenId, address payable owner, uint256 selling, uint256 buying, uint256 price, uint256 sellerFee, Sig memory signature) public payable {

        uint256 nonce = verifySignature(address(token), tokenId, owner, selling, price, sellerFee, signature);
        uint256 total = price.mul(buying);
        uint256 buyerFeeValue = total.mul(buyerFee).div(maxBuyerFeePercentage);
        require(total.add(buyerFeeValue) == msg.value, "msg.value is incorrect" );
        bool closed = verifyOpenAndModifyState(address(token), tokenId, owner, nonce, selling, buying);
        transferProxy.erc1155safeTransferFrom(token, owner, msg.sender, tokenId, buying, EMPTY);
        transferEther(token, tokenId, owner, total, sellerFee);
        emit Buy(address(token), tokenId, owner, price, msg.sender, buying);
        if (closed) {
            emit CloseOrder(address(token), tokenId, owner, nonce + 1);
        }
    }

    function buyERC20(Asset memory asset, address payable owner, uint256 sellerFee, Sig memory signature) public {

        uint256 nonce = verifySignatureERC20(address(asset.token), asset.tokenId, owner, asset.selling, asset.price, sellerFee, asset.erc20, signature);
        uint256 total = asset.price.mul(asset.buying);
        uint256 buyerFeeValue = total.mul(buyerFee).div(maxBuyerFeePercentage);
        require(erc20TransferProxy.userBalance(IERC20(asset.erc20), msg.sender) >= total.add(buyerFeeValue), "Insufficient Balance" );
        bool closed = verifyOpenAndModifyState(address(asset.token), asset.tokenId, owner, nonce, asset.selling, asset.buying);
        transferProxy.erc1155safeTransferFrom(asset.token, owner, msg.sender, asset.tokenId, asset.buying, EMPTY);
        uint256 sellerFeeToSlash = transferERC20FeeToBeneficiary(total, sellerFee, asset.erc20);
        transferERC20(asset, total, owner, sellerFeeToSlash);
        emit BuyERC20(address(asset.token), asset.tokenId, owner, asset.price, msg.sender, asset.buying, asset.erc20);
        if (closed) {
            emit CloseOrderERC20(address(asset.token), asset.tokenId, owner, nonce + 1, asset.erc20);
        }
    }
    
    function transferERC20(Asset memory asset, uint256 total, address payable owner, uint256 sellerFeeToSlash) internal {

        uint256 creatorFee = getCreatorFee(address(asset.token), asset.tokenId);
        address creator = address(0);
        uint256 creatorSlash = 0;

        if(creatorFee != 0) {
            creator = getCreator(address(asset.token), asset.tokenId);
            creatorSlash = total.mul(creatorFee).div(maxBuyerFeePercentage);
            erc20TransferProxy.erc20safeTransferFrom(IERC20(asset.erc20), msg.sender, creator, creatorSlash);
        }

        uint256 sellerSlash = total.sub(creatorSlash).sub(sellerFeeToSlash);
        erc20TransferProxy.erc20safeTransferFrom(IERC20(asset.erc20), msg.sender, owner, sellerSlash);
    }
    
    function transferERC20FeeToBeneficiary(uint256 price, uint256 sellerFee, address erc20Token) internal returns (uint256) {

        uint256 platformBuyerFee = price.mul(buyerFee).div(maxBuyerFeePercentage);
        erc20TransferProxy.erc20safeTransferFrom(IERC20(erc20Token), msg.sender, beneficiary, platformBuyerFee);
        
        uint256 platformSellerFee = price.mul(sellerFee).div(maxBuyerFeePercentage);
        if(sellerFee > 0) {
            erc20TransferProxy.erc20safeTransferFrom(IERC20(erc20Token), msg.sender, beneficiary, platformSellerFee);   
        }
        
        return platformSellerFee;
    }
    
    function getCreatorFee(address erc1155Adddress, uint256 tokenId) internal view returns (uint256) {

        uint256[] memory fees = ERC1155TokenInterface(erc1155Adddress).getFeeBps(tokenId);
        if(fees.length > 0) {
            return fees[0];
        } else {
            return 0;
        }
    }
    
    function getCreator(address erc1155Adddress, uint256 tokenId) internal view returns (address) {

        address[] memory creators = ERC1155TokenInterface(erc1155Adddress).getFeeRecipients(tokenId);
        if(creators.length > 0) {
            return creators[0];
        } else {
            return address(0);
        }
    }

    function cancel(address token, uint256 tokenId) public payable {

        uint nonce = nonceHolder.getNonce(token, tokenId, msg.sender);
        nonceHolder.setNonce(token, tokenId, msg.sender, nonce + 1);
        emit CloseOrder(token, tokenId, msg.sender, nonce + 1);
    }

    function verifySignature(address token, uint256 tokenId, address payable owner, uint256 selling, uint256 price, uint256 sellerFee, Sig memory signature) view internal returns (uint256 nonce) {

        nonce = nonceHolder.getNonce(token, tokenId, owner);
        require(prepareMessage(token, tokenId, price, selling, sellerFee, nonce).recover(signature.v, signature.r, signature.s) == owner, "incorrect signature");
    }
    
    function verifySignatureERC20(address token, uint256 tokenId, address payable owner, uint256 selling, uint256 price, uint256 sellerFee, address erc20, Sig memory signature) view internal returns (uint256 nonce) {

        nonce = nonceHolder.getNonce(token, tokenId, owner);
        require(prepareMessageERC20(token, tokenId, price, selling, sellerFee, nonce, erc20).recover(signature.v, signature.r, signature.s) == owner, "incorrect signature");
    }

    function verifyOpenAndModifyState(address token, uint256 tokenId, address payable owner, uint256 nonce, uint256 selling, uint256 buying) internal returns (bool) {

        uint comp = nonceHolder.getCompleted(token, tokenId, owner, nonce).add(buying);
        require(comp <= selling);
        nonceHolder.setCompleted(token, tokenId, owner, nonce, comp);

        if (comp == selling) {
            nonceHolder.setNonce(token, tokenId, owner, nonce + 1);
            return true;
        }
        return false;
    }

    function prepareMessage(address token, uint256 tokenId, uint256 price, uint256 value, uint256 fee, uint256 nonce) public pure returns (string memory) {

        return prepareMessage(token, tokenId, price, fee, nonce).append(". value: ", value.toString());
    }

    function prepareMessageERC20(address token, uint256 tokenId, uint256 price, uint256 value, uint256 fee, uint256 nonce, address erc20) public pure returns (string memory) {

        return prepareMessage(token, tokenId, price, value, fee, nonce).append(". erc20: ", erc20.toString());
    }
}