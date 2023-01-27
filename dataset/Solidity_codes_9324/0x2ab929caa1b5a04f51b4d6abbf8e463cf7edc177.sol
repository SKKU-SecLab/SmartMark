



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


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;





pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

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

}




pragma solidity ^0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}




pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}




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









pragma solidity ^0.8.4;

contract ANE is ERC721Holder, ERC1155Holder {


    uint256 public counter;

    mapping(bytes32 => AnscaEscrow) anscaEscrowList;
    mapping(address => bytes32[]) ownerEscrowMapping;

    uint256 public FEE = 75;
    bool public paused;

    address owner;
    address feeCollectorAddress;

    enum NftType{NULL, ERC721, ERC1155}

    enum Action{ CREATE, BUY, CANCEL }

    struct AnscaEscrow {
        bytes32 id;
        uint256[] nftIds;
        uint256[] nftQuantities;
        uint256 price;     
        uint256 creationTimestamp;
        address seller;
        address buyer;
        address[] nftContractAddresses;
        NftType[] nftTypes;
        bool open;
        bool zero;
    }

    event ANEEvent(address indexed _from, bytes32 indexed _id, uint8 _action);

    constructor(address _feeCollectorAddress) {
        owner = msg.sender;
        feeCollectorAddress = _feeCollectorAddress;
    }

    function escrowWentWell(bytes32 _id) external view returns(bool) {

        return anscaEscrowList[_id].buyer != address(0);
    }

    function addressIsInvolved(bytes32 _id, address _address) external view returns(bool) {

        return anscaEscrowList[_id].buyer == _address || anscaEscrowList[_id].seller == _address;
    }

    function getAllEscrowsForSender() external view returns(bytes32[] memory){

        return ownerEscrowMapping[msg.sender];
    }
    function getNftIdsByNftEscrowId(bytes32 _id) external view returns(uint256[] memory){

        return anscaEscrowList[_id].nftIds;
    }
    function getAddressesByNftEscrowId(bytes32 _id) external view returns(address[] memory){

        return anscaEscrowList[_id].nftContractAddresses;
    }
    function getNftQuantitiesByNftEscrowId(bytes32 _id) external view returns(uint256[] memory){

        return anscaEscrowList[_id].nftQuantities;
    }
    function getNftTypesByNftEscrowId(bytes32 _id) external view returns(ANE.NftType[] memory){

        return anscaEscrowList[_id].nftTypes;
    }

    function getEscrowById(bytes32 _id) external view returns(string memory) {

        AnscaEscrow memory localAnscaEscrow = anscaEscrowList[_id];

        return string(abi.encodePacked(
            localAnscaEscrow.id,
            ";",
            Strings.toString(localAnscaEscrow.price),
            ";",
            localAnscaEscrow.open ? "TRUE" : "FALSE",
            ";",
            Strings.toHexString(uint256(uint160(address(localAnscaEscrow.seller)))),
            ";",
            Strings.toHexString(uint256(uint160(address(localAnscaEscrow.buyer)))),
            ";",
            Strings.toString(localAnscaEscrow.creationTimestamp)));
    }

    function createEscrow(bytes32 _id, uint256[] calldata _nftIds, address[] calldata _nftContractAddresses, uint256[] calldata _nftQuantities, uint256 _price) external {

        require(!paused, "18");
        require(anscaEscrowList[_id].id != _id || (anscaEscrowList[_id].id == _id && anscaEscrowList[_id].zero),"10");
        require(_nftIds.length > 0 && _nftIds.length < 101, "11");
        require(_nftIds.length == _nftContractAddresses.length && _nftIds.length == _nftQuantities.length, "12");
        require(_price > 0,"13");

        uint256  arrayLength = _nftIds.length;
        AnscaEscrow memory localAnscaEscrow = AnscaEscrow({
            id: _id,
            nftIds: _nftIds,
            nftQuantities: _nftQuantities,
            price: _price,
            seller: msg.sender,
            buyer: address(0),
            nftContractAddresses: _nftContractAddresses,
            nftTypes: new NftType[](arrayLength),
            open: true,
            zero: false,
            creationTimestamp: block.timestamp
        });
        counter++;

        ownerEscrowMapping[msg.sender].push(_id);
        anscaEscrowList[_id] = localAnscaEscrow;

        for (uint i=0; i<arrayLength; i++) {
            if(IERC165(address(_nftContractAddresses[i])).supportsInterface(0x80ac58cd)) { //ERC721
                anscaEscrowList[_id].nftTypes[i] = NftType.ERC721;
                IERC721 erc721Nft = IERC721(address(_nftContractAddresses[i]));
                require(erc721Nft.ownerOf(_nftIds[i]) == msg.sender, "14");
                erc721Nft.safeTransferFrom(msg.sender, address(this), _nftIds[i]);
            } else if (IERC165(address(_nftContractAddresses[i])).supportsInterface(0xd9b67a26)) { //ERC1155
                anscaEscrowList[_id].nftTypes[i] = NftType.ERC1155;
                IERC1155 erc1155Nft = IERC1155(address(_nftContractAddresses[i]));
                require(_nftQuantities[i] > 0, "15");
                require(erc1155Nft.balanceOf( msg.sender, _nftIds[i]) >= _nftQuantities[i], "16");
                erc1155Nft.safeTransferFrom(msg.sender, address(this), _nftIds[i], _nftQuantities[i] < 1 ? 1 : _nftQuantities[i], "");  
            } else {
                revert('17');
            }
        }
        emit ANEEvent(msg.sender, _id, uint8(Action.CREATE));    
    }

    function cancelEscrow(bytes32 _id) external {

        AnscaEscrow memory localAnscaEscrow = anscaEscrowList[_id];
        require(msg.sender == localAnscaEscrow.seller, "20");

        localAnscaEscrow.zero = true;
        localAnscaEscrow.open = false;
        anscaEscrowList[_id] = localAnscaEscrow;

        uint256  arrayLength = anscaEscrowList[_id].nftIds.length;
        for (uint i=0; i<arrayLength; i++) {
            if(anscaEscrowList[_id].nftTypes[i] == NftType.ERC721) {
                IERC721 erc721Nft = IERC721(address(anscaEscrowList[_id].nftContractAddresses[i]));
                erc721Nft.safeTransferFrom(address(this), msg.sender, anscaEscrowList[_id].nftIds[i]);
            } else if (anscaEscrowList[_id].nftTypes[i] == NftType.ERC1155) {
                IERC1155 erc1155Nft = IERC1155(address(anscaEscrowList[_id].nftContractAddresses[i]));
                erc1155Nft.safeTransferFrom(address(this), msg.sender, anscaEscrowList[_id].nftIds[i], anscaEscrowList[_id].nftQuantities[i] < 1 ? 1 : anscaEscrowList[_id].nftQuantities[i], "");            
            }
        }
        emit ANEEvent(msg.sender, _id, uint8(Action.CANCEL));  
    }

    function buyNft(bytes32 _id) external payable {

        AnscaEscrow memory localAnscaEscrow = anscaEscrowList[_id];
        require(localAnscaEscrow.open, "30");
        require(msg.value >= localAnscaEscrow.price, "31");

        localAnscaEscrow.zero = true;
        localAnscaEscrow.open = false;
        localAnscaEscrow.buyer = msg.sender;
        ownerEscrowMapping[msg.sender].push(_id);
        anscaEscrowList[_id] = localAnscaEscrow;

        uint256  arrayLength = anscaEscrowList[_id].nftIds.length;
        for (uint i=0; i<arrayLength; i++) {
            if(anscaEscrowList[_id].nftTypes[i] == NftType.ERC721) {
                IERC721 erc721Nft = IERC721(address(anscaEscrowList[_id].nftContractAddresses[i]));
                erc721Nft.safeTransferFrom(address(this), msg.sender, anscaEscrowList[_id].nftIds[i]);
            } else if (anscaEscrowList[_id].nftTypes[i] == NftType.ERC1155) {
                IERC1155 erc1155Nft = IERC1155(address(anscaEscrowList[_id].nftContractAddresses[i]));
                erc1155Nft.safeTransferFrom(address(this), msg.sender, anscaEscrowList[_id].nftIds[i], anscaEscrowList[_id].nftQuantities[i] < 1 ? 1 : anscaEscrowList[_id].nftQuantities[i], "");            
            }
        }
        uint256 fee = (localAnscaEscrow.price * FEE) / 10000;
        payable(localAnscaEscrow.seller).transfer(localAnscaEscrow.price - fee);
        payable(feeCollectorAddress).transfer(fee);

        emit ANEEvent(msg.sender, _id, uint8(Action.BUY));        
    }


    function changeFeeCollectorAddress(address _adr) external {

        require(msg.sender == owner);
        feeCollectorAddress = _adr;
    }

    function changeFee(uint256 _fee) external {

        require(msg.sender == owner);
        require(_fee <= 100); // 100 = 1%
        FEE = _fee;
    }

    function pause(bool _pause) external {

        require(msg.sender == owner);
        paused = _pause;
    }
}