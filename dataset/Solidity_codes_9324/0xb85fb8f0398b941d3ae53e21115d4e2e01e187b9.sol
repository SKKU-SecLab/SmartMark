



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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
}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
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




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
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


pragma solidity 0.8.7;










contract SuperlativeApesStaking is ERC20("Superlative Staking", "SLAPE"), IERC721Receiver, Ownable, ReentrancyGuard {

    using EnumerableSet for EnumerableSet.UintSet;

    mapping (address => uint256) public totalStakedTokens;
    mapping(uint256 => uint256) public stakedDays;
    mapping(address => EnumerableSet.UintSet) private _deposits;

    mapping(address => EnumerableSet.UintSet) private _depositsMutant;
    mapping (address => uint256) public totalStakedMutantTokens;
    mapping(uint256 => uint256) public stakedMutantDays;

    uint256 public ReservedForLiquidity = 888888 ether;

    uint256 constant public APE_RATE = 10 ether; 
    uint256 constant public GOLD_RATE = 20 ether;


    uint256 constant public MUTANT_RATE = 5 ether;
    uint256 constant public MUTANT_M3_RATE = 20 ether;

    
    uint256[] public GOLD_APES = [1207, 415 , 286 , 2591, 2457, 2131, 2128, 1704, 1605, 1529, 1437, 1378, 3794, 3776, 3730, 3207, 3028, 2663, 4441, 4354, 4325, 3910];
    uint256 [] public M3 = [3499,1046,4407,83,2736];
    

    address[] public stakedWalletSlape;
    address[] public stakedWalletMutant;
    address[] private tempArray;

    IERC721 public superlativeApesContract = IERC721(0x1e87eE9249Cc647Af9EDEecB73D6b76AF14d8C27);
    IERC721 public superlativeMutantContract = IERC721(0x9FB2EEb75754815c5Cc9092Cd53549cEa5dc404f);

    constructor() 
    {
        _mint(msg.sender,ReservedForLiquidity);
    }

    function stakedWalletsLength() public view returns(uint256)
    {
        return stakedWalletSlape.length;
    }

    function teamMint(uint256 totalAmount) public onlyOwner
    {
        _mint(msg.sender, (totalAmount * 10 ** 18));
    }

    function StakeYourSlape(uint256[] calldata tokenID) public 
    {
        require(superlativeApesContract.isApprovedForAll(msg.sender, address(this)), "You are not Approved to stake your NFT!");
        
        for(uint256 i; i<tokenID.length; i++)
        {
            superlativeApesContract.safeTransferFrom(msg.sender, address(this), tokenID[i], "");

            if(!contains(msg.sender))
            {
                stakedWalletSlape.push(msg.sender);
            }
            
            _deposits[msg.sender].add(tokenID[i]);
            totalStakedTokens[msg.sender] = totalStakedTokens[msg.sender] + 1;
            stakedDays[tokenID[i]] = block.timestamp;
        }
    }

    function unStakeYourSlape(uint256[] calldata tokenID) public 
    {
        claimTokens();
        for(uint256 i; i<tokenID.length; i++)
        {
            superlativeApesContract.safeTransferFrom(address(this), msg.sender, tokenID[i], "");
            _deposits[msg.sender].remove(tokenID[i]);
            totalStakedTokens[msg.sender] = totalStakedTokens[msg.sender] + 1;

            if(_deposits[msg.sender].values().length < 1)
            {
                remove(msg.sender);
            }
        }
    }

    function contains(address _incoming) internal view returns(bool)
    {
        bool doesListContainElement = false;
    
        for (uint i=0; i < stakedWalletSlape.length; i++) {
            if (_incoming == stakedWalletSlape[i]) {
                doesListContainElement = true;
            }
        }

        return doesListContainElement;
    }
    
    function remove(address _incoming) internal {

        delete tempArray;
        
        for (uint256 i = 0; i<stakedWalletSlape.length; i++){
            if(stakedWalletSlape[i] != _incoming)
            {
                tempArray.push(stakedWalletSlape[i]);
            }
        }

        delete stakedWalletSlape;

        stakedWalletSlape = tempArray;
        
    }


    function claimTokens() public 
    {
        uint256 payout = 0;
        for(uint256 i = 0; i < _deposits[msg.sender].length(); i++)
        {
            payout += totalRewardsToPay(_deposits[msg.sender].at(i));
            stakedDays[_deposits[msg.sender].at(i)] = block.timestamp;
        }
        _mint(msg.sender, payout);
    }

    function viewRewardTotal() external view returns (uint256)
    {
        uint256 payout = 0;
        
        for(uint256 i = 0; i < _deposits[msg.sender].length(); i++)
        {
            payout = payout + totalRewardsToPay(_deposits[msg.sender].at(i));
        }
        return payout;
    }

    function totalRewardsToPay(uint256 tokenId) internal view returns(uint256)
    {
        uint256 payout = 0;
        
        payout = howManyDaysStaked(tokenId) * APE_RATE;

        for(uint256 i=0; i<GOLD_APES.length; i++)
        {
            if(tokenId == GOLD_APES[i])
            {
                payout = howManyDaysStaked(tokenId) * GOLD_RATE;
            }   
        }
        return payout;
    }

    function howManyDaysStaked(uint256 tokenId) public view returns(uint256)
    {
        
        require(
            _deposits[msg.sender].contains(tokenId),
            'Token not deposited'
        );
        
        uint256 timeCalc = block.timestamp - stakedDays[tokenId];
        uint256 returndays = timeCalc / 86400;
       
        return returndays;
    }

    function returnStakedTokens() public view returns (uint256[] memory)
    {
        return _deposits[msg.sender].values();
    }
    



    function containsMutate(address _incoming) internal view returns(bool)
    {
        bool doesListContainElement = false;
    
        for (uint i=0; i < stakedWalletMutant.length; i++) {
            if (_incoming == stakedWalletMutant[i]) {
                doesListContainElement = true;
            }
        }

        return doesListContainElement;
    }

    function unStakeYourMutant(uint256[] calldata tokenID) public 
    {
        claimTokensMutants();
        for(uint256 i; i<tokenID.length; i++)
        {
            superlativeMutantContract.safeTransferFrom(address(this), msg.sender, tokenID[i], "");
            _depositsMutant[msg.sender].remove(tokenID[i]);
            totalStakedMutantTokens[msg.sender] = totalStakedMutantTokens[msg.sender] + 1;

            if(_depositsMutant[msg.sender].values().length < 1)
            {
                remove(msg.sender);
            }
        }
    }

    function StakeYourMutant(uint256[] calldata tokenID) public 
    {
        require(superlativeMutantContract.isApprovedForAll(msg.sender, address(this)), "You are not Approved to stake your NFT!");
        
        for(uint256 i; i<tokenID.length; i++)
        {
            superlativeMutantContract.safeTransferFrom(msg.sender, address(this), tokenID[i], "");

            if(!containsMutate(msg.sender))
            {
                stakedWalletMutant.push(msg.sender);
            }
            
            _depositsMutant[msg.sender].add(tokenID[i]);
            totalStakedMutantTokens[msg.sender] = totalStakedMutantTokens[msg.sender] + 1;
            stakedMutantDays[tokenID[i]] = block.timestamp;
        }
    }

    function claimTokensMutants() public 
    {
        uint256 payout = 0;
        for(uint256 i = 0; i < _depositsMutant[msg.sender].length(); i++)
        {
            payout += totalRewardsToPayMutant(_depositsMutant[msg.sender].at(i));   
            stakedMutantDays[_depositsMutant[msg.sender].at(i)] = block.timestamp;
        }

        _mint(msg.sender, payout);
    }

    function viewRewardTotalMutant() external view returns (uint256)
    {
        uint256 payout = 0;
        
        for(uint256 i = 0; i < _depositsMutant[msg.sender].length(); i++)
        {
            payout = payout + totalRewardsToPayMutant(_depositsMutant[msg.sender].at(i));
        }
        return payout;
    }

    function howManyDaysStakedMutant(uint256 tokenId) public view returns(uint256)
    {
        
        require(
            _depositsMutant[msg.sender].contains(tokenId),
            'Token not deposited'
        );
        
        uint256 timeCalc = block.timestamp - stakedMutantDays[tokenId];
        uint256 returndays = timeCalc / 86400;
       
        return returndays;
    }

    function returnStakedTokensMutant() public view returns (uint256[] memory)
    {
        return _depositsMutant[msg.sender].values();
    }

    function totalRewardsToPayMutant(uint256 tokenId) internal view returns(uint256)
    {
        uint256 payout = howManyDaysStakedMutant(tokenId) * MUTANT_RATE;
        
        for(uint256 i=0;i<M3.length;i++)
        {
            if(M3[i] == tokenId)
            {
                payout = howManyDaysStakedMutant(tokenId) * MUTANT_M3_RATE;
            }
        }

        if(tokenId >= 13333)
        {
            payout = howManyDaysStakedMutant(tokenId) * MUTANT_M3_RATE;
        }
        
        
        return payout;
    }


    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}