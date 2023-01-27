
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

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

}// MIT

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

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT
pragma solidity >=0.8.6;

contract Administration is Ownable {
    
    event SetAdmin(address indexed admin, bool active);
    
    mapping (address => bool) private admins;
    
    modifier onlyAdmin(){
        require(admins[_msgSender()] || owner() == _msgSender(), "Admin: caller is not an admin");
        _;
    }
    
    function setAdmin(address admin, bool active) external onlyOwner {
        admins[admin] = active;
        emit SetAdmin(admin, active);
    }
    
}// MIT
pragma solidity >=0.8.6;


contract POWERSTONES is ERC20, Administration {

    uint256 private _initialTokens = 750000000 ether;
    
    constructor() ERC20("POWERSTONES", "POWR") {}
    
    function initialMint() external onlyAdmin {
        require(totalSupply() == 0, "ERROR: Assets found");
        _mint(owner(), _initialTokens);
    }

    function mintTokens(uint amount) public onlyAdmin {
        _mint(owner(), amount);
    }

    function mintTo(address to, uint amount) public onlyAdmin {
        _mint(to, amount);
    }
    
    function burnTokens(uint amount) external onlyAdmin {
        _burn(owner(), amount);
    }

    function buy(address from, uint amount) external onlyAdmin {
        _burn(from, amount);
    }

    function withdraw() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }
}// MIT
pragma solidity >=0.8.6;


contract METAG_STAKING is Ownable, IERC721Receiver {
    using EnumerableSet for EnumerableSet.UintSet; 

    mapping(uint => address) public ownership;
    mapping(uint => uint) public stakeTime;
    mapping(address => uint) public lastWithdraw;
    mapping(address => uint[]) public _qty;
    mapping(uint256 => Stake) public stakes;
    mapping(address => EnumerableSet.UintSet) private stakedTokens;

    bool public paused = false;
    uint public tokensPerBlock;
    uint256 public nonce = 0;
    uint nullToken = 1 ether;
    uint256 public lockupPeriod = 604800; // 1 week

    IERC721 public NFT;
    POWERSTONES public TOKEN;

    struct Stake {
        uint256 lockupExpires;
        uint256 lastClaimedBlock;
    }

    struct RewardChanged {
        uint256 block;
        uint256 rewardPerBlock;
    }

    RewardChanged[] rewardChanges;

    modifier notPaused(){
        require(!paused, "PAUSED");
        _;
    }

    constructor(uint128 _tokensPerBlock) {
        tokensPerBlock = _tokensPerBlock;
    }

    function getStaked() public view returns (uint) {
        return nonce;
    }

    function setTokensPerBlock(uint new_) external onlyOwner {
        tokensPerBlock = new_;
    }

    function setLockupPeriod(uint new_) external onlyOwner {
        lockupPeriod = new_;
    }

    function togglePause() public onlyOwner {
        paused = !paused;
    }

    function setNFTAddress(address new_) external onlyOwner {
        NFT = IERC721(new_);
    }

    function setCOINAddress(address new_) external onlyOwner {
        TOKEN = POWERSTONES(new_);
    }

    function getAssetsByHolder(address holder) public view returns (uint[] memory){
        return _qty[holder];
    }

    function claimRewards(uint256[] calldata tokenIds) external notPaused {
        require(tokenIds.length > 0, "ClaimRewards: missing token ids");

        uint256 rewards;

        for (uint256 i; i < tokenIds.length; i++) {
            require(
                stakedTokens[msg.sender].contains(tokenIds[i]), 
                "ClaimRewards: token not staked"
            );
            require(
                stakes[tokenIds[i]].lockupExpires < block.timestamp, 
                "ClaimRewards: lockup period not expired"
            );            
            
            rewards += calculateRewards(tokenIds[i]);
            stakes[tokenIds[i]].lastClaimedBlock = uint128(block.number);
            stakes[tokenIds[i]].lockupExpires = uint128(block.timestamp + lockupPeriod);
        }

        TOKEN.mintTo(_msgSender(), rewards);
    }  

    function calculateRewards(uint256 tokenID) public view returns (uint256) {
        require(stakes[tokenID].lastClaimedBlock != 0, "token not staked");
        require(tokenID != nullToken, "err: token not staked");

        uint256 rewards;
        uint256 blocksPassed;

        uint256 lastClaimedBlock = stakes[tokenID].lastClaimedBlock;

        uint256 from;
        uint256 last;

        for(uint256 i=0; i < rewardChanges.length; i++) {
            bool hasNext = i+1 < rewardChanges.length;

            from = rewardChanges[i].block >= lastClaimedBlock ? 
                   rewardChanges[i].block : 
                   lastClaimedBlock;
            
            last = hasNext ? 
                   (rewardChanges[i+1].block >= lastClaimedBlock ? 
                      rewardChanges[i+1].block : 
                      from 
                   ) : 
                   block.number;

            blocksPassed = last - from;
            rewards += rewardChanges[i].rewardPerBlock * blocksPassed;         
        }
        return rewards;
    }  

    function stake(uint256[] calldata tokenIds) external notPaused {
        require(tokenIds.length > 0, "Stake: amount prohibited");

        for (uint256 i; i < tokenIds.length; i++) {
            require(NFT.ownerOf(tokenIds[i]) == msg.sender, "Stake: sender not owner");

            NFT.transferFrom(msg.sender, address(this), tokenIds[i]);

            stakes[tokenIds[i]] = Stake(uint128(block.timestamp + lockupPeriod), uint128(block.number));
            stakedTokens[msg.sender].add(tokenIds[i]);
            _qty[msg.sender].push(tokenIds[i]);
            nonce++;
        }
        tokensPerBlock = tokensPerBlock / nonce;
        rewardChanges.push(RewardChanged(uint256(block.number), tokensPerBlock / nonce));
    }   

    function unstake(uint256[] calldata tokenIds) external notPaused {
        require(tokenIds.length > 0, "Unstake: amount prohibited");

        for (uint256 i; i < tokenIds.length; i++) {
            require(
                stakedTokens[msg.sender].contains(tokenIds[i]), 
                "Unstake: token not staked"
            );
            
            stakedTokens[msg.sender].remove(tokenIds[i]);
            delete stakes[tokenIds[i]];
            removeToken(tokenIds[i]);
            NFT.transferFrom(address(this), msg.sender, tokenIds[i]);
            nonce--;
        }
        tokensPerBlock = tokensPerBlock / (nonce == 0 ? 1 : nonce);
        rewardChanges.push(RewardChanged(uint256(block.number), tokensPerBlock / (nonce == 0 ? 1 : nonce)));
    }

    function removeToken(uint tokenId) internal {
        for(uint i=0;i<_qty[_msgSender()].length;i++){
            if(_qty[_msgSender()][i] == tokenId){
                _qty[_msgSender()][i] = nullToken;
                break;
            }
        }
    }

    function onERC721Received(address operator, address, uint256, bytes memory) public view override returns (bytes4) {
        require(operator == address(this), "Operator not staking contract");

        return this.onERC721Received.selector;
    }

}