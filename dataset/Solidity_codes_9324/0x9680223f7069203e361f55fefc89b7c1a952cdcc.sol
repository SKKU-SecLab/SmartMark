
pragma solidity ^0.5.10;


contract IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract IERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);


    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function transferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4);

}


contract ERC165 is IERC165 {

    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_InterfaceId_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}


contract IERC721Metadata {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}


contract IERC721Enumerable {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}


contract ERC20Token {

    function balanceOf(address owner) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);

}


contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
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


library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


contract Inventory is ERC165, IERC721, IERC721Metadata, IERC721Enumerable, Ownable {

    using SafeMath for uint256;
    using Address for address;
    
    string private _name;
    string private _symbol;
    string private _pathStart;
    string private _pathEnd;
    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
    bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;
    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    ERC20Token public constant treasureChestRewardToken = ERC20Token(0x3D3D35bb9bEC23b06Ca00fe472b50E7A4c692C30);
    
    ERC20Token public constant UNI_ADDRESS = ERC20Token(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    
    uint256 private constant UNICORN_TEMPLATE_ID = 11;
	uint256 public UNICORN_TOTAL_SUPPLY = 0;
	mapping (address => bool) public unicornClaimed;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => uint256) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;
    
    mapping (address => bool) private _approvedGameContract;

    mapping (uint256 => uint256) public treasureChestRewards;

    mapping (address => uint256) public treasureHuntPoints;
    
    mapping (address => uint256[6]) public characterEquipment;
    
    mapping (uint256 => bool) _templateExists; 

    struct Item {
        uint256 templateId; // id of Template in the itemTemplates array
        uint8 feature1;
        uint8 feature2;
        uint8 feature3;
        uint8 feature4;
        uint8 equipmentPosition;
        bool burned;
    }
    
    struct Template {
        string uri;
    }
    
    Item[] public allItems;
    
    Template[] public itemTemplates;
    
    modifier onlyApprovedGame() {

        require(_approvedGameContract[msg.sender], "msg.sender is not an approved game contract");
        _;
    }
    
    modifier tokenExists(uint256 _tokenId) {

        require(_exists(_tokenId), "Token does not exist");
        _;
    }
    
    modifier isOwnedByOrigin(uint256 _tokenId) {

        require(ownerOf(_tokenId) == tx.origin, "tx.origin is not the token owner");
        _;
    }
    
    modifier isOwnerOrApprovedGame(uint256 _tokenId) {

        require(ownerOf(_tokenId) == msg.sender || _approvedGameContract[msg.sender], "Not owner or approved game");
        _;
    }
    
    modifier templateExists(uint256 _templateId) {

        require(_templateExists[_templateId], "Template does not exist");
        _;
    }

    constructor() 
        public  
    {
        _name = "Inventory";
        _symbol = "ITEM";
        _pathStart = "https://team3d.io/inventory/json/";
        _pathEnd = ".json";
        _registerInterface(InterfaceId_ERC721Metadata);
        _registerInterface(_InterfaceId_ERC721Enumerable);
        _registerInterface(_InterfaceId_ERC721);
        
        addNewItem(0,0);
    }
    
    function mintUnicorn()
        external
    {

        uint256 id;
        
        require(UNICORN_TOTAL_SUPPLY < 100, "Unicorns are now extinct");
		require(!unicornClaimed[msg.sender], "You have already claimed a unicorn");
        require(UNI_ADDRESS.balanceOf(msg.sender) >= 1000 * 10**18, "Min balance 1000 UNI");
        require(_templateExists[UNICORN_TEMPLATE_ID], "Unicorn template has not been added yet");
        checkAndTransferVIDYA(1000 * 10**18); // Unicorn's head costs 1000 VIDYA 
        
        id = allItems.push(Item(UNICORN_TEMPLATE_ID,0,0,0,0,0,false)) -1;
		
		UNICORN_TOTAL_SUPPLY = UNICORN_TOTAL_SUPPLY.add(1);
		unicornClaimed[msg.sender] = true;
        
        _mint(msg.sender, id);
    }
    
    function checkAndTransferVIDYA(uint256 _amount) private {

        require(treasureChestRewardToken.transferFrom(msg.sender, address(this), _amount) == true, "transfer must succeed");
    }
    
    function equip(
        uint256 _tokenId, 
        uint8 _equipmentPosition
    ) 
        external
        tokenExists(_tokenId)
    {

        require(_equipmentPosition < 6);
        require(allItems[_tokenId].equipmentPosition == _equipmentPosition, 
            "Item cannot be equipped in this slot");
            
        characterEquipment[msg.sender][_equipmentPosition] = _tokenId;
    }

    function unequip(
        uint8 _equipmentPosition
    ) 
        external
    {

        require(_equipmentPosition < 6);
        characterEquipment[msg.sender][_equipmentPosition] = 0;
    }

    function getEquipment(
        address player
    ) 
        public 
        view 
        returns(uint256[6] memory)
    {

        return characterEquipment[player];
    }

    function getIndividualCount(
        uint256 _templateId
    ) 
        public 
        view 
        returns(uint256) 
    {

        uint counter = 0;
        
        for (uint i = 0; i < allItems.length; i++) {
            if (allItems[i].templateId == _templateId && !allItems[i].burned) {
                counter++;
            }
        }
        
        return counter;
    }
    
    function getIndividualOwnedCount(
        uint256 _templateId,
        address _owner
    )
        public 
        view 
        returns(uint256)
    {

        uint counter = 0;
        uint[] memory ownedItems = getItemsByOwner(_owner);
        
        for(uint i = 0; i < ownedItems.length; i++) {
            
            if(allItems[ownedItems[i]].templateId == _templateId) {
                counter++;
            }
        }
        
        return counter;
    }
    
    function getIndividualCountByID(
        uint256 _tokenId
    )
        public
        view
        tokenExists(_tokenId)
        returns(uint256)
    {

        uint256 counter = 0;
        uint256 templateId = allItems[_tokenId].templateId; // templateId we are looking for 
        
        for(uint i = 0; i < allItems.length; i++) {
            if(templateId == allItems[i].templateId && !allItems[i].burned) {
                counter++;
            }
        }
        
        return counter;
    }
    
    function getIndividualOwnedCountByID(
        uint256 _tokenId,
        address _owner 
    )
        public
        view
        tokenExists(_tokenId)
        returns(uint256)
    {

        uint256 counter = 0;
        uint256 templateId = allItems[_tokenId].templateId; // templateId we are looking for 
        uint[] memory ownedItems = getItemsByOwner(_owner);
        
        for(uint i = 0; i < ownedItems.length; i++) {
            if(templateId == allItems[ownedItems[i]].templateId) {
                counter++;
            }
        }
        
        return counter;
    }
    
    function getTemplateCountsByTokenIDs(
        uint[] memory _tokenIds
    )
        public
        view
        returns(uint[] memory)
    {

        uint[] memory counts = new uint[](_tokenIds.length);
        
        for(uint i = 0; i < _tokenIds.length; i++) {
            counts[i] = getIndividualCountByID(_tokenIds[i]);
        }
        
        return counts;
    }
    
    function getTemplateCountsByTokenIDsOfOwner(
        uint[] memory _tokenIds,
        address _owner 
    )
        public
        view
        returns(uint[] memory)
    {

        uint[] memory counts = new uint[](_tokenIds.length);
        
        for(uint i = 0; i < _tokenIds.length; i++) {
            counts[i] = getIndividualOwnedCountByID(_tokenIds[i], _owner);
        }
        
        return counts;
    }
    
    function getTemplateIDsByTokenIDs(
        uint[] memory _tokenIds
    )
        public
        view
        returns(uint[] memory)
    {

        uint[] memory templateIds = new uint[](_tokenIds.length);
        
        for(uint i = 0; i < _tokenIds.length; i++) {
            templateIds[i] = allItems[_tokenIds[i]].templateId;
        }
        
        return templateIds;
    }

    function getItemsByOwner(
        address _owner
    ) 
        public 
        view 
        returns(uint[] memory) 
    {

        uint[] memory result = new uint[](_ownedTokensCount[_owner]);
        uint counter = 0;
        
        for (uint i = 0; i < allItems.length; i++) {
            if (_tokenOwner[i] == _owner && !allItems[i].burned) {
                result[counter] = i;
                counter++;
            }
        }
        
        return result;
    }

    function withdrawERC20Tokens(
        address _tokenContract
    ) 
        external 
        onlyOwner 
        returns(bool) 
    {

        ERC20Token token = ERC20Token(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(msg.sender, amount);
    }
    
    function approveGameContract(
        address _game,
        bool _status
    )
        external 
        onlyOwner
    {

        _approvedGameContract[_game] = _status;
    }
    
    function setPaths(
        string calldata newPathStart,
        string calldata newPathEnd
    )
        external
        onlyOwner
        returns(bool)
    {

        bool success;
        
        if(keccak256(abi.encodePacked(_pathStart)) != keccak256(abi.encodePacked(newPathStart))) {
            _pathStart = newPathStart;
            success = true;
        }
        
        if(keccak256(abi.encodePacked(_pathEnd)) != keccak256(abi.encodePacked(newPathEnd))) {
            _pathEnd = newPathEnd;
            success = true;
        }
        
        return success;
    }

    function addNewItem(
        uint256 _templateId,
        uint8 _equipmentPosition
    )
        public 
        onlyOwner
    {

        uint256 id;
        
        if(!_templateExists[_templateId]) {
            itemTemplates.push(Template(uint2str(_templateId)));
            _templateExists[_templateId] = true;
        }
        
        id = allItems.push(Item(_templateId,0,0,0,0,_equipmentPosition,false)) -1;
        
        _mint(msg.sender, id);
    }
    
    function addNewItemAndTransfer(
        uint256 _templateId,
        uint8 _equipmentPosition,
        address receiver 
    )
        public 
        onlyOwner
    {

        uint256 id;
        
        if(!_templateExists[_templateId]) {
            itemTemplates.push(Template(uint2str(_templateId)));
            _templateExists[_templateId] = true;
        }
        
        id = allItems.push(Item(_templateId,0,0,0,0,_equipmentPosition,false)) -1;
        
        _mint(receiver, id);
    }
    
    function createFromTemplate(
        uint256 _templateId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition
    )
        public
        templateExists(_templateId)
        onlyApprovedGame
        returns(uint256)
    {

        uint256 id; 
        address player = tx.origin;
        
        id = allItems.push(
            Item(
                _templateId,
                _feature1,
                _feature2,
                _feature3,
                _feature4,
                _equipmentPosition,
                false
            )
        ) -1;
        
        _mint(player, id);
        
        return id;
    }

    function changeFeaturesForItem(
        uint256 _tokenId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition
    )
        public 
        onlyApprovedGame // msg.sender has to be a manually approved game address 
        tokenExists(_tokenId) // check if _tokenId exists in the first place 
        isOwnedByOrigin(_tokenId) // does the tx.origin (player in a game) own the token?
        returns(bool)
    {

        return (
            _changeFeaturesForItem(
                _tokenId,
                _feature1,
                _feature2,
                _feature3,
                _feature4,
                _equipmentPosition
            )
        );
    }

    function _changeFeaturesForItem(
        uint256 _tokenId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition
    )
        internal
        returns(bool)
    {

        Item storage item = allItems[_tokenId];

        if(item.feature1 != _feature1) {
            item.feature1 = _feature1;
        }
        
        if(item.feature2 != _feature2) {
            item.feature2 = _feature2;
        }
        
        if(item.feature3 != _feature3) {
            item.feature3 = _feature3;
        }
        
        if(item.feature4 != _feature4) {
            item.feature4 = _feature4;
        }
        
        if(item.equipmentPosition != _equipmentPosition) {
            item.equipmentPosition = _equipmentPosition;
        }
        
        return true;
    }
    
    function getFeaturesOfItem(
        uint256 _tokenId 
    )
        public 
        view 
        returns(uint8[] memory)
    {

        Item storage item = allItems[_tokenId];
        uint8[] memory features = new uint8[](4);
        
        features[0] = item.feature1;
        features[1] = item.feature2;
        features[2] = item.feature3;
        features[3] = item.feature4;
        
        return features;
    }

    function uint2str(
        uint256 i
    ) 
        internal 
        pure 
        returns(string memory) 
    {

        if (i == 0) return "0";
        
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10)); 
            i /= 10;
        }
        return string(bstr);
    }
    
    function append(
        string memory a, 
        string memory b, 
        string memory c
    ) 
        internal 
        pure 
        returns(string memory) 
    {

        return string(
            abi.encodePacked(a, b, c)
        );
    }
    
    function addTreasureChest(uint256 _tokenId, uint256 _rewardsAmount) 
    external
    tokenExists(_tokenId)
    onlyApprovedGame 
    {

        treasureChestRewards[_tokenId] = _rewardsAmount;
    }

    function burn(
        uint256 _tokenId
    )
        public
        tokenExists(_tokenId)
        isOwnerOrApprovedGame(_tokenId)
        returns(bool)
    {

        if (tx.origin == msg.sender) {
            return _burn(_tokenId, msg.sender);
        } else {
            return _burn(_tokenId, tx.origin);
        }
    }
    
    function _burn(
        uint256 _tokenId,
        address owner
    )
        internal
        returns(bool)
    {

        allItems[_tokenId].burned = true;
        
        _tokenOwner[_tokenId] = address(0);
        
        _ownedTokensCount[owner] = _ownedTokensCount[owner].sub(1);

        uint256 treasureChestRewardsForToken = treasureChestRewards[_tokenId];
        if (treasureChestRewardsForToken > 0) {
            treasureChestRewardToken.transfer(msg.sender, treasureChestRewardsForToken);
            treasureHuntPoints[owner]++;
        }

        emit Transfer(owner, address(0), _tokenId);
        
        return true;
    }

    function getLevel(address player) public view returns(uint256) {

        return treasureHuntPoints[player];
    }

    function totalSupply() 
        public 
        view 
        returns(uint256)
    {

        uint256 counter;
        for(uint i = 0; i < allItems.length; i++) {
            if(!allItems[i].burned) {
                counter++;
            }
        }
        
        return counter;
    }
    
    function tokenByIndex(
        uint256 _index
    ) 
        public 
        view 
        returns(uint256) 
    {

        require(_index < totalSupply());
        return allItems[_index].templateId;
    }
    
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) 
        public 
        view 
        returns 
        (uint256 tokenId) 
    {

        require(index < balanceOf(owner));
        return getItemsByOwner(owner)[index];
    }

    function name() 
        external 
        view 
        returns(string memory) 
    {

        return _name;
    }

    function symbol() 
        external 
        view 
        returns(string memory) 
    {

        return _symbol;
    }

    function tokenURI(
        uint256 tokenId
    ) 
        external 
        view 
        returns(string memory) 
    {

        require(_exists(tokenId));
        uint256 tokenTemplateId = allItems[tokenId].templateId;
        
        string memory id = uint2str(tokenTemplateId);
        return append(_pathStart, id, _pathEnd);
    }

    function balanceOf(
        address owner
    ) 
        public 
        view 
        returns(uint256) 
    {

        require(owner != address(0));
        return _ownedTokensCount[owner];
    }

    function ownerOf(
        uint256 tokenId
    ) 
        public 
        view 
        returns(address) 
    {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        require(!allItems[tokenId].burned, "This token is burned"); // Probably useless require at this point 
        
        return owner;
    }

    function approve(
        address to, 
        uint256 tokenId
    ) 
        public 
    {

        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(
        uint256 tokenId
    ) 
        public 
        view 
        returns(address)
    {

        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(
        address to, 
        bool approved
    ) 
        public 
    {

        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(
        address owner, 
        address operator
    ) 
        public 
        view 
        returns(bool) 
    {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) 
        public 
    {

        require(_isApprovedOrOwner(msg.sender, tokenId));
        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId
    )
        public 
    {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory _data
    ) 
        public 
    {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    function _exists(
        uint256 tokenId
    ) 
        internal 
        view 
        returns(bool) 
    {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(
        address spender, 
        uint256 tokenId
    ) 
        internal 
        view 
        returns(bool) 
    {

        address owner = ownerOf(tokenId);
        return (
            spender == owner || 
            getApproved(tokenId) == spender || 
            isApprovedForAll(owner, spender)
        );
    }

    function _mint(
        address to, 
        uint256 tokenId
    ) internal {

        require(to != address(0));
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        emit Transfer(address(0), to, tokenId);
    }

    function _transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) 
        internal 
    {

        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory _data
    ) 
        internal 
        returns(bool) 
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(
            msg.sender, 
            from, 
            tokenId, 
            _data
        );
        
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(
        uint256 tokenId
    ) 
        private 
    {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}