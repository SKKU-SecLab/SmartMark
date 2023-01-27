

pragma solidity 0.7.6;




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


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool[] memory) {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool, bool)
    {

        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return (false, false);
        return (success, abi.decode(result, (bool)));
    }
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


interface IStarUpdateListener is IERC165 {

    function onQuasarUpdated(uint256 id, uint256 oldAmount, uint256 newAmount) external;

    function onPowahUpdated(uint256 id, uint256 oldPowah, uint256 newPowah) external;

}


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}


interface IStarNFT is IERC1155 {

    event PowahUpdated(uint256 indexed id, uint256 indexed oldPoints, uint256 indexed newPoints);


    function isOwnerOf(address, uint256) external view returns (bool);

    function starInfo(uint256) external view returns (uint128 powah, uint128 mintBlock, address originator);

    function quasarInfo(uint256) external view returns (uint128 mintBlock, IERC20 stakeToken, uint256 amount, uint256 campaignID);

    function superInfo(uint256) external view returns (uint128 mintBlock, IERC20[] memory stakeToken, uint256[] memory amount, uint256 campaignID);


    function mint(address account, uint256 powah) external returns (uint256);

    function mintBatch(address account, uint256 amount, uint256[] calldata powahArr) external returns (uint256[] memory);

    function burn(address account, uint256 id) external;

    function burnBatch(address account, uint256[] calldata ids) external;


    function mintQuasar(address account, uint256 powah, uint256 cid, IERC20 stakeToken, uint256 amount) external returns (uint256);

    function burnQuasar(address account, uint256 id) external;


    function mintSuper(address account, uint256 powah, uint256 campaignID, IERC20[] calldata stakeTokens, uint256[] calldata amounts) external returns (uint256);

    function burnSuper(address account, uint256 id) external;

    function updatePowah(address owner, uint256 id, uint256 powah) external;

}


contract StarNFT is ERC165, IERC1155, IERC1155MetadataURI, IStarNFT {

    using SafeMath for uint256;
    using Address for address;
    using ERC165Checker for address;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event BurnQuasar(uint256 indexed id);
    event BurnSuper(uint256 indexed id);
    modifier onlyOwner() {

        require(msg.sender == _owner, "Must be owner");
        _;
    }
    modifier onlyGalaxyCommunity() {

        require(msg.sender == _galaxyCommunityAddress, "must be galaxy community");
        _;
    }
    modifier onlyMinter() {

        require(_minters[msg.sender], "must be minter");
        _;
    }
    modifier onlyOperator() {

        require(_operators[msg.sender], "must be operator");
        _;
    }
    struct NFTInfo {
        uint128 mintBlock;
        uint128 powah;
        address originator;
    }

    struct Quasar {
        IERC20 stakeToken;
        uint256 amount;
        uint256 campaignID;
    }

    struct Super {
        IERC20[] backingTokens;
        uint256[] backingAmounts;
        uint256 campaignID;
    }

    bool private _initialized;

    string private _baseURI;

    address private _owner;

    address private _galaxyCommunityAddress;

    mapping(address => bool) private _minters;

    mapping(address => bool) private _operators;

    uint256 private _starCount;
    mapping(uint256 => address) private _starBelongTo;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => NFTInfo) private _stars;
    mapping(uint256 => Quasar) private _quasars;
    mapping(uint256 => Super) private _supers;

    function initialize(address owner, address galaxyCommunity) external {

        require(!_initialized, "Contract already initialized");
        _owner = owner;
        _galaxyCommunityAddress = galaxyCommunity;

        _registerInterface(0xd9b67a26);
        _registerInterface(0x01ffc9a7);

        _registerInterface(0x0e89341c);
        _initialized = true;
    }

    function setApprovalForAll(address operator, bool approved) external override {

        require(msg.sender != operator, "Setting approval status for self");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external override {

        require(amount == 1, "Invalid amount");
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "Transfer caller is neither owner nor approved"
        );
        require(isOwnerOf(from, id), "Not the owner");

        _starBelongTo[id] = to;

        emit TransferSingle(msg.sender, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external override {

        require(ids.length == amounts.length, "Array(ids, amounts) length mismatch");
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "Transfer caller is neither owner nor approved");

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            require(isOwnerOf(from, id), "Not the owner");
            _starBelongTo[id] = to;
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, amounts, data);
    }

    function mint(address account, uint256 powah) external onlyMinter override returns (uint256) {

        return _mint(account, powah);
    }

    function mintBatch(address account, uint256 amount, uint256[] calldata powahArr) external onlyMinter override returns (uint256[] memory) {

        require(account != address(0), "Must not mint to null address");
        require(powahArr.length == amount, "Array(powah) length mismatch param(amount)");
        return _mintBatch(account, amount, powahArr);
    }

    function burn(address account, uint256 id) external onlyMinter override {

        require(isOwnerOf(account, id), "Not the owner");
        _burn(account, id);
    }

    function burnBatch(address account, uint256[] calldata ids) external onlyMinter override {

        for (uint i = 0; i < ids.length; i++) {
            require(isOwnerOf(account, ids[i]), "Not the owner");
        }
        _burnBatch(account, ids);
    }

    function mintQuasar(address account, uint256 powah, uint256 campaignID, IERC20 stakeToken, uint256 erc20Amount) external onlyMinter override returns (uint256) {

        return _mintQuasar(account, powah, campaignID, stakeToken, erc20Amount);
    }

    function burnQuasar(address account, uint256 id) external onlyMinter override {

        require(isOwnerOf(account, id), "Not the owner");
        _burnQuasar(id);
    }

    function mintSuper(address account, uint256 powah, uint256 campaignID, IERC20[] calldata stakeTokens, uint256[] calldata amounts) external onlyMinter override returns (uint256) {

        require(account != address(0), "Must not mint to null address");
        return _mintSuper(account, powah, campaignID, stakeTokens, amounts);
    }

    function burnSuper(address account, uint256 id) external onlyMinter override {

        require(isOwnerOf(account, id), "Must be owner of this Super NFT");
        _burnSuper(id);
    }

    function updatePowah(address owner, uint256 id, uint256 powah) external onlyOperator override {

        require(isOwnerOf(owner, id), "Must be owner");

        emit PowahUpdated(id, _stars[id].powah, powah);
        _doSafePowahUpdatedAcceptanceCheck(owner, id, _stars[id].powah, powah);

        _stars[id].powah = uint128(powah);
    }

    function setURI(string memory newURI) external onlyGalaxyCommunity {

        _baseURI = newURI;
    }

    function transferGalaxyCommunity(address newGalaxyCommunity) external onlyGalaxyCommunity {

        require(newGalaxyCommunity != address(0), "NewGalaxyCommunity must not be null address");
        _galaxyCommunityAddress = newGalaxyCommunity;
    }

    function transferOwner(address newOwner) external onlyOwner {

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function addMinter(address minter) external onlyOwner {

        require(minter != address(0), "Minter must not be null address");
        require(!_minters[minter], "Minter already added");
        _minters[minter] = true;
    }

    function removeMinter(address minter) external onlyOwner {

        require(_minters[minter], "Minter does not exist");
        delete _minters[minter];
    }

    function addOperator(address operator) external onlyOwner {

        require(operator != address(0), "Operator must not be null address");
        require(!_operators[operator], "Minter already added");
        _operators[operator] = true;
    }

    function removeOperator(address operator) external onlyOwner {

        require(_operators[operator], "Operator does not exist");
        delete _operators[operator];
    }

    function initialized() external view returns (bool) {

        return _initialized;
    }

    function starNFTOwner() external view returns (address) {

        return _owner;
    }

    function galaxyCommunity() external view returns (address) {

        return _galaxyCommunityAddress;
    }

    function isMinter(address minter) external view returns (bool) {

        return _minters[minter];
    }

    function isOperator(address operator) external view returns (bool) {

        return _operators[operator];
    }

    function isApprovedForAll(address account, address operator) public view override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function baseURI() external view returns (string memory) {

        return _baseURI;
    }

    function starNFTCount() external view returns (uint256) {

        return _starCount;
    }

    function uri(uint256 id) external view override returns (string memory) {

        require(id <= _starCount, "Star nft does not exist");
        if (bytes(_baseURI).length == 0) {
            return "";
        } else {
            return string(abi.encodePacked(_baseURI, uint2str(id), ".json"));
        }
    }

    function isOwnerOf(address account, uint256 id) public view override returns (bool) {

        require(account != address(0), "Owner must not be null address");
        return _starBelongTo[id] == account;
    }

    function starInfo(uint256 id) external view override returns (uint128 powah, uint128 mintBlock, address originator) {

        powah = _stars[id].powah;
        mintBlock = _stars[id].mintBlock;
        originator = _stars[id].originator;
    }

    function quasarInfo(uint256 id) external view override returns (uint128 mintBlock, IERC20 stakeToken, uint256 amount, uint256 campaignID) {

        mintBlock = _stars[id].mintBlock;
        stakeToken = _quasars[id].stakeToken;
        amount = _quasars[id].amount;
        campaignID = _quasars[id].campaignID;
    }
    function superInfo(uint256 id) external view override returns (uint128 mintBlock, IERC20[] memory stakeToken, uint256[] memory amount, uint256 campaignID){

        mintBlock = _stars[id].mintBlock;
        campaignID = _supers[id].campaignID;
        stakeToken = _supers[id].backingTokens;
        amount = _supers[id].backingAmounts;
    }

    function balanceOf(address account, uint256 id) public view override returns (uint256) {

        if (isOwnerOf(account, id)) {
            return 1;
        }
        return 0;
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view override returns (uint256[] memory){

        require(accounts.length == ids.length, "Array(accounts, ids) length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function _mint(address account, uint256 powah) private returns (uint256) {

        require(account != address(0), "Must not mint to null address");
        _starCount++;
        uint256 sID = _starCount;
        _starBelongTo[sID] = account;
        _stars[sID] = NFTInfo({
        powah : uint128(powah),
        mintBlock : uint128(block.number),
        originator : account
        });

        emit TransferSingle(msg.sender, address(0), account, sID, 1);

        _doSafeTransferAcceptanceCheck(msg.sender, address(0), account, sID, 1, "");

        return sID;
    }

    function _mintQuasar(address account, uint256 powah, uint256 campaignID, IERC20 stakeToken, uint256 amount) private returns (uint256) {

        uint256 sID = _mint(account, powah);
        _quasars[sID] = Quasar({
        stakeToken : stakeToken,
        amount : amount,
        campaignID : campaignID
        });
        return sID;
    }

    function _mintSuper(address account, uint256 powah, uint256 campaignID, IERC20[] calldata stakeTokens, uint256[] calldata amounts) private returns (uint256){

        require(account != address(0), "Must not mint to null address");
        require(stakeTokens.length > 0, "Array(stakeTokens) must not be empty");
        require(stakeTokens.length == amounts.length, "Array(stakeTokens, amounts) length mismatch");

        uint256 sID = _mint(account, powah);
        _supers[sID].campaignID = campaignID;
        _supers[sID].backingTokens = stakeTokens;
        _supers[sID].backingAmounts = amounts;

        return sID;
    }

    function _mintBatch(address to, uint256 amount, uint256[] calldata powahArr) private returns (uint256[] memory) {

        uint256[] memory ids = new uint256[](amount);
        uint256[] memory amounts = new uint256[](amount);
        for (uint i = 0; i < ids.length; i++) {
            _starCount++;
            _starBelongTo[_starCount] = to;
            _stars[_starCount] = NFTInfo({
            powah : uint128(powahArr[i]),
            mintBlock : uint128(block.number),
            originator : to
            });
            ids[i] = _starCount;
            amounts[i] = 1;
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, address(0), to, ids, amounts, "");

        return ids;
    }

    function _burn(address account, uint256 id) private {

        delete _starBelongTo[id];
        delete _quasars[id];
        delete _supers[id];
        delete _stars[id];

        emit TransferSingle(msg.sender, account, address(0), id, 1);
    }

    function _burnQuasar(uint256 id) private {

        delete _quasars[id];

        emit BurnQuasar(id);
    }

    function _burnSuper(uint256 id) private {

        delete _supers[id].backingTokens;
        delete _supers[id].backingAmounts;
        delete _supers[id];

        emit BurnSuper(id);
    }

    function _burnBatch(address account, uint256[] memory ids) private {

        uint256[] memory amounts = new uint256[](ids.length);
        for (uint i = 0; i < ids.length; i++) {
            delete _starBelongTo[ids[i]];
            delete _quasars[ids[i]];
            delete _supers[ids[i]];
            delete _stars[ids[i]];
            amounts[i] = 1;
        }

        emit TransferBatch(msg.sender, account, address(0), ids, amounts);
    }

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
                    revert("ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("transfer to non ERC1155Receiver implementer");
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
                    revert("ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeQuasarUpdatedAcceptanceCheck(
        address owner,
        uint256 id,
        uint256 oldAmount,
        uint256 newAmount
    )
    private
    {

        if (owner.isContract() && owner.supportsERC165()) {
            if (
                IERC165(owner).supportsInterface(
                    IStarUpdateListener(0).onQuasarUpdated.selector
                )
            ) {
                IStarUpdateListener(owner).onQuasarUpdated(id, oldAmount, newAmount);
            }
        }
    }

    function _doSafePowahUpdatedAcceptanceCheck(
        address owner,
        uint256 id,
        uint256 oldPowah,
        uint256 newPowah
    )
    private
    {

        if (owner.isContract() && owner.supportsERC165()) {
            if (
                IERC165(owner).supportsInterface(
                    IStarUpdateListener(0).onPowahUpdated.selector
                )
            ) {
                IStarUpdateListener(owner).onPowahUpdated(id, oldPowah, newPowah);
            }
        }
    }

    function uint2str(uint _i) internal pure returns (string memory) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bStr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bStr[k] = b1;
            _i /= 10;
        }
        return string(bStr);
    }
}