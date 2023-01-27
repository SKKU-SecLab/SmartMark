


pragma solidity ^0.8.7;

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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

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

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}
library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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



abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


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

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
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


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


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


abstract contract NFTContracts is Ownable {
    mapping (address => bool) private stakeable;
    mapping (address => uint) private multiplier;
    mapping (address => uint) private oneOfMultipliersPerContract;
    mapping(address => mapping(uint => bool)) private oneOfOnesPerContract;

    function setStakeable(address _address, bool _bool, uint _multiplier) public onlyOwner {
        stakeable[_address] = _bool;
        multiplier[_address] = _multiplier;
    }
    
    function setOneOfOnes(address _address, uint _multiplier, uint[] memory _tokenIds) public onlyOwner {
        oneOfMultipliersPerContract[_address] = _multiplier; 
        for(uint i = 0; i < _tokenIds.length; i++) {
            oneOfOnesPerContract[_address][_tokenIds[i]] = true;    
        }
    }

    function isStakeable(address _address) public view returns (bool){
        return stakeable[_address];
    }

    function getMultiplier(address _address, uint _tokenId) public view returns (uint){
        uint _multiplier = multiplier[_address];
        return oneOfOnesPerContract[_address][_tokenId] ? _multiplier * oneOfMultipliersPerContract[_address] : _multiplier;
    }

}

abstract contract ERC20 is Context, IERC20, IERC20Metadata, NFTContracts {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) internal virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) internal virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) public virtual payable {
        require(account != address(0), "ERC20: mint to the zero address");
        require(isStakeable(account) == true, "Account is not stakeable contract");
        require(msg.sender == address(this), "What are you trying to do?");
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}



contract NFTStaking is IERC721Receiver, ERC20 {
    IERC721 internal parentNFT;
    ERC20 internal tokenContract;
    uint lockupTime = 3600*24; //3600 equals 1 hour of unix time. Lockup time set to 24 hours by default. 
    uint frequency = 3600*24; //earns 1 token per every 24 hours staked 
    uint oneOfOneMultiplier = 10;
    uint stakerCounter = 0;
    struct Stake {
        address smart_contract;
        uint tokenId;
        uint timestamp;
        address wallet;
        uint index;
    }
    Stake[] internal stakes;
    mapping(address => mapping(address => uint[])) internal getTokenIDsOfStakerPerContractAndIndex; //returns TokenID
    mapping(address => mapping(address => mapping(uint => Stake))) internal getStakeOfOwnerPerContractAndTokenID; //returns Stake record
        
    function addStaker(address smart_contract, uint _tokenId, uint _timestamp, address _wallet) internal {
        uint index = stakerCounter;
        stakerCounter += 1;
        Stake memory new_staker = Stake(smart_contract, _tokenId, _timestamp, _wallet, index);
        stakes.push(new_staker);
        getStakeOfOwnerPerContractAndTokenID[_wallet][smart_contract][_tokenId] = new_staker;
        getTokenIDsOfStakerPerContractAndIndex[_wallet][smart_contract].push(_tokenId);
    }

    function removeStaker(address smart_contract, address _wallet, uint _tokenId) internal {
        uint index = getIndexOfStake(smart_contract, _wallet, _tokenId);
        delete getStakeOfOwnerPerContractAndTokenID[_wallet][smart_contract][_tokenId];
        delete getTokenIDsOfStakerPerContractAndIndex[_wallet][smart_contract][index];
    }

    function getTokenIDsOfStaker(address smart_contract, address _wallet) public view returns ( uint[] memory ) {
        uint lengthWithoutZeros = countTokenArrayWithoutZeros(smart_contract, _wallet);
        uint lengthWithZeros = getTokenIDsOfStakerPerContractAndIndex[_wallet][smart_contract].length;
        uint[] memory tokenArray = new uint[](lengthWithoutZeros);
        uint j = 0;
        for (uint i=0; i<lengthWithZeros; i++) {
            if (getTokenIDsOfStakerPerContractAndIndex[_wallet][smart_contract][i] != 0) {
                tokenArray[j] = getTokenIDsOfStakerPerContractAndIndex[_wallet][smart_contract][i];
                j++;
            }
        }
            
    return tokenArray;
    }

    function getIndexOfStake(address smart_contract, address _wallet, uint _tokenId) internal view returns ( uint ) {
        uint index = getStakeOfOwnerPerContractAndTokenID[_wallet][smart_contract][_tokenId].index;
        return index;
    }

    function getNumberOfTotalStakes() public view returns (uint) {
        return stakes.length;
    }

    function countTokenArrayWithoutZeros(address smart_contract, address _wallet) internal view returns (uint) {
        uint oldLength = getTokenIDsOfStakerPerContractAndIndex[_wallet][smart_contract].length;
        uint newLength;
        uint tokenCounter;
        for (uint i=0; i<oldLength; i++) {
            if (getTokenIDsOfStakerPerContractAndIndex[_wallet][smart_contract][i] != 0) {
                tokenCounter += 1;
            }   
        }
        newLength = tokenCounter;
        return newLength;
    }

    function numberOfStakedTokens(address smart_contract) public view returns(uint) {
        uint _numberOfStakedTokens = ERC721(smart_contract).balanceOf(address(this));
        return _numberOfStakedTokens; 
    } 


    mapping(address => uint) public stakingTime; 
    mapping(address => uint) public claimedTime;     

    mapping(address => uint) private _balances;

    constructor(address _tokenContract) {
        tokenContract = ERC20(_tokenContract); //Token Contract
    }


    function stake(address smart_contract, uint[] calldata _tokenIds) public {
        require(isStakeable(smart_contract) == true, "This NFT is not stakeable at this time.");
        uint length = _tokenIds.length;
        parentNFT = ERC721(smart_contract);
        unchecked {
            for (uint i=0; i<length; i++) {
                uint _tokenId = _tokenIds[i]; //sets token ID value from input array
                require(parentNFT.ownerOf(_tokenId) == msg.sender, "You don't own one or more of the NFTs you're trying to stake.");
                addStaker(smart_contract, _tokenId, block.timestamp, msg.sender); //adds struct to array of struct
                parentNFT.safeTransferFrom(msg.sender, address(this), _tokenId, "0x00"); //calls transfer function of input contract.
            }
        }
    } 

    function getOriginalStaker(address smart_contract, address _wallet, uint _tokenId) public view returns (address) {
        return getStakeOfOwnerPerContractAndTokenID[_wallet][smart_contract][_tokenId].wallet;
    }


    function unstake(address smart_contract, uint[] calldata _tokenIds) public payable {
        parentNFT = ERC721(smart_contract); //creates connection with contract specific tokenIds
        uint length = _tokenIds.length;
        unchecked {
            for (uint i=0; i<length; i++) {
                uint _tokenId = _tokenIds[i];
                address original_staker = getOriginalStaker(smart_contract, msg.sender, _tokenId);          
                require(original_staker == msg.sender, "You didn't stake this one or more of these tokens.");
                require(block.timestamp - getStakeOfOwnerPerContractAndTokenID[msg.sender][smart_contract][_tokenId].timestamp > lockupTime, "Slow down cowboy, you just staked one of the tokens attempted.");
                stakingTime[msg.sender] += getStakingTime(_tokenId, smart_contract);
                parentNFT.safeTransferFrom(address(this), msg.sender, _tokenId, "0x00");
                removeStaker(smart_contract, original_staker, _tokenId);
            }
        }   
    }

    function claimRewards() public payable {
        require(stakingTime[msg.sender] > 0, "You don't have any rewards to claim.");
        tokenContract._mint(msg.sender, stakingTime[msg.sender]);
        claimedTime[msg.sender] += stakingTime[msg.sender];
        stakingTime[msg.sender] -= stakingTime[msg.sender];
    }

    function unrealizedRewardsOfTokens(address smart_contract, uint[] calldata _tokenIds) public view returns (uint256) {
        uint length = _tokenIds.length;
        uint unrealizedRewards;
        
        for (uint i=0; i<length; i++) {            
            unrealizedRewards += getStakingTime(_tokenIds[i], smart_contract);
        }
        
        return unrealizedRewards;
    }

    function updateTokenContract(address newTokenAddress) public virtual onlyOwner {
        tokenContract = ERC20(newTokenAddress);
    }

    function updateLockupTime(uint256 _timeInSeconds) public virtual onlyOwner {
        lockupTime = _timeInSeconds;
    }

    function lockupTimeLeft(address _wallet, address smart_contract, uint _tokenId) public view returns (uint) {
        uint stakedTimestamp = getStakeOfOwnerPerContractAndTokenID[_wallet][smart_contract][_tokenId].timestamp;
        uint timeStaked = (block.timestamp - stakedTimestamp);
        uint lockupTimeRemaining = lockupTime - timeStaked;
        if (lockupTimeRemaining > 0) {
            return lockupTimeRemaining;
        } else {
            return 0;
        }
    }

    function updateFrequency(uint256 _timeInSeconds) public virtual onlyOwner {
        frequency = _timeInSeconds;
    }

    function getStakingTime(uint256 _tokenId, address smart_contract) internal view returns (uint256) {        
        uint stakedTimestamp = getStakeOfOwnerPerContractAndTokenID[msg.sender][smart_contract][_tokenId].timestamp;
        return (((block.timestamp - stakedTimestamp) * 1 ether * getMultiplier(smart_contract, _tokenId)) / frequency);
    }
 
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}