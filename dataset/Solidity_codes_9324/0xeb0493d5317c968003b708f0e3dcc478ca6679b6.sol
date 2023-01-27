
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// AGPL-3.0

pragma solidity ^0.8.12;


interface IReverseResolver {

    function claim(address owner) external returns (bytes32);

}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

}

interface IQuest3Data {

    function getDeath (uint256 seed, uint256 prevLevel, bytes[8] memory stats) external view returns (bytes memory death, string memory ending);
    function getFail (uint256 seed, uint256 level, bytes[8] memory stats) external view returns (bytes memory happening);
    function getAdvance (uint256 seed, uint256 level, bytes[8] memory stats) external view returns (bytes memory happening, bytes memory stat);
    function getMetadata (uint256 tokenId, uint256 level, uint8 journeyLength, bytes[15] memory storySegments, bytes[8] memory stats, uint16 heroStatus) external pure returns (string memory);
    function generateCompletionImage (uint tokenId, uint level, bytes memory lastWords, uint heroStatus) external pure returns (bytes memory);
    function generateProgressImage (uint tokenId, uint level) external pure returns (bytes memory);
}

contract Quest3 is IERC721Enumerable, IERC721Metadata {


    string public name = "Quest-3";
    string public symbol = unicode"⛰";

    uint256 public maxSupply = 25600;
    uint256 public totalSupply = 0;

    address public contractOwner;

    address[25600] internal Owners; // Maps tokenIds to owning addresses.
    mapping (address => uint256[]) internal TokensByOwner; // Mapping from address to owned tokens.
    uint16[25600] internal OwnerTokenIndex; // Maps the a tokenId to its index in the `TokensByOwner[address]` array.


    mapping(uint256 => address) internal TokenApprovals; // Mapping from token ID to approved address.
    mapping(address => mapping(address => bool)) internal OperatorApprovals; // Mapping from owner to operator approvals.

    bool paused = true; // Pausing stops all user interactions.
    bool frozen = false; // Freezing stops minting and actions.

    uint256 public MintPriceWei = 0.01994206980085 ether;

    mapping (uint256 => uint16[16]) TokenHistory;

    uint256 public HeroThreshold = 10;
    uint16[25600] public HeroStatus;

    IQuest3Data Data;


    constructor (address quest3DataContract) {
        contractOwner = msg.sender;
        Data = IQuest3Data(quest3DataContract);
        IReverseResolver(0x084b1c3C81545d370f3634392De611CaaBFf8148).claim(msg.sender);
    }

    function transferOwnership (address newOwner) public onlyOwner {
        contractOwner = newOwner;
    }

    function pause () public onlyOwner {
        paused = true;
    }

    function unpause () public onlyOwner {
        paused = false;
    }

    function ownerWithdraw () public {
        payable(contractOwner).transfer(address(this).balance);
    }

    function clearPendingStatus (uint256 tokenId) public onlyOwner {
        TokenHistory[tokenId][IS_PENDING_INDEX] = 0;
    }

    function setHeroThreshold (uint256 threshold) public onlyOwner {
        HeroThreshold = threshold;
    }

    function permanentlyCloseMint() public onlyOwner {

        maxSupply = totalSupply;
    }

    function setFrozen (bool state) public onlyOwner {
        frozen = state;
    }


    modifier onlyOwner() {

        require(msg.sender == contractOwner, "Not Owner");
        _;
    }

    modifier whenNotPaused() {

        require(paused == false || msg.sender == contractOwner, "Paused");
        _;
    }


    Action[256] public ActionQueue;
    uint constant public MAX_QUEUE = 256;

    struct Action {
        uint128 revealBlock;
        uint128 tokenId;
    }

    struct QueueCursor {
        uint16 index;
        uint16 count;
    }

    QueueCursor public Cursor = QueueCursor(0,0);

    function getQueueLength () public view returns (uint256) {
        return Cursor.count;
    }

    function getQueue () public view returns (Action[] memory) {
        uint count = Cursor.count;
        uint index = Cursor.index;
        Action[] memory queue = new Action[](count);
        for (uint i = 0; i < queue.length; i++) {
            queue[i] = ActionQueue[index];
            index++;
            if(index == MAX_QUEUE) index = 0;
        }
        return queue;
    }


    uint256 constant JOURNEY_LENGTH_INDEX = 0;
    uint256 constant IS_PENDING_INDEX = 15;

    function updateTokenHistory (uint256 tokenId) internal {
        uint16[16] storage history = TokenHistory[tokenId];
        uint journeyLength = history[JOURNEY_LENGTH_INDEX];

        uint level = history[journeyLength] & 15;

        uint prevLevel = 0;

        if (journeyLength == 0) {
            level = 1; // starting level
        } else if (journeyLength == 1) {
            prevLevel = 1; // starting level is always 1
        } else {
            prevLevel = history[journeyLength - 1] & 15; // prevLevel is penultimate level in pendingHistory
        }

        uint nextSeed = uint256(keccak256(abi.encodePacked(tokenId, blockhash(block.number-1))));

        uint resolution = nextSeed & 255;
        uint deathThreshold = 5 + level * 9;
        uint failThreshold = 90 + level * 22;
        if (level == 1) { deathThreshold = 2; } // low chance to die on level 1
        if (prevLevel == level) { failThreshold = 0; } // must die or advance
        if (resolution < deathThreshold) {
            level = 0; // died
        } else if (resolution >= failThreshold) {
            level = level + 1; // advanced
        }

        history[JOURNEY_LENGTH_INDEX] = uint16(journeyLength + 1);
        history[journeyLength + 1] = uint16((nextSeed << 4) + level);
        history[IS_PENDING_INDEX] = 0;
    }

    function handleAction (uint256 tokenId, uint256 maxReveals) private whenNotPaused {
        require(frozen == false, "Frozen");
        uint count = Cursor.count;
        uint index = Cursor.index;
        if (maxReveals < 3) {
            maxReveals = 3;
        }
        uint revealCount = 0;
        for (uint i = 0; i < maxReveals; i++) {
            if (count == 0) break;
            Action storage action = ActionQueue[index];
            if (block.number <= action.revealBlock) break;
            updateTokenHistory(action.tokenId);
            delete ActionQueue[index];
            count--;
            index++;
            revealCount++;
            if(index == MAX_QUEUE) index = 0;
        }
        if (revealCount >= HeroThreshold) {
            HeroStatus[tokenId] += uint16(revealCount);
        }

        uint16[16] storage history = TokenHistory[tokenId];

        uint tokenJourneyLength = history[JOURNEY_LENGTH_INDEX];
        uint tokenLevel = history[tokenJourneyLength] & 15;

        if (((tokenLevel > 0 && tokenLevel < 8) || tokenJourneyLength == 0)
            && count < MAX_QUEUE
            && history[IS_PENDING_INDEX] == 0)
        {
            uint tokenQueueIndex = count + index;
            count++;
            if (MAX_QUEUE <= tokenQueueIndex) {
                tokenQueueIndex -= MAX_QUEUE;
            }
            ActionQueue[tokenQueueIndex] = Action(uint128(block.number + 1), uint128(tokenId));
            history[IS_PENDING_INDEX] = 1;
        }
        Cursor.count = uint16(count);
        Cursor.index = uint16(index);
    }

    function doSomethingHeroic (uint256 tokenId, uint256 maxAssists) public {
        require(msg.sender == Owners[tokenId] && msg.sender == tx.origin, "Not Owner");
        require(maxAssists >= HeroThreshold, "A true hero must assist many others");
        handleAction(tokenId, maxAssists);
    }

    function doSomething (uint256 tokenId) public {
        require(msg.sender == Owners[tokenId] && msg.sender == tx.origin, "Not Owner");
        handleAction(tokenId, 3);
    }

    function doSomething (uint256[] memory tokenIds) public {
        require(msg.sender == tx.origin);
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(msg.sender == Owners[tokenId], "Not Owner");
            handleAction(tokenId, 3);
        }
    }


    function mintHelper (address recipient) private  {
        uint256 tokenId = totalSupply;
        TokensByOwner[recipient].push(tokenId);
        OwnerTokenIndex[tokenId] = uint16(TokensByOwner[recipient].length);
        Owners[tokenId] = recipient;
        totalSupply++;
        handleAction(tokenId, 3);
        emit Transfer(address(0), recipient, tokenId);
    }

    function mint (address recipient, uint256 quantity) public payable whenNotPaused {
        require (quantity <= 10, "Quantity Limit Exceeded");
        require (totalSupply + quantity <= maxSupply, "Max Supply Exceeded");
        uint256 cost = quantity * MintPriceWei;
        require(msg.value >= cost, "Insufficent Funds");
        for (uint i = 0; i < quantity; i++) {
            mintHelper(recipient);
        }
    }

    function mint (uint256 quantity) public payable {
        mint(msg.sender, quantity);
    }

    function mint (address[] memory recipients) public payable whenNotPaused {
        uint quantity = recipients.length;
        require (quantity <= 10 || msg.sender == contractOwner, "Quantity Limit Exceeded");
        require (totalSupply + quantity <= maxSupply, "Max Supply Exceeded");
        uint256 cost = quantity * MintPriceWei;
        require(msg.value >= cost, "Insufficent Funds");
        for (uint i = 0; i < quantity; i++) {
            mintHelper(recipients[i]);
        }
    }



    function isPending (uint256 tokenId) public view returns (bool pending, uint position, uint revealBlock) {
        pending = TokenHistory[tokenId][IS_PENDING_INDEX] == 1;
        if (pending) {
            uint count = Cursor.count;
            uint index = Cursor.index;
            for (uint i = 0; i < count; i++) {
                Action storage action = ActionQueue[index];
                if (action.tokenId == tokenId) {
                    position = i;
                    revealBlock = action.revealBlock;
                    break;
                }
                index++;
                if(index == MAX_QUEUE) index = 0;
            }
        }
    }

    function getDetails (uint256 tokenId) public view returns (uint256 level,
                                                               uint8 journeyLength,
                                                               bytes[15] memory storySegments,
                                                               bytes[8] memory stats,
                                                               uint16 heroStatus)
    {
        require(tokenId < totalSupply, "Doesn't Exist");
        uint16[16] storage tokenHistory = TokenHistory[tokenId];
        journeyLength = uint8(tokenHistory[JOURNEY_LENGTH_INDEX]);
        level = 1; // if quest has just begun, level will be 1
        uint prevLevel = 1;
        for (uint i = 1; i <= journeyLength; i++) {
            uint256 seed = uint256(keccak256(abi.encodePacked(tokenHistory[i], tokenId)));
            level = tokenHistory[i] & 15;
            if (level == 0) {
                (bytes memory storySegment, string memory ending) = Data.getDeath(seed, prevLevel, stats);
                stats[7] = storySegment;
                storySegments[i-1] = storySegment;
                storySegments[i] = bytes(ending);
            } else if (prevLevel == level) {
                storySegments[i-1] = Data.getFail(seed, level, stats);
            } else {
                (bytes memory storySegment, bytes memory stat) = Data.getAdvance(seed, level, stats);
                stats[level - 1] = stat;
                storySegments[i-1] = storySegment;
            }
            prevLevel = level;
        }

        heroStatus = HeroStatus[tokenId];

        if (tokenHistory[IS_PENDING_INDEX] == 1) {
            stats[0] = "Pending";
        } else if (level == 0) {
            stats[0] = "NGMI";
        } else if (level == 8) {
            stats[0] = "GMI";
        } else {
            stats[0] = "Questing";
        }
    }

    function getLevel (uint256 tokenId) public view returns (uint256 level) {
        require(tokenId < totalSupply, "Doesn't Exist");
        uint16[16] storage tokenHistory = TokenHistory[tokenId];
        uint16 journeyLength = tokenHistory[JOURNEY_LENGTH_INDEX];
        if (journeyLength == 0) {
            return 1;
        } else {
            return (tokenHistory[journeyLength] & 15);
        }
    }

    function getSym(int seed) internal pure returns (uint8) {

        if (seed & 1 == 0) return 0;
        if ((seed >> 1) & 1 == 0) {
            return 1;
        }
        return 2;
    }

    function getMysteriousCartouche (uint256 tokenId) public view returns (uint8 level, uint8[6] memory cartouche) {
        (uint256 currentLevel,uint8 journeyLength,, bytes[8] memory stats,) = getDetails(tokenId);
        if (currentLevel == 8) {
            int seed = int(uint256(keccak256(abi.encodePacked(tokenId, stats[7]))) >> 141);
            cartouche[0] = getSym(seed);
            cartouche[1] = getSym(seed >> 2);
            cartouche[2] = getSym(seed >> 4);
            cartouche[3] = getSym(seed >> 6);
            cartouche[4] = getSym(seed >> 8);
            cartouche[5] = getSym(seed >> 10);
        }
        if (journeyLength > 0) {
            level = uint8(currentLevel);
        } else {
            level = 1;
        }
    }


    function tokenURI (uint256 tokenId) public view returns (string memory) {
        (uint256 level, uint8 journeyLength, bytes[15] memory storySegments, bytes[8] memory stats, uint16 heroStatus) = getDetails(tokenId);
        return Data.getMetadata(tokenId, level, journeyLength, storySegments, stats, heroStatus);
    }

    function tokenSVG (uint256 tokenId) public view returns (string memory svg) {
        (uint256 level, uint8 journeyLength,, bytes[8] memory stats, uint16 heroStatus) = getDetails(tokenId);
        if (journeyLength > 0 && (level == 0 || level == 8)) {
            svg = string(Data.generateCompletionImage(tokenId, level, stats[7], heroStatus));
        } else {
            svg = string(Data.generateProgressImage(tokenId, level));
        }
    }


    function tokenExists(uint256 tokenId) public view returns (bool) {

        return (tokenId < totalSupply);
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        require(tokenExists(tokenId), "ERC721: Nonexistent token");
        return Owners[tokenId];
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return TokensByOwner[owner].length;
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {

        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId;
    }

    function _approve(address to, uint256 tokenId) internal {

        TokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function approve(address to, uint256 tokenId) public  {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
                msg.sender == owner || isApprovedForAll(owner, msg.sender),
                "ERC721: approve caller is not owner nor approved for all"
                );
        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(tokenId < totalSupply, "ERC721: approved query for nonexistent token");
        return TokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view  returns (bool) {

        return OperatorApprovals[owner][operator];
    }

    function setApprovalForAll(
                               address operator,
                               bool approved
                               ) external virtual {

        require(msg.sender != operator, "ERC721: approve to caller");
        OperatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
        size := extcodesize(account)
                }
        return size > 0;
    }

    function _checkOnERC721Received(
                                    address from,
                                    address to,
                                    uint256 tokenId,
                                    bytes memory _data
                                    ) private returns (bool) {

        if (isContract(to)) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                            }
                }
            }
        } else {
            return true;
        }
    }

    function _transfer(
                       address from,
                       address to,
                       uint256 tokenId
                       ) private whenNotPaused {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        _approve(address(0), tokenId);

        uint16 valueIndex = OwnerTokenIndex[tokenId];
        uint256 toDeleteIndex = valueIndex - 1;
        uint256 lastIndex = TokensByOwner[from].length - 1;
        if (lastIndex != toDeleteIndex) {
            uint256 lastTokenId = TokensByOwner[from][lastIndex];
            TokensByOwner[from][toDeleteIndex] = lastTokenId;
            OwnerTokenIndex[lastTokenId] = valueIndex;
        }
        TokensByOwner[from].pop();

        TokensByOwner[to].push(tokenId);
        OwnerTokenIndex[tokenId] = uint16(TokensByOwner[to].length);

        Owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(tokenId < totalSupply, "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function transferFrom(
                          address from,
                          address to,
                          uint256 tokenId
                          ) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
                              address from,
                              address to,
                              uint256 tokenId
                              ) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
                              address from,
                              address to,
                              uint256 tokenId,
                              bytes memory _data
                              ) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }


    function _safeTransfer(
                           address from,
                           address to,
                           uint256 tokenId,
                           bytes memory _data
                           ) private {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }


    function tokenByIndex(uint256 tokenId) public view returns (uint256) {

        require(tokenExists(tokenId), "Nonexistent Token");
        return tokenId;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return TokensByOwner[owner][index];
    }


    function withdrawForeignERC20(address tokenContract) public onlyOwner {

        IERC20 token = IERC20(tokenContract);
        token.transfer(contractOwner, token.balanceOf(address(this)));
        }

    function withdrawForeignERC721(address tokenContract, uint256 tokenId) public onlyOwner {

        IERC721(tokenContract).safeTransferFrom(address(this), contractOwner, tokenId);
    }
}