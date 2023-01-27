
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// contracts/Sabi.sol
pragma solidity ^0.8.0;


contract Sabi is ERC20Burnable, Ownable {

    using SafeMath for uint256;

    uint256 public MAX_WALLET_STAKED = 100; 
    uint256 public EMISSIONS_RATE = 115740700000000; 
    uint256 public CLAIM_END_TIME = 1672581600; 

    address nullAddress = 0x0000000000000000000000000000000000000000;

    address public wabiAddress;
    mapping(uint256 => uint256) internal idToRarityBoosts;

    mapping(uint256 => uint256) internal tokenIdToTimeStamp;

    mapping(uint256 => address) internal tokenIdToStaker;

    mapping(address => uint256[]) internal stakerToTokenIds;

    constructor() ERC20("Sabi", "SABI") {
        idToRarityBoosts[285] = 3; idToRarityBoosts[476] = 3; idToRarityBoosts[556] = 3; idToRarityBoosts[1480] = 3; idToRarityBoosts[1628] = 3; idToRarityBoosts[2594] = 3; idToRarityBoosts[2834] = 3; idToRarityBoosts[2961] = 3; idToRarityBoosts[3108] = 3; idToRarityBoosts[3472] = 3;
        idToRarityBoosts[4630] = 2; idToRarityBoosts[4722] = 2; idToRarityBoosts[2564] = 2; idToRarityBoosts[3474] = 2; idToRarityBoosts[2783] = 2; idToRarityBoosts[4637] = 2; idToRarityBoosts[1730] = 2; idToRarityBoosts[4066] = 2; idToRarityBoosts[218] = 2; idToRarityBoosts[4304] = 2; 
        idToRarityBoosts[1027] = 2; idToRarityBoosts[5587] = 2; idToRarityBoosts[4466] = 2; idToRarityBoosts[2492] = 2; idToRarityBoosts[866] = 2; idToRarityBoosts[842] = 2; idToRarityBoosts[1252] = 2; idToRarityBoosts[4800] = 2; idToRarityBoosts[4425] = 2; idToRarityBoosts[5638] = 2;
        idToRarityBoosts[1358] = 2; idToRarityBoosts[4353] = 2; idToRarityBoosts[4183] = 2; idToRarityBoosts[5465] = 2; idToRarityBoosts[3530] = 2; idToRarityBoosts[3761] = 2; idToRarityBoosts[4454] = 2; idToRarityBoosts[2126] = 2; idToRarityBoosts[2425] = 2; idToRarityBoosts[101] = 2; 
        idToRarityBoosts[2967] = 2; idToRarityBoosts[2736] = 2; idToRarityBoosts[2548] = 2; idToRarityBoosts[2878] = 2; idToRarityBoosts[511] = 2; idToRarityBoosts[4191] = 2; idToRarityBoosts[3001] = 2; idToRarityBoosts[4383] = 2; idToRarityBoosts[4359] = 2; idToRarityBoosts[2569] = 2;
        idToRarityBoosts[4435] = 2; idToRarityBoosts[2083] = 2; idToRarityBoosts[5428] = 2; idToRarityBoosts[1478] = 2; idToRarityBoosts[1735] = 2; idToRarityBoosts[1528] = 2; idToRarityBoosts[3357] = 2; idToRarityBoosts[2953] = 2; idToRarityBoosts[4502] = 2; idToRarityBoosts[1685] = 2; 
        idToRarityBoosts[4424] = 2; idToRarityBoosts[1251] = 2; idToRarityBoosts[2457] = 2; idToRarityBoosts[2732] = 2; idToRarityBoosts[2917] = 2; idToRarityBoosts[519] = 2; idToRarityBoosts[1434] = 2; idToRarityBoosts[3939] = 2; idToRarityBoosts[1657] = 2; idToRarityBoosts[2676] = 2;
        idToRarityBoosts[841] = 2; idToRarityBoosts[643] = 2; idToRarityBoosts[4550] = 2; idToRarityBoosts[846] = 2; idToRarityBoosts[4587] = 2; idToRarityBoosts[1831] = 2; idToRarityBoosts[4763] = 2; idToRarityBoosts[1232] = 2; idToRarityBoosts[1594] = 2; idToRarityBoosts[1070] = 2; 
        idToRarityBoosts[4497] = 2; idToRarityBoosts[2203] = 2; idToRarityBoosts[467] = 2; idToRarityBoosts[4810] = 2; idToRarityBoosts[75] = 2; idToRarityBoosts[3911] = 2; idToRarityBoosts[2391] = 2; idToRarityBoosts[2092] = 2; idToRarityBoosts[4953] = 2; 
        
    }

    function setWabiAddress(address _wabiAddress) public onlyOwner {
        wabiAddress = _wabiAddress;
        return;
    }

    function setRarityBoost(uint256 tokenId, uint256 boost) public onlyOwner {
        idToRarityBoosts[tokenId] = boost;
        return;
    }

    function getTokensStaked(address staker)
        public
        view
        returns (uint256[] memory)
    {
        return stakerToTokenIds[staker];
    }

    function remove(address staker, uint256 index) internal {
        if (index >= stakerToTokenIds[staker].length) return;

        for (uint256 i = index; i < stakerToTokenIds[staker].length - 1; i++) {
            stakerToTokenIds[staker][i] = stakerToTokenIds[staker][i + 1];
        }
        stakerToTokenIds[staker].pop();
    }

    function removeTokenIdFromStaker(address staker, uint256 tokenId) internal {
        for (uint256 i = 0; i < stakerToTokenIds[staker].length; i++) {
            if (stakerToTokenIds[staker][i] == tokenId) {
                remove(staker, i);
            }
        }
    }

    function stakeByIds(uint256[] memory tokenIds) public {
        require(
            stakerToTokenIds[msg.sender].length + tokenIds.length <=
                MAX_WALLET_STAKED,
            "Must have less than 100 wabi staked!"
        );

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                IERC721(wabiAddress).ownerOf(tokenIds[i]) == msg.sender &&
                    tokenIdToStaker[tokenIds[i]] == nullAddress,
                "Token must be stakable by you!"
            );

            IERC721(wabiAddress).transferFrom(
                msg.sender,
                address(this),
                tokenIds[i]
            );

            stakerToTokenIds[msg.sender].push(tokenIds[i]);

            tokenIdToTimeStamp[tokenIds[i]] = block.timestamp;
            tokenIdToStaker[tokenIds[i]] = msg.sender;
        }
    }

    function unstakeAll() public {
        require(
            stakerToTokenIds[msg.sender].length > 0,
            "Must have at least one token staked!"
        );
        uint256 totalRewards = 0;

        for (uint256 i = stakerToTokenIds[msg.sender].length; i > 0; i--) {
            uint256 tokenId = stakerToTokenIds[msg.sender][i - 1];

            IERC721(wabiAddress).transferFrom(
                address(this),
                msg.sender,
                tokenId
            );

            if (idToRarityBoosts[tokenId] != 0) {
                totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenId]) *
                    EMISSIONS_RATE * idToRarityBoosts[tokenId]);
            } else {
                totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenId]) *
                    EMISSIONS_RATE);
            }

            removeTokenIdFromStaker(msg.sender, tokenId);

            tokenIdToStaker[tokenId] = nullAddress;
        }

        _mint(msg.sender, totalRewards);
    }

    function unstakeByIds(uint256[] memory tokenIds) public {
        uint256 totalRewards = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokenIdToStaker[tokenIds[i]] == msg.sender,
                "Message Sender was not original staker!"
            );

            IERC721(wabiAddress).transferFrom(
                address(this),
                msg.sender,
                tokenIds[i]
            );

            if (idToRarityBoosts[tokenIds[i]] != 0) {
                totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenIds[i]]) *
                    EMISSIONS_RATE * idToRarityBoosts[tokenIds[i]]);
            } else {
                totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenIds[i]]) *
                    EMISSIONS_RATE);
            }

            removeTokenIdFromStaker(msg.sender, tokenIds[i]);

            tokenIdToStaker[tokenIds[i]] = nullAddress;
        }

        _mint(msg.sender, totalRewards);
    }

    function claimByTokenId(uint256 tokenId) public {
        require(
            tokenIdToStaker[tokenId] == msg.sender,
            "Token is not claimable by you!"
        );
        require(block.timestamp < CLAIM_END_TIME, "Claim period is over!");
        if (idToRarityBoosts[tokenId] != 0) {
            _mint(
                msg.sender,
                ((block.timestamp - tokenIdToTimeStamp[tokenId]) * EMISSIONS_RATE * idToRarityBoosts[tokenId]));
                    
        } else {
            _mint(
                msg.sender,
                ((block.timestamp - tokenIdToTimeStamp[tokenId]) * EMISSIONS_RATE));    
        }

        tokenIdToTimeStamp[tokenId] = block.timestamp;
    }

    function claimAll() public {
        require(block.timestamp < CLAIM_END_TIME, "Claim period is over!");
        uint256[] memory tokenIds = stakerToTokenIds[msg.sender];
        uint256 totalRewards = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokenIdToStaker[tokenIds[i]] == msg.sender,
                "Token is not claimable by you!"
            );

            if (idToRarityBoosts[tokenIds[i]] != 0) {
                totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenIds[i]]) *
                    EMISSIONS_RATE * idToRarityBoosts[tokenIds[i]]);
            } else {
                totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenIds[i]]) *
                    EMISSIONS_RATE);
            }

            tokenIdToTimeStamp[tokenIds[i]] = block.timestamp;
        }

        _mint(msg.sender, totalRewards);
    }

    function getAllRewards(address staker) public view returns (uint256) {
        uint256[] memory tokenIds = stakerToTokenIds[staker];
        uint256 totalRewards = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (idToRarityBoosts[tokenIds[i]] != 0) {
                totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenIds[i]]) *
                    EMISSIONS_RATE * idToRarityBoosts[tokenIds[i]]);
            } else {
                totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenIds[i]]) *
                    EMISSIONS_RATE);
            }
        }

        return totalRewards;
    }

    function getRewardsByTokenId(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        require(
            tokenIdToStaker[tokenId] != nullAddress,
            "Token is not staked!"
        );

        uint256 secondsStaked = block.timestamp - tokenIdToTimeStamp[tokenId];

        if (idToRarityBoosts[tokenId] != 0) {
            return secondsStaked * EMISSIONS_RATE * idToRarityBoosts[tokenId];
        }
        return secondsStaked * EMISSIONS_RATE;
    }

    function getStaker(uint256 tokenId) public view returns (address) {
        return tokenIdToStaker[tokenId];
    }

    function getRarityBoost(uint256 tokenId) public view returns (uint256) {
        return idToRarityBoosts[tokenId];
    }
}