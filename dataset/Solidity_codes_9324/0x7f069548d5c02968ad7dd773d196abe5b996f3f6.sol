
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


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
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
}// MIT LICENSE

pragma solidity ^0.8.9;


interface IToken {
    function ownerOf(uint id) external view returns (address);
    function isPirate(uint16 id) external view returns (bool);
    function transferFrom(address from, address to, uint tokenId) external;
    function safeTransferFrom(address from, address to, uint tokenId, bytes memory _data) external;
    function isApprovedForAll(address owner, address operator) external returns(bool);
    function setApprovalForAll(address operator, bool approved) external;
}
interface IRum {
    function ownerOf(uint id) external view returns (address);
    function burn(address account, uint amount) external;
    function balanceOf(address account, uint tokenId) external returns (uint);
}
interface INewLand {
    function stakeTokens(address account, uint16[] memory tokenIds) external;
}

contract GHGSail is Ownable, IERC721Receiver, Pausable {
    uint constant public RUM_TICKET_ID = 0;

    IToken public goldHunter;
    IToken public shipToken;
    INewLand public newLand;
    IRum public rum;

    struct OceanStake {
        address owner;
        uint80 startTimestamp;
        uint16[] tokenIds;
        uint16 speed;
    }

    mapping(uint16 => bool) public waterproof;
    mapping(uint256 => uint256) public stakeIndices;
    mapping(address => OceanStake[]) public oceanStake;

    mapping(address => bool) public approvedManagers;

    uint public distance = 424800;

    mapping(uint16 => uint16) public speedMapping;

    mapping(uint16 => uint16) public rumSpeedMapping;

    uint16 public shipsInOceanCounter;
    uint16 public raftsInOceanCounter;
    uint16 public shipsArrivedCounter;
    uint16 public raftsArrivedCounter;
    uint16 public tokensArrivedCounter;

    event TokenStaked(address owner, uint16 shipId, uint16[] tokenIds, uint16 rum, uint16 speed, uint timestamp);
    event ShipArrived(address owner, uint16 shipId, uint16[] tokenIds, uint timestamp);

    function addManager(address _address) public onlyOwner {
        approvedManagers[_address] = true;
    }

    function removeManager(address _address) public onlyOwner {
        approvedManagers[_address] = false;
    }

    function getStake(address _address) external view returns(OceanStake[] memory) {
        return oceanStake[_address];
    }

    constructor() {
        _pause();

        rumSpeedMapping[0] = 10;
        rumSpeedMapping[1] = 8;
        rumSpeedMapping[2] = 7;
        rumSpeedMapping[3] = 6;
        rumSpeedMapping[4] = 4;
        rumSpeedMapping[5] = 3;
        rumSpeedMapping[6] = 2;

        speedMapping[0] = 30; // raft
        speedMapping[1] = 30; // default ship
        speedMapping[2] = 45; // pirate ship
        speedMapping[3] = 15; // goldminer
        speedMapping[4] = 30; // pirate
        speedMapping[5] = 0;  // fairwind
    }

    function setGoldHunter(address _address) external onlyOwner {
        addManager(_address);
        goldHunter = IToken(_address);
    }
    function setShips(address _address) external onlyOwner {
        addManager(_address);
        shipToken = IToken(_address);
    }
    function setRum(address _address) external onlyOwner {
        rum = IRum(_address);
    }
    function setNewLand(address _address) external onlyOwner {
        addManager(_address);
        newLand = INewLand(_address);
    }
    function changeRumSpeedMapping(uint16 _key, uint16 _newValue) external onlyOwner {
        rumSpeedMapping[_key] = _newValue;
    }
    function changeSpeedMapping(uint16 _key, uint16 _newValue) external onlyOwner {
        speedMapping[_key] = _newValue;
    }
    function changeDistance(uint16 _distance) external onlyOwner {
        distance = _distance;
    }

    function stakeTokens(address _account, uint16 _shipId, uint16[] calldata _tokenIds, uint16 _rumAmount) public whenNotPaused {
        require(_account == msg.sender, "You do not have a permission to do that");

        if (_shipId != 0) {
            require(shipToken.ownerOf(_shipId) == msg.sender, "This NTF does not belong to address");
        }

        uint16 speed = speedMapping[0]; // raft speed
        if (_shipId != 0) {
            if (shipToken.isPirate(_shipId)) {
                speed = speedMapping[2]; // pirate ship speed
                require(_tokenIds.length <= 7, "Cannot stake more than 7 NFTs");
            } else {
                speed = speedMapping[1]; // default ship speed
                require(_tokenIds.length <= 5, "Cannot stake more than 5 NFTs");
            }

            shipToken.transferFrom(msg.sender, address(this), _shipId);
            waterproof[_shipId] = true;
        }

        for (uint16 i = 0; i < _rumAmount; i++) {
            require(rum.balanceOf(_account, RUM_TICKET_ID) > 0, "No tokens available to burn");
            rum.burn(_account, 1);
            speed += rumSpeedMapping[i];
        }

        uint16[] memory tokens = new uint16[](_tokenIds.length + 1);
        tokens[0] = _shipId;

        for (uint i = 0; i < _tokenIds.length; i++) {
            require(goldHunter.ownerOf(_tokenIds[i]) == msg.sender, "This NTF does not belong to address");
            goldHunter.transferFrom(msg.sender, address(this), _tokenIds[i]);
            waterproof[_tokenIds[i]] = true;
            tokens[i+1] = _tokenIds[i];
            if (_shipId != 0) {
                speed += goldHunter.isPirate(_tokenIds[i]) ? speedMapping[4] : speedMapping[3];
            }
        }

        oceanStake[_account].push(OceanStake({
            owner: _account,
            speed: uint16(speed),
            tokenIds: tokens,
            startTimestamp: uint80(block.timestamp)
            }));

        shipsInOceanCounter += 1;
        if (_shipId == 0) raftsInOceanCounter += 1;
        emit TokenStaked(msg.sender, _shipId, _tokenIds, _rumAmount, uint16(speed), block.timestamp);
    }

    function unstakeTokens(address _owner, uint16 _index) external whenNotPaused {
        OceanStake memory userStake = oceanStake[_owner][_index];
        require(userStake.owner == msg.sender, "This stake does not belong to address");

        uint arrivedTimestamp = userStake.startTimestamp + distance / (userStake.speed + speedMapping[5]) * 1 minutes;
        require(block.timestamp >= arrivedTimestamp, "The bus has not arrived yet");

        oceanStake[_owner][_index] = oceanStake[_owner][oceanStake[_owner].length - 1];
        oceanStake[_owner].pop();

        if (userStake.tokenIds[0] != 0) {
            shipToken.safeTransferFrom(address(this), msg.sender, userStake.tokenIds[0], "");
        }
        for (uint i = 1; i < userStake.tokenIds.length; i++) {
            goldHunter.safeTransferFrom(address(this), msg.sender, userStake.tokenIds[i], "");
        }

        shipsArrivedCounter += 1;
        shipsInOceanCounter -= 1;
        tokensArrivedCounter += uint16(userStake.tokenIds.length - 1);

        if (userStake.tokenIds[0] == 0) {
            raftsInOceanCounter -= 1;
            raftsArrivedCounter += 1;
        }

        emit ShipArrived(userStake.owner, userStake.tokenIds[0], userStake.tokenIds, block.timestamp);
    }

    function unstakeTokensIntoLand(address _owner, uint16 _index) external whenNotPaused {
        OceanStake memory userStake = oceanStake[_owner][_index];
        require(userStake.owner == msg.sender, "This stake does not belong to address");

        if (!shipToken.isApprovedForAll(address(this), address(newLand))) shipToken.setApprovalForAll(address(newLand), true);
        if (!goldHunter.isApprovedForAll(address(this), address(newLand))) goldHunter.setApprovalForAll(address(newLand), true);

        uint arrivedTimestamp = userStake.startTimestamp + distance / (userStake.speed + speedMapping[5]) * 1 minutes;
        require(block.timestamp >= arrivedTimestamp, "The ship has not arrived yet");

        oceanStake[_owner][_index] = oceanStake[_owner][oceanStake[_owner].length - 1];
        oceanStake[_owner].pop();

        newLand.stakeTokens(_owner, userStake.tokenIds);

        tokensArrivedCounter += uint16(userStake.tokenIds.length - 1);
        shipsArrivedCounter += 1;
        shipsInOceanCounter -= 1;

        if (userStake.tokenIds[0] == 0) {
            raftsInOceanCounter -= 1;
            raftsArrivedCounter += 1;
        }

        emit ShipArrived(userStake.owner, userStake.tokenIds[0], userStake.tokenIds, block.timestamp);
    }

    function isWaterproof(uint16 _index) public view returns(bool) {
        return waterproof[_index];
    }

    function isWaterproofMany(uint16[] calldata _tokensIds) public view returns(bool[] memory) {
        bool[] memory valid = new bool[](_tokensIds.length);

        for (uint i = 0; i < _tokensIds.length; i++) {
            valid[i] = waterproof[_tokensIds[i]];
        }

        return valid;
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function pause() external onlyOwner {
        _pause();
    }

    function onERC721Received(
        address,
        address from,
        uint,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "Cannot send tokens to this contact directly");
        return IERC721Receiver.onERC721Received.selector;
    }
}