
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

}// MIT

pragma solidity ^0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

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


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}pragma solidity ^0.8.2;

interface IAdapter {


    function getByteCodeERC20(address nftContract, string memory method, address airDropContract, address account, uint256 tokenId) external returns(bytes memory);


    function getByteCodeERC721(address nftContract, string memory method, address airDropContract, address account, uint256 tokenId) external returns(bytes memory);


    function getByteCodeERC1155(address nftContract, string memory method, address airDropContract, address account, uint256 tokenId) external returns(bytes memory);


}// MIT
pragma solidity ^0.8.2;


contract XAirDrop is Initializable, IERC721ReceiverUpgradeable, IERC1155ReceiverUpgradeable{

    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct AirDrop{
        bool isListed;
        uint256 ercType;
        address airDropTokenContract;
        address airDropContract;
        string method;
        IAdapter adapter;
    }

    bool internal _notEntered;

    address public xNFT;
    address public admin;
    address public pendingAdmin;

    mapping(address => mapping(address => AirDrop)) public erc20Map;
    mapping(address => mapping(address => mapping(uint256 => bool))) isClaim20AirDropMap;
    mapping(address => mapping(address => AirDrop)) public erc721Map;
    mapping(address => mapping(address => mapping(uint256 => bool))) isClaim721AirDropMap;
    mapping(address => mapping(address => AirDrop)) public erc721aMap;
    mapping(address => mapping(address => mapping(uint256 => bool))) isClaim721aAirDropMap;

    function initialize(address _xNFT) external initializer {

        xNFT = _xNFT;
        admin = msg.sender;
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "require admin auth");
        _;
    }

    modifier onlyERC(uint256 ercType) {

        require(ercType == 20 || ercType == 721 || ercType == 72110, "ercType is error");
        _;
    }

    function setPendingAdmin(address newPendingAdmin) external onlyAdmin{

        pendingAdmin = newPendingAdmin;
    }

    function acceptAdmin() public{

        require(msg.sender == pendingAdmin, "only pending admin could accept");
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    function setXNFT(address _xNFT) external onlyAdmin{

        xNFT = _xNFT;
    }

    function addERC(address nftContract, bool _isListed, uint256 _ercType, address _airDropTokenContract, address _airDropContract, string memory _method, IAdapter _adapter) external onlyERC(_ercType) onlyAdmin{

        AirDrop storage airDrop;
        if(_ercType == 20){
            airDrop = erc20Map[nftContract][_airDropContract];
            airDrop.ercType = 20;
        }else if(_ercType == 721){
            airDrop = erc721Map[nftContract][_airDropContract];
            airDrop.ercType = 721;
        }else{ // 721a
            airDrop = erc721aMap[nftContract][_airDropContract];
            airDrop.ercType = 72110;
        }
        require(airDrop.airDropTokenContract == address(0), "already assigned value");
        airDrop.isListed = _isListed;
        airDrop.airDropTokenContract = _airDropTokenContract;
        airDrop.airDropContract = _airDropContract;
        airDrop.method = _method;
        airDrop.adapter = _adapter;
    }

    function setERC(address nftContract, bool _isListed, uint256 _ercType, address _airDropTokenContract, address _airDropContract, string memory _method, IAdapter _adapter) external onlyERC(_ercType) onlyAdmin{

        AirDrop storage airDrop;
        if(_ercType == 20){
            airDrop = erc20Map[nftContract][_airDropContract];
        }else if(_ercType == 721){
            airDrop = erc721Map[nftContract][_airDropContract];
        }else{ // 721a
            airDrop = erc721aMap[nftContract][_airDropContract];
        }
        require(airDrop.airDropTokenContract != address(0), "no value has been assigned");
        airDrop.isListed = _isListed;
        airDrop.airDropTokenContract = _airDropTokenContract;
        airDrop.method = _method;
        airDrop.adapter = _adapter;
    }

    function execution(address nftContract, address airDropContract, address receiver, uint256 tokenId, uint256 ercType) external  onlyERC(ercType) nonReentrant{

        require(msg.sender == xNFT, "not xNFT");
        IERC721Upgradeable(nftContract).setApprovalForAll(xNFT, true);
        if(ercType == 20){
            erc20(nftContract, airDropContract, receiver, tokenId);
        }else if(ercType == 721){
            erc721(nftContract, airDropContract, receiver, tokenId);
        }else if(ercType == 72110){ // 721a
            erc721a(nftContract, airDropContract, receiver, tokenId);
        }
    }

    function erc20(address nftContract, address airDropContract, address receiver, uint256 tokenId) internal{

        AirDrop memory airDrop = erc20Map[nftContract][airDropContract];
        if(airDrop.ercType == 20 && airDrop.isListed == true){
            (bool result, ) = airDrop.airDropContract.call(airDrop.adapter.getByteCodeERC20(nftContract, airDrop.method, airDrop.airDropTokenContract, receiver, tokenId));
            require(result, "20 call execution failed");
            uint256 airdropBalance = IERC20Upgradeable(airDrop.airDropTokenContract).balanceOf(address(this));
            if (airdropBalance > 0) {
                IERC20Upgradeable(airDrop.airDropTokenContract).safeTransfer(receiver, airdropBalance);

                isClaim20AirDropMap[nftContract][airDropContract][tokenId] = true;
            }
        }
    }

    function erc721(address nftContract, address airDropContract, address receiver, uint256 tokenId) internal{

        AirDrop memory airDrop = erc721Map[nftContract][airDropContract];
        if(airDrop.ercType == 721 && airDrop.isListed == true){
            (bool result, ) = airDrop.airDropContract.call(airDrop.adapter.getByteCodeERC721(nftContract, airDrop.method, airDrop.airDropTokenContract, receiver, tokenId));
            require(result, "721 call execution failed");
            IERC721EnumerableUpgradeable ierc721 = IERC721EnumerableUpgradeable(airDrop.airDropTokenContract);
            uint256 airdropBalance = ierc721.balanceOf(address(this));
            if(airdropBalance > 0){
                for(uint256 i=0; i<airdropBalance; i++){
                    uint256 _tokenId = ierc721.tokenOfOwnerByIndex(address(this), 0);
                    ierc721.safeTransferFrom(address(this), receiver, _tokenId);
                }
                isClaim721AirDropMap[nftContract][airDropContract][tokenId] = true;
            }
        }
    }

    function erc721a(address nftContract, address airDropContract, address receiver, uint256 tokenId) internal{

        AirDrop memory airDrop = erc721aMap[nftContract][airDropContract];
        if(airDrop.ercType == 72110 && airDrop.isListed == true){
            IERC721EnumerableUpgradeable ierc721 = IERC721EnumerableUpgradeable(airDrop.airDropTokenContract);
            uint256 erc721aTotalSupplyBefore = ierc721.totalSupply();

            (bool result, ) = airDrop.airDropContract.call(airDrop.adapter.getByteCodeERC721(nftContract, airDrop.method, airDrop.airDropTokenContract, receiver, tokenId));
            require(result, "721a call execution failed");

            uint256 erc721aTotalSupplyAfter = ierc721.totalSupply();
            if((erc721aTotalSupplyAfter - erc721aTotalSupplyBefore) > 0){
                for(uint256 i=erc721aTotalSupplyBefore; i<erc721aTotalSupplyAfter; i++){
                    ierc721.safeTransferFrom(address(this), receiver, i);
                }
                isClaim721aAirDropMap[nftContract][airDropContract][tokenId] = true;
            }
        }
    }

    function getIsClaim20AirDropMap(address nftContracts, address airdropContracts, uint256[] memory tokenIds) external view returns(bool[] memory isClaims){

        isClaims = new bool[](tokenIds.length);
        for(uint256 i=0; i<tokenIds.length; i++){
            isClaims[i] = isClaim20AirDropMap[nftContracts][airdropContracts][tokenIds[i]];
        }
    }

    function getIsClaim721AirDropMap(address nftContracts, address airdropContracts, uint256[] memory tokenIds) external view returns(bool[] memory isClaims){

        isClaims = new bool[](tokenIds.length);
        for(uint256 i=0; i<tokenIds.length; i++){
            isClaims[i] = isClaim721AirDropMap[nftContracts][airdropContracts][tokenIds[i]];
        }
    }

    function getIsClaim721aAirDropMap(address nftContracts, address airdropContracts, uint256[] memory tokenIds) external view returns(bool[] memory isClaims){

        isClaims = new bool[](tokenIds.length);
        for(uint256 i=0; i<tokenIds.length; i++){
            isClaims[i] = isClaim721aAirDropMap[nftContracts][airdropContracts][tokenIds[i]];
        }
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4){

        return this.onERC721Received.selector;
    }

    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external override returns (bytes4){

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived( address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external override returns(bytes4) {

        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) external view override returns (bool){

        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId;
    }
}