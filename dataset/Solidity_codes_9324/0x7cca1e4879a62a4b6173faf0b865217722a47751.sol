
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}// MIT

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}// MIT

pragma solidity ^0.8.0;




abstract contract SamotNFT {
    function ownerOf(uint256 tokenId) public view virtual returns (address);

    function balanceOf(address owner)
        public
        view
        virtual
        returns (uint256 balance);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual;

    function isApprovedForAll(address owner, address operator)
        external
        view
        virtual
        returns (bool);
}

contract SamotToken is ERC20, ERC721Holder, Ownable {
    using SafeMath for uint256;
    address constant WALLET1 = 0xffe5CBCDdF2bd1b4Dc3c00455d4cdCcf20F77587;
    address constant WALLET2 = 0xD9CC8af4E8ac5Cb5e7DdFffD138A58Bac49dAEd5;
    uint256 public maxToMintPerNFT = 100;
    uint256 public maxToMint = 50000;
    uint256 public maxSupply = 6000000;
    uint256 public epochStartTime = block.timestamp;
    bool public preSaleIsActive = true;
    bool public saleIsActive = false;
    uint256 public stakingReward = 10;
    uint256 public mintPrice = 200000000000000;
    address[] internal stakeholders;
    uint256[] internal stakedtokens;
    uint256 initialSupply = 1000000;
    SamotNFT nft;

    event Claimed(address _from, uint256 _tokenId);

    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {
        _mint(msg.sender, initialSupply.mul(10**18));
    }

    struct Stakes {
        uint256[] tokens;
        uint256[] timestamps;
        bool exists;
    }

    mapping(address => Stakes) internal stakes;
    mapping(address => uint256) internal rewards;

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function flipPreSaleState() public onlyOwner {
        preSaleIsActive = !preSaleIsActive;
    }

    function setNFTContract(address _contract) external onlyOwner {
        nft = SamotNFT(_contract);
    }

    function setReward(uint256 _reward) external onlyOwner {
        stakingReward = _reward;
    }

    function setMintPrice(uint256 _price) external onlyOwner {
        mintPrice = _price;
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function setMaxToMint(uint256 _maxToMint) external onlyOwner {
        maxToMint = _maxToMint;
    }

    function setMaxToMintPerNFT(uint256 _maxToMint) external onlyOwner {
        maxToMintPerNFT = _maxToMint;
    }

    function getPrice() public view returns (uint256) {
        uint256 currentSupply = totalSupply().div(10**18);
        require(currentSupply <= maxSupply, "Sold out.");
        if (currentSupply >= 5000000) {
            return mintPrice.mul(2**4);
        } else if (currentSupply >= 4000000) {
            return mintPrice.mul(2**3);
        } else if (currentSupply >= 3000000) {
            return mintPrice.mul(2**2);
        } else if (currentSupply >= 2000000) {
            return mintPrice.mul(2);
        } else {
            return mintPrice;
        }
    }

    function mint(uint256 numberOfTokens) public payable {
        require(saleIsActive, "Sale is not active.");
        require(numberOfTokens > 0, "numberOfTokens cannot be 0");
        uint256 balance = balanceOf(msg.sender).div(10**18);
        if (preSaleIsActive) {
            require(
                getPrice().mul(numberOfTokens) <= msg.value,
                "ETH sent is incorrect."
            );
            require(
                nft.balanceOf(msg.sender) > 0,
                "You must own at least one Samot NFT to participate in the pre-sale."
            );
            require(
                numberOfTokens <=
                    maxToMintPerNFT.mul(nft.balanceOf(msg.sender)),
                "Exceeds limit for pre-sale."
            );
            require(
                balance.add(numberOfTokens) <=
                    maxToMintPerNFT.mul(nft.balanceOf(msg.sender)),
                "Exceeds limit for pre-sale."
            );
        } else {
            require(
                getPrice().mul(numberOfTokens) <= msg.value,
                "ETH sent is incorrect."
            );
            require(
                numberOfTokens <= maxToMint,
                "Exceeds limit for public sale."
            );
            require(balance <= maxToMint, "Exceeds limit for public sale.");
        }
        _mint(msg.sender, numberOfTokens.mul(10**18));
    }

    function isClaimable(uint256 _tokenId) internal view returns (bool) {
        for (uint256 s = 0; s < stakes[msg.sender].tokens.length; s += 1) {
            if (_tokenId == stakes[msg.sender].tokens[s]) return true;
        }
        return false;
    }

    function isStaked(uint256 _tokenId) internal view returns (bool, uint256) {
        for (uint256 s = 0; s < stakedtokens.length; s += 1) {
            if (_tokenId == stakedtokens[s]) return (true, s);
        }
        return (false, 0);
    }

    function isStakeholder(address _address)
        internal
        view
        returns (bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    function addStakeholder(address _stakeholder) internal {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if (!_isStakeholder) {
            stakeholders.push(_stakeholder);
            stakes[_stakeholder].exists = true;
        }
    }

    function removeStakeholder(address _stakeholder) internal {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder) {
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
            delete stakes[_stakeholder];
        }
    }

    function addStake(address _stakeholder, uint256 _tokenId) internal {
        (bool _isStaked, ) = isStaked(_tokenId);
        if (!_isStaked) {
            stakedtokens.push(_tokenId);
            stakes[_stakeholder].tokens.push(_tokenId);
            stakes[_stakeholder].timestamps.push(block.timestamp);
        }
    }

    function removeStake(address _stakeholder, uint256 _tokenId) internal {
        (bool _isStaked, uint256 s) = isStaked(_tokenId);
        if (_isStaked) {
            stakedtokens[s] = stakedtokens[stakedtokens.length - 1];
            stakedtokens.pop();
            for (
                uint256 i = 0;
                i < stakes[_stakeholder].tokens.length;
                i += 1
            ) {
                if (_tokenId == stakes[_stakeholder].tokens[i]) {
                    stakes[_stakeholder].tokens[i] = stakes[_stakeholder]
                        .tokens[stakes[_stakeholder].tokens.length - 1];
                    stakes[_stakeholder].tokens.pop();
                    stakes[_stakeholder].timestamps[i] = stakes[_stakeholder]
                        .timestamps[stakes[_stakeholder].timestamps.length - 1];
                    stakes[_stakeholder].timestamps.pop();
                }
            }
        }
    }

    function stakeNFTs(uint256[] memory tokenIds) public {
        if (!stakes[msg.sender].exists) addStakeholder(msg.sender);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                nft.ownerOf(tokenIds[i]) == msg.sender,
                "You do not own this NFT."
            );
            require(
                nft.isApprovedForAll(msg.sender, address(this)),
                "This contract is not approved to transfer your NFT."
            );
            addStake(msg.sender, tokenIds[i]);
            nft.safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }
    }

    function unstakeNFTs(uint256[] memory tokenIds) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                stakes[msg.sender].tokens.length > 0,
                "You don't have any NFTs staked."
            );
            require(
                isClaimable(tokenIds[i]) == true,
                "You do not own this NFT."
            );
            removeStake(msg.sender, tokenIds[i]);
            nft.safeTransferFrom(address(this), msg.sender, tokenIds[i]);
            emit Claimed(msg.sender, tokenIds[i]);
        }
        if (stakes[msg.sender].tokens.length == 0)
            removeStakeholder(msg.sender);
    }

    function stakeOf(address _stakeholder)
        public
        view
        returns (uint256[] memory)
    {
        return stakes[_stakeholder].tokens;
    }

    function stakeTimestampsOf(address _stakeholder)
        public
        view
        returns (uint256[] memory)
    {
        return stakes[_stakeholder].timestamps;
    }

    function totalStakes() public view returns (uint256) {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            _totalStakes = _totalStakes.add(
                stakes[stakeholders[s]].tokens.length
            );
        }
        return _totalStakes;
    }

    function rewardOf(address _stakeholder) public view returns (uint256) {
        return rewards[_stakeholder];
    }

    function totalRewards() public view returns (uint256) {
        uint256 _totalRewards = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
        }
        return _totalRewards;
    }

    function calculateReward(address _stakeholder)
        public
        view
        returns (uint256)
    {
        uint256 staked = 0;
        for (
            uint256 t = 0;
            t < stakes[_stakeholder].timestamps.length;
            t += 1
        ) {
            if (stakes[_stakeholder].timestamps[t] <= epochStartTime) {
                staked = staked.add(1);
            }
        }
        return stakingReward.mul(staked);
    }

    function distributeRewards() public onlyOwner {
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
        epochStartTime = block.timestamp;
    }

    function withdrawReward() public {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward.mul(10**18));
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        uint256 wallet1Balance = balance.mul(10).div(100);
        uint256 wallet2Balance = balance.mul(85).div(100);
        payable(WALLET1).transfer(wallet1Balance);
        payable(WALLET2).transfer(wallet2Balance);
        payable(msg.sender).transfer(
            balance.sub(wallet1Balance.add(wallet2Balance))
        );
    }
}