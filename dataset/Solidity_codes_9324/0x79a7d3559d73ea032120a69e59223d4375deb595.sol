
pragma solidity ^0.8.11;




contract TheNFT {

    string public constant PNG_SHA_256_HASH = "3ed52e4afc9030f69004f163017c3ffba0b837d90061437328af87330dee9575";
    string public constant PDF_SHA_256_HASH = "6c9ae041b9b9603da01d0aa4d912586c8d85b9fe1932c57f988d8bd0f9da3bc7";
    address private constant DEAD_ADDRESS = address(0x74eda0); // unwrapped NFTs go here
    address public curator;                                    // the curator receives restoration fees
    string private assetURL;
    string private baseURI;
    uint256 private immutable max;                             // total supply (1800)
    uint256 private constant fee = 4;                          // fee is the amount of DAO needed to restore

    IERC20 private immutable theDAO;                           // the contract of TheDAO, the greatest DAO of all time
    uint256 private constant oneDao = 1e16;                    // 1 DAO = 16^10 wei or 0.01 ETH

    mapping(address => uint256) private balances;              // counts of ownership
    mapping(uint256  => address) private ownership;
    mapping(uint256  => address) private approval;
    mapping(address => mapping(address => bool)) private approvalAll; // operator approvals

    event Mint(address owner, uint256 tokenId);
    event Burn(address owner, uint256 tokenId);
    event Restore(address owner, uint256 tokenId);
    event Curator(address curator);
    event BaseURI(string);

    constructor(address _theDAO, uint256 _max) {
        curator = msg.sender;
        theDAO = IERC20(_theDAO);
        balances[address(this)] = _max; // track how many haven't been minted
        max = _max;
    }

    modifier onlyCurator {

        require(
            msg.sender == curator,
            "only curator can call this"
        );
        _;
    }

    modifier regulated(address _to) {

        require(
            _to != DEAD_ADDRESS,
            "cannot send to dead address"
        );
        require(
            _to != address(this),
            "cannot send to self"
        );
        require(
            _to != address(0),
            "cannot send to 0x"
        );
        _;
    }

    function getStats(address _user) external view returns(uint256[] memory) {

        uint[] memory ret = new uint[](6);
        ret[0] = theDAO.balanceOf(_user);                // amount of TheDAO tokens owned by _user
        ret[1] = theDAO.allowance(_user, address(this)); // amount of DAO this contract is approved to spend
        ret[2] = balanceOf(address(this));               // how many NFTs to be minted
        ret[3] = balanceOf(DEAD_ADDRESS);                // how many NFTs are burned
        ret[4] = theDAO.balanceOf(address(this));        // amount of DAO held by this contract
        ret[5] = balanceOf(_user);                       // how many _user has
        return ret;
    }

    function mint(uint256 i) external {

        uint256 id = max - balances[address(this)];                    // id is the next assigned id
        require(id < max, "minting finished");
        require (i > 0 && i <= 100, "must be between 1 and 100");
        if (i + id > max) {                                            // if it goes over the max supply
            i = max -  id;                                             // cap it
        }
        if (theDAO.transferFrom(msg.sender, address(this), oneDao*i)) { // take the DAO fee
            while (i > 0) {
                _transfer(address(this), msg.sender, id);
                emit Mint(msg.sender, id);
                i--;
                id++;
            }
        }
    }

    function burn(uint256 id) external {

        require (msg.sender == ownership[id], "only owner can burn");
        if (theDAO.transfer(msg.sender, oneDao)) { // send theDAO token back to sender
            _transfer(msg.sender, DEAD_ADDRESS, id); // burn the NFT token
            emit Burn(msg.sender, id);
        }
    }

    function restore(uint256 id) external {

        require(DEAD_ADDRESS == ownership[id], "must be dead");
        require(theDAO.transferFrom(msg.sender, address(this), oneDao), "DAO deposit insufficient");
        require(theDAO.transferFrom(msg.sender, curator, oneDao*fee), "DAO fee insufficient"); // Fee goes to the curator
        _transfer(DEAD_ADDRESS, msg.sender, id); // send the NFT token to the new owner
        emit Restore(msg.sender, id);
    }
    function setCurator(address _curator) external onlyCurator {

        curator = _curator;
        emit Curator(_curator);
    }

    function setBaseURI(string memory _uri) external onlyCurator {

        baseURI = _uri;
        emit BaseURI(_uri);
    }


    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function totalSupply() external view returns (uint256) {

        return max;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {

        require (_index < max, "index out of range");
        return _index;
    }

    function tokenOfOwnerByIndex(address  _owner , uint256 _index) external view returns (uint256) {

        require (_index < max, "index out of range");
        require (_owner != address(0), "address invalid");
        require (ownership[_index] != address(0), "token not assigned");
        return _index;
    }

    function balanceOf(address _holder) public view returns (uint256) {

        require (_holder != address(0));
        return balances[_holder];
    }

    function name() public pure returns (string memory) {

        return "TheNFT Project";
    }

    function symbol() public pure returns (string memory) {

        return "TheNFT";
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {

        require (_tokenId < max, "index out of range");
        string memory _baseURI = baseURI;
        uint256 num = _tokenId % 100;
        return bytes(_baseURI).length > 0
        ? string(abi.encodePacked(_baseURI, toString(_tokenId/100), "/", toString(num), ".json"))
        : '';
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {

        require (_tokenId < max, "index out of range");
        address holder = ownership[_tokenId];
        require (holder != address(0), "not minted.");
        return holder;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) external regulated(_to) {

        require (_tokenId < max, "index out of range");
        address owner = ownership[_tokenId];
        require (owner == _from, "_from must be owner");
        require (_to != address(0), "_to most not be 0x");
        if (msg.sender == owner || (approvalAll[owner][msg.sender])) {
            _transfer(_from, _to, _tokenId);
        } else if (approval[_tokenId] == msg.sender) {
            approval[_tokenId] = address (0); // clear previous approval
            emit Approval(msg.sender, address (0), _tokenId);
            _transfer(_from, _to, _tokenId);
        } else {
            revert("not permitted");
        }
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external regulated(_to) {

        require (_tokenId < max, "index out of range");
        address owner = ownership[_tokenId];
        require (owner == _from, "_from must be owner");
        require (_to != address(0), "_to most not be 0x");
        if (msg.sender == owner || (approvalAll[owner][msg.sender])) {
            _transfer(_from, _to, _tokenId);
        } else if (approval[_tokenId] == msg.sender) {
            approval[_tokenId] = address (0); // clear previous approval
            emit Approval(msg.sender, address (0), _tokenId);
            _transfer(_from, _to, _tokenId);
        } else {
            revert("not permitted");
        }
        require(_checkOnERC721Received(_from, _to, _tokenId, ""), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external regulated(_to) {

        require (_tokenId < max, "index out of range");
        address owner = ownership[_tokenId];
        require (owner == _from, "_from must be owner");
        require (_to != address(0), "_to most not be 0x");
        if (msg.sender == owner || (approvalAll[owner][msg.sender])) {
            _transfer(_from, _to, _tokenId);
        } else if (approval[_tokenId] == msg.sender) {
            approval[_tokenId] = address (0); // clear previous approval
            emit Approval(msg.sender, address (0), _tokenId);
            _transfer(_from, _to, _tokenId);
        } else {
            revert("not permitted");
        }
    }

    function approve(address _to, uint256 _tokenId) external {

        require (_tokenId < max, "index out of range");
        address owner = ownership[_tokenId];
        require (owner == msg.sender || isApprovedForAll(owner, msg.sender), "action not token permitted");
        approval[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }
    function setApprovalForAll(address _operator, bool _approved) external {

        require(msg.sender != _operator, "ERC721: approve to caller");
        approvalAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {

        require (_tokenId < max, "index out of range");
        return approval[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

        return approvalAll[_owner][_operator];
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {

        return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        interfaceId == type(IERC165).interfaceId ||
        interfaceId == type(IERC721Enumerable).interfaceId ||
        interfaceId == type(IERC721TokenReceiver).interfaceId;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {

        balances[_to]++;
        balances[_from]--;
        ownership[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function onERC721Received(address /*_operator*/, address /*_from*/, uint256 /*_tokenId*/, bytes memory /*_data*/) external pure returns (bytes4) {

        revert("nope");
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
            return false; // not needed, but the ide complains that there's "no return statement"
        } else {
            return true;
        }
    }

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function toString(uint256 value) public pure returns (string memory) {


        uint8 count;
        if (value == 0) {
            return "0";
        }
        uint256 digits = 31;
        bytes memory buffer = new bytes(32);
        while (value != 0) {
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
            digits -= 1;
            count++;
        }
        uint256 temp;
        assembly {
            temp := mload(add(buffer, 32))
            temp := shl(mul(sub(32,count),8), temp)
            mstore(add(buffer, 32), temp)
            mstore(buffer, count)
        }
        return string(buffer);
    }
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


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

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

interface IERC721TokenReceiver {

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns (bytes4);

}

interface IERC721Enumerable {

    function totalSupply() external view returns (uint256);


    function tokenByIndex(uint256 _index) external view returns (uint256);


    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);

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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.11;



contract TheNFTV2 {

    ITheNFTv1 v1;                                              // points to v1 of TheNFT
    string public constant PNG_SHA_256_HASH = "3ed52e4afc9030f69004f163017c3ffba0b837d90061437328af87330dee9575";
    string public constant PDF_SHA_256_HASH = "6c9ae041b9b9603da01d0aa4d912586c8d85b9fe1932c57f988d8bd0f9da3bc7";
    address private constant DEAD_ADDRESS = address(0x74eda0); // unwrapped NFTs go here
    address public curator;                                    // the curator receives restoration fees
    string private assetURL;
    string private baseURI;
    uint256 private immutable max;                             // total supply (1800)
    uint256 private constant fee = 4;                          // fee is the amount of DAO needed to restore

    IERC20 private immutable theDAO;                           // the contract of TheDAO, the greatest DAO of all time
    uint256 private constant oneDao = 1e16;                    // 1 DAO = 16^10 wei or 0.01 ETH

    mapping(address => uint256) private balances;              // counts of ownership
    mapping(uint256  => address) private ownership;
    mapping(uint256  => address) private approval;
    mapping(address => mapping(address => bool)) private approvalAll; // operator approvals

    event Mint(address owner, uint256 tokenId);
    event Burn(address owner, uint256 tokenId);
    event Restore(address owner, uint256 tokenId);
    event Upgrade(address owner, uint256 tokenId);
    event OwnershipTransferred(address previousOwner, address newOwner);
    event BaseURI(string);
    constructor(
        address _theDAO,
        uint256 _max,
        address _v1
    ) {
        curator = msg.sender;
        theDAO = IERC20(_theDAO);
        v1 = ITheNFTv1(_v1);
        max = _max;
        balances[address(this)] = max;          // track how many haven't been upgraded
        theDAO.approve(_v1, type(uint256).max); // allow v1 to spend our DAO
    }

    modifier onlyCurator {

        require(
            msg.sender == curator,
            "only curator can call this"
        );
        _;
    }

    modifier regulated(address _to) {

        require(
            _to != DEAD_ADDRESS,
            "cannot send to dead address"
        );
        require(
            _to != address(this),
            "cannot send to self"
        );
        require(
            _to != address(0),
            "cannot send to 0x"
        );
        _;
    }

    function getStats(address _user) external view returns(uint256[] memory) {

        uint[] memory ret = new uint[](10);
        ret[0] = theDAO.balanceOf(_user);                  // amount of TheDAO tokens owned by _user
        ret[1] = theDAO.allowance(_user, address(this));   // amount of DAO this contract is approved to spend
        ret[2] = v1.balanceOf(address(v1));                // how many NFTs to be minted
        ret[3] = v1.balanceOf(DEAD_ADDRESS);               // how many NFTs are burned (v1)
        ret[4] = theDAO.balanceOf(address(this));          // amount of DAO held by this contract
        ret[5] = balanceOf(_user);                         // how many _user has
        ret[6] = theDAO.balanceOf(address(v1));            // amount of DAO held by v1
        ret[7] = balanceOf(address(this));                 // how many NFTs to be upgraded
        ret[8] = balanceOf(DEAD_ADDRESS);                  // how many v2 nfts burned
        if (v1.isApprovedForAll(_user, address(this))) {
            ret[9] = 1;                                    // approved for upgrade?
        }
        return ret;
    }

    function upgrade(uint256[] calldata _ids) external {

        for (uint256 i; i < _ids.length; i++) {
            require ((v1.ownerOf(_ids[i]) == msg.sender && ownership[_ids[i]] == address(0)), "not upgradable id");
            v1.transferFrom(msg.sender, address(this), _ids[i]); // transfer to here
            _upgrade(_ids[i]);                                   // burn * issue new nft
        }
    }

    function _upgrade(uint256 id) internal {

        v1.burn(id);                                    // take DAO token out
        _transfer(address(this), msg.sender, id);       // issue new nft
        emit Mint(msg.sender, id);
    }

    function mint(uint256 i) external {

        uint256 id = max - v1.balanceOf(address(v1));                    // id is the next assigned id
        require(id < max, "minting finished");
        require (i > 0 && i <= 100, "must be between 1 and 100");
        if (i + id > max) {                                            // if it goes over the max supply
            i = max -  id;                                             // cap it
        }
        require(
            theDAO.transferFrom(msg.sender, address(this), oneDao*i) == true,
            "DAO tokens required"
        );
        v1.mint(i);
        while (i > 0) {
            _upgrade(id);
            i--;
            id++;
        }
    }

    function burn(uint256 id) external {

        require (msg.sender == ownership[id], "only owner can burn");
        if (theDAO.transfer(msg.sender, oneDao)) {   // send theDAO token back to sender
            _transfer(msg.sender, DEAD_ADDRESS, id); // burn the NFT token
            emit Burn(msg.sender, id);
        }
    }

    function restore(uint256 id) external {

        require(DEAD_ADDRESS == ownership[id], "must be dead");
        require(theDAO.transferFrom(msg.sender, address(this), oneDao), "DAO deposit insufficient");
        require(theDAO.transferFrom(msg.sender, curator, oneDao*fee), "DAO fee insufficient"); // Fee goes to the curator
        _transfer(DEAD_ADDRESS, msg.sender, id); // send the NFT token to the new owner
        emit Restore(msg.sender, id);
    }
    function setCurator(address _curator) external onlyCurator {

        _transferOwnership(_curator);
    }

    function owner() external view returns (address) {

        return curator;
    }
    function renounceOwnership() external  {

        _transferOwnership(address(0));
    }

    function _transferOwnership(address newOwner) internal virtual {

        address oldOwner = curator;
        curator = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function setBaseURI(string memory _uri) external onlyCurator {

        baseURI = _uri;
        emit BaseURI(_uri);
    }


    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function totalSupply() external view returns (uint256) {

        return max;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {

        require (_index < max, "index out of range");
        return _index;
    }

    function tokenOfOwnerByIndex(address  _owner , uint256 _index) external view returns (uint256) {

        require (_index < max, "index out of range");
        require (_owner != address(0), "address invalid");
        require (ownership[_index] != address(0), "token not assigned");
        return _index;
    }

    function balanceOf(address _holder) public view returns (uint256) {

        require (_holder != address(0));
        return balances[_holder];
    }

    function name() public pure returns (string memory) {

        return "TheDAO SEC Report NFT";
    }

    function symbol() public pure returns (string memory) {

        return "TheNFTv2";
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {

        require (_tokenId < max, "index out of range");
        string memory _baseURI = baseURI;
        uint256 num = _tokenId % 100;
        return bytes(_baseURI).length > 0
        ? string(abi.encodePacked(_baseURI, toString(_tokenId/100), "/", toString(num), ".json"))
        : '';
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {

        require (_tokenId < max, "index out of range");
        address holder = ownership[_tokenId];
        require (holder != address(0), "not minted.");
        return holder;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) external regulated(_to) {

        require (_tokenId < max, "index out of range");
        address o = ownership[_tokenId];
        require (o == _from, "_from must be owner");
        address a = approval[_tokenId];
        require (o == msg.sender || (a == msg.sender) || (approvalAll[o][msg.sender]), "not permitted");
        _transfer(_from, _to, _tokenId);
        if (a != address(0)) {
            approval[_tokenId] = address(0); // clear previous approval
            emit Approval(msg.sender, address(0), _tokenId);
        }
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external regulated(_to) {

        require (_tokenId < max, "index out of range");
        address o = ownership[_tokenId];
        require (o == _from, "_from must be owner");
        address a = approval[_tokenId];
        require (o == msg.sender || (a == msg.sender) || (approvalAll[o][msg.sender]), "not permitted");
        _transfer(_from, _to, _tokenId);
        if (a != address(0)) {
            approval[_tokenId] = address(0); // clear previous approval
            emit Approval(msg.sender, address(0), _tokenId);
        }
        require(_checkOnERC721Received(_from, _to, _tokenId, ""), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external regulated(_to) {

        require (_tokenId < max, "index out of range");
        address o = ownership[_tokenId];
        require (o == _from, "_from must be owner");
        address a = approval[_tokenId];
        require (o == msg.sender|| (a == msg.sender) || (approvalAll[o][msg.sender]), "not permitted");
        _transfer(_from, _to, _tokenId);
        if (a != address(0)) {
            approval[_tokenId] = address(0); // clear previous approval
            emit Approval(msg.sender, address(0), _tokenId);
        }
    }

    function approve(address _to, uint256 _tokenId) external {

        require (_tokenId < max, "index out of range");
        address o = ownership[_tokenId];
        require (o == msg.sender || isApprovedForAll(o, msg.sender), "action not token permitted");
        approval[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }
    function setApprovalForAll(address _operator, bool _approved) external {

        require(msg.sender != _operator, "ERC721: approve to caller");
        approvalAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {

        require (_tokenId < max, "index out of range");
        return approval[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

        return approvalAll[_owner][_operator];
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {

        return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        interfaceId == type(IERC165).interfaceId ||
        interfaceId == type(IERC721Enumerable).interfaceId ||
        interfaceId == type(IERC721TokenReceiver).interfaceId;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {

        balances[_to]++;
        balances[_from]--;
        ownership[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function onERC721Received(address /*_operator*/, address /*_from*/, uint256 /*_tokenId*/, bytes memory /*_data*/) external pure returns (bytes4) {

        revert("nope");
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
            return false; // not needed, but the ide complains that there's "no return statement"
        } else {
            return true;
        }
    }

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function toString(uint256 value) public pure returns (string memory) {


        uint8 count;
        if (value == 0) {
            return "0";
        }
        uint256 digits = 31;
        bytes memory buffer = new bytes(32);
        while (value != 0) {
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
            digits -= 1;
            count++;
        }
        uint256 temp;
        assembly {
            temp := mload(add(buffer, 32))
            temp := shl(mul(sub(32,count),8), temp)
            mstore(add(buffer, 32), temp)
            mstore(buffer, count)
        }
        return string(buffer);
    }
}

interface ITheNFTv1 {

    function balanceOf(address) external view returns(uint256);

    function ownerOf(uint256) external view returns(address);

    function transferFrom(address,address,uint256) external;

    function isApprovedForAll(address, address) external view returns(bool) ;

    function burn(uint256) external;

    function mint(uint256) external;

}
