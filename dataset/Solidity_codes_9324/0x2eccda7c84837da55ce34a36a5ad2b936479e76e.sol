
pragma solidity 0.8.1;

interface IMoonCatAcclimator {

    function getApproved(uint256 tokenId) external view returns (address);

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address);

    function balanceOf(address _owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);

}

interface IMoonCatRescue {

    function rescueOrder(uint256 tokenId) external view returns (bytes5);

    function catOwners(bytes5 catId) external view returns (address);

}

interface IReverseResolver {

    function claim(address owner) external returns (bytes32);

}

interface IRegistry {

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function owner(bytes32 node) external view returns (address);

}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

}
interface IERC721 {

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

}

contract MoonCatResolver {


    IMoonCatAcclimator MCA = IMoonCatAcclimator(0xc3f733ca98E0daD0386979Eb96fb1722A1A05E69);
    IMoonCatRescue MCR = IMoonCatRescue(0x60cd862c9C687A9dE49aecdC3A99b74A4fc54aB6);


    mapping(bytes32 => uint256) internal NamehashMapping; // ENS namehash => Rescue ID of MoonCat
    mapping(uint256 => mapping(uint256 => bytes)) internal MultichainMapping; // Rescue ID of MoonCat => Multichain ID => value
    mapping(uint256 => mapping(string => string)) internal TextKeyMapping; // Rescue ID of MoonCat => text record key => value
    mapping(uint256 => bytes) internal ContentsMapping; // Rescue ID of MoonCat => content hash
    mapping(uint256 => address) internal lastAnnouncedAddress; // Rescue ID of MoonCat => address that was last emitted in an AddrChanged Event

    address payable public owner;
    bytes32 immutable public rootHash;
    string public ENSDomain; // Reference for the ENS domain this contract resolves
    string public avatarBaseURI = "eip155:1/erc721:0xc3f733ca98e0dad0386979eb96fb1722a1a05e69/";
    uint64 public defaultTTL = 86400;

    uint256 constant internal avatarKeyLength = 6;
    bytes32 constant internal avatarKeyHash = keccak256("avatar");

    event AddrChanged(bytes32 indexed node, address a);
    event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);
    event TextChanged(bytes32 indexed node, string indexedKey, string key);
    event ContenthashChanged(bytes32 indexed node, bytes hash);

    modifier onlyOwner () {

        require(msg.sender == owner, "Only Owner");
        _;
    }

    modifier onlyMoonCatOwner (uint256 rescueOrder) {

        require(MCR.catOwners(MCR.rescueOrder(rescueOrder)) == address(MCA), "Not Acclimated");
        require(msg.sender == MCA.ownerOf(rescueOrder), "Not MoonCat's owner");
        _;
    }


    constructor(bytes32 _rootHash, string memory _ENSDomain){
        owner = payable(msg.sender);
        rootHash = _rootHash;
        ENSDomain = _ENSDomain;
        IReverseResolver(0x084b1c3C81545d370f3634392De611CaaBFf8148)
            .claim(msg.sender);
    }

    function transferOwnership (address payable newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setAvatarBaseUrl(string calldata url) public onlyOwner {

        avatarBaseURI = url;
    }

    function setDefaultTTL(uint64 newTTL) public onlyOwner {

        defaultTTL = newTTL;
    }

    function giveControl(bytes32 nodeId) public onlyOwner {

        IRegistry(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e).setSubnodeOwner(rootHash, nodeId, owner);
    }

    function withdrawForeignERC20(address tokenContract) public onlyOwner {

        IERC20 token = IERC20(tokenContract);
        token.transfer(owner, token.balanceOf(address(this)));
    }

    function withdrawForeignERC721(address tokenContract, uint256 tokenId) public onlyOwner {

        IERC721(tokenContract).safeTransferFrom(address(this), owner, tokenId);
    }

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {

        return interfaceID == 0x01ffc9a7 // supportsInterface call itself
            || interfaceID == 0x3b3b57de // EIP137: ENS resolver
            || interfaceID == 0xf1cb7e06 // EIP2304: Multichain addresses
            || interfaceID == 0x59d1d43c // EIP634: ENS text records
            || interfaceID == 0xbc1c58d1 // EIP1577: contenthash
        ;
    }

    function addr(bytes32 nodeID) public view returns (address) {

        uint256 rescueOrder = getRescueOrderFromNodeId(nodeID);
        address actualOwner = MCA.ownerOf(rescueOrder);
        if (
            MCR.catOwners(MCR.rescueOrder(rescueOrder)) != address(MCA) ||
            actualOwner != lastAnnouncedAddress[rescueOrder]
        ) {
            return address(0); // Not Acclimated/Announced; return zero (per spec)
        } else {
            return lastAnnouncedAddress[rescueOrder];
        }
    }

    function addr(bytes32 nodeID, uint256 coinType) public view returns (bytes memory) {

        uint256 rescueOrder = getRescueOrderFromNodeId(nodeID);
        if (MCR.catOwners(MCR.rescueOrder(rescueOrder)) != address(MCA)) {
            return bytes(''); // Not Acclimated; return zero (per spec)
        }
        if (coinType == 60) {
            return abi.encodePacked(addr(nodeID));
        } else {
            return MultichainMapping[rescueOrder][coinType];
        }
    }

    function setAddr(bytes32 nodeID, uint256 coinType, bytes calldata newAddr) public {

        uint256 rescueOrder = getRescueOrderFromNodeId(nodeID);
        setAddr(rescueOrder, coinType, newAddr);
    }

    function setAddr(uint256 rescueOrder, uint256 coinType, bytes calldata newAddr) public onlyMoonCatOwner(rescueOrder) {

        if (coinType == 60) {
            announceMoonCat(rescueOrder);
            return;
        }
        emit AddressChanged(getSubdomainNameHash(uint2str(rescueOrder)), coinType, newAddr);
        emit AddressChanged(getSubdomainNameHash(bytes5ToHexString(MCR.rescueOrder(rescueOrder))), coinType, newAddr);
        MultichainMapping[rescueOrder][coinType] = newAddr;
    }

    function text(bytes32 nodeID, string calldata key) public view returns (string memory) {

        uint256 rescueOrder = getRescueOrderFromNodeId(nodeID);

        string memory value = TextKeyMapping[rescueOrder][key];
        if (bytes(value).length > 0) {
            return value;
        }

        bytes memory keyBytes = bytes(key);
        if (keyBytes.length == avatarKeyLength && keccak256(keyBytes) == avatarKeyHash){
            return string(abi.encodePacked(avatarBaseURI,  uint2str(rescueOrder)));
        }

        return value;
    }

    function setText(bytes32 nodeID, string calldata key, string calldata value) public {

        uint256 rescueOrder = getRescueOrderFromNodeId(nodeID);
        setText(rescueOrder, key, value);
    }

    function setText(uint256 rescueOrder, string calldata key, string calldata value) public onlyMoonCatOwner(rescueOrder) {

        bytes memory keyBytes = bytes(key);
        bytes32 orderHash = getSubdomainNameHash(uint2str(rescueOrder));
        bytes32 hexHash = getSubdomainNameHash(bytes5ToHexString(MCR.rescueOrder(rescueOrder)));

        if (bytes(value).length == 0 && keyBytes.length == avatarKeyLength && keccak256(keyBytes) == avatarKeyHash){
            string memory avatarRecordValue = string(abi.encodePacked(avatarBaseURI,  uint2str(rescueOrder)));
            emit TextChanged(orderHash, key, avatarRecordValue);
            emit TextChanged(hexHash, key, avatarRecordValue);
        } else {
            emit TextChanged(orderHash, key, value);
            emit TextChanged(hexHash, key, value);
        }
        TextKeyMapping[rescueOrder][key] = value;
    }

    function contenthash(bytes32 nodeID) public view returns (bytes memory) {

        uint256 rescueOrder = getRescueOrderFromNodeId(nodeID);
        return ContentsMapping[rescueOrder];
    }

    function setContenthash(bytes32 nodeID, bytes calldata hash) public {

        uint256 rescueOrder = getRescueOrderFromNodeId(nodeID);
        setContenthash(rescueOrder, hash);
    }

    function setContenthash(uint256 rescueOrder, bytes calldata hash) public onlyMoonCatOwner(rescueOrder) {

        emit ContenthashChanged(getSubdomainNameHash(uint2str(rescueOrder)), hash);
        emit ContenthashChanged(getSubdomainNameHash(bytes5ToHexString(MCR.rescueOrder(rescueOrder))), hash);
        ContentsMapping[rescueOrder] = hash;
    }

    function setTTL(uint rescueOrder, uint64 newTTL) public onlyMoonCatOwner(rescueOrder) {

        IRegistry registry = IRegistry(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        registry.setTTL(getSubdomainNameHash(uint2str(rescueOrder)), newTTL);
        registry.setTTL(getSubdomainNameHash(bytes5ToHexString(MCR.rescueOrder(rescueOrder))), newTTL);
    }

    function multicall(bytes[] calldata data) external returns(bytes[] memory results) {

        results = new bytes[](data.length);
        for (uint i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success);
            results[i] = result;
        }
        return results;
    }

    function getRescueOrderFromNodeId(bytes32 nodeID) public view returns (uint256) {

        uint256 rescueOrder = NamehashMapping[nodeID];
        if (rescueOrder == 0) {
            require(
                nodeID == 0x8bde039a2a7841d31e0561fad9d5cfdfd4394902507c72856cf5950eaf9e7d5a // 0.ismymooncat.eth
                || nodeID == 0x1002474938c26fb23080c33c3db026c584b30ec6e7d3edf4717f3e01e627da26, // 0x00d658d50b.ismymooncat.eth
                "Unknown Node ID"
            );
        }
        return rescueOrder;
    }

    function getSubdomainNameHash(string memory subdomain) public view returns (bytes32) {

        return keccak256(abi.encodePacked(rootHash, keccak256(abi.encodePacked(subdomain))));
    }

    function mapMoonCat(uint256 rescueOrder) public {

        string memory orderSubdomain = uint2str(rescueOrder);
        string memory hexSubdomain = bytes5ToHexString(MCR.rescueOrder(rescueOrder));

        bytes32 orderHash = getSubdomainNameHash(orderSubdomain);
        bytes32 hexHash = getSubdomainNameHash(hexSubdomain);

        if (uint256(NamehashMapping[orderHash]) != 0) {
            return;
        }

        NamehashMapping[orderHash] = rescueOrder;
        NamehashMapping[hexHash] = rescueOrder;

        if(MCR.catOwners(MCR.rescueOrder(rescueOrder)) != address(MCA)) {
            return;
        }

        IRegistry registry = IRegistry(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        registry.setSubnodeRecord(rootHash, keccak256(bytes(orderSubdomain)), address(this), address(this), defaultTTL);
        registry.setSubnodeRecord(rootHash, keccak256(bytes(hexSubdomain)), address(this), address(this), defaultTTL);

        address moonCatOwner = MCA.ownerOf(rescueOrder);
        lastAnnouncedAddress[rescueOrder] = moonCatOwner;
        emit AddrChanged(orderHash, moonCatOwner);
        emit AddrChanged(hexHash, moonCatOwner);
        emit AddressChanged(orderHash, 60, abi.encodePacked(moonCatOwner));
        emit AddressChanged(hexHash, 60, abi.encodePacked(moonCatOwner));

        string memory avatarRecordValue = string(abi.encodePacked(avatarBaseURI,  uint2str(rescueOrder)));
        emit TextChanged(orderHash, "avatar", avatarRecordValue);
        emit TextChanged(hexHash, "avatar", avatarRecordValue);
    }

    function announceMoonCat(uint256 rescueOrder) public {

        require(MCR.catOwners(MCR.rescueOrder(rescueOrder)) == address(MCA), "Not Acclimated");
        address moonCatOwner = MCA.ownerOf(rescueOrder);

        lastAnnouncedAddress[rescueOrder] = moonCatOwner;
        bytes32 orderHash = getSubdomainNameHash(uint2str(rescueOrder));
        bytes32 hexHash = getSubdomainNameHash(bytes5ToHexString(MCR.rescueOrder(rescueOrder)));

        emit AddrChanged(orderHash, moonCatOwner);
        emit AddrChanged(hexHash, moonCatOwner);
        emit AddressChanged(orderHash, 60, abi.encodePacked(moonCatOwner));
        emit AddressChanged(hexHash, 60, abi.encodePacked(moonCatOwner));
    }

    function needsAnnouncing(uint256 rescueOrder) public view returns (bool) {

        require(MCR.catOwners(MCR.rescueOrder(rescueOrder)) == address(MCA), "Not Acclimated");
        return lastAnnouncedAddress[rescueOrder] != MCA.ownerOf(rescueOrder);
    }

    function needsAnnouncing(address moonCatOwner) public view returns (uint256[] memory) {

        uint256 balance = MCA.balanceOf(moonCatOwner);
        uint256 announceCount = 0;
        uint256[] memory tempRescueOrders = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            uint256 rescueOrder = MCA.tokenOfOwnerByIndex(moonCatOwner, i);
            if (lastAnnouncedAddress[rescueOrder] != moonCatOwner){
                tempRescueOrders[announceCount] = rescueOrder;
                announceCount++;
            }
        }
        uint256[] memory rescueOrders = new uint256[](announceCount);
        for (uint256 i = 0; i < announceCount; i++){
            rescueOrders[i] = tempRescueOrders[i];
        }
        return rescueOrders;
    }

    function needsAnnouncing() public view returns (uint256[] memory) {

        return needsAnnouncing(msg.sender);
    }

    function mapMoonCats(uint256[] memory rescueOrders) public {

        for (uint256 i = 0; i < rescueOrders.length; i++) {
            address lastAnnounced = lastAnnouncedAddress[rescueOrders[i]];
            if (lastAnnounced == address(0)){
                mapMoonCat(rescueOrders[i]);
            } else if (lastAnnounced != MCA.ownerOf(rescueOrders[i])){
                announceMoonCat(rescueOrders[i]);
            }
        }
    }

    function mapMoonCats(address moonCatOwner) public {

        for (uint256 i = 0; i < MCA.balanceOf(moonCatOwner); i++) {
            uint256 rescueOrder = MCA.tokenOfOwnerByIndex(moonCatOwner, i);
            address lastAnnounced = lastAnnouncedAddress[rescueOrder];
            if (lastAnnounced == address(0)){
                mapMoonCat(rescueOrder);
            } else if (lastAnnounced != moonCatOwner){
                announceMoonCat(rescueOrder);
            }
        }
    }

    function mapMoonCats() public {

        mapMoonCats(msg.sender);
    }

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    function bytes5ToHexString(bytes5 x) internal pure returns (string memory) {

        uint256 length = 5;
        uint256 value = uint256(uint40(x));

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }

    function uint2str(uint value) internal pure returns (string memory) {

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

}