
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

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
}//Apache-2.0

pragma solidity ^0.8.0;


interface IPoets is IERC721 {
    function getWordCount(uint256 tokenId) external view returns (uint8);
}//MIT
pragma solidity 0.8.9;


contract Silence is ERC20, Ownable, IERC721Receiver {
    struct Vow {
        address tokenOwner;
        uint256 tokenId;
        uint256 created;
        uint256 updated;
    }

    struct TokenTransfer {
        address to;
        uint256 tokenId;
        uint256 timelock;
    }

    event TakeVow(address indexed owner, uint256 tokenId);
    event BreakVow(address indexed owner, uint256 vowId, uint256 tokenId);
    event Claim(address indexed owner, uint256 vowId, uint256 amount);
    event ClaimBatch(address indexed owner, uint256[] vowIds, uint256 total);
    event ProposeTransfer(address indexed to, uint256 tokenId);

    IPoets public immutable poets;
    mapping(uint256 => Vow) public vows;
    mapping(address => uint256[]) public vowsByAddress;
    mapping(uint256 => TokenTransfer) public proposals;

    uint256 public proposalCount;
    uint256 public vowCount;

    uint256 private immutable accrualEnd;

    uint256 private constant SILENT_ERA = 360 days;
    uint256 private constant MAX_DAILY_SILENCE = 5e18;
    uint256 private constant MIN_DAILY_SILENCE = 1e18;

    constructor(address _poets) ERC20("Silence", "SILENCE") {
        poets = IPoets(_poets);
        accrualEnd = block.timestamp + SILENT_ERA;
    }

    function takeVow(uint256 tokenId) external {
        require(poets.ownerOf(tokenId) == msg.sender, "!tokenOwner");
        _takeVow(msg.sender, tokenId);
        poets.transferFrom(msg.sender, address(this), tokenId);
        emit TakeVow(msg.sender, tokenId);
    }

    function breakVow(uint256 vowId) external {
        address tokenOwner = vows[vowId].tokenOwner;
        require(vows[vowId].updated != 0, "!vow");
        require(tokenOwner == msg.sender, "!tokenOwner");
        uint256 tokenId = vows[vowId].tokenId;
        uint256 accrued = _claimSilence(vowId);
        delete vows[vowId];
        _mint(msg.sender, accrued);
        poets.transferFrom(address(this), tokenOwner, tokenId);
        emit BreakVow(tokenOwner, vowId, tokenId);
    }

    function claim(uint256 vowId) external {
        require(vows[vowId].updated != 0, "!vow");
        require(vows[vowId].tokenOwner == msg.sender, "!tokenOwner");
        uint256 amount = _claimSilence(vowId);
        _mint(msg.sender, amount);
        emit Claim(msg.sender, vowId, amount);
    }

    function claimAll() external {
        claimBatch(getVowsByAddress(msg.sender));
    }

    function claimBatch(uint256[] memory vowIds) public {
        uint256 total = 0;
        for (uint256 i = 0; i < vowIds.length; i++) {
            uint256 vowId = vowIds[i];
            if (vows[vowId].updated != 0) {
                require(vows[vowId].tokenOwner == msg.sender, "!tokenOwner");
                uint256 amount = _claimSilence(vowId);
                total += amount;
            }
        }
        _mint(msg.sender, total);
        emit ClaimBatch(msg.sender, vowIds, total);
    }

    function proposeTransfer(address to, uint256 tokenId) external onlyOwner {
        proposalCount++;
        proposals[proposalCount].to = to;
        proposals[proposalCount].tokenId = tokenId;
        proposals[proposalCount].timelock = block.timestamp + 7 days;
        emit ProposeTransfer(to, tokenId);
    }

    function executeTransfer(uint256 id) external onlyOwner {
        address to = proposals[id].to;
        uint256 tokenId = proposals[id].tokenId;
        require(to != address(0), "!proposal");
        require(tokenId < 1025, "!origin");
        require(proposals[id].timelock < block.timestamp, "timelock");
        poets.transferFrom(address(this), to, tokenId);
    }

    function claimable(uint256 vowId) external view returns (uint256) {
        return _claimableSilence(vowId);
    }

    function accrualRate(uint256 vowId) external view returns (uint256) {
        return _accrualRate(vowId, block.timestamp);
    }

    function getVowsByAddress(address tokenOwner)
        public
        view
        returns (uint256[] memory)
    {
        return vowsByAddress[tokenOwner];
    }

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes calldata
    ) external view override returns (bytes4) {
        require(msg.sender == address(poets), "!poet");
        require(tokenId < 1025, "!origin");
        return this.onERC721Received.selector;
    }

    function _takeVow(address tokenOwner, uint256 tokenId) internal {
        require(poets.getWordCount(tokenId) == 0, "!mute");
        vowCount++;
        vows[vowCount].tokenOwner = tokenOwner;
        vows[vowCount].tokenId = tokenId;
        vows[vowCount].created = block.timestamp;
        vows[vowCount].updated = block.timestamp;
        vowsByAddress[tokenOwner].push(vowCount);
    }

    function _accrualRate(uint256 vowId, uint256 timestamp)
        internal
        view
        returns (uint256)
    {
        uint256 vowLength = timestamp - vows[vowId].created;
        if (vowLength > SILENT_ERA) {
            return 0;
        } else {
            return
                MIN_DAILY_SILENCE +
                ((vowLength * (MAX_DAILY_SILENCE - MIN_DAILY_SILENCE)) /
                    SILENT_ERA);
        }
    }

    function _claimableSilence(uint256 vowId) internal view returns (uint256) {
        uint256 start = vows[vowId].updated;
        uint256 end = block.timestamp;
        uint256 duration = (end - start);

        if (start == 0) {
            return 0;
        } else if (start >= accrualEnd) {
            return 0;
        } else if (end > accrualEnd) {
            duration = accrualEnd - start;
            end = accrualEnd;
        }
        uint256 rate1 = _accrualRate(vowId, start);
        uint256 rate2 = _accrualRate(vowId, end);
        return _accruedAmount(rate1, rate2, duration);
    }

    function _accruedAmount(
        uint256 r1,
        uint256 r2,
        uint256 duration
    ) internal pure returns (uint256) {
        return (duration * (r1 + r2)) / (2 days);
    }

    function _claimSilence(uint256 vowId) internal returns (uint256) {
        uint256 amount = _claimableSilence(vowId);
        vows[vowId].updated = block.timestamp;
        return amount;
    }
}