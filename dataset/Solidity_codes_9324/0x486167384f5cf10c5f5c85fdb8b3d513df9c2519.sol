
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

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT
pragma solidity ^0.8.6;


contract CloneFactory {

    function createClone(address target) internal returns (address result) {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }

    function isClone(address target, address query)
        internal
        view
        returns (bool result)
    {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000
            )
            mstore(add(clone, 0xa), targetBytes)
            mstore(
                add(clone, 0x1e),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;

interface ICollectionStruct {

    struct BaseCollectionStruct {
        string name;
        string symbol;
        address admin;
        uint256 maximumTokens;
        uint16 maxPurchase;
        uint16 maxHolding;
        uint256 price;
        uint256 publicSaleStartTime;
        string projectURI;
    }

    struct Whitelist {
        bytes32 root;
        string cid;
    }

    struct PresaleableStruct {
        uint256 presaleReservedTokens;
        uint256 presalePrice;
        uint256 presaleStartTime;
        uint256 presaleMaxHolding;
        Whitelist presaleWhitelist;
    }

    struct PaymentSplitterStruct {
        address simplr;
        uint256 simplrShares;
        address[] payees;
        uint256[] shares;
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;

interface IAffiliateRegistry {

    function setAffiliateShares(uint256 _affiliateShares, bytes32 _projectId)
        external;


    function registerProject(string memory projectName, uint256 affiliateShares)
        external
        returns (bytes32 projectId);


    function getProjectId(string memory _projectName, address _projectOwner)
        external
        view
        returns (bytes32 projectId);


    function getAffiliateShareValue(
        bytes memory signature,
        address affiliate,
        bytes32 projectId,
        uint256 value
    ) external view returns (bool _isAffiliate, uint256 _shareValue);

}// GPL-3.0-or-later
pragma solidity 0.8.11;


interface ICollection is ICollectionStruct {

    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    function setupWithAffiliate(
        BaseCollectionStruct memory _baseCollection,
        PresaleableStruct memory _presaleable,
        PaymentSplitterStruct memory _paymentSplitter,
        bytes32 _projectURIProvenance,
        RoyaltyInfo memory _royalties,
        uint256 _reserveTokens,
        IAffiliateRegistry _registry,
        bytes32 _projectId
    ) external;


    function setup(
        BaseCollectionStruct memory _baseCollection,
        PresaleableStruct memory _presaleable,
        PaymentSplitterStruct memory _paymentSplitter,
        bytes32 _projectURIProvenance,
        RoyaltyInfo memory _royalties,
        uint256 _reserveTokens
    ) external;


    function setMetadata(string memory _metadata) external;

}// GPL-3.0-or-later
pragma solidity 0.8.11;


contract CollectionFactoryV2 is Pausable, Ownable, CloneFactory {

    string public constant VERSION = "0.2.0";

    address public affiliateRegistry;

    address public freePass;

    address public simplr;

    uint256 public simplrShares;

    uint256 public upfrontFee;

    uint256 public totalWithdrawn;

    bytes32 public affiliateProjectId;

    mapping(uint256 => address) public mastercopies;

    event CollectionCreated(
        address indexed collection,
        address indexed admin,
        uint256 indexed collectionType
    );

    event NewCollectionTypeAdded(
        uint256 indexed collectionType,
        address mastercopy,
        bytes data
    );


    constructor(
        address _masterCopy,
        bytes memory _data,
        address _simplr,
        address _newRegistry,
        bytes32 _newProjectId,
        uint256 _simplrShares,
        uint256 _upfrontFee
    ) {
        require(_masterCopy != address(0), "CFv2:001");
        require(_simplr != address(0), "CFv2:002");
        simplr = _simplr;
        simplrShares = _simplrShares;
        upfrontFee = _upfrontFee;
        affiliateRegistry = _newRegistry;
        affiliateProjectId = _newProjectId;
        _addNewCollectionType(_masterCopy, 1, _data);
    }


    function setSimplr(address _simplr) external onlyOwner {

        require(_simplr != address(0) && simplr != _simplr, "CFv2:003");
        simplr = _simplr;
    }

    function setFreePass(address _freePass) external onlyOwner {

        require(
            _freePass != address(0) &&
                IERC165(_freePass).supportsInterface(type(IERC721).interfaceId),
            "CFv2:010"
        );
        freePass = _freePass;
    }

    function setSimplrShares(uint256 _simplrShares) external onlyOwner {

        simplrShares = _simplrShares;
    }

    function setUpfrontFee(uint256 _upfrontFee) external onlyOwner {

        upfrontFee = _upfrontFee;
    }

    function setAffiliateRegistry(address _newRegistry) external onlyOwner {

        affiliateRegistry = _newRegistry;
    }

    function setAffiliateProjectId(bytes32 _newProjectId) external onlyOwner {

        affiliateProjectId = _newProjectId;
    }

    function setMastercopy(address _newMastercopy, uint256 _type)
        external
        onlyOwner
    {

        require(
            _newMastercopy != address(0) &&
                _newMastercopy != mastercopies[_type],
            "CFv2:004"
        );
        require(mastercopies[_type] != address(0), "CFv2:005");
        mastercopies[_type] = _newMastercopy;
    }

    function withdraw(uint256 _value) external onlyOwner {

        require(_value <= address(this).balance, "CFv2:008");
        totalWithdrawn += _value;
        Address.sendValue(payable(simplr), _value);
    }

    function pause() external onlyOwner whenNotPaused {

        _pause();
    }

    function unpause() external onlyOwner whenPaused {

        _unpause();
    }

    function addNewCollectionType(
        address _mastercopy,
        uint256 _type,
        bytes memory _data
    ) external onlyOwner {

        _addNewCollectionType(_mastercopy, _type, _data);
    }


    function createCollection(
        uint256 _type,
        ICollection.BaseCollectionStruct memory _baseCollection,
        ICollection.PresaleableStruct memory _presaleable,
        ICollection.PaymentSplitterStruct memory _paymentSplitter,
        bytes32 _projectURIProvenance,
        ICollection.RoyaltyInfo memory _royalties,
        uint256 _reserveTokens,
        string memory _metadata,
        bool _isAffiliable,
        bool _useSeat,
        uint256 _seatId
    ) external payable whenNotPaused {

        require(mastercopies[_type] != address(0), "CFv2:005");
        if (_useSeat && IERC721(freePass).balanceOf(msg.sender) > 0) {
            _paymentSplitter.simplrShares = 1;
            IERC721(freePass).transferFrom(msg.sender, address(this), _seatId);
        } else {
            require(msg.value == upfrontFee, "CFv2:006");
            _paymentSplitter.simplrShares = simplrShares;
        }
        _paymentSplitter.simplr = simplr;
        address collection = createClone(mastercopies[_type]);
        ICollection(collection).setMetadata(_metadata);
        if (
            _isAffiliable &&
            affiliateRegistry != address(0) &&
            affiliateProjectId != bytes32(0)
        ) {
            ICollection(collection).setupWithAffiliate(
                _baseCollection,
                _presaleable,
                _paymentSplitter,
                _projectURIProvenance,
                _royalties,
                _reserveTokens,
                IAffiliateRegistry(affiliateRegistry),
                affiliateProjectId
            );
        } else {
            ICollection(collection).setup(
                _baseCollection,
                _presaleable,
                _paymentSplitter,
                _projectURIProvenance,
                _royalties,
                _reserveTokens
            );
        }
        emit CollectionCreated(collection, _baseCollection.admin, _type);
    }


    function _addNewCollectionType(
        address _mastercopy,
        uint256 _type,
        bytes memory _data
    ) private {

        require(mastercopies[_type] == address(0), "CFv2:009");
        require(_mastercopy != address(0), "CFv2:001");
        mastercopies[_type] = _mastercopy;
        emit NewCollectionTypeAdded(_type, _mastercopy, _data);
    }
}