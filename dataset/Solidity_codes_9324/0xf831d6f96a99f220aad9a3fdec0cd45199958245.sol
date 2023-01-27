
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
interface IGold {
    function mint(address account, uint amount) external;
}
interface ISail {
    function isWaterproof(uint16 id) external view returns (bool);
}

contract NewLand is Ownable, IERC721Receiver, Pausable {
    uint public constant TAX_PERCENTAGE = 20;
    uint public constant MINIMUM_TIME_TO_EXIT = 2 days;

    bool zeroClaim = false;

    mapping(uint16 => uint) public rewardRates;

    IToken public ships;
    IToken public goldHunter;
    ISail public sail;
    IGold public gold;

    uint public totalGoldClaimed;
    uint public pirateReward;
    uint public unaccountedRewards;

    struct Stake {
        address owner;
        uint16 tokenId;
        uint80 value;
    }

    mapping(address => bool) public approvedManagers;

    mapping(uint => uint) shipIndices;
    mapping(uint => uint) goldMinerIndices;
    mapping(uint => uint) pirateIndices;
    mapping(address => Stake[]) goldMinerStake;
    mapping(address => Stake[]) pirateStake;
    mapping(address => Stake[]) shipStake;

    mapping(address => uint) pirateHolderIndex;
    address[] pirateHolders;

    uint public totalGoldMinerStaked;
    uint public totalShipStaked;
    uint public totalPirateStaked;
    uint public tokenStolenCounter;

    event TokenStolen(address owner, uint16 tokenId, address thief);
    event LandTokenStaked(address owner, uint16 tokenId, uint value);

    event ShipClaimed(uint16 tokenId, uint earned, bool unstaked);
    event GoldMinerClaimed(uint16 tokenId, uint earned, bool unstaked);
    event PirateClaimed(uint16 tokenId, uint earned, bool unstaked);

    function addManager(address _address) public onlyOwner {
        approvedManagers[_address] = true;
    }

    function removeManager(address _address) public onlyOwner {
        approvedManagers[_address] = false;
    }

    constructor() {
       rewardRates[0] = 2000 ether;
       rewardRates[1] = 4000 ether;
       rewardRates[2] = 6000 ether;

        _pause();
    }

    function setGoldHunter(address _address) external onlyOwner {
        addManager(_address);
        goldHunter = IToken(_address);
    }
    function setOcean(address _address) external onlyOwner {
        addManager(_address);
        sail = ISail(_address);
    }
    function setShip(address _address) external onlyOwner {
        addManager(_address);
        ships = IToken(_address);
    }
    function setZeroClaim(bool _status) external onlyOwner {
        zeroClaim = _status;
    }
    function setGold(address _address) external onlyOwner {
        gold = IGold(_address);
    }
    function getAccountGoldMiners(address user) external view returns (Stake[] memory) {
        return goldMinerStake[user];
    }
    function getAccountPirates(address user) external view returns (Stake[] memory) {
        return pirateStake[user];
    }
    function getAccountShips(address user) external view returns (Stake[] memory) {
        return shipStake[user];
    }
    function changeRewardRates(uint16 _key, uint16 _wei) external onlyOwner {
        rewardRates[_key] = _wei;
    }

    function stakeTokens(address _account, uint16[] memory _tokenIds) public {
        require(_account == msg.sender || msg.sender == address(sail), "Only manager or owner can do this");

        if (_tokenIds[0] != 0) {
            require(ships.ownerOf(_tokenIds[0]) == msg.sender, "This NTF does not belong to address");
            require(sail.isWaterproof(_tokenIds[0]) == true, "Token is not ready");
            ships.transferFrom(msg.sender, address(this), _tokenIds[0]);
            _stakeShips(_account, _tokenIds[0]);
        }
        for (uint i = 1; i < _tokenIds.length; i++) {
            require(goldHunter.ownerOf(_tokenIds[i]) == msg.sender, "This NTF does not belong to address");
            require(sail.isWaterproof(_tokenIds[i]) == true, "Token is not ready");
            goldHunter.transferFrom(msg.sender, address(this), _tokenIds[i]);
            
            if (goldHunter.isPirate(_tokenIds[i])) {
                _stakePirates(_account, _tokenIds[i]);
            } else {
                _stakeGoldMiners(_account, _tokenIds[i]);
            }
        }
    }

    function _stakeShips(address account, uint16 tokenId) internal whenNotPaused {
        totalShipStaked += 1;

        shipIndices[tokenId] = shipStake[account].length;
        shipStake[account].push(Stake({
            owner: account,
            tokenId: uint16(tokenId),
            value: uint80(block.timestamp)
        }));

        emit LandTokenStaked(account, tokenId, block.timestamp);
    }

    function _stakeGoldMiners(address account, uint16 tokenId) internal whenNotPaused {
        totalGoldMinerStaked += 1;

        goldMinerIndices[tokenId] = goldMinerStake[account].length;
        goldMinerStake[account].push(Stake({
            owner: account,
            tokenId: uint16(tokenId),
            value: uint80(block.timestamp)
        }));
        emit LandTokenStaked(account, tokenId, block.timestamp);
    }

    function _stakePirates(address account, uint16 tokenId) internal {
        totalPirateStaked += 1;

        if (pirateStake[account].length == 0) {
            pirateHolderIndex[account] = pirateHolders.length;
            pirateHolders.push(account);
        }

        pirateIndices[tokenId] = pirateStake[account].length;
        pirateStake[account].push(Stake({
            owner: account,
            tokenId: uint16(tokenId),
            value: uint80(pirateReward)
            }));

        emit LandTokenStaked(account, tokenId, pirateReward);
    }

    function claimFromStake(uint16[] calldata shipTokenIds, uint16[] calldata tokenIds, bool unstake) external whenNotPaused {
        uint owed = 0;
        for (uint i = 0; i < shipTokenIds.length; i++) {
            owed += _claimFromShip(shipTokenIds[i], unstake);
        }
        for (uint i = 0; i < tokenIds.length; i++) {
            if (goldHunter.isPirate(tokenIds[i])) {
                owed += _claimFromPirate(tokenIds[i], unstake);
            } else {
                owed += _claimFromMiner(tokenIds[i], unstake);
            }
        }
        if (owed == 0) return;
        gold.mint(msg.sender, owed);
        totalGoldClaimed += owed;
    }

    function _claimFromMiner(uint16 tokenId, bool unstake) internal returns (uint owed) {
        Stake memory stake = goldMinerStake[msg.sender][goldMinerIndices[tokenId]];
        require(stake.owner == msg.sender, "This NTF does not belong to address");
        require(!(unstake && block.timestamp - stake.value < MINIMUM_TIME_TO_EXIT), "Need to wait 2 days since last claim");

        owed = zeroClaim ? 0 : ((block.timestamp - stake.value) * rewardRates[0]) / 1 days;
        if (unstake == true) {
            bool stolen = false;
            address luckyPirate;
            if (tokenId >= 10000) {
                if (getSomeRandomNumber(tokenId, 100) <= 5) {
                    luckyPirate = randomPirateOwner();
                    if (luckyPirate != address(0x0) && luckyPirate != msg.sender) {
                        stolen = true;
                    }
                }
            }
            if (getSomeRandomNumber(tokenId, 100) <= 50) {
                _payTax(owed);
                owed = 0;
            }
            totalGoldMinerStaked -= 1;

            Stake memory lastStake = goldMinerStake[msg.sender][goldMinerStake[msg.sender].length - 1];
            goldMinerStake[msg.sender][goldMinerIndices[tokenId]] = lastStake;
            goldMinerIndices[lastStake.tokenId] = goldMinerIndices[tokenId];
            goldMinerStake[msg.sender].pop();
            delete goldMinerIndices[tokenId];

            if (!stolen) {
                goldHunter.safeTransferFrom(address(this), msg.sender, tokenId, "");
            } else {
                if (!goldHunter.isApprovedForAll(address(this), luckyPirate)) {
                    goldHunter.setApprovalForAll(luckyPirate, true);
                }
                goldHunter.safeTransferFrom(address(this), luckyPirate, tokenId, "");
                emit TokenStolen(msg.sender, tokenId, luckyPirate);
                tokenStolenCounter += 1;
            }
        } else {
            _payTax((owed * TAX_PERCENTAGE) / 100);
            owed = (owed * (100 - TAX_PERCENTAGE)) / 100;
            
            uint80 timestamp = uint80(block.timestamp);

            goldMinerStake[msg.sender][goldMinerIndices[tokenId]] = Stake({
                owner: msg.sender,
                tokenId: uint16(tokenId),
                value: timestamp
            });
        }

        emit GoldMinerClaimed(tokenId, owed, unstake);
    }

    function _claimFromShip(uint16 tokenId, bool unstake) internal returns (uint owed) {
        Stake memory stake = shipStake[msg.sender][shipIndices[tokenId]];
        require(stake.owner == msg.sender, "This NTF does not belong to address");
        require(!(unstake && block.timestamp - stake.value < MINIMUM_TIME_TO_EXIT), "Need to wait 2 days since last claim");

        uint rate = ships.isPirate(tokenId) ? rewardRates[2] : rewardRates[1];
        owed = zeroClaim ? 0 : ((block.timestamp - stake.value) * rate) / 1 days;

        _payTax((owed * TAX_PERCENTAGE) / 100);
        owed = (owed * (100 - TAX_PERCENTAGE)) / 100;

        if (unstake == true) {
            totalShipStaked -= 1;

            Stake memory lastStake = shipStake[msg.sender][shipStake[msg.sender].length - 1];
            shipStake[msg.sender][shipIndices[tokenId]] = lastStake;
            shipIndices[lastStake.tokenId] = shipIndices[tokenId];
            shipStake[msg.sender].pop();
            delete shipIndices[tokenId];

            ships.safeTransferFrom(address(this), msg.sender, tokenId, "");
        } else {
            uint80 timestamp = uint80(block.timestamp);

            shipStake[msg.sender][shipIndices[tokenId]] = Stake({
                owner: msg.sender,
                tokenId: uint16(tokenId),
                value: timestamp
            });
        }

        emit ShipClaimed(tokenId, owed, unstake);
    }

    function _claimFromPirate(uint16 tokenId, bool unstake) internal returns (uint owed) {
        require(goldHunter.ownerOf(tokenId) == address(this), "This NTF does not belong to address");

        Stake memory stake = pirateStake[msg.sender][pirateIndices[tokenId]];

        require(stake.owner == msg.sender, "This NTF does not belong to address");
        owed = zeroClaim ? 0 : (pirateReward - stake.value);

        if (unstake == true) {
            totalPirateStaked -= 1;

            Stake memory lastStake = pirateStake[msg.sender][pirateStake[msg.sender].length - 1];
            pirateStake[msg.sender][pirateIndices[tokenId]] = lastStake;
            pirateIndices[lastStake.tokenId] = pirateIndices[tokenId];
            pirateStake[msg.sender].pop();
            delete pirateIndices[tokenId];
            updatePirateOwnerAddressList(msg.sender);

            goldHunter.safeTransferFrom(address(this), msg.sender, tokenId, "");
        } else {
            pirateStake[msg.sender][pirateIndices[tokenId]] = Stake({
                owner: msg.sender,
                tokenId: uint16(tokenId),
                value: uint80(pirateReward)
            });
        }
        emit PirateClaimed(tokenId, owed, unstake);
    }

    function updatePirateOwnerAddressList(address account) internal {
        if (pirateStake[account].length != 0) {
            return; // No need to update holders
        }

        address lastOwner = pirateHolders[pirateHolders.length - 1];
        pirateHolderIndex[lastOwner] = pirateHolderIndex[account];
        pirateHolders[pirateHolderIndex[account]] = lastOwner;
        pirateHolders.pop();
        delete pirateHolderIndex[account];
    }

    function _payTax(uint _amount) internal {
        if (totalPirateStaked == 0) {
            unaccountedRewards += _amount;
            return;
        }

        pirateReward += (_amount + unaccountedRewards) / totalPirateStaked;
        unaccountedRewards = 0;
    }

    function getSomeRandomNumber(uint _seed, uint _limit) internal view returns (uint16) {
        uint random = uint(
            keccak256(
                abi.encodePacked(
                    _seed,
                    blockhash(block.number - 1),
                    block.coinbase,
                    block.difficulty,
                    block.timestamp,
                    msg.sender
                )
            )
        );

        return uint16(random % _limit);
    }

    function randomPirateOwner() public view returns (address) {
        if (totalPirateStaked == 0) return address(0x0);

        uint holderIndex = getSomeRandomNumber(totalPirateStaked, pirateHolders.length);

        return pirateHolders[holderIndex];
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