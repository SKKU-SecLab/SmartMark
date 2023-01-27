
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



contract MultiSendNFTs {


    struct SendContractData721 {
        address contractAddress;
        SendTokenData721[] tokenData; 
    }

    struct SendTokenData721 {
        address recipient;
        uint256 tokenId;
    }

    struct SendContractData1155 {
        address contractAddress;
        SendTokenData1155[] tokenData; 
    }

    struct SendTokenData1155 {
        address recipient;
        uint256 tokenId;
        uint256 amount;
    }

    function multiSend721(SendContractData721[] calldata data) public {

        for (uint i = 0; i < data.length; i++) {
            SendContractData721 memory contractData = data[i];
            require(IERC721(contractData.contractAddress).isApprovedForAll(msg.sender, address(this)), "Contract needs to be approved to send");

            for (uint j = 0; j < contractData.tokenData.length; j++) {
                SendTokenData721 memory tokenData = contractData.tokenData[j];
                require(IERC721(contractData.contractAddress).ownerOf(tokenData.tokenId) == msg.sender, "Can only send tokens that you own");
            }
        }

        for (uint i = 0; i < data.length; i++) {
            SendContractData721 memory contractData = data[i];
            for (uint j = 0; j < contractData.tokenData.length; j++) {
                SendTokenData721 memory tokenData = contractData.tokenData[j];
                IERC721(contractData.contractAddress).safeTransferFrom(msg.sender, tokenData.recipient, tokenData.tokenId);
            }
        }
    }

    function multiSend1155(SendContractData1155[] calldata data) public {

        for (uint i = 0; i < data.length; i++) {
            SendContractData1155 memory contractData = data[i];
            require(IERC1155(contractData.contractAddress).isApprovedForAll(msg.sender, address(this)), "Contract needs to be approved to send");

            for (uint j = 0; j < contractData.tokenData.length; j++) {
                SendTokenData1155 memory tokenData = contractData.tokenData[j];
                require(IERC1155(contractData.contractAddress).balanceOf(msg.sender, tokenData.tokenId) >= tokenData.amount, "Not enough tokens");
            }
        }

        for (uint i = 0; i < data.length; i++) {
            SendContractData1155 memory contractData = data[i];
            for (uint j = 0; j < contractData.tokenData.length; j++) {
                SendTokenData1155 memory tokenData = contractData.tokenData[j];
                IERC1155(contractData.contractAddress).safeTransferFrom(msg.sender, tokenData.recipient, tokenData.tokenId, tokenData.amount, "");
            }
        }
    }

}