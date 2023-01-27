





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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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




pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}




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

        _setApprovalForAll(_msgSender(), operator, approved);
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

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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

}




pragma solidity ^0.8.9;



interface ISquid {
    function ownerOf(uint id) external view returns (address);
    function isShark(uint16 id) external view returns (bool);
    function transferFrom(address from, address to, uint tokenId) external;
    function safeTransferFrom(address from, address to, uint tokenId, bytes memory _data) external;
}

interface IInkk {
    function mint(address account, uint amount) external;
}

contract Reef is Ownable, IERC721Receiver {
    bool private _paused = false;

    uint16 private _randomIndex = 0;
    uint private _randomCalls = 0;
    mapping(uint => address) private _randomSource;

    struct Stake {
        uint16 tokenId;
        uint80 value;
        address owner;
    }

    event TokenStaked(address owner, uint16 tokenId, uint value);
    event SquidClaimed(uint16 tokenId, uint earned, bool unstaked);
    event SharkClaimed(uint16 tokenId, uint earned, bool unstaked);

    ISquid public squidGame;
    IInkk public inkk;

    mapping(uint256 => uint256) public squidIndices;
    mapping(address => Stake[]) public squidStake;

    mapping(uint256 => uint256) public sharkIndices;
    mapping(address => Stake[]) public sharkStake;
    address[] public sharkHolders;

    uint public totalSquidStaked;
    uint public totalSharkStaked = 0;
    uint public unaccountedRewards = 0;

    uint public constant DAILY_INKK_RATE = 10000 ether;
    uint public constant MINIMUM_TIME_TO_EXIT = 2 days; // change back to 2 days after test
    uint public constant TAX_PERCENTAGE = 20;
    uint public constant MAXIMUM_GLOBAL_INKK = 2400000000 ether;

    uint public totalInkkEarned;

    uint public lastClaimTimestamp;
    uint public sharkReward = 0;

    bool public rescueEnabled = false;

    constructor() {
        _randomSource[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _randomSource[1] = 0x3cD751E6b0078Be393132286c442345e5DC49699;
        _randomSource[2] = 0xb5d85CBf7cB3EE0D56b3bB207D5Fc4B82f43F511;
        _randomSource[3] = 0xC098B2a3Aa256D2140208C3de6543aAEf5cd3A94;
        _randomSource[4] = 0x28C6c06298d514Db089934071355E5743bf21d60;
        _randomSource[5] = 0x2FAF487A4414Fe77e2327F0bf4AE2a264a776AD2;
        _randomSource[6] = 0x267be1C1D684F78cb4F6a176C4911b741E4Ffdc0;
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

    function setSquidGame(address _squidGame) external onlyOwner {
        squidGame = ISquid(_squidGame);
    }

    function setInkk(address _inkk) external onlyOwner {
        inkk = IInkk(_inkk);
    }

    function getAccountSquids(address user) external view returns (Stake[] memory) {
        return squidStake[user];
    }

    function getAccountSharks(address user) external view returns (Stake[] memory) {
        return sharkStake[user];
    }

    function addTokensToStake(address account, uint16[] calldata tokenIds) external {
        require(account == msg.sender || msg.sender == address(squidGame), "You do not have a permission to do that");

        for (uint i = 0; i < tokenIds.length; i++) {
            if (msg.sender != address(squidGame)) {
                require(squidGame.ownerOf(tokenIds[i]) == msg.sender, "This NTF does not belong to address");
                squidGame.transferFrom(msg.sender, address(this), tokenIds[i]);
            } else if (tokenIds[i] == 0) {
                continue; // there may be gaps in the array for stolen tokens
            }

            if (squidGame.isShark(tokenIds[i])) {
                _stakeSharks(account, tokenIds[i]);
            } else {
                _stakeSquids(account, tokenIds[i]);
            }
        }
    }

    function _stakeSquids(address account, uint16 tokenId) internal whenNotPaused _updateEarnings {
        totalSquidStaked += 1;

        squidIndices[tokenId] = squidStake[account].length;
        squidStake[account].push(Stake({
            owner: account,
            tokenId: uint16(tokenId),
            value: uint80(block.timestamp)
        }));
        emit TokenStaked(account, tokenId, block.timestamp);
    }


    function _stakeSharks(address account, uint16 tokenId) internal {
        totalSharkStaked += 1;

        if (sharkStake[account].length == 0) {
            sharkHolders.push(account);
        }

        sharkIndices[tokenId] = sharkStake[account].length;
        sharkStake[account].push(Stake({
            owner: account,
            tokenId: uint16(tokenId),
            value: uint80(sharkReward)
            }));

        emit TokenStaked(account, tokenId, sharkReward);
    }


    function claimFromStake(uint16[] calldata tokenIds, bool unstake) external whenNotPaused _updateEarnings {
        uint owed = 0;
        for (uint i = 0; i < tokenIds.length; i++) {
            if (!squidGame.isShark(tokenIds[i])) {
                owed += _claimFromSquid(tokenIds[i], unstake);
            } else {
                owed += _claimFromShark(tokenIds[i], unstake);
            }
        }
        if (owed == 0) return;
        inkk.mint(msg.sender, owed);
    }

    function _claimFromSquid(uint16 tokenId, bool unstake) internal returns (uint owed) {
        Stake memory stake = squidStake[msg.sender][squidIndices[tokenId]];
        require(stake.owner == msg.sender, "This NTF does not belong to address");
        require(!(unstake && block.timestamp - stake.value < MINIMUM_TIME_TO_EXIT), "Need to wait 2 days since last claim");

        if (totalInkkEarned < MAXIMUM_GLOBAL_INKK) {
            owed = ((block.timestamp - stake.value) * DAILY_INKK_RATE) / 1 days;
        } else if (stake.value > lastClaimTimestamp) {
            owed = 0; // $INKK production stopped already
        } else {
            owed = ((lastClaimTimestamp - stake.value) * DAILY_INKK_RATE) / 1 days; // stop earning additional $INKK if it's all been earned
        }
        if (unstake) {
            if (getSomeRandomNumber(tokenId, 100) <= 50) {
                _payTax(owed);
                owed = 0;
            }
            updateRandomIndex();
            totalSquidStaked -= 1;

            Stake memory lastStake = squidStake[msg.sender][squidStake[msg.sender].length - 1];
            squidStake[msg.sender][squidIndices[tokenId]] = lastStake;
            squidIndices[lastStake.tokenId] = squidIndices[tokenId];
            squidStake[msg.sender].pop();
            delete squidIndices[tokenId];

            squidGame.safeTransferFrom(address(this), msg.sender, tokenId, "");
        } else {
            _payTax((owed * TAX_PERCENTAGE) / 100); // Pay Shark Tax
            owed = (owed * (100 - TAX_PERCENTAGE)) / 100;
            
            uint80 timestamp = uint80(block.timestamp);

            squidStake[msg.sender][squidIndices[tokenId]] = Stake({
                owner: msg.sender,
                tokenId: uint16(tokenId),
                value: timestamp
            }); // reset stake
        }

        emit SquidClaimed(tokenId, owed, unstake);
    }

    function _claimFromShark(uint16 tokenId, bool unstake) internal returns (uint owed) {
        require(squidGame.ownerOf(tokenId) == address(this), "This NTF does not belong to address");

        Stake memory stake = sharkStake[msg.sender][sharkIndices[tokenId]];

        require(stake.owner == msg.sender, "This NTF does not belong to address");
        owed = (sharkReward - stake.value);

        if (unstake) {
            totalSharkStaked -= 1; // Remove Shark from total staked

            Stake memory lastStake = sharkStake[msg.sender][sharkStake[msg.sender].length - 1];
            sharkStake[msg.sender][sharkIndices[tokenId]] = lastStake;
            sharkIndices[lastStake.tokenId] = sharkIndices[tokenId];
            sharkStake[msg.sender].pop();
            delete sharkIndices[tokenId];
            updateSharkOwnerAddressList(msg.sender);

            squidGame.safeTransferFrom(address(this), msg.sender, tokenId, "");
        } else {
            sharkStake[msg.sender][sharkIndices[tokenId]] = Stake({
                owner: msg.sender,
                tokenId: uint16(tokenId),
                value: uint80(sharkReward)
            }); // reset stake
        }
        emit SharkClaimed(tokenId, owed, unstake);
    }

    function updateSharkOwnerAddressList(address account) internal {
        if (sharkStake[account].length != 0) {
            return; // No need to update holders
        }

        address lastOwner = sharkHolders[sharkHolders.length - 1];
        uint indexOfHolder = 0;
        for (uint i = 0; i < sharkHolders.length; i++) {
            if (sharkHolders[i] == account) {
                indexOfHolder = i;
                break;
            }
        }
        sharkHolders[indexOfHolder] = lastOwner;
        sharkHolders.pop();
    }

    function rescue(uint16[] calldata tokenIds) external {
        require(rescueEnabled, "Rescue disabled");
        uint16 tokenId;
        Stake memory stake;

        for (uint16 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            if (!squidGame.isShark(tokenId)) {
                stake = squidStake[msg.sender][squidIndices[tokenId]];

                require(stake.owner == msg.sender, "This NTF does not belong to address");

                totalSquidStaked -= 1;

                Stake memory lastStake = squidStake[msg.sender][squidStake[msg.sender].length - 1];
                squidStake[msg.sender][squidIndices[tokenId]] = lastStake;
                squidIndices[lastStake.tokenId] = squidIndices[tokenId];
                squidStake[msg.sender].pop();
                delete squidIndices[tokenId];

                squidGame.safeTransferFrom(address(this), msg.sender, tokenId, "");

                emit SquidClaimed(tokenId, 0, true);
            } else {
                stake = sharkStake[msg.sender][sharkIndices[tokenId]];
        
                require(stake.owner == msg.sender, "This NTF does not belong to address");

                totalSharkStaked -= 1;
                
                    
                Stake memory lastStake = sharkStake[msg.sender][sharkStake[msg.sender].length - 1];
                sharkStake[msg.sender][sharkIndices[tokenId]] = lastStake;
                sharkIndices[lastStake.tokenId] = sharkIndices[tokenId];
                sharkStake[msg.sender].pop();
                delete sharkIndices[tokenId];
                updateSharkOwnerAddressList(msg.sender);
                
                squidGame.safeTransferFrom(address(this), msg.sender, tokenId, "");
                
                emit SharkClaimed(tokenId, 0, true);
            }
        }
    }

    function _payTax(uint _amount) internal {
        if (totalSharkStaked == 0) {
            unaccountedRewards += _amount;
            return;
        }

        sharkReward += (_amount + unaccountedRewards) / totalSharkStaked;
        unaccountedRewards = 0;
    }


    modifier _updateEarnings() {
        if (totalInkkEarned < MAXIMUM_GLOBAL_INKK) {
            totalInkkEarned += ((block.timestamp - lastClaimTimestamp) * totalSquidStaked * DAILY_INKK_RATE) / 1 days;
            lastClaimTimestamp = block.timestamp;
        }
        _;
    }


    function setRescueEnabled(bool _enabled) external onlyOwner {
        rescueEnabled = _enabled;
    }

    function setPaused(bool _state) external onlyOwner {
        _paused = _state;
    }


    function randomSharkOwner() external returns (address) {
        if (totalSharkStaked == 0) return address(0x0);

        uint holderIndex = getSomeRandomNumber(totalSharkStaked, sharkHolders.length);
        updateRandomIndex();

        return sharkHolders[holderIndex];
    }

    function updateRandomIndex() internal {
        _randomIndex += 1;
        _randomCalls += 1;
        if (_randomIndex > 6) _randomIndex = 0;
    }

    function getSomeRandomNumber(uint _seed, uint _limit) internal view returns (uint16) {
        uint extra = 0;
        for (uint16 i = 0; i < 7; i++) {
            extra += _randomSource[_randomIndex].balance;
        }

        uint random = uint(
            keccak256(
                abi.encodePacked(
                    _seed,
                    blockhash(block.number - 1),
                    block.coinbase,
                    block.difficulty,
                    msg.sender,
                    extra,
                    _randomCalls,
                    _randomIndex
                )
            )
        );

        return uint16(random % _limit);
    }

    function changeRandomSource(uint _id, address _address) external onlyOwner {
        _randomSource[_id] = _address;
    }

    function shuffleSeeds(uint _seed, uint _max) external onlyOwner {
        uint shuffleCount = getSomeRandomNumber(_seed, _max);
        _randomIndex = uint16(shuffleCount);
        for (uint i = 0; i < shuffleCount; i++) {
            updateRandomIndex();
        }
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