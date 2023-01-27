
pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

}//MIT
pragma solidity 0.7.5;


contract ClaimERC1155 {

    bytes32 internal _merkleRoot;
    IERC1155 internal immutable _asset;
    address internal immutable _assetsHolder;
    event ClaimedAssets(address to, uint256[] assetIds, uint256[] assetValues);

    constructor(IERC1155 asset, address assetsHolder) {
        _asset = asset;
        if (assetsHolder == address(0)) {
            assetsHolder = address(this);
        }
        _assetsHolder = assetsHolder;
    }

    function _claimERC1155(
        address to,
        uint256[] calldata assetIds,
        uint256[] calldata assetValues,
        bytes32[] calldata proof,
        bytes32 salt
    ) internal {

        _checkValidity(to, assetIds, assetValues, proof, salt);
        _sendAssets(to, assetIds, assetValues);
        emit ClaimedAssets(to, assetIds, assetValues);
    }

    function _checkValidity(
        address to,
        uint256[] memory assetIds,
        uint256[] memory assetValues,
        bytes32[] memory proof,
        bytes32 salt
    ) internal view {

        require(assetIds.length == assetValues.length, "INVALID_INPUT");
        bytes32 leaf = _generateClaimHash(to, assetIds, assetValues, salt);
        require(_verify(proof, leaf), "INVALID_CLAIM");
    }

    function _generateClaimHash(
        address to,
        uint256[] memory assetIds,
        uint256[] memory assetValues,
        bytes32 salt
    ) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(to, assetIds, assetValues, salt));
    }

    function _verify(bytes32[] memory proof, bytes32 leaf) internal view returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == _merkleRoot;
    }

    function _sendAssets(
        address to,
        uint256[] memory assetIds,
        uint256[] memory assetValues
    ) internal {

        _asset.safeBatchTransferFrom(_assetsHolder, to, assetIds, assetValues, "");
    }
}//MIT
pragma solidity 0.7.5;

contract WithAdmin {

    address internal _admin;

    event AdminChanged(address oldAdmin, address newAdmin);

    modifier onlyAdmin() {

        require(msg.sender == _admin, "ADMIN_ONLY");
        _;
    }

    function getAdmin() external view returns (address) {

        return _admin;
    }

    function changeAdmin(address newAdmin) external {

        require(msg.sender == _admin, "ADMIN_ACCESS_DENIED");
        emit AdminChanged(_admin, newAdmin);
        _admin = newAdmin;
    }
}//MIT
pragma solidity 0.7.5;


contract AssetGiveaway is WithAdmin, ClaimERC1155 {

    bytes4 private constant ERC1155_RECEIVED = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED = 0xbc197c81;
    uint256 internal immutable _expiryTime;
    mapping(address => bool) public claimed;

    constructor(
        address asset,
        address admin,
        bytes32 merkleRoot,
        address assetsHolder,
        uint256 expiryTime
    ) ClaimERC1155(IERC1155(asset), assetsHolder) {
        _admin = admin;
        _merkleRoot = merkleRoot;
        _expiryTime = expiryTime;
    }

    function setMerkleRoot(bytes32 merkleRoot) external onlyAdmin {

        require(_merkleRoot == 0, "MERKLE_ROOT_ALREADY_SET");
        _merkleRoot = merkleRoot;
    }

    function claimAssets(
        address to,
        uint256[] calldata assetIds,
        uint256[] calldata assetValues,
        bytes32[] calldata proof,
        bytes32 salt
    ) external {

        require(block.timestamp < _expiryTime, "CLAIM_PERIOD_IS_OVER");
        require(to != address(0), "INVALID_TO_ZERO_ADDRESS");
        require(claimed[to] == false, "DESTINATION_ALREADY_CLAIMED");
        claimed[to] = true;
        _claimERC1155(to, assetIds, assetValues, proof, salt);
    }

    function onERC1155Received(
        address, /*operator*/
        address, /*from*/
        uint256, /*id*/
        uint256, /*value*/
        bytes calldata /*data*/
    ) external pure returns (bytes4) {

        return ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address, /*from*/
        uint256[] calldata, /*ids*/
        uint256[] calldata, /*values*/
        bytes calldata /*data*/
    ) external pure returns (bytes4) {

        return ERC1155_BATCH_RECEIVED;
    }
}